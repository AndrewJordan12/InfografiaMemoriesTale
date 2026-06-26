shader_type canvas_item;

// Screen appearance settings
uniform vec4 screen_color : source_color = vec4(0.1, 0.15, 0.2, 1.0);
uniform vec4 border_color : source_color = vec4(0.3, 0.4, 0.5, 1.0);
uniform vec4 display_color : source_color = vec4(0.0, 0.8, 0.0, 1.0);

// Border thickness (as fraction of screen size)
uniform float border_thickness : hint_range(0.0, 0.1) = 0.03;

// Screen curvature (0 = flat, higher = more curved)
uniform float curvature : hint_range(0.0, 0.5) = 0.15;

// Scanline effect
uniform bool show_scanlines = true;
uniform float scanline_intensity : hint_range(0.0, 0.5) = 0.15;

// Grid effect
uniform bool show_grid = true;
uniform float grid_intensity : hint_range(0.0, 0.3) = 0.1;

// Glow effect
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    // Get UV coordinates centered
    vec2 uv = UV - 0.5;
    
    // Apply curvature
    float dist = length(uv);
    float curvature_factor = 1.0 + curvature * dist * dist;
    vec2 curved_uv = uv / curvature_factor + 0.5;
    
    // Check if we're inside the screen area
    vec2 border_uv = curved_uv - 0.5;
    float border_x = abs(border_uv.x) - (0.5 - border_thickness);
    float border_y = abs(border_uv.y) - (0.5 - border_thickness);
    float is_border = max(border_x, border_y);
    
    // Check if we're inside the display area
    vec2 display_uv = curved_uv - 0.5;
    float display_x = abs(display_uv.x) - (0.5 - border_thickness * 1.5);
    float display_y = abs(display_uv.y) - (0.5 - border_thickness * 3.0);
    float is_display = max(display_x, display_y);
    
    // Screen background with border
    vec4 screen_base = screen_color;
    
    // Border with slight gradient
    float border_gradient = 1.0 - abs(border_uv.y) * 0.3;
    vec4 final_border = border_color * border_gradient;
    
    // Display area background
    vec4 display_base = display_color * 0.3;
    
    // Grid effect (calculator screen grid)
    float grid = 0.0;
    if (show_grid && is_display <= 0.0) {
        vec2 grid_uv = curved_uv * 80.0;
        vec2 grid_lines = abs(fract(grid_uv - 0.5) - 0.5);
        float grid_x = 1.0 - smoothstep(0.0, 0.02, grid_lines.x);
        float grid_y = 1.0 - smoothstep(0.0, 0.02, grid_lines.y);
        grid = max(grid_x, grid_y) * grid_intensity;
    }
    
    // Scanline effect
    float scanline = 0.0;
    if (show_scanlines && is_display <= 0.0) {
        float scanline_y = sin(curved_uv.y * 400.0 * 3.14159) * 0.5 + 0.5;
        scanline = scanline_y * scanline_intensity;
    }
    
    // Calculate final color
    vec4 final_color = vec4(0.0);
    
    if (is_border > 0.0) {
        // Outside screen - transparent
        final_color = vec4(0.0, 0.0, 0.0, 0.0);
    } else if (is_display > 0.0) {
        // Border area
        final_color = final_border;
        final_color.a = 1.0;
    } else {
        // Display area with effects
        vec4 display_color_final = display_base;
        display_color_final.rgb += vec3(0.0, 0.05, 0.0) * (1.0 - abs(display_uv.y) * 0.5);
        display_color_final += vec4(vec3(grid), 0.0);
        display_color_final += vec4(vec3(scanline), 0.0);
        
        final_color = display_color_final;
        final_color.a = 1.0;
        
        // Screen glare/reflection
        vec2 glare_uv = curved_uv - 0.5;
        float glare = 1.0 - smoothstep(0.0, 0.3, length(glare_uv - vec2(-0.3, 0.3)));
        final_color.rgb += vec3(0.0, 0.02, 0.0) * glare * 0.5;
    }
    
    // Add subtle vignette (only for non-transparent areas)
    if (final_color.a > 0.0) {
        float vignette = 1.0 - length(curved_uv - 0.5) * 0.3;
        final_color.rgb *= vignette;
    }
    
    COLOR = final_color;
}