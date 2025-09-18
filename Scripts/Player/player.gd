extends CharacterBody2D

var normal_movement_speed = 300.0
var movement_speed = 300.0
var hp = 8000
var maxhp = 8000
var last_movement = Vector2.UP

var time = 0

var experience = 0 
var experience_level = 1
var collected_experience = 0

#Attacks
const letterOpener: Resource = preload("res://Scenes/Prefabs/Player/Attacks/letterOpener.tscn")
const letter: Resource = preload("res://Scenes/Prefabs/Player/Attacks/letter.tscn")
const staby: Resource = preload("res://Scenes/Prefabs/Player/Attacks/staby.tscn")

#Attack Nodes
@onready var letterOpenerTimer: Timer = get_node("%LetterOpenerTimer")
@onready var letterOpenerAttackTimer: Timer =  letterOpenerTimer.get_node("%LetterOpenerAttackTimer")
@onready var letterTimer: Timer = get_node("%LetterTimer")
@onready var letterAttackTimer: Timer =  letterOpenerTimer.get_node("%LetterAttackTimer")
@onready var staby_base: Node2D = get_node("%StabyBase")


#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attack = 0

#letterOpener Nodes
var letterOpener_ammo = 0
var letterOpener_baseammo = 0
var letterOpener_attackspeed = 2
var letterOpener_level = 0

#Letter Nodes
var letter_ammo = 0
var letter_baseammo = 0
var letter_attackspeed = 5
var letter_level = 0

#Staby
var staby_ammo = 0
var staby_level = 0

#Enemy Related
var enemy_close = []

var mov: Vector2 = Vector2.ZERO

@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel: Panel = %LevelUp
@onready var upgradeOptions: VBoxContainer = %UpgradeOptions
@onready var snd_level: AudioStreamPlayer2D = %snd_level
@onready var itemOptions = preload("res://Scenes/Prefabs/Utility/item_options.tscn")
@onready var health_bar = %HealthBar
@onready var lbl_timer = $GUILayer/GUI/lblTimer
@onready var collected_weapons = $GUILayer/GUI/CollectedWeapons
@onready var collected_skills = $GUILayer/GUI/CollectedSkills
@onready var item_container: Resource = preload("res://Scenes/Prefabs/Utility/item_container.tscn")
@onready var death_panel: Panel = %DeathPanel
@onready var lbl_result: Label = %lbl_Result

func _ready():
	set_expBar(experience, calculate_experiencecap())
	_on_hurt_box_hurt(0, 0, 0, false)

func _physics_process(_delta: float) -> void:
	movement()

func movement():
	var x_mov = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	var y_mov = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	mov = Vector2(x_mov, y_mov)
	
	match mov:
		Vector2(-1, 1):
			sprite.frame = 6
			#up_right
		Vector2(1, 1):
			sprite.frame = 3
			#down_right
		Vector2(-1, -1):
			sprite.frame = 7
			#up_left
		Vector2(1, -1):
			sprite.frame = 4
			#down_left
		Vector2.UP:
			sprite.frame = 0
		Vector2.DOWN:
			sprite.frame = 1
		Vector2.RIGHT:
			sprite.frame = 2
		Vector2.LEFT:
			sprite.frame = 5
	
	if mov != Vector2.ZERO:
		last_movement = mov

	velocity = mov.normalized() * movement_speed
	move_and_slide()

func attack():
	if(letterOpener_level > 0):
		letterOpenerTimer.wait_time = letterOpener_attackspeed * (1 - spell_cooldown)
		if letterOpenerTimer.is_stopped():
			letterOpenerTimer.start()
	if(letter_level > 0):
		letterTimer.wait_time = letter_attackspeed * (1 - spell_cooldown)
		if letterTimer.is_stopped():
			letterTimer.start()
	if staby_level > 0:
		spawn_staby()


func _on_letterOpener_timer_timeout():
	letterOpener_ammo += letterOpener_baseammo + additional_attack
	letterOpenerAttackTimer.start()

func _on_letterOpener_attack_timer_timeout():
	if letterOpener_ammo > 0:
		var letterOpener_attack = letterOpener.instantiate()
		letterOpener_attack.position = position
		letterOpener_attack.target = get_random_target()
		letterOpener_attack.level = letterOpener_level
		add_child(letterOpener_attack)
		letterOpener_ammo -= 1
		if letterOpener_ammo > 0:
			letterOpenerAttackTimer.start()
		else:
			letterOpenerAttackTimer.stop()


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
	var get_stabies = staby_base.get_children()
	if not get_stabies.size() > 0:
		var staby_spawn = staby.instantiate()
		staby_spawn.global_position = global_position
		staby_base.add_child(staby_spawn)
		staby_spawn.update_staby()

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

func _on_hurt_box_hurt(damage: Variant, _angle, _knockback, slowing) -> void:
	if slowing:
		movement_speed -= movement_speed * 0.7
		var slow_tween = create_tween()
		slow_tween.tween_property(self, "movement_speed", normal_movement_speed, 1.5).set_ease(Tween.EASE_OUT)
		slow_tween.play()
	hp -= clamp(damage - armor, 1.0, 999.0)
	health_bar.max_value = maxhp
	health_bar.value = hp
	if(damage != 0):
		var flash_tween = sprite.create_tween()
		if slowing:
			flash_tween.tween_property(sprite, "modulate",  Color(5, 2.5, 2.5), 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			flash_tween.play()
			flash_tween.tween_property(sprite, "modulate",  Color(2.5, 2.5, 2.5), 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			flash_tween.play()
			flash_tween.tween_property(sprite, "modulate",  Color(1.0, 1.0, 1.0), 1.3)
			flash_tween.play()
		else:
			flash_tween.tween_property(sprite, "modulate",  Color(2.5, 0.5, 0.5), 0.1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			flash_tween.play()
			flash_tween.tween_property(sprite, "modulate",  Color(1.0, 1.0, 1.0), 0.1)
			flash_tween.play()
	if hp <= 0:
		death()

func death():
	death_panel.visible = true
	get_tree().paused = true
	var tween = death_panel.create_tween()
	tween.tween_property(death_panel, "position", Vector2(440, 110.0), 1.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >= 300:
		lbl_result.text= "You win"
	else:
		lbl_result.text= "You are dead"
	

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
		experience_level += 1
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
		exp_cap = 95 + (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
	return exp_cap

func set_expBar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func level_up():
	health_bar.visible = false
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
		"letter_opener1":
			letterOpener_level = 1
			letterOpener_attackspeed -= 0.5
			letterOpener_baseammo += 1
		"letter_opener2":
			letterOpener_level = 2
			letterOpener_baseammo += 1
		"letter_opener3":
			letterOpener_level = 3
			letterOpener_attackspeed -= 0.5
		"letter_opener4":
			letterOpener_level = 4
			letterOpener_attackspeed -= 1
			letterOpener_baseammo += 2
		"letter1":
			letter_level = 1
			letter_baseammo += 2
		"letter2":
			letter_level = 2
			letter_attackspeed -= 0.5
			letter_baseammo += 2
		"letter3":
			letter_level = 3
			letter_attackspeed -= 1
		"letter4":
			letter_level = 4
			letter_attackspeed -= 1
			letter_baseammo += 2
		"staby1":
			staby_level = 1
			staby_ammo += 1
		"staby2":
			staby_level = 2
			staby_ammo += 1
		"staby3":
			staby_level = 3
			staby_ammo += 2
		"staby4":
			staby_level = 4
			staby_ammo += 2
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 50.0
			normal_movement_speed += 50.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.50
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.1
		"ring1","ring2":
			additional_attack += 1
		"food":
			hp += 20
			hp = clamp(hp, 0, maxhp)
			health_bar.max_value = maxhp
			health_bar.value = hp
	adjust_ui_collection(upgrade)
	attack()
	health_bar.visible = true
	
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
	if(experience_level == 2):
		for i in UpgradeDb.UPGRADES:
			if i in collected_upgrades: 
				pass
			elif i in upgrade_options:
				pass
			elif UpgradeDb.UPGRADES[i]["type"] == "item":
				pass
			elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0 and UpgradeDb.UPGRADES[i]["type"] == "weapon":
				var to_add = true
				for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
					if not n in collected_upgrades:
						to_add = false
				if to_add:
					dbList.append(i)
			elif UpgradeDb.UPGRADES[i]["type"] == "weapon":
				dbList.append(i)
	else:
		for i in UpgradeDb.UPGRADES:
			if i in collected_upgrades: 
				pass
			elif i in upgrade_options:
				pass
			elif UpgradeDb.UPGRADES[i]["type"] == "item":
				pass
			elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
				var to_add = true
				for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
					if not n in collected_upgrades:
						to_add = false
				if to_add:
					dbList.append(i)
			else:
				dbList.append(i)
	if dbList.size() > 0:
		var randomitem = dbList.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func change_time(argtime = 0):
	time = argtime
	var get_minutes = int(time/60)
	var get_seconds = time % 60
	if get_minutes < 10:
		get_minutes = str(0, get_minutes)
	if get_seconds < 10:
		get_seconds = str(0, get_seconds)
	lbl_timer.text = str(get_minutes, ":", get_seconds)

func adjust_ui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if(get_type != "item"):
		var get_collected_display_names = []
		for i in collected_upgrades:
			get_collected_display_names.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_display_names:
			var new_item_container = item_container.instantiate()
			new_item_container.upgrade = upgrade
			match get_type:
				"weapon":
					collected_weapons.add_child(new_item_container) 
				"upgrade":
					collected_skills.add_child(new_item_container) 
			


func _on_restart_button_button_up() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_button_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/TitleScreen/menu.tscn")
