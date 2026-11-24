class_name HudDialogueController
extends RefCounted
## Bộ Điều Khiển Hộp Thoại Cốt Truyện NPC, Chọn Nhánh Hảo Cảm & Thực Thi Hành Động Kết Thoại (Tách từ hud_controller.gd).


static func open_dialogue(hud, speaker: String, avatar_path: String, lines: Array, finish_action: String) -> void:
	if lines.is_empty():
		return
	if hud.current_modal != "":
		hud._close_modal()
	hud._hide_slot_tooltip()

	hud.dialogue_active = true
	hud.dialogue_lines = lines
	hud.dialogue_index = 0
	hud.dialogue_finish_action = finish_action
	hud.dialogue_choices = []
	hud.dlg_speaker_lbl.text = speaker
	if avatar_path != "":
		hud.dlg_avatar_rect.texture = load(avatar_path)
	hud.dialogue_panel.visible = true
	render_dialogue_line(hud)
	hud._sync_player_input_block()


static func open_choice_dialogue(hud, speaker: String, avatar_path: String, lines: Array, choices: Array) -> void:
	if lines.is_empty():
		return
	if hud.current_modal != "":
		hud._close_modal()
	hud._hide_slot_tooltip()

	hud.dialogue_active = true
	hud.dialogue_lines = lines
	hud.dialogue_index = 0
	hud.dialogue_finish_action = ""
	hud.dialogue_choices = choices
	hud.dlg_speaker_lbl.text = speaker
	if avatar_path != "":
		hud.dlg_avatar_rect.texture = load(avatar_path)
	hud.dialogue_panel.visible = true
	render_dialogue_line(hud)
	hud._sync_player_input_block()


static func render_dialogue_line(hud) -> void:
	if hud.dialogue_index >= hud.dialogue_lines.size():
		return
	hud.dlg_body_lbl.text = str(hud.dialogue_lines[hud.dialogue_index])
	var is_last: bool = (hud.dialogue_index >= hud.dialogue_lines.size() - 1)

	for ch in hud.dlg_choices_vbox.get_children():
		ch.queue_free()

	if is_last and not hud.dialogue_choices.is_empty():
		hud.dialogue_panel.offset_top = -336
		hud.dlg_choices_vbox.visible = true
		hud.dlg_next_btn.visible = false
		for c_entry in hud.dialogue_choices:
			if not (c_entry is Dictionary):
				continue
			var cd: Dictionary = c_entry
			var act_str: String = str(cd.get("action", ""))
			var cb := Button.new()
			cb.text = "▸ " + str(cd.get("label", "Chọn"))
			cb.alignment = HORIZONTAL_ALIGNMENT_LEFT
			cb.custom_minimum_size = Vector2(0, 30)
			cb.add_theme_font_size_override("font_size", 13)
			cb.add_theme_color_override("font_color", Color("#FFD166"))
			cb.pressed.connect(func() -> void:
				AudioManager.play_sfx("ui_click")
				hud.dialogue_finish_action = act_str
				close_dialogue(hud, true)
			)
			hud.dlg_choices_vbox.add_child(cb)
	else:
		hud.dialogue_panel.offset_top = -288
		hud.dlg_choices_vbox.visible = false
		hud.dlg_next_btn.visible = true
		hud.dlg_next_btn.text = ("Hoàn tất [V / Enter] (%d/%d)" % [hud.dialogue_index + 1, hud.dialogue_lines.size()]) if is_last else ("Tiếp tục [V / Enter] (%d/%d)" % [hud.dialogue_index + 1, hud.dialogue_lines.size()])


static func advance_dialogue(hud) -> void:
	if not hud.dialogue_active:
		return
	AudioManager.play_sfx("ui_click")
	hud.dialogue_index += 1
	if hud.dialogue_index < hud.dialogue_lines.size():
		render_dialogue_line(hud)
	else:
		close_dialogue(hud, true)


static func close_dialogue(hud, run_finish_action: bool) -> void:
	var act: String = hud.dialogue_finish_action
	hud.dialogue_active = false
	hud.dialogue_lines = []
	hud.dialogue_index = 0
	hud.dialogue_finish_action = ""
	hud.dialogue_choices = []
	hud.dlg_choices_vbox.visible = false
	hud.dialogue_panel.visible = false
	hud._sync_player_input_block()

	if run_finish_action and act != "":
		execute_dialogue_action(hud, act)


static func execute_dialogue_action(hud, act: String) -> void:
	if act.begins_with("effect:"):
		var eff_id: String = act.substr(7)
		var eff: Dictionary = GameDatabase.get_story_effect(eff_id)
		if not eff.is_empty():
			var res: Dictionary = PlayerData.execute_story_effect(eff)
			if bool(res.get("heal_full", false)):
				hud._heal_player_full("")
			var oshop: String = str(res.get("open_shop", ""))
			if oshop != "":
				hud.shop_venue_id = "nha_phi"
				hud.shop_tab = "shop"
				hud._open_nha_phi_shop()
			var oauc: String = str(res.get("open_auction", ""))
			if oauc != "":
				hud._open_auction_house(oauc)
			var warp_m: String = str(eff.get("warp_map", ""))
			if warp_m != "":
				var w: Node = hud._find_world()
				if w != null and w.has_method("load_map"):
					var wsp_arr: Array = eff.get("warp_spawn", [])
					var wsp: Vector2 = Vector2(float(wsp_arr[0]), float(wsp_arr[1])) if wsp_arr.size() >= 2 else Vector2.ZERO
					w.load_map(warp_m, wsp, true)
		return
	elif act.begins_with("flag:"):
		var flag_id: String = act.substr(5)
		PlayerData.set_story_flag(flag_id)
		if flag_id == "met_tieu_y_tien" or flag_id == "met_tieu_dinh_le" or flag_id == "pact_hai_ba_dong":
			hud._heal_player_full("")
		elif flag_id == "absorbed_tu_hoa":
			PlayerData.set_story_flag("van_chi_departed")
			hud._heal_player_full("")
	elif act == "choice:lang_anh_quiet":
		PlayerData.set_story_flag("secret_lang_anh_done")
		hud._on_banter("Lăng Ảnh khẽ gật đầu rồi tan biến vào bóng đêm, để lại kỳ vật [Hắc Ảnh Phù (+8% Tốc Chạy)]!")
	elif act == "choice:lang_anh_bow":
		PlayerData.set_story_flag("secret_lang_anh_done")
		PlayerData.add_affection("huan_nhi", 10)
		PlayerData.bonus_soul += 4
		EventBus.stats_changed.emit()
		hud._on_banter("Lăng Ảnh hơi kinh ngạc trước sự bình tĩnh của bạn, để lại [Hắc Ảnh Phù], +10 Hảo Cảm Huân Nhi & +4 Linh Hồn!")
	elif act == "choice:van_chi_herb_fish":
		PlayerData.add_affection("van_chi", 30)
		PlayerData.set_story_flag("met_van_chi")
		hud._heal_player_full("Vân Chi khẽ mỉm cười trước tài nướng cá thảo mộc (+30 Hảo Cảm Vân Chi)! Giờ tiến vào Hang Tím phía Đông hạ Tiểu Sư Vương!")
	elif act == "choice:van_chi_pink_powder":
		PlayerData.add_affection("van_chi", 15)
		PlayerData.add_story_relic("Kỷ Niệm Ẩn: Bữa Cá Nướng 'Bỏng Môi' Bên Suối")
		PlayerData.set_story_flag("met_van_chi")
		hud._heal_player_full("Vân Chi ăn xong đỏ bừng mặt lao thẳng xuống Bờ Suối Trăng Bạc mắng 'tiểu tặc vô sỉ'! (+15 Hảo Cảm & Kỷ Niệm Ẩn!)")
	elif act == "choice:u_lan_hug":
		PlayerData.add_affection("tieu_y_tien", 40)
		PlayerData.set_story_flag("ch02_farewell_done")
		hud._heal_player_full("Tiêu Viêm bọc Tử Hỏa ôm chặt Tiểu Y Tiên giữa vòng cỏ héo (+40 Hảo Cảm)! Hẹn ngày tương phùng tại Xuất Vân Đế Quốc!")
	elif act == "choice:u_lan_promise":
		PlayerData.add_affection("tieu_y_tien", 20)
		PlayerData.set_story_flag("ch02_farewell_done")
		hud._heal_player_full("Tiểu Y Tiên lau nước mắt mỉm cười (+20 Hảo Cảm) rồi lặng lẽ để lại bức thư chia ly hướng về Xuất Vân Đế Quốc!")
	elif act == "choice:thanh_lan_sister":
		PlayerData.add_affection("thanh_lan", 35)
		PlayerData.set_story_flag("met_thanh_lan")
		hud._heal_player_full("Thanh Lân bật khóc cảm động (+35 Hảo Cảm Thanh Lân)! Bích Xà Tam Hoa Đồng mở lối xuống Hố Cát Bắc Địa Huyệt Dung Nham!")
	elif act == "choice:thanh_lan_protect":
		PlayerData.add_affection("thanh_lan", 20)
		PlayerData.set_story_flag("met_thanh_lan")
		hud._heal_player_full("Thanh Lân gật đầu biết ơn (+20 Hảo Cảm Thanh Lân)! Hố Cát Bắc dẫn xuống Địa Huyệt Dung Nham đã mở!")
	elif act == "choice:van_van_call_name":
		PlayerData.add_affection("van_chi", 35)
		PlayerData.set_story_flag("van_van_ch03_done")
		PlayerData.add_story_relic("Kỷ Niệm: Mũi Kiếm Nghiêng Ba Tấc Của Vân Vận")
		hud._heal_player_full("Đôi mắt phượng của Vân Vận nhòe đi, nàng khẽ nghiêng kiếm mở lối giữa bão cát (+35 Hảo Cảm Vân Vận)!")
	elif act == "choice:van_van_silent":
		PlayerData.add_affection("van_chi", 20)
		PlayerData.set_story_flag("van_van_ch03_done")
		hud._heal_player_full("Vân Vận nghiêng mũi kiếm ba tấc giữ kín bí mật cho Tiêu Viêm (+20 Hảo Cảm Vân Vận)!")
	elif act == "choice:devour_bang_tam":
		if PlayerData.get_item_count("pill_bang_tam_dan") > 0:
			PlayerData.remove_item("pill_bang_tam_dan", 1)
			PlayerData.add_exp(400)
		PlayerData.set_story_flag("ch03_completed")
		EventBus.screen_shake_requested.emit(12.0, 0.45)
		hud._heal_player_full("NIẾT BÀN THÀNH CÔNG! Băng Tâm Đan bảo vệ kinh mạch — thu phục [#19 Thanh Liên Địa Tâm Hỏa] + Thần Thú [Thải Lân] + Tuyệt Kỹ [F] PHẬT NỘ HỎA LIÊN!!")
	elif act == "choice:devour_iron_will":
		PlayerData.bonus_soul += 6
		PlayerData.set_story_flag("ch03_completed")
		EventBus.screen_shake_requested.emit(12.0, 0.45)
		hud._heal_player_full("Ý CHÍ ƯỚC HẸN 3 NĂM BẤT KHUẤT (+6 SOUL)! Thu phục [#19 Thanh Liên Địa Tâm Hỏa] + Thần Thú [Thải Lân] + Tuyệt Kỹ [F] PHẬT NỘ HỎA LIÊN!!")
	elif act == "feed_thai_lan":
		PlayerData.add_affection("my_do_toa", 15)
		hud._heal_player_full("Thải Lân vui vẻ nuốt Hỏa Tinh tỏa Thất Thải Quang Mang (+15 Hảo Cảm Thải Lân / Mỹ Đỗ Toa)!")
	elif act == "gift_huan_nhi":
		PlayerData.set_story_flag("huan_nhi_gift")
		PlayerData.add_affection("huan_nhi", 15)
		PlayerData.add_item("herb_ngung_huyet_thao", 2)
		PlayerData.add_item("pill_ngung_huyet_tan", 1)
		AudioManager.play_sfx("loot_rare")
		hud._on_banter("Tiêu Huân Nhi tặng bạn: Ngưng Huyết Thảo x2 & Ngưng Huyết Tán x1 (+15 Hảo Cảm)! Hãy tới gặp Nạp Lan Yên Nhiên [V].")
	elif act == "heal_full":
		hud._heal_player_full("Đã hồi phục toàn bộ HP & Đấu Khí!")
	elif act == "open_shop:nha_phi":
		hud._open_nha_phi_shop()
	elif act.begins_with("open_auction:"):
		hud._open_auction_house(act.substr(13))
	elif act == "open_pan_gate":
		hud.world_map_tab = "pan_gate"
		if hud.current_modal != "world_map":
			hud._toggle_modal("world_map")
		else:
			hud._populate_modal()
	elif act == "open_tower":
		hud.world_map_tab = "tower"
		if hud.current_modal != "world_map":
			hud._toggle_modal("world_map")
		else:
			hud._populate_modal()
