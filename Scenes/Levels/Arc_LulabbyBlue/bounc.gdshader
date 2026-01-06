// Converted/modified from ShaderToy: https://www.shadertoy.com/view/ldBXDD
// Attach this shader to a ColorRect

shader_type canvas_item;

uniform vec2 offset_center = vec2(0.0, 0.0);
uniform float wave_count : hint_range(1.0, 20.0, 1.0) = 20.0;
uniform float speed : hint_range(0.0, 100.0, 0.1) = 3.0;
uniform float height : hint_range(0.0, 1.0, 0.001) = 0.003;
uniform sampler2D tela : hint_screen_texture;

void fragment() {
	vec2 cPos = -1.0 + 2.0 * UV / (1.0 / TEXTURE_PIXEL_SIZE) + offset_center;
	float cLength = length(cPos);
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy + (cPos/cLength) * cos(cLength * wave_count - TIME * speed) * height;
    vec3 col = texture(tela,uv).xyz;
	COLOR.rgb = col;
}

