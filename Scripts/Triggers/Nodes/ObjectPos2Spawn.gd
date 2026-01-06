class_name SpawnerPos
extends Marker2D

@export var ObjectToAdd : PackedScene
@onready var visible_mask: VisibleOnScreenNotifier2D = $VisibleMask

var object_is_alive : bool = false

func _enter_tree() -> void:

	if not $VisibleMask.screen_entered.is_connected(get_parent().spawn_object) and get_child_count() <= 1:
		$VisibleMask.screen_entered.connect(
		get_parent().spawn_object.bind(ObjectToAdd, self))
				
	
