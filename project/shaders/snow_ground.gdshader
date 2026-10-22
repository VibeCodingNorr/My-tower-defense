shader_type spatial;
render_mode cull_back, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// M0.4.2: a single surface blends snow, ice and frosted edges.
// The serpentine route is decorative and does not define creep navigation.
// All distances below are in world units (camera-independent).
uniform vec4 snow_light : source_color = vec4(0.56, 0.63, 0.65, 1.0);
uniform vec4 snow_shadow : source_color = vec4(0.39, 0.49, 0.54, 1.0);
uniform vec4 ice_deep : source_color = vec4(0.23, 0.40, 0.49, 1.0);
uniform vec4 ice_light : source_color = vec4(0.35, 0.54, 0.61, 1.0);
uniform vec4 ice_rim : source_color = vec4(0.67, 0.72, 0.72, 1.0);
uniform float path_half_width = 2.05;
uniform float path_edge_softness = 0.48;
uniform float ground_grid_opacity : hint_range(0.0, 0.25) = 0.045;

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

float distance_segment(vec2 p, vec2 a, vec2 b) {
    vec2 v = b - a;
    float t = clamp(dot(p - a, v) / dot(v, v), 0.0, 1.0);
    return length(p - (a + t * v));
}

// One continuous route rather than nine overlaid, square-ended rectangles.
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

void fragment() {
    vec2 p = ground_xz;
    float coarse = noise21(p * 0.11);
    float speckle = noise21(p * 1.8);
    float ridge = noise21(p * 0.42);

    // Gentle, cool snow variations rather than overexposed white.
    vec3 snow = mix(snow_shadow.rgb, snow_light.rgb, 0.40 + 0.45 * coarse);
    snow += (speckle - 0.5) * 0.040;

    // A faint one-unit placement guide, visible only on the snowy surfaces.
    vec2 cell = abs(fract(p - 0.5) - 0.5) / max(fwidth(p), vec2(0.001));
    float grid_line = 1.0 - clamp(min(cell.x, cell.y), 0.0, 1.0);
    snow = mix(snow, snow_shadow.rgb, grid_line * ground_grid_opacity);

    float d = route_distance(p);
    float boundary = path_half_width + (coarse - 0.5) * 0.28 + (ridge - 0.5) * 0.22;
    float ice_mask = 1.0 - smoothstep(
        boundary - path_edge_softness,
        boundary + path_edge_softness,
        d
    );

    // Mottled frozen water; no repeated bright striping.
    float crack = noise21(p * 1.20 + vec2(ridge, coarse));
    float vein = abs(sin(p.x * 1.12 + p.y * 0.83 + coarse * 6.0));
    float frost = smoothstep(0.78, 0.97, vein) * (0.14 + 0.18 * crack);
    vec3 ice = mix(ice_deep.rgb, ice_light.rgb, 0.28 + 0.38 * crack);
    ice += vec3(0.08, 0.11, 0.11) * frost;

    // Frosted snowbank ring helps the player read every lane edge.
    float bank = smoothstep(boundary - 0.70, boundary - 0.12, d)
        * (1.0 - smoothstep(boundary + 0.12, boundary + 0.85, d));
    vec3 blended = mix(snow, ice, ice_mask);
    blended = mix(blended, ice_rim.rgb, bank * 0.48);

    ALBEDO = clamp(blended, vec3(0.0), vec3(1.0));
    ROUGHNESS = mix(0.91, 0.49, ice_mask);
    SPECULAR = mix(0.10, 0.29, ice_mask);
}
