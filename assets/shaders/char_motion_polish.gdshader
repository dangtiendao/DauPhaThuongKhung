shader_type canvas_item;

// Shader Tăng Mượt Hoạt Ảnh 60-144 FPS cho Nhân Vật & Boss (Pixel-Crisp Cloth Sway + Đấu Khí Rim-Glow + Hit Flash):
// - Khóa cứng bàn chân (cell_y >= 0.78) để chống trượt chân tuyệt đối!
// - Phất nhẹ phần tóc, dải lụa, áo choàng ở nửa trên bằng sóng sin mượt 60 FPS (an toàn ranh giới từng ô hframes x vframes).
// - Viền sáng Đấu Khí / Dị Hỏa 1px dọc biên hình bóng khi Gồng chiêu, Bộc phát Phase 2 hoặc Đấu Vương Hóa Dực!
// - Hỗ trợ hit_flash trắng sắc nét không làm mất màu nền gốc.

uniform float hframes = 4.0;
uniform float vframes = 2.0;
uniform float sway_amp : hint_range(0.0, 0.03) = 0.005;
uniform float sway_speed : hint_range(0.0, 12.0) = 3.2;
uniform vec4 rim_color : source_color = vec4(0.44, 0.84, 1.0, 1.0);
uniform float rim_strength : hint_range(0.0, 1.5) = 0.0;
uniform float hit_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 grid = vec2(max(1.0, hframes), max(1.0, vframes));
	vec2 cell_size = vec2(1.0) / grid;
	vec2 cell_idx = floor(UV * grid);
	vec2 cell_min = cell_idx * cell_size;
	vec2 cell_max = cell_min + cell_size;
	vec2 local_uv = (UV - cell_min) / cell_size;

	// Khóa cứng bàn chân (local_uv.y >= 0.78 -> weight = 0.0); phất mềm từ eo lên đỉnh đầu
	float upper_w = clamp((0.78 - local_uv.y) / 0.78, 0.0, 1.0);
	float sway_curve = upper_w * upper_w;
	float wave = sin(TIME * sway_speed + local_uv.y * 5.2) * sway_amp * sway_curve;

	vec2 sample_local = vec2(local_uv.x + wave, local_uv.y);
	// Chống tràn sang ô bên cạnh trong SpriteSheet (nếu ngoài [0,1] của ô -> trong suốt)
	bool out_of_cell = (sample_local.x < 0.0 || sample_local.x > 1.0 || sample_local.y < 0.0 || sample_local.y > 1.0);
	vec2 sample_uv = clamp(cell_min + sample_local * cell_size, cell_min + vec2(0.0005), cell_max - vec2(0.0005));

	vec4 tex = out_of_cell ? vec4(0.0) : texture(TEXTURE, sample_uv);
	vec4 out_col = tex * COLOR;

	// Rim-Glow Đấu Khí 1px quanh đường viền nhân vật (chỉ chạy khi rim_strength > 0.01 để tiết kiệm GPU)
	if (rim_strength > 0.01 && tex.a > 0.15) {
		vec2 px = TEXTURE_PIXEL_SIZE;
		float a_l = (sample_uv.x - px.x < cell_min.x) ? 0.0 : texture(TEXTURE, sample_uv + vec2(-px.x, 0.0)).a;
		float a_r = (sample_uv.x + px.x > cell_max.x) ? 0.0 : texture(TEXTURE, sample_uv + vec2(px.x, 0.0)).a;
		float a_u = (sample_uv.y - px.y < cell_min.y) ? 0.0 : texture(TEXTURE, sample_uv + vec2(0.0, -px.y)).a;
		float a_d = (sample_uv.y + px.y > cell_max.y) ? 0.0 : texture(TEXTURE, sample_uv + vec2(0.0, px.y)).a;
		float min_nb = min(min(a_l, a_r), min(a_u, a_d));
		float edge_mask = clamp(1.0 - smoothstep(0.10, 0.55, min_nb), 0.0, 1.0);
		float rim_pulse = 0.82 + 0.18 * sin(TIME * 7.5 + local_uv.y * 6.0);
		out_col.rgb = mix(out_col.rgb, rim_color.rgb * (1.28 * rim_pulse), edge_mask * clamp(rim_strength * 0.72, 0.0, 0.92));
	}

	// Hit-Flash trắng sắc nét khi trúng đòn
	if (hit_flash > 0.01 && out_col.a > 0.05) {
		out_col.rgb = mix(out_col.rgb, vec3(1.0, 0.98, 0.94) * 1.45, hit_flash);
	}

	COLOR = out_col;
}
