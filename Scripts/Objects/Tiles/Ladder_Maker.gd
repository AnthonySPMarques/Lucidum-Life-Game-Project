@tool
class_name Ladder extends Node2D

@export_range(2, 200) var Ladder_Size = 3
const SNAP_GRID = 64

@onready var spriterect: NinePatchRect = $Sprite
@onready var ladder_area: Area2D = $LadderArea

func _process(_delta: float) -> void:
	
	spriterect.size.y = SNAP_GRID * Ladder_Size
	ladder_area.scale.y = Ladder_Size
