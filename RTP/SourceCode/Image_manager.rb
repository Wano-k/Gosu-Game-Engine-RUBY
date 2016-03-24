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
			:line,
			:title,
			:autotiles_textures,
			:battle_textures,
			:characters,
			:others_textures,
			:tilesets_textures,
			:floors_textures,
			:relief,
			:object3D_textures,
			:object3D_models,
			:water_textures
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window)
		@window = window
		@langues = ["fr", "eng"]


		@battle = Hash.new
		Dir.entries("Pictures/HUD/Battle").each {|img| @battle[img[0..img.size-5]] = load_image("Pictures/HUD/Battle/" + img) if img.include?(".png")}
		@facesets = []
		Dir.entries("Pictures/HUD/Facesets").each {|img| @facesets.push(load_image("Pictures/HUD/Facesets/" + img)) if img.include?(".png")}
		@icons = Hash.new
		Dir.entries("Pictures/HUD/Icons").each {|img| @icons[img[0..img.size-5]] = load_image("Pictures/HUD/Icons/" + img) if img.include?(".png")}
		@others_hud = Hash.new
		Dir.entries("Pictures/HUD/Others").each {|img| @others_hud[img[0..img.size-5]] = load_image("Pictures/HUD/Others/" + img) if img.include?(".png")}
		arrow = Gosu::Image.load_tiles("Pictures/HUD/System/arrows.png", 10, 6)
		@arrow_down = arrow[0]
		@arrow_up = arrow[1]
		
		@corner = []
		@border = []
		i = 0
		$game_system.window_skins.each do |window_skin|
			@corner[i] = []
			@border[i] = []
			@corner[i].push(Gosu::Image.new(@window, "Pictures/HUD/WindowSkins/" + window_skin.corner_top_left[0][$lang] + ".png", true, window_skin.corner_top_left[1][0], window_skin.corner_top_left[1][1], window_skin.corner_top_left[1][2], window_skin.corner_top_left[1][3]))
			@border[i].push(Gosu::Image.new(@window, "Pictures/HUD/WindowSkins/" + window_skin.border_top[0][$lang] + ".png", true, window_skin.border_top[1][0], window_skin.border_top[1][1], window_skin.border_top[1][2], window_skin.border_top[1][3]))
			i += 1
		end
		
		@line = Gosu::Image.new(@window, "Pictures/HUD/System/syst.png", true, 0, 8, 1, 6)
		@title = Hash.new
		Dir.entries("Pictures/HUD/Title").each {|img| @title[img[0..img.size-5]] = load_image("Pictures/HUD/Title/" + img) if img.include?(".png")}
		@autotiles_textures, @autotiles_hud = [], []
		Dir.entries("Pictures/Textures2D/Autotiles").each do |img| 
			if img.include?(".png")
				@autotiles_textures.push(Texture.load_tiles("Pictures/Textures2D/Autotiles/" + img, ($tile_size/2).to_i, ($tile_size/2).to_i))
				@autotiles_hud.push(load_image("Pictures/Textures2D/Autotiles/" + img))
			end
		end
		@battle_textures = Hash.new
		Dir.entries("Pictures/Textures2D/Battle").each {|img| @battle_textures[img[0..img.size-5]] = load_texture("Pictures/Textures2D/Battle/" + img) if img.include?(".png")}
		@characters, @characters_hud  = Hash.new, Hash.new
		Dir.entries("Pictures/Textures2D/Characters").each do |img| 
			if img.include?(".png")
				@characters[img[0..img.size-5]] = Texture::load_tiles("Pictures/Textures2D/Characters/" + img, 64, 64)
				@characters_hud[img[0..img.size-5]] = Gosu::Image.load_tiles(window, "Pictures/Textures2D/Characters/" + img, 64, 64, true)
			end
		end
		@tilesets_textures = Hash.new
		Dir.entries("Pictures/Textures2D/Tilesets").each do |img| 
			if img.include?(".png")
				@tilesets_textures[img[0..img.size-5]] = load_texture("Pictures/Textures2D/Tilesets/" + img)
			end
		end
		@floors_textures = Hash.new
		Dir.entries("Pictures/Textures2D/Floors").each do |img| 
			if img.include?(".png")
				@floors_textures[img[0..img.size-5]] = load_texture("Pictures/Textures2D/Floors/" + img)
			end
		end
		@others_textures = Hash.new
		Dir.entries("Pictures/Textures2D/Others").each {|img| @others_textures[img[0..img.size-5]] = load_texture("Pictures/Textures2D/Others/" + img) if img.include?(".png")}
		@relief = []
		Dir.entries("Pictures/Textures2D/Relief").each do |file| 
			if file.include?(".png")
				@relief.push(Texture.load_tiles("Pictures/Textures2D/Relief/" + file, $tile_size.to_i, $tile_size.to_i))
			end
		end
		@object3D_textures, @object3D_models = [], []
		i = -1
		j = 0
		Dir.entries("3Dobjects").each do |file| 
			if file.include?(".png")
				if file.include?("min")
					j = 0
					i += 1
					@object3D_textures[i] = []
				else
					@object3D_textures[i][j] = GLTexture.new(@window, "3Dobjects/" + file)
					j += 1
				end
			elsif file.include?(".obj")
				@object3D_models.push(ObjModel.new("3Dobjects/" + file))
			end
		end
		@water_textures = Hash.new
		Dir.entries("Pictures/Textures2D/Water/").each do |dir| 
			next if (dir == "." or dir == "..")
			@water_textures[dir] = []
			Dir.entries("Pictures/Textures2D/Water/" + dir).each do |file| 
				if file.include?(".png")
					if dir == "Border"
						@water_textures[dir].push(load_texture("Pictures/Textures2D/Water/" + dir + "/" + file))
					elsif dir == "Tile"
						width = load_image("Pictures/Textures2D/Water/" + dir + "/" + file).width
						file_num = file[0..file.size-5].to_i
						@water_textures[dir][file_num] = []
						@water_textures[dir][file_num].push(Texture.load_tiles("Pictures/Textures2D/Water/" + dir + "/" + file, (width/4).to_i, $tile_size.to_i))
					elsif dir == "Foam"
						img = load_image("Pictures/Textures2D/Water/" + dir + "/" + file)
						width = img.width
						height = img.height
						image = Texture.chunky_load_tiles("Pictures/Textures2D/Water/" + dir + "/" + file, (width/4).to_i, height)
						file_num = file[0..file.size-5].to_i
						@water_textures[dir][file_num] = []
						for i in 0..3
							@water_textures[dir][file_num].push(Texture.load_tiles(image[i], ($tile_size/2).to_i, ($tile_size/2).to_i))
						end
					end
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
		@langues.each {|langue|  tableau[langue] = load_image(chemin[0,chemin.size-4] + "_" + langue + ".png")}
		return tableau
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	load_image
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def load_texture(chemin, flip = false)
		return Texture.new(chemin, flip)
	end
end