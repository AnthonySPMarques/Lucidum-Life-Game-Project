class_name Enemy extends CharacterBody2D

const BIG_AWAKEN_CELL = preload("uid://br8famj3d7k88")
const BIG_HEALTH_CAPSULE = preload("uid://ceb255lmao30h")
const SMALL_AWAKEN_CELL = preload("uid://bihx2gr1dvf85")
const SMALL_HEALTH_CAPSULE = preload("uid://c2cbaj6378akv")

@export_category("Spawns")
@export var random_items : Array[PackedScene] = [
	null,
	null,
	null,
	null,
	null,
	null,
	BIG_AWAKEN_CELL,
	BIG_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_HEALTH_CAPSULE,
	SMALL_AWAKEN_CELL,
	SMALL_AWAKEN_CELL,
	SMALL_AWAKEN_CELL,
	SMALL_AWAKEN_CELL,
	SMALL_AWAKEN_CELL,
	SMALL_AWAKEN_CELL,
]
var random_selected_items : Array[PackedScene]
var item_spawn_amount : int = 1

###Exported Vars###
@export_category("NodePaths")
#Enemie's common hitbox to taking damages
@export var EnemyArea2DBody : Area2D
#Set enemie's current center
@export var EnemieCenterPath : Node2D
#Get enemie visibility mask:
@export var EnemieVisibilityMask: VisibleOnScreenNotifier2D
#Get Maker2D to set the default position where the labels from damage shows up
@export var Damage_Counter_Position : Node2D
#Node to create when enemy dies
#@export var When_Die_Node_To_Add : PackedScene

@export_category("Booleans")
#Can show damage counter
@export var Damage_Counter_Show : bool = true
#Used when the enemie has a linear movement
@export var Enable_enemie_path_follow : bool = false #Path follow
#Enable gravity
#@export var enable_linear_velocity : bool = false
#@export var instant_velocity : bool = false
#@export var stopped : bool = false
@export var stop_when_hitted : bool = false
#When true the enemie will not have any reaction after die and will just
#be removed from the scene
@export var enable_auto_death : bool = true


@export_category("Int/Floats")
#Divide pela velocidade da força do sopro
@export var Mass : float = 1.0
@export var damage_force : float = 1.0 #Damage counter
#Enemy health bar
@export var hp : float = 4.0 #Health
#Score when die
@export_range(0, 999_999) var score_reward : int = 1
#Gravity force
@export_range(0.0, 10_000.0) var max_gravity_force : float = 5800
#@export_range(0, 10_000.0) var linear_speed : float = 50.0
#@export_range(0, 10_000.0) var acceleration_speed : float = 20.0
#@export_range(0, 10_000.0) var friction_speed : float = 20.0

###Vars###
var invencible : bool = false
#AGORA SIM DÁ PRA FAZER PARTICÚLAS QUICAVÈIS!
#var sparkticles = preload("res://Scenes/Objects/Effects/FireSpark.tscn")
var child_added : bool = false
var direction_movement : int = -1
var being_blowed : bool = false
var is_area2D_overlaping_attack : bool = false
var blow = null

var itemspawnamountrn = randi_range(1, item_spawn_amount)

var gravity_engine : float = ProjectSettings.get_setting("physics/2d/default_gravity")

"Signals"
#signal enemie_killed #when enemie dies and is removed from tree
signal enemy_health_is_over #When enemie dies but doesn't get removed from tree
signal enemy_is_hit

"CREATE CLASH"

func create_clash(area: Area2D) -> void:
	#print("clash created by reacting with area2D ", area.name)
	#Create animated sprite node for clash effect
	if area.is_in_group("ClashAreas"):
	
		var rn = GlobalEngine.random_number.randi_range(0, 1)
		##create_VisualEffectTrigger(Effect_ID, Position, Scale)
		Triggers.create_VisualEffectTrigger(rn, area.global_position, Vector2.ONE)
		
		if area.get_parent() is ClashAreaNode:
			area.get_parent().play_attackhit()
	
	
	
#func call_create_clash(node: Node2D) -> void:
	#
	#var rn = GlobalEngine.random_number.randi_range(0, 1)
	###create_VisualEffectTrigger(Effect_ID, Position, Scale)
	#Triggers.create_VisualEffectTrigger(rn, node.global_position, Vector2.ONE)
	#
	#if node.get_parent() is ClashAreaNode:
		#node.get_parent().play_attackhit()
		#
		
#Call on every hit
func damage_amount(damage : float) -> void:
	hp -= damage
	
	if hp < 1:
		if enable_auto_death == true:
			if self.is_in_group("Hurters"):
				remove_from_group("Hurters")
			kill()
		else:
			if self.is_in_group("Hurters"):
				remove_from_group("Hurters")
			enemy_health_is_over.emit()
	else:
		enemy_is_hit.emit()
		
func Enemy_Body_entered(body: Node2D) -> void:
	
	if body.is_in_group("InstantKill_Enemies"):
		#print(body, " instant killed ", name)
		kill_notbyplayer()
	
		
func EnemyArea2D_entered(_area: Area2D) -> void:
	is_area2D_overlaping_attack = true
	
func EnemyArea2D_exited(_area: Area2D) -> void:
	is_area2D_overlaping_attack = false
	
	
func only_delete() -> void:
	#print("Enemy Only Deleted")
	if get_parent() is SpawnerPos:
		get_parent().object_is_alive = false
		
	self.call_deferred("queue_free")

func kill() -> void:
	randomize()
	push_warning("Possible Array issues in [", name, "] \nscript in variable random_selected_items")
	if has_signal("enemy_health_is_over"):
		enemy_health_is_over.emit()
	
	#print("Enemy spawned items -> -> ->" ,random_selected_items)
	##Disconnect signals
	if EnemyArea2DBody.area_entered.is_connected(create_clash):
		EnemyArea2DBody.area_entered.disconnect(create_clash)
		
		if EnemyArea2DBody.area_entered.is_connected(EnemyArea2D_entered):
			EnemyArea2DBody.area_entered.disconnect(EnemyArea2D_entered)
		if EnemyArea2DBody.area_exited.is_connected(EnemyArea2D_exited):
			EnemyArea2DBody.area_exited.disconnect(EnemyArea2D_exited)
	
	var flockos = get_tree().get_nodes_in_group("Player")[0]
	SoundEffects.play_sound(SoundEffects.SFX_DESTROYEREXPLOSION)
	Triggers.create_ParticleTrigger(
		preload("res://Scenes/Triggers/FXs/Particles/3.tscn"), 
		EnemieCenterPath.global_position,
		Vector2i.ONE,
		preload("res://tres/Materials/ShiningSparkles_Particles_explosion.tres"),
		1.0)
	Triggers.create_VisualEffectTrigger(15, global_position)
	if flockos is Flockos:
		flockos.UI.PLUS_Current_Score_Value(score_reward)
	#if When_Die_Node_To_Add != null:
		#get_parent().add_child(When_Die_Node_To_Add.instantiate())
	if itemspawnamountrn > 0:
		#print("if itemspawnamountrn > 0 returned TRUE")
		for Y in itemspawnamountrn:
			if Y < itemspawnamountrn: #To avoid bypass limit
				#print("Y < itemspawnamountrn returned TRUE")
				
				var choosen_num : int = GlobalEngine.random_number.randi_range(0, random_items.size()-1)
				
				random_selected_items.append(random_items[choosen_num])
				#print(random_items[choosen_num])
		#Loop 5 times appending a random number inside an array
		if random_selected_items.size() > 0 and random_selected_items.size() <= item_spawn_amount:
			#print("			random_selected_items.size() > 0 returned TRUE")
			#print("			...", name, " random_selected_items.size() = ", random_selected_items.size())
			for Y in random_selected_items:
				#print("Selected spawn item is ", Y)
				if Y != null:
					#print("Y != null returned TRUE")
					var item_spw = Y.instantiate() as MiscCollectables
					
					item_spw.set_as_top_level(true)
					item_spw.has_life_time = true
					item_spw.global_position = EnemieCenterPath.global_position
					#item_spw.apply_random_impulse = true
					#print("added item ", item_spw.name, " to scene")
					call_deferred("add_sibling", item_spw)
	else:
		print("if itemspawnamountrn > 0 returned FALSE")
	#print("random_selected_items Array from ", name ," is ", random_selected_items)
	if get_parent() is SpawnerPos:
		get_parent().object_is_alive = false
	
	##TIMER##
	var timer_caseiro = Timer.new()
	TemporaryNodes.add_child(timer_caseiro)
	timer_caseiro.one_shot = true
	timer_caseiro.start(0.001)
	await timer_caseiro.timeout
	#print("timer_caseiro from ", name ," is finished")
	timer_caseiro.queue_free()
	
	#print("called queue_free from enemy logic")
	queue_free()


func kill_notbyplayer() -> void:
	randomize()
	push_warning("Possible Array issues in [", name, "] \nscript in variable random_selected_items")
	if has_signal("enemy_health_is_over"):
		enemy_health_is_over.emit()
	
	#print("Enemy spawned items -> -> ->" ,random_selected_items)
	##Disconnect signals
	if EnemyArea2DBody.area_entered.is_connected(create_clash):
		EnemyArea2DBody.area_entered.disconnect(create_clash)
		
		if EnemyArea2DBody.area_entered.is_connected(EnemyArea2D_entered):
			EnemyArea2DBody.area_entered.disconnect(EnemyArea2D_entered)
		if EnemyArea2DBody.area_exited.is_connected(EnemyArea2D_exited):
			EnemyArea2DBody.area_exited.disconnect(EnemyArea2D_exited)
	
	SoundEffects.play_sound(SoundEffects.SFX_DESTROYEREXPLOSION)
	Triggers.create_ParticleTrigger(
		preload("res://Scenes/Triggers/FXs/Particles/3.tscn"), 
		EnemieCenterPath.global_position,
		Vector2i.ONE,
		preload("res://tres/Materials/ShiningSparkles_Particles_explosion.tres"),
		1.0)
	Triggers.create_VisualEffectTrigger(15, global_position)

	#if When_Die_Node_To_Add != null:
		#get_parent().add_child(When_Die_Node_To_Add.instantiate())
	if itemspawnamountrn > 0:
		#print("if itemspawnamountrn > 0 returned TRUE")
		for Y in itemspawnamountrn:
			if Y < itemspawnamountrn: #To avoid bypass limit
				#print("Y < itemspawnamountrn returned TRUE")
				
				var choosen_num : int = GlobalEngine.random_number.randi_range(0, random_items.size()-1)
				
				random_selected_items.append(random_items[choosen_num])
				#print(random_items[choosen_num])
		#Loop 5 times appending a random number inside an array
		if random_selected_items.size() > 0 and random_selected_items.size() <= item_spawn_amount:
			#print("			random_selected_items.size() > 0 returned TRUE")
			#print("			...", name, " random_selected_items.size() = ", random_selected_items.size())
			for Y in random_selected_items:
				#print("Selected spawn item is ", Y)
				if Y != null:
					#print("Y != null returned TRUE")
					var item_spw = Y.instantiate() as Node2D
					
					item_spw.set_as_top_level(true)
					item_spw.global_position = EnemieCenterPath.global_position
					#item_spw.apply_random_impulse = true
					#print("added item ", item_spw.name, " to scene")
					call_deferred("add_sibling", item_spw)
	else:
		print("if itemspawnamountrn > 0 returned FALSE")
	#print("random_selected_items Array from ", name ," is ", random_selected_items)
	if get_parent() is SpawnerPos:
		get_parent().object_is_alive = false
	
	##TIMER##
	var timer_caseiro = Timer.new()
	TemporaryNodes.add_child(timer_caseiro)
	timer_caseiro.one_shot = true
	timer_caseiro.start(0.001)
	await timer_caseiro.timeout
	#print("timer_caseiro from ", name ," is finished")
	timer_caseiro.queue_free()
	#print("called queue_free from enemy logic")
	queue_free()
