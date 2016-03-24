# encoding: UTF-8

class TextButtonCtrl < Wx::Panel
	attr_reader :text_ctrl, :button
	attr_accessor :values
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, default_text, size_x = -1)
		super(parent)
		@text = default_text
		@values = []
		
		sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		@text_ctrl = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [size_x, 20], Wx::LC_REPORT | Wx::LC_NO_HEADER)
		@text_ctrl.insert_column(0, "head")
		@text_ctrl.set_column_width(0, size_x -10)
		@text_ctrl.insert_item(0, default_text)
		@button = Wx::Button.new(self,  Wx::ID_ANY,  "...", Wx::DEFAULT_POSITION, [-1, 20], Wx::BU_EXACTFIT)
		sizer.add(@text_ctrl)
		sizer.add(@button)
		
		# Set sizer
		set_sizer(sizer)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	enable
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def enable(b)
		@text_ctrl.enable(b)
		@button.enable(b)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		
	end
end

class ImageButtonCtrl < Wx::Panel
	attr_reader :text_ctrl, :button
	attr_accessor :values
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, default_text, b, size_x = -1)
		super(parent)
		@text = default_text
		@values = []
		
		sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		@text_ctrl = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [size_x, 20], Wx::LC_REPORT | Wx::LC_NO_HEADER)
		@text_ctrl.insert_column(0, "head")
		@text_ctrl.set_column_width(0, size_x -10)
		@text_ctrl.insert_item(0, default_text)
		@button = Wx::BitmapButton.new(self, Wx::ID_ANY, b, Wx::DEFAULT_POSITION, [-1, 20])
		sizer.add(@text_ctrl)
		sizer.add(@button)
		
		# Set sizer
		set_sizer(sizer)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	enable
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def enable(b)
		@text_ctrl.enable(b)
		@button.enable(b)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		
	end
end

class LangButtonCtrl < ImageButtonCtrl
	
	class Dialog_all < Wx::Dialog

		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent, text)
			super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Modifier pour toutes les langues", "eng" => "Set for all languages"}) , Wx::DEFAULT_POSITION, [200, 130], Wx::DEFAULT_DIALOG_STYLE)
			set_own_background_colour(Wx::Colour.new(200,200, 225))
			
			# Sizers
			name_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			
			# Variables
			@name = Wx::TextCtrl.new(self, Wx::ID_ANY, text[$game_langs.languages[0]])
			@new_text = text
			
			okCancel = OkCancel.new(self)
			okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
			main_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Modifier pour toutes les langues", "eng" => "Set for all languages"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			main_sizer.add_spacer(10)
			main_sizer.add(@name, 0, Wx::GROW)
			main_sizer.add_spacer(20)
			main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
			
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			evt_button(okCancel.button_ok) do |event|
				$game_langs.languages.each do |lang|
					@new_text[lang] = @name.get_value()
				end
				end_modal(1000)
			end
			
			evt_button(okCancel.button_cancel) do |event|
				end_modal(-1)
			end
		end
	
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return @new_text
		end
	end
	
	class Dialog_each < Wx::Dialog

		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent, text)
			super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Modifier pour chaque langue", "eng" => "Set for each language"}) , Wx::DEFAULT_POSITION, [250, 160], Wx::DEFAULT_DIALOG_STYLE)
			set_own_background_colour(Wx::Colour.new(200,200, 225))
			
			# Sizers
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			
			# Variables
			@new_text = text
			@notebook = Wx::Notebook.new(self, Wx::ID_ANY)
			$game_langs.languages.each do |lang|
				@notebook.add_page(Name_panel.new(@notebook, self, @new_text[lang], lang), lang)
			end
			@notebook.set_background_colour(Wx::Colour.new(200,200, 225))
			
			okCancel = OkCancel.new(self)
			okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
			main_sizer.add(@notebook, 1, Wx::GROW)
			main_sizer.add_spacer(20)
			main_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
			
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			evt_button(okCancel.button_ok) do |event|
				@notebook.each_page() do |page|
					@new_text[page.get_value()[0]] = page.get_value()[1]
				end
				end_modal(1000)
			end
			
			evt_button(okCancel.button_cancel) do |event|
				end_modal(-1)
			end
		end
	
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return @new_text
		end
	end
	
	class Name_panel < Wx::Panel
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(notebook, parent, name, lang)
			super(notebook)
			set_own_background_colour($background_color)
			
			@name = Wx::TextCtrl.new(self, Wx::ID_ANY, name)
			@lang = lang 
			
			main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
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
			return [@lang, @name.get_value()]
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, default_text, size_x = -1)
		super(parent, default_text[$game_langs.languages[0]], Wx::Bitmap.new("Datas/bmp/lang.png"), size_x)
		
		@values = default_text.clone
		
		evt_button(@button) do |event|
			dialog = Dialog_each.new(self, @values)
			if (dialog.show_modal() == 1000)
				@values = dialog.get_value()
				@text_ctrl.set_item_text(0, @values[$game_langs.languages[0]])
			end
		end
		
		@text_ctrl.evt_left_dclick() do |event|
			dialog = Dialog_all.new(self, @values)
			if (dialog.show_modal() == 1000)
				@values = dialog.get_value()
				@text_ctrl.set_item_text(0, @values[$game_langs.languages[0]])
			end
		end
	end
end

class NumberCtrl < Wx::Panel
	ID_TEXT = 2000
	
	attr_accessor :text_ctrl, :min_value, :max_value
	
	def initialize(parent, min_value, max_value, default_value = 0, progress = 1, max_length = 0, is_int = true, pos = Wx::DEFAULT_POSITION, size = Wx::DEFAULT_SIZE)
		super(parent)
		@min_value, @max_value, @is_int =  min_value, max_value, is_int
		
		sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		@text_ctrl = Wx::TextCtrl.new(self,  ID_TEXT, default_value.to_s, pos, size)
		@text_ctrl.set_max_length(max_length)
		inter_buttons = Wx::BoxSizer.new(Wx::VERTICAL)
		b = Wx::Bitmap.from_image(Wx::Image.new("Datas/bmp/arrow_up.png"))
		@button_up_inter = Wx::BitmapButton.new(self, Wx::ID_ANY, b, Wx::DEFAULT_POSITION, Wx::Size.new(-1,@text_ctrl.get_size.get_height/2))
		b = Wx::Bitmap.from_image(Wx::Image.new("Datas/bmp/arrow_down.png"))
		@button_down_inter = Wx::BitmapButton.new(self, Wx::ID_ANY, b, Wx::DEFAULT_POSITION, Wx::Size.new(-1,@text_ctrl.get_size.get_height/2))
		inter_buttons.add(@button_up_inter)
		inter_buttons.add(@button_down_inter)
		
		
		sizer.add(@text_ctrl, 0, Wx::ALIGN_CENTER_VERTICAL)
		sizer.add(inter_buttons, 0, Wx::ALIGN_CENTER_VERTICAL)
		# Set sizer
		set_sizer(sizer)
		# Set evt
		evt_text(ID_TEXT) do |event|
			change_value(@text_ctrl.get_value())
		end
		evt_button(@button_up_inter) do |event|
			new_val = get_value(@text_ctrl.get_value())+progress
			change_value(new_val)
		end
		evt_button(@button_down_inter) do |event|
			new_val = get_value(@text_ctrl.get_value())-progress
			change_value(new_val)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value(val)
		new_val = @is_int ? val.to_i : val.to_f
		new_val  = new_val.round(2) if !@is_int
		return new_val
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	change_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def change_value(val)
		new_val = @is_int ? val.to_i : val.to_f
		new_val  = new_val.round(2) if !@is_int
		new_val = @max_value if new_val >  @max_value
		new_val = @min_value if new_val < @min_value
		@text_ctrl.change_value(new_val.to_s)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	enable
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def enable(b)
		@text_ctrl.enable(b)
		@button_up_inter.enable(b)
		@button_down_inter.enable(b)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_final_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_final_value()
		return @text_ctrl.get_value().to_i
	end
end

class OkCancel < Wx::Panel
	attr_reader :button_ok, :button_cancel
	
	def initialize(parent)
		super(parent)
		sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		@button_ok = Wx::Button.new(self,  Wx::ID_ANY, "Ok")
		@button_cancel = Wx::Button.new(self,  Wx::ID_ANY, String_lang::get({"fr" => "Annuler", "eng" => "Cancel"}))
		sizer.add(@button_ok, 0, Wx::ALIGN_CENTER_VERTICAL)
		sizer.add(@button_cancel, 0, Wx::ALIGN_CENTER_VERTICAL)
		
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(sizer, 0, Wx::ALIGN_RIGHT)
		
		# Set sizer
		set_sizer(main_sizer)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		
	end
end

class Close < Wx::Panel
	:button_close
	
	def initialize(parent)
		super(parent)
		sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		button_close = Wx::Button.new(self,  Wx::ID_ANY, String_lang::get({"fr" => "Fermer", "eng" => "Close"}))
		sizer.add(button_close, 0, Wx::ALIGN_CENTER_VERTICAL)
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(sizer, 0, Wx::ALIGN_RIGHT)
		
		set_sizer(main_sizer)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		
	end
end

class AlertYesNo < Wx::Dialog
	def initialize(parent, message, size = WX::DEFAULT_SIZE)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Alerte", "eng" => "Alert"}),  Wx::DEFAULT_POSITION, size)
		sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		text = Wx::StaticText.new(self, Wx::ID_ANY, message)
		buttons = Wx::BoxSizer.new(Wx::HORIZONTAL)
		button_yes = Wx::Button.new(self,  Wx::ID_ANY, String_lang::get({"fr" => "Oui", "eng" => "Yes"}))
		button_no = Wx::Button.new(self,  Wx::ID_ANY, String_lang::get({"fr" => "Non", "eng" => "No"}))
		buttons.add(button_yes)
		buttons.add(button_no)
		sizer.add(text, 1, Wx::ALIGN_CENTER)
		sizer.add(buttons, 1, Wx::ALIGN_CENTER)
		
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(sizer, 0, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(main_sizer)
		
		evt_button(button_yes) {end_modal(1000)}
		evt_button(button_no) {end_modal(-1)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		
	end
end