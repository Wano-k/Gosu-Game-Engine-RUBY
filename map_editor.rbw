 # encoding: UTF-8
#!/usr/bin/env ruby

require "rubygems"
require "gosu"
require "opengl"
require "texplay"
require "scanf"
require "chunky_png"
require 'dl/import'
require 'dl/struct'
require 'fileutils'
require 'wx'
require 'ruby-prof'
require 'Matrix'

require_relative "image_manager.rb"
require_relative "map.rb"
require_relative "hero.rb"
require_relative "camera.rb"
require_relative "interface.rb" 
require_relative "map_editor.rb"
require_relative "class_texture.rb"
require_relative "utils.rb"
require_relative "autotiles.rb"
require_relative "toolbar_editor.rb"
 
require_relative "sprite.rb"
require_relative "rect.rb"
require_relative "bitmap.rb"
require_relative "selection_rectangle.rb"
require_relative "text.rb"
require_relative "string_lang.rb"
require_relative "RTP/SourceCode/Wanok.rb"
require_relative "RTP/SourceCode/Game_map.rb"
require_relative "RTP/SourceCode/Game_map_portion.rb"

file = File.open("Datas/editor/editcom.txt", "r:UTF-8").readlines
tab = file[0].chomp.split("$")
$directory = tab[1]
$map_name = tab[2]
lines = File.open($directory + "PROPERTIES.txt", "r:UTF-8").readlines
begin
	$tile_size = lines[0].chomp.split(":")[1].to_f
rescue 
	$tile_size = 16.0
end
begin
	tab = lines[1].chomp.split(":")[1].split(",")
	$ground_color = Gosu::Color.new(tab[0].to_i, tab[1].to_i, tab[2].to_i)
rescue
	$ground_color = Gosu::Color.new(0,0,0)
end
at_exit {
	if $window.render != nil
		$window.render.save($directory + "Maps/" + $map_name + "/render.png")
		$window.render_grid.save($directory + "Maps/" + $map_name + "/render_grid.png")
	end
	
	file = File.open("Datas/editor/editcom.txt", "w:UTF-8")
	file.puts("false")
	file.close

	FileUtils.rm_rf(Dir.glob($directory + "/Maps/" + $map_name + "/TemporalSave/*"))
}

Gosu::enable_undocumented_retrofication

$screen_x =  928
$screen_y = 576

$window_x = $screen_x/928.0
$window_y = $screen_y/576.0
$font_name = "Corbel"
$font_size = 16
$lang = "eng"
$keys_repeat = {}
$debug = true

#--------------------------------------------------------------------------------------------------------------------------------
#	[CLASS] SaveApp
#--------------------------------------------------------------------------------------------------------------------------------

class SaveApp < Wx::App
	def on_init
		frame = Frame.new("Save")
		frame.show
	end
	
	class Frame < Wx::Frame
  
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(title)
			super(nil, :title => title, :size => [ 400, 200])
			
			
		end
	end
end

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
		frame = ErrorFrame.new("", @error)
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
		main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		main_sizer.add(sizer, 1, Wx::ALIGN_CENTER)
		
		# Set sizer
		set_sizer(main_sizer)
		
		centre()
	end
end

def p(txt)
	if $debug
		s = txt.inspect.chomp.unpack("C*").pack("U*")[0...1024]
		
		file = File.open("Datas/editor/consolecom.txt", "a:UTF-8")
		file.puts(s)
		file.close
	end
end

def print(txt)
	if $debug
		$app_main = App.new(txt)
		$app_main.main_loop
	end
end

def print_if(txt, kb)
	print txt if $window.button_down?(kb)
end

#--------------------------------------------------------------------------------------------------------------------------------
#	Screen size
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
#	CLASS WINDOW
#--------------------------------------------------------------------------------------------------------------------------------


class Window < Gosu::Window 
	 attr_accessor :im, 
			:hero, 
			:map, 
			:camera, 
			:party, 
			:interface, 
			:interpreter, 
			:ground, 
			:move_tick, 
			:song, 
			:volume, 
			:time, 
			:moves, 
			:input, 
			:troops,
			:colors,
			:selected_mouse,
			:selected_mouse_obj,
			:textures,
			:screen,
			:render,
			:render_grid
	 
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize
		super($screen_x, $screen_y, false)
		$window = self
		
		$game_map = Wanok::load_datas($directory + "Maps/" + $map_name + "/infos.map")
		@im = Image_manager.new($directory)
		@interface = Interface.new($directory, $map_name)
		@ground = $ground_color
		@colors = Hash.new
		@screen = true
		
		glEnable(GL_ALPHA_TEST)
		glEnable(GL_TEXTURE_2D)
		glAlphaFunc(GL_GREATER, 0)
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	needs_cursor?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def needs_cursor?
		return true
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id)
		exit if id == Gosu::KbF12
		
		@hero.button_down(id) if @hero != nil
		@interface.button_down(id)
		@camera.button_down(id) if @camera != nil
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_up
	#--------------------------------------------------------------------------------------------------------------------------------
	 
	def button_up(id)       
		$keys_repeat.delete(id)
		
		@hero.button_up(id) if @hero != nil
		@interface.button_up(id)
		@camera.button_up(id) if @camera != nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down_repeat
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down_repeat(id, time = 0)
		$keys_repeat[id] = [time,time] if !button_down_repeat?(id)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down_repeat?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down_repeat?(id)
		return ($keys_repeat[id] != nil)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update
		@camera.look if @camera != nil
		@hero.update() if @hero != nil
		@map.update()
		@interface.update()
		@camera.update() if @camera != nil
		
		self.caption = String_lang::get({"fr" => "Editeur de carte", "eng" => "Map editor"}) + " - " + Gosu::fps.to_s + "FPS"
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------

	def draw
		gl do 
			glEnableClientState(GL_VERTEX_ARRAY) 
			glEnableClientState(GL_TEXTURE_COORD_ARRAY)
			glEnableClientState(GL_NORMAL_ARRAY) 
			glEnable(GL_TEXTURE_2D) 
			glEnable(GL_DEPTH_TEST) 
			glClearColor(255.0,255.0,255.0,1.0)
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) 
			glColor3ub(0,0,0) 
			@textures = false
			@map.draw() if @map != nil
			@selected_mouse_obj = @colors[Wanok::get_mouse_color()]
			glClearColor(@ground.red/255.0, @ground.green/255.0, @ground.blue/255.0, 1.0)
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT) 
			glColor3ub(0,0,0) 
			@textures = true
			if @screen
				@camera.look($game_map.size[0]*$tile_size/2, 9*$tile_size, ($game_map.size[1]*$tile_size)+(20*$tile_size), $game_map.size[0]*$tile_size/2, 0.0, ($game_map.size[1]*$tile_size)-(15*$tile_size))  if @camera != nil
			else
				@camera.look if @camera != nil
			end
			Gosu::scale(1, -1) {
				@map.draw(@screen) if @map != nil
			}
			if @screen
				image = Gosu::Image.new("Datas/editor/render.png")
				glBindTexture(GL_TEXTURE_2D, image.gl_tex_info.tex_name)
				glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, (width-640)/2, 0, 640, 480)
				image = image.subimage(0, 0, 640, 480)
				@render = image
				
				@map.draw_grid()
				image = Gosu::Image.new("Datas/editor/render.png")
				glBindTexture(GL_TEXTURE_2D, image.gl_tex_info.tex_name)
				glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, (width-640)/2, 0, 640, 480)
				image = image.subimage(0, 0, 640, 480)
				@render_grid = image
				
				@screen = false
				draw()
			end
			
			@hero.draw()  if @hero != nil
			
			@interface.draw
		end
	end
end
Window.new.show