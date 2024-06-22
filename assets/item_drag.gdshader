shader_type canvas_item;

uniform bool drag = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (drag) color.a = color.a / 2.0;
	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
