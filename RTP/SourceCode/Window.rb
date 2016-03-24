# encoding: UTF-8

#--------------------------------------------------------------------------------------------------------------------------------
#
#	[CLASS] Window
#
#	Main class, display the game.
#
#--------------------------------------------------------------------------------------------------------------------------------

class Window < Gosu::Window 
	
	attr_accessor 	:im, 					# Image Manager
				:hero, 				# Hero
				:map, 				# Map
				:camera, 				# Camera
				:party, 				# Party
				:interface, 				# Graphic Interface
				:interpreter, 			# Command Interpreter
				:move_tick, 			# Move tick
				:song, 				# Playing Song
				:volume, 				# Volume Song
				:time_song, 			# Time to set song volume
				:events, 				# Events
				:input, 				# Input
				:troops				# Troops
	 
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize()
		super($game_system.screen_x, $game_system.screen_y, $game_system.full_screen)
		self.caption = ""
		@im = Image_manager.new(self)
		@camera = nil
		@hero = nil
		@party = nil
		@map = nil
		@interface = Interface.new(self)
		@background_color = Gosu::Color.new(0, 0, 0)
		@last_time = Gosu::milliseconds
		@move_tick = Gosu::milliseconds
		@song, @volume, @time_song = nil, 0, 0
		@input = nil
		@frame = 0 
		@frame_tick = Gosu::milliseconds 
		@frame_duration = 160
		
		glEnable(GL_ALPHA_TEST)
		glEnable(GL_TEXTURE_2D)
		glAlphaFunc(GL_GREATER, 0)
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	needs_cursor?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def needs_cursor?
		return true
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id)
		exit if id == Gosu::KbF12
		
		@input.button_down(id) if @input != nil
		@camera.button_down(id) if @camera != nil
		@hero.button_down(id) if @hero != nil
		@interface.button_down(id)
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_up
	#--------------------------------------------------------------------------------------------------------------------------------
	 
	def button_up(id)
		@input.button_up(id) if @input != nil
		@camera.button_up(id) if @camera != nil
		@hero.button_up(id) if @hero != nil
		@interface.button_up(id)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update
		@move_tick = Gosu::milliseconds - @last_time
		@last_time = Gosu::milliseconds
		
		# Update frame
		if Gosu::milliseconds - @frame_tick >= @frame_duration
			@frame += 1
			@frame = 0 if @frame > 3
			@frame_tick = Gosu::milliseconds
		end	
		
		@camera.update	if @camera != nil
		@hero.update if @hero != nil
		self.caption = "Game - " + Gosu::fps.to_s + "FPS"
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------

	def draw
		gl do 
			glEnableClientState(GL_VERTEX_ARRAY) 
			glEnableClientState(GL_TEXTURE_COORD_ARRAY)
			glEnableClientState(GL_NORMAL_ARRAY) 
			glEnable(GL_TEXTURE_2D) 
			glEnable(GL_DEPTH_TEST) 
			@background_color = @map.ground if @map != nil
			color = @background_color
			glClearColor(color.red / 255.0, color.green / 255.0, color.blue / 255.0, 1.0) 
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) 
			@camera.look if @camera != nil
			@map.draw if @map != nil
			@hero.draw  if @hero != nil
			@interface.draw
		end
	end
end