extends Node2D

@export var lifetime: float = 0.12
@onready var flash: Polygon2D = $Flash

func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, lifetime)
	tween.tween_callback(queue_free)
