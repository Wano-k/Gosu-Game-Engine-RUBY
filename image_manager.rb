# encoding: UTF-8

class Image_manager
	
	attr_reader :battle,
			:facesets,
			:icons,
			:others_hud,
			:arrow_down,
			:arrow_up,
			:corner,
			:border,
			:corner_selection,
			:border_selection,
			:line,
			:title,
			:autotiles_textures,
			:autotiles_hud,
			:battle_textures,
			:characters,
			:characters_hud,
			:editor,
			:selection_tileset,
			:editor_hud,
			:editor_floors_hud,
			:editor_sprites_hud,
			:others_textures,
			:tilesets_hud,
			:tilesets_textures,
			:floors_hud,
			:floors_textures,
			:relief,
			:relief_hud,
			:object3D_textures,
			:object3D_hud,
			:object3D_min,
			:object3D_models,
			:praticable_textures,
			:praticable_hud,
			:editor_paint_hud,
			:editor_slopes_hud,
			:editor_relief_hud,
			:editor_paint_hud,
			:water_textures,
			:water_hud,
			:id_water_autotiles,
			:frames
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(directory)
		@battle = Hash.new
		Dir.entries(directory + "/Pictures/HUD/Battle").each {|img| @battle[img[0..img.size-5]] = load_image(directory + "/Pictures/HUD/Battle/" + img) if img.include?(".png")}
		@facesets = []
		Dir.entries(directory + "/Pictures/HUD/Facesets").each {|img| @facesets.push(load_image(directory + "/Pictures/HUD/Facesets/" + img)) if img.include?(".png")}
		@icons = Hash.new
		Dir.entries(directory + "/Pictures/HUD/Icons").each {|img| @icons[img[0..img.size-5]] = load_image(directory + "/Pictures/HUD/Icons/" + img) if img.include?(".png")}
		@others_hud = Hash.new
		Dir.entries(directory + "/Pictures/HUD/Others").each {|img| @others_hud[img[0..img.size-5]] = load_image(directory + "/Pictures/HUD/Others/" + img) if img.include?(".png")}
		arrow = Gosu::Image.load_tiles($window, directory + "/Pictures/HUD/System/arrows.png", 10, 6, true)
		@arrow_down = arrow[0]
		@arrow_up = arrow[1]
		border_size = 8
		dif_border = 3
		@corner = Gosu::Image.new($window, directory + "/Pictures/HUD/System/syst.png", true, 0, 0, border_size, border_size)
		@border = Gosu::Image.new($window, directory + "/Pictures/HUD/System/syst.png", true, 0, border_size, 1, dif_border)
		@corner_selection = Gosu::Image.new($window, "Datas/editor_cursor.png", true, 0, 0, 4, 4)
		@border_selection = Gosu::Image.new($window, "Datas/editor_cursor.png", true, 4, 0, 1, 4)
		@line = Gosu::Image.new($window, directory + "/Pictures/HUD/System/syst.png", true, 0, 8, 1, 6)
		@title = Hash.new
		Dir.entries(directory + "/Pictures/HUD/Title").each {|img| @title[img[0..img.size-5]] = load_image(directory + "/Pictures/HUD/Title/" + img) if img.include?(".png")}
		@autotiles_textures, @autotiles_hud = [], []
		@id_water_autotiles = 0
		@frames = Array.new
		i = 0
		Dir.entries(directory + "/Pictures/Textures2D/Autotiles").each do |file| 
			if file.include?(".png")
				img = load_image(directory + "/Pictures/Textures2D/Autotiles/" + file)
				width = img.width
				height = img.height
				nb_frame = (width / ($tile_size*2)).to_i
				@frames.push(nb_frame)
				image = Texture.chunky_load_tiles(directory + "/Pictures/Textures2D/Autotiles/" + file, ($tile_size*2).to_i, ($tile_size*3).to_i)
				@autotiles_textures[i] = []
				for j in 0...nb_frame
					@autotiles_textures[i].push(Texture.chunky_load_tiles(image[j], ($tile_size/2).to_i, ($tile_size/2).to_i))
				end
				@autotiles_hud.push(load_image(directory + "/Pictures/Textures2D/Autotiles/" + file))
				@id_water_autotiles += 1
				i += 1
			end
		end
		@battle_textures = Hash.new
		Dir.entries(directory + "/Pictures/Textures2D/Battle").each {|img| @battle_textures[img[0..img.size-5]] = load_texture(directory + "/Pictures/Textures2D/Battle/" + img) if img.include?(".png")}
		@characters, @characters_hud  = Hash.new, Hash.new
		Dir.entries(directory + "/Pictures/Textures2D/Characters").each do |img| 
			if img.include?(".png")
				@characters[img[0..img.size-5]] = Texture::load_tiles(directory + "/Pictures/Textures2D/Characters/" + img, 64, 64)
				@characters_hud[img[0..img.size-5]] = Gosu::Image.load_tiles(window, directory + "/Pictures/Textures2D/Characters/" + img, 64, 64, true)
			end
		end
		@editor = load_texture("Datas/editor_cursor.png")
		@selection_tileset = load_image("Datas/editor_cursor.png")
		@editor_hud = Hash.new
		Dir.entries("Datas/editor_hud").each {|img| @editor_hud[img[0..img.size-5]] = load_image("Datas/editor_hud/" + img) if img.include?(".png")}
		@editor_floors_hud = []
		Dir.entries("Datas/editor_hud/Floors").each {|img| @editor_floors_hud.push(load_image("Datas/editor_hud/Floors/" + img)) if img.include?(".png")}
		@editor_sprites_hud = []
		Dir.entries("Datas/editor_hud/Sprites").each {|img| @editor_sprites_hud.push(load_image("Datas/editor_hud/Sprites/" + img)) if img.include?(".png")}
		@tilesets_hud, @tilesets_textures = Hash.new, Hash.new
		Dir.entries(directory + "/Pictures/Textures2D/Tilesets").each do |img| 
			if img.include?(".png")
				@tilesets_hud[img[0..img.size-5]] = load_image(directory + "/Pictures/Textures2D/Tilesets/" + img)
				@tilesets_textures[img[0..img.size-5]] = load_texture(directory + "/Pictures/Textures2D/Tilesets/" + img)
			end
		end
		@floors_hud, @floors_textures = Hash.new, Hash.new
		Dir.entries(directory + "/Pictures/Textures2D/Floors").each do |img| 
			if img.include?(".png")
				@floors_hud[img[0..img.size-5]] = load_image(directory + "/Pictures/Textures2D/Floors/" + img)
				@floors_textures[img[0..img.size-5]] = load_texture(directory + "/Pictures/Textures2D/Floors/" + img)
			end
		end
		@others_textures = Hash.new
		Dir.entries(directory + "/Pictures/Textures2D/Others").each {|img| @others_textures[img[0..img.size-5]] = load_texture(directory + "/Pictures/Textures2D/Others/" + img) if img.include?(".png")}
		@relief, @relief_hud = [], []
		Dir.entries(directory + "/Pictures/Textures2D/Relief").each do |file| 
			if file.include?(".png")
				@relief.push(Texture.load_tiles(directory + "/Pictures/Textures2D/Relief/" + file, $tile_size.to_i, $tile_size.to_i))
				@relief_hud.push(load_image(directory + "/Pictures/Textures2D/Relief/" + file))
			end
		end
		@object3D_textures, @object3D_hud, @object3D_min, @object3D_models = [], [], [], []
		i = -1
		j = 0
		Dir.entries(directory + "/3Dobjects").each do |file| 
			if file.include?(".png")
				if file.include?("min")
					j = 0
					i += 1
					@object3D_textures[i] = []
					@object3D_hud[i] = []
					@object3D_min[i] = load_image(directory + "/3Dobjects/" + file)
				else
					@object3D_textures[i][j] = GLTexture.new($window, directory + "/3Dobjects/" + file)
					@object3D_hud[i][j] = load_image(directory + "/3Dobjects/" + file)
					j += 1
				end
			elsif file.include?(".obj")
				@object3D_models.push(ObjModel.new(directory + "/3Dobjects/" + file))
			end
		end
		@object3D_hud[0] = [] if @object3D_hud[0] == nil
		@praticable_textures, @praticable_hud = [], []
		Dir.entries("Datas/editor_hud/Praticable").each do |file| 
			if file.include?(".png")
				@praticable_textures.push(load_texture("Datas/editor_hud/Praticable/" + file))
				@praticable_hud.push(load_image("Datas/editor_hud/Praticable/" + file))
			end
		end
		@editor_slopes_hud = []
		Dir.entries("Datas/editor_hud/Slopes").each {|img| @editor_slopes_hud.push(load_image("Datas/editor_hud/Slopes/" + img)) if img.include?(".png")}
		@editor_relief_hud = []
		Dir.entries("Datas/editor_hud/Relief").each {|img| @editor_relief_hud.push(load_image("Datas/editor_hud/Relief/" + img)) if img.include?(".png")}
		@editor_paint_hud = []
		Dir.entries("Datas/editor_hud/Paint").each {|img| @editor_paint_hud.push(load_image("Datas/editor_hud/Paint/" + img)) if img.include?(".png")}
		@water_textures, @water_hud = Array.new, Hash.new
		Dir.entries(directory + "/Pictures/Textures2D/Water/").each do |dir| 
			next if (dir == "." or dir == "..")
			@water_hud[dir] = []
			i = 0
			Dir.entries(directory + "/Pictures/Textures2D/Water/" + dir).each do |file| 
				if file.include?(".png")
					if dir == "Border"
						@water_textures.push(load_texture(directory + "/Pictures/Textures2D/Water/" + dir + "/" + file))
					elsif dir == "Foam"
						img = load_image(directory + "/Pictures/Textures2D/Water/" + dir + "/" + file)
						width = img.width
						height = img.height
						nb_frame = (width / ($tile_size*2)).to_i
						@frames.push(nb_frame)
						image = Texture.chunky_load_tiles(directory + "/Pictures/Textures2D/Water/" + dir + "/" + file, ($tile_size*2).to_i, ($tile_size*3).to_i)
						@autotiles_textures[@id_water_autotiles + i] = []
						for j in 0...nb_frame
							@autotiles_textures[@id_water_autotiles + i].push(Texture.chunky_load_tiles(image[j], ($tile_size/2).to_i, ($tile_size/2).to_i))
						end
						i += 1
					end
					@water_hud[dir].push(load_image(directory + "/Pictures/Textures2D/Water/" + dir + "/" + file))
				end
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	load_image
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def load_image(chemin)
		return Gosu::Image.new(chemin)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	load_image_lang
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def load_image_lang(chemin)
		tableau = Hash.new
		$game_langs.each {|langue|  tableau[langue] = load_image(chemin[0,chemin.size-4] + "_" + langue + ".png")}
		return tableau
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	load_image
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def load_texture(chemin, flip = false)
		return Texture.new(chemin, flip)
	end
	
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	name_image
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.name_image(name)
		if (name == String_lang::get({"fr" => "Aucun(e)", "eng" => "None"}))
			return :none
		else
			return name[2...name.size]
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	text_image
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.text_image(name)
		text = name[$lang]
		if (text == :none)
			return String_lang::get({"fr" => "Aucun(e)", "eng" => "None"})
		else
			end_lang = "_" + $lang
			text = text[0...text.size-end_lang.size] if (text.end_with?(end_lang))
			return "> " + text
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_images
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.get_images(dir, name)
		images = Hash.new
		$game_langs.languages.each do |lang|
			images[lang] = :none
		end

		Dir.entries($directory + dir).each do |file|
			if file.include?(".png")
				file_name = File.basename(file,File.extname(file))
				$game_langs.languages.each do |lang|
					if file_name == name
						images[lang] = file_name
					else
						end_lang = "_" + lang
						if (file_name.end_with?(end_lang))
							file_true_name = file_name[0...file_name.size-end_lang.size]
							images[lang] = file_name if file_true_name == name
						end
					end
				end
			end
		end
		
		return images
	end
end