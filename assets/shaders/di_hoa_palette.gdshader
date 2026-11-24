shader_type canvas_item;
render_mode blend_add;

// Shader Dị Hỏa & Thú Hỏa Động 60 FPS (Palette Swap + Lửa Chảy + Hòa Trộn Phát Sáng Additive):
// - Nhuộm 3 tầng lửa (core / mid / outer) cho đủ 23 Dị Hỏa & Thú Hỏa từ sprite Grayscale.
// - Tự sinh nhiễu dòng chảy 2 tầng (procedural fBM) giúp viền lửa uốn lượn, rực sáng không cần ảnh noise ngoài.
// - Hỗ trợ dissolve để vệt chém / vụ nổ tan biến mượt thành tàn lửa thay vì tắt đột ngột.
uniform vec4 core_color : source_color = vec4(1.0, 0.95, 0.70, 1.0);
uniform vec4 mid_color : source_color = vec4(1.0, 0.48, 0.05, 1.0);
uniform vec4 outer_color : source_color = vec4(0.62, 0.16, 0.17, 1.0);
uniform float intensity : hint_range(0.4, 3.5) = 1.45;
uniform float flow_speed : hint_range(0.0, 8.0) = 2.6;
uniform float turbulence : hint_range(0.0, 0.25) = 0.055;
uniform vec2 scroll_dir = vec2(-1.0, -0.35);
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm2(vec2 p) {
	float v = 0.0;
	v += 0.65 * value_noise(p);
	v += 0.35 * value_noise(p * 2.15 + vec2(3.7, 1.9));
	return v;
}

void fragment() {
	float t = TIME * flow_speed;
	vec2 n_uv = UV * 5.5 + scroll_dir * t;
	float n1 = fbm2(n_uv);
	float n2 = fbm2(UV * 9.0 - scroll_dir * (t * 1.45) + vec2(1.7, 4.3));

	vec2 warped_uv = UV + vec2(n1 - 0.5, n2 - 0.5) * turbulence;
	vec4 tex = texture(TEXTURE, clamp(warped_uv, vec2(0.001), vec2(0.999)));

	float raw_lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	float flicker = 0.88 + 0.24 * n2;
	float lum = clamp(raw_lum * flicker + (n1 - 0.5) * 0.14 * tex.a, 0.0, 1.0);

	// Dissolve mượt từ viền ngoài vào tâm lửa (đảm bảo tan sạch hoàn toàn khi dissolve = 1.0)
	float dissolve_edge = dissolve * 1.25;
	float dissolve_mask = smoothstep(dissolve_edge, dissolve_edge + 0.26, tex.a * (0.55 + 0.65 * n1));
	float final_a = tex.a * COLOR.a * dissolve_mask;

	vec3 mapped;
	if (lum > 0.64) {
		mapped = mix(mid_color.rgb, core_color.rgb, (lum - 0.64) / 0.36);
	} else if (lum > 0.28) {
		mapped = mix(outer_color.rgb, mid_color.rgb, (lum - 0.28) / 0.36);
	} else {
		mapped = outer_color.rgb * (lum / 0.28);
	}

	// Quầng sáng nhẹ ở lõi trắng nóng để Additive Blend rực mà không bị bệt phẳng
	float hot_core = smoothstep(0.76, 1.0, lum) * 0.32;
	vec3 final_rgb = (mapped + core_color.rgb * hot_core) * intensity;
	COLOR = vec4(final_rgb, final_a);
}
