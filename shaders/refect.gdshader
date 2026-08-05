shader_type canvas_item;

// --- Reflection distortion ---
uniform float wave_speed : hint_range(0.0, 5.0) = 1.2;
uniform float wave_amplitude : hint_range(0.0, 0.05) = 0.006;
uniform float wave_frequency : hint_range(1.0, 60.0) = 18.0;

// --- Color grading ---
uniform vec4 water_tint : source_color = vec4(0.078, 0.596, 0.863, 1.0); // #1498dc
uniform float tint_strength : hint_range(0.0, 1.0) = 0.8;
uniform float darken : hint_range(0.0, 1.0) = 0.8;

// --- Pixelation, for a retro/pixel-art look. Set to 0.0 to disable. ---
uniform float pixel_size : hint_range(0.0, 0.02) = 0.0035;

// --- Bright thin line right at the water surface ---
uniform float surface_line_width : hint_range(0.0, 0.02) = 0.004;
uniform vec4 surface_line_color : source_color = vec4(0.4, 0.75, 0.95, 0.7);

// --- Where the water surface sits, in SCREEN UV space (0 = top, 1 = bottom).
// Updated every frame from GDScript, see water_controller.gd ---
uniform float water_level_uv : hint_range(0.0, 1.0) = 0.5;

// --- Camera pan offset in UV space, keeps the pixelation grid locked
// to the world instead of the screen (prevents shimmer while camera moves) ---
uniform vec2 world_offset_uv = vec2(0.0);

// --- The mirrored world render, from ReflectionViewport. This already IS
// the correct reflection - no further vertical mirror math needed here. ---
uniform sampler2D reflection_tex : filter_linear;
uniform sampler2D noise_tex : filter_nearest;
uniform float noise_strength : hint_range(0.0, 1.0) = 0.2;
uniform float noise_scale : hint_range(1.0, 200.0) = 40.0;
uniform float water_world_y = -100.0;

uniform vec2 ripple_center = vec2(-1000.0, -1000.0);
uniform float ripple_time = -100.0;
uniform float ripple_speed = 0.35;
uniform float ripple_width = 0.015;
uniform float ripple_strength = 0.015;
uniform float ripple_age = -1.0;
uniform float ripple_lifetime : hint_range(0.5, 10.0) = 2.5;

void fragment() {
    vec2 uv = SCREEN_UV;

    if (uv.y < water_level_uv) {
        // Above the waterline: the real scene is already visible beneath
        // this node, so leave it untouched.
        COLOR = vec4(0.0);
    } else {
        vec2 sample_uv = uv;
		
		float age = ripple_age;
		if (age > 0.0 && age < ripple_lifetime) {
		    float radius = age * ripple_speed;
		    float life_fade = 1.0 - smoothstep(0.0, ripple_lifetime, age);
		    float width = ripple_width * (1.0 + radius * 1.5);

		    vec2 dir = sample_uv - ripple_center;
		    float d = length(dir);

		    // Height-field wave value at this point (a thin ring, not a whole-scene lens)
		    float wave = exp(-pow((d - radius) / width, 2.0)) * life_fade;

		    // Approximate the wave's gradient (slope) instead of pushing radially outward.
		    // This is what real refraction responds to: how steep the ripple is, not
		    // "away from center" direction — so it reads as a surface ripple, not a shove.
		    float eps = 0.002;
		    float wave_dx = exp(-pow((length(sample_uv + vec2(eps,0.0) - ripple_center) - radius) / width, 2.0)) * life_fade - wave;
		    float wave_dy = exp(-pow((length(sample_uv + vec2(0.0,eps) - ripple_center) - radius) / width, 2.0)) * life_fade - wave;

		    sample_uv += vec2(wave_dx, wave_dy) * (ripple_strength / eps) * 0.02;
		}

        // Lock pixelation grid to world space to avoid shimmer during camera motion
        if (pixel_size > 0.0) {
            vec2 shifted = sample_uv + world_offset_uv;
            shifted = floor(shifted / pixel_size) * pixel_size;
            sample_uv = shifted - world_offset_uv;
        }

        // Horizontal wobble
        sample_uv.x += sin(sample_uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
		
		vec2 reflection_uv = sample_uv;
		reflection_uv.y = 1.0 - reflection_uv.y;
        vec4 reflection = texture(
		    reflection_tex,
		    clamp(reflection_uv, vec2(0.0), vec2(1.0))
		);
		
	

		vec4 noise = texture(noise_tex, sample_uv * noise_scale);

		// Only show noise near the surface
		float surface_fade = 1.0 - smoothstep(0.0, 0.25, uv.y - water_level_uv);

		// Use the noise as a brightness mask
		float ripple = noise.r * surface_fade;

        // Flat, uniform darken + tint
        reflection.rgb *= (1.0 - darken);
        reflection.rgb = mix(reflection.rgb, water_tint.rgb, tint_strength);
		
		//float ripple = texture(noise_tex, sample_uv * noise_scale).r;
		reflection.rgb = mix(
		    reflection.rgb,
		    reflection.rgb * 0.6 + vec3(0.3,0.7,1.0),
		    ripple * noise_strength
		);

        vec4 result = vec4(reflection.rgb, 1.0);

        // Bright thin line at the surface itself
        float line = 1.0 - smoothstep(0.0, surface_line_width, uv.y - water_level_uv);
        result.rgb = mix(result.rgb, surface_line_color.rgb, line * surface_line_color.a);

        COLOR = result;
    }
}
