require 'rubygems'

require 'active_record'

require 'rubypuz/puz'
require 'rubypuz/xwordinfo'
require 'rubypuz/xpf'
require 'rubypuz/cyber'

class CrosswordEntry < ActiveRecord::Base
  serialize :crossword
end

class CrosswordStore
  attr_reader :crosswords

  def initialize(datapath = nil)
    ENV['DATADIR'] = (datapath ||= ENV['DATADIR']) or raise 'No DATADIR'
    @datadir = datapath
    load './environment.rb'
  end

  # Update database
  def load_crosswords
    Dir["#@datadir/*"].sort.each do |path|
      path = Pathname.new(path).realpath
      next if path.extname == '.sqlite' # it's the db
      
      name = path.basename(path.extname).to_s
      if ce = CrosswordEntry.find_by_name(name)
        next if ce.created_on > path.mtime
        ce.delete
      end
	    load_crossword(path)
    end
  end

  def load_crossword(pathname)
  	types = {
  		'.puz' => Crossword,
  		'.xwordinfo' => XWordInfoCrossword,
  		'.xpf' => XPFCrossword,
  		'.cyberpresse' => CyberpresseCrossword
  	} # TODO: registry
  	
  	ext = pathname.extname
  	klass = types[ext] or raise "#{pathname.to_s} not a crossword"
  	name = pathname.basename(ext).to_s
    puts "Loading crossword #{name}"
	
    crossword = klass.new
    pathname.open { |f| crossword.parse(f) }
    
    CrosswordEntry.create(
      :name => name,
      :title => crossword.title,
      :filename => pathname.to_s,
      :crossword => crossword
    )
  end

  def in_order
    CrosswordEntry.find(:all, :order => 'title').map do |ce|
      [ce.name, ce.crossword]
    end
  end

  def include? name
    CrosswordEntry.exists?(:name => name)
  end
  
  def get_crossword name
    CrosswordEntry.find_by_name(name).crossword
  end
  
  def count
    CrosswordEntry.count
  end
  
  def first
    f = CrosswordEntry.first
    [f.crossword, f.name]
  end
end

if $0 == __FILE__
  store = CrosswordStore.new
  store.load_crosswords
end
