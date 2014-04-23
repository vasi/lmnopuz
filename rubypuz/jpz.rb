require 'rubypuz/puz'
require 'nokogiri'
require 'zip'

class JPZCrossword < Crossword
  # Figure out if a clue list is down or accross
  def orientate(cw, clues, clue_hash)
    clue = clues.at('clue')
    word = cw.at_css('word#%s' % clue['word'])
    xrange = word['x'].include?('-')
    yrange = word['y'].include?('-')
    
    if xrange && !yrange
      @across = clue_hash
    elsif !xrange && yrange
      @down = clue_hash
    else
      raise "Can't orientate clue list"
    end
  end
  
  def open(filename)
    # May be a zip file, or raw xml
    entry = Zip::ZipInputStream.open(filename).get_next_entry
    io = entry ? entry.get_input_stream : File.open(filename)
    parse(io)
  end
  
	def parse(file, checksum = false)
    doc = Nokogiri.XML(file)
    doc.remove_namespaces!
    rect = doc.at('rectangular-puzzle')
    
    md = rect.at('metadata')
    @title = md.at('title').text
    @author = md.at('creator').text
    @copyright = md.at('copyright').text
    
    cw = rect.at('crossword')
    
    cw.search('clues').each do |clues|
      clue_hash = {}
      clues.search('clue').each { |c| clue_hash[c['number'].to_i] = c.text }
      orientate(cw, clues, clue_hash)
    end
    
    grid = cw.at('grid')
    @height = grid['height'].to_i
    @width = grid['width'].to_i
    @squares = Array.new(width) { Array.new(height) }
    grid.search('cell').each do |cell|
      square = Square.new
      square.answer = cell['solution'] or next
      if n = cell['number']
        n = n.to_i
        square.down = n if @down[n]
        square.across = n if @across[n]
      end
      
      x = cell['x'].to_i - 1
      y = cell['y'].to_i - 1
      @squares[x][y] = square
    end
  end
end

