require 'active_record'

require 'rubypuz/puz'
require 'rubypuz/xwordinfo'
require 'rubypuz/xpf'
require 'rubypuz/cyber'

# CrosswordStore supplies the actual crossword data, allowing enumerating
# crosswords and fetching a given crossword by name.
class CrosswordStore
  attr_reader :crosswords

  def initialize(datapath)
    refresh(datapath)
  end

  def refresh(datapath)
    # All available crosswords, mapping file basename => Puz obj
    @crosswords = {}
    load_crosswords datapath
  end

  # Load all the crosswords found in the datadir path.
  def load_crosswords(datapath)
    print "Loading crosswords... "; $stdout.flush
    crossword_count = 0
    Dir["#{datapath}/*"].sort.each do |path|
	  name = load_crossword(path) or next
      print "#{name} "; $stdout.flush
      crossword_count += 1
    end
    if crossword_count < 1
      puts "no crosswords found.  (Specify a data path with --data.)"
      exit 1
    else
      puts  # finish off "loading..." line.
    end
  end

  # Load a single crossword into @crosswords hash, return the name
  def load_crossword(path)
	ext = File.extname(File.basename(path)) # extname can fail on some full paths
	types = {
		'.puz' => Crossword,
		'.xwordinfo' => XWordInfoCrossword,
		'.xpf' => XPFCrossword,
		'.cyberpresse' => CyberpresseCrossword
	} # TODO: registry
	klass = types[ext] or return nil # not a crossword
	name = File.basename(path, ext)
	
    crossword = klass.new
    File::open(path) { |f| crossword.parse(f) }
    @crosswords[name] = crossword
    return name
  end

  def in_order
    @crosswords.to_a.sort_by { |name, crossword| crossword.title }
  end

  def include? cw
    @crosswords.has_key? cw
  end
  def get_crossword cw
    @crosswords[cw]
  end
end
