# encoding: UTF-8

class Dialog_scripts < Wx::Dialog
	
	class Panel_scripts < Wx::Panel
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent)
			super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::DOUBLE_BORDER)
			set_own_background_colour($background_color)
			
			
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent)
		super(parent, Wx::ID_ANY, "Scripts", Wx::DEFAULT_POSITION, [800, 600], Wx::DEFAULT_DIALOG_STYLE)
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		scripts_panel = Panel_scripts.new(self)
		panel_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour(Wx::Colour.new(200,200, 225))
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(panel_sizer, 1, Wx::GROW)
		main_sizer.add_spacer(20)
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
		
	end
end