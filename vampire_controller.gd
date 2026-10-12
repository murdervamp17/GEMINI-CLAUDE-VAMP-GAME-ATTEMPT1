extends CharacterBody2D
class_name VampireController

@export var move_speed: float = 180.0
@export var hover_amplitude: float = 2.0
@export var hover_frequency: float = 1.2
@export var hover_smoothing: float = 10.0
@export var aim_distance: float = 90.0

@onready var body_art: Node2D = $BodyArt
@onready var telekinesis: TelekinesisController = $TelekinesisController

var _base_y: float
var _hover_time := 0.0

func _ready() -> void:
	_base_y = position.y
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()

	_hover_time += delta
	var target_y := sin(_hover_time * TAU * hover_frequency) * hover_amplitude
	body_art.position.y = lerpf(body_art.position.y, target_y, 1.0 - exp(-hover_smoothing * delta))

	if input_vector.x != 0.0:
		body_art.scale.x = sign(input_vector.x)

	var mouse_world := get_global_mouse_position()
	telekinesis.set_aim_point(mouse_world)

	if Input.is_action_just_pressed("grab"):
		telekinesis.try_grab_aimed_target()
	if Input.is_action_just_pressed("throw_object"):
		telekinesis.throw_held()
	if Input.is_action_just_pressed("release_object"):
		telekinesis.release_held()

func get_aim_direction() -> Vector2:
	var direction := get_global_mouse_position() - global_position
	if direction.length_squared() < 0.001:
		return Vector2.RIGHT * body_art.scale.x
	return direction.normalized()
