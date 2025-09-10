extends CharacterBody2D

@export var movement_speed = 100.0
@export var hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
var knockback = Vector2.ZERO

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite:Sprite2D = $Sprite2D
@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var sound_hit = $snd_hit

var death_anim: Resource = preload("res://Scenes/Prefabs/Enemy/explosion.tscn")

var exp_gem = preload("res://Scenes/Prefabs/Objects/experience.tscn")

signal remove_from_array(object)

func _ready():
	animation.play("walk")

func _physics_process(_delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()
	
	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

func death():
	emit_signal("remove_from_array", self )
	
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	
	queue_free()

func _on_hurt_box_hurt(damage: Variant, angle, knockback_amount) -> void:
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		sound_hit.play( )
