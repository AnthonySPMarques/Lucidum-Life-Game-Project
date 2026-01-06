class_name EnemyStateMaker
extends Node

# Pass in a reference to the player's kinematic body so that it can be used by the state
var enemy: EnemyObject

#var BlendTree = preload("res://tres/FlockosAnimationTree.tres")

func enter() -> void:
	enemy = owner as EnemyObject
	
func exit() -> void:
	pass

func input(_event: InputEvent) -> EnemyStateMaker:
	return null

func process(_delta: float) -> EnemyStateMaker:
	return null

func physics_process(_delta: float) -> EnemyStateMaker:
	return null
