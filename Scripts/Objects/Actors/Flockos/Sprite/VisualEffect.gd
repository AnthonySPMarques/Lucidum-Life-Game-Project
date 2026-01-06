extends Node2D

signal squish_finished

@export var ShakeForce : int = 0
@export var shake_duration : float = 1.0
var rng = RandomNumberGenerator.new()

var current_shake_force : int = 0

var previous_window_pos = null
var current_window_pos = null

func _ready() -> void:
	set_unique_name_in_owner(true)
	
func _apply_shake() -> void:
	set_physics_process(true)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	previous_window_pos = DisplayServer.window_get_position()
	current_shake_force = ShakeForce

func _physics_process(delta: float) -> void:
	
	if current_shake_force > 0:
		current_shake_force = lerp(current_shake_force, 0, shake_duration * delta)
		
		DisplayServer.window_set_position(
			DisplayServer.window_get_position() + Shake_Window()
		)
	else:
		if previous_window_pos != null:
			current_window_pos = Vector2i(
			lerp(DisplayServer.window_get_position().x, previous_window_pos.x, 0.2),
			lerp(DisplayServer.window_get_position().y, previous_window_pos.y, 0.2)
			)
			DisplayServer.window_set_position(current_window_pos)
			set_physics_process(false)
	
	
func squish_sprite(SquishScale: Vector2, duration: float) -> void:
	scale = SquishScale
	var tweeny : Tween = create_tween()
	
	tweeny.tween_property(
		self,
		"scale",
		Vector2.ONE,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	tweeny.play()
	
	if tweeny.finished:
		squish_finished.emit()
	

func Shake_Window() -> Vector2i:
	
	return Vector2i(rng.randi_range(-current_shake_force, current_shake_force), 
	rng.randi_range(-current_shake_force, current_shake_force))
