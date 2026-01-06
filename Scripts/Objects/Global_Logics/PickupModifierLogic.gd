##Resource used to create multiple types of pickups
class_name Pickup_Logic_Resource extends Resource

enum ItemType {CommonRigid = 1, Static = 2}
@export var item_Type : ItemType = ItemType.CommonRigid


#@export var Property_To_Modify : String = "" ##Key
#@export var Value_Modifier : int = 1 ##Value



#Item name for animation player
@export_enum(
"HealthCapsule_Small", "HealthCapsule_Big",
"HealthCapsule_Max","AwakenCell_Small",
"AwakenCell_Big","AwakenCell_Max",
"Nightfly","SmallLucidelCoin",
"BigLucidelCoin", "GigaLucidelCoin",
"ChancePlus"
) var PickUp_Display : String = ""
@export var Property_To_Modify : Dictionary = {};
