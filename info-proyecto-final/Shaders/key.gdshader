shader_type canvas_item;

uniform vec4 key_color : source_color = vec4(0.15, 0.2, 0.25, 1.0);
uniform vec4 key_hover_color : source_color = vec4(0.35, 0.45, 0.55, 1.0);
uniform vec4 key_press_color : source_color = vec4(0.1, 0.15, 0.2, 1.0);

uniform float corner_radius : hint_range(0.0, 0.5) = 0.15;
uniform float shadow_intensity : hint_range(0.0, 1.0) = 0.4;

uniform bool is_pressed = false;
uniform bool is_hovered = false;
uniform bool is_active = false;

uniform float press_animation : hint_range(0.0, 1.0) = 0.0;

uniform float glow_intensity : hint_range(0.0, 1.0) = 0.2;

uniform bool smooth_edges = true;

float rounded_rect(vec2 uv, vec2 size, float radius) {
    vec2 abs_uv = abs(uv);
    vec2 half_size = size * 0.5;
    vec2 d = abs_uv - half_size + radius;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius;
}

void fragment() {
    vec2 uv = UV - 0.5;
    
    float press_offset = press_animation * 0.03;
    vec2 press_uv = uv + vec2(0.0, press_offset);
    
    vec2 key_size = vec2(0.9, 0.9);
    
    float radius = corner_radius * 0.5;
    float dist = rounded_rect(uv, key_size, radius);
    
    float key_mask = 1.0 - smoothstep(0.0, 0.01, dist);
    
    vec2 shadow_offset = vec2(0.02, 0.03 + press_animation * 0.02);
    float shadow_dist = rounded_rect(uv - shadow_offset, key_size, radius);
    float shadow_mask = 1.0 - smoothstep(0.0, 0.01, shadow_dist);
    float shadow = shadow_mask * shadow_intensity * (0.7 - press_animation * 0.3);
    
    vec4 base_color = key_color;
    float press_factor = press_animation;
    
    if (is_pressed || press_factor > 0.5) {
        base_color = key_press_color;
    } else if (is_hovered) {
        base_color = key_hover_color;
    }
    
    if (is_active) {
        base_color = mix(base_color, vec4(1.0, 0.9, 0.4, 1.0), 0.15);
    }
    
    vec4 key_final = base_color;
    
    float edge_highlight = exp(-abs(dist) * 50.0) * 0.2;
    key_final.rgb += vec3(0.3, 0.4, 0.5) * edge_highlight;
    
    float glow = 0.0;
    if (is_active) {
        glow = glow_intensity * (sin(TIME * 2.0) * 0.5 + 0.5);
    } else if (is_hovered) {
        glow = glow_intensity * 0.3;
    }
    
    vec4 final_color = vec4(0.0);
    
    if (key_mask > 0.5) {
        final_color = vec4(0.0, 0.0, 0.0, shadow);
        
        vec4 key_body = key_final;
        key_body.a = 1.0;
        
        if (glow > 0.01) {
            vec3 glow_color = vec3(0.3, 0.6, 1.0) * glow * 0.5;
            key_body.rgb += glow_color;
        }
        
        float press_dist = rounded_rect(press_uv, key_size, radius);
        if (press_dist < 0.01) {
            final_color = mix(final_color, key_body, key_mask);
        } else {
            final_color = key_body;
        }
    } else {
        final_color = vec4(0.0, 0.0, 0.0, 0.0);
    }
    
    if (smooth_edges && final_color.a > 0.0) {
        final_color.a *= smoothstep(0.0, 0.01, -dist);
    }
    COLOR = final_color;
}