extends CharacterBody2D


var movement_speed = 300.0
var hp = 80

#Attacks
var staby: Resource = preload("res://Scenes/Prefabs/Player/Attacks/staby.tscn")

#Attack Nodes
@onready var stabyTimer: Timer = get_node("%StabyTimer")
@onready var stabyAttackTimer: Timer =  stabyTimer.get_node("%StabyAttackTimer")

#Staby Nodes
var staby_ammo = 0
var staby_baseammo = 2
var staby_attackspeed = 2.5
var staby_level = 1

#Enemy Related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

func _ready():
	attack()

func _physics_process(_delta: float) -> void:
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

func attack():
	if(staby_level > 0):
		stabyTimer.wait_time = staby_attackspeed
		if stabyTimer.is_stopped():
			stabyTimer.start()


func _on_staby_timer_timeout():
	staby_ammo += staby_baseammo
	stabyAttackTimer.start()

func _on_staby_attack_timer_timeout():
	if staby_ammo > 0:
		var staby_attack = staby.instantiate()
		staby_attack.position = position
		staby_attack.target = get_random_target()
		staby_attack.level = staby_level
		add_child(staby_attack)
		staby_ammo -= 1
		if staby_ammo > 0:
			stabyAttackTimer.start()
		else:
			stabyAttackTimer.stop()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_hurt_box_hurt(damage: Variant) -> void:
	hp -= damage
	print(hp)
