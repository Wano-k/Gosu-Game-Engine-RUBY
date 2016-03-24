# encoding: UTF-8

class Logo < Wx::Frame
  def initialize(parent)
    super(parent, :title => "Logo", :size => [200,200], 
          :style => Wx::FRAME_SHAPED|Wx::SIMPLE_BORDER|Wx::FRAME_NO_TASKBAR|Wx::STAY_ON_TOP)

    @has_shape = false
    @delta = [0,0]

    evt_left_down {|event| on_left_down(event)}
    evt_left_up {|event| on_left_up(event)}
    evt_motion {|event| on_mouse_move(event)}
    evt_paint {on_paint}

    @bmp = Wx::Bitmap.new("Datas/bmp/logo.png")
    set_client_size(@bmp.width, @bmp.height)

    if Wx::PLATFORM == 'WXGTK'
      # wxGTK requires that the window be created before you can
      # set its shape, so delay the call to SetWindowShape until
      # this event.
      evt_window_create { set_window_shape }
    else
      # On wxMSW and wxMac the window has already been created, so go for it.
      set_window_shape
    end

    
  end

  def set_window_shape
    r = Wx::Region.new(@bmp)
    @has_shape = set_shape(r)
  end

  def on_paint
    paint { | dc | dc.draw_bitmap(@bmp, 0, 0, true) }
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