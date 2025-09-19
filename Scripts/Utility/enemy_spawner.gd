extends Node2D

@export var spawns: Array[SpawnInfo] = []

@onready var player = get_tree().get_first_node_in_group("player")
const FISH_ENEMY = preload("res://Scenes/Prefabs/Enemy/fish_enemy.tscn")
const SPIDER_ENEMY = preload("res://Scenes/Prefabs/Enemy/spider_enemy.tscn")
const SNAIL_ENEMY = preload("res://Scenes/Prefabs/Enemy/snail_enemy.tscn")
const DOG_ENEMY = preload("res://Scenes/Prefabs/Enemy/dog_enemy.tscn")

var time = 0

signal changetime(time: int)

func _ready() -> void:
	Client.enemy_received.connect(_on_mob_spawn)
	changetime.connect(player.change_time)

func _process(_delta) -> void:
	if(Input.is_action_just_pressed("test_Spider")):
		_on_mob_spawn("dog", "30", "3", "50", "0")
		_on_mob_spawn("fish", "10", "2", "10", "0")
		_on_mob_spawn("fish", "10", "2", "10", "0")
		_on_mob_spawn("fish", "10", "2", "10", "0")
		_on_mob_spawn("dog", "30", "3", "50", "0")

func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	for e_spawn in enemy_spawns:
		if time >= e_spawn.time_start and time <= e_spawn.time_end:
			if e_spawn.spawn_delay_counter < e_spawn.enemy_spawn_delay:
				e_spawn.spawn_delay_counter += 1
			else:
				e_spawn.spawn_delay_counter = 0
				var new_enemy: Resource = load(str(e_spawn.enemy.resource_path))
				var counter = 0
				while counter < e_spawn.enemy_num:
					var enemy_spawn: CharacterBody2D = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1
	emit_signal("changetime", time)

func get_random_position(): 
	var vpr = (get_viewport_rect().size * 1.4) * randf_range(1.1, 1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right= Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up", "down", "left", "right"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
	match pos_side:
		"up":
			spawn_pos1 = top_left
			spawn_pos2 = top_right
		"down":
			spawn_pos1 = bottom_left
			spawn_pos2 = bottom_right
		"left":
			spawn_pos1 = top_left
			spawn_pos2 = bottom_left
		"right":
			spawn_pos1 = top_right
			spawn_pos2 = bottom_right
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	
	return Vector2(x_spawn, y_spawn)

func _on_mob_spawn(type: String, life: String, damage: String, cost: String, id: String) -> void:
	if(Client.enemy_pooling.filter(func(element): return element.type == type).size() > 0):
		wake_mob(type, life, damage, cost, id)
	else:
		spawn_mob(type, life, damage, cost, id)

func spawn_mob(type: String, life: String, damage: String, cost: String, id: String):
	var enemy_spawn: RigidBody2D = null
	match type:
		"fish":
			enemy_spawn = FISH_ENEMY.instantiate()
		"snail":
			enemy_spawn = SNAIL_ENEMY.instantiate()
		"dog":
			enemy_spawn = DOG_ENEMY.instantiate()
		"spider":
			enemy_spawn = SPIDER_ENEMY.instantiate()
	if(enemy_spawn != null):
		enemy_spawn.global_position = get_random_position()
		enemy_spawn.hp = int(life)
		enemy_spawn.get_node("HitBox").damage = int(damage)
		enemy_spawn.experience = float(cost)/10
		enemy_spawn._id = id
		add_child(enemy_spawn)

func wake_mob(type: String, life: String, damage: String, cost: String, id: String):
	var enemy_spawn: RigidBody2D = Client.enemy_pooling.filter(func(element): return element.type == type)[0]
	if(enemy_spawn != null):
		enemy_spawn.dead = false
		enemy_spawn.experience = float(cost)/10
		enemy_spawn._id = id
		enemy_spawn.global_position = get_random_position()
		enemy_spawn.hp = int(life)
		var hitbox = enemy_spawn.get_node("HitBox")
		hitbox.damage = int(damage)
		hitbox.set_deferred("monitoring", true)
		hitbox.set_deferred("monitorable", true)
		enemy_spawn.get_node("CollisionShape2D").set_deferred("disabled", false) 
		enemy_spawn.sleeping = false
		enemy_spawn.get_node("Sprite2D").visible = true
		Client.enemy_pooling.remove_at(Client.enemy_pooling.find(enemy_spawn))
	else:
		spawn_mob(type, life, damage, cost, id)	
