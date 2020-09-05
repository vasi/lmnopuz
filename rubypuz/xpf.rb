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
		doc.search('Clues/Clue').each do |clue|
			row, col, num, dir, ans = *%w[Row Col Num Dir Ans].
				map { |k| clue[k] }
			row, col, num = *[row, col, num].map { |a| a.to_i } 
			dir = dir.downcase.to_sym
			@squares[col - 1][row - 1].__send__("#{dir}=", num)
			__send__(dir)[num] = clue.inner_text
			# TODO: Do something with ans (rebus?)
		end
		
		# TODO: Rebus, Notepad, Circle, Shade
	end
end

