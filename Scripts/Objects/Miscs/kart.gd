class_name Kart
extends CharacterBody2D

@export_range(0.0, 10.0) var ImpulseX_Multiplier : float = 1.5

var get_bagagem : Node2D

@onready var kart_area_2d: Area2D = $KartArea2D

func _physics_process(_delta: float) -> void:
	
	move_and_slide()
	
	if velocity.x != 0:
		$AnimationPlayer.play("Kart")
	else:
		$AnimationPlayer.play("KartOff")
	
	if is_on_floor():
		var tweni = create_tween()
		tweni.tween_property(%Sprite, 
		"rotation",
		get_floor_normal().angle() + deg_to_rad(90.0), 
		0.1).set_ease(Tween.EASE_IN_OUT)
		tweni.play()
		
		var tweni2 = create_tween()
		tweni2.tween_property(%CollisionShape2D_PlayerSolid, 
		"rotation",
		get_floor_normal().angle() + deg_to_rad(90.0), 
		0.1).set_ease(Tween.EASE_IN_OUT)
		tweni2.play()
		
	else:
		
		%Sprite.rotation_degrees = 0
		%CollisionShape2D.rotation_degrees = 90
	#Get Flockos node and apply impulse to her when
	#she leaves the kart
	if get_bagagem != null:
		if get_bagagem is Flockos:

			if Input.is_action_just_pressed("Jump"):
				get_bagagem.is_impulsed_by_forces = true
				get_bagagem.velocity.x += velocity.x*ImpulseX_Multiplier
				
				
func _on_KartArea2D_entered(body: Node2D) -> void:
	if body is Flockos:
		print(self.name, " entered on ", body.name)
		$AudioStreamPlayer2D.play()
		get_bagagem = body
		$AnimationPlayer.play("Kart")
		$MovementPlug.Can_Move = true


func _on_KartArea2D_exited(body: Node2D) -> void:
	print(self.name, " exited on ", body.name)
	if body is Flockos:
		get_bagagem = null
