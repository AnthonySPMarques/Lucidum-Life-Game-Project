#@tool
extends AnimatableBody2D
class_name MiscPlatform

@export_enum(
"Large_Paddle_Platform",
"Small_Travel_Platform") var Platform_Type : String = "Small_Travel_Platform"

@onready var platform_animation: AnimationPlayer = $PlatformAnimation

@onready var remote_transform_player: RemoteTransform2D = $RemoteTransformPlayer
@onready var generic_platform_area_2d: Area2D = $GenericPlatformArea2D

var flockos_is_over_here : bool = false

func _ready() -> void:
	pass
	if not Engine.is_editor_hint():
		platform_animation.play(Platform_Type)
	#if not Engine.is_editor_hint():
		#print(flockos_is_over_here)

	#if flockos_is_over_here == true:
		#if GlobalEngine.flockos.States.Default_State == GlobalEngine.flockos.HangingTop:
			#remote_transform_player.remote_path = GlobalEngine.flockos.get_path()
		#else:
			#remote_transform_player.remote_path = ""
	#else:
		#remote_transform_player.remote_path = ""
	

func _on_generic_platform_area_2d_body_entered(body: Node2D) -> void:
	if body is Flockos:
		flockos_is_over_here = true
func _on_generic_platform_area_2d_body_exited(body: Node2D) -> void:
	if body is Flockos:
		flockos_is_over_here = false
