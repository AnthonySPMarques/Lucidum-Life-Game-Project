extends Control
class_name Plake_Content

@onready var tween_maker_panel: TweenMaker = $TweenMaker_Panel
@onready var panel_container: Control = $PanelContainer

func _ready() -> void:
	
	panel_container.scale = Vector2.ZERO
	
func pop_up() -> void:
	tween_maker_panel._tween_property(
		tween_maker_panel.Object_to_tween,
		tween_maker_panel.Property_path,
		tween_maker_panel.final_tween_destiny,
		tween_maker_panel.Tween_duration,
		tween_maker_panel.Ease_Tween,
		tween_maker_panel.Transi_Tween)
	
func pop_down() -> void:
	tween_maker_panel._tween_property(
		tween_maker_panel.Object_to_tween,
		tween_maker_panel.Property_path,
		Vector2.ZERO,
		tween_maker_panel.Tween_duration,
		tween_maker_panel.Ease_Tween,
		tween_maker_panel.Transi_Tween)
