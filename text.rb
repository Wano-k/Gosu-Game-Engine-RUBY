# encoding: UTF-8

class Text
	
	attr_reader :moving, :text
	attr_accessor :x, :y, :z, :angle, :opacity, :image, :grise
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, text, x = 0, y = 0, z = 0, font_name = $font_name, font_size = $font_size, line_spacing = 2, max_width = 900, align = :left, angle = 0, opacity = 255, moving = false, contour = true, gris = false, color = nil)
		@window, @text, @x, @y, @z, @font_size, @line_spacing, @max_width, @angle, @opacity, @moving, @contour, @grise, @color = window, text, x, y, z, _xy(font_size), line_spacing, max_width, angle, opacity, moving, contour, grise, color
		@font = Gosu::Font.new(@window, font_name, _xy(font_size))
		@image = Gosu::Image.from_text(@window, text, font_name, @font_size, @line_spacing, @max_width, align)
		if @contour
			@contours = Array.new
			4.times do
				@contours.push(Text.new(@window, @text, x, y, z, font_name, font_size, line_spacing, max_width, align, angle, opacity, false, false))
			end
		end
		@x, @y = x, y
		@velocity = 100
		@offset_x, @offset_y = 0, 0
		@new_x, @new_y = 0, 0
		@time = -1
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_width
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_width
		@font.text_width(@text)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	move
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def move(x, y, z, time, opacity = @opacity) 
		# if already moved, just draw
		if ((@x == x and @y == y and @opacity == opacity) or time == 0)
			self.draw(x, y, z)
			return
		end
		
		# time
		if (time != 0 and @time == -1)
			@time = time
		end
		@time -= 1 if (@time > 0)
		
		# if the move is canceled
		if @new_x != x or @new_y != y
			@moving = false
		end
		
		# prepare offset
		if !@moving
			@offset_x, @offset_y, @offset_opacity = (x - @x)/ Float(time), (y - @y)/ Float(time), (opacity - @opacity)/ Float(time)
			@new_x, @new_y = x, y
			@moving = true
		end
		
		speed = (@velocity * @window.move_tick) / 1000.0
		offset_x = @offset_x * speed 
		offset_y = @offset_y * speed
		offset_opacity = @offset_opacity * speed

		# if end of move
		if ((((x - @x) >= 0 and (@x + offset_x) >= x) or ((x - @x) < 0 and (@x + offset_x) <= x)) and (((y - @y) >= 0 and (@y +(offset_y*2)) >= y) or ((y - @y) < 0 and (@y + (offset_y*2)) <= y)) and (((opacity - @opacity) >= 0 and (@opacity + offset_opacity) >= opacity) or ((opacity - @opacity) < 0 and (@opacity + offset_opacity) <= opacity))) or (@time == 0)
			self.draw(x, y, z, opacity)
			@time = -1
			@offset_x, @offset_y, @x, @y = 0, 0, x, y
			@moving = false
		# if moving, draw
		else 
			self.draw(@x + offset_x, @y + offset_y, z, @opacity + offset_opacity)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw(x = @x, y = @y, z = @z, opacity = @opacity)
		@x, @y, @opacity = x, y, opacity
		x, y = x, y
		if @contour
			@contours[0].image.draw(x+(@font_size/12), y, z, 1, 1, Gosu::Color.new(@opacity, 0, 0, 0))
			@contours[1].image.draw(x-(@font_size/12), y, z, 1, 1, Gosu::Color.new(@opacity, 0, 0, 0))
			@contours[2].image.draw(x, y+(@font_size/12), z, 1, 1, Gosu::Color.new(@opacity, 0, 0, 0))
			@contours[3].image.draw(x, y-(@font_size/12), z, 1, 1, Gosu::Color.new(@opacity, 0, 0, 0))
		end
		color = @grise ? Gosu::Color.new(@opacity, 150, 150, 150) : Gosu::Color.new(@opacity, 255, 255, 255)
		color = @color if @color != nil
		@image.draw(x, y, z, 1, 1, color)
	end
	
end