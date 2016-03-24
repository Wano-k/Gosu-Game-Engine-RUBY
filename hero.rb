# encoding: UTF-8

class Hero
	
	attr_accessor :position, :reflect1, :reflect2,:orientation, :orientation_eyes, :angle, :climbing
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize()
		@cursor_editor = $window.im.editor
		@position = Vector3D.new(0.0, 0.0, 0.0) 
		@target = nil
		@velocity = 48 
		@count = 0
		@sous_count = 0
		@keystates = {
			Gosu::KbW => nil,
			Gosu::KbS => nil,
			Gosu::KbA => nil,
			Gosu::KbD => nil
		}
		@sous_count = {
			Gosu::KbW => 0,
			Gosu::KbS => 0,
			Gosu::KbA => 0,
			Gosu::KbD => 0
		}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id) 
		return if $window.button_down?(Gosu::KbLeftControl) and id == Gosu::KbW
		
		@keystates[id] = Gosu::milliseconds 

		if (id == Gosu::KbW or id == Gosu::KbS or id == Gosu::KbA or id == Gosu::KbD) and ((5-@count) != 0)
			if @sous_count[id] > 0
				@sous_count[id] += 1
				@sous_count[id] = @sous_count[id]% (5-@count)
				@count += 1 if @sous_count[id] == 0
				return
			end
			@sous_count[id] += 1
		end

		x, y = ((@position.x + 1) / $tile_size).to_i, ((@position.y + 1) / $tile_size).to_i
		
		if (!$window.interface.block and $window.camera.target_angle == $window.camera.horizontal_angle)
			angle = $window.camera.horizontal_angle
			selection = $window.interface.hud.selection
			shift = $window.button_down_repeat?(Gosu::KbLeftShift)
			if (id == Gosu::KbW)
				x_plus = $tile_size * (Math::cos(angle * Math::PI / 180.0).round)
				y_plus = $tile_size * (Math::sin(angle * Math::PI / 180.0).round)
				@position.y += y_plus if (y > 0 and y_plus < 0) or (y < $game_map.size[1] and y_plus > 0)
				@position.x += x_plus if  y_plus == 0 and ((x > 0 and x_plus < 0) or (x < $game_map.size[0] and x_plus > 0))
				if shift
					selection[3] -=1
					selection[3] -=2 if selection[3] == 0
				end
			elsif (id == Gosu::KbS)
				x_plus = $tile_size * (Math::cos(angle * Math::PI / 180.0).round)
				y_plus = $tile_size * (Math::sin(angle * Math::PI / 180.0).round)
				@position.y -= y_plus if (y < $game_map.size[1] and y_plus < 0) or (y > 0 and y_plus > 0)
				@position.x -= x_plus if y_plus == 0 and ((x < $game_map.size[0] and x_plus < 0) or (x > 0 and x_plus > 0))
				if shift
					selection[3] +=1
					selection[3] +=2 if selection[3] == -1
				end
			elsif (id == Gosu::KbA)
				x_plus = $tile_size * (Math::cos((angle - 90.0) * Math::PI / 180.0).round)
				y_plus = $tile_size * (Math::sin((angle - 90.0) * Math::PI / 180.0).round)
				@position.x += x_plus if (x > 0 and x_plus < 0) or (x < $game_map.size[0] and x_plus > 0)
				@position.y += y_plus if x_plus == 0 and ((y > 0 and y_plus < 0) or (y < $game_map.size[1] and y_plus > 0))
				if shift
					selection[2] -=1
					selection[2] -=2 if selection[2] == 0
				end
			elsif (id == Gosu::KbD)
				x_plus = $tile_size * (Math::cos((angle - 90.0) * Math::PI / 180.0).round)
				y_plus = $tile_size * (Math::sin((angle - 90.0) * Math::PI / 180.0).round)
				@position.x -= x_plus if (x < $game_map.size[0] and x_plus < 0) or (x > 0 and x_plus > 0)
				@position.y -= y_plus if x_plus == 0 and ((y < $game_map.size[1] and y_plus < 0) or (y > 0 and y_plus > 0))
				if shift
					selection[2] +=1
					selection[2] +=2 if selection[2] == -1
				end
			end
			x, y = ((@position.x + 1) / $tile_size).to_i, ((@position.y + 1) / $tile_size).to_i
			#~ $window.interface.hud.selection = [x,y,1,1] if !$window.interface.hud.selected
		end
		$window.interface.hud.text_position = Text.new($window, "[" + x.to_s + ", " + y.to_s + "]", 0, $screen_y - 32, 0, $font_name, $font_size, 2, $screen_x - 20 - 32, :right)
		#~ @window.interface.hud.text_informations = Text.new(@window, @window.map.tiles[[x,y,[0,0],0]], 388, 500)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_up
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_up(id)
		@keystates[id] = nil 
		nb = 0
		nb += 1 if @keystates[Gosu::KbW] != nil 
		nb += 1 if @keystates[Gosu::KbS] != nil 
		nb += 1 if @keystates[Gosu::KbA] != nil
		nb += 1 if @keystates[Gosu::KbD] != nil

		@count = 0 if nb == 0
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	 button_down?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down?(id)
		return $window.button_down?(id)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	keystates_is_empty
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def keystates_is_empty()
		@keystates.each_value do |val|
			return false if val != nil
		end
		return true
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_x
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_x()
		return ((@position.x + 1) / $tile_size).to_i
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_y
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_y()
		return ((@position.y + 1) / $tile_size).to_i
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update
		x, y, z = ((@position.x + 1) / $tile_size).to_i, ((@position.y + 1) / $tile_size).to_i, 1
		if (!$window.interface.block)
			h = $window.interface.hud.height
			@position.z = (h[0]*$tile_size) + h[1]
			@keystates.each do |id, val|
				button_down(id) if (val != nil)
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw
		@cursor_editor.set_active
		Wanok::draw_a_quad_texture([@position.x, @position.z + 0.01, @position.y], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [$tile_size, 1.0, $tile_size], [0, 0.5, 0], [1, 0.5, 0], [1, 0.5, 1], [0, 0.5, 1])
	end
end