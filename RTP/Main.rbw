# encoding: UTF-8

#--------------------------------------------------------------------------------------------------------------------------------
#
#	
#
#	Main file, displaying the principal window.
#
#
#--------------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------------
#	Informations
#--------------------------------------------------------------------------------------------------------------------------------

# All docs required
require "rubygems"
require "gosu"
require "opengl"
require "texplay"
require "scanf"
require "chunky_png"
require 'dl/import'
require 'dl/struct'
require 'wx'

Dir.entries("SourceCode").each do |code|
	eval(File.open("SourceCode/" + code, "r:UTF-8").readlines.join("\n")) if code.include?(".rb") 
end

# Global variables
$game_system = Wanok::load_datas("Datas/System.rpmdatas")
$game_langs = Wanok::load_datas("Datas/Data_lang.rpmdatas")

$tile_size = 16.0 
$game_start = nil
$game_playing = false
$window_x = $game_system.screen_x/640.0
$window_y = $game_system.screen_y/480.0
$font_name = "Corbel"
$font_size = 16
$lang = $game_langs.current_lang

at_exit {
	file = File.open("Datas/Editor/editcom.txt", "w:UTF-8")
	file.puts("false")
	file.close
}

#--------------------------------------------------------------------------------------------------------------------------------
#	Screen size methods
#--------------------------------------------------------------------------------------------------------------------------------
	
def _x(val)
	return ($window_x*val).round
end

def _y(val)
	return ($window_y*val).round
end

def _xy(val)
	return ((($window_x+$window_y)/2)*val).round
end

def _xDouble(val)
	return ($window_x*val)
end

def _yDouble(val)
	return ($window_y*val)
end

#--------------------------------------------------------------------------------------------------------------------------------
#
#	[CLASSES] Window to display errors
#
#--------------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------------
#	[CLASS] App
#--------------------------------------------------------------------------------------------------------------------------------

class App < Wx::App
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------

	def initialize(error)
		super()
		@error  = error
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	on_init
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def on_init()
		frame = ErrorFrame.new("Error", @error)
		frame.show
	end
end

#--------------------------------------------------------------------------------------------------------------------------------
#	[CLASS] ErrorFrame
#--------------------------------------------------------------------------------------------------------------------------------

class ErrorFrame < Wx::Frame
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(title, error)
		super(nil, :title => title, :size => [400, 150])
		set_own_background_colour(Wx::Colour.new(225,225, 245))
		
		# Create text error
		s = error.inspect.chomp.unpack("C*").pack("U*")
		sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		text = Wx::StaticText.new(self, Wx::ID_ANY, s)
		text.wrap(350)
		sizer.add(text, 1, Wx::ALIGN_CENTER)
		button = Wx::Button.new(self,  Wx::ID_ANY, String_lang::get({"fr" => "Détails", "eng" => "Details"}))
		sizer.add_spacer(5)
		sizer.add(button, 0, Wx::ALIGN_CENTER)
		main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		main_sizer.add(sizer, 1, Wx::ALIGN_CENTER)
		
		# Set sizer
		set_sizer(main_sizer)
		
		centre()
		
		# Set evt
		evt_button(button) do |event|
			alert = Wx::MessageDialog.new(nil, error.backtrace.join("\n"), String_lang::get({"fr" => "Erreur", "eng" => "Error"}), Wx::ICON_INFORMATION)
			alert.show_modal
		end
	end
end

file = File.open("Datas/Editor/editcom.txt", "r:UTF-8").readlines
if !eval(file[0])
	launcher = false
else
	launcher = eval(file[1])
end
$launcher = {:closed => true}
Launcher.new.show if launcher
Window.new.show if (launcher and !$launcher[:closed]) or !launcher