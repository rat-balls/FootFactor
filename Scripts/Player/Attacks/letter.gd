extends Area2D

var level = 1
var hp = 9999
var speed = 200
var damage = 3
var knockback_amount = 50
var attack_size = 1.0

var last_movement = Vector2.ZERO
var angle = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	match level:
		1:
			hp = hp
			speed = speed
			damage = damage
			knockback_amount = knockback_amount
			attack_size = attack_size
	
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1.0, -0.25), last_movement.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * 500
		Vector2.RIGHT, Vector2.LEFT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1.0, -0.25)) * 500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * 500
		Vector2(1, 1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * 500
	
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	var scale_tween = create_tween().set_parallel(true)
	scale_tween.tween_property(self, "scale", Vector2(1 + attack_size, 1 + attack_size), 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	var final_speed = speed
	speed = speed/5.0
	var speed_tween = create_tween().set_parallel(true)
	speed_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	
	var angle_tween = create_tween()
	var set_angle = randi_range(0, 1)
	angle = angle_less if set_angle == 1 else angle_more
	
	for i in range(6):
		angle_tween.tween_property(self, "angle", angle_less if (i + set_angle) % 2 == 0 else angle_more, 2)
	
	angle_tween.play()

func _physics_process(delta):
	position += angle * speed * delta

func _on_timer_timeout():
	emit_signal("remove_from_array")
	queue_free()
