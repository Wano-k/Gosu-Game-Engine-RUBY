# encoding: UTF-8

class Panel_map < Wx::Panel
	attr_reader :window_map
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	ID_BUTTON_1 = 1000
	ID_BUTTON_2 = 1001
	
	def initialize(frame, parent, tree)
		super(parent)
		@frame, @tree = frame, tree
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		@window_map = MapDisplay.new(self)
		@tool = Tool_bar_map.new(self, @window_map, @tree)
		
		# Main sizer
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(@tool, 0, Wx::GROW)
		main_sizer.add(@window_map, 1, Wx::GROW)
		
		# Set sizer
		set_sizer(main_sizer)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	play
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def play(launcher)
		begin
			@frame.disable()
			file = File.open($directory + "/Datas/Editor/editcom.txt", "w:UTF-8")
			file.puts("true\n" + launcher.to_s)
			file.close
			Dir.chdir($directory) do
				IO.popen("Game.exe")
			end
			$testing = true
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	map_editor
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def map_editor()
		begin
			@frame.disable()
			file = File.open("Datas/editor/editcom.txt", "w:UTF-8")
			file.puts("true$" + $directory + "$" + @map + "$nil")
			file.close
			file = File.open("Datas/editor/consolecom.txt", "w:UTF-8")
			file.puts("true")
			file.close
			#~ IO.popen("rubyw console.rbw")
			IO.popen("map_editor.exe")
			$editor = true
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update_map
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update_map(map)
		if map == nil
			@tool.enable(false)
			@window_map.hide()
		elsif @map == nil
			@window_map.set_image(map)
			@tool.enable(true)
			@window_map.show()
		end
		@map = map
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		
	end
end

class MapDisplay < Wx::ScrolledWindow
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent)
		super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE)
		set_own_background_colour(Wx::Colour.new(200,200, 225))
		
		@image = nil
		@grid = true
		
		evt_left_dclick() {parent.map_editor()}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_image(map, scroll_update = true)
		begin
			@map = map
			if map == nil
				hide()
			else
				path = @grid ? "render_grid" : "render"
				@image = Wx::Bitmap.new($directory + "Maps/" + @map + "/" + path + ".png")
				set_scrollbars(1, 1, @image.get_width(), @image.get_height(), 0, 0, true) if scroll_update
				refresh
				show()
			end
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_grid
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_grid()
		@grid = !@grid
		
		set_image(@map, false)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	on_draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def on_draw dc
		#~ dc.clear()
		if @map != nil
			dc.draw_bitmap(@image, 0, 0, true)
		end
	end
end

class Tool_bar_map < Wx::Panel
	ID_TOOL_MAP_GRID = 9000
	ID_TOOL_MAP_ZOOM_PLUS = 9001
	ID_TOOL_MAP_ZOOM_MOINS = 9002
	ID_TOOL_MAP_SET_MAP = 9003
	ID_TOOL_MAP_MOVE_MAP = 9004
	ID_TOOL_MAP_SET_MAP_NAME = 9005
	ID_TOOL_MAP_DELETE_MAP = 9006
	ID_TOOL_MAP_EDITOR = 9007
	
	attr_accessor :tool_bar
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, window_map, tree)
		super(parent)
		
		@tool_bar = Wx::ToolBar.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TB_FLAT)
		@tool_bar.set_own_background_colour(Wx::Colour.new(225,225, 245))
		b = Wx::Bitmap.new("Datas/bmp/grid.png")
		@tool_bar.add_tool(ID_TOOL_MAP_GRID, String_lang::get({"fr" => "Grille", "eng" => "Grid"}), b, String_lang::get({"fr" => "Affiche/cache la grille", "eng" => "Hide/show grid"}))
		b = Wx::Bitmap.new("Datas/bmp/zoom_plus.png")
		@tool_bar.add_tool(ID_TOOL_MAP_ZOOM_PLUS, "+", b, "Zoom +")
		b = Wx::Bitmap.new("Datas/bmp/zoom_moins.png")
		@tool_bar.add_tool(ID_TOOL_MAP_ZOOM_MOINS, "-", b, "Zoom -")
		@tool_bar.add_separator()
		b = Wx::Bitmap.new("Datas/bmp/set_map.png")
		@tool_bar.add_tool(ID_TOOL_MAP_SET_MAP, "-", b, "Set map")
		b = Wx::Bitmap.new("Datas/bmp/move_map.png")
		@tool_bar.add_tool(ID_TOOL_MAP_MOVE_MAP, "-", b, "Move map")
		b = Wx::Bitmap.new("Datas/bmp/set_map_name.png")
		@tool_bar.add_tool(ID_TOOL_MAP_SET_MAP_NAME, "-", b, "Set map name")
		b = Wx::Bitmap.new("Datas/bmp/delete_map.png")
		@tool_bar.add_tool(ID_TOOL_MAP_DELETE_MAP, "-", b, "Delete map")
		@tool_bar.add_separator()
		b = Wx::Bitmap.new("Datas/bmp/map_editor.png")
		@tool_bar.add_tool(ID_TOOL_MAP_EDITOR, "+", b, String_lang::get({"fr" => "Lancer l'éditeur de carte", "eng" => "Launch map editor"}))
		
		@tool_bar.realize()
		box = Wx::BoxSizer.new(Wx::HORIZONTAL)
		box.add(@tool_bar,1,Wx::ALL)
		set_sizer(box)
		
		evt_menu(ID_TOOL_MAP_GRID) {window_map.set_grid()}
		evt_menu(ID_TOOL_MAP_SET_MAP) {tree.set_map()}
		evt_menu(ID_TOOL_MAP_MOVE_MAP) {}
		evt_menu(ID_TOOL_MAP_SET_MAP_NAME) {tree.set_name()}
		evt_menu(ID_TOOL_MAP_DELETE_MAP) {tree.delete_map()}
		evt_menu(ID_TOOL_MAP_EDITOR) {parent.map_editor()}
		evt_menu(ID_TOOL_MAP_PLAY) {parent.play(false)}
		evt_menu(ID_TOOL_MAP_PLAY_LAUNCHER) {parent.play(true)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	enable
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def enable(b)
		@tool_bar.set_tool_disabled_bitmap(ID_TOOL_MAP_GRID,  Wx::Bitmap.new("Datas/bmp/grid.png"))
		@tool_bar.enable_tool(ID_TOOL_MAP_GRID, b)
		@tool_bar.enable_tool(ID_TOOL_MAP_ZOOM_PLUS, b)
		@tool_bar.enable_tool(ID_TOOL_MAP_ZOOM_MOINS, b)	
		@tool_bar.enable_tool(ID_TOOL_MAP_SET_MAP, b)	
		@tool_bar.enable_tool(ID_TOOL_MAP_MOVE_MAP, b)	
		@tool_bar.enable_tool(ID_TOOL_MAP_SET_MAP_NAME, b)	
		@tool_bar.enable_tool(ID_TOOL_MAP_DELETE_MAP, b)	
		@tool_bar.enable_tool(ID_TOOL_MAP_EDITOR, b)
	end
end