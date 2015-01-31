require 'rubypuz/puz'
require 'cgi'

class CyberpresseCrossword < Crossword
	# ignore checksum parameter
	def parse(file, checksum = false)
		h = CGI.parse(file.read)
		@title = "Cyberpresse \##{h['grille_num'].first}"
		@copyright = @author = h['auteur'].first
		
		@width = h['maxX'].first.to_i
		@height = h['maxY'].first.to_i
		setup_grid(h['grilleCor'].first)
		
		place_clues(h, :across, 'h')
		place_clues(h, :down, 'v')
		
		place_numbers
	end
	
	def setup_grid(grid)
		@squares = Array.new(@width) do |x|
			Array.new(@height) do |y|
				letter = grid[y*@width + x, 1]
				if letter == ')'
					nil
				else
					sq = Square.new
					sq.answer = letter.upcase
					sq
				end
			end
		end
	end
	
	def place_clues(h, dir, pref)
		transf = dir == :down ? proc { |*x| x } : proc { |*x| x.reverse }
		imax, jmax = transf[@width, @height]
		(0...imax).each do |i|
			clues = parse_clues(h, pref, i)
			squares = (0...jmax).map { |j| transf[i, j] }.map { |x,y| @squares[x][y] }
			place_clues_row(dir, squares, clues)
		end
	end
	
	def place_clues_row(dir, squares, clues)
		rs = ranges(squares).select { |r| r.size >= 3 }.each do |r|
			# Temporarily put it here
			r.first.__send__("#{dir}=", clues.shift)
		end
	end
	
	def ranges(enum, &pred)
		pred ||= proc { |x| x }
		ret = []
		cur = nil
		enum.each do |x|
			if pred[x]
				(cur ||= []) << x
			else
				ret << cur if cur
				cur = nil
			end
		end
		ret << cur if cur
		ret		
	end
	
	def parse_clues(h, pref, idx)
		str = h[pref + (idx + 1).to_s].first.sub(/\.\s+$/, '')
		return str.split(' - ').map do |s|
			s.encode('UTF-8', "ISO-8859-1")
		end
	end
	
	def place_numbers
		@down = {}
		@across = {}
		num = 1
		each_square do |x, y, sq|
			next unless sq.down || sq.across
			if sq.down
				@down[num] = sq.down
				sq.down = num
			end
			if sq.across
				@across[num] = sq.across
				sq.across = num
			end
			num += 1
		end
	end
end

