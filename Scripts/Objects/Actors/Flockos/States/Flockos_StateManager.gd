class_name StateMaker
extends Node

#
##Export Vars
##To set in Player animation function:
#export (String) var transition_name
#export (int) var transition_current
#
#export (String) var parameter_name
#export (String) var travel_destiny_name

#Define what states you can do cloudshot
@export var Can_CloudShot : bool = false
##If this state is where the player ducks.
@export var Ducking_State : bool = false

@export var AnimationCurrentTransition : String

# Pass in a reference to the player's kinematic body so that it can be used by the state
var player: Flockos

#var BlendTree = preload("res://tres/FlockosAnimationTree.tres")

func enter() -> void:
	player = owner as Flockos
	player.AnimationTraveler["parameters/Current_Animation_State/transition_request"] = AnimationCurrentTransition
	
func exit() -> void:
	pass

func input(_event: InputEvent) -> StateMaker:
	return null

func process(_delta: float) -> StateMaker:
	return null

func physics_process(_delta: float) -> StateMaker:
	return null
