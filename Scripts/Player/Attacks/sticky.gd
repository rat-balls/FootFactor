extends Area2D

var level = 1
var hp = 9999
var speed = 250
var damage = 15
var knockback_amount = 200
var attack_size = 1.0
var attack_speed = 5

var target = Vector2.ZERO
var target_array = [Vector2.ZERO]
var angle = Vector2.ZERO
var sticked = false
var propagated = 0
var sticked_enemy

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var snd_play: AudioStreamPlayer2D = $snd_play
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var duration: Timer = %Duration
@onready var propagate_timer: Timer = $PropagateTimer
@onready var damage_timer: Timer = $DamageTimer
const STICKY = preload("res://Scenes/Prefabs/Player/Attacks/sticky.tscn")

func _ready():
	level = player.sticky_level
	match level:
		1:
			hp = 9999
			speed = 200.0
			damage = 0.5
			knockback_amount = 50
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 7.0 * (1 - player.spell_cooldown)
		2:
			hp = 9999
			speed = 200.0
			damage = 0.75
			knockback_amount = 50
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 7.0 * (1 - player.spell_cooldown)
		3:
			hp = 9999
			speed = 300.0
			damage = 0.75
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 6.0 * (1 - player.spell_cooldown)
		3:
			hp = 9999
			speed = 400.0
			damage = 1
			knockback_amount = 150
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)
	
	scale = Vector2(1.0, 1.0) * attack_size

func _physics_process(delta):
	if(target && !sticked):
		angle = global_position.direction_to(target)
		position += angle * speed * delta
	elif sticked_enemy && sticked:
		global_position = sticked_enemy.global_position

func enemy_hit(charge = 1):
	hp -= charge

func enemy_stick(enemy):
	collision.call_deferred("set_disabled", true)
	sticked_enemy = enemy
	sticked = true
	duration.start()
	propagate_timer.start()
	damage_timer.start()

func _on_duration_timeout() -> void:
	if(sticked_enemy):
		sticked_enemy.sticked = false
	queue_free()

func _on_damage_timer_timeout() -> void:
	if(sticked_enemy):
		sticked_enemy.hurt.emit(damage, angle, knockback_amount, false)
		damage_timer.start()

func _on_propagate_timer_timeout() -> void:
	if(propagated < player.sticky_propagate_count && sticked):
		for i in player.sticky_propagateammo + player.additional_attack :
			var new_sticky: Area2D = STICKY.instantiate()
			new_sticky.propagated = 1 + propagated
			new_sticky.target = player.get_random_target() 
			new_sticky.global_position = global_position
			get_parent().add_child(new_sticky)
	propagate_timer.start()
	
