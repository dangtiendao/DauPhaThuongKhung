class_name ThienPhanTowerManager
extends RefCounted
## Quản lý Phó bản Roguelite Thiên Phần Luyện Khí Tháp (tách từ WorldStageManager):
## - Leo tầng vô tận, Tâm Hỏa chước đốt (giảm 45% khi vận Dị Hỏa), tầng Boss mỗi 3 tầng, chọn 1/3 Chúc Phúc & đổi Tinh Hỏa Năng.

var world: Node2D
var is_active: bool = false
var tower_floor: int = 1
var enemies_alive: Array = []
var total_wave: int = 0
var heat_dps: float = 0.0
var heat_accum: float = 0.0
var heat_text_accum: float = 0.0
var return_map: String = ""
var return_pos: Vector2 = Vector2.ZERO
var waiting_blessing: bool = false
var _session_token: int = 0
var sign_lbl: Label = null


func _init(stage_ref: Node2D) -> void:
	world = stage_ref


func reset_state(emit_clear: bool = true) -> void:
	is_active = false
	waiting_blessing = false
	enemies_alive.clear()
	total_wave = 0
	heat_dps = 0.0
	heat_accum = 0.0
	heat_text_accum = 0.0
	sign_lbl = null
	_session_token += 1
	PlayerData.clear_tower_buffs()
	if emit_clear:
		EventBus.tower_state_updated.emit(0, 0, 0, 0.0, false)


func tick(delta: float) -> void:
	if not is_active or waiting_blessing or enemies_alive.is_empty():
		return
	prune_enemies()
	if not is_active or waiting_blessing or enemies_alive.is_empty():
		return
	heat_accum += delta
	if heat_accum >= 1.0:
		heat_accum -= 1.0
		heat_text_accum += 1.0
		if heat_dps > 0.0 and PlayerData.current_hp > 1.0:
			var actual_loss: float = minf(heat_dps, PlayerData.current_hp - 1.0)
			if actual_loss > 0.0:
				PlayerData.current_hp = maxf(1.0, PlayerData.current_hp - actual_loss)
				EventBus.stats_changed.emit()
				if heat_text_accum >= 3.0 and world.player_node != null:
					heat_text_accum = 0.0
					EventBus.floating_text_requested.emit(
						world.player_node.global_position + Vector2(0, -58),
						"Tâm Hỏa -%d" % maxi(1, int(round(actual_loss))),
						Color("#FF6B6B")
					)


static func get_blessing_pool() -> Array:
	return [
		{
			"id": "tower_atk",
			"name": "Phần Thiên Viêm Ý",
			"title": "Phần Thiên Viêm Ý",
			"tag": "+25% ATK",
			"desc": "Vẫn Lạc Tâm Viêm rèn Đấu Khí: +25% Công Kích (ATK) trong suốt lượt leo Tháp!",
			"color_hex": "#FF6B00",
			"color": "#FF6B00",
			"icon": "res://assets/sprites/icons/skill_phe_lang_xich.png",
			"stat_key": "atk_pct",
			"value": 25.0,
			"stat_key2": "",
			"value2": 0.0,
			"heal_ratio": 0.0
		},
		{
			"id": "tower_hp",
			"name": "Thanh Liên Hộ Tâm",
			"title": "Thanh Liên Hộ Tâm",
			"tag": "+22% HP · Hồi 45%",
			"desc": "Thanh Liên khí tức ôn dưỡng kinh mạch: +22% Sinh Lực Tối Đa (HP) & hồi ngay 45% HP/QI!",
			"color_hex": "#52B788",
			"color": "#52B788",
			"icon": "res://assets/sprites/icons/pill_hp_red.png",
			"stat_key": "hp_pct",
			"value": 22.0,
			"stat_key2": "",
			"value2": 0.0,
			"heal_ratio": 0.45
		},
		{
			"id": "tower_haste",
			"name": "Tam Thiên Lôi Ảnh",
			"title": "Tam Thiên Lôi Ảnh",
			"tag": "-15% CD · +15% SPD",
			"desc": "Thân pháp lôi đình xuất thần nhập hóa: -15% Hồi Chiêu Đấu Kỹ & +15% Tốc Độ Di Chuyển!",
			"color_hex": "#38BDF8",
			"color": "#38BDF8",
			"icon": "res://assets/sprites/icons/skill_tu_van_duc.png",
			"stat_key": "cd_red_pct",
			"value": 15.0,
			"stat_key2": "spd_pct",
			"value2": 15.0,
			"heal_ratio": 0.0
		},
		{
			"id": "tower_poise_crit",
			"name": "Bát Cực Phá Thế",
			"title": "Bát Cực Phá Thế",
			"tag": "+35% Phá Thế · +12% Crit",
			"desc": "Ám kình xuyên giáp vỡ hộ thuẫn: +35% Phá Thế Boss & +12% Tỷ lệ Chí Mạng!",
			"color_hex": "#FFD166",
			"color": "#FFD166",
			"icon": "res://assets/sprites/icons/skill_bat_cuc_bang.png",
			"stat_key": "poise_pct",
			"value": 35.0,
			"stat_key2": "crit_pct",
			"value2": 12.0,
			"heal_ratio": 0.0
		},
		{
			"id": "tower_lifesteal",
			"name": "Huyết Ma Hấp Tinh",
			"title": "Huyết Ma Hấp Tinh",
			"tag": "+7% Hút Máu",
			"desc": "Thôn phệ tinh huyết địch thủ chống lại Tâm Hỏa: +7% Hút Máu mọi đòn đánh & kỹ năng!",
			"color_hex": "#EF476F",
			"color": "#EF476F",
			"icon": "res://assets/sprites/icons/skill_hap_chuong.png",
			"stat_key": "lifesteal_pct",
			"value": 7.0,
			"stat_key2": "",
			"value2": 0.0,
			"heal_ratio": 0.0
		},
		{
			"id": "tower_def",
			"name": "Huyền Trọng Bất Hoại",
			"title": "Huyền Trọng Bất Hoại",
			"tag": "+30% DEF · Hồi 35%",
			"desc": "Đấu Khí Khải Giáp ngưng thực kiên cố: +30% Phòng Ngự (DEF) & hồi ngay 35% HP/QI!",
			"color_hex": "#C77DFF",
			"color": "#C77DFF",
			"icon": "res://assets/sprites/icons/icon_armor.png",
			"stat_key": "def_pct",
			"value": 30.0,
			"stat_key2": "",
			"value2": 0.0,
			"heal_ratio": 0.35
		}
	]


func start_tower(start_floor: int = 1) -> void:
	if world.boss_rush_mgr != null and world.boss_rush_mgr.is_active:
		var saved_br_map: String = world.boss_rush_mgr.return_map
		var saved_br_pos: Vector2 = world.boss_rush_mgr.return_pos
		world.boss_rush_mgr.reset_state()
		return_map = saved_br_map if (saved_br_map != "" and saved_br_map != "tam_ma_luyen_canh") else GameDatabase.start_map_id
		return_pos = saved_br_pos if saved_br_pos != Vector2.ZERO else Vector2(340.0, 520.0)
	elif not is_active and world.current_map_id != "thien_phan_thap":
		return_map = world.current_map_id if world.current_map_id != "" else GameDatabase.start_map_id
		return_pos = world.player_node.global_position if world.player_node != null else Vector2(340.0, 520.0)

	PlayerData.clear_tower_buffs()
	_session_token += 1
	is_active = true
	tower_floor = maxi(1, start_floor)
	enemies_alive.clear()
	total_wave = 0
	heat_dps = 0.0
	heat_accum = 0.0
	heat_text_accum = 0.0
	waiting_blessing = false
	sign_lbl = null

	var arena_def: Dictionary = {
		"id": "thien_phan_thap",
		"name": "Thiên Phần Luyện Khí Tháp",
		"bgm": "bgm_lava",
		"size": [1280, 896],
		"ambient_hex": "#ffb899",
		"base_tile": "res://assets/sprites/tiles/volcanic_basalt.png",
		"zones": [
			{
				"rect": [192, 128, 896, 640],
				"tile": "res://assets/sprites/tiles/arena_violet.png",
				"border_hex": "#FF6B00",
				"arena_circle": true
			}
		],
		"signs": [
			{
				"pos": [420, 78],
				"text": "THIÊN PHẦN LUYỆN KHÍ THÁP — TẦNG %d" % tower_floor,
				"color": "#FFD166"
			}
		],
		"props": [
			{ "type": "lantern", "pos": [140, 160] },
			{ "type": "lantern", "pos": [1140, 160] },
			{ "type": "lantern", "pos": [140, 760] },
			{ "type": "lantern", "pos": [1140, 760] }
		],
		"chests": [],
		"portals": [],
		"npcs": [],
		"spawns": []
	}

	world.setup_arena_stage(arena_def, Vector2(340.0, 448.0))

	# Tìm lại Label bảng hiệu Tháp để cập nhật số tầng khi leo tiếp
	for ch in world.map_overlay_root.get_children():
		if ch is Label and (ch as Label).text.find("THIÊN PHẦN LUYỆN KHÍ THÁP") != -1:
			sign_lbl = ch as Label
			break

	EventBus.audio_sfx_requested.emit("portal_warp")
	EventBus.bgm_requested.emit("bgm_lava")
	EventBus.map_changed.emit("thien_phan_thap", "Thiên Phần Luyện Khí Tháp — Tầng %d" % tower_floor)
	EventBus.banter_triggered.emit("THIÊN PHẦN LUYỆN KHÍ THÁP TẦNG %d: Vẫn Lạc Tâm Viêm rèn thể! Quét sạch địch từng tầng để chọn Chúc Phúc Roguelite & thu Tinh Hỏa Năng!" % tower_floor)

	_spawn_floor(tower_floor)
	world.queue_redraw()


func _get_boss_pool() -> Array:
	var bosses: Array = []
	for eid in GameDatabase.enemies_by_id.keys():
		var edef: Dictionary = GameDatabase.enemies_by_id[eid]
		if edef is Dictionary and bool(edef.get("is_boss", false)):
			bosses.append({
				"id": str(eid),
				"realm": int(edef.get("realm_index", 1)),
				"hp": float(edef.get("max_hp", 500.0))
			})
	bosses.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["realm"]) != int(b["realm"]):
			return int(a["realm"]) < int(b["realm"])
		return float(a["hp"]) < float(b["hp"])
	)
	var out: Array = []
	for b in bosses:
		out.append(str(b["id"]))
	if out.is_empty():
		out.append("tieu_ninh_boss")
	return out


func _get_mob_pools() -> Dictionary:
	var special_types: Array = ["burrower", "artillery", "shieldbearer", "bomber"]
	var special_mobs: Array = []
	var standard_mobs: Array = []
	var max_realm_cap: int = clampi(PlayerData.realm_index + 2, 2, 12)

	for eid in GameDatabase.enemies_by_id.keys():
		var edef: Dictionary = GameDatabase.enemies_by_id[eid]
		if not (edef is Dictionary):
			continue
		if bool(edef.get("is_boss", false)):
			continue
		var ai_t: String = str(edef.get("ai_type", "chaser"))
		if ai_t == "dummy":
			continue
		var r_idx: int = int(edef.get("realm_index", 1))
		if special_types.has(ai_t):
			special_mobs.append(str(eid))
		elif r_idx <= max_realm_cap:
			standard_mobs.append(str(eid))

	if standard_mobs.is_empty():
		for eid in GameDatabase.enemies_by_id.keys():
			var edef: Dictionary = GameDatabase.enemies_by_id[eid]
			if edef is Dictionary and not bool(edef.get("is_boss", false)) and str(edef.get("ai_type", "")) != "dummy":
				standard_mobs.append(str(eid))
	if standard_mobs.is_empty():
		standard_mobs.append("hoang_da_son_lang")

	return { "special": special_mobs, "standard": standard_mobs }


func _spawn_enemy_unit(enemy_id_str: String, spawn_pos: Vector2, floor_num: int, is_boss_slot: bool) -> Node2D:
	var inst: CharacterBody2D = world.ENEMY_SCENE.instantiate() as CharacterBody2D
	world.entities_root.add_child(inst)
	if inst.has_method("configure_enemy"):
		inst.configure_enemy(enemy_id_str, spawn_pos)
	if inst.has_method("configure_tower_enemy"):
		inst.configure_tower_enemy(floor_num, is_boss_slot)
	else:
		if "detect_radius" in inst:
			inst.set("detect_radius", 1200.0)
		if "max_hp" in inst and "cur_hp" in inst:
			var sc_hp: float = (0.78 + float(floor_num) * 0.14) if is_boss_slot else (0.70 + float(floor_num) * 0.12)
			var scaled_hp: float = maxf(80.0, float(inst.get("max_hp")) * sc_hp)
			inst.set("max_hp", scaled_hp)
			inst.set("cur_hp", scaled_hp)
	enemies_alive.append(inst)
	return inst


func _spawn_floor(floor_num: int) -> void:
	enemies_alive.clear()
	heat_accum = 0.0
	heat_text_accum = 0.0

	# Tâm Hỏa Chước Đốt: 2.0 + floor * 1.4 HP/s, giảm 45% nếu đang trang bị Dị Hỏa!
	var raw_heat: float = 2.0 + float(floor_num) * 1.4
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var has_di_hoa: bool = false
	if not f_def.is_empty():
		var fid: String = str(f_def.get("id", ""))
		var fcat: String = str(f_def.get("category", ""))
		has_di_hoa = (fcat == "heavenly" or fid.begins_with("di_hoa_"))
	heat_dps = snappedf(raw_heat * (0.55 if has_di_hoa else 1.0), 0.1)

	if sign_lbl != null and is_instance_valid(sign_lbl):
		sign_lbl.text = "THIÊN PHẦN LUYỆN KHÍ THÁP — TẦNG %d%s" % [
			floor_num,
			" (THÁP CHỦ)" if (floor_num % 3 == 0) else ""
		]

	var mob_pools: Dictionary = _get_mob_pools()
	var special_mobs: Array = mob_pools["special"]
	var standard_mobs: Array = mob_pools["standard"]
	var p_pos: Vector2 = world.player_node.global_position if world.player_node != null else Vector2(340.0, 448.0)

	if floor_num % 3 == 0:
		var boss_pool: Array = _get_boss_pool()
		var tier_step: int = int(floor_num / 3) - 1
		var start_offset: int = clampi((PlayerData.realm_index - 1) * 2, 0, maxi(0, boss_pool.size() - 1))
		var b_idx: int = (start_offset + tier_step) % boss_pool.size()
		var boss_id_pick: String = str(boss_pool[b_idx])
		var boss_pos := Vector2(930.0, 448.0)
		if p_pos.distance_to(boss_pos) < 280.0:
			boss_pos = Vector2(320.0, 448.0)
		_spawn_enemy_unit(boss_id_pick, boss_pos, floor_num, true)

		var escort_offsets: Array = [Vector2(-110.0, -170.0), Vector2(-110.0, 170.0)]
		for idx_e in range(2):
			var pick_pool: Array = special_mobs if (not special_mobs.is_empty() and (idx_e == 0 or randf() < 0.65)) else standard_mobs
			var mob_id: String = str(pick_pool[randi() % pick_pool.size()])
			var e_pos: Vector2 = (boss_pos + (escort_offsets[idx_e] as Vector2)).clamp(Vector2(140.0, 150.0), Vector2(1140.0, 746.0))
			_spawn_enemy_unit(mob_id, e_pos, floor_num, false)

		var b_name: String = str(GameDatabase.get_enemy_def(boss_id_pick).get("name", boss_id_pick))
		if world.player_node != null:
			EventBus.floating_text_requested.emit(world.player_node.global_position + Vector2(0, -86), "TẦNG %d — THÁP CHỦ XUẤT HIỆN!" % floor_num, Color("#FF4D6D"))
		EventBus.banter_triggered.emit("THÁP TẦNG %d (BOSS): [%s] cùng 2 hộ vệ chấn giữ tầng lửa!" % [floor_num, b_name])
	else:
		var wave_cnt: int = 3 + mini(5, floor_num)
		for i in range(wave_cnt):
			var use_special: bool = (not special_mobs.is_empty()) and (i < mini(special_mobs.size(), maxi(2, int(wave_cnt / 2))) or randf() < 0.55)
			var mob_id: String = ""
			if use_special:
				mob_id = str(special_mobs[(i + floor_num) % special_mobs.size()])
			else:
				mob_id = str(standard_mobs[(i + floor_num + randi()) % standard_mobs.size()])

			var ang: float = -PI * 0.44 + (PI * 0.88) * (float(i) / maxf(1.0, float(wave_cnt - 1)))
			var dist_r: float = 250.0 + float(i % 2) * 115.0
			var candidate := Vector2(720.0 + cos(ang) * dist_r, 448.0 + sin(ang) * dist_r)
			candidate = candidate.clamp(Vector2(150.0, 150.0), Vector2(1130.0, 746.0))
			if candidate.distance_to(p_pos) < 230.0:
				var away: Vector2 = (candidate - p_pos).normalized()
				if away.length() < 0.01:
					away = Vector2.RIGHT
				candidate = (p_pos + away * 290.0).clamp(Vector2(150.0, 150.0), Vector2(1130.0, 746.0))
			_spawn_enemy_unit(mob_id, candidate, floor_num, false)

		if world.player_node != null:
			EventBus.floating_text_requested.emit(world.player_node.global_position + Vector2(0, -86), "TẦNG %d — KHAI CHIẾN!" % floor_num, Color("#FFD166"))

	total_wave = enemies_alive.size()
	EventBus.tower_state_updated.emit(tower_floor, enemies_alive.size(), total_wave, heat_dps, true)


func prune_enemies() -> void:
	if not is_active or waiting_blessing or enemies_alive.is_empty():
		return
	var dead_found: Array = []
	for en in enemies_alive:
		if en == null or not is_instance_valid(en):
			dead_found.append(en)
		else:
			var is_dying_f: bool = bool(en.get("is_dying")) if "is_dying" in en else false
			if is_dying_f or not en.is_in_group("enemies"):
				dead_found.append(en)
	if not dead_found.is_empty():
		on_enemy_defeated(dead_found[0] as Node)


func on_enemy_defeated(enemy_node: Node) -> void:
	if not is_active or waiting_blessing:
		return

	var next_alive: Array = []
	for en in enemies_alive:
		if en == null or not is_instance_valid(en) or en == enemy_node:
			continue
		var is_dying_f: bool = bool(en.get("is_dying")) if "is_dying" in en else false
		if is_dying_f or not en.is_in_group("enemies"):
			continue
		next_alive.append(en)
	enemies_alive = next_alive

	EventBus.tower_state_updated.emit(tower_floor, enemies_alive.size(), total_wave, heat_dps, true)

	if enemies_alive.is_empty():
		var rew: Dictionary = PlayerData.record_tower_floor_clear(tower_floor)
		var fe_gain: int = int(rew.get("fire_energy", 12))
		var st_gain: int = int(rew.get("stones", 1))
		var g_gain: int = int(rew.get("gold", 55))

		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.screen_shake_requested.emit(6.0, 0.24)
		if world.player_node != null:
			EventBus.floating_text_requested.emit(
				world.player_node.global_position + Vector2(0, -90),
				"VƯỢT TẦNG %d! +%d Hỏa Năng" % [tower_floor, fe_gain],
				Color("#FFD166")
			)
		EventBus.banter_triggered.emit(
			"VƯỢT TẦNG %d THIÊN PHẦN THÁP! Nhận +%d Tinh Hỏa Năng · +%d Đá CH · +%d Kim Tệ (Kỷ lục: Tầng %d)!" % [
				tower_floor, fe_gain, st_gain, g_gain, int(rew.get("best_floor", tower_floor))
			]
		)

		waiting_blessing = true
		var pool: Array = get_blessing_pool()
		pool.shuffle()
		var choices: Array = [pool[0], pool[1], pool[2]]
		EventBus.tower_blessing_requested.emit(tower_floor, choices)


func apply_blessing(blessing_id: String) -> void:
	if not is_active:
		return

	var chosen: Dictionary = {}
	for b in get_blessing_pool():
		if str(b.get("id", "")) == blessing_id:
			chosen = b
			break

	if not chosen.is_empty():
		var sk1: String = str(chosen.get("stat_key", ""))
		var v1: float = float(chosen.get("value", 0.0))
		var hr: float = float(chosen.get("heal_ratio", 0.0))
		PlayerData.add_tower_buff(sk1, v1, hr)
		var sk2: String = str(chosen.get("stat_key2", ""))
		var v2: float = float(chosen.get("value2", 0.0))
		if sk2 != "" and v2 != 0.0:
			PlayerData.add_tower_buff(sk2, v2, 0.0)
		EventBus.banter_triggered.emit("CHÚC PHÚC TÂM HỎA [%s]: %s" % [str(chosen.get("name", "")), str(chosen.get("desc", ""))])

	tower_floor += 1
	waiting_blessing = false
	EventBus.audio_sfx_requested.emit("level_up")
	EventBus.map_changed.emit("thien_phan_thap", "Thiên Phần Luyện Khí Tháp — Tầng %d" % tower_floor)
	_spawn_floor(tower_floor)


func exit_tower() -> void:
	reset_state(true)
	PlayerData.recalculate_and_clamp(true)
	EventBus.stats_changed.emit()
	var ret_map: String = return_map if (return_map != "" and return_map != "thien_phan_thap" and return_map != "tam_ma_luyen_canh") else GameDatabase.start_map_id
	var ret_pos: Vector2 = return_pos if return_pos != Vector2.ZERO else Vector2.ZERO
	world.load_map(ret_map, ret_pos, false)


func on_player_died() -> bool:
	if not is_active:
		return false
	var cur_fl: int = tower_floor
	PlayerData.recalculate_and_clamp(true)
	EventBus.stats_changed.emit()
	EventBus.audio_sfx_requested.emit("alchemy_fail")
	if world.player_node != null:
		EventBus.floating_text_requested.emit(world.player_node.global_position + Vector2(0, -82), "TRUYỀN TỐNG KHẨN CẤP!", Color("#FF758F"))
	EventBus.banter_triggered.emit("Trọng thương tại Thiên Phần Tháp Tầng %d — đã tự động truyền tống ra ngoài (giữ nguyên toàn bộ Tinh Hỏa Năng & Đá CH)!" % cur_fl)
	exit_tower()
	return true
