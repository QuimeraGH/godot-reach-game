shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR.rgb = vec3(1.0); // This makes the sprite white
}
