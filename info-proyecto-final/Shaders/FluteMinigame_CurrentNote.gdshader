shader_type canvas_item;

uniform float fade_height : hint_range(0.0, 0.5) = 0.2;
uniform float fade_curve : hint_range(0.1, 3.0) = 1.0;  // 1.0 = linear

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    // Get distance from edges
    float top_dist = UV.y / fade_height;
    float bottom_dist = (1.0 - UV.y) / fade_height;
    
    // Apply curve (1.0 = linear, >1.0 = faster fade, <1.0 = slower fade)
    float top_fade = clamp(pow(top_dist, fade_curve), 0.0, 1.0);
    float bottom_fade = clamp(pow(bottom_dist, fade_curve), 0.0, 1.0);
    
    float fade_factor = min(top_fade, bottom_fade);
    
    color.a *= fade_factor;
	color.a -= 0.8;
    COLOR = color;
}