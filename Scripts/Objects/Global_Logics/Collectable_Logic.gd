extends Node2D
class_name Collectable_Logic

signal picked_up(by: PhysicsBody2D)

@export_category("Item properties")
@export var Pickup_Resource : Pickup_Logic_Resource
@export var Ignore_Body_Error_print : bool = false
@export var Ignore_Area_Error_print : bool = false
@export var Ignore_VisibilityArea_Remove : bool = false
@export var has_life_time : bool = false
@export var has_gravity : bool = true
@export_range(5., 30.) var life_time : float = 5.#How much time the item will be displayed in viewport before disappear
@export var apply_random_impulse : bool = false
@export var apply_straight_impulse : bool = true
##RIGIDBODY PROPERTIES##
@export_range(1.0, 1000.0) var MaxItemRigidImpulse_X : float = 100.0
@export_range(-1000.0, 1000.0) var MinItemRigidImpulse_X : float = -100.0
@export_range(0.0, 1000.0) var MaxItemRigidImpulse_Y : float = 500.0
@export_range(0.0, 1000.0) var MinItemRigidImpulse_Y : float = 100.0
@export var PickedUp_Sound : int = 37
##CHARACTERBODY PROPERTIES##
@export var CharacterBody_height_impulse : float = 200.0
@export_category("Item physics")
#Capsule gravity
@export var item_gravity_modifier : float = 1.0

@export_category("NodePaths")

@export var Item_Area2D : Area2D = null
@export var Item_Body : PhysicsBody2D = null
@export var Parent : Node2D = null

#Check if the capsule is a CharacterBody2D
var get_player : Flockos = Flockos.new()
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var LifeTime : float = 0


func _enter_tree() -> void:
	
	if Item_Body == null and Ignore_Body_Error_print == false:
		printerr("Item node: '%s' have his body path [null] and cannot be applied any physic behaivor." % self)
	
	if Item_Area2D == null and Ignore_Area_Error_print == false:
		printerr("Item node: '%s' have his area path [null] and cannot be applied any value modifiment to the body that collided with it." % self)
		
	if Item_Area2D != null:
		if not Item_Area2D.body_entered.is_connected(area_has_collided):
			Item_Area2D.body_entered.connect(area_has_collided)
		
	if not self.is_in_group("Collectables"):
		self.add_to_group("Collectables")
		
	if Item_Body is CharacterBody2D:
		Item_Body.velocity.y = 0

func apply_physics_process(delta: float) -> void:
	##Apply simple gravity
	if Item_Body is CharacterBody2D:
		
		if not Item_Body.is_on_floor():
			Item_Body.velocity.y += (gravity * delta) * item_gravity_modifier
		else:
			Item_Body.velocity.y = 0
		Item_Body.move_and_slide()
		
func area_has_collided(body: Node2D) -> void:
	SoundEffects.play_sound(PickedUp_Sound)
	emit_signal("picked_up", body)
	
func kill() -> void:
	
	if not Parent:
		self.call_deferred("queue_free")
	else:
		Parent.call_deferred("queue_free")
		
