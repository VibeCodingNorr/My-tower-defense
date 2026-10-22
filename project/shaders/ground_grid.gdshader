shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 grass : source_color = vec4(0.25, 0.39, 0.34, 1.0);
uniform vec4 grid_line : source_color = vec4(0.37, 0.52, 0.53, 1.0);
uniform float cells = 48.0;
uniform float line_strength : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    vec2 cell_uv = UV * cells;
    vec2 lines = abs(fract(cell_uv - 0.5) - 0.5) / max(fwidth(cell_uv), vec2(0.0001));
    float mask = 1.0 - clamp(min(lines.x, lines.y), 0.0, 1.0);
    ALBEDO = mix(grass.rgb, grid_line.rgb, mask * line_strength);
    ROUGHNESS = 1.0;
}
