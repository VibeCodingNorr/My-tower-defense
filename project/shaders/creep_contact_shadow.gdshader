shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled, depth_draw_never;

// A non-gameplay oval contact shadow, anchored to the ground plane.
// Fades out at the edge instead of showing a hard black sticker.
uniform vec4 shade : source_color = vec4(0.045, 0.085, 0.10, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.33;

void fragment() {
    vec2 c = (UV - vec2(0.5)) * 2.0;
    float d = length(c);
    ALBEDO = shade.rgb;
    ALPHA = strength * (1.0 - smoothstep(0.26, 1.0, d));
}
