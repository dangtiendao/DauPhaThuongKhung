class_name PanelEndingCredits
extends RefCounted
## Trình chiếu True Ending Credits & Post-Credits Điện Ảnh 2D Pixel (Chương 11 — Đại Kết Cục Viêm Đế v1.0.0):
##   - Khung chia đôi: Trái cuộn 11 Cột Mốc Hành Trình Ch.01 -> Ch.11 & Lời Cảm Ơn; Phải trình diễn Đại Hôn Ô Thản Thành + Teaser Đại Thiên!
##   - Mở từ Lễ Đường Đại Hôn, Bia Đại Thiên Thế Giới, hoặc Menu Tạm Dừng [ESC].

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


func build_content(vbox: VBoxContainer) -> void:
	hud.modal_title_lbl.text = "★ TRUE ENDING — ĐẤU PHÁ THƯƠNG KHUNG: VIÊM ĐẾ VẠN HỎA CHI CHỦ (v1.0.0) ★"
	vbox.add_theme_constant_override("separation", 10)

	# 1. Banner Chúc Mừng Đại Kết Cục
	var hero_card: PanelContainer = hud._make_styled_panel(Color(0.16, 0.05, 0.08, 0.96), Color("#F43F5E"), 2, 10)
	vbox.add_child(hero_card)
	var hv := VBoxContainer.new()
	hv.add_theme_constant_override("separation", 4)
	hero_card.add_child(hv)
	hv.add_child(hud._make_label("★ TAM THẬP NIÊN HÀ ĐÔNG, TAM THẬP NIÊN HÀ TÂY — MẠC KHI THIẾU NIÊN CÙNG! ★", 15, Color("#FDE047")))
	var sub_h: Label = hud._make_label(
		"Từ cậu thiếu niên Đấu Chi Khí Tam Đoạn bị từ hôn tại Ô Thản Thành đến ngôi vị VIÊM ĐẾ (ĐẤU ĐẾ) hiệu triệu 23 Dị Hỏa phong ấn Hồn Thiên Đế — Hành trình 11 Chương (4 Quyển) chính thức viên mãn!",
		12, Color("#FFE4E6")
	)
	sub_h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hv.add_child(sub_h)

	# 2. Khung Chia Đôi Điện Ảnh (Trái: 11 Cột Mốc Kỷ Niệm | Phải: Đại Hôn Ô Thản Thành & Post-Credits)
	var split := HBoxContainer.new()
	split.add_theme_constant_override("separation", 12)
	vbox.add_child(split)

	var left_card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.09, 0.16, 0.95), Color("#FBBF24"), 1, 9)
	left_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(left_card)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 4)
	left_card.add_child(lv)
	lv.add_child(hud._make_label("📜 11 CỘT MỐC BẤT HỦ (CHƯƠNG 01 → CHƯƠNG 11)", 13, Color("#FBBF24")))
	var milestones: Array[String] = [
		"• Ch.01 Ô Thản Thành: Rạch tay viết Hưu Thư — Bái sư Dược Lão trên Vách Đá Hậu Sơn!",
		"• Ch.02 Ma Thú Sơn Mạch: Tử Vân Dực, cá nướng bên Suối Trăng Bạc & chia ly Tiểu Y Tiên.",
		"• Ch.03 Sa Mạc Tháp Qua Nhĩ: Thôn phệ #19 Thanh Liên Địa Tâm Hỏa — Khai sinh Phật Nộ Hỏa Liên!",
		"• Ch.04 Đế Đô & Vân Lam Sơn: Quán quân Đan Hội, xé mặt nạ Nham Kiêu trả trọn Ước Hẹn 3 Năm!",
		"• Ch.05 Hắc Giác Vực & Già Nam: Tam Thiên Lôi Động, hội ngộ Tiêu Huân Nhi & Tân Sinh Vương.",
		"• Ch.06 Nội Viện & Đáy Tháp: Lập Bàn Môn, thu Tử Nghiên, luyện hóa #14 Vẫn Lạc Tâm Viêm Hóa Dực!",
		"• Ch.07 Tam Thượng Vân Lam: Lập Đế Quốc Viêm Minh, hội ngộ Thiên Độc Nữ & đúc Địa Yêu Khôi.",
		"• Ch.08 Bắc Vực & Đan Hội Trung Châu: Đột phá Đấu Tông, Quán quân Đan Hội & #9 Tam Thiên Hỏa!",
		"• Ch.09 Vong Hồn & Thiên Mộ: Cứu Bán Thánh Dược Trần, Cửu Chuyển Đấu Tôn & Tộc Văn Tiêu Huyền!",
		"• Ch.10 Bồ Đề & Tịnh Liên: Thủy Mặc Bách Thế Hóa Thánh, Thiên Phủ Liên Minh & Khí Linh Tiểu Y!",
		"• Ch.11 Cổ Đế & Song Đế Chiến: Cứu Phụ thân Tiêu Chiến, Vạn Hỏa Triều Tông & Đại Hôn Ô Thản Thành!"
	]
	for ms in milestones:
		var ml: Label = hud._make_label(ms, 11, Color("#E9ECEF"))
		ml.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lv.add_child(ml)

	var right_col := VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.add_theme_constant_override("separation", 8)
	split.add_child(right_col)

	# Khung Đại Hôn Ô Thản Thành
	var wed_card: PanelContainer = hud._make_styled_panel(Color(0.15, 0.06, 0.09, 0.95), Color("#FB7185"), 2, 9)
	right_col.add_child(wed_card)
	var wv := VBoxContainer.new()
	wv.add_theme_constant_override("separation", 6)
	wed_card.add_child(wv)
	wv.add_child(hud._make_label("🏮 ĐẠI LỄ THÀNH HÔN PHỦ TIÊU GIA — Ô THẢN THÀNH", 13, Color("#FDA4AF")))
	var cast_row := HBoxContainer.new()
	cast_row.add_theme_constant_override("separation", 10)
	wv.add_child(cast_row)
	cast_row.add_child(hud._make_icon_box("res://assets/sprites/npcs/npc_tieu_chien_reunion.png", Color("#FBBF24"), 58))
	cast_row.add_child(hud._make_icon_box("res://assets/sprites/npcs/npc_huan_nhi_bride.png", Color("#F43F5E"), 64))
	cast_row.add_child(hud._make_icon_box("res://assets/sprites/npcs/npc_thai_lan_bride.png", Color("#F59E0B"), 64))
	cast_row.add_child(hud._make_icon_box("res://assets/sprites/npcs/npc_tieu_tieu.png", Color("#F472B6"), 54))
	cast_row.add_child(hud._make_icon_box("res://assets/sprites/npcs/npc_duoc_tran_ban_thanh.png", Color("#72EFDD"), 58))
	var wed_txt: Label = hud._make_label(
		"Tiêu Viêm trong bộ hỷ phục tân lang đỏ thắm nắm tay hai tân nương Cổ Huân Nhi & Thải Lân bái đường trước phụ thân Tiêu Chiến và sư tôn Dược Trần giữa pháo hoa rợp trời Ô Thản Thành!",
		11, Color("#FFE4E6")
	)
	wed_txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	wv.add_child(wed_txt)

	# Khung Post-Credits Teaser Đại Thiên Thế Giới
	var pc_card: PanelContainer = hud._make_styled_panel(Color(0.06, 0.08, 0.18, 0.96), Color("#00F5D4"), 2, 9)
	right_col.add_child(pc_card)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 6)
	pc_card.add_child(pv)
	pv.add_child(hud._make_label("🌌 POST-CREDITS TEASER — ĐẠI THIÊN THẾ GIỚI", 13, Color("#00F5D4")))
	var duo_row := HBoxContainer.new()
	duo_row.add_theme_constant_override("separation", 10)
	pv.add_child(duo_row)
	duo_row.add_child(hud._make_icon_box("res://assets/sprites/enemies/vo_to_lam_dong_boss.png", Color("#38BDF8"), 64))
	duo_row.add_child(hud._make_icon_box("res://assets/sprites/enemies/muc_ton_muc_tran_boss.png", Color("#FBBF24"), 64))
	duo_row.add_child(hud._make_icon_box("res://assets/sprites/npcs/npc_dai_thien_portal.png", Color("#00F5D4"), 60))
	var pc_txt: Label = hud._make_label(
		"Giữa bầu trời tinh không Đại Thiên Thế Giới, Võ Tổ LÂM ĐỘNG (Bát Đại Tổ Phù) & Đại Chúa Tể MỤC TRẦN (Nhất Khí Hóa Tam Thanh) chắp tay mỉm cười nghênh đón:\n\"Tại hạ Tiêu Viêm, đến từ Đấu Khí Đại Lục — Xin được chỉ giáo!\"\n[ĐÃ MỞ KHÓA POST-GAME: 17 BÍ CẢNH DỊ HỎA · 2 SUPERBOSS · NEW GAME+ LUÂN HỒI!]",
		11, Color("#CCFBF1")
	)
	pc_txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pv.add_child(pc_txt)

	# 3. Bảng Thành Tích Tài Khoản & Nút Điều Hướng
	var stat_card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.11, 0.15, 0.95), Color("#80ED99"), 1, 8)
	vbox.add_child(stat_card)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 5)
	stat_card.add_child(sv)
	var ep_cnt: int = EmperorRealmManager.get_epilogue_done_count(PlayerData)
	var fl_cnt: int = EmperorRealmManager.get_heavenly_flame_count(PlayerData)
	var ng_c: int = EmperorRealmManager.get_ng_plus_cycle(PlayerData)
	sv.add_child(hud._make_label(
		"★ THÀNH TÍCH VIÊM ĐẾ:  %s  |  Dị Hỏa: %d/23  |  Hậu Truyện: %d/5  |  Vòng Luân Hồi NG+: %d  |  Địch Đã Hạ: %d" % [
			PlayerData.get_realm_display_title(), fl_cnt, ep_cnt, ng_c, PlayerData.enemies_killed_total
		],
		12, Color("#80ED99")
	))
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	sv.add_child(btn_row)

	var btn_post := Button.new()
	btn_post.text = "🌌 Tiếp Tục Phiêu Lưu Post-Game (Đại Thiên Thế Giới)"
	btn_post.add_theme_font_size_override("font_size", 12)
	btn_post.add_theme_color_override("font_color", Color("#00F5D4"))
	btn_post.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud._close_modal()
	)
	btn_row.add_child(btn_post)

	var btn_ngp := Button.new()
	btn_ngp.text = "☯ Bắt Đầu Luân Hồi Chuyển Thế (New Game+ Vòng %d)" % (ng_c + 1)
	btn_ngp.add_theme_font_size_override("font_size", 12)
	btn_ngp.add_theme_color_override("font_color", Color("#FDE047"))
	btn_ngp.pressed.connect(func() -> void:
		var res: Dictionary = EmperorRealmManager.start_new_game_plus(PlayerData)
		hud.modal_status_lbl.text = str(res.get("msg", ""))
		if bool(res.get("ok", false)):
			hud._close_modal()
			var w: Node = hud._find_world()
			if w != null and w.has_method("load_map"):
				w.load_map("ch01_tieu_gia", Vector2.ZERO, true)
	)
	btn_row.add_child(btn_ngp)
