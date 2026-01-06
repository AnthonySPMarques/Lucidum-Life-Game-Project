extends StaticBody2D

var top_ladder = false
@onready var toggle_checker: Area2D = $Toggle_Checker
@onready var to_flip: Timer = $ToFlip
@onready var mask: CollisionShape2D = $Mask


func _ready() -> void:
	toggle_checker.body_entered.connect(Toggle_On_Locker)
	toggle_checker.body_exited.connect(Toggle_Off_Locker)

	add_to_group("Climbable")

func _process(_delta: float) -> void:

	if (Input.is_action_pressed("Down") and !Input.is_action_pressed("Up")) \
	and top_ladder:
		#$Mask.rotation_degrees = 180
		$ToFlip.start()


func Toggle_On_Locker(body: Node2D):
	if body.is_in_group("Player"):
		top_ladder = true


func Toggle_Off_Locker(body: Node2D):
	if body.is_in_group("Player"):
		top_ladder = false


func _on_ToFlip_timeout() -> void:
	#$Mask.rotation_degrees = 0
	$ToFlip.stop()
