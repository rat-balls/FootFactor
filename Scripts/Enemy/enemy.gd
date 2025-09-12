extends CharacterBody2D

@export var movement_speed = 100.0
@export var hp = 10
@export var knockback_recovery = 3.5
@export var experience = 1
var knockback = Vector2.ZERO
var _id = 0

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite:Sprite2D = $Sprite2D
@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var sound_hit = $snd_hit

var death_anim: Resource = preload("res://Scenes/Prefabs/Enemy/explosion.tscn")

var exp_gem = preload("res://Scenes/Prefabs/Objects/experience.tscn")

signal remove_from_array(object)

func _ready():
	pass
	#animation.play("walk")

func _physics_process(_delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()
	
	var right_big = direction.x > 0.5
	var right_small = direction.x > 0.25
	var up_big = direction.y < -0.5
	var up_small = direction.y < -0.25
	var down_big = direction.y > 0.5
	var down_small = direction.y > 0.25
	var left_big = direction.x < -0.5
	var left_small = direction.x < -0.25
	
	if up_big and right_small:
		sprite.frame = 5
		#up_right
	elif up_big and left_small:
		sprite.frame = 2
		#up_left
	elif down_big and right_small:
		sprite.frame = 0
		#down_right
	elif down_big and left_small:
		sprite.frame = 1
		#down_left
	elif up_big:
		sprite.frame = 6
		#up
	elif down_big:
		sprite.frame = 4
		#down
	elif right_big:
		sprite.frame = 7
		#right
	elif left_big:
		sprite.frame = 3
		#left
	

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
	
	Client.enemy_death.emit(_id)
	
	queue_free()

func _on_hurt_box_hurt(damage: Variant, angle, knockback_amount) -> void:
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		sound_hit.play( )
