# encoding: UTF-8

class Sprite 
	
	attr_reader :moving
	attr_accessor :x, :y, :z, :angle, :zoom_x, :zoom_y, :opacity, :image
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	create
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.create(window, image, x = 0, y = 0, z = 0, angle = 0, zoom_x = 1, zoom_y = 1, opacity = 255, moving = false, in_tool_bar = false)
		if image != nil
			return Sprite.new(window, image, x, y, z, angle, zoom_x, zoom_y, opacity, moving, in_tool_bar)
		else
			return nil
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, image, x = 0, y = 0, z = 0, angle = 0, zoom_x = 1, zoom_y = 1, opacity = 255, moving = false, in_tool_bar = false)
		@window, @image, @x, @y, @z, @angle, @zoom_x, @zoom_y, @opacity, @moving, @in_tool_bar = window, image, x, y, z, angle, (image.height/Float(image.height))*zoom_x, (image.width/Float(image.width))*zoom_y, opacity, moving, in_tool_bar
		
		if @in_tool_bar
			@zoom_y = (_yDouble(image.height/Float(image.height)))*zoom_y
			@zoom_x = (_xDouble(image.width/Float(image.width)))*zoom_x
		end
		@velocity = 100
		@offset_x, @offset_y = 0, 0
		@new_x, @new_y = 0, 0
		@time = -1
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
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
		if ((((x - @x) >= 0 and (@x + offset_x) >= x) or ((x - @x) < 0 and (@x + offset_x) <= x)) and (((y - @y) >= 0 and (@y + (offset_y*2)) >= y) or ((y - @y) < 0 and (@y + (offset_y*2)) <= y)) and (((opacity - @opacity) >= 0 and (@opacity + offset_opacity) >= opacity) or ((opacity - @opacity) < 0 and (@opacity + offset_opacity) <= opacity))) or (@time == 0)
			self.draw(x, y, z, opacity)
			@offset_x, @offset_y, @x, @y = 0, 0, x, y
			@time = -1
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
		im_w = @in_tool_bar ? _x(@image.width/2) : @image.width/2
		im_h = @in_tool_bar ? _y(@image.height/2) : @image.height/2
		
		@image.draw_rot(x + im_w, y + im_h, z, @angle, 0.5, 0.5, @zoom_x, @zoom_y, Gosu::Color.new(@opacity, 255, 255, 255), :default)
	end
	
end