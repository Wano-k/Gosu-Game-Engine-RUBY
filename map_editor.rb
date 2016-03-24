# encoding: UTF-8

class Map_editor
	MAX_CANCEL = 20
	
	attr_reader 	:hover,
				:display_grill,
				:height, 
				:selection_button, 
				:selection_rectangle, 
				:draw_mode,
				:rectangle_draw
	attr_accessor 	:selection, 
				:text_position, 
				:text_informations, 
				:previous_selected_mouse, 
				:rectangle_draw
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(directory, map_name)
		@directory, @map_name = directory, map_name
		
		# Sauvegardes temporaires
		Dir.entries(@directory + "/Maps/" + map_name + "/").each {|file| FileUtils.cp(@directory + "Maps/" + map_name + "/" + file, @directory + "Maps/" + map_name + "/temporalSave/" + file)  if file.include?(".pmap")}
		
		# Création propriétés de window
		$window.camera = Camera.new($tile_size/2)
		$window.hero = Hero.new()
		$window.map = Map.new(map_name, directory, Gosu::Color.new(110, 179, 93))
		
		# Création de tool bar
		@toolbar = Toobar_editor.new()
		
		# Sprites
		@sprite_yes = Sprite.new($window.im.editor_hud["yes"], 55, 5)
		@sprite_no = Sprite.new($window.im.editor_hud["no"], 55, 5)
		@cursor_texture= Sprite.new($window.im.editor_hud["selection"])
		@arrows_textures_up = Sprite.new($window.im.editor_hud["hud_arrow_up"])
		@arrows_textures_down = Sprite.new($window.im.editor_hud["hud_arrow_down"])
		@arrows_form_up = Sprite.new($window.im.editor_hud["hud_arrow_up"])
		@arrows_form_down = Sprite.new($window.im.editor_hud["hud_arrow_down"])
		@arrows_textures_left_right = Sprite.new($window.im.editor_hud["hud_arrow_left_right"])
		x, y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.z + 1) / $tile_size).to_i
		@text_position = Text.new($window, "[" + x.to_s + ", " + y.to_s + "]", 0, $screen_y - 32, 0, $font_name, $font_size, 2, $screen_x - 20 - 32, :right)
		
		#Textures
		@tileset = $window.im.tilesets_hud["rtp"]
		@tileset_textures = $window.im.tilesets_textures["rtp"]
		@floor = $window.im.floors_hud["rtp"]
		@floor_textures = $window.im.floors_textures["rtp"]
		
		# rectangle
		init_rectangle()
		@selection_rectangle_form = Selection_rectangle.new($window, $screen_x - 34, 80, 32, 32)
		@selection_rectangle_pressed = false
		@selection_rectangle_max_width = @floor.width*(32.0/$tile_size).to_i < (8*32) ? @floor.width*(32.0/$tile_size).to_i : (8*32)
		@selection_rectangle_max_height = 11 + (($screen_y - 480.0)/32.0).to_i
		@mouse_x = $window.mouse_x
		@mouse_y = $window.mouse_y
		
		#Selection
		@display_grill = true
		@cancel = []
		@redo = []
		@cancel_redo_index = -1
		@selection_button = :button_first_layer
		@hover = :nothing
		@height = [0,0]
		@indexes_rectangle = [0,0]
		@indexes = { 
			:button_first_layer => 0,
			:button_sprite => 0,
			:button_objet => 0,
			:button_pente => 0,
			:button_relief => 0,
			:button_ev => 0,
			:button_praticable => 0,
			:button_couche => 0,
			:button_hauteur => 0
		}
		@indexes_end = { 
			:button_first_layer => 1,
			:button_sprite => 1,
			:button_objet => $window.im.object3D_hud[0].size,
			:button_pente => $window.im.relief_hud.size,
			:button_relief => $window.im.relief_hud.size,
			:button_ev => 1,
			:button_praticable => $window.im.praticable_hud.size,
			:button_couche => 1,
			:button_hauteur => 1
		}
		@indexes_kind = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		@indexes_form = { 
			:button_first_layer => 0,
			:button_sprite => 0,
			:button_objet => 0,
			:button_pente => 0,
			:button_relief => 0,
			:button_ev => 0,
			:button_praticable => 0,
			:button_couche => 0,
			:button_hauteur => 0
		}		
		@previous_selected_mouse = nil
		@previous_cursor = nil
		@applying = false
		@is_saved = true
		@draw_mode = 0
		@rectangle_draw = nil
		@rectangle_settings = nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	init_rectangle
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def init_rectangle()
		@selection_rectangle = Selection_rectangle.new($window, 2, 80, 0, 0)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	init_rectangle_draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def init_rectangle_draw(id)
		if !$window.button_down_repeat?(id)
			$window.interface.eval_deleted_preview_item()
			create_cancel()
			if @draw_mode == 1
				@rectangle_draw = [$window.selected_mouse,$window.selected_mouse]
				get_rectangle_settings()
				delete_first_layer(256, false)
				apply_first_layer(256, false) if id == 256
				@previous_selected_mouse = nil
				@applying = true
			end
			$window.button_down_repeat(id)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	BUTTON DOWN
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id)
		x, y = $window.hero.get_x(), $window.hero.get_y()
		set_hover()

		# Pressing left ctrl avoid preview item
		if id == Gosu::KbLeftControl
			$window.interface.eval_deleted_preview_item()
		end

		# Make rectangle selction (tileset)
		if @selection_rectangle_pressed 
			if id == 259 # molette haut
				@indexes_rectangle[1] += 1
			elsif id == 260 # molette bas
				@indexes_rectangle[1] -= 1
			elsif id == 92
				@indexes_rectangle[0] += 1
			elsif id == 94
				@indexes_rectangle[0] -= 1
			end
			change_indexes()
			make_rect_selection()
			return
		end

		# Toolbar tests
		if @toolbar.is_hover?() and !@applying
			@toolbar.button_down(self, id)
			return
		end
		
		
		# All over pressions
		case id
			when 256 # Left clic
				if (@hover == :textures or @hover == :big_textures)
					# If rectangle selection
					if !$window.button_down_repeat?(id) and ((@selection_button == :button_first_layer and is_in_floor_mode?()) or @selection_button == :button_sprite)
						$window.interface.eval_deleted_preview_item()
						make_rect_selection()
						@selection_rectangle_pressed = true
						$window.button_down_repeat(id)
						return
					end
				end
				init_rectangle_draw(id)
				apply(id) if @draw_mode != 1
			
			when 258 # Right clic
				if (@hover == :textures or @hover == :big_textures) and !$window.button_down_repeat?(id) and ((@selection_button == :button_first_layer and @indexes_kind[0] == 0) or @selection_button == :button_sprite)
					init_rectangle()
				else
					init_rectangle_draw(id)
					delete(id) if @draw_mode != 1
				end
			
			when 257 # wheel centre
				if $window.button_down_repeat?(id)
					dif = $window.mouse_y - @mouse_y
					$window.camera.height += (dif*2)
					dif = $window.mouse_x - @mouse_x
					$window.camera.set_angle_h(dif/2)
				else
					$window.button_down_repeat(id)
				end
				
			when 259 # wheel up
				if @selection_button == :button_sprite or (@selection_button == :button_first_layer and @indexes_kind[0] == 0)
					if @hover == :textures or @hover == :big_textures
						@indexes_rectangle[1] += 1
					else
						zoom_plus()
					end
				else
					if @hover == :textures
						@indexes[@selection_button] -= 1
					elsif  @hover == :form_textures
						@indexes_form[@selection_button] -= 1
						@indexes[@selection_button] = 0
					else
						zoom_plus()
					end
				end
				change_indexes
				
			when 260 # wheel down
				if @selection_button == :button_sprite or (@selection_button == :button_first_layer and @indexes_kind[0] == 0)
					if @hover == :textures or @hover == :big_textures
						@indexes_rectangle[1] -= 1
					else
						zoom_less()
					end
				else
					if @hover == :textures
						@indexes[@selection_button] += 1
					elsif  @hover == :form_textures
						@indexes_form[@selection_button] += 1
						@indexes[@selection_button] = 0
					else
						zoom_less()
					end
				end
				change_indexes()
				
			when 92
				@indexes_rectangle[0] += 1
				change_indexes
			when 94
				@indexes_rectangle[0] -= 1
				change_indexes
			when Gosu::KbSpace
				create_cancel() if !$window.button_down_repeat?(id)
				$window.button_down_repeat(id)
				apply(id)
			when Gosu::KbDelete
				create_cancel() if !$window.button_down_repeat?(id)
				$window.button_down_repeat(id)
				delete(id)
			when Gosu::KbG
				grid()
			when Gosu::KbW # CTRL+Z
				cancel() if $window.button_down?(Gosu::KbLeftControl) and !$window.button_down_repeat?(id)
			when Gosu::KbY # CTRL+Y
				redoo() if $window.button_down?(Gosu::KbLeftControl) and !$window.button_down_repeat?(id)
		end
			
		@mouse_x = $window.mouse_x
		@mouse_y = $window.mouse_y
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	BUTTON UP
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_up(id) 
		case id
			when 256
				update_redo()
				@selection_rectangle_pressed = false
				@selection_rectangle.set_real_position()
				@applying = false
				@previous_selected_mouse = nil
				@rectangle_draw = nil
				
				if @draw_mode == 1
					if @cancel_redo_index > -1
						portions = []
						$game_map.deleted_preview_item.each_key do |coords|
							x, y = coords[0], coords[1]
							cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i
							portion_x, portion_y = (x/16) - (cursor_x/16), (y/16) - (cursor_y/16)
							portions.push([portion_x,portion_y]) if !portions.include?([portion_x,portion_y])
						end
						
						delete = []
						@cancel[@cancel_redo_index].each_key do |portion|
							delete.push(portion) if !portions.include?(portion)
						end
						
						delete.each do |portion|
							@cancel[@cancel_redo_index].delete(portion)
						end
					end 
					$game_map.deleted_preview_item = {}
				end
				
			when 258
				update_redo()
				@previous_selected_mouse = nil
				@rectangle_draw = nil
				@applying = false
				if @draw_mode == 1
					$game_map.deleted_preview_item = {}
				end
				
			when Gosu::KbSpace
				update_redo()
				@previous_cursor = nil
				@rectangle_draw = nil
				
			when Gosu::KbDelete
				update_redo()
				@previous_cursor = nil
				@rectangle_draw = nil
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_in_floor_mode?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_in_floor_mode?()
		@indexes_kind[0] == 0
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	create_cancel
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def create_cancel()
		size = @cancel.size
		if size == MAX_CANCEL
			@cancel.delete_at(0)
			@cancel_redo_index -= 1
		end
		lim = -1
		for i in 0...size
			if lim == -1 and i > @cancel_redo_index
				lim = i
			end
			if lim != -1
				@cancel.delete_at(lim)
			end
		end
		@cancel_redo_index += 1
		@cancel.push(Hash.new)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_cancel
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_cancel(portion, map)
		if !@cancel[@cancel_redo_index].include?(portion)
			@cancel[@cancel_redo_index][portion] = []
			@cancel[@cancel_redo_index][portion][0] = Marshal::load(Marshal.dump(map))
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_redo
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_redo(portion, map)
		@cancel[@cancel_redo_index][portion][1] = map if @cancel[@cancel_redo_index][portion][1] == nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update_redo
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update_redo()
		if !@cancel.empty? and @cancel_redo_index >= 0 and @cancel_redo_index < @cancel.size
			@cancel[@cancel_redo_index].each do |portion, maps|
				@cancel[@cancel_redo_index][portion][1] = Marshal::load(Marshal.dump(maps[1]))
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	cancel
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def cancel()
		size = @cancel.size
		if !@cancel.empty?() and @cancel_redo_index >= 0 and @cancel_redo_index < @cancel.size
			cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i

			@cancel[@cancel_redo_index].each do |coords, maps|
				map = maps[0]
				x, y = coords[0], coords[1]
				portion_x, portion_y = x - (cursor_x/16), y - (cursor_y/16)
				$window.map.portions[[portion_x, portion_y]] = map
				$game_map.add_portion_save([portion_x, portion_y])
				$game_map.add_portion_update([portion_x, portion_y])
			end
			@cancel_redo_index -= 1
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	redoo
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def redoo()
		if !@cancel.empty?() and @cancel_redo_index+1 < @cancel.size
			cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i
			@cancel_redo_index += 1
			
			@cancel[@cancel_redo_index].each do |coords, maps|
				map = maps[1]
				x, y = coords[0], coords[1]
				portion_x, portion_y = x - (cursor_x/16), y - (cursor_y/16)
				$window.map.portions[[portion_x, portion_y]] = map
				$game_map.add_portion_save([portion_x, portion_y])
				$game_map.add_portion_update([portion_x, portion_y])
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	grid
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def grid()
		@display_grill = !@display_grill
	end 
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	floor
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def floor(i)
		@indexes[:button_first_layer] = 0
		case i
			when 0
				@indexes_end[:button_first_layer] = 1
			when 1
				@indexes_end[:button_first_layer] = $window.im.autotiles_hud.size
			when 2
				@indexes_end[:button_first_layer] = $window.im.water_hud["Foam"].size
		end
		@indexes_rectangle = [0,0]
		@selection_rectangle.set_position(0,0)
		if (i == 0)
			@selection_rectangle.width = 0
			@selection_rectangle.height= 0
		else
			@selection_rectangle.width = 32
			@selection_rectangle.height = 32
		end
		@selection_button = :button_first_layer
		@indexes_kind[0] = i
		set_rect_width()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def sprite(i)
		@draw_mode = 0
		if @selection_button != :button_sprite
			@indexes_rectangle = [0,0]
			@selection_rectangle.set_position(0,0)
			@selection_rectangle.width = 0
			@selection_rectangle.height = 0
		end
		@selection_button = :button_sprite
		@indexes_kind[1] = i
		set_rect_width()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	object
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def object()
		if @selection_button != :button_objet
			@indexes_rectangle = [0,0]
			@selection_rectangle.set_position(0,0)
			@selection_rectangle.width = 32
			@selection_rectangle.height = 32
		end
		@selection_button = :button_objet
		@indexes_kind[2] = 0
		set_rect_width()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	mountain
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def mountain(i)
		if @selection_button != :button_relief
			@indexes_rectangle = [0,0]
			@selection_rectangle.set_position(0,0)
			@selection_rectangle.width = 32
			@selection_rectangle.height = 32
		end
		@selection_button = :button_relief
		@indexes_kind[3] = 0
		set_rect_width()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	mountain
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def block(length, width, height, height_more)
		if @selection_button != :button_relief
			@indexes_rectangle = [0,0]
			@selection_rectangle.set_position(0,0)
			@selection_rectangle.width = 32
			@selection_rectangle.height = 32
		end
		@selection_button = :button_relief
		@indexes_kind[3] = 1
		@indexes_form[:button_relief] = [length, width, height, height_more]
		set_rect_width()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_mode
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_mode(index)
		@draw_mode = index
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_block_values
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_block_values(length, width, height, height_more)
		@indexes_form[:button_relief] = [length, width, height, height_more]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_height_values
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_height_values(h, h_more)
		@height = [h, h_more]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	zoom_plus
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def zoom_plus
		dist = 350.0/180.0
		$window.camera.distance -= dist*20
		$window.camera.height -= 20
		$window.camera.distance = (dist*20) if $window.camera.distance < (dist*20)
		$window.camera.height = 20 if $window.camera.height < 20
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	zoom_less
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def zoom_less
		dist = 350.0/180.0
		$window.camera.distance += dist*20
		$window.camera.height += 20
	end	
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	make_rect_selection
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def make_rect_selection()
		index_x = @indexes_rectangle[0] >(@selection_rectangle_max_width/32)-1 ? (@selection_rectangle_max_width/32)-1  : 0
		index_y = @indexes_rectangle[1] >@selection_rectangle_max_height-1 ? @selection_rectangle_max_height-1 : 0

		tile = @selection_button == :button_sprite ? @tileset : @floor
		img_x = (tile.width/$tile_size)
		img_y = (tile.height/$tile_size)
		
		if !@selection_rectangle_pressed
			mouse_x = $window.mouse_x - 2
			mouse_y = $window.mouse_y - 80
			return if mouse_x > ((img_x*32) - 1)
			return if mouse_y > ((img_y*32) - 1)
			pos_x = (mouse_x.to_i / 32) + index_x - @indexes_rectangle[0]
			pos_y = (($window.mouse_y - 80).to_i / 32) + index_y - @indexes_rectangle[1]
			@selection_rectangle.set_position(2 + (pos_x*32), 80 + (pos_y*32))
			@selection_rectangle.width = 32
			@selection_rectangle.height = 32
		else
			mouse_x = $window.mouse_x - 2
			mouse_y = $window.mouse_y - 80
			mouse_x = @selection_rectangle_max_width-1  if mouse_x > @selection_rectangle_max_width-1 
			mouse_x = 0 if mouse_x < 0
			mouse_y = (@selection_rectangle_max_height*32)-1 if mouse_y > (@selection_rectangle_max_height*32)-1
			mouse_y = 0 if mouse_y < 0
			pos = @selection_rectangle.get_position()
			pos[0] = (pos[0].to_i - 2) / 32
			pos[1] = (pos[1].to_i - 80) / 32
			pos_x = ((mouse_x).to_i / 32) + index_x - @indexes_rectangle[0]
			pos_y = ((mouse_y).to_i / 32) + index_y - @indexes_rectangle[1]
			i_x = pos[0] <= pos_x ? 1 : -1
			i_y = pos[1] <= pos_y ? 1 : -1
			length = ((pos_x - pos[0]) + i_x)*32
			width = ((pos_y - pos[1]) + i_y)*32
			
			@selection_rectangle.width = length if !(mouse_x > ((img_x*32) - 1))
			@selection_rectangle.height = width if !(mouse_y > ((img_y*32) - 1))
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_rect_width
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_rect_width()
		if @selection_button == :button_first_layer or  @selection_button == :button_sprite
			tile = @selection_button == :button_first_layer ? @floor : @tileset
			@selection_rectangle_max_width = tile.width*(32.0/$tile_size).to_i < 256 ? tile.width*(32.0/$tile_size).to_i : 256
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_hover
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_hover()
		mouse_x = $window.mouse_x
		mouse_y = $window.mouse_y
		
		if (mouse_x >= 2 and mouse_x <= 34 and mouse_y >= 80 and mouse_y <= 80 + (@selection_rectangle_max_height*32) + 14)
			@hover = :textures
		elsif (mouse_x >= 2 and mouse_x <= @selection_rectangle_max_width + 2 and mouse_y >= 80 and mouse_y <= 80 + (@selection_rectangle_max_height*32) + 14)
			@hover = :big_textures
		#~ elsif (mouse_x >= 894 and mouse_x <= 926 and mouse_y >= 80 and mouse_y <= 448)
			#~ @hover = :form_textures
		else 
			@hover = :nothing
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	change_indexes : set rectangle size/position
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def change_indexes
		if @selection_button == :button_sprite or (@selection_button == :button_first_layer and @indexes_kind[0] == 0)
			tile = @selection_button == :button_sprite ? @tileset : @floor
			img_x = -(tile.width/$tile_size)
			@indexes_rectangle[0] = 0 if @indexes_rectangle[0] > 0
			if img_x >= -5
				@indexes_rectangle[0] = 0
			elsif @indexes_rectangle[0] - 8 < img_x
				@indexes_rectangle[0] += 1
			end
			img_y = -(tile.height/$tile_size)
			@indexes_rectangle[1] = 0 if @indexes_rectangle[1] > 0
			if img_y >= -11
				@indexes_rectangle[1] = 0
			elsif @indexes_rectangle[1] - @selection_rectangle_max_height < img_y
				@indexes_rectangle[1] += 1
			end
		else
			if @indexes_end[@selection_button] != 0
				@indexes[@selection_button] = @indexes[@selection_button] % @indexes_end[@selection_button] 
				if @selection_button == :button_objet
					@indexes_form[@selection_button] = @indexes_form[@selection_button] % $window.im.object3D_hud.size
					@indexes_end[@selection_button] = $window.im.object3D_hud[@indexes_form[@selection_button]].size
				end
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	save
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def save
		Dir.entries(@directory + "/Maps/" + @map_name + "/").each {|file| File.delete(@directory + "Maps/" + @map_name + "/" + file)  if file.include?(".pmap")}
		Dir.entries(@directory + "Maps/" + @map_name + "/temporalSave").each {|file| FileUtils.cp(@directory + "Maps/" + @map_name + "/temporalSave/" + file, @directory + "Maps/" + @map_name + "/" + file)  if file.include?(".pmap")}
		Wanok::save_datas($directory + "Maps/" + $map_name + "/infos.map", $game_map)
		$window.screen = true
		@is_saved = true
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_rectangle_settings
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_rectangle_settings()
		adding_x = false
		adding_y = false
		deleting_x = false
		deleting_y = false
		cx, cy, rx, ry = [0,-1], [0,-1], [0,-1], [0,-1]
		acx, acy, arx, ary = [0,-1], [0,-1], [0,-1], [0,-1]
		mouse = $window.selected_mouse
		
		cursor_x, cursor_y = $window.hero.get_x(), $window.hero.get_y()
		portion_x, portion_y = (mouse.x/16) - (cursor_x/16), (mouse.y/16) - (cursor_y/16)
		
		if (Wanok::is_in_portion?(portion_x, portion_y) and $window.selected_mouse.x >= 0 and $window.selected_mouse.x <= $game_map.size[0] and $window.selected_mouse.y >= 0 and $window.selected_mouse.y <= $game_map.size[1])
			# Special
			if (((@rectangle_draw[0].x < @rectangle_draw[1].x) and (mouse.x < @rectangle_draw[0].x)) or
				((@rectangle_draw[0].x > @rectangle_draw[1].x) and (mouse.x > @rectangle_draw[0].x)))
				mouse = Vector3D.new(@rectangle_draw[0].x,mouse.y,mouse.z)
			end	
			if (((@rectangle_draw[0].y < @rectangle_draw[1].y) and (mouse.y < @rectangle_draw[0].y)) or
				((@rectangle_draw[0].y > @rectangle_draw[1].y) and (mouse.y > @rectangle_draw[0].y)))
				mouse = Vector3D.new(mouse.x,@rectangle_draw[0].y,mouse.z)
			end	

			# Setting x
			if (@rectangle_draw[0].x < @rectangle_draw[1].x)
				if (@rectangle_draw[1].x < mouse.x) # Adding a col
					adding_x = true
					cx = [@rectangle_draw[1].x+1, mouse.x]
					acx = [@rectangle_draw[1].x, mouse.x]
					rx = [@rectangle_draw[0].x, @rectangle_draw[1].x]
					arx = [@rectangle_draw[0].x, @rectangle_draw[1].x]
				elsif (@rectangle_draw[1].x > mouse.x) # Deleting a col
					deleting_x = true
					cx = [mouse.x+1, @rectangle_draw[1].x]
					acx = [mouse.x, @rectangle_draw[1].x]						
					rx = [@rectangle_draw[0].x, mouse.x]
					arx = [@rectangle_draw[0].x, mouse.x]
				else
					rx = [@rectangle_draw[0].x, mouse.x]
					acx = [@rectangle_draw[0].x, mouse.x]
				end
			elsif (@rectangle_draw[0].x > @rectangle_draw[1].x)
				if (mouse.x < @rectangle_draw[1].x) # Adding a col
					adding_x = true
					cx = [mouse.x, @rectangle_draw[1].x-1]
					acx = [mouse.x, @rectangle_draw[1].x]
					rx = [@rectangle_draw[1].x, @rectangle_draw[0].x]
					arx = [@rectangle_draw[1].x, @rectangle_draw[0].x]
				elsif (mouse.x > @rectangle_draw[1].x) # Deleting a col
					deleting_x = true
					cx = [@rectangle_draw[1].x, mouse.x-1]
					acx = [@rectangle_draw[1].x, mouse.x]
					rx = [mouse.x, @rectangle_draw[0].x]
					arx = [mouse.x, @rectangle_draw[0].x]
				else
					rx = [mouse.x, @rectangle_draw[0].x]
					arx = [mouse.x, @rectangle_draw[0].x]
				end
			else
				adding_x = true
				if (mouse.x < @rectangle_draw[1].x) # Adding a left col
					cx = [mouse.x, @rectangle_draw[1].x - 1]
					acx = [mouse.x, @rectangle_draw[1].x]
				elsif (mouse.x > @rectangle_draw[1].x) # Adding a right col
					cx = [@rectangle_draw[1].x+1, mouse.x]
					acx = [@rectangle_draw[1].x, mouse.x]
				end
				rx = [@rectangle_draw[0].x, @rectangle_draw[0].x]
				arx = [@rectangle_draw[0].x, @rectangle_draw[0].x]
			end
			
			# Setting y
			if (@rectangle_draw[0].y < @rectangle_draw[1].y)
				if (@rectangle_draw[1].y < mouse.y) # Adding a row
					adding_y = true
					cy = [@rectangle_draw[0].y, @rectangle_draw[1].y]
					acy = [@rectangle_draw[0].y, @rectangle_draw[1].y]
					ry = [@rectangle_draw[1].y+1, mouse.y]
					ary = [@rectangle_draw[1].y, mouse.y]
				elsif (@rectangle_draw[1].y > mouse.y) # Deleting a row
					deleting_y = true
					cy = [@rectangle_draw[0].y, mouse.y]
					acy = [@rectangle_draw[0].y, mouse.y]
					ry = [mouse.y+1, @rectangle_draw[1].y]
					ary = [mouse.y, @rectangle_draw[1].y]
				else
					cy = [@rectangle_draw[0].y, mouse.y]
					acy = [@rectangle_draw[0].y, mouse.y]
				end
			elsif (@rectangle_draw[0].y > @rectangle_draw[1].y)
				if (mouse.y < @rectangle_draw[1].y) # Adding a row
					adding_y = true
					cy = [@rectangle_draw[1].y, @rectangle_draw[0].y]
					acy = [@rectangle_draw[1].y, @rectangle_draw[0].y]
					ry = [mouse.y, @rectangle_draw[1].y - 1]
					ary = [mouse.y, @rectangle_draw[1].y]
				elsif (mouse.y > @rectangle_draw[1].y) # Deleting a row
					deleting_y = true
					cy = [mouse.y, @rectangle_draw[0].y]
					acy = [mouse.y, @rectangle_draw[0].y]
					ry = [@rectangle_draw[1].y, mouse.y - 1]
					ary = [@rectangle_draw[1].y, mouse.y]
				else
					cy = [mouse.y, @rectangle_draw[0].y]
					acy = [mouse.y, @rectangle_draw[0].y]
				end
			else
				adding_y = true
				if (mouse.y < @rectangle_draw[1].y) # Adding a up row
					ry = [mouse.y, @rectangle_draw[1].y-1]
					ary = [mouse.y, @rectangle_draw[1].y]
				elsif (mouse.y > @rectangle_draw[1].y) # Adding a down row
					ry = [@rectangle_draw[1].y+1, mouse.y]
					ary =  [@rectangle_draw[1].y, mouse.y]
				end
				cy = [@rectangle_draw[0].y, @rectangle_draw[0].y]
				acy = [@rectangle_draw[0].y, @rectangle_draw[0].y]
			end
			
			if (@rectangle_draw[0].x == @rectangle_draw[1].x and @rectangle_draw[1].x == mouse.x and @rectangle_draw[0].y == @rectangle_draw[1].y and @rectangle_draw[1].y == mouse.y)
				adding_x = true
				cx = [mouse.x, mouse.x]
				acx = [mouse.x, mouse.x]
				cy = [mouse.y, mouse.y]
				acy = [mouse.y, mouse.y]
			end
			@rectangle_draw[1] = mouse
		end
		
		@rectangle_settings = [[adding_x,adding_y,deleting_x,deleting_y], [cx,cy],[rx,ry], [acx,acy],[arx,ary]]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	apply
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def apply(id)
		if @indexes_end[@selection_button] != 0
			$window.interface.eval_deleted_preview_item()
			@applying = true if id == 256 
			case @selection_button
				when :button_first_layer
					apply_first_layer(id)
				when :button_sprite
					apply_sprite(id)
				when :button_objet
					apply_objet(id)
				when :button_pente
					apply_pente
				when :button_relief
					apply_relief(id)
				when :button_praticable
					apply_praticable
				when :button_ev
					apply_ev
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	delete
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def delete(id)
		case @selection_button
			when :button_first_layer
				delete_first_layer(id)
			when :button_sprite
				delete_sprite(id)
			when :button_objet
				delete_objet(id)
			when :button_pente
				delete_pente(id)
			when :button_relief
				delete_relief(id)
			when :button_praticable
				delete_praticable(id)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	apply_first_layer
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def apply_first_layer(id, line = true)
		# Enregistrement du genre
		case @indexes_kind[0]
			when 0
				new_type_floor = "floor"
				new_id_floor = @selection_rectangle.get_rect()
				new_form_floor = nil
				pos_x, pos_y, width, height =new_id_floor[0], new_id_floor[1], new_id_floor[2], new_id_floor[3]
				return if (width == 0 and height == 0)
			when 1
				new_type_floor = "autotile"
				new_form_floor = nil
			when 2
				new_type_floor = "water"
				new_form_floor = @indexes_form[@selection_button]
		end
		if @indexes_kind[0] > 0
			new_id_floor = @indexes[@selection_button]
			new_id_floor += $window.im.id_water_autotiles if @indexes_kind[0] == 2
			width = $tile_size
			height = $tile_size
		end

		# Définition de coordonnées
		if id == Gosu::KbSpace
			x, y, z = $window.hero.get_x(), $window.hero.get_y(), Wanok::pixel_height(@height)
			coords = [x, y, z, @couche]
			return if @previous_cursor == coords and line
		else
			co = $window.selected_mouse
			x, y, z = co.x, co.y, Wanok::pixel_height(@height)
			coords = [x, y, z, @couche]
			return if @previous_selected_mouse == coords and line
		end

		if @draw_mode == 0 or (@draw_mode == 1 and !line and @rectangle_draw == nil)
			for i in 0...width/$tile_size
				for j in 0...height/$tile_size
					break if (x+i) > $game_map.size[0] or (y+j) > $game_map.size[1]
					new_id = new_type_floor == "floor" ? [((i*$tile_size)+new_id_floor[0]).to_i,((j*$tile_size)+new_id_floor[1]).to_i,$tile_size.to_i,$tile_size.to_i] : new_id_floor
					co = [x+i, y+j, z, @couche]
					if (new_id_floor[2] == $tile_size.to_i and new_id_floor[3] == $tile_size.to_i) or (j % 2 == 0 and i % 2 == 0)
						if id == Gosu::KbSpace
							trace_line(new_type_floor, new_id, new_form_floor, 0, co, @previous_cursor, 0) if (line and @previous_cursor != nil)
						else
							trace_line(new_type_floor, new_id, new_form_floor, 0, co, @previous_selected_mouse, 0) if (line and @previous_selected_mouse != nil)
						end
					end
					stock_first_layer(co, new_type_floor, new_id, new_form_floor, line)
				end
			end
		end
		if @draw_mode == 1 and !line and @rectangle_draw != nil and false
			adding_x, adding_y = @rectangle_settings[0][0], @rectangle_settings[0][1]
			rect_col = @rectangle_settings[1]
			rect_row = @rectangle_settings[2]
			autotile_rect_col = @rectangle_settings[3]
			autotile_rect_row = @rectangle_settings[4]
			#Columns
			if adding_x
				for i in rect_col[0][0]..rect_col[0][1]
					for j in rect_col[1][0]..rect_col[1][1]
						co = [i, j, z, @couche]
						local_x, local_y = i - @rectangle_draw[0].x, j - @rectangle_draw[0].y
						texture_after_reduced = new_type_floor == "floor" ? [new_id_floor[0] + (((local_x*$tile_size).to_i)%new_id_floor[2]),new_id_floor[1] + (((local_y*$tile_size).to_i)%new_id_floor[3]),$tile_size.to_i,$tile_size.to_i] : new_id_floor
						stock_first_layer(co, new_type_floor, texture_after_reduced, new_form_floor, line)
					end
				end
			end
			# Rows
			if adding_y
				for i in rect_row[0][0]..rect_row[0][1]
					for j in rect_row[1][0]..rect_row[1][1]
						co = [i, j, z, @couche]
						local_x, local_y = i - @rectangle_draw[0].x, j - @rectangle_draw[0].y
						texture_after_reduced = new_type_floor == "floor" ? [new_id_floor[0] + (((local_x*$tile_size).to_i)%new_id_floor[2]),new_id_floor[1] + (((local_y*$tile_size).to_i)%new_id_floor[3]),$tile_size.to_i,$tile_size.to_i] : new_id_floor
						stock_first_layer(co, new_type_floor, texture_after_reduced, new_form_floor, line)
					end
				end
			end
			# Column & rows
			if adding_x or adding_y
				for i in rect_col[0][0]..rect_col[0][1]
					for j in rect_row[1][0]..rect_row[1][1]
						co = [i, j, z, @couche]
						local_x, local_y = i - @rectangle_draw[0].x, j - @rectangle_draw[0].y
						texture_after_reduced = new_type_floor == "floor" ? [new_id_floor[0] + (((local_x*$tile_size).to_i)%new_id_floor[2]),new_id_floor[1] + (((local_y*$tile_size).to_i)%new_id_floor[3]),$tile_size.to_i,$tile_size.to_i] : new_id_floor
						stock_first_layer(co, new_type_floor, texture_after_reduced, new_form_floor, line)
					end
				end
			end
			# Update
			if new_type_floor == "autotile"
				if adding_x
					for i in autotile_rect_col[0][0]..autotile_rect_col[0][1]
						for j in autotile_rect_col[1][0]..autotile_rect_col[1][1]
							co = [i, j, z, @couche]
							$game_map.autotiles[new_id_floor].tiles[co].update()
						end
					end
				end
				if adding_y
					for i in autotile_rect_row[0][0]..autotile_rect_row[0][1]
						for j in autotile_rect_row[1][0]..autotile_rect_row[1][1]
							co = [i, j, z, @couche]
							$game_map.autotiles[new_id_floor].tiles[co].update()
						end
					end
				end
				if adding_x or adding_y
					for i in autotile_rect_col[0][0]..autotile_rect_col[0][1]
						for j in autotile_rect_row[1][0]..autotile_rect_row[1][1]
							co = [i, j, z, @couche]
							$game_map.autotiles[new_id_floor].tiles[co].update()
						end
					end
				end
			end
		end
		if @draw_mode == 2
			if new_type_floor == "floor"
				new_id = new_id_floor
				draw_pin(coords, new_id, new_type_floor, new_form_floor)
			end
		end
		
		if id == Gosu::KbSpace
			@previous_cursor = coords
		else
			@previous_selected_mouse = coords
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	stock_first_layer
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def stock_first_layer(coords, new_type_floor, new_id_floor, new_form_floor, line = true)
		x, y, z = coords[0], coords[1], coords[2]
		
		return if !Wanok::mouse_is_in_area?([x, y, z])
		cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i
		portion_x, portion_y = (x/16) - (cursor_x/16), (y/16) - (cursor_y/16)
		return if !Wanok::is_in_portion?(portion_x, portion_y)
		
		add_cancel([(x/16), (y/16)], $window.map.portions[[portion_x, portion_y]]) if line or @rectangle_draw != nil
		if $window.map.portions[[portion_x, portion_y]] == nil
			$window.map.portions[[portion_x, portion_y]] = Game_map_portion.new()
		end
		
		case new_type_floor
			when "floor"
				is_saved = !$window.map.portions[[portion_x, portion_y]].add_floor(coords, new_id_floor, new_type_floor, new_form_floor)
			when "autotile", "water"
				is_saved = !$window.map.portions[[portion_x, portion_y]].add_floor(coords, new_id_floor, new_type_floor, new_form_floor, (line or @draw_mode != 1 or @rectangle_draw == nil))
		end
			
		@is_saved = is_saved if (@is_saved and line)
		$game_map.add_portion_save([portion_x, portion_y]) if line or @rectangle_draw != nil
		$game_map.add_portion_update([portion_x, portion_y])
		add_redo([(x/16), (y/16)], $window.map.portions[[portion_x, portion_y]]) if line or @rectangle_draw != nil
	end
		
	#--------------------------------------------------------------------------------------------------------------------------------
	#	delete_first_layer
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def delete_first_layer(id, line = true)
		# Enregistrement du genre
		case @indexes_kind[0]
			when 0
				new_type_floor = "floor"
				new_form_floor = nil
				new_id_floor = @selection_rectangle.get_rect()
				pos_x, pos_y, width, height =new_id_floor[0], new_id_floor[1], new_id_floor[2], new_id_floor[3]
			when 1
				new_type_floor = "autotile"
				new_form_floor = nil
			when 2
				new_type_floor = "water"
				new_form_floor = @indexes_form[@selection_button]
		end
		if @indexes_kind[0] > 0
			new_id_floor = @indexes[@selection_button]
			new_id_floor += $window.im.id_water_autotiles if @indexes_kind[0] == 2
			width = $tile_size
			height = $tile_size
		end
		
		# Définition de coordonnées
		if id == Gosu::KbDelete
			x, y, z = $window.hero.get_x(), $window.hero.get_y(), Wanok::pixel_height(@height)
			coords = [x, y, z, @couche]
			return if @previous_cursor == coords and line
		else
			co = $window.selected_mouse
			x, y, z = co.x, co.y, Wanok::pixel_height(@height)
			coords = [x, y, z, @couche]
			return if @previous_selected_mouse == coords and line
		end

		if line
			if @draw_mode == 2
				draw_pin(coords, nil, new_type_floor, new_form_floor)
			else
				erase_first_layer(coords)
			end
		else
			if @draw_mode == 0 or (@draw_mode == 1 and !line and @rectangle_draw == nil)
				for i in 0...width/$tile_size
					for j in 0...height/$tile_size
						break if (x+i) > $game_map.size[0] or (y+j) > $game_map.size[1]
						new_id = new_type_floor == "floor" ? [((i*$tile_size)+new_id_floor[0]).to_i,((j*$tile_size)+new_id_floor[1]).to_i,$tile_size.to_i,$tile_size.to_i] : new_id_floor
						co = [x+i, y+j, z, @couche]
						trace_line(new_type_floor, new_id, new_form_floor, 0, co, @previous_selected_mouse, 0) if line and @previous_selected_mouse != nil and id != Gosu::KbSpace
						erase_first_layer(co, [co, new_type_floor, new_id, new_form_floor])
					end
				end
			end
			if @draw_mode == 1 and !line and @rectangle_draw != nil and false
				deleting_x, deleting_y = @rectangle_settings[0][2], @rectangle_settings[0][3]
				rect_col = @rectangle_settings[1]
				rect_row = @rectangle_settings[2]

				# Columns
				for i in rect_col[0][0]..rect_col[0][1]
					for j in rect_col[1][0]..rect_col[1][1]
						co = [i, j, z, @couche]
						erase_first_layer(co, [co, new_type_floor, new_id_floor, new_form_floor])
						if deleting_x and $game_map.deleted_preview_rectangle[co] == nil
							$game_map.deleted_preview_rectangle[co] = $game_map.deleted_preview_item[co]
							$game_map.deleted_preview_item.delete(co)
						end
					end
				end
				# Rows
				for i in rect_row[0][0]..rect_row[0][1]
					for j in rect_row[1][0]..rect_row[1][1]
						co = [i, j, z, @couche]
						erase_first_layer(co, [co, new_type_floor, new_id_floor, new_form_floor])
						if deleting_y and $game_map.deleted_preview_rectangle[co] == nil
							$game_map.deleted_preview_rectangle[co] = $game_map.deleted_preview_item[co]
							$game_map.deleted_preview_item.delete(co)
						end
					end
				end
				# Column & rows
				for i in rect_col[0][0]..rect_col[0][1]
					for j in rect_row[1][0]..rect_row[1][1]
						co = [i, j, z, @couche]
						erase_first_layer(co, [co, new_type_floor, new_id_floor, new_form_floor])
						if deleting_x or deleting_y and $game_map.deleted_preview_rectangle[co] == nil
							$game_map.deleted_preview_rectangle[co] = $game_map.deleted_preview_item[co]
							$game_map.deleted_preview_item.delete(co)
						end
					end
				end
			end
		end
		
		if id == Gosu::KbDelete
			@previous_cursor = coords
		else
			@previous_selected_mouse = coords
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	erase_first_layer
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def erase_first_layer(coords, line = nil)
		x, y, z = coords[0], coords[1], coords[2]
		
		return if !Wanok::mouse_is_in_area?([x, y, z])
		cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i
		portion_x, portion_y = (x/16) - (cursor_x/16), (y/16) - (cursor_y/16)
		return nil if !Wanok::is_in_portion?(portion_x, portion_y)
		if $window.map.portions[[portion_x, portion_y]] == nil and (line != nil or @rectangle_draw != nil)
			$window.map.portions[[portion_x, portion_y]] = Game_map_portion.new()
		end
		
		if $window.map.portions[[portion_x, portion_y]] != nil
			add_cancel([(x/16), (y/16)], $window.map.portions[[portion_x, portion_y]]) if (line  == nil) or @rectangle_draw != nil
			is_saved = !$window.map.portions[[portion_x, portion_y]].delete_floor(coords, line)
			@is_saved = is_saved if (@is_saved and line == nil)
			$game_map.add_portion_save([portion_x, portion_y]) if (line == nil) or @rectangle_draw != nil
			$game_map.add_portion_update([portion_x, portion_y])
			add_redo([(x/16), (y/16)], $window.map.portions[[portion_x, portion_y]]) if (line  == nil) or @rectangle_draw != nil
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	apply_sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def apply_sprite(id, line = true)
		new_second_layer = @selection_rectangle.get_rect()
		case @indexes_kind[1]
			when 0
				new_type = "sprite_cam"
			when 1
				new_type = "sprite_fix"
			when 2
				new_type = "double_sprite"
			when 3
				new_type = "quadra_sprite"
			when 4
				new_type = "sprite_floor"
			when 5
				new_type = "sprite_wall"
		end
		return if (new_second_layer[2] == 0 and new_second_layer[3] == 0) or new_type == 0
		
		# Définition de coordonnées
		if id == Gosu::KbSpace
			x, y, z = $window.hero.get_x(), $window.hero.get_y(), Wanok::pixel_height(@height)
			coords = [x, y, z, @couche]
			return if @previous_cursor == coords and line
		else
			co = $window.selected_mouse
			x, y, z = co.x, co.y, Wanok::pixel_height(@height)
			coords = [x, y, z, @couche]
			return if @previous_selected_mouse == coords and line
		end

		if @draw_mode == 0 or (@draw_mode == 1 and !line and @rectangle_draw == nil)
			trace_line(new_type, 0, 0, new_second_layer, coords, @previous_selected_mouse, 2) if @previous_selected_mouse != nil
		end
		
		if id == Gosu::KbSpace
			@previous_cursor = coords
		else
			@previous_selected_mouse = coords
		end
		
		stock_sprite(coords, new_type, new_second_layer,line)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	stock_sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def stock_sprite(coords, new_type, new_second_layer, line= true)
		x, y, z = coords[0], coords[1], coords[2]
		
		return if !Wanok::mouse_is_in_area?([x, y, z])
		cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i
		portion_x, portion_y = (x/16) - (cursor_x/16), (y/16) - (cursor_y/16)
		return if !Wanok::is_in_portion?(portion_x, portion_y)
		
		add_cancel([(x/16), (y/16)], $window.map.portions[[portion_x, portion_y]]) if line or @rectangle_draw != nil
		if $window.map.portions[[portion_x, portion_y]] == nil
			$window.map.portions[[portion_x, portion_y]] = Game_map_portion.new()
		end
		
		is_saved = !$window.map.portions[[portion_x, portion_y]].add_sprite(coords, new_type, new_second_layer)
		@is_saved = is_saved if (@is_saved and line)
		$game_map.add_portion_save([portion_x, portion_y]) if line or @rectangle_draw != nil
		add_redo([(x/16), (y/16)], $window.map.portions[[portion_x, portion_y]]) if line or @rectangle_draw != nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	delete_sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def delete_sprite(id, line = true)
		new_second_layer = @selection_rectangle.get_rect()
		case @indexes_kind[1]
			when 0
				new_type = "sprite_cam"
			when 1
				new_type = "sprite_fix"
			when 2
				new_type = "double_sprite"
			when 3
				new_type = "quadra_sprite"
			when 4
				new_type = "sprite_floor"
			when 5
				new_type = "sprite_wall"
		end
		
		# Définition de coordonnées
		if id == Gosu::KbDelete
			x, y, z = $window.hero.get_x(), $window.hero.get_y(), Wanok::pixel_height(@height)
			coords = [x, y, z, @couche]
			return if @previous_cursor == coords and line
		elsif id == 258
			co = $window.selected_mouse_obj
			coords = (co == nil) ? nil : co[1]
			return if (@previous_selected_mouse == coords and line) or coords == nil
		else
			co = $window.selected_mouse
			x, y, z = co.x, co.y, Wanok::pixel_height(@height)
			coords = [x, y, z, @couche]
			return if @previous_selected_mouse == coords and line
		end

		#  Ligne à tracer
		if line
			if @draw_mode == 2
				draw_pin(coords, nil, new_type_floor, new_form_floor)
			else
				erase_sprite(coords)
			end
		else
			if @draw_mode == 0 or (@draw_mode == 1 and !line and @rectangle_draw == nil)
				trace_line(0, 0, 0, 0, coords, @previous_selected_mouse, 3) if @previous_selected_mouse != nil
				erase_sprite(coords, [coords, new_type])
			end
		end
		
		if id == Gosu::KbDelete
			@previous_cursor = coords
		else
			@previous_selected_mouse = coords
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	erase_sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def erase_sprite(coords, line = nil)
		x, y, z = coords[0], coords[1], coords[2]
		
		return if !Wanok::mouse_is_in_area?([x, y, z])
		cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i
		portion_x, portion_y = (x/16) - (cursor_x/16), (y/16) - (cursor_y/16)
		return nil if !Wanok::is_in_portion?(portion_x, portion_y)
		if $window.map.portions[[portion_x, portion_y]] == nil and (line != nil or @rectangle_draw != nil)
			$window.map.portions[[portion_x, portion_y]] = Game_map_portion.new()
		end
		
		if $window.map.portions[[portion_x, portion_y]] != nil
			add_cancel([(x/16), (y/16)], $window.map.portions[[portion_x, portion_y]]) if (line  == nil) or @rectangle_draw != nil
			is_saved = !$window.map.portions[[portion_x, portion_y]].delete_sprite(coords, line)
			@is_saved = is_saved if (@is_saved and line == nil)
			$game_map.add_portion_save([portion_x, portion_y]) if (line == nil) or @rectangle_draw != nil
			add_redo([(x/16), (y/16)], $window.map.portions[[portion_x, portion_y]]) if (line  == nil) or @rectangle_draw != nil
		end
	end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	apply_objet
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def apply_objet(id)
		#~ new_form = @indexes_form[@selection_button]
		#~ new_second_layer = @indexes[@selection_button]
		#~ new_type = "3Dobject"
		
		#~ if id == Gosu::KbSpace
			#~ x, y, z = ((@window.hero.position.x + 1) / $tile_size).to_i, ((@window.hero.position.z + 1) / $tile_size).to_i, @height
			#~ coords = [x, y, z, @couche]
		#~ else
			#~ return if @window.selected_mouse == nil
			#~ coords = @window.selected_mouse[1]
		#~ end
		#~ return if @previous_selected_mouse == coords
		
		#~ add_cancel(@window.map.tiles) if @first_pressure

		#~ trace_line(new_type, 0, new_form, new_second_layer, coords, @previous_selected_mouse, 4) if @previous_selected_mouse != nil
		#~ @previous_selected_mouse = coords
		
		#~ stock_objet(coords, new_type, new_second_layer, new_form)
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	stock_objet
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def stock_objet(coords, new_type, new_second_layer, new_form)
		#~ if @window.map.tiles.has_key?(coords)
			#~ tab = @window.map.tiles[coords].split(";") # actual datas
			#~ type_floor, type_obj, first_layer, second_layer, pos, orientation, form_floor, form_obj, hauteur, couche = tab[0], tab[1], tab[2], tab[3], tab[4], tab[5], tab[6], tab[7], tab[8], tab[9]
			#~ @window.map.tiles[coords] = type_floor + ";" + new_type + ";" + first_layer + ";" + new_second_layer.to_s + ";" + pos + ";" + orientation + ";" + form_floor + ";" + new_form.to_s + ";" + hauteur + ";" + @couche.to_s
			#~ @window.map.objects[[form_obj.to_i, second_layer.to_i]].delete(coords) if @window.map.objects[[form_obj.to_i, second_layer.to_i]] != nil
			#~ Wanok::add_array(@window.map.objects, [new_form, new_second_layer.to_i], coords)
		#~ end
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	delete_objet
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def delete_objet
		#~ return if @window.selected_mouse_obj == nil
		#~ coords = @window.selected_mouse_obj[1]

		#~ return if @previous_selected_mouse == coords
		
		#~ add_cancel(@window.map.tiles) if @first_pressure
		
		#~ trace_line(0, 0, 0, 0, coords, @previous_selected_mouse, 5) if @previous_selected_mouse != nil
		#~ @previous_selected_mouse = coords
		
		#~ erase_objet(coords)
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	erase_objet
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def erase_objet(coords)
		#~ if @window.map.tiles.has_key?(coords)
			#~ tab = @window.map.tiles[coords].split(";") # actual datas
			#~ type_floor, type_obj, first_layer, second_layer, pos, orientation, form_floor, form_obj, hauteur, couche = tab[0], tab[1], tab[2], tab[3], tab[4], tab[5], tab[6], tab[7], tab[8], tab[9]
			#~ @window.map.tiles[coords] = type_floor + ";0;" + first_layer + ";0;" + pos + ";" + orientation + ";" + form_floor + ";0;" + hauteur + ";" + @couche.to_s
			#~ @window.map.objects[[form_obj.to_i, second_layer.to_i]].delete(coords) if @window.map.objects[[form_obj.to_i, second_layer.to_i]] != nil
		#~ end
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	apply_pente
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def apply_pente
		#~ new_form = @indexes_kind[3]
		#~ new_second_layer = @indexes[@selection_button]
		#~ new_type = "6"
		#~ new_praticable = "4"
		
		#~ x, y, z = ((@window.hero.position.x + 1) / $tile_size).to_i, ((@window.hero.position.z + 1) / $tile_size).to_i, @height
		#~ return if !@window.map.tiles.has_key?([x, y, z, @couche])
		#~ tab = @window.map.tiles[[x, y, z, @couche]].split(";") # actual datas
		#~ type, first_layer, second_layer, pos, orientation, praticable, hauteur, form, couche = tab[0], tab[1], tab[2], tab[3], tab[4], tab[5], tab[6], tab[7], tab[8]
		#~ first_layer = "0" if !@window.map.tiles.has_key?([x, y, z, @couche])
		#~ @window.map.tiles[[x, y, z, @couche]] = new_type + ";" + first_layer + ";" + new_second_layer.to_s + ";" + pos + ";" + orientation + ";" + new_praticable + ";" + hauteur + ";" + new_form.to_s + ";" + @couche.to_s
		
		#~ refresh_layers
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	delete_pente
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def delete_pente
		#~ x, y, z = ((@window.hero.position.x + 1) / $tile_size).to_i, ((@window.hero.position.z + 1) / $tile_size).to_i, @height
		#~ tab = @window.map.tiles[[x, y, z, @couche]].split(";") # actual datas
		#~ type, first_layer, second_layer, pos, orientation, praticable, hauteur, form, couche = tab[0], tab[1], tab[2], tab[3], tab[4], tab[5], tab[6], tab[7], tab[8]
		#~ @window.map.tiles[[x, y, z, @couche]] = "0;" + first_layer + ";0;0;0;0;" + hauteur + ";0;" + @couche.to_s
		
		#~ refresh_layers
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	apply_relief
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def apply_relief(id)
		#~ case @indexes_kind[3]
			#~ when 0
				#~ new_type = "mountain"
			#~ when 1	
				#~ new_type = "block"
		#~ end
		#~ new_second_layer = @indexes[@selection_button]
		#~ new_form = @indexes_form[@selection_button]
		
		#~ if id == Gosu::KbSpace
			#~ x, y, z = ((@window.hero.position.x + 1) / $tile_size).to_i, ((@window.hero.position.z + 1) / $tile_size).to_i, @height
			#~ coords = [x, y, z, @couche]
		#~ else
			#~ return if @window.selected_mouse == nil
			#~ coords = @window.selected_mouse[1]
		#~ end
		#~ return if @previous_selected_mouse == coords
		
		#~ add_cancel(@window.map.tiles) if @first_pressure
		
		#~ if new_type == "mountain"
			#~ if !@window.map.tiles.has_key?([x, y, z+1, @couche])
				#~ return if !@window.map.tiles.has_key?([x, y, z, @couche])
				#~ tab = @window.map.tiles[[x, y, z, @couche]].split(";") # actual datas
				#~ type, first_layer, second_layer, pos, orientation, praticable, hauteur, form, couche = tab[0].to_i, tab[1].to_i, tab[2].to_i, tab[3].to_i, tab[4].to_i, tab[5].to_i, tab[6].to_i, tab[7].to_i, tab[8].to_i

				#~ coords = [[x, y-1, z, @couche], [x+1, y, z, @couche], [x, y+1, z, @couche], [x-1, y, z, @couche], [x+1, y-1, z, @couche], [x+1, y+1, z, @couche], [x-1, y+1, z, @couche], [x-1, y-1, z, @couche]]
				#~ for i in 0...coords.size 
					#~ return if !@window.map.tiles.has_key?(coords[i])
				#~ end
				#~ @window.map.tiles[[x, y, z+1, @couche]] = "0;" + @default_first_layer.to_s + ";0;" + pos.to_s + ";" + orientation.to_s + ";0;" + (z+1).to_s + ";0" + ";" + @couche.to_s
				
				#~ for i in 0...coords.size
					#~ test = @window.map.tiles[coords[i]].split(";")
					#~ s, r = test[7].to_i, test[6].to_i
					#~ if ((hauteur+1) != r)
						#~ q, h = coords[i][0], coords[i][1]
						#~ new_coords = [[q, h+1, z, @couche], [q-1, h, z, @couche], [q, h-1, z, @couche], [q+1, h, z, @couche], [q-1, h+1, z, @couche], [q-1, h-1, z, @couche], [q+1, h-1, z, @couche], [q+1, h+1, z, @couche]]
						#~ text = "3"
						#~ ombre = "0"
						#~ for j in 0..3
							#~ if (@window.map.tiles.has_key?([new_coords[j][0], new_coords[j][1], new_coords[j][2]+1, @couche]))
								#~ @window.map.tiles[new_coords[j]] = "0;" + @default_first_layer.to_s + ";0;" + pos.to_s + ";" + orientation.to_s + ";" + praticable.to_s + ";" + z.to_s + ";0" + ";" + @couche.to_s
								#~ text += "1"
							#~ else
								#~ text += "0"
							#~ end
						#~ end
						#~ for j in 4..7
							#~ if (s < 2000 or (j == 4 and text.split("")[1] == "0" and text.split("")[2] == "0") or (j == 5 and text.split("")[2] == "0" and text.split("")[3] == "0") or (j == 6 and text.split("")[3] == "0" and text.split("")[4] == "0") or (j == 7 and text.split("")[1] == "0" and text.split("")[4] == "0"))
								#~ if (@window.map.tiles.has_key?([new_coords[j][0], new_coords[j][1], new_coords[j][2]+1, @couche]))
									#~ @window.map.tiles[new_coords[j]] = "0;" + @default_first_layer.to_s + ";0;" + pos.to_s + ";" + orientation.to_s + ";" + praticable.to_s + ";" + z.to_s + ";0" + ";" + @couche.to_s
									#~ text += "1"
								#~ else
									#~ text += "0"
								#~ end
							#~ else
								#~ text += "0"
							#~ end
						#~ end
						
						#~ split = text.split("")
						#~ if split[3] == "1" or split[4] == "1" or split[2] == "1" or (split[7] == "1" and split[8] == "1") or (split[5] == "1" and split[6] == "1") or (split[6] == "1" and split[7] == "1")
							#~ ombre = "1"
						#~ elsif (split[5] == "1" and split[8] == "1")
							#~ ombre = "0"
						#~ elsif split[7] == "1"
							#~ ombre = "2"
						#~ elsif split[6] == "1"
							#~ ombre = "3"
						#~ elsif split[8] == "1"
							#~ ombre = "4"
						#~ elsif split[5] == "1"
							#~ ombre = "5"
						#~ end

						#~ @window.map.tiles[coords[i]] = "7;" + ombre + ";" + new_second_layer.to_s + ";" + test[3] + ";" + test[4] + ";3;" + test[6] + ";" + text + ";" + @couche.to_s if (!@window.map.tiles.has_key?([coords[i][0], coords[i][1], coords[i][2]+1, @couche]))
					#~ end
				#~ end
				#~ @window.map.tiles[[x, y, z, @couche]] = "0;" + @default_first_layer.to_s + ";0;" + pos.to_s + ";" + orientation.to_s + ";0;" + z.to_s + ";0" + ";" + @couche.to_s
				
				#~ refresh_layers
			#~ end
		#~ else
			#~ trace_line(new_type, 0, new_form, new_second_layer, coords, @previous_selected_mouse, 4) if @previous_selected_mouse != nil
			#~ @previous_selected_mouse = coords
			
			#~ stock_block(coords, new_type, new_second_layer, new_form)
		#~ end
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	stock_block
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def stock_block(coords, new_type, new_second_layer, new_form)
		#~ if @window.map.tiles.has_key?(coords)
			#~ tab = @window.map.tiles[coords].split(";") # actual datas
			#~ type_floor, type_obj, first_layer, second_layer, pos, orientation, form_floor, form_obj, hauteur, couche = tab[0], tab[1], tab[2], tab[3], tab[4], tab[5], tab[6], tab[7], tab[8], tab[9]
			#~ @window.map.tiles[coords] = type_floor + ";" + new_type + ";" + first_layer + ";" + new_second_layer.to_s + ";" + pos + ";" + orientation + ";" + form_floor + ";" + new_form.to_s + ";" + hauteur + ";" + @couche.to_s
			#~ new_coords = [coords[0], coords[1], [coords[2][0] + new_form[2], coords[2][1] + new_form[3]], coords[3]]
			#~ if !@window.map.tiles.has_key?(new_coords)
				#~ @window.map.tiles[new_coords] = "floor;0;[0,0,16,16];0;0;0;0;0;" + new_coords[2].to_s + ";" + @couche.to_s
			#~ end
		#~ end
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	delete_relief
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def delete_relief
		#~ new_second_layer = @indexes[@selection_button]
		#~ x, y, z = ((@window.hero.position.x + 1) / $tile_size).to_i, ((@window.hero.position.z + 1) / $tile_size).to_i, @height
		
		#~ if @window.map.tiles.has_key?([x, y, z+1, @couche])
			#~ tab = @window.map.tiles[[x, y, z+1, @couche]].split(";") # actual datas
			#~ type, first_layer, second_layer, pos, orientation, praticable, hauteur, form, couche = tab[0].to_i, tab[1].to_i, tab[2].to_i, tab[3].to_i, tab[4].to_i, tab[5].to_i, tab[6].to_i, tab[7].to_i, tab[8].to_i
			#~ coords = [[x, y, z, @couche], [x, y-1, z, @couche], [x+1, y, z, @couche], [x, y+1, z, @couche], [x-1, y, z, @couche], [x+1, y-1, z, @couche], [x+1, y+1, z, @couche], [x-1, y+1, z, @couche], [x-1, y-1, z, @couche]]
			#~ @window.map.tiles.delete([x, y, z+1, @couche])
			
			#~ for i in 0...coords.size
				#~ test = @window.map.tiles[coords[i]].split(";")
				#~ s, r = test[7].to_i, test[6].to_i
				#~ if ((hauteur+1) != r)
					#~ q, h = coords[i][0], coords[i][1]
					#~ new_coords = [[q, h+1, z, @couche], [q-1, h, z, @couche], [q, h-1, z, @couche], [q+1, h, z, @couche], [q-1, h+1, z, @couche], [q-1, h-1, z, @couche], [q+1, h-1, z, @couche], [q+1, h+1, z, @couche]]
					#~ text = "3"
					#~ ombre = "0"
					#~ for j in 0..3
						#~ if (@window.map.tiles.has_key?([new_coords[j][0], new_coords[j][1], new_coords[j][2]+1, @couche]))
							#~ @window.map.tiles[new_coords[j]] = "0;" + @default_first_layer.to_s + ";0;" + pos.to_s + ";" + orientation.to_s + ";" + praticable.to_s + ";" + z.to_s + ";0" + ";" + @couche.to_s
							#~ text += "1"
						#~ else
							#~ text += "0"
						#~ end
					#~ end
					#~ for j in 4..7
						#~ if (s < 2000 or (j == 4 and text.split("")[1] == "0" and text.split("")[2] == "0") or (j == 5 and text.split("")[2] == "0" and text.split("")[3] == "0") or (j == 6 and text.split("")[3] == "0" and text.split("")[4] == "0") or (j == 7 and text.split("")[1] == "0" and text.split("")[4] == "0"))
							#~ if (@window.map.tiles.has_key?([new_coords[j][0], new_coords[j][1], new_coords[j][2]+1, @couche]))
								#~ @window.map.tiles[new_coords[j]] = "0;" + @default_first_layer.to_s + ";0;" + pos.to_s + ";" + orientation.to_s + ";" + praticable.to_s + ";" + z.to_s + ";0;" + @couche.to_s
								#~ text += "1"
							#~ else
								#~ text += "0"
							#~ end
						#~ else
							#~ text += "0"
						#~ end
					#~ end
					#~ type = "7"
					#~ second = new_second_layer
					#~ praticable = "3"
					#~ if text == "300000000"
						#~ text = "0"
						#~ type = "0"
						#~ second = 0
						#~ ombre = @default_first_layer
						#~ praticable = "0"
					#~ else
						#~ split = text.split("")
						#~ if split[3] == "1" or split[4] == "1" or split[2] == "1" or (split[7] == "1" and split[8] == "1") or (split[5] == "1" and split[6] == "1") or (split[6] == "1" and split[7] == "1")
							#~ ombre = "1"
						#~ elsif (split[5] == "1" and split[8] == "1")
							#~ ombre = "0"
						#~ elsif split[7] == "1"
							#~ ombre = "2"
						#~ elsif split[6] == "1"
							#~ ombre = "3"
						#~ elsif split[8] == "1"
							#~ ombre = "4"
						#~ elsif split[5] == "1"
							#~ ombre = "5"
						#~ end
					#~ end
					#~ @window.map.tiles[coords[i]] = type + ";" + ombre.to_s + ";" + new_second_layer.to_s + ";" + test[3] + ";" + test[4] + ";" + praticable + ";" + test[6] + ";" + text + ";" + @couche.to_s if (!@window.map.tiles.has_key?([coords[i][0], coords[i][1], coords[i][2]+1, @couche]))
				#~ end
			#~ end
			
			#~ refresh_layers
		#~ end
	#~ end
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	apply_ev
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
	#~ def apply_ev
		#~ @window.interface.block = true
		#~ file = File.open("Datas/editcom.txt", "r:UTF-8").readlines
		#~ tab = file[0].chomp.split("$")
		#~ tab[3] = "[0,0]"
		#~ file = File.open("Datas/editcom.txt", "w:UTF-8")
		#~ file.puts(tab.join("$"))
		#~ file.close()
		#~ file = File.open("Datas/editcom.txt", "r:UTF-8").readlines
	#~ end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw_pin
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw_pin(coords, texture_after, new_type_floor, new_form_floor)
		x, y = coords[0], coords[1]
		cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i
		portion_x, portion_y = (x/16) - (cursor_x/16), (y/16) - (cursor_y/16)
		texture_before = ($window.map.portions[[portion_x, portion_y]] != nil) ? $window.map.portions[[portion_x, portion_y]].get_floor_texture(coords) : nil
		
		texture_after_reduced = texture_after != nil ? [texture_after[0],texture_after[1],$tile_size.to_i,$tile_size.to_i] : nil
		
		if texture_before != texture_after
			tab = [coords]
			if texture_after_reduced == nil
				erase_first_layer(coords)
			else
				stock_first_layer(coords, new_type_floor, texture_after_reduced, new_form_floor)
			end
			while (!tab.empty?)
				adjacentes = [
					[tab[0][0]-1,tab[0][1],tab[0][2],tab[0][3]],
					[tab[0][0]+1,tab[0][1],tab[0][2],tab[0][3]],
					[tab[0][0],tab[0][1]+1,tab[0][2],tab[0][3]],
					[tab[0][0],tab[0][1]-1,tab[0][2],tab[0][3]]
						]
				tab.delete_at(0)
				adjacentes.each do |new_coords|	
					local_x, local_y = new_coords[0] - coords[0], new_coords[1] - coords[1]
					texture_after_reduced = texture_after != nil ? [texture_after[0] + (((local_x*$tile_size).to_i)%texture_after[2]),texture_after[1] + (((local_y*$tile_size).to_i)%texture_after[3]),$tile_size.to_i,$tile_size.to_i] : nil
					x, y = new_coords[0], new_coords[1]
					portion_x, portion_y = (x/16) - (cursor_x/16), (y/16) - (cursor_y/16)
					if Wanok::is_in_portion?(portion_x, portion_y)
						texture_here = ($window.map.portions[[portion_x, portion_y]] != nil) ? $window.map.portions[[portion_x, portion_y]].get_floor_texture(new_coords) : nil
						if (Wanok::mouse_is_in_area?(new_coords) and texture_here == texture_before)
							if texture_after_reduced == nil
								erase_first_layer(new_coords)
							else
								stock_first_layer(new_coords, new_type_floor, texture_after_reduced, new_form_floor)
							end
							tab.push(new_coords)
						end
					end
				end
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	stock
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def stock(coords, new_type, new_first_layer, new_form, new_second_layer, kind)
		case kind
			when 0
				stock_first_layer(coords, new_type, new_first_layer, new_form)
			when 1
				erase_first_layer(coords)
			when 2
				stock_sprite(coords, new_type, new_second_layer)
			when 3
				erase_sprite(coords)
			when 4
				stock_objet(coords, new_type, new_second_layer, new_form)
			when 5
				erase_objet(coords)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	trace_line
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def trace_line(new_type, new_first_layer, new_form, new_second_layer, coords, previous_selected_mouse, kind)
		x1, x2, y1, y2 = previous_selected_mouse[0], coords[0], previous_selected_mouse[1], coords[1]
		z = coords[2]
		dx = x2 - x1
		dy = y2 - y1
		test = true
	    
		if (dx != 0)
			if dx >0
				if dy != 0
					if dy > 0
						if dx >= dy
							e = dx
							dx = 2*e
							dy = dy*2
							while (test)
								stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
								x1 += 1
								break if (x1 == x2)
								e -= dy
								if (e < 0)
									y1 += 1
									e += dx
								end
							end
						else
							e = dy
							dy = 2*e
							dx = dx*2
							while (test)
								stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
								y1 += 1
								break if (y1 == y2)
								e -= dx
								if (e < 0)
									x1 += 1
									e += dy
								end
							end
						end
					else
						if dx >= -dy
							e = dx
							dx = 2*e
							dy = dy*2
							while (test)
								stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
								x1 += 1
								break if (x1 == x2)
								e += dy
								if (e < 0)
									y1 -= 1
									e += dx
								end
							end
						else
							e = dy
							dy = 2*e
							dx = dx*2
							while (test)
								stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
								y1 -= 1
								break if (y1 == y2)
								e += dx
								if (e > 0)
									x1 += 1
									e += dy
								end
							end
						end
					end
				else
					until (x1 == x2)
						stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
						x1 += 1
					end
				end
			else
				dy = y2-y1
				if (dy != 0)
					if (dy > 0)
						if (-dx >= dy)
							e = dx
							dx = e*2
							dy = dy*2
							while (test)
								stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
								x1 -= 1
								break if (x1 == x2)
								e += dy
								if (e >= 0)
									y1 += 1
									e += dx
								end
							end
						else
							e = dy
							dy = 2*e
							dx = dx*2
							while (test)
								stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
								y1 += 1
								break if (y1 == y2)
								e += dx
								if (e <= 0)
									x1 -= 1
									e += dy
								end
							end
						end
					else
						if (dx <= dy)
							e = dx
							dx = e*2
							dy = dy*2
							while (test)
								stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
								x1 -= 1
								break if (x1 == x2)
								e -= dy
								if (e >= 0)
									y1 -= 1
									e += dx
								end
							end
						else
							e = dy
							dy = 2*e
							dx = dx*2
							while (test)
								stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
								y1 -= 1
								break if (y1 == y2)
								e -= dx
								if (e >= 0)
									x1 -= 1
									e += dy
								end
							end
						end
					end
				else
					until (x1 == x2)
						stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
						x1 -= 1
					end
				end
			end
		else
			dy = y2 - y1
			if (dy != 0)
				if (dy > 0)
					until (y1 == y2)
						stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
						y1 += 1
					end
				else
					until (y1 == y2)
						stock([x1, y1, z, @couche], new_type, new_first_layer, new_form, new_second_layer, kind)
						y1 -= 1
					end
				end
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update
		set_hover()
		
		# update repeating keys
		$keys_repeat.each_key do |key|
			if $keys_repeat[key][0] == 0
				$keys_repeat[key][0] = $keys_repeat[key][1] 
				button_down(key)
			else
				$keys_repeat[key][0] -= 1
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw
		x, y = $window.hero.get_x(), $window.hero.get_y()
		@text_position.draw
		
		@arrows_textures_up.draw
		@arrows_textures_down.draw(0, $screen_y-34, 0)
		@arrows_textures_left_right.draw(0, $screen_y-34, 0)
		@arrows_form_up.draw($screen_x - 36, 0, 0)
		@arrows_form_down.draw($screen_x - 36, $screen_y-34, 0)
		if @indexes_end[@selection_button] != 0
			x_s, y_s, c = 2, 80, Gosu::Color.new(255, 255, 255)
			if @selection_button == :button_sprite or (@selection_button == :button_first_layer and @indexes_kind[0] == 0)
				tile = @selection_button == :button_sprite ? @tileset : @floor
				x_r, y_r = x_s, y_s
				x_plus = (@indexes_rectangle[0]*32.0)
				y_plus = (@indexes_rectangle[1]*32.0)
				x_s += x_plus
				y_s += y_plus
				width = (tile.width*(32.0/$tile_size))
				height = (tile.height*(32.0/$tile_size))
				r = Rect.new($window, 0, 34, 0, @selection_rectangle_max_width, ((2+@selection_rectangle_max_height)*32) + 28)
				r_cursors = Rect.new($window, 2, $screen_y - 2 - 32, 0, 102, 32)
				alpha = (((r.is_in_rect?([$window.mouse_x, $window.mouse_y]) or @selection_rectangle_pressed or @hover == :cursor_textures_up or @hover == :cursor_textures_down or @hover == :cursor_textures_left or @hover == :cursor_textures_right or r_cursors.is_in_rect?([$window.mouse_x, $window.mouse_y]))) and !@applying) ? 255 : 150
				c = Gosu::Color.new(alpha, 255, 255, 255)
				$window.clip_to(x_r, y_r, @selection_rectangle_max_width, @selection_rectangle_max_height*32){
					tile.draw_as_quad(x_s, y_s, c, x_s + width, y_s, c, x_s + width, y_s + height, c, x_s, y_s + height, c, 0)
					@selection_rectangle.draw(@indexes_rectangle[0]*32.0, @indexes_rectangle[1]*32.0, alpha)
				}
			else
				for i in 0...@selection_rectangle_max_height
					index = (i-((@selection_rectangle_max_height-1)/2)+@indexes[@selection_button]) % @indexes_end[@selection_button]
					case @selection_button
						when :button_first_layer
							case @indexes_kind[0]
								when 1
									images = $window.im.autotiles_hud
								when 2
									images = $window.im.water_hud["Foam"]
							end
							image = images[index]
						when :button_objet
							images = $window.im.object3D_hud[@indexes_form[:button_objet]]
							image = images[index]
						when :button_relief, :button_pente
							images = $window.im.relief_hud
							image = images[index]
					end
					image.draw_as_quad(x_s, y_s + (i*32.0), c, x_s + 32.0, y_s + (i*32.0), c, x_s, y_s + ((i+1)*32.0), c, x_s + 32.0, y_s + ((i+1)*32.0), c, 0) if image != nil
				end
				
				@selection_rectangle.draw(x_s, y_s + (((@selection_rectangle_max_height-1)/2)*32.0), 255)
				#~ @cursor_texture.draw(x_s, y_s + (((@selection_rectangle_max_height-1)/2)*32.0))
				if @selection_button == :button_objet or (@selection_button == :button_first_layer and @indexes_kind[0] == 2)
					x_s, y_s, c = $screen_x - 34, 80, Gosu::Color.new(255, 255, 255)
					case @selection_button
						when :button_first_layer
							images = $window.im.water_hud["Border"]
						when :button_objet
							images = $window.im.object3D_min
					end
					for i in 0...@selection_rectangle_max_height
						index = (i-((@selection_rectangle_max_height-1)/2)+@indexes_form[@selection_button]) % images.size
						image = images[index]
						image.draw_as_quad(x_s, y_s + (i*32.0), c, x_s + 32.0, y_s + (i*32.0), c, x_s, y_s + ((i+1)*32.0), c, x_s + 32.0, y_s + ((i+1)*32.0), c, 0)
					end
					@selection_rectangle_form.draw(0, (((@selection_rectangle_max_height-1)/2)*32.0), 255)
				end
			end
		end

		@toolbar.update() if !@selection_rectangle_pressed and !@applying
		@toolbar.draw()
		
		if @is_saved
			@sprite_yes.draw()
		else
			@sprite_no.draw()
		end
	end
end 