extends Plugger
class_name RoboCopPlug

#From Node2Plug to Object To Pin Transfrom

@export var Object_To_Pin_Transform: Node2D
@export var RemoteNode: RemoteTransform2D
var MarkerNode: Marker2D

func _pin()->void: #Create marker2D to pin with a created remotetransform
	
	MarkerNode = Marker2D.new()
	
	
