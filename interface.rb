# encoding: UTF-8

class Interface
	
	attr_accessor :type, :hud, :block, :editor
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(directory, map_name)
		@type = nil
		@hud = Map_editor.new(directory, map_name)
		@block = false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id) 
		@hud.button_down(id)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_up
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_up(id) 
		@hud.button_up(id)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	eval_deleted_preview_item
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def eval_deleted_preview_item()
		$game_map.deleted_preview_item.each do |coords,tab|
			if tab == :none
				case @hud.selection_button
					when :button_first_layer
						@hud.erase_first_layer(coords, false)
					when :button_sprite
						@hud.erase_sprite(coords, false)
				end
			else
				case @hud.selection_button
					when :button_first_layer
						@hud.stock_first_layer(coords, $game_map.deleted_preview_item[coords][0], $game_map.deleted_preview_item[coords][1], $game_map.deleted_preview_item[coords][2], false)
					when :button_sprite
						@hud.stock_sprite(coords, $game_map.deleted_preview_item[coords][0], $game_map.deleted_preview_item[coords][1], false)
				end
			end
		end
		$game_map.deleted_preview_item = {}	
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	eval_deleted_preview_item
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def eval_deleted_preview_rectangle()
		$game_map.deleted_preview_rectangle.each do |coords,tab|
			if tab == :none
				@hud.erase_first_layer(coords, false)
			else
				@hud.stock_first_layer(coords, $game_map.deleted_preview_rectangle[coords][0], $game_map.deleted_preview_rectangle[coords][1], $game_map.deleted_preview_rectangle[coords][2], false)
			end
		end
		$game_map.deleted_preview_rectangle = {}	
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update()
		ray = Wanok::get_ray_world($window.camera.projection_matrix, $window.camera.view_matrix)
		distance = (Wanok::pixel_height(@hud.height) - $window.camera.z)/ray.y
		point = Wanok::get_point_on_ray(ray, distance)
		corrected_point = Vector3D.new((point.x/$tile_size).to_i, (point.z/$tile_size).to_i, (point.y/$tile_size).to_i)
		corrected_point.x -= 1 if point.x < 0
		corrected_point.y -= 1 if point.z < 0
			
		$window.selected_mouse = corrected_point
		@hud.update

		if @hud.draw_mode == 0 or @hud.draw_mode == 1
			if @hud.selection_button == :button_first_layer and (@hud.hover != :big_textures or !@hud.is_in_floor_mode?()) and @hud.hover != :textures and @hud.selection_rectangle.width != 0 and @hud.selection_rectangle.height != 0 and !$window.button_down?(256) and !$window.button_down?(258) and !$window.button_down?(Gosu::KbLeftControl)
				if @previous_mouse != nil and [@previous_mouse.x,@previous_mouse.y,@previous_mouse.z] != [$window.selected_mouse.x,$window.selected_mouse.y,$window.selected_mouse.z]
					eval_deleted_preview_item()
					@hud.delete_first_layer(256, false)
					@hud.apply_first_layer(256, false)
					@hud.previous_selected_mouse = nil
				end
				@previous_mouse = $window.selected_mouse
			elsif @hud.selection_button == :button_sprite and (@hud.hover != :big_textures or !@hud.is_in_floor_mode?()) and @hud.hover != :textures and @hud.selection_rectangle.width != 0 and @hud.selection_rectangle.height != 0 and !$window.button_down?(256) and !$window.button_down?(258) and !$window.button_down?(Gosu::KbLeftControl)
				if @previous_mouse != nil and [@previous_mouse.x,@previous_mouse.y,@previous_mouse.z] != [$window.selected_mouse.x,$window.selected_mouse.y,$window.selected_mouse.z]
					eval_deleted_preview_item()
					@hud.delete_sprite(nil, false)
					@hud.apply_sprite(256, false)
					@hud.previous_selected_mouse = nil
				end
				@previous_mouse = $window.selected_mouse
			elsif @hud.selection_button == :button_first_layer and (@hud.hover != :big_textures or !@hud.is_in_floor_mode?()) and @hud.hover != :textures and !$window.button_down?(256) and !$window.button_down?(258)
				eval_deleted_preview_item()
			elsif @hud.selection_button == :button_sprite and (@hud.hover != :big_textures or !@hud.is_in_floor_mode?()) and @hud.hover != :textures and !$window.button_down?(256) and !$window.button_down?(258)
				eval_deleted_preview_item()
			end 
		end
		if @hud.draw_mode == 1
			if @hud.selection_button == :button_first_layer and @hud.selection_rectangle.width != 0 and @hud.selection_rectangle.height != 0 and ($window.button_down?(256) or $window.button_down?(258)) and !$window.button_down?(Gosu::KbLeftControl) and @hud.rectangle_draw != nil
				if @previous_mouse != nil and [@previous_mouse.x,@previous_mouse.y,@previous_mouse.z] != [$window.selected_mouse.x,$window.selected_mouse.y,$window.selected_mouse.z]
					@hud.get_rectangle_settings()
					@hud.delete_first_layer(256, false)
					@hud.apply_first_layer(256, false) if $window.button_down?(256)
					@hud.previous_selected_mouse = nil
					eval_deleted_preview_rectangle()
				end
				@previous_mouse = $window.selected_mouse
			end
		end

		$game_map.update_portions()
	end
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw
		@hud.draw
	end
end