shader_type canvas_item;

uniform sampler2D refraction_map;
uniform vec2 refraction_stretch = vec2(1.0, 1.0);
uniform float refraction_strength : hint_range(0.0, 0.1) = 0.02;
uniform float speed : hint_range(0.0, 1.0) = 0.1;

uniform sampler2D normal_map : hint_normal;
uniform float wave_scale = 8.0;
uniform float wave_speed = 0.3;
uniform float normal_strength = 0.25;

uniform float reflection_strength : hint_range(0.0, 1.0) = 0.85;
uniform float reflection_distortion = 0.02;

uniform vec4 water_tint : source_color = vec4(0.1, 0.45, 0.7, 0.35);
uniform float color_mix : hint_range(0.0,1.0) = 0.4;

uniform float edge_glow = 0.12;
uniform float edge_power = 2.2;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

varying vec2 globalposition;

void vertex(){
	globalposition = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment()
{
	vec2 uv = UV;
	float t = TIME * wave_speed;

	vec2 g_uv = globalposition / 512.0;
	vec2 r_uv = vec2(
		mod(g_uv.x * refraction_stretch.x + TIME * speed, 1.0),
		mod(g_uv.y * refraction_stretch.y + TIME * speed, 1.0)
	);

	vec2 refraction_offset = texture(refraction_map, r_uv).xy;
	refraction_offset -= 0.5;

	vec2 uvA = uv * wave_scale + vec2(t, t * 0.4);
	vec2 uvB = uv * wave_scale * 0.9 + vec2(-t * 0.6, t * 0.3);

	vec3 n1 = texture(normal_map, uvA).rgb * 2.0 - 1.0;
	vec3 n2 = texture(normal_map, uvB).rgb * 2.0 - 1.0;
	vec3 normal = normalize(vec3(n1.xy + n2.xy, 1.0));
	normal.xy *= normal_strength;

	vec2 final_offset = refraction_offset * refraction_strength + normal.xy * reflection_distortion;

	// normal background sample
	vec2 screen_uv = SCREEN_UV - final_offset;
	screen_uv = clamp(screen_uv, vec2(0.001), vec2(0.999));
	vec4 scene_color = texture(SCREEN_TEXTURE, screen_uv);

	// ****** vertical mirror UV ******
	vec2 mirror_uv = vec2(SCREEN_UV.x, 1.0 - SCREEN_UV.y) - final_offset;
	mirror_uv = clamp(mirror_uv, vec2(0.001), vec2(0.999));
	vec4 mirror_scene = texture(SCREEN_TEXTURE, mirror_uv);

	// blend mirror with scene reflection
	vec3 reflected = mix(scene_color.rgb, mirror_scene.rgb, reflection_strength);

	// fresnel edge shimmer
	float edge = pow(1.0 - abs(uv.y * 2.0 - 1.0), edge_power) * edge_glow;

	vec3 tinted = mix(reflected, water_tint.rgb, color_mix);
	tinted += edge;

	COLOR = vec4(tinted, water_tint.a);
}
