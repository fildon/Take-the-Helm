extends CharacterBody2D
## Player-controlled boat with arcade thrust-and-steer physics.
## Forward direction is local +X (right).  The boat gains momentum
## when thrusting and gradually slows via water drag.

# ── Movement tuning ──────────────────────────────────────────────
@export_group("Movement")
## Forward acceleration in pixels / second².
@export var thrust_force: float = 300.0
## Reverse thrust as a fraction of forward thrust.
@export var reverse_factor: float = 0.4
## Turning rate in radians / second.
@export var turn_speed: float = 2.5
## Linear drag coefficient – higher values = more water resistance.
@export_range(0.0, 0.1) var drag: float = 0.02
## Maximum speed in pixels / second.
@export var max_speed: float = 500.0

# Convenience: current speed for other systems (HUD, camera, etc.)
var speed: float = 0.0


func _physics_process(delta: float) -> void:
	# ── Steering ──────────────────────────────────────────────────
	var steer := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		steer -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		steer += 1.0
	rotation += steer * turn_speed * delta

	# ── Thrust ────────────────────────────────────────────────────
	var throttle := 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		throttle += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		throttle -= reverse_factor

	var forward := Vector2.RIGHT.rotated(rotation)
	velocity += forward * throttle * thrust_force * delta

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

	move_and_slide()
