extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

signal hurt(damage, angle, knockback)

var hit_once_array = []

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
			if not area.get("angle") == null:
				angle = area.angle
			if not area.get("knockback_amount") == null:
				knockback = area.knockback_amount
			emit_signal("hurt", damage, angle, knockback)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)


func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
