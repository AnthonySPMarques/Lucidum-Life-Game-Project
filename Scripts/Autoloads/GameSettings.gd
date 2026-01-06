extends Node
"Where all game configurations are"

class ConfigurationManager:
	class AudioChannelsManager:
		var Music_Volume : float = 0 : 
			set(DB_Converter): 
				Music_Volume = linear_to_db(clampf(DB_Converter, 0, 100))
			get:
				return Music_Volume
		var Sound_Volume : float = 0 : 
			set(DB_Converter): 
				Music_Volume = linear_to_db(clampf(DB_Converter, 0, 100))
			get:
				return Sound_Volume
		var Sound_Espacoso_Volume : float = 0 : 
			set(DB_Converter): 
				Music_Volume = linear_to_db(clampf(DB_Converter, 0, 100))
			get:
				return Sound_Espacoso_Volume
		var Sound_Repetidor_Volume : float = 0 : 
			set(DB_Converter): 
				Music_Volume = linear_to_db(clampf(DB_Converter, 0, 100))
			get:
				return Sound_Repetidor_Volume
	class GameplaySettings:
		static var Game_Configurations_Dictionary : Dictionary = {
			"Disable_Particles" : false,
			"Disable_Shaders" : false,
			"Enable_vsync" : true,
		}
		
