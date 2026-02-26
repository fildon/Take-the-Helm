extends Polygon2D
## Feeds the Wind autoload's direction and strength into the ocean
## ShaderMaterial each frame so waves match the wind.

func _process(_delta: float) -> void:
	var mat := material as ShaderMaterial
	if not mat:
		return
	mat.set_shader_parameter("wind_direction", Wind.wind_direction)
	# Normalise strength to roughly 0-1 for the shader.
	var norm := clampf(Wind.wind_strength / 300.0, 0.0, 1.0)
	mat.set_shader_parameter("wind_strength", norm)
