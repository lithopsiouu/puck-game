shader_type canvas_item;

uniform sampler2D texture2;
uniform sampler2D colorTexture;

uniform vec2 scroll1 = vec2(0.1, 0.1);
uniform vec2 scroll2 = vec2(0.2, 0.2);

void fragment() {
	float textureColor1 = texture(TEXTURE, UV + scroll1 * TIME).r;
	float textureColor2 = texture(TEXTURE, UV + scroll2 * TIME).r;
	float energy = textureColor1 * textureColor2;
	vec4 color = texture(colorTexture, vec2(energy));
	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
