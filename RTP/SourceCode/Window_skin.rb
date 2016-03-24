# encoding: UTF-8

class Window_skin
	attr_accessor 	:name,
				:corner_top_left,
				:corner_top_right,
				:corner_bot_left,
				:corner_bot_right,
				:corner_sym,
				:border_top,
				:border_right,
				:border_left,
				:border_bot,
				:border_sym,
				:border_choice_type,
				:background_kind,
				:background_image,
				:background_image_choice_type,
				:background_color
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(
		name = "New window skin", 
		corner_top_left = [{"eng" => "Window1", "fr" => "Window1"}, [0, 0, 8, 8]],
		corner_top_right = [{"eng" => :none, "fr" => :none}, [0, 0, 1, 1]],
		corner_bot_left = [{"eng" => :none, "fr" => :none}, [0, 0, 1, 1]],
		corner_bot_right = [{"eng" => :none, "fr" => :none}, [0, 0, 1, 1]],
		corner_sym = true,
		border_top = [{"eng" => "Window1", "fr" => "Window1"}, [0, 8, 1, 6]],
		border_right = [{"eng" => :none, "fr" => :none}, [0, 0, 1, 1]],
		border_left = [{"eng" => :none, "fr" => :none}, [0, 0, 1, 1]],
		border_bot = [{"eng" => :none, "fr" => :none}, [0, 0, 1, 1]],
		border_sym = true,
		border_choice_type = 1,
		background_kind = 1,
		background_image = [{"eng" => :none, "fr" => :none}, [0, 0, 1, 1]],
		background_image_choice_type = 1,
		background_color = 0
		)
		
		@name = name
		@corner_top_left = corner_top_left
		@corner_top_right = corner_top_right
		@corner_bot_left = corner_bot_left
		@corner_bot_right = corner_bot_right
		@corner_sym = corner_sym
		@border_top = border_top
		@border_right = border_right
		@border_left = border_left
		@border_bot = border_bot
		@border_sym = border_sym
		@border_choice_type = border_choice_type
		@background_kind = background_kind
		@background_image = background_image
		@background_image_choice_type = background_image_choice_type
		@background_color = background_color
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	background_is_image?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def background_is_image?()
		return (@backgorund == 0)
	end
end