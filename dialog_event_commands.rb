# encoding: UTF-8

class Dialog_event_commands < Wx::Dialog
	class Page1 < Wx::Panel
		def initialize(notebook, parent)
			super(notebook)
			
			index = 0
			left_side = Wx::BoxSizer.new(Wx::VERTICAL)
			box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, "Message")
			box1.add(Wx::Button.new(self, index,  String_lang::get({"fr" => "Afficher un message", "eng" => "Display a message"})+ "..."), 0, Wx::GROW)
			index += 1
			box1.add_spacer(1)
			box1.add(Wx::Button.new(self, index, String_lang::get({"fr" => "Afficher un choix", "eng" => "Display a choice"})+ "..."), 0, Wx::GROW)
			index += 1
			box1.add_spacer(1)
			box1.add(Wx::Button.new(self, index, String_lang::get({"fr" => "Entrer un nombre", "eng" => "Enter a number"})+ "..."), 0, Wx::GROW)
			index += 1
			box1.add_spacer(1)
			box1.add(Wx::Button.new(self, index, String_lang::get({"fr" => "Options d'affichage", "eng" => "Display options"})+ "..."), 0, Wx::GROW)
			index += 1
			left_side.add(box1, 0, Wx::GROW)
			left_side.add_spacer(10)
			box2 = Wx::StaticBoxSizer.new(Wx::VERTICAL,  self, String_lang::get({"fr" => "Syntaxe", "eng" => "Syntax"}))
			box2.add(Wx::Button.new(self, index,  "Conditions..."), 0, Wx::GROW)
			index += 1
			box2.add_spacer(1)
			box2.add(Wx::Button.new(self, index, String_lang::get({"fr" => "Boucle", "eng" => "Loop"})), 0, Wx::GROW)
			index += 1
			box2.add_spacer(1)
			box2.add(Wx::Button.new(self, index, String_lang::get({"fr" => "Sortir de la boucle", "eng" => "Break loop"})), 0, Wx::GROW)
			index += 1
			box2.add_spacer(1)
			box2.add(Wx::Button.new(self, index, String_lang::get({"fr" => "Insérer un commentaire", "eng" => "Insert a comment"})+ "..."), 0, Wx::GROW)
			index += 1
			box2.add_spacer(1)
			box2.add(Wx::Button.new(self, index, String_lang::get({"fr" => "Mettre une étiquette", "eng" => "Label"})+ "..."), 0, Wx::GROW)
			index += 1
			box2.add_spacer(1)
			box2.add(Wx::Button.new(self, index, String_lang::get({"fr" => "Aller à l'étiquette", "eng" => "Jump to label"})+ "..."), 0, Wx::GROW)
			index += 1
			left_side.add(box2, 0, Wx::GROW)
			
			right_side = Wx::BoxSizer.new(Wx::VERTICAL)
			
			main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			main_sizer.add(left_side, 1, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(right_side, 1, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			evt_button(Wx::ID_ANY) do |event|
				dialog = Event_interpreter::create_dialog(self, event.get_id())
				dialog.show_modal
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, commands)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Commandes d'évènements", "eng" => "Event commands"}), Wx::DEFAULT_POSITION, [450, 500])
		set_own_background_colour($background_color)
		
		@commands = commands
		
		notebook = Wx::Notebook.new(self, Wx::ID_ANY)
		notebook.set_own_background_colour($background_color)
		page1 = Page1.new(notebook, self)
		#~ page2 = Page2.new(notebook, self)
		@pages = [page1]
		notebook.add_page(page1, "1")
		#~ notebook.add_page(page2, String_lang::get({"fr" => "Héros", "eng" => "Actors"}))
		#~ notebook.add_page(Wx::Panel.new(self), String_lang::get({"fr" => "Evènements", "eng" => "Events"}))
		#~ notebook.add_page(Wx::Panel.new(self), "Possessions")
		#~ notebook.add_page(Wx::Panel.new(self),  String_lang::get({"fr" => "Autres", "eng" => "Others"}))
		
		close = Close.new(self)
		close.set_own_background_colour($background_color)
		
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(notebook, 1, Wx::GROW)
		main_sizer.add_spacer(10)
		main_sizer.add(close, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
	end
end

class Dialog_conditions < Wx::Dialog
	ID_RADIO_1 = 5000
	ID_RADIO_2 = 5001
	
	class Page1 < Wx::Panel
		def initialize(notebook, parent)
			super(notebook)
			@radios = []
			@elements = []
			
			# Switch
			box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[0] = Wx::RadioButton.new(self, ID_RADIO_1, String_lang::get({"fr" => "L'interupteur", "eng" => "Switch"}) + " ", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::RB_GROUP)
			@radios[0].set_value(true)
			box1.add(@radios[0], 0, Wx::ALIGN_CENTER_VERTICAL)
			switch = TextButtonCtrl.new(self, "ID-0001:")
			box1.add(switch, 0, Wx::ALIGN_CENTER_VERTICAL)
			text1 = Wx::StaticText.new(self, Wx::ID_ANY, " " + String_lang::get({"fr" => "est", "eng" => "is"}) + " ")
			box1.add(text1, 0, Wx::ALIGN_CENTER_VERTICAL)
			switch_act = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "activé", "eng" => "ON"}), String_lang::get({"fr" => "désactivé", "eng" => "OFF"})])
			switch_act.set_selection(0)
			box1.add(switch_act, 0, Wx::ALIGN_CENTER_VERTICAL)
			@elements[0] = [switch, text1, switch_act]
			
			# Self switch
			box2 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[1] = Wx::RadioButton.new(self, ID_RADIO_1, String_lang::get({"fr" => "L'interupteur local", "eng" => "Self switch"}) + " ")
			box2.add(@radios[1], 0, Wx::ALIGN_CENTER_VERTICAL)
			self_switch = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, ["A", "B", "C", "D", "E", "F", "G", "H"])
			self_switch.set_selection(0)
			box2.add(self_switch, 0, Wx::ALIGN_CENTER_VERTICAL)
			text2 = Wx::StaticText.new(self, Wx::ID_ANY, " " + String_lang::get({"fr" => "est", "eng" => "is"}) + " ")
			box2.add(text2, 0, Wx::ALIGN_CENTER_VERTICAL)
			self_switch_act = Wx::Choice.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "activé", "eng" => "ON"}), String_lang::get({"fr" => "désactivé", "eng" => "OFF"})])
			self_switch_act.set_selection(0)
			box2.add(self_switch_act, 0, Wx::ALIGN_CENTER_VERTICAL)
			@elements[1] = [self_switch, text2, self_switch_act]
			enable_elements(@elements[1], false)
			
			# Variable
			box3 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[2] = Wx::RadioButton.new(self,  ID_RADIO_1, String_lang::get({"fr" => "La variable ", "eng" => "Variable"}) + " ")
			box3.add(@radios[2], 0, Wx::ALIGN_CENTER_VERTICAL)
			var = TextButtonCtrl.new(self, "ID-0001:")
			box3.add(var, 0, Wx::ALIGN_CENTER_VERTICAL)
			box3.add_spacer(10)
			text3 = Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "est", "eng" => "is"}) + " : ")
			box3.add(text3, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			cond_var = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "égale", "eng" => "equal to"}), String_lang::get({"fr" => "supérieure ou égale", "eng" => "equal to, or greater than"}), String_lang::get({"fr" => "inférieure ou égale", "eng" => "equal to, or less than"}), String_lang::get({"fr" => "strictement inférieure", "eng" => "less than"}), String_lang::get({"fr" => "strictement supérieure", "eng" => "greater than"}), String_lang::get({"fr" => "différente de", "eng" => "not equal to"})])
			cond_var.set_selection(0)
			box4.add_spacer(10)
			box4.add(cond_var, 0, Wx::ALIGN_CENTER_VERTICAL)
			text4 = Wx::StaticText.new(self, Wx::ID_ANY, " " + String_lang::get({"fr" => "à", "eng" => " "}) + " ")
			box4.add(text4, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4_1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[3] = Wx::RadioButton.new(self, ID_RADIO_2, " ", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::RB_GROUP)
			@radios[3].set_value(true)
			box4_1.add(@radios[3], 0, Wx::ALIGN_CENTER_VERTICAL)
			var_compare_1 = NumberCtrl.new(self, -99999999, 99999999, 0, 1, 8, true, Wx::DEFAULT_POSITION, [60, -1])
			box4_1.add(var_compare_1, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4_2 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[4] = Wx::RadioButton.new(self,  ID_RADIO_2, " ")
			box4_2.add(@radios[4], 0, Wx::ALIGN_CENTER_VERTICAL)
			var_compare_2 = TextButtonCtrl.new(self, "ID-0001:")
			box4_2.add(var_compare_2, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4_3 = Wx::BoxSizer.new(Wx::VERTICAL)
			box4_3.add(box4_1)
			box4_3.add(box4_2)
			box4.add(box4_3)
			@elements[2] = [var, text3, cond_var, text4, @radios[3], @radios[4]]
			@elements[3] = [var_compare_1]
			@elements[4] = [var_compare_2]
			enable_elements(@elements[2], false)
			enable_elements(@elements[3], false)
			enable_elements(@elements[4], false)
			
			# Main sizer
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			main_sizer.add(box1, 0, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(box2, 0, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(box3, 0, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(box4, 0, Wx::GROW)
		
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			# Set evt
			evt_radiobutton(Wx::ID_ANY) do |event|
				for i in 0..2
					enable_elements(@elements[i], @radios[i].get_value())
				end
				if @radios[2].get_value()
					enable_elements(@elements[3], @radios[3].get_value())
					enable_elements(@elements[4], @radios[4].get_value())
				else
					enable_elements(@elements[3], false)
					enable_elements(@elements[4], false)
				end
				parent.update(self)
			end
		end
		
		def enable_all(b)
			@elements.each do |elements|
				elements.each do |element|
					element.enable(b)
				end
			end
			@radios[0].set_value(false)
			@radios[1].set_value(false)
			@radios[2].set_value(false)
		end
		
		def enable_elements(elements, b)
			elements.each do |element|
				element.enable(b)
			end
		end
	end
	
	class Page2 < Wx::Panel
		def initialize(notebook, parent)
			super(notebook)
			@radios = []
			@elements = []
			
			# player
			box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[0] = Wx::RadioButton.new(self, ID_RADIO_1, String_lang::get({"fr" => "Le héros", "eng" => "Player"}) + " ", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::RB_GROUP)
			@radios[0].set_value(false)
			box1.add(@radios[0], 0, Wx::ALIGN_CENTER_VERTICAL)
			player = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, ["ID-0001:player1"])
			player.set_selection(0)
			box1.add(player, 0, Wx::ALIGN_CENTER_VERTICAL)
			@elements[0] = [player]
			enable_elements(@elements[0], false)
			
			# all players
			box2 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[1] = Wx::RadioButton.new(self, ID_RADIO_1, String_lang::get({"fr" => "L'ensemble de l'équipe", "eng" => "The team"}) + " ")
			box2.add(@radios[1], 0, Wx::ALIGN_CENTER_VERTICAL)
			@elements[1] = []
			
			# at least one player
			box3 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[2] = Wx::RadioButton.new(self, ID_RADIO_1, String_lang::get({"fr" => "Au moins un membre de l'équipe", "eng" => "At least one player"}) + " ")
			box3.add(@radios[2], 0, Wx::ALIGN_CENTER_VERTICAL)
			@elements[2] = []
			
			# list
			box4 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box4.add_spacer(20)
			box4_1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[3] = Wx::RadioButton.new(self, ID_RADIO_2, String_lang::get({"fr" => "a pour nom", "eng" => "is named"}) + " ", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::RB_GROUP)
			@radios[3].set_value(true)
			box4_1.add(@radios[3], 0, Wx::ALIGN_CENTER_VERTICAL)
			name = Wx::TextCtrl.new(self, Wx::ID_ANY)
			box4_1.add(name, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4_2 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[4] = Wx::RadioButton.new(self,  ID_RADIO_2, String_lang::get({"fr" => "peut utiliser la competence", "eng" => "can use the skill"}) + " ")
			box4_2.add(@radios[4], 0, Wx::ALIGN_CENTER_VERTICAL)
			skill = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, ["ID-0001:skill1"])
			skill.set_selection(0)
			box4_2.add(skill, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4_3 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[5] = Wx::RadioButton.new(self,  ID_RADIO_2, String_lang::get({"fr" => "est equipé de", "eng" => "is equiped with"}) + " ")
			box4_3.add(@radios[5], 0, Wx::ALIGN_CENTER_VERTICAL)
			equip = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, ["ID-0001:weapon1"])
			equip.set_selection(0)
			box4_3.add(equip, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4_4 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[6] = Wx::RadioButton.new(self,  ID_RADIO_2, String_lang::get({"fr" => "est sous l'effet du statut", "eng" => "is under effect of"}) + " ")
			box4_4.add(@radios[6], 0, Wx::ALIGN_CENTER_VERTICAL)
			effect = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, ["ID-0001:effect1"])
			effect.set_selection(0)
			box4_4.add(effect, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4_5 = Wx::BoxSizer.new(Wx::HORIZONTAL)
			@radios[7] = Wx::RadioButton.new(self,  ID_RADIO_2, String_lang::get({"fr" => "a ses PV", "eng" => "has his HP"}) + " ")
			box4_5.add(@radios[7], 0, Wx::ALIGN_CENTER_VERTICAL)
			compare = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "égaux", "eng" => "equal to"}), String_lang::get({"fr" => "supérieurs ou égaux", "eng" => "equal to, or greater than"}), String_lang::get({"fr" => "inférieurs ou égaux", "eng" => "equal to, or less than"}), String_lang::get({"fr" => "strictement inférieurs", "eng" => "less than"}), String_lang::get({"fr" => "strictement supérieurs", "eng" => "greater than"}), String_lang::get({"fr" => "différents de", "eng" => "not equal to"})])
			compare.set_selection(0)
			box4_5.add(compare, 0, Wx::ALIGN_CENTER_VERTICAL)
			text1 = Wx::StaticText.new(self, Wx::ID_ANY, " " + String_lang::get({"fr" => "à", "eng" => " "}) + " ")
			box4_5.add(text1, 0, Wx::ALIGN_CENTER_VERTICAL)
			percent = NumberCtrl.new(self, 0, 100, 50, 1, 3, true, Wx::DEFAULT_POSITION, [30, -1])
			box4_5.add(percent, 0, Wx::ALIGN_CENTER_VERTICAL)
			text2 = Wx::StaticText.new(self, Wx::ID_ANY, " % " + String_lang::get({"fr" => "de ses PV max", "eng" => "of his max HP"}))
			box4_5.add(text2, 0, Wx::ALIGN_CENTER_VERTICAL)
			box4_fin = Wx::BoxSizer.new(Wx::VERTICAL)
			box4_fin.add(box4_1)
			box4_fin.add_spacer(10)
			box4_fin.add(box4_2)
			box4_fin.add_spacer(10)
			box4_fin.add(box4_3)
			box4_fin.add_spacer(10)
			box4_fin.add(box4_4)
			box4_fin.add_spacer(10)
			box4_fin.add(box4_5)
			box4.add(box4_fin)
			@elements[0] = [player]
			@elements[1] = []
			@elements[2] = []
			@elements[3] = [@radios[3], @radios[4], @radios[5], @radios[6], @radios[7]]
			@elements[4] = [name]
			@elements[5] = [skill]
			@elements[6] = [equip]
			@elements[7] = [effect]
			@elements[8] = [compare, text1, percent, text2]
			
			@elements.each do |element|
				enable_elements(element, false)
			end

			# Main sizer
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			main_sizer.add(box1, 0, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(box2, 0, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(box3, 0, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(box4, 0, Wx::GROW)
		
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			# Set evt
			evt_radiobutton(Wx::ID_ANY) do |event|
				enable_elements(@elements[0], @radios[0].get_value())
				enable_elements(@elements[3], (@radios[0].get_value() or @radios[1].get_value() or @radios[2].get_value()))
				if @radios[0].get_value() or @radios[1].get_value() or @radios[2].get_value()
					for i in 4..8
						enable_elements(@elements[i], @radios[i-1].get_value())
					end
				else
					for i in 4..8
						enable_elements(@elements[i], false)
					end
				end
				parent.update(self)
			end
		end
		
		def enable_all(b)
			@elements.each do |elements|
				elements.each do |element|
					element.enable(b)
				end
			end
			@radios[0].set_value(false)
			@radios[1].set_value(false)
			@radios[2].set_value(false)
		end
		
		def enable_elements(elements, b)
			elements.each do |element|
				element.enable(b)
			end
		end
	end
	
	def initialize(parent)
		super(parent, Wx::ID_ANY, "Conditions", Wx::DEFAULT_POSITION, [450, 380])
		set_own_background_colour(Wx::Colour.new(225,225, 245))
		
		notebook = Wx::Notebook.new(self, Wx::ID_ANY)
		notebook.set_own_background_colour(Wx::Colour.new(225,225, 245))
		page1 = Page1.new(notebook, self)
		page2 = Page2.new(notebook, self)
		@pages = [page1, page2]
		notebook.add_page(page1, String_lang::get({"fr" => "Interrupteurs et variables", "eng" => "Switches and variables"}))
		notebook.add_page(page2, String_lang::get({"fr" => "Héros", "eng" => "Actors"}))
		notebook.add_page(Wx::Panel.new(self), String_lang::get({"fr" => "Evènements", "eng" => "Events"}))
		notebook.add_page(Wx::Panel.new(self), "Possessions")
		notebook.add_page(Wx::Panel.new(self),  String_lang::get({"fr" => "Autres", "eng" => "Others"}))
		
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(notebook, 1, Wx::GROW)
		main_sizer.add_spacer(10)
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour(Wx::Colour.new(225,225, 245))
		main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
	end
	
	def update(page_spe)
		@pages.each do |page|
			page.enable_all(false) if page != page_spe
		end
	end
end

class Dialog_display_message < Wx::Dialog
	def initialize(parent)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Afficher un message", "eng" => "Display a message"}), Wx::DEFAULT_POSITION, [$game_screen_x, 300])
		set_own_background_colour(Wx::Colour.new(225,225, 245))
	end
end

class Dialog_display_options < Wx::Dialog
	def initialize(parent)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Options d'affichage", "eng" => "Display options"}), Wx::DEFAULT_POSITION, [500, 380])
		set_own_background_colour(Wx::Colour.new(225,225, 245))

		left_side = Wx::BoxSizer.new(Wx::VERTICAL)
		box_window = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Fenêtre", "eng" => "Window"}))
		check_display_window = Wx::CheckBox.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Afficher la fenêtre", "eng" => "Display window"}))
		box_window.add(check_display_window, 0, Wx::GROW)
		box_window.add_spacer(10)
		box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Apparence", "eng" => "Graphic"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		window_graphic = TextButtonCtrl.new(self, "", 140)
		box1.add(window_graphic, 0, Wx::ALIGN_CENTER_VERTICAL)
		box_window.add(box1)
		box_window.add_spacer(10)
		box1 = Wx::BoxSizer.new(Wx::VERTICAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, "x : "))
		box1.add_spacer(2)
		@window_x = NumberCtrl.new(self, -9999, 9999, $game_system.screen_x, 0, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box1.add(@window_x)
		box2 = Wx::BoxSizer.new(Wx::VERTICAL)
		box2.add(Wx::StaticText.new(self, Wx::ID_ANY, "y : "))
		box2.add_spacer(2)
		@window_y = NumberCtrl.new(self, -9999, 9999, $game_system.screen_y, 300, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box2.add(@window_y)
		box_nums = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, "Position")
		box_nums.add(box1, 1, Wx::GROW)
		box_nums.add(box2, 1, Wx::GROW)
		box_window.add(box_nums, 0, Wx::GROW)
		box1 = Wx::BoxSizer.new(Wx::VERTICAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Largeur", "eng" => "Width"}) + " : "))
		box1.add_spacer(2)
		@window_width = NumberCtrl.new(self, 1, 9999, 640, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box1.add(@window_width)
		box2 = Wx::BoxSizer.new(Wx::VERTICAL)
		box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Hauteur", "eng" => "Height"}) + " : "))
		box2.add_spacer(2)
		@window_height = NumberCtrl.new(self, 1, 9999, 180, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box2.add(@window_height)
		box_nums = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, "Size")
		box_nums.add(box1, 1, Wx::GROW)
		box_nums.add(box2, 1, Wx::GROW)
		box_window.add(box_nums, 0, Wx::GROW)
		box1 = Wx::BoxSizer.new(Wx::VERTICAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Haut", "eng" => "Up"}) + " : "))
		box1.add_spacer(2)
		@window_padding_top = NumberCtrl.new(self, 0, 9999, 5, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box1.add(@window_padding_top)
		box2.add_spacer(2)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Gauche", "eng" => "Left"}) + " : "))
		box1.add_spacer(2)
		@window_padding_left = NumberCtrl.new(self, 0, 9999, 5, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box1.add(@window_padding_left)
		box2 = Wx::BoxSizer.new(Wx::VERTICAL)
		box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Bas", "eng" => "Bottom"}) + " : "))
		box2.add_spacer(2)
		@window_padding_bot = NumberCtrl.new(self, 0, 9999, 5, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box2.add(@window_padding_bot)
		box2.add_spacer(2)
		box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Droite", "eng" => "Right"}) + " : "))
		box2.add_spacer(2)
		@window_padding_right = NumberCtrl.new(self, 0, 9999, 5, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box2.add(@window_padding_right)
		box_nums = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, "Padding :")
		box_nums.add(box1, 1, Wx::GROW)
		box_nums.add(box2, 1, Wx::GROW)
		box_window.add(box_nums, 0, Wx::GROW)
		left_side.add(box_window, 0, Wx::GROW)
		
		
		right_side = Wx::BoxSizer.new(Wx::VERTICAL)
		box_faceset = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, "Faceset")
		check_behind_window = Wx::CheckBox.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Derrière la fenêtre", "eng" => "Behind window"}))
		box_faceset.add(check_behind_window, 0, Wx::GROW)
		box_faceset.add_spacer(10)
		box1 = Wx::BoxSizer.new(Wx::VERTICAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Largeur", "eng" => "Width"}) + " : "))
		box1.add_spacer(2)
		@faceset_width = NumberCtrl.new(self, 1, 9999, 100, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box1.add(@faceset_width)
		box2 = Wx::BoxSizer.new(Wx::VERTICAL)
		box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Hauteur", "eng" => "Height"}) + " : "))
		box2.add_spacer(2)
		@faceset_height = NumberCtrl.new(self, 1, 9999, 100, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box2.add(@faceset_height)
		box_nums = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self, String_lang::get({"fr" => "Taille max", "eng" => "Max size"}))
		box_nums.add(box1, 1, Wx::GROW)
		box_nums.add(box2, 1, Wx::GROW)
		box_faceset.add(box_nums, 0, Wx::GROW)
		right_side.add(box_faceset, 0, Wx::GROW)
		box_text = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Texte", "eng" => "Text"}))
		check_outline = Wx::CheckBox.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Contour", "eng" => "Outline"}))
		box_text.add(check_outline, 0, Wx::GROW)
		box_text.add_spacer(10)
		box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Couleur de texte", "eng" => "Text color"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		choice_text_color = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Blanc", "eng" => "White"}), String_lang::get({"fr" => "Noir", "eng" => "Black"})])
		choice_text_color.set_selection(0)
		box1.add(choice_text_color, 0, Wx::ALIGN_CENTER_VERTICAL)
		box_text.add(box1)
		box_text.add_spacer(5)
		box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Couleur du contour", "eng" => "Outline color"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		choice_outline_color = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Blanc", "eng" => "White"}), String_lang::get({"fr" => "Noir", "eng" => "Black"})])
		choice_outline_color.set_selection(1)
		box1.add(choice_outline_color, 0, Wx::ALIGN_CENTER_VERTICAL)
		box_text.add(box1)
		box_text.add_spacer(5)
		box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Taille", "eng" => "Size"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		text_size = NumberCtrl.new(self, 1, 9999, 14, 1, 4, true, Wx::DEFAULT_POSITION, [50,-1])
		box1.add(text_size, 0, Wx::ALIGN_CENTER_VERTICAL)
		box_text.add(box1)
		box_text.add_spacer(5)
		box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, "Font : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		text_font = Wx::TextCtrl.new(self,  Wx::ID_ANY, "Arial")
		box1.add(text_font, 0, Wx::ALIGN_CENTER_VERTICAL)
		box_text.add(box1)
		box_text.add_spacer(5)
		box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Son", "eng" => "Sound"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		text_sound = TextButtonCtrl.new(self, "", 140)
		box1.add(text_sound, 0, Wx::ALIGN_CENTER_VERTICAL)
		box_text.add(box1)
		right_side.add(box_text, 0, Wx::GROW)
		
		page =  Wx::BoxSizer.new(Wx::HORIZONTAL)
		page.add(left_side, 1, Wx::GROW)
		page.add_spacer(10)
		page.add(right_side, 1, Wx::GROW)
		
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(page, 1, Wx::GROW)
		main_sizer.add_spacer(10)
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour(Wx::Colour.new(225,225, 245))
		main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
	end
end