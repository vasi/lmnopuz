# Jonesin' crosswords
class Jonesin < Downloader
  def date_pattern; 'jz%y%m%d'; end
  def extension; 'puz'; end
  def name; "Jonesin' Crosswords"; end
  
  class Download < Downloader::Download
    def uri; "http://herbach.dnsalias.com/Jonesin/%s" % filename; end
	def want?; super && date.wday == 4; end # Thursday
  end
end
