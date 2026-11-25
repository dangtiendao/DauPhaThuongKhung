class_name PanelAchievements
extends RefCounted
## Panel Thành Tựu & Danh Hiệu Vinh Quang (v1.1.0 — tích hợp tab trong [M] và nút nhanh trong [ESC]).

const AchMgr = preload("res://scripts/systems/achievement_manager.gd")

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


func build_achievements_tab(vbox: VBoxContainer) -> void:
	var sum: Dictionary = AchMgr.get_summary(PlayerData)
	var active_tag: String = AchMgr.get_active_title_display(PlayerData)
	var sum_card: PanelContainer = hud._make_styled_panel(Color(0.11, 0.08, 0.16, 0.96), Color("#FFD700"), 2, 10)
	vbox.add_child(sum_card)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 5)
	sum_card.add_child(sv)

	var pct: int = int(round(100.0 * float(sum["unlocked"]) / float(maxi(1, int(sum["total"])))))
	sv.add_child(hud._make_label(
		"🏆 THÀNH TỰU & DANH HIỆU VINH QUANG — %d / %d (%d%%)   |   Cúp Bạch Kim: %d / %d" % [
			int(sum["unlocked"]), int(sum["total"]), pct, int(sum["platinum_unlocked"]), int(sum["platinum_total"])
		],
		14, Color("#FFD700")
	))

	var pbar: ProgressBar = hud._make_bar(Color("#FFD700"), 10, 520)
	pbar.max_value = float(maxi(1, int(sum["total"])))
	pbar.value = float(int(sum["unlocked"]))
	sv.add_child(pbar)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	sv.add_child(title_row)
	var cur_t_lbl: Label = hud._make_label(
		"Danh Hiệu Đang Đeo: %s" % (active_tag if active_tag != "" else "(Chưa đeo — chọn 'Đeo Danh Hiệu' ở thành tựu đã mở!)"),
		12, Color("#72EFDD") if active_tag != "" else Color("#ADB5BD")
	)
	cur_t_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(cur_t_lbl)
	if active_tag != "":
		var clear_btn := Button.new()
		clear_btn.text = "Gỡ Danh Hiệu"
		clear_btn.add_theme_font_size_override("font_size", 11)
		clear_btn.pressed.connect(func() -> void:
			var res: Dictionary = AchMgr.equip_title(PlayerData, "")
			hud.modal_status_lbl.text = str(res.get("msg", ""))
			hud._populate_modal()
		)
		title_row.add_child(clear_btn)

	# Bộ lọc nhóm Thành Tựu
	var f_row := HBoxContainer.new()
	f_row.add_theme_constant_override("separation", 8)
	sv.add_child(f_row)
	for spec in [
		{ "k": "all", "t": "Tất Cả (%d)" % int(sum["total"]) },
		{ "k": "story", "t": "★ Cốt Truyện & Bạch Kim (9)" },
		{ "k": "grind", "t": "⚔ Tu Luyện & Cày Cuốc (11)" }
	]:
		var fk: String = str(spec["k"])
		var fb := Button.new()
		fb.text = ("★ " if hud.achievements_filter == fk else "") + str(spec["t"])
		fb.disabled = (hud.achievements_filter == fk)
		fb.add_theme_font_size_override("font_size", 11)
		fb.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			hud.achievements_filter = fk
			hud._populate_modal()
		)
		f_row.add_child(fb)

	var tier_colors: Dictionary = {
		"platinum": Color("#72EFDD"),
		"gold": Color("#FFD166"),
		"silver": Color("#C77DFF"),
		"bronze": Color("#FF9F1C")
	}
	var tier_labels: Dictionary = {
		"platinum": "BẠCH KIM",
		"gold": "HOÀNG KIM",
		"silver": "BẠCH NGÂN",
		"bronze": "THANH ĐỒNG"
	}

	for d in AchMgr.get_all_definitions():
		var cat: String = str(d.get("category", "story"))
		if hud.achievements_filter != "all" and hud.achievements_filter != cat:
			continue
		var ev: Dictionary = AchMgr.evaluate_achievement(PlayerData, d)
		var is_done: bool = bool(ev["unlocked"])
		var aid: String = str(d.get("id", ""))
		var tier_k: String = str(d.get("tier", "gold"))
		var col: Color = (tier_colors.get(tier_k, Color("#FFD166")) as Color) if is_done else Color("#495057")
		var is_eq: bool = (PlayerData.active_title_id == aid and is_done)

		var card: PanelContainer = hud._make_styled_panel(
			Color(0.08, 0.11, 0.17, 0.95) if is_done else Color(0.06, 0.07, 0.11, 0.92),
			Color("#80ED99") if is_eq else col,
			2 if (is_eq or (is_done and tier_k == "platinum")) else 1,
			7
		)
		vbox.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		var iv := VBoxContainer.new()
		iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		iv.add_theme_constant_override("separation", 2)
		row.add_child(iv)

		var status_sym: String = "🏆" if (is_done and tier_k == "platinum") else ("★" if is_done else "🔒")
		iv.add_child(hud._make_label(
			"%s [%s · %s] %s   —   Danh hiệu: 《%s》" % [
				status_sym, str(d.get("code", "")), str(tier_labels.get(tier_k, "HOÀNG KIM")),
				str(d.get("name", "")), str(d.get("title_tag", ""))
			],
			12, col if is_done else Color("#ADB5BD")
		))

		var dl: Label = hud._make_label(str(d.get("desc", "")), 11, Color("#DEE2E6") if is_done else Color("#868E96"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		iv.add_child(dl)

		iv.add_child(hud._make_label(
			"• Tiến độ: %s   |   Phần thưởng: %s" % [str(ev["progress_text"]), str(d.get("reward", ""))],
			11, Color("#80ED99") if is_done else Color("#FFD166")
		))

		var act_btn := Button.new()
		act_btn.add_theme_font_size_override("font_size", 11)
		if is_eq:
			act_btn.text = "✓ Đang Đeo"
			act_btn.disabled = true
		elif is_done:
			act_btn.text = "Đeo Danh Hiệu"
			act_btn.add_theme_color_override("font_color", Color("#FFD700"))
			var cap_id: String = aid
			act_btn.pressed.connect(func() -> void:
				var res: Dictionary = AchMgr.equip_title(PlayerData, cap_id)
				hud.modal_status_lbl.text = str(res.get("msg", ""))
				hud._populate_modal()
			)
		else:
			act_btn.text = "Chưa Mở"
			act_btn.disabled = true
		row.add_child(act_btn)
