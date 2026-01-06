class_name Slashs
extends StateMaker

##Patterns to use as slot or whatever else, this is only a logic to get each type
##of state attack
enum ENUM_Attacks_Type {
	
	##When pressed main attack input in idle states
	Idle,
	##When pressed main attack input in run states
	Run,
	##When pressed main attack input in down states
	Crounched,
	##When pressed main attack input while on air states
	OnAir,
	##When pressed main attack input while on dashes states
	Dash,
	##When pressed main attack input while on wall states
	OnWall,
	##When pressed main attack input while on climbing states
	OnClimb,
	##When pressed main attack input while on hanging states
	OnHang,
	
	##When pressed alt attack input in idle states
	IdleAlt,
	##When pressed alt attack input in run states
	RunAlt,
	##When pressed alt attack input in down states
	CrounchedAlt,
	##When pressed alt attack input while on air states
	OnAirAlt,
	##When pressed alt attack input while on dashes states
	DashAlt,
	##When pressed alt attack input while on wall states
	OnWallAlt,
	##When pressed alt attack input while on climbing states
	OnClimbAlt,
	##When pressed alt attack input while on hanging states
	OnHangAlt,
	##[Main_Attack_Input + UP] while on floor
	UP_plus_MAINATTACK,
	##[Main_Attack_Input + DOWN] while on air
	DOWN_plus_MAINATTACK,
	
	##If this state peforms a special attack (Something that fills almost the entire screen)
	SPECIAL_ATTACK
	}

@export_category("Global properties")
##You may use this variable to get how an attack state works or what type of attack state is
@export var State_Attack_Type : ENUM_Attacks_Type = ENUM_Attacks_Type.Idle
##Time that player have to execute the next combo
@export var Attack_Duration := 0.5
#Delay for execute
@export var Time_ToInput := 0.2

#Check if the player executed the combo
var Executed = false
var TimerSlash : float
var TimerInput : float

@export var NextSlashState : StateMaker

"Call States"

#-----------------------------#
#
func _ready() -> void:
	
	add_to_group("SlashState")

func physics_process(_delta: float) -> StateMaker:

	if player.Hitted:
		return player.KnockBackState
	return null
