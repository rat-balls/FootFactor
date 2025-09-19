extends Area2D

var walled = false

func _on_body_entered(body: Node2D) -> void:
	if(body.name == "InvisWalls"):
		print("walled2" )
		walled = true
