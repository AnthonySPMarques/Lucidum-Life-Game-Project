extends Node2D

@export var NPC : NPC_Object

@onready var plake_content: Plake_Content = $Plake_Content
@onready var animation_tree: AnimationTree = $"../Sprite2D/AnimationPlayer/AnimationTree"

func on_plaky_npc_interaction_request() -> void:
	#print("interacted with npc ", str(name))
	plake_content.pop_up()
	
	if NPC.name.begins_with("Plaky_NP"):
		#print("Plaky_NPC")
		animation_tree["parameters/playback"].travel("On")

func on_plaky_npc_toggle_request() -> void:
	#print("stopped to interact with npc ", str(name))
	plake_content.pop_down()
	
	if NPC.name.begins_with("Plaky_NP"):
		#print("Plaky_NPC")
		animation_tree["parameters/playback"].travel("ToOff")
