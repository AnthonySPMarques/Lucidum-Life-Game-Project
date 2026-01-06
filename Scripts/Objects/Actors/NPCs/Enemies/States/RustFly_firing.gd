extends EnemyStateMaker

const SHINING_BULLET = preload("res://Scenes/Objects/Projectiles/ShiningBullet.tscn")

@export_range(0.0, 10.0) var Tween_Duration : float = 1.0
@export var Bullet_Speed : float = 400.0

@onready var mask_player: CollisionShape2D = $"../../Area2Ds/PlayerDetector/CollisionShape2D"
@onready var animation_tree: AnimationTree = $"../../Sprite/AnimationTree"
@onready var RustFly_OnHang_State: Node = %RustFly_OnHang
@onready var RustFly_Fly_StateNode: Node = %RustFly_Fly
@onready var pos_l: Marker2D = $"../../Sprite/PosL"
@onready var pos_r: Marker2D = $"../../Sprite/PosR"

var go_hang_state : bool = false

var can_fire : bool = true

func enter() -> void:
	can_fire = true
	super()
	go_hang_state = false
	animation_tree["parameters/playback"].travel("RustFly_Shooting")
	mask_player.disabled = true
	
	var tween = create_tween()
	tween.tween_property(RustFly_Fly_StateNode.Path_2D, "progress_ratio", 0.0,
	Tween_Duration).set_trans(Tween.TRANS_SINE).set_ease(
		Tween.EASE_IN).set_delay(0.1)
	await tween.finished
	go_hang_state = true

func process(_delta: float) -> EnemyStateMaker:
	shoot()
	
	if go_hang_state:
		return RustFly_OnHang_State
	return null

func shoot()-> void:
	
	if is_instance_valid(SHINING_BULLET):
		if can_fire:
			can_fire = false
			%GatlingGunSound.play()
			var bullet_ins_L = SHINING_BULLET.instantiate()
			var bullet_ins_R = SHINING_BULLET.instantiate()
			
			bullet_ins_L.global_position = pos_l.global_position
			bullet_ins_L.rotation_degrees = -45.0
			bullet_ins_L.linear_speed = Bullet_Speed
			enemy.get_parent().get_parent().get_parent().call_deferred("add_sibling" ,bullet_ins_L)
			bullet_ins_L.set_as_top_level(true)
			
			bullet_ins_R.global_position = pos_r.global_position
			bullet_ins_R.rotation_degrees = -135
			bullet_ins_R.linear_speed = Bullet_Speed
			enemy.get_parent().get_parent().get_parent().call_deferred("add_sibling" ,bullet_ins_R)
			bullet_ins_R.set_as_top_level(true)
			
			##TIMER##
			var timer_caseiro = Timer.new()
			TemporaryNodes.add_child(timer_caseiro)
			timer_caseiro.one_shot = true
			timer_caseiro.start(0.15)
			await timer_caseiro.timeout
			print("timer_caseiro from ", name ," is finished")
			timer_caseiro.queue_free()
			
			can_fire = true
		#push_error("Must set bullets to be created and plan a way to remove the path2D parent from scene!")
