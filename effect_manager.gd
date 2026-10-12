extends Node2D
class_name EffectManager

@export var impact_effect_scene: PackedScene
@export var blood_effect_scene: PackedScene
@export var max_live_effects: int = 24

var _live_effects: Array[Node] = []

func _ready() -> void:
	add_to_group("effect_manager")

func spawn_impact(world_position: Vector2, direction: Vector2 = Vector2.UP) -> void:
	_spawn_effect(impact_effect_scene, world_position, direction)

func spawn_blood(world_position: Vector2, direction: Vector2 = Vector2.UP) -> void:
	_spawn_effect(blood_effect_scene, world_position, direction)

func _spawn_effect(scene: PackedScene, world_position: Vector2, direction: Vector2) -> void:
	if scene == null:
		return
	_prune_effects()
	if _live_effects.size() >= max_live_effects:
		var oldest := _live_effects.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

	var effect := scene.instantiate() as Node2D
	if effect == null:
		return
	get_tree().current_scene.add_child(effect)
	effect.global_position = world_position
	effect.rotation = direction.angle()
	_live_effects.append(effect)

func _prune_effects() -> void:
	for i in range(_live_effects.size() - 1, -1, -1):
		if not is_instance_valid(_live_effects[i]):
			_live_effects.remove_at(i)
