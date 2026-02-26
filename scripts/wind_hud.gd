extends Control
## HUD overlay: wind direction arrow, speed read-out, and sail trim hint.

@onready var _wind_arrow: Polygon2D = $WindArrow
@onready var _speed_label: Label = $SpeedLabel
@onready var _sail_label: Label  = $SailLabel

var _boat: CharacterBody2D


func _ready() -> void:
	# Find the boat in the scene tree (sibling or child of parent).
	_boat = get_tree().get_first_node_in_group("boat") as CharacterBody2D
	if not _boat:
		# Fall back to path from main scene.
		_boat = get_node_or_null("../Boat") as CharacterBody2D


func _process(_delta: float) -> void:
	# ── Wind arrow ────────────────────────────────────────────────
	if _wind_arrow:
		# Show the direction the wind is blowing *from* (more intuitive).
		var from_angle := Wind.wind_direction.angle() + PI
		_wind_arrow.rotation = from_angle
		# Scale slightly with strength.
		var s := remap(Wind.wind_strength, 100.0, 300.0, 0.8, 1.4)
		_wind_arrow.scale = Vector2(s, s)

	# ── Speed read-out ────────────────────────────────────────────
	if _speed_label and _boat:
		_speed_label.text = "Speed: %d" % roundi(_boat.speed)

	# ── Sail angle hint ──────────────────────────────────────────
	if _sail_label and _boat:
		var deg := rad_to_deg(_boat.sail_angle)
		_sail_label.text = "Sail: %+.0f°" % deg
