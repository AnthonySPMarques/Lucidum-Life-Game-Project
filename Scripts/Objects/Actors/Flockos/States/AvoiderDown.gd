@icon("res://Sprites/EditorTriggers/AvoiderDownIcon.png")
extends Slashs


const FALL2SHINE : float = 2000.0

@export_category("Velocity_Values")
@export var impulsed_gravity : float = 1.1
@export var Fall_Speed : float = 0.0
@export var Velocity_speed : float = 0.0

var go_to_jump = false
var can_fall = false
#var spring_audio = preload("res://tres/SFXs/Spring.tres")

var squish : float = 0.0
const MAX_SQUISH = 1.5

func enter() -> void:
	super()
	SoundEffects.play_sound(SoundEffects.SFX_WHOOSH)
	
	squish = 1.0
	
	player.velocity.y = 0
	
	#Restar trail position
	%PivotTrail.position = Vector2.ZERO
	
	%Trail.can_trail = false
	
	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	#Hitbox_Mask.disabled = false
	
	if not %AvoiderDown_Box.is_connected("body_entered", jump_on_enemie):
		%AvoiderDown_Box.body_entered.connect(jump_on_enemie)

func exit() -> void:
	%Trail.can_trail = false
	%ColorState.play("RESET")
	%Meele_Hitbox.disable_all_collision_shapes()
	%Meele_Hitbox.disable_clash_areas()
	#Hitbox_Mask.disabled = true
	
	go_to_jump = false
	can_fall = false
	
	
func set_fall():
	can_fall = true
	
func physics_process(delta : float) -> StateMaker:

	
	
	if player.can_be_knockbacked():
		return player.KnockBackState
	
	if player.is_small_area_on_water:
		"Create bubble particle"
		Triggers.create_ParticleTrigger(
		#Particle Scene
		preload("res://Scenes/Triggers/FXs/Particles/0.tscn"),
		#Particle Posiiton
		player.PivotCenter.global_position,
		#Particle Scale
		Vector2(player.sprite.scale.x, 1),
		#Particle Material
		preload("res://tres/Materials/WaterBubbleDeep.tres"),
		#Particle AmountRatio
		0.08);

	if player.is_immune == false:
		%Hitbox.enable_DefaultHitbox()
	
	if can_fall:
		player.velocity.y += Fall_Speed * impulsed_gravity
	else:
		player.velocity.y *= 0
		
	
	if go_to_jump:
		player.can_crazy_fly = true
		player.can_air_dash = true
		return player.JumpState
	
	if player.is_on_water:
		print("avoider down bubbles")
	
	var side : int = 0
	
	##Player shine based on velocity.y
	if player.velocity.y > FALL2SHINE:
		%ColorState.play("Shiny")
		%Trail.can_trail = true

	#Apply Direction
	if Input.is_action_pressed("Left") and !Input.is_action_pressed("Right"):
		side = -1
	elif Input.is_action_pressed("Right") and !Input.is_action_pressed("Left"):
		side = 1
	elif Input.is_action_pressed("Left") and Input.is_action_pressed("Right"):
		side = 0
	else:
		side = 0

	#Give player movement values:
	player.velocity.x = Velocity_speed * side

	#player.velocity.y += player.Gravity * delta * impulsed_gravity
	
	###Add squish force by impulsed gravity reduced by 2
	if squish < MAX_SQUISH:
		squish += impulsed_gravity * delta
	else:
		squish = MAX_SQUISH
	
	if player.is_on_floor():
		if Input.is_action_pressed("Jump"):
			return player.JumpState
		else:
			#Dust landing#
			Triggers.create_VisualEffectTrigger(8, 
			player.global_position, 
			Vector2(%FlockosSprite.scale.x, 1))
			
			Triggers.create_VisualEffectTrigger(5, 
			player.global_position + (Vector2(-10, 10)), 
			Vector2(%FlockosSprite.scale.x, 1))
			
			Triggers.create_VisualEffectTrigger(5, 
			player.global_position + (Vector2(10, 10)), 
			Vector2(%FlockosSprite.scale.x, 1))
			
			#Add key to fade gravity by starting from the squish value accreassed
			#by the impulse gravity force while falling:
			%Visuals.squish_sprite(
				Vector2(1.0 + (squish - 0.8), 1.0 - (squish - 1.0)),
				0.2)
			
			if player.velocity.y > 400:
				CameraZonesManager.StrongQuake.preview = true
				SoundEffects.play_sound(SoundEffects.SFX_STRONGSWORDSTAMP)
				
			if player.velocity.y > 150:
				player.is_landing = true
				
			
				
			return player.IdleState

	return null

func jump_on_enemie(enemie: Node2D) -> void:
	#Get enemie collision to jump on him
	go_to_jump = enemie is Enemy
