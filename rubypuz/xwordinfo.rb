# Adapt xwordinfo.com HTML to the Crossword class
#
# TODO: circles, utf8, comment

require 'rubypuz/puz'
require 'hpricot'

class XWordInfoCrossword < Crossword
	attr_reader :key_hash
	
	# ignore checksum parameter, it's meaningless for XWordInfo
	def parse(file, checksum = false)
		doc = Hpricot(file)
		@key_hash = doc.to_s.hash
		
		@title = doc.at('#ctl00_CPHContent_TitleLabel').inner_text
		@author = doc.at('#xwauthor').inner_text
		@copyright = doc.at('#ctl00_CPHContent_Copyright').inner_text
		
		# Get the clues
		%w[across down].each do |dir|
			clues = instance_variable_set("@#{dir}", Hash.new)
			
			elems = doc.at("#ctl00_CPHContent_#{dir.capitalize}Clues").children
			until elems.empty?
				clue_elem, ans_elem, br = elems.slice!(0, 3)
				md = clue_elem.to_s.match(/^(\d+)\.\s*(.+?)[\s:]*$/) \
					or raise FailedParseException, "can't parse clue: '#{clue}'"				
				num = md[1].to_i
				clue = md[2]
				ans = ans_elem.inner_text # ignore
				
				clues[num] = clue
			end
		end
		
		# Get the squares
		table = doc.at('#ctl00_CPHContent_PuzTable')
		rows = table.search('tr')
		@height = rows.size
		rows.each_with_index do |row, ri|
			cols = row.search('td')
			unless defined? @width # initialize squares array
				@width = cols.size
				@squares = Array.new(@width) { Array.new(@height) }
			end
			
			cols.each_with_index do |cell, ci|
				next if cell.empty? # blank square
				sq = @squares[ci][ri] = Square.new
				
				# Get the square's numbers
				num = cell.search('.num').remove.inner_text
				unless num.empty?
					num = num.to_i
					sq.down = num if @down.include?(num)
					sq.across = num if @across.include?(num)
				end
				
				sq.answer = cell.inner_text # TODO: rebus?
			end
		end
	end
end
