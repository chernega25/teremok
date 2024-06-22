shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform bool selected = false;

void fragment() {
	if (selected)
		COLOR = color;
}