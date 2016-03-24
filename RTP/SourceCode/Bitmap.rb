# encoding: UTF-8

#--------------------------------------------------------------------------------------------------------------------------------
#	class Bitmap:	
#	
#	Sprite wich can be extended
#	
#--------------------------------------------------------------------------------------------------------------------------------


class Bitmap
	
	attr_accessor :x, :y, :length, :height, :angle, :opacity
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, image, x, y, length, height, angle = 0, color = Gosu::Color.new(255, 255, 255), opacity = 255) # integer
		@image, @x, @y, @length, @height, @angle, @opacity = image, x, y, length, height, angle, opacity
		@color = Gosu::Color.new(@opacity, color.red, color.green, color.blue)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw(x = @x, y = @y, z = 0, length = @length, height = @height, opacity = @opacity, angle = @angle)
		d_length = (@angle == 0 || @angle == 180) ? (Float(length) / @length) : (Float(length) / @length)
		d_height = (@angle == 0 || @angle == 180) ? (Float(height) / @height) : (Float(height) / @height)

		if opacity != @opacity
			@color = Gosu::Color.new(opacity, @color.red, @color.green, @color.blue)
			@opacity = opacity
		end

		@image.draw_rot(x, y, z, @angle, 0.0, 0.0, d_length, d_height, @color, :default)
	end
end