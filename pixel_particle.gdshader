shader_type canvas_item;
render_mode unshaded;

uniform float alpha_cutoff : hint_range(0.0, 1.0) = 0.03;
uniform vec4 tint : source_color = vec4(0.78, 0.04, 0.15, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec4 result = tex * COLOR * tint;
	if (result.a < alpha_cutoff) {
		discard;
	}
	COLOR = result;
}
