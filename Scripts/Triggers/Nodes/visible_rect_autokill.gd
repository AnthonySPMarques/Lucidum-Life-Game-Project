class_name AutoKill_VisibleRect extends VisibleOnScreenNotifier2D

func _enter_tree() -> void:
	screen_exited.connect(kill)
func kill() -> void:
	if get_parent() != null:
		get_parent().call_deferred("queue_free")
		
