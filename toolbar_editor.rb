# encoding: UTF-8
COLOR_BUTTON_NORMAL = Gosu::Color.new(255, 63, 63, 63)
COLOR_BUTTON_SELECTED = Gosu::Color.new(255, 117, 150, 170)
COLOR_BUTTON_HOVER = Gosu::Color.new(255, 173, 173, 173)
COLOR_TEXT_WRONG = Gosu::Color.new(255, 200, 20, 20)
COLOR_TEXT_OK = Gosu::Color.new(255, 255, 255, 255)
HEIGHT = 32

class Toobar_editor
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(color = COLOR_BUTTON_NORMAL)
		@fond = Rect.new($window, 0, 0, 0, $screen_x, HEIGHT, color) 
		@menus = []
		add_menu(String_lang::get({"fr" => "Sauv.", "eng" => "Save"}), 80)
		
		add_menu("Options", 106)
		button_cancel = @menus[1].add_button(String_lang::get({"fr" => "Annuler (ctrl-Z)", "eng" => "Cancel (ctrl-Z)"}))
		button_redo = @menus[1].add_button(String_lang::get({"fr" => "Refaire (ctrl-Y)", "eng" => "Redo (ctrl-Y)"}))
		button_grid = @menus[1].add_button(String_lang::get({"fr" => "Grille (G)", "eng" => "Grid (G)"}))

		add_menu(String_lang::get({"fr" => "Sol", "eng" => "Floor"}), 110, true, true, true,Sprite.new($window.im.editor_floors_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_floor = @menus[2].add_button(String_lang::get({"fr" => "Sol", "eng" => "Floor"}), Sprite.new($window.im.editor_floors_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_autotile = @menus[2].add_button("Autotile", Sprite.new($window.im.editor_floors_hud[1], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_water = @menus[2].add_button(String_lang::get({"fr" => "Eau", "eng" => "Water"}), Sprite.new($window.im.editor_floors_hud[2], 0, 0, 0, 0, 1, 1, 255, false, true))
	
		add_menu("Sprite face", 110, true, false, true, Sprite.new($window.im.editor_sprites_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_sprite_face = @menus[3].add_button("Sprite face", Sprite.new($window.im.editor_sprites_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_sprite_fix = @menus[3].add_button(String_lang::get({"fr" => "Sprite fixe", "eng" => "Sprite fix"}), Sprite.new($window.im.editor_sprites_hud[1], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_sprite_double = @menus[3].add_button("Double sprite", Sprite.new($window.im.editor_sprites_hud[2], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_sprite_quadra = @menus[3].add_button("Quadra sprite", Sprite.new($window.im.editor_sprites_hud[3], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_sprite_floor = @menus[3].add_button(String_lang::get({"fr" => "Sprite sol", "eng" => "Sprite floor"}), Sprite.new($window.im.editor_sprites_hud[4], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_sprite_wall = @menus[3].add_button(String_lang::get({"fr" => "Sprite mur", "eng" => "Sprite wall"}), Sprite.new($window.im.editor_sprites_hud[5], 0, 0, 0, 0, 1, 1, 255, false, true))
		
		add_menu(String_lang::get({"fr" => "Objet 3D", "eng" => "3D object"}), 110, true, false, true, Sprite.new($window.im.editor_hud["button_objet"], 0, 0, 0, 0, 1, 1, 255, false, true))
		
		add_menu(String_lang::get({"fr" => "Relief", "eng" => "Mountains"}), 110, true, false, true, Sprite.new($window.im.editor_relief_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_montains = @menus[5].add_button(String_lang::get({"fr" => "Relief", "eng" => "Montains"}), Sprite.new($window.im.editor_relief_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_block = @menus[5].add_menu(String_lang::get({"fr" => "Bloc", "eng" => "Block"}), Sprite.new($window.im.editor_relief_hud[1], 0, 0, 0, 0, 1, 1, 255, false, true))
		$button_block_1 = button_block.add_button("Length : ", nil, true, $tile_size.to_i, 0, $tile_size.to_i, 1)
		$button_block_2 = button_block.add_button("Width : ", nil, true, $tile_size.to_i, 0, $tile_size.to_i, 1)
		$button_block_3 = button_block.add_button("Height : ", nil, true, 1, -9999, 9999, 1)
		$button_block_4 = button_block.add_button("Height more : ", nil, true, 0, 0, $tile_size.to_i, 1)
		
		
		add_menu(String_lang::get({"fr" => "Pente", "eng" => "Slope"}), 110, true, false, true, Sprite.new($window.im.editor_slopes_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		
		add_menu("", 32, true, false, true, Sprite.new($window.im.editor_hud["button_ev"], 0, 0, 0, 0, 1, 1, 255, false, true))
		
		add_menu("", 32, false, false, true, Sprite.new($window.im.editor_paint_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_pen = @menus[8].add_button("", Sprite.new($window.im.editor_paint_hud[0], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_rect = @menus[8].add_button("", Sprite.new($window.im.editor_paint_hud[1], 0, 0, 0, 0, 1, 1, 255, false, true))
		button_tin = @menus[8].add_button("", Sprite.new($window.im.editor_paint_hud[2], 0, 0, 0, 0, 1, 1, 255, false, true))
		
		add_menu("", 32, false, false, false, Sprite.new($window.im.editor_hud["button_move"], 0, 0, 0, 0, 1, 1, 255, false, true))
		
		add_menu("", 32, false, false, false, Sprite.new($window.im.editor_hud["button_turn"], 0, 0, 0, 0, 1, 1, 255, false, true))
		
		add_menu("", 32, false, false, false, Sprite.new($window.im.editor_hud["button_couche"], 0, 0, 0, 0, 1, 1, 255, false, true))
		
		add_menu("", 32, false, false, false, Sprite.new($window.im.editor_hud["button_hauteur"], 0, 0, 0, 0, 1, 1, 255, false, true))
		$button_height_1 = @menus[12].add_button("", nil, true, 0, -9999, 9999, 1, "height")
		$button_height_2 = @menus[12].add_button("", nil, true, 0, 0, $tile_size.to_i-1, 1, "height")
		
		# controls
		@menus[0].add_command("save")
		@menus[1].add_command("class()")
		button_cancel.add_command("cancel")
		button_redo.add_command("redoo")
		button_grid.add_command("grid")
		@menus[2].add_command("floor(0)")
		button_floor.add_command("floor(0)")
		button_autotile.add_command("floor(1)")
		button_water.add_command("floor(2)")
		@menus[3].add_command("sprite(0)")
		button_sprite_face.add_command("sprite(0)")
		button_sprite_fix.add_command("sprite(1)")
		button_sprite_double.add_command("sprite(2)")
		button_sprite_quadra.add_command("sprite(3)")
		button_sprite_floor.add_command("sprite(4)")
		button_sprite_wall.add_command("sprite(5)")
		#~ @menus[4].add_command("object")
		#~ @menus[5].add_command("mountain(0)")
		@menus[8].add_command("set_mode(0)")
		button_pen.add_command("set_mode(0)")
		button_rect.add_command("set_mode(1)")
		button_tin.add_command("set_mode(2)")
		#~ button_montains.add_command("mountain(0)")
		#~ block = "block($button_block_1.get_value(), $button_block_2.get_value(), $button_block_3.get_value(), $button_block_4.get_value())"
		#~ button_block.add_command(block)
		#~ $button_block_1.add_command(block)
		#~ $button_block_2.add_command(block)
		#~ $button_block_3.add_command(block)
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	scroll_up
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def scroll_up(parent)
		@menus.each {|menu| menu.scroll_up(parent)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	scroll_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def scroll_down(parent)
		@menus.each {|menu| menu.scroll_down(parent)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(parent, id) 
		if id == 259
			scroll_up(parent)
		elsif id == 260
			scroll_down(parent)
		else
			return if id != 256

			@menus.each do |menu| 
				test = menu.button_down(parent, @menus) 
				return if test
			end
		end
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_menu
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_menu(label = "", width = 100, selectable = false, selected = false, click_to_select = false, image = nil)
		x = 0
		@menus.each {|menu| x += menu.get_width()}
		@menus.push(Menu.new(x, 0, width, @menus.size, label, selectable, selected, click_to_select, image))
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_hover?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_hover?()
		@menus.each do |menu| 
			test = menu. is_hover?()
			return true if test
		end
		return false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update()
		@menus.each {|menu| menu.update()}  
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw()
		@fond.draw
		@menus.each {|menu| menu.draw}
		$window.draw_line(0, HEIGHT-1, Gosu::Color.argb(0xff_000000), $screen_x, HEIGHT-1, Gosu::Color.argb(0xff_000000), 0, :default)
	end
end

class Menu
	attr_accessor :main_button 
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(x, y, width, index, label, selectable, selected, click_to_select, image, vertical_dispo = true)
		@x, @y, @width, @index, @label, @selectable, @selected, @click_to_select, @image, @vertical_dispo = x, y, width, index, label, selectable, selected, click_to_select, image, vertical_dispo
		@main_button = Button.new(@x, @y, @width, label, @selected, image)
		@buttons = []
		@display_buttons = false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	scroll_up
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def scroll_up(parent)
		@buttons.each {|button| button.scroll_up(parent)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	scroll_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def scroll_down(parent)
		@buttons.each {|button| button.scroll_down(parent)}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(parent, menus) 
		if @main_button.is_hover?() or @display_buttons
			return true if @main_button.get_command() == nil
			test = @main_button.button_down(parent, @main_button) 
			if test
				if @selectable
					menus.each {|menu| menu.main_button.selected = false}
					@main_button.selected = true
				end
				return true
			end
			@buttons.each do |button| 
				test = button.button_down(parent, button) 
				if test
					@display_buttons = false
					@main_button.force_hover(false)
					if @click_to_select
						menus.each {|menu| menu.main_button.selected = false} if @selectable
						@main_button.set_text(button.get_text(), button.get_image())
						@main_button.selected = true if @selectable
						add_command(button.get_command())
					end
					return true
				end
			end
		end
		return false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_text
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_text()
		return @main_button.get_text()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_image
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_image()
		return @main_button.get_image()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_command
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_command()
		return @main_button.get_command()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_width
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_width()
		return @width
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_hover?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_hover?()
		return (@main_button.fond.is_in_rect?([$window.mouse_x, $window.mouse_y])  or @display_buttons)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_hover?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_hover_complete?()
		r = Rect.new($window, _x(@x), _x(@y), 0, _x(@width), 32*(@buttons.size+1))
		test = false
		@buttons.each do |button| 
			test = button.is_hover_complete?()
			break if test 
		end
		return (test or r.is_in_rect?([$window.mouse_x, $window.mouse_y]))
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	select
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def select()

	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_button
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_button(text = "", image = nil, scrolling = false, default_value = 0, min = -9999, max = 9999, bound = 1, type = "bloc")
		button = @vertical_dispo ? Button.new(@x, @y + (@buttons.size*HEIGHT) + 32, @width, text, false, image, scrolling, default_value, min, max, bound, type) : Button.new(@x + @width, @y + (@buttons.size*HEIGHT), @width, text, false, image, scrolling, default_value, min, max, bound, type)
		@buttons.push(button)
		return button
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_menu
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_menu(label, image = nil)
		menu = Menu.new(@x, @y + (@buttons.size*HEIGHT) + 32, @width, 0, label, false, @selected, false, image, false)
		@buttons.push(menu)
		return menu
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_command
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_command(command)
		@main_button.add_command(command)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update()
		@main_button.update()
		@buttons.each {|button| button.update()}
		if !is_hover_complete?()
			@display_buttons = false
			@main_button.force_hover(false)
		elsif @main_button.is_hover?()
			@display_buttons = true
			@main_button.force_hover(true)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw()
		@main_button.draw
		if @display_buttons
			@buttons.each {|button| button.draw()}
		end
	end
end

class Button
	attr_accessor :selected, :text, :image, :selectable, :fond, :menu
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(x, y, width, text = "", selected = false, image = nil, scrolling = false, default_value = 0, min = -9999, max = 9999, bound = 1, type = "bloc")
		@x, @y, @width, @text, @selected, @scrolling, @value, @min, @max, @bound, @type = x, y, width, text, selected, scrolling, default_value, min, max, bound, type
		color = @selected ? COLOR_BUTTON_SELECTED : COLOR_BUTTON_NORMAL
		@fond = Rect.new($window, _x(x), y, 0, _x(width), HEIGHT, color) 
		set_text(text, image)
		@hover = false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	scroll_up
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def scroll_up(parent)
		if @scrolling and is_hover?()
			@value += @bound
			@value = @min if @value > @max
			set_text(@text, nil)
			
			scroll(parent)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	scroll_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def scroll_down(parent)
		if @scrolling and is_hover?()
			@value -= @bound
			@value = @max if @value <= @min
			set_text(@text, nil)
			
			scroll(parent)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	scroll
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def scroll(parent)
		case @type
			when "bloc"
				parent.set_block_values($button_block_1.get_value(), $button_block_2.get_value(), $button_block_3.get_value(), $button_block_4.get_value())
			when "height"
				parent.set_height_values($button_height_1.get_value(), $button_height_2.get_value())
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(parent, button) 
		if is_hover?()
			$window.interface.eval_deleted_preview_item()
			eval("parent." + @command) if @command != nil
			return true
		end		
		return false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_text
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_text(text, image)
		text += @value.to_s if @scrolling
		color = COLOR_TEXT_OK
		if image != nil
			@text_img = Text.new($window, text,  _x(@x + 32), @y + (HEIGHT/2) - ($font_size/2), 0, $font_name, $font_size, 2, _x(@width - 32), :center, 0, 255, false, false, false, color)
		else
			@text_img = Text.new($window, text, _x(@x), @y + (HEIGHT/2) - ($font_size/2), 0, $font_name, $font_size, 2, _x(@width), :center, 0, 255, false, false, false, color)
		end
		@image = image
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		return @value
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_text
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_text()
		return @text
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_image
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_image()
		return @image
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	add_command
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def add_command(command)
		@command = command
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_command
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_command()
		return @command
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	force_hover
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def force_hover(b)
		@hover = b
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_hover?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_hover?()
		return @fond.is_in_rect?([$window.mouse_x, $window.mouse_y])
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_hover?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_hover_complete?()
		return is_hover?()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update()
		color = (is_hover?() or @hover) ? COLOR_BUTTON_HOVER : COLOR_BUTTON_NORMAL
		color = COLOR_BUTTON_SELECTED if @selected
		@fond = Rect.new($window, _x(@x), @y, 0, _x(@width), HEIGHT, color) 
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def draw()
		@fond.draw
		@text_img.draw
		@image.draw(_x(@x), @y, 0) if @image != nil
		$window.draw_line(_x(@x), @y+HEIGHT-1, Gosu::Color.argb(0xff_000000), _x(@x+@width), @y+HEIGHT-1, Gosu::Color.argb(0xff_000000), 0, :default)
	end
end
