extends EnemyStateMaker

@export_range(0.0, 10.0) var Tween_Duration : float = 1.0
@export var Path_2D : PathFollow2D

@onready var mask_player: CollisionShape2D = $"../../Area2Ds/PlayerDetector/CollisionShape2D"
@onready var animation_tree: AnimationTree = $"../../Sprite/AnimationTree"
@onready var RustFly_Firing_State: Node = %RustFly_Firing
@onready var time_to_shot: Timer = $TimeToShot

var go_to_fire_state : bool = false

func enter() -> void:
	super()
	go_to_fire_state = false
	animation_tree["parameters/playback"].travel("RustFly_Flying_Loop")
	mask_player.disabled = true

	var tween = create_tween()
	tween.tween_property(Path_2D, "progress_ratio", 1.0,
	Tween_Duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).set_delay(0.025)
	await tween.finished
	time_to_shot.start(0.2)
	await time_to_shot.timeout
	go_to_fire_state = true
	
func process(_delta: float) -> EnemyStateMaker:
	if go_to_fire_state:
		
		return RustFly_Firing_State
	return null
