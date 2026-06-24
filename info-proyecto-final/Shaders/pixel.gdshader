shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float tamano_pixel : hint_range(1.0, 32.0) = 4.0;

void fragment() {
	vec2 screen_size = vec2(textureSize(screen_texture, 0));

	vec2 uv = SCREEN_UV;
	uv = floor(uv * screen_size / tamano_pixel)
	   * tamano_pixel
	   / screen_size;

	COLOR = texture(screen_texture, uv);
}