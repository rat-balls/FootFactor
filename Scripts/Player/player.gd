extends CharacterBody2D


var movement_speed = 300.0
var hp = 80

var experience = 0 
var experience_level = 1 
var collected_experience = 0
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

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")

func _ready():
	attack()
	set_expBar(experience, calculate_expriencecap())

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

func _on_hurt_box_hurt(damage: Variant, _angle, _knockback) -> void:
	hp -= damage 
	print(hp)


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_expriencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level +=1
		lblLevel.text = str("Level: ",experience_level)
		experience = 0
		exp_required = calculate_expriencecap()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
		
	set_expBar(experience, exp_required)
	
func calculate_expriencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap + 95 + (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
	return exp_cap

func set_expBar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value
