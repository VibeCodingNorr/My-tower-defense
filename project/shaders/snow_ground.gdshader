shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// M0.4.3 — Painterly winter terrain. Entire decorative path blends into snow.
// No collision, routing, navigation or game logic.
uniform vec4 snow_light : source_color = vec4(0.65, 0.70, 0.69, 1.0);
uniform vec4 snow_shadow : source_color = vec4(0.38, 0.46, 0.46, 1.0);
uniform vec4 ice_deep : source_color = vec4(0.20, 0.36, 0.45, 1.0);
uniform vec4 ice_light : source_color = vec4(0.37, 0.54, 0.60, 1.0);
uniform vec4 ice_rim : source_color = vec4(0.65, 0.72, 0.72, 1.0);
uniform vec4 stony_ground : source_color = vec4(0.26, 0.34, 0.33, 1.0);
uniform float path_half_width = 2.05;
uniform float path_edge_softness = 0.50;
uniform float ground_grid_opacity : hint_range(0.0, 0.25) = 0.034;

varying vec2 ground_xz;

void vertex() {
    ground_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float noise21(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
        mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x),
        f.y
    );
}

float fbm(vec2 p) {
    return noise21(p) * 0.54 +
        noise21(p * 2.13 + 12.5) * 0.29 +
        noise21(p * 4.37 - 16.3) * 0.17;
}

float distance_segment(vec2 p, vec2 a, vec2 b) {
    vec2 v = b - a;
    float t = clamp(dot(p - a, v) / max(dot(v, v), 0.0001), 0.0, 1.0);
    return length(p - (a + t * v));
}

float route_distance(vec2 p) {
    float d = distance_segment(p, vec2(-16.0, -16.0), vec2(16.0, -16.0));
    d = min(d, distance_segment(p, vec2(16.0, -16.0), vec2(16.0, -8.0)));
    d = min(d, distance_segment(p, vec2(16.0, -8.0), vec2(-16.0, -8.0)));
    d = min(d, distance_segment(p, vec2(-16.0, -8.0), vec2(-16.0, 0.0)));
    d = min(d, distance_segment(p, vec2(-16.0, 0.0), vec2(16.0, 0.0)));
    d = min(d, distance_segment(p, vec2(16.0, 0.0), vec2(16.0, 8.0)));
    d = min(d, distance_segment(p, vec2(16.0, 8.0), vec2(-16.0, 8.0)));
    d = min(d, distance_segment(p, vec2(-16.0, 8.0), vec2(-16.0, 16.0)));
    d = min(d, distance_segment(p, vec2(-16.0, 16.0), vec2(16.0, 16.0)));
    return d;
}

float build_spots(vec2 p) {
    float d = length(p - vec2(-8.0, -12.0));
    d = min(d, length(p - vec2(8.0, -4.0)));
    d = min(d, length(p - vec2(-3.0, 4.0)));
    d = min(d, length(p - vec2(-8.0, 12.0)));
    d = min(d, length(p - vec2(8.0, -12.0)));
    return d;
}

void fragment() {
    vec2 p = ground_xz;
    float macro = fbm(p * 0.10);
    float medium = fbm(p * 0.41);
    float grains = noise21(p * 2.55);

    // Break up the uniform blue snow with warmer rock/gravel pockets.
    vec3 snow = mix(snow_shadow.rgb, snow_light.rgb, clamp(macro * 0.63 + medium * 0.29, 0.0, 1.0));
    snow += (grains - 0.5) * 0.035;
    float gravel = smoothstep(0.64, 0.77, medium + (grains - 0.5) * 0.10);
    snow = mix(snow, stony_ground.rgb, gravel * 0.50);

    // A darker, rugged substrate around static tower scale-reference props.
    float pad_dist = build_spots(p);
    float patch_edge = 2.40 + (medium - 0.5) * 0.8;
    float stone_patch = 1.0 - smoothstep(patch_edge - 0.45, patch_edge + 0.65, pad_dist);
    snow = mix(snow, stony_ground.rgb * (0.87 + 0.20 * medium), stone_patch * 0.68);

    // Almost invisible building grid — retained for visual proportions.
    vec2 cell = abs(fract(p - 0.5) - 0.5) / max(fwidth(p), vec2(0.001));
    float grid_line = 1.0 - clamp(min(cell.x, cell.y), 0.0, 1.0);
    snow = mix(snow, snow_shadow.rgb, grid_line * ground_grid_opacity);

    float d = route_distance(p);
    float edge_noise = (fbm(p * 0.68) - 0.5) * 0.78;
    float boundary = path_half_width + edge_noise;
    float ice_mask = 1.0 - smoothstep(
        boundary - path_edge_softness,
        boundary + path_edge_softness,
        d
    );

    // Subtle fractured ice instead of repeated bright diagonal stripes.
    float cracks = fbm(p * 0.83 + vec2(medium * 2.3, macro * 1.6));
    float thin_vein = abs(sin(p.x * 0.79 + p.y * 0.36 + macro * 5.0));
    float vein = smoothstep(0.965, 0.994, thin_vein) * (0.18 + 0.24 * cracks);
    vec3 ice = mix(ice_deep.rgb, ice_light.rgb, clamp(0.22 + cracks * 0.52, 0.0, 1.0));
    ice += vec3(0.10, 0.14, 0.14) * vein;

    // Snow-lipped banks deliberately imperfect rather than uniform neon lines.
    float bank = smoothstep(boundary - 0.68, boundary - 0.14, d) *
        (1.0 - smoothstep(boundary + 0.04, boundary + 0.73, d));
    float bank_shade = 0.34 + 0.24 * medium;
    vec3 blended = mix(snow, ice, ice_mask);
    blended = mix(blended, ice_rim.rgb, bank * bank_shade);

    ALBEDO = clamp(blended, vec3(0.0), vec3(1.0));
    ROUGHNESS = mix(0.91, 0.53, ice_mask);
    SPECULAR = mix(0.12, 0.28, ice_mask);
}
