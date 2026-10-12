extends Node2D
class_name BloodTrail

@export var particle_scene: PackedScene
@export var minimum_speed: float = 180.0
@export var emission_distance: float = 18.0
@export var max_trail_particles: int = 20

var target_body: RigidBody2D
var _last_position := Vector2.ZERO
var _distance_since_emit := 0.0
var _spawned := 0

func _ready() -> void:
	_last_position = global_position

func setup(body: RigidBody2D) -> void:
	target_body = body

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target_body):
		queue_free()
		return

	global_position = target_body.global_position
	var velocity := target_body.linear_velocity
	_distance_since_emit += global_position.distance_to(_last_position)
	_last_position = global_position

	if velocity.length() < minimum_speed:
		return
	if _distance_since_emit >= emission_distance and _spawned < max_trail_particles:
		_distance_since_emit = 0.0
		_spawned += 1
		if particle_scene != null:
			var particle := particle_scene.instantiate() as Node2D
			if particle != null:
				get_tree().current_scene.add_child(particle)
				particle.global_position = global_position
				particle.rotation = velocity.angle()
