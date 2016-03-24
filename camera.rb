# encoding: UTF-8

class Camera
	
	attr_reader :x, :y, :z, :display, :vertical_angle, :target_angle, :t_x, :t_y, :t_z, :moving, :projection_matrix, :view_matrix 
	attr_accessor :targeted, :height, :distance, :horizontal_angle
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(editor = 0, moving = false)
		@editor, @moving = editor, moving
		@x, @y, @z = 0.0, 400.0, 0.0
		@t_x, @t_y, @t_z = 0.0, 0.0, 0.0 
		@horizontal_angle, @vertical_angle = -90.0, 0.0
		@target_angle = -90.0
		@distance = 350.0  # 350 150 int
		@height = 180.0  # 180 30 int
		@fovy = 35.0
		@interieur = false
		@worldmap = false
		@rotate_tick = Gosu::milliseconds
		@rotate_velocity = 180 
		@rotate_steps = 90.0
		@display = :tps 
		@targeted = true
		@orientations = { 
			:south => 0,
			:west => 1,
			:north => 2,
			:east => 3,
			:south_west => 4,
			:south_east => 5,
			:north_west => 6,
			:north_east => 7
		}
		@velocity = 100
		@offset_x, @offset_y = 0, 0
		@new_x, @new_y, @new_z, @new_distance, @new_height = 0, 0, 0, 0, 0
		@time = -1
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down?(id) 
		return $window.button_down?(id)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id) 
		
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_up
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_up(id) 

	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	move
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def move(t_x, t_y, t_z, distance, height, time)
		# if already moved, just draw
		if ((@t_x == t_x and @t_y == t_y and @t_z == t_z and @distance == distance and @height == height) or time == 0)
			@t_x, @t_y, @t_z, @distance, @height = t_x, t_y, t_z, distance, height
			@moving = false
			@time = -1
			return
		end

		# if the move is canceled
		if (@new_x != t_x or @new_y != t_y or @new_z != t_z or @new_distance != distance or @new_height != height)
			@moving = false
			@time = -1
		end
		
		# time
		if (time != 0 and @time == -1)
			@time = time
		end
		@time -= 1 if (@time > 0)
		
		# prepare offset
		if !@moving
			@offset_x, @offset_y, @offset_z, @offset_distance, @offset_height = (t_x - @t_x)/ Float(time), (t_y - @t_y)/ Float(time), (t_z - @t_z)/ Float(time), (distance - @distance)/ Float(time), (height - @height)/ Float(time)
			@new_x, @new_y, @new_z, @new_distance, @new_height = t_x, t_y, t_z, distance, height
			@moving = true
		end
		speed = (@velocity * $window.move_tick) / 1000.0
		offset_x, offset_y, offset_z, offset_distance, offset_height = @offset_x * speed, @offset_y * speed, @offset_z * speed, @offset_distance * speed, @offset_height * speed
		# if end of move
		if ((((t_x - @t_x) >= 0 and (@t_x + (offset_x*2)) >= t_x) or ((t_x - @t_x) < 0 and (@t_x + (offset_x*2)) <= t_x)) and (((t_y - @t_y) >= 0 and (@t_y + (offset_y*2)) >= t_y) or ((t_y - @t_y) < 0 and (@t_y + (offset_y*2)) <= t_y)) and (((t_z - @t_z) >= 0 and (@t_z + (offset_z*2)) >= t_z) or ((t_z - @t_z) < 0 and (@t_z + (offset_z*2)) <= t_z)) and (((distance - @distance) >= 0 and (@distance + (offset_distance*2)) >= distance) or ((distance - @distance) < 0 and (@distance + (offset_distance*2)) <= distance)) and (((height - @height) >= 0 and (@height + (offset_height*2)) >= height) or ((height - @height) < 0 and (@height + (offset_height*2)) <= height)))  or (@time == 0)
			@offset_x, @offset_y, @offset_z, @offset_distance, @offset_height, @t_x, @t_y, @t_z, @distance, @height = 0, 0, 0, 0, 0, t_x, t_y, t_z, distance, height
			@time = -1
			@moving = false
		# if moving, draw
		else 
			@t_x, @t_y, @t_z, @distance, @height = @t_x + offset_x, @t_y + offset_y, @t_z + offset_z, @distance + offset_distance, @height + offset_height
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_angle_h
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_angle_h(i)
		@horizontal_angle += i
		@target_angle += i
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_angle_v
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_angle_v(i)
		@vertical_angle += i
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	change_interieur
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def change_interieur(interieur)
		@interieur = interieur
		@distance = interieur ? 160.0 : 350 
		@height = interieur ? 30.0 : 180
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	change_worldmap
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def change_worldmap(worldmap)
		@worldmap = worldmap
		@distance = worldmap ? 350.0 : 350 
		@height = worldmap ? 240.0 : 180
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update
		if (!$window.map.battle and !$window.interface.block)
			if @target_angle != @horizontal_angle 
				speed = (@rotate_velocity * (Gosu::milliseconds - @rotate_tick)) / 1000.0 
				if @target_angle > @horizontal_angle 
					@horizontal_angle += speed 
					@horizontal_angle = @target_angle if @horizontal_angle > @target_angle  
				elsif @target_angle < @horizontal_angle
					@horizontal_angle -= speed
					@horizontal_angle = @target_angle if @horizontal_angle < @target_angle
				end
			end
			if (@horizontal_angle >= 270.0 or @horizontal_angle <= -450.0)
				@horizontal_angle = -90.0
				@target_angle = -90.0
			end
				
			if @target_angle == @horizontal_angle 
				if (@editor == 0)
					if @horizontal_angle == -90.0 # centre
						$window.hero.orientation_eyes = @window.hero.orientation
					elsif (@horizontal_angle == 180.0 or @horizontal_angle == -180.0) # droite
						nb = (@orientations[$window.hero.orientation] + 1)%4
						$window.hero.orientation_eyes = @orientations.key(nb)
					elsif (@horizontal_angle == 90.0 or @horizontal_angle == -270.0) # haut
						nb = (@orientations[$window.hero.orientation] + 2)%4
						$window.hero.orientation_eyes = @orientations.key(nb)
					elsif (@horizontal_angle == 0.0 or @horizontal_angle == -360.0) # gauche
						nb = (@orientations[$window.hero.orientation] + 3)%4
						$window.hero.orientation_eyes = @orientations.key(nb)
					end
				end
				if button_down?(Gosu::KbLeft) 
					@target_angle -= @rotate_steps 
				elsif button_down?(Gosu::KbRight) 
					@target_angle += @rotate_steps
				end
			end		
		end

		if @targeted
			@t_x = $window.hero.position.x - ($tile_size/2) + @editor
			@t_y = $window.hero.position.y
			@t_z = $window.hero.position.z
		end
		
		@x = @t_x - @distance * Math::cos(@horizontal_angle * Math::PI / 180.0) 
		@y = @t_y - @distance * Math::sin(@horizontal_angle * Math::PI / 180.0)
		@z = @t_z - @distance * Math::sin(@vertical_angle * Math::PI / 180.0) + @height
		
		@rotate_tick = Gosu::milliseconds
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	look
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def look(x = @x, z = @z, y = @y, t_x = @t_x, t_z = @t_z, t_y = @t_y)
		glMatrixMode(GL_PROJECTION) 
		glLoadIdentity
		glScale(1.0,-1.0,1.0) if $window.screen
		gluPerspective(@fovy, $window.width.to_f / $window.height.to_f, 1.0, 20000.0)
		glMatrixMode(GL_MODELVIEW)
		glLoadIdentity
		gluLookAt(x, z, y, t_x, t_z, t_y, 0, 1, 0)
		@projection_matrix = Matrix.columns(glGetFloatv(GL_PROJECTION_MATRIX))
		@view_matrix = Matrix.columns(glGetFloatv(GL_MODELVIEW_MATRIX))
	end
end