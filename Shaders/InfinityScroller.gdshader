shader_type canvas_item;

uniform vec2 motion = vec2(0.0);
uniform float scale = 1.0;
uniform vec2 offset = vec2(0.0);


uniform vec4 color_gap: source_color  = vec4(0.25);
uniform vec4 color_stripe: source_color  = vec4(1.0, 0.75, 0.0, 1.0);
uniform float divisions = 8.0; // increase for more stripe density
uniform float stripe_bias = 2.5; // 1.0 means no stripes; 2.0 means stripes and gaps are equal size
uniform float speed = 0.1;
uniform float angle = 0.7854; // in radians
uniform float alpha : hint_range(0.0, 1.0, 0.01) = 0.5; // alpha carai


void vertex(){
	UV = (VERTEX + offset + TIME * motion) * TEXTURE_PIXEL_SIZE * (1.0/scale);
}

void fragment() {
	COLOR = texture(TEXTURE,UV);
	float w = cos(angle) * UV.x + sin(angle) * UV.y - speed * TIME;
	COLOR.a *= alpha;
	if (floor(mod(w * divisions, stripe_bias)) < 0.0001) {
		COLOR.rgb = color_gap.rgb ;
	} else {
		COLOR.rg = color_stripe.rg;
	}
}