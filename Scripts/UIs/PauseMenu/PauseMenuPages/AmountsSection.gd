extends Control
class_name AmountSection

@onready var LabelCoins: Label = %Coins
@onready var LabelNightfly_white: Label = %Nightfly_white
@onready var LabelLives: Label = %Lives

func _ready() -> void:
	##Get all this shit from PlayerData
	if GlobalEngine.flockos != null:
		##Assing values
		pass
