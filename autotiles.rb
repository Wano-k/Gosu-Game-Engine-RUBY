class Autotile
	
	attr_reader :render, :position
	attr_accessor :tiles
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	NEW
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(autotile, position)
		@autotile, @position = autotile, position
		@tiles = {
			:A => nil,
			:B => nil,
			:C => nil,
			:D => nil
		}
		@render = [nil,nil,nil,nil]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	UPDATE_TABLE
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update_table(symbole,num)
		new = (symbole.to_s + num.to_s).to_sym
		dif = (@tiles[symbole] != new)
		@tiles[symbole] = new
		return dif
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	UPDATE
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update()
		coords = @position
		portion = Wanok::get_portion(coords)
		change = false
		
		# top left
		num = 0
		if !@autotile.tile_on_left?(coords) and !@autotile.tile_on_top?(coords)
			num = 2
		elsif !@autotile.tile_on_top?(coords) and @autotile.tile_on_left?(coords)
			num = 4
		elsif !@autotile.tile_on_left?(coords) and @autotile.tile_on_top?(coords)
			num = 5
		elsif @autotile.tile_on_left?(coords) and @autotile.tile_on_top?(coords) and @autotile.tile_on_top_left?(coords)
			num = 3
		else
			num = 1
		end
		change = (update_table(:A, num) or change)

		# top right
		if !@autotile.tile_on_right?(coords) and !@autotile.tile_on_top?(coords)
			num = 2
		elsif !@autotile.tile_on_top?(coords) and @autotile.tile_on_right?(coords)
			num = 4
		elsif !@autotile.tile_on_right?(coords) and @autotile.tile_on_top?(coords)
			num = 5
		elsif @autotile.tile_on_right?(coords) and @autotile.tile_on_top?(coords) and @autotile.tile_on_top_right?(coords)
			num = 3
		else
			num = 1
		end
		change = (update_table(:B, num) or change)

		# bottom left
		if !@autotile.tile_on_left?(coords) and !@autotile.tile_on_bottom?(coords)
			num = 2
		elsif !@autotile.tile_on_bottom?(coords) and @autotile.tile_on_left?(coords)
			num = 4
		elsif !@autotile.tile_on_left?(coords) and @autotile.tile_on_bottom?(coords)
			num = 5
		elsif @autotile.tile_on_left?(coords) and @autotile.tile_on_bottom?(coords) and @autotile.tile_on_bottom_left?(coords)
			num = 3
		else
			num = 1
		end
		change = (update_table(:C, num) or change)

		# bottom right
		if !@autotile.tile_on_right?(coords) and !@autotile.tile_on_bottom?(coords)
			num = 2
		elsif !@autotile.tile_on_bottom?(coords) and @autotile.tile_on_right?(coords)
			num = 4
		elsif !@autotile.tile_on_right?(coords) and @autotile.tile_on_bottom?(coords)
			num = 5
		elsif @autotile.tile_on_right?(coords) and @autotile.tile_on_bottom?(coords) and @autotile.tile_on_bottom_right?(coords)
			num = 3
		else
			num = 1
		end
		change = (update_table(:D, num) or change)

		if change
			game_map_portion = $window.map.portions[portion]
			type = (@autotile.id >= $window.im.id_water_autotiles) ? "water" : "autotiles"
			if game_map_portion != nil
				if game_map_portion.send(type)[@autotile.id] != nil
					if game_map_portion.send(type)[@autotile.id][@render] != nil
						game_map_portion.send(type)[@autotile.id][@render].delete(coords)
						$game_map.texture_autotiles[@autotile.id][@render][1] -= 1
						game_map_portion.send(type)[@autotile.id].delete(@render) if game_map_portion.send(type)[@autotile.id][@render].empty?()
						game_map_portion.send(type).delete(@autotile.id) if game_map_portion.send(type)[@autotile.id].empty?()
					end	
				end	
				@render = [@autotile.borders[@tiles[:A]],@autotile.borders[@tiles[:B]],@autotile.borders[@tiles[:C]],@autotile.borders[@tiles[:D]]]
				game_map_portion.send(type)[@autotile.id] = Hash.new if !game_map_portion.send(type).has_key?(@autotile.id)
				Wanok::add_array(game_map_portion.send(type)[@autotile.id], @render, coords)
				$game_map.texture_autotiles[@autotile.id] = Hash.new if !$game_map.texture_autotiles.has_key?(@autotile.id)
				if !$game_map.texture_autotiles[@autotile.id].has_key?(@render)
					$game_map.texture_autotiles[@autotile.id][@render] = [Texture::compose_autotile(@autotile.id,@render[0], @render[1], @render[2], @render[3]), 1]
				else
					$game_map.texture_autotiles[@autotile.id][@render][1] += 1
				end
				$game_map.add_portion_update(portion)
			end
		end
	end
end







class Autotiles
	
	attr_accessor :tileset, :tiles, :list, :id, :borders
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	NEW
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(id)
		@id = id
		@tileset = $window.im.autotiles_textures[id]
		
		@borders = {
			:A1 => 2,
			:B1 => 3,
			:C1 => 6,
			:D1 => 7,
			:A2 => 8,
			:B4 => 9,
			:A4 => 10,
			:B2 => 11,
			:C5 => 12,
			:D3 => 13,
			:C3 => 14,
			:D5 => 15,
			:A5 => 16,
			:B3 => 17,
			:A3 => 18,
			:B5 => 19,
			:C2 => 20,
			:D4 => 21,
			:C4 => 22,
			:D2 => 23
		}
		@tiles = Hash.new
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	EMPTY
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def empty?()
		return @tiles.empty?()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	GET TEXTURE
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_texture(texture1,texture2,texture3,texture4)
		res = []
		@tileset.each do |tileset|
			l = $tile_size.to_i
			image = ChunkyPNG::Image.new(l,l)
			image1 = tileset[texture1]
			image2 = tileset[texture2]
			image3 = tileset[texture3]
			image4 = tileset[texture4]
			image.compose!(image1, 0, 0) 
			image.compose!(image2, l/2, 0) 
			image.compose!(image3, 0, l/2) 
			image.compose!(image4, l/2, l/2) 
			image.flip_horizontally!			
			res.push(Texture.new(image))
		end
		
		return res
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	ADD
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add(coords, update=true)
		x, y, z, couche = coords[0], coords[1], coords[2], coords[3]
			
		if !@tiles.has_key?([x, y, z, couche])
			@tiles[[x, y, z, couche]] = Autotile.new(self, [x, y, z, couche])
			if update
				for x2 in (x - 1)..(x + 1)
					for y2 in (y - 1)..(y + 1)
						if @tiles.has_key?([x2, y2, z, couche])
							@tiles[[x2, y2, z, couche]].update()
						end
					end
				end
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	REMOVE
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def remove(coords, update=true)
		x, y, z, couche = coords[0], coords[1], coords[2], coords[3]
		if @tiles.has_key?([x, y, z, couche])
			render = @tiles[coords].render
			$game_map.texture_autotiles[@id][render][1] -= 1 if !update
			@tiles.delete([x, y, z, couche])
			if update
				for x2 in (x - 1)..(x + 1)
					for y2 in (y - 1)..(y + 1)
						if @tiles.has_key?([x2, y2, z, couche])
							@tiles[[x2, y2, z, couche]].update()
						end
					end
				end
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	TILE
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def tile_on_left?(coords)
		return @tiles.has_key?([coords[0] - 1, coords[1], coords[2], coords[3]])
	end

	def tile_on_right?(coords)
		return @tiles.has_key?([coords[0] + 1, coords[1], coords[2], coords[3]])
	end
	
	def tile_on_top?(coords)
		return @tiles.has_key?([coords[0], coords[1] - 1, coords[2], coords[3]])
	end
	
	def tile_on_bottom?(coords)
		return @tiles.has_key?([coords[0], coords[1] + 1, coords[2], coords[3]])
	end
	
	def tile_on_top_left?(coords)
		return @tiles.has_key?([coords[0] - 1, coords[1] - 1, coords[2], coords[3]])
	end

	def tile_on_top_right?(coords)
		return @tiles.has_key?([coords[0] + 1, coords[1] - 1, coords[2], coords[3]])
	end
	
	def tile_on_bottom_left?(coords)
		return @tiles.has_key?([coords[0] - 1, coords[1] + 1, coords[2], coords[3]])
	end

	def tile_on_bottom_right?(coords)
		return @tiles.has_key?([coords[0] + 1, coords[1] + 1, coords[2], coords[3]])
	end
end