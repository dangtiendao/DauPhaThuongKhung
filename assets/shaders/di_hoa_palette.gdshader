shader_type canvas_item;

// Shader đổi bảng màu (Palette Swap) cho cả 23 loại Dị Hỏa & Thú Hỏa!
// Chỉ cần vẽ hiệu ứng lửa/vệt chém ở thang độ xám (Grayscale), Shader sẽ nhuộm 3 tầng lửa:
// - core_color: Tâm lửa sáng rực
// - mid_color: Thân ngọn lửa
// - outer_color: Viền lửa ngoài cùng
uniform vec4 core_color : source_color = vec4(1.0, 0.95, 0.70, 1.0);
uniform vec4 mid_color : source_color = vec4(1.0, 0.48, 0.05, 1.0);
uniform vec4 outer_color : source_color = vec4(0.62, 0.16, 0.17, 1.0);
uniform float intensity : hint_range(0.5, 3.0) = 1.25;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
	vec3 mapped;
	if (lum > 0.68) {
		mapped = mix(mid_color.rgb, core_color.rgb, (lum - 0.68) / 0.32);
	} else if (lum > 0.32) {
		mapped = mix(outer_color.rgb, mid_color.rgb, (lum - 0.32) / 0.36);
	} else {
		mapped = outer_color.rgb * (lum / max(0.01, 0.32));
	}
	COLOR = vec4(mapped * intensity, tex.a * COLOR.a);
}
