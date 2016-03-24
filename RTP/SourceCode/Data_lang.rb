# encoding: UTF-8

class Data_lang
	attr_accessor 	:current_lang,
				:languages,
				:languages_names
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize()
		@current_lang = "eng"
		@languages = ["eng", "fr"]
		@languages_names = {"eng" => {"eng" => "English", "fr" => "French"}, "fr" => {"eng" => "Anglais", "fr" => "Français"}}
	end
end


