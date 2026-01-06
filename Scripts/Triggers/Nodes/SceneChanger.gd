extends Node

##Mains##
const PRESENTATION = preload("uid://blcs31tdyhx2l")
const TITLE_SCREEN = preload("uid://bi6qkwbpncbea")

##Lullaby blue arc##
const LULLABY_BLUE_1 = preload("uid://dxkoxaolhufnb")
const LULLABY_BLUE_2 = preload("uid://c6e4o8rxncot6")


func change_to_scene(scene) -> void:
	if self.is_inside_tree():
		if scene is PackedScene:
			get_tree().change_scene_to_packed(scene)
		else:
			get_tree().change_scene_to_file(scene)
