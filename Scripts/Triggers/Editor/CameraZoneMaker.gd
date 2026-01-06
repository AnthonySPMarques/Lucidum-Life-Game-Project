class_name CameraZonesManager extends Node

static var Phantoms_Children : Array[PhantomCamera2D]
static var Phantoms_Resources : Array[Resource]
static var Phantoms_InitialPos : Array[Vector2]

static var AreaZones_Children : Array[Area2D]
static var CollisionZones_Children : Array[CollisionShape2D]

static var Current_camerazone : PhantomCamera2D
static var StrongQuake : PhantomCameraNoiseEmitter2D
static var NOISE_STRONGQUAKE: int

##Main follow offset to put into the first camera
var main_offset : Vector2 = Vector2(0, -64)

#Like recalling _ready()
func update_appends() -> void:
	
	print(
		"[CameraZoneMaker.gd] Previous arrays are: ",
		Phantoms_Children, " and ", AreaZones_Children
	)
	
	if Phantoms_Children.size() > 0:
		Phantoms_Children.clear()
	if AreaZones_Children.size() > 0:
		AreaZones_Children.clear()
	if CollisionZones_Children.size() > 0:
		CollisionZones_Children.clear()
	
	"#Loops to get all the nodes and add to an Array#"
	for phantom in $Phantoms.get_children():
		if is_instance_valid(phantom):
			if phantom is PhantomCamera2D:
				Phantoms_Children.append(phantom)
				
				##Append all resources from all phantoms2D to a var
				Phantoms_Resources.append(phantom.get_tween_resource())
				
				##Store phanton initial positions
				Phantoms_InitialPos.append(phantom.global_position)
			
			#phantom.set_follow_offset(Vector2i(0, -128))
			
	for areazones in $Areas.get_children():
		if is_instance_valid(areazones):
			if areazones is Area2D:
				AreaZones_Children.append(areazones)
				if areazones.get_child(0) is CollisionShape2D:
					CollisionZones_Children.append(areazones.get_child(0))
	
	"#Connect all the nodes#"
	for areas in AreaZones_Children:
		if is_instance_valid(areas):
			if not areas.area_entered.is_connected(Set_CurrentZone):
				areas.area_entered.connect(Set_CurrentZone.bind(
					Phantoms_Children[areas.get_index()]
				))
			if not areas.area_exited.is_connected(UnSet_CurrentZone):
				areas.area_exited.connect(UnSet_CurrentZone.bind(
					Phantoms_Children[areas.get_index()]
				))
	print("[CameraZoneMaker.gd] Now they are
	\n Phantoms = ", Phantoms_Children,
	"\nAreas2Ds = ", AreaZones_Children, "\nCollisionZones = ", CollisionZones_Children)
	#Current_camerazone.
	
static func Set_Phantomcamera_tweenresource(phantom: PhantomCamera2D, twresource: PhantomCameraTween) -> void:
	phantom.set_tween_resource(twresource)
	

func Set_CurrentZone(Target: Node2D, CameraZone: PhantomCamera2D):
	
	print("Set CameraZone.name = ",CameraZone.name)
	if Target.name == "PersistentBox" or Target.name == "CameraBox":
		
		Current_camerazone = CameraZone
		Current_camerazone.follow_offset = main_offset
		
		CameraZone.set_priority(100)
		CameraZone.set_follow_target(Target)
		
		
		if Target is PlayerGetter:
			if Target.Player_node is Flockos:
				var flockos = Target.Player_node as Flockos
				flockos.areaS_current_zoomscale = CameraZone.zoom
				print(flockos.areaS_current_zoomscale)
		else:
			print(Target.name)
		
		

func UnSet_CurrentZone(Target: Node2D, CameraZone: PhantomCamera2D):
	print("UnSet CameraZone.name = ",CameraZone.name)
	if Target.name == "PersistentBox" or Target.name == "CameraBox":
		#print("unsetted")
		CameraZone.set_priority(0)
		CameraZone.set_follow_target(null)
		
static func reset_cameras_pos() -> void:
	"#Loops to set all the nodes to their original pos#"
	for phantom in Phantoms_Children:
		if phantom is PhantomCamera2D:
			phantom.global_position = Phantoms_InitialPos[phantom.get_index()]
			
			#phantom.set_follow_offset(Vector2i(0, -128))
