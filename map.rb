# encoding: UTF-8

#--------------------------------------------------------------------------------------------------------------------------------
#	class Map: 	
#	
#	
#--------------------------------------------------------------------------------------------------------------------------------


class Map
	PORTIONS_SIZE = 16
	
	attr_accessor 	:battle,
				:ground,
				:portions
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(map_name, directory, ground = Gosu::Color.new(30, 20, 50))
		@map_name, @directory, @ground = map_name, directory, ground

		r = (@ground.red)/255.0
		g = (@ground.green)/255.0
		b = (@ground.blue)/255.0
		@tile_color = [1.0, 1.0, 1.0, 1]
		@water_color = [r + 0.07, g + 0.07, b + 0.1, 1]
		@water_height = ($tile_size/4).to_i
		@battle = false
		
		# Water anim
		@anim_frame = Array.new
		@anim_tick = Array.new
		@anim_duration = Array.new
		for i in 0...$window.im.frames.size
			@anim_frame[i] = 0
			@anim_tick[i] = Gosu::milliseconds
			@anim_duration[i] = 200
		end
		
		# Events
		@current_portion = [0,0]
		@current_texture = nil
		$game_map.activate_tilesets()
		$game_map.create_textures()
		
		# generate a list to draw autotiles and reliefs
		@list_grid = glGenLists(1)
		@list_floors = Hash.new
		@list_autotiles = Hash.new
		@list_water = Hash.new
		@list_water_border = Hash.new
		@portions = Hash.new
		for i in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
			for j in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
				# Gen lists
				@list_floors[[i,j]] = glGenLists(1)
				@list_autotiles[[i,j]] = Hash.new
				@list_water[[i,j]] = Hash.new
				@list_water_border[[i,j]] = glGenLists(1)
				# Stock portions
				path = @directory + "Maps/" + map_name + "/" + i.to_s + "-" + j.to_s + ".pmap"
				@portions[[i,j]] = (File.file?(path)) ? Wanok::load_datas(path) : nil
			end
		end
		create_list_flat_floor()
		create_list_borders_t_b()
		create_list_borders_l_r()
		create_list_sprites_quad()
		create_list_sprites_quad_empty()
		gen_list()
	end
		
	#--------------------------------------------------------------------------------------------------------------------------------
	#
	#	gen_list : Lists are "Display Lists" used in order to display static 3D objects quickly
	#
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def gen_list
		# grid
		glNewList(@list_grid, GL_COMPILE)
			glDisable(GL_TEXTURE_2D)
			glEnable(GL_BLEND)
			z = 0.25
			color = [100.0, 100.0, 100.0, 0.4]
			for i in 0..($game_map.size[1]+1)
				y = i * $tile_size
				Wanok::draw_line([0.0, z, y], [($game_map.size[0]+1)*$tile_size, z, y], color)
			end
			for i in 0..($game_map.size[0]+1)
				x = i * $tile_size
				Wanok::draw_line([x, z, 0.0], [x, z, ($game_map.size[1]+1)* $tile_size], color)
			end
			glDisable(GL_BLEND)
			glEnable(GL_TEXTURE_2D)
		glEndList
		
		# floors + autotiles
		@list_floors.each_key do |portion|
			gen_list_floors(portion) if @portions[portion] != nil
		end
		@list_autotiles.each_key do |portion|
			gen_list_autotiles(portion) if @portions[portion] != nil
		end
		@list_water.each_key do |portion|
			gen_list_water(portion) if @portions[portion] != nil
		end
		@list_water_border.each_key do |portion|
			gen_list_water_border(portion) if @portions[portion] != nil
		end
	end
	
	def gen_list_floors(portion)
		@list_floors[portion] = glGenLists(1)
		return if @portions[portion] == nil
		
		glNewList(@list_floors[portion], GL_COMPILE)
			@portions[portion].floors.each_key do |rect|
				($game_map.texture_floors[rect][0]).set_active()
				@portions[portion].floors[rect].each do |coords, infos|
					draw_floor_layer(coords)
				end
			end
		glEndList
	end
	
	def gen_list_autotiles(portion)
		@list_autotiles[portion] = Hash.new
		return if @portions[portion] == nil
		
		@portions[portion].autotiles.each_key do |id|
			@list_autotiles[portion][id] = Hash.new
			@portions[portion].autotiles[id].each_key do |texture_id|
				@list_autotiles[portion][id][texture_id] = Array.new
				size = $game_map.texture_autotiles[id][texture_id][0].size
				for i in 0...size
					@list_autotiles[portion][id][texture_id].push(glGenLists(1))
					glNewList(@list_autotiles[portion][id][texture_id][i], GL_COMPILE)
						($game_map.texture_autotiles[id][texture_id][0][i]).set_active()
						@portions[portion].autotiles[id][texture_id].each do |coords|
							draw_floor_layer(coords)
						end
					glEndList
				end
			end
		end
	end
	
	def gen_list_water(portion)
		@list_water[portion] = Hash.new
		return if @portions[portion] == nil
		
		@portions[portion].water.each_key do |id|
			@list_water[portion][id] = Hash.new
			@portions[portion].water[id].each_key do |texture_id|
				@list_water[portion][id][texture_id] = Array.new
				size = $game_map.texture_autotiles[id][texture_id][0].size
				for i in 0...size
					@list_water[portion][id][texture_id].push(glGenLists(1))
					glNewList(@list_water[portion][id][texture_id][i], GL_COMPILE)
						($game_map.texture_autotiles[id][texture_id][0][i]).set_active()
						@portions[portion].water[id][texture_id].each do |coords|
							draw_floor_layer(coords,-@water_height)
						end
					glEndList
				end
			end
		end
	end
	
	def gen_list_water_border(portion)
		@list_water_border[portion] = glGenLists(1)
		return if @portions[portion] == nil
		
		glNewList(@list_water_border[portion], GL_COMPILE)
			@portions[portion].water_border.each_key do |id|
				$window.im.water_textures[id].set_active()
				@portions[portion].water_border[id].each do |coords|
					draw_waterborders(coords)
				end
			end
		glEndList
	end
	
	def create_list_flat_floor(color = [1, 1, 1, 1])
		@list_flat_floor = glGenLists(1)
		vertices = [[0, 0, 0], [1, 0, 0], [1, 0, 1], [0, 0, 1]]
		glNewList(@list_flat_floor, GL_COMPILE)
			Wanok::draw_a_quad_texture([0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [$tile_size, 1.0, $tile_size], vertices[0], vertices[1] , vertices[2] , vertices[3], color)
		glEndList
	end
	
	def create_list_borders_t_b(color = [1, 1, 1, 1])
		@list_borders_t_b = glGenLists(1)
		vertices = [[0, 0, 0], [1, 0, 0], [1, -1, 0], [0, -1, 0]]
		glNewList(@list_borders_t_b, GL_COMPILE)
			Wanok::draw_a_quad_texture([0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [1.0, 1.0, 1.0], vertices[0], vertices[1] , vertices[2] , vertices[3], color)
		glEndList
	end
	
	def create_list_borders_l_r(color = [1, 1, 1, 1])
		@list_borders_l_r = glGenLists(1)
		vertices = [[0, 0, 0], [0, 0, 1], [0, -1, 1], [0, -1, 0]]
		glNewList(@list_borders_l_r, GL_COMPILE)
			Wanok::draw_a_quad_texture([0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [1.0, 1.0, 1.0], vertices[0], vertices[1] , vertices[2] , vertices[3], color)
		glEndList
	end
	
	def create_list_sprites_quad(color = [1, 1, 1, 1])
		@list_sprites_quad = glGenLists(1)
		vertices = [[-0.5, 1, 0], [0.5, 1, 0], [0.5, 0, 0], [-0.5, 0, 0]]
		glNewList(@list_sprites_quad, GL_COMPILE)
			Wanok::draw_a_quad_texture([0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [1.0, 1.0, 1.0], vertices[0], vertices[1] , vertices[2] , vertices[3], color)
		glEndList
	end
	
	def create_list_sprites_quad_empty()
		@list_sprites_quad_empty = glGenLists(1)
		vertices = [[-0.5, 1, 0], [0.5, 1, 0], [0.5, 0, 0], [-0.5, 0, 0]]
		glNewList(@list_sprites_quad_empty, GL_COMPILE)
			Wanok::draw_a_quad_empty([0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [1.0, 1.0, 1.0], vertices[0], vertices[1] , vertices[2] , vertices[3])
		glEndList
	end
	
	def set_lists(i,j,k,l)
		@portions[[i,j]] = @portions[[k,l]]
		@list_floors[[i,j]] = @list_floors[[k,l]]
		@list_autotiles[[i,j]] = @list_autotiles[[k,l]]
		@list_water[[i,j]] = @list_water[[k,l]]
		@list_water_border[[i,j]] = @list_water_border[[k,l]]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw floor layer
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw_floor_layer(coords, offset_z = 0)
		glPushMatrix 
			glTranslate(coords[0] * $tile_size, coords[2] + offset_z, coords[1] * $tile_size)
			glCallList(@list_flat_floor)
		glPopMatrix
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw waterborders
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw_waterborders(coords)
		# top border
		draw_waterborder([coords[0], coords[1], coords[2]], [$tile_size, -@water_height, 1.0]) if !water_at([coords[0], coords[1] - 1, coords[2], coords[3]])
		# bottom border
		draw_waterborder([coords[0], coords[1]+1, coords[2]], [$tile_size, -@water_height, 1.0]) if !water_at([coords[0], coords[1] + 1, coords[2], coords[3]])
		# left border
		draw_waterborder([coords[0], coords[1], coords[2]], [1.0, -@water_height, $tile_size], false) if !water_at([coords[0] - 1, coords[1], coords[2], coords[3]])
		# right border
		draw_waterborder([coords[0]+1, coords[1], coords[2]], [1.0, -@water_height, $tile_size], false) if !water_at([coords[0] + 1, coords[1], coords[2], coords[3]])
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw waterborders
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw_waterborder(coords, scale, t_b = true)
		glPushMatrix 
			glTranslate(coords[0] * $tile_size, coords[2] - @water_height, coords[1] * $tile_size)
			glScale(scale[0], scale[1], scale[2])
			if t_b
				glCallList(@list_borders_t_b)
			else
				glCallList(@list_borders_l_r)
			end
		glPopMatrix
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	water_at?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def water_at(coords)
		co = Wanok::get_portion(coords)
		if co != nil
			portion = @portions[co]
			if portion != nil
				infos = portion.get_floor_infos(coords)
				if infos != nil
					return infos[0] == "water"
				end
			end
		end
		return false
		return true
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw_sprite(type, coords, length, height, position, orientation, color = [1, 1, 1, 1], transparent = [0.0, 1.0, 1.0, 0.0])
		x = (coords[0] * $tile_size) + ($tile_size/2)
		z = (coords[1] * $tile_size) + ($tile_size/2)
		y = coords[2]
		
		angle = type == "sprite_cam" ? $window.camera.horizontal_angle : -90.0
		angle += orientation if type != "sprite_cam"
		
		case type 
			# haut
			when "sprite_cam", "sprite_fix", "double_sprite", "quadra_sprite", "sprite_wall"
				ecart = 0
				ecart += 1 if type == "sprite_wall"
				if position == 1
					case orientation
						when 0
							z = (coords[1]+1) * $tile_size - ecart
						when 90
							x = coords[0] * $tile_size + ecart
						when 180
							z = coords[1] * $tile_size + ecart
						when 270
							x = (coords[0]+1) * $tile_size - ecart
					end
				end
				draw_a_sprite(x, y, z, [-90.0 - angle, 0, 1, 0], length, height)
				draw_a_sprite(x, y, z, [angle, 0, 1, 0], length, height) if type == "double_sprite" or type == "quadra_sprite"
				if type == "quadra_sprite"
					draw_a_sprite(x, y, z, [angle + 45, 0, 1, 0], length, height)
					draw_a_sprite(x, y, z, [angle - 45, 0, 1, 0], length, height)
				end
			# sol
			when "sprite_floor"
				glPushMatrix 
					glTranslate(coords[0] * $tile_size, coords[2]+0.015, coords[1] * $tile_size)
					glScale(length/$tile_size, 1.0, height/$tile_size)
					glCallList(@list_flat_floor)
				glPopMatrix
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw_a_sprite
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw_a_sprite(x, y, z, rotation, length, height)
		if $window.textures
			glPushMatrix 
				glTranslate(x,y,z)
				glRotate(rotation[0], rotation[1], rotation[2], rotation[3])
				glScale(length, height, 1.0)
				glCallList(@list_sprites_quad)
			glPopMatrix
		else
			glPushMatrix 
				glTranslate(x,y,z)
				glRotate(rotation[0], rotation[1], rotation[2], rotation[3])
				glScale(length, height, 1.0)
				glColor3ub(Wanok::get_color()[0],Wanok::get_color()[1],Wanok::get_color()[2])
				glCallList(@list_sprites_quad_empty)
			glPopMatrix
		end
	end

	def draw_grid()
		glPushMatrix 
			glTranslate(0.0,Wanok::pixel_height($window.interface.hud.height),0.0)
			glCallList(@list_grid)
		glPopMatrix
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_portion
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_portion
		position = $window.hero.position
		return [(position.x/$tile_size/16).to_i, (position.y/$tile_size/16).to_i]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_portion
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_portion(previous_portion)
		portions = []
		# If cursor going to right side
		if (@current_portion[0] > previous_portion[0])
			for j in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
				remove_portion([-Wanok::PORTION_RADIUS,j])
				for i in -Wanok::PORTION_RADIUS...Wanok::PORTION_RADIUS
					set_lists(i,j,i+1,j)
				end
				update_portion([Wanok::PORTION_RADIUS,j])
				portions.push([Wanok::PORTION_RADIUS,j])
			end
		elsif (@current_portion[0] < previous_portion[0])
			for j in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
				remove_portion([Wanok::PORTION_RADIUS,j])
				for i in (Wanok::PORTION_RADIUS).downto(-Wanok::PORTION_RADIUS+1)
					set_lists(i,j,i-1,j)
				end
				update_portion([-Wanok::PORTION_RADIUS,j])
				portions.push([-Wanok::PORTION_RADIUS,j])
			end
		end
		
		# y
		if (@current_portion[1] > previous_portion[1])
			for i in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
				remove_portion([i,-Wanok::PORTION_RADIUS])
				for j in -Wanok::PORTION_RADIUS...Wanok::PORTION_RADIUS
					set_lists(i,j,i,j+1)
				end
				update_portion([i,Wanok::PORTION_RADIUS])
				portions.push([i,Wanok::PORTION_RADIUS])
			end
		elsif (@current_portion[1] < previous_portion[1])
			for i in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
				remove_portion([i,Wanok::PORTION_RADIUS])
				for j in (Wanok::PORTION_RADIUS).downto(-Wanok::PORTION_RADIUS+1)
					set_lists(i,j,i,j-1)
				end
				update_portion([i,-Wanok::PORTION_RADIUS])
				portions.push([i,-Wanok::PORTION_RADIUS])
			end
		end
		
		update_portions(portions)
	end
	
	def remove_portion(tab)
		if @portions[tab] != nil
			@portions[tab].autotiles.each_key do |id|
				@portions[tab].autotiles[id].each_key do |texture|
					@portions[tab].autotiles[id][texture].each do |coords|
						$game_map.autotiles[id].remove(coords, false)
					end
				end
			end
		end
	end
	
	def update_portion(tab)
		path = @directory + "Maps/" + @map_name + "/temporalSave/" + (@current_portion[0]+tab[0]).to_s + "-" + (@current_portion[1]+tab[1]).to_s + ".pmap"
		@portions[tab] = (File.file?(path)) ? Wanok::load_datas(path) : nil
		if @portions[tab] != nil
			@portions[tab].autotiles.each_key do |id|
				@portions[tab].autotiles[id].each_key do |texture|
					@portions[tab].autotiles[id][texture].each do |coords|
						$game_map.autotiles[id].add(coords, false)
					end
				end
			end
		end
	end
	
	def update_portions(portions)
		portions.each do |portion|
			if @portions[portion] != nil
				tab = Marshal::load(Marshal.dump(@portions[portion].autotiles))
				tab.each_key do |id|
					tab[id].each_key do |texture|
						tab[id][texture].each do |coords|
							$game_map.autotiles[id].tiles[coords].update()
						end
					end
				end
			end
			gen_list_floors(portion)
			gen_list_autotiles(portion)
			gen_list_water(portion)
			gen_list_water_border(portion)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update()
		# water frame update
		for i in 0...$window.im.frames.size
			size = $window.im.frames[i]
			if size > 1
				if Gosu::milliseconds - @anim_tick[i] >= @anim_duration[i]
					@anim_frame[i] += 1
					@anim_tick[i] = Gosu::milliseconds
					@anim_frame[i] = 0 if @anim_frame[i] >= size
				end
			end
		end

		previous_portion = @current_portion
		@current_portion = get_portion()
		
		if (@current_portion != previous_portion)
			set_portion(previous_portion)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw(screen = false)
		if $window.textures
			updated_frames = Array.new
			for i in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
				for j in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
					if @portions[[i,j]] != nil
						# Floors
						glCallList(@list_floors[[i,j]])
						@portions[[i,j]].autotiles.each_key do |id|
							@portions[[i,j]].autotiles[id].each_key do |texture_id|
								glCallList(@list_autotiles[[i,j]][id][texture_id][@anim_frame[id]])
							end
						end
						@portions[[i,j]].water.each_key do |id|
							@portions[[i,j]].water[id].each_key do |texture_id|
								glCallList(@list_water[[i,j]][id][texture_id][@anim_frame[id]])
							end
						end
						glCallList(@list_water_border[[i,j]])
						
						# Sprites
						@portions[[i,j]].sprites.each_key do |rect|
							texture =  $game_map.texture_sprites[rect][0]
							texture.set_active()
							length = texture.width()
							height = texture.height()
							@portions[[i,j]].sprites[rect].each do |coords,type|
								draw_sprite(type,coords,length,height,0,0)
							end
						end
					end
				end
			end

			#~ # EDITOR OPTIONS
			if !screen and $window.interface.hud.display_grill
				draw_grid()
			end
		else
			for i in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
				for j in -Wanok::PORTION_RADIUS..Wanok::PORTION_RADIUS
					if @portions[[i,j]] != nil
						@portions[[i,j]].sprites.each_key do |rect|
							@portions[[i,j]].sprites[rect].each do |coords,type|
								Wanok::next_color("sprite", coords)
								draw_sprite(type,coords,32,32,32,0,0)
							end
						end
					end
				end
			end
			Wanok::init_colors()
		end
	end
end
