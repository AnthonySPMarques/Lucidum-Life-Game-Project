extends Area2D
class_name Level_Changer

##How Flockos will enter scene:
##Thunder_Wrap,
##Exiting_From_Door,
##WalkingLeft,
##WalkingRight,
##Falling,
##HighJump
@export var Entrace_Mode: Flockos.Entering_Scene_Transition

##Int used to load level file with this number, example:
##Lullaby Blue - (Area_Number)
@export_range(1, 50) var Area_Number: int

##From what marker index position she will go when go to next scene
@export var Exit_ID: int

##Set current phantom camera to next scene
@export var Current_Phantom_Camera_ID: int
