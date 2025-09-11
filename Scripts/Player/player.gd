extends CharacterBody2D


var movement_speed = 300.0
var hp = 80
var maxhp = 80
var last_movement = Vector2.UP

var experience = 0 
var experience_level = 1 
var collected_experience = 0

#Attacks
const iceSpear: Resource = preload("res://Scenes/Prefabs/Player/Attacks/iceSpear.tscn")
const letter: Resource = preload("res://Scenes/Prefabs/Player/Attacks/letter.tscn")
const staby: Resource = preload("res://Scenes/Prefabs/Player/Attacks/staby.tscn")

#Attack Nodes
@onready var iceSpearTimer: Timer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer: Timer =  iceSpearTimer.get_node("%IceSpearAttackTimer")
@onready var letterTimer: Timer = get_node("%LetterTimer")
@onready var letterAttackTimer: Timer =  iceSpearTimer.get_node("%LetterAttackTimer")
@onready var staby_base: Node2D = get_node("%StabyBase")


#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldow = 0
var spell_size = 0
var additional_attack = 0

#iceSpear Nodes
var iceSpear_ammo = 0
var iceSpear_baseammo = 1
var iceSpear_attackspeed = 5
var iceSpear_level = 0

#Letter Nodes
var letter_ammo = 0
var letter_baseammo = 3
var letter_attackspeed = 3
var letter_level = 0

#Staby
var staby_ammo = 3
var staby_level = 1

#Enemy Related
var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel: Panel = %LevelUp
@onready var upgradeOptions: VBoxContainer = %UpgradeOptions
@onready var snd_level: AudioStreamPlayer2D = %snd_level
@onready var itemOptions = preload("res://Scenes/Prefabs/Utility/item_options.tscn")

func _ready():
	upgrade_character("icespear1")
	attack()
	set_expBar(experience, calculate_experiencecap())

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
		last_movement = mov
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else: 
				sprite.frame = 1
			walkTimer.start()

	velocity = mov.normalized() * movement_speed
	move_and_slide()

func attack():
	if(iceSpear_level > 0):
		iceSpearTimer.wait_time = iceSpear_attackspeed * (1 - spell_cooldow)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if(letter_level > 0):
		letterTimer.wait_time = letter_attackspeed * (1 - spell_cooldow)
		if letterTimer.is_stopped():
			letterTimer.start()
	if staby_level > 0:
		spawn_staby()


func _on_iceSpear_timer_timeout():
	iceSpear_ammo += iceSpear_baseammo + additional_attack
	iceSpearAttackTimer.start()

func _on_iceSpear_attack_timer_timeout():
	if iceSpear_ammo > 0:
		var iceSpear_attack = iceSpear.instantiate()
		iceSpear_attack.position = position
		iceSpear_attack.target = get_random_target()
		iceSpear_attack.level = iceSpear_level
		add_child(iceSpear_attack)
		iceSpear_ammo -= 1
		if iceSpear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()


func _on_letter_timer_timeout() -> void:
	letter_ammo += letter_baseammo + additional_attack
	letterAttackTimer.start()

func _on_letter_attack_timer_timeout() -> void:
	if letter_ammo > 0:
		var letter_attack = letter.instantiate()
		letter_attack.position = position
		letter_attack.last_movement = last_movement
		letter_attack.level = letter_level
		add_child(letter_attack)
		letter_ammo -= 1
		if letter_ammo > 0:
			letterAttackTimer.start()
		else:
			letterAttackTimer.stop()

func spawn_staby():
	var staby_spawn = staby.instantiate()
	staby_spawn.global_position = global_position
	staby_base.add_child(staby_spawn)
	
	#update staby
	var get_stabies = staby_base.get_children()
	for i in get_stabies:
		if i.has_method("update_staby"):
			i.update_staby()
	

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
	hp -= clamp(damage - armor, 1.0, 999.0)


func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level +=1
		experience = 0
		exp_required = calculate_experiencecap()
		level_up()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
		
	set_expBar(experience, exp_required)
	
func calculate_experiencecap():
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

func level_up():
	snd_level.play()
	lblLevel.text = str("Level: ", experience_level)
	var levelTween = levelPanel.create_tween().set_parallel(true)
	levelTween.tween_property(levelPanel, "position", Vector2(440, 110.0), 0.2)
	levelTween.play()
	levelPanel.visible = true
	var options = 0
	var options_max = 3
	while options < options_max:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	
	get_tree().paused = true

func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			iceSpear_level = 1
			iceSpear_baseammo += 1
		"icespear2":
			iceSpear_level = 2
			iceSpear_baseammo += 1
		"icespear3":
			iceSpear_level = 3
		"icespear4":
			iceSpear_level = 4
			iceSpear_baseammo += 2
		"letter1":
			letter_level = 1
			letter_baseammo += 1
		"letter2":
			letter_level = 2
			letter_baseammo += 1
		"letter3":
			letter_level = 3
			letter_attackspeed -= 0.5
		"letter4":
			letter_level = 4
			letter_baseammo += 1
		"staby1":
			staby_level = 1
			staby_ammo = 1
		"staby2":
			staby_level = 2
		"staby3":
			staby_level = 3
		"staby4":
			staby_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldow += 0.05
		"ring1","ring2":
			additional_attack += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
	attack()
	
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(1400, 500)
	get_tree().paused = false
	calculate_experience(0)

func get_random_item():
	var dbList = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: 
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item":
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					pass
				else:
					dbList.append(i)
		else:
			dbList.append(i)
	if dbList.size() > 0:
		var randomitem = dbList.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null
			
