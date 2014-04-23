require 'rubygems'

require 'active_record'

require 'rubypuz/puz'
require 'rubypuz/xwordinfo'
require 'rubypuz/xpf'
require 'rubypuz/jpz'
require 'rubypuz/cyber'

require 'download/downloader'


class CrosswordEntry < ActiveRecord::Base
  serialize :crossword
  
  def date_readable
    date && date.strftime('%Y-%m-%d %a')
  end
  
  def title_readable
    parts = [source, date_readable, title].compact
    parts.empty? ? name : parts.join(' - ')
  end
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
    
    obj = { :name => name,
            :title => crossword.title,
            :filename => pathname.to_s,
            :crossword => crossword }
    rec = Downloader.recognize(name, crossword)
    obj.merge!(rec) if rec
    
    CrosswordEntry.create(obj)
  end

  def in_order
    CrosswordEntry.find(:all, :order => 'source, date, title',
        :select => 'name, title, source, date').map do |ce|
      [ce.name, ce.title_readable]
    end
  end

  def include? name
    CrosswordEntry.exists?(:name => name)
  end
  
  def get_crossword name
    get_entry(name).crossword
  end
  def get_entry name
    CrosswordEntry.find_by_name(name)
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
