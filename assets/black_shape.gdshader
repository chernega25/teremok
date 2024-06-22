shader_type canvas_item;

uniform bool on = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (on) {
		color.r = 0.0;
		color.b = 0.0;
		color.g = 0.0;
	} 
	COLOR = color;
}

