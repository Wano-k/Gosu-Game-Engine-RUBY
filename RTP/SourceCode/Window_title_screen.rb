# encoding: UTF-8

#--------------------------------------------------------------------------------------------------------------------------------
#
#	[CLASS] Window_title_screen
#
#	Display title screen.
#
#--------------------------------------------------------------------------------------------------------------------------------


class Window_title_screen
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window)
		@window = window
		
		# Sprites
		@sprite_title_screen = Sprite.create(@window, @window.im.title[$game_system.title_background[0][$lang]], $game_system.title_background[1], $game_system.title_background[2])
		@sprite_title_logo = Sprite.create(@window, @window.im.title[$game_system.title_logo[0][$lang]], $game_system.title_logo[1], $game_system.title_logo[2])
		@sprite_title_press = Sprite.create(@window, @window.im.title[$game_system.title_text[0][$lang]], $game_system.title_text[1], $game_system.title_text[2])
		@sprite_title_press.opacity = 0 if @title_press != nil
		
		# Press display
		@display_press = ($game_system.title_type == 1)
		@reduce_opacity = false
		if !@display_press
			@window_commands = Window_choice.new(@window, 275, 300, 0, 100, 30, ["New game", "Load game", "Exit"])
		end
		# Step
		@step = 1
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id) 
		if id == Gosu::KbSpace and @step == 1
			new_game()
		elsif id == Gosu::KbSpace 
			@step = 1
		end
		
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_up
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_up(id) 
		
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	display_press_start
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def display_press_start
		if @sprite_title_press.opacity < 255 and !@reduce_opacity
			@sprite_title_press.opacity += 5
		elsif @sprite_title_press.opacity == 255 and !@reduce_opacity
			@reduce_opacity = true
		elsif @sprite_title_press.opacity > 0 and @reduce_opacity
			@sprite_title_press.opacity -= 5
		elsif  @sprite_title_press.opacity == 0 and @reduce_opacity
			@reduce_opacity = false
		end
		@sprite_title_press.draw()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	new_game
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def new_game()
		
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw
		@sprite_title_screen.draw() if @sprite_title_screen != nil
		
		if (@step == 1)
			@sprite_title_logo.draw() if @sprite_title_logo != nil
			display_press_start if @display_press and @sprite_title_press != nil
		end
		
		@window_commands.draw if !@display_press
	end
end