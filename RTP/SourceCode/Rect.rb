# encoding: UTF-8

class Rect
	
	attr_accessor :position_x, :position_y, :z, :length, :width, :color
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, position_x, position_y, z, length, width, color = nil) 
		@window, @position_x, @position_y, @z, @length, @width, @color = window, position_x, position_y, z, length, width, color
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_in_rect?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_in_rect?(coords)
		return (coords[0] >= @position_x and coords[0] <= (@position_x+@length) and coords[1] >= @position_y and coords[1] <= (@position_y+@width))
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw
		@window.draw_quad(@position_x, @position_y, @color, @position_x + @length, @position_y, @color, @position_x + @length, @position_y + @width, @color, @position_x, @position_y + @width, @color, @z, :default)
	end
end

class Rect_empty
	
	attr_accessor :position_x, :position_y, :z, :length, :width, :color
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, position_x, position_y, z, length, width, color, density = 1) 
		@window, @position_x, @position_y, @z, @length, @width, @color, @density = window, _x(position_x), _y(position_y), z, _x(length), _y(width), color, density
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw
		for i in 0...@density
			@window.draw_line(@position_x, @position_y+i, @color, @position_x+@length, @position_y+i, @color, 0, :default)
			@window.draw_line(@position_x+@length-i, @position_y, @color, @position_x+@length-i, @position_y+@width, @color, 0, :default)
			@window.draw_line(@position_x+@length, @position_y+@width-i, @color, @position_x, @position_y+@width-i, @color, 0, :default)
			@window.draw_line(@position_x+i, @position_y+@width, @color, @position_x+i, @position_y, @color, 0, :default)
		end
	end
end