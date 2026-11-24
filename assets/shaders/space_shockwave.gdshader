shader_type canvas_item;

// Sóng Biến Dạng Không Gian Thực (Screen-Space Shockwave Refraction + Chromatic Aberration nhẹ):
// - Tương thích 100% Godot 4 GL Compatibility (gl_compatibility), chạy mượt 60-144 FPS.
// - Khi gắn lên ColorRect phủ màn hình (ScreenFxOverlay), phát sóng khúc xạ bẻ cong bản đồ & quái vật
//   từ tâm `center_uv` với bán kính giãn nở `radius` và độ dày `thickness`.
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 center_uv = vec2(0.5, 0.5);
uniform float radius : hint_range(0.0, 1.5) = 0.0;
uniform float thickness : hint_range(0.01, 0.35) = 0.09;
uniform float force : hint_range(0.0, 0.12) = 0.0;
uniform float chroma_shift : hint_range(0.0, 0.025) = 0.005;
uniform vec4 ring_tint : source_color = vec4(0.45, 0.94, 0.87, 1.0);
uniform float ring_glow : hint_range(0.0, 1.5) = 0.45;
uniform float aspect_ratio = 1.7777;

void fragment() {
	vec2 diff = SCREEN_UV - center_uv;
	vec2 scaled = vec2(diff.x * aspect_ratio, diff.y);
	float dist = length(scaled);

	float outer = smoothstep(radius - thickness, radius, dist);
	float inner = 1.0 - smoothstep(radius, radius + thickness, dist);
	float ring_mask = clamp(outer * inner * 4.0, 0.0, 1.0);

	if (ring_mask <= 0.001 || force <= 0.0001) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		vec2 dir = dist > 0.0001 ? normalize(diff) : vec2(1.0, 0.0);
		vec2 disp = dir * ring_mask * force;
		vec2 uv_r = clamp(SCREEN_UV - disp - dir * chroma_shift * ring_mask, vec2(0.001), vec2(0.999));
		vec2 uv_g = clamp(SCREEN_UV - disp, vec2(0.001), vec2(0.999));
		vec2 uv_b = clamp(SCREEN_UV - disp + dir * chroma_shift * ring_mask, vec2(0.001), vec2(0.999));

		float r = texture(SCREEN_TEXTURE, uv_r).r;
		float g = texture(SCREEN_TEXTURE, uv_g).g;
		float b = texture(SCREEN_TEXTURE, uv_b).b;

		vec3 refracted = vec3(r, g, b);
		// Quầng sáng mảnh dọc đỉnh sóng khúc xạ tạo chiều sâu không gian nứt vỡ
		float crest = pow(ring_mask, 2.2) * ring_glow;
		vec3 final_col = refracted + ring_tint.rgb * crest;
		COLOR = vec4(final_col, clamp(ring_mask * 1.35, 0.0, 1.0));
	}
}
