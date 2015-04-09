class Downloader
  def self.wanted(argv)
    [Cyberpresse.new, Jonesin.new, LATimes.new]
  end
end
