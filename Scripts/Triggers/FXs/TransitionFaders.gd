extends ParallaxBackground 
#class_name Fader_Trigger

signal Transition_Animation_Finished
var current_transition_name : String = ""
@export var selfcolor: ColorRect
@export var color_glitcher: ColorRect

func _ready() -> void:
	if selfcolor != null:
		selfcolor.set("size", DisplayServer.window_get_size())
	if color_glitcher != null:
		color_glitcher.set("size", DisplayServer.window_get_size())
	print(DisplayServer.window_get_size())
	
func set_tween_fader(fadeid: int, duration: float, color: Color) -> void:

	$Transitions.set_as_top_level(true)
	var tween = create_tween()
	
	%Color.color = color
	
	match fadeid:
		0:	#Fade_In
			%Color.color.a = 0.0
			tween.tween_property(%Color,
			"color:a",
			1.0,
			duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			
			tween.play()
			
		1:	#Fade_Out
			%Color.color.a = 1.0
			tween.tween_property(%Color,
			"color:a",
			0.0,
			duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			
			tween.play()
		
func set_animation_fader(animation_name: String) -> void:
	print("trans ",current_transition_name)
	current_transition_name = animation_name
	%AnimationPlayer.play(animation_name)
	await %AnimationPlayer.animation_finished
	Transition_Animation_Finished.emit()
	
