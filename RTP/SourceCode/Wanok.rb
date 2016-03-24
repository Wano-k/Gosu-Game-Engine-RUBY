# encoding: UTF-8

#--------------------------------------------------------------------------------------------------------------------------------
#
#	[MODULE] Wanok
#
#	Some methods.
#
#--------------------------------------------------------------------------------------------------------------------------------

module Wanok
	@@color_rgb = [0,0,1]
	@@color_hexa = 0x000001
	PORTION_RADIUS = 3
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_color
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.get_color()
		return @@color_rgb
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	save_datas
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.save_datas(filename, object)
		File.open(filename, 'w+b') do |f|  
			Marshal.dump(object, f)  
		end 
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	load_datas
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.load_datas(filename)
		File.open(filename, 'r+b') do |f|  
			var = Marshal.load(f)  
		end 
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_array
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.add_array(tab, key, coords)
		tab[key] = Array.new if !tab.has_key?(key)
		tab[key].push(coords)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_hash
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.add_hash(tab, key, key2, val)
		tab[key] = Hash.new if !tab.has_key?(key)
		tab[key][key2] = val
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	pixel_height
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.pixel_height(tab)
		return ((tab[0]*$tile_size.to_i) + tab[1])
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_portion
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.get_portion(coords)
		x, y = coords[0], coords[1]
		cursor_x, cursor_y = $window.hero.get_x(), $window.hero.get_y()
		portion_x, portion_y = (x/16) - (cursor_x/16), (y/16) - (cursor_y/16)
		
		return [portion_x, portion_y]
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_mouse_color
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.get_mouse_color()
		return glReadPixels($window.mouse_x, $window.height - $window.mouse_y, 1, 1, GL_RGB, GL_UNSIGNED_BYTE).unpack("C*")
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	init_colors
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.init_colors()
		@@color_rgb = [0,0,1]
		@@color_hexa = 0x000001
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	next_color
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.next_color(obj, coords)
		if @@color_hexa <= 0xFFFFFF
			@@color_rgb[0] = @@color_hexa >> 16
			@@color_rgb[1] = (@@color_hexa >> 8) - (@@color_rgb[0] * 256)
			@@color_rgb[2] = @@color_hexa - (@@color_rgb[0] * (256**2)) - (@@color_rgb[1] * 256)
		
			@@color_hexa += 1
			$window.colors[[ @@color_rgb[0].to_i,  @@color_rgb[1].to_i, @@color_rgb[2].to_i]] = [obj, coords]
		else
			raise("No more colors!")
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#
	#
	#	3D FUNCTIONS
	#
	#
	#--------------------------------------------------------------------------------------------------------------------------------
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw_a_quad
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.draw_a_quad_texture(translate, rotate_1 = [0, 0, 0, 0], rotate_2 = [0, 0, 0, 0], rotate_3 = [0, 0, 0, 0], scale = [$tile_size, 1.0, $tile_size], v1 = [0, 0, 0], v2 = [1, 0, 0], v3 = [1, 0, 1], v4 = [0, 0, 1], color = [1, 1, 1, 1], translate2 = nil, color2 = nil, color3 = nil, color4 = nil, text = [0.0, 1.0, 1.0, 0.0])
		left, right, top, bottom = text[0], text[1], text[2], text[3]
		glEnable(GL_BLEND)
		
		glPushMatrix 
			glTranslate(translate[0], translate[1], translate[2]) if translate != nil
			glRotate(rotate_1[0], rotate_1[1], rotate_1[2], rotate_1[3])
			glRotate(rotate_2[0], rotate_2[1], rotate_2[2], rotate_2[3])
			glRotate(rotate_3[0], rotate_3[1], rotate_3[2], rotate_3[3])
			if translate2 != nil
				glTranslate(translate2[0], translate2[1], translate2[2] )
			end
			glScale(scale[0], scale[1], scale[2])

			begin
				glBegin(GL_QUADS)
					glColor4f(color[0], color[1], color[2], color[3])
					glTexCoord2d(left, top); glVertex3f(v1[0], v1[1]*top, v1[2])
					glColor4f(color2[0], color2[1], color2[2], color2[3]) if color2 != nil
					glTexCoord2d(right, top); glVertex3f(v2[0], v2[1]*top, v2[2])
					glColor4f(color3[0], color3[1], color3[2], color3[3]) if color3 != nil
					glTexCoord2d(right, bottom); glVertex3f(v3[0], v3[1], v3[2])
					glColor4f(color4[0], color4[1], color4[2], color4[3]) if color4 != nil
					glTexCoord2d(left, bottom); glVertex3f(v4[0], v4[1], v4[2])
				glEnd
			rescue 

			end
		glPopMatrix
		glDisable(GL_BLEND)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw_a_quad_empty
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.draw_a_quad_empty(translate, rotate_1 = [0, 0, 0, 0], rotate_2 = [0, 0, 0, 0], rotate_3 = [0, 0, 0, 0], scale = [$tile_size, 1.0, $tile_size], v1 = [0, 0, 0], v2 = [1, 0, 0], v3 = [1, 0, 1], v4 = [0, 0, 1], color = [0.5, 1, 1, 1], translate2 = nil, color2 = nil, color3 = nil, color4 = nil, text = [0.0, 1.0, 1.0, 0.0])
		left, right, top, bottom = text[0], text[1], text[2], text[3]
		glDisable(GL_TEXTURE_2D)
		glPushMatrix 
			glTranslate(translate[0], translate[1], translate[2]) if translate != nil
			glRotate(rotate_1[0], rotate_1[1], rotate_1[2], rotate_1[3])
			glRotate(rotate_2[0], rotate_2[1], rotate_2[2], rotate_2[3])
			glRotate(rotate_3[0], rotate_3[1], rotate_3[2], rotate_3[3])
			if translate2 != nil
				glTranslate(translate2[0], translate2[1], translate2[2] )
			end
			glScale(scale[0], scale[1], scale[2])

			begin
				glBegin(GL_QUADS)
					glVertex3f(v1[0], v1[1]*top, v1[2])
					glVertex3f(v2[0], v2[1]*top, v2[2])
					glVertex3f(v3[0], v3[1], v3[2])
					glVertex3f(v4[0], v4[1], v4[2])
				glEnd
			rescue 

			end
		glPopMatrix
		glEnable(GL_TEXTURE_2D)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw_line
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.draw_line(point1, point2, color)
		glPushMatrix
			glColor4f(color[0], color[1], color[2], color[3])
			begin
				glBegin(GL_LINES)
					glVertex3f(point1[0], point1[1], point1[2])
					glVertex3f(point2[0], point2[1], point2[2])
				glEnd
			rescue
			
			end
		glPopMatrix
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_mouse_pos
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.get_mouse_pos()
		return Vector2D.new($window.mouse_x, $window.mouse_y)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	transform_to_normalized_coords
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.transform_to_normalized_coords(mouse)
		x = (2.0 * mouse.x) / $window.width - 1.0
		y = 1.0 - (2.0 * mouse.y) / $window.height
		z = 1.0
		return Vector3D.new(x, y, z)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	transform_to_homogeneous_clip
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.transform_to_homogeneous_clip(normalized)
		return Vector4D.new(normalized.x, normalized.y, -1.0, 1.0)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	transform_to_eye_coords
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.transform_to_eye_coords(ray_clip, projection_matrix)
		vector = projection_matrix.inverse() * (ray_clip).to_matrix()
		ray_eye = Vector4D.new(vector.element(0,0), vector.element(1,0), vector.element(2,0), vector.element(3,0))
		ray_eye = Vector4D.new(ray_eye.x, ray_eye.y, -1.0, 0.0)
		return ray_eye
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	transform_to_world_coords
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.transform_to_world_coords(ray_eye, view_matrix)
		vector = view_matrix.inverse * (ray_eye).to_matrix()
		ray_world = Vector3D.new(vector.element(0,0), vector.element(1,0), vector.element(2,0))
		ray_world.normalise()
		return ray_world
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_ray_world
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.get_ray_world(projection_matrix, view_matrix)
		return transform_to_world_coords(transform_to_eye_coords(transform_to_homogeneous_clip(transform_to_normalized_coords(get_mouse_pos())), projection_matrix), view_matrix)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_point_on_ray
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.get_point_on_ray(ray, distance)
		return Vector3D.new((ray.x * distance)+$window.camera.x, (ray.y * distance)+$window.camera.z, (ray.z * distance)+$window.camera.y)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	take_screenshot
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.take_screenshot(map_name)
		pixels=glReadPixels(0, 0, $window.width, $window.height, GL_RGB,GL_UNSIGNED_BYTE)
		datastream = pixels.to_blob()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	mouse_is_in_area?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.mouse_is_in_area?(point)
		return (point[0] >= 0 and point[1] >=0 and point[0] <= $game_map.size[0] and point[1] <= $game_map.size[1])
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_in_portion?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def self.is_in_portion?(portion_x, portion_y)
		return (portion_x <= PORTION_RADIUS and portion_x >= -PORTION_RADIUS and portion_y <= PORTION_RADIUS and portion_y >= -PORTION_RADIUS)
	end
end