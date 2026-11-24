class_name PanelPauseSettings
extends RefCounted
## Panel [ESC] Menu Tạm Dừng — Save/Load 3 Ô Nạp Giới, Auto-Save, DEMO, Hiển Thị, Âm Thanh & Đổi Phím Tùy Chỉnh.

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


func build_content(vbox: VBoxContainer) -> void:
	hud.modal_title_lbl.text = "[ESC] TẠM DỪNG — TỰ ĐỘNG LƯU · CHẾ ĐỘ DEMO · 3 Ô NẠP GIỚI"

	var top_btns := HBoxContainer.new()
	top_btns.add_theme_constant_override("separation", 10)
	vbox.add_child(top_btns)

	var resume_b := Button.new()
	resume_b.text = "Tiếp Tục Tu Luyện [ESC]"
	resume_b.add_theme_font_size_override("font_size", 13)
	resume_b.pressed.connect(hud._close_modal)
	top_btns.add_child(resume_b)

	var cur_world: Node = hud._find_world()
	if cur_world != null and bool(cur_world.get("is_boss_rush_active")):
		var exit_br_b := Button.new()
		exit_br_b.text = "← Rời Tâm Ma Luyện Cảnh"
		exit_br_b.add_theme_font_size_override("font_size", 13)
		exit_br_b.add_theme_color_override("font_color", Color("#FF758F"))
		exit_br_b.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			hud._close_modal()
			if cur_world.has_method("exit_boss_rush"):
				cur_world.exit_boss_rush()
		)
		top_btns.add_child(exit_br_b)
	elif cur_world != null and bool(cur_world.get("is_tower_active")):
		var exit_tw_b := Button.new()
		exit_tw_b.text = "← Rời Thiên Phần Luyện Khí Tháp"
		exit_tw_b.add_theme_font_size_override("font_size", 13)
		exit_tw_b.add_theme_color_override("font_color", Color("#FF9F1C"))
		exit_tw_b.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			hud._close_modal()
			EventBus.tower_exit_requested.emit()
		)
		top_btns.add_child(exit_tw_b)

	var main_b := Button.new()
	main_b.text = "Lưu & Về Màn Hình Chính"
	main_b.add_theme_font_size_override("font_size", 13)
	main_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.trigger_auto_save("về menu chính", true)
		PlayerData.session_returned_to_menu = true
		hud.get_tree().paused = false
		hud.get_tree().change_scene_to_file(hud.MAIN_MENU_SCENE)
	)
	top_btns.add_child(main_b)

	var demo_b := Button.new()
	demo_b.text = "✓ Đang Ở Chế Độ DEMO FULL (Bấm [M] Dịch Chuyển)" if PlayerData.is_demo_mode else "★ Bật Chế Độ DEMO — Mở Khóa Tất Cả Ngay!"
	demo_b.add_theme_font_size_override("font_size", 13)
	demo_b.add_theme_color_override("font_color", Color("#E0AAFF"))
	demo_b.disabled = PlayerData.is_demo_mode
	demo_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("breakthrough")
		PlayerData.activate_demo_unlock_all(3)
		if PlayerData.auto_save_enabled:
			PlayerData.save_game(3, true)
		hud._close_modal()
		hud._sync_world_after_load()
		hud._refresh_all()
		hud._on_banter("ĐÃ BẬT CHẾ ĐỘ DEMO FULL (Ô 3)! Bấm [M] Dịch Chuyển Nhanh %d bản đồ (Ch01–Ch05), bấm [F] thử Phật Nộ Hỏa Liên 4 Hỏa!" % GameDatabase.maps_ordered.size())
	)
	top_btns.add_child(demo_b)

	# Khung Tùy Chọn Tự Động Lưu & Tự Động Chơi Tiếp
	var auto_card: PanelContainer = hud._make_styled_panel(Color(0.07, 0.11, 0.17, 0.94), Color("#2EC4B6"), 1, 9)
	vbox.add_child(auto_card)
	var auto_v := VBoxContainer.new()
	auto_v.add_theme_constant_override("separation", 4)
	auto_card.add_child(auto_v)

	var chk_as := CheckButton.new()
	chk_as.text = "Tự Động Lưu Dữ Liệu (Auto-Save 30s · Chuyển Map · Hoàn Thành NV · Đóng Game)"
	chk_as.button_pressed = PlayerData.auto_save_enabled
	chk_as.add_theme_font_size_override("font_size", 12)
	chk_as.add_theme_color_override("font_color", Color("#72EFDD"))
	chk_as.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.set_auto_save_enabled(on)
		hud.modal_status_lbl.text = "Đã BẬT Tự Động Lưu (Auto-Save)!" if on else "Đã TẮT Tự Động Lưu!"
	)
	auto_v.add_child(chk_as)

	var chk_ac := CheckButton.new()
	chk_ac.text = "Tự Động Vào Chơi Tiếp Bản Lưu Gần Nhất Khi Mở Game Lần Sau"
	chk_ac.button_pressed = PlayerData.auto_continue_on_start
	chk_ac.add_theme_font_size_override("font_size", 12)
	chk_ac.add_theme_color_override("font_color", Color("#FFE599"))
	chk_ac.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.set_auto_continue_on_start(on)
		hud.modal_status_lbl.text = "Lần sau mở game sẽ tự động tiếp tục từ Ô %d!" % PlayerData.active_save_slot if on else "Đã tắt tự động vào game khi khởi động."
	)
	auto_v.add_child(chk_ac)

	var aud_card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.11, 0.19, 0.94), Color("#70D6FF"), 1, 9)
	vbox.add_child(aud_card)
	var aud_v := VBoxContainer.new()
	aud_v.add_theme_constant_override("separation", 5)
	aud_card.add_child(aud_v)

	var bgm_l: Label = hud._make_label("Nhạc Nền Cổ Phong (BGM): %d%%" % int(round(AudioManager.bgm_volume * 100.0)), 13, Color("#FFE599"))
	aud_v.add_child(bgm_l)
	var bgm_s := HSlider.new()
	bgm_s.min_value = 0.0
	bgm_s.max_value = 1.0
	bgm_s.step = 0.05
	bgm_s.value = AudioManager.bgm_volume
	bgm_s.value_changed.connect(func(v: float) -> void:
		AudioManager.set_bgm_volume(v)
		PlayerData.save_user_settings()
		bgm_l.text = "Nhạc Nền Cổ Phong (BGM): %d%%" % int(round(v * 100.0))
	)
	aud_v.add_child(bgm_s)

	var sfx_l: Label = hud._make_label("Hiệu Ứng Chiến Đấu & Luyện Đan (SFX): %d%%" % int(round(AudioManager.sfx_volume * 100.0)), 13, Color("#70D6FF"))
	aud_v.add_child(sfx_l)
	var sfx_s := HSlider.new()
	sfx_s.min_value = 0.0
	sfx_s.max_value = 1.0
	sfx_s.step = 0.05
	sfx_s.value = AudioManager.sfx_volume
	sfx_s.value_changed.connect(func(v: float) -> void:
		AudioManager.set_sfx_volume(v)
		PlayerData.save_user_settings()
		sfx_l.text = "Hiệu Ứng Chiến Đấu & Luyện Đan (SFX): %d%%" % int(round(v * 100.0))
		AudioManager.play_sfx("loot_pickup", 0.0)
	)
	aud_v.add_child(sfx_s)

	# Khung Cài Đặt Hiển Thị & Cảm Giác Chiến Đấu (Fullscreen / VSync / FPS / Rung Màn Hình)
	var disp_card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.10, 0.18, 0.94), Color("#FFD166"), 1, 9)
	vbox.add_child(disp_card)
	var disp_v := VBoxContainer.new()
	disp_v.add_theme_constant_override("separation", 5)
	disp_card.add_child(disp_v)
	disp_v.add_child(hud._make_label("HIỂN THỊ & CẢM GIÁC CHIẾN ĐẤU", 13, Color("#FFD166")))

	var disp_row := HFlowContainer.new()
	disp_row.add_theme_constant_override("h_separation", 14)
	disp_row.add_theme_constant_override("v_separation", 4)
	disp_v.add_child(disp_row)

	var chk_fs := CheckButton.new()
	chk_fs.text = "Toàn Màn Hình (Fullscreen)"
	chk_fs.button_pressed = AudioManager.is_fullscreen
	chk_fs.add_theme_font_size_override("font_size", 12)
	chk_fs.add_theme_color_override("font_color", Color("#F8F9FA"))
	chk_fs.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		AudioManager.set_fullscreen(on)
		hud.modal_status_lbl.text = "Đã chuyển sang Toàn Màn Hình!" if on else "Đã chuyển về chế độ Cửa Sổ 1280×720!"
	)
	disp_row.add_child(chk_fs)

	var chk_vs := CheckButton.new()
	chk_vs.text = "Đồng Bộ Khung Hình (VSync)"
	chk_vs.button_pressed = AudioManager.vsync_enabled
	chk_vs.add_theme_font_size_override("font_size", 12)
	chk_vs.add_theme_color_override("font_color", Color("#A8DADC"))
	chk_vs.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		AudioManager.set_vsync(on)
		hud.modal_status_lbl.text = "Đã BẬT VSync (Chống xé hình)!" if on else "Đã TẮT VSync (Mở khóa FPS tối đa)!"
	)
	disp_row.add_child(chk_vs)

	var chk_fps := CheckButton.new()
	chk_fps.text = "Hiện FPS Góc Phải"
	chk_fps.button_pressed = AudioManager.show_fps
	chk_fps.add_theme_font_size_override("font_size", 12)
	chk_fps.add_theme_color_override("font_color", Color("#80ED99"))
	chk_fps.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		AudioManager.set_show_fps(on)
		hud.modal_status_lbl.text = "Đã BẬT hiển thị FPS!" if on else "Đã ẩn hiển thị FPS."
	)
	disp_row.add_child(chk_fps)

	var shk_l: Label = hud._make_label("Cường Độ Rung Màn Hình (Screen Shake): %d%%" % int(round(AudioManager.shake_scale * 100.0)), 12, Color("#FF9F1C"))
	disp_v.add_child(shk_l)
	var shk_s := HSlider.new()
	shk_s.min_value = 0.0
	shk_s.max_value = 1.0
	shk_s.step = 0.1
	shk_s.value = AudioManager.shake_scale
	shk_s.value_changed.connect(func(v: float) -> void:
		AudioManager.set_shake_scale(v)
		shk_l.text = "Cường Độ Rung Màn Hình (Screen Shake): %d%%" % int(round(v * 100.0))
	)
	disp_v.add_child(shk_s)

	# Khung Đổi Phím Tùy Chỉnh (Key Rebinding — Tự Lưu & Đồng Bộ Thanh MOBA!)
	var kb_card: PanelContainer = hud._make_styled_panel(Color(0.07, 0.09, 0.16, 0.94), Color("#C77DFF"), 1, 9)
	vbox.add_child(kb_card)
	var kb_v := VBoxContainer.new()
	kb_v.add_theme_constant_override("separation", 6)
	kb_card.add_child(kb_v)

	var kb_hdr := HBoxContainer.new()
	kb_v.add_child(kb_hdr)
	var kb_title: Label = hud._make_label("ĐỔI PHÍM TÙY CHỈNH (KEY REBINDING — Bấm ô phím rồi nhấn phím mới)", 13, Color("#E0AAFF"))
	kb_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kb_hdr.add_child(kb_title)

	var kb_reset := Button.new()
	kb_reset.text = "Khôi Phục Mặc Định"
	kb_reset.add_theme_font_size_override("font_size", 11)
	kb_reset.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.rebinding_action = ""
		AudioManager.reset_default_keybinds()
		hud.modal_status_lbl.text = "Đã khôi phục toàn bộ phím điều khiển mặc định!"
		hud._populate_modal()
	)
	kb_hdr.add_child(kb_reset)

	var kb_grid := HFlowContainer.new()
	kb_grid.add_theme_constant_override("h_separation", 8)
	kb_grid.add_theme_constant_override("v_separation", 6)
	kb_v.add_child(kb_grid)

	var kb_specs: Array = [
		["move_up", "Đi Lên"], ["move_down", "Đi Xuống"], ["move_left", "Sang Trái"], ["move_right", "Sang Phải"],
		["dash", "Lướt Né"], ["interact", "Tương Tác"], ["skill_q", "Đấu Kỹ 1"], ["skill_e", "Đấu Kỹ 2"],
		["skill_r", "Đấu Kỹ 3"], ["skill_ult", "Hỏa Liên"], ["skill_assist", "Trợ Chiến"],
		["toggle_weight", "Trọng Áp"], ["toggle_companion", "Đồng Hành"], ["soul_radar", "Radar Hồn"]
	]
	for spec in kb_specs:
		var act_k: String = str(spec[0])
		var act_lbl: String = str(spec[1])
		var is_wait: bool = (hud.rebinding_action == act_k)
		var kb_btn := Button.new()
		kb_btn.text = "%s: [Nhấn phím...]" % act_lbl if is_wait else "%s: [%s]" % [act_lbl, AudioManager.get_action_key_label(act_k)]
		kb_btn.add_theme_font_size_override("font_size", 11)
		if is_wait:
			kb_btn.add_theme_color_override("font_color", Color("#FFD166"))
		kb_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			hud.rebinding_action = act_k
			hud.modal_status_lbl.text = "Đang đổi phím [%s] — Hãy nhấn phím bất kỳ trên bàn phím (ESC để hủy)!" % act_lbl
			hud._populate_modal()
		)
		kb_grid.add_child(kb_btn)

	vbox.add_child(hud._make_label("3 Ô LƯU TIẾN ĐỘ NẠP GIỚI (Ô hiện tại: Ô %d)" % PlayerData.active_save_slot, 14, Color("#FFD166")))
	for s in range(1, PlayerData.MAX_SAVE_SLOTS + 1):
		var info: Dictionary = PlayerData.get_save_slot_summary(s)
		var exists: bool = bool(info.get("exists", false))
		var card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.10, 0.17, 0.94), Color("#FFD166") if exists else Color("#495057"), 1, 8)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		card.add_child(row)

		var l: Label = hud._make_label(str(info.get("label", "")), 13, Color("#F8F9FA") if exists else Color("#ADB5BD"))
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)

		var slot_n: int = s
		var save_b := Button.new()
		save_b.text = "Lưu Vào Ô %d" % slot_n
		save_b.pressed.connect(func() -> void:
			if PlayerData.save_game(slot_n):
				hud.modal_status_lbl.text = "Đã lưu thành công vào Ô %d!" % slot_n
				hud._populate_modal()
		)
		row.add_child(save_b)

		var load_b := Button.new()
		load_b.text = "Tải Ô %d" % slot_n
		load_b.disabled = not exists
		load_b.pressed.connect(func() -> void:
			if PlayerData.load_game(slot_n):
				hud._close_modal()
				hud._sync_world_after_load()
				hud._refresh_all()
				hud._on_banter("Đã tải tiến độ từ Ô Lưu %d!" % slot_n)
		)
		row.add_child(load_b)
