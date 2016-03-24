# encoding: UTF-8

class Interface
	
	attr_accessor :type, :hud, :block, :editor
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window)
		@window,  @type = window, nil
		@hud = Window_title_screen.new(@window)
		@editor = nil
		@block = true
	end
	
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id) 
		@hud.button_down(id) if @hud != nil
		
		case @type
			when "load_screen"
				@hud = Window_load_screen.new(@window)
			when "title"
				Gosu::Sample.new(@window, "Audio/Effect/Cancel.ogg").play()
				@hud = Window_title_screen.new(@window)
			when "message"
				@hud = Window_message.new(@window)
			when "battle"
				@hud = Battle.new(@window)
			when "choose_map"
				Gosu::Sample.new(@window, "Audio/Effect/Cursor.ogg").play()
				@hud = Choose_map.new(@window)
			when "editor"
				Gosu::Sample.new(@window, "Audio/Effect/Cursor.ogg").play()
				map_name = @hud.map_name
				@block = false
				@hud = Map_editor.new(@window, map_name)
			when "map"
				@hud = nil
				@block = false
			end
		@type = nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_up
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_up(id) 
		@hud.button_up(id) if @hud != nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw
		@hud.draw if @hud != nil
	end
end