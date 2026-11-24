extends Area2D
## Thực thể Kỹ năng Đấu Kỹ bay trên bản đồ HD (1280x720):
## - Diễm Phân Phệ Lãng Xích & Phật Nộ Hỏa Liên kích thước hoành tráng kèm Đèn 2D & Hạt Lửa!
## - Hiện thực hóa trọn bộ 28 hiệu ứng đặc biệt (lotus_effect) của 28 loại Hỏa khi dung hợp Phật Nộ Hỏa Liên [F]!

var behavior_mode: String = "flame_wave"
var move_dir: Vector2 = Vector2.RIGHT
var speed_px: float = 480.0
var damage_amount: float = 35.0
var knockback_force: float = 340.0
var realm_pen: float = 0.25
var explosion_radius: float = 210.0
var burn_dps: float = 8.0
var fusion_flames: Array = []

var lifetime: float = 1.4
var elapsed: float = 0.0
var lotus_detonated: bool = false
var target_point: Vector2 = Vector2.ZERO
var hit_enemies: Dictionary = {}

# Hiệu ứng hậu chấn / vùng tồn lưu sau khi Hỏa Liên phát nổ (Thanh Liên dung nham, Hỏa Vân chậm, Vạn Thú 3 nhịp, Thiên thạch, Tia tím)
var post_zone_timer: float = 0.0
var post_tick_accum: float = 0.0
var beast_bites_left: int = 0
var beast_bite_timer: float = 0.0
var sub_bolts: Array = [] # { pos, vel, color, dmg, life, radius, hit_ids }
var chain_arcs: Array = [] # { p1, p2, color, timer }
var active_ring_colors: Array = []

var glow_light: PointLight2D
var trail_particles: CPUParticles2D

@onready var visual_sprite: Sprite2D = $Sprite2D


func configure_skill(
	mode_str: String,
	origin: Vector2,
	aim_target: Vector2,
	dmg: float,
	kb: float,
	r_pen: float,
	rad_px: float,
	spd: float,
	flame_def: Dictionary,
	fused_list: Array = []
) -> void:
	behavior_mode = mode_str
	global_position = origin
	target_point = aim_target
	move_dir = (aim_target - origin).normalized()
	if move_dir == Vector2.ZERO:
		move_dir = Vector2.RIGHT
	damage_amount = dmg
	knockback_force = kb
	realm_pen = r_pen
	explosion_radius = rad_px
	speed_px = spd
	burn_dps = dmg * float(flame_def.get("burn_dps_ratio", 0.15))

	fusion_flames = fused_list.duplicate()
	if behavior_mode == "fire_lotus_ult" and fusion_flames.is_empty():
		fusion_flames = [str(flame_def.get("id", "pham_hoa"))]

	# Các hiệu ứng điều chỉnh ngay từ lúc khởi tạo Hỏa Liên:
	if behavior_mode == "fire_lotus_ult":
		if _has_flame("xich_lang_thu_hoa"):
			explosion_radius *= 1.15
		if _has_flame("di_hoa_01_de_viem"):
			realm_pen = 1.0
		if _has_flame("di_hoa_15_hai_tam"):
			knockback_force *= 1.35
		lifetime = 1.65
		_build_ring_colors(flame_def)
	else:
		lifetime = 0.95
		rotation = move_dir.angle()

	call_deferred("_apply_flame_visuals", flame_def)


func _has_flame(fid: String) -> bool:
	return fusion_flames.has(fid)


func _build_ring_colors(fallback_def: Dictionary) -> void:
	active_ring_colors.clear()
	for fid in fusion_flames:
		var fd: Dictionary = GameDatabase.get_flame_def(str(fid))
		if not fd.is_empty():
			active_ring_colors.append(Color(str(fd.get("mid_hex", "#FF7B00"))))
	if active_ring_colors.is_empty():
		active_ring_colors.append(Color(str(fallback_def.get("mid_hex", "#2EC4B6"))))
	if active_ring_colors.size() == 1:
		active_ring_colors.append(Color(str(fallback_def.get("core_hex", "#FFD166"))))


func _apply_flame_visuals(flame_def: Dictionary) -> void:
	if visual_sprite == null:
		return
	var core_c := Color(str(flame_def.get("core_hex", "#FFF3B0")))
	var mid_c := Color(str(flame_def.get("mid_hex", "#FF7B00")))
	var outer_c := Color(str(flame_def.get("outer_hex", "#9E2A2B")))

	if behavior_mode == "fire_lotus_ult":
		visual_sprite.texture = load("res://assets/sprites/vfx/fire_lotus.png")
		visual_sprite.scale = Vector2(1.8, 1.8)
	else:
		visual_sprite.texture = load("res://assets/sprites/vfx/slash_arc.png")
		visual_sprite.scale = Vector2(2.2, 2.2)

	var shader_res: Shader = load("res://assets/shaders/di_hoa_palette.gdshader")
	var mat := ShaderMaterial.new()
	mat.shader = shader_res
	mat.set_shader_parameter("core_color", core_c)
	mat.set_shader_parameter("mid_color", mid_c)
	mat.set_shader_parameter("outer_color", outer_c)
	mat.set_shader_parameter("intensity", 1.85)
	visual_sprite.material = mat

	glow_light = PointLight2D.new()
	glow_light.texture = load("res://assets/sprites/vfx/light_radial_128.png")
	glow_light.texture_scale = 3.8 if behavior_mode == "fire_lotus_ult" else 2.8
	glow_light.energy = 1.75
	glow_light.color = mid_c.lerp(core_c, 0.35)
	add_child(glow_light)

	trail_particles = CPUParticles2D.new()
	trail_particles.emitting = true
	trail_particles.amount = 32
	trail_particles.lifetime = 0.45
	trail_particles.spread = 180.0
	trail_particles.gravity = Vector2(0, -24)
	trail_particles.initial_velocity_min = 35.0
	trail_particles.initial_velocity_max = 110.0
	trail_particles.scale_amount_min = 3.0
	trail_particles.scale_amount_max = 6.0
	trail_particles.color = core_c.lerp(mid_c, 0.5)
	add_child(trail_particles)


func _physics_process(delta: float) -> void:
	elapsed += delta
	_tick_chain_arcs(delta)
	_tick_sub_bolts(delta)
	queue_redraw()

	if behavior_mode == "flame_wave":
		global_position += move_dir * speed_px * delta
		_check_wave_hits()
		if elapsed >= lifetime:
			queue_free()
	elif behavior_mode == "fire_lotus_ult":
		if not lotus_detonated:
			visual_sprite.rotation += 10.5 * delta
			if global_position.distance_to(target_point) > 16.0 and elapsed < 0.55:
				global_position = global_position.move_toward(target_point, speed_px * delta)
			else:
				_pull_enemies_toward_lotus(delta)
				var pulse: float = 1.9 + sin(elapsed * 26.0) * 0.45
				visual_sprite.scale = Vector2(pulse, pulse)

			if elapsed >= 1.15:
				_detonate_fire_lotus()
		else:
			# Duy trì các vùng hậu chấn sau vụ nổ (Dung nham Thanh Liên 3s / Mây lửa Hỏa Vân 3.5s / Vạn Thú 3 nhịp / Thiên thạch)
			_tick_post_detonation_effects(delta)
			if visual_sprite != null:
				visual_sprite.modulate.a = maxf(0.0, visual_sprite.modulate.a - delta * 2.2)
			if glow_light != null and post_zone_timer <= 0.0:
				glow_light.energy = maxf(0.0, glow_light.energy - delta * 4.0)
			if elapsed >= lifetime and post_zone_timer <= 0.0 and beast_bites_left <= 0 and sub_bolts.is_empty() and chain_arcs.is_empty():
				queue_free()


func _check_wave_hits() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for en in enemies:
		if not is_instance_valid(en):
			continue
		var enemy_node: Node2D = en as Node2D
		if enemy_node == null or hit_enemies.has(enemy_node.get_instance_id()):
			continue
		if global_position.distance_to(enemy_node.global_position) <= explosion_radius:
			hit_enemies[enemy_node.get_instance_id()] = true
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(damage_amount, move_dir * knockback_force, realm_pen, burn_dps)


func _pull_enemies_toward_lotus(delta: float) -> void:
	var pull_rad: float = explosion_radius * 1.25
	var pull_spd: float = 185.0
	if _has_flame("di_hoa_21_am_duong"):
		pull_rad *= 1.45
		pull_spd = 340.0
	if _has_flame("di_hoa_02_hu_vo"):
		pull_rad = maxf(pull_rad, explosion_radius * 2.1)
		pull_spd = maxf(pull_spd, 390.0)

	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for en in enemies:
		if not is_instance_valid(en):
			continue
		var enemy_node: Node2D = en as Node2D
		if enemy_node == null:
			continue
		var dist: float = global_position.distance_to(enemy_node.global_position)
		if dist <= pull_rad and dist > 16.0:
			var pull_dir: Vector2 = (global_position - enemy_node.global_position).normalized()
			enemy_node.global_position += pull_dir * pull_spd * delta


func _detonate_fire_lotus() -> void:
	lotus_detonated = true
	visual_sprite.scale = Vector2(4.4, 4.4)
	if glow_light != null:
		glow_light.texture_scale = 7.2
		glow_light.energy = 2.8
	if trail_particles != null:
		trail_particles.amount = 64
		trail_particles.initial_velocity_max = 280.0
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.audio_sfx_requested.emit("skill_burst")
	EventBus.screen_shake_requested.emit(13.5, 0.42)

	var f_cnt: int = max(1, fusion_flames.size())
	var effect_tags: Array = []

	# === 1. HIỆU ỨNG TÁC ĐỘNG LÊN TIÊU VIÊM (KHIÊN / HỒI PHỤC / GIẢM SÁT THƯƠNG / X2 DƯỢC) ===
	var player_pos: Vector2 = global_position
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is Node2D:
		player_pos = (players[0] as Node2D).global_position

	if _has_flame("di_hoa_23_huyen_hoang"):
		var sh_val: float = PlayerData.get_max_hp() * 0.15
		PlayerData.lotus_shield_hp = maxf(PlayerData.lotus_shield_hp, sh_val)
		effect_tags.append("Khiên Huyền Hoàng")
		EventBus.floating_text_requested.emit(player_pos + Vector2(0, -82), "+%d Khiên Đất!" % int(round(sh_val)), Color("#D4A373"))

	if _has_flame("di_hoa_13_quy_linh"):
		PlayerData.lotus_dmg_red_timer = 4.0
		effect_tags.append("Quy Linh -30% DMG")

	if _has_flame("di_hoa_09_tam_thien"):
		var heal_tt: float = PlayerData.get_max_hp() * 0.12 * PlayerData.get_heal_effectiveness_mult()
		PlayerData.current_hp = minf(PlayerData.get_max_hp(), PlayerData.current_hp + heal_tt)
		effect_tags.append("Tam Thiên Hồi HP")
		EventBus.floating_text_requested.emit(player_pos + Vector2(0, -64), "+%d HP Tinh Không" % int(round(heal_tt)), Color("#F72585"))

	if _has_flame("di_hoa_05_sinh_linh"):
		PlayerData.current_hp = PlayerData.get_max_hp()
		PlayerData.lotus_double_herb_timer = 15.0
		effect_tags.append("Sinh Linh Đầy HP & x2 Dược")
		EventBus.floating_text_requested.emit(player_pos + Vector2(0, -96), "SINH LINH HỒI ĐẦY HP & x2 DƯỢC!", Color("#51CF66"))

	if _has_flame("di_hoa_02_hu_vo"):
		var hv_hp: float = PlayerData.get_max_hp() * 0.15
		var hv_qi: float = PlayerData.get_max_qi() * 0.25
		PlayerData.current_hp = minf(PlayerData.get_max_hp(), PlayerData.current_hp + hv_hp)
		PlayerData.current_qi = minf(PlayerData.get_max_qi(), PlayerData.current_qi + hv_qi)
		effect_tags.append("Hắc Động Hút HP/QI")

	EventBus.stats_changed.emit()

	# === 2. TÍNH TOÁN SÁT THƯƠNG, BỎ QUA GIÁP, XUYÊN ÁP CHẾ & CHÍ MẠNG THEO 28 NGỌN HỎA ===
	var final_dmg: float = damage_amount
	var ignore_def: float = 0.0
	var crit_mult_override: float = 1.0
	var final_burn: float = burn_dps * 1.5
	var final_pen: float = realm_pen

	if _has_flame("pham_hoa"):
		final_burn *= 1.18
	if _has_flame("di_hoa_10_cuu_u_phong"):
		final_dmg += float(PlayerData.get_soul()) * 1.8
		effect_tags.append("Hồn Phong")
	if _has_flame("di_hoa_08_hong_lien"):
		var kill_bonus: float = minf(0.65, float(PlayerData.enemies_killed_total) * 0.015)
		final_dmg *= (1.0 + kill_bonus)
		effect_tags.append("Nghiệp Hỏa +%d%%" % int(round(kill_bonus * 100.0)))
	if _has_flame("di_hoa_14_van_lac"):
		ignore_def = maxf(ignore_def, 0.40)
		effect_tags.append("Xuyên 40% DEF")
	if _has_flame("di_hoa_04_kim_de"):
		final_dmg *= 1.32
		ignore_def = maxf(ignore_def, 0.65)
		effect_tags.append("Kim Đế Đốt Khí")
	if _has_flame("di_hoa_03_tinh_lien"):
		ignore_def = 1.0
		effect_tags.append("Tịnh Hóa Chuẩn")
	if _has_flame("di_hoa_06_bat_hoang"):
		crit_mult_override = 2.0
		effect_tags.append("Bát Hoang x2 Crit")
	if _has_flame("di_hoa_01_de_viem"):
		final_pen = 1.0
		final_dmg *= 1.25
		effect_tags.append("Đế Viêm 100% Xuyên")

	var lotus_cry: String = "PHẬT NỘ HỎA LIÊN (%d HỎA)!" % f_cnt if f_cnt >= 2 else "PHẬT NỘ HỎA LIÊN!"
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -56), lotus_cry, Color("#FFD166"))
	if not effect_tags.is_empty():
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -84), "✦ " + " · ".join(effect_tags.slice(0, 3)), Color("#72EFDD"))

	# === 3. TÁC ĐỘNG LÊN TOÀN BỘ KẺ ĐỊCH TRONG VÙNG NỔ ===
	var hit_list: Array = []
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for en in enemies:
		if not is_instance_valid(en):
			continue
		var enemy_node: Node2D = en as Node2D
		if enemy_node == null:
			continue
		if global_position.distance_to(enemy_node.global_position) <= explosion_radius:
			hit_list.append(enemy_node)
			var out_dir: Vector2 = (enemy_node.global_position - global_position).normalized()
			if out_dir == Vector2.ZERO:
				out_dir = Vector2.RIGHT

			# Phá khiên / Tịnh hóa buff Boss (#7 Cửu U Kim Tổ Hỏa & #3 Tịnh Liên Yêu Hỏa)
			if (_has_flame("di_hoa_07_cuu_u_kim_to") or _has_flame("di_hoa_03_tinh_lien")) and enemy_node.has_method("break_boss_shield"):
				enemy_node.break_boss_shield()
			# Ăn mòn phòng ngự (Cửu U Minh Hỏa -15% DEF, #15 Hải Tâm Diễm -25% DEF)
			if _has_flame("cuu_u_minh_hoa") and enemy_node.has_method("apply_def_shred"):
				enemy_node.apply_def_shred(0.15, 5.5)
			if _has_flame("di_hoa_15_hai_tam") and enemy_node.has_method("apply_def_shred"):
				enemy_node.apply_def_shred(0.25, 5.5)
			# Làm chậm (#11 Cốt Linh Lãnh Hỏa -50%, #16 Hỏa Vân Thủy Viêm -40%)
			if _has_flame("di_hoa_11_cot_linh") and enemy_node.has_method("apply_slow"):
				enemy_node.apply_slow(0.50, 4.5)
			elif _has_flame("di_hoa_16_hoa_van") and enemy_node.has_method("apply_slow"):
				enemy_node.apply_slow(0.40, 4.5)
			# Tê liệt / Làm choáng (#12 Cửu Long Lôi Cương 2.0s, #18 Phong Lôi 1.2s)
			if _has_flame("di_hoa_12_cuu_long") and enemy_node.has_method("apply_stun"):
				enemy_node.apply_stun(2.0)
			elif _has_flame("di_hoa_18_phong_loi") and enemy_node.has_method("apply_stun"):
				enemy_node.apply_stun(1.2)
			# Đánh dấu sương độc nổ dây chuyền khi chết (#20 U Minh Độc Hỏa)
			if _has_flame("di_hoa_20_u_minh_doc") and enemy_node.has_method("apply_poison_detonate"):
				enemy_node.apply_poison_detonate(final_dmg * 0.55, 6.0)

			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(final_dmg, out_dir * knockback_force, final_pen, final_burn, ignore_def, crit_mult_override)

	# === 4. HIỆU ỨNG PHỤ BẮN LAN / HẬU CHẤN ===
	# Tử Tinh Thú Hỏa: phóng tia lửa tím nảy lan 3 mục tiêu gần nhất!
	if _has_flame("tu_tinh_thu_hoa"):
		_trigger_purple_chain_bounce(final_dmg * 0.42)

	# #17 Hỏa Sơn Thạch Diễm: bắn văng 6 mảnh thiên thạch nham thạch xung quanh!
	if _has_flame("di_hoa_17_hoa_son"):
		for mi in range(6):
			var ang: float = float(mi) * (TAU / 6.0) + randf_range(-0.12, 0.12)
			sub_bolts.append({
				"pos": global_position,
				"vel": Vector2(cos(ang), sin(ang)) * 340.0,
				"color": Color("#E29578"),
				"dmg": final_dmg * 0.36,
				"life": 0.72,
				"radius": 28.0,
				"hit_ids": {}
			})

	# #22 Vạn Thú Linh Hỏa: hóa hình bầy thú lửa cắn xé thêm 3 nhịp!
	if _has_flame("di_hoa_22_van_thu"):
		beast_bites_left = 3
		beast_bite_timer = 0.42

	# #19 Thanh Liên Địa Tâm Hỏa (vũng dung nham 3s) & #16 Hỏa Vân Thủy Viêm (thảm mây lửa làm chậm 3.5s)
	if _has_flame("di_hoa_19_thanh_lien") or _has_flame("di_hoa_16_hoa_van"):
		post_zone_timer = 3.5 if _has_flame("di_hoa_16_hoa_van") else 3.0
		post_tick_accum = 0.0


func _trigger_purple_chain_bounce(chain_dmg: float) -> void:
	var candidates: Array = []
	for en in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(en) and en is Node2D:
			var d: float = global_position.distance_to((en as Node2D).global_position)
			if d <= explosion_radius * 2.1:
				candidates.append({ "node": en as Node2D, "dist": d })
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["dist"]) < float(b["dist"]))
	var prev_p: Vector2 = global_position
	var count_b: int = mini(3, candidates.size())
	for i in range(count_b):
		var nd: Node2D = candidates[i]["node"] as Node2D
		if nd != null and is_instance_valid(nd):
			chain_arcs.append({ "p1": prev_p, "p2": nd.global_position + Vector2(0, -24), "color": Color("#C77DFF"), "timer": 0.38 })
			if nd.has_method("receive_hit"):
				nd.receive_hit(chain_dmg, (nd.global_position - prev_p).normalized() * 140.0, realm_pen, burn_dps * 0.5)
			prev_p = nd.global_position + Vector2(0, -24)


func _tick_post_detonation_effects(delta: float) -> void:
	if post_zone_timer > 0.0:
		post_zone_timer -= delta
		post_tick_accum += delta
		if post_tick_accum >= 0.55:
			post_tick_accum = 0.0
			var zone_r: float = explosion_radius * 0.88
			for en in get_tree().get_nodes_in_group("enemies"):
				if not is_instance_valid(en) or not (en is Node2D):
					continue
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= zone_r:
					if _has_flame("di_hoa_16_hoa_van") and enemy_node.has_method("apply_slow"):
						enemy_node.apply_slow(0.40, 1.2)
					if _has_flame("di_hoa_19_thanh_lien") and enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(damage_amount * 0.22, Vector2.ZERO, realm_pen, burn_dps * 0.4)

	if beast_bites_left > 0:
		beast_bite_timer -= delta
		if beast_bite_timer <= 0.0:
			beast_bites_left -= 1
			beast_bite_timer = 0.42
			EventBus.audio_sfx_requested.emit("hit_impact")
			for en in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(en) and en is Node2D:
					var enemy_node: Node2D = en as Node2D
					if global_position.distance_to(enemy_node.global_position) <= explosion_radius * 1.1:
						chain_arcs.append({
							"p1": global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40)),
							"p2": enemy_node.global_position + Vector2(0, -24),
							"color": Color("#FF4D6D"),
							"timer": 0.24
						})
						if enemy_node.has_method("receive_hit"):
							enemy_node.receive_hit(damage_amount * 0.28, Vector2.ZERO, realm_pen, burn_dps * 0.3)


func _tick_sub_bolts(delta: float) -> void:
	var kept: Array = []
	for sb in sub_bolts:
		sb["life"] = float(sb["life"]) - delta
		if float(sb["life"]) <= 0.0:
			continue
		var cur_p: Vector2 = sb["pos"] as Vector2
		cur_p += (sb["vel"] as Vector2) * delta
		sb["pos"] = cur_p
		var h_map: Dictionary = sb["hit_ids"]
		var rad: float = float(sb["radius"])
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var end2: Node2D = en as Node2D
				var eid: int = end2.get_instance_id()
				if not h_map.has(eid) and cur_p.distance_to(end2.global_position) <= rad + 18.0:
					h_map[eid] = true
					if end2.has_method("receive_hit"):
						end2.receive_hit(float(sb["dmg"]), (sb["vel"] as Vector2).normalized() * 190.0, realm_pen, burn_dps * 0.3)
		kept.append(sb)
	sub_bolts = kept


func _tick_chain_arcs(delta: float) -> void:
	var kept: Array = []
	for ca in chain_arcs:
		ca["timer"] = float(ca["timer"]) - delta
		if float(ca["timer"]) > 0.0:
			kept.append(ca)
	chain_arcs = kept


func _draw() -> void:
	if behavior_mode == "fire_lotus_ult":
		var ring_cols: Array = active_ring_colors if not active_ring_colors.is_empty() else [Color("#2EC4B6"), Color("#9D4EDD")]
		var c1: Color = ring_cols[0] as Color
		var c2: Color = ring_cols[1 % ring_cols.size()] as Color

		# Vẽ vũng dung nham Thanh Liên (#19) / thảm mây lửa Hỏa Vân (#16) đang cháy trên mặt đất!
		if lotus_detonated and post_zone_timer > 0.0:
			var z_a: float = clampf(post_zone_timer / 3.0, 0.15, 0.72)
			var z_rad: float = explosion_radius * 0.88
			var pool_col: Color = Color("#2EC4B6") if _has_flame("di_hoa_19_thanh_lien") else Color("#FF6B6B")
			draw_circle(Vector2.ZERO, z_rad, Color(pool_col.r, pool_col.g, pool_col.b, 0.18 * z_a))
			draw_arc(Vector2.ZERO, z_rad, elapsed * 1.8, elapsed * 1.8 + TAU * 0.88, 48, Color(pool_col.r, pool_col.g, pool_col.b, 0.72 * z_a), 3.6)
			draw_arc(Vector2.ZERO, z_rad * 0.56, -elapsed * 2.5, -elapsed * 2.5 + TAU * 0.80, 36, Color(0.88, 1.0, 0.92, 0.52 * z_a), 2.2)

		# Vẽ đủ tới 4 vòng lửa đồng tâm theo số Hỏa dung hợp (2–4 Hỏa)!
		if not lotus_detonated or elapsed < 1.55:
			var alpha_v: float = 0.55 if not lotus_detonated else clampf((1.55 - elapsed) * 2.4, 0.0, 0.92)
			var radii_mults: Array = [1.0, 0.76, 0.56, 0.38]
			for idx in range(mini(4, ring_cols.size())):
				var rc: Color = ring_cols[idx] as Color
				var dir_s: float = 1.0 if (idx % 2 == 0) else -1.0
				var ang0: float = dir_s * elapsed * (3.0 + float(idx) * 1.1)
				draw_arc(Vector2.ZERO, explosion_radius * float(radii_mults[idx]), ang0, ang0 + TAU * 0.84, 48, Color(rc.r, rc.g, rc.b, alpha_v), 4.0 - float(idx) * 0.45)

			# 8 cánh sen lửa mang màu xoay vòng của toàn bộ các ngọn Hỏa dung hợp!
			var petal_r: float = explosion_radius * (0.42 if not lotus_detonated else 0.88)
			for k in range(8):
				var ang: float = elapsed * 5.2 + float(k) * (TAU / 8.0)
				var p_pos: Vector2 = Vector2(cos(ang), sin(ang)) * petal_r
				var pc: Color = ring_cols[k % ring_cols.size()] as Color
				draw_circle(p_pos, 14.0 if not lotus_detonated else 28.0, Color(pc.r, pc.g, pc.b, 0.42 * alpha_v))
				draw_circle(p_pos, 7.0 if not lotus_detonated else 14.0, Color(1.0, 0.96, 0.85, 0.78 * alpha_v))

			if lotus_detonated:
				draw_circle(Vector2.ZERO, explosion_radius * 0.92, Color(c1.r, c1.g, c1.b, 0.20 * alpha_v))
				draw_circle(Vector2.ZERO, explosion_radius * 0.50, Color(c2.r, c2.g, c2.b, 0.28 * alpha_v))

	# Vẽ 6 thiên thạch nham thạch (#17 Hỏa Sơn Thạch Diễm)
	for sb in sub_bolts:
		var lp: Vector2 = (sb["pos"] as Vector2) - global_position
		var sc: Color = sb["color"] as Color
		draw_circle(lp, 12.0, Color(sc.r, sc.g, sc.b, 0.48))
		draw_circle(lp, 7.0, sc)
		draw_circle(lp, 3.5, Color("#FFF3B0"))

	# Vẽ tia lửa tím nảy lan (Tử Hỏa) & vết cắn bầy thú lửa (#22 Vạn Thú)
	for ca in chain_arcs:
		var p1: Vector2 = (ca["p1"] as Vector2) - global_position
		var p2: Vector2 = (ca["p2"] as Vector2) - global_position
		var cc: Color = ca["color"] as Color
		var mid: Vector2 = (p1 + p2) * 0.5 + Vector2(randf_range(-12, 12), randf_range(-12, 12))
		draw_polyline(PackedVector2Array([p1, mid, p2]), Color(cc.r, cc.g, cc.b, 0.92), 4.0)
		draw_polyline(PackedVector2Array([p1, mid, p2]), Color(1.0, 0.96, 0.90, 0.85), 1.8)
