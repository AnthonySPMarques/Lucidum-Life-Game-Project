shader_type canvas_item;

//eraser unifroms
uniform float percent_bar : hint_range(0.0, 1.0) = 1.0;

void fragment() {

    //Eraser Shader
    //vec4 current_color = texture(TEXTURE, UV);
    vec4 transparence = vec4(0.0, 0.0, 0.0, 0.0);

    COLOR = texture(TEXTURE, vec2(percent_bar * UV.x, UV.y));

}