extends Node
## Global wind system.
## Provides a smoothly varying wind direction and strength that other
## systems (boat physics, water shader, HUD) can query each frame.
## Add this script as an autoload named "Wind".

# ── Tuning ────────────────────────────────────────────────────────
@export_group("Wind")
## Base wind strength in pixels / second².
@export var base_strength: float = 180.0
## Extra strength added during gusts.
@export var gust_intensity: float = 90.0
## How quickly the wind direction drifts (radians / second).
@export var drift_speed: float = 0.15
## Starting wind angle in radians (0 = blowing to the right / +X).
@export var initial_angle: float = PI * 0.25

# ── Runtime state ─────────────────────────────────────────────────
## Current wind direction (unit vector – the direction the wind blows TOWARD).
var wind_direction: Vector2 = Vector2.RIGHT
## Current wind strength (pixels / s²).
var wind_strength: float = 0.0

# Internal accumulators for Perlin-like layered sine variation.
var _time: float = 0.0


func _ready() -> void:
	wind_direction = Vector2.RIGHT.rotated(initial_angle)
	wind_strength = base_strength


func _process(delta: float) -> void:
	_time += delta

	# ── Direction drift (two layered sine waves) ─────────────────
	var angle_offset := (
		sin(_time * drift_speed * 1.0) * 0.45
		+ sin(_time * drift_speed * 2.7 + 1.3) * 0.25
	)
	var current_angle := initial_angle + angle_offset
	wind_direction = Vector2.RIGHT.rotated(current_angle)

	# ── Strength variation (base + gusts) ────────────────────────
	var gust := (
		sin(_time * 0.4) * 0.5
		+ sin(_time * 1.1 + 2.0) * 0.3
		+ sin(_time * 2.6 + 5.0) * 0.2
	)
	# gust now in roughly [-1, 1]; remap to [0, 1]
	gust = clampf((gust + 1.0) * 0.5, 0.0, 1.0)
	wind_strength = base_strength + gust * gust_intensity
