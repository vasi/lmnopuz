# Adapt xwordinfo.com HTML to the Crossword class
#
# TODO: circles, charset, comment

require 'rubypuz/puz'
require 'nokogiri'

class XPFCrossword < Crossword
	attr_reader :key_hash
	
	XPF_BLACK = '.'
	XPF_MISSING = '~'
	XPF_UNFILLED = ' ' # TODO: Check that we have none
	
	# ignore checksum
	def parse(file, checksum = false)
		xml = Nokogiri.XML(file)
		doc = xml.at('Puzzle') || xml.at('Crossword') # TODO: Multiple puzzles?
		@key_hash = doc.to_s.hash
		
		@title = doc.at('Title').inner_text
		@author = doc.at('Author').inner_text
		@copyright = %w[Copyright Publisher].map { |k| doc.at(k) }.
			compact.first.inner_text
		# TODO: Date, Editor, Type?
		
		@height = doc.at('Size/Rows').inner_text.to_i
		@width = doc.at('Size/Cols').inner_text.to_i
		sq = doc.search('Grid/Row').map do |row|
			row.inner_text.split('').map do |c|
				if c == XPF_BLACK || c == XPF_MISSING
					nil # TODO: Handle missing, blank?
				else
					s = Square.new
					s.answer = c
					s
				end
			end
		end
		@squares = sq[0].zip *sq[1..-1] # transpose
		
		@down = {}
		@across = {}
		if doc.name == "Puzzle"
			doc.search('Clues/Clue').each do |clue|
				row, col, num, dir, ans = *%w[Row Col Num Dir Ans].
					map { |k| clue[k] }
				row, col, num = *[row, col, num].map { |a| a.to_i }
				dir = dir.downcase.to_sym
				@squares[col - 1][row - 1].__send__("#{dir}=", num)
				__send__(dir)[num] = clue.inner_text
				# TODO: Do something with ans (rebus?)
			end
		else
			assign_clues(doc)
		end
		
		# TODO: Rebus, Notepad, Circle, Shade
	end

	# Allows x, y to be outside range!
	private def has_letter(x, y)
		return false if x < 0 || y < 0
		return false if x >= @width || y >= @height
		!@squares[x][y].nil?
	end

	def assign_clues(doc)
		clues_across = doc.search('Across/Clue')
		clues_down = doc.search('Down/Clue')

		clues_across.each do |clue|
			@across[clue['Num'].to_i] = clue.inner_text
		end
		clues_down.each do |clue|
			@down[clue['Num'].to_i] = clue.inner_text
		end

		# Allocate clue numbers. A square gets a number if it starts an answer,
		# and doesn't end one.
		num = 1
		(0...@height).each do |y|
			(0...@width).each do |x|
				has_across = !has_letter(x - 1, y) && has_letter(x, y) && has_letter(x + 1, y)
				@squares[x][y].across = num if has_across
				has_down = !has_letter(x, y - 1) && has_letter(x, y) && has_letter(x, y + 1)
				@squares[x][y].down = num if has_down
				num += 1 if has_across || has_down
			end
		end
	end
end
