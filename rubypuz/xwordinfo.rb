# Adapt xwordinfo.com HTML to the Crossword class
#
# TODO: circles, charset, comment

require 'rubypuz/puz'
require 'nokogiri'

class XWordInfoCrossword < Crossword
	attr_reader :key_hash
	
	# ignore checksum parameter, it's meaningless for XWordInfo
	def parse(file, checksum = false)
		doc = Nokogiri::HTML(file)
		@key_hash = doc.to_s.hash
		cph = proc { |n| doc.css("\#CPHContent_#{n}") }
		
		@title = cph['TitleLabel'].inner_text
		@author = cph['AuthorLabel'].inner_text
		@copyright = cph['Copyright'].inner_text
		
		# Get the clues
		%w[across down].each do |dir|
			clues = instance_variable_set("@#{dir}", Hash.new)
			
			elems = cph["#{dir.capitalize}Clues"].children
			until elems.empty?
				clue_elems = []
				while e = elems.shift
					break if Nokogiri::XML::Element === e && e.name == "br"
					clue_elems << e
				end
				
				clue_elem, ans_elem = clue_elems
				md = clue_elem.to_s.match(/^(\d+)\.\s*(.+?)[\s:]*$/) \
					or raise FailedParseException, "can't parse clue: '#{clue_elem}'"				
				num = md[1].to_i
				clue = md[2]
				
				clues[num] = clue
			end
		end
		
		# Get the squares
		table = cph['PuzTable']
		rows = table.search('tr')
		@height = rows.size
		rows.each_with_index do |row, ri|
			cols = row.search('td')
			unless defined? @width # initialize squares array
				@width = cols.size
				@squares = Array.new(@width) { Array.new(@height) }
			end
			
			cols.each_with_index do |cell, ci|
				next if cell.children.empty? # blank square
				sq = @squares[ci][ri] = Square.new
				
				# Get the square's numbers
				num = cell.search('.num').remove.inner_text
				unless num.empty?
					num = num.to_i
					sq.down = num if @down.include?(num)
					sq.across = num if @across.include?(num)
				end
				
				sq.answer = cell.inner_text # TODO: rebus?
				sq.answer = SQUARE_UNKNOWN if sq.answer == "\302\240" # non-break space
			end
		end
	end
end

