extends Node2D
class_name TelekinesisController

@export var grab_range: float = 220.0
@export var max_grab_mass: float = 20.0
@export var hold_stiffness: float = 38.0
@export var hold_damping: float = 10.0
@export var max_hold_acceleration: float = 900.0
@export var hold_distance: float = 58.0
@export var min_throw_speed: float = 300.0
@export var max_throw_speed: float = 850.0
@export var throw_charge_seconds: float = 1.0
@export var target_collision_mask: int = 1

var held_body: RigidBody2D
var aim_point: Vector2
var _charge_time := 0.0

func _physics_process(delta: float) -> void:
	if held_body == null:
		queue_redraw()
		return
	if not is_instance_valid(held_body):
		held_body = null
		return

	var anchor := get_hold_anchor()
	var error := anchor - held_body.global_position
	var acceleration := error * hold_stiffness - held_body.linear_velocity * hold_damping
	acceleration = acceleration.limit_length(max_hold_acceleration)
	held_body.apply_central_force(acceleration * held_body.mass)

	if Input.is_action_pressed("throw_object"):
		_charge_time = minf(_charge_time + delta, throw_charge_seconds)
	queue_redraw()

func set_aim_point(point: Vector2) -> void:
	aim_point = point
	queue_redraw()

func get_hold_anchor() -> Vector2:
	var origin := get_parent().global_position
	var direction := aim_point - origin
	if direction.length_squared() < 0.001:
		direction = Vector2.RIGHT
	return origin + direction.normalized() * hold_distance

func try_grab_aimed_target() -> bool:
	if held_body != null:
		return false

	var origin := get_parent().global_position
	var direction := aim_point - origin
	if direction.length_squared() < 0.001:
		return false

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(origin, aim_point, target_collision_mask)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result := space_state.intersect_ray(query)

	if result.is_empty():
		return false

	var body := result.get("collider") as RigidBody2D
	if body == null or body.mass > max_grab_mass or body.is_in_group("ungrabbable"):
		return false
	if origin.distance_to(body.global_position) > grab_range:
		return false

	held_body = body
	_charge_time = 0.0
	if body.has_method("on_telekinetic_grab"):
		body.on_telekinetic_grab()
	return true

func throw_held() -> void:
	if held_body == null or not is_instance_valid(held_body):
		held_body = null
		return

	var body := held_body
	var direction := aim_point - get_parent().global_position
	if direction.length_squared() < 0.001:
		direction = Vector2.RIGHT
	direction = direction.normalized()

	var charge := clampf(_charge_time / maxf(throw_charge_seconds, 0.001), 0.0, 1.0)
	var speed := lerpf(min_throw_speed, max_throw_speed, charge)
	body.linear_velocity = direction * speed
	body.angular_velocity += randf_range(-5.0, 5.0)
	if body.has_method("on_telekinetic_throw"):
		body.on_telekinetic_throw(direction, speed)
	held_body = null
	_charge_time = 0.0

func release_held() -> void:
	if held_body != null and is_instance_valid(held_body):
		if held_body.has_method("on_telekinetic_release"):
			held_body.on_telekinetic_release()
	held_body = null
	_charge_time = 0.0

func _draw() -> void:
	var origin := to_local(get_parent().global_position)
	if held_body != null and is_instance_valid(held_body):
		var target := to_local(held_body.global_position)
		draw_line(origin, target, Color(0.85, 0.08, 0.20, 0.95), 2.0, false)
		for i in range(1, 8):
			var u := float(i) / 8.0
			var p := origin.lerp(target, u)
			draw_circle(p, 1.5, Color(1.0, 0.25, 0.36, 0.95))
	elif aim_point != Vector2.ZERO:
		var target := to_local(aim_point)
		if origin.distance_to(target) <= grab_range:
			draw_line(origin, target, Color(0.75, 0.08, 0.16, 0.22), 1.0, true)
