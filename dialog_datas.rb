# encoding: UTF-8

class Dialog_datas < Wx::Dialog
	LIST_WIDTH = 174
	
	class Heroes < Wx::Panel
		def initialize(notebook, parent)
			super(notebook)
			
			set_own_background_colour(Wx::Colour.new(225,225, 245))
			left_side = Wx::BoxSizer.new(Wx::VERTICAL)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Héros", "eng" => "Heroes"}))
			list_inter = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [LIST_WIDTH, -1], Wx::LC_REPORT | Wx::LC_NO_HEADER)
			list_inter.insert_column(0, "head")
			list_inter.set_column_width(0, LIST_WIDTH-21)
			list_inter.insert_item(0,  "<> 001: Lucas")
			box1.add(list_inter,1, Wx::GROW )
			left_side.add(box1, 1, Wx::GROW)
			
			right_side = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, "")
			box1 = Wx::BoxSizer.new(Wx::VERTICAL)
			box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom", "eng" => "Name"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			name = LangButtonCtrl.new(self, {"eng" => "Lucas", "fr" => "Lucas"}, 135)
			name.set_own_background_colour($background_color)
			box1.add_spacer(2)
			box1.add(name, 0, Wx::GROW)
			box1.add_spacer(5)
			box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Classe", "eng" => "Class"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			class_name = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Combatant", "eng" => "Fighter"})])
			class_name.set_selection(0)
			box1.add_spacer(2)
			box1.add(class_name, 0, Wx::GROW)
			box1.add_spacer(5)
			box_lvl_1 = Wx::BoxSizer.new(Wx::VERTICAL)
			box_lvl_1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Niveau départ", "eng" => "Starting level"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			lvl_start = NumberCtrl.new(self, 0, 9999, 1, 1, 4, true, Wx::DEFAULT_POSITION, [57,-1])
			box_lvl_1.add_spacer(2)
			box_lvl_1.add(lvl_start)
			box_lvl_2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box_lvl_2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Niveau max", "eng" => "Max level"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			lvl_max = NumberCtrl.new(self, 0, 9999, 9999, 1, 4, true, Wx::DEFAULT_POSITION, [57,-1])
			box_lvl_2.add_spacer(2)
			box_lvl_2.add(lvl_max)
			box_lvl = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box_lvl.add(box_lvl_1, 1, Wx::GROW)
			box_lvl.add_spacer(10)
			box_lvl.add(box_lvl_2, 1, Wx::GROW)
			box1.add(box_lvl, 0, Wx::GROW)
			box_map = Wx::BoxSizer.new(Wx::VERTICAL)
			box_map.add_spacer(10)
			box_map.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Apparence sur carte", "eng" => "In map graphic"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box_map.add_spacer(2)
			graphic_map = Wx::Panel.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::SIMPLE_BORDER)
			graphic_map.set_own_background_colour(Wx::Colour.new(250,250, 250))
			box_map.add(graphic_map, 1, Wx::GROW)
			box1.add(box_map, 1, Wx::GROW)
			box_battle = Wx::BoxSizer.new(Wx::VERTICAL)
			box_battle.add_spacer(10)
			box_battle.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Apparence en combat", "eng" => "On battle graphic"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box_battle.add_spacer(2)
			graphic_battle = Wx::Panel.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::SIMPLE_BORDER)
			graphic_battle.set_own_background_colour(Wx::Colour.new(250,250, 250))
			box_battle.add(graphic_battle, 1, Wx::GROW)
			box1.add(box_battle, 1, Wx::GROW)
			
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box3 = Wx::BoxSizer.new(Wx::VERTICAL)
			right_side.add(box1, 1, Wx::ALL | Wx::GROW, 10)
			right_side.add(box2, 1, Wx::ALL | Wx::GROW, 10)
			right_side.add(box3, 1, Wx::ALL | Wx::GROW, 10)
			
			main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			main_sizer.add(left_side, 1, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(right_side, 3, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
		end
	end
	
	class Title_screen < Wx::Panel
		def initialize(notebook, parent)
			super(notebook)
			set_own_background_colour(Wx::Colour.new(225,225, 245))
			
			
			# Variables
			@choice_type = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Classique", "eng" => "Classic"}), String_lang::get({"fr" => "Appuyer sur start", "eng" => "Press start to play"})]); @choice_type.set_selection($game_system.title_type)
			@title_screen_apparence = TextButtonCtrl.new(self, Image_manager::text_image($game_system.title_background[0]), 140); @title_screen_apparence.values = $game_system.title_background; @title_screen_apparence.set_own_background_colour(Wx::Colour.new(225,225, 245))
			@text_apparence = TextButtonCtrl.new(self, Image_manager::text_image($game_system.title_text[0]), 140); @text_apparence.values = $game_system.title_text; @text_apparence.set_own_background_colour(Wx::Colour.new(225,225, 245))
			@title_logo = TextButtonCtrl.new(self, Image_manager::text_image($game_system.title_logo[0]), 140); @title_logo.values = $game_system.title_logo; @title_logo.set_own_background_colour($background_color)
			@video_intro = TextButtonCtrl.new(self, String_lang::get({"fr" => "Aucun(e)", "eng" => "None"}), 130); @video_intro.set_own_background_colour($background_color)
			@choice_video_transition = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, ["None"]); @choice_video_transition.set_selection(0)
			@list_commands = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::LC_REPORT | Wx::LC_NO_HEADER)
			@list_commands.insert_column(0, "head")
			@list_commands.set_column_width(0, -2)
			@commands_values = []
			i = 0
			$game_system.title_commands.each do |command|
				@list_commands.insert_item(i,  "<> " + command["name"])
				@commands_values.push(command)
				i += 1
			end
			@list_commands.insert_item(i,  "<> ")
			@choice_commands_type = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Boite de dialogue", "eng" => "Dialog box"}), "Images"]); @choice_commands_type.set_selection(0)
			@nb_commands = NumberCtrl.new(self, 1, 99, 3, 1, 4, true, Wx::DEFAULT_POSITION, [57,-1]); @nb_commands.set_own_background_colour($background_color)
			@commands_x = NumberCtrl.new(self, -9999, 9999, 0, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1]); @commands_x.set_own_background_colour($background_color)
			@commands_y = NumberCtrl.new(self, -9999, 9999, 0, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1]); @commands_y.set_own_background_colour($background_color)
			
			

			# top
			top = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, "Options")
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Genre", "eng" => "Type"}) + " :"), 0, Wx::GROW)
			box.add_spacer(2)
			box.add(@choice_type, 0, Wx::GROW)
			box1.add(box, 1, Wx::ALL | Wx::GROW, 5)
			top.add(box1, 1, Wx::GROW)
			
			# side 1
			box1 = Wx::BoxSizer.new(Wx::VERTICAL)
			side_1 = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Ecran principal", "eng" => "Main screen"}))
			h_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Fond", "eng" => "Background"}) + " :"), 0, Wx::GROW)
			box.add_spacer(2)
			box.add(@title_screen_apparence, 0, Wx::GROW)
			h_box.add(box, 1, Wx::GROW)
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Texte", "eng" => "Text"}) + " :"), 0, Wx::GROW)
			box.add_spacer(2)
			box.add(@text_apparence, 0, Wx::GROW)
			h_box.add(box, 1, Wx::GROW)
			box1.add(h_box, 0, Wx::GROW)
			box1.add_spacer(5)
			h_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(Wx::StaticText.new(self, Wx::ID_ANY, "Logo"), 0, Wx::GROW)
			box.add_spacer(2)
			box.add(@title_logo, 0, Wx::GROW)
			h_box.add(box, 1, Wx::GROW)
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			button = Wx::Button.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Faire défiler le fond", "eng" => "Scroll background"}) + "...", Wx::DEFAULT_POSITION, [-1, 20], Wx::BU_EXACTFIT)
			void = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(void, 1, Wx::GROW)
			box.add(button, 0, Wx::GROW)
			h_box.add(box, 1, Wx::GROW)
			box1.add(h_box, 0, Wx::GROW)
			box1.add_spacer(15)
			
			# Video
			box = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, String_lang::get({"fr" => "Vidéo d'introduction", "eng" => "Introduction video"}))
			h_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			v_box = Wx::BoxSizer.new(Wx::VERTICAL)
			v_box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Fichier", "eng" => "File"})), 0, Wx::GROW)
			v_box.add_spacer(2)
			v_box.add(@video_intro, 0, Wx::GROW)
			h_box.add(v_box, 1, Wx::GROW)
			v_box = Wx::BoxSizer.new(Wx::VERTICAL)
			v_box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Transition vidéo/écran titre", "eng" => "Video/Title screen transition"})), 0, Wx::GROW)
			v_box.add_spacer(2)
			v_box.add(@choice_video_transition, 0, Wx::GROW)
			h_box.add(v_box, 1, Wx::GROW)
			box.add(h_box, 1, Wx::ALL | Wx::GROW, 5)
			box1.add(box, 0, Wx::GROW)
			
			#Commands
			commands_sizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Commandes", "eng" => "Commands"}))
			box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box.add(@list_commands, 1, Wx::GROW)
			infos_commands = Wx::BoxSizer.new(Wx::VERTICAL)
			h_box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			v_box = Wx::BoxSizer.new(Wx::VERTICAL)
			v_box.add(Wx::StaticText.new(self, Wx::ID_ANY, "Type :"), 0, Wx::GROW)
			v_box.add_spacer(2)
			v_box.add(@choice_commands_type, 0, Wx::GROW)
			h_box.add(v_box, 1, Wx::GROW)
			v_box = Wx::BoxSizer.new(Wx::VERTICAL)
			v_box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Commandes max", "eng" => "Max commands"}) + ":"), 0, Wx::GROW)
			v_box.add_spacer(2)
			v_box.add(@nb_commands, 0, Wx::GROW)
			h_box.add_spacer(5)
			h_box.add(v_box, 1, Wx::GROW)
			infos_commands.add(h_box, 0, Wx::GROW)
			h_box = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, "Position")
			v_box = Wx::BoxSizer.new(Wx::VERTICAL)
			v_box.add(Wx::StaticText.new(self, Wx::ID_ANY, "x :"), 0, Wx::GROW)
			v_box.add_spacer(2)
			v_box.add(@commands_x, 0, Wx::GROW)
			h_box.add(v_box, 1, Wx::GROW)
			v_box = Wx::BoxSizer.new(Wx::VERTICAL)
			v_box.add(Wx::StaticText.new(self, Wx::ID_ANY, "x :"), 0, Wx::GROW)
			v_box.add_spacer(2)
			v_box.add(@commands_y, 0, Wx::GROW)
			h_box.add_spacer(5)
			h_box.add(v_box, 1, Wx::GROW)
			infos_commands.add(h_box, 0, Wx::GROW)
			box.add_spacer(10)
			box.add(infos_commands, 1, Wx::GROW)
			commands_sizer.add(box, 1, Wx::ALL | Wx::GROW, 5)
			box1.add_spacer(15)
			box1.add(commands_sizer, 1, Wx::GROW)
			side_1.add(box1, 1, Wx::ALL | Wx::GROW, 5)
			
			# side 2
			side_2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Ecran de chargement", "eng" => "Load screen"}))
			side_2.add(box1, 1, Wx::GROW)
			
			
			
			
			others = Wx::BoxSizer.new(Wx::HORIZONTAL)
			others.add(side_1, 1, Wx::GROW)
			others.add_spacer(10)
			others.add(side_2, 1, Wx::GROW)
			
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			main_sizer.add(top, 0, Wx::GROW)
			main_sizer.add(others, 1, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			# Set evt
			evt_button(@title_screen_apparence.button) do |event|
				begin
				set_apparence(parent, String_lang::get({"fr" => "Fond", "eng" => "Background"}), @title_screen_apparence)
				rescue Exception => e  
					FrameAlert::message(e)
				end
			end
			evt_button(@text_apparence.button) do |event|
				begin
				set_apparence(parent, String_lang::get({"fr" => "Texte", "eng" => "Text"}), @text_apparence)
				rescue Exception => e  
					FrameAlert::message(e)
				end
			end
			evt_button(@title_logo.button) do |event|
				begin
				set_apparence(parent, "Logo", @title_logo, $game_system.title_logo)
				rescue Exception => e  
					FrameAlert::message(e)
				end
			end
		end
			
		#--------------------------------------------------------------------------------------------------------------------------------
		#	set_apparence
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def set_apparence(parent, name, widget)
			dialog = Dialog_preview_title.new(parent, name, widget)
			if (dialog.show_modal() == 1000)
				tab = dialog.get_value()
				text = tab["name"]
				text = "> " + text if (text != String_lang::get({"fr" => "Aucun(e)", "eng" => "None"}))
				widget.text_ctrl.set_item_text(0, text)
				name = Image_manager::name_image(text)
				widget.values = [Image_manager::get_images("/Pictures/HUD/Title", name), tab["pos_x"], tab["pos_y"]]
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return {"choice_type" => @choice_type.get_selection(), "title_screen_apparence" => @title_screen_apparence.values, "text_apparence" => @text_apparence.values, "title_logo" => @title_logo.values, "commands" => @commands_values}
		end
	end
	
	class System < Wx::Panel
		def initialize(notebook, parent)
			super(notebook)
			set_own_background_colour($background_color)
			screen_size = File.open($directory + "/Datas/Editor/screen_editor.txt", 'r').readlines
			
			# Variables
			@name = LangButtonCtrl.new(self, $game_system.name, 145)
			@name.set_own_background_colour($background_color)
			@screen_x = NumberCtrl.new(self, 1, 99999, $game_system.screen_x, 1, 4, true, Wx::DEFAULT_POSITION, [67,-1]); @screen_x.set_own_background_colour($background_color)
			@screen_y = NumberCtrl.new(self, 1, 99999, $game_system.screen_y, 1, 4, true, Wx::DEFAULT_POSITION, [67,-1]); @screen_y.set_own_background_colour($background_color)
			@full_screen = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Mode fenêtré", "eng" => "Window mode"}), String_lang::get({"fr" => "Mode plein écran", "eng" => "Full screen mode"})])
			index = $game_system.full_screen ? 1 : 0
			@full_screen.set_selection(index)
			@screen_editor_x = NumberCtrl.new(self, 1, 99999, screen_size[0].to_i, 1, 4, true, Wx::DEFAULT_POSITION, [67,-1]); @screen_editor_x.set_own_background_colour($background_color)
			@screen_editor_y = NumberCtrl.new(self, 1, 99999, screen_size[1].to_i, 1, 4, true, Wx::DEFAULT_POSITION, [67,-1]); @screen_editor_y.set_own_background_colour($background_color)
			@full_screen_editor = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Mode fenêtré", "eng" => "Window mode"}), String_lang::get({"fr" => "Mode plein écran", "eng" => "Full screen mode"})])
			index = screen_size[2] == "true" ? 1 : 0
			@full_screen_editor.set_selection(index)
			@list_window_skins = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [LIST_WIDTH, -1], Wx::LC_REPORT | Wx::LC_NO_HEADER)
			@list_window_skins.insert_column(0, "head")
			@list_window_skins.set_column_width(0, LIST_WIDTH-21)
			i = 0
			@window_skins_values = []
			$game_system.window_skins.each do |window_skin|
				@list_window_skins.insert_item(i,  "<> " + window_skin.name)
				@window_skins_values.push(window_skin)
				i += 1
			end
			@list_window_skins.insert_item(i,  "<> ")
			@list_colors = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [LIST_WIDTH, -1], Wx::LC_REPORT | Wx::LC_NO_HEADER)
			@list_colors.insert_column(0, "head")
			@list_colors.set_column_width(0, LIST_WIDTH-21)
			i = 0
			@colors_values = []
			$game_system.colors.each do |color|
				@list_colors.insert_item(i,  "<> " + color["name"])
				@colors_values.push(color)
				i += 1
			end
			@list_colors.insert_item(i,  "<> ")
			@launcher_caption = LangButtonCtrl.new(self, $game_system.launcher_caption, 145); @launcher_caption.set_own_background_colour($background_color)
			@launcher_background_apparence = TextButtonCtrl.new(self, Image_manager::text_image($game_system.launcher_background[0]), 140); @launcher_background_apparence.values = $game_system.launcher_background; @launcher_background_apparence.set_own_background_colour(Wx::Colour.new(225,225, 245))
			list_window_skins = []
			$game_system.window_skins.each do |windowskin|
				list_window_skins.push(windowskin.name)
			end
			@launcher_windowskin = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, list_window_skins)
			@launcher_windowskin.set_selection($game_system.launcher_windowskin)
			@launcher_resolution = Wx::CheckBox.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Autoriser changement de résolution", "eng" => "Allow to set resolution"})); @launcher_resolution.set_value($game_system.launcher_resolution)
			@launcher_mode = Wx::CheckBox.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Autoriser mode écran", "eng" => "Allow screen mode"})); @launcher_mode.set_value($game_system.launcher_mode)
			
			
			
			
			
			# 1
			side_1 = Wx::BoxSizer.new(Wx::VERTICAL)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Nom du jeu", "eng" => "Game name"}))
			box1.add(@name, 0, Wx::GROW)
			side_1.add(box1, 0, Wx::GROW)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, "Message")
			button_set_message_options = Wx::Button.new(self,  Wx::ID_ANY,  String_lang::get({"fr" => "Modifier les options de messages", "eng" => "Set default messages options"}))
			box1.add(button_set_message_options, 0, Wx::GROW)
			side_1.add(box1, 0, Wx::GROW)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, String_lang::get({"fr" => "Résolution native", "eng" => "Native resolution"}))
			box_size = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Longueur", "eng" => "Width"}) + " :"), 0, Wx::GROW)
			box.add_spacer(2)
			box.add(@screen_x, 0, Wx::GROW)
			box_size.add(box, 1, Wx::GROW)
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Longueur", "eng" => "Width"}) + " :"), 0, Wx::GROW)
			box.add_spacer(2)
			box.add(@screen_y, 0, Wx::GROW)
			box_size.add(box, 1, Wx::GROW)
			box1.add(box_size, 0, Wx::GROW)
			box1.add_spacer(10)
			box1.add(@full_screen, 0, Wx::GROW)
			side_1.add_spacer(10)
			side_1.add(box1, 0, Wx::GROW)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, String_lang::get({"fr" => "Résolution éditeur", "eng" => "Editor resolution"}))
			box_size = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Longueur", "eng" => "Width"}) + " :"), 0, Wx::GROW)
			box.add_spacer(2)
			box.add(@screen_editor_x, 0, Wx::GROW)
			box_size.add(box, 1, Wx::GROW)
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			box.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Longueur", "eng" => "Width"}) + " :"), 0, Wx::GROW)
			box.add_spacer(2)
			box.add(@screen_editor_y, 0, Wx::GROW)
			box_size.add(box, 1, Wx::GROW)
			box1.add(box_size, 0, Wx::GROW)
			box1.add_spacer(10)
			box1.add(@full_screen_editor, 0, Wx::GROW)
			side_1.add_spacer(10)
			side_1.add(box1, 0, Wx::GROW)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, "Window skins")
			box1.add(@list_window_skins, 1, Wx::GROW)
			side_1.add_spacer(10)
			side_1.add(box1, 1, Wx::GROW)
			
			# 2
			side_2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, String_lang::get({"fr" => "Couleurs", "eng" => "Colors"}))
			box1.add(@list_colors, 1, Wx::GROW)
			side_2.add(box1, 1, Wx::GROW)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, "Launcher")
			box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Titre", "eng" => "Caption"}) + " :"), 0, Wx::GROW)
			box1.add_spacer(2)
			box1.add(@launcher_caption, 0, Wx::GROW)
			box1.add_spacer(5)
			box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Fond", "eng" => "Background"}) + " :"), 0, Wx::GROW)
			box1.add_spacer(2)
			box1.add(@launcher_background_apparence, 0, Wx::GROW)
			box1.add_spacer(5)
			box1.add(Wx::StaticText.new(self, Wx::ID_ANY, "Window skin"), 0, Wx::GROW)
			box1.add_spacer(2)
			box1.add(@launcher_windowskin, 0, Wx::GROW)
			box1.add_spacer(5)
			box1.add(@launcher_resolution, 0, Wx::GROW)
			box1.add_spacer(5)
			box1.add(@launcher_mode, 0, Wx::GROW)
			side_2.add(box1, 0, Wx::GROW)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, "other")
			side_2.add(box1, 1, Wx::GROW)
			
			# 3
			side_3 = Wx::BoxSizer.new(Wx::VERTICAL)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, "Elements")
			list_stats = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [LIST_WIDTH, -1], Wx::LC_REPORT | Wx::LC_NO_HEADER)
			list_stats.insert_column(0, "head")
			list_stats.set_column_width(0, LIST_WIDTH-21)
			list_stats.insert_item(0,  "<> Fire")
			list_stats.insert_item(1,  "<> Water")
			list_stats.insert_item(2,  "<> Earth")
			list_stats.insert_item(3,  "<> Wind")
			list_stats.insert_item(4,  "<> ")
			box1.add(list_stats, 1, Wx::GROW)
			side_3.add(box1, 2, Wx::GROW)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, String_lang::get({"fr" => "Commandes combat", "eng" => "Battle commands"}))
			list_commands = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [LIST_WIDTH, -1], Wx::LC_REPORT | Wx::LC_NO_HEADER)
			list_commands.insert_column(0, "head")
			list_commands.set_column_width(0, LIST_WIDTH-21)
			list_commands.insert_item(0,  "<> Attack")
			list_commands.insert_item(1,  "<> Skill")
			list_commands.insert_item(2,  "<> Item")
			list_commands.insert_item(3,  "<> Defense")
			list_commands.insert_item(4,  "<> ")
			box1.add(list_commands, 1, Wx::GROW)
			side_3.add(box1, 1, Wx::GROW)
			
			# 4
			side_4 = Wx::BoxSizer.new(Wx::VERTICAL)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, String_lang::get({"fr" => "Statistiques", "eng" => "Stats"}))
			list_stats = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [LIST_WIDTH, -1], Wx::LC_REPORT | Wx::LC_NO_HEADER)
			list_stats.insert_column(0, "head")
			list_stats.set_column_width(0, LIST_WIDTH-21)
			list_stats.insert_item(0,  "<> HP")
			list_stats.insert_item(1,  "<> MP")
			list_stats.insert_item(2,  "<> SP")
			list_stats.insert_item(3,  "<> Gold")
			list_stats.insert_item(4,  "<> Attack")
			list_stats.insert_item(5,  "<> Defense")
			list_stats.insert_item(6,  "<> Agility")
			list_stats.insert_item(7,  "<> Chance")
			list_stats.insert_item(8,  "<> ")
			box1.add(list_stats, 1, Wx::GROW)
			side_4.add(box1, 2, Wx::GROW)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, String_lang::get({"fr" => "Equipements", "eng" => "Equipments"}))
			list_equipments = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [LIST_WIDTH, -1], Wx::LC_REPORT | Wx::LC_NO_HEADER)
			list_equipments.insert_column(0, "head")
			list_equipments.set_column_width(0, LIST_WIDTH-21)
			list_equipments.insert_item(0,  "<> Weapon")
			list_equipments.insert_item(1,  "<> Helmet")
			list_equipments.insert_item(2,  "<> Armor")
			list_equipments.insert_item(3,  "<> Shield")
			list_equipments.insert_item(4,  "<> Accessory")
			list_equipments.insert_item(5,  "<> ")
			box1.add(list_equipments, 1, Wx::GROW)
			side_4.add(box1, 1, Wx::GROW)
			
			main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			main_sizer.add(side_1, 1, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(side_2, 1, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(side_3, 1, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(side_4, 1, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			# Set evt
			@list_window_skins.evt_left_dclick() do |event|
				begin
				id = @list_window_skins.get_selections()[0]
				if id < (@window_skins_values.size)
					window_skin = @window_skins_values[id]
				else
					window_skin = Window_skin.new("New window skin")
				end
				dialog = Dialog_window_skin.new(self, window_skin)
				if (dialog.show_modal() == 1000)
					window_skin = dialog.get_value()
					if id == (@window_skins_values.size)
						@list_window_skins.insert_item(id+1,  "<> ")
					end
					@window_skins_values[id] = window_skin
					@list_window_skins.set_item_text(id,  "<> " + window_skin.name)
				end
				rescue Exception => e  
					FrameAlert::message(e)
				end
			end
			@list_colors.evt_left_dclick() do |event|
				begin
				id = @list_colors.get_selections()[0]
				if id < (@colors_values.size)
					color = @colors_values[id]
				else
					color = {"name" => "New color", "color" => [0,0,0]}
				end
				dialog = Dialog_colors.new(self, color)
				if (dialog.show_modal() == 1000)
					color = dialog.get_value()
					if id == (@colors_values.size)
						@list_colors.insert_item(id+1,  "<> ")
					end
					@colors_values[id] = color
					@list_colors.set_item_text(id,  "<> " + color["name"])
				end
				rescue Exception => e  
					FrameAlert::message(e)
				end
			end
			evt_button(button_set_message_options) do |event|
				begin
				dialog = Event_interpreter::create_dialog(self, 3)
				dialog.show_modal
				rescue Exception => e  
					FrameAlert::message(e)
				end
			end
			
			evt_button(@launcher_background_apparence.button) do |event|
				begin
				set_apparence(parent, String_lang::get({"fr" => "Fond", "eng" => "Background"}), @launcher_background_apparence)
				rescue Exception => e  
					FrameAlert::message(e)
				end
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	set_apparence
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def set_apparence(parent, name, widget)
			dialog = Dialog_preview_title.new(parent, name, widget)
			if (dialog.show_modal() == 1000)
				tab = dialog.get_value()
				text = tab["name"]
				text = "> " + text if (text != String_lang::get({"fr" => "Aucun(e)", "eng" => "None"}))
				widget.text_ctrl.set_item_text(0, text)
				name = Image_manager::name_image(text)
				widget.values = [Image_manager::get_images("/Pictures/HUD/Title", name), tab["pos_x"], tab["pos_y"]]
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			full_screen = @full_screen.get_selection() == 0 ? false : true
			full_screen_editor = @full_screen_editor.get_selection() == 0 ? false : true

			return {"name" => @name.values, "screen_x" => @screen_x.get_final_value(), "screen_y" => @screen_y.get_final_value(), "full_screen" => full_screen, "screen_editor_x" => @screen_editor_x.get_final_value(), "screen_editor_y" => @screen_editor_y.get_final_value(), "full_screen_editor" => full_screen_editor, "window_skins" => @window_skins_values, "colors" => @colors_values, "launcher_caption" => @launcher_caption.values, "launcher_background" => @launcher_background_apparence.values, "launcher_windowskin" => @launcher_windowskin.get_selection(), "launcher_resolution" => @launcher_resolution.get_value(), "launcher_mode" => @launcher_mode.get_value()}
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Base de Données", "eng" => "Datas"}), Wx::DEFAULT_POSITION, [800, 600])
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		notebook = Wx::Notebook.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NB_MULTILINE)
		
		@heroes = Heroes.new(notebook, self)
		@battle = System.new(notebook, self)
		@menu = System.new(notebook, self)
		@title_screen = Title_screen.new(notebook, self)
		@system = System.new(notebook, self)
		@music_sounds = System.new(notebook, self)
		notebook.add_page(@heroes, String_lang::get({"fr" => "Héros", "eng" => "Heroes"}))
		notebook.add_page(@battle, String_lang::get({"fr" => "Combat", "eng" => "Battle"}))
		notebook.add_page(@menu, "Menu")
		notebook.add_page(@title_screen, String_lang::get({"fr" => "Ecran titre", "eng" => "Title screen"}))
		notebook.add_page(@system, String_lang::get({"fr" => "Système", "eng" => "System"}))
		notebook.add_page(@music_sounds, String_lang::get({"fr" => "Musiques et sons", "eng" => "Musics and sounds"}))
		notebook.set_background_colour(Wx::Colour.new(200,200, 225))
		
		
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(notebook, 1, Wx::GROW)
		main_sizer.add_spacer(10)
		main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
		
		# Set evt
		evt_button(okCancel.button_ok) {end_modal(1000)}
		evt_button(okCancel.button_cancel) {end_modal(-1)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		tab = Hash.new
		tab["title_screen"] = @title_screen.get_value()
		tab["system"] = @system.get_value()
		return tab
	end
end