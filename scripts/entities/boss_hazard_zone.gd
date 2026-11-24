class_name BossHazardZone
extends Node2D
## Vùng Kỹ Năng Mặt Đất của Boss chuẩn 60–144 FPS (Additive Blend + Soft Particles + Easing Curves):
## - "pillar": Cột Lửa Đan Vương Cổ Hà / Băng Trụ Hải Ba Đông / Đại Thủ Ấn Vân Sơn (cột năng lượng giáng từ trời + sóng xung kích kép).
## - "pool": Vũng Độc Liễu Tịch / Hồ Dung Nham Hỏa Linh Xà (hồ xoáy đa tầng + bong bóng nổ gợn sóng + tàn hạt bốc lên).
## - "vortex": Lốc Cát Mặc Ba Tư / Không Gian Vặn Vẹo Mặc Thừa / Phong Quyển (6 nhánh xoáy hút tâm tốc độ cao + vòng xoay ngược chiều + hạt xoáy).

const PILLAR_BEAM_HEIGHT: float = 620.0

var zone_mode: String = "pillar" # "pillar" (báo trước rồi nổ 1 lần), "pool" (tồn tại gây DoT), "vortex" (hút + DoT)
var radius_px: float = 82.0
var telegraph_sec: float = 0.85
var active_sec: float = 0.35
var damage_val: float = 24.0
var attacker_realm: int = 3
var zone_color: Color = Color("#FF7B00")
var apply_slow_ratio: float = 0.0
var apply_slow_sec: float = 0.0
var pull_strength: float = 0.0

var elapsed: float = 0.0
var exploded: bool = false
var tick_accum: float = 0.0

var _visual_elapsed: float = 0.0
var _detonate_vis_time: float = 0.0
var _core_color: Color = Color("#FFF6DC")
var _outer_color: Color = Color("#9E2A2B")
var _active_particles: CPUParticles2D = null
var _pool_bubbles: Array[Dictionary] = []


func configure_hazard(
	pos: Vector2,
	mode_str: String,
	rad: float,
	tele_s: float,
	act_s: float,
	dmg: float,
	realm_i: int,
	col: Color,
	slow_r: float = 0.0,
	slow_d: float = 0.0,
	pull_s: float = 0.0
) -> void:
	global_position = pos
	zone_mode = mode_str
	radius_px = rad
	telegraph_sec = tele_s
	active_sec = act_s
	damage_val = dmg
	attacker_realm = realm_i
	zone_color = col
	apply_slow_ratio = slow_r
	apply_slow_sec = slow_d
	pull_strength = pull_s

	elapsed = 0.0
	_visual_elapsed = 0.0
	_detonate_vis_time = tele_s
	exploded = false
	tick_accum = 0.0
	_core_color = zone_color.lerp(Color(1.0, 0.98, 0.90, 1.0), 0.72)
	_outer_color = zone_color.darkened(0.24)

	if _active_particles != null and is_instance_valid(_active_particles):
		_active_particles.queue_free()
		_active_particles = null

	_pool_bubbles.clear()
	if zone_mode == "pool":
		for i in range(10):
			_pool_bubbles.append({
				"ang": float(i) * (TAU / 10.0) + randf_range(-0.28, 0.28),
				"rad_n": randf_range(0.18, 0.80),
				"phase": randf(),
				"spd": randf_range(0.68, 1.25),
				"sz": randf_range(5.5, 11.5)
			})

	z_index = -1
	material = VfxAssets.get_additive_material()
	reset_physics_interpolation()
	queue_redraw()


func _process(delta: float) -> void:
	_visual_elapsed += delta
	queue_redraw()


func _physics_process(delta: float) -> void:
	elapsed += delta

	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var p: Node2D = players[0] as Node2D if not players.is_empty() else null

	if elapsed < telegraph_sec:
		return

	if not exploded:
		exploded = true
		_detonate_vis_time = _visual_elapsed
		EventBus.audio_sfx_requested.emit("skill_burst" if zone_mode == "pillar" else "skill_fire")
		if zone_mode == "pillar":
			z_index = 4
			EventBus.screen_shake_requested.emit(5.5, 0.16)
			_spawn_pillar_impact_vfx()
			if p != null and global_position.distance_to(p.global_position) <= radius_px:
				_hit_player(p, damage_val)
		elif zone_mode == "pool":
			_spawn_pool_particles()
		elif zone_mode == "vortex":
			_spawn_vortex_particles()

	if zone_mode == "pool" or zone_mode == "vortex":
		if _active_particles != null and is_instance_valid(_active_particles):
			var rem_sec: float = (telegraph_sec + active_sec) - elapsed
			if rem_sec <= 0.45 and _active_particles.emitting:
				_active_particles.emitting = false

		if p != null and pull_strength > 0.0:
			var dist_p: float = global_position.distance_to(p.global_position)
			if dist_p <= radius_px * 1.45 and dist_p > 18.0:
				var pull_d: Vector2 = (global_position - p.global_position).normalized()
				p.global_position += pull_d * pull_strength * delta
		tick_accum += delta
		if tick_accum >= 0.55:
			tick_accum = 0.0
			if p != null and global_position.distance_to(p.global_position) <= radius_px:
				_hit_player(p, damage_val * 0.45)

	if elapsed >= telegraph_sec + active_sec:
		queue_free()


func _spawn_pillar_impact_vfx() -> void:
	var parent_n: Node = get_parent()
	if parent_n == null:
		return
	VfxAssets.spawn_spark_burst(
		parent_n,
		global_position,
		_core_color,
		zone_color,
		22,
		110.0,
		295.0,
		0.42,
		Vector2(0.0, -1.0),
		145.0,
		0.30,
		0.72,
		true
	)
	var dust_col: Color = Color(zone_color.r, zone_color.g, zone_color.b, 0.36).lerp(Color(0.84, 0.85, 0.90, 0.38), 0.48)
	VfxAssets.spawn_dust_puff(parent_n, global_position, dust_col, 10, 165.0, 1.65)


func _spawn_pool_particles() -> void:
	var parent_n: Node = get_parent()
	if parent_n != null:
		VfxAssets.spawn_spark_burst(
			parent_n,
			global_position,
			_core_color,
			zone_color,
			10,
			45.0,
			115.0,
			0.35,
			Vector2(0.0, -1.0),
			120.0,
			0.22,
			0.48,
			false
		)

	var p := CPUParticles2D.new()
	p.local_coords = true
	p.amount = 18
	p.lifetime = 0.85
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = radius_px * 0.82
	p.direction = Vector2(0.0, -1.0)
	p.spread = 24.0
	p.gravity = Vector2(0.0, -28.0)
	p.damping_min = 12.0
	p.damping_max = 32.0
	p.initial_velocity_min = 24.0
	p.initial_velocity_max = 68.0
	p.scale_amount_min = 0.20
	p.scale_amount_max = 0.50
	p.z_index = 2
	VfxAssets.configure_glow_particles(p, _core_color, zone_color, false)
	add_child(p)
	p.emitting = true
	_active_particles = p


func _spawn_vortex_particles() -> void:
	var p := CPUParticles2D.new()
	p.local_coords = true
	p.amount = 22
	p.lifetime = 0.68
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE_SURFACE
	p.emission_sphere_radius = radius_px * 0.90
	p.direction = Vector2.RIGHT
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 6.0
	p.initial_velocity_max = 18.0
	p.radial_accel_min = -220.0
	p.radial_accel_max = -135.0
	p.tangential_accel_min = 185.0
	p.tangential_accel_max = 275.0
	p.orbit_velocity_min = 0.45
	p.orbit_velocity_max = 0.85
	p.scale_amount_min = 0.18
	p.scale_amount_max = 0.44
	p.z_index = 2
	VfxAssets.configure_glow_particles(p, _core_color, zone_color, true)
	add_child(p)
	p.emitting = true
	_active_particles = p


func _hit_player(p: Node2D, dmg_amt: float) -> void:
	if apply_slow_ratio > 0.0 and apply_slow_sec > 0.0:
		PlayerData.apply_player_slow(apply_slow_ratio, apply_slow_sec)
		EventBus.floating_text_requested.emit(p.global_position + Vector2(0, -82), "LÀM CHẬM!", zone_color)
	if p.has_method("take_enemy_damage"):
		var push_d: Vector2 = (p.global_position - global_position).normalized()
		if push_d == Vector2.ZERO:
			push_d = Vector2.RIGHT
		p.take_enemy_damage(dmg_amt, attacker_realm, push_d * (140.0 if zone_mode == "pillar" else 60.0))


func _ease_out_expo(t: float) -> float:
	return 1.0 if t >= 1.0 else 1.0 - pow(2.0, -10.0 * t)


func _ease_out_cubic(t: float) -> float:
	var inv: float = 1.0 - clampf(t, 0.0, 1.0)
	return 1.0 - inv * inv * inv


func _draw_soft_halo(center: Vector2, radius: float, col: Color) -> void:
	if col.a <= 0.01 or radius <= 1.0:
		return
	var halo_tex: Texture2D = VfxAssets.get_soft_halo_texture()
	draw_texture_rect(halo_tex, Rect2(center - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0)), false, col)


func _draw() -> void:
	if not exploded:
		_draw_telegraph()
	else:
		var act_elapsed: float = maxf(0.0, _visual_elapsed - _detonate_vis_time)
		var act_t: float = clampf(act_elapsed / maxf(0.05, active_sec), 0.0, 1.0)
		if zone_mode == "pillar":
			_draw_active_pillar(act_t)
		elif zone_mode == "pool":
			_draw_active_pool(act_elapsed, act_t)
		else:
			_draw_active_vortex(act_elapsed, act_t)


func _draw_telegraph() -> void:
	var safe_tele: float = maxf(0.05, telegraph_sec)
	var prog: float = clampf(_visual_elapsed / safe_tele, 0.0, 1.0)
	var rem_tele: float = maxf(0.0, telegraph_sec - _visual_elapsed)

	# Nhấp nháy cảnh báo khẩn cấp trong 0.20s cuối trước khi kích nổ!
	var urgent: float = clampf(1.0 - rem_tele / 0.20, 0.0, 1.0)
	var urgent_flash: float = (0.5 + 0.5 * sin(_visual_elapsed * 56.0)) * urgent
	var pulse: float = 0.86 + 0.14 * sin(_visual_elapsed * 14.0)

	# 1. Nền phủ phát sáng nhịp đập (Pulsing Radial Fill)
	var fill_col: Color = zone_color.lerp(_core_color, urgent_flash * 0.55)
	_draw_soft_halo(
		Vector2.ZERO,
		radius_px * (1.04 + 0.05 * pulse),
		Color(fill_col.r, fill_col.g, fill_col.b, (0.24 + 0.22 * prog + 0.26 * urgent_flash) * pulse)
	)
	draw_circle(
		Vector2.ZERO,
		radius_px,
		Color(zone_color.r, zone_color.g, zone_color.b, (0.10 + 0.14 * prog) * pulse + 0.18 * urgent_flash)
	)
	draw_circle(
		Vector2.ZERO,
		radius_px * prog,
		Color(fill_col.r, fill_col.g, fill_col.b, 0.10 + 0.14 * prog + 0.16 * urgent_flash)
	)

	# 2. Viền cảnh báo ngoài sắc nét (Crisp Outer Warning Border)
	var border_col: Color = zone_color.lerp(_core_color, urgent_flash * 0.65)
	draw_arc(Vector2.ZERO, radius_px, 0.0, TAU, 52, Color(zone_color.r, zone_color.g, zone_color.b, 0.34 + 0.25 * urgent_flash), 6.5)
	draw_arc(Vector2.ZERO, radius_px, 0.0, TAU, 52, Color(border_col.r, border_col.g, border_col.b, 0.88 + 0.12 * urgent_flash), 2.6 + urgent_flash * 1.4)

	# 3. Các vạch phù văn trận pháp xoay quanh chu vi (Rotating Arcane Rune Ticks)
	var tick_cnt: int = 16 if radius_px >= 92.0 else 12
	var spin_a: float = _visual_elapsed * (1.35 + prog * 1.65)
	var tick_col: Color = zone_color.lerp(_core_color, 0.35 + urgent_flash * 0.60)
	for i in range(tick_cnt):
		var ang: float = spin_a + float(i) * (TAU / float(tick_cnt))
		var d := Vector2(cos(ang), sin(ang))
		var is_major: bool = (i % 2 == 0)
		var r_in: float = radius_px - (11.5 if is_major else 6.5)
		var r_out: float = radius_px + (4.5 if is_major else 2.5)
		draw_line(d * r_in, d * r_out, Color(tick_col.r, tick_col.g, tick_col.b, 0.85), 2.2 if is_major else 1.4)
		if is_major:
			var perp := Vector2(-d.y, d.x)
			var g_c: Vector2 = d * (radius_px - 15.0)
			var diamond := PackedVector2Array([
				g_c + d * 3.0,
				g_c + perp * 2.2,
				g_c - d * 3.0,
				g_c - perp * 2.2
			])
			draw_colored_polygon(diamond, Color(_core_color.r, _core_color.g, _core_color.b, 0.72 + 0.25 * urgent_flash))

	# 4 cung trận pháp xoay ngược chiều sát vành trong
	var inner_spin: float = -_visual_elapsed * 2.2
	for q in range(4):
		var qa: float = inner_spin + float(q) * (TAU * 0.25)
		draw_arc(Vector2.ZERO, radius_px * 0.86, qa, qa + 0.58, 12, Color(_core_color.r, _core_color.g, _core_color.b, 0.58 + 0.32 * urgent_flash), 1.8)

	# 4. Vòng đếm ngược thu hẹp dần vào tâm (Inward-Shrinking Countdown Ring)
	var shrink_r: float = lerpf(radius_px, radius_px * 0.12, prog)
	draw_arc(Vector2.ZERO, shrink_r, 0.0, TAU, 44, Color(zone_color.r, zone_color.g, zone_color.b, 0.45 + 0.35 * prog), 5.0)
	draw_arc(Vector2.ZERO, shrink_r, 0.0, TAU, 44, Color(_core_color.r, _core_color.g, _core_color.b, 0.90 + 0.10 * urgent_flash), 2.2 + urgent_flash * 1.4)

	# Tâm tụ khí + chớp khẩn cấp 0.2s cuối
	var center_r: float = 4.5 + 8.0 * prog + 6.0 * urgent_flash
	draw_circle(Vector2.ZERO, center_r, Color(_core_color.r, _core_color.g, _core_color.b, 0.45 + 0.50 * urgent_flash))
	if urgent > 0.01:
		draw_arc(Vector2.ZERO, radius_px * (1.0 + 0.08 * urgent_flash), 0.0, TAU, 44, Color(1.0, 0.98, 0.88, 0.78 * urgent_flash), 3.2)


func _draw_active_pillar(t: float) -> void:
	# CỘT NĂNG LƯỢNG GIÁNG TỪ TRỜI XUỐNG MẶT ĐẤT (ease_out_expo + đa tầng + sóng xung kích kép!)
	var ease_e: float = _ease_out_expo(t)
	var fade_alpha: float = clampf((1.0 - t) * (1.15 - 0.52 * ease_e), 0.0, 1.0)
	if fade_alpha <= 0.01:
		return
	var flash_a: float = clampf(1.0 - _ease_out_expo(minf(1.0, t * 2.4)), 0.0, 1.0)

	# 1. Quầng sáng bùng nổ tại mặt đất
	_draw_soft_halo(
		Vector2.ZERO,
		radius_px * (1.18 + 0.45 * ease_e),
		Color(zone_color.r, zone_color.g, zone_color.b, 0.65 * fade_alpha)
	)
	if flash_a > 0.01:
		draw_circle(Vector2.ZERO, radius_px * (0.72 + 0.38 * ease_e), Color(1.0, 0.99, 0.92, 0.62 * flash_a))

	# 2. Cột tia năng lượng thẳng đứng từ trời xuống tâm nổ (3 lớp: Outer Bloom -> Mid Energy -> White-Hot Core)
	var y_bottom: float = 12.0
	var y_top: float = y_bottom - PILLAR_BEAM_HEIGHT
	var outer_half_w: float = radius_px * 0.76 * lerpf(1.16, 0.24, ease_e)
	var mid_half_w: float = radius_px * 0.45 * lerpf(1.14, 0.16, ease_e)
	var core_half_w: float = radius_px * 0.20 * lerpf(1.12, 0.07, ease_e)

	_draw_vertical_beam_layer(outer_half_w, y_top, y_bottom, Color(zone_color.r, zone_color.g, zone_color.b, 0.42 * fade_alpha))
	var mid_c: Color = zone_color.lerp(_core_color, 0.38)
	_draw_vertical_beam_layer(mid_half_w, y_top, y_bottom, Color(mid_c.r, mid_c.g, mid_c.b, 0.78 * fade_alpha))
	_draw_vertical_beam_layer(core_half_w, y_top, y_bottom, Color(1.0, 0.99, 0.94, 0.96 * fade_alpha))

	# Đáy cột bo sáng mềm ôm lấy tâm nổ
	draw_circle(Vector2(0.0, 2.0), outer_half_w * 0.78, Color(zone_color.r, zone_color.g, zone_color.b, 0.34 * fade_alpha))
	draw_circle(Vector2(0.0, 2.0), core_half_w * 1.25, Color(1.0, 0.99, 0.94, 0.88 * fade_alpha))

	# 3 tia năng lượng xoắn nhẹ bốc dọc theo thân cột
	for s_idx in range(3):
		var pts := PackedVector2Array()
		var phase: float = float(s_idx) * (TAU / 3.0) + _visual_elapsed * 14.0
		for seg in range(11):
			var u: float = float(seg) / 10.0
			var yy: float = lerpf(y_bottom, y_bottom - 340.0, u)
			var xx: float = sin(u * 9.0 + phase) * (outer_half_w * (0.72 - 0.25 * u))
			pts.append(Vector2(xx, yy))
		draw_polyline(pts, Color(_core_color.r, _core_color.g, _core_color.b, 0.70 * fade_alpha), 2.6 * fade_alpha)

	# Vòng cổ năng lượng dạng elip bốc dọc thân trụ (tạo chiều sâu không gian 3D)
	var collar_y: float = -ease_e * 115.0
	draw_set_transform(Vector2(0.0, collar_y), 0.0, Vector2(1.0, 0.38))
	draw_arc(Vector2.ZERO, radius_px * (0.55 + 0.55 * ease_e), 0.0, TAU, 40, Color(_core_color.r, _core_color.g, _core_color.b, 0.86 * fade_alpha), 5.0 * fade_alpha)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 3. Sóng xung kích kép nở rộng (Twin Expanding Shockwave Rings)
	var r1: float = radius_px * (0.28 + 1.08 * ease_e)
	var f1: float = clampf(1.0 - t, 0.0, 1.0)
	draw_arc(Vector2.ZERO, r1, 0.0, TAU, 52, Color(zone_color.r, zone_color.g, zone_color.b, 0.92 * f1), 9.0 * f1)
	draw_arc(Vector2.ZERO, r1 * 0.95, 0.0, TAU, 48, Color(1.0, 0.98, 0.90, 0.90 * f1), 3.2 * f1)

	if t > 0.08:
		var t2: float = clampf((t - 0.08) / 0.92, 0.0, 1.0)
		var r2: float = radius_px * (0.18 + 0.95 * _ease_out_cubic(t2))
		var f2: float = (1.0 - t2) * (1.0 - t2)
		draw_arc(Vector2.ZERO, r2, 0.0, TAU, 44, Color(_core_color.r, _core_color.g, _core_color.b, 0.85 * f2), 5.5 * f2)


func _draw_vertical_beam_layer(half_w: float, y_top: float, y_bottom: float, col: Color) -> void:
	if half_w <= 0.4 or col.a <= 0.01:
		return
	var top_col := Color(col.r, col.g, col.b, col.a * 0.42)
	var poly := PackedVector2Array([
		Vector2(-half_w * 0.82, y_top),
		Vector2(half_w * 0.82, y_top),
		Vector2(half_w, y_bottom),
		Vector2(-half_w, y_bottom)
	])
	var cols := PackedColorArray([top_col, top_col, col, col])
	draw_polygon(poly, cols)


func _draw_active_pool(act_elapsed: float, act_t: float) -> void:
	# VŨNG ĐỘC / HỒ DUNG NHAM: Xoáy đa tầng + viền sôi gợn sóng + bong bóng nổi nổ gợn sóng!
	var fade_in: float = clampf(act_elapsed / 0.16, 0.0, 1.0)
	var rem_sec: float = maxf(0.0, active_sec - act_elapsed)
	var fade_out: float = clampf(rem_sec / 0.45, 0.0, 1.0)
	var env: float = fade_in * fade_out
	if env <= 0.01:
		return

	var boil_pulse: float = 0.92 + 0.08 * sin(_visual_elapsed * 6.5)

	# 1. Nền phát sáng mềm trên mặt đất
	_draw_soft_halo(
		Vector2.ZERO,
		radius_px * (1.16 * boil_pulse),
		Color(zone_color.r, zone_color.g, zone_color.b, 0.44 * env)
	)
	draw_circle(Vector2.ZERO, radius_px * 0.96, Color(_outer_color.r, _outer_color.g, _outer_color.b, 0.24 * env))

	# 2. Viền chất lỏng uốn lượn sôi sục quanh chu vi
	var rim_segs: int = 44
	var rim_pts := PackedVector2Array()
	for s in range(rim_segs + 1):
		var ang: float = float(s) * TAU / float(rim_segs)
		var wave: float = sin(ang * 6.0 + _visual_elapsed * 3.6) * 3.4 + cos(ang * 4.0 - _visual_elapsed * 2.4) * 2.0
		rim_pts.append(Vector2(cos(ang), sin(ang)) * (radius_px + wave))
	draw_polyline(rim_pts, Color(zone_color.r, zone_color.g, zone_color.b, 0.86 * env), 4.2)
	draw_polyline(rim_pts, Color(_core_color.r, _core_color.g, _core_color.b, 0.55 * env), 1.6)

	# 3. Các vòng xoáy dung nham / độc khí đa tầng quay ngược chiều
	var a1: float = _visual_elapsed * 1.8
	var a2: float = -_visual_elapsed * 2.5
	var a3: float = _visual_elapsed * 3.3
	draw_arc(Vector2.ZERO, radius_px * 0.84, a1, a1 + TAU * 0.76, 36, Color(zone_color.r, zone_color.g, zone_color.b, 0.72 * env), 3.4)
	draw_arc(Vector2.ZERO, radius_px * 0.58, a2, a2 + TAU * 0.72, 30, Color(_core_color.r, _core_color.g, _core_color.b, 0.62 * env), 2.6)
	draw_arc(Vector2.ZERO, radius_px * 0.30, a3, a3 + TAU * 0.68, 22, Color(zone_color.r, zone_color.g, zone_color.b, 0.74 * env), 2.2)

	# 4 luồng xoáy dung nham chảy cong bên trong hồ
	for v_idx in range(4):
		var va: float = _visual_elapsed * 1.15 + float(v_idx) * (TAU * 0.25)
		var v_pts := PackedVector2Array()
		for seg in range(8):
			var u: float = float(seg) / 7.0
			var rr: float = lerpf(radius_px * 0.14, radius_px * 0.86, u)
			var ang: float = va + u * 1.35 + sin(u * PI + _visual_elapsed * 3.0) * 0.18
			v_pts.append(Vector2(cos(ang), sin(ang)) * rr)
		draw_polyline(v_pts, Color(_core_color.r, _core_color.g, _core_color.b, 0.42 * env), 2.2)

	# 4. Bong bóng độc / dung nham nổi lên rồi vỡ thành vòng gợn sóng (Rising Bubbles & Ripples)
	for b in _pool_bubbles:
		var b_ang: float = float(b["ang"]) + _visual_elapsed * 0.22
		var b_rad: float = radius_px * float(b["rad_n"])
		var b_spd: float = float(b["spd"])
		var b_sz: float = float(b["sz"])
		var cycle: float = fmod(_visual_elapsed * b_spd + float(b["phase"]), 1.0)
		var base_pos := Vector2(cos(b_ang), sin(b_ang)) * b_rad

		if cycle < 0.64:
			var rise_t: float = cycle / 0.64
			var b_pos: Vector2 = base_pos + Vector2(sin(rise_t * 5.0 + b_ang) * 2.5, -rise_t * 14.0)
			var cur_r: float = b_sz * (0.35 + 0.65 * sin(rise_t * PI * 0.82))
			var ba: float = sin(rise_t * PI) * 0.85 * env
			draw_circle(b_pos, cur_r, Color(zone_color.r, zone_color.g, zone_color.b, 0.45 * ba))
			draw_arc(b_pos, cur_r, 0.0, TAU, 16, Color(_core_color.r, _core_color.g, _core_color.b, 0.88 * ba), 1.6)
			draw_circle(b_pos + Vector2(-cur_r * 0.30, -cur_r * 0.30), maxf(1.2, cur_r * 0.25), Color(1.0, 1.0, 0.95, 0.90 * ba))
		else:
			var pop_t: float = (cycle - 0.64) / 0.36
			var rip_r: float = b_sz * (0.85 + 1.85 * _ease_out_cubic(pop_t))
			var ra: float = (1.0 - pop_t) * env
			if ra > 0.02:
				var rip_pos: Vector2 = base_pos + Vector2(0.0, -6.0)
				draw_arc(rip_pos, rip_r, 0.0, TAU, 18, Color(_core_color.r, _core_color.g, _core_color.b, 0.78 * ra), maxf(0.6, 1.8 * ra))

	# Nhấn lóe sáng nhẹ lúc mới bùng phát
	if act_t < 0.12:
		var pop_f: float = 1.0 - (act_t / 0.12)
		draw_arc(Vector2.ZERO, radius_px * (0.75 + 0.35 * (1.0 - pop_f)), 0.0, TAU, 44, Color(_core_color.r, _core_color.g, _core_color.b, 0.80 * pop_f), 5.0 * pop_f)


func _draw_active_vortex(act_elapsed: float, act_t: float) -> void:
	# LỐC XOÁY / KHÔNG GIAN VẶN VẸO: 6 nhánh xoáy hút tâm tốc độ cao + vòng xoay ngược chiều + mắt bão!
	var fade_in: float = clampf(act_elapsed / 0.15, 0.0, 1.0)
	var rem_sec: float = maxf(0.0, active_sec - act_elapsed)
	var fade_out: float = clampf(rem_sec / 0.40, 0.0, 1.0)
	var env: float = fade_in * fade_out
	if env <= 0.01:
		return

	var spin_fast: float = _visual_elapsed * 7.2
	var spin_rev: float = -_visual_elapsed * 5.8

	# 1. Quầng hút năng lượng mềm & viền lực hút ngoài (khi có pull_strength)
	_draw_soft_halo(
		Vector2.ZERO,
		radius_px * (1.12 + 0.08 * sin(_visual_elapsed * 12.0)),
		Color(zone_color.r, zone_color.g, zone_color.b, 0.45 * env)
	)
	if pull_strength > 0.0:
		var pull_r: float = radius_px * 1.32
		for d_i in range(6):
			var da: float = spin_rev * 0.45 + float(d_i) * (TAU / 6.0)
			draw_arc(Vector2.ZERO, pull_r, da, da + 0.48, 10, Color(zone_color.r, zone_color.g, zone_color.b, 0.32 * env), 2.0)

	# 2. 6 nhánh gió / không gian xoắn ốc tốc độ cao lao từ vành ngoài hút thẳng vào tâm!
	for arm in range(6):
		var base_a: float = spin_fast + float(arm) * (TAU / 6.0)
		var outer_pts := PackedVector2Array()
		var core_pts := PackedVector2Array()
		var segs: int = 11
		for s in range(segs + 1):
			var u: float = float(s) / float(segs)
			var rr: float = lerpf(radius_px * 1.12, radius_px * 0.10, u)
			var twist: float = base_a + u * 2.25 + sin(u * PI + _visual_elapsed * 9.0) * 0.10
			var pt := Vector2(cos(twist), sin(twist)) * rr
			outer_pts.append(pt)
			if s >= 2:
				core_pts.append(pt)

		draw_polyline(outer_pts, Color(zone_color.r, zone_color.g, zone_color.b, 0.80 * env), 4.8)
		draw_polyline(core_pts, Color(_core_color.r, _core_color.g, _core_color.b, 0.90 * env), 1.9)

		# Hạt sáng trượt nhanh dọc nhánh xoáy vào tâm
		var u_bead: float = fmod(_visual_elapsed * 1.95 + float(arm) * (1.0 / 6.0), 1.0)
		var b_r: float = lerpf(radius_px * 1.08, radius_px * 0.12, u_bead)
		var b_a: float = base_a + u_bead * 2.25
		var b_pos := Vector2(cos(b_a), sin(b_a)) * b_r
		var b_alpha: float = sin(u_bead * PI) * env
		draw_circle(b_pos, 3.8 * (1.0 - 0.35 * u_bead), Color(_core_color.r, _core_color.g, _core_color.b, 0.92 * b_alpha))

	# 3. Các vòng lốc xoay ngược chiều nhau (Counter-Rotating Vortex Rings)
	for k in range(2):
		var oa: float = spin_fast * 0.62 + float(k) * PI
		draw_arc(Vector2.ZERO, radius_px, oa, oa + 2.35, 28, Color(zone_color.r, zone_color.g, zone_color.b, 0.88 * env), 4.0)

	for m in range(3):
		var ma: float = spin_rev * 1.15 + float(m) * (TAU / 3.0)
		draw_arc(Vector2.ZERO, radius_px * 0.66, ma, ma + 1.48, 20, Color(_core_color.r, _core_color.g, _core_color.b, 0.78 * env), 2.8)

	draw_arc(Vector2.ZERO, radius_px * 0.36, spin_fast * 1.55, spin_fast * 1.55 + TAU * 0.78, 24, Color(_core_color.r, _core_color.g, _core_color.b, 0.90 * env), 2.6)

	# 4. Mắt xoáy tâm bão rực sáng
	var eye_pulse: float = 0.88 + 0.14 * sin(_visual_elapsed * 22.0)
	_draw_soft_halo(Vector2.ZERO, radius_px * 0.38 * eye_pulse, Color(_core_color.r, _core_color.g, _core_color.b, 0.62 * env))
	draw_circle(Vector2.ZERO, radius_px * 0.15 * eye_pulse, Color(zone_color.r, zone_color.g, zone_color.b, 0.78 * env))
	draw_circle(Vector2.ZERO, radius_px * 0.08 * eye_pulse, Color(1.0, 0.99, 0.95, 0.96 * env))

	# Nhịp xung kích nhỏ khi lốc vừa hình thành
	if act_t < 0.14:
		var burst_f: float = 1.0 - (act_t / 0.14)
		draw_arc(Vector2.ZERO, radius_px * (0.40 + 0.72 * (1.0 - burst_f)), 0.0, TAU, 44, Color(_core_color.r, _core_color.g, _core_color.b, 0.85 * burst_f), 5.2 * burst_f)
