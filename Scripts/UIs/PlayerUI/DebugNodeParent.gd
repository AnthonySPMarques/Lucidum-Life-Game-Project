extends CanvasLayer

@onready var state: Label = %stateLabel
@onready var velocity: Label = %velocityLabel
@onready var bools: Label = %boolsLabel
@onready var debug_maker: Control = %Debug_Maker
@onready var fps: Label = %FPSLabel

var flockos : Flockos

func _ready() -> void:
	flockos = get_parent()
	layer = 125 if visible else 0

func _process(_delta: float) -> void:
	
	if flockos != null:
		if is_instance_valid(flockos):
			state.visible = flockos.Show_Debug_States
			state.text = ("STATES : " + str(flockos.States.Default_State.name))
			
			velocity.visible = flockos.Show_Debug_Velocity
			velocity.text = ("VELOCITY X : " + str(flockos.velocity.x) + "   ||   VELOCITY Y : " + str(flockos.velocity.y))
			
			bools.visible = flockos.Show_Debug_Bool
			bools.text = ("BOOLS: \n[Can Airdash] = " + str(flockos.can_air_dash) +
			"\n[Can Climb] = " + str(flockos.can_climb) +
			"\n[Charged Slash] = " + str(%UserInterface.is_awaken_energy_full) +
			"\n[Can Jump] = " + str(flockos.can_jump) +
			"\n[In Water] = " + str(flockos.is_on_water) +
			"\n[Is On Floor] = " + str(flockos.is_on_floor()) +
			"\n[Is Wet] = " + str(flockos.is_wet) +
			"\n[Is immune] = " + str(flockos.is_immune) +
			"\n[Hitted] = " + str(flockos.Hitted) +
			"\n[is_dead] = " + str(flockos.is_dead) +
			"\n[is_dead_globally] = " + str(GlobalEngine.flockos.is_dead) +
			"\n[Is On Slider] = " + str(GlobalEngine.flockos.is_on_slider))
			
			fps.text = "FPS: " + str(Engine.get_frames_per_second()) + "\n PIF: " + \
			str(Engine.get_physics_interpolation_fraction())
			
			
			debug_maker.visible = flockos.Show_Debug_Cheats
	
func _on_Toggler_toggled(button_pressed: bool) -> void:
	if button_pressed == true:
		$"%DebugPrinters".hide()
	else:
		$"%DebugPrinters".show()
