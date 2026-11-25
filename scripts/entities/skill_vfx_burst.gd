class_name SkillVfxBurst
extends Node2D
## Hệ thống Hiệu Ứng Chiêu Thức 60–144 FPS (Additive Blend + Easing Curves + Multi-Layer Ribbons):
## - Thay thế hoàn toàn vòng draw_arc tĩnh bằng hiệu ứng động riêng biệt cho toàn bộ 15 Đấu Kỹ & Đánh thường Combo 3 nhịp!
## - Tự động đồng bộ bảng màu 23 Dị Hỏa / Thú Hỏa hiện tại và chạy theo _process() để mượt trên mọi màn hình 60/120/144Hz.

var vfx_mode: String = "melee_slash"
var duration: float = 0.28
var elapsed: float = 0.0
var radius_px: float = 110.0
var aim_angle: float = 0.0
var flip_dir: float = 1.0
var combo_idx: int = 1

var core_color: Color = Color("#FFF3B0")
var mid_color: Color = Color("#FF7B00")
var outer_color: Color = Color("#9E2A2B")
var extra_colors: Array = []

var follow_target: Node2D = null
var follow_offset: Vector2 = Vector2(0.0, -24.0)
var trail_end_local: Vector2 = Vector2.ZERO
var end_world_pos: Vector2 = Vector2.ZERO
var has_end_world_pos: bool = false

# Hạt cánh hoa / vết nứt / tia sét / trụ bụi sinh sẵn ngẫu nhiên ổn định theo seed của lần xuất chiêu
var _crack_angles: PackedFloat32Array = PackedFloat32Array()
var _crack_lengths: PackedFloat32Array = PackedFloat32Array()
var _petal_dirs: Array = []
var _bolt_jitters: PackedFloat32Array = PackedFloat32Array()
var _branch_data: Array = []
var _pillar_data: Array = []


func configure(
	mode: String,
	world_pos: Vector2,
	dir_vec: Vector2,
	rad: float,
	dur: float,
	c_core: Color,
	c_mid: Color,
	c_outer: Color,
	opts: Dictionary = {}
) -> void:
	vfx_mode = mode
	global_position = world_pos
	aim_angle = dir_vec.angle() if dir_vec.length() > 0.001 else 0.0
	radius_px = maxf(24.0, rad)
	duration = maxf(0.10, dur)
	elapsed = 0.0
	core_color = c_core
	mid_color = c_mid
	outer_color = c_outer
	flip_dir = float(opts.get("flip_dir", 1.0))
	combo_idx = int(opts.get("combo_idx", 1))
	follow_target = opts.get("follow_target", null) as Node2D
	follow_offset = opts.get("follow_offset", Vector2(0.0, -24.0)) as Vector2
	extra_colors = opts.get("extra_colors", []) as Array
	has_end_world_pos = false
	end_world_pos = world_pos
	trail_end_local = Vector2.ZERO
	if opts.has("end_world_pos"):
		end_world_pos = opts["end_world_pos"] as Vector2
		has_end_world_pos = true
		trail_end_local = end_world_pos - world_pos

	z_index = int(opts.get("z_index", 5))
	material = VfxAssets.get_additive_material()

	# Khởi tạo dữ liệu vết nứt / cánh lửa / tia sét / trụ bụi ngẫu nhiên 1 lần để không bị nhảy lung tung giữa các frame
	if vfx_mode == "toai_thach" or vfx_mode == "bat_cuc_bang" or vfx_mode == "poison_palm":
		var cnt: int = 8 if vfx_mode == "toai_thach" else 6
		_crack_angles.clear()
		_crack_lengths.clear()
		for i in range(cnt):
			var base_a: float = aim_angle + (float(i) - float(cnt - 1) * 0.5) * (0.28 if vfx_mode != "toai_thach" else 0.78)
			_crack_angles.append(base_a + randf_range(-0.14, 0.14))
			_crack_lengths.append(radius_px * randf_range(0.68, 1.08))
	elif vfx_mode == "lotus_detonate":
		_petal_dirs.clear()
		for i in range(16):
			var a: float = float(i) * (TAU / 16.0) + randf_range(-0.12, 0.12)
			_petal_dirs.append({
				"ang": a,
				"spd": radius_px * randf_range(0.75, 1.38),
				"spin": randf_range(-7.0, 7.0),
				"sz": randf_range(12.0, 24.0),
				"cidx": i
			})
	elif vfx_mode == "thunder_blink":
		_bolt_jitters.clear()
		for i in range(11):
			var sgn: float = 1.0 if (i % 2 == 0) else -1.0
			_bolt_jitters.append(sgn * randf_range(10.0, 26.0))
		_branch_data.clear()
		for b in range(6):
			var side_b: float = 1.0 if (b % 2 == 0) else -1.0
			_branch_data.append({
				"u": clampf(0.14 + float(b) * 0.14 + randf_range(-0.04, 0.04), 0.10, 0.88),
				"side": side_b,
				"ang_off": side_b * randf_range(0.45, 1.08),
				"len": randf_range(28.0, 62.0),
				"mid_jit": randf_range(-12.0, 12.0)
			})
	elif vfx_mode == "mountain_seal" or vfx_mode == "tyrant_claw":
		_crack_angles.clear()
		_crack_lengths.clear()
		for i in range(10):
			var ca: float = float(i) * (TAU / 10.0) + randf_range(-0.16, 0.16)
			_crack_angles.append(ca)
			_crack_lengths.append(radius_px * randf_range(0.82, 1.24))
		_pillar_data.clear()
		for p in range(6):
			var pa: float = float(p) * (TAU / 6.0) + randf_range(-0.18, 0.18)
			_pillar_data.append({
				"ang": pa,
				"dist": radius_px * randf_range(0.42, 0.88),
				"w": randf_range(12.0, 20.0),
				"h": randf_range(85.0, 145.0),
				"delay": float(p % 3) * 0.06
			})
	elif vfx_mode == "glazed_lotus_vortex":
		_petal_dirs.clear()
		for i in range(8):
			_petal_dirs.append({
				"ang": float(i) * (TAU / 8.0),
				"cidx": i
			})


func _process(delta: float) -> void:
	elapsed += delta
	if follow_target != null and is_instance_valid(follow_target):
		global_position = follow_target.global_position + follow_offset
	if elapsed >= duration:
		queue_free()
		return
	queue_redraw()


func _ease_out_expo(t: float) -> float:
	return 1.0 if t >= 1.0 else 1.0 - pow(2.0, -10.0 * t)


func _ease_out_cubic(t: float) -> float:
	var inv: float = 1.0 - clampf(t, 0.0, 1.0)
	return 1.0 - inv * inv * inv


func _draw() -> void:
	var t: float = clampf(elapsed / duration, 0.0, 1.0)
	match vfx_mode:
		"melee_slash":
			_draw_melee_slash(t)
		"toai_thach":
			_draw_toai_thach(t)
		"bat_cuc_bang":
			_draw_bat_cuc_bang(t)
		"flame_dash":
			_draw_flame_dash(t)
		"pull_pulse":
			_draw_pull_pulse(t)
		"sonic_stun":
			_draw_sonic_stun(t)
		"flame_shield":
			_draw_flame_shield(t)
		"wing_cyclone":
			_draw_wing_cyclone(t)
		"flame_buff":
			_draw_flame_buff(t)
		"poison_palm":
			_draw_poison_palm(t)
		"lotus_cast":
			_draw_lotus_cast(t)
		"lotus_detonate":
			_draw_lotus_detonate(t)
		"duoc_lao_assist":
			_draw_assist_pillar(t, false)
		"medusa_assist":
			_draw_assist_pillar(t, true)
		"thunder_blink":
			_draw_thunder_blink(t)
		"mountain_seal":
			_draw_mountain_seal(t)
		"golden_roar":
			_draw_golden_roar(t)
		"flame_clone":
			_draw_flame_clone(t)
		"windup_charge":
			_draw_windup_charge(t)
		"boss_strike_arc":
			_draw_boss_strike_arc(t)
		"tyrant_claw":
			_draw_tyrant_claw(t)
		"glazed_lotus_vortex":
			_draw_glazed_lotus_vortex(t)
		"ocean_seal":
			_draw_ocean_seal(t)
		"flame_buff_tier2":
			_draw_flame_buff_tier2(t)
		"dia_yeu_khoi_assist":
			_draw_dia_yeu_khoi_assist(t)
		"space_lock":
			_draw_space_lock(t)
		"emperor_five_seals":
			_draw_emperor_five_seals(t)
		"flame_buff_tier3":
			_draw_flame_buff_tier3(t)
		"soul_shock_palm":
			_draw_soul_shock_palm(t)
		"thunder_clone":
			_draw_thunder_clone(t)
		"thien_yeu_khoi_assist":
			_draw_thien_yeu_khoi_assist(t)
		"spatial_giant_palm":
			_draw_spatial_giant_palm(t)
		"creation_heaven_palm":
			_draw_creation_heaven_palm(t)
		"ten_golden_puppets":
			_draw_ten_golden_puppets(t)
		"xiao_clan_crest":
			_draw_xiao_clan_crest(t)
		"ban_thanh_duoc_tran_assist":
			_draw_ban_thanh_duoc_tran_assist(t)
		"yellow_springs_palm":
			_draw_yellow_springs_palm(t)
		"yellow_springs_wrath":
			_draw_yellow_springs_wrath(t)
		"reincarnation_fire_disc":
			_draw_reincarnation_fire_disc(t)
		"purifying_lotus_array":
			_draw_purifying_lotus_array(t)
		"bac_vuong_tinh_lien_assist":
			_draw_bac_vuong_tinh_lien_assist(t)
		"ground_crater":
			_draw_ground_crater(t)
		"dan_lei_pillar":
			_draw_dan_lei_pillar(t)
		_:
			_draw_generic_ring(t)


## Vẽ dải cung trăng khuyết vuốt nhọn 2 đầu mượt mà (dùng cho vệt chém, vòng xích, sóng kiếm).
func _draw_tapered_arc_ribbon(center: Vector2, r_mid: float, thickness: float, a_start: float, a_end: float, col: Color, segments: int = 20) -> void:
	if col.a <= 0.01 or thickness <= 0.4 or absf(a_end - a_start) < 0.02:
		return
	var outer_pts := PackedVector2Array()
	var inner_pts := PackedVector2Array()
	for i in range(segments + 1):
		var u: float = float(i) / float(segments)
		var ang: float = lerpf(a_start, a_end, u)
		# Dày ở đầu lưỡi (u ~ 0.68) và vuốt nhọn sắc bén về 2 đuôi
		var profile: float = sin(u * PI) * (0.65 + 0.55 * u)
		var half_w: float = thickness * 0.5 * profile
		var dir := Vector2(cos(ang), sin(ang))
		outer_pts.append(center + dir * (r_mid + half_w))
		inner_pts.append(center + dir * maxf(2.0, r_mid - half_w))
	var poly := PackedVector2Array()
	for p in outer_pts:
		poly.append(p)
	for j in range(inner_pts.size() - 1, -1, -1):
		poly.append(inner_pts[j])
	draw_colored_polygon(poly, col)


func _draw_melee_slash(t: float) -> void:
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.75), 0.0, 1.0)
	var span: float = 2.45 if combo_idx >= 3 else 1.85
	var start_a: float = aim_angle - flip_dir * span * 0.55
	var head_a: float = start_a + flip_dir * span * ease_t
	var tail_lag: float = clampf((t - 0.14) / 0.86, 0.0, 1.0)
	var tail_a: float = lerpf(start_a, head_a, tail_lag * tail_lag)

	var r: float = radius_px * (0.90 + 0.16 * ease_t)
	var base_thick: float = (34.0 if combo_idx >= 3 else 24.0) * (1.0 - 0.35 * t)

	# 3 tầng ánh sáng phát quang + lớp Motion-Smear che nối pha Windup->Impact mượt 60–144 FPS!
	var smear_fade: float = clampf(1.0 - pow(t, 1.35), 0.0, 1.0)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r * 0.78, base_thick * 2.15, start_a, head_a, Color(outer_color.r, outer_color.g, outer_color.b, 0.24 * smear_fade), 20)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r, base_thick * 1.65, tail_a, head_a, Color(outer_color.r, outer_color.g, outer_color.b, 0.46 * fade), 22)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r * 1.02, base_thick, tail_a, head_a, Color(mid_color.r, mid_color.g, mid_color.b, 0.86 * fade), 22)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r * 1.05, base_thick * 0.44, lerpf(tail_a, head_a, 0.22), head_a, Color(core_color.r, core_color.g, core_color.b, 0.98 * fade), 18)

	# Đầu lưỡi chém lóe sáng + 3 kim gió xé không khí bám theo mũi lưỡi + vệt thứ 2 cho nhịp Combo 3!
	var tip_dir := Vector2(cos(head_a), sin(head_a))
	var tip_tan := Vector2(-tip_dir.y, tip_dir.x) * flip_dir
	var tip_pos: Vector2 = tip_dir * (r * 1.03)
	draw_circle(tip_pos, (14.5 if combo_idx >= 3 else 9.5) * fade, Color(core_color.r, core_color.g, core_color.b, 0.88 * fade))
	for ns in range(3):
		var rad_off: float = (float(ns) - 1.0) * 11.0
		var needle_base: Vector2 = tip_dir * (r * 0.98 + rad_off)
		var needle_len: float = (34.0 if combo_idx >= 3 else 24.0) * (1.0 - 0.35 * t)
		draw_line(needle_base - tip_tan * needle_len, needle_base + tip_tan * (needle_len * 0.32), Color(core_color.r, core_color.g, core_color.b, 0.72 * fade), (2.6 if ns == 1 else 1.6) * fade)
	if combo_idx >= 3:
		_draw_tapered_arc_ribbon(Vector2.ZERO, r * 0.70, base_thick * 0.72, tail_a, head_a, Color(core_color.r, core_color.g, core_color.b, 0.62 * fade), 18)
		var ring_r: float = radius_px * (0.35 + 0.85 * _ease_out_cubic(t))
		draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 40, Color(mid_color.r, mid_color.g, mid_color.b, 0.58 * fade), 4.8 * fade)


func _draw_toai_thach(t: float) -> void:
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - t * t, 0.0, 1.0)
	var f_dir := Vector2(cos(aim_angle), sin(aim_angle))

	# 1. Sóng chưởng hình nón phóng thẳng về trước
	var cone_r: float = radius_px * (0.28 + 0.92 * ease_t)
	_draw_tapered_arc_ribbon(Vector2.ZERO, cone_r, 30.0 * fade, aim_angle - 0.92, aim_angle + 0.92, Color(mid_color.r, mid_color.g, mid_color.b, 0.85 * fade), 18)
	_draw_tapered_arc_ribbon(Vector2.ZERO, cone_r * 1.04, 13.0 * fade, aim_angle - 0.72, aim_angle + 0.72, Color(core_color.r, core_color.g, core_color.b, 0.95 * fade), 14)

	# 2. Vết nứt đá địa chấn lan tỏa từ tâm chưởng
	var crack_ext: float = clampf(t * 3.2, 0.0, 1.0)
	for i in range(_crack_angles.size()):
		var ang: float = _crack_angles[i]
		var L: float = _crack_lengths[i] * crack_ext
		var d := Vector2(cos(ang), sin(ang))
		var perp := Vector2(-d.y, d.x)
		var p1: Vector2 = d * (L * 0.45) + perp * (8.0 if (i % 2 == 0) else -8.0)
		var p2: Vector2 = d * L
		draw_polyline(PackedVector2Array([Vector2.ZERO, p1, p2]), Color(mid_color.r, mid_color.g, mid_color.b, 0.78 * fade), 3.6 * fade)
		draw_polyline(PackedVector2Array([Vector2.ZERO, p1, p2]), Color(core_color.r, core_color.g, core_color.b, 0.92 * fade), 1.6 * fade)

	# 3. Quầng nổ tâm chưởng & vòng chấn động
	draw_circle(f_dir * (10.0 * ease_t), radius_px * 0.42 * (1.0 - 0.35 * t), Color(core_color.r, core_color.g, core_color.b, 0.32 * fade))
	draw_arc(Vector2.ZERO, radius_px * (0.25 + 0.85 * ease_t), 0.0, TAU, 36, Color(outer_color.r, outer_color.g, outer_color.b, 0.75 * fade), 5.0 * fade)


func _draw_bat_cuc_bang(t: float) -> void:
	# BÁT CỰC BĂNG: 3 tầng sóng Ám Kình liên tiếp xuyên thủng mục tiêu!
	var f_dir := Vector2(cos(aim_angle), sin(aim_angle))
	var perp := Vector2(-f_dir.y, f_dir.x)

	for layer in range(3):
		var lt: float = clampf((t - float(layer) * 0.09) / (1.0 - float(layer) * 0.09), 0.0, 1.0)
		if lt <= 0.0 or lt >= 1.0:
			continue
		var le: float = _ease_out_expo(lt)
		var lf: float = 1.0 - lt * lt
		var center_pt: Vector2 = f_dir * (float(layer) * 28.0 + le * 24.0)
		var arc_r: float = radius_px * (0.45 + 0.65 * le) * (1.0 - float(layer) * 0.14)
		_draw_tapered_arc_ribbon(center_pt, arc_r, (28.0 - float(layer) * 5.0) * lf, aim_angle - 0.85, aim_angle + 0.85, Color(mid_color.r, mid_color.g, mid_color.b, 0.88 * lf), 16)
		_draw_tapered_arc_ribbon(center_pt, arc_r * 1.03, 10.0 * lf, aim_angle - 0.65, aim_angle + 0.65, Color(core_color.r, core_color.g, core_color.b, 0.96 * lf), 12)

	# Tia áp lực xé gió lao về phía trước
	var fade: float = clampf(1.0 - t * 1.15, 0.0, 1.0)
	var ease_t: float = _ease_out_expo(t)
	for i in range(6):
		var off_s: float = (float(i) - 2.5) * 18.0
		var p_start: Vector2 = perp * off_s + f_dir * (10.0 + ease_t * 25.0)
		var p_end: Vector2 = perp * (off_s * 1.35) + f_dir * (radius_px * (0.55 + 0.65 * ease_t))
		draw_line(p_start, p_end, Color(core_color.r, core_color.g, core_color.b, 0.82 * fade), 2.8 * fade)

	draw_circle(Vector2.ZERO, radius_px * 0.45 * (1.0 - t * 0.5), Color(core_color.r, core_color.g, core_color.b, 0.36 * fade))


func _draw_flame_dash(t: float) -> void:
	# BẠO BỘ: Nổ lửa dưới chân + vệt chấn động thiêu đốt dọc quỹ đạo lướt
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.5), 0.0, 1.0)
	var r0: float = radius_px * (0.20 + 0.85 * ease_t)

	draw_circle(Vector2.ZERO, r0 * 0.62, Color(mid_color.r, mid_color.g, mid_color.b, 0.24 * fade))
	draw_arc(Vector2.ZERO, r0, 0.0, TAU, 36, Color(mid_color.r, mid_color.g, mid_color.b, 0.90 * fade), 6.0 * fade)
	draw_arc(Vector2.ZERO, r0 * 0.65, 0.0, TAU, 28, Color(core_color.r, core_color.g, core_color.b, 0.95 * fade), 3.0 * fade)

	var wake_vec: Vector2 = trail_end_local if trail_end_local.length() > 12.0 else Vector2(cos(aim_angle), sin(aim_angle)) * (radius_px * 1.45)
	var cur_tip: Vector2 = wake_vec * clampf(t * 2.8, 0.0, 1.0)
	draw_line(Vector2.ZERO, cur_tip, Color(outer_color.r, outer_color.g, outer_color.b, 0.55 * fade), 32.0 * fade)
	draw_line(Vector2.ZERO, cur_tip, Color(mid_color.r, mid_color.g, mid_color.b, 0.85 * fade), 18.0 * fade)
	draw_line(Vector2.ZERO, cur_tip, Color(core_color.r, core_color.g, core_color.b, 0.96 * fade), 6.5 * fade)


func _draw_pull_pulse(t: float) -> void:
	# HẤP CHƯỞNG — XUY HỎA CHƯỞNG: 3 vòng gió hút NGƯỢC từ ngoài vào tâm + 8 dải lốc xoáy + nổ nén!
	var pull_t: float = clampf(t / 0.68, 0.0, 1.0)
	var inv_pull: float = 1.0 - _ease_out_cubic(pull_t)
	var pull_a: float = clampf(sin(pull_t * PI) * 1.15, 0.0, 1.0)

	# 3 vòng hút đồng tâm co dần về giữa
	for k in range(3):
		var kt: float = clampf(pull_t - float(k) * 0.14, 0.0, 1.0)
		var kr: float = radius_px * (1.05 - 0.88 * _ease_out_cubic(kt))
		var ka: float = sin(kt * PI)
		draw_arc(Vector2.ZERO, kr, elapsed * 5.0 + float(k) * 2.0, elapsed * 5.0 + float(k) * 2.0 + TAU * 0.78, 36, Color(mid_color.r, mid_color.g, mid_color.b, 0.82 * ka), 4.2)

	# 8 dải gió cong xoắn ốc lao từ vành ngoài hút vào tâm
	for i in range(8):
		var a0: float = float(i) * (TAU / 8.0) + elapsed * 6.5
		var pts := PackedVector2Array()
		for s in range(7):
			var u: float = float(s) / 6.0
			var rr: float = lerpf(radius_px * (0.28 + 0.72 * inv_pull), 10.0, u)
			var ang: float = a0 + u * 1.15
			pts.append(Vector2(cos(ang), sin(ang)) * rr)
		draw_polyline(pts, Color(core_color.r, core_color.g, core_color.b, 0.75 * pull_a), 2.8)

	# Pha nổ chấn kình (t > 0.56)
	if t > 0.56:
		var bt: float = clampf((t - 0.56) / 0.44, 0.0, 1.0)
		var be: float = _ease_out_expo(bt)
		var bf: float = 1.0 - bt
		draw_circle(Vector2.ZERO, radius_px * 0.45 * be, Color(core_color.r, core_color.g, core_color.b, 0.40 * bf))
		draw_arc(Vector2.ZERO, radius_px * 0.72 * be, 0.0, TAU, 36, Color(core_color.r, core_color.g, core_color.b, 0.92 * bf), 6.0 * bf)


func _draw_sonic_stun(t: float) -> void:
	# SƯ TỬ NGÂM: 3 lớp sóng âm vàng kim gợn sóng nở liên tiếp + gai chấn động hồn phách!
	for w in range(3):
		var wt: float = clampf((t - float(w) * 0.14) / (1.0 - float(w) * 0.14), 0.0, 1.0)
		if wt <= 0.0 or wt >= 1.0:
			continue
		var we: float = _ease_out_cubic(wt)
		var wf: float = 1.0 - wt * wt
		var base_r: float = radius_px * (0.18 + 0.92 * we)

		# Vòng sóng âm gợn sin quanh chu vi
		var pts := PackedVector2Array()
		var segs: int = 48
		for s in range(segs + 1):
			var ang: float = float(s) * TAU / float(segs)
			var ripple: float = sin(ang * 12.0 + elapsed * 24.0 + float(w) * 2.0) * (6.0 * wf)
			pts.append(Vector2(cos(ang), sin(ang)) * (base_r + ripple))
		draw_polyline(pts, Color(mid_color.r, mid_color.g, mid_color.b, 0.90 * wf), (6.0 - float(w) * 1.2) * wf)
		draw_arc(Vector2.ZERO, base_r * 0.94, 0.0, TAU, 40, Color(core_color.r, core_color.g, core_color.b, 0.75 * wf), 2.4 * wf)

	# 12 tia sóng gầm phóng xuyên tâm
	var fade: float = clampf(1.0 - t * 1.25, 0.0, 1.0)
	var ease_t: float = _ease_out_expo(t)
	for i in range(12):
		var a: float = float(i) * (TAU / 12.0) + 0.12
		var p1 := Vector2(cos(a), sin(a)) * (radius_px * 0.25 * ease_t)
		var p2 := Vector2(cos(a), sin(a)) * (radius_px * (0.65 + 0.45 * ease_t))
		draw_line(p1, p2, Color(core_color.r, core_color.g, core_color.b, 0.65 * fade), 2.5 * fade)


func _draw_flame_shield(t: float) -> void:
	# LỤC HỢP DU THÂN XÍCH: Xoay 3 lưỡi xích lửa 360° tốc độ cao + Hỏa Thuẫn bảo vệ suốt 1.25s!
	var env: float = clampf(t * 7.0, 0.0, 1.0) * clampf((1.0 - t) * 4.0, 0.0, 1.0)
	var burst_t: float = clampf(t / 0.30, 0.0, 1.0)
	var spin: float = elapsed * 13.5

	# Vụ nổ quét 360° mở màn (0..0.30)
	if burst_t < 1.0:
		var bf: float = 1.0 - burst_t
		var br: float = radius_px * (0.35 + 0.75 * _ease_out_expo(burst_t))
		draw_circle(Vector2.ZERO, br * 0.85, Color(mid_color.r, mid_color.g, mid_color.b, 0.22 * bf))
		draw_arc(Vector2.ZERO, br, 0.0, TAU, 48, Color(core_color.r, core_color.g, core_color.b, 0.92 * bf), 7.5 * bf)

	# 3 vòng lưỡi xích lửa xoay liên tục quanh thân Tiêu Viêm
	var shield_r: float = lerpf(radius_px * 0.88, 62.0, clampf(t * 2.4, 0.0, 1.0))
	for k in range(3):
		var a0: float = spin + float(k) * (TAU / 3.0)
		_draw_tapered_arc_ribbon(Vector2.ZERO, shield_r, 18.0 * env, a0, a0 + 1.35, Color(mid_color.r, mid_color.g, mid_color.b, 0.82 * env), 14)
		_draw_tapered_arc_ribbon(Vector2.ZERO, shield_r * 1.03, 7.0 * env, a0 + 0.35, a0 + 1.35, Color(core_color.r, core_color.g, core_color.b, 0.95 * env), 10)

	# Quầng Hỏa Thuẫn miễn thương lấp lánh
	var pulse: float = 0.88 + sin(elapsed * 18.0) * 0.12
	draw_circle(Vector2.ZERO, shield_r * 0.82, Color(outer_color.r, outer_color.g, outer_color.b, 0.14 * env * pulse))
	draw_arc(Vector2.ZERO, shield_r * 0.82, -spin * 0.6, -spin * 0.6 + TAU * 0.85, 36, Color(core_color.r, core_color.g, core_color.b, 0.78 * env), 2.8)


func _draw_wing_cyclone(t: float) -> void:
	# TỬ VÂN DỰC KÍCH: Đôi cánh tím bung rực phía sau + lốc xoáy tím quét càn!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.65), 0.0, 1.0)
	var f_dir := Vector2(cos(aim_angle), sin(aim_angle))
	var perp := Vector2(-f_dir.y, f_dir.x)

	# Đôi cánh Tử Vân Dực 2 bên bung rộng theo hướng lao
	var wing_span: float = 52.0 + 46.0 * ease_t
	for side in [-1.0, 1.0]:
		var w_pts := PackedVector2Array([
			-f_dir * 8.0,
			perp * (side * wing_span * 0.55) - f_dir * 26.0,
			perp * (side * wing_span) - f_dir * 6.0,
			perp * (side * wing_span * 0.78) + f_dir * 22.0,
			perp * (side * wing_span * 0.30) + f_dir * 8.0
		])
		draw_colored_polygon(w_pts, Color(mid_color.r, mid_color.g, mid_color.b, 0.45 * fade))
		draw_polyline(w_pts, Color(core_color.r, core_color.g, core_color.b, 0.90 * fade), 2.6 * fade)

	# 2 vòng lốc xoáy tím càn quét
	var spin: float = elapsed * 14.0
	var r1: float = radius_px * (0.30 + 0.78 * ease_t)
	_draw_tapered_arc_ribbon(f_dir * 24.0, r1, 24.0 * fade, spin, spin + 2.6, Color(mid_color.r, mid_color.g, mid_color.b, 0.85 * fade), 18)
	_draw_tapered_arc_ribbon(f_dir * 24.0, r1 * 0.72, 16.0 * fade, spin + PI, spin + PI + 2.4, Color(core_color.r, core_color.g, core_color.b, 0.92 * fade), 16)


func _draw_flame_buff(t: float) -> void:
	# THIÊN HỎA TAM HUYỀN BIẾN: 3 cột lửa bốc thẳng lên trời + sóng nhiệt bùng nổ!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.55), 0.0, 1.0)

	# 3 tầng cột lửa dâng cao từ chân nhân vật
	var pillar_h: float = 195.0 * clampf(t * 2.5, 0.0, 1.0)
	var pillar_w: float = (56.0 * (1.0 - 0.55 * t))
	for k in range(3):
		var pw: float = pillar_w * (1.0 - float(k) * 0.28)
		var col: Color = outer_color if k == 0 else (mid_color if k == 1 else core_color)
		var alpha: float = (0.38 if k == 0 else (0.58 if k == 1 else 0.82)) * fade
		var rect := Rect2(-pw * 0.5, 16.0 - pillar_h, pw, pillar_h)
		draw_rect(rect, Color(col.r, col.g, col.b, alpha), true)

	# 3 vòng hỏa ấn bốc lên
	for ring_i in range(3):
		var rt: float = clampf(t - float(ring_i) * 0.12, 0.0, 1.0)
		var y_rise: float = 10.0 - rt * 120.0
		var rr: float = radius_px * (0.28 + 0.75 * _ease_out_cubic(rt))
		var rf: float = 1.0 - rt
		draw_set_transform(Vector2(0.0, y_rise), 0.0, Vector2(1.0, 0.42))
		draw_arc(Vector2.ZERO, rr, 0.0, TAU, 40, Color(mid_color.r, mid_color.g, mid_color.b, 0.88 * rf), 5.5 * rf)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_arc(Vector2.ZERO, radius_px * (0.22 + 0.88 * ease_t), 0.0, TAU, 44, Color(core_color.r, core_color.g, core_color.b, 0.85 * fade), 4.0 * fade)


func _draw_poison_palm(t: float) -> void:
	# LẠC ĐỘC ÁM CHƯỞNG: Sóng chưởng xanh ngọc đen + 6 luồng độc khí uốn lượn + độc ấn!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - t * t, 0.0, 1.0)

	var wave_r: float = radius_px * (0.25 + 0.85 * ease_t)
	_draw_tapered_arc_ribbon(Vector2.ZERO, wave_r, 28.0 * fade, aim_angle - 1.1, aim_angle + 1.1, Color(mid_color.r, mid_color.g, mid_color.b, 0.85 * fade), 18)
	_draw_tapered_arc_ribbon(Vector2.ZERO, wave_r * 0.86, 12.0 * fade, aim_angle - 0.85, aim_angle + 0.85, Color(core_color.r, core_color.g, core_color.b, 0.90 * fade), 14)

	# 6 luồng độc khí uốn lượn bò về phía mục tiêu
	for i in range(_crack_angles.size()):
		var ang: float = _crack_angles[i]
		var d := Vector2(cos(ang), sin(ang))
		var perp := Vector2(-d.y, d.x)
		var L: float = _crack_lengths[i] * ease_t
		var pts := PackedVector2Array()
		for s in range(7):
			var u: float = float(s) / 6.0
			var wag: float = sin(u * 8.0 + elapsed * 18.0 + float(i)) * 9.0 * u
			pts.append(d * (L * u) + perp * wag)
		draw_polyline(pts, Color(mid_color.r, mid_color.g, mid_color.b, 0.82 * fade), 4.2 * fade)
		draw_polyline(pts, Color(core_color.r, core_color.g, core_color.b, 0.85 * fade), 1.6 * fade)

	draw_arc(Vector2.ZERO, radius_px * 0.48 * ease_t, elapsed * 4.0, elapsed * 4.0 + TAU * 0.82, 32, Color(core_color.r, core_color.g, core_color.b, 0.80 * fade), 3.0 * fade)


func _draw_lotus_cast(t: float) -> void:
	# Pha tụ ấn 0.24s trước khi phóng Phật Nộ Hỏa Liên: các luồng lửa từ nhiều ngọn Dị Hỏa hội tụ giữa lòng bàn tay!
	var inv: float = 1.0 - _ease_out_cubic(t)
	var cols: Array = extra_colors if not extra_colors.is_empty() else [mid_color, core_color]
	var cnt: int = maxi(4, cols.size() * 2)
	for i in range(cnt):
		var c: Color = cols[i % cols.size()] as Color
		var a: float = float(i) * (TAU / float(cnt)) + elapsed * 10.0
		var r_out: float = lerpf(88.0, 12.0, _ease_out_cubic(t))
		var p_out := Vector2(cos(a), sin(a)) * r_out
		var p_mid := Vector2(cos(a + 0.45), sin(a + 0.45)) * (r_out * 0.55)
		draw_polyline(PackedVector2Array([p_out, p_mid, Vector2.ZERO]), Color(c.r, c.g, c.b, 0.90), 3.8)
		draw_circle(p_out, 5.5 * inv + 2.0, Color(c.r, c.g, c.b, 0.92))

	var core_r: float = 6.0 + 18.0 * _ease_out_expo(t)
	draw_circle(Vector2.ZERO, core_r, Color(mid_color.r, mid_color.g, mid_color.b, 0.65))
	draw_circle(Vector2.ZERO, core_r * 0.52, Color(1.0, 0.98, 0.90, 0.95))


func _draw_lotus_detonate(t: float) -> void:
	# VỤ NỔ PHẬT NỘ HỎA LIÊN ĐA TẦNG: Lóe sáng tâm + 2 sóng xung kích + 16 cánh sen lửa bay rợp trời!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.45), 0.0, 1.0)
	var cols: Array = extra_colors if not extra_colors.is_empty() else [mid_color, core_color]
	var c0: Color = cols[0] as Color
	var c1: Color = cols[1 % cols.size()] as Color

	# Quầng sáng nổ cực đại ngay khoảnh khắc kích nổ (flash mềm)
	var flash_a: float = clampf(1.0 - t * 3.2, 0.0, 1.0)
	if flash_a > 0.01:
		draw_circle(Vector2.ZERO, radius_px * (0.85 + 0.45 * ease_t), Color(1.0, 0.97, 0.86, 0.55 * flash_a))

	# 2 sóng xung kích nở lệch nhịp
	var r_outer: float = radius_px * (0.25 + 1.05 * ease_t)
	draw_circle(Vector2.ZERO, r_outer * 0.82, Color(c0.r, c0.g, c0.b, 0.22 * fade))
	draw_arc(Vector2.ZERO, r_outer, 0.0, TAU, 56, Color(c0.r, c0.g, c0.b, 0.95 * fade), 10.0 * fade)
	draw_arc(Vector2.ZERO, r_outer * 0.94, 0.0, TAU, 48, Color(1.0, 0.98, 0.88, 0.90 * fade), 3.6 * fade)

	if t > 0.08:
		var t2: float = clampf((t - 0.08) / 0.92, 0.0, 1.0)
		var r2: float = radius_px * (0.15 + 0.95 * _ease_out_cubic(t2))
		var f2: float = 1.0 - t2 * t2
		draw_arc(Vector2.ZERO, r2, 0.0, TAU, 48, Color(c1.r, c1.g, c1.b, 0.88 * f2), 6.5 * f2)

	# 16 cánh sen lửa sắc nhọn xoay văng ra xung quanh
	for pd in _petal_dirs:
		var d_ang: float = float(pd["ang"])
		var dist: float = float(pd["spd"]) * ease_t
		var pos := Vector2(cos(d_ang), sin(d_ang)) * dist
		var rot: float = d_ang + float(pd["spin"]) * t
		var sz: float = float(pd["sz"]) * (1.0 - 0.55 * t)
		var pc: Color = cols[int(pd["cidx"]) % cols.size()] as Color
		var f_v := Vector2(cos(rot), sin(rot))
		var p_v := Vector2(-f_v.y, f_v.x)
		var petal_poly := PackedVector2Array([
			pos + f_v * sz,
			pos + p_v * (sz * 0.36),
			pos - f_v * (sz * 0.55),
			pos - p_v * (sz * 0.36)
		])
		draw_colored_polygon(petal_poly, Color(pc.r, pc.g, pc.b, 0.88 * fade))
		draw_circle(pos, sz * 0.24, Color(1.0, 0.98, 0.90, 0.85 * fade))


func _draw_assist_pillar(t: float, is_medusa: bool) -> void:
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.5), 0.0, 1.0)
	var r: float = radius_px * (0.20 + 0.95 * ease_t)

	# Cột năng lượng giáng xuống
	var ph: float = 280.0
	var pw: float = (78.0 if is_medusa else 62.0) * (1.0 - 0.65 * t)
	draw_rect(Rect2(-pw * 0.5, 16.0 - ph, pw, ph), Color(mid_color.r, mid_color.g, mid_color.b, 0.45 * fade), true)
	draw_rect(Rect2(-pw * 0.24, 16.0 - ph, pw * 0.48, ph), Color(core_color.r, core_color.g, core_color.b, 0.85 * fade), true)

	draw_circle(Vector2.ZERO, r * 0.72, Color(mid_color.r, mid_color.g, mid_color.b, 0.22 * fade))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 52, Color(mid_color.r, mid_color.g, mid_color.b, 0.95 * fade), 8.5 * fade)
	draw_arc(Vector2.ZERO, r * 0.68, elapsed * 5.0, elapsed * 5.0 + TAU * 0.82, 40, Color(core_color.r, core_color.g, core_color.b, 0.90 * fade), 4.0 * fade)

	if is_medusa:
		# Vết nứt không gian Đấu Tông Mỹ Đỗ Toa
		for i in range(8):
			var a: float = float(i) * (TAU / 8.0) + 0.35
			var d := Vector2(cos(a), sin(a))
			draw_line(d * (r * 0.25), d * (r * 1.15), Color(1.0, 0.92, 1.0, 0.88 * fade), 3.0 * fade)


func _draw_thunder_blink(t: float) -> void:
	# TAM THIÊN LÔI ĐỘNG: Tia sét ngân-tử điện áp cao nối gốc -> end_world_pos + nhánh sét phụ + vòng điện nổ + tàn ảnh Lôi Ảnh!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.45), 0.0, 1.0)
	var end_local: Vector2 = to_local(end_world_pos) if has_end_world_pos else (trail_end_local if trail_end_local.length() > 4.0 else Vector2(cos(aim_angle), sin(aim_angle)) * (radius_px * 1.45))
	var bolt_vec: Vector2 = end_local
	var bolt_len: float = bolt_vec.length()
	var bolt_dir: Vector2 = bolt_vec / bolt_len if bolt_len > 1.0 else Vector2(cos(aim_angle), sin(aim_angle))
	var perp := Vector2(-bolt_dir.y, bolt_dir.x)

	# 1. Tàn ảnh Lôi Ảnh bùng sáng tại điểm xuất phát (Origin Silhouette Flash)
	var flash_a: float = clampf(1.0 - t * 2.1, 0.0, 1.0)
	if flash_a > 0.01:
		draw_circle(Vector2.ZERO, radius_px * 0.48 * (0.7 + 0.5 * ease_t), Color(outer_color.r, outer_color.g, outer_color.b, 0.34 * flash_a))
		var sil_h: float = 54.0 * (1.0 + 0.25 * t)
		var sil_w: float = 20.0 * (1.0 - 0.30 * t)
		var sil_poly := PackedVector2Array([
			Vector2(0.0, -sil_h),
			Vector2(sil_w, -sil_h * 0.45),
			Vector2(sil_w * 0.62, 10.0),
			Vector2(0.0, 18.0),
			Vector2(-sil_w * 0.62, 10.0),
			Vector2(-sil_w, -sil_h * 0.45)
		])
		draw_colored_polygon(sil_poly, Color(mid_color.r, mid_color.g, mid_color.b, 0.52 * flash_a))
		draw_polyline(sil_poly, Color(core_color.r, core_color.g, core_color.b, 0.96 * flash_a), 2.6 * flash_a)
		draw_line(Vector2(0.0, -sil_h * 1.15), Vector2(0.0, 18.0), Color(core_color.r, core_color.g, core_color.b, 0.92 * flash_a), 5.0 * flash_a)

	# 2. Vòng điện chấn động nở rộng có gai tia chớp tại điểm gốc + điểm đáp
	var ring_r: float = radius_px * (0.24 + 0.84 * ease_t)
	var jagged_ring := PackedVector2Array()
	var r_segs: int = 36
	for s in range(r_segs + 1):
		var ang: float = float(s) * TAU / float(r_segs)
		var jag: float = (1.0 if (s % 2 == 0) else -1.0) * (5.5 + 3.0 * sin(elapsed * 48.0 + float(s) * 1.7)) * fade
		jagged_ring.append(Vector2(cos(ang), sin(ang)) * (ring_r + jag))
	draw_polyline(jagged_ring, Color(outer_color.r, outer_color.g, outer_color.b, 0.72 * fade), 6.5 * fade)
	draw_polyline(jagged_ring, Color(core_color.r, core_color.g, core_color.b, 0.92 * fade), 2.2 * fade)
	draw_arc(Vector2.ZERO, ring_r * 0.74, elapsed * 9.0, elapsed * 9.0 + TAU * 0.78, 32, Color(mid_color.r, mid_color.g, mid_color.b, 0.78 * fade), 3.0 * fade)

	if t > 0.08:
		var end_t: float = clampf((t - 0.08) / 0.92, 0.0, 1.0)
		var end_f: float = 1.0 - end_t * end_t
		var end_r: float = radius_px * (0.18 + 0.52 * _ease_out_expo(end_t))
		draw_circle(end_local, end_r * 0.55, Color(mid_color.r, mid_color.g, mid_color.b, 0.24 * end_f))
		draw_arc(end_local, end_r, 0.0, TAU, 30, Color(mid_color.r, mid_color.g, mid_color.b, 0.88 * end_f), 4.6 * end_f)
		draw_arc(end_local, end_r * 0.65, 0.0, TAU, 24, Color(core_color.r, core_color.g, core_color.b, 0.94 * end_f), 2.0 * end_f)

	# 3. Tia sét chính 3 tầng (Viền Tử Quang -> Thân Ngân Lôi -> Lõi Trắng Bạch) + Tia sét xoắn song hành
	var seg_cnt: int = maxi(6, _bolt_jitters.size() - 1)
	var main_pts := PackedVector2Array()
	var sub_pts := PackedVector2Array()
	var prog_tip: float = clampf(t * 4.5, 0.22, 1.0)
	for i in range(seg_cnt + 1):
		var u: float = (float(i) / float(seg_cnt)) * prog_tip
		var base_p: Vector2 = bolt_vec * u
		var env_u: float = sin((float(i) / float(seg_cnt)) * PI)
		var base_j: float = _bolt_jitters[i % _bolt_jitters.size()] if not _bolt_jitters.is_empty() else 14.0
		var crackle: float = 0.78 + 0.42 * sin(elapsed * 64.0 + float(i) * 4.3)
		var off_main: float = base_j * env_u * crackle
		var off_sub: float = -base_j * 0.72 * env_u * (0.75 + 0.45 * cos(elapsed * 52.0 + float(i) * 3.1))
		main_pts.append(base_p + perp * off_main)
		sub_pts.append(base_p + perp * off_sub)

	if main_pts.size() >= 2:
		draw_polyline(main_pts, Color(outer_color.r, outer_color.g, outer_color.b, 0.44 * fade), 18.0 * fade)
		draw_polyline(main_pts, Color(mid_color.r, mid_color.g, mid_color.b, 0.88 * fade), 8.2 * fade)
		draw_polyline(main_pts, Color(core_color.r, core_color.g, core_color.b, 0.98 * fade), 3.0 * fade)
	if sub_pts.size() >= 2:
		draw_polyline(sub_pts, Color(mid_color.r, mid_color.g, mid_color.b, 0.65 * fade), 4.2 * fade)
		draw_polyline(sub_pts, Color(core_color.r, core_color.g, core_color.b, 0.85 * fade), 1.6 * fade)

	# 4. Các nhánh sét phân nhánh lóe rực dọc thân tia chớp
	for bi in range(_branch_data.size()):
		var bd: Dictionary = _branch_data[bi]
		var bu: float = float(bd["u"])
		if bu > prog_tip:
			continue
		var root_p: Vector2 = bolt_vec * bu + perp * (sin(bu * PI) * 8.0 * float(bd["side"]))
		var b_dir: Vector2 = bolt_dir.rotated(float(bd["ang_off"]))
		var b_perp := Vector2(-b_dir.y, b_dir.x)
		var b_len: float = float(bd["len"]) * (0.75 + 0.35 * sin(elapsed * 50.0 + float(bi) * 2.7))
		var mid_p: Vector2 = root_p + b_dir * (b_len * 0.52) + b_perp * float(bd["mid_jit"])
		var tip_p: Vector2 = root_p + b_dir * b_len
		var b_pts := PackedVector2Array([root_p, mid_p, tip_p])
		draw_polyline(b_pts, Color(mid_color.r, mid_color.g, mid_color.b, 0.78 * fade), 4.0 * fade)
		draw_polyline(b_pts, Color(core_color.r, core_color.g, core_color.b, 0.95 * fade), 1.6 * fade)


func _draw_mountain_seal(t: float) -> void:
	# ĐẾ ẤN QUYẾT — KHAI SƠN ẤN: Cổ Đế Kim-Ngọc Thủ Ấn từ trời giáng xuống (-180px -> 0px) + sóng chấn động + tia nứt + cột bụi sáng!
	var slam_t: float = clampf(t / 0.28, 0.0, 1.0)
	var drop_ease: float = slam_t * slam_t * slam_t
	var drop_y: float = lerpf(-180.0, 0.0, drop_ease)
	var imp_t: float = clampf((t - 0.26) / 0.74, 0.0, 1.0)
	var imp_ease: float = _ease_out_expo(imp_t)
	var imp_fade: float = clampf(1.0 - pow(imp_t, 1.55), 0.0, 1.0)
	var jade_col: Color = outer_color

	# 1. Vòng định vị tụ lực trên mặt đất trước khi Ấn nện xuống
	if slam_t < 1.0:
		var tele_r: float = radius_px * (1.15 - 0.38 * slam_t)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.56))
		draw_arc(Vector2.ZERO, tele_r, elapsed * 4.0, elapsed * 4.0 + TAU * 0.88, 44, Color(mid_color.r, mid_color.g, mid_color.b, 0.75 * slam_t), 4.0)
		draw_circle(Vector2.ZERO, radius_px * 0.58 * slam_t, Color(jade_col.r, jade_col.g, jade_col.b, 0.18 * slam_t))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 2. Vụ nổ khi Khai Sơn Ấn đập xuống mặt đất (t >= 0.26)
	if imp_t > 0.0:
		var flash_a: float = clampf(1.0 - imp_t * 3.1, 0.0, 1.0)
		if flash_a > 0.01:
			draw_circle(Vector2.ZERO, radius_px * (0.72 + 0.45 * imp_ease), Color(core_color.r, core_color.g, core_color.b, 0.50 * flash_a))

		# 3 tầng sóng xung kích vàng kim - ngọc bích đồng tâm
		for w in range(3):
			var wt: float = clampf((imp_t - float(w) * 0.11) / (1.0 - float(w) * 0.11), 0.0, 1.0)
			if wt <= 0.0 or wt >= 1.0:
				continue
			var we: float = _ease_out_expo(wt)
			var wf: float = 1.0 - wt * wt
			var wr: float = radius_px * (0.24 + 0.98 * we)
			var w_col: Color = mid_color if w != 1 else jade_col
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.56))
			draw_arc(Vector2.ZERO, wr, 0.0, TAU, 48, Color(w_col.r, w_col.g, w_col.b, 0.92 * wf), (8.5 - float(w) * 1.8) * wf)
			draw_arc(Vector2.ZERO, wr * 0.92, 0.0, TAU, 40, Color(core_color.r, core_color.g, core_color.b, 0.80 * wf), 2.5 * wf)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		# 10 tia nứt địa chấn phóng xuyên tâm
		var crack_ext: float = clampf(imp_t * 3.4, 0.0, 1.0)
		for i in range(_crack_angles.size()):
			var ang: float = _crack_angles[i]
			var L: float = _crack_lengths[i] * crack_ext
			var d := Vector2(cos(ang), sin(ang))
			var p_v := Vector2(-d.y, d.x)
			var mid_pt: Vector2 = d * (L * 0.48) + p_v * (10.0 if (i % 2 == 0) else -10.0)
			var end_pt: Vector2 = d * L
			mid_pt.y *= 0.62
			end_pt.y *= 0.62
			draw_polyline(PackedVector2Array([Vector2.ZERO, mid_pt, end_pt]), Color(mid_color.r, mid_color.g, mid_color.b, 0.85 * imp_fade), 4.6 * imp_fade)
			draw_polyline(PackedVector2Array([Vector2.ZERO, mid_pt, end_pt]), Color(core_color.r, core_color.g, core_color.b, 0.96 * imp_fade), 1.8 * imp_fade)

		# 6 cột bụi linh khí phát sáng bốc thẳng lên trời xung quanh ấn ký
		for pd in _pillar_data:
			var pt: float = clampf((imp_t - float(pd["delay"])) / maxf(0.2, 1.0 - float(pd["delay"])), 0.0, 1.0)
			if pt <= 0.0:
				continue
			var pe: float = _ease_out_cubic(pt)
			var pf: float = sin(pt * PI) * imp_fade
			var pa: float = float(pd["ang"])
			var bx: float = cos(pa) * float(pd["dist"]) * (0.85 + 0.25 * pe)
			var by: float = sin(pa) * float(pd["dist"]) * 0.56
			var pw: float = float(pd["w"]) * (1.0 - 0.35 * pt)
			var ph: float = float(pd["h"]) * pe
			draw_rect(Rect2(bx - pw * 0.5, by - ph, pw, ph), Color(jade_col.r, jade_col.g, jade_col.b, 0.36 * pf), true)
			draw_rect(Rect2(bx - pw * 0.24, by - ph, pw * 0.48, ph), Color(core_color.r, core_color.g, core_color.b, 0.72 * pf), true)

	# 3. Cự Ấn Cổ Đế Kim-Ngọc (rơi từ -180px -> 0px rồi tỏa sáng tan dần)
	var seal_fade: float = 1.0 if slam_t < 1.0 else clampf(1.0 - pow(imp_t, 1.35), 0.0, 1.0)
	if seal_fade > 0.02:
		var seal_sc: float = 1.0 + 0.14 * imp_ease
		var half_s: float = radius_px * 0.42 * seal_sc
		var seal_center := Vector2(0.0, drop_y - 18.0)

		# Vệt gió nén phía trên khi Cự Ấn đang lao xuống
		if slam_t < 1.0:
			for k in range(-2, 3):
				var sx: float = float(k) * (half_s * 0.44)
				draw_line(
					seal_center + Vector2(sx, -half_s * 0.6),
					seal_center + Vector2(sx, -half_s * 2.1),
					Color(mid_color.r, mid_color.g, mid_color.b, 0.55 * (1.0 - slam_t * 0.35)),
					4.0
				)

		# Khung Ấn Bát Quái / Đế Ấn vuông vát góc (Kim-Ngọc phát quang)
		var cut: float = half_s * 0.24
		var oct_pts := PackedVector2Array([
			seal_center + Vector2(-half_s + cut, -half_s),
			seal_center + Vector2(half_s - cut, -half_s),
			seal_center + Vector2(half_s, -half_s + cut),
			seal_center + Vector2(half_s, half_s - cut),
			seal_center + Vector2(half_s - cut, half_s),
			seal_center + Vector2(-half_s + cut, half_s),
			seal_center + Vector2(-half_s, half_s - cut),
			seal_center + Vector2(-half_s, -half_s + cut)
		])
		draw_colored_polygon(oct_pts, Color(jade_col.r, jade_col.g, jade_col.b, 0.24 * seal_fade))
		var oct_loop := PackedVector2Array(oct_pts)
		oct_loop.append(oct_pts[0])
		draw_polyline(oct_loop, Color(mid_color.r, mid_color.g, mid_color.b, 0.92 * seal_fade), 5.5 * seal_fade)
		draw_polyline(oct_loop, Color(core_color.r, core_color.g, core_color.b, 0.96 * seal_fade), 2.0 * seal_fade)

		# Khung trong & Cổ tự "Sơn / Đế Ấn" sắc nét tỏa kim quang
		var in_s: float = half_s * 0.72
		draw_rect(Rect2(seal_center.x - in_s, seal_center.y - in_s, in_s * 2.0, in_s * 2.0), Color(mid_color.r, mid_color.g, mid_color.b, 0.62 * seal_fade), false, 2.4)
		var g_s: float = half_s * 0.46
		var rune_col := Color(core_color.r, core_color.g, core_color.b, 0.96 * seal_fade)
		# Nét trục giữa + 2 đỉnh sơn + đế ngang (hình tượng Khai Sơn Cổ Ấn)
		draw_line(seal_center + Vector2(0.0, -g_s), seal_center + Vector2(0.0, g_s * 0.85), rune_col, 4.2 * seal_fade)
		draw_line(seal_center + Vector2(-g_s * 0.85, -g_s * 0.25), seal_center + Vector2(-g_s * 0.85, g_s * 0.85), rune_col, 3.6 * seal_fade)
		draw_line(seal_center + Vector2(g_s * 0.85, -g_s * 0.25), seal_center + Vector2(g_s * 0.85, g_s * 0.85), rune_col, 3.6 * seal_fade)
		draw_line(seal_center + Vector2(-g_s * 0.92, g_s * 0.85), seal_center + Vector2(g_s * 0.92, g_s * 0.85), rune_col, 4.0 * seal_fade)
		draw_line(seal_center + Vector2(-g_s * 0.55, -g_s * 0.55), seal_center + Vector2(g_s * 0.55, -g_s * 0.55), Color(mid_color.r, mid_color.g, mid_color.b, 0.88 * seal_fade), 2.8 * seal_fade)


func _draw_golden_roar(t: float) -> void:
	# SƯ HỔ TOÁI KIM NGÂM: Quạt sóng âm vàng kim rộng ±48° + 4 tầng lưỡi liềm áp lực + răng nanh Sư Hổ + gợn sóng xuyên tâm!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.55), 0.0, 1.0)
	var half_cone: float = deg_to_rad(48.0)

	# 1. Quạt ánh kim nền biểu thị rõ vùng nón ±48°
	var cone_r: float = radius_px * (0.32 + 0.76 * ease_t)
	var fan_pts := PackedVector2Array([Vector2.ZERO])
	var fan_segs: int = 18
	for s in range(fan_segs + 1):
		var ang: float = lerpf(aim_angle - half_cone, aim_angle + half_cone, float(s) / float(fan_segs))
		fan_pts.append(Vector2(cos(ang), sin(ang)) * cone_r)
	draw_colored_polygon(fan_pts, Color(outer_color.r, outer_color.g, outer_color.b, 0.16 * fade))

	# 2. 4 tầng sóng lưỡi liềm áp lực âm ba bắn liên hoàn về phía trước
	for layer in range(4):
		var lt: float = clampf((t - float(layer) * 0.085) / (1.0 - float(layer) * 0.085), 0.0, 1.0)
		if lt <= 0.0 or lt >= 1.0:
			continue
		var le: float = _ease_out_cubic(lt)
		var lf: float = 1.0 - lt * lt
		var arc_r: float = radius_px * (0.24 + 0.86 * le)
		var thick: float = (28.0 - float(layer) * 3.8) * lf
		_draw_tapered_arc_ribbon(Vector2.ZERO, arc_r, thick * 1.45, aim_angle - half_cone, aim_angle + half_cone, Color(outer_color.r, outer_color.g, outer_color.b, 0.42 * lf), 20)
		_draw_tapered_arc_ribbon(Vector2.ZERO, arc_r, thick, aim_angle - half_cone * 0.96, aim_angle + half_cone * 0.96, Color(mid_color.r, mid_color.g, mid_color.b, 0.88 * lf), 20)
		_draw_tapered_arc_ribbon(Vector2.ZERO, arc_r * 1.03, thick * 0.38, aim_angle - half_cone * 0.84, aim_angle + half_cone * 0.84, Color(core_color.r, core_color.g, core_color.b, 0.96 * lf), 16)

		# Đường sóng âm rung sin chạy dọc theo từng tầng lưỡi liềm
		var rip_pts := PackedVector2Array()
		for rs in range(25):
			var u: float = float(rs) / 24.0
			var ra: float = lerpf(aim_angle - half_cone * 0.92, aim_angle + half_cone * 0.92, u)
			var rip: float = sin(u * PI * 8.0 + elapsed * 32.0 + float(layer) * 1.8) * (5.5 * lf)
			rip_pts.append(Vector2(cos(ra), sin(ra)) * (arc_r + rip))
		draw_polyline(rip_pts, Color(core_color.r, core_color.g, core_color.b, 0.72 * lf), 2.2 * lf)

	# 3. Răng nanh ấn ký Sư Hổ Vàng Kim dọc 2 mép hàm gầm thét
	var fang_offsets: Array[float] = [-0.74, -0.44, -0.18, 0.18, 0.44, 0.74]
	for fi in range(fang_offsets.size()):
		var fa: float = aim_angle + fang_offsets[fi]
		var f_dir := Vector2(cos(fa), sin(fa))
		var f_perp := Vector2(-f_dir.y, f_dir.x)
		var base_d: float = radius_px * (0.26 + 0.56 * ease_t) * (0.94 if (fi % 2 == 0) else 0.78)
		var f_len: float = (34.0 if (fi == 0 or fi == 5) else 26.0) * (1.0 - 0.30 * t)
		var f_w: float = 11.0 * (1.0 - 0.25 * t)
		var f_base: Vector2 = f_dir * base_d
		var fang_poly := PackedVector2Array([
			f_base + f_dir * f_len,
			f_base + f_perp * f_w,
			f_base - f_dir * (f_len * 0.28),
			f_base - f_perp * f_w
		])
		draw_colored_polygon(fang_poly, Color(mid_color.r, mid_color.g, mid_color.b, 0.78 * fade))
		draw_polyline(fang_poly, Color(core_color.r, core_color.g, core_color.b, 0.95 * fade), 2.0 * fade)

	# 4. Tia chấn động xuyên tâm + Vòng chấn sóng cận thân (95px)
	for i in range(9):
		var ra: float = lerpf(aim_angle - half_cone, aim_angle + half_cone, float(i) / 8.0)
		var d := Vector2(cos(ra), sin(ra))
		draw_line(d * (radius_px * 0.18 * ease_t), d * (radius_px * (0.58 + 0.48 * ease_t)), Color(core_color.r, core_color.g, core_color.b, 0.58 * fade), 2.4 * fade)
	var close_r: float = minf(98.0, radius_px * 0.48) * (0.35 + 0.75 * ease_t)
	draw_arc(Vector2.ZERO, close_r, 0.0, TAU, 36, Color(mid_color.r, mid_color.g, mid_color.b, 0.75 * fade), 4.2 * fade)
	draw_circle(Vector2.ZERO, close_r * 0.52, Color(core_color.r, core_color.g, core_color.b, 0.28 * fade))


func _draw_flame_clone(t: float) -> void:
	# HỎA LIÊN PHÂN THÂN: Vòng xoáy 3 cánh Hỏa Liên phát sáng quay liên tục + dải quỹ đạo bám theo Tiêu Viêm suốt thời gian duy trì!
	var fade_in: float = clampf(elapsed / 0.24, 0.0, 1.0)
	var fade_out: float = clampf((duration - elapsed) / 0.45, 0.0, 1.0)
	var env: float = fade_in * fade_out
	if env <= 0.01:
		return

	var pulse: float = 0.92 + 0.08 * sin(elapsed * 9.0)
	var spin: float = elapsed * 4.4
	var orbit_r: float = clampf(radius_px * 0.56, 56.0, 96.0) * pulse
	var outer_aura_r: float = radius_px * (0.86 + 0.06 * sin(elapsed * 6.5))

	# 1. Vòng hào quang phạm vi thiêu đốt bên ngoài & vòng ấn xoay ngược bên trong
	draw_arc(Vector2.ZERO, outer_aura_r, spin * 0.45, spin * 0.45 + TAU * 0.88, 52, Color(outer_color.r, outer_color.g, outer_color.b, 0.34 * env), 3.4)
	draw_arc(Vector2.ZERO, outer_aura_r * 0.94, -spin * 0.65, -spin * 0.65 + TAU * 0.75, 44, Color(mid_color.r, mid_color.g, mid_color.b, 0.44 * env), 2.0)
	draw_circle(Vector2.ZERO, orbit_r * 0.72, Color(outer_color.r, outer_color.g, outer_color.b, 0.09 * env * pulse))

	# 2. 3 dải quỹ đạo xoáy 3-cánh Hỏa Liên (Trailing Orbital Arcs + Pointed Lotus-Flame Crests)
	for k in range(3):
		var head_a: float = spin + float(k) * (TAU / 3.0)
		var tail_a: float = head_a - 1.55
		_draw_tapered_arc_ribbon(Vector2.ZERO, orbit_r, 20.0 * env, tail_a, head_a, Color(outer_color.r, outer_color.g, outer_color.b, 0.44 * env), 16)
		_draw_tapered_arc_ribbon(Vector2.ZERO, orbit_r * 1.02, 11.5 * env, tail_a + 0.25, head_a, Color(mid_color.r, mid_color.g, mid_color.b, 0.82 * env), 14)
		_draw_tapered_arc_ribbon(Vector2.ZERO, orbit_r * 1.04, 4.8 * env, tail_a + 0.58, head_a, Color(core_color.r, core_color.g, core_color.b, 0.96 * env), 10)

		# Cánh hoa sen lửa 3 mũi tỏa sáng ngay đầu mỗi quỹ đạo
		var orb_pos := Vector2(cos(head_a), sin(head_a)) * orbit_r
		var tang := Vector2(-sin(head_a), cos(head_a))
		var rad_v := Vector2(cos(head_a), sin(head_a))
		var petal_poly := PackedVector2Array([
			orb_pos + tang * 22.0,
			orb_pos + rad_v * 9.5,
			orb_pos - tang * 12.0,
			orb_pos - rad_v * 9.5
		])
		draw_colored_polygon(petal_poly, Color(mid_color.r, mid_color.g, mid_color.b, 0.76 * env))
		draw_circle(orb_pos, 11.0 * env, Color(mid_color.r, mid_color.g, mid_color.b, 0.45 * env))
		draw_circle(orb_pos, 5.2 * env, Color(core_color.r, core_color.g, core_color.b, 0.96 * env))

	# 3. Nhịp gợn sóng kích hoạt mở màn (t < 0.14)
	if t < 0.14:
		var bt: float = clampf(t / 0.14, 0.0, 1.0)
		var bf: float = 1.0 - bt
		draw_arc(Vector2.ZERO, radius_px * (0.28 + 0.85 * _ease_out_expo(bt)), 0.0, TAU, 44, Color(core_color.r, core_color.g, core_color.b, 0.90 * bf), 6.0 * bf)


func _draw_windup_charge(t: float) -> void:
	# TỤ LỰC HỘI TỤ (Cast Tiêu Viêm & Boss Windup): 8 tia linh khí hút mạnh về tâm + vòng ấn thu nhỏ phát sáng!
	var inv_t: float = 1.0 - t
	var fade_in: float = clampf(t * 4.0, 0.0, 1.0)
	var fade_out: float = clampf((1.0 - t) * 4.5, 0.0, 1.0)
	var env: float = fade_in * fade_out
	var spin: float = elapsed * 5.2

	# 1. Vòng ấn hội tụ co dần về lõi
	var ring_r: float = radius_px * (0.28 + 0.78 * inv_t * inv_t)
	draw_arc(Vector2.ZERO, ring_r, spin, spin + TAU * 0.84, 36, Color(mid_color.r, mid_color.g, mid_color.b, 0.78 * env), 3.6)
	draw_arc(Vector2.ZERO, ring_r * 0.74, -spin * 1.4, -spin * 1.4 + TAU * 0.72, 28, Color(core_color.r, core_color.g, core_color.b, 0.65 * env), 2.0)

	# 2. 8 tia linh khí kéo vệt lao thẳng vào tâm
	for i in range(8):
		var a: float = spin * 0.4 + float(i) * (TAU / 8.0)
		var d := Vector2(cos(a), sin(a))
		var outer_d: float = radius_px * (0.25 + 0.92 * inv_t)
		var inner_d: float = maxf(6.0, outer_d - radius_px * (0.34 + 0.22 * t))
		draw_line(d * outer_d, d * inner_d, Color(outer_color.r, outer_color.g, outer_color.b, 0.48 * env), 5.0 * env)
		draw_line(d * lerpf(outer_d, inner_d, 0.25), d * inner_d, Color(core_color.r, core_color.g, core_color.b, 0.92 * env), 2.2 * env)

	# 3. Lõi tích tụ phình sáng lên đỉnh ở cuối pha tụ lực
	var core_r: float = (10.0 + 18.0 * t) * env
	draw_circle(Vector2.ZERO, core_r * 1.55, Color(mid_color.r, mid_color.g, mid_color.b, 0.32 * env))
	draw_circle(Vector2.ZERO, core_r * 0.68, Color(core_color.r, core_color.g, core_color.b, 0.92 * env))


func _draw_boss_strike_arc(t: float) -> void:
	# VỆT CHÉM BOSS 3 TẦNG 60 FPS: Dải lưỡi liềm sắc lẹm + vệt Motion Smear + kim gió theo màu đặc trưng từng Boss!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.65), 0.0, 1.0)
	var span: float = 2.25
	var start_a: float = aim_angle - flip_dir * span * 0.54
	var head_a: float = start_a + flip_dir * span * ease_t
	var tail_lag: float = clampf((t - 0.12) / 0.88, 0.0, 1.0)
	var tail_a: float = lerpf(start_a, head_a, tail_lag * tail_lag)
	var r: float = radius_px * (0.86 + 0.22 * ease_t)
	var thick: float = 30.0 * (1.0 - 0.34 * t)

	_draw_tapered_arc_ribbon(Vector2.ZERO, r * 0.78, thick * 1.85, start_a, head_a, Color(outer_color.r, outer_color.g, outer_color.b, 0.22 * fade), 18)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r, thick * 1.48, tail_a, head_a, Color(outer_color.r, outer_color.g, outer_color.b, 0.52 * fade), 20)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r * 1.03, thick * 0.95, tail_a, head_a, Color(mid_color.r, mid_color.g, mid_color.b, 0.88 * fade), 20)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r * 1.06, thick * 0.38, lerpf(tail_a, head_a, 0.25), head_a, Color(core_color.r, core_color.g, core_color.b, 0.98 * fade), 16)

	var tip_dir := Vector2(cos(head_a), sin(head_a))
	var tip_pos: Vector2 = tip_dir * (r * 1.04)
	draw_circle(tip_pos, 11.5 * fade, Color(core_color.r, core_color.g, core_color.b, 0.88 * fade))


func _draw_tyrant_claw(t: float) -> void:
	# ĐẠI LIỆT PHÁCH QUAN TRẢO (Bá Thương Liễu Kình — Ch.06): 4 vết cào kim quang song song xé rách không gian + sóng phá giáp!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.55), 0.0, 1.0)
	var f_dir := Vector2(cos(aim_angle), sin(aim_angle))
	var perp := Vector2(-f_dir.y, f_dir.x)

	# 1. Vòng xung kích phá khiên vàng kim + vết nứt địa chấn
	var shock_r: float = radius_px * (0.28 + 0.86 * ease_t)
	draw_circle(Vector2.ZERO, shock_r * 0.82, Color(outer_color.r, outer_color.g, outer_color.b, 0.16 * fade))
	draw_arc(Vector2.ZERO, shock_r, 0.0, TAU, 44, Color(mid_color.r, mid_color.g, mid_color.b, 0.82 * fade), 5.5 * fade)
	draw_arc(Vector2.ZERO, shock_r * 0.72, 0.0, TAU, 36, Color(core_color.r, core_color.g, core_color.b, 0.65 * fade), 2.6 * fade)

	for ci in range(_crack_angles.size()):
		var ca: float = _crack_angles[ci]
		var cl: float = _crack_lengths[ci] * clampf(t * 3.0, 0.0, 1.0)
		var cd := Vector2(cos(ca), sin(ca))
		draw_line(cd * 14.0, cd * cl, Color(mid_color.r, mid_color.g, mid_color.b, 0.62 * fade), 2.6 * fade)

	# 2. 4 vết cào móng rồng/bá trảo chéo song song quét tốc độ cao (lệch pha tạo cảm giác xé từng móng!)
	var slash_dir: Vector2 = (f_dir * 0.76 + perp * 0.65).normalized()
	var slash_perp := Vector2(-slash_dir.y, slash_dir.x)
	for claw_i in range(4):
		var ct: float = clampf((t - float(claw_i) * 0.045) / (1.0 - float(claw_i) * 0.045), 0.0, 1.0)
		if ct <= 0.0:
			continue
		var ce: float = _ease_out_expo(ct)
		var cf: float = clampf(1.0 - pow(ct, 1.5), 0.0, 1.0)
		var lane: float = (float(claw_i) - 1.5) * (radius_px * 0.25)
		var len_mult: float = 1.08 if (claw_i == 1 or claw_i == 2) else 0.86
		var half_len: float = radius_px * 0.92 * len_mult
		var p_start: Vector2 = slash_perp * lane - slash_dir * half_len
		var p_end: Vector2 = slash_perp * lane + slash_dir * lerpf(-half_len * 0.35, half_len, ce)
		var mid_p: Vector2 = p_start.lerp(p_end, 0.55) + slash_perp * (10.0 * (1.0 if claw_i % 2 == 0 else -1.0))
		var w_base: float = (18.0 if (claw_i == 1 or claw_i == 2) else 13.0) * cf

		var claw_pts := PackedVector2Array([p_start, mid_p, p_end])
		draw_polyline(claw_pts, Color(outer_color.r, outer_color.g, outer_color.b, 0.55 * cf), w_base * 1.45)
		draw_polyline(claw_pts, Color(mid_color.r, mid_color.g, mid_color.b, 0.92 * cf), w_base * 0.82)
		draw_polyline(claw_pts, Color(core_color.r, core_color.g, core_color.b, 0.98 * cf), w_base * 0.34)
		draw_circle(p_end, 11.0 * cf, Color(core_color.r, core_color.g, core_color.b, 0.92 * cf))


func _draw_glazed_lotus_vortex(t: float) -> void:
	# LƯU LY LIÊN TÂM ẤN (Song Dị Hỏa #19 Thanh Liên + #14 Vẫn Lạc): Xoáy Lưu Ly xanh-tím hút vào tâm -> Nở Liên Hoa 8 Cánh bùng nổ Nội Thiêu!
	var fade: float = clampf(1.0 - pow(t, 1.85), 0.0, 1.0)
	var emerald := Color("#00F5D4")
	var violet := Color("#E0AAFF")
	var white_hot := Color("#FFFFFF")
	var spin: float = elapsed * 6.8

	# 1. Xoáy kép ngược chiều (Thanh Liên Lục & Tâm Viêm Tím) hút địch vào tâm
	var pull_r: float = radius_px * (1.06 - 0.36 * _ease_out_cubic(t))
	draw_circle(Vector2.ZERO, pull_r * 0.85, Color(violet.r, violet.g, violet.b, 0.14 * fade))
	for arm in range(4):
		var col_a: Color = emerald if (arm % 2 == 0) else violet
		var a0: float = spin + float(arm) * (TAU * 0.25)
		_draw_tapered_arc_ribbon(Vector2.ZERO, pull_r * (0.92 if arm % 2 == 0 else 0.72), 20.0 * fade, a0 - 1.35, a0, Color(col_a.r, col_a.g, col_a.b, 0.78 * fade), 18)
		_draw_tapered_arc_ribbon(Vector2.ZERO, pull_r * (0.94 if arm % 2 == 0 else 0.74), 7.5 * fade, a0 - 0.85, a0, Color(white_hot.r, white_hot.g, white_hot.b, 0.92 * fade), 14)

	# 2. Đóa Sen Lưu Ly 8 cánh nở rực ở trung tâm rồi bung sóng Nội Thiêu!
	var bloom_t: float = _ease_out_expo(clampf(t * 1.45, 0.0, 1.0))
	var petal_len: float = radius_px * (0.34 + 0.56 * bloom_t)
	var petal_w: float = radius_px * 0.18 * (1.0 - 0.25 * t)
	for pd in _petal_dirs:
		var idx_p: int = int(pd.get("cidx", 0))
		var ang: float = float(pd.get("ang", 0.0)) - spin * 0.35
		var d := Vector2(cos(ang), sin(ang))
		var prp := Vector2(-d.y, d.x)
		var p_col: Color = emerald if (idx_p % 2 == 0) else violet
		var poly := PackedVector2Array([
			Vector2.ZERO,
			d * (petal_len * 0.45) + prp * petal_w,
			d * petal_len,
			d * (petal_len * 0.45) - prp * petal_w
		])
		draw_colored_polygon(poly, Color(p_col.r, p_col.g, p_col.b, 0.44 * fade))
		draw_polyline(PackedVector2Array([poly[0], poly[1], poly[2], poly[3], poly[0]]), Color(white_hot.r, white_hot.g, white_hot.b, 0.78 * fade), 2.0 * fade)

	# 3. Lõi Tâm Hỏa trắng rực + Sóng chấn động kép bung rộng
	var wave_r: float = radius_px * (0.20 + 0.96 * _ease_out_expo(t))
	draw_arc(Vector2.ZERO, wave_r, 0.0, TAU, 48, Color(emerald.r, emerald.g, emerald.b, 0.82 * fade), 5.0 * fade)
	draw_arc(Vector2.ZERO, wave_r * 0.78, 0.0, TAU, 40, Color(violet.r, violet.g, violet.b, 0.86 * fade), 3.6 * fade)
	draw_circle(Vector2.ZERO, (22.0 + 18.0 * (1.0 - t)) * fade, Color(white_hot.r, white_hot.g, white_hot.b, 0.85 * fade))


func _draw_ocean_seal(t: float) -> void:
	# ĐẾ ẤN QUYẾT — PHIÊN HẢI ẤN (Cổ Tộc Ch.07): Trận Ấn Kim Hoàng giáng xuống kích nổ 3 tầng Sóng Thần Thanh Lam!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.75), 0.0, 1.0)
	var gold := Color("#FFD166")
	var azure := Color("#38BDF8")
	var white_hot := Color("#FFFFFF")

	# 1. Trận Ấn Cổ Tộc hình bát giác xoay nhanh trên mặt đất
	var seal_r: float = radius_px * (0.36 + 0.64 * ease_t)
	draw_circle(Vector2.ZERO, seal_r * 0.85, Color(azure.r, azure.g, azure.b, 0.16 * fade))
	var rot: float = elapsed * 2.4
	var oct_pts := PackedVector2Array()
	for i in range(9):
		var a: float = rot + float(i) * (TAU / 8.0)
		oct_pts.append(Vector2(cos(a), sin(a)) * (seal_r * 0.76))
	draw_polyline(oct_pts, Color(gold.r, gold.g, gold.b, 0.88 * fade), 3.6 * fade)

	# 2. 3 đợt Sóng Thần Thanh-Kim quét ra phía trước (cung trăng khuyết dồn dập)
	for layer in range(3):
		var lt: float = clampf((t - float(layer) * 0.07) / (1.0 - float(layer) * 0.07), 0.0, 1.0)
		if lt <= 0.0:
			continue
		var le: float = _ease_out_expo(lt)
		var lf: float = clampf(1.0 - lt * lt, 0.0, 1.0)
		var wr: float = radius_px * (0.34 + 0.78 * le) * (1.0 - float(layer) * 0.12)
		var col_w: Color = azure if (layer != 1) else gold
		_draw_tapered_arc_ribbon(Vector2.ZERO, wr, (34.0 - float(layer) * 6.0) * lf, aim_angle - 1.45, aim_angle + 1.45, Color(col_w.r, col_w.g, col_w.b, 0.82 * lf), 22)
		_draw_tapered_arc_ribbon(Vector2.ZERO, wr * 1.04, 10.0 * lf, aim_angle - 1.15, aim_angle + 1.15, Color(white_hot.r, white_hot.g, white_hot.b, 0.94 * lf), 16)

	# 3. Đế Ấn Kim Quang chấn nát mặt đất
	draw_arc(Vector2.ZERO, seal_r * 1.04, 0.0, TAU, 48, Color(gold.r, gold.g, gold.b, 0.82 * fade), 5.0 * fade)
	draw_circle(Vector2.ZERO, (28.0 - 12.0 * t) * fade, Color(white_hot.r, white_hot.g, white_hot.b, 0.78 * fade))


func _draw_flame_buff_tier2(t: float) -> void:
	# THIÊN HỎA TAM HUYỀN BIẾN — NHỊ BIẾN (Ch.07): 3 cột Dị Hỏa xoắn ốc bùng thiên (Thanh Liên + Vẫn Lạc + Bạch Cốt)!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.8), 0.0, 1.0)
	var cols: Array = [Color("#00F5D4"), Color("#E0AAFF"), Color("#CAF0F8")]
	var spin: float = elapsed * 8.2

	# Vòng Hỏa Trận tam sắc
	var r: float = radius_px * (0.30 + 0.78 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.75, Color(0.88, 0.56, 1.0, 0.15 * fade))
	for k in range(3):
		var c: Color = cols[k]
		var a0: float = spin + float(k) * (TAU / 3.0)
		_draw_tapered_arc_ribbon(Vector2.ZERO, r * (0.94 - float(k) * 0.14), 22.0 * fade, a0 - 1.55, a0, Color(c.r, c.g, c.b, 0.86 * fade), 18)
		# Cột hỏa bốc thẳng lên trời
		var px: float = cos(a0) * (r * 0.34)
		var p_top := Vector2(px, -radius_px * (0.65 + 0.55 * ease_t))
		var p_bot := Vector2(px, 16.0)
		draw_line(p_bot, p_top, Color(c.r, c.g, c.b, 0.75 * fade), 14.0 * fade)
		draw_line(p_bot, p_top, Color(1.0, 1.0, 1.0, 0.92 * fade), 5.0 * fade)

	draw_arc(Vector2.ZERO, r * 1.05, 0.0, TAU, 48, Color(1.0, 0.86, 0.42, 0.85 * fade), 4.8 * fade)


## Helper VFX 2.0: Vẽ tia sét phân nhánh đa cấp (fractal lightning) có 1–2 nhánh rẽ phụ chân thực.
func _draw_fractal_bolt(p0: Vector2, p1: Vector2, col: Color, core_c: Color, width: float, seed_idx: int, jitter: float = 16.0) -> void:
	var segs: int = 6
	var diff: Vector2 = p1 - p0
	var ln: float = diff.length()
	if ln < 4.0 or col.a <= 0.02:
		return
	var dir: Vector2 = diff / ln
	var perp := Vector2(-dir.y, dir.x)
	var pts := PackedVector2Array([p0])
	var flicker_step: float = floor(elapsed * 22.0) * 1.73
	for s in range(1, segs):
		var u: float = float(s) / float(segs)
		var env: float = sin(u * PI)
		var w_sin: float = sin(float(seed_idx * 17 + s * 31) + flicker_step) * 0.72 + cos(float(seed_idx * 9 - s * 19) + flicker_step * 1.4) * 0.28
		pts.append(p0.lerp(p1, u) + perp * (w_sin * jitter * env))
	pts.append(p1)
	draw_polyline(pts, Color(col.r, col.g, col.b, col.a * 0.42), width * 2.15)
	draw_polyline(pts, col, width)
	draw_polyline(pts, core_c, maxf(1.2, width * 0.42))
	# Nhánh rẽ phụ tại đốt thứ 2 và 4
	if pts.size() >= 5 and jitter >= 8.0:
		for bi in [2, 4]:
			var b_start: Vector2 = pts[bi]
			var side_s: float = 1.0 if ((seed_idx + bi) % 2 == 0) else -1.0
			var b_dir: Vector2 = (dir * 0.75 + perp * (side_s * 0.65)).normalized()
			var b_mid: Vector2 = b_start + b_dir * (ln * 0.16) + perp * (-side_s * jitter * 0.28)
			var b_end: Vector2 = b_start + b_dir * (ln * 0.30)
			draw_polyline(PackedVector2Array([b_start, b_mid, b_end]), Color(col.r, col.g, col.b, col.a * 0.72), maxf(1.4, width * 0.52))
			draw_polyline(PackedVector2Array([b_start, b_mid, b_end]), Color(core_c.r, core_c.g, core_c.b, core_c.a * 0.78), maxf(0.9, width * 0.24))


## Helper VFX 2.0: Vẽ Trận Đồ Cổ Tự đa tầng (vòng kép + vạch ấn triện + sao nội tiếp).
func _draw_ancient_rune_seal(center: Vector2, r: float, spin: float, col: Color, core_c: Color, fade: float, vertices: int = 6) -> void:
	if r <= 4.0 or fade <= 0.02:
		return
	draw_arc(center, r, 0.0, TAU, 48, Color(col.r, col.g, col.b, 0.86 * fade), 3.2 * fade)
	draw_arc(center, r * 0.84, 0.0, TAU, 44, Color(core_c.r, core_c.g, core_c.b, 0.68 * fade), 1.8 * fade)
	# Vạch ấn cổ tự xoay đều trên vành trận đồ
	var tick_cnt: int = vertices * 4
	for ti in range(tick_cnt):
		var ta: float = spin + float(ti) * (TAU / float(tick_cnt))
		var td := Vector2(cos(ta), sin(ta))
		var p_in: Vector2 = center + td * (r * 0.85)
		var p_out: Vector2 = center + td * (r * (0.98 if (ti % 2 == 0) else 0.93))
		draw_line(p_in, p_out, Color(core_c.r, core_c.g, core_c.b, (0.85 if ti % 2 == 0 else 0.50) * fade), (2.2 if ti % 2 == 0 else 1.2) * fade)
	# Ngôi sao đa giác nội tiếp
	var step_v: int = 2 if vertices >= 5 else 1
	var poly_pts := PackedVector2Array()
	for vi in range(vertices + 1):
		var va: float = spin * 1.15 + float((vi * step_v) % vertices) * (TAU / float(vertices))
		poly_pts.append(center + Vector2(cos(va), sin(va)) * (r * 0.82))
	draw_polyline(poly_pts, Color(col.r, col.g, col.b, 0.78 * fade), 2.2 * fade)


func _draw_dia_yeu_khoi_assist(t: float) -> void:
	# ĐỊA YÊU KHÔI LÔI BỘC (VFX 2.0): Cột Thiên Bạc + Trận Cổ Lôi + 8 tia sét phân nhánh đa cấp!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.65), 0.0, 1.0)
	var silver := Color("#E2F1FF")
	var cyan := Color("#48CAE4")

	var r: float = radius_px * (0.28 + 0.88 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.85, Color(cyan.r, cyan.g, cyan.b, 0.16 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.92, elapsed * 2.2, cyan, silver, fade, 6)
	# Cột năng lượng bạc từ trời giáng xuống
	draw_line(Vector2(0, -radius_px * 1.50), Vector2(0, 12.0), Color(cyan.r, cyan.g, cyan.b, 0.58 * fade), 40.0 * fade)
	draw_line(Vector2(0, -radius_px * 1.50), Vector2(0, 12.0), Color(silver.r, silver.g, silver.b, 0.96 * fade), 15.0 * fade)
	for i in range(8):
		var a: float = float(i) * (TAU / 8.0) + elapsed * 1.4
		var p_end := Vector2(cos(a), sin(a)) * (r * 1.06)
		_draw_fractal_bolt(Vector2.ZERO, p_end, Color(cyan.r, cyan.g, cyan.b, 0.90 * fade), Color(1.0, 1.0, 1.0, 0.98 * fade), 3.6 * fade, i + 11, 15.0)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(silver.r, silver.g, silver.b, 0.90 * fade), 5.2 * fade)


func _draw_space_lock(t: float) -> void:
	# KHÔNG GIAN PHONG TỎA (VFX 2.0): Trận Đồ Bát Quái Hư Không co siết + 8 vết nứt gương không gian phân nhánh!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 2.0), 0.0, 1.0)
	var jade := Color("#72EFDD")
	var sky := Color("#48BFE3")
	var r_outer: float = radius_px * (1.14 - 0.18 * ease_t)
	draw_circle(Vector2.ZERO, r_outer * 0.88, Color(sky.r, sky.g, sky.b, 0.14 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r_outer, elapsed * 1.1, jade, Color.WHITE, fade, 8)
	_draw_ancient_rune_seal(Vector2.ZERO, r_outer * 0.62, -elapsed * 1.9, sky, jade, fade * 0.9, 4)
	# Dải không gian cắt ngang dạng cung lửa băng
	_draw_tapered_arc_ribbon(Vector2.ZERO, r_outer * 0.78, 16.0 * fade, elapsed * 3.5, elapsed * 3.5 + 2.1, Color(jade.r, jade.g, jade.b, 0.82 * fade), 20)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r_outer * 0.78, 14.0 * fade, elapsed * 3.5 + PI, elapsed * 3.5 + PI + 2.1, Color(1.0, 1.0, 1.0, 0.86 * fade), 20)
	# 8 đường nứt không gian dạng tia kính vỡ sắc lạnh
	for j in range(8):
		var ca: float = float(j) * (TAU / 8.0) + 0.25
		var p_end := Vector2(cos(ca), sin(ca)) * (r_outer * 1.02)
		_draw_fractal_bolt(Vector2.ZERO, p_end, Color(sky.r, sky.g, sky.b, 0.78 * fade), Color(1.0, 1.0, 1.0, 0.94 * fade), 2.4 * fade, j + 41, 14.0)


func _draw_emperor_five_seals(t: float) -> void:
	# ĐẾ ẤN QUYẾT — NGŨ ẤN HỢP NHẤT: CỔ ĐẾ ẤN (VFX 2.0): Đại Trận Đồ Cổ Tộc + 5 Ấn Triện Xoay Hội Tụ + Sóng Bộc Phá Hoàng Kim!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.75), 0.0, 1.0)
	var gold := Color("#FFD166")
	var crim := Color("#FF595E")
	var r: float = radius_px * (0.24 + 0.86 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.84, Color(crim.r, crim.g, crim.b, 0.16 * fade))
	draw_circle(Vector2.ZERO, r * 0.44, Color(gold.r, gold.g, gold.b, 0.30 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.96, elapsed * 1.6, gold, Color.WHITE, fade, 5)
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.56, -elapsed * 2.4, crim, gold, fade, 5)
	# 5 Đạo Phù Ấn Cổ Tộc xoay hội tụ nối tia năng lượng vào tâm
	for k in range(5):
		var a: float = float(k) * (TAU / 5.0) + elapsed * 3.4
		var p := Vector2(cos(a), sin(a)) * (r * 0.64)
		_draw_ancient_rune_seal(p, 22.0 * (0.7 + 0.35 * fade), -elapsed * 4.5 + float(k), gold, Color.WHITE, fade, 4)
		draw_circle(p, 6.5 * fade, Color(1.0, 1.0, 1.0, 0.95 * fade))
		_draw_fractal_bolt(Vector2.ZERO, p, Color(crim.r, crim.g, crim.b, 0.82 * fade), Color(gold.r, gold.g, gold.b, 0.95 * fade), 2.8 * fade, k + 73, 10.0)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r * 0.88, 22.0 * fade, elapsed * 5.0, elapsed * 5.0 + 2.6, Color(gold.r, gold.g, gold.b, 0.88 * fade), 22)
	_draw_tapered_arc_ribbon(Vector2.ZERO, r * 0.88, 18.0 * fade, elapsed * 5.0 + PI, elapsed * 5.0 + PI + 2.4, Color(crim.r, crim.g, crim.b, 0.84 * fade), 22)
	draw_arc(Vector2.ZERO, r * 1.04, 0.0, TAU, 56, Color(1.0, 0.94, 0.72, 0.92 * fade), 4.6 * fade)


func _draw_flame_buff_tier3(t: float) -> void:
	# THIÊN HỎA TAM HUYỀN BIẾN — TAM BIẾN (VFX 2.0): Đại Trận Tam Hỏa + 3 Cột Lửa Xoắn Ốc + Tia Phóng Điện Thiên Địa!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.75), 0.0, 1.0)
	var cols: Array = [Color("#00F5D4"), Color("#C77DFF"), Color("#FFD166")]
	var spin: float = elapsed * 9.5
	var r: float = radius_px * (0.28 + 0.82 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.78, Color(0.82, 0.52, 1.0, 0.16 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.96, elapsed * 2.5, Color("#FFD166"), Color("#00F5D4"), fade, 6)
	for k in range(3):
		var c: Color = cols[k]
		var a0: float = spin + float(k) * (TAU / 3.0)
		_draw_tapered_arc_ribbon(Vector2.ZERO, r * (0.98 - float(k) * 0.14), 26.0 * fade, a0 - 1.85, a0, Color(c.r, c.g, c.b, 0.92 * fade), 20)
		var px: float = cos(a0) * (r * 0.36)
		var p_top := Vector2(px, -radius_px * (0.90 + 0.68 * ease_t))
		var p_bot := Vector2(px, 18.0)
		draw_line(p_bot, p_top, Color(c.r, c.g, c.b, 0.72 * fade), 22.0 * fade)
		draw_line(p_bot, p_top, Color(1.0, 1.0, 1.0, 0.96 * fade), 7.0 * fade)
		_draw_fractal_bolt(p_bot, p_top, Color(c.r, c.g, c.b, 0.85 * fade), Color(1.0, 1.0, 1.0, 0.96 * fade), 2.6 * fade, k + 91, 14.0)
	draw_arc(Vector2.ZERO, r * 1.08, 0.0, TAU, 52, Color(1.0, 0.86, 0.40, 0.92 * fade), 5.6 * fade)


func _draw_soul_shock_palm(t: float) -> void:
	# HỒN KỸ: KINH HỒN CHƯỞNG (VFX 2.0): Chưởng Ấn Linh Hồn Đa Lớp + Trận Đồ Tâm Linh + 4 Sóng Xung Kích Tinh Thần!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.85), 0.0, 1.0)
	var vio := Color("#E0AAFF")
	var deep := Color("#7B2CBF")
	var r: float = radius_px * (0.22 + 0.86 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.74, Color(deep.r, deep.g, deep.b, 0.18 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.88, -elapsed * 2.8, vio, Color.WHITE, fade * 0.85, 6)
	for ring_i in range(4):
		var rr: float = r * (0.38 + float(ring_i) * 0.22)
		_draw_tapered_arc_ribbon(Vector2.ZERO, rr, (12.0 - float(ring_i) * 2.0) * fade, aim_angle - 1.3, aim_angle + 1.3, Color(vio.r, vio.g, vio.b, (0.90 - float(ring_i) * 0.18) * fade), 18)
	# Bàn tay linh hồn cong mềm phát sáng đa lớp tại tâm
	var palm_dir := Vector2(cos(aim_angle), sin(aim_angle))
	var palm_perp := Vector2(-palm_dir.y, palm_dir.x)
	var palm_sc: float = 0.78 + 0.44 * ease_t
	draw_circle(-palm_dir * 8.0, 26.0 * palm_sc, Color(deep.r, deep.g, deep.b, 0.55 * fade))
	draw_circle(-palm_dir * 6.0, 18.0 * palm_sc, Color(vio.r, vio.g, vio.b, 0.82 * fade))
	draw_circle(-palm_dir * 4.0, 11.0 * palm_sc, Color(1.0, 1.0, 1.0, 0.94 * fade))
	var f_lens: Array = [28.0, 42.0, 48.0, 43.0, 32.0]
	var f_spread: Array = [-0.55, -0.24, 0.0, 0.24, 0.50]
	for fi in range(5):
		var fa: float = aim_angle + float(f_spread[fi])
		var f_dir := Vector2(cos(fa), sin(fa))
		var f_base: Vector2 = palm_perp * (float(fi - 2) * 8.5 * palm_sc)
		var f_tip: Vector2 = f_base + f_dir * (float(f_lens[fi]) * palm_sc)
		draw_line(f_base, f_tip, Color(deep.r, deep.g, deep.b, 0.60 * fade), 10.0 * fade)
		draw_line(f_base, f_tip, Color(vio.r, vio.g, vio.b, 0.90 * fade), 5.6 * fade)
		draw_line(f_base, f_tip, Color(1.0, 1.0, 1.0, 0.96 * fade), 2.2 * fade)
		draw_circle(f_tip, 3.6 * fade, Color(1.0, 1.0, 1.0, 0.92 * fade))


func _draw_thunder_clone(t: float) -> void:
	# TAM THIÊN LÔI HUYỄN THÂN (VFX 2.0): Vòng Lôi Trận + 9 Tia Thiên Lôi Phân Nhánh Đa Cấp!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.7), 0.0, 1.0)
	var l_cols: Array = [Color("#C77DFF"), Color("#FFD166"), Color("#48CAE4")]
	var r: float = radius_px * (0.26 + 0.86 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.68, Color(0.78, 0.49, 1.0, 0.16 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.86, elapsed * 3.2, Color("#C77DFF"), Color("#FFD166"), fade, 6)
	for i in range(9):
		var a: float = float(i) * (TAU / 9.0) + elapsed * 3.4
		var c: Color = l_cols[i % 3]
		var p_end := Vector2(cos(a), sin(a)) * (r * 1.06)
		_draw_fractal_bolt(Vector2.ZERO, p_end, Color(c.r, c.g, c.b, 0.92 * fade), Color(1.0, 1.0, 1.0, 0.98 * fade), 3.4 * fade, i + 109, 17.0)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, Color(1.0, 0.86, 0.40, 0.88 * fade), 4.6 * fade)


func _draw_thien_yeu_khoi_assist(t: float) -> void:
	# CHUẨN THIÊN YÊU KHÔI — NGŨ SẮC THIÊN LÔI (VFX 2.0): Cột Ngũ Sắc Thiên Lôi + Đại Trận Hoàng Kim + 10 Tia Sét Phân Nhánh!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.6), 0.0, 1.0)
	var five_cols: Array = [Color("#FF595E"), Color("#4CC9F0"), Color("#FFFFFF"), Color("#FFD166"), Color("#C77DFF")]
	var r: float = radius_px * (0.26 + 0.94 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.90, Color(1.0, 0.82, 0.36, 0.20 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.95, elapsed * 2.4, Color("#FFD166"), Color("#C77DFF"), fade, 8)
	# Cột Ngũ Sắc từ trời giáng xuống
	draw_line(Vector2(0, -radius_px * 1.75), Vector2(0, 14.0), Color(1.0, 0.82, 0.36, 0.68 * fade), 52.0 * fade)
	draw_line(Vector2(0, -radius_px * 1.75), Vector2(0, 14.0), Color(0.84, 0.56, 1.0, 0.84 * fade), 28.0 * fade)
	draw_line(Vector2(0, -radius_px * 1.75), Vector2(0, 14.0), Color(1.0, 1.0, 1.0, 0.98 * fade), 13.0 * fade)
	for ci in range(5):
		var c5: Color = five_cols[ci]
		var ox: float = (float(ci) - 2.0) * 14.0
		_draw_fractal_bolt(Vector2(ox, -radius_px * 1.65), Vector2(ox * 0.35, 10.0), Color(c5.r, c5.g, c5.b, 0.88 * fade), Color(1.0, 1.0, 1.0, 0.96 * fade), 3.0 * fade, ci + 131, 18.0)
	for i in range(10):
		var a: float = float(i) * (TAU / 10.0) + elapsed * 2.0
		var c: Color = five_cols[i % 5]
		var p_end := Vector2(cos(a), sin(a)) * (r * 1.08)
		_draw_fractal_bolt(Vector2.ZERO, p_end, Color(c.r, c.g, c.b, 0.92 * fade), Color(1.0, 1.0, 1.0, 0.98 * fade), 3.8 * fade, i + 151, 18.0)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 54, Color(1.0, 0.86, 0.40, 0.95 * fade), 6.2 * fade)


func _draw_ground_crater(t: float) -> void:
	# Vết cháy / nứt mặt đất âm ỉ tro lửa sau các đại chiêu (giữ rõ 60% thời gian rồi mờ dần mượt!)
	var fade: float = clampf((1.0 - t) / 0.45, 0.0, 1.0)
	var ember_pulse: float = 0.72 + 0.28 * sin(elapsed * 6.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.56))
	# Lớp cháy sém ngoài
	draw_circle(Vector2.ZERO, radius_px * 0.82, Color(outer_color.r, outer_color.g, outer_color.b, 0.24 * fade))
	draw_circle(Vector2.ZERO, radius_px * 0.46, Color(mid_color.r, mid_color.g, mid_color.b, 0.20 * fade * ember_pulse))
	# 9 vết nứt xuyên tâm phát sáng tàn lửa bên trong
	var n_cracks: int = mini(_crack_angles.size(), 9)
	for i in range(n_cracks):
		var ca: float = _crack_angles[i]
		var cl: float = radius_px * clampf(_crack_lengths[i], 0.55, 1.05)
		var d := Vector2(cos(ca), sin(ca))
		var prp := Vector2(-d.y, d.x)
		var p1: Vector2 = d * (cl * 0.44) + prp * (10.0 if (i % 2 == 0) else -10.0)
		var p2: Vector2 = d * cl
		draw_polyline(PackedVector2Array([Vector2.ZERO, p1, p2]), Color(mid_color.r, mid_color.g, mid_color.b, 0.72 * fade * ember_pulse), 3.4 * fade)
		draw_polyline(PackedVector2Array([Vector2.ZERO, p1, p2]), Color(core_color.r, core_color.g, core_color.b, 0.65 * fade * ember_pulse), 1.4 * fade)
	draw_arc(Vector2.ZERO, radius_px * 0.76, 0.0, TAU, 36, Color(mid_color.r, mid_color.g, mid_color.b, 0.34 * fade), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_dan_lei_pillar(t: float) -> void:
	# CỘT THIÊN LÔI ĐAN LÔI (Ngũ Sắc Đan Lôi đánh thẳng từ bầu trời xuống bản đồ!)
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.55), 0.0, 1.0)
	var r: float = radius_px * (0.22 + 0.90 * ease_t)
	var sky_y: float = -780.0
	# Cột sáng khổng lồ giáng thẳng từ tầng mây
	draw_line(Vector2(0, sky_y), Vector2(0, 12.0), Color(outer_color.r, outer_color.g, outer_color.b, 0.50 * fade), 64.0 * fade)
	draw_line(Vector2(0, sky_y), Vector2(0, 12.0), Color(mid_color.r, mid_color.g, mid_color.b, 0.88 * fade), 32.0 * fade)
	draw_line(Vector2(0, sky_y), Vector2(0, 12.0), Color(1.0, 1.0, 1.0, 0.98 * fade), 13.0 * fade)
	# 3 thân sét phân nhánh đánh dọc cột
	for bi in range(3):
		var ox: float = (float(bi) - 1.0) * 18.0
		_draw_fractal_bolt(Vector2(ox, sky_y), Vector2(ox * 0.25, 10.0), Color(mid_color.r, mid_color.g, mid_color.b, 0.95 * fade), Color(1.0, 1.0, 1.0, 0.98 * fade), 4.2 * fade, bi + 211, 28.0)
	# Trận nổ tại điểm chạm mặt đất
	draw_set_transform(Vector2(0, 8), 0.0, Vector2(1.0, 0.50))
	_draw_ancient_rune_seal(Vector2.ZERO, r, elapsed * 2.8, mid_color, core_color, fade, 6)
	draw_arc(Vector2.ZERO, r * 1.15, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.92 * fade), 5.0 * fade)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_spatial_giant_palm(t: float) -> void:
	# KHÔNG GIAN ĐẠI THỦ ẤN (Đấu Tôn Ch.09): Xoáy không gian bạc-tím + Bàn tay không gian khổng lồ nén tâm + vết nứt không gian!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.75), 0.0, 1.0)
	var r: float = radius_px * (1.15 - 0.35 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.85, Color(0.45, 0.94, 0.87, 0.16 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.96, -elapsed * 3.4, Color("#72EFDD"), Color("#C77DFF"), fade, 8)
	for i in range(6):
		var a: float = float(i) * (TAU / 6.0) + elapsed * 2.2
		var p_out := Vector2(cos(a), sin(a)) * (r * 1.15)
		_draw_fractal_bolt(p_out, Vector2.ZERO, Color(0.45, 0.94, 0.87, 0.88 * fade), Color(1.0, 1.0, 1.0, 0.96 * fade), 3.2 * fade, i + 231, 16.0)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 52, Color(0.85, 0.98, 1.0, 0.94 * fade), 5.8 * fade)
	draw_circle(Vector2.ZERO, 28.0 * (1.0 - 0.35 * t), Color(1.0, 1.0, 1.0, 0.92 * fade))


func _draw_creation_heaven_palm(t: float) -> void:
	# ĐẠI THIÊN TẠO HÓA CHƯỞNG (Thiên Giai Ch.09): Cột kim quang giáng trời + Ấn Tạo Hóa 8 Cánh + Bàn tay Thiên Giai khổng lồ!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.65), 0.0, 1.0)
	var r: float = radius_px * (0.28 + 0.92 * ease_t)
	draw_line(Vector2(0, -radius_px * 1.9), Vector2(0, 14.0), Color(1.0, 0.30, 0.43, 0.55 * fade), 68.0 * fade)
	draw_line(Vector2(0, -radius_px * 1.9), Vector2(0, 14.0), Color(1.0, 0.82, 0.40, 0.88 * fade), 36.0 * fade)
	draw_line(Vector2(0, -radius_px * 1.9), Vector2(0, 14.0), Color(1.0, 1.0, 1.0, 0.98 * fade), 15.0 * fade)
	draw_circle(Vector2.ZERO, r * 0.92, Color(1.0, 0.82, 0.40, 0.22 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r, elapsed * 2.4, Color("#FFD166"), Color("#FF4D6D"), fade, 8)
	for i in range(8):
		var a: float = float(i) * (TAU / 8.0) - elapsed * 1.5
		var d := Vector2(cos(a), sin(a))
		draw_line(d * (r * 0.22), d * (r * 1.15), Color(1.0, 0.82, 0.40, 0.88 * fade), 5.2 * fade)
	draw_arc(Vector2.ZERO, r * 1.08, 0.0, TAU, 56, Color(1.0, 0.96, 0.82, 0.95 * fade), 6.5 * fade)


func _draw_ten_golden_puppets(t: float) -> void:
	# THẬP TUYỆT KIM KHÔI TRẬN (10 Thiên Yêu Khôi Ch.09): 10 Điểm Sao Khôi Lỗi Hoàng Kim kết thành Thập Giác Lôi Trận!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.65), 0.0, 1.0)
	var r: float = radius_px * (0.30 + 0.82 * ease_t)
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.94, elapsed * 2.6, Color("#FFD166"), Color("#C77DFF"), fade, 10)
	var prev_pt := Vector2.ZERO
	for i in range(10):
		var a: float = float(i) * (TAU / 10.0) + elapsed * 1.8
		var pt := Vector2(cos(a), sin(a)) * r
		draw_circle(pt, 9.0 * fade, Color(1.0, 0.88, 0.45, 0.92 * fade))
		draw_circle(pt, 4.5 * fade, Color(1.0, 1.0, 1.0, 0.98 * fade))
		if i > 0:
			_draw_fractal_bolt(prev_pt, pt, Color(1.0, 0.82, 0.40, 0.85 * fade), Color(1.0, 1.0, 1.0, 0.95 * fade), 2.8 * fade, i + 251, 10.0)
		prev_pt = pt
	draw_arc(Vector2.ZERO, r * 1.04, 0.0, TAU, 52, Color(0.84, 0.56, 1.0, 0.82 * fade), 4.2 * fade)


func _draw_xiao_clan_crest(t: float) -> void:
	# TỘC VĂN ĐẤU ĐẾ TIÊU TỘC (Ch.09 Thiên Mộ): Trụ huyết kim quang + Huy hiệu kim cương rực lửa đỏ-vàng bùng nổ!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.6), 0.0, 1.0)
	var r: float = radius_px * (0.28 + 0.90 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.88, Color(1.0, 0.30, 0.43, 0.22 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.92, elapsed * 2.8, Color("#FF4D6D"), Color("#FFD166"), fade, 6)
	var diam := PackedVector2Array([Vector2(0, -r * 0.72), Vector2(r * 0.42, 0), Vector2(0, r * 0.72), Vector2(-r * 0.42, 0)])
	draw_colored_polygon(diam, Color(1.0, 0.82, 0.40, 0.32 * fade))
	draw_polyline(PackedVector2Array([diam[0], diam[1], diam[2], diam[3], diam[0]]), Color(1.0, 0.96, 0.85, 0.96 * fade), 5.0 * fade)
	draw_arc(Vector2.ZERO, r * 1.05, 0.0, TAU, 54, Color(1.0, 0.35, 0.48, 0.94 * fade), 6.0 * fade)


func _draw_ban_thanh_duoc_tran_assist(t: float) -> void:
	# BÁN THÁNH DƯỢC TRẦN — CỐT LINH VẠN LÝ BĂNG PHONG: Cột Băng Hỏa trắng xanh chói lòa + 12 tinh thể băng tỏa toàn sân!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.55), 0.0, 1.0)
	var r: float = radius_px * (0.24 + 0.96 * ease_t)
	draw_line(Vector2(0, -radius_px * 1.85), Vector2(0, 16.0), Color(0.30, 0.79, 0.94, 0.62 * fade), 62.0 * fade)
	draw_line(Vector2(0, -radius_px * 1.85), Vector2(0, 16.0), Color(0.88, 0.98, 1.0, 0.96 * fade), 24.0 * fade)
	draw_circle(Vector2.ZERO, r * 0.94, Color(0.75, 0.96, 1.0, 0.22 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.95, -elapsed * 2.0, Color("#E0FBFC"), Color("#4CC9F0"), fade, 12)
	for i in range(12):
		var a: float = float(i) * (TAU / 12.0) + elapsed * 1.4
		var p_end := Vector2(cos(a), sin(a)) * (r * 1.08)
		_draw_fractal_bolt(Vector2.ZERO, p_end, Color(0.66, 0.90, 0.96, 0.92 * fade), Color(1.0, 1.0, 1.0, 0.98 * fade), 3.6 * fade, i + 271, 14.0)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 58, Color(0.92, 0.99, 1.0, 0.96 * fade), 6.8 * fade)


func _draw_yellow_springs_palm(t: float) -> void:
	# HOÀNG TUYỀN CHỈ & CHƯỞNG (Ch.10): Cột chỉ lực vàng sẫm xuyên giáp + Chưởng Ấn Cửu U hút sinh cơ!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.6), 0.0, 1.0)
	var r: float = radius_px * (0.26 + 0.90 * ease_t)
	var f_dir := Vector2(cos(aim_angle), sin(aim_angle))
	draw_line(-f_dir * (radius_px * 0.65), f_dir * (radius_px * 1.05), Color(0.79, 0.54, 0.02, 0.62 * fade), 44.0 * fade)
	draw_line(-f_dir * (radius_px * 0.65), f_dir * (radius_px * 1.05), Color(0.99, 0.88, 0.28, 0.95 * fade), 16.0 * fade)
	draw_circle(Vector2.ZERO, r * 0.88, Color(0.79, 0.54, 0.02, 0.20 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.94, elapsed * 2.8, Color("#CA8A04"), Color("#FEF08A"), fade, 8)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 54, Color(0.99, 0.88, 0.28, 0.94 * fade), 6.2 * fade)


func _draw_yellow_springs_wrath(t: float) -> void:
	# HOÀNG TUYỀN THIÊN NỘ (Ch.10 Hồn Kỹ Toàn Màn Hình): 4 tầng sóng âm gợn rồng vàng sẫm chấn toái linh hồn!
	for w in range(4):
		var wt: float = clampf((t - float(w) * 0.11) / (1.0 - float(w) * 0.11), 0.0, 1.0)
		if wt <= 0.0 or wt >= 1.0:
			continue
		var we: float = _ease_out_cubic(wt)
		var wf: float = 1.0 - wt * wt
		var br: float = radius_px * (0.16 + 1.04 * we)
		var pts := PackedVector2Array()
		for s in range(57):
			var ang: float = float(s) * TAU / 56.0
			var rip: float = sin(ang * 14.0 + elapsed * 28.0 + float(w) * 1.8) * (9.0 * wf)
			pts.append(Vector2(cos(ang), sin(ang)) * (br + rip))
		draw_polyline(pts, Color(0.95, 0.72, 0.08, 0.92 * wf), (7.5 - float(w) * 1.2) * wf)
		draw_arc(Vector2.ZERO, br * 0.95, 0.0, TAU, 48, Color(1.0, 0.97, 0.76, 0.80 * wf), 2.8 * wf)
	var fade: float = clampf(1.0 - pow(t, 1.5), 0.0, 1.0)
	_draw_ancient_rune_seal(Vector2.ZERO, radius_px * (0.28 + 0.55 * _ease_out_expo(t)), -elapsed * 3.2, Color("#F59E0B"), Color("#FFFFFF"), fade, 10)


func _draw_reincarnation_fire_disc(t: float) -> void:
	# PHẬT NỘ LUÂN HỒI (Ch.10 Tự Sáng Tạo): Đĩa xoáy Thái Cực Đen–Trắng 4 Dị Hỏa cắt đôi không gian!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.7), 0.0, 1.0)
	var r: float = radius_px * (0.34 + 0.78 * ease_t)
	var spin: float = elapsed * 14.0
	draw_circle(Vector2.ZERO, r * 0.92, Color(0.06, 0.05, 0.09, 0.42 * fade))
	draw_arc(Vector2.ZERO, r * 0.92, spin, spin + PI, 32, Color(1.0, 0.98, 0.94, 0.96 * fade), 18.0 * fade)
	draw_arc(Vector2.ZERO, r * 0.92, spin + PI, spin + TAU, 32, Color(0.14, 0.08, 0.24, 0.94 * fade), 18.0 * fade)
	draw_arc(Vector2.ZERO, r * 1.08, spin * 1.3, spin * 1.3 + TAU * 0.85, 48, Color(0.0, 0.96, 0.83, 0.88 * fade), 5.5 * fade)
	draw_arc(Vector2.ZERO, r * 0.62, -spin * 1.6, -spin * 1.6 + TAU * 0.85, 40, Color(1.0, 0.69, 0.80, 0.90 * fade), 4.5 * fade)
	for i in range(6):
		var a: float = spin + float(i) * (TAU / 6.0)
		var d := Vector2(cos(a), sin(a))
		draw_line(d * (r * 0.24), d * (r * 1.18), Color(1.0, 1.0, 1.0, 0.90 * fade) if (i % 2 == 0) else Color(0.62, 0.30, 0.87, 0.86 * fade), 4.0 * fade)


func _draw_purifying_lotus_array(t: float) -> void:
	# TỊNH LIÊN YÊU TRẬN (Ch.10 Yêu Thánh): 12 Cánh Sen Lửa Trắng-Hồng khóa chết toàn chiến trường!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.55), 0.0, 1.0)
	var r: float = radius_px * (0.28 + 0.84 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.92, Color(1.0, 0.94, 0.96, 0.16 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.94, elapsed * 1.8, Color("#FDA4AF"), Color("#FFFFFF"), fade, 12)
	for i in range(12):
		var a: float = float(i) * (TAU / 12.0) + elapsed * 0.85
		var d := Vector2(cos(a), sin(a))
		var p := Vector2(-d.y, d.x)
		var petal := PackedVector2Array([
			d * (r * 0.22),
			d * (r * 0.68) + p * (r * 0.13),
			d * (r * 1.06),
			d * (r * 0.68) - p * (r * 0.13)
		])
		draw_colored_polygon(petal, Color(1.0, 0.80, 0.88, 0.34 * fade) if (i % 2 == 0) else Color(1.0, 0.97, 0.99, 0.36 * fade))
		draw_polyline(PackedVector2Array([petal[0], petal[1], petal[2], petal[3], petal[0]]), Color(1.0, 0.95, 0.97, 0.90 * fade), 2.4 * fade)
	draw_arc(Vector2.ZERO, r * 1.06, 0.0, TAU, 60, Color(1.0, 0.69, 0.80, 0.94 * fade), 6.2 * fade)


func _draw_bac_vuong_tinh_lien_assist(t: float) -> void:
	# [T] BẮC VƯƠNG KIM CƯƠNG PHÁ THIÊN & KIM ĐẾ TỊNH LIÊN HỢP BÍCH: Trụ Kim Lôi + Biển Lửa Vàng-Trắng-Hồng!
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - pow(t, 1.55), 0.0, 1.0)
	var r: float = radius_px * (0.25 + 0.96 * ease_t)
	draw_line(Vector2(0, -radius_px * 1.95), Vector2(0, 18.0), Color(1.0, 0.84, 0.0, 0.66 * fade), 72.0 * fade)
	draw_line(Vector2(0, -radius_px * 1.95), Vector2(0, 18.0), Color(1.0, 0.72, 0.82, 0.88 * fade), 36.0 * fade)
	draw_line(Vector2(0, -radius_px * 1.95), Vector2(0, 18.0), Color(1.0, 1.0, 1.0, 0.98 * fade), 15.0 * fade)
	draw_circle(Vector2.ZERO, r * 0.94, Color(1.0, 0.92, 0.78, 0.22 * fade))
	_draw_ancient_rune_seal(Vector2.ZERO, r * 0.96, elapsed * 2.5, Color("#FFD700"), Color("#FFAFCC"), fade, 12)
	for i in range(12):
		var a: float = float(i) * (TAU / 12.0) - elapsed * 1.8
		var p_end := Vector2(cos(a), sin(a)) * (r * 1.12)
		var bc: Color = Color(1.0, 0.84, 0.0, 0.94 * fade) if (i % 2 == 0) else Color(1.0, 0.69, 0.80, 0.94 * fade)
		_draw_fractal_bolt(Vector2.ZERO, p_end, bc, Color(1.0, 1.0, 1.0, 0.98 * fade), 4.0 * fade, i + 307, 18.0)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 60, Color(1.0, 0.95, 0.86, 0.96 * fade), 7.2 * fade)


func _draw_generic_ring(t: float) -> void:
	var ease_t: float = _ease_out_expo(t)
	var fade: float = clampf(1.0 - t * t, 0.0, 1.0)
	var r: float = radius_px * (0.25 + 0.82 * ease_t)
	draw_circle(Vector2.ZERO, r * 0.8, Color(mid_color.r, mid_color.g, mid_color.b, 0.20 * fade))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 44, Color(core_color.r, core_color.g, core_color.b, 0.92 * fade), 5.5 * fade)
