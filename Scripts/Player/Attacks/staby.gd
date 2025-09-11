extends Area2D

var level = 1
var hp = 1
var speed = 100
var damage = 5
var knockback_amount = 100
var attack_size = 1.0

var target = Vector2.ZERO
var angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(0)
	match level:
		1:
			hp = hp
			speed = speed
			damage = damage
			knockback_amount = knockback_amount
			attack_size = attack_size
			
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.2+attack_size,0.2+attack_size), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func _physics_process(delta):
	position += angle * speed * delta

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		queue_free()

func _on_timer_timeout():
	queue_free()
