# encoding: UTF-8

class Window_box
	
	attr_reader :moving, :offset_x, :text
	attr_accessor :x, :y, :opacity, :back_opacity, :grey, :length, :width
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, x, y, z, length, width, text = nil, opacity = 255, back_opacity = 255, align = :center, grey = false, window_skin = 0, font_name = $font_name, font_size = $font_size)
		@window, @x, @y, @z, @length, @width, @text, @opacity, @back_opacity, @align, @grey, @font_name, @font_size = window, x, y, z, length, width, text, opacity, back_opacity, align, grey, font_name, font_size
		@window_skin = $game_system.window_skins[window_skin]
		@offset_x, @offset_y, @offset_opacity = 0, 0, 0
		@border_top_left, @border_top_right, @border_bot_right, @border_bot_left = create_corner(0), create_corner(90), create_corner(180), create_corner(270)
		@border_top, @border_right, @border_bot, @border_left = create_border(0), create_border(90), create_border(180), create_border(270)
		@velocity = 100
		@moving = false
		@new_x, @new_y, @new_length = 0, 0, length
		@sprite_text = Text.new(@window, text, x, y + (width/2) - (font_size/2), @z, @font_name, @font_size, 2, length, align, 0, opacity, moving, true) if @text != nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	create_corner
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def create_corner(angle)
		img = @window.im.corner[0][0]
		return Bitmap.new(@window, img, 0, 0, img.width, img.height, angle, Gosu::Color.new(255, 255, 255), @opacity)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	create_border
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def create_border(angle)
		img = @window.im.border[0][0]
		return Bitmap.new(@window, img, 0, 0, img.width, img.height, angle, Gosu::Color.new(255, 255, 255), @opacity)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_text
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_text(text)
		@sprite_text = Text.new(@window, text, @x, @y + (@width/2) - (@font_size/2), @z, @font_name, @font_size, 2, @new_length, @align, 0, @opacity, @moving, true)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	move
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def move(x, y, z, time, opacity = @opacity) 
		# if already moved, just draw
		if @x == x and @y == y and @opacity == opacity
			self.draw(x, y, z)
			return
		end
		
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
		if (((x - @x) >= 0 and (@x + offset_x) >= x) or ((x - @x) < 0 and (@x + offset_x) <= x)) and (((y - @y) >= 0 and (@y + offset_y) >= y)) or ((y - @y) < 0 and (@y + offset_y) <= y) and (((opacity - @opacity) >= 0 and (@opacity + offset_opacity) >= opacity) or ((opacity - @opacity) < 0 and (@opacity + offset_opacity) <= opacity))
			self.draw(x, y, z)
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
	
	def draw(x = @x, y = @y, z = @z, opacity = @opacity, colors = nil)
		@x, @y, @opacity = x, y, opacity

		# back
		back_opacity = @back_opacity
		if opacity < 255
			back_opacity = opacity 
		elsif @back_opacity  < opacity 
			back_opacity = @back_opacity
		end
	        color = @grey ? Gosu::Color.new(back_opacity, 190, 120, 120) : Gosu::Color.new(back_opacity, 100, 100, 100)
		color = Gosu::Color.new(back_opacity, color[0], color[1], color[2]) if colors != nil
		dif_border = 2
		rect = Rect.new(@window, @x + dif_border, @y + dif_border, z, @length - (2*dif_border), @width - (2*dif_border), color)
		rect.draw
		
		# borders_corner
		@border_top_left.draw(@x, @y, z, @border_top_left.length, @border_top_left.height, opacity)
		@border_top_right.draw(@x+@length, @y, z, @border_top_right.length, @border_top_right.height, opacity)
		@border_bot_right.draw(@x+@length, @y+@width, z, @border_bot_right.length, @border_bot_right.height, opacity)
		@border_bot_left.draw(@x, @y+@width, z, @border_bot_left.length, @border_bot_left.height, opacity)
		
		# borders
		@border_top.draw(@x+@border_top_left.length, @y, z, @length-(@border_top_left.length+@border_top_right.length), @border_top.height, opacity)
		@border_right.draw(@x+@length, @y+@border_top_right.height, z, @width-(@border_top_right.height+@border_bot_right.height), @border_right.height, opacity)
		@border_bot.draw(@x+@length-@border_bot_left.length, @y+@width, z, @length-(@border_bot_left.length+@border_bot_right.length), @border_bot.height, opacity)
		@border_left.draw(@x, @y+@width-@border_top_left.height, z, @width-(@border_top_left.height+@border_bot_left.height), @border_left.height, opacity)
		
		# text
		@sprite_text.draw(@x, @y + (@width/2) - (@font_size/2), @z, opacity) if @text != nil
	end
end 