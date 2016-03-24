# encoding: UTF-8

class Game_map
	attr_reader 	:map_name,
				:virtual_map_name,
				:tileset,
				:size,
				:tileset_floors,
				:texture_floors,
				:texture_autotiles,
				:texture_sprites,
				:autotiles,
				:tileset_sprites
	attr_accessor	:deleted_preview_item,
				:deleted_preview_rectangle
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(map_name)
		@map_name, @virtual_map_name, @tileset, @size = map_name, map_name, 0, [20,20]
		
		# texture_floors = { id_rect => [texture, occurrence] }
		@texture_floors = Hash.new
		@texture_autotiles = Hash.new
		@texture_sprites = Hash.new
		@autotiles = Hash.new

		@deleted_preview_item = {}
		@deleted_preview_rectangle = {}
		@portions_to_save = []
		@portions_to_update = []
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_portion_save
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_portion_save(portion)
		@portions_to_save.push(portion) if !@portions_to_save.include?(portion)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_portion_update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_portion_update(portion)
		@portions_to_update.push(portion) if !@portions_to_update.include?(portion)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update_portions
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update_portions()
		cursor_x, cursor_y = (($window.hero.position.x + 1) / $tile_size).to_i, (($window.hero.position.y + 1) / $tile_size).to_i

		@portions_to_save.each do |portion|
			x, y = portion[0] + (cursor_x/16), portion[1] + (cursor_y/16)
			if ($window.map.portions[portion] != nil and $window.map.portions[portion].is_empty?()) or $window.map.portions[portion] == nil
				$window.map.portions[portion] = nil
				path = $directory + "Maps/" + @map_name + "/TemporalSave/" + x.to_s + "-" +y.to_s + ".pmap"
				File.delete(path) if (File.file?(path)) 
			else
				Wanok::save_datas($directory + "Maps/" + @map_name + "/TemporalSave/" + x.to_s + "-" +y.to_s + ".pmap", $window.map.portions[portion])
			end
		end
		@portions_to_save = []
		
		@portions_to_update.each do |portion|
			$window.map.gen_list_floors(portion)
			$window.map.gen_list_autotiles(portion)
			$window.map.gen_list_water(portion)
			$window.map.gen_list_water_border(portion)
		end
		
		@portions_to_update = []
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	activate_tilesets
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def activate_tilesets()
		@tileset_floors = $window.im.floors_textures["rtp"]
		@tileset_sprites = $window.im.tilesets_textures["rtp"]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	create_textures
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def create_textures()
		@texture_floors.each_key do |rect|
			@texture_floors[rect][0] = @tileset_floors.crop(rect[0], rect[1], rect[2], rect[3])
		end
		@autotiles.each_key do |id|
			@texture_autotiles[id].each_key do |rect|
				@texture_autotiles[id][rect][0] = Texture::compose_autotile(id,rect[0], rect[1], rect[2], rect[3])
			end
		end
		@texture_sprites.each_key do |rect|
			@texture_sprites[rect][0] = @tileset_sprites.crop(rect[0], rect[1], rect[2], rect[3])
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_datas
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_datas(virtual_map_name, tileset, size)
		@virtual_map_name, @tileset, @size = virtual_map_name, tileset, size
	end
end
