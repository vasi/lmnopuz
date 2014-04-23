class Downloader
  def self.wanted(argv)
    [Cyberpresse.new, Jonesin.new, LATimes.new, WaPo.new]
  end
end
