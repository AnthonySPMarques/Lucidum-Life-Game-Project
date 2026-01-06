extends Sprite2D
@export var ghost_trail_lifetime : float = 1.0

func _ready() -> void:
	
	var tween = create_tween()
	#tween_property
	#(object: Object, property: NodePath, final_val: Variant, duration: float)
	
	tween.tween_property(self, 
	"self_modulate:a", 
	0.0,
	ghost_trail_lifetime / $Play.get_playing_speed() ).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.play()
	
	if not tween.finished.is_connected(kill):
		tween.finished.connect(kill)
	
func _process(_delta : float) -> void:
	$Play.play("i")
	
func kill() -> void:
	if is_instance_valid(self):
		self.call_deferred("queue_free")
