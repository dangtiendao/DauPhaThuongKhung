class_name PanelAlchemy
extends RefCounted
## Panel [L] Lò Luyện Đan Tương Tác (Mini-game Khống Hỏa + Đón Đan Lôi + Ràng buộc Cảnh Linh Hồn alchemy_max_tier).

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


func build_content(vbox: VBoxContainer) -> void:
	var sr: Dictionary = PlayerData.get_soul_realm_info()
	var sr_name: String = str(sr.get("name", "Phàm Cảnh Linh Hồn"))
	var max_tier: int = int(sr.get("alchemy_max_tier", 6))
	hud.modal_title_lbl.text = "[L] LÒ LUYỆN ĐAN — %s (Tối đa Phẩm %d · SOUL: %d)" % [sr_name, max_tier, PlayerData.get_soul()]

	if hud.alc_active:
		build_minigame_view(vbox)
		return

	var inv_str: String = "Dược Liệu & Đan Dược: "
	if PlayerData.inventory.is_empty():
		inv_str += "(Trống)"
	else:
		var parts: Array = []
		for item_id in PlayerData.inventory.keys():
			var idef: Dictionary = GameDatabase.get_item_def(str(item_id))
			parts.append("%s x%d" % [str(idef.get("name", item_id)), int(PlayerData.inventory[item_id])])
		inv_str += "  |  ".join(parts)

	var inv_lbl: Label = hud._make_label(inv_str, 13, Color("#FFE599"))
	inv_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(inv_lbl)

	# Khung Đan Dược Sử Dụng Trực Tiếp
	var pill_card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.11, 0.17, 0.94), Color("#70D6FF"), 1, 7)
	vbox.add_child(pill_card)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 4)
	pill_card.add_child(pv)
	pv.add_child(hud._make_label("ĐAN DƯỢC HỒI PHỤC TRONG NẠP GIỚI (Bấm Uống trực tiếp hoặc Gắn vào ô [1] / [2]):", 12, Color("#70D6FF")))
	var p_flow := HFlowContainer.new()
	p_flow.add_theme_constant_override("h_separation", 6)
	p_flow.add_theme_constant_override("v_separation", 5)
	pv.add_child(p_flow)
	for c_id in ["pill_ngung_huyet_tan", "pill_bang_tam_dan", "pill_hoi_khi_dan", "pill_thanh_lien_tu", "pill_truc_co_linh_dich"]:
		var cid_s: String = str(c_id)
		var owned_p: int = PlayerData.get_item_count(cid_s)
		var cdef: Dictionary = GameDatabase.get_item_def(cid_s)
		var ctype: String = str(cdef.get("type", ""))
		var p_box := HBoxContainer.new()
		p_box.add_theme_constant_override("separation", 3)
		p_flow.add_child(p_box)

		var drink_b := Button.new()
		drink_b.text = "Uống %s (x%d)" % [str(cdef.get("name", cid_s)), owned_p]
		drink_b.disabled = (owned_p <= 0)
		drink_b.add_theme_font_size_override("font_size", 11)
		drink_b.add_theme_color_override("font_color", Color(str(cdef.get("color_hex", "#FFE599"))) if owned_p > 0 else Color("#6C757D"))
		drink_b.pressed.connect(func() -> void:
			var p_nd: Node = hud._find_player()
			var wp: Vector2 = (p_nd as Node2D).global_position + Vector2(0, -45) if (p_nd != null and p_nd is Node2D) else Vector2.ZERO
			if PlayerData.use_consumable(cid_s, wp):
				hud.modal_status_lbl.text = "Đã uống [%s] thành công!" % str(cdef.get("name", cid_s))
				hud._populate_modal()
			else:
				hud.modal_status_lbl.text = "HP / Đấu Khí đã đầy hoặc đã hết đan dược này!"
		)
		p_box.add_child(drink_b)

		if ctype == "consumable_hp" or ctype == "consumable_qi":
			var slot_n: int = 1 if ctype == "consumable_hp" else 2
			var is_assigned: bool = (PlayerData.quick_hp_pill_id == cid_s) if slot_n == 1 else (PlayerData.quick_qi_pill_id == cid_s)
			var pin_b := Button.new()
			pin_b.text = "★[%d]" % slot_n if is_assigned else "Gắn[%d]" % slot_n
			pin_b.disabled = is_assigned
			pin_b.add_theme_font_size_override("font_size", 10)
			pin_b.pressed.connect(func() -> void:
				PlayerData.set_quick_pill_slot(slot_n, cid_s)
				hud.modal_status_lbl.text = "Đã gắn [%s] làm đan ưu tiên cho phím [%d]!" % [str(cdef.get("name", cid_s)), slot_n]
				hud._populate_modal()
			)
			p_box.add_child(pin_b)

	var sample_rec: Dictionary = GameDatabase.recipes_list[0] if not GameDatabase.recipes_list.is_empty() else {}
	var preview_mods: Dictionary = AlchemySystem.get_minigame_modifiers(sample_rec)
	var tip: Label = hud._make_label(
		"Thưởng Khống Hỏa (+%d%% = Dị Hỏa +%d%% · Dược Đỉnh +%d%% · Tiểu Y Tiên +%d%% · Linh Hồn +%d%%) -> Vùng Đan Tâm: [%d – %d] | Giới hạn %s: Tối đa Phẩm %d" % [
			int(preview_mods.get("total_pct", 0)),
			int(preview_mods.get("flame_pct", 0)),
			int(preview_mods.get("gear_pct", 0)),
			int(preview_mods.get("aff_pct", 0)),
			int(preview_mods.get("soul_pct", 0)),
			int(round(float(preview_mods.get("zone_min", 38.0)))),
			int(round(float(preview_mods.get("zone_max", 66.0)))),
			sr_name,
			max_tier
		],
		12,
		Color("#80ED99")
	)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(tip)

	for rec in GameDatabase.recipes_list:
		if not (rec is Dictionary):
			continue
		var r_dict: Dictionary = rec
		var out_def: Dictionary = GameDatabase.get_item_def(str(r_dict.get("output_item", "")))
		var out_name: String = str(out_def.get("name", ""))
		var ing_dict: Dictionary = r_dict.get("ingredients", {})
		var ing_parts: Array = []
		for ik in ing_dict.keys():
			var idef: Dictionary = GameDatabase.get_item_def(str(ik))
			ing_parts.append("%s %d/%d" % [str(idef.get("name", ik)), PlayerData.get_item_count(str(ik)), int(ing_dict[ik])])

		var tier_v: int = int(r_dict.get("tier", 1))
		var tier_locked: bool = (tier_v > max_tier)
		var rate_pct: int = int(round(AlchemySystem.get_success_chance(r_dict) * 100.0))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		vbox.add_child(row)

		var lock_note: String = ""
		if tier_locked:
			var req_sr: Dictionary = AlchemySystem.get_required_soul_realm_for_tier(tier_v)
			lock_note = "  [Cần %s · %d+ SOUL]" % [str(req_sr.get("name", "Linh Cảnh")), int(req_sr.get("min_soul", 250))]

		var desc: Label = hud._make_label(
			"[Phẩm %d] %s (Cần %d SOUL)%s — Nguyên liệu: %s" % [tier_v, out_name, int(r_dict.get("req_soul", 5)), lock_note, ", ".join(ing_parts)],
			13,
			Color("#FF758F") if tier_locked else Color("#DEE2E6")
		)
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(desc)

		var mini_btn := Button.new()
		mini_btn.text = "Khóa Cảnh Hồn" if tier_locked else "Khai Lò Khống Hỏa"
		mini_btn.add_theme_font_size_override("font_size", 12)
		if tier_locked:
			mini_btn.add_theme_color_override("font_color", Color("#FF758F"))
		mini_btn.pressed.connect(func() -> void:
			start_minigame(r_dict)
		)
		row.add_child(mini_btn)

		if tier_v <= 1:
			var fast_btn := Button.new()
			fast_btn.text = "Luyện Nhanh (%d%%)" % rate_pct
			fast_btn.add_theme_font_size_override("font_size", 11)
			fast_btn.pressed.connect(func() -> void:
				var res: Dictionary = AlchemySystem.craft_recipe(r_dict)
				hud.modal_status_lbl.text = str(res.get("msg", ""))
				hud._populate_modal()
			)
			row.add_child(fast_btn)


func start_minigame(recipe: Dictionary) -> void:
	var check: Dictionary = AlchemySystem.can_craft(recipe)
	if not bool(check.get("ok", false)):
		hud.modal_status_lbl.text = str(check.get("reason", "Không đủ nguyên liệu!"))
		AudioManager.play_sfx("alchemy_fail")
		return

	AlchemySystem.consume_ingredients(recipe)
	var mods: Dictionary = AlchemySystem.get_minigame_modifiers(recipe)
	hud.alc_zone_min = float(mods.get("zone_min", 38.0))
	hud.alc_zone_max = float(mods.get("zone_max", 66.0))
	hud.alc_cool_mult = float(mods.get("cool_mult", 1.0))
	hud.alc_perfect_req = float(mods.get("perfect_ratio_req", 0.62))
	hud.alc_pass_req = float(mods.get("pass_ratio_req", 0.28))
	hud.alc_bonus_summary = "Thưởng Dị Hỏa +%d%% · Dược Đỉnh +%d%% · Hồng Nhan +%d%% · Linh Hồn +%d%% (Vùng xanh %d–%d · Nguội x%.2f)" % [
		int(mods.get("flame_pct", 0)), int(mods.get("gear_pct", 0)),
		int(mods.get("aff_pct", 0)), int(mods.get("soul_pct", 0)),
		int(round(hud.alc_zone_min)), int(round(hud.alc_zone_max)), hud.alc_cool_mult
	]
	hud.alc_active = true
	hud.alc_recipe = recipe
	hud.alc_duration = 4.8 if int(recipe.get("tier", 1)) >= 2 else 3.8
	hud.alc_time_left = hud.alc_duration
	hud.alc_heat = (hud.alc_zone_min + hud.alc_zone_max) * 0.5
	hud.alc_in_zone_sec = 0.0
	hud.alc_lightning_pending = (int(recipe.get("tier", 1)) >= 2)
	hud.alc_lightning_triggered = false
	hud.alc_lightning_window = 0.0
	hud.alc_lightning_blocked = false
	AudioManager.play_sfx("skill_fire")
	hud.modal_status_lbl.text = "ĐANG NUNG LÒ! Giữ Hỏa Hầu trong vùng [%d–%d] bằng phím [Space] hoặc nút [THÚC HỎA]!" % [int(round(hud.alc_zone_min)), int(round(hud.alc_zone_max))]
	hud._populate_modal()


func build_minigame_view(vbox: VBoxContainer) -> void:
	var out_def: Dictionary = GameDatabase.get_item_def(str(hud.alc_recipe.get("output_item", "")))
	var card: PanelContainer = hud._make_styled_panel(Color(0.11, 0.07, 0.09, 0.96), Color("#FF9F1C"), 2, 16)
	vbox.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	card.add_child(v)

	v.add_child(hud._make_label("ĐANG LUYỆN CHẾ: %s  (Phẩm %d)" % [str(out_def.get("name", "")), int(hud.alc_recipe.get("tier", 1))], 18, Color("#FFD166")))
	var b_lbl: Label = hud._make_label(hud.alc_bonus_summary, 12, Color("#72EFDD"))
	b_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(b_lbl)

	hud.alc_info_lbl = hud._make_label("Hỏa Hầu: 52 / 100  (Vùng Đan Tâm chuẩn: %d — %d)" % [int(round(hud.alc_zone_min)), int(round(hud.alc_zone_max))], 14, Color("#80ED99"))
	v.add_child(hud.alc_info_lbl)

	hud.alc_heat_bar = hud._make_bar(Color("#FF9F1C"), 26, 920)
	hud.alc_heat_bar.max_value = 100.0
	hud.alc_heat_bar.value = hud.alc_heat
	v.add_child(hud.alc_heat_bar)

	v.add_child(hud._make_label("Tiến độ ngưng tụ Đan Dược:", 13, Color("#A8DADC")))
	hud.alc_progress_bar = hud._make_bar(Color("#52B788"), 18, 920)
	hud.alc_progress_bar.max_value = hud.alc_duration
	hud.alc_progress_bar.value = 0.0
	v.add_child(hud.alc_progress_bar)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 16)
	v.add_child(btn_row)

	hud.alc_pulse_btn = Button.new()
	hud.alc_pulse_btn.text = "THÚC HỎA (+16 Nhiệt)  [Phím Space]"
	hud.alc_pulse_btn.custom_minimum_size = Vector2(360, 48)
	hud.alc_pulse_btn.add_theme_font_size_override("font_size", 15)
	hud.alc_pulse_btn.pressed.connect(pulse_heat)
	btn_row.add_child(hud.alc_pulse_btn)

	hud.alc_lightning_btn = Button.new()
	hud.alc_lightning_btn.text = "ĐAN LÔI: Chưa xuất hiện"
	hud.alc_lightning_btn.custom_minimum_size = Vector2(360, 48)
	hud.alc_lightning_btn.disabled = true
	hud.alc_lightning_btn.add_theme_font_size_override("font_size", 15)
	hud.alc_lightning_btn.pressed.connect(block_lightning)
	btn_row.add_child(hud.alc_lightning_btn)


func pulse_heat() -> void:
	if not hud.alc_active:
		return
	hud.alc_heat = clampf(hud.alc_heat + 16.0, 0.0, 100.0)
	AudioManager.play_sfx("alchemy_tick")


func block_lightning() -> void:
	if not hud.alc_active or hud.alc_lightning_window <= 0.0:
		return
	hud.alc_lightning_blocked = true
	hud.alc_lightning_window = 0.0
	AudioManager.play_sfx("hit_crit")
	hud.modal_status_lbl.text = "TUYỆT VỜI! Bạn đã đánh tan ĐAN LÔI — Chắc chắn thưởng +1 viên Đan Dược!"
	if hud.alc_lightning_btn != null and is_instance_valid(hud.alc_lightning_btn):
		hud.alc_lightning_btn.text = "ĐÃ CHẮN ĐAN LÔI THÀNH CÔNG!"
		hud.alc_lightning_btn.disabled = true


func tick_minigame(delta: float) -> void:
	hud.alc_time_left -= delta
	var tier_f: float = float(hud.alc_recipe.get("tier", 1))
	var cool_rate: float = (20.0 + tier_f * 4.5 + sin(hud.alc_time_left * 5.0) * 6.0) * hud.alc_cool_mult
	hud.alc_heat = clampf(hud.alc_heat - cool_rate * delta, 0.0, 100.0)

	var in_sweet: bool = (hud.alc_heat >= hud.alc_zone_min and hud.alc_heat <= hud.alc_zone_max)
	if in_sweet:
		hud.alc_in_zone_sec += delta

	if hud.alc_lightning_pending and not hud.alc_lightning_triggered and hud.alc_time_left <= hud.alc_duration * 0.52:
		hud.alc_lightning_triggered = true
		var mods: Dictionary = AlchemySystem.get_minigame_modifiers(hud.alc_recipe)
		hud.alc_lightning_window = 1.85 + float(mods.get("lightning_extra_sec", 0.0))
		AudioManager.play_sfx("boss_roar")
		hud.modal_status_lbl.text = "CẢNH BÁO ĐAN LÔI GIÁNG XUỐNG! Bấm ngay nút [CHẮN ĐAN LÔI] hoặc phím [E]!"

	if hud.alc_lightning_window > 0.0:
		hud.alc_lightning_window -= delta
		if hud.alc_lightning_btn != null and is_instance_valid(hud.alc_lightning_btn):
			hud.alc_lightning_btn.disabled = false
			hud.alc_lightning_btn.text = "CHẮN ĐAN LÔI NGAY! [E] (%.1fs)" % maxf(0.0, hud.alc_lightning_window)
		if hud.alc_lightning_window <= 0.0 and not hud.alc_lightning_blocked:
			hud.alc_heat = clampf(hud.alc_heat - 18.0, 0.0, 100.0)
			if hud.alc_lightning_btn != null and is_instance_valid(hud.alc_lightning_btn):
				hud.alc_lightning_btn.disabled = true
				hud.alc_lightning_btn.text = "Đan Lôi đánh trúng lò (-18 nhiệt)!"

	if hud.alc_heat_bar != null and is_instance_valid(hud.alc_heat_bar):
		hud.alc_heat_bar.value = hud.alc_heat
	if hud.alc_progress_bar != null and is_instance_valid(hud.alc_progress_bar):
		hud.alc_progress_bar.value = hud.alc_duration - maxf(0.0, hud.alc_time_left)
	if hud.alc_info_lbl != null and is_instance_valid(hud.alc_info_lbl):
		var z_txt: String = "ĐÚNG ĐAN TÂM" if in_sweet else ("HỎA QUÁ MẠNH!" if hud.alc_heat > hud.alc_zone_max else "HỎA YẾU — THÚC HỎA!")
		hud.alc_info_lbl.text = "Hỏa Hầu: %d / 100  (Chuẩn: %d–%d)  ->  %s   |   Còn %.1fs" % [
			int(round(hud.alc_heat)), int(round(hud.alc_zone_min)), int(round(hud.alc_zone_max)), z_txt, maxf(0.0, hud.alc_time_left)
		]
		hud.alc_info_lbl.add_theme_color_override("font_color", Color("#80ED99") if in_sweet else Color("#FF758F"))

	if hud.alc_time_left <= 0.0:
		var ratio_ok: float = hud.alc_in_zone_sec / maxf(0.1, hud.alc_duration)
		var q_tier: int = 0
		if ratio_ok >= hud.alc_perfect_req:
			q_tier = 2
		elif ratio_ok >= hud.alc_pass_req:
			q_tier = 1
		var finished_rec: Dictionary = hud.alc_recipe
		var blocked_l: bool = hud.alc_lightning_blocked
		hud.alc_active = false
		hud.alc_recipe = {}
		var res: Dictionary = AlchemySystem.finish_minigame_craft(finished_rec, q_tier, blocked_l)
		hud.modal_status_lbl.text = str(res.get("msg", ""))
		hud._populate_modal()
