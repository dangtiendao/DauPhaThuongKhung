class_name HudMobaDockHelper
extends RefCounted
## Trợ Lý Cập Nhật Thanh Chiêu Thức MOBA, 7 Đồng Hành, 3 Ô Đan Nhanh & 8 Nút Hệ Thống (Tách từ hud_controller.gd).


static func refresh_moba_dock(hud) -> void:
	# 1. Ô Đánh Thường [LMB]
	if hud.slot_lmb != null:
		var has_w: bool = PlayerData.has_weapon_equipped()
		var w_icon_p: String = "res://assets/sprites/icons/skill_unarmed.png"
		var w_name: String = "Quyền Cước (Tay Không)"
		if has_w:
			var w_inst: Dictionary = PlayerData.equipped_gear.get("weapon", {})
			var tdef: Dictionary = GameDatabase.get_equipment_template(str(w_inst.get("template_id", "")))
			w_icon_p = str(tdef.get("icon", w_icon_p))
			w_name = EquipmentSystem.get_item_display_name(w_inst)
		hud.slot_lmb.set_slot_visual(hud._get_cached_tex(w_icon_p), "ATK %d" % int(PlayerData.get_atk()), false, false, false, Color("#FFE599"))
		hud.slot_lmb.set_tooltip_info(
			"Đánh Thường [Chuột Trái] — %s" % w_name,
			"Combo 3 nhịp liền thân · Công kích: %d" % int(PlayerData.get_atk()),
			"Nhấp Chuột Trái lên màn hình để tung 3 đòn liên hoàn theo hướng con trỏ chuột (nhịp 3 đánh diện rộng + rung chấn).",
			Color("#FFE599")
		)

	# 2. 4 Ô Đấu Kỹ [Q] [E] [R] [F]
	var default_locked_icons: Dictionary = {
		"Q": "res://assets/sprites/icons/skill_toai_thach.png",
		"E": "res://assets/sprites/icons/skill_bat_cuc_bang.png",
		"R": "res://assets/sprites/icons/skill_phe_lang_xich.png",
		"F": "res://assets/sprites/icons/skill_hoa_lien.png"
	}
	var lock_hints: Dictionary = {
		"Q": "Bái sư Dược Lão tại Vách Đá Hậu Sơn để học Toái Thạch Chưởng [Q]!",
		"E": "Đánh bại Tiêu Ninh ở Lễ Thành Niên hoặc mở Rương Cổ Hậu Sơn!",
		"R": "Sang Chương 02 (Ma Thú Sơn Mạch) gặp Tiểu Y Tiên để học Diễm Phân Phệ Lãng Xích!",
		"F": "Chỉ mở khóa ở Chương 03 Sa Mạc Tháp Qua Nhĩ sau khi thu phục Thanh Liên Địa Tâm Hỏa (#19)!"
	}
	hud._slot_qi_costs.clear()
	for slot_k in ["Q", "E", "R", "F"]:
		var btn: MobaSlotButton = hud.skill_slots[slot_k]
		var sid: String = PlayerData.get_skill_in_slot(slot_k)
		if sid == "":
			btn.set_slot_visual(hud._get_cached_tex(str(default_locked_icons[slot_k])), "KHÓA", true, false, false)
			btn.set_tooltip_info(
				"Ô Đấu Kỹ [%s] — Chưa Mở Khóa" % slot_k,
				"Chuẩn nguyên tác · Mở dần theo cốt truyện",
				str(lock_hints[slot_k]),
				Color("#ADB5BD")
			)
		else:
			var sdef: Dictionary = GameDatabase.get_skill_def(sid)
			var ic_p: String = str(sdef.get("icon", default_locked_icons[slot_k]))
			var qi_c: float = float(sdef.get("qi_cost", 15.0))
			if str(sdef.get("behavior", "")) == "fire_lotus_ult":
				qi_c *= PlayerData.get_lotus_qi_cost_multiplier()
			hud._slot_qi_costs[slot_k] = qi_c
			var low_qi: bool = (PlayerData.current_qi < qi_c)
			var is_buff_on: bool = (
				(sid == "thien_hoa_tam_huyen_bien" and PlayerData.is_flame_buff_active)
				or (sid == "thien_hoa_nhi_bien" and PlayerData.is_nhi_bien_active)
				or (sid == "thien_hoa_tam_bien" and PlayerData.is_tam_bien_active)
			)
			var mi: Dictionary = PlayerData.get_skill_mastery_info(sid)
			var eff_cd: float = float(sdef.get("cooldown", 5.0)) * float(mi.get("cd_mult", 1.0))
			var dmg_pct: int = int(round((float(mi.get("dmg_mult", 1.0)) - 1.0) * 100.0))
			var m_tag: String = " · %s (+%d%% DMG)" % [str(mi.get("tier_name", "Sơ Khuy")), dmg_pct] if dmg_pct > 0 else " · %s" % str(mi.get("tier_name", "Sơ Khuy"))
			btn.set_slot_visual(hud._get_cached_tex(ic_p), "%d QI" % int(qi_c), false, is_buff_on, low_qi, Color("#FF758F") if low_qi else Color("#70D6FF"))
			btn.set_tooltip_info(
				"[%s] %s" % [slot_k, str(sdef.get("name", sid))],
				"%s%s · Tốn %d Đấu Khí · Hồi %.1fs" % [str(sdef.get("grade", "")), m_tag, int(qi_c), eff_cd],
				str(sdef.get("description", "")) + "\n(Thông thạo: %d lần xuất chiêu · Mở [K] để xem thưởng Thông Thạo & đổi chiêu!)" % int(mi.get("uses", 0)),
				mi.get("color", Color("#FFD166")) as Color
			)

	# 3. Ô Trợ Chiến [T] Cốt Linh Phụ Thể / Mỹ Đỗ Toa / Địa Yêu Khôi / Chuẩn Thiên Yêu Khôi / Bắc Vương / Hợp Bích / VIÊM ĐẾ PHÁP TƯỚNG
	var btn_t: MobaSlotButton = hud.skill_slots["T"]
	var t_mode: String = PlayerData.get_assist_mode()
	if t_mode == "viem_de_phap_tuong":
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/icons/skill_de_hon_phap_tuong.png"),
			"VIÊM ĐẾ",
			false,
			PlayerData.is_duoc_lao_active or PlayerData.is_de_hon_active,
			false,
			Color("#FFD700")
		)
		btn_t.set_tooltip_info(
			"[T] VIÊM ĐẾ PHÁP TƯỚNG — Vạn Hỏa Triều Tông (#1 Đế Viêm)",
			"Hồi 45s · Duy trì 12s · ATK x5.00 · SPD +78% · Khiên 75% HP · +100% SOUL Chuẩn · Choáng 5s · Tự Nhặt Đồ",
			"Đỉnh cao Đấu Đế & Đế Cảnh Linh Hồn: Triệu hồi 23 Dị Hỏa càn quét 520px, nghiền nát mọi khiên Boss, trừ 60% giáp & tự động hút sạch chiến lợi phẩm!",
			Color("#FFD700")
		)
	elif t_mode == "tinh_lien_hop_bich":
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/npcs/npc_tieu_y.png"),
			"HỢP BÍCH",
			false,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#FFAFCC")
		)
		btn_t.set_tooltip_info(
			"[T] Kim Đế Tịnh Liên Hợp Bích & Bắc Vương (#4 + #3 Tiểu Y)",
			"Hồi 45s · Duy trì 12s · ATK x4.35 · SPD +70% · Khiên 60% HP · Choáng 4.5s · Tự Nhặt Đồ",
			"Cổ Huân Nhi (#4 Kim Đế) + Khí Linh Tiểu Y (#3 Tịnh Liên) + Bắc Vương đồng xuất kích! Tịnh hóa toàn sân 460px, phá khiên -50% giáp & tự động hút toàn bộ chiến lợi phẩm!",
			Color("#FFD700")
		)
	elif t_mode == "bac_vuong":
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/npcs/npc_bac_vuong.png"),
			"BẮC VƯƠNG",
			false,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#FFD700")
		)
		btn_t.set_tooltip_info(
			"[T] Siêu Khôi Lỗi Đấu Thánh — BẮC VƯƠNG (Kim Cương Phá Thiên)",
			"Hồi 45s · Duy trì 12s · ATK x3.80 · SPD +64% · Khiên 50% HP · Gom Quái & Choáng 4.2s",
			"Khôi Lỗi Lục/Thất Tinh Đấu Thánh Bắc Vương lao tới đấm nát không gian, hút gom toàn bộ địch trong 420px, phá khiên & tăng +280% ATK!",
			Color("#FFD700")
		)
	elif t_mode == "ban_thanh_duoc_tran":
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/npcs/npc_duoc_tran_ban_thanh.png"),
			"BÁN THÁNH",
			false,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#E0FBFC")
		)
		btn_t.set_tooltip_info(
			"[T] Bán Thánh Dược Trần — Cốt Linh Vạn Lý Băng Phong",
			"Hồi 45s · Duy trì 12s · ATK x3.35 · SPD +58% · Khiên 40% HP · Đóng Băng Toàn Sân 4.0s",
			"Bán Thánh Dược Trần xuất thế hộ pháp! Đóng băng tuyệt đối toàn bộ kẻ địch trong 380px suốt 4 giây, tạo Khiên 40% HP, phá giáp -35% & tăng +235% ATK!",
			Color("#E0FBFC")
		)
	elif t_mode == "thien_yeu_khoi":
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/npcs/npc_dia_yeu_khoi.png"),
			"THIÊN KHÔI",
			false,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#FFD166")
		)
		btn_t.set_tooltip_info(
			"[T] Vệ Sĩ Hoàng Kim — Chuẩn Thiên Yêu Khôi (Ngũ Sắc Thiên Lôi)",
			"Hồi 45s · Duy trì 12s · ATK x3.05 · SPD +52% · Khiên 30% HP · Phá Khiên & Choáng 2.2s",
			"Hấp thu trọn vẹn Ngũ Sắc Đan Lôi Chung Kết Đan Hội! Giáng cột Thiên Lôi Hoàng Kim 300px, tạo Khiên 30% Max HP, miễn làm chậm & tăng +205% ATK suốt 12 giây!",
			Color("#FFD166")
		)
	elif t_mode == "dia_yeu_khoi":
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/npcs/npc_dia_yeu_khoi.png"),
			"YÊU KHÔI",
			false,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#CAF0F8")
		)
		btn_t.set_tooltip_info(
			"[T] Vệ Sĩ Bất Tử — Địa Yêu Khôi Lôi Bộc",
			"Hồi 45s · Duy trì 12s · ATK x2.70 · SPD +45% · Miễn Nhiễm Làm Chậm · Phá Khiên Boss",
			"Rèn từ thi thể Đấu Tông 7 Tinh Địa Ma Lão Quỷ! Nện Lôi Bộc bạc 265px gây choáng 1.8s, phá vỡ mọi khiên Boss & miễn nhiễm làm chậm suốt 12 giây!",
			Color("#CAF0F8")
		)
	elif t_mode == "medusa_dau_tong":
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/npcs/npc_my_do_toa.png"),
			"ĐẤU TÔNG",
			false,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#E0AAFF")
		)
		btn_t.set_tooltip_info(
			"[T] Đấu Tông Mỹ Đỗ Toa Hộ Pháp",
			"Hồi 45s · Duy trì 12s · ATK x2.45 · SPD +40% · Sóng Không Gian",
			"Thỏa thuận Phục Linh Tử Đan! Triệu hồi bản thể Đấu Tông Mỹ Đỗ Toa bộc phát sóng xung kích Thất Thải & tăng cường chiến lực cực hạn!",
			Color("#E0AAFF")
		)
	elif t_mode == "sleeping":
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/icons/skill_duoc_lao_assist.png"),
			"NGỦ SAY",
			true,
			false,
			false,
			Color("#ADB5BD")
		)
		btn_t.set_tooltip_info(
			"[T] Dược Lão Đang Ngủ Say Trong Nhẫn Đen",
			"Tạm khóa theo cốt truyện Chương 04 (sau vụ nổ Song Sắc Hỏa Liên tại Mặc Gia)",
			"Dược Lão đã tiêu hao toàn bộ tàn hồn che chở cho bạn trước Mặc Thừa & Bát Dực Hắc Xà Hoàng! Hãy tự lực chinh phục Đế Đô & Vân Lam Sơn (tới khi Đấu Tông Mỹ Đỗ Toa xuất thế bảo hộ)!",
			Color("#ADB5BD")
		)
	else:
		var t_unl: bool = (t_mode == "duoc_lao")
		btn_t.set_slot_visual(
			hud._get_cached_tex("res://assets/sprites/icons/skill_duoc_lao_assist.png"),
			"PHỤ THỂ" if t_unl else "KHÓA",
			not t_unl,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#A8DADC")
		)
		btn_t.set_tooltip_info(
			"[T] Cốt Linh Phụ Thể (Dược Lão)" + ("" if t_unl else " — Chưa Mở Khóa"),
			"Hồi 45s · Duy trì 12s · ATK x2.2 & Cốt Linh Lãnh Hỏa" if t_unl else "Mở khóa khi hạ Boss Chương 01: Gia Liệt Áo",
			"Dược Lão mượn thân thể Tiêu Viêm xuất chiến trong 12 giây, bùng phát ngọn Cốt Linh Lãnh Hỏa (#11)!" if t_unl else "Hoàn thành trận đánh bại Gia Liệt Áo cuối Chương 01 để mở khóa chiêu này.",
			Color("#70D6FF") if t_unl else Color("#ADB5BD")
		)

	# 4. Ô Lướt [Space] (Tự nâng cấp hiển thị Viêm Đế Bước / Đấu Thánh Không Gian / Đấu Tôn Xé Không / Đấu Tông / Đấu Vương / Lôi Động / Tử Vân Dực!)
	var has_emperor_step: bool = EmperorRealmManager.is_viem_de_emperor(PlayerData)
	var has_saint_dom: bool = SaintRealmManager.has_dau_thanh_domain(PlayerData)
	var has_spatial_blink: bool = PlayerData.has_dau_ton_spatial_blink()
	var has_void_step: bool = PlayerData.has_dau_tong_void_step()
	var has_dw_wings: bool = PlayerData.has_dau_vuong_wings()
	var has_thunder: bool = PlayerData.is_skill_unlocked("tam_thien_loi_dong")
	var has_wings: bool = PlayerData.has_tu_van_duc_equipped() or has_dw_wings
	var dash_sub: String = "Đế Bước" if has_emperor_step else ("Thánh Vực" if has_saint_dom else ("Xé Không" if has_spatial_blink else ("Hư Không" if has_void_step else ("Lôi·Dực" if (has_dw_wings and has_thunder) else ("Hóa Dực" if has_dw_wings else ("Lôi Động" if has_thunder else ("Tử Vân" if has_wings else "Lướt")))))))
	var dash_col: Color = Color("#FFF3B0") if has_emperor_step else (Color("#FFD700") if has_saint_dom else (Color("#72EFDD") if has_spatial_blink else (Color("#C77DFF") if has_void_step else (Color("#00F5D4") if has_dw_wings else (Color("#72EFDD") if has_thunder else (Color("#E0AAFF") if has_wings else Color("#70D6FF")))))))
	var dash_tex: Texture2D = hud._get_cached_tex("res://assets/sprites/icons/skill_tam_thien_loi_dong.png") if has_thunder else (
		hud._get_cached_tex("res://assets/sprites/icons/skill_tu_van_duc.png") if has_wings else hud._get_cached_tex("res://assets/sprites/icons/skill_dash.png")
	)
	hud.slot_dash.set_slot_visual(
		dash_tex,
		dash_sub,
		false,
		has_wings or has_thunder or has_void_step or has_spatial_blink or has_saint_dom or has_emperor_step,
		false,
		dash_col
	)
	if has_emperor_step:
		hud.slot_dash.set_tooltip_info(
			"[Space] VIÊM ĐẾ — ĐẾ BƯỚC HƯ KHÔNG (1.280 px/s)!",
			"Hồi 1.10s · Tốc độ 1.280px/s · Bất tử I-frame 0.85s · Đánh thường phóng 5 Đạo Kiếm Khí 23 Sắc!",
			"Quyền năng Đấu Đế Chương 11: Bước qua không gian bất chấp trọng lực, +45% Đế Uy trước mọi kẻ địch dưới bậc Đấu Đế!",
			Color("#FFF3B0")
		)
	elif has_saint_dom:
		hud.slot_dash.set_tooltip_info(
			"[Space] ĐẤU THÁNH KHÔNG GIAN — Xé Không Cực Hạn!",
			"Hồi 0.38s · Tốc độ 1.120px/s · Bất tử I-frame 0.70s · Đánh thường tự phóng 3 Kiếm Khí Xé Không!",
			"Quyền năng bậc Đấu Thánh Chương 10: Chưởng khống lãnh địa không gian, bước đi không trọng lực & +25% Thánh Uy trước địch dưới bậc Đấu Thánh!",
			Color("#FFD700")
		)
	elif has_spatial_blink:
		hud.slot_dash.set_tooltip_info(
			"[Space] Đấu Tôn — Xé Rách Không Gian (True Spatial Blink)!",
			"Hồi 0.48s · Tốc độ 980px/s · Bất tử I-frame 0.60s · Sóng chấn động không gian!",
			"Đặc quyền Đấu Tôn Chương 09: Xé toạc khe nứt hư không dịch chuyển tức thì né trọn đại chiêu Boss Đấu Thánh!",
			Color("#72EFDD")
		)
	elif has_void_step:
		hud.slot_dash.set_tooltip_info(
			"[Space] Đấu Tông — Đạp Hư Không + Tam Thiên Lôi Động!",
			"Tốc độ xé gió 860px/s · I-frame kéo dài · Sóng không gian dưới chân!",
			"Cường giả Đấu Tông đạp không nhi hành, mỗi bước lướt xé rách gợn sóng không gian né trọn đại chiêu Boss!",
			Color("#C77DFF")
		)
	elif has_dw_wings:
		hud.slot_dash.set_tooltip_info(
			"[Space] Đấu Khí Hóa Dực" + (" + Tam Thiên Lôi Động!" if has_thunder else " — Ngự Không Phi Hành!"),
			"Hồi 0.56s · Tốc độ bay 780px/s · I-frame 0.48s · +15% SPD vĩnh viễn!",
			"Đôi cánh Đấu Khí Lưu Ly sau lưng Đấu Vương bùng phát tốc độ bay cực hạn" + (" kết hợp Tàn Ảnh Lôi Điện giật tê kẻ địch!" if has_thunder else ", dễ dàng vượt qua đại trận & kỹ năng diện rộng của Boss!"),
			Color("#00F5D4")
		)
	elif has_thunder:
		hud.slot_dash.set_tooltip_info(
			"[Space] Tam Thiên Lôi Động — Thân Pháp Lôi Thiểm!",
			"Hồi 0.62s · I-frame 0.42s · Để lại Tàn Ảnh Lôi Điện giật chậm & phá thế địch!",
			"Thân pháp Địa Giai của Phong Lôi Các: mỗi lần lướt né hóa hồ quang sấm sét để lại Lôi Ảnh gây tê liệt kẻ địch áp sát!",
			Color("#72EFDD")
		)
	else:
		hud.slot_dash.set_tooltip_info(
			"[Space] Lướt Tử Vân Dực (ĐÃ NÂNG CẤP!)" if has_wings else "[Space] Thân Pháp Lướt Né",
			"Hồi 0.64s · Tăng +35% cự ly & I-frame dài hơn!" if has_wings else "Hồi 0.7s · Có khung bất tử (I-frame)",
			"Đôi cánh Tử Vân Dực bùng phát lông vũ tím giúp bay vọt vượt đạn Boss cực nhanh!" if has_wings else "Lướt nhanh né cú húc Sơn Trư và 3 tia Nguyệt Nha của Boss! (Lấy Tử Vân Dực ở Huyền Nhai Sơn Động để nâng cấp!)",
			Color("#C77DFF") if has_wings else Color("#4CC9F0")
		)

	# 5. Ô Trọng Áp [C]
	var has_xich: bool = PlayerData.has_huyen_trong_xich_equipped()
	var sealed: bool = has_xich and PlayerData.is_ruler_sealed
	hud.slot_weight.set_slot_visual(
		hud._get_cached_tex("res://assets/sprites/weapons/huyen_trong_xich.png"),
		"+30%" if sealed else ("Mở" if has_xich else "KHÓA"),
		not has_xich,
		sealed,
		false,
		Color("#70D6FF") if sealed else Color("#FFE599")
	)
	hud.slot_weight.set_tooltip_info(
		"[C] Phong Ấn Huyền Trọng Xích" + (" (ĐANG BẬT)" if sealed else ""),
		"Trạng thái: Trọng Áp (-15% SPD, +30% EXP) <-> Giải Phong" if has_xich else "Cần đeo vũ khí [Huyền Trọng Xích]",
		"Bấm để chuyển đổi tức thì giữa chế độ Khổ Tu (+30% EXP) và Giải Phong toàn tốc khi đánh Boss!" if has_xich else "Hạ Boss Gia Liệt Áo cuối Chương 01 để Dược Lão trao Huyền Trọng Xích.",
		Color("#70D6FF")
	)

	# 6. Ô Đồng Hành [G] (Trọn bộ 7 Đồng Hành Ch.01–Ch.08)
	var has_comp: bool = not PlayerData.unlocked_companions.is_empty()
	var cur_c: String = PlayerData.active_companion_id
	var c_tex: Texture2D = hud._get_cached_tex("res://assets/sprites/npcs/npc_duoc_lao.png")
	var c_sub: String = "Bật" if cur_c != "" else ("Tắt" if has_comp else "KHÓA")
	var c_col: Color = Color("#80ED99")
	if cur_c == "tieu_y_tien":
		if PlayerData.has_flag("ch07_thien_doc_nu_joined"):
			c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_thien_doc_nu.png")
			c_sub = "Thiên Độc"
			c_col = Color("#E0AAFF")
		else:
			c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_tieu_y_tien.png")
			c_sub = "Y Tiên"
	elif cur_c == "dia_yeu_khoi":
		var is_tyk_ic: bool = PlayerData.has_flag("ch08_dan_hoi_champion")
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_dia_yeu_khoi.png")
		c_sub = "Thiên Khôi" if is_tyk_ic else "Yêu Khôi"
		c_col = Color("#FFD166") if is_tyk_ic else Color("#CAF0F8")
	elif cur_c == "thien_hoa_ton_gia":
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_thien_hoa_ton_gia.png")
		c_sub = "Thiên Hỏa"
		c_col = Color("#FF9F1C")
	elif cur_c == "thai_lan":
		c_tex = hud._get_cached_tex("res://assets/sprites/enemies/pet_thai_lan.png")
		c_sub = "Thải Lân"
		c_col = Color("#72EFDD")
	elif cur_c == "huan_nhi":
		var is_hn_st: bool = PlayerData.has_flag("ch10_tinh_lien_tamed")
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_huan_nhi_dau_thanh.png" if is_hn_st else "res://assets/sprites/npcs/npc_huan_nhi.png")
		c_sub = "Thánh Huân" if is_hn_st else "Huân Nhi"
		c_col = Color("#FFD700")
	elif cur_c == "tu_nghien":
		var is_lh_ic: bool = PlayerData.has_flag("ch09_co_long_unified")
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_tu_nghien_long_hoang.png" if is_lh_ic else "res://assets/sprites/npcs/npc_tu_nghien.png")
		c_sub = "Long Hoàng" if is_lh_ic else "Tử Nghiên"
		c_col = Color("#FFD166") if is_lh_ic else Color("#E0AAFF")
	elif cur_c == "thanh_lan":
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_thanh_lan_dau_ton.png")
		c_sub = "Thanh Lân"
		c_col = Color("#80ED99")
	elif cur_c == "van_van_hoa_tong":
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_van_van_hoa_tong.png")
		c_sub = "Vân Vận"
		c_col = Color("#FFC8DD")
	elif cur_c == "bac_vuong":
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_bac_vuong.png")
		c_sub = "Bắc Vương"
		c_col = Color("#FFD700")
	elif cur_c == "thai_lan_tieu_tieu":
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_tieu_tieu.png")
		c_sub = "Tiêu Tiêu"
		c_col = Color("#FBCFE8")
	elif cur_c == "chuc_khon_long_hoang":
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_chuc_khon_long_hoang.png")
		c_sub = "Chúc Khôn"
		c_col = Color("#FFE66D")
	elif cur_c == "duoc_lao_phantom":
		var is_bt_ic: bool = PlayerData.has_flag("ch09_duoc_tran_revived")
		c_tex = hud._get_cached_tex("res://assets/sprites/npcs/npc_duoc_tran_ban_thanh.png" if is_bt_ic else "res://assets/sprites/npcs/npc_duoc_lao.png")
		c_sub = "Dược Trần" if is_bt_ic else "Dược Lão"
		c_col = Color("#E0FBFC") if is_bt_ic else Color("#70D6FF")
	hud.slot_companion.set_slot_visual(
		c_tex,
		c_sub,
		not has_comp,
		cur_c != "",
		false,
		c_col
	)
	hud.slot_companion.set_tooltip_info(
		"[G] Đồng Hành Trợ Chiến — " + (PlayerData.get_companion_display_name(cur_c) if has_comp else "Chưa mở"),
		"Bấm để triệu hồi hoặc chuyển đổi Đồng Hành (%d/12 + Khí Linh Tiểu Y)" % PlayerData.unlocked_companions.size() if has_comp else "Mở khóa 12 Đồng Hành từ Ch.01 -> Ch.11 (Dược Trần, Thiên Độc Nữ, Thải Lân & Tiêu Tiêu, Huân Nhi, Tử Nghiên, Bắc Vương, Long Hoàng Chúc Khôn...)",
		"Đủ 12 Đồng Hành AI (gồm Long Hoàng Chúc Khôn Cửu Tinh Đấu Thánh Đỉnh Phong & Bắc Vương) kết hợp Khí Linh Tiểu Y (#3) bay hộ vệ thường trực!",
		c_col
	)

	# 7. 3 Ô Đan Dược Bấm Uống Ngay [1] [2] [3] (hỗ trợ đầy đủ đan Ch.01–Ch.11!)
	var pill_visual_meta: Dictionary = {
		"pill_ngung_huyet_tan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Hồi ngay +%d HP", "col": Color("#EF476F") },
		"pill_bang_tam_dan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Tứ Phẩm · Hồi ngay +%d HP!", "col": Color("#70D6FF") },
		"pill_huyet_ngung_dan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Ngũ Phẩm · Hồi ngay +%d HP!", "col": Color("#FF4D6D") },
		"pill_hoa_lien_dan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Ngũ Phẩm Bàn Môn · Hồi +%d HP!", "col": Color("#FF9F1C") },
		"pill_viem_minh_linh_dan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Lục Phẩm Viêm Minh · Hồi +%d HP!", "col": Color("#FF4D6D") },
		"pill_hoa_bo_dan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Thất Phẩm Trung Châu · Hồi +%d HP!", "col": Color("#FF6B00") },
		"pill_bach_hoa_ngoc_lo": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Hoa Tông · Hồi +%d HP!", "col": Color("#FF8FA3") },
		"pill_kim_cuong_bat_hoai": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Bát Phẩm · Hồi +%d HP!", "col": Color("#FFD166") },
		"pill_duong_dau_dan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Đường Đậu Đan · Hồi +%d HP!", "col": Color("#F9A8D4") },
		"pill_cuu_duong_hoan_cot": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Bát Phẩm Cao · Hồi +%d HP!", "col": Color("#FB923C") },
		"pill_tru_nhan_thanh_dan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Cửu Phẩm · Hồi +%d HP!", "col": Color("#FFD700") },
		"pill_hoi_khi_dan": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Hồi ngay +%d Đấu Khí (QI)", "col": Color("#38BDF8") },
		"pill_thanh_lien_tu": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Kỳ Bảo · Hồi ngay +%d Đấu Khí!", "col": Color("#2EC4B6") },
		"pill_dan_hoan_ngot": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Kẹo Đan Tử Nghiên · Hồi +%d QI!", "col": Color("#E0AAFF") },
		"pill_thanh_hon_hoa_sinh": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Lục Phẩm · Hồi ngay +%d Đấu Khí!", "col": Color("#56CFE1") },
		"pill_thang_linh_dan": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Thất Phẩm Trung Châu · Hồi +%d QI!", "col": Color("#72EFDD") },
		"pill_phuc_hon_thanh_dan": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Bát Phẩm · Hồi +%d QI!", "col": Color("#72EFDD") },
		"pill_thanh_linh_phuc_nguyen": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Chuẩn Cửu Phẩm · Hồi 80%% HP & +%d QI!", "col": Color("#F472B6") },
		"pill_truc_co_linh_dich": { "icon": "res://assets/sprites/icons/pill_exp_jade.png", "sub": "Nhận ngay +%d EXP Đấu Khí", "col": Color("#06D6A0") }
	}
	for pi in range(3):
		var slot_n: int = pi + 1
		var pid: String = PlayerData.get_effective_quick_pill(slot_n)
		var idef: Dictionary = GameDatabase.get_item_def(pid)
		var pmeta: Dictionary = pill_visual_meta.get(pid, { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Đan dược", "col": Color("#FFE599") })
		var cnt: int = PlayerData.get_item_count(pid)
		var pb: MobaSlotButton = hud.pill_slots[pi]
		var badge_col: Color = Color("#72EFDD") if (pid == "pill_bang_tam_dan" or pid == "pill_thanh_lien_tu" or pid == "pill_hoa_bo_dan" or pid == "pill_thang_linh_dan") and cnt > 0 else (Color("#FFFFFF") if cnt > 0 else Color("#6C757D"))
		pb.set_slot_visual(hud._get_cached_tex(str(pmeta["icon"])), "x%d" % cnt, false, false, cnt <= 0, badge_col)

		var eff_amt: int = 0
		var itype: String = str(idef.get("type", ""))
		if itype == "consumable_hp":
			eff_amt = int(round(float(idef.get("heal_hp", 75.0)) * PlayerData.get_heal_effectiveness_mult()))
		elif itype == "consumable_qi":
			eff_amt = int(round(float(idef.get("restore_qi", 55.0))))
		elif itype == "consumable_exp":
			eff_amt = int(idef.get("grant_exp", 240))
		var sub_str: String = (str(pmeta["sub"]) % eff_amt) if str(pmeta["sub"]).find("%d") != -1 else str(pmeta["sub"])
		pb.set_tooltip_info(
			"[%d] %s (Đang có: %d)" % [slot_n, str(idef.get("name", pid)), cnt],
			sub_str,
			str(idef.get("description", "")) + "\n(Tự động chuyển sang đan cao cấp khi hết đan sơ cấp — hoặc đổi trực tiếp trong [L] / [I]!)",
			pmeta["col"] as Color
		)

	# 8. 8 Nút Hệ Thống góc trái dưới
	var sys_meta: Dictionary = {
		"I": { "icon": "res://assets/sprites/icons/icon_armor.png", "sub": "Đồ", "locked": false, "glow": false, "t": "[I] Trang Bị 10 Ô & Cường Hóa", "d": "Mặc/tháo 10 ô trang bị, xem Set Bonus, cường hóa & phân giải đồ thừa." },
		"K": { "icon": "res://assets/sprites/icons/skill_toai_thach.png", "sub": "Kỹ", "locked": false, "glow": false, "t": "[K] Kho %d Đấu Kỹ & Xưởng Hỏa Liên" % GameDatabase.skills_by_id.size(), "d": "Tự do lắp các Đấu Kỹ đã lĩnh ngộ vào phím Q/E/R, xem Độ Thông Thạo và ghép Hỏa cho Phật Nộ Hỏa Liên." },
		"B": { "icon": "res://assets/sprites/icons/icon_stone.png", "sub": "Đột!" if PlayerData.is_at_bottleneck() else "Cảnh", "locked": false, "glow": PlayerData.is_at_bottleneck(), "t": "[B] Cảnh Giới & Đột Phá", "d": "Xem tiến độ 12 Đại Cảnh Giới, Linh Hồn Lực và bấm Đột Phá khi đạt 9 Đoạn/Tinh Đỉnh Phong!" },
		"L": { "icon": "res://assets/sprites/icons/icon_cauldron.png", "sub": "Đan", "locked": not PlayerData.is_alchemy_unlocked(), "glow": false, "t": "[L] Lò Luyện Đan Tương Tác", "d": "Khai lò luyện đan qua Mini-game Khống Hỏa [Space] & Chắn Đan Lôi [E]!" },
		"H": { "icon": "res://assets/sprites/icons/skill_hoa_lien.png", "sub": "Hỏa", "locked": not PlayerData.is_flames_unlocked(), "glow": false, "t": "[H] Dị Hỏa Bảng & Phần Quyết", "d": "Xem và vận chuyển các Thú Hỏa / Dị Hỏa đã thu phục theo đúng cốt truyện." },
		"M": { "icon": "res://assets/sprites/icons/icon_pendant.png", "sub": "Map", "locked": false, "glow": false, "t": "[M] Thế Giới · Hồng Nhan · Thiên Phủ · Tâm Ma · Tháp & Đồ Giám", "d": "Xem %d bản đồ (Ch.01–11), Quản Trị Thiên Phủ Liên Minh (6 Công Trình · 25 Boss Cường Bảng), Buff Hồng Nhan, Tâm Ma Luyện Cảnh (64 Boss), Thiên Phần Tháp & Đồ Giám Vạn Thú!" % GameDatabase.maps_ordered.size() },
		"F5": { "icon": "res://assets/sprites/icons/icon_ring.png", "sub": "Lưu", "locked": false, "glow": false, "t": "[F5] Lưu Nhanh Vào Ô %d" % PlayerData.active_save_slot, "d": "Lưu tức thì toàn bộ tiến độ tu luyện, bản đồ & trang bị vào ô hiện tại." },
		"ESC": { "icon": "res://assets/sprites/icons/icon_necklace.png", "sub": "Menu", "locked": false, "glow": false, "t": "[ESC] Menu Tạm Dừng & Hiển Thị", "d": "Lưu/Tải 3 Ô Nạp Giới, chỉnh Fullscreen/VSync/FPS/Rung màn hình & Âm lượng BGM/SFX." }
	}
	for k in sys_meta.keys():
		if hud.sys_buttons.has(k):
			var sm: Dictionary = sys_meta[k]
			var b: MobaSlotButton = hud.sys_buttons[k]
			b.set_slot_visual(hud._get_cached_tex(str(sm["icon"])), str(sm["sub"]), bool(sm["locked"]), bool(sm["glow"]), false)
			b.set_tooltip_info(str(sm["t"]), "Bấm chuột trực tiếp hoặc nhấn phím [%s]" % str(k), str(sm["d"]), Color("#FFD166"))

	hud._refresh_interact_button()
