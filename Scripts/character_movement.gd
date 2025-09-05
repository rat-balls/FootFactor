extends Node2D

@export var SPEED: float = 10.0

func _process(delta):
	
	var dir: Vector2 = get_input()
	translate(dir)
	
func get_input() -> Vector2:
	var input_direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	return input_direction * SPEED
