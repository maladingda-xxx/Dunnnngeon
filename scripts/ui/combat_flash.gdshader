shader_type canvas_item;

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform bool forest_palette = false;
varying vec4 tint;

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
}

void fragment() {
	vec4 pixel = texture(TEXTURE, UV);
	if (forest_palette) {
		ivec2 sheet = textureSize(TEXTURE, 0);
		pixel.rgb = forest_green(pixel.rgb, ivec2(UV * vec2(sheet)), sheet.x);
	}
	pixel *= tint;
	COLOR = vec4(mix(pixel.rgb, vec3(1.0, 0.89, 0.76), flash), pixel.a);
}
