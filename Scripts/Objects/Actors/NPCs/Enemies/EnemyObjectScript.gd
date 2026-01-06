#@tool
extends Enemy
class_name EnemyObject

@export var Animation_Tree : AnimationTree
@export var enable_flip_sprite : bool = true
@export var flip_x : bool

var current_direction : String = "" #For chase player state

var get_arvore
var flockos : Flockos

@onready var invencibility_time: Timer = $Invencibility_Time

@onready var state_player: AnimationPlayer = $StatePlayer

@onready var EnemyStates: Node = $EnemyMachine_State

##Timer to play while is invencible
#@export_range(0.000, 10.000) var TimerLeft : float = 0.1

func _enter_tree() -> void:
	#push_warning("Possible reason of the error ERROR: Condition p_elem->_root != this is true.")
	pass
	
	
func _ready() -> void:
	flockos = GlobalEngine.flockos
	get_arvore = get_tree()
	
	
	if get_parent() is SpawnerPos:
		var spawner = get_parent() as SpawnerPos
		spawner.visible_mask.scale = EnemieVisibilityMask.scale
		spawner.visible_mask.rect = EnemieVisibilityMask.rect
		
	print("Enemy spawned ",name, " ",  global_position)
	#reparent(enemy_spawner)
	if Animation_Tree != null:
		Animation_Tree.active = true
	
	if EnemieVisibilityMask != null:
		EnemieVisibilityMask.show()
	if get_parent() is SpawnerPos:
		get_parent().object_is_alive = true
	
	#group to all objects that hurts
	if not is_in_group("Hurters") and not is_in_group("Enemies"):
		self.add_to_group("Hurters", true)
		self.add_to_group("Enemies", true)

	if EnemyArea2DBody != null:
		print("enemy area2D is not null")
		if not EnemyArea2DBody.body_entered.is_connected(Enemy_Body_entered):
			EnemyArea2DBody.body_entered.connect(Enemy_Body_entered)
			print("EnemyArea2DBody.body_entered is connected to func Enemy_Body_entered")
		
		
		if not EnemyArea2DBody.area_entered.is_connected(create_clash):
			EnemyArea2DBody.area_entered.connect(create_clash)
			print("EnemyArea2DBody.area_entered is connected to func create_clash")
		
		if not EnemyArea2DBody.area_entered.is_connected(EnemyArea2D_entered):
			EnemyArea2DBody.area_entered.connect(EnemyArea2D_entered)
			print("EnemyArea2DBody.area_entered is connected to func EnemyArea2D_entered")
		
		if not EnemyArea2DBody.area_exited.is_connected(EnemyArea2D_exited):
			EnemyArea2DBody.area_exited.connect(EnemyArea2D_exited)
			print("EnemyArea2DBody.area_entered is connected to func EnemyArea2D_exited")
			
	else:
		printerr("AreaBody Missed", EnemyArea2DBody)
	
	
	print(name, " entered_tree")
	#print("Enemy has been getted tree in get_arvore = ", get_arvore)
	#
	if enable_flip_sprite:
		$Mask.scale.x = -1 if flip_x else 1
		%Enemy_HitBox.scale.x = -1 if flip_x else 1
		$Sprite.scale.x = -1 if flip_x else 1
	else:
		$Mask.scale.x = 1
		%Enemy_HitBox.scale.x = 1
		$Sprite.scale.x = 1
	
	if EnemieVisibilityMask != null:
		if not EnemieVisibilityMask.screen_exited.is_connected(only_delete):
			EnemieVisibilityMask.screen_exited.connect(only_delete)
			print("screen_exited is connect in ", name)
	
	invencible = false
	if not invencibility_time.timeout.is_connected(end_invencibility):
		invencibility_time.timeout.connect(end_invencibility)
		print("invencibility_time is connect in ", name)
		
	EnemyStates.init(self)
	
	
func _unhandled_input(event: InputEvent) -> void:
	EnemyStates.input(event)
	#print("Applyed unhandled_input on enemy state machines")
	
func _process(delta: float) -> void:
	
	
	#Add Inv frames to enemy
	#if self.is_inside_tree(): #5 = enemies
		#set_collision_layer_value(5, !invencible)
		
	EnemyStates.process(delta)
	#print("Applyed process on enemy state machines")
	
	flip_x = false if flockos.global_position.x > global_position.x else true
		
func _physics_process(delta: float) -> void:
	EnemyStates.physics_process(delta)
	#print("Applyed physics process on enemy state machines")
	
	move_and_slide()
	
	if enable_flip_sprite:
		$Mask.scale.x = -1 if flip_x else 1
		%Enemy_HitBox.scale.x = -1 if flip_x else 1
		$Sprite.scale.x = -1 if flip_x else 1
	else:
		$Mask.scale.x = 1
		%Enemy_HitBox.scale.x = 1
		$Sprite.scale.x = 1
	
	#$Node2D/Label.text = str(hp)
	#if invencible:
		#modulate.a = 0.2
	#else:
		#modulate.a = 1


func hitted(damage : float, delay_inv : float = 0.0) -> void:
	print("Enemy hitted")
	#call_create_clash(self)
	if not invencible:
		if delay_inv > 0.0000:
			invencible = true
		%LabelAP.play("Pulse")
		%HealthLabel.text = str(hp)
		damage_amount(damage)
		invencibility_time.start(delay_inv)
		if state_player.current_animation != null:
			state_player.stop(true)
			state_player.play(&"Flash")
	
	

func end_invencibility() -> void:
	invencible = false
	print("enemy is invencible")
