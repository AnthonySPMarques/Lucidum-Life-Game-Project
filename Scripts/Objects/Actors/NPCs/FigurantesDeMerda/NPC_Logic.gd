extends Node2D
class_name NPC_Logic

##When player is interacting with this NPC.
signal interaction_request
##When player is not anymore interacting with this NPC.
signal toggle_request

##If [b]true[/b] No need to push any button to popup the 
##dialog box or something else and neither stop player.
@export var auto_interact: bool = false
