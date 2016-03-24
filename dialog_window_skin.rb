# encoding: UTF-8

class Dialog_window_skin < Wx::Dialog
	
	class Window_skin_panel < Wx::Panel
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent, window_skin)
			super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::DOUBLE_BORDER)
			set_own_background_colour($background_color)
			
			# Sizers
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			name_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			corners_sizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Coin", "eng" => "Corners"}))
			borders_sizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Bordures", "eng" => "Borders"}))
			background_sizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Fond", "eng" => "Background"}))
			arrow_sizer = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, String_lang::get({"fr" => "Animation de flèche", "eng" => "Arrow animation"}))
			
			# Variables
			@name = Wx::TextCtrl.new(self, Wx::ID_ANY); @name.set_value(window_skin.name)
			@corner_top_left = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.corner_top_left[0]), 130); @corner_top_left.values = window_skin.corner_top_left
			@corner_top_right = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.corner_top_right[0]), 130); @corner_top_right.values = window_skin.corner_top_right
			@corner_bot_left = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.corner_bot_left[0]), 130); @corner_bot_left.values = window_skin.corner_bot_left
			@corner_bot_right = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.corner_bot_right[0]), 130); @corner_bot_right.values = window_skin.corner_bot_right
			@corner_sym = Wx::CheckBox.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Symétrique", "eng" => "Symetric"})); @corner_sym.set_value(window_skin.corner_sym)
			@border_top = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.border_top[0]), 130); @border_top.values = window_skin.border_top
			@border_right = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.border_right[0]), 130); @border_right.values = window_skin.border_right
			@border_left = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.border_left[0]), 130); @border_left.values = window_skin.border_left
			@border_bot = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.border_bot[0]), 130); @border_bot.values = window_skin.border_bot
			@border_sym = Wx::CheckBox.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Symétrique", "eng" => "Symetric"})); @border_sym.set_value(window_skin.border_sym)
			@border_choice_type = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Répéter", "eng" => "Repeat"}), String_lang::get({"fr" => "Etirer", "eng" => "Stretch"})]); @border_choice_type.set_selection(window_skin.border_choice_type)
			@radios = []
			@elements = []
			@radios[0] = Wx::RadioButton.new(self, 1, "Image ", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::RB_GROUP)
			@radios[1] = Wx::RadioButton.new(self, 1, String_lang::get({"fr" => "Couleur", "eng" => "Color"}) + " ")
			@background = TextButtonCtrl.new(self, Image_manager::text_image(window_skin.background_image[0]), 130); @background.values = window_skin.background_image
			@background_choice_color = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, ["Black"]); @background_choice_color.set_selection(window_skin.background_color)
			@background_choice_type = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Répéter", "eng" => "Repeat"}), String_lang::get({"fr" => "Etirer", "eng" => "Stretch"})]); @background_choice_type.set_selection(window_skin.background_image_choice_type)
			@elements[0] = [@background, @background_choice_type]
			@elements[1] = [@background_choice_color]
			radio = (window_skin.background_kind == 0)
			@radios[0].set_value(radio)
			@radios[1].set_value(!radio)
			enable_elements(@elements[0], radio)
			enable_elements(@elements[1], !radio)
			@arrow = TextButtonCtrl.new(self, "None", 130); @arrow.set_own_background_colour($background_color)
			
			
			# Name
			name_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom", "eng" => "Name"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
			name_sizer.add(@name, 0, Wx::ALIGN_CENTER_VERTICAL)
		
			# Corners
			box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box.add_spacer(10)
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Haut-Gauche", "eng" => "Top-Left"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box2.add_spacer(2)
			box2.add(@corner_top_left, 0, Wx::GROW)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Bas-Gauche", "eng" => "Bot-Left"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box2.add_spacer(2)
			box2.add(@corner_bot_left, 0, Wx::GROW)
			box.add(box2, 0, Wx::GROW)
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Haut-Droite", "eng" => "Top-Right"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box2.add_spacer(2)
			box2.add(@corner_top_right, 0, Wx::GROW)
			box2.add_spacer(2)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Bas-Droite", "eng" => "Bot-Right"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box2.add_spacer(2)
			box2.add(@corner_bot_right, 0, Wx::GROW)
			box.add_spacer(10)
			box.add(box2, 0, Wx::GROW)
			box.add_spacer(10)
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box2.add_spacer(20)
			box2.add(@corner_sym, 0, Wx::GROW)
			box.add(box2, 0, Wx::GROW)
			corners_sizer.add(box, 0, Wx::GROW)
			
			# Borders
			box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box.add_spacer(10)
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Haut", "eng" => "Top"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box2.add_spacer(2)
			box2.add(@border_top, 0, Wx::GROW)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Gauche", "eng" => "Left"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box2.add_spacer(2)
			box2.add(@border_left, 0, Wx::GROW)
			box.add(box2, 0, Wx::GROW)
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Droite", "eng" => "Right"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box2.add_spacer(2)
			box2.add(@border_right, 0, Wx::GROW)
			box2.add_spacer(2)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Bas", "eng" => "Bot"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			box2.add_spacer(2)
			box2.add(@border_bot, 0, Wx::GROW)
			box.add_spacer(10)
			box.add(box2, 0, Wx::GROW)
			box.add_spacer(10)
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box2.add_spacer(20)
			box2.add(@border_sym, 0, Wx::GROW)
			box2.add_spacer(19)
			box2.add(@border_choice_type, 0, Wx::GROW)
			box.add(box2, 0, Wx::GROW)
			borders_sizer.add(box, 0, Wx::GROW)
			
			# Background
			box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box.add_spacer(10)
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box3 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box3.add(@radios[0], 0, Wx::GROW)
			box3.add(@background, 0, Wx::GROW)
			box3.add_spacer(10)
			box3.add(@background_choice_type, 0, Wx::GROW)
			box2.add(box3, 0, Wx::GROW)
			box2.add_spacer(5)
			box3 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box3.add(@radios[1], 0, Wx::GROW)
			box3.add(@background_choice_color, 0, Wx::GROW)
			box2.add(box3, 0, Wx::GROW)
			box.add(box2, 0, Wx::GROW)
			background_sizer.add(box, 0, Wx::GROW)
			
			# Arrow
			arrow_sizer.add_spacer(10)
			arrow_sizer.add(@arrow, 0, Wx::GROW)
			
			# Main fusion
			main_sizer.add(name_sizer, 0, Wx::GROW)
			main_sizer.add_spacer(20)
			main_sizer.add(corners_sizer, 1, Wx::GROW)
			main_sizer.add_spacer(5)
			main_sizer.add(borders_sizer, 1, Wx::GROW)
			main_sizer.add_spacer(5)
			main_sizer.add(background_sizer, 0, Wx::GROW)
			main_sizer.add_spacer(5)
			main_sizer.add(arrow_sizer, 0, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			# Set evt
			evt_radiobutton(Wx::ID_ANY) do |event|
				for i in 0..1
					enable_elements(@elements[i], @radios[i].get_value())
				end
			end
			evt_button(@corner_top_left.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Angle haut-gauche", "eng" => "Corner top-left"}), @corner_top_left)
			end
			evt_button(@corner_top_right.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Angle haut-droite", "eng" => "Corner top-right"}), @corner_top_right)
			end
			evt_button(@corner_bot_left.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Angle bas-gauche", "eng" => "Corner bot-left"}), @corner_bot_left)
			end
			evt_button(@corner_bot_right.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Angle bas-droite", "eng" => "Corner bot-right"}), @corner_bot_right)
			end
			evt_button(@border_top.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Bordure haut", "eng" => "Border top"}), @border_top)
			end
			evt_button(@border_right.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Bordure droite", "eng" => "Border right"}), @border_right)
			end
			evt_button(@border_left.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Bordure gauche", "eng" => "Border left"}), @border_left)
			end
			evt_button(@border_bot.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Bordure bas", "eng" => "Border bot"}), @border_bot)
			end
			evt_button(@background.button) do |event|
				set_apparence(parent, String_lang::get({"fr" => "Fond", "eng" => "Background"}), @background)
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	enable_elements
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def enable_elements(elements, b)
			elements.each do |element|
				element.enable(b)
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	set_apparence
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def set_apparence(parent, name, widget)
			dialog = Dialog_preview_window_skin.new(parent, name, widget)
			if (dialog.show_modal() == 1000)
				tab = dialog.get_value()
				text = tab["name"]
				text = "> " + text if (text != String_lang::get({"fr" => "Aucun(e)", "eng" => "None"}))
				widget.text_ctrl.set_item_text(0, text)
				name = Image_manager::name_image(text)
				widget.values = [Image_manager::get_images("/Pictures/HUD/WindowSkins", name), tab["rectangle"]]
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			begin
			background_kind = (@radios[0].get_value()) ? 0 : 1
			
			return Window_skin.new(@name.get_value(), @corner_top_left.values, @corner_top_right.values, @corner_bot_left.values, @corner_bot_right.values, @corner_sym.get_value(), @border_top.values, @border_right.values, @border_left.values, @border_bot.values, @border_sym.get_value(), @border_choice_type.get_selection(), background_kind, @background.values, @background_choice_type.get_selection(), @background_choice_color.get_selection())
			rescue Exception => e  
			FrameAlert::message(e)
		end
		end
	end
	
	attr_reader :main_panel
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, window_skin)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Apparence fenêtre", "eng" => "Window skin"}), Wx::DEFAULT_POSITION, [500, 475], Wx::DEFAULT_DIALOG_STYLE)
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		@main_panel = Window_skin_panel.new(self, window_skin)
		
		
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
		button_preview = Wx::Button.new(self,  Wx::ID_ANY,  String_lang::get({"fr" => "Aperçu", "eng" => "Preview"}))
		okCancel_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		okCancel_sizer.add(button_preview, 0, Wx::GROW)
		okCancel_sizer.add(okCancel, 1, Wx::GROW)
		
		global_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		global_sizer.add(@main_panel, 1, Wx::GROW)
		global_sizer.add_spacer(10)
		global_sizer.add(okCancel_sizer, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(global_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
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
		return @main_panel.get_value()
	end
end