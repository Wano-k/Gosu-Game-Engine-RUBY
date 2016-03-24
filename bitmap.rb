# encoding: UTF-8

#--------------------------------------------------------------------------------------------------------------------------------
#	class Bitmap:	
#	
#	Part of image system wich can be extended
#	
#--------------------------------------------------------------------------------------------------------------------------------


class Bitmap
	
	attr_accessor :opacity
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, image, position_x, position_y, length, width, angle = 0, color = Gosu::Color.new(255, 255, 255), opacity = 255) # integer
		@image, @length, @width, @angle, @opacity = image, length, width, angle, opacity
		@color = Gosu::Color.new(@opacity, color.red, color.green, color.blue)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw(x, y, z = 0, length = @length, width = @width, opacity = @opacity, angle = @angle)
		d_length = (@angle == 0 || @angle == 180) ? (Float(length) / @length) : (Float(length) / @length)
		d_width = (@angle == 0 || @angle == 180) ? (Float(width) / @width) : (Float(width) / @width)

		if opacity != @opacity
			@color = Gosu::Color.new(opacity, @color.red, @color.green, @color.blue)
			@opacity = opacity
		end

		@image.draw_rot(x, y, z, @angle, 0.0, 0.0, d_length, d_width, @color, :default)
	end
end