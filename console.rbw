# encoding: UTF-8
#!/usr/bin/env ruby

require 'rubygems' 
require 'fileutils'
require 'wx'
	
class App < Wx::App
	def on_init
		frame = PrincipalFrame.new("Console")
		frame.show
	end
end

class PrincipalFrame < Wx::Frame
	
	class Display < Wx::ScrolledWindow
		attr_accessor :text
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(window)
			super(window)
			set_own_background_colour(Wx::Colour.new(255, 255, 255))

			# Sizers
			main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			
			# Variables
			sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			@text = Wx::StaticText.new(self, Wx::ID_ANY, ">")
			sizer.add(@text, 1, Wx::ALIGN_LEFT)
			
			
			#...
			main_sizer.add(sizer, 1, Wx::ALIGN_LEFT)
			
			window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
			window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 10)
			
			# Set sizer
			set_sizer(window_sizer)

			set_scrollbars(1, 1, 1, 1, 0, 0, true)
			show()
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(title)
		super(nil, :title => title, :size => [600, 300])
		set_own_background_colour(Wx::Colour.new(255, 255, 255))
		
		@display = Display.new(self)
		@line_nb = 1
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(@display, 1, Wx::ALL | Wx::GROW)
		set_sizer(main_sizer)
		
		timer = Wx::Timer.new(self, Wx::ID_ANY)
		evt_timer(timer.id) {update_editor()}
		timer.start(10)
	end
		
	def update_editor()
		file = File.open("Datas/Editor/consolecom.txt", "r:UTF-8").readlines
		if file[0] != nil
			editor = eval(file[0].chomp)
			if !editor
				on_quit()
			else
				if file.size > 1 and @line_nb != file.size
					@line_nb = file.size
					text = ""
					for i in 1...file.size
						text += "> " + file[i] +"\n"
					end
					@display.text.set_label(text)
					@display.refresh()
					@display.set_scrollbars(1, 1, 1, 1, 0, 0, true)
					@display.refresh()
					@display.show()
				end
			end
		end
	end
		
	#--------------------------------------------------------------------------------------------------------------------------------
	#	on_quit
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def on_quit
		file = File.open("Datas/editor/consolecom.txt", "w:UTF-8")
		file.puts("false")
		file.close
		close()
	end
 end

$app_main = App.new
$app_main.main_loop