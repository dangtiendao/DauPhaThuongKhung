extends Area2D
## Đạn & Kiếm Khí Boss chuẩn 60–144 FPS (Additive Blend + Soft Particle Trail + Glowing Ribbon):
## Hỗ trợ đa dạng hình thái cho từng Boss: Nguyệt Nha ("wave"), Cầu Năng Lượng ("orb"),
## Thương Khí ("spear"), Tảng Đá Dung Nham ("boulder"), rượt nhẹ & làm chậm!

const MAX_TRAIL_PTS: int = 12
const TRAIL_SAMPLE_INTERVAL: float = 0.015

var velocity_vec: Vector2 = Vector2.RIGHT * 340.0
var speed_mag: float = 340.0
var damage_val: float = 18.0
var realm_idx: int = 2
var wave_color: Color = Color("#FF4D6D")
var lifetime: float = 2.2
var hit_done: bool = false
var proj_style: String = "wave" # "wave", "orb", "spear", "boulder"
var hit_radius: float = 32.0
var slow_ratio: float = 0.0
var slow_sec: float = 0.0
var homing_turn_rate: float = 0.0

var _elapsed: float = 0.0
var _spin_angle: float = 0.0
var _spin_speed: float = 4.5
var _core_color: Color = Color("#FFF6E0")
var _outer_color: Color = Color("#A4133C")
var _trail_pts: Array[Vector2] = []
var _trail_sample_accum: float = 0.0
var _trail_particles: CPUParticles2D = null
var _rock_poly: PackedVector2Array = PackedVector2Array()
var _rock_inner_poly: PackedVector2Array = PackedVector2Array()
var _rock_cracks: Array[PackedVector2Array] = []


func configure_projectile(
	start_pos: Vector2,
	dir: Vector2,
	speed: float,
	dmg: float,
	attacker_realm: int,
	col: Color,
	style: String = "wave",
	slow_r: float = 0.0,
	slow_dur: float = 0.0,
	homing_rate: float = 0.0
) -> void:
	global_position = start_pos
	speed_mag = speed
	var n_dir: Vector2 = dir.normalized() if dir.length() > 0.001 else Vector2.RIGHT
	velocity_vec = n_dir * speed_mag
	rotation = velocity_vec.angle()
	damage_val = dmg
	realm_idx = attacker_realm
	wave_color = col
	proj_style = style
	slow_ratio = slow_r
	slow_sec = slow_dur
	homing_turn_rate = homing_rate
	hit_radius = 28.0 if style == "spear" else (34.0 if style == "boulder" else 32.0)

	_elapsed = 0.0
	_spin_angle = randf() * TAU
	_spin_speed = 7.8 if style == "boulder" else 4.6
	_core_color = wave_color.lerp(Color(1.0, 0.98, 0.92, 1.0), 0.72)
	_outer_color = wave_color.darkened(0.28)
	_trail_pts.clear()
	_trail_pts.append(start_pos)
	_trail_sample_accum = 0.0

	z_index = 4
	# Lõi tảng đá giữ nét đặc sắc nét (normal blend) với khe nứt phát sáng; các đạn khí/năng lượng dùng Additive Blend
	material = null if style == "boulder" else VfxAssets.get_additive_material()

	if style == "boulder":
		_build_boulder_geometry()
	_setup_trail_particles()
	reset_physics_interpolation()
	queue_redraw()


func _build_boulder_geometry() -> void:
	_rock_poly.clear()
	_rock_inner_poly.clear()
	_rock_cracks.clear()

	var verts: int = 9
	for i in range(verts):
		var ang: float = float(i) * (TAU / float(verts)) + randf_range(-0.14, 0.14)
		var rad: float = randf_range(12.8, 16.8)
		_rock_poly.append(Vector2(cos(ang), sin(ang)) * rad)
		_rock_inner_poly.append(Vector2(cos(ang + 0.08), sin(ang + 0.08)) * (rad * 0.62) + Vector2(-1.5, -1.5))

	for c in range(4):
		var base_a: float = float(c) * (TAU / 4.0) + randf_range(-0.35, 0.35)
		var d := Vector2(cos(base_a), sin(base_a))
		var perp := Vector2(-d.y, d.x)
		var len_c: float = randf_range(11.5, 14.5)
		var p1: Vector2 = d * (len_c * 0.45) + perp * randf_range(-3.2, 3.2)
		var p2: Vector2 = d * len_c + perp * randf_range(-2.0, 2.0)
		_rock_cracks.append(PackedVector2Array([Vector2.ZERO, p1, p2]))


func _setup_trail_particles() -> void:
	if _trail_particles != null and is_instance_valid(_trail_particles):
		_trail_particles.queue_free()
		_trail_particles = null

	var p := CPUParticles2D.new()
	p.local_coords = false
	p.amount = 12
	p.z_index = -1
	p.direction = Vector2(-1.0, 0.0)
	p.damping_min = 45.0
	p.damping_max = 95.0

	if proj_style == "orb":
		p.lifetime = 0.30
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		p.emission_sphere_radius = 9.0
		p.spread = 115.0
		p.gravity = Vector2(0.0, -14.0)
		p.initial_velocity_min = 16.0
		p.initial_velocity_max = 52.0
		p.scale_amount_min = 0.18
		p.scale_amount_max = 0.42
	elif proj_style == "spear":
		p.lifetime = 0.22
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		p.emission_sphere_radius = 4.0
		p.spread = 18.0
		p.gravity = Vector2.ZERO
		p.initial_velocity_min = 32.0
		p.initial_velocity_max = 88.0
		p.scale_amount_min = 0.16
		p.scale_amount_max = 0.36
	elif proj_style == "boulder":
		p.lifetime = 0.32
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		p.emission_sphere_radius = 12.0
		p.spread = 65.0
		p.gravity = Vector2(0.0, 52.0)
		p.initial_velocity_min = 18.0
		p.initial_velocity_max = 58.0
		p.scale_amount_min = 0.18
		p.scale_amount_max = 0.40
	else:
		p.lifetime = 0.26
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		p.emission_rect_extents = Vector2(4.0, 14.0)
		p.spread = 32.0
		p.gravity = Vector2.ZERO
		p.initial_velocity_min = 24.0
		p.initial_velocity_max = 74.0
		p.scale_amount_min = 0.18
		p.scale_amount_max = 0.38

	var use_streak: bool = (proj_style == "spear" or proj_style == "wave")
	VfxAssets.configure_glow_particles(p, _core_color, wave_color, use_streak)
	add_child(p)
	p.emitting = true
	_trail_particles = p


func _process(delta: float) -> void:
	_elapsed += delta
	_spin_angle += _spin_speed * delta
	_trail_sample_accum += delta

	if _trail_sample_accum >= TRAIL_SAMPLE_INTERVAL:
		_trail_sample_accum = 0.0
		if _trail_pts.is_empty() or _trail_pts[_trail_pts.size() - 1].distance_squared_to(global_position) >= 9.0:
			_trail_pts.append(global_position)
			while _trail_pts.size() > MAX_TRAIL_PTS:
				_trail_pts.pop_front()

	queue_redraw()


func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var p: Node2D = players[0] as Node2D if not players.is_empty() else null

	if homing_turn_rate > 0.0 and p != null:
		var want_dir: Vector2 = ((p.global_position + Vector2(0, -16)) - global_position).normalized()
		var cur_dir: Vector2 = velocity_vec.normalized()
		var new_dir: Vector2 = cur_dir.lerp(want_dir, clampf(homing_turn_rate * delta, 0.0, 1.0)).normalized()
		velocity_vec = new_dir * speed_mag
		rotation = velocity_vec.angle()

	global_position += velocity_vec * delta

	if hit_done or p == null:
		return
	if global_position.distance_to(p.global_position + Vector2(0, -16)) <= hit_radius:
		hit_done = true
		var parent_n: Node = get_parent()
		if parent_n != null:
			var impact_dir: Vector2 = -velocity_vec.normalized() if velocity_vec.length() > 0.01 else Vector2.LEFT
			VfxAssets.spawn_spark_burst(
				parent_n,
				global_position,
				_core_color,
				wave_color,
				16 if proj_style == "boulder" else 14,
				95.0,
				240.0,
				0.30,
				impact_dir,
				145.0,
				0.26,
				0.58,
				proj_style != "boulder"
			)
			if proj_style == "boulder":
				VfxAssets.spawn_dust_puff(parent_n, global_position, Color(0.58, 0.56, 0.54, 0.48), 7, 150.0, 1.15)

		if slow_ratio > 0.0 and slow_sec > 0.0:
			PlayerData.apply_player_slow(slow_ratio, slow_sec)
			EventBus.floating_text_requested.emit(p.global_position + Vector2(0, -84), "BỊ HÀN BĂNG LÀM CHẬM!", Color("#70D6FF"))
		if p.has_method("take_enemy_damage"):
			p.take_enemy_damage(damage_val, realm_idx, velocity_vec.normalized() * 230.0)
		queue_free()


func _get_local_trail_points() -> PackedVector2Array:
	var local_pts := PackedVector2Array()
	for gp in _trail_pts:
		local_pts.append(to_local(gp))
	if local_pts.is_empty() or local_pts[local_pts.size() - 1].length_squared() > 1.0:
		local_pts.append(Vector2.ZERO)
	return local_pts


func _draw_trail_ribbon(local_pts: PackedVector2Array, width_outer: float, width_inner: float, col_outer: Color, col_inner: Color) -> void:
	var count: int = local_pts.size()
	if count < 2:
		return

	var normals: Array[Vector2] = []
	normals.resize(count)
	for i in range(count):
		var tangent: Vector2
		if i == 0:
			tangent = local_pts[1] - local_pts[0]
		elif i == count - 1:
			tangent = local_pts[i] - local_pts[i - 1]
		else:
			tangent = local_pts[i + 1] - local_pts[i - 1]
		if tangent.length_squared() < 0.0001:
			tangent = Vector2.RIGHT
		else:
			tangent = tangent.normalized()
		normals[i] = Vector2(-tangent.y, tangent.x)

	var denom: float = float(count - 1)
	for layer in range(2):
		var base_w: float = width_outer if layer == 0 else width_inner
		var base_c: Color = col_outer if layer == 0 else col_inner
		if base_w <= 0.2 or base_c.a <= 0.01:
			continue
		for i in range(count - 1):
			var p0: Vector2 = local_pts[i]
			var p1: Vector2 = local_pts[i + 1]
			if p0.distance_squared_to(p1) < 0.25:
				continue
			var u0: float = float(i) / denom
			var u1: float = float(i + 1) / denom
			var w0: float = maxf(0.45, base_w * 0.5 * pow(u0, 1.35))
			var w1: float = maxf(0.45, base_w * 0.5 * pow(u1, 1.35))
			var a0: float = base_c.a * (u0 * u0)
			var a1: float = base_c.a * (u1 * u1)
			var c0 := Color(base_c.r, base_c.g, base_c.b, a0)
			var c1 := Color(base_c.r, base_c.g, base_c.b, a1)
			var quad := PackedVector2Array([
				p0 + normals[i] * w0,
				p1 + normals[i + 1] * w1,
				p1 - normals[i + 1] * w1,
				p0 - normals[i] * w0
			])
			var cols := PackedColorArray([c0, c1, c1, c0])
			draw_polygon(quad, cols)


func _draw_tapered_arc_ribbon(center: Vector2, r_mid: float, thickness: float, a_start: float, a_end: float, col: Color, segments: int = 18) -> void:
	if col.a <= 0.01 or thickness <= 0.4 or absf(a_end - a_start) < 0.02:
		return
	var outer_pts := PackedVector2Array()
	var inner_pts := PackedVector2Array()
	for i in range(segments + 1):
		var u: float = float(i) / float(segments)
		var ang: float = lerpf(a_start, a_end, u)
		var prof: float = sin(u * PI)
		var half_w: float = maxf(0.35, thickness * 0.5 * prof)
		var dir := Vector2(cos(ang), sin(ang))
		outer_pts.append(center + dir * (r_mid + half_w))
		inner_pts.append(center + dir * maxf(2.0, r_mid - half_w))
	var poly := PackedVector2Array()
	for pt in outer_pts:
		poly.append(pt)
	for j in range(inner_pts.size() - 1, -1, -1):
		poly.append(inner_pts[j])
	draw_colored_polygon(poly, col)


func _draw_soft_halo(center: Vector2, radius: float, col: Color) -> void:
	if col.a <= 0.01 or radius <= 1.0:
		return
	var halo_tex: Texture2D = VfxAssets.get_soft_halo_texture()
	draw_texture_rect(halo_tex, Rect2(center - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0)), false, col)


func _draw() -> void:
	var life_fade: float = clampf(lifetime / 0.18, 0.0, 1.0)
	if life_fade <= 0.01:
		return
	var pop_in: float = clampf(_elapsed / 0.055, 0.45, 1.0)
	var local_trail: PackedVector2Array = _get_local_trail_points()

	if proj_style == "orb":
		_draw_orb(local_trail, life_fade, pop_in)
	elif proj_style == "spear":
		_draw_spear(local_trail, life_fade, pop_in)
	elif proj_style == "boulder":
		_draw_boulder(local_trail, life_fade, pop_in)
	else:
		_draw_wave(local_trail, life_fade, pop_in)


func _draw_wave(local_trail: PackedVector2Array, fade: float, pop_in: float) -> void:
	# Dải đuôi năng lượng mềm phía sau
	_draw_trail_ribbon(
		local_trail,
		18.0 * pop_in,
		6.5 * pop_in,
		Color(wave_color.r, wave_color.g, wave_color.b, 0.48 * fade),
		Color(_core_color.r, _core_color.g, _core_color.b, 0.72 * fade)
	)

	# Quầng sáng mềm quanh lưỡi liềm
	_draw_soft_halo(Vector2(4.0, 0.0), 30.0 * pop_in, Color(wave_color.r, wave_color.g, wave_color.b, 0.42 * fade))

	# Song vệt xé gió uốn lượn từ 2 đầu mũi trăng khuyết
	for side in [-1.0, 1.0]:
		var wake_pts := PackedVector2Array()
		var tip_y: float = side * 18.5 * pop_in
		for s in range(7):
			var u: float = float(s) / 6.0
			var wx: float = lerpf(4.0, -34.0, u)
			var wag: float = sin(_elapsed * 26.0 + u * 5.2 + side * 1.4) * (3.2 * u)
			var wy: float = tip_y * (1.0 - 0.14 * u) + wag
			wake_pts.append(Vector2(wx, wy))
		draw_polyline(wake_pts, Color(wave_color.r, wave_color.g, wave_color.b, 0.62 * fade), 4.2 * fade)
		draw_polyline(wake_pts, Color(_core_color.r, _core_color.g, _core_color.b, 0.85 * fade), 1.6 * fade)

	# Nguyệt Nha 3 tầng vuốt nhọn sắc bén (Outer Bloom -> Main Blade -> Hot Core)
	var arc_center := Vector2(-7.0, 0.0)
	var r: float = 21.5 * pop_in
	_draw_tapered_arc_ribbon(arc_center, r, 15.5, -1.20, 1.20, Color(_outer_color.r, _outer_color.g, _outer_color.b, 0.46 * fade), 20)
	_draw_tapered_arc_ribbon(arc_center + Vector2(1.0, 0.0), r, 9.2, -1.12, 1.12, Color(wave_color.r, wave_color.g, wave_color.b, 0.90 * fade), 20)
	_draw_tapered_arc_ribbon(arc_center + Vector2(2.6, 0.0), r * 0.98, 3.8, -0.92, 0.92, Color(_core_color.r, _core_color.g, _core_color.b, 0.98 * fade), 16)

	# Lõi sáng trắng bùng lên ở mũi trăng khuyết
	var apex := Vector2(15.5 * pop_in, 0.0)
	var flare_s: float = (5.2 + sin(_elapsed * 30.0) * 1.1) * pop_in
	var star := PackedVector2Array([
		apex + Vector2(flare_s * 1.35, 0.0),
		apex + Vector2(0.0, flare_s * 0.55),
		apex + Vector2(-flare_s * 0.85, 0.0),
		apex + Vector2(0.0, -flare_s * 0.55)
	])
	draw_colored_polygon(star, Color(1.0, 0.99, 0.94, 0.96 * fade))


func _draw_orb(local_trail: PackedVector2Array, fade: float, pop_in: float) -> void:
	var pulse: float = 1.0 + sin(_elapsed * 18.0) * 0.09
	var r_scale: float = pop_in * pulse

	# Đuôi sao chổi mượt mà (uốn cong theo quỹ đạo rượt)
	_draw_trail_ribbon(
		local_trail,
		20.0 * pop_in,
		8.0 * pop_in,
		Color(wave_color.r, wave_color.g, wave_color.b, 0.52 * fade),
		Color(_core_color.r, _core_color.g, _core_color.b, 0.78 * fade)
	)

	# Quầng sáng mềm đa tầng
	_draw_soft_halo(Vector2.ZERO, 28.0 * r_scale, Color(wave_color.r, wave_color.g, wave_color.b, 0.52 * fade))
	draw_circle(Vector2.ZERO, 13.5 * r_scale, Color(wave_color.r, wave_color.g, wave_color.b, 0.45 * fade))
	draw_circle(Vector2.ZERO, 9.4 * r_scale, Color(wave_color.r, wave_color.g, wave_color.b, 0.92 * fade))

	# Vòng phù văn xoay bên trong & viền ngoài ngược chiều
	var rune_r: float = 14.2 * pop_in
	for seg in range(4):
		var a0: float = _spin_angle + float(seg) * (TAU * 0.25)
		draw_arc(Vector2.ZERO, rune_r, a0, a0 + 0.88, 10, Color(_core_color.r, _core_color.g, _core_color.b, 0.84 * fade), 2.0)
		var notch_a: float = a0 + 0.44
		var nd := Vector2(cos(notch_a), sin(notch_a))
		draw_line(nd * (rune_r - 2.6), nd * (rune_r + 2.8), Color(1.0, 0.99, 0.92, 0.90 * fade), 1.6)

	draw_arc(Vector2.ZERO, 10.6 * pop_in, -_spin_angle * 1.4, -_spin_angle * 1.4 + TAU * 0.72, 18, Color(_core_color.r, _core_color.g, _core_color.b, 0.62 * fade), 1.6)

	# Lõi năng lượng trắng nóng rực
	draw_circle(Vector2.ZERO, 6.0 * r_scale, Color(_core_color.r, _core_color.g, _core_color.b, 0.94 * fade))
	draw_circle(Vector2.ZERO, 3.2 * r_scale, Color(1.0, 1.0, 0.98, 0.98 * fade))

	# 3 đốm linh hồn / hỏa tinh quay quanh quỹ đạo
	for w in range(3):
		var wa: float = _elapsed * 6.4 + float(w) * (TAU / 3.0)
		var wr: float = 17.5 * pop_in
		var wpos := Vector2(cos(wa) * wr, sin(wa) * (wr * 0.76))
		var wprev := Vector2(cos(wa - 0.55) * wr, sin(wa - 0.55) * (wr * 0.76))
		draw_line(wprev, wpos, Color(wave_color.r, wave_color.g, wave_color.b, 0.65 * fade), 2.4)
		draw_circle(wpos, 3.0 * pop_in, Color(_core_color.r, _core_color.g, _core_color.b, 0.92 * fade))
		draw_circle(wpos, 1.4 * pop_in, Color(1.0, 1.0, 1.0, 0.95 * fade))


func _draw_spear(local_trail: PackedVector2Array, fade: float, pop_in: float) -> void:
	# Dải đuôi năng lượng sắc bén phía sau thương khí
	_draw_trail_ribbon(
		local_trail,
		12.0 * pop_in,
		4.6 * pop_in,
		Color(wave_color.r, wave_color.g, wave_color.b, 0.54 * fade),
		Color(_core_color.r, _core_color.g, _core_color.b, 0.85 * fade)
	)

	# Quầng sáng thuôn dài dọc thân thương
	var halo_tex: Texture2D = VfxAssets.get_soft_halo_texture()
	draw_texture_rect(halo_tex, Rect2(-26.0, -14.0, 56.0, 28.0), false, Color(wave_color.r, wave_color.g, wave_color.b, 0.46 * fade))

	# Đuôi tia sáng kéo dài xé gió
	var streak_len: float = (44.0 + sin(_elapsed * 32.0) * 5.0) * pop_in
	draw_line(Vector2(-streak_len, 0.0), Vector2(24.0 * pop_in, 0.0), Color(wave_color.r, wave_color.g, wave_color.b, 0.55 * fade), 5.6 * fade)
	draw_line(Vector2(-streak_len * 0.72, 0.0), Vector2(26.0 * pop_in, 0.0), Color(_core_color.r, _core_color.g, _core_color.b, 0.92 * fade), 2.2 * fade)

	# Cánh năng lượng vuốt ngược 2 bên thân thương (Outer Energy Fins)
	var fin_flare: float = 1.0 + sin(_elapsed * 24.0) * 0.12
	for side in [-1.0, 1.0]:
		var fin_pts := PackedVector2Array([
			Vector2(10.0, side * 2.5) * pop_in,
			Vector2(-9.0, side * 11.8 * fin_flare) * pop_in,
			Vector2(-19.5, side * 9.0 * fin_flare) * pop_in,
			Vector2(-7.5, side * 2.2) * pop_in
		])
		draw_colored_polygon(fin_pts, Color(wave_color.r, wave_color.g, wave_color.b, 0.56 * fade))
		draw_line(Vector2(8.0, side * 2.8) * pop_in, Vector2(-15.5, side * 10.2 * fin_flare) * pop_in, Color(_core_color.r, _core_color.g, _core_color.b, 0.84 * fade), 1.6)

	# Mũi thương khí sắc nhọn 2 lớp + trục lõi trắng rực
	var outer_lance := PackedVector2Array([
		Vector2(28.0, 0.0) * pop_in,
		Vector2(-6.0, -7.2) * pop_in,
		Vector2(-19.0, 0.0) * pop_in,
		Vector2(-6.0, 7.2) * pop_in
	])
	var inner_lance := PackedVector2Array([
		Vector2(26.0, 0.0) * pop_in,
		Vector2(-4.0, -3.6) * pop_in,
		Vector2(-13.0, 0.0) * pop_in,
		Vector2(-4.0, 3.6) * pop_in
	])
	draw_colored_polygon(outer_lance, Color(wave_color.r, wave_color.g, wave_color.b, 0.90 * fade))
	draw_colored_polygon(inner_lance, Color(_core_color.r, _core_color.g, _core_color.b, 0.96 * fade))
	draw_line(Vector2(-18.0, 0.0) * pop_in, Vector2(27.0, 0.0) * pop_in, Color(1.0, 1.0, 0.96, 0.98 * fade), 1.8)
	draw_circle(Vector2(24.0, 0.0) * pop_in, 3.0 * pop_in, Color(1.0, 1.0, 1.0, 0.95 * fade))


func _draw_boulder(local_trail: PackedVector2Array, fade: float, pop_in: float) -> void:
	# Vệt bụi đá & tia năng lượng phía sau
	_draw_trail_ribbon(
		local_trail,
		18.0 * pop_in,
		5.5 * pop_in,
		Color(0.45, 0.44, 0.46, 0.34 * fade),
		Color(wave_color.r, wave_color.g, wave_color.b, 0.55 * fade)
	)

	# Các cụm bụi mềm dọc theo quỹ đạo lăn
	var smoke_tex: Texture2D = VfxAssets.get_smoke_puff_texture()
	var t_cnt: int = local_trail.size()
	if t_cnt >= 3:
		for i in range(0, t_cnt - 1, 2):
			var u: float = float(i) / float(t_cnt - 1)
			var puff_r: float = lerpf(11.0, 6.0, u) * pop_in
			var pt: Vector2 = local_trail[i]
			draw_texture_rect(
				smoke_tex,
				Rect2(pt - Vector2(puff_r, puff_r), Vector2(puff_r * 2.0, puff_r * 2.0)),
				false,
				Color(0.56, 0.55, 0.58, 0.28 * u * fade)
			)

	# Hào quang năng lượng nhẹ sau lõi đá đặc
	_draw_soft_halo(Vector2.ZERO, 24.0 * pop_in, Color(wave_color.r, wave_color.g, wave_color.b, 0.40 * fade))

	# Tảng đá góc cạnh xoay mượt + vết nứt phát sáng rực
	if _rock_poly.size() < 3:
		_build_boulder_geometry()

	draw_set_transform(Vector2.ZERO, _spin_angle, Vector2(pop_in, pop_in))
	draw_colored_polygon(_rock_poly, Color(0.19, 0.20, 0.24, 0.98 * fade))
	if _rock_inner_poly.size() >= 3:
		draw_colored_polygon(_rock_inner_poly, Color(0.31, 0.33, 0.38, 0.92 * fade))

	# Khe nứt năng lượng phát sáng trên bề mặt đá
	var glow_pulse: float = 0.84 + 0.16 * sin(_elapsed * 16.0)
	for crack in _rock_cracks:
		draw_polyline(crack, Color(wave_color.r, wave_color.g, wave_color.b, 0.92 * glow_pulse * fade), 3.4)
		draw_polyline(crack, Color(_core_color.r, _core_color.g, _core_color.b, 0.96 * glow_pulse * fade), 1.3)
	draw_circle(Vector2.ZERO, 3.8, Color(wave_color.r, wave_color.g, wave_color.b, 0.88 * glow_pulse * fade))
	draw_circle(Vector2.ZERO, 1.9, Color(_core_color.r, _core_color.g, _core_color.b, 0.98 * fade))

	# Viền đá phát quang sắc nét
	var rim := PackedVector2Array(_rock_poly)
	rim.append(_rock_poly[0])
	draw_polyline(rim, Color(wave_color.r, wave_color.g, wave_color.b, 0.92 * fade), 2.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
