extends Node
class_name DamageReceiver

signal damaged(amount: float, impact_position: Vector2)
signal defeated

@export var max_health: float = 100.0
var health: float

func _ready() -> void:
	health = max_health

func apply_damage(amount: float, impact_position: Vector2 = Vector2.ZERO) -> void:
	if health <= 0.0 or amount <= 0.0:
		return
	health = maxf(health - amount, 0.0)
	damaged.emit(amount, impact_position)
	if health <= 0.0:
		defeated.emit()
