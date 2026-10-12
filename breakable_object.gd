extends RigidBody2D
class_name BreakableObject

@export var break_threshold_energy: float = 1600.0
@export var physical_fragment_scene: PackedScene
@export_range(0, 8) var physical_fragment_count: int = 4
@export_range(0, 20) var visual_shard_count: int = 8
@export var fragment_impulse: float = 180.0
@export var effect_manager_path: NodePath

var already_broken := false
var _previous_velocity := Vector2.ZERO

func _ready() -> void:
	add_to_group("telekinetic_targets")
	_previous_velocity = linear_velocity

func _physics_process(_delta: float) -> void:
	_previous_velocity = linear_velocity

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if already_broken:
		return
	for i in range(state.get_contact_count()):
		var impulse := state.get_contact_impulse(i).length()
		var estimated_energy := 0.5 * mass * _previous_velocity.length_squared()
		if impulse > 40.0 or estimated_energy >= break_threshold_energy:
			break_apart(state.get_contact_local_position(i))
			return

func on_telekinetic_grab() -> void:
	# Optional hook for sound, outline, or highlight.
	pass

func on_telekinetic_throw(_direction: Vector2, _speed: float) -> void:
	# Optional hook for throw sound or trail activation.
	pass

func on_telekinetic_release() -> void:
	pass

func break_apart(local_impact_position: Vector2 = Vector2.ZERO) -> void:
	if already_broken:
		return
	already_broken = true
	var world_position := global_position
	var world_rotation := global_rotation
	var manager := get_node_or_null(effect_manager_path) if not effect_manager_path.is_empty() else get_tree().get_first_node_in_group("effect_manager")

	if manager and manager.has_method("spawn_impact"):
		manager.spawn_impact(world_position, -linear_velocity.normalized())

	if physical_fragment_scene != null:
		for i in range(physical_fragment_count):
			var fragment := physical_fragment_scene.instantiate() as RigidBody2D
			if fragment == null:
				continue
			get_parent().add_child(fragment)
			fragment.global_position = world_position + Vector2(randf_range(-6.0, 6.0), randf_range(-6.0, 6.0))
			fragment.global_rotation = world_rotation + randf_range(-0.5, 0.5)
			var direction := (Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) + Vector2.UP * 0.7).normalized()
			fragment.apply_central_impulse(direction * fragment_impulse * randf_range(0.65, 1.25))

	queue_free()
