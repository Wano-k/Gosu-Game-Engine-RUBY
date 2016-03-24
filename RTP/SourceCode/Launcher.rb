# encoding: UTF-8

SM_CXSCREEN	=	0
SM_CYSCREEN	=	1
 
user32 = DL.dlopen("user32")
 
get_system_metrics = DL::CFunc.new(user32['GetSystemMetrics'], DL::TYPE_LONG, 'MessageBox')
$user_screen_x, tmp = get_system_metrics.call([SM_CXSCREEN, "h", "m", 0].pack('L!ppL!').unpack('L!*'))
$user_screen_y, tmp = get_system_metrics.call([SM_CYSCREEN, "h", "m", 0].pack('L!ppL!').unpack('L!*'))


class Launcher < Gosu::Window 
	attr_accessor :im, :move_tick
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize
		file = File.open("Datas/Laun/inf.txt", "r:UTF-8").readlines
		size = file[0].chomp.split('$')
		super(size[0].to_i, size[1].to_i, false)
		self.caption = String_lang::get($game_system.launcher_caption)
		
		@im = Image_manager.new(self)
		@last_time = Gosu::milliseconds
		@move_tick = Gosu::milliseconds
		
		@sprite_background = Sprite.create(self, @im.title[$game_system.launcher_background[0][$lang]], $game_system.launcher_background[1], $game_system.launcher_background[2])
	
		@list = [eval(file[1].chomp), eval(file[2].chomp)]
		@user_resos, reso_text = Array.new, Array.new
		@list.each do |tab|
			tab.each do |reso|
				if (reso[0] <= $user_screen_x or reso[1] <= $user_screen_y)
					@user_resos.push([reso[0].to_s, reso[1].to_s])
					reso_text.push(reso[0].to_s + " x " + reso[1].to_s)
				end
			end
		end
		@user_resos.push([$user_screen_x.to_s, $user_screen_y.to_s])
		reso_text.push($user_screen_x.to_s + " x " + $user_screen_y.to_s)
		$font_size = 32
		@window_choices_play = Window_choice.new(self, 50, 40, 0, 200, 80, ["Play"])
		$font_size = 16
		@window_resolution = Window_box.new(self, 0, 180, 0, 300, 10, "-Resolution : 640 x 480 -")
		@window_choices_resolution = Window_choice.new(self, 100, 200, 0, 100, 30, reso_text)
		@window_mode = Window_box.new(self, 0, 380, 0, 300, 10, "-Screen mode : window -")
		@window_choices_mode = Window_choice.new(self, 100, 400, 0, 100, 30, ["Window", "Full"])
	end

	#--------------------------------------------------------------------------------------------------------------------------------
	#	needs_cursor?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def needs_cursor?
		return true
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	button_down
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def button_down(id)
		if id == Gosu::KbF12
			$launcher[:closed] = false
			close
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update
		@move_tick = Gosu::milliseconds - @last_time
		@last_time = Gosu::milliseconds
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	draw
	#--------------------------------------------------------------------------------------------------------------------------------

	def draw		
		@sprite_background.draw if @sprite_background != nil
		@window_choices_play.draw
		@window_resolution.draw
		@window_choices_resolution.draw
		@window_mode.draw
		@window_choices_mode.draw
	end
end