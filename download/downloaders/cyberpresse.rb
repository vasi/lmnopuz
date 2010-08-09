class Cyberpresse < Downloader
  def date_pattern; 'cp%j'; end
  def extension; 'cyberpresse'; end
  
  def oldest
    # Only 7 days available
    Date.today - 8
  end
  def newest; Date.today - 1; end
  
  class Download < Downloader::Download
    def day; Date.today - date - 1; end
    
    def uri
      "http://www.ludipresse.com/cgi-bin/CGI_FLASH/cyber.cgi?#{day}B12345"
    end
    
    # day-of-year might be inconsistent?
    def yday
      # download is forced
      @yday ||= CGI.parse(text)['grille_num'].first.rjust(3, '0')
    end
    
    def filename
      text # ensure download
      'cp%s.%s' % [yday, downloader.extension]
    end
    
    OLD_FILE_AGE = 30 # days
    
    # Could be present from last year!
    def want?
      super || (Date.today - path.mtime.to_date) > OLD_FILE_AGE
    end
  end
end
