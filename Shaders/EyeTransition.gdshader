shader_type canvas_item;

uniform float eye_height : hint_range(0.0, 2.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5); // normalized center
uniform float smooth_edge : hint_range(0.0, 0.1) = 0.01;

void fragment() {
    vec2 uv = UV;
    vec2 dist = uv - center;

    float radius_x = 0.5;
    float radius_y = eye_height * 0.5;

    float ellipse = pow(dist.x / radius_x, 2.0) + pow(dist.y / radius_y, 2.0);

    // Compute the "hole" shape
    float mask = smoothstep(1.0 - smooth_edge, 1.0, ellipse);

    // Invert mask = transparent in center, solid outside
    COLOR.a *= mask;
}
