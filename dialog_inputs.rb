# encoding: UTF-8

class Dialog_inputs < Wx::Dialog
	ID_SCROLL = 6000
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent)
		super(parent, ID_SCROLL, String_lang::get({"fr" => "Gestion des inputs", "eng" => "Inputs management"}), Wx::DEFAULT_POSITION, [480, 400], Wx::DEFAULT_DIALOG_STYLE)
		set_own_background_colour($background_color)
		
		@scroll_win = Wx::ScrolledWindow.new(self, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::VSCROLL)
		@scroll_win.set_scrollbars(0, 5, 0, 10, 0, 0)
		@scroll_win.set_own_background_colour($background_color)
    
		box1 = Wx::StaticBoxSizer.new(Wx::VERTICAL, @scroll_win, String_lang::get({"fr" => "Liste des actions", "eng" => "Inputs list"}))
		@actions = {String_lang::get({"fr" => "Déplacement haut", "eng" => "Move forward"}) => "W", String_lang::get({"fr" => "Déplacement bas", "eng" => "Move backward"}) => "S", String_lang::get({"fr" => "Déplacement gauche", "eng" => "Move left"}) => "A", String_lang::get({"fr" => "Déplacement droite", "eng" => "Move right"}) => "D", String_lang::get({"fr" => "Camera gauche", "eng" => "Camera left"}) => String_lang::get({"fr" => "GAUCHE", "eng" => "LEFT"}), String_lang::get({"fr" => "Camera droite", "eng" => "Camera right"}) => String_lang::get({"fr" => "DROITE", "eng" => "RIGHT"}), "Action" => String_lang::get({"fr" => "ESPACE", "eng" => "SPACE"}), String_lang::get({"fr" => "Annuler", "eng" => "Cancel"}) => "X", String_lang::get({"fr" => "Menu principal", "eng" => "Principal menu"}) => String_lang::get({"fr" => "ECHAP", "eng" => "ESCAPE"})}
		@actions_panels = []
		colors = [Wx::Colour.new(200,200, 225), Wx::Colour.new(215,215, 235)]
		i = 0
		@actions.each do |action|
			@actions_panels.push(Panel_action.new(@scroll_win, action, colors[i]))
			i = (i+1) % 2
		end
		@actions_panels.each {|panel| box1.add(panel, 0, Wx::GROW)}
		
		scroll_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		scroll_sizer.add(box1, 1, Wx::ALL | Wx::GROW, 10)
		@scroll_win.set_sizer(scroll_sizer)
		
		# Main sizer
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(@scroll_win, 1, Wx::GROW)
		
		# Set sizer
		set_sizer(main_sizer)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		
	end
	
	class Panel_action < Wx::Panel
		def initialize(parent, action, color)
			super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, [-1,100])
			set_own_background_colour(color)
			box1 = Wx::GridSizer.new(2, 1)
			box1.add(Wx::StaticText.new(self, Wx::ID_ANY, action[0]), 0, Wx::ALIGN_CENTER_VERTICAL)
			
			box_input = Wx::GridSizer.new(2, 1)
			box_input.add(Wx::StaticText.new(self, Wx::ID_ANY, action[1]), 0, Wx::ALIGN_CENTER)
			box_input.add(Wx::Button.new(self, Wx::ID_ANY, "...", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::BU_EXACTFIT), 0, Wx::ALIGN_RIGHT)
			box1.add(box_input, 0, Wx::ALIGN_RIGHT)
			
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			main_sizer.add(box1, 1, Wx::ALL | Wx::GROW, 10)
			
			set_sizer(main_sizer)
		end
	end
end