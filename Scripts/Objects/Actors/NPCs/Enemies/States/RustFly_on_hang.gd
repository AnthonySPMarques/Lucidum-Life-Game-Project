extends EnemyStateMaker

var get_player : Flockos

@onready var RustFly_fly: EnemyStateMaker = %RustFly_Fly
@onready var animation_tree: AnimationTree = $"../../Sprite/AnimationTree"
@onready var mask_player: CollisionShape2D = $"../../Area2Ds/PlayerDetector/CollisionShape2D"

func enter() -> void:
	super()
	animation_tree["parameters/playback"].travel("RustFly_Hanging")
	mask_player.disabled = false
	
	###!!!POTENTIAL ERROR OR FPS DROP VARIABLE!!!###
	#push_warning("POTENTIAL ERROR OR FPS DROP VARIABLE,\n at [get_player] variable from node ", name)
	if get_tree().get_nodes_in_group("Player").size() > 0:
		get_player = get_tree().get_nodes_in_group("Player")[0] if\
		get_tree().get_nodes_in_group("Player")[0] is Flockos else null
	
func physics_process(_delta: float) -> EnemyStateMaker:
	
	enemy.velocity.y = 0
	
	if get_player != null:
		if %PlayerDetector.overlaps_body(get_player):
			print(get_player, " is on RustFly area")
			return RustFly_fly
	
	return null
