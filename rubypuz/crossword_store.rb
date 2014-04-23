require 'rubygems'

require 'active_record'

require 'rubypuz/puz'
require 'rubypuz/xwordinfo'
require 'rubypuz/xpf'
require 'rubypuz/jpz'
require 'rubypuz/cyber'

class CrosswordEntry < ActiveRecord::Base
  serialize :crossword
end

class CrosswordStore
  class InvalidCrossword < Exception; end
  
  attr_reader :crosswords, :datadir

  def initialize(datapath = nil)
    ENV['DATADIR'] = (datapath ||= ENV['DATADIR']) or raise 'No DATADIR'
    @datadir = datapath
    load 'environment.rb'
  end

	CrosswordTypes = {
		'.puz' => Crossword,
		'.xwordinfo' => XWordInfoCrossword,
		'.xpf' => XPFCrossword,
		'.cyberpresse' => CyberpresseCrossword,
    '.jpz' => JPZCrossword,
	} # TODO: registry
  
  # Update database
  def load_crosswords
    entries = CrosswordEntry.find(:all, :select => 'id, name, created_on').
      inject({}) { |h,e| h[e.name] = e; h }
    
    dir = Pathname.new(@datadir)
    dir.children.sort.map { |p| p.realpath }.each do |path|
      next unless path.file?
      next unless CrosswordTypes.include?(path.extname)
      
      name = path.basename(path.extname).to_s
      if ce = entries[name]
        next if ce.created_on > path.mtime
        CrosswordEntry.delete(ce.id)
      end
	    load_crossword(path, false)
    end
  end

  def load_crossword(pathname, overwrite = true)
  	ext = pathname.extname
  	klass = CrosswordTypes[ext] or
  	  raise InvalidCrossword.new('Not a crossword')
  	name = pathname.basename(ext).to_s
    
    if overwrite && cw = CrosswordEntry.find_by_name(name)
      cw.delete
    end
    
    puts "Loading crossword #{name}"
    crossword = klass.new
    if crossword.respond_to?(:open)
      crossword.open(pathname.to_s)
    else
      pathname.open { |f| crossword.parse(f) }
    end
    
    CrosswordEntry.create(
      :name => name,
      :title => crossword.title,
      :filename => pathname.to_s,
      :crossword => crossword
    )
  end

  def in_order
    CrosswordEntry.find(:all, :order => 'title',
        :select => 'title, name').map do |ce|
      title = ce.title
      title = ce.name if title.empty?
      [ce.name, title]
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
