extends Node2D

func _ready() -> void:
	Client.new_run.emit()
