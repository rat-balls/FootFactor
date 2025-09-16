extends Control

var level = "res://Scenes/MainScenes/world.tscn"
@onready var options: Panel = $Options
@onready var btn_play: Button = $btn_play

func _ready():
	options.visible = false
	btn_play.visible = true

func _on_btn_play_button_up():
	var _level = get_tree().change_scene_to_file(level)

func _on_btn_menu_pressed():
	options.visible = true
	btn_play.visible = false

func _on_btn_back_pressed():
	_ready()
