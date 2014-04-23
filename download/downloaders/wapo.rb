# Washington Post crosswords
class WaPo < Downloader
  def date_pattern; 'cs%y%m%d'; end
  def extension; 'jpz'; end
  def name; 'Washington Post'; end
  def title(cw); cw.title.scan(/"(.*)"/).flatten.first; end
  
  class Download < Downloader::Download
    def uri; "http://cdn.games.arkadiumhosted.com/washingtonpost/crossynergy/%s" % filename; end
  end
end
