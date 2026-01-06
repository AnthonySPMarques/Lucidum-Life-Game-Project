extends Node

const SAVE_PATH = "user://LucidumLifeData/"
const PASSWORD_FILE = "S2U1A8M0A6E"

var json = JSON.new()

func _ready() -> void:
	check_save_directory(SAVE_PATH)
	
func check_save_directory(dir: String) -> void:
	DirAccess.make_dir_absolute(dir)

#Func to add data to a autolaod dictionary
func save_data(dir: String, content: Dictionary) -> void:
	#open_encrypted_with_pass(dir , FileAccess.WRITE, PASSWORD_FILE)
	var File = FileAccess.open(dir, FileAccess.WRITE)
	if File == null:
		printerr(FileAccess.get_open_error())
		return
	
	
	#####here the posible error
	var jsons_string = JSON.stringify(content, "\n")
	File.store_string(jsons_string)
	File.close()
	print(content)
	
	pass
	
func load_data(dir: String) -> Dictionary:
	if FileAccess.file_exists(dir):
		#open_encrypted_with_pass(dir , FileAccess.READ, PASSWORD_FILE)
		var File = FileAccess.open(dir, FileAccess.READ)
		if File == null:
			printerr(FileAccess.get_open_error())
			return {}
		
		var content_file = File.get_as_text()
		File.close()
		
		var data_jsons = JSON.parse_string(content_file)
		if data_jsons == null:
			printerr("Game data couldn't parse json %s at: (%s)" % [dir, content_file])
			return {}
		
		var Player_Data = PlayerResources
		Player_Data.Current_Energy = data_jsons.Flockos_Properties.Current_Energy
		Player_Data.Current_Health = data_jsons.Flockos_Properties.Current_Health 
		Player_Data.Max_Health = data_jsons.Flockos_Properties.Max_Health
		Player_Data.Max_Energy = data_jsons.Flockos_Properties.Max_Energy
		Player_Data.Current_Energy = data_jsons.Flockos_Properties.Current_Energy 
		Player_Data.current_position = Vector2(data_jsons.Flockos_Properties.current_position.x,
		data_jsons.Flockos_Properties.current_position.y)
		Player_Data.Current_Score = data_jsons.Flockos_Properties.Current_Score
		print(data_jsons)
		return data_jsons
		
	else:
		printerr("Game data has not found in %s!" % [dir])
		return {}
	
