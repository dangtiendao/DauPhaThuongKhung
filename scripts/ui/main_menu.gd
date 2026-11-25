extends Control
## Màn Hình Chính (Title Screen) Chuẩn HD 32-bit Pixel Art:
## - Hỗ trợ: Tiếp Tục (nhớ đúng Ô chơi gần nhất), Chơi Mới (Chuẩn Cốt Truyện),
##   CHẾ ĐỘ DEMO — MỞ KHÓA TẤT CẢ (31 Map · Full 17 Kỹ · 28 Hỏa · 5 Đồng Hành · Bàn Môn · Đấu Vương Hóa Dực),
##   Tùy chọn TỰ ĐỘNG LƯU (Auto-Save) & TỰ ĐỘNG VÀO CHƠI TIẾP LẦN SAU!

const GAME_SCENE_PATH: String = "res://scenes/main_prototype.tscn"

var sub_panel: PanelContainer
var sub_title_lbl: Label
var sub_body_vbox: VBoxContainer
var status_lbl: Label
var continue_btn: Button

var auto_resume_banner: PanelContainer
var auto_resume_lbl: Label
var auto_resume_countdown: float = -1.0
var auto_resume_target_slot: int = -1


func _ready() -> void:
	get_tree().paused = false
	_build_title_ui()
	AudioManager.play_bgm("bgm_peaceful")
	_check_auto_continue_on_start()


func _process(delta: float) -> void:
	if auto_resume_countdown > 0.0:
		auto_resume_countdown -= delta
		if auto_resume_lbl != null:
			auto_resume_lbl.text = "Tự động vào tiếp Ô %d sau %.1fs..." % [auto_resume_target_slot, maxf(0.0, auto_resume_countdown)]
		if auto_resume_countdown <= 0.0:
			auto_resume_countdown = -1.0
			_execute_continue_slot(auto_resume_target_slot)


func _check_auto_continue_on_start() -> void:
	if not PlayerData.auto_continue_on_start or PlayerData.session_returned_to_menu:
		return
	var best_slot: int = PlayerData.get_best_continue_slot()
	if best_slot == -1:
		return
	auto_resume_target_slot = best_slot
	auto_resume_countdown = 1.6
	if auto_resume_banner != null:
		auto_resume_banner.visible = true


func _cancel_auto_continue() -> void:
	auto_resume_countdown = -1.0
	if auto_resume_banner != null:
		auto_resume_banner.visible = false


func _build_title_ui() -> void:
	# 1. Hình nền HD Pixel Art toàn màn hình
	var bg := TextureRect.new()
	bg.texture = load("res://assets/sprites/ui/title_backdrop.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)

	# Lớp phủ tối nhẹ bên trái giúp chữ vàng & nút bấm nổi bật tuyệt đối
	var left_tint := ColorRect.new()
	left_tint.color = Color(0.03, 0.04, 0.09, 0.68)
	left_tint.anchor_left = 0.0
	left_tint.anchor_right = 0.45
	left_tint.anchor_top = 0.0
	left_tint.anchor_bottom = 1.0
	left_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left_tint)

	# Tàn lửa Dị Hỏa bay lên sống động
	var embers := CPUParticles2D.new()
	embers.position = Vector2(760, 690)
	embers.emitting = true
	embers.amount = 38
	embers.lifetime = 4.2
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	embers.emission_rect_extents = Vector2(560, 40)
	embers.direction = Vector2(-0.25, -1.0)
	embers.spread = 35.0
	embers.gravity = Vector2(0, -14)
	embers.initial_velocity_min = 24.0
	embers.initial_velocity_max = 62.0
	embers.scale_amount_min = 2.5
	embers.scale_amount_max = 5.0
	embers.color = Color("#FFAE42")
	add_child(embers)

	# 2. Khung Tiêu Đề & Menu Chính (Cột Trái)
	var menu_col := VBoxContainer.new()
	menu_col.anchor_left = 0.0
	menu_col.anchor_top = 0.0
	menu_col.anchor_bottom = 1.0
	menu_col.offset_left = 48
	menu_col.offset_top = 34
	menu_col.offset_right = 528
	menu_col.offset_bottom = -24
	menu_col.add_theme_constant_override("separation", 8)
	add_child(menu_col)

	var badge_lbl := _make_label("OFFICIAL RELEASE v1.0.0  •  TRỌN BỘ 4/4 QUYỂN (11/11 CHƯƠNG · ĐẠI KẾT CỤC VIÊM ĐẾ)", 12, Color("#70D6FF"))
	menu_col.add_child(badge_lbl)

	var title_lbl := _make_label("ĐẤU PHÁ\nTHƯƠNG KHUNG", 40, Color("#FFD166"))
	title_lbl.add_theme_constant_override("outline_size", 8)
	menu_col.add_child(title_lbl)

	var sub_lbl := _make_label("Ô Thản Thành · Già Nam · Trung Châu · Thiên Mộ · Bồ Đề Hóa Thánh · Đà Xá Cổ Đế Động Phủ · Song Đế Chiến & Đại Thiên Thế Giới", 13, Color("#E9ECEF"))
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_col.add_child(sub_lbl)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 6)
	menu_col.add_child(spacer)

	# Nút 1: Tiếp tục chơi (nhớ đúng Ô chơi gần nhất)
	continue_btn = _make_menu_button("TIẾP TỤC TU LUYỆN", Color("#FFD166"))
	continue_btn.pressed.connect(_on_continue_pressed)
	menu_col.add_child(continue_btn)
	_refresh_continue_button()

	# Nút 2: Bắt đầu mới chuẩn nguyên tác (Ô 1)
	var new_btn := _make_menu_button("BẮT ĐẦU HÀNH TRÌNH MỚI (CHUẨN CỐT TRUYỆN)", Color("#80ED99"))
	new_btn.pressed.connect(_on_new_game_pressed)
	menu_col.add_child(new_btn)

	# Nút 3: OPTION 1 — CHẾ ĐỘ DEMO (MỞ KHÓA TẤT CẢ!)
	var demo_btn := _make_menu_button("★ CHẾ ĐỘ DEMO — MỞ KHÓA TẤT CẢ (%d MAP · VIÊM ĐẾ 23 DỊ HỎA)" % GameDatabase.maps_ordered.size(), Color("#E0AAFF"))
	demo_btn.pressed.connect(_on_demo_unlock_all_pressed)
	menu_col.add_child(demo_btn)

	# Nút 4: Chọn 3 Ô Lưu
	var slots_btn := _make_menu_button("QUẢN LÝ 3 Ô LƯU NẠP GIỚI", Color("#70D6FF"))
	slots_btn.pressed.connect(_open_slots_panel)
	menu_col.add_child(slots_btn)

	# Hàng nút phụ gọn gàng: Âm Thanh | Hướng Dẫn | Thoát
	var util_row := HBoxContainer.new()
	util_row.add_theme_constant_override("separation", 8)
	menu_col.add_child(util_row)

	var audio_btn := _make_compact_button("Âm Thanh", Color("#E9ECEF"))
	audio_btn.pressed.connect(_open_audio_panel)
	util_row.add_child(audio_btn)

	var help_btn := _make_compact_button("Điều Khiển", Color("#E9ECEF"))
	help_btn.pressed.connect(_open_controls_panel)
	util_row.add_child(help_btn)

	var quit_btn := _make_compact_button("Thoát Game", Color("#FF758F"))
	quit_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.save_user_settings()
		get_tree().quit()
	)
	util_row.add_child(quit_btn)

	# Khung OPTION 2 — TÙY CHỌN TỰ ĐỘNG LƯU & TỰ ĐỘNG CHƠI TIẾP
	var auto_card := _make_styled_panel(Color(0.06, 0.09, 0.16, 0.92), Color("#2EC4B6"), 2, 10)
	menu_col.add_child(auto_card)

	var auto_v := VBoxContainer.new()
	auto_v.add_theme_constant_override("separation", 4)
	auto_card.add_child(auto_v)

	auto_v.add_child(_make_label("TÙY CHỌN LƯU & CHƠI TIẾP TỰ ĐỘNG", 12, Color("#72EFDD")))

	var chk_autosave := CheckButton.new()
	chk_autosave.text = "Tự Động Lưu Dữ Liệu (Auto-Save 30s · Đổi Map · Thoát)"
	chk_autosave.button_pressed = PlayerData.auto_save_enabled
	chk_autosave.add_theme_font_size_override("font_size", 12)
	chk_autosave.add_theme_color_override("font_color", Color("#F8F9FA"))
	chk_autosave.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.set_auto_save_enabled(on)
		status_lbl.text = "Đã BẬT Tự Động Lưu (Auto-Save)!" if on else "Đã TẮT Tự Động Lưu — nhớ bấm [F5] để lưu tay!"
	)
	auto_v.add_child(chk_autosave)

	var chk_autocont := CheckButton.new()
	chk_autocont.text = "Tự Động Vào Chơi Tiếp Bản Lưu Gần Nhất Lần Sau"
	chk_autocont.button_pressed = PlayerData.auto_continue_on_start
	chk_autocont.add_theme_font_size_override("font_size", 12)
	chk_autocont.add_theme_color_override("font_color", Color("#FFE599"))
	chk_autocont.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.set_auto_continue_on_start(on)
		if not on:
			_cancel_auto_continue()
		status_lbl.text = "Lần sau mở game sẽ tự động tải bản lưu gần nhất!" if on else "Đã tắt tự động vào game khi mở."
	)
	auto_v.add_child(chk_autocont)

	# Thanh đếm ngược Tự Động Chơi Tiếp (chỉ hiện khi auto_continue_on_start đang BẬT)
	auto_resume_banner = _make_styled_panel(Color(0.14, 0.11, 0.04, 0.96), Color("#FFD166"), 2, 7)
	auto_resume_banner.visible = false
	menu_col.add_child(auto_resume_banner)

	var ar_h := HBoxContainer.new()
	ar_h.add_theme_constant_override("separation", 8)
	auto_resume_banner.add_child(ar_h)

	auto_resume_lbl = _make_label("Tự động vào tiếp sau 1.6s...", 12, Color("#FFD166"))
	auto_resume_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ar_h.add_child(auto_resume_lbl)

	var cancel_ar := Button.new()
	cancel_ar.text = "Hủy (Ở Menu)"
	cancel_ar.add_theme_font_size_override("font_size", 11)
	cancel_ar.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		_cancel_auto_continue()
	)
	ar_h.add_child(cancel_ar)

	var foot_spacer := Control.new()
	foot_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_col.add_child(foot_spacer)

	status_lbl = _make_label("Mẹo: Chế Độ DEMO chạy riêng ở Ô 3 (không ghi đè cốt truyện Ô 1) & hỗ trợ Dịch Chuyển Nhanh [M]!", 11, Color("#A8DADC"))
	status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu_col.add_child(status_lbl)

	# 3. Bảng phụ bên phải (Chọn 3 Ô Save / Cài Đặt Âm Thanh / Hướng Dẫn)
	sub_panel = _make_styled_panel(Color(0.05, 0.06, 0.12, 0.94), Color("#2EC4B6"), 2, 16)
	sub_panel.anchor_left = 0.48
	sub_panel.anchor_right = 0.96
	sub_panel.anchor_top = 0.12
	sub_panel.anchor_bottom = 0.88
	sub_panel.visible = false
	add_child(sub_panel)

	var sp_v := VBoxContainer.new()
	sp_v.add_theme_constant_override("separation", 10)
	sub_panel.add_child(sp_v)

	var hdr := HBoxContainer.new()
	sp_v.add_child(hdr)

	sub_title_lbl = _make_label("NẠP GIỚI LƯU TRỮ", 18, Color("#FFD166"))
	sub_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr.add_child(sub_title_lbl)

	var close_b := Button.new()
	close_b.text = "Đóng"
	close_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		sub_panel.visible = false
	)
	hdr.add_child(close_b)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sp_v.add_child(scroll)

	sub_body_vbox = VBoxContainer.new()
	sub_body_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub_body_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(sub_body_vbox)


func _refresh_continue_button() -> void:
	var best_slot: int = PlayerData.get_best_continue_slot()
	if best_slot != -1:
		var info: Dictionary = PlayerData.get_save_slot_summary(best_slot)
		continue_btn.disabled = false
		continue_btn.text = "TIẾP TỤC — %s" % str(info.get("label", ""))
		continue_btn.clip_text = true
		continue_btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	else:
		continue_btn.disabled = true
		continue_btn.text = "TIẾP TỤC (Chưa có bản lưu)"


func _execute_continue_slot(slot_idx: int) -> void:
	if slot_idx <= 0:
		return
	PlayerData.session_returned_to_menu = false
	AudioManager.play_sfx("portal_warp")
	if PlayerData.load_game(slot_idx):
		get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_continue_pressed() -> void:
	_cancel_auto_continue()
	var best_slot: int = PlayerData.get_best_continue_slot()
	if best_slot != -1:
		_execute_continue_slot(best_slot)


func _on_new_game_pressed() -> void:
	_cancel_auto_continue()
	PlayerData.session_returned_to_menu = false
	AudioManager.play_sfx("portal_warp")
	PlayerData.reset_for_new_game(1)
	if PlayerData.auto_save_enabled:
		PlayerData.save_game(1, true)
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_demo_unlock_all_pressed() -> void:
	_cancel_auto_continue()
	PlayerData.session_returned_to_menu = false
	AudioManager.play_sfx("breakthrough")
	# Chạy Chế Độ DEMO trên Ô 3 để bảo toàn bản lưu cốt truyện ở Ô 1 & Ô 2!
	PlayerData.activate_demo_unlock_all(3)
	if PlayerData.auto_save_enabled:
		PlayerData.save_game(3, true)
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _clear_sub_body() -> void:
	for ch in sub_body_vbox.get_children():
		ch.queue_free()


func _open_slots_panel() -> void:
	_cancel_auto_continue()
	AudioManager.play_sfx("ui_click")
	sub_panel.visible = true
	sub_title_lbl.text = "QUẢN LÝ 3 Ô LƯU NẠP GIỚI"
	_clear_sub_body()

	sub_body_vbox.add_child(_make_label("Chọn 1 trong 3 Ô Lưu để tải tiến độ cũ, tạo hành trình chuẩn cốt truyện, hoặc mở Chế Độ DEMO tại ô đó:", 13, Color("#A8DADC")))
	for s in range(1, PlayerData.MAX_SAVE_SLOTS + 1):
		var info: Dictionary = PlayerData.get_save_slot_summary(s)
		var exists: bool = bool(info.get("exists", false))
		var is_last: bool = (s == PlayerData.last_played_slot and exists)
		var border_c: Color = Color("#FFD166") if is_last else (Color("#70D6FF") if exists else Color("#495057"))
		var card := _make_styled_panel(Color(0.09, 0.11, 0.19, 0.94), border_c, 2 if is_last else 1, 10)
		sub_body_vbox.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		card.add_child(row)

		var tag_txt: String = " [GẦN NHẤT]" if is_last else ""
		var lbl := _make_label(str(info.get("label", "")) + tag_txt, 12, Color("#FFD166") if is_last else (Color("#F8F9FA") if exists else Color("#ADB5BD")))
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(lbl)

		var slot_num: int = s
		if exists:
			var load_b := Button.new()
			load_b.text = "Tải"
			load_b.add_theme_font_size_override("font_size", 12)
			load_b.pressed.connect(func() -> void:
				_execute_continue_slot(slot_num)
			)
			row.add_child(load_b)

		var new_b := Button.new()
		new_b.text = "Mới"
		new_b.add_theme_font_size_override("font_size", 12)
		new_b.pressed.connect(func() -> void:
			PlayerData.session_returned_to_menu = false
			AudioManager.play_sfx("portal_warp")
			PlayerData.reset_for_new_game(slot_num)
			if PlayerData.auto_save_enabled:
				PlayerData.save_game(slot_num, true)
			get_tree().change_scene_to_file(GAME_SCENE_PATH)
		)
		row.add_child(new_b)

		var demo_b := Button.new()
		demo_b.text = "Demo"
		demo_b.add_theme_font_size_override("font_size", 12)
		demo_b.add_theme_color_override("font_color", Color("#E0AAFF"))
		demo_b.pressed.connect(func() -> void:
			PlayerData.session_returned_to_menu = false
			AudioManager.play_sfx("breakthrough")
			PlayerData.activate_demo_unlock_all(slot_num)
			if PlayerData.auto_save_enabled:
				PlayerData.save_game(slot_num, true)
			get_tree().change_scene_to_file(GAME_SCENE_PATH)
		)
		row.add_child(demo_b)


func _open_audio_panel() -> void:
	_cancel_auto_continue()
	AudioManager.play_sfx("ui_click")
	sub_panel.visible = true
	sub_title_lbl.text = "CÀI ĐẶT ÂM THANH CỔ PHONG"
	_clear_sub_body()

	var bgm_lbl := _make_label("Nhạc Nền (Cổ Tranh / Trống Chiến): %d%%" % int(round(AudioManager.bgm_volume * 100.0)), 14, Color("#FFE599"))
	sub_body_vbox.add_child(bgm_lbl)
	var bgm_slider := HSlider.new()
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.05
	bgm_slider.value = AudioManager.bgm_volume
	bgm_slider.value_changed.connect(func(v: float) -> void:
		AudioManager.set_bgm_volume(v)
		PlayerData.save_user_settings()
		bgm_lbl.text = "Nhạc Nền (Cổ Tranh / Trống Chiến): %d%%" % int(round(v * 100.0))
	)
	sub_body_vbox.add_child(bgm_slider)

	var sfx_lbl := _make_label("Hiệu Ứng Chiến Đấu & Luyện Đan (SFX): %d%%" % int(round(AudioManager.sfx_volume * 100.0)), 14, Color("#70D6FF"))
	sub_body_vbox.add_child(sfx_lbl)
	var sfx_slider := HSlider.new()
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.05
	sfx_slider.value = AudioManager.sfx_volume
	sfx_slider.value_changed.connect(func(v: float) -> void:
		AudioManager.set_sfx_volume(v)
		PlayerData.save_user_settings()
		sfx_lbl.text = "Hiệu Ứng Chiến Đấu & Luyện Đan (SFX): %d%%" % int(round(v * 100.0))
		AudioManager.play_sfx("loot_pickup", 0.0)
	)
	sub_body_vbox.add_child(sfx_slider)

	var test_btn := Button.new()
	test_btn.text = "Thử Âm Thanh Đột Phá!"
	test_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("breakthrough", 0.0)
	)
	sub_body_vbox.add_child(test_btn)


func _open_controls_panel() -> void:
	_cancel_auto_continue()
	AudioManager.play_sfx("ui_click")
	sub_panel.visible = true
	sub_title_lbl.text = "HƯỚNG DẪN ĐIỀU KHIỂN"
	_clear_sub_body()
	var lines: String = (
		"• [W A S D] / Mũi tên: Di chuyển 8 hướng\n"
		+ "• [V] hoặc [Enter]: Nói chuyện NPC, Chạm Ma Thạch Bi, Mở Rương & Đi qua Cổng\n"
		+ "• [Chuột Trái]: Đánh Combo 3 nhịp (phóng 3 Kiếm Khí Đấu Thánh -> 5 Đạo Kiếm Khí 23 Sắc Viêm Đế!)\n"
		+ "• [Space]: Lướt né (tự tiến hóa Tử Vân Dực -> Lôi Động -> Hóa Dực -> Đạp Hư Không -> Xé Không -> Đấu Thánh -> Đế Bước 1.280px/s!)\n"
		+ "• [Chuột Phải / C]: Bật/Tắt Trọng Áp Huyền Trọng Xích / Hằng Cổ Xích (+30% EXP)\n"
		+ "• [Q] [E] [R] [F] [T] [X]: 37 Đấu Kỹ, Hằng Cổ Dị Hỏa Liên (7–23 Hỏa), Trợ Chiến [T] Viêm Đế & Tộc Văn Tiêu Tộc [X]\n"
		+ "• [G]: Triệu hồi / Đổi 12 Đồng Hành AI (gồm Bắc Vương 7★, Chúc Khôn #12 + Khí Linh Tiểu Y thường trực!)\n"
		+ "• [Z]: Radar Linh Hồn — Quét rương báu & phát hiện kẻ địch ẩn thân\n"
		+ "• [1] [2] [3]: Uống nhanh Đan Dược hồi HP / Đấu Khí / EXP\n"
		+ "• [I] Trang Bị 10 Ô & Khảm Ma Hạch 1–10  |  [K] Kho 37 Đấu Kỹ  |  [B] Đột Phá · Cửu Chuyển · Viêm Đế\n"
		+ "• [L] Lò Luyện Đan Phẩm 1–10 (+ Tiểu Y Luyện Nhanh)  |  [H] Dị Hỏa Bảng (28 Hỏa · 23 Dị Hỏa)\n"
		+ "• [M] Thế Giới (%d Map · Ch.01–11), Hồng Nhan, Thiên Phủ (25 Cường Bảng), Tâm Ma (64 Boss), Tháp & Đồ Giám (118 loài)\n" % GameDatabase.maps_ordered.size()
		+ "• [ESC] Tạm Dừng, True Ending Credits, Luân Hồi New Game+, Đổi Phím, Hiển Thị, Auto-Save, 3 Ô & DEMO"
	)
	var l := _make_label(lines, 13, Color("#F8F9FA"))
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub_body_vbox.add_child(l)


func _make_menu_button(txt: String, text_col: Color) -> Button:
	var b := Button.new()
	b.text = txt
	b.custom_minimum_size = Vector2(465, 38)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_font_size_override("font_size", 14)
	b.add_theme_color_override("font_color", text_col)
	var sb_n := StyleBoxFlat.new()
	sb_n.bg_color = Color(0.08, 0.10, 0.18, 0.88)
	sb_n.border_color = Color(text_col.r, text_col.g, text_col.b, 0.58)
	sb_n.set_border_width_all(2)
	sb_n.set_corner_radius_all(5)
	sb_n.set_content_margin_all(8)
	var sb_h := StyleBoxFlat.new()
	sb_h.bg_color = Color(0.15, 0.19, 0.30, 0.96)
	sb_h.border_color = text_col
	sb_h.set_border_width_all(2)
	sb_h.set_corner_radius_all(5)
	sb_h.set_content_margin_all(8)
	b.add_theme_stylebox_override("normal", sb_n)
	b.add_theme_stylebox_override("hover", sb_h)
	b.add_theme_stylebox_override("pressed", sb_h)
	return b


func _make_compact_button(txt: String, text_col: Color) -> Button:
	var b := Button.new()
	b.text = txt
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, 34)
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", text_col)
	var sb_n := StyleBoxFlat.new()
	sb_n.bg_color = Color(0.08, 0.10, 0.18, 0.86)
	sb_n.border_color = Color(text_col.r, text_col.g, text_col.b, 0.45)
	sb_n.set_border_width_all(1)
	sb_n.set_corner_radius_all(5)
	sb_n.set_content_margin_all(6)
	var sb_h := StyleBoxFlat.new()
	sb_h.bg_color = Color(0.16, 0.20, 0.32, 0.96)
	sb_h.border_color = text_col
	sb_h.set_border_width_all(2)
	sb_h.set_corner_radius_all(5)
	sb_h.set_content_margin_all(6)
	b.add_theme_stylebox_override("normal", sb_n)
	b.add_theme_stylebox_override("hover", sb_h)
	b.add_theme_stylebox_override("pressed", sb_h)
	return b


func _make_styled_panel(bg_col: Color, border_col: Color, border_w: int = 2, pad: int = 10) -> PanelContainer:
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(pad)
	pc.add_theme_stylebox_override("panel", sb)
	return pc


func _make_label(txt: String, fsize: int, col: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.06, 0.96))
	l.add_theme_constant_override("outline_size", 4)
	return l
