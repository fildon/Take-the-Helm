extends Camera2D
## Smooth-follow camera that tracks a target node (the boat).
## Supports mouse-wheel zoom and a look-ahead offset in the
## direction of travel so the player can see more of what's ahead.

@export var target_path: NodePath = "../Boat"
## How far ahead of the target the camera looks (pixels).
@export var look_ahead: float = 80.0
## Minimum zoom (zoomed out).
@export var min_zoom: float = 0.3
## Maximum zoom (zoomed in).
@export var max_zoom: float = 3.0
## Zoom multiplier per scroll tick.
@export var zoom_step: float = 0.1

var _target: CharacterBody2D


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 3.0
	_target = get_node_or_null(target_path) as CharacterBody2D


func _process(_delta: float) -> void:
	if not _target:
		return
	# Look ahead in the direction the boat is moving.
	var ahead := Vector2.ZERO
	if _target.velocity.length() > 10.0:
		var speed_ratio := clampf(_target.velocity.length() / 300.0, 0.0, 1.0)
		ahead = _target.velocity.normalized() * look_ahead * speed_ratio
	global_position = _target.global_position + ahead


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var z := zoom.x
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			z *= (1.0 + zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			z *= (1.0 - zoom_step)
		else:
			return
		z = clampf(z, min_zoom, max_zoom)
		zoom = Vector2(z, z)
