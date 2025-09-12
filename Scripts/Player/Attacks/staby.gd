extends Area2D

var level = 1
var hp = 99999999
var speed = 250
var damage = 10
var knockback_amount = 200
var attack_size = 1.0
var attack_speed = 5

var target = Vector2.ZERO
var target_array = [Vector2.ZERO]
var angle = Vector2.ZERO

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_timer: Timer = %AttackTimer
@onready var charge_timer: Timer = %ChargeTimer
@onready var snd_play: AudioStreamPlayer2D = $snd_play
@onready var collision: CollisionShape2D = $CollisionShape2D

signal remove_from_array(object)

func _ready():
	update_staby()

func update_staby():
	level = player.staby_level
	match level:
		1:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldow)
		2:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldow)
		3:
			hp = 9999
			speed = 200.0
			damage = 15
			knockback_amount = 120
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldow)
	
	scale = Vector2(1.0, 1.0) * attack_size
	attack_timer.wait_time = attack_speed
	attack_timer.start()

func _physics_process(delta):
	if(target):
		position += angle * speed * delta

func add_paths():
	snd_play.play()
	emit_signal("remove_from_array", self)
	target_array.clear()
	var counter = 0
	while counter < player.staby_ammo:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
		enable_attack(true)
	target = target_array[0]
	process_path()

func process_path():
	
	angle = global_position.direction_to(target)
	
	if angle.x > 0.1:
		sprite.flip_h = true
	elif angle.x < -0.1:
		sprite.flip_h = false
		
	var angle_tween = create_tween()
	angle_tween.tween_property(self, "rotation_degrees", -35 if sprite.flip_h else 35, 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	angle_tween.play()
	angle_tween.tween_property(self, "rotation_degrees", 0, 0.2)
	angle_tween.play()
	
	charge_timer.start()

func enable_attack(atk = true):
	collision.call_deferred("set", "disabled", !atk)
	target = null

func enemy_hit(charge = 1):
	hp -= charge
	if hp <= 0:
		queue_free()

func _on_attack_timer_timeout() -> void:
	attack_timer.stop()
	add_paths()

#add tween to make it cabrer
func _on_charge_timer_timeout() -> void:
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			snd_play.play()
			emit_signal("remove_from_array", self)
		else:
			enable_attack(false)
	else:
		charge_timer.stop()
		attack_timer.start()
		enable_attack(false)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
