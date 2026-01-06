#@tool
## "Health_Bar.gd"
class_name Global_Interface extends CanvasLayer
#var Get_Array_Inside_Interface

##Signals
signal signal_when_maximum_Health_value_changed(Max_Health_value)
signal signal_when_current_Health_value_changed(Cur_Health_Value)
signal signal_when_maximum_AwakenEnergy_value_changed(Max_AwakenEnergy_Value)
signal signal_when_current_AwakenEnergy_value_changed(Cur_AwakenEnergy_Value)
signal signal_when_health_is_over
signal signal_when_awaken_energy_is_full
signal Change_general_values(Var: StringName, Value: int, Plus: bool)
###Consts
const HEALTH_BAR_SNAP = 6
const AWAKEN_ENERGY_BAR_SNAP = 4
const ERASE_SIZE = 0.03125
const MAX_Y_CANVAS_POSITION = 220
const IMAGINARY_RIGHTBOTTOM_RECTPOINT_POSITION = 280

@onready var flockos := User as Flockos \
if User is Flockos else null

##Exported variables
@export_category("Nodes")

@export var User : Node2D

##Exported variables
@export_category("Bar Modifiers")


#Maximum heatlh
var Health_Max = Flockos.Player_Data.Max_Health :
	set = change_Maximum_Health_Value

#Maximum Awaken
var Awaken_Max = Flockos.Player_Data.Max_Energy :
	set = change_Maximum_AwakenEnergy_Value

##Onready variables
#@onready var get_flockos = get_parent() as Flockos

#Current heatlh
var Health_Value : int = Flockos.Player_Data.Current_Health :
	set = change_Current_Health_Value
#Current awaken
var Awaken_Value : int = Flockos.Player_Data.Current_Energy :
	set = change_Current_AwakenEnergy_Value

var Nightflies_local : int = 0

##Divide pelo número máximo do health para determinar a ultima fração do valor do hp.
##Exemplo: Health = 32, Health_Rigid_Value_Divisor = 4. Logo a última fração do hp é igual a 
##Health / Health_Rigid_Value_Divisor = 32/4 = 8
@export var Health_Rigid_Value_Divisor : float = 4.0




##Variables
var health_size_left : float
var awaken_energy_size_left : float
var is_health_rigid = false
var line2d_health_range : float
var line2d_awaken_energy_range : float
var last_health_fraction : float
var is_health_full : bool
var is_awaken_energy_full : bool
var can_fill_health = false

var hitted = false
var Score_Value = 0

var Chances : int = 10
var MaxChances : int = 0

var lucidells : int = 0
var richtext_effects = "[tornado radius=2 freq=2][center][i]"

var current_scene

@onready var chances_label: RichTextLabel = %RichLabelChances
@onready var UI_visual_interface: Control = $Ui_Visual_Interface
@onready var UI_progress_bars: Control = $Ui_Visual_Interface/ProgressBars
@onready var UI_score_box: Control = $Ui_Visual_Interface/Score_Box
@onready var score_label: RichTextLabel = $Ui_Visual_Interface/Score_Box/Score_Label
@onready var nightfly_counter_text: RichTextLabel = $Ui_Visual_Interface/NightFly_Counter/Text
@onready var nightfly_hud: Control = $Ui_Visual_Interface/NightFly_Counter
@onready var label_namer: Label = %Label_Namer
@onready var lucidell_label: Label = $Ui_Visual_Interface/LucidellsCounter/LucidellLabel

#var dict : Dictionary = {
		#"Player": get_player_data.player_name,
		#"Health_Value": get_player_data.Current_Health,
		#"Health_Max": get_player_data.Max_Health
	#};
	

func _ready() -> void:
	##Store vars from player data
	MaxChances = flockos.Own_Player_Data.MaxChances
	Chances = MaxChances
	
	%HpIconAnimation.active = true
	current_scene = get_tree().current_scene
	
	
	#Get last health fraction:
	last_health_fraction = (
	round(Health_Max / Health_Rigid_Value_Divisor)
	)
	
	%Animations.active = true
	line2d_health_range = %Health_Line.get_point_position(1).x - %Health_Line.get_point_position(0).x
	
	if User is Flockos:
		change_Current_Health_Value(User.Player_Data.Current_Health)
		User.Player_Data.Current_Score = Score_Value
		User.Player_Data.Chances = Chances
	else:
		printerr("Parent of UI must be Flockos")
		breakpoint
	
	
	#blank_ui.body_entered.connect(blank_alpha.bind(UI_progress_bars))
	#blank_ui.body_exited.connect(fill_alpha.bind(UI_progress_bars))
	#
	#blank_score.body_entered.connect(blank_alpha.bind(UI_score_box))
	#blank_score.body_exited.connect(fill_alpha.bind(UI_score_box))
	
	#if player_path != null:
		#if is_instance_valid(get_node(player_path)):
			#get_player = get_node(player_path)
			
	
			
func _process(_delta: float) -> void:
	#%Circular_Health.material.set("shader_parameter/segments", Health_Max)
	label_namer.text = GlobalEngine.GamePlayer.Universe_2D_Trigger.current_level.name
	chances_label.text = "[center]" + str(Chances)
	lucidell_label.text = "Lucidells: " + str(lucidells)
	
	if Chances > MaxChances:
		Chances = MaxChances
	#Functions
	if User is Flockos:
		animate_icon()
	
		score_label.text = richtext_effects+"SCORE = %d" % Score_Value
		
		#if current_scene is LevelLogic:
			#
			#if current_scene.LevelType == current_scene.LevTypeEnum.Nightfly_Level:
				##nightfly_counter_text.text = "[ %d / %d ]" % [Nightflies_local, current_scene.Nightflies_To_Catch]
				#nightfly_counter_text.text = "%d" % current_scene.Nightflies_To_Catch
				#nightfly_hud.show()
			#else:
				#nightfly_hud.hide()
				
	is_health_rigid = bool(Health_Value < last_health_fraction)
	%Health_Line.modulate.a = $Ui_Visual_Interface.modulate.a
	
	if flockos.get_global_transform_with_canvas().get_origin().y < MAX_Y_CANVAS_POSITION and\
	flockos.get_global_transform_with_canvas().get_origin().x < IMAGINARY_RIGHTBOTTOM_RECTPOINT_POSITION:
		
		create_tween().tween_property(
			UI_visual_interface,
			"modulate:a",
			0.25,
			0.02
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	else:
		create_tween().tween_property(
			UI_visual_interface,
			"modulate:a",
			1,
			0.02
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
	
	#returns 192
	##Modify line range based on health/awaken_energy value
	#For health
	%Health_Line.set_point_position(1, 
	Vector2((Health_Value * HEALTH_BAR_SNAP) + %Health_Line.get_point_position(0).x, 
	%Health_Line.get_point_position(1).y))
	
	%UnderBarHP.size.x = Health_Max*HEALTH_BAR_SNAP
	%BoardHP.size.x = Health_Max*HEALTH_BAR_SNAP + 10
	
	Health_Value = snappedi(Health_Value, 1)
	
	#For awaken energy
	%AwakenEnergy_Line.set_point_position(1, 
	Vector2((Awaken_Value * AWAKEN_ENERGY_BAR_SNAP) + %AwakenEnergy_Line.get_point_position(0).x, 
	%AwakenEnergy_Line.get_point_position(1).y))
	Awaken_Value = snappedi(Awaken_Value, 1)
	
	if Awaken_Value == Awaken_Max:
		%AwakenIconAnimation.play("default")
	else:
		%AwakenIconAnimation.play("RESET")
	
	#Size left
	health_size_left = Health_Max - Health_Value
	awaken_energy_size_left = Awaken_Max - Awaken_Value

func shake() -> void:
	%Animations.get("parameters/playback").travel("Hurted")
	Health_Value = round(Health_Value)
	flockos.Player_Data.Current_Health = round(flockos.Player_Data.Current_Health)


func change_Current_Health_Value(value: int) -> void:
	
	if Health_Value > value: #Is to hurt
		hitted = true
		shake()
	#else: #Is to heal
		#if User is Flockos:
			#User.play_lighting_heal()
	#%Circular_Health.material.set("shader_parameter/value", Health_Value*ERASE_SIZE)
	
	
	
	#update current value
	Health_Value = value
	flockos.Own_Player_Data.Current_Health = value
	
	is_health_full = bool(Health_Value >= Health_Max)
	
	#Set limit by clamp
	Health_Value = clamp(Health_Value, 0, Health_Max)
	#emit_signal("signal_when_current_Health_value_changed")
	
	if Health_Value <= 0:
		emit_signal("signal_when_health_is_over")
		
func change_Maximum_Health_Value(value: int) -> void:
	
	Health_Max = round(value)
	flockos.Own_Player_Data.Max_Health = value
	
	
	if Health_Value != 0:
		Health_Value = value
		flockos.Player_Data.Current_Health = value
		
		
	emit_signal("signal_when_maximum_Health_value_changed")
	
func change_Current_AwakenEnergy_Value(value: int) -> void:
	
	#update current value
	Awaken_Value = value
	flockos.Own_Player_Data.Current_Energy = value
	
	is_awaken_energy_full = bool(Awaken_Value >= Awaken_Max)
	
	#Set limit by clamp
	Awaken_Value = clamp(Awaken_Value, 0, Awaken_Max)
	signal_when_current_AwakenEnergy_value_changed.emit()
	
	if Awaken_Value == Awaken_Max:
		signal_when_awaken_energy_is_full.emit()
		return
		
func change_Maximum_AwakenEnergy_Value(value: int) -> void:
	Awaken_Max = round(value)
	
	if Awaken_Value != 0:
		Awaken_Value = value

	emit_signal("signal_when_maximum_AwakenEnergy_value_changed")
	
func PLUS_Current_Score_Value(score: int) -> void:
	%ScoreEffectPlayer.play("Earned")
	Score_Value += score
	flockos.Player_Data.Current_Score = Score_Value


func _To_Change_general_values(Variable: StringName, Value: int, Plus:bool=true) -> void:
	var Var = str_to_var(Variable) #Get var from this script
	if Plus:
		Var += Value
	else:
		Var = Plus
	
	print(name, ".[UserInterfaceNode] Chances = ", Chances)

func animate_icon() -> void:
	if not hitted:
		if User is Flockos:
			
			if User.is_on_water:
				%Animations.get("parameters/playback").travel("Wet_Paused")
			else:
				if User.is_wet == true:
					%Animations.set("parameters/advance_condition/can_normal", false)
					%Animations.get("parameters/playback").travel("Wetted")
				else:
					%Animations.set("parameters/advance_condition/can_normal", true)
					%Animations.get("parameters/playback").travel("tonormal")
					
					if Health_Value < last_health_fraction:
						%Animations.set("parameters/advance_condition/Is_Rigid", true)
						%Animations.get("parameters/playback").travel("Rigided")
					
					else:
						%Animations.set("parameters/advance_condition/Is_Rigid", false)
						%Animations.get("parameters/playback").travel("Normal")
						
					
	pass
	
func animate_filling_Current_Health_Value(value: float) -> void:
	var goal = Health_Value + value
	var tweener = get_tree().create_tween()
	
	if goal < Health_Max:
		tweener.tween_property(self,
		"Health_Value",
		goal,
		0.5).as_relative().set_trans(
			Tween.TRANS_BACK
			).set_ease(Tween.EASE_OUT)
		
	else:
		tweener.stop()
		Health_Value = Health_Max
		
func set_hitted_false() -> void:
	hitted = false
		

		
func quit_flockos_wet():
	if User is Flockos:
		User.is_wet = false
