extends Node3D

@onready var camera_pivot: Node3D = $CameraPivot

var level = "res://Scenes/MainScenes/world.tscn"
@onready var options: Panel = $Options
@onready var btn_play: Button = $btn_play

func _ready():
	options.visible = true
	btn_play.visible = true

func _on_btn_play_button_up():
	var _level = get_tree().change_scene_to_file(level)

func _on_btn_menu_pressed():
	options.visible = true
	btn_play.visible = false

func _on_btn_back_pressed():
	_ready()

func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(0,value)

func _on_check_box_toggled(toggled_on):
	AudioServer.set_bus_mute(0,toggled_on)
