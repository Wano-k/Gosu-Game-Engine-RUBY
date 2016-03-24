# encoding: UTF-8

class Dialog_colors < Wx::Dialog
	
	class Colors_panel < Wx::Panel
		attr_reader :timer
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent, color)
			super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::DOUBLE_BORDER)
			set_own_background_colour($background_color)

			# Sizers
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			name_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			big_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
			sliders_name_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			sliders_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			preview_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			
			# Variables
			rgb_color = color["color"]
			@color = Wx::Colour.new(rgb_color[0], rgb_color[1], rgb_color[2])
			@name = Wx::TextCtrl.new(self, Wx::ID_ANY); @name.set_value(color["name"])
			@slider_r = Wx::Slider.new(self, Wx::ID_ANY, rgb_color[0], 0, 255, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::SL_HORIZONTAL | Wx::SL_AUTOTICKS | Wx::SL_LABELS)
			@slider_r.set_tick_freq(15, 1); @slider_r.set_background_colour($background_color)
			@slider_g = Wx::Slider.new(self, Wx::ID_ANY, rgb_color[1], 0, 255, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::SL_HORIZONTAL | Wx::SL_AUTOTICKS | Wx::SL_LABELS)
			@slider_g.set_tick_freq(15, 1); @slider_g.set_background_colour($background_color)
			@slider_b = Wx::Slider.new(self, Wx::ID_ANY, rgb_color[2], 0, 255, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::SL_HORIZONTAL | Wx::SL_AUTOTICKS | Wx::SL_LABELS)
			@slider_b.set_tick_freq(15, 1); @slider_b.set_background_colour($background_color)
			@preview_panel = Wx::Panel.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::DOUBLE_BORDER); @preview_panel.set_own_background_colour($background_color)
			@ctrl_hexa = Wx::TextCtrl.new(self, Wx::ID_ANY); @ctrl_hexa.set_value("#" + @color.to_hex)
			
			
			# Name
			name_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Nom", "eng" => "Name"}) + " : "), 0, Wx::ALIGN_CENTER_VERTICAL)
			name_sizer.add(@name, 0, Wx::ALIGN_CENTER_VERTICAL)
		
			# Sliders
			sliders_name_sizer.add_spacer(25)
			sliders_name_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Rouge", "eng" => "Red"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			sliders_sizer.add(@slider_r, 1, Wx::GROW)
			sliders_name_sizer.add_spacer(40)
			sliders_name_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Vert", "eng" => "Green"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			sliders_sizer.add(@slider_g, 1, Wx::GROW)
			sliders_name_sizer.add_spacer(40)
			sliders_name_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, String_lang::get({"fr" => "Bleu", "eng" => "Blue"}) + " :"), 0, Wx::ALIGN_CENTER_VERTICAL)
			sliders_sizer.add(@slider_b, 1, Wx::GROW)
		
			
			# Panel + hexa
			preview_sizer.add(@preview_panel, 1, Wx::GROW)
			preview_sizer.add_spacer(10)
			preview_sizer.add(@ctrl_hexa, 0, Wx::GROW)
			
			# Big sizer
			big_sizer.add_spacer(5)
			big_sizer.add(sliders_name_sizer, 0, Wx::GROW)
			big_sizer.add(sliders_sizer, 2, Wx::GROW)
			big_sizer.add_spacer(20)
			big_sizer.add(preview_sizer, 1, Wx::GROW)
			
			
			
			# Main fusion
			main_sizer.add(name_sizer, 0, Wx::GROW)
			main_sizer.add_spacer(20)
			main_sizer.add(big_sizer, 0, Wx::GROW)
			
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)
			
			# Set evt
			@timer = Wx::Timer.new(self,101)
			evt_timer(101,:on_timer)
			evt_text(@ctrl_hexa) do |event|	
				new_color = Wx::Colour::from_hex(event.get_string())
				if new_color != nil
					@slider_r.set_value(new_color.red())
					@slider_g.set_value(new_color.green())
					@slider_b.set_value(new_color.blue())
				end
			end
			@timer.start(10)
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	on_timer
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def on_timer(evt)
			previous_color = @color
			begin
				@color = Wx::Colour.new(@slider_r.get_value(), @slider_g.get_value(), @slider_b.get_value())
			rescue

			end
			if @color != previous_color
				@ctrl_hexa.change_value("#" + @color.to_hex)
			end
			@preview_panel.set_own_background_colour(@color)
			@preview_panel.refresh
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	get_value
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def get_value()
			return {"name" => @name.get_value(), "color" => [@slider_r.get_value(), @slider_g.get_value(), @slider_b.get_value()]}
		end
	
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, color)
		super(parent, Wx::ID_ANY, String_lang::get({"fr" => "Couleur", "eng" => "Color"}), Wx::DEFAULT_POSITION, [600, 310], Wx::DEFAULT_DIALOG_STYLE)
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		@main_panel = Colors_panel.new(self, color)
		
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
			@main_panel.timer.stop()
			end_modal(1000)
		end
		evt_button(okCancel.button_cancel) do |event|
			@main_panel.timer.stop()
			end_modal(-1)
		end
		evt_close() do |event|
			@main_panel.timer.stop()
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