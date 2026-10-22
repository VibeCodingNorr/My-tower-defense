shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// Opaque, stylized frozen lanes. Gameplay/pathfinding will be separate.
uniform vec4 ice_base : source_color = vec4(0.42, 0.63, 0.73, 1.0);
uniform vec4 ice_light : source_color = vec4(0.67, 0.82, 0.90, 1.0);
uniform vec4 frost : source_color = vec4(0.86, 0.91, 0.95, 1.0);
uniform float noise_scale = 10.0;
uniform float streak_scale = 26.0;

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
    float n = noise2d(UV * noise_scale);
    float streak = 0.5 + 0.5 * sin((UV.x + UV.y) * streak_scale + n * 4.0);

    vec3 color = mix(ice_base.rgb, ice_light.rgb, streak * 0.35 + n * 0.35);
    color = mix(color, frost.rgb, smoothstep(0.72, 1.0, n) * 0.20);

    ALBEDO = color;
    ROUGHNESS = 0.14;
    SPECULAR = 0.86;
    EMISSION = ice_light.rgb * 0.018;
}
