extends Control
@export var scenetogo_after_presentation : PackedScene
func goto_titlescreen() -> void:
	SceneChanger.change_to_scene(scenetogo_after_presentation)
	
