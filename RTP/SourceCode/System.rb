# encoding: UTF-8

class System
	attr_accessor 	:name,
				:screen_x,
				:screen_y,
				:full_screen,
				:title_type,
				:title_background,
				:title_text,
				:title_logo,
				:title_commands,
				:title_commands_type,
				:title_max_commands,
				:title_commands_position,
				:window_skins,
				:colors,
				:launcher_caption,
				:launcher_background,
				:launcher_windowskin,
				:launcher_resolution,
				:launcher_mode
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize()
		@name = {}
		@screen_x = 640
		@screen_y = 480
		@full_screen = false
		default_window = Window_skin.new("Default-RTP")
		@window_skins = [default_window]
		black_color = {"name" => String_lang::get({"fr" => "Noir", "eng" => "Black"}), "color" => [0,0,0]}
		white_color = {"name" => String_lang::get({"fr" => "Blanc", "eng" => "White"}), "color" => [255,255,255]}
		@colors = [black_color, white_color]
		@launcher_caption = {"eng" => "Welcome !", "fr" => "Bienvenue !"}
		@launcher_background = [{"eng" => "Title_screen", "fr" => "Title_screen"}, 0, 0]
		@launcher_windowskin = 0
		@launcher_resolution = true
		@launcher_mode = true
		
		@title_type = 1
		@title_background = [{"eng" => "Title_screen", "fr" => "Title_screen"}, 0, 0]
		@title_text = [{"eng" => "Press_start_eng", "fr" => "Press_start_fr"}, 150, 380]
		@title_logo = [{"eng" => "Logo", "fr" => "Logo"}, 0, 0]
		@title_commands = 	[
						{"name" => "New game"}, 
						{"name" => "Load game"}, 
						{"name" => "Exit"}
					]
		@title_commands_type = 0
		@title_max_commands = 3
		@title_commands_position = [200,300]
	end
end


