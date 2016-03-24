# encoding: UTF-8

class Window_choice
	
	attr_reader :x, :y, :texts
	attr_accessor :button, :index, :active
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, x, y, z, length, width, texts, font_name = $font_name, font_size = $font_size, opacity = 255, back_opacity = 255, last_x = false, index = 0, align = :center, active = true, active_grey = true, type = 0, window_skin = 0) # type = 0: vertical type = 1: horrizontal
		@window, @x_p, @y_p, @z, @length, @width, @texts, @font_name, @font_size, @opacity, @back_opacity, @last_x, @index, @align, @active, @active_grey, @x, @y, @type, @window_skin = window, x, y, z, length, width, texts, font_name, font_size, opacity, back_opacity, last_x, index, align, active, active_grey, x, y, type, window_skin
		redef(texts)
		@count = 0
		@sous_count = 0
		@repeat = nil
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	BUTTON DOWN
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id) 
		return if !@active
		if @sous_count > 0
			@sous_count += 1
			@sous_count = @sous_count%6
			return
		end
		@repeat = id
		@sous_count += 1
		
		case id
			when Gosu::KbDown
				if @type == 0
					Gosu::Sample.new(@window, "Audio/Effect/Switch.ogg").play()
					@index += 1
					@index = @index % @nb
				end
			when Gosu::KbUp
				if @type == 0
					Gosu::Sample.new(@window, "Audio/Effect/Switch.ogg").play()
					@index -= 1
					@index = @index % @nb
				end
			when Gosu::KbRight
				if @type == 1
					Gosu::Sample.new(@window, "Audio/Effect/Switch.ogg").play()
					@index += 1
					@index = @index % @nb
				end
			when Gosu::KbLeft
				if @type == 1
					Gosu::Sample.new(@window, "Audio/Effect/Switch.ogg").play()
					@index -= 1
					@index = @index % @nb
				end
			when Gosu::KbSpace
				@button = @index
			when Gosu::KbX
				@button = @nb-1 if @last_x
		end
		@y = @y_p + (@width*@index)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	BUTTON UP
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_up(id)
		@repeat = nil
		@count = 0
		@sous_count = 0
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	SET TEXT
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_text(texts)
		@texts = texts
		if @nb == @texts.size
			for i in 0..(@nb-1)
				@window_choice[i].set_text(texts[i])
			end
		else
			redef(texts)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	redef
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def redef(texts)
		@window_choice, @nb, @button = [], texts.size, nil
		if @type == 0
			for i in 0..(@nb-1)
				@window_choice[i] = Window_box.new(@window, @x_p, @y_p + (i*@width), @z, @length, @width, @texts[i], 0, 0, @align, @grey, @window_skin, @font_name, @font_size)
			end
		else
			for i in 0..(@nb-1)
				@window_choice[i] = Window_box.new(@window, @x_p + (i*@length), @y_p, @z, @length, @width, @texts[i], 0, 0, @align, @grey, @window_skin, @font_name, @font_size)
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set index last
	#--------------------------------------------------------------------------------------------------------------------------------
	def set_index_last
		@index = @nb-1
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	index_first?
	#--------------------------------------------------------------------------------------------------------------------------------
	def index_first?
		return @index == 0
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	index_last?
	#--------------------------------------------------------------------------------------------------------------------------------
	def index_last?
		return @index == @nb-1
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	activate
	#--------------------------------------------------------------------------------------------------------------------------------
	def activate
		@active = true
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	desactivate
	#--------------------------------------------------------------------------------------------------------------------------------
	def desactivate
		@active = false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	activate
	#--------------------------------------------------------------------------------------------------------------------------------
	def activate_grey
		@active_grey = true
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	desactivate
	#--------------------------------------------------------------------------------------------------------------------------------
	def desactivate_grey
		@active_grey = false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	desactivate
	#--------------------------------------------------------------------------------------------------------------------------------
	def size
		return @texts.size
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw(x = @x_p, y = @y_p, z = @z_p, time = 20, opacity = @opacity)
		move = (@type == 0) ? "@window_choice[i].move(@x_p, @y_p + (i*@width), @z, time, opacity)" : "@window_choice[i].move(@x_p + (i*@length), @y_p, @z, time, opacity)"
		if !@active_grey
			for i in 0..(@nb-1)
				@window_choice[i].grey = false
				eval(move)
			end
		else
			for i in 0..(@nb-1)
				if (i == @index)
					@window_choice[i].grey = true
				else
					@window_choice[i].grey = false
				end
				eval(move)
			end
		end
		@count += 1 if @repeat != nil
		button_down(@repeat) if (@count >= 20 and @repeat != nil)
	end
end 