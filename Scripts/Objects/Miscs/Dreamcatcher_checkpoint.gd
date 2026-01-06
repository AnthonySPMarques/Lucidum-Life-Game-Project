class_name Checkpoint
extends Area2D

@onready var respawn_pos: Marker2D = $RespawnPos

##Properties stored inside a dicionary in case of wanting to restore more stuffs
#var player_properties_fiado : Dictionary = {"global_posiiton" : Vector2.ZERO}
var is_marked: bool = false #If player has marked his checkpoint in this node
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var effect_player: AnimationPlayer = $Sprite2D/EffectPlayer

func _process(_delta: float) -> void:
	if is_marked:
		animation_player.play("Marked")
		effect_player.play("Effect")
	else:
		animation_player.play("Unmarked")
		effect_player.play("RESET")
	$CollisionShape2D.disabled = is_marked
	
func mark_this_checkpoint() -> void:
	var get_checkpoints : Array = get_tree().get_nodes_in_group("Checkpoint")
	
	for checkpoint in get_checkpoints:
		checkpoint.is_marked = false
	
	self.is_marked = true
	

func apply_player_properties(_properties: Dictionary) -> void:
	##nothing to store inside a dicionary for now
	pass
	
func load_player_properties() -> void:
	
	if get_tree().get_nodes_in_group("Player")[0] != null:
		var get_player = get_tree().get_nodes_in_group("Player")[0] as Flockos
		#Properties to be loaded
		get_player.global_position = respawn_pos.global_position+Vector2(0, 128)
		
