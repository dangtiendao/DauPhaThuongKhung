shader_type canvas_item;
render_mode blend_add;

// Shader Năng Lượng & Đấu Khí Hóa Dực Đa Tầng (fBM Flow + Noise Dissolve + Hot Rim):
// - Dùng cho Cánh Đấu Khí Hóa Dực, Trận Đồ Cổ Tự, Vòng Ngũ Luân Ly Hỏa & Cột Ánh Sáng Phẩm Chất.
// - Tương thích 100% GL Compatibility, không cần ảnh noise ngoài.
uniform vec4 core_color : source_color = vec4(1.0, 0.96, 0.80, 1.0);
uniform vec4 mid_color : source_color = vec4(0.0, 0.96, 0.83, 1.0);
uniform vec4 outer_color : source_color = vec4(0.62, 0.30, 0.87, 1.0);
uniform float intensity : hint_range(0.3, 3.0) = 1.35;
uniform float flow_speed : hint_range(0.0, 8.0) = 3.2;
uniform float wave_amp : hint_range(0.0, 0.08) = 0.022;
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_amp : hint_range(0.0, 0.5) = 0.14;

float hash21(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 34.53);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
		mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x),
		f.y
	);
}

float fbm(vec2 p) {
	return 0.62 * vnoise(p) + 0.38 * vnoise(p * 2.3 + vec2(4.1, 2.7));
}

void fragment() {
	float t = TIME * flow_speed;
	float n1 = fbm(UV * 6.0 + vec2(-t * 0.45, -t * 0.85));
	float n2 = fbm(UV * 11.0 + vec2(t * 0.6, -t * 1.15) + vec2(2.3, 5.1));

	vec2 uv_w = UV + vec2(n1 - 0.5, n2 - 0.5) * wave_amp;
	vec4 tex = texture(TEXTURE, clamp(uv_w, vec2(0.001), vec2(0.999)));

	float lum = clamp(dot(tex.rgb, vec3(0.299, 0.587, 0.114)) * (0.86 + 0.28 * n2), 0.0, 1.0);
	float pulse = 1.0 + sin(TIME * 4.5) * pulse_amp;

	float edge = dissolve * 1.25;
	float dmask = smoothstep(edge, edge + 0.24, tex.a * (0.52 + 0.68 * n1));
	// Mép cháy nóng rực quanh biên dissolve
	float burn_rim = smoothstep(edge, edge + 0.14, tex.a * (0.52 + 0.68 * n1)) * (1.0 - smoothstep(edge + 0.14, edge + 0.30, tex.a * (0.52 + 0.68 * n1))) * step(0.01, dissolve);

	vec3 col;
	if (lum > 0.62) {
		col = mix(mid_color.rgb, core_color.rgb, (lum - 0.62) / 0.38);
	} else if (lum > 0.24) {
		col = mix(outer_color.rgb, mid_color.rgb, (lum - 0.24) / 0.38);
	} else {
		col = outer_color.rgb * (lum / 0.24);
	}
	col += core_color.rgb * (burn_rim * 0.85 + smoothstep(0.78, 1.0, lum) * 0.28);

	COLOR = vec4(col * intensity * pulse, tex.a * COLOR.a * dmask);
}
