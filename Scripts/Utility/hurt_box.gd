extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage, angle, knockback)

var hit_once_array = []
var sticked = false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			match HurtBoxType:
				0: #CoolDown
					collision.call_deferred("set", "disabled", true)
					disableTimer.start()
				1: #HitOnce
					if hit_once_array.has(area) == false:
						hit_once_array.append(area_entered)
					else: 
						return
				2: #DisableHitBox
					if area.has_method("tempdisable"):
						area.tempdisable()
			var damage = area.damage
			var angle = Vector2.ZERO
			var knockback = 1
			var slowing = false
			if not area.get("angle") == null:
				angle = area.angle
			if not area.get("knockback_amount") == null:
				knockback = area.knockback_amount
			if not area.get("slowing") == null:
				slowing = area.slowing
			emit_signal("hurt", damage, angle, knockback, slowing)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)
			if area.has_method("enemy_stick") && !sticked:
				sticked = true
				area.enemy_stick(self)

func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
