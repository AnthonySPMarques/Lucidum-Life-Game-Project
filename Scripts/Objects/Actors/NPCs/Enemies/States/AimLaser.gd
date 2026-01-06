extends EnemyStateMaker

@export var arrow_amount : int = 3
@export_range(0, 360, 0.1, "radians_as_degrees") var rad_arc_range : float = 0.0

var target : Flockos
var arrow : PackedScene = preload("res://Scenes/Objects/Projectiles/SheesparkArrow.tscn")

@onready var sheespark_idle: Node = $"../SheesparkIdle"
@onready var aimmer: Line2D = %Aimmer
@onready var pivot: Marker2D = %Pivot
@onready var arrow_pos: Marker2D = %ArrowPos
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var sprite: Sprite2D = %Sprite

func enter() -> void:
	pivot.position.x *= sprite.scale.x
	animation_tree["parameters/playback"].travel("Sheespark_AimLunarLaser_Loop")
	aimmer.clear_points()
	aimmer.set_as_top_level(true)
	#Also flip aim pos when sprite is mirrored
	aimmer.add_point(pivot.global_position, 0)
	aimmer.add_point(target.center_position, 1)
	print("Sheespark entered aimming state")
	super()
	
	
func physics_process(_delta: float) -> EnemyStateMaker:
	if !enemy.flip_x:
		pivot.position.x = -28
	else:
		pivot.position.x = 28
	
	if target == null:
		return sheespark_idle
	else:
		arrow_pos.rotation_degrees = rad_to_deg(pivot.get_angle_to(target.center_position))
		aimmer.set_point_position(0, pivot.global_position)
		aimmer.set_point_position(1, target.center_position)
		if animation_tree["parameters/playback"].get_current_node() == "Sheespark_AimLunarLaser_Loop":
			$"../../Sprite/BehaviorPlayer".play("AimLaser")
			
	return null

func shot_arrow() -> void:
	if target != null:
		var player_distance = pivot.global_position - target.center_position
		%ShotSFX.play()
		for Y in arrow_amount:
			var arrow_I = arrow.instantiate() as ArrowPattern
			arrow_I.position = arrow_pos.global_position
			var spread = rad_arc_range / (arrow_amount-1)
			arrow_I.global_rotation = (
				player_distance.angle() +
				spread * Y - rad_arc_range/2
			)

			enemy.call_deferred("add_sibling", arrow_I)
			print("Arrow added to scene")
			arrow_I.set_as_top_level(true)
	
	
func target_lost(area: Area2D) -> void:
	if area is PlayerHitbox:
		target = null
	
