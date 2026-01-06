class_name PlayerResources extends Resource

const MAXIMUM_SCORE_LIMIT : int = 999_999_999_999

@export_category("Names")
@export var player_name : String = "Flockos"

##Decided starting value is to be 14
@export_category("Int/Floats/Vectors")
@export var Current_Health : int = 14
@export var Max_Health : int = 14

@export var Current_Energy : int = 0
@export var Max_Energy : int = 14

@export var Nightflies_saved : Dictionary = {
	"Sadness": 0,"Fear": 0,"Hate": 0,
	"Courage": 0,"Joyness": 0};
	
@export var Current_Score : int = 0

#Lives
@export var MaxChances : int = 9
var Chances : int = MaxChances


@export_category("Slots")
#They are there just for example
@export var Skills_In_Inventory : Array = ["AvoiderDown", "LightingKite"]
@export var Equipped_Skills : Array = []

#Store properties:
var lucidells : int = 0 #Amount of coins that are called lucidells
var current_position : Vector2

#@export var Properties_as_dicts : Dictionary = {
	##Strings#
	#"Owner" : Node2D,
	##INTS#
	#"Current_Health" : 14,
	#"Max_Health" : 14,
	#"Current_Awaken_Energy": 0,
	#"Max_Awaken_Energy": 0,
	#"Current_Score": 0,
	#"Chances": 9, #Cuz cat has nine lifes lol
	#
	##ARRAYS#
	#"Skills": ["AvoiderDown", "LightingKite"], ##Skills adquired
	#"Equipped_Skill": [], ##Equipped Skills that can be performed in game
	#
	##DICTS#
	#"Saved_Nightflies": {"Sadness": 0,"Fear": 0,"Hate": 0,"Courage": 0,"Joyness": 0},
	#
	##VECTORS#
	#"Current_Player_Position": Vector2.ZERO
#}
