@tool
extends Label

func _process(_delta: float) -> void:
	text = "[Entrace mode: %d]-[Exit id: %d]" % [get_parent().Entrace_Mode, get_parent().Exit_ID]
	if not Engine.is_editor_hint():
		queue_free()
