require 'open-uri'

class Downloader
  class Download
    attr_reader :date, :downloader, :datadir
    
    def initialize(dler, datadir, date)
      @downloader = dler
      @datadir = datadir
      @date = date
    end
    def uri; end
    def validate?(text = nil); true; end # Is the download a valid crossword?
    
    def filename
      '%s.%s' % [date.strftime(downloader.date_pattern), downloader.extension]
    end
    def path; Pathname.new(datadir) + filename; end
    
    def open_args; {}; end
    def text; @text ||= download_text; end
    def download_text
      begin
        open(uri, open_args).read
      rescue OpenURI::HTTPError => e
        raise CrosswordStore::InvalidCrossword.new("Download failed: #{e}")
      end
    end
    
    def download
      validate? or raise CrosswordStore::InvalidCrossword.new('Validation failed')
      t = text
      path.open('w') { |f| f.write(t) }
      return path.realpath
    end
    
    def want?; !path.file?; end
  end
  
  def date_pattern; end
  def extension; 'puz'; end  
  def newest; Date.today; end
  def self.wanted(argv); []; end # Downloaders to use
  
  def oldest
    likepat = date_pattern.gsub(/(%[^%])/, '%').gsub(/%%/, '%')
    ce = CrosswordEntry.find(:first,
      :conditions => ['name like ?', likepat],
      :order => 'name desc',
      :select => 'name'
    ) or return Date.today - initial_days + 1
    Date.strptime(ce.name, date_pattern)
  end
  
  DEFAULT_INITIAL_DAYS = 7
  
  attr_reader :initial_days
  
  def initialize(opts = {})
    @initial_days = opts[:initial_days] || DEFAULT_INITIAL_DAYS
    @oldest = opts[:oldest] || self.oldest
  end
  
  def update(store)
    oldest.upto(newest) do |date|
      begin
        download_date(store, date)
      rescue CrosswordStore::InvalidCrossword => inv
        puts "#{self.class.name} update failed for #{date}: #{inv}"
      end
    end
  end
  
  def download_date(store, date)
    dl = self.class.const_get(:Download).new(self, store.datadir, date)
    dl.want? or return
    path = dl.download
    store.load_crossword(path, true) # overwrite old ones
  end
  
  def self.load_downloaders
    Pathname.new(__FILE__).parent.join('downloaders').children.grep(/\.rb$/).
      each { |f| require f }
  end
  
  def self.update_all(argv, store)
    self.wanted(argv).each { |d| d.update(store) }
  end
end
