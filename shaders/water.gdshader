shader_type canvas_item;
// Animated ocean surface – layered sine waves with foam highlights.
// Uses world-space coordinates so the pattern scrolls correctly
// as the camera moves.  Wind direction and strength bias the waves.

uniform vec4 deep_color   : source_color = vec4(0.04, 0.12, 0.36, 1.0);
uniform vec4 shallow_color: source_color = vec4(0.15, 0.40, 0.65, 1.0);
uniform vec4 foam_color   : source_color = vec4(0.70, 0.85, 0.95, 1.0);
uniform float wave_speed : hint_range(0.0, 2.0)  = 0.4;
uniform float wave_scale : hint_range(0.001, 0.05) = 0.008;
uniform float foam_threshold : hint_range(0.0, 1.0) = 0.72;

// Wind parameters (set from script each frame).
uniform vec2  wind_direction = vec2(1.0, 0.0);
uniform float wind_strength  = 0.5; // normalised 0-1

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// Rotate UV space so the primary wave axis aligns with wind.
	vec2 wd = normalize(wind_direction + vec2(0.001));
	// Build a 2D rotation from wind direction.
	mat2 wind_rot = mat2(vec2(wd.x, -wd.y), vec2(wd.y, wd.x));
	vec2 p = wind_rot * (world_pos * wave_scale);
	float t = TIME * wave_speed;

	// Amplitude boost from wind (1.0 at calm, up to 1.6 at full wind).
	float amp = mix(1.0, 1.6, wind_strength);

	// Four octaves of sine waves – now biased along the wind axis.
	float w1 = sin(p.x * 1.1 + t)           * cos(p.y * 0.9 + t * 0.7) * amp;
	float w2 = sin(p.x * 0.6 + p.y * 0.8 + t * 1.2) * 0.6;
	float w3 = sin(p.x * 2.3 - p.y * 1.7 + t * 0.6) * 0.3 * amp;
	float w4 = sin(p.x * 3.1 + p.y * 2.8 + t * 1.8) * 0.15;

	float wave = (w1 + w2 + w3 + w4) * 0.25 + 0.5;

	vec4 col = mix(deep_color, shallow_color, wave);

	// Foam highlights on wave crests – more foam in strong wind.
	float foam_thresh = foam_threshold - wind_strength * 0.12;
	if (wave > foam_thresh) {
		float foam = smoothstep(foam_thresh, 1.0, wave);
		col = mix(col, foam_color, foam * 0.4);
	}

	COLOR = col;
}
