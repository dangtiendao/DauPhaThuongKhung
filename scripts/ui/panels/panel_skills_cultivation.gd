class_name PanelSkillsCultivation
extends RefCounted
## Panel Mô-Đun [K] Kho 24 Đấu Kỹ & Xưởng Hỏa Liên · [B] Đột Phá Cảnh Giới · [H] Dị Hỏa Bảng (Tách từ hud_controller.gd).

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


func build_skills_codex_content(vbox: VBoxContainer) -> void:
	hud.modal_title_lbl.text = "[K] KHO ĐẤU KỸ (%d / %d ĐÃ LĨNH NGỘ) & XƯỞNG DUNG HỢP HỎA LIÊN" % [PlayerData.unlocked_skills.size(), GameDatabase.skills_by_id.size()]

	var active_bar: PanelContainer = hud._make_styled_panel(Color(0.10, 0.11, 0.20, 0.94), Color("#FFD166"), 1, 8)
	vbox.add_child(active_bar)
	var q_n: String = str(GameDatabase.get_skill_def(PlayerData.slot_q_skill).get("name", "(Trống)")) if PlayerData.slot_q_skill != "" else "(Trống)"
	var e_n: String = str(GameDatabase.get_skill_def(PlayerData.slot_e_skill).get("name", "(Trống)")) if PlayerData.slot_e_skill != "" else "(Trống)"
	var r_n: String = str(GameDatabase.get_skill_def(PlayerData.slot_r_skill).get("name", "(Trống)")) if PlayerData.slot_r_skill != "" else "(Trống)"
	var f_n: String = str(GameDatabase.get_skill_def(PlayerData.slot_f_skill).get("name", "(Khóa — Ch.03)")) if PlayerData.slot_f_skill != "" else "(Khóa — Chương 03)"
	var x_tag: String = "   |   [X] Tộc Văn Tiêu Tộc ✓" if PlayerData.is_skill_unlocked("toc_van_tieu_toc") else ""
	active_bar.add_child(hud._make_label("Bộ Chiêu Đang Lắp:  [Q] %s   |   [E] %s   |   [R] %s   |   [F] %s%s" % [q_n, e_n, r_n, f_n, x_tag], 13, Color("#FFE599")))

	for sid in GameDatabase.skills_by_id.keys():
		var sdef: Dictionary = GameDatabase.get_skill_def(str(sid))
		var is_unl: bool = PlayerData.is_skill_unlocked(str(sid))
		var is_ult: bool = (str(sid) == "phat_no_hoa_lien")
		var border_c: Color = Color("#FF9F1C") if is_unl else Color("#343A40")
		var card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.09, 0.16, 0.94), border_c, 1, 7)
		vbox.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		var ic_p: String = str(sdef.get("icon", "res://assets/sprites/icons/skill_toai_thach.png"))
		var ic_box: PanelContainer = hud._make_icon_box(ic_p, border_c, 44)
		if not is_unl:
			ic_box.modulate = Color(0.45, 0.48, 0.55, 0.70)
		row.add_child(ic_box)

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info_v)

		var title_col: Color = Color("#FFD166") if is_unl else Color("#6C757D")
		var lock_tag: String = "" if is_unl else " [KHÓA]"
		var mi: Dictionary = PlayerData.get_skill_mastery_info(str(sid))
		var eff_cd: float = float(sdef.get("cooldown", 5.0)) * float(mi.get("cd_mult", 1.0))
		info_v.add_child(hud._make_label("%s  <%s>%s   |   QI: %d  |  CD: %.1fs" % [
			str(sdef.get("name", sid)), str(sdef.get("grade", "")), lock_tag,
			int(sdef.get("qi_cost", 15)), eff_cd
		], 13, title_col))

		if is_unl:
			var m_tier_idx: int = int(mi.get("tier", 0))
			var m_tier: String = str(mi.get("tier_name", "Sơ Khuy"))
			var m_uses: int = int(mi.get("uses", 0))
			var m_next: int = int(mi.get("next_uses", 8))
			var dmg_b: int = int(round((float(mi.get("dmg_mult", 1.0)) - 1.0) * 100.0))
			var cd_b: int = int(round((1.0 - float(mi.get("cd_mult", 1.0))) * 100.0))
			var rad_b: int = int(round((float(mi.get("radius_mult", 1.0)) - 1.0) * 100.0))
			var m_col: Color = mi.get("color", Color("#A8DADC")) as Color
			var prog_s: String = "ĐẠT TỐI ĐA (%d lần)" % m_uses if m_tier_idx >= 3 else "%d / %d lần" % [m_uses, m_next]
			var bonus_s: String = "+%d%% DMG · -%d%% CD · +%d%% Phạm Vi" % [dmg_b, cd_b, rad_b] if dmg_b > 0 else "Dùng %d lần để đạt Tiểu Thành (+12%% DMG, -6%% CD)" % m_next
			info_v.add_child(hud._make_label("★ Thông Thạo: %s (%s) — %s" % [m_tier, prog_s, bonus_s], 11, m_col))
			var m_bar: ProgressBar = hud._make_bar(m_col, 5, 220)
			m_bar.max_value = 100.0
			m_bar.value = 100.0 if m_tier_idx >= 3 else clampf(100.0 * float(m_uses) / float(max(1, m_next)), 0.0, 100.0)
			info_v.add_child(m_bar)

		var sub_txt: String = str(sdef.get("description", "")) if is_unl else ("Nguồn mở khóa: " + str(sdef.get("unlock_source", "")))
		var dl: Label = hud._make_label(sub_txt, 11, Color("#CED4DA") if is_unl else Color("#868E96"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(dl)

		if is_unl and not is_ult:
			var sk_key: String = str(sid)
			for slot_k in ["Q", "E", "R"]:
				var k_cap: String = slot_k
				var is_here: bool = (PlayerData.get_skill_in_slot(k_cap) == sk_key)
				var b := Button.new()
				b.text = "Đang ở [%s]" % k_cap if is_here else "Gắn [%s]" % k_cap
				b.disabled = is_here
				b.add_theme_font_size_override("font_size", 11)
				b.pressed.connect(func() -> void:
					PlayerData.assign_skill_to_slot(k_cap, sk_key)
					hud.modal_status_lbl.text = "Đã lắp [%s] vào ô [%s] trên thanh MOBA!" % [str(sdef.get("name", sk_key)), k_cap]
				)
				row.add_child(b)

	var lotus_card: PanelContainer = hud._make_styled_panel(Color(0.12, 0.06, 0.14, 0.94), Color("#C77DFF"), 2, 10)
	vbox.add_child(lotus_card)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 6)
	lotus_card.add_child(lv)

	var bonus_pct: int = max(0, PlayerData.lotus_fusion_flames.size() - 1) * 28
	var max_lotus_f: int = PlayerData.get_lotus_max_flames()
	var five_tag: String = " · ★ Đã Mở LỤC SẮC THÁNH LIÊN (100%% Xuyên Giáp)!" if max_lotus_f >= 6 else (" · ★ Đã Mở NGŨ SẮC BĂNG PHONG 3s!" if max_lotus_f >= 5 else "")
	lv.add_child(hud._make_label("XƯỞNG DUNG HỢP PHẬT NỘ HỎA LIÊN (%d/%d Hỏa đã ghép — Uy lực +%d%%%s)" % [PlayerData.lotus_fusion_flames.size(), max_lotus_f, bonus_pct, five_tag], 14, Color("#E0AAFF")))
	if PlayerData.unlocked_flames.is_empty():
		lv.add_child(hud._make_label("Chưa thu phục ngọn Hỏa nào! Hãy bái sư Dược Lão (Phàm Hỏa) -> Hạ Mục Xà (Tử Hỏa) -> Sa Mạc Chương 03 (Thanh Liên Địa Tâm Hỏa).", 12, Color("#ADB5BD")))
	else:
		var f_flow := HFlowContainer.new()
		f_flow.add_theme_constant_override("h_separation", 6)
		f_flow.add_theme_constant_override("v_separation", 6)
		lv.add_child(f_flow)
		for fid in PlayerData.unlocked_flames:
			var f_str: String = str(fid)
			var fdef: Dictionary = GameDatabase.get_flame_def(f_str)
			var in_lotus: bool = PlayerData.lotus_fusion_flames.has(f_str)
			var fb := Button.new()
			fb.text = ("★ " if in_lotus else "+ ") + str(fdef.get("name", f_str))
			fb.tooltip_text = "Hiệu ứng Hỏa Liên: " + str(fdef.get("lotus_effect", ""))
			fb.add_theme_font_size_override("font_size", 11)
			if in_lotus:
				fb.add_theme_color_override("font_color", Color(str(fdef.get("mid_hex", "#FFD166"))).lightened(0.28))
			fb.pressed.connect(func() -> void:
				hud.modal_status_lbl.text = PlayerData.toggle_lotus_fusion_flame(f_str)
			)
			f_flow.add_child(fb)

		if not PlayerData.lotus_fusion_flames.is_empty():
			var eff_lines: Array = []
			for lf in PlayerData.lotus_fusion_flames:
				var ldef: Dictionary = GameDatabase.get_flame_def(str(lf))
				eff_lines.append("• %s: %s" % [str(ldef.get("name", lf)), str(ldef.get("lotus_effect", ""))])
			var eff_lbl: Label = hud._make_label("Hiệu ứng Đang Kích Hoạt trong [F] Phật Nộ Hỏa Liên:\n" + "\n".join(eff_lines), 11, Color("#80ED99"))
			eff_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lv.add_child(eff_lbl)


func build_breakthrough_content(vbox: VBoxContainer) -> void:
	hud.modal_title_lbl.text = "[B] TU LUYỆN CẢNH GIỚI & LINH HỒN (12 ĐẠI CẢNH GIỚI)"
	var r_def: Dictionary = GameDatabase.get_realm_def(PlayerData.realm_index)
	var req_item_id: String = str(r_def.get("breakthrough_item", "none"))
	var req_item_name: String = "Không cần"
	var owned_cnt: int = 0
	if req_item_id != "none":
		var idef: Dictionary = GameDatabase.get_item_def(req_item_id)
		req_item_name = str(idef.get("name", req_item_id))
		owned_cnt = PlayerData.get_item_count(req_item_id)

	var info_txt: String = (
		"• Cảnh giới hiện tại: %s (EXP: %d / %d)\n" % [PlayerData.get_realm_display_title(), PlayerData.current_exp, PlayerData.get_required_exp()]
		+ "• Cảnh giới Linh Hồn: %s (%d SOUL)\n" % [PlayerData.get_soul_realm_name(), PlayerData.get_soul()]
		+ "• Hệ số nhận EXP hiện tại: x%.2f\n" % PlayerData.get_exp_multiplier()
		+ "• Đan dược đột phá Đại Cảnh Giới kế tiếp: %s (Đang có: %d)\n" % [req_item_name, owned_cnt]
		+ "• Đặc quyền cảnh giới hiện tại: %s" % str(r_def.get("unlock_feature", ""))
	)
	var info_lbl: Label = hud._make_label(info_txt, 14, Color("#E9ECEF"))
	info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(info_lbl)

	var bt_btn := Button.new()
	bt_btn.text = "PHÁ QUAN ĐỘT PHÁ ĐẠI CẢNH GIỚI!"
	bt_btn.add_theme_font_size_override("font_size", 15)
	bt_btn.pressed.connect(func() -> void:
		var res: Dictionary = PlayerData.try_breakthrough()
		hud.modal_status_lbl.text = str(res.get("msg", ""))
		hud._populate_modal()
	)
	vbox.add_child(bt_btn)

	# Hệ thống Cửu Chuyển Đấu Tôn (Chương 09 — Thiên Mộ Tam Tầng)
	var nt_card: PanelContainer = hud._make_styled_panel(Color(0.11, 0.08, 0.18, 0.95), Color("#FFD166"), 2, 10)
	vbox.add_child(nt_card)
	var nt_v := VBoxContainer.new()
	nt_v.add_theme_constant_override("separation", 6)
	nt_card.add_child(nt_v)
	var cur_turn: int = NineTurnManager.get_turn_level(PlayerData)
	var cur_pct: int = int(round(float(cur_turn) * NineTurnManager.BONUS_PER_TURN * 100.0))
	nt_v.add_child(hud._make_label("✦ CỬU CHUYỂN ĐẤU TÔN — CHUYỂN LUÂN NIẾT BÀN (%d / 9 Chuyển · +%d%% Toàn Bộ Chỉ Số)" % [cur_turn, cur_pct], 14, Color("#FFD166")))
	var nt_chk: Dictionary = NineTurnManager.can_condense_next_turn(PlayerData)
	var nt_req: Dictionary = NineTurnManager.get_next_turn_requirement(PlayerData)
	var nt_desc: String = ""
	if not NineTurnManager.is_unlocked(PlayerData):
		nt_desc = "Mở khóa khi đột phá cảnh giới Đấu Tôn (Chương 09 — Hồi 9.2). Săn Năng Lượng Thể trong Thiên Mộ (x5 EXP) lấy Năng Lượng Hạch 8/9 để ngưng tụ 9 Chuyển Luân!"
	elif bool(nt_req.get("maxed", false)):
		nt_desc = "★ ĐÃ VIÊN MÃN CỬU CHUYỂN ĐẤU TÔN ĐỈNH PHONG (9/9 Chuyển · +72% HP / QI / ATK / DEF / SOUL)! Đủ sức giao phong ngang ngửa Bán Thánh!"
	else:
		var req_iid: String = str(nt_req.get("req_item", "core_nang_luong_8"))
		var req_iname: String = str(GameDatabase.get_item_def(req_iid).get("name", req_iid))
		var req_qty: int = int(nt_req.get("req_qty", 2))
		var g_cost: int = int(nt_req.get("gold_cost", 65000))
		nt_desc = "Chuyển Luân kế tiếp (%d/9 -> +%d%% chỉ số): Cần %dx [%s] (Đang có: %d) HOẶC 1x [Cửu Chuyển Tôn Nguyên Đan] (Đang có: %d) + %d Kim Tệ." % [
			int(nt_req.get("next_turn", cur_turn + 1)),
			int(round(float(cur_turn + 1) * 8.0)),
			req_qty, req_iname, PlayerData.get_item_count(req_iid),
			PlayerData.get_item_count("pill_cuu_chuyen_ton_nguyen"), g_cost
		]
	var nt_lbl: Label = hud._make_label(nt_desc, 12, Color("#E0FBFC") if bool(nt_chk.get("ok", false)) else Color("#CED4DA"))
	nt_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nt_v.add_child(nt_lbl)
	if NineTurnManager.is_unlocked(PlayerData) and not bool(nt_req.get("maxed", false)):
		var nt_btn := Button.new()
		nt_btn.text = "NGƯNG TỤ CHUYỂN LUÂN %d/9 (+8%% TOÀN CHỈ SỐ)!" % (cur_turn + 1)
		nt_btn.disabled = not bool(nt_chk.get("ok", false))
		nt_btn.add_theme_font_size_override("font_size", 13)
		nt_btn.add_theme_color_override("font_color", Color("#FFD166"))
		nt_btn.pressed.connect(func() -> void:
			var r_nt: Dictionary = NineTurnManager.condense_next_turn(PlayerData)
			if bool(r_nt.get("ok", false)):
				hud.modal_status_lbl.text = "✦ NGƯNG TỤ THÀNH CÔNG CỬU CHUYỂN %d/9 (+%d%% TOÀN BỘ CHỈ SỐ)!" % [int(r_nt.get("turn", 1)), int(r_nt.get("bonus_pct", 8))]
			else:
				hud.modal_status_lbl.text = str(r_nt.get("reason", "Chưa đủ điều kiện ngưng tụ!"))
			hud._populate_modal()
		)
		nt_v.add_child(nt_btn)

	# Hệ thống Đấu Thánh Không Gian · Bách Thế Luân Hồi · Khí Linh Tiểu Y (Chương 10)
	var st_card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.06, 0.14, 0.95), Color("#F8A5C2"), 2, 10)
	vbox.add_child(st_card)
	var st_v := VBoxContainer.new()
	st_v.add_theme_constant_override("separation", 5)
	st_card.add_child(st_v)
	var domain_on: bool = SaintRealmManager.has_dau_thanh_domain(PlayerData)
	var tieu_y_on: bool = SaintRealmManager.has_tieu_y_spirit(PlayerData)
	var bt_stage: int = SaintRealmManager.get_bach_the_stage(PlayerData)
	var bt_ben: int = SaintRealmManager.get_bach_the_benevolent_count(PlayerData)
	var bv_7: bool = SaintRealmManager.has_bac_vuong_seven_star(PlayerData)
	st_v.add_child(hud._make_label("✿ ĐẤU THÁNH KHÔNG GIAN & KHÍ LINH TIỂU Y (#3 TỊNH LIÊN YÊU HỎA)", 14, Color("#F8A5C2")))
	var st_lines: Array[String] = [
		"• Đấu Thánh Không Gian: %s" % ("★ ĐÃ KHAI MỞ (Xé Không 1.5s · 3 Đạo Kiếm Khí LMB · +25% Thánh Uy)" if domain_on else "Chưa khai mở (Vượt Ảo Cảnh Bách Thế Luân Hồi dưới Bồ Đề Cổ Thụ — Ch.10)"),
		"• Bách Thế Luân Hồi: %d/3 Kiếp (Đạo Tâm Thiện: %d/3%s)" % [bt_stage, bt_ben, " · ★ Trăm Kiếp Sơ Tâm (+250 SOUL)" if PlayerData.has_flag("ach_10_02_tram_kiep_so_tam") else ""],
		"• Khí Linh Yêu Hỏa Tiểu Y (#3): %s" % ("★ ĐỒNG HÀNH VĨNH VIỄN (30% Tịnh Hóa Đạn Tà +8% QI · Tự Luyện Đan Phẩm 1–8 [L])" if tieu_y_on else "Chưa thu phục (Song luyện Đài Sen cùng Cổ Huân Nhi — Hồi 10.5)"),
		"• Khôi Lỗi Bắc Vương: %s" % ("★ THẤT TINH ĐẤU THÁNH (Cửu Huyền Kim Lôi)" if bv_7 else ("Lục Tinh Đấu Thánh (Chờ Cửu Huyền Kim Lôi Hạch — SQ_10_04)" if PlayerData.unlocked_companions.has("bac_vuong") else "Chưa rèn đúc (Yêu Hỏa Không Gian — Hồi 10.5)"))
	]
	var st_lbl: Label = hud._make_label("\n".join(st_lines), 12, Color("#FFE5EC") if domain_on else Color("#CED4DA"))
	st_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	st_v.add_child(st_lbl)


func build_flames_content(vbox: VBoxContainer) -> void:
	hud.modal_title_lbl.text = "[H] DỊ HỎA BẢNG & PHẦN QUYẾT (ĐÃ THU PHỤC: %d / %d)" % [PlayerData.unlocked_flames.size(), GameDatabase.flames_ordered.size()]
	var hint: Label = hud._make_label("Chuẩn cốt truyện: Chỉ những ngọn Hỏa bạn thực sự thu phục qua các Chương mới có thể vận chuyển!", 13, Color("#A8DADC"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint)

	for fl in GameDatabase.flames_ordered:
		if not (fl is Dictionary):
			continue
		var f_dict: Dictionary = fl
		var fid: String = str(f_dict.get("id", ""))
		var fname: String = str(f_dict.get("name", fid))
		var pq: String = str(f_dict.get("phan_quyet_tier", ""))
		var ch_src: String = str(f_dict.get("chapter_source", "Chưa mở khóa"))
		var atk_m: float = float(f_dict.get("atk_mult", 1.0))
		var exp_b: float = float(f_dict.get("exp_bonus_pct", 0.0))

		var is_unlocked: bool = PlayerData.unlocked_flames.has(fid)
		var is_cur: bool = (PlayerData.equipped_flame_id == fid)

		var row := HBoxContainer.new()
		vbox.add_child(row)

		var swatch := ColorRect.new()
		swatch.custom_minimum_size = Vector2(22, 22)
		swatch.color = Color(str(f_dict.get("mid_hex", "#FF7B00"))) if is_unlocked else Color("#2A2E39")
		row.add_child(swatch)

		var txt_str: String = ""
		var txt_col: Color = Color("#6C757D")
		if is_unlocked:
			var leff: String = str(f_dict.get("lotus_effect", ""))
			txt_str = " %s  |  Phần Quyết: %s  |  ATK x%.2f  |  +%d%% EXP  |  Luyện Đan +%d%%\n    ✦ Hỏa Liên: %s" % [
				fname, pq, atk_m, int(exp_b), int(float(f_dict.get("alchemy_bonus_pct", 0.0))), leff
			]
			txt_col = Color("#FFD166") if is_cur else Color("#F8F9FA")
		else:
			txt_str = " ???  [Chưa thu phục — %s]" % ch_src
			txt_col = Color("#6C757D")

		var lbl: Label = hud._make_label(txt_str, 12, txt_col)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var btn := Button.new()
		if not is_unlocked:
			btn.text = "Khóa"
			btn.disabled = true
		elif is_cur:
			btn.text = "Đang dùng"
			btn.disabled = true
		else:
			btn.text = "Vận Chuyển"
			btn.pressed.connect(func() -> void:
				PlayerData.equip_flame(fid)
				hud.modal_status_lbl.text = "Đã vận chuyển %s — Phần Quyết: %s!" % [fname, pq]
				hud._populate_modal()
			)
		btn.add_theme_font_size_override("font_size", 12)
		row.add_child(btn)
