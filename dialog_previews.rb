# encoding: UTF-8

class Dialog_preview < Wx::Dialog
	PEN = Wx::Pen.new(Wx::Colour.new(200, 0, 0, 70))
	PEN_GRID = Wx::Pen.new(Wx::Colour.new(200, 200, 200, 150))
	BRUSH = Wx::Brush.new(Wx::Colour.new(200, 0, 0, 50))
	BACKGROUND = Wx::Brush.new(Wx::Colour.new(255, 0, 0))
	
	class ImageDisplay < Wx::ScrolledWindow
		
		attr_accessor :moving, :rectangle_pix
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	initialize
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def initialize(parent, selection, obj)
			super(parent, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::DOUBLE_BORDER)
			set_own_background_colour(Wx::Colour.new(200,200, 225))
			@selection = selection
			@image = nil
			@bitmap = nil
			@first_selection = true
			if @selection
				rect = [obj[1][0], obj[1][1], obj[1][2], obj[1][3]]
				@zoom = 1.0
				@zoom_time = 0
				@true_rectangle = [0, 0, 0, 0]
				@rectangle_pix = Array.new(rect)
				@rectangle = Array.new(rect)
				@moving = false
			end
			
			set_cursor(Wx::Cursor.new(Wx::CURSOR_PENCIL))
			
			evt_left_down {|event| on_left_button_event_down(event)}
			evt_left_up {|event| on_left_button_event_up(event)}
			evt_motion {|event| on_left_button_event_motion(event)}
			evt_paint { on_paint }
			evt_mousewheel {|event| on_mousewheel_event(event)}
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	init_rect
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def init_rect()
			@zoom = 1.0
			@zoom_time = 0
			@true_rectangle = [0, 0, 0, 0]
			@rectangle = [0, 0, 1, 1]
			@rectangle_pix = [0, 0, 1, 1]
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	widgets_rect_update
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def widgets_rect_update()
			parent.position_x.text_ctrl.set_value(@rectangle_pix[0].to_s)
			parent.position_y.text_ctrl.set_value(@rectangle_pix[1].to_s)
			parent.size_x.text_ctrl.set_value(@rectangle_pix[2].to_s)
			parent.size_y.text_ctrl.set_value(@rectangle_pix[3].to_s)
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	on_paint
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def on_paint()
			paint{ | dc | do_drawing(dc) }
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	do_drawing
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def do_drawing(dc)
			do_prepare_dc(dc)
			dc.draw_bitmap(@bitmap, 0, 0, true) if @bitmap != nil
			if (@selection and @bitmap != nil and @zoom_time > 0)
				w, h = @image.get_width(), @image.get_height()
				dc.set_pen(PEN_GRID)
				for i in 0...w
					for j in 0...h
						dc.draw_line(0, (j*@zoom).to_i, (w*@zoom).to_i, (j*@zoom).to_i)
					end
					dc.draw_line((i*@zoom).to_i, 0, (i*@zoom).to_i, (h*@zoom).to_i)
				end
				gdc = Wx::GraphicsContext.create(dc)
				gdc.set_pen(PEN)
				gdc.set_brush(BRUSH)
				gdc.draw_rectangle(@rectangle[0], @rectangle[1], @rectangle[2], @rectangle[3])	
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	on_left_button_event_dow
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def on_left_button_event_down(event)
			if @selection and @bitmap != nil
				set_focus()
				capture_mouse()
				if (event.get_x() > 0 and event.get_x() < @bitmap.get_width() and event.get_y() > 0 and event.get_y() < @bitmap.get_height())
					@true_rectangle = [event.get_x(), event.get_y(), 0, 0]
					@rectangle = [(event.get_x()/@zoom.to_i)*@zoom.to_i, (event.get_y()/@zoom.to_i)*@zoom.to_i, @zoom.to_i, @zoom.to_i]
					@rectangle_pix = @rectangle.map{|x| x/@zoom.to_i}
					parent.position_x.text_ctrl.set_value(@rectangle_pix[0].to_s)
					parent.position_y.text_ctrl.set_value(@rectangle_pix[1].to_s)
					parent.size_x.text_ctrl.set_value(@rectangle_pix[2].to_s)
					parent.size_y.text_ctrl.set_value(@rectangle_pix[3].to_s)
					@moving = false
					refresh
				end
			end
		end
		    
		#--------------------------------------------------------------------------------------------------------------------------------
		#	on_left_button_event_up
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def on_left_button_event_up(event)
			release_mouse()
			@moving = false
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	on_left_button_event_motion
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def on_left_button_event_motion(event) 
			if event.left_is_down() and @selection and @bitmap != nil
				if (event.get_x() > 0 and event.get_x() < @bitmap.get_width() and event.get_y() > 0 and event.get_y() < @bitmap.get_height())
					@true_rectangle[2] = event.get_x() - @true_rectangle[0]
					@true_rectangle[3] = event.get_y() - @true_rectangle[1]
					previous_rect = Array.new(@rectangle)
					
					left = ((@true_rectangle[0]/@zoom.to_i))*@zoom.to_i
					right= (((@true_rectangle[0] + @true_rectangle[2])/@zoom.to_i))*@zoom.to_i
					top = ((@true_rectangle[1]/@zoom.to_i))*@zoom.to_i
					bot = (((@true_rectangle[1] + @true_rectangle[3])/@zoom.to_i))*@zoom.to_i

					@rectangle = [(@true_rectangle[0]/@zoom.to_i)*@zoom.to_i, (@true_rectangle[1]/@zoom.to_i)*@zoom.to_i, right-left+@zoom.to_i, bot-top+@zoom.to_i]
					w, h = @rectangle[2], @rectangle[3]
					if w <= 0
						@rectangle[0] += w - @zoom.to_i
						@rectangle[2] = - w + (2*@zoom.to_i)
					end
					if h <= 0
						@rectangle[1] += h - @zoom.to_i
						@rectangle[3] = - h + (2*@zoom.to_i)
					end
					if (previous_rect != @rectangle)
						@rectangle_pix = @rectangle.map{|x| x/@zoom.to_i}
						widgets_rect_update()
						@moving = true
					end
				end
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	on_mousewheel_event
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def on_mousewheel_event(event)
			if @selection and @image != nil
				if event.get_wheel_rotation() > 0
					zoom(true)
				elsif event.get_wheel_rotation() < 0
					zoom(false)
				end
			end
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	update
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def set_image(image)
			if @selection
				if !@first_selection
					init_rect() 
					widgets_rect_update()
				else
					@first_selection = false
				end
			end
			
			w, h = -1, -1
			if image == nil
				@bitmap = nil
				@image = nil
			else
				@image = Wx::Image.new(image)
				@bitmap = Wx::Bitmap.new(image)
				w = @bitmap.get_width()
				h = @bitmap.get_height()
			end
			set_scrollbars(1, 1, w, h, 0, 0, true)
			refresh
			show()
		end
		
		#--------------------------------------------------------------------------------------------------------------------------------
		#	zoom
		#--------------------------------------------------------------------------------------------------------------------------------
		
		def zoom(b)
			if ((@zoom_time > -5 and !b) or (@zoom_time < 5 and b))
				if b
					@zoom *= 2
					@zoom_time += 1
				else
					@zoom /= 2
					@zoom_time -= 1
				end
				w, h = (@image.get_width()*@zoom).to_i, (@image.get_height()*@zoom).to_i
				image = @image.scale(w, h)
				@bitmap = Wx::Bitmap.from_image(image)
				w = @bitmap.get_width()
				h = @bitmap.get_height()
				@rectangle = @rectangle_pix.map{|x| x*@zoom.to_i}
				set_scrollbars(1, 1, w, h, 0, 0, true)
				refresh
			end
		end
	end
	
	attr_accessor :position_x, :position_y, :size_x, :size_y
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, text, widget, dir, selection)
		super(parent, Wx::ID_ANY, text, Wx::DEFAULT_POSITION, [700, 500])
		set_own_background_colour($background_color)
		@obj, @dir = widget.values, dir
		widget_text = widget.text_ctrl.get_item_text(0)
		widget_text = widget_text[2...widget_text.size] if widget_text != String_lang::get({"fr" => "Aucun(e)", "eng" => "None"})
		@image_preview = ImageDisplay.new(self, selection, @obj)
		@selected_text = nil
		
		width = 200
		list_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		@list = Wx::ListCtrl.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [width,-1], Wx::LC_NO_HEADER | Wx::LC_SMALL_ICON)
		@list.insert_column(0, "head")
		@list.set_column_width(0, width-21)
		none = String_lang::get({"fr" => "Aucun(e)", "eng" => "None"})
		@list_names = [none]
		@list.insert_item(0, none)
		images = Wx::ImageList.new(16, 16, true)
		images.add(Wx::Bitmap.new("Datas/bmp/point_b.png"))
		images.add(Wx::Bitmap.new("Datas/bmp/point_r.png"))
		@list.set_image_list(images, Wx::IMAGE_LIST_SMALL)
		@list.set_item_image(0, -1, -1)
		i = 1
		image_names = []
		Dir.entries("RTP/" + dir).each do |file|
			if file.include?(".png")
				file_name = File.basename(file,File.extname(file))
				adding = true
				$game_langs.languages.each do |lang|
					end_lang = "_" + lang
					if (file_name.end_with?(end_lang))
						file_name = file_name[0...file_name.size-end_lang.size]
						if image_names.include?(file_name)
							adding = false
						else
							image_names.push(file_name)
						end
						break
					end
				end
				if (adding)
					@list.insert_item(i, file_name)
					@list.set_item_image(id, 0, -1)
					@list_names.push(file)
					if file_name == widget_text
						@list.set_item_state(i, Wx::LIST_STATE_SELECTED, Wx::LIST_STATE_SELECTED)
						@list.set_focus()
						selected(i)
					end
					i += 1
				end
			end
		end
		list_sizer.add(@list, 1, Wx::GROW)
		
		image_preview_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		image_preview_sizer.add(@image_preview, 1, Wx::GROW)
		
		okCancel = OkCancel.new(self)
		okCancel.set_own_background_colour($background_color)
		main_sizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
		main_sizer.add(list_sizer, 0, Wx::GROW)
		main_sizer.add_spacer(5)
		main_sizer.add(image_preview_sizer, 1, Wx::GROW)
		options_sizer = set_options()
		main_sizer.add(options_sizer, 0, Wx::GROW)
		global_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		global_sizer.add(main_sizer, 1, Wx::GROW)
		global_sizer.add_spacer(10)
		global_sizer.add(okCancel, 0, Wx::GROW | Wx::ALIGN_RIGHT | Wx::ALL)
		
		window_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		window_sizer.add(global_sizer, 1, Wx::ALL | Wx::GROW, 10)
		
		# Set sizer
		set_sizer(window_sizer)
		
		# Set evt
		timer = Wx::Timer.new(self, Wx::ID_ANY)
		evt_timer(Wx::ID_ANY) do |event| 
			if @image_preview.moving
				@image_preview.refresh
				@image_preview.moving = false
			end
		end
		timer.start(100)
			
		evt_list_item_selected(Wx::ID_ANY) do |event|
			selected(event.get_index())
		end
		evt_list_item_deselected(Wx::ID_ANY) do |event|
			@selected_text = nil
			@image_preview.set_image(nil)
		end
		evt_button(okCancel.button_ok) do |event| 
			if @selected_text != nil
				timer.stop()
				end_modal(1000)
			else
				alert = Wx::MessageDialog.new(nil, String_lang::get({"fr" => "Pas d'image selectionné.", "eng" => "No selected image."}), String_lang::get({"fr" => "Erreur", "eng" => "Error"}), Wx::ICON_INFORMATION)
				alert.show_modal
			end
		end
		evt_button(okCancel.button_cancel) do |event| 
			timer.stop()
			end_modal(-1)
		end
		evt_close() do |event| 
			timer.stop()
			end_modal(-1)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	selected
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def selected(id)
		@selected_text = @list.get_item_text(id)
		if id == 0
			@image_preview.set_image(nil)
		else
			@image_preview.set_image("RTP/" + @dir + @list_names[id])
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_options
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_options()
		return Wx::BoxSizer.new(Wx::VERTICAL)
	end

end

class Dialog_preview_title < Dialog_preview
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, name, widget)
		super(parent, name, widget, "Pictures/HUD/Title/", false)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_options
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_options()
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, "Position x :"), 0, Wx::GROW)
		main_sizer.add_spacer(2)
		@position_x = NumberCtrl.new(self, -9999, 9999, @obj[1], 1, 4, true)
		main_sizer.add(@position_x, 0, Wx::GROW)
		main_sizer.add_spacer(5)
		main_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, "Position y :"), 0, Wx::GROW)
		main_sizer.add_spacer(2)
		@position_y = NumberCtrl.new(self, -9999, 9999, @obj[2], 1, 4, true)
		main_sizer.add(@position_y, 0, Wx::GROW)
		
		window_sizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, "Options")
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 5)
		
		return window_sizer
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		return {"name" => @selected_text, "pos_x" => @position_x.get_final_value(), "pos_y" => @position_y.get_final_value()}
	end
end

class Dialog_preview_window_skin < Dialog_preview
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(parent, name, widget)
		super(parent, name, widget, "Pictures/HUD/WindowSkins/", true)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_options
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_options()
		main_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
		main_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, "Position x"), 0, Wx::GROW)
		main_sizer.add_spacer(2)
		@position_x = NumberCtrl.new(self, 0, 9999, @obj[1][0], 1, 4, true)
		main_sizer.add(@position_x, 0, Wx::GROW)
		main_sizer.add_spacer(5)
		main_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, "Position y :"), 0, Wx::GROW)
		main_sizer.add_spacer(2)
		@position_y = NumberCtrl.new(self, 0, 9999, @obj[1][1], 1, 4, true)
		main_sizer.add(@position_y, 0, Wx::GROW)
		main_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, "Width :"), 0, Wx::GROW)
		main_sizer.add_spacer(2)
		@size_x = NumberCtrl.new(self, 1, 9999, @obj[1][2], 1, 4, true)
		main_sizer.add(@size_x, 0, Wx::GROW)
		main_sizer.add_spacer(5)
		main_sizer.add(Wx::StaticText.new(self, Wx::ID_ANY, "Height :"), 0, Wx::GROW)
		main_sizer.add_spacer(2)
		@size_y = NumberCtrl.new(self, 1, 9999, @obj[1][3], 1, 4, true)
		main_sizer.add(@size_y, 0, Wx::GROW)
		
		window_sizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, "Options")
		window_sizer.add(main_sizer, 1, Wx::ALL | Wx::GROW, 5)
		
		return window_sizer
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	get_value
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def get_value()
		return {"name" => @selected_text, "rectangle" => @image_preview.rectangle_pix}
	end
end