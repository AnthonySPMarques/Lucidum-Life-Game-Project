extends NPC_Logic
class_name NPC_Object
@onready var interaction: Node2D = %InteractionDialog
func _ready() -> void:
	self.connect("area_entered", _on_area_entered)
	self.connect("area_exited", _on_area_exited)
	self.connect("interaction_request", interaction.on_plaky_npc_interaction_request)
	self.connect("toggle_request", interaction.on_plaky_npc_toggle_request)
	
func _on_area_entered(area: Area2D) -> void:
	if area.name == "PersistentBox":
		if (Input.is_action_just_pressed("Down") or\
		Input.is_action_just_pressed("Up")) or auto_interact:
			interaction_request.emit()


func _on_area_exited(area: Area2D) -> void:
	if area.name == "PersistentBox":
		if auto_interact:
			toggle_request.emit()
