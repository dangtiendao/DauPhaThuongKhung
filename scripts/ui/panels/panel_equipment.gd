class_name PanelEquipment
extends RefCounted
## Panel [I] Nhân Vật, Trang Bị 10 Ô, Cường Hóa, Phân Giải & Khảm Ma Hạch 3 Rãnh lên Vũ Khí.

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


func build_modal() -> void:
	hud.modal_title_lbl.text = "[I] NHÂN VẬT, TRANG BỊ 10 Ô & CƯỜNG HÓA   |   Kim Tệ: %d   |   Đá Cường Hóa: %d" % [PlayerData.gold, PlayerData.enhance_stones]

	var split := HBoxContainer.new()
	split.set_anchors_preset(Control.PRESET_FULL_RECT)
	split.add_theme_constant_override("separation", 12)
	hud.modal_content_host.add_child(split)

	var left_scroll := ScrollContainer.new()
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_stretch_ratio = 1.05
	split.add_child(left_scroll)

	var left_v := VBoxContainer.new()
	left_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_v.add_theme_constant_override("separation", 5)
	left_scroll.add_child(left_v)

	var set_lines: Array = PlayerData.cached_gear_bonuses.get("_active_sets", [])
	var set_txt: String = " | ".join(set_lines) if set_lines.size() > 0 else "Chưa kích hoạt (Mặc >= 2 món cùng bộ Tiêu Gia / Ma Thú)"
	var summary_panel: PanelContainer = hud._make_styled_panel(Color(0.09, 0.11, 0.19, 0.92), Color("#FFD166"), 1, 6)
	left_v.add_child(summary_panel)
	var sum_lbl: Label = hud._make_label(
		"Chỉ số: ATK %d | DEF %d | SPD %d | SOUL %d | Chí mạng %d%% | Hút máu %d%% | Giảm CD %d%% | Hỏa +%d%%\nBộ Trang Bị: %s" % [
			int(PlayerData.get_atk()), int(PlayerData.get_def()), int(PlayerData.get_move_speed()), PlayerData.get_soul(),
			int(round(PlayerData.get_crit_chance() * 100.0)), int(round(PlayerData.get_lifesteal_ratio() * 100.0)),
			int(round((1.0 - PlayerData.get_cooldown_multiplier()) * 100.0)),
			int(round((PlayerData.get_flame_dmg_multiplier() - 1.0) * 100.0)),
			set_txt
		],
		11,
		Color("#FFE599")
	)
	sum_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_panel.add_child(sum_lbl)

	# Khung Khảm Ma Hạch lên Huyền Trọng Xích / Vũ Khí (3 Rãnh)
	var core_card: PanelContainer = hud._make_styled_panel(Color(0.10, 0.07, 0.16, 0.94), Color("#E0AAFF"), 1, 7)
	left_v.add_child(core_card)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 5)
	core_card.add_child(cv)
	cv.add_child(hud._make_label("💎 KHẢM MA HẠCH LÊN VŨ KHÍ / HUYỀN TRỌNG XÍCH (3 RÃNH — Chọn rãnh rồi bấm Ma Hạch để khảm)", 11, Color("#E0AAFF")))

	var sock_row := HBoxContainer.new()
	sock_row.add_theme_constant_override("separation", 6)
	cv.add_child(sock_row)
	for s_idx in range(3):
		var cid_s: String = str(PlayerData.weapon_core_sockets[s_idx]) if s_idx < PlayerData.weapon_core_sockets.size() else ""
		var cdef: Dictionary = PlayerData.get_core_socket_def(cid_s) if cid_s != "" else {}
		var is_sel: bool = (hud.selected_core_slot == s_idx)
		var cap_i: int = s_idx
		var s_btn := Button.new()
		s_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s_btn.add_theme_font_size_override("font_size", 10)
		if cdef.is_empty():
			s_btn.text = ("★ " if is_sel else "") + "Rãnh #%d: (Trống)" % (s_idx + 1)
			s_btn.add_theme_color_override("font_color", Color("#FFD166") if is_sel else Color("#ADB5BD"))
		else:
			s_btn.text = ("★ " if is_sel else "") + "Rãnh #%d: %s" % [s_idx + 1, str(cdef["name"]).left(18)]
			s_btn.tooltip_text = str(cdef.get("desc", ""))
			s_btn.add_theme_color_override("font_color", cdef.get("color", Color("#FFD166")) as Color)
		s_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			hud.selected_core_slot = cap_i
			hud._populate_modal()
		)
		sock_row.add_child(s_btn)
		if not cdef.is_empty():
			var rm_b := Button.new()
			rm_b.text = "×"
			rm_b.tooltip_text = "Tháo Ma Hạch khỏi Rãnh #%d về lại Nạp Giới" % (s_idx + 1)
			rm_b.add_theme_font_size_override("font_size", 10)
			rm_b.pressed.connect(func() -> void:
				var res: Dictionary = PlayerData.unsocket_monster_core(cap_i)
				hud.modal_status_lbl.text = str(res.get("msg", ""))
			)
			sock_row.add_child(rm_b)

	var core_bag_row := HFlowContainer.new()
	core_bag_row.add_theme_constant_override("h_separation", 5)
	core_bag_row.add_theme_constant_override("v_separation", 4)
	cv.add_child(core_bag_row)
	var has_any_core: bool = false
	for core_k in ["core_hoa_1", "core_moc_2", "core_hoa_3", "core_phong_4", "core_loi_5", "core_huyet_5", "core_bang_5"]:
		var cnt: int = PlayerData.get_item_count(core_k)
		if cnt <= 0:
			continue
		has_any_core = true
		var cd: Dictionary = PlayerData.get_core_socket_def(core_k)
		var cap_ck: String = core_k
		var cb := Button.new()
		cb.text = "+ %s (x%d)" % [str(cd.get("name", core_k)), cnt]
		cb.tooltip_text = "Khảm vào Rãnh #%d: %s" % [hud.selected_core_slot + 1, str(cd.get("desc", ""))]
		cb.add_theme_font_size_override("font_size", 10)
		cb.add_theme_color_override("font_color", cd.get("color", Color("#FFD166")) as Color)
		cb.pressed.connect(func() -> void:
			var res: Dictionary = PlayerData.socket_monster_core(hud.selected_core_slot, cap_ck)
			hud.modal_status_lbl.text = str(res.get("msg", ""))
		)
		core_bag_row.add_child(cb)
	if not has_any_core:
		core_bag_row.add_child(hud._make_label("(Chưa có Ma Hạch trong túi — Săn Ma Thú hoặc đổi bằng Hỏa Năng trong Thiên Phần Tháp!)", 10, Color("#868E96")))

	for s_entry in GameDatabase.equipment_slots:
		if not (s_entry is Dictionary):
			continue
		var slot_id: String = str(s_entry.get("id", ""))
		var slot_name: String = str(s_entry.get("name", slot_id))
		var def_icon: String = str(s_entry.get("default_icon", "res://assets/sprites/icons/icon_armor.png"))
		var eq = PlayerData.equipped_gear.get(slot_id, {})
		var has_item: bool = (eq is Dictionary) and not eq.is_empty()

		var r_col: Color = EquipmentSystem.get_rarity_color(str(eq.get("rarity", "pham"))) if has_item else Color("#3A4258")
		var row_card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.10, 0.16, 0.92), r_col, 1, 5)
		left_v.add_child(row_card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row_card.add_child(row)

		var icon_path: String = def_icon
		if has_item:
			var tdef: Dictionary = GameDatabase.get_equipment_template(str(eq.get("template_id", "")))
			icon_path = str(tdef.get("icon", def_icon))
		row.add_child(hud._make_icon_box(icon_path, r_col, 38))

		var txt_col := VBoxContainer.new()
		txt_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(txt_col)

		if has_item:
			txt_col.add_child(hud._make_label("%s: %s" % [slot_name, EquipmentSystem.get_item_display_name(eq)], 12, r_col))
			var st_l: Label = hud._make_label(EquipmentSystem.format_stats_line(eq), 11, Color("#CED4DA"))
			st_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			txt_col.add_child(st_l)

			var uid_str: String = str(eq.get("uid", ""))
			var cost: Dictionary = EquipmentSystem.get_enhance_cost(eq)
			var enh_btn := Button.new()
			enh_btn.text = "+1 (%dV/%dĐ)" % [int(cost.get("gold", 40)), int(cost.get("stones", 1))]
			enh_btn.add_theme_font_size_override("font_size", 11)
			enh_btn.pressed.connect(func() -> void:
				var res: Dictionary = PlayerData.enhance_gear_by_uid(uid_str)
				hud.modal_status_lbl.text = str(res.get("msg", ""))
			)
			row.add_child(enh_btn)

			var un_btn := Button.new()
			un_btn.text = "Tháo"
			un_btn.add_theme_font_size_override("font_size", 11)
			un_btn.pressed.connect(func() -> void:
				hud.modal_status_lbl.text = PlayerData.unequip_slot(slot_id)
			)
			row.add_child(un_btn)
		else:
			var empty_hint: String = "%s: (Tay Không — Mua tại Nhã Phi hoặc đánh Boss)" % slot_name if slot_id == "weapon" else "%s: (Chưa trang bị)" % slot_name
			txt_col.add_child(hud._make_label(empty_hint, 12, Color("#6C757D")))

	var right_col := VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.size_flags_stretch_ratio = 0.95
	right_col.add_theme_constant_override("separation", 6)
	split.add_child(right_col)

	var bag_hdr := HBoxContainer.new()
	right_col.add_child(bag_hdr)
	var bag_title: Label = hud._make_label("TÚI TRANG BỊ TRONG NẠP GIỚI (%d món)" % PlayerData.gear_bag.size(), 13, Color("#70D6FF"))
	bag_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_hdr.add_child(bag_title)

	var bulk_salvage_btn := Button.new()
	bulk_salvage_btn.text = "Phân giải Phàm/Linh (+0)"
	bulk_salvage_btn.add_theme_font_size_override("font_size", 11)
	bulk_salvage_btn.pressed.connect(func() -> void:
		hud.modal_status_lbl.text = PlayerData.salvage_low_rarity_gear()
	)
	bag_hdr.add_child(bulk_salvage_btn)

	# Thanh uống đan nhanh ngay trong Nạp Giới [I]
	var quick_pill_flow := HFlowContainer.new()
	quick_pill_flow.add_theme_constant_override("h_separation", 4)
	quick_pill_flow.add_theme_constant_override("v_separation", 4)
	right_col.add_child(quick_pill_flow)
	for cid in ["pill_ngung_huyet_tan", "pill_bang_tam_dan", "pill_huyet_ngung_dan", "pill_hoi_khi_dan", "pill_thanh_lien_tu", "pill_truc_co_linh_dich", "pill_hoa_lien_dan", "pill_am_duong_huyen_long"]:
		var cid_s: String = str(cid)
		var p_cnt: int = PlayerData.get_item_count(cid_s)
		if p_cnt <= 0:
			continue
		var cdef: Dictionary = GameDatabase.get_item_def(cid_s)
		var ub := Button.new()
		ub.text = "Uống %s (x%d)" % [str(cdef.get("name", cid_s)), p_cnt]
		ub.add_theme_font_size_override("font_size", 10)
		ub.add_theme_color_override("font_color", Color(str(cdef.get("color_hex", "#FFE599"))))
		ub.pressed.connect(func() -> void:
			var p_nd: Node = hud._find_player()
			var wp: Vector2 = (p_nd as Node2D).global_position + Vector2(0, -45) if (p_nd != null and p_nd is Node2D) else Vector2.ZERO
			if PlayerData.use_consumable(cid_s, wp):
				hud.modal_status_lbl.text = "Đã uống [%s]!" % str(cdef.get("name", cid_s))
				hud._populate_modal()
			else:
				hud.modal_status_lbl.text = "HP / Đấu Khí hiện đã đầy!"
		)
		quick_pill_flow.add_child(ub)

	var right_scroll := ScrollContainer.new()
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_col.add_child(right_scroll)

	var bag_v := VBoxContainer.new()
	bag_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_v.add_theme_constant_override("separation", 6)
	right_scroll.add_child(bag_v)

	if PlayerData.gear_bag.is_empty():
		bag_v.add_child(hud._make_label("Túi trống! Hãy đánh quái, mở Bảo Rương ẩn hoặc ghé Phòng Đấu Giá Nhã Phi!", 12, Color("#ADB5BD")))
	else:
		for item in PlayerData.gear_bag:
			if not (item is Dictionary):
				continue
			var inst: Dictionary = item
			var tdef: Dictionary = GameDatabase.get_equipment_template(str(inst.get("template_id", "")))
			var r_col: Color = EquipmentSystem.get_rarity_color(str(inst.get("rarity", "pham")))
			var card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.10, 0.17, 0.94), r_col, 1, 6)
			bag_v.add_child(card)

			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 8)
			card.add_child(h)

			var icon_p: String = str(tdef.get("icon", "res://assets/sprites/icons/icon_armor.png"))
			h.add_child(hud._make_icon_box(icon_p, r_col, 40))

			var info_v := VBoxContainer.new()
			info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(info_v)

			info_v.add_child(hud._make_label(EquipmentSystem.get_item_display_name(inst), 12, r_col))
			var stat_l: Label = hud._make_label(EquipmentSystem.format_stats_line(inst), 11, Color("#DEE2E6"))
			stat_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			info_v.add_child(stat_l)

			var btn_v := VBoxContainer.new()
			btn_v.add_theme_constant_override("separation", 3)
			h.add_child(btn_v)

			var uid_val: String = str(inst.get("uid", ""))
			var eq_btn := Button.new()
			eq_btn.text = "Mặc"
			eq_btn.add_theme_font_size_override("font_size", 11)
			eq_btn.pressed.connect(func() -> void:
				hud.modal_status_lbl.text = PlayerData.equip_gear_from_bag(uid_val)
			)
			btn_v.add_child(eq_btn)

			var sal_btn := Button.new()
			sal_btn.text = "Phân giải"
			sal_btn.add_theme_font_size_override("font_size", 11)
			sal_btn.pressed.connect(func() -> void:
				hud.modal_status_lbl.text = PlayerData.salvage_gear_by_uid(uid_val)
			)
			btn_v.add_child(sal_btn)
