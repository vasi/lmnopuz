# LA Tribune crosswords
class LATribune < Downloader
  def date_pattern; 'lat%y%m%d'; end
  def extension; 'puz'; end
  
  class Download < Downloader::Download
    def open_args
      { 'Referer' => 'http://www.cruciverb.com/puzzles.php?op=showarch&pub=lat' }
    end
    def uri; "http://www.cruciverb.com/puzzles/lat/%s" % filename; end
  end
end
