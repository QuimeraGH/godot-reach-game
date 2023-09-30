shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR.rgb = tex_color.rgb * 0.5; // This makes the sprite darker
}
