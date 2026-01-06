extends CanvasLayer
class_name MenuPause

const SETTINGSECTION_INDEX : int = 0 #Used to get the setting section node inside *Sections* var

#0 = settings section

@export var NodeSections : Array[Node] #An array for all sections
var flockos : Flockos
var Is_Pause_On_Screen : bool = false
var enable_fullscreen: bool = false

@onready var Menu_Control: Control = $MenuControl
@onready var TabMenu: TabContainer = $MenuControl/TabContainer
@onready var status: Control = $MenuControl/TabContainer/STATUS
#$@onready var nightmare_styles: Control = $"MenuControl/TabContainer/Nightmare Styles"
@onready var items: Control = $MenuControl/TabContainer/ITEMS
@onready var map: Control = $MenuControl/TabContainer/MAP
@onready var settings: Control = $MenuControl/TabContainer/SETTINGS
@onready var BoxText: RichTextLabel = $MenuControl/BoxDescTex/RichTextLabel

###Circular progress textures
@onready var circular_hp_progress: TextureProgressBar = %CircularHP
@onready var circular_hp_grid: ColorRect = %CircularHPGrid
@onready var hp_amount_label: Label = %HPAmountLabel

@onready var circular_aw_progress: TextureProgressBar = %CircularAW
@onready var circular_aw_grid: ColorRect = %CircularAWGrid
@onready var aw_amount_label: Label = %AWAmountLabel
###
@onready var resume: Button = $MenuControl/PlaceHolder/VBoxContainer/Container/Resume
@onready var setting: Button = $MenuControl/PlaceHolder/VBoxContainer/Container2/Setting
@onready var retry: Button = $MenuControl/PlaceHolder/VBoxContainer/Container3/retry

@onready var vbox_placeholder: VBoxContainer = $MenuControl/PlaceHolder/VBoxContainer




func _ready() -> void:
	
	if self.visible == true:
		hide()
	
	if get_parent() is Flockos:
		flockos = get_parent() as Flockos
	
	resume.grab_focus()
	
	
func _input(_event: InputEvent) -> void:
	
	
	#Input to pause
	if Input.is_action_just_pressed("EscSelect") or Input.is_action_just_pressed("EnterStart"):
		if Is_Pause_On_Screen == false:
			%FaderAnim.play(&"White")
			##TIMER##
			var timer_caseiro = Timer.new()
			TemporaryNodes.add_child(timer_caseiro)
			timer_caseiro.one_shot = true
			timer_caseiro.start(0.05)
			await timer_caseiro.timeout
			print("timer_caseiro from ", name ," is finished")
			timer_caseiro.queue_free()
			Show_Pause()
		
	if Is_Pause_On_Screen == true:
		if Input.is_action_just_pressed("Cancel_Request"):
			##TIMER##
			var timer_caseiro = Timer.new()
			TemporaryNodes.add_child(timer_caseiro)
			timer_caseiro.one_shot = true
			timer_caseiro.start(0.05)
			await timer_caseiro.timeout
			print("timer_caseiro from ", name ," is finished")
			timer_caseiro.queue_free()
			Hide_Pause()
		
		##Replace for pause menu the shortcut fullscreen
		if Input.is_action_just_pressed("ScreenChanger") and !Input.is_action_pressed("Ctrl_Key"):
			enable_fullscreen = !enable_fullscreen
			if enable_fullscreen:
				fullscreen()
			else:
				windowscreen()
	

	
func fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func windowscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _process(_delta: float) -> void:
	
	for containers in vbox_placeholder.get_children():
		for button in containers.get_children():
			if button is Button:
			
				when_button_hovered(button)
				if not button.pressed.is_connected(when_button_clicked):
					button.pressed.connect(when_button_clicked.bind(button))
	
func when_button_hovered(button: Button) -> void:
	button.pivot_offset = button.size/2
	var Tweenery = create_tween()
	
	if button.is_hovered() or button.has_focus():
		
		#Vector
		Tweenery.tween_property(button, ^"scale", 
		Vector2(1.1, 1.1), 
		0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		
		#Grow and shine button
		Tweenery.tween_property(button, ^"modulate", 
		Color(2.0, 2.0, 2.0), 
		0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		
		Tweenery.play()
		
	elif !button.is_hovered() and !button.has_focus():
		
		#shirnk and unshine button
		Tweenery.tween_property(button, ^"modulate", 
		Color(1.0, 1.0, 1.0), 
		0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		
		Tweenery.tween_property(button, ^"scale", 
		Vector2(1, 1), 
		0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		
		Tweenery.play()

	
func when_button_clicked(button: Button) -> void:
	match button:
		resume:
			Hide_Pause()
		setting:
			change_section(NodeSections[SETTINGSECTION_INDEX], vbox_placeholder)
		retry:
			Hide_Pause()
			flockos.States.change_state(flockos.DeathState)
			
			print("push a window asking for confirmation of going to title screen")

func change_section(section_show: Node, section_hide: Node) -> void:
	section_show.show()
	section_show.set_as_top_level(true)
	section_hide.hide()
	section_hide.set_as_top_level(false)

func change_descbox_text(text: String) -> void:
	BoxText.text = text
	
func Show_Pause() -> void:
	show()
	layer = 128
	
	#Auto set enable_fullscreen var
	enable_fullscreen = bool(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)

	#TabMenu.current_tab = 0
	#TabMenu.get_tab_bar().grab_focus()
	#Show esc menu on screen
	#change_dialogbox_text("Selection 1A")
	if Is_Pause_On_Screen == false:
		Is_Pause_On_Screen = true
	##Make the first button focus
	get_tree().paused = true
	
	##TIMER##
	var timer_caseiro = Timer.new()
	TemporaryNodes.add_child(timer_caseiro)
	timer_caseiro.one_shot = true
	timer_caseiro.start(0.05)
	await timer_caseiro.timeout
	print("timer_caseiro from ", name ," is finished")
	timer_caseiro.queue_free()
	
	resume.grab_focus()
	
	
	#SoundEffects.play_sound(SoundEffects.SFX_MENUAPPEAR)
	
func Hide_Pause() -> void:
	hide()
	layer = 1
	#Hide esc menu on screen
	get_tree().paused = false
	#SoundEffects.play_sound(SoundEffects.SFX_MENUQUIT)
	
	if Is_Pause_On_Screen == true:
		Is_Pause_On_Screen = false
		
