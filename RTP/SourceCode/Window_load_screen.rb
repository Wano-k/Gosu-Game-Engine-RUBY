# encoding: UTF-8
# OLD CLOCKWORK CODE

class Window_load_screen
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	NEW
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window)
		@window = window
		@font = Gosu::Font.new(@window, $font_name, $font_size)
		
		# backward
		@title_screen = Sprite.create(@window, @window.im.title[$game_system.title_background[$lang]], 0, -520)
		#~ @black = Sprite.new(@window, @window.im.others_hud["black"], 0, 0, 5, 0, 1, 1, 0)
		#~ @white = Sprite.new(@window, @window.im.others_hud["white"], 0, 0, 50, 0, 1, 1, 0)
		
		#top
		#~ @top_bar = Window_box.new(@window, -400, 30, 0, 400, 30)
		#~ @top_string = String_lang::get({"fr" => "Sélectionnez une partie", "eng" => "Choose a game"})
		#~ @top_text = Text.new(@window, @top_string, -520, 37, 0, $font_name, $font_size, 2, 400, :center)
		
		# mid
		#~ @save_names = [nil, nil, nil, nil]
		#~ @is_save = [false, false, false, false]
		#~ @slots_windows = []
		#~ for i in 0..3
			#~ @save_names[i] = File.open("Data/save" + (i+1).to_s + ".txt", "r").readlines[0] 
			#~ if @save_names[i] == nil
				#~ @save_names[i] = String_lang::get({"fr" => "-vide-", "eng" => "-empty-"})
			#~ else
				#~ @is_save[i] = true
			#~ end
			#~ @slots_windows[i] = Window_box.new(@window, -50 + (i*15) -140, 150 + (i*50), 0, 140, 45, 255, 255, @save_names[i])
		#~ end
		#~ @slots_windows[0].grey = true
		#~ @cursor = Sprite.new(@window, @window.im.system["cursor"], -33, 155)
		
		# in a party
		#~ @window_fond = Window_box.new(@window, 990, 150, 0, 350, 200, 255, 100)
		#~ @window_line = Bitmap.new(@window, @window.im.line, 0, 8, 22, 6)
		#~ @reward_windows = []
		#~ for i in 0..9
			#~ floor = i >= 5 ? 1 : 0
			#~ index = i%5
			#~ @reward_windows[i] = Window_box.new(@window, 270 + (index*55), 230 + (floor*55), 0, 50, 50, 0)
		#~ end
		#~ @image_po = Sprite.new(@window, @window.im.icons["po"], 560, 170, 0, 0, 1, 1, 0)
		#~ @text_po = Text.new(@window, "0", 560 - @font.text_width("0"), 177, 0, $font_name, $font_size, 2, 130, :left)
		#~ @image_time = Sprite.new(@window, @window.im.icons["time"], 562, 190, 0, 0, 1, 1, 0)
		#~ @text_time = Text.new(@window, "00:00:00", 560 - @font.text_width("00:00:00"), 197, 0, $font_name, $font_size, 2, 130, :left)
					
		# bottom
		#~ @bot_bar = Window_box.new(@window, 480, 420, 0, 400, 30)
		#~ @bot_string = @is_save[0] ? String_lang::get({"fr" => "Appuyez sur ESPACE pour charger votre partie", "eng" => "Press SPACE to load your game"}) : String_lang::get({"fr" => "Appuyez sur ESPACE pour créer une nouvelle partie", "eng" => "Press SPACE to create a new game"})
		#~ @bot_text = Text.new(@window, @bot_string, 600, 427, 0, $font_name, $font_size, 2, 400, :center)
		
		# commands
		#~ @x_image = Sprite.new(@window, @window.im.system["toucheX"], 665, 425, 10)
		#~ @x_text = Text.new(@window, "Annuler", 555, 427, 10, $font_name, $font_size, 2, 100, :center)
		#~ @z_image = Sprite.new(@window, @window.im.system["toucheZ"], 645, 395)
		#~ @z_text = Text.new(@window, "Options", 640, 397, 10, $font_name, $font_size, 2, 100, :center)
		
		# data first party
		#~ charge_data(1) if @is_save[0]
		
		# Index
		@index = 0
		@step = 0
		
		# Flag
		@flag_button_down = false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	BUTTON DOWN
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id) 
		#~ return if !@flag_button_down
		
		#~ # Step 0: Select a party
		#~ if @step == 0 
			#~ case id
				#~ when Gosu::KbDown
					#~ Gosu::Sample.new(@window, "Audio/Effect/Switch.ogg").play()
					#~ @index += 1
					#~ @index = @index%4
					#~ change_informations
					#~ charge_data(@index+1) if @is_save[@index]
				#~ when Gosu::KbUp
					#~ Gosu::Sample.new(@window, "Audio/Effect/Switch.ogg").play()
					#~ @index -= 1
					#~ @index = @index%4
					#~ change_informations
					#~ charge_data(@index+1) if @is_save[@index]
				#~ when Gosu::KbX
					#~ @window.interface.type = "title"
				#~ when Gosu::KbW # Z
					#~ if @is_save[@index]
						#~ Gosu::Sample.new(@window, "Audio/Effect/Cursor.ogg").play()
						#~ @window_options = Window_options.new(@window)
						#~ @step = 3
					#~ end
				#~ when Gosu::KbSpace
					#~ if !@is_save[@index] # if create a new game
						#~ Gosu::Sample.new(@window, "Audio/Effect/Cursor.ogg").play()
						#~ @window_enter_name = Window_text_input.new(@window, 355, 180, 0, 140, 30)
						#~ @window.text_input = @window_enter_name.text_field
						#~ @x_image = Sprite.new(@window, @window.im.system["toucheECHAP"], 585, 425)
						#~ @step = 1
						#~ change_informations
					#~ else # if load a game
						#~ Gosu::Sample.new(@window, "Audio/Effect/Obtain.ogg").play()
						#~ @window.volume = 0
						#~ @window.time = 100
						#~ @step = 5
					#~ end
			#~ end
		#~ # Step 1: Enter name
		#~ elsif @step == 1
			#~ case id
				#~ when Gosu::KbEscape
					#~ Gosu::Sample.new(@window, "Audio/Effect/Cancel.ogg").play()
					#~ @x_image = Sprite.new(@window, @window.im.system["toucheX"], 585, 425)
					#~ @window_enter_name = nil
					#~ @step = 0
					#~ change_informations
				#~ when 28 # enter
					#~ text = @window_enter_name.text_field.text.strip
					#~ if text.size == 0
						#~ Gosu::Sample.new(@window, "Audio/Effect/Cancel.ogg").play()
						#~ return
					#~ end
					#~ Gosu::Sample.new(@window, "Audio/Effect/Obtain.ogg").play()
					#~ @save_names[@index] = text
					#~ @is_save[@index] = true
					#~ @slots_windows[@index].set_text(text)
					#~ write_new_game(@index+1)
					#~ charge_data(@index+1)
					#~ @x_image = Sprite.new(@window, @window.im.system["toucheECHAP"], 585, 425)
					#~ # change opacity
					#~ @sprites_heros[0].opacity = 0
					#~ @player_levels[0].opacity = 0
					#~ @image_po.opacity = 0
					#~ @text_po.opacity = 0
					#~ @image_time.opacity = 0
					#~ @text_time.opacity = 0
					#~ for i in 0..2
						#~ @reward_windows[i].opacity = 0
					#~ end
					#~ for i in 3..9
						#~ @reward_windows[i].opacity = 0
					#~ end
					#~ @frame = 0
					#~ @frame_duration = 0
					#~ @step = 2
					#~ @window_enter_name = nil
				#~ else
					#~ @window_enter_name.button_down(id) 
			#~ end
		#~ # Step 3: Options
		#~ elsif @step == 3
			#~ @window_options.button_down(id)
			#~ if id == Gosu::KbX and !@window_options.display
				#~ Gosu::Sample.new(@window, "Audio/Effect/Cancel.ogg").play()
				#~ @window_options = nil
				#~ @step = 0
			#~ end
		#~ end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	BUTTON UP
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_up(id) 
		#~ if @step == 1
			#~ @window_enter_name.button_up(id) 
		#~ elsif @step == 3
			#~ @window_options.button_up(id)
		#~ end 
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	ACTIVE MOVE
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def change_informations
		#~ if @step == 0
			#~ text_bot = @is_save[@index] ? String_lang::get({"fr" => "Appuyez sur ESPACE pour charger votre partie", "eng" => "Press SPACE to load your game"}) : String_lang::get({"fr" => "Appuyez sur ESPACE pour créer une nouvelle partie", "eng" => "Press SPACE to create a new game"})
			#~ text_top = String_lang::get({"fr" => "Sélectionnez une partie", "eng" => "Choose a game"})
		#~ elsif @step == 1
			#~ text_bot = String_lang::get({"fr" => "Appuyez sur ENTREE pour valider le nom de votre partie", "eng" => "Press ENTER to validate your game's name"})
			#~ text_top = String_lang::get({"fr" => "Entrez le nom de votre partie", "eng" => "Enter your game's name"})
		#~ end
		#~ if text_bot != @bot_string
			#~ @bot_text = Text.new(@window, text_bot, -400, 427, 0, $font_name, $font_size, 2, 400, :center)
			#~ @bot_string = text_bot
		#~ end
		#~ if text_top != @top_string
			#~ @top_text = Text.new(@window, text_top, 1040, 37, 0, $font_name, $font_size, 2, 400, :center)
			#~ @top_string = text_top
		#~ end
	end
	
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	WRITE NEW GAME
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def write_new_game(slot)
		#~ lines = File.open("Data/Battlers/Players/0.txt", "r").readlines
		
		#~ File.open("Data/save" + slot.to_s + ".txt", "w") do |line|  
			#~ # l.0 : party name 
			#~ line.puts @save_names[@index] 
			#~ # l.1 : 4 heros file animation 
			#~ line.puts "Pictures/Characters/edwin12.png$nil$nil$nil" 
			#~ # l.2 : levels 
			#~ line.puts "1$nil$nil$nil" 
			#~ # l.3 : Common caracteristics(po, rewards, time 
			#~ line.puts "0$[false, false, false, false, false, false, false, false, false, false]$00:00:00"
			#~ # l.4 : Map information(map name, ground color, position) 
			#~ line.puts "banon$Gosu::Color.new(110, 179, 93)$[0, 0, 0]"
			#~ # l.5 : Players objects
			#~ line.puts lines[0]
		#~ end  
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	DELETE PARTY
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def delete_party(slot)
		#~ File.delete("Data/save" + slot.to_s + ".txt")
		#~ File.new("Data/save" + slot.to_s + ".txt", "w")
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	CHARGE DATA
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def charge_data(slot)
		#~ lines = File.open("Data/save" + slot.to_s + ".txt", "r").readlines
		#~ @images_heros, @player_levels, @sprites_heros = [], [], []
		
		#~ path = lines[1].split("$")
		#~ level = lines[2].split("$")
		#~ common =  lines[3].split("$")

		#~ for i in 0..3
			#~ if path[i].chomp != "nil"
				#~ @images_heros[i] = @window.im.characters_hud[path[i].chomp]
				#~ @sprites_heros[i] = Sprite.new(@window, @images_heros[i][0], 260, 140, 0, 0, 1, 1, 0)
				#~ @player_levels[i] = Text.new(@window, "Nv. " + level[i].chomp, 260, 205, 0, $font_name, $font_size - 2, 2, 64, :center)
			#~ end
		#~ end
		
		#~ @string_po = common[0]
		#~ @text_po = Text.new(@window, @string_po, 560 - @font.text_width(@string_po), 177, 0, $font_name, $font_size, 2, 130, :left)
		#~ @string_time = common[2].chomp
		#~ @text_time = Text.new(@window, @string_time, 560 - @font.text_width(@string_time), 197, 0, $font_name, $font_size, 2, 130, :left)
	end
	#--------------------------------------------------------------------------------------------------------------------------------
	#	START PARTY
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def start_party(slot)
		#~ @window.party = Party.new(@window, slot) 
		#~ @window.party.update_rang
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	DRAW
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw
		#~ @black.move(0, 0, 5, 20, 0) if @step == 0
		
		#~ # Flag
		#~ @flag_button_down = true if @slots_windows[0].x == 90
		
		#~ # Update frame
		#~ if Gosu::milliseconds - @frame_tick >= @frame_duration
			#~ @frame += 1
			#~ @frame_duration += 10 if @step == 2 and @frame_duration < 160
			#~ @frame = 0 if @frame > 3
			#~ @frame_tick = Gosu::milliseconds
		#~ end
	
	
		#~ # Move title screen
		#~ time = @flag_button_down ? 20 : 50
		#~ @title_screen.move(0, -450 - (@index*15), 0, time) if @step != 1
		#~ @title_screen.move(0, -150, 0, 50) if @step == 1

		#~ # Move bars information
		#~ @top_bar.move(250, 30, 0, 30) 
		#~ @bot_bar.move(-10, 420, 0, 30)
		#~ @top_text.move(250, 37, 0, 30)
		#~ @bot_text.move(-10, 427, 0, 30)
		
		
		#~ # Move commands indication
		#~ @x_image.move(585, 425, 10, 10)
		#~ @x_text.move(510, 427, 10, 10)
		#~ if @is_save[@index]
			#~ @z_image.move(595, 395, 0, 10)
			#~ @z_text.move(520, 397, 0, 10)
		#~ else
			#~ @z_image.move(645, 395, 0, 10)
			#~ @z_text.move(640, 397, 0, 10)
		#~ end
		
		
		#~ # Move slots
		#~ for i in 0..3
			#~ slot_x, time = 50 - (i*15), 30
			#~ if @slots_windows[i].x >= slot_x
				#~ if i == @index and @slots_windows[i].x <= 90 - (i*15)
					#~ slot_x += 40
					#~ time = 10
					#~ @slots_windows[i].grey = true
				#~ end
				#~ if i != @index and @slots_windows[i].x > 50 - (i*15)
					#~ time = 10
					#~ @slots_windows[i].grey = false
				#~ end
			#~ end
			#~ @slots_windows[i].move(slot_x, 150 + (i*50), 0, time)
		#~ end
		
		
		#~ # Move cursor
		#~ @cursor.angle += 5
		#~ @cursor.angle = 0 if @cursor.angle == 360
		#~ time = @flag_button_down ? 10 : 30
		#~ @cursor.move(45 - (@index*15), 155 + (@index*50), 0, time)


		#~ # Move party informations
		#~ if @is_save[@index] and @step != 2
			#~ @window_fond.move(250, 150, 0, 20)
			#~ if !@window_fond.moving
				#~ party_number = @images_heros.size
				#~ bounce = (@frame == 1 or @frame == 3) ? 1 : 0
				#~ @window_line.draw(_x(229 - (15*@index)), _y(171 + (50*@index)), 0, _x(22 + (15*@index)), _y(6))
				#~ for i in 0..(party_number-1)
					#~ @sprites_heros[i].image = @images_heros[i][@frame]
					#~ @sprites_heros[i].draw(260, 140 + bounce, 0, 255)
					#~ @player_levels[i].draw(260, 205, 0, 255)
				#~ end
				#~ for i in 0..9
					#~ floor = i >= 5 ? 1 : 0
					#~ index = i%5
					#~ @reward_windows[i].draw(270 + (index*55), 230 + (floor*55), 0, 255)
				#~ end
				#~ @image_po.draw(560, 170, 0, 255)
				#~ @text_po.draw(560 - @font.text_width(@string_po), 177, 0, 255)
				#~ @image_time.draw(562, 190, 0, 255)
				#~ @text_time.draw(560 - @font.text_width(@string_time), 197, 0, 255)
			#~ end
		#~ else
			#~ @window_fond.move(990, 150, 0, 20) if (@step != 1 and @step != 2)
		#~ end

		#~ #-----------------------------------------------------------------
		#~ #	 // Other Steps //
		#~ #-----------------------------------------------------------------
		
		#~ # Step 1: entering name
		#~ if @step == 1 
			#~ @window_fond.move(250, 150, 0, 20)
			#~ if !@window_fond.moving
				#~ @window_line.draw(_x(229 - (15*@index)), _y(171 + (50*@index)), 0, _x(22 + (15*@index)), _y(6))
				#~ @window_enter_name.draw
			#~ end

		#~ # Step 2: creating party
		#~ elsif @step == 2
			#~ if @frame_duration == 160
				#~ @step = 0
				#~ change_informations
			#~ end
			#~ @window_fond.draw
			#~ @window_line.draw(_x(229 - (15*@index)), _y(171 + (50*@index)), 0, _x(22 + (15*@index)), _y(6))
			#~ @sprites_heros[0].image = @images_heros[0][@frame*4]
			#~ @sprites_heros[0].move(260, 140, 0, 50, 255)
			#~ @player_levels[0].move(260, 205, 0, 50, 255)
			#~ @image_po.move(560, 170, 0, 50, 255)
			#~ @text_po.move(561 - @font.text_width("0"), 177, 0, 50, 255)
			#~ @image_time.move(562, 190, 0, 50, 255)
			#~ @text_time.move(561 - @font.text_width("00:00:00"), 197, 0, 50, 255)
			#~ for i in 0..9
				#~ floor = i >= 5 ? 1 : 0
				#~ index = i%5
				#~ @reward_windows[i].move(270 + (index*55), 230 + (floor*55), 0, 50, 255)
			#~ end
		#~ # Step 3: options
		#~ elsif @step == 3
			#~ if @window_options.delete
				#~ delete_party(@index+1)
				#~ @window_options = nil
				#~ @is_save[@index] = false
				#~ @slots_windows[@index].set_text("vide")
				#~ @step = 0 
				#~ change_informations
			#~ else
				#~ @black.move(0, 0, 5, 20, 100)
				#~ @window_options.draw
			#~ end
		#~ # Step 5: load party
		#~ elsif @step == 5
			#~ @black.move(0, 0, 50, 100, 255)
			#~ if !@black.moving
				#~ start_party(@index+1) if !@white.moving
				#~ @window.volume = 0.7
				#~ @window.time = 50
			#~ end
		#~ end
	end
end