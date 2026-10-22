shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// Preserve the Kenney tower atlas/details, but replace conspicuous magenta
// accents with weathered fantasy masonry. This affects ONLY static tower meshes.
uniform sampler2D source_texture : source_color, filter_linear_mipmap;
uniform bool has_texture = false;
uniform vec4 source_color : source_color = vec4(1.0);
uniform float purple_replacement : hint_range(0.0, 1.0) = 0.97;

void fragment() {
    vec3 sample_rgb = vec3(1.0);
    if (has_texture) {
        sample_rgb = texture(source_texture, UV).rgb;
    }
    vec3 base = sample_rgb * source_color.rgb;
    float purple = smoothstep(0.065, 0.23, base.b - base.g)
        * smoothstep(0.015, 0.15, base.r - base.g);
    float brightness = dot(base, vec3(0.25, 0.60, 0.15));
    vec3 winter_stone = mix(
        vec3(0.19, 0.25, 0.25),
        vec3(0.58, 0.59, 0.54),
        clamp(brightness * 1.30, 0.0, 1.0)
    );
    ALBEDO = mix(base, winter_stone, purple * purple_replacement);
    ROUGHNESS = 0.87;
    SPECULAR = 0.13;
}
