# encoding: UTF-8

class Dialog_new_map < Wx::Dialog
	
	class New_map_panel < Wx::Panel
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent, map)
			super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::DOUBLE_BORDER)
			set_own_background_colour($background_color)
			

			# Sizers
			main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			left_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			right_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			
			# Variables
			@name = Wx::TextCtrl.new(self, Wx::ID_ANY);@name.set_value(map.virtual_map_name)
			@tileset = Wx::Choice.new(self,  Wx::ID_ANY,  Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, ["ID:0001:Main"]);@tileset.set_selection(map.tileset)
			@width = NumberCtrl.new(self, 1, 5000, map.size[0], 1, 4, true)
			@height = NumberCtrl.new(self, 1, 5000, map.size[1], 1, 4, true)
			
			# Left side
			left_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom", "eng" => "Name"}) + " : "))
			left_sizer.add_spacer(2)
			left_sizer.add(@name, 0, Wx::GROW)
			left_sizer.add_spacer(5)
			left_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, "Tileset"))
			left_sizer.add_spacer(2)
			left_sizer.add(@tileset, 0, Wx::GROW)
			left_sizer.add_spacer(5)
			box1 = Wx::BoxSizer.new(Wx::VERTICAL)
			box1.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Largeur", "eng" => "Width"}) + " : "))
			left_sizer.add_spacer(2)
			box1.add(@width)
			box2 = Wx::BoxSizer.new(Wx::VERTICAL)
			box2.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Hauteur", "eng" => "Height"}) + " : "))
			left_sizer.add_spacer(2)
			box2.add(@height)
			box_nums = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box_nums.add(box1, 1, Wx::GROW)
			left_sizer.add_spacer(5)
			box_nums.add(box2, 1, Wx::GROW)
			left_sizer.add(box_nums, 0, Wx::GROW)

		
			# Main fusion
			main_sizer.add(left_sizer, 1, Wx::GROW)
			main_sizer.add_spacer(10)
			main_sizer.add(right_sizer, 1, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			# Set evt
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return [@name.get_value(), @tileset.get_selection(), @width.get_final_value(), @height.get_final_value()]
		end
	
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, map)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Nouvelle carte", "eng" => "New map"}), Wx::DEFAULT_POSITION, [550, 250])
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		@main_panel = New_map_panel.new(self, map)
		
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