# encoding: UTF-8

class Dialog_lang < Wx::Dialog
	
	class Name_panel < Wx::Panel
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(notebook, parent, name)
			super(notebook)
			set_own_background_colour($background_color)
			
			@name = Wx::TextCtrl.new(self, Wx::ID_ANY, name)
			
			main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			main_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom", "eng" => "Name"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			main_sizer.add_spacer(5)
			main_sizer.add(@name, 1, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return @name.get_value()
		end
	end
	
	class Dialog_lang_selection < Wx::Dialog

		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent, title, l, l_n)
			super(parent, Wx::ID_ANY, title, Wx::DEFAULT_POSITION, [260, 185], Wx::DEFAULT_DIALOG_STYLE)
			set_own_background_colour(Wx::Colour.new(200,200, 225))
			@languages2 = Array.new(l)
			@languages_names2 = l_n.clone
			@languages2.each do |lang|
				@languages_names2[lang] = l_n[lang].clone
			end
		
			if title == ""
				@languages2.push(title)
				@languages_names2[title] = {}
				@languages2.each do |lang|
					@languages_names2[title][lang] = ""
				end
				@languages2.each do |lang|
					@languages_names2[lang][title] = ""
				end
			end
			
			# Sizers
			name_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			
			# Variables
			@name = Wx::TextCtrl.new(self, Wx::ID_ANY, title)
			@new_name = title
			@button_name = Wx::Button.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Confirmer le nom", "eng" => "Confirm name"}))
			@notebook = Wx::Notebook.new(self, Wx::ID_ANY)
			@languages2.each do |lang|
				@notebook.add_page(Name_panel.new(@notebook, self, @languages_names2[@new_name][lang]), lang)
			end
			@notebook.set_background_colour(Wx::Colour.new(200,200, 225))
		
			# 1
			name_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom court", "eng" => "Short name"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			name_sizer.add_spacer(5)
			name_sizer.add(@name, 1, Wx::GROW)
			name_sizer.add_spacer(5)
			name_sizer.add(@button_name, 0, Wx::GROW)
		
		
			okCancel = OkCancel.new(self)
			okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
			main_sizer.add(name_sizer, 0, Wx::GROW)
			main_sizer.add_spacer(5)
			main_sizer.add(@notebook, 1, Wx::GROW)
			main_sizer.add_spacer(20)
			main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
			
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			evt_button(@button_name) do |event|
				if @name.get_value() == ""
					alert = Wx::MessageDialog.new(nil, String_lang::get({"fr" => "Vous ne pouvez pas laisser le champ du nom vide.", "eng" => "You can't let the name's field empty."}), String_lang::get({"fr" => "Attention", "eng" => "Warning"}), Wx::ICON_INFORMATION)
					alert.show_modal	
				elsif @languages2.include?(@name.get_value())
					if @name.get_value() != @new_name
						alert = Wx::MessageDialog.new(nil, String_lang::get({"fr" => "Ce nom existe déjà.", "eng" => "This name already exists."}), String_lang::get({"fr" => "Attention", "eng" => "Warning"}), Wx::ICON_INFORMATION)
						alert.show_modal	
					end
				else 
					previous_name = @new_name
					@new_name = @name.get_value()
					
					id = @languages2.index(previous_name)
					@languages2[id] = @new_name
					@languages_names2[@new_name] = @languages_names2[previous_name].clone
					@languages_names2.delete(previous_name)
					@languages_names2.each_key do |lang|
						@languages_names2[lang][@new_name] = @languages_names2[lang][previous_name]
						@languages_names2[lang].delete(previous_name)
					end
					@notebook.set_page_text(id, @new_name)
				end
			end
			
			evt_button(okCancel.button_ok) do |event|
				if @new_name != @name.get_value()
					alert = Wx::MessageDialog.new(nil, String_lang::get({"fr" => "Vous n'avez pas confirmé le nom.", "eng" => "You didn't confirm the name."}), String_lang::get({"fr" => "Attention", "eng" => "Warning"}), Wx::ICON_INFORMATION)
					alert.show_modal	
				elsif @new_name != ""
					i = 0
					@notebook.each_page() do |page|
						@languages_names2[@new_name][@languages2[i]] = page.get_value()
						i += 1
					end
					end_modal(1000)
				else
					alert = Wx::MessageDialog.new(nil, String_lang::get({"fr" => "Vous ne pouvez pas laisser le champ du nom vide.", "eng" => "You can't let the name's field empty."}), String_lang::get({"fr" => "Attention", "eng" => "Warning"}), Wx::ICON_INFORMATION)
					alert.show_modal	
				end
			end
			
			evt_button(okCancel.button_cancel) do |event|
				end_modal(-1)
			end
		end
	
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return [@languages2, @languages_names2]
		end
	end
	
	class Dialog_lang_display < Wx::Dialog
		
		class System < Wx::ScrolledWindow
		
			#--------------------------------------------------------------------------------------------------------------------------------
			#	initialize
			#--------------------------------------------------------------------------------------------------------------------------------
			
			def initialize(notebook, all_texts)
				super(notebook)
				set_own_background_colour($background_color)

				# Sizers
				main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
				
				# Variables
				@name = LangButtonCtrl.new(self, all_texts["name"], 145)
				@launcher_caption = LangButtonCtrl.new(self, all_texts["launcher_caption"], 145)
				
				box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, String_lang::get({"fr" => "Général", "eng" => "Global"}))
				box2 = Wx::BoxSizer.new(Wx::HORIZONTAL)
				box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom du jeu", "eng" => "Game name"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
				box2.add_spacer(5)
				box2.add(@name, 0, Wx::GROW)
				box2.add_spacer(10)
				box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Launcher - titre", "eng" => "Launcher - caption"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
				box2.add_spacer(5)
				box2.add(@launcher_caption, 0, Wx::GROW)
				box1.add(box2)
				main_sizer.add(box1)
				main_sizer.add_spacer(5)
				
				window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
				window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
				
				# Set sizer
				set_sizer(window_sizer)

				set_scrollbars(1, 1, 1, 1, 0, 0, true)
				show()
			end
			
			#--------------------------------------------------------------------------------------------------------------------------------
			#	get_default_value
			#--------------------------------------------------------------------------------------------------------------------------------
			
			def self.get_default_value()
				return {"name" => $game_system.name, "launcher_caption" => $game_system.launcher_caption}
			end
		
			#--------------------------------------------------------------------------------------------------------------------------------
			#	get_value
			#--------------------------------------------------------------------------------------------------------------------------------
			
			def get_value()
				return {"name" => @name.values, "launcher_caption" => @launcher_caption.values}
			end
		end
	
	
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent, all_texts)
			super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Textes", "eng" => "Texts"}), Wx::DEFAULT_POSITION, [640, 480], Wx::DEFAULT_DIALOG_STYLE)
			set_own_background_colour(Wx::Colour.new(200,200, 225))
			
			# Sizers
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			
			# Variables
			notebook = Wx::Notebook.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NB_MULTILINE)
			@system = System.new(notebook, all_texts["system"])
			notebook.add_page(@system, String_lang::get({"fr" => "Système", "eng" => "System"}))
			notebook.add_page(Wx::Panel.new(notebook), String_lang::get({"fr" => "Messages d'events", "eng" => "Event messages"}))
			notebook.add_page(Wx::Panel.new(notebook), String_lang::get({"fr" => "Objets", "eng" => "Items"}))
			notebook.add_page(Wx::Panel.new(notebook), String_lang::get({"fr" => "Objets", "eng" => "..."}))
			notebook.set_background_colour(Wx::Colour.new(200,200, 225))
		
			# 1
		
		
			okCancel = OkCancel.new(self)
			okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
			main_sizer.add(notebook, 1, Wx::GROW)
			main_sizer.add_spacer(20)
			main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
			
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			evt_button(okCancel.button_ok) do |event|
				end_modal(1000)
			end
			
			evt_button(okCancel.button_cancel) do |event|
				end_modal(-1)
			end
		end
	
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_default_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def self.get_default_value()
			return {"system" => System::get_default_value()}
		end
			
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return {"system" => @system.get_value()}
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Langues", "eng" => "Languages"}), Wx::DEFAULT_POSITION, [300, 200], Wx::DEFAULT_DIALOG_STYLE)
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		@all_texts = Dialog_lang_display::get_default_value()
		
		# Sizers
		list_sizer = Wx::FlexGridSizer.new(2, 2, 5, 5)
		
		# Variables
		width = 240
		@languages = Array.new($game_langs.languages)
		@languages_names = $game_langs.languages_names.clone
		@languages.each do |lang|
			@languages_names[lang] = $game_langs.languages_names[lang].clone
		end
		@list = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [width,-1], Wx::LC_REPORT | Wx::LC_NO_HEADER)
		@list.insert_column(0, "head")
		@list.set_column_width(0, width-21)
		set_list()
		b = Wx::Bitmap.new("Datas/bmp/big_arrow_up.png")
		@button_up = Wx::BitmapButton.new(self, Wx::ID_ANY, b, Wx::DEFAULT_POSITION)
		b = Wx::Bitmap.new("Datas/bmp/big_arrow_down.png")
		@button_down = Wx::BitmapButton.new(self, Wx::ID_ANY, b, Wx::DEFAULT_POSITION)
		@button_messages = Wx::Button.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Afficher les textes", "eng" => "Display texts"}))
		
		#
		list_sizer.add(@list, 0, Wx::GROW)
		box = Wx::BoxSizer.new(Wx::VERTICAL)
		box.add(@button_up, 0, Wx::GROW)
		box.add(@button_down, 0, Wx::GROW)
		list_sizer.add(box, 0, Wx::GROW)
		list_sizer.add(@button_messages, 0, Wx::GROW)
		
		
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(list_sizer, 1, Wx::GROW)
		main_sizer.add_spacer(20)
		main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
		
		# Set evt
		current_selection = nil
		current_selection_label = nil
		
		@list.evt_left_dclick() do |event|
			begin
			if current_selection != nil
				if @languages.size == current_selection
					dialog = Dialog_lang_selection.new(self, "", @languages, @languages_names)
				else
					dialog = Dialog_lang_selection.new(self, @languages[current_selection], @languages, @languages_names)
				end
				if (dialog.show_modal() == 1000)
					val = dialog.get_value()
					@languages = val[0]
					@languages_names = val[1]
					set_list()
				end
			end
			rescue Exception => e  
				FrameAlert::message(e)
			end
		end
		
		@list.evt_key_down() do |event|
			begin
			if current_selection != nil
				if event.get_key_code() == 127 and current_selection_label != "<> "
					if @languages.size == 1
						alert = Wx::MessageDialog.new(nil, String_lang::get({"fr" => "Vous devez garder au moins une langue.", "eng" => "You have to keep at least one language."}), String_lang::get({"fr" => "Attention", "eng" => "Warning"}), Wx::ICON_INFORMATION)
						alert.show_modal	
					else
						@languages_names.delete(@languages[current_selection])
						@languages_names.each_key do |lang|
							@languages_names[lang].delete(@languages[current_selection])
						end
						@languages.delete_at(current_selection)
						
						@list.delete_item(current_selection)
						set_list()
					end
				end
			end
			rescue Exception => e  
				FrameAlert::message(e)
			end
		end
		
		evt_list_item_selected(@list) do |event|
			begin
			current_selection = @list.get_selections()[0]
			current_selection_label = event.get_label()
			rescue Exception => e  
				FrameAlert::message(e)
			end
		end
		
		evt_list_item_deselected(@list) do |event|
			begin
			current_selection = nil
			current_selection_label = nil
			rescue Exception => e  
				FrameAlert::message(e)
			end
		end
		
		evt_button(@button_up) do |event|
			begin
			if current_selection != nil and current_selection != 0 and current_selection_label != "<> "
				@languages.insert(current_selection-1, @languages[current_selection])
				@languages.delete_at(current_selection+1)
				set_list()
			end
			rescue Exception => e  
				FrameAlert::message(e)
			end
		end
		
		evt_button(@button_down) do |event|
			begin
			if current_selection != nil and current_selection != @languages.size-1 and current_selection_label != "<> "
				@languages.insert(current_selection+2, @languages[current_selection])
				@languages.delete_at(current_selection)
				set_list()
			end
			rescue Exception => e  
				FrameAlert::message(e)
			end
		end
		
		evt_button(@button_messages) do |event|
			begin
			dialog = Dialog_lang_display.new(self, @all_texts)
			if (dialog.show_modal() == 1000)
				@all_texts = dialog.get_value()
			end
			rescue Exception => e  
				FrameAlert::message(e)
			end
		end
		
		evt_button(okCancel.button_ok) {end_modal(1000)}
		evt_button(okCancel.button_cancel) {end_modal(-1)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_list
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_list()
		@list.delete_all_items()
		i = 0
		@languages.each do |lang|
			trad = ""
			@languages.each do |lang2|
				lang_trad = @languages_names[lang][lang2]
				trad += lang2 + " => " + lang_trad + ", "
			end
			trad = trad[0...trad.size-2]
			@list.insert_item(i, "<> " + lang + " : " + trad)
			i += 1
		end
		@list.insert_item(i, "<> ")
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		return [@languages, @languages_names, @all_texts]
	end
end