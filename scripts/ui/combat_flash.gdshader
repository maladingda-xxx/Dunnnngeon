shader_type canvas_item;

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform bool forest_palette = false;
uniform vec4 deform_region = vec4(0.0);
uniform vec2 deform_size = vec2(0.0);
uniform vec4 deformation = vec4(0.0);
varying vec4 tint;
const float POSE_OVERSCAN = 1.8;

// In each 192 px Archer frame, the quiver and tunic share the same brown.
// Each mask stores the first tunic row, the quiver gap on that row, and the left edge.
const ivec4 IDLE_TUNIC = ivec4(109, 83, 85, 79);
const ivec4 RUN_TUNIC[4] = {
	ivec4(110, 82, 84, 78), ivec4(108, 83, 84, 78),
	ivec4(111, 1, 0, 80), ivec4(108, 83, 84, 78)
};
const ivec4 SHOOT_TUNIC[8] = {
	ivec4(109, 82, 84, 77), ivec4(111, 1, 0, 76),
	ivec4(111, 1, 0, 75), ivec4(111, 1, 0, 75),
	ivec4(111, 1, 0, 75), ivec4(111, 81, 83, 76),
	ivec4(110, 79, 81, 75), ivec4(109, 82, 84, 77)
};

bool is_tunic(ivec2 pixel, int sheet_width) {
	int frame = pixel.x / 192;
	int x = pixel.x % 192;
	ivec4 mask = IDLE_TUNIC;
	if (sheet_width == 768) {
		mask = RUN_TUNIC[frame];
	} else if (sheet_width == 1536) {
		mask = SHOOT_TUNIC[frame];
	}
	bool after_quiver = x < mask.y || x > mask.z;
	return x >= mask.w && pixel.y <= 121
		&& (pixel.y > mask.x || (pixel.y == mask.x && after_quiver));
}

vec3 forest_green(vec3 source, ivec2 pixel, int sheet_width) {
	vec3 rgb8 = source * 255.0;
	if (distance(rgb8, vec3(136, 96, 73)) < 0.75 && is_tunic(pixel, sheet_width)) {
		return vec3(38, 77, 47) / 255.0;
	}
	if (distance(rgb8, vec3(172, 146, 86)) < 0.75) {
		return vec3(27, 61, 43) / 255.0;
	}
	if (distance(rgb8, vec3(213, 204, 69)) < 0.75) {
		return vec3(46, 96, 55) / 255.0;
	}
	if (distance(rgb8, vec3(255, 250, 186)) < 0.75) {
		return vec3(115, 151, 83) / 255.0;
	}
	return source;
}

void vertex() {
	tint = COLOR;
	if (deform_region.z > 0.0) {
		vec2 center = deform_size * 0.5;
		VERTEX = center + (VERTEX - center) * POSE_OVERSCAN;
	}
}

void fragment() {
	vec2 sample_uv = UV;
	float inside = 1.0;
	if (deform_region.z > 0.0) {
		vec2 local = ((UV - deform_region.xy) / deform_region.zw - 0.5) * POSE_OVERSCAN + 0.5;
		float upper = 1.0 - smoothstep(0.05, 0.94, local.y);
		float hem = smoothstep(0.40, 0.95, local.y);
		float wings = smoothstep(0.14, 0.49, abs(local.x - 0.5));
		local -= vec2(deformation.x * upper + deformation.w * hem,
			deformation.y * upper + deformation.z * wings);
		inside = step(0.0, local.x) * step(local.x, 1.0) * step(0.0, local.y) * step(local.y, 1.0);
		vec2 half_pixel = 0.5 * TEXTURE_PIXEL_SIZE;
		sample_uv = clamp(deform_region.xy + local * deform_region.zw,
			deform_region.xy + half_pixel, deform_region.xy + deform_region.zw - half_pixel);
	}
	vec4 pixel = texture(TEXTURE, sample_uv);
	pixel.a *= inside;
	if (forest_palette) {
		ivec2 sheet = textureSize(TEXTURE, 0);
		pixel.rgb = forest_green(pixel.rgb, ivec2(UV * vec2(sheet)), sheet.x);
	}
	pixel *= tint;
	COLOR = vec4(mix(pixel.rgb, vec3(1.0, 0.89, 0.76), flash), pixel.a);
}
