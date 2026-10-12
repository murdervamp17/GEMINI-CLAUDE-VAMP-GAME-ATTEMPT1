shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec2 effect_center = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 1.0) = 0.18;
uniform float ring_radius : hint_range(0.0, 1.0) = 0.08;
uniform float ring_width : hint_range(0.001, 0.2) = 0.025;
uniform float strength : hint_range(0.0, 0.08) = 0.012;
uniform float phase = 0.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 delta = uv - effect_center;
	float r = length(delta);
	float ring = exp(-pow((r - ring_radius) / ring_width, 2.0));
	float mask = 1.0 - smoothstep(radius * 0.65, radius, r);
	vec2 direction = delta / max(r, 0.0001);
	vec2 offset = direction * ring * strength * mask * sin(phase);
	vec4 scene = texture(screen_texture, uv + offset);
	COLOR = scene;
}
