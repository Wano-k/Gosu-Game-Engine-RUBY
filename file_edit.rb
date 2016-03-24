# encoding: UTF-8

class File_edit
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window)
		@window = window
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	insert lines
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.insert(file_location, lines, nb)
		tab = []
		File.open(file_location, "r:UTF-8").readlines.each do |line|  
			tab.push(line)
		end
		file = File.open(file_location, "w:UTF-8")
		for i in 0..tab.size
			if i < nb
				file.puts(tab[i])
			elsif i < nb + lines.size
				file.puts(lines[i-nb])
			else
				file.puts(tab[i-lines.size])
			end	
		end
		file.close
		
		return (tab.size+1)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	replace a line
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.replace(file_location, lines, nb)
		tab = []
		File.open(file_location, "r:UTF-8").readlines.each do |line|  
			tab.push(line)
		end

		File.open(file_location, "w:UTF-8") do |line|
			for i in 0..tab.size-1
				if i == nb
					line.puts lines
				else
					line.puts tab[i]
				end	
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	delete a line
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.delete(file_location, nb)
		tab = []
		File.open(file_location, "r:UTF-8").readlines.each do |line|  
			tab.push(line)
		end

		file = File.open(file_location, "w:UTF-8")
		for i in 0...tab.size
			file.puts(tab[i]) if i != nb
		end
		file.close
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	contains line
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.contains_line(file_location, line)
		i = 0
		File.open(file_location, "r:UTF-8").readlines.each do |line2| 
			return i if (line == line2.chomp)
			i += 1
		end
	
		return nil
	end
end