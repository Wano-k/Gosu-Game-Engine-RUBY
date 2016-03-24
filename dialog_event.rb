# encoding: UTF-8

class Dialog_event < Wx::Dialog
	
	ID_NEW = 1001
	ID_COPY = 1002
	ID_PASTE = 1003
	ID_DELETE = 1004
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, map_coords)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Gestion d'évenement", "eng" => "Event management"}), Wx::DEFAULT_POSITION, [820, 600], Wx::STAY_ON_TOP)
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		# Top_sizer
		top_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		name = Wx::TextCtrl.new(self, Wx::ID_ANY)
		name.set_value("EV0001")
		box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom", "eng" => "Name"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		box1.add(name, 0, Wx::ALIGN_CENTER_VERTICAL)
		box2 = Wx::StaticBoxSizer.new(Wx::HORIZONTAL,  self, String_lang::get({"fr" => "Gestion des pages", "eng" => "Pages management"}))
		button1 = Wx::Button.new(self,  Wx::ID_ANY,  String_lang::get({"fr" => "Nouveau", "eng" => "New"}))
		button2 = Wx::Button.new(self,  Wx::ID_ANY,  String_lang::get({"fr" => "Copier", "eng" => "Copy"}))
		button3 = Wx::Button.new(self,  Wx::ID_ANY,  String_lang::get({"fr" => "Coller", "eng" => "Paste"}))
		button4 = Wx::Button.new(self,  Wx::ID_ANY,  String_lang::get({"fr" => "Supprimer", "eng" => "Delete"}))
		button3.enable(false)
		button4.enable(false)
		box2.add(button1, 1, Wx::GROW)
		box2.add(button2, 1, Wx::GROW)
		box2.add(button3, 1, Wx::GROW)
		box2.add(button4, 1, Wx::GROW)
		top_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		top_sizer.add(box1, 0, Wx::GROW)
		top_sizer.add_spacer(20)
		top_sizer.add(box2, 1, Wx::GROW)
		
		notebook = Wx::Notebook.new(self, Wx::ID_ANY)
		panel_page = Panel_page.new(notebook)
		notebook.set_background_colour(Wx::Colour.new(200,200, 225))
		notebook.add_page(panel_page, "1")
		
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(top_sizer, 0, Wx::GROW)
		main_sizer.add(notebook, 1, Wx::GROW)
		main_sizer.add_spacer(10)
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
		main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
		
		# Set evt
		evt_button(button1) do |event|
			notebook.add_page(Panel_page.new(notebook), (notebook.get_page_count()+1).to_s)
			button4.enable(true)
		end
		evt_button(button4) do |event|
			if (notebook.get_page_count() > 1)
				notebook.delete_page(notebook.get_selection())
				i = 0
				notebook.each_page() do |page|
					notebook.set_page_text(i,  (i+1).to_s)
					i += 1
				end
				button4.enable(false) if notebook.get_page_count() == 1
			end
		end
		evt_button(okCancel.button_ok) {end_modal(1000)}
		evt_button(okCancel.button_cancel) {end_modal(-1)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		
	end
end

class Panel_page < Wx::Panel
	
	def initialize(notebook)
		super(notebook)
		set_background_colour($background_color)
		
		# Conditions
		box1 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		width = 250
		list_inter = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [width,100], Wx::LC_REPORT | Wx::LC_NO_HEADER)
		list_inter.insert_column(0, "head")
		list_inter.set_column_width(0, width-21)
		list_inter.insert_item(0,  "<>")
		box1.add(list_inter)
		
		inf_conditions = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Conditions de l'évenement", "eng" => "Event conditions"}))
		inf_conditions.add(box1, 1, Wx::GROW)
		
		# Apparence + déplacements
		inf_apparence = Wx::BoxSizer.new(Wx::VERTICAL)
		inf_apparence.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Apparence", "eng" => "Graphic"}) + " : "))
		apparence_panel = Panel_apparence.new(self)
		inf_apparence.add_spacer(5)
		inf_apparence.add(apparence_panel)
		
		inf_deplacement = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Déplacement", "eng" => "Moving"}))
		box5 = Wx::FlexGridSizer.new(2,  4)
		box5.add(Wx::StaticText.new(self, Wx::ID_ANY, "Type : "))
		type = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Ne bouge pas", "eng" => "Fixed"}), String_lang::get({"fr" => "Aléatoire", "eng" => "Random"}), String_lang::get({"fr" => "Parcours", "eng" => "Route"})])
		type.set_selection(0)
		box5.add(type)
		box5.add(nil)
		edit_parcours = Wx::Button.new(self,  Wx::ID_ANY,  String_lang::get({"fr" => "Editer parcours", "eng" => "Edit route"}), Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::BU_EXACTFIT)
		edit_parcours.enable(false)
		box5.add(edit_parcours)
		box5.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Vitesse", "eng" => "Speed"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		speed = NumberCtrl.new(self, 0.0, 10.0, 1.0, 0.1, 5, false, Wx::DEFAULT_POSITION, [60, -1])
		box6 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box6.add(Wx::StaticText.new(self, Wx::ID_ANY, " x "), 0, Wx::ALIGN_CENTER_VERTICAL)
		box6.add(speed, 0, Wx::ALIGN_CENTER_VERTICAL)
		box5.add(box6)
		box5.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Fréquence", "eng" => "Frequency"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
		frequency = NumberCtrl.new(self, 0.0, 10.0, 1.0, 0.1, 5, false, Wx::DEFAULT_POSITION, [60, -1])
		box7 = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box7.add(Wx::StaticText.new(self, Wx::ID_ANY, " x "), 0, Wx::ALIGN_CENTER_VERTICAL)
		box7.add(frequency, 0, Wx::ALIGN_CENTER_VERTICAL)
		box5.add(box7)
		inf_deplacement.add(box5)
		
		size = inf_conditions.get_size()
		inf_apparence_deplacement = Wx::BoxSizer.new(Wx::HORIZONTAL)
		inf_apparence_deplacement.add(inf_apparence)
		inf_apparence_deplacement.add_spacer(20)
		inf_apparence_deplacement.add(inf_deplacement, 0, Wx::ALIGN_RIGHT)
		
		# Options + déclenchement
		inf_options = Wx::BoxSizer.new(Wx::VERTICAL)
		kind_apparence = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Aucune", "eng" => "None"}), String_lang::get({"fr" => "Sprite camera", "eng" => "Sprite camera"}), String_lang::get({"fr" => "Sprite fixe", "eng" => "Sprite fix"}), String_lang::get({"fr" => "Objet 3D", "eng" => "3D object"}), String_lang::get({"fr" => "Au sol", "eng" => "On the floor"}), String_lang::get({"fr" => "Sur les murs", "eng" => "On walls"})])
		kind_apparence.set_selection(0)
		inf_options.add(kind_apparence, 0, Wx::ALIGN_CENTER_HORIZONTAL)
		inf_options.add_spacer(5)
		
		check_options = []
		string_options = [String_lang::get({"fr" => "Animé au déplacement", "eng" => "Move animation"}), String_lang::get({"fr" => "Animé à l'arrêt", "eng" => "Stop animation"}), String_lang::get({"fr" => "Direction fixe", "eng" => "Direction fix"}), String_lang::get({"fr" => "Traversable", "eng" => "Through"})]
		string_options.each {|string| check_options.push(Wx::CheckBox.new(self, Wx::ID_ANY, string))}
		box2 = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, "Options")
		check_options.each do |check| 
			box2.add(check)
			box2.add_spacer(5)
		end
		inf_options.add(box2)
		inf_cond = Wx::RadioBox.new(self,  Wx::ID_ANY,  String_lang::get({"fr" => "Déclenchement", "eng" => "Trigger"}), Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, [String_lang::get({"fr" => "Par la touche action", "eng" => "Action button"}), String_lang::get({"fr" => "Au contact du héros", "eng" => "Player touch"}), String_lang::get({"fr" => "Contact évènement", "eng" => "Event touch"}), String_lang::get({"fr" => "Démarrage auto", "eng" => "Autorun"}), String_lang::get({"fr" => "Processus parallèle", "eng" => "Parallel process"})], 0,  Wx::RA_SPECIFY_ROWS)
		
		
		inf_options_cond = Wx::BoxSizer.new(Wx::HORIZONTAL)
		inf_options_cond.add(inf_options)
		inf_options_cond.add_spacer(20)
		inf_options_cond.add(inf_cond, 0, Wx::ALIGN_RIGHT)
		
		# Regroupement
		informations_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		informations_sizer.add(inf_conditions, 0, Wx::GROW)
		informations_sizer.add_spacer(5)
		informations_sizer.add(inf_apparence_deplacement, 0, Wx::GROW)
		informations_sizer.add_spacer(10)
		informations_sizer.add(inf_options_cond, 0, Wx::GROW)
		
		prog_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		prog = Panel_prog.new(self)
		prog_sizer.add(prog, 1, Wx::GROW)
		
		main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		main_sizer.add(informations_sizer, 0, Wx::ALL)
		main_sizer.add_spacer(20)
		main_sizer.add(prog_sizer, 1, Wx::GROW)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
		
		# Set evt
		#~ evt_button(button_delete_inter) do |event|
			#~ if (list_inter.get_selections()[0] != nil)
				#~ list_inter.delete_item(list_inter.get_selections()[0])
			#~ end
		#~ end
		#~ evt_button(button_add_inter) do |event|
			#~ dialog = Dialog_conditions.new(self)
			#~ dialog.show_modal
		#~ end
		
		current_selection = nil
		current_selection_label = nil
		
		list_inter.evt_left_dclick() do |event|
			if current_selection != nil
				dialog = Dialog_conditions.new(self)
				dialog.show_modal()
			end
		end
		
		list_inter.evt_key_down() do |event|
			if current_selection != nil
				if event.get_key_code() == 127 and current_selection_label != "<>"
					list_inter.delete_item(current_selection)
				end
			end
		end
		
		evt_list_item_selected(list_inter) do |event|
			current_selection = list_inter.get_selections()[0]
			current_selection_label = event.get_label()
		end
		
		evt_list_item_deselected(list_inter) do |event|
			current_selection = nil
			current_selection_label = nil
		end
	end
end

class Panel_apparence < Wx::Panel
	def initialize(parent)
		super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, [100,120], Wx::SIMPLE_BORDER)
		
		set_own_background_colour(Wx::Colour.new(250,250, 250))
		
		evt_left_dclick() {}
	end
end

class Panel_prog < Wx::Panel
	def initialize(parent)
		super(parent)
		
		@commands = [String_lang::get({"fr" => "Afficher un message", "eng" => "Display a message"}) + "...",
					String_lang::get({"fr" => "Afficher un choix", "eng" => "Display a choice"}) + "...",
					String_lang::get({"fr" => "Entrer un nombre", "eng" => "Enter a number"}) + "...",
					String_lang::get({"fr" => "Options d'affichage", "eng" => "Display options"}) + "...",
					"Conditions...",
					String_lang::get({"fr" => "Boucle", "eng" => "Loop"}),
					String_lang::get({"fr" => "Sortir de la boucle", "eng" => "Break loop"}),
					String_lang::get({"fr" => "Insérer un commentaire", "eng" => "Insert a comment"}) + "...",
					String_lang::get({"fr" => "Mettre une étiquette", "eng" => "Label"}) + "...",
					String_lang::get({"fr" => "Aller à l'étiquette", "eng" => "Jump to label"}) + "..."
					]
					
		current_command = ""
		
		list = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::LC_REPORT | Wx::LC_NO_HEADER)
		list.insert_column(0, "head")
		list.set_column_width(0, 456)
		list.insert_item(0,  "-> ")
		panel_commands = Panel_commands.new(list, [40, 0], @commands)

		
		
		main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		main_sizer.add(list, 1, Wx::GROW)
		
		set_sizer(main_sizer)
		
		panel_commands.hide
		
		evt_list_item_selected(Wx::ID_ANY) do |event|

		end

		underscore = true
		current_selection = nil
		
		list.evt_left_dclick() do |event|
			if current_selection != nil
				dialog = Dialog_event_commands.new(self, @commands)
				dialog.show_modal()
			end
		end
	
		list.evt_key_down() do |event|
			if current_selection != nil
				code = event.get_key_code()
				char = "a"
				new_char = ""
				
				for i in 65...91
					new_char = char if code == i
					char = char.next()
					break if new_char != ""
				end
				if new_char != ""
					new_char.capitalize! if current_command.size == 0
					current_command += new_char
				end
				if code == 8
					current_command = current_command[0...current_command.size-1]
				end
				if code == 32
					current_command += " "
				end
				
				text = "-> " + current_command
				text += "_" if underscore
				list.set_item_text(current_selection, text)
				panel_commands.update_texts(current_command)
			end
		end

		evt_list_item_selected(Wx::ID_ANY) do |event|
			current_selection = list.get_selections()[0]
			underscore = true
			current_command = ""
			panel_commands.move(40, ((current_selection+1)*14) + 2)
			panel_commands.update_texts(current_command)
			panel_commands.show
			list.set_item_text(current_selection, "-> " + current_command + "_")
		end
		
		evt_list_item_deselected(Wx::ID_ANY) do |event|
			list.set_item_text(current_selection, "-> ")
			current_command = ""
			current_selection = nil
			panel_commands.hide
			underscore = false
		end
	end
end

class Panel_commands < Wx::Panel
	def initialize(parent, pos, commands)
		super(parent, Wx::ID_ANY, pos, [416,500])
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		@commands = Array.new(commands)
		@commands_controls = []
		@commands.sort!

		i = 0
		@commands.each do |command|
			text = Wx::StaticText.new(self, Wx::ID_ANY, "-> " + command, [5, (i*15)])
			text.set_foreground_colour(Wx::BLACK)
			@commands_controls.push(text)
			i += 1
		end

		@font1 = Wx::Font.new()
		@font2 = Wx::Font.new()
		@font2.set_weight(Wx::FONTWEIGHT_BOLD)
		@commands_controls[0].set_font(@font2)
		
		@commands_controls.each do |command|
			command.evt_left_down() do |event|
				label = command.get_label()
				index = 0
				for i in 0...commands.size
					if label == ("-> " + commands[i])
						index = i
						break
					end
				end
				dialog = Event_interpreter::create_dialog(self, index)
				dialog.show_modal
			end
			command.evt_motion() do |event|
				@commands_controls.each do |command2|
					if command == command2
						command2.set_font(@font2)
					else
						command2.set_font(@font1)
					end
				end
			end
		end
	end
	
	def update_texts(current_command)
		i = 0
		j = 0
		@commands.each do |command|
			command = command.downcase 
			current_command = current_command.downcase 
			@commands_controls[j].set_font(@font1)
			grp1 = command.split(" ")
			grp2 = current_command.split(" ")
			grp2 = [""] if current_command == ""
			
			grp1.each do |word1|
				grp2.each do |word2|
					if word1.include?(word2)
						grp2.delete(word2)
					end
				end
			end
			
			if grp2.size == 0
				@commands_controls[j].set_font(@font2) if i == 0
				@commands_controls[j].show
				@commands_controls[j].move(5, (i*15))
				i += 1
			else
				@commands_controls[j].hide
			end
			j += 1
		end
	end
end