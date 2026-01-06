extends Label
class_name Input_name_translator

@export var Input_name : String = ""

func _ready() -> void:
	for action in InputMap.get_actions():
		if action == Input_name:
			var event = InputMap.action_get_events(action)
			if event.size() > 0:
				text = event[0].as_text()
			else:
				text = ""
		
	
