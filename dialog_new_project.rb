# encoding: UTF-8

class Dialog_new_project < Wx::Dialog
	
	class New_project_panel < Wx::Panel
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent)
			super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::DOUBLE_BORDER)
			set_own_background_colour($background_color)

			# Sizers
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			title_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			location_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			
			# Variables
			@title = Wx::TextCtrl.new(self, Wx::ID_ANY); @title.set_value(String_lang::get({"fr" => "Jeu sans nom", "eng" => "Game without name"}))	
			@location = TextButtonCtrl.new(self, Dir.pwd + "/Games", 370); @location.values = Dir.pwd + "/Games"; @location.set_own_background_colour(Wx::Colour.new(225,225, 245))
			
			
			# Title
			title_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom du jeu", "eng" => "Name of game"}) + " : "))
			title_sizer.add(@title, 1, Wx::GROW)
			
			# Location
			location_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Emplacement", "eng" => "Location"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
			location_sizer.add(@location, 1, Wx::GROW)

		
			
			# Main fusion
			main_sizer.add(title_sizer, 0, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(location_sizer, 0, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			# Set evt
			evt_button(@location.button)  do |event|
				direct = Wx::DirDialog.new(self, String_lang::get({"fr" => "Choisissez un dossier", "eng" => "Select a directory"}), Dir.pwd + "/Games")
				if (direct.show_modal() == 1000)
					path = direct.get_path().gsub('\\', '/')
					@location.text_ctrl.set_item_text(0, path)
					@location.values = path
				end
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return [@title.get_value, @location.values]
		end
	
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Nouveau jeu", "eng" => "New game"}), Wx::DEFAULT_POSITION, [500, 170])
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		@main_panel = New_project_panel.new(self)
		
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		global_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		global_sizer.add(@main_panel, 1, Wx::GROW)
		global_sizer.add_spacer(10)
		global_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(global_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
		
		# Set evt
		evt_button(okCancel.button_ok) do |event|
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
		return @main_panel.get_value()
	end
end