shader_type canvas_item;
// Animated ocean surface – layered sine waves with foam highlights.
// Uses world-space coordinates so the pattern scrolls correctly
// as the camera moves.

uniform vec4 deep_color   : source_color = vec4(0.04, 0.12, 0.36, 1.0);
uniform vec4 shallow_color: source_color = vec4(0.15, 0.40, 0.65, 1.0);
uniform vec4 foam_color   : source_color = vec4(0.70, 0.85, 0.95, 1.0);
uniform float wave_speed : hint_range(0.0, 2.0)  = 0.4;
uniform float wave_scale : hint_range(0.001, 0.05) = 0.008;
uniform float foam_threshold : hint_range(0.0, 1.0) = 0.72;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 p = world_pos * wave_scale;
	float t = TIME * wave_speed;

	// Four octaves of sine waves at different angles and frequencies.
	float w1 = sin(p.x * 1.1 + t)           * cos(p.y * 0.9 + t * 0.7);
	float w2 = sin(p.x * 0.6 + p.y * 0.8 + t * 1.2) * 0.6;
	float w3 = sin(p.x * 2.3 - p.y * 1.7 + t * 0.6) * 0.3;
	float w4 = sin(p.x * 3.1 + p.y * 2.8 + t * 1.8) * 0.15;

	float wave = (w1 + w2 + w3 + w4) * 0.25 + 0.5;

	vec4 col = mix(deep_color, shallow_color, wave);

	// Foam highlights on wave crests.
	if (wave > foam_threshold) {
		float foam = smoothstep(foam_threshold, 1.0, wave);
		col = mix(col, foam_color, foam * 0.4);
	}

	COLOR = col;
}
