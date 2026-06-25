shader_type canvas_item;

uniform float grain_opacity : hint_range(0.0, 1.0) = 0.15;
uniform float grain_speed : hint_range(0.0, 30.0) = 15.0;

void fragment() {
	float n1 = fract(sin(dot(UV * TIME * grain_speed, vec2(12.9898, 78.233))) * 43758.5453);
	float n2 = fract(sin(dot(UV * TIME * grain_speed * 1.3, vec2(63.726, 10.873))) * 12345.6789);
	float n3 = fract(sin(dot(UV * TIME * grain_speed * 0.7, vec2(34.567, 89.012))) * 98765.4321);

	float grain = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;

	float alpha = grain * grain_opacity;

	COLOR = vec4(grain, grain, grain, alpha);
}
