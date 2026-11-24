class_name PanelWorldMapBestiary
extends RefCounted
## Panel [M] Bản Đồ Thế Giới (25 Map), Hồng Nhan Tri Kỷ (Buff · Tặng Quà) & Đồ Giám Vạn Thú.

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


func build_content(vbox: VBoxContainer) -> void:
	var total_maps: int = GameDatabase.maps_ordered.size()
	hud.modal_title_lbl.text = "[M] THẾ GIỚI (%d MAP) • HỒNG NHAN • TÂM MA • THIÊN PHẦN THÁP • ĐỒ GIÁM" % total_maps
	vbox.add_theme_constant_override("separation", 6)

	var tab_row := HFlowContainer.new()
	tab_row.add_theme_constant_override("h_separation", 7)
	tab_row.add_theme_constant_override("v_separation", 6)
	vbox.add_child(tab_row)

	var unclaimed_gifts: int = 0
	for prof in PlayerData.get_heroine_profiles():
		var hk: String = str(prof.get("key", ""))
		var cur_a: int = PlayerData.get_affection(hk)
		for ms in prof.get("milestones", []):
			var req_v: int = int(ms.get("req", 999))
			if ms.has("gift_items") and cur_a >= req_v and not PlayerData.is_affection_milestone_claimed(hk, req_v):
				unclaimed_gifts += 1

	var tab_maps_btn := Button.new()
	tab_maps_btn.text = ("★ " if hud.world_map_tab == "maps" else "") + "Bản Đồ (%d)" % total_maps
	tab_maps_btn.disabled = (hud.world_map_tab == "maps")
	tab_maps_btn.add_theme_font_size_override("font_size", 12)
	tab_maps_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.world_map_tab = "maps"
		hud._populate_modal()
	)
	tab_row.add_child(tab_maps_btn)

	var gift_badge: String = " [%d QUÀ!]" % unclaimed_gifts if unclaimed_gifts > 0 else ""
	var tab_her_btn := Button.new()
	tab_her_btn.text = ("★ " if hud.world_map_tab == "heroines" else "") + "Hồng Nhan" + gift_badge
	tab_her_btn.disabled = (hud.world_map_tab == "heroines")
	tab_her_btn.add_theme_font_size_override("font_size", 12)
	tab_her_btn.add_theme_color_override("font_color", Color("#FFD166") if unclaimed_gifts > 0 else Color("#E0AAFF"))
	tab_her_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.world_map_tab = "heroines"
		hud._populate_modal()
	)
	tab_row.add_child(tab_her_btn)

	var tab_br_btn := Button.new()
	tab_br_btn.text = ("★ " if hud.world_map_tab == "boss_rush" else "") + "⚔ Tâm Ma Luyện Cảnh"
	tab_br_btn.disabled = (hud.world_map_tab == "boss_rush")
	tab_br_btn.add_theme_font_size_override("font_size", 12)
	tab_br_btn.add_theme_color_override("font_color", Color("#FF758F"))
	tab_br_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.world_map_tab = "boss_rush"
		hud._populate_modal()
	)
	tab_row.add_child(tab_br_btn)

	var tab_best_btn := Button.new()
	tab_best_btn.text = ("★ " if hud.world_map_tab == "bestiary" else "") + "📖 Đồ Giám Vạn Thú"
	tab_best_btn.disabled = (hud.world_map_tab == "bestiary")
	tab_best_btn.add_theme_font_size_override("font_size", 12)
	tab_best_btn.add_theme_color_override("font_color", Color("#72EFDD"))
	tab_best_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.world_map_tab = "bestiary"
		hud._populate_modal()
	)
	tab_row.add_child(tab_best_btn)

	var tab_tw_btn := Button.new()
	tab_tw_btn.text = ("★ " if hud.world_map_tab == "tower" else "") + "🔥 Thiên Phần Tháp"
	tab_tw_btn.disabled = (hud.world_map_tab == "tower")
	tab_tw_btn.add_theme_font_size_override("font_size", 12)
	tab_tw_btn.add_theme_color_override("font_color", Color("#FF9F1C"))
	tab_tw_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.world_map_tab = "tower"
		hud._populate_modal()
	)
	tab_row.add_child(tab_tw_btn)

	if hud.world_map_tab == "heroines":
		build_heroines_tab(vbox)
		return
	elif hud.world_map_tab == "boss_rush":
		hud.panel_tower_boss_rush.build_boss_rush_tab(vbox)
		return
	elif hud.world_map_tab == "bestiary":
		build_bestiary_tab(vbox)
		return
	elif hud.world_map_tab == "tower":
		hud.panel_tower_boss_rush.build_tower_tab(vbox)
		return

	# 1. Tóm tắt Buff Hồng Nhan & Kỳ Vật Cốt Truyện
	var lore_card: PanelContainer = hud._make_styled_panel(Color(0.11, 0.08, 0.16, 0.94), Color("#E0AAFF"), 1, 7)
	vbox.add_child(lore_card)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 3)
	lore_card.add_child(lv)
	lv.add_child(hud._make_label(
		"HỒNG NHAN:  Huân Nhi %d  |  Tiểu Y Tiên %d  |  Vân Chi %d  |  Thanh Lân %d  |  Thải Lân %d" % [
			PlayerData.get_affection("huan_nhi"),
			PlayerData.get_affection("tieu_y_tien"),
			PlayerData.get_affection("van_chi"),
			PlayerData.get_affection("thanh_lan"),
			PlayerData.get_affection("my_do_toa")
		],
		12,
		Color("#FFD166")
	))
	var buff_l: Label = hud._make_label("Buff Hảo Cảm Đang Kích Hoạt: " + PlayerData.get_active_affection_summary_text(), 11, Color("#80ED99"))
	buff_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(buff_l)
	var relic_txt: String = " · ".join(PlayerData.story_relics) if not PlayerData.story_relics.is_empty() else "(Chưa thu thập — Hãy hoàn thành các mốc cốt truyện & kỳ ngộ ẩn!)"
	var rl: Label = hud._make_label("Kỳ Vật & Danh Hiệu Đã Đạt (%d): %s" % [PlayerData.story_relics.size(), relic_txt], 11, Color("#A8DADC"))
	rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(rl)

	var last_chapter: String = ""
	for mid in GameDatabase.maps_ordered:
		var m_def: Dictionary = GameDatabase.get_map_def(str(mid))
		if m_def.is_empty():
			continue
		var ch_lbl: String = str(m_def.get("chapter", ""))
		if ch_lbl != "" and ch_lbl != last_chapter:
			last_chapter = ch_lbl
			var ch_hdr: Label = hud._make_label("═══ %s ═══" % ch_lbl.to_upper(), 13, Color("#70D6FF"))
			vbox.add_child(ch_hdr)
		var is_here: bool = (PlayerData.current_map_id == str(mid))
		var ch_list: Array = m_def.get("chests", [])
		var opened_cnt: int = 0
		for c in ch_list:
			if c is Dictionary and PlayerData.is_chest_opened(str(c.get("id", ""))):
				opened_cnt += 1

		var border_c: Color = Color("#FFD166") if is_here else Color("#3A506B")
		var card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.11, 0.19, 0.94), border_c, 2 if is_here else 1, 5)
		vbox.add_child(card)
		var row_m := HBoxContainer.new()
		row_m.add_theme_constant_override("separation", 8)
		card.add_child(row_m)

		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_theme_constant_override("separation", 1)
		row_m.add_child(v)

		var here_tag: String = "   [★ BẠN ĐANG Ở ĐÂY]" if is_here else ""
		v.add_child(hud._make_label("%s — %s%s" % [str(m_def.get("chapter", "")), str(m_def.get("name", "")), here_tag], 12, Color("#FFD166") if is_here else Color("#F8F9FA")))

		var npc_names: Array = []
		for n in m_def.get("npcs", []):
			if n is Dictionary:
				npc_names.append(str(n.get("name", "")))
		var npc_str: String = ", ".join(npc_names) if not npc_names.is_empty() else "(Khu bí cảnh chiến đấu)"
		v.add_child(hud._make_label("• NPC: %s   |   Bảo Rương: %d / %d đã mở" % [npc_str, opened_cnt, ch_list.size()], 11, Color("#CED4DA")))

		if PlayerData.is_demo_mode and not is_here:
			var target_mid: String = str(mid)
			var tp_btn := Button.new()
			tp_btn.text = "Dịch Chuyển ->"
			tp_btn.add_theme_font_size_override("font_size", 12)
			tp_btn.add_theme_color_override("font_color", Color("#E0AAFF"))
			tp_btn.pressed.connect(func() -> void:
				AudioManager.play_sfx("portal_warp")
				hud._close_modal()
				var w: Node = hud._find_world()
				if w != null and w.has_method("load_map"):
					w.load_map(target_mid, Vector2.ZERO, true)
			)
			row_m.add_child(tp_btn)


func build_heroines_tab(vbox: VBoxContainer) -> void:
	var sum_card: PanelContainer = hud._make_styled_panel(Color(0.11, 0.08, 0.17, 0.95), Color("#FFD166"), 1, 8)
	vbox.add_child(sum_card)
	var sum_v := VBoxContainer.new()
	sum_v.add_theme_constant_override("separation", 3)
	sum_card.add_child(sum_v)
	sum_v.add_child(hud._make_label("TỔNG BUFF HẢO CẢM HỒNG NHAN ĐANG KÍCH HOẠT (CỘNG THẲNG VÀO CHỈ SỐ TIÊU VIÊM):", 12, Color("#FFD166")))
	var s_lbl: Label = hud._make_label(PlayerData.get_active_affection_summary_text(), 12, Color("#80ED99"))
	s_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sum_v.add_child(s_lbl)

	var gift_card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.11, 0.17, 0.94), Color("#2EC4B6"), 1, 8)
	vbox.add_child(gift_card)
	var gv := VBoxContainer.new()
	gv.add_theme_constant_override("separation", 5)
	gift_card.add_child(gv)

	var sel_name: String = hud.selected_gift_heroine
	var sel_favs: Array = []
	var sel_fav_hint: String = ""
	for p in PlayerData.get_heroine_profiles():
		if str(p.get("key", "")) == hud.selected_gift_heroine:
			sel_name = str(p.get("name", ""))
			sel_favs = p.get("favorite_items", [])
			sel_fav_hint = str(p.get("fav_hint", ""))
			break
	gv.add_child(hud._make_label("TẶNG QUÀ TĂNG HẢO CẢM -> Đang chọn: %s (%d/100)  |  Sở thích (x2 điểm): %s" % [
		sel_name, PlayerData.get_affection(hud.selected_gift_heroine), sel_fav_hint
	], 12, Color("#72EFDD")))

	var gift_flow := HFlowContainer.new()
	gift_flow.add_theme_constant_override("h_separation", 6)
	gift_flow.add_theme_constant_override("v_separation", 5)
	gv.add_child(gift_flow)

	var any_gift: bool = false
	for iid in PlayerData.inventory.keys():
		var cnt: int = int(PlayerData.inventory[iid])
		if cnt <= 0:
			continue
		var idef: Dictionary = GameDatabase.get_item_def(str(iid))
		if str(idef.get("type", "")) == "breakthrough":
			continue
		any_gift = true
		var is_fav: bool = sel_favs.has(str(iid))
		var item_key: String = str(iid)
		var gb := Button.new()
		gb.text = "%s%s (x%d)" % ["★ " if is_fav else "", str(idef.get("name", item_key)), cnt]
		gb.add_theme_font_size_override("font_size", 11)
		if is_fav:
			gb.add_theme_color_override("font_color", Color("#FFD166"))
		gb.pressed.connect(func() -> void:
			var res: Dictionary = PlayerData.give_gift_to_heroine(hud.selected_gift_heroine, item_key)
			hud.modal_status_lbl.text = str(res.get("msg", ""))
			hud._populate_modal()
		)
		gift_flow.add_child(gb)
	if not any_gift:
		gv.add_child(hud._make_label("(Nạp Giới chưa có thảo dược / ma hạch / đan dược nào để tặng — hãy đánh quái hoặc mua tại Nhã Phi!)", 11, Color("#ADB5BD")))

	for prof in PlayerData.get_heroine_profiles():
		var hk: String = str(prof.get("key", ""))
		var col := Color(str(prof.get("color", "#FFD166")))
		var cur_a: int = PlayerData.get_affection(hk)
		var is_sel: bool = (hk == hud.selected_gift_heroine)
		var card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.10, 0.17, 0.95), col if is_sel else Color("#3A4760"), 2 if is_sel else 1, 7)
		vbox.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		row.add_child(hud._make_icon_box(str(prof.get("sprite", "res://assets/sprites/npcs/npc_huan_nhi.png")), col, 52))

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_v.add_theme_constant_override("separation", 3)
		row.add_child(info_v)

		var hdr := HBoxContainer.new()
		hdr.add_theme_constant_override("separation", 8)
		info_v.add_child(hdr)

		var nm_l: Label = hud._make_label("%s  <%s>  —  Hảo Cảm: %d / 100" % [str(prof.get("name", "")), str(prof.get("title", "")), cur_a], 13, col)
		nm_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hdr.add_child(nm_l)

		var sel_b := Button.new()
		sel_b.text = "Đang Chọn Tặng Quà" if is_sel else "Chọn Tặng Quà"
		sel_b.disabled = is_sel
		sel_b.add_theme_font_size_override("font_size", 11)
		sel_b.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			hud.selected_gift_heroine = hk
			hud._populate_modal()
		)
		hdr.add_child(sel_b)

		var pbar: ProgressBar = hud._make_bar(col, 9, 400)
		pbar.max_value = 100.0
		pbar.value = float(cur_a)
		info_v.add_child(pbar)

		var ms_flow := HFlowContainer.new()
		ms_flow.add_theme_constant_override("h_separation", 8)
		ms_flow.add_theme_constant_override("v_separation", 4)
		info_v.add_child(ms_flow)

		for ms in prof.get("milestones", []):
			var req_v: int = int(ms.get("req", 25))
			var reached: bool = (cur_a >= req_v)
			var desc_m: String = str(ms.get("desc", ""))
			var m_lbl: Label = hud._make_label("%s [%d]: %s" % ["✓" if reached else "○", req_v, desc_m], 11, Color("#80ED99") if reached else Color("#868E96"))
			ms_flow.add_child(m_lbl)

			if ms.has("gift_items") and reached:
				var claimed: bool = PlayerData.is_affection_milestone_claimed(hk, req_v)
				var cb := Button.new()
				cb.text = "Đã nhận quà %d" % req_v if claimed else "★ Nhận Quà Mốc %d!" % req_v
				cb.disabled = claimed
				cb.add_theme_font_size_override("font_size", 11)
				if not claimed:
					cb.add_theme_color_override("font_color", Color("#FFD166"))
				cb.pressed.connect(func() -> void:
					var res: Dictionary = PlayerData.claim_affection_milestone(hk, req_v)
					hud.modal_status_lbl.text = str(res.get("msg", ""))
					hud._populate_modal()
				)
				ms_flow.add_child(cb)


func build_bestiary_tab(vbox: VBoxContainer) -> void:
	var all_enemies: Array = []
	var total_bosses: int = 0
	var defeated_species: int = 0
	var total_kills: int = 0
	for eid in GameDatabase.enemies_by_id.keys():
		var ed: Dictionary = GameDatabase.get_enemy_def(str(eid))
		all_enemies.append(ed)
		if bool(ed.get("is_boss", false)):
			total_bosses += 1
		var kc: int = PlayerData.get_enemy_kill_count(str(eid))
		if kc > 0:
			defeated_species += 1
			total_kills += kc

	all_enemies.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra: int = int(a.get("realm_index", 1))
		var rb: int = int(b.get("realm_index", 1))
		if ra != rb:
			return ra < rb
		var ba: int = 1 if bool(a.get("is_boss", false)) else 0
		var bb: int = 1 if bool(b.get("is_boss", false)) else 0
		if ba != bb:
			return ba < bb
		return float(a.get("max_hp", 0)) < float(b.get("max_hp", 0))
	)

	var sum_card: PanelContainer = hud._make_styled_panel(Color(0.06, 0.11, 0.15, 0.95), Color("#72EFDD"), 2, 9)
	vbox.add_child(sum_card)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 5)
	sum_card.add_child(sv)
	sv.add_child(hud._make_label("📖 ĐỒ GIÁM VẠN THÚ — %d / %d LOÀI ĐÃ TIÊU DIỆT (%d BOSS · %d QUÁI · TỔNG %d TRẬN HẠ)" % [
		defeated_species, all_enemies.size(), total_bosses, all_enemies.size() - total_bosses, total_kills
	], 13, Color("#72EFDD")))

	var f_row := HBoxContainer.new()
	f_row.add_theme_constant_override("separation", 8)
	sv.add_child(f_row)
	for fs in [
		{ "k": "all", "t": "Tất Cả (%d)" % all_enemies.size() },
		{ "k": "boss", "t": "Đại Boss (%d)" % total_bosses },
		{ "k": "mob", "t": "Ma Thú & Quái Thường (%d)" % (all_enemies.size() - total_bosses) }
	]:
		var fk: String = str(fs["k"])
		var fb := Button.new()
		fb.text = ("★ " if hud.bestiary_filter == fk else "") + str(fs["t"])
		fb.disabled = (hud.bestiary_filter == fk)
		fb.add_theme_font_size_override("font_size", 11)
		fb.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			hud.bestiary_filter = fk
			hud._populate_modal()
		)
		f_row.add_child(fb)

	for ed in all_enemies:
		var is_b: bool = bool(ed.get("is_boss", false))
		if hud.bestiary_filter == "boss" and not is_b:
			continue
		if hud.bestiary_filter == "mob" and is_b:
			continue
		var eid: String = str(ed.get("id", ""))
		var kills: int = PlayerData.get_enemy_kill_count(eid)
		var border_c: Color = (Color("#FF4D6D") if is_b else Color("#52B788")) if kills > 0 else Color("#343A40")

		var card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.10, 0.16, 0.94), border_c, 1, 6)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		var icon_box: PanelContainer = hud._make_icon_box_from_tex(hud._get_enemy_thumb_tex(ed), border_c, 44)
		if kills <= 0:
			icon_box.modulate = Color(0.55, 0.58, 0.65, 0.80)
		row.add_child(icon_box)

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_v.add_theme_constant_override("separation", 1)
		row.add_child(info_v)

		var kind_tag: String = "[ĐẠI BOSS]" if is_b else "[QUÁI]"
		var map_id_tag: String = str(ed.get("map_tag", ""))
		var map_name: String = str(GameDatabase.get_map_def(map_id_tag).get("name", map_id_tag))
		info_v.add_child(hud._make_label("%s %s  <%s>   |   Khu vực: %s" % [
			kind_tag, str(ed.get("name", eid)), str(ed.get("realm_label", "")), map_name
		], 12, Color("#FFD166") if is_b else Color("#F8F9FA")))

		info_v.add_child(hud._make_label("HP: %d  ·  ATK: %d  ·  DEF: %d  ·  Thưởng: %d EXP / %d Kim Tệ" % [
			int(ed.get("max_hp", 0)), int(ed.get("atk", 0)), int(ed.get("def", 0)),
			int(ed.get("exp_reward", 0)), int(ed.get("gold_reward", 0))
		], 11, Color("#CED4DA")))

		var drop_names: Array = []
		for dr in ed.get("drops", []):
			if dr is Dictionary:
				var it_id: String = str(dr.get("item_id", ""))
				var it_def: Dictionary = GameDatabase.get_item_def(it_id)
				drop_names.append(str(it_def.get("name", it_id)))
		var drop_txt: String = ", ".join(drop_names) if not drop_names.is_empty() else "Trang bị & Nguyên liệu ngẫu nhiên"
		var dl: Label = hud._make_label("Vật phẩm rơi: %s" % drop_txt, 10, Color("#A8DADC"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(dl)

		var k_lbl: Label = hud._make_label("Đã hạ: %d" % kills if kills > 0 else "Chưa gặp", 12, Color("#80ED99") if kills > 0 else Color("#6C757D"))
		row.add_child(k_lbl)
