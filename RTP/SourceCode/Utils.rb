# encoding: UTF-8
# OLD CLOCKWORK CODE

class Vector3D
	
	attr_accessor :x, :y, :z
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(x, y, z)
		@x, @y, @z = x, y, z
	end
end












class GLTexture
	
        attr_reader :width, :height
	
        #~ # GOSU IMAGE -> OPENGL TEXTURE FIX
        #~ # SOLVES PROBLEM WITH REPETITION / CROPING
	
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	initialize
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
        def initialize(p_win, filename, save_gosu_image = false, alpha = true)
                filename.is_a?(Gosu::Image) ? gosu_image = filename : gosu_image = Gosu::Image.new(p_win, filename, true)
                @width, @height = gosu_image.width, gosu_image.height
                array_of_pixels = gosu_image.to_blob
                @texture_id = glGenTextures(1)
                glBindTexture(GL_TEXTURE_2D, @texture_id[0])
                if alpha
                        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, gosu_image.width, gosu_image.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, array_of_pixels)
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
                else
                        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, gosu_image.width, gosu_image.height, 0, GL_RGB, GL_UNSIGNED_BYTE, array_of_pixels)
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
                        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)                       
                end
                
                if save_gosu_image
                        @gosu_image = gosu_image
                else
                        gosu_image = nil
                end                     
        end
        
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	draw_2d
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
        def draw_2d(x, y, z, zoom = 1, color = Gosu::Color.new(255, 255, 255, 255))
                if @gosu_image != nil
                        @gosu_image.draw(x, y, z, zoom, zoom, color)
                end
        end
 
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	#~ #	get_id
	#~ #--------------------------------------------------------------------------------------------------------------------------------
	
        def get_id
                return @texture_id[0]
        end
end

class ObjModel
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(filename, pivot = [0, 0, 0])
		@v, @vt, @vn = Array.new, Array.new, Array.new
		@pivot = pivot
		v, vt, vn = Array.new, Array.new, Array.new
		File.open(filename).readlines.each do |line|
			if line.include?("v  ")
				ajusted = line.chomp.scanf("v  %f %f %f")
				v << [ajusted[0] - pivot[0], ajusted[1] - pivot[1], ajusted[2] - pivot[2]]
			elsif line.include?("vt ")
				vt << line.chomp.scanf("vt  %f %f %f")
				vt.last[1] = 1.0 - vt.last[1] 
			elsif line.include?("vn ")
				vn << line.chomp.scanf("vn  %f %f %f")
			elsif line.include?("f ")
				t = line.chomp.scanf("f %d/%d/%d %d/%d/%d %d/%d/%d")
				@v += v[t[0] - 1]; @v += v[t[3] - 1]; @v += v[t[6] - 1]
				@vt += vt[t[1] - 1]; @vt += vt[t[4] - 1]; @vt += vt[t[7] - 1]
				@vn += vn[t[2] - 1]; @vn += vn[t[5] - 1]; @vn += vn[t[8] - 1]
			end
		end
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw(position = [0, 0, 0], rot = 0, color = nil)
		glPushMatrix
		glTranslate(position[0], position[1], position[2])
		glRotate(rot, 0, 1, 0)
		glColor3ub(color[0], color[1], color[2]) if color != nil
		glVertexPointer(3, GL_FLOAT, 0, @v)
		glTexCoordPointer(3, GL_FLOAT, 0, @vt)
		glNormalPointer(GL_FLOAT, 0, @vn)
		glDrawArrays(GL_TRIANGLES, 0, @v.size / 3)
		glPopMatrix
	end
end



