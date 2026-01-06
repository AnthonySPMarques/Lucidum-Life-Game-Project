extends Node2D
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D

func _process(_delta: float) -> void:
	
	if $Path2D/PathFollow2D.get_child_count() == 0:
		call_deferred("queue_free")
	
