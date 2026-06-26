shader_type canvas_item;
render_mode unshaded;

uniform float speed : hint_range(0.1, 10.0) = 2.0;
uniform float glitch_strength : hint_range(0.0, 1.0) = 0.4;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.25;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.25;
uniform float brightness : hint_range(0.0, 1.0) = 0.45;

float rand(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * speed;

	// Horizontal glitch bands
	float band = floor(uv.y * 30.0);
	float offset = (rand(vec2(band, floor(t * 8.0))) - 0.5);
	uv.x += offset * glitch_strength;

	// Color bars
	float bars = floor(fract(uv.x + t * 0.1) * 6.0);

	vec3 col;

	if (bars < 1.0)
		col = vec3(1.0, 0.1, 0.1);
	else if (bars < 2.0)
		col = vec3(1.0, 1.0, 0.1);
	else if (bars < 3.0)
		col = vec3(0.1, 1.0, 0.2);
	else if (bars < 4.0)
		col = vec3(0.1, 1.0, 1.0);
	else if (bars < 5.0)
		col = vec3(0.3, 0.3, 1.0);
	else
		col = vec3(1.0, 0.1, 1.0);

	// Static noise
	float noise = rand(
		vec2(
			floor(uv.x * 300.0),
			floor(uv.y * 300.0 + t * 20.0)
		)
	);

	col += (noise - 0.5) * noise_strength;

	// Scanlines
	float scan = sin(uv.y * 800.0);
	col -= abs(scan) * scanline_strength * 2.0;

	// RGB split
	float shift = sin(t * 3.0) * 0.01;

	float r = col.r;
	float g = mix(col.g, col.r, abs(shift));
	float b = mix(col.b, col.g, abs(shift));

	col = vec3(r, g, b);

	// CRT flicker
	float flicker = 0.9 + rand(vec2(floor(t * 30.0))) * 0.2;
	col *= flicker;

	// Random bright glitch lines
	if (rand(vec2(floor(t * 20.0), band)) > 0.97) {
		col *= 2.5;
	}

	// Vignette
	float vig = smoothstep(
		0.8,
		0.2,
		length(UV - vec2(0.5))
	);

	col *= vig;

	// Global brightness
	col *= brightness;

	col = clamp(col, vec3(0.0), vec3(1.0));

	COLOR = vec4(col, 1.0);
}