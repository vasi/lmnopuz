# Washington Post crosswords
class WaPo < Downloader
  def date_pattern; 'cs%y%m%d'; end
  def extension; 'jpz'; end
  
  class Download < Downloader::Download
    def uri; "http://cdn.games.arkadiumhosted.com/washingtonpost/crossynergy/%s" % filename; end
  end
end
