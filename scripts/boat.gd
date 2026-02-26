extends CharacterBody2D
## Player-controlled sailing boat.
## Forward direction is local +X (right).  The boat is propelled by
## wind acting on a trim-able sail, with lateral keel resistance and
## water drag.  Steering via rudder (A/D), sail trim via Q/E.

# ── Movement tuning ──────────────────────────────────────────────
@export_group("Movement")
## Turning rate in radians / second.
@export var turn_speed: float = 2.5
## Linear drag coefficient – higher = more water resistance.
@export_range(0.0, 0.1) var drag: float = 0.02
## Maximum speed in pixels / second.
@export var max_speed: float = 500.0

@export_group("Sail")
## How effectively the sail converts wind into force (area factor).
@export var sail_efficiency: float = 1.0
## How quickly the player can rotate the sail (radians / second).
@export var sail_trim_speed: float = 2.0
## Maximum sail angle from centreline (radians). ~80 degrees.
@export var max_sail_angle: float = 1.4
## Keel lateral-resistance factor (0 = no keel, 1 = perfect keel).
@export_range(0.0, 1.0) var keel_factor: float = 0.85
## Small auxiliary thrust (rowing / motor) for manoeuvring, px/s².
@export var aux_thrust: float = 60.0

# ── Runtime state (readable by HUD / camera) ─────────────────────
## Current boat speed in px/s.
var speed: float = 0.0
## Current sail angle relative to the hull (radians, 0 = aligned with hull).
var sail_angle: float = 0.0

# ── Node references ──────────────────────────────────────────────
@onready var _sail_polygon: Polygon2D = $Sail


func _physics_process(delta: float) -> void:
	# ── Steering (rudder) ─────────────────────────────────────────
	var steer := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		steer -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		steer += 1.0
	rotation += steer * turn_speed * delta

	# ── Sail trim (Q / E) ────────────────────────────────────────
	var trim := 0.0
	if Input.is_key_pressed(KEY_Q):
		trim -= 1.0
	if Input.is_key_pressed(KEY_E):
		trim += 1.0
	sail_angle = clampf(sail_angle + trim * sail_trim_speed * delta,
						-max_sail_angle, max_sail_angle)

	# ── Wind force on sail ────────────────────────────────────────
	var wind_dir: Vector2 = Wind.wind_direction
	var wind_str: float   = Wind.wind_strength

	# Apparent wind = true wind − boat velocity (simplified).
	var apparent_wind := wind_dir * wind_str - velocity
	var apparent_strength := apparent_wind.length()

	if apparent_strength > 0.1:
		var apparent_dir := apparent_wind.normalized()

		# Sail normal (perpendicular to the sail chord) in world space.
		var sail_world_angle := rotation + sail_angle
		var sail_normal := Vector2.UP.rotated(sail_world_angle)

		# Force magnitude ∝ |dot(apparent_wind_dir, sail_normal)|.
		# This naturally gives zero force when the wind is along the sail
		# and max force when perpendicular to it.
		var force_mag := absf(apparent_dir.dot(sail_normal)) * apparent_strength * sail_efficiency

		# Force direction: push along the apparent wind direction projected
		# onto the sail normal side (away from wind).
		var push_dir := sail_normal if apparent_dir.dot(sail_normal) > 0.0 else -sail_normal
		var sail_force := push_dir * force_mag

		velocity += sail_force * delta

	# ── Auxiliary thrust (W / S — small, for docking) ─────────────
	var throttle := 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		throttle += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		throttle -= 0.4
	if throttle != 0.0:
		var forward := Vector2.RIGHT.rotated(rotation)
		velocity += forward * throttle * aux_thrust * delta

	# ── Keel: resist lateral (sideways) motion ───────────────────
	var forward_dir := Vector2.RIGHT.rotated(rotation)
	var lateral_dir := Vector2.DOWN.rotated(rotation)

	var forward_component := velocity.dot(forward_dir)
	var lateral_component := velocity.dot(lateral_dir)
	# Reduce lateral velocity by the keel factor.
	velocity = forward_dir * forward_component + lateral_dir * lateral_component * (1.0 - keel_factor)

	# ── Drag (frame-rate independent) ────────────────────────────
	velocity *= pow(1.0 - drag, delta * 60.0)

	# ── Speed cap ─────────────────────────────────────────────────
	speed = velocity.length()
	if speed > max_speed:
		velocity = velocity.normalized() * max_speed
		speed = max_speed
	elif speed < 0.5:
		velocity = Vector2.ZERO
		speed = 0.0

	# ── Update sail visual ────────────────────────────────────────
	if _sail_polygon:
		_sail_polygon.rotation = sail_angle

	move_and_slide()
