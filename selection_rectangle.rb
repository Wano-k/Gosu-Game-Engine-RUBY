# encoding: UTF-8

#--------------------------------------------------------------------------------------------------------------------------------
#	class Bitmap:	
#	
#	Part of image system wich can be extended
#	
#--------------------------------------------------------------------------------------------------------------------------------


class Selection_rectangle
	
	attr_accessor :width, :height
	attr_reader :x, :y
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, x, y, width, height)
		@window, @x, @y, @width, @height = window, x, y, width, height
		@border_size, @dif_border = 4, 4
		@border_top_left, @border_top_right, @border_bot_right, @border_bot_left = create_corner(0), create_corner(90), create_corner(180), create_corner(270)
		@border_top, @border_right, @border_bot, @border_left = create_border(0), create_border(90), create_border(180), create_border(270)
		@real_x, @real_y = 0, 0
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	create_corner
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def create_corner(angle)
		return Bitmap.new(@window, @window.im.corner_selection, 0, 0, @border_size, @border_size, angle, Gosu::Color.new(255, 255, 255), 255)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	create_border
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def create_border(angle)
		return Bitmap.new(@window, @window.im.border_selection, 0, @border_size, 1, @dif_border, angle, Gosu::Color.new(255, 255, 255), 255)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_position
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_position(x, y)
		@x, @y = x, y
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_real_position
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_real_position()
		@x, @y = @real_x, @real_y
		@width = -@width if @width < 0
		@height = -@height if @height < 0
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_position
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_position()
		return [@x, @y]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_rect
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_rect()
		return [((@x-2)*($tile_size/32)).to_i, ((@y-80)*($tile_size/32)).to_i, (@width*($tile_size/32)).to_i, (@height*($tile_size/32)).to_i]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw(x_plus, y_plus, opacity)
		return if @width == 0 and @height == 0
		x = @x + x_plus
		x_width = 0
		if @width < 0
			x += @width + 32
			@width = -@width
			x_width= @width - 32
		end
		y = @y + y_plus
		y_height = 0
		if @height < 0
			y += @height + 32
			@height = -@height
			y_height = @height - 32
		end
		z = 0

		# borders_corner
		@border_top_left.draw(x, y, z, @border_size, @border_size, opacity)
		@border_top_right.draw(x+@width, y, z,@border_size, @border_size, opacity)
		@border_bot_right.draw(x+@width, y+@height, z, @border_size, @border_size, opacity)
		@border_bot_left.draw(x, y+@height, z, @border_size, @border_size, opacity)
		
		# borders
		@border_top.draw(x+@border_size, y, z, @width-(2*@border_size), @dif_border, opacity)
		@border_right.draw(x+@width, y+@border_size, z, @height-(2*@border_size), @dif_border, opacity)
		@border_bot.draw(x+@width-@border_size, y+@height, z, @width - (@border_size*2), @dif_border, opacity)
		@border_left.draw(x, y+@height-@border_size, z, @height-(2*@border_size), @dif_border, opacity)

		@real_x, @real_y = @x - x_width, @y - y_height
	end
end