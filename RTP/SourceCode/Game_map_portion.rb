# encoding: UTF-8

class Game_map_portion
	
	attr_reader 	:floors,
				:autotiles,
				:sprites,
				:water,
				:water_border
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize()
		@floors = Hash.new # textures => coords
		@autotiles = Hash.new # id => texture_id => [coords]
		@water = Hash.new # id => texture_id => [coords]
		@water_border = Hash.new # form_id => [coords]
		@sprites = Hash.new # textures => coords
		
		# coords => infos (type,id,form)
		@floors_infos = Hash.new # floors + autotiles + water
		@sprites_infos = Hash.new
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_empty?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_empty?()
		return (@floors.empty?() and @autotiles.empty?() and @sprites.empty?() and @water.empty?())
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_floor_infos
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_floor_infos(coords)
		return @floors_infos[coords]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_floor_texture
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_floor_texture(coords)
		return @floors_infos[coords] != nil ? @floors_infos[coords][1] : nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_floor
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_floor(coords, id, type, form, line = true)
		is_changing = false

		# if a floor already exists here
		if ((rect = get_floor_texture(coords)) != nil)
			infos = get_floor_infos(coords)
			is_changing = (rect != id)
			case infos[0]
				when "floor"
					@floors[rect].delete(coords)
					if @floors[rect].empty?()
						@floors.delete(rect)
						$game_map.texture_floors[rect][1] -= 1
						$game_map.texture_floors.delete(rect) if $game_map.texture_floors[rect][1] == 0
					end
				when "autotile"
					previous_id = infos[1]
					render = $game_map.autotiles[previous_id].tiles[coords].render
					$game_map.texture_autotiles[previous_id][render][1] -= 1
					$game_map.autotiles[previous_id].remove(coords)
					if $game_map.autotiles[previous_id].empty?()
						$game_map.autotiles.delete(previous_id)
					end
					@autotiles[previous_id].each_key do |texture|
						@autotiles[previous_id][texture].delete(coords)
						if @autotiles[previous_id][texture].empty?()
							@autotiles[previous_id].delete(texture)
						end
					end
					if @autotiles[previous_id].empty?()
						@autotiles.delete(previous_id)
					end
				when "water"
					previous_id, previous_form = infos[1], infos[2]
					render = $game_map.autotiles[previous_id].tiles[coords].render
					$game_map.texture_autotiles[previous_id][render][1] -= 1
					$game_map.autotiles[previous_id].remove(coords)
					if $game_map.autotiles[previous_id].empty?()
						$game_map.autotiles.delete(previous_id)
					end
					@water[previous_id].each_key do |texture|
						@water[previous_id][texture].delete(coords)
						if @water[previous_id][texture].empty?()
							@water[previous_id].delete(texture)
						end
					end
					if @water[previous_id].empty?()
						@water.delete(previous_id)
					end
					@water_border[previous_form].delete(coords)
					@water_border.delete(previous_form) if @water_border[previous_form].empty?()
			end
			@floors_infos.delete(coords)
		end
		
		# Adding the new floor
		@floors_infos[coords] = [type,id,form]

		case type 
			when "floor"
				Wanok::add_hash(@floors, id, coords, [type,form])
				if !$game_map.texture_floors.has_key?(id)
					$game_map.texture_floors[id] = [$game_map.tileset_floors.crop(id[0], id[1], id[2], id[3]), 1]
				else
					$game_map.texture_floors[id][1] += 1
				end
			when "autotile"
				$game_map.autotiles[id] = Autotiles.new(id) if $game_map.autotiles[id] == nil
				$game_map.autotiles[id].add(coords, line)
			when "water"
				$game_map.autotiles[id] = Autotiles.new(id) if $game_map.autotiles[id] == nil
				$game_map.autotiles[id].add(coords, line)
				Wanok::add_array(@water_border, form, coords)
		end
		
		return is_changing
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	delete_floor
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def delete_floor(coords, line)
		return if $game_map.deleted_preview_item[coords] != nil and line != nil and line != false
		is_changing = false
		id = nil
		
		# if a floor exists here
		if ((rect = get_floor_texture(coords)) != nil)
			infos = get_floor_infos(coords)
			is_changing = true
			line[1] = infos[0] if line != nil and line != false
			case infos[0]
				when "floor"
					id = rect
					@floors[rect].delete(coords)
					if @floors[rect].empty?()
						@floors.delete(rect)
						$game_map.texture_floors[rect][1] -= 1
						$game_map.texture_floors.delete(rect) if $game_map.texture_floors[rect][1] == 0
					end
				when "autotile"
					id = infos[1]
					render = $game_map.autotiles[id].tiles[coords].render
					$game_map.texture_autotiles[id][render][1] -= 1
					$game_map.autotiles[id].remove(coords)
					if $game_map.autotiles[id].empty?()
						$game_map.autotiles.delete(id)
					end
					@autotiles[id].each_key do |texture|
						@autotiles[id][texture].delete(coords)
						if @autotiles[id][texture].empty?()
							@autotiles[id].delete(texture)
						end
					end
					if @autotiles[id].empty?()
						@autotiles.delete(id)
					end
				when "water"
					id, previous_form = infos[1], infos[2]
					render = $game_map.autotiles[id].tiles[coords].render
					$game_map.texture_autotiles[id][render][1] -= 1
					$game_map.autotiles[id].remove(coords)
					if $game_map.autotiles[id].empty?()
						$game_map.autotiles.delete(id)
					end
					@water[id].each_key do |texture|
						@water[id][texture].delete(coords)
						if @water[id][texture].empty?()
							@water[id].delete(texture)
						end
					end
					if @water[id].empty?()
						@water.delete(id)
					end
					@water_border[previous_form].delete(coords)
					@water_border.delete(previous_form) if @water_border[previous_form].empty?()
			end
			@floors_infos.delete(coords)
		end
		
		if line != nil and line != false
			coords = line[0]
			tab = (id == nil)  ? :none : [infos[0],id,infos[2]]
			$game_map.deleted_preview_item[coords] = tab
		end
		
		return is_changing
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_sprite_infos
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_sprite_infos(coords)
		return @sprites_infos[coords]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_floor_texture
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_sprite_texture(coords)
		return @sprites_infos[coords] != nil ? @sprites_infos[coords][1] : nil
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_sprite(coords, type, id, line = true)
		is_changing = true
		
		# if a sprite already exists here
		if ((rect = get_sprite_texture(coords)) != nil)
			infos = get_sprite_infos(coords)
			is_changing = (rect != id)
			@sprites[rect].delete(coords)
			if @sprites[rect].empty?()
				@sprites.delete(rect)
				$game_map.texture_sprites[rect][1] -= 1
				$game_map.texture_sprites.delete(rect) if $game_map.texture_sprites[rect][1] == 0
			end
			@sprites_infos.delete(coords)
		end
		
		# Adding the new sprite
		@sprites_infos[coords] = [type,id]
		Wanok::add_hash(@sprites, id, coords, type)
		if !$game_map.texture_sprites.has_key?(id)
			$game_map.texture_sprites[id] = [$game_map.tileset_sprites.crop(id[0], id[1], id[2], id[3]), 1]
		else
			$game_map.texture_sprites[id][1] += 1
		end
		
		return is_changing
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	delete_sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def delete_sprite(coords, line)
		return if $game_map.deleted_preview_item[coords] != nil and line != nil and line != false
		is_changing = false
		
		# if a sprite already exists here
		if ((rect = get_sprite_texture(coords)) != nil)
			infos = get_sprite_infos(coords)
			@sprites[rect].delete(coords)
			if @sprites[rect].empty?()
				@sprites.delete(rect)
				$game_map.texture_sprites[rect][1] -= 1
				$game_map.texture_sprites.delete(rect) if $game_map.texture_sprites[rect][1] == 0
			end
			@sprites_infos.delete(coords)
		end
		
		if line != nil and line != false
			coords = line[0]
			tab = (rect == nil)  ? :none : [infos[0],rect]
			$game_map.deleted_preview_item[coords] = tab
		end
		
		return is_changing
	end
end
