# encoding: UTF-8
#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'wx'
require 'gosu'
require 'opengl'
require 'chunky_png'

require_relative "string_lang.rb"
require_relative "dialog_new_project.rb"
require_relative "dialog_scripts.rb"
require_relative "dialog_new_map.rb"
require_relative "dialog_inputs.rb"
require_relative "dialog_event.rb"
require_relative "dialog_event_commands.rb"
require_relative "dialog_lang.rb"
require_relative "dialog_datas.rb"
require_relative "dialog_previews.rb"
require_relative "dialog_window_skin.rb"
require_relative "dialog_colors.rb"
require_relative "event_interpreter.rb"
require_relative "tree_map.rb"
require_relative "panel_map.rb"
require_relative "file_edit.rb"
require_relative "custom_widgets.rb"
require_relative "image_manager.rb"
require_relative "class_texture.rb"
require_relative "logo.rb"
require_relative "gauge.rb"
require_relative "RTP/SourceCode/System.rb"
require_relative "RTP/SourceCode/Data_lang.rb"
require_relative "RTP/SourceCode/Game_map.rb"
require_relative "RTP/SourceCode/Game_map_portion.rb"
require_relative "RTP/SourceCode/Window_skin.rb"
require_relative "RTP/SourceCode/Wanok.rb"

$lang = "eng"
$title = "RPG Paper Maker RUBY v.0.0.0"
$title_game = ""
$editor = false
$testing = false
$background_color = Wx::Colour.new(225,225, 245)
$game_screen_x =  640
$game_screen_y = 480
$directory = nil

ID_NEW = 1
ID_BROWSE_PROJECT = 2
ID_OPEN_1 = 3
ID_OPEN_2 = 4
ID_OPEN_3 = 5
ID_INPUTS = 6
ID_DATAS = 7
ID_LANGUAGES = 8
ID_EVENT = 9
ID_TOOL_MAP_PLAY = 10
ID_TOOL_MAP_PLAY_LAUNCHER = 11
ID_TOOLBAR = 999

class Wx::Colour
	def self.from_hex(hex_str)
		unless hex_str =~ /\A#?[0-9A-F]{6}\z/i
			return nil
		end
		components = hex_str.scan(/[0-9A-F]{2}/i).map { | x | Integer("0x#{x}") }
		new(*components)
	end

	def to_hex
		[ :red, :green, :blue ].inject('') do | hex_str, component |
			hex_str << sprintf('%02X', send(component) )
		end
	end
	
	def RGBToHSL()
		r, g, b = red(), green(), blue()

		red = (r)/255.0
		green = (g)/255.0
		blue = (b)/255.0
				
		max = [blue, red, green].max
		min = [blue, red, green].min
				
		# Compute H
		h = 0.0
		if (max == min)
			h = 0
		elsif (max == red)
			h = (60.0 * (green-blue)/(max-min)).to_i % 360
		elsif (max == green)
			h = ((60.0 * (blue-red)/(max-min) + 120)).to_i % 360
		elsif (max == blue)
			h = ((60.0 * (red-green)/(max-min) + 240)).to_i % 360
		end	
		
		# Compute S
		s = 0.0
		if (max == min)
			s = 0
		elsif (max + min <= 1.0)
			s = (max-min)/(max+min)
		else 
			s = (max-min)/(2.0-(max+min))
		end
	     
		# Compute L
		l = max

		return [h,(s*100).to_i,(l*100).to_i]
	end
end

class FrameAlert
	def self.message(e)
		alert = Wx::MessageDialog.new(nil,
				String_lang::get({"fr" => "Attention, une erreur s'est produite", "eng" => "Warning, an error has occured"}) + " : \n" + e.to_s + "\n\n" + e.backtrace.join("\n"),
				String_lang::get({"fr" => "Erreur", "eng" => "Error"}),
				Wx::ICON_INFORMATION)
		alert.show_modal
	end
end
	
class App < Wx::App
	def on_init
		frame = PrincipalFrame.new($title)
		frame.show
		frame.show_windows(false)
	end
end

class PrincipalFrame < Wx::Frame
	class ListFileDropTarget < Wx::FileDropTarget
		def initialize(frame)
			super()
			@frame = frame
		end

		def on_drop_files(x, y, files)
			@frame.open_drop_project(files[0])
			return true
		end
	end
  
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(title)
		super(nil, :title => title, :size => [800, 600])
		begin
			centre()
			logo = Logo.new(self)
			logo.center_on_parent(Wx::BOTH)
			logo.show(true)
			
			self.drop_target = ListFileDropTarget.new(self)
			system = System.new()
			Wanok::save_datas("RTP/Datas/System.rpmdatas", system)
			data_lang = Data_lang.new()
			Wanok::save_datas("RTP/Datas/Data_lang.rpmdatas", data_lang)
			@map = nil
			set_own_background_colour(Wx::Colour.new(200,200, 225))
			set_icon(Wx::Icon.new("./icon.ico"))

			new_menu_bar
			
			box = Wx::BoxSizer.new(Wx::VERTICAL)
			@tool = Tool_bar.new(self)
			box.add(@tool,0,Wx::GROW)
			@splitter = Wx::SplitterWindow.new(self, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::SP_NO_XP_THEME | Wx::SP_3D | Wx::SP_LIVE_UPDATE)
			@tree = Tree_map.new(self, @splitter)
			@panel_map = Panel_map.new(self, @splitter, @tree)
			@splitter.split_vertically(@tree, @panel_map, 200)
			@splitter.set_minimum_pane_size(1)
			box.add(@splitter,1,Wx::GROW)
			
			set_sizer(box)
			create_status_bar(2)
			
			timer = Wx::Timer.new(self, Wx::ID_ANY)
			evt_timer(timer.id) {editor_update()}
			timer.start(10)
			
			timer_logo = Wx::Timer.new(self, Wx::ID_ANY)
			evt_timer(timer_logo.id) {timer_logo.stop;logo.close}
			timer_logo.start(1000)
			maximize(true)
			@tool.enable(false)
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
 
	#--------------------------------------------------------------------------------------------------------------------------------
	#	editor_update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def editor_update()
		begin
			if $editor
				file = File.open("Datas/Editor/editcom.txt", "r:UTF-8").readlines
				if file[0] != nil
					tab = file[0].chomp.split("$")

					#test if editor is open
					$editor = eval(tab[0])
					if !$editor
						enable()
						bring_to_front()
						@panel_map.window_map.set_image(@tree.map)
					else
						map_coords = eval(tab[3])
						if map_coords != nil
							file = File.open("Datas/Editor/editcom.txt", "w:UTF-8")
							tab[3] = "nil"
							file.puts(tab.join("$"))
							file.close()
							dialog = Dialog_event.new(self, map_coords)
							dialog.set_window_style(Wx::DEFAULT_DIALOG_STYLE)
							dialog.show_modal
						end
					end
				end
			end
			if $testing
				file = File.open($directory + "/Datas/Editor/editcom.txt", "r:UTF-8").readlines
				tab = file[0].chomp.split("$")
				$testing = eval(tab[0])
				if !$testing
					enable()
					bring_to_front()
				end
			end
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	show_windows
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def show_windows(b)
		@tree.show(b)
		@panel_map.show(b)
		@splitter.show(b)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	new_menu_bar
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def new_menu_bar
		menu_bar = Wx::MenuBar.new
		
		menu_file = Wx::Menu.new
		new_file = Wx::MenuItem.new(nil,  ID_NEW, String_lang::get({"fr" => "Nouveau jeu", "eng" => "New game"}) + "...", String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		new_file.set_bitmap(Wx::Bitmap.new("Datas/bmp/new_file.png"))
		menu_file.append_item(new_file)
		
		menu_open = Wx::Menu.new
		menu_open.append(ID_BROWSE_PROJECT, String_lang::get({"fr" => "Parcourir", "eng" => "Browse"}) + "...", String_lang::get({"fr" => "Recherche un jeu déjà existant", "eng" => "Search for a game already existing"}))
		i = 1
		lines = []
		File.open("Datas/current games.txt", "r").readlines.each do |line|
			menu_open.append(eval("ID_OPEN_" + i.to_s), line[0...line.size-1], "")
			lines.push(line[0...line.size-1])
			i += 1
		end
		open_file = menu_file.append_menu(Wx::ID_ANY, String_lang::get({"fr" => "Ouvrir un jeu", "eng" => "Open a game"}) + "...", menu_open)
		menu_file.remove(open_file)
		open_file.set_bitmap(Wx::Bitmap.new("Datas/bmp/open_file.png"))
		menu_file.append_item(open_file)
		
		menu_file.append(Wx::ID_EXIT, String_lang::get({"fr" => "Quitter", "eng" => "Exit"}) + "\tAlt-X", String_lang::get({"fr" => "Ferme le programme", "eng" => "Quit the program"}))
		menu_bar.append(menu_file, String_lang::get({"fr" => "Fichier", "eng" => "File"}))
		menu_management = Wx::Menu.new
		menu_management.append(ID_INPUTS, String_lang::get({"fr" => "Clavier", "eng" => "Inputs"}) + "...", String_lang::get({"fr" => "Gérer les touches de clavier", "eng" => "Manage keyboard inputs"}))
		menu_management.append(ID_DATAS, String_lang::get({"fr" => "Base de Données", "eng" => "Datas"}) + "...", String_lang::get({"fr" => "Gérer les données du jeu", "eng" => "Manage game datas"}))
		menu_management.append(ID_LANGUAGES, String_lang::get({"fr" => "Langues", "eng" => "Languages"}) + "...", String_lang::get({"fr" => "Gérer les langues du jeu", "eng" => "Manage game languages"}))
		menu_management.append(ID_EVENT, "Event test...", String_lang::get({"fr" => "Test des events", "eng" => "Test events"}))
		menu_bar.append(menu_management, String_lang::get({"fr" => "Gestion", "eng" => "Management"}))
		menu_game = Wx::Menu.new
		menu_game.append(ID_TOOL_MAP_PLAY, String_lang::get({"fr" => "Jouer", "eng" => "Play"}) + "...", String_lang::get({"fr" => "Tester le jeu", "eng" => "Test the game"}))
		menu_game.append(ID_TOOL_MAP_PLAY_LAUNCHER, String_lang::get({"fr" => "Jouer+", "eng" => "Play+"}) + "...", String_lang::get({"fr" => "Tester le jeu avec le launcher", "eng" => "Test the game with launcher"}))
		menu_bar.append(menu_game, String_lang::get({"fr" => "Tester", "eng" => "Test"}))
		menu_help = Wx::Menu.new
		menu_help.append(Wx::ID_ABOUT, String_lang::get({"fr" => "À propos", "eng" => "About"}) + "...\tF1", String_lang::get({"fr" => "Informations à propos du logiciel", "eng" => "Show about the engine"}))
		menu_bar.append(menu_help, String_lang::get({"fr" => "Aide", "eng" => "Help"}))
		
		self.menu_bar = menu_bar
		
		evt_menu ID_NEW, :new_project
		evt_menu ID_BROWSE_PROJECT, :browse_project
		evt_menu(ID_OPEN_1) {open_project(lines[0])}
		evt_menu(ID_OPEN_2) {open_project(lines[1])}
		evt_menu(ID_OPEN_3) {open_project(lines[2])}
		evt_menu ID_INPUTS, :inputs
		#~ evt_menu ID_LANGUAGES, :languages
		evt_menu ID_EVENT, :event_test
		evt_menu ID_DATAS, :datas
		evt_menu (ID_TOOL_MAP_PLAY) {play(false)}
		evt_menu (ID_TOOL_MAP_PLAY_LAUNCHER) {play(true)}
		evt_menu Wx::ID_EXIT, :on_quit
		evt_menu Wx::ID_ABOUT, :on_about
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	event_test
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def event_test
		dialog = Dialog_event.new(self, "df")
		dialog.set_window_style(Wx::DEFAULT_DIALOG_STYLE)
		dialog.show_modal
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	new_project
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def new_project
		begin
			dialog = Dialog_new_project.new(self)
			new_project_after(dialog)
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	def new_project_after(dialog)
		if dialog.show_modal == 1000
			values = dialog.get_value()
			directory = values[1] + "/" + values[0]
			if Dir.exist?(directory)
				dialog.show
				alert = Wx::MessageDialog.new(nil,
								String_lang::get({"fr" => "Ce projet existe déjà.\nChangez de répertoire.", "eng" => "The current project already exists.\nPlease choose another directory."}),
								String_lang::get({"fr" => "Action impossible", "eng" => "Impossible action"}),
								Wx::ICON_INFORMATION)
				alert.show_modal
				new_project_after(dialog)
			else
				gauge = Gauge.new(self,"creating a new directory...")
				Dir.mkdir(directory)
				gauge.set_step(5, "getting RTP pack...")
				FileUtils.copy_entry("RTP", directory)
				gauge.set_step(80, "configuring game system...")
				$title_game = values[0]
				system = Wanok::load_datas(directory + "/Datas/System.rpmdatas")
				system.name = {"eng" => $title_game, "fr" => $title_game}
				Wanok::save_datas(directory + "/Datas/System.rpmdatas", system)
				gauge.set_step(90, "opening project...")
				
				open_project(directory + "/")
				gauge.set_step(100, "OK")
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_current_game
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_current_game
		nb = File_edit::contains_line("Datas/current games.txt", $directory)
		if nb == nil
			files_nb = File_edit::insert("Datas/current games.txt", [$directory], 0)
			File_edit::delete("Datas/current games.txt", 3) if files_nb == 4
			new_menu_bar
		else
			File_edit::delete("Datas/current games.txt", nb)
			File_edit::insert("Datas/current games.txt", [$directory], 0)
		end
		new_menu_bar
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	browse_project
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def browse_project
		begin
			direct = Wx::FileDialog.new(self, String_lang::get({"fr" => "Choisissez un fichier", "eng" => "Choose a file"}), Dir.pwd + "/Games", "", "*.rpgpapermakeredit")
			if direct.show_modal == Wx::ID_OK
				open_project(direct.get_path()[0...direct.get_path().size-22])
			end
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	open_project
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def open_project(directory)
		begin
			$directory = directory.gsub('\\', '/')
			file = File.open($directory + "Game.rpgpapermakeredit", "r:UTF-8")
			file.close
			File.open($directory + "/Datas/System.rpmdatas", 'r+b') do |f|  
				$game_system = Marshal.load(f)  
			end  	
			File.open($directory + "/Datas/Data_lang.rpmdatas", 'r+b') do |f|  
				$game_langs = Marshal.load(f)  
			end  	
			$title_game = $game_system.name[$game_langs.languages[0]]
			set_title($title + " - " + $title_game)
			set_current_game
			
			@tree.update(@panel_map)
			@tool.enable(true)
			show_windows(true)
			show(false)
			show(true)
		rescue => e
			if e.class == Errno::ENOENT
				alert = Wx::MessageDialog.new(nil,
					String_lang::get({"fr" => "Erreur", "eng" => "Error"}) + " (no such file or directory) : \n" + String_lang::get({"fr" => "Impossible d'ouvrir le projet", "eng" => "Can't open the project"}) + ".",
					String_lang::get({"fr" => "Erreur", "eng" => "Error"}),
					Wx::ICON_INFORMATION)
				alert.show_modal
			else
				FrameAlert::message(e)
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	open_drop_project
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def open_drop_project(file)
		open_project(file[0...file.size-22])
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	inputs
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def inputs
		begin
			dialog = Dialog_inputs.new(self)
			if (dialog.show_modal == 1000)
				
			end
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	languages
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def languages
		begin
			dialog = Dialog_lang.new(self)
			if (dialog.show_modal == 1000)
				val = dialog.get_value()
				$game_langs.languages = val[0]
				$game_langs.languages_names = val[1]
				Wanok::save_datas($directory + "/Datas/Data_lang.rpmdatas", $game_langs)
				
				tab = val[2]
				system = tab["system"]
				
				# system
				$game_system.name = system["name"]
				$game_system.launcher_caption = system["launcher_caption"]
				
				$title_game = $game_system.name[$game_langs.languages[0]]
				set_title($title + " - " + $title_game)
			end
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	datas
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def datas
		begin
			dialog = Dialog_datas.new(self)
			test = dialog.show_modal()
			error = false
			if (test == 1000)
				tab = dialog.get_value()
				system = tab["system"]
				title = tab["title_screen"]
				
				# system
				$game_system.name = system["name"]
				$game_system.screen_x = system["screen_x"]
				$game_system.screen_y = system["screen_y"]
				$game_system.full_screen = system["full_screen"]
				$game_system.window_skins = system["window_skins"]
				$game_system.colors = system["colors"]
				$game_system.launcher_caption = system["launcher_caption"]
				$game_system.launcher_background = system["launcher_background"]
				$game_system.launcher_windowskin = system["launcher_windowskin"]
				$game_system.launcher_resolution = system["launcher_resolution"]
				$game_system.launcher_mode = system["launcher_mode"]
				
				
				#title
				$game_system.title_type = title["choice_type"]
				$game_system.title_background = title["title_screen_apparence"]
				$game_system.title_text = title["text_apparence"]
				$game_system.title_logo = title["title_logo"]
				$game_system.title_commands = title["commands"]

				
				File.open($directory + "/Datas/System.rpmdatas", 'w+b') do |f|  
					Marshal.dump($game_system, f)  
				end
				File.open($directory + "/Datas/Editor/screen_editor.txt", 'w') do |line|  
					line.puts(system["screen_editor_x"])
					line.puts(system["screen_editor_y"])
					line.puts(system["full_screen_editor"])
				end
				
				$title_game = $game_system.name[$game_langs.languages[0]]
				set_title($title + " - " + $title_game)
			end
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	play
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def play(launcher)
		@panel_map.play(launcher)
	end
		
	#--------------------------------------------------------------------------------------------------------------------------------
	#	on_quit
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def on_quit
		close()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	on_about
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def on_about
		Wx::about_box(:name => $title,
			    :version     => "0.0.0",
			    :description => "This is the free opensource ruby 2016 version. This is a deprecated version.",
			    :developers  => ['Wanok'] )
	end
 end

class Tool_bar < Wx::Panel
	attr_accessor :tool_bar
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent)
		super(parent)
		
		begin
			@tool_bar = Wx::ToolBar.new(self,  ID_TOOLBAR, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TB_FLAT | Wx::TB_TEXT)
			@tool_bar.set_own_background_colour(Wx::Colour.new(225,225, 245))
			b = Wx::Bitmap.new("Datas/bmp/new_file.png")
			@tool_bar.add_tool(ID_NEW, String_lang::get({"fr" => "Nouv.", "eng" => "New"}), b, String_lang::get({"fr" => "Nouveau jeu", "eng" => "New game"}))
			b = Wx::Bitmap.new("Datas/bmp/open_file.png")
			@tool_bar.add_tool(ID_BROWSE_PROJECT, String_lang::get({"fr" => "Ouvrir", "eng" => "Open"}), b, String_lang::get({"fr" => "Ouvrir un jeu", "eng" => "Open a game"}))
			@tool_bar.add_separator()
			b = Wx::Bitmap.new("Datas/bmp/inputs.png")
			@tool_bar.add_tool(ID_INPUTS, "Inputs", b, String_lang::get({"fr" => "Gérer les touches de clavier", "eng" => "Manage keyboard inputs"}))
			b = Wx::Bitmap.new("Datas/bmp/lang.png")
			@tool_bar.add_tool(ID_LANGUAGES, "Lang.", b, String_lang::get({"fr" => "Gérer les langues du jeu", "eng" => "Manage game languages"}))
			b = Wx::Bitmap.new("Datas/bmp/datas.png")
			@tool_bar.add_tool(ID_DATAS, String_lang::get({"fr" => "BDD", "eng" => "Datas"}), b, String_lang::get({"fr" => "Gérer les données du jeu", "eng" => "Manage game datas"}))
			b = Wx::Bitmap.new("Datas/bmp/play.png")
			@tool_bar.add_separator()
			@tool_bar.add_tool(ID_TOOL_MAP_PLAY, String_lang::get({"fr" => "Jouer", "eng" => "Play"}), b, String_lang::get({"fr" => "Tester le jeu", "eng" => "Test the game"}))
			b = Wx::Bitmap.new("Datas/bmp/playlauncher.png")
			@tool_bar.add_tool(ID_TOOL_MAP_PLAY_LAUNCHER, String_lang::get({"fr" => "Jouer+", "eng" => "Play+"}), b, String_lang::get({"fr" => "Tester le jeu avec le launcher", "eng" => "Test the game with launcher"}))
		
			@tool_bar.realize()
			box = Wx::BoxSizer.new(Wx::HORIZONTAL)
			box.add(@tool_bar,1,Wx::ALL)
			set_sizer(box)
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	enable
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def enable(b)
		@tool_bar.set_tool_disabled_bitmap(ID_BROWSE_PROJECT, Wx::Bitmap.new("Datas/bmp/open_file.png"))
		@tool_bar.enable_tool(ID_INPUTS, b)
		@tool_bar.enable_tool(ID_LANGUAGES, b)
		@tool_bar.enable_tool(ID_DATAS, b)
		@tool_bar.enable_tool(ID_TOOL_MAP_PLAY, b)
		@tool_bar.enable_tool(ID_TOOL_MAP_PLAY_LAUNCHER, b)
		parent.menu_bar.enable_top(1, b)
		parent.menu_bar.enable_top(2, b)
	end
end

$app_main = App.new
$app_main.main_loop