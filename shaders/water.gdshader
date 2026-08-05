shader_type canvas_item;

uniform vec2 speed = vec2(0.5, 0.2);
uniform float wave_height = 0.1;
uniform sampler2D noise_texture: filter_nearest, repeat_enable;

void vertex() {
	VERTEX.y += sin(TIME);
}

void fragment() {
    vec2 uv = SCREEN_UV + speed * TIME;
	vec2 noise = 2.0 * texture(noise_texture, uv).rg - vec2(1.0);
	COLOR = texture(TEXTURE, UV + noise * wave_height);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
