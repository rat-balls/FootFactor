extends Area2D

var angle = Vector2.ZERO
var speed = 300
var damage = 3
var slowing = true
var frameCount := 60
const updateRate := 30

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	angle = global_position.direction_to(player.global_position)

func _physics_process(delta):
	position += angle * speed * delta

func _on_timer_timeout():
	queue_free()
