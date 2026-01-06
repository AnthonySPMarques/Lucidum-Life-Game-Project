extends Plugger
class_name TweenMaker

@export var auto_start : bool = true

@export_enum("Property") var tween_mode = "Property"

@export var Property_path : String = "size"
@export var Tween_duration : float = 0.5
@export var Tween_delay : float = 0.0
@export var Ease_Tween : Tween.EaseType
@export var Transi_Tween : Tween.TransitionType

var Object_to_tween : Node
var final_tween_destiny ## <- Dynamic variable

func _ready() -> void:
	
	##Store the node to be tweened with Node_To_Plugin.
	Object_to_tween = Node_To_PlugIn
	
	##Store the metadata in the final_tween_destiny variable, that's why
	##it is a dynamic variable.
	if has_meta("Final_Destiny"):
		final_tween_destiny = get_meta("Final_Destiny")
	else:
		push_error("You must add a metadata for the final destiny tween")
		breakpoint
	##If the plugger will autostart the tween.
	if auto_start:
		match tween_mode:
			"Property":
				_tween_property()
			
func _tween_property(Obj = Object_to_tween,
pty_path = Property_path, 
final_destiny = final_tween_destiny,
duration = Tween_duration,
ease_t = Ease_Tween,
transi_t = Transi_Tween) -> void:
	
	##Create tween stored in a generic var
	var tw = create_tween()
	
	##Active the tween
	tw.tween_property(Obj, pty_path, final_destiny, 
	duration).set_ease(ease_t).set_trans(transi_t).set_delay(Tween_delay)
	
	tw.play()
	print("Tween started")
	
	await tw.finished
	print("Tween finished")
