class_name PanelTowerBossRush
extends RefCounted
## Panel Phó bản Endgame trong [M] — Tâm Ma Luyện Cảnh (Boss Rush 23 Boss) & Thiên Phần Luyện Khí Tháp (Roguelite + Chúc Phúc).

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


static func grade_color(g: String) -> Color:
	match g:
		"SSS":
			return Color("#FFD166")
		"SS":
			return Color("#FF4D6D")
		"S":
			return Color("#C77DFF")
		"A":
			return Color("#80ED99")
		"B":
			return Color("#70D6FF")
		_:
			return Color("#CED4DA")


func build_boss_rush_tab(vbox: VBoxContainer) -> void:
	var bosses: Array = []
	for eid in GameDatabase.enemies_by_id.keys():
		var ed: Dictionary = GameDatabase.get_enemy_def(str(eid))
		if bool(ed.get("is_boss", false)):
			bosses.append(ed)
	bosses.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra: int = int(a.get("realm_index", 1))
		var rb: int = int(b.get("realm_index", 1))
		if ra != rb:
			return ra < rb
		return float(a.get("max_hp", 0)) < float(b.get("max_hp", 0))
	)

	var sum_card: PanelContainer = hud._make_styled_panel(Color(0.13, 0.05, 0.09, 0.95), Color("#FF4D6D"), 2, 9)
	vbox.add_child(sum_card)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 5)
	sum_card.add_child(sv)
	sv.add_child(hud._make_label("⚔ TÂM MA LUYỆN CẢNH — TÁI CHIẾN TOÀN BỘ %d ĐẠI BOSS (XẾP HẠNG C → SSS)" % bosses.size(), 14, Color("#FFD166")))
	var desc_l: Label = hud._make_label("Bước vào Đấu Trường Tâm Ma 1v1 để thử sức với bất kỳ Đại Boss nào mà KHÔNG ảnh hưởng nhiệm vụ cốt truyện! Đánh nhanh & ít mất máu đạt hạng SSS nhận tối đa Đá Cường Hóa + Kim Tệ.", 11, Color("#E2E8F0"))
	desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sv.add_child(desc_l)

	var cur_world: Node = hud._find_world()
	if cur_world != null and bool(cur_world.get("is_boss_rush_active")):
		var leave_btn := Button.new()
		leave_btn.text = "← Rời Tâm Ma Luyện Cảnh (Trở Về Bản Đồ Cũ)"
		leave_btn.add_theme_font_size_override("font_size", 13)
		leave_btn.add_theme_color_override("font_color", Color("#FF758F"))
		leave_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			hud._close_modal()
			if cur_world.has_method("exit_boss_rush"):
				cur_world.exit_boss_rush()
		)
		sv.add_child(leave_btn)

	var diff_row := HFlowContainer.new()
	diff_row.add_theme_constant_override("h_separation", 8)
	diff_row.add_theme_constant_override("v_separation", 5)
	sv.add_child(diff_row)

	var diff_specs: Array = [
		{ "k": "normal", "t": "Thường (HP x1.0 · ATK x1.0 · Thưởng x1.0)", "hp_m": 1.0, "atk_m": 1.0, "col": Color("#80ED99") },
		{ "k": "nightmare", "t": "Ác Mộng (HP x1.65 · ATK x1.35 · Thưởng x1.75)", "hp_m": 1.65, "atk_m": 1.35, "col": Color("#FF9F1C") },
		{ "k": "dau_tong", "t": "Đấu Tông (HP x2.45 · ATK x1.72 · Thưởng x2.6)", "hp_m": 2.45, "atk_m": 1.72, "col": Color("#FF4D6D") }
	]
	var cur_hp_m: float = 1.0
	var cur_atk_m: float = 1.0
	for ds in diff_specs:
		var dk: String = str(ds["k"])
		if dk == hud.boss_rush_diff:
			cur_hp_m = float(ds["hp_m"])
			cur_atk_m = float(ds["atk_m"])
		var db := Button.new()
		db.text = ("★ " if dk == hud.boss_rush_diff else "") + str(ds["t"])
		db.disabled = (dk == hud.boss_rush_diff)
		db.add_theme_font_size_override("font_size", 11)
		db.add_theme_color_override("font_color", ds["col"] as Color)
		db.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			hud.boss_rush_diff = dk
			hud._populate_modal()
		)
		diff_row.add_child(db)

	var cleared_cnt: int = 0
	for bd in bosses:
		if not PlayerData.get_boss_rush_record(str(bd.get("id", "")), hud.boss_rush_diff).is_empty():
			cleared_cnt += 1
	sv.add_child(hud._make_label("Tiến độ độ khó đang chọn: Đã chinh phục %d / %d Đại Boss" % [cleared_cnt, bosses.size()], 12, Color("#72EFDD")))

	for bd in bosses:
		var bid: String = str(bd.get("id", ""))
		var rec: Dictionary = PlayerData.get_boss_rush_record(bid, hud.boss_rush_diff)
		var has_clear: bool = not rec.is_empty()
		var best_g: String = str(rec.get("best_grade", ""))
		var border_c: Color = grade_color(best_g) if has_clear else Color("#495057")

		var card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.08, 0.15, 0.95), border_c, 2 if has_clear else 1, 7)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		row.add_child(hud._make_icon_box_from_tex(hud._get_enemy_thumb_tex(bd), border_c, 46))

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_v.add_theme_constant_override("separation", 2)
		row.add_child(info_v)

		var sc_hp: int = int(round(float(bd.get("max_hp", 300.0)) * cur_hp_m))
		var sc_atk: int = int(round(float(bd.get("atk", 20.0)) * cur_atk_m))
		info_v.add_child(hud._make_label("%s  <%s>" % [str(bd.get("name", bid)), str(bd.get("realm_label", ""))], 13, Color("#FFD166")))
		info_v.add_child(hud._make_label("HP Tâm Ma: %d  ·  ATK: %d  ·  DEF: %d  |  Đã hạ thực chiến: %d lần" % [
			sc_hp, sc_atk, int(bd.get("def", 5)), PlayerData.get_enemy_kill_count(bid)
		], 11, Color("#CED4DA")))

		if has_clear:
			info_v.add_child(hud._make_label("★ Kỷ lục [%s]: HẠNG %s  ·  Nhanh nhất %.1fs  ·  Thắng %d lần" % [
				hud.boss_rush_diff.to_upper(), best_g, float(rec.get("best_time", 0.0)), int(rec.get("clears", 1))
			], 11, grade_color(best_g)))
		else:
			info_v.add_child(hud._make_label("Chưa có kỷ lục ở độ khó này — Hãy khiêu chiến ngay!", 11, Color("#ADB5BD")))

		var cap_bid: String = bid
		var cap_diff: String = hud.boss_rush_diff
		var fight_btn := Button.new()
		fight_btn.text = "⚔ Khiêu Chiến!"
		fight_btn.add_theme_font_size_override("font_size", 12)
		fight_btn.add_theme_color_override("font_color", Color("#FF9F1C"))
		fight_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			hud._close_modal()
			EventBus.boss_rush_requested.emit(cap_bid, cap_diff)
		)
		row.add_child(fight_btn)


func build_tower_tab(vbox: VBoxContainer) -> void:
	var sr: Dictionary = PlayerData.get_soul_realm_info()
	var card: PanelContainer = hud._make_styled_panel(Color(0.14, 0.05, 0.05, 0.96), Color("#FF7B00"), 2, 12)
	vbox.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	card.add_child(v)

	v.add_child(hud._make_label("🔥 THIÊN PHẦN LUYỆN KHÍ THÁP — PHÓ BẢN ROGUELITE VÔ TẬN", 15, Color("#FFD166")))
	var desc: Label = hud._make_label(
		"Thánh địa tu luyện trứ danh của Học Viện Già Nam! Bên trong Tháp có Tâm Hỏa Chước Đốt liên tục (Dị Hỏa giảm 45% thiêu đốt). Vượt mỗi tầng nhận ngay Tinh Hỏa Năng, Đá Cường Hóa, Kim Tệ và được chọn 1 trong 3 Chúc Phúc Tâm Hỏa cộng dồn suốt lượt leo!\n• Mỗi 3 tầng (Tầng 3, 6, 9, 12...) chạm trán Đại Boss Thủ Tháp!\n• Trọng thương trong Tháp sẽ an toàn truyền tống ra ngoài, giữ trọn 100% chiến lợi phẩm.",
		12,
		Color("#E2E8F0")
	)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(desc)

	v.add_child(hud._make_label("★ Kỷ lục cao nhất: Tầng %d   |   Tinh Hỏa Năng: %d   |   Radar Linh Hồn [%s]: %s (Tầm %dpx)" % [
		PlayerData.tower_best_floor,
		PlayerData.fire_energy,
		AudioManager.get_action_key_label("soul_radar"),
		str(sr.get("name", "Phàm Cảnh Linh Hồn")),
		int(round(PlayerData.get_soul_radar_radius()))
	], 12, Color("#72EFDD")))

	var btn_row := HFlowContainer.new()
	btn_row.add_theme_constant_override("h_separation", 10)
	btn_row.add_theme_constant_override("v_separation", 8)
	v.add_child(btn_row)

	var cur_world: Node = hud._find_world()
	if cur_world != null and bool(cur_world.get("is_tower_active")):
		var leave_b := Button.new()
		leave_b.text = "← Rời Thiên Phần Luyện Khí Tháp (Về Bản Đồ Cũ)"
		leave_b.add_theme_font_size_override("font_size", 13)
		leave_b.add_theme_color_override("font_color", Color("#FF758F"))
		leave_b.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			hud._close_modal()
			EventBus.tower_exit_requested.emit()
		)
		btn_row.add_child(leave_b)
	else:
		var start1 := Button.new()
		start1.text = "🔥 Khởi Hành Từ Tầng 1"
		start1.custom_minimum_size = Vector2(210, 40)
		start1.add_theme_font_size_override("font_size", 13)
		start1.add_theme_color_override("font_color", Color("#FFD166"))
		start1.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			hud._close_modal()
			EventBus.tower_start_requested.emit(1)
		)
		btn_row.add_child(start1)

		for cp in [4, 7, 10]:
			if PlayerData.tower_best_floor >= cp:
				var cp_f: int = cp
				var cp_btn := Button.new()
				cp_btn.text = "⚡ Vào Nhanh Tầng %d" % cp_f
				cp_btn.custom_minimum_size = Vector2(165, 40)
				cp_btn.add_theme_font_size_override("font_size", 12)
				cp_btn.add_theme_color_override("font_color", Color("#FF9F1C"))
				cp_btn.pressed.connect(func() -> void:
					AudioManager.play_sfx("portal_warp")
					hud._close_modal()
					EventBus.tower_start_requested.emit(cp_f)
				)
				btn_row.add_child(cp_btn)

	var shop_card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.10, 0.17, 0.95), Color("#FFD166"), 1, 10)
	vbox.add_child(shop_card)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 6)
	shop_card.add_child(sv)
	sv.add_child(hud._make_label("ĐỔI TINH HỎA NĂNG (Hiện có: %d Hỏa Năng)" % PlayerData.fire_energy, 13, Color("#FFD166")))

	var ex_row := HFlowContainer.new()
	ex_row.add_theme_constant_override("h_separation", 8)
	ex_row.add_theme_constant_override("v_separation", 6)
	sv.add_child(ex_row)

	var ex_items: Array = [
		{ "t": "Đổi 5 Đá Cường Hóa (40 Hỏa Năng)", "cost": 40, "kind": "stones", "val": 5 },
		{ "t": "Đổi 1 Lôi Ma Hạch Cấp 5 (90 Hỏa Năng)", "cost": 90, "kind": "item", "id": "core_loi_5" },
		{ "t": "Đổi 1 Huyết Ma Hạch Cấp 5 (90 Hỏa Năng)", "cost": 90, "kind": "item", "id": "core_huyet_5" },
		{ "t": "Đổi 1 Đấu Linh Đan (120 Hỏa Năng)", "cost": 120, "kind": "item", "id": "pill_dau_linh_dan" }
	]
	for ex in ex_items:
		var cost_v: int = int(ex["cost"])
		var eb := Button.new()
		eb.text = str(ex["t"])
		eb.disabled = (PlayerData.fire_energy < cost_v)
		eb.add_theme_font_size_override("font_size", 11)
		eb.pressed.connect(func() -> void:
			if PlayerData.fire_energy < cost_v:
				return
			PlayerData.add_fire_energy(-cost_v)
			if str(ex["kind"]) == "stones":
				PlayerData.enhance_stones += int(ex["val"])
				EventBus.stats_changed.emit()
			else:
				PlayerData.add_item(str(ex["id"]), 1)
			AudioManager.play_sfx("loot_rare")
			hud.modal_status_lbl.text = "Đổi thành công: %s!" % str(ex["t"])
			hud._populate_modal()
		)
		ex_row.add_child(eb)


func build_blessing_content(vbox: VBoxContainer) -> void:
	hud.modal_title_lbl.text = "🔥 CHÚC PHÚC TÂM HỎA — VƯỢT TẦNG %d THÀNH CÔNG!" % hud.pending_tower_floor
	vbox.add_theme_constant_override("separation", 10)
	vbox.add_child(hud._make_label("Tâm Hỏa trong Tháp tôi luyện kinh mạch! Chọn 1 trong 3 Chúc Phúc để cộng dồn sức mạnh cho Tầng %d:" % (hud.pending_tower_floor + 1), 13, Color("#FFE599")))

	for ch in hud.pending_tower_choices:
		if not (ch is Dictionary):
			continue
		var cd: Dictionary = ch
		var bid: String = str(cd.get("id", ""))
		var col := Color(str(cd.get("color_hex", "#FFD166")))
		var card: PanelContainer = hud._make_styled_panel(Color(0.10, 0.08, 0.16, 0.96), col, 2, 12)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		card.add_child(row)

		var iv := VBoxContainer.new()
		iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		iv.add_theme_constant_override("separation", 3)
		row.add_child(iv)
		iv.add_child(hud._make_label("✦ " + str(cd.get("name", bid)), 15, col))
		var dl: Label = hud._make_label(str(cd.get("desc", "")), 12, Color("#E2E8F0"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		iv.add_child(dl)

		var cap_id: String = bid
		var pick_btn := Button.new()
		pick_btn.text = "Chọn Chúc Phúc →"
		pick_btn.custom_minimum_size = Vector2(170, 44)
		pick_btn.add_theme_font_size_override("font_size", 13)
		pick_btn.add_theme_color_override("font_color", col)
		pick_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("breakthrough")
			hud._close_modal()
			EventBus.tower_blessing_picked.emit(cap_id)
		)
		row.add_child(pick_btn)

	var exit_b := Button.new()
	exit_b.text = "← Dừng Leo & Rút Lui An Toàn (Giữ Toàn Bộ Hỏa Năng & Đá CH)"
	exit_b.add_theme_font_size_override("font_size", 12)
	exit_b.add_theme_color_override("font_color", Color("#ADB5BD"))
	exit_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("portal_warp")
		hud._close_modal()
		EventBus.tower_exit_requested.emit()
	)
	vbox.add_child(exit_b)
