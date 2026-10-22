shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// M0.4.6 static display treatment: preserve Kenney details but give their
// bright/purple atlas colors a muted medieval winter palette.
// No source GLB or gameplay materials are modified.
uniform sampler2D source_texture : source_color, filter_linear_mipmap;
uniform bool has_texture = false;
uniform vec4 source_tint : source_color = vec4(1.0);
uniform float material_brightness : hint_range(0.2, 1.0) = 0.68;
uniform float purple_replacement : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec3 sampled = vec3(1.0);
    if (has_texture) {
        sampled = texture(source_texture, UV).rgb;
    }
    vec3 base = clamp(sampled * source_tint.rgb, vec3(0.0), vec3(1.0));
    float value = dot(base, vec3(0.25, 0.62, 0.13));

    // Count magenta and lilac as one family; avoid recoloring neutral grays.
    float violet = smoothstep(0.045, 0.20, base.b - base.g)
        * smoothstep(-0.03, 0.07, base.r - base.g);

    // Recolor saturated purple blocks to slightly brown-gray winter masonry.
    vec3 aged_stone = mix(
        vec3(0.20, 0.25, 0.24),
        vec3(0.48, 0.49, 0.43),
        clamp(value * 1.15, 0.0, 1.0)
    );

    // Keep atlas UV detail and shading, but reduce the eye-catching white.
    vec3 neutral = mix(vec3(value), base, 0.58);
    neutral *= material_brightness;
    vec3 result_color = mix(neutral, aged_stone, violet * purple_replacement);

    ALBEDO = clamp(result_color, vec3(0.0), vec3(0.66));
    ROUGHNESS = 0.93;
    SPECULAR = 0.09;
}
