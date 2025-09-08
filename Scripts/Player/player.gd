extends CharacterBody2D


var movement_speed = 300.0
var hp = 80
@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

func _physics_process(delta: float) -> void:
	movement()

func movement():
	var x_mov = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	var y_mov = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	var mov = Vector2(x_mov, y_mov)
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false

	if mov != Vector2.ZERO:
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else: 
				sprite.frame = 1
			walkTimer.start()

	velocity = mov.normalized() * movement_speed
	move_and_slide()
