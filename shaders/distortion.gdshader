shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 scroll = vec2(0.05,0.05);
uniform float strength = 0.01;
uniform bool useMask = false;
uniform sampler2D mask;

void fragment() {
	vec2 distortedUV = SCREEN_UV + texture(TEXTURE, UV + scroll * TIME).r * strength;
	vec4 screenColor = texture(SCREEN_TEXTURE, distortedUV);
	COLOR = screenColor;
	if (useMask) {
		COLOR.a = texture(mask, UV).r;
	}
}