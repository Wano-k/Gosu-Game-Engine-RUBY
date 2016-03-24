# encoding: UTF-8

class Event_interpreter
	def self.create_dialog(parent, index)
		case index
			when 0
				return Dialog_display_message.new(parent)
			when 4
				return Dialog_conditions.new(parent)
		end
		return Dialog_display_message.new(parent)
	end
end