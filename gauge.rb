# encoding: UTF-8

class Gauge < Wx::Frame
	MAX = 100
	attr_accessor :loading
	
	def initialize(parent, loading = "")
		super(parent, :title => "Logo", :size => [300,120], :style => Wx::NO_BORDER|Wx::FRAME_NO_TASKBAR|Wx::STAY_ON_TOP)
		set_own_background_colour(Wx::Colour.new(240,230, 235))
		
		@delta = [0,0]
		@loading = loading
		@count = 0
		
		evt_left_down {|event| on_left_down(event)}
		evt_left_up {|event| on_left_up(event)}
		evt_motion {|event| on_mouse_move(event)}
		evt_paint {on_paint}

		@text = Wx::StaticText.new(self, Wx::ID_ANY, "Loading..." + @loading, Wx::Point.new(25,30))
		@g = Wx::Gauge.new(self, -1, MAX, Wx::Point.new(25,65), Wx::Size.new(250,25), Wx::GA_HORIZONTAL|Wx::GA_SMOOTH)
		@g.set_bezel_face(5)
		@g.set_shadow_width(5)
    
		center_on_parent(Wx::BOTH)
		show()
	end

	def set_step(count, new_text)
		@count = count
		@g.set_value(@count)
		@text.set_label("Loading..." + new_text)
		if @count == MAX
			on_exit()
		end
	end
	
	def on_paint
		paint { | dc |  }
	end
	    
	def on_exit
		close(true)
	end
	
	def on_left_down(event)
		capture_mouse
		point = client_to_screen(event.position)
		origin = position
		dx = point.x - origin.x
		dy = point.y - origin.y
		@delta = [dx, dy]
	end

	def on_left_up(event)
		if has_capture
			release_mouse
		end
	end

	def on_mouse_move(event)
		if event.dragging and event.left_is_down
			point = client_to_screen(event.position)
			move(point.x - @delta[0], point.y - @delta[1])
		end
	end
end