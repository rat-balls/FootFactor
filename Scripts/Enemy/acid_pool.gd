extends Area2D

@onready var timer: Timer = $Timer
var damage = 3
var slowing = true

func _ready():
	var size_tween = create_tween()
	size_tween.tween_property(self, "scale", Vector2(0, 0), 3).set_delay(1.0)
	size_tween.play()

func _on_timer_timeout() -> void:
	queue_free()
