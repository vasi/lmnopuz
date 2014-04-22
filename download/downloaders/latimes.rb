# LA Times crosswords
class LATimes < Downloader
  def date_pattern; 'lat%y%m%d'; end
  def extension; 'jpz'; end
  
  class Download < Downloader::Download
    def uri
      date.strftime("http://cdn.games.arkadiumhosted.com/latimes/assets/DailyCrossword/la%y%m%d.xml")
    end
  end
end
