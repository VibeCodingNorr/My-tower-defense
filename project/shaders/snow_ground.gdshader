shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// Snow color variation and subtle 1m placement reference grid.
// No textures or proprietary Warcraft assets required.
uniform vec4 snow_a : source_color = vec4(0.73, 0.79, 0.82, 1.0);
uniform vec4 snow_b : source_color = vec4(0.63, 0.70, 0.74, 1.0);
uniform vec4 packed_snow : source_color = vec4(0.56, 0.64, 0.68, 1.0);
uniform float macro_scale = 7.0;
uniform float detail_scale = 32.0;
uniform float grid_strength : hint_range(0.0, 1.0) = 0.06;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x),
        u.y
    );
}

void fragment() {
    float macro = noise2d(UV * macro_scale);
    float detail = noise2d(UV * detail_scale);
    float blend = clamp(macro * 0.75 + detail * 0.25, 0.0, 1.0);

    vec3 color = mix(snow_a.rgb, snow_b.rgb, blend);

    vec2 grid_uv = UV * 96.0;
    vec2 lines = abs(fract(grid_uv - 0.5) - 0.5) / max(fwidth(grid_uv), vec2(0.0001));
    float grid_mask = 1.0 - clamp(min(lines.x, lines.y), 0.0, 1.0);
    color = mix(color, packed_snow.rgb, grid_mask * grid_strength);

    ALBEDO = color;
    ROUGHNESS = 0.96;
    SPECULAR = 0.08;
}
