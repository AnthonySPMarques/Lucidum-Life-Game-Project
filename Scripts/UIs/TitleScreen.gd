extends CanvasLayer
class_name TitleScreen

@onready var start_button: Button = %Start
@onready var continue_button: Button = %Continue
@onready var settings_button: Button = %Settings
@onready var quit_button: Button = %Quit


func _ready() -> void:
	TranslationServer.set_locale("en")
	start_button.grab_focus()
	
	start_button.pressed.connect(when_button_pressed.bind(start_button.name))
	continue_button.pressed.connect(when_button_pressed.bind(continue_button.name))
	settings_button.pressed.connect(when_button_pressed.bind(settings_button.name))
	quit_button.pressed.connect(when_button_pressed.bind(quit_button.name))
	
func _unhandled_input(event: InputEvent) -> void:
	
	if not (start_button.has_focus() and continue_button.has_focus() and settings_button.has_focus()\
	and quit_button.has_focus()):
		if event.is_action_pressed(&"Down") or event.is_action_pressed(&"Up"):
			start_button.grab_focus()
	
func when_button_pressed(names: String) -> void:
	match names:
		"Start": SceneChanger.change_to_scene(SceneChanger.LULLABY_BLUE_1)
		"Continue": print("Change section to load datas")
		"Settings": print("Change section to settings")
		"Quit": get_tree().quit()
	


func _on_start_mouse_exited() -> void:
	start_button.release_focus()

func _on_continue_mouse_exited() -> void:
	continue_button.release_focus()
	
func _on_settings_mouse_exited() -> void:
	settings_button.release_focus()
	
func _on_quit_mouse_exited() -> void:
	quit_button.release_focus()
