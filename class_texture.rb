require 'chunky_png'

class Texture
	
	attr_reader :transparency, :image, :array
	def initialize(filename, flip = false)
		@image = filename.is_a?(ChunkyPNG::Image) ? filename : ChunkyPNG::Image.from_file(filename)
		@width, @height, @texture_id = @image.width, @image.height, glGenTextures(1)
		@image.flip_horizontally! if flip
		@transparency = !@image.palette.opaque?
		glBindTexture(GL_TEXTURE_2D, @texture_id[0])
		@array = []
		if @transparency
			@array = @image.to_rgba_stream.each_byte.to_a
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, @image.width, @image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, @array)
		else
			@array = @image.to_rgb_stream.each_byte.to_a
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, @image.width, @image.height, 0, GL_RGB, GL_UNSIGNED_BYTE, @array)
		end
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)	
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
	end
	
	def width; @width; end
	def height; @height; end
	
	def set_active()
		glBindTexture(GL_TEXTURE_2D, @texture_id[0])
	end
	
	def update_image_stream()
		@image = ChunkyPNG::Canvas::from_rgb_stream(@image.width, @image.height, @array.join)
	end
	
	def crop(x, y, widht, height)
		texture = Texture.new(@image.crop(x, y, widht, height), true)
		return texture
	end
	
	def self.compose_autotile(id,texture1,texture2,texture3,texture4)
		return $game_map.autotiles[id].get_texture(texture1,texture2,texture3,texture4)
	end
	
	def self.load_tiles(filename, tile_width, tile_height)
		global_image = filename.is_a?(ChunkyPNG::Image) ? filename : ChunkyPNG::Image.from_file(filename)
		images = Array.new
		for y in 0...global_image.height / tile_height
			for x in 0...global_image.width / tile_width
				images.push(Texture.new(global_image.crop(x * tile_width, y * tile_height, tile_width, tile_height), true))
			end
		end
		return images
	end
	
	def self.chunky_load_tiles(filename, tile_width, tile_height)
		return nil if filename == nil
		global_image = filename.is_a?(ChunkyPNG::Image) ? filename : ChunkyPNG::Image.from_file(filename)
		images = Array.new
		for y in 0...global_image.height / tile_height
			for x in 0...global_image.width / tile_width
				images.push(global_image.crop(x * tile_width, y * tile_height, tile_width, tile_height))
			end
		end
		return images
	end
	
	def get_id
                return @texture_id[0]
        end
end