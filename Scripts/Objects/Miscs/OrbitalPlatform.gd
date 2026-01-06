@tool
extends Marker2D
class_name Orbit_Platform

@export var Radius : Vector2 = Vector2.ONE*256
@export var rotation_speed : float = 5.0

var platforms : Array = []
var orbitangle_offset = 0

var prev_platform_count :int= 0

func _physics_process(delta: float) -> void:
	
	if prev_platform_count != get_child_count():
		prev_platform_count = get_child_count() #Store to the next validation
		_search_platform()
	
	orbitangle_offset += TAU * delta / float(rotation_speed)
	orbitangle_offset = wrapf(orbitangle_offset, -PI, PI) #To -180 to 180 degrees
	_update_platform()
	
func _update_platform() -> void:
	if platforms.size() != 0:
		var spacing = TAU / float(platforms.size())
		for Y in platforms.size():
			var newpos = Vector2.ZERO
			newpos.x = cos(spacing * Y + orbitangle_offset) * Radius.x
			newpos.y = sin(spacing * Y + orbitangle_offset) * Radius.y
			platforms[Y].position = newpos
			
func _search_platform() -> void:
	platforms = []
	for platformies in get_children():
		if platformies.is_in_group("Orbital_To_Rotate"):
			platforms.append(platformies)
