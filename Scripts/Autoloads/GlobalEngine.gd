extends Node

const CURRENT_GAME_SPEED : float = 1.0

var GamePlayer : GamePlayerManager

var GameSpeed : float = CURRENT_GAME_SPEED
var ChangingGameSpeed : bool = false

var arvore = null
var flockos : Flockos #Flockos will store herself here in the script
var Gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var random_number : RandomNumberGenerator

#var current_level : LevelLogic

func _ready() -> void:
	arvore = get_tree()
	
	#Shuffle random_number
	randomize()
	random_number = RandomNumberGenerator.new()

	
func change_gamespeed(speed : float, time_to_back : float) -> void:
	Engine.set_time_scale(speed)
	
	if time_to_back != -1:
		var timer_caseiro = Timer.new()
		TemporaryNodes.add_child(timer_caseiro)
		timer_caseiro.one_shot = true
		timer_caseiro.start(time_to_back)
		await timer_caseiro.timeout
		#print("timer_caseiro from GlobalEngine.gd is finished")
		timer_caseiro.queue_free()
		return_defaultspeed()
	
func return_defaultspeed() -> void:
	if ChangingGameSpeed == false:
		Engine.set_time_scale(CURRENT_GAME_SPEED)
