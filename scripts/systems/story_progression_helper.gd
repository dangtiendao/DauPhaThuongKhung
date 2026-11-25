class_name StoryProgressionHelper
extends RefCounted
## Trợ Lý Khởi Tạo Trạng Thái, Chế Độ DEMO & Data-Driven Story Engine (Tách mô-đun từ player_data.gd):
##   - Khởi tạo Chế Độ DEMO (Mở Khóa Tất Cả 46 Map Ch.01–08)
##   - Khởi tạo trạng thái chuẩn nguyên tác Phút 0
##   - Xử lý cờ cốt truyện (set_story_flag), đánh giá điều kiện JSON & thi hành hiệu ứng JSON (Ch.01–Ch.11)

const PanGateMgr = preload("res://scripts/systems/pan_gate_manager.gd")


static func activate_demo_unlock_all(pd, slot_idx: int = 3) -> void:
	pd.active_save_slot = clampi(slot_idx, 1, pd.MAX_SAVE_SLOTS)
	pd.last_played_slot = pd.active_save_slot
	pd.is_demo_mode = true
	pd.has_saved_player_pos = false
	pd.saved_player_pos = Vector2.ZERO
	pd.auto_save_timer = 0.0
	pd.current_map_id = "ch01_tieu_gia"

	pd.realm_index = 9 # Cửu Chuyển Đấu Tôn Đỉnh Phong (Xé Rách Không Gian · Trọn 100% Quyển I–III Ch.01–Ch.09!)
	pd.stage = 9
	pd.nine_turn_level = 9
	pd.bonus_soul = 1650 # Thiên Cảnh Trung Kỳ Đỉnh Phong (Luyện Bát Phẩm Đan & Khống 10 Kim Khôi!)
	pd.gold = 950000
	pd.enhance_stones = 999

	# Mở toàn bộ cờ cốt truyện để đi tất cả 46 bản đồ Ch01–Ch08 & Viêm Minh / Thiên Bảo Phường / Lò Đan Bát Phẩm / 28 Hỏa!
	pd.story_flags = {
		"tu_hon_done": true,
		"duoc_lao_awake": true,
		"huan_nhi_gift": true,
		"bought_bao_bo": true,
		"bought_hap_chuong": true,
		"ready_thanh_nien_le": true,
		"unlocked_bat_cuc_bang": true,
		"got_gia_nam_leave": true,
		"killed_lieu_tich": true,
		"ch01_completed": true,
		"met_tieu_y_tien": true,
		"found_doc_kinh": true,
		"got_tu_van_duc": true,
		"met_van_chi": true,
		"killed_tieu_su_vuong": true,
		"absorbed_tu_hoa": true,
		"killed_muc_luc": true,
		"killed_muc_xa": true,
		"ch02_farewell_done": true,
		"ch02_completed": true,
		"met_tieu_dinh_le": true,
		"pact_hai_ba_dong": true,
		"met_thanh_lan": true,
		"got_thanh_lien_dai": true,
		"beat_co_ha_mac_ba_tu": true,
		"snatched_thanh_lien_hoa": true,
		"ch03_completed": true,
		"ch04_pha_ach_done": true,
		"ch04_mac_gia_done": true,
		"ch04_nham_kieu_mask": true,
		"ch04_cured_nap_lan_kiet": true,
		"ch04_dan_hoi_champion": true,
		"ch04_uoc_hen_revealed": true,
		"ch04_van_yen_started": true,
		"ch04_medusa_saved": true,
		"ch04_hon_dien_clue": true,
		"ch04_second_van_lam_ready": true,
		"ch04_killed_van_lang": true,
		"ch04_tieu_toc_no_huyet": true,
		"ch04_kim_viem_ngoc": true,
		"ch04_completed": true,
		"ch05_killed_van_phan": true,
		"ch05_killed_pham_lang": true,
		"ch05_duoc_lao_awakened_ch05": true,
		"ch05_auction_done": true,
		"ch05_read_mang_thien_xich": true,
		"ch05_huan_nhi_reunited": true,
		"ch05_beat_ngo_hao": true,
		"ch05_got_su_ho": true,
		"ch05_killed_la_hau": true,
		"ch05_completed": true,
		"ch06_ban_mon_founded": true,
		"ch06_tu_nghien_joined": true,
		"ch06_got_dia_tam_nhu": true,
		"ch06_got_top10_pass": true,
		"ch06_tower_eruption_done": true,
		"ch06_absorbed_van_lac": true,
		"ch06_completed": true,
		"ch07_huan_nhi_farewell_done": true,
		"ch07_broke_dau_hoang": true,
		"ch07_co_ha_ally": true,
		"ch07_tieu_chien_relic_done": true,
		"ch07_killed_van_son": true,
		"ch07_duoc_lao_captured": true,
		"ch07_van_lam_disbanded": true,
		"ch07_viem_minh_founded": true,
		"ch07_thai_lan_pill_done": true,
		"ch07_killed_nhan_lac_thien": true,
		"ch07_thien_doc_nu_joined": true,
		"ch07_tieu_le_cured": true,
		"ch07_killed_hat_tat_nham": true,
		"ch07_got_binh_nap_hon": true,
		"ch07_lien_quan_aura": true,
		"ch07_captured_han_phong_jar": true,
		"ch07_killed_dia_ma_lao_quy": true,
		"ch07_dia_yeu_khoi_forged": true,
		"ch07_thai_lan_farewell_done": true,
		"ch07_completed": true,
		"ch08_han_tuyet_saved": true,
		"ch08_han_nguyet_met": true,
		"ch08_escaped_phi_thien": true,
		"ch08_helped_kim_thach": true,
		"ch08_killed_vuong_tran": true,
		"ch08_kim_thu_secret_done": true,
		"ch08_broke_dau_tong": true,
		"ch08_han_secret_gift_done": true,
		"ch08_phong_ton_ally": true,
		"ch08_beat_phuong_thanh_nhi": true,
		"ch08_ma_doc_ban_cured": true,
		"ch08_beat_bang_ha_thanh_hai": true,
		"ch08_huan_nhi_de_an_done": true,
		"ch08_passed_cuu_long_trial": true,
		"ch08_got_tam_huyen_tam_bien": true,
		"ch08_stele_shattered": true,
		"ch08_huyen_y_memory_done": true,
		"ch08_dan_hoi_champion": true,
		"ch08_hung_chien_oath_done": true,
		"ch08_repelled_mo_cot": true,
		"ch08_killed_tam_thien_dragon": true,
		"ch08_completed": true,
		"FLAG_ZI_YAN_COMPANION": true,
		"FLAG_MEDUSA_SOUL_BOND": true,
		"FLAG_FALLING_HEART_FLAME": true,
		"FLAG_HAN_FENG_SOUL_ESCAPED": true,
		"FLAG_YAN_ALLIANCE_FOUNDED": true,
		"FLAG_DUOC_LAO_CAPTURED": true,
		"FLAG_VAN_LAM_DISBANDED": true,
		"FLAG_HAN_FENG_CAPTURED_JAR": true,
		"FLAG_DIA_YEU_KHOI_FORGED": true,
		"FLAG_BOOK_02_COMPLETED": true,
		"FLAG_ESCAPED_FEI_TIAN": true,
		"FLAG_DAU_TONG_AWAKENED": true,
		"FLAG_MA_DOC_BAN_CURED": true,
		"FLAG_THIEN_HOA_REVIVED": true,
		"FLAG_GU_CLAN_INTERVENTION": true,
		"FLAG_PHAN_VIEM_ALLY": true,
		"FLAG_SOUL_PEAK_LINH_CANH": true,
		"FLAG_DAN_HOI_CHAMPION": true,
		"FLAG_THIEN_YEU_KHOI_EVOLVED": true,
		"FLAG_CH08_COMPLETED": true,
		"FLAG_TAM_THIEN_IMMORTAL_BODY": true,
		"FLAG_FOUR_FLAME_LOTUS": true,
		"ch09_tinh_van_rally": true,
		"ch09_beat_trich_tinh": true,
		"ch09_saved_duoc_lao": true,
		"ch09_nirvana_awakened": true,
		"ch09_broke_dau_ton": true,
		"ch09_sq01_thiet_kiem_grave_done": true,
		"ch09_beat_yeu_hoa": true,
		"ch09_hoa_tong_saved": true,
		"ch09_sq02_van_van_peach_done": true,
		"ch09_thanh_lan_reunited": true,
		"ch09_sq03_thanh_lan_serpent_done": true,
		"ch09_beat_tan_hon_tao_hoa": true,
		"ch09_got_tao_hoa_palm": true,
		"ch09_duoc_tran_revived": true,
		"ch09_forged_ten_puppets": true,
		"ch09_sq04_hac_ma_loi_king_done": true,
		"ch09_beat_bac_long_vuong": true,
		"ch09_co_long_unified": true,
		"ch09_killed_co_yeu_boss": true,
		"ch09_beat_co_yeu": true,
		"ch09_beat_huyet_dao_thanh_gia": true,
		"ch09_completed": true,
		"ch09_sq05_tieu_huyen_stele_done": true,
		"FLAG_SAVED_DUOC_LAO": true,
		"FLAG_DAU_TON_AWAKENED": true,
		"FLAG_TINH_VAN_CAC_FOUNDED": true,
		"FLAG_HOA_TONG_ALLY": true,
		"FLAG_THANH_LAN_COMPANION": true,
		"FLAG_GOT_TAO_HOA_PALM": true,
		"FLAG_DUOC_TRAN_BAN_THANH": true,
		"FLAG_FIVE_FLAME_LOTUS": true,
		"FLAG_FOUR_MAP_COMPLETE": true,
		"FLAG_THAP_TUYET_KIM_KHOI": true,
		"FLAG_KIM_KHOI_THONG_LINH": true,
		"FLAG_CO_LONG_UNIFIED": true,
		"FLAG_THIEN_MO_PASS": true,
		"FLAG_NINE_TURN_PEAK": true,
		"FLAG_TIEU_TOC_VAN": true,
		"FLAG_TIEU_HUYEN_OATH": true,
		"FLAG_CH09_COMPLETED": true,
		"FLAG_BOOK_03_COMPLETED": true,
	}
	pd.affection = { "huan_nhi": 100, "tieu_y_tien": 100, "van_chi": 100, "thanh_lan": 100, "my_do_toa": 100 }
	pd.story_relics = [
		"Chế Độ DEMO — Mở Khóa 100%% Quyển I–III (%d Map · Ch01–Ch09 · 28 Hỏa · Cửu Chuyển 9/9)" % GameDatabase.maps_ordered.size(),
		"Ấn Ký Tôn Nghiêm (+5% Công Kích)",
		"Hắc Ảnh Phù (+8% Tốc Chạy)",
		"Thanh Liên Đài (+15% EXP & +40% Hồi QI)",
		"Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (4/4 TRỌN BỘ!)",
		"Sơ Hình Phật Nộ Hỏa Liên & Thần Thú Thải Lân",
		"Quán Quân Đan Hội Gia Mã · Lạc Độc Ấn",
		"Tàn Dư Hắc Vụ Xiềng Xích (Manh Mối Hồn Điện)",
		"Kim Viêm Hộ Hồn Ngọc (Hồi Sinh 1 Lần 50% HP)",
		"Hỏa Năng Tinh Tạp · Tân Sinh Vương Già Nam",
		"Lưu Ly Liên Tâm Hỏa (#19 + #14) · Đấu Khí Hóa Dực",
		"Minh Chủ Đế Quốc VIÊM MINH · Tam Sắc Dị Hỏa",
		"Vệ Sĩ Bất Tử: Chuẩn Thiên Yêu Khôi & Thiên Hỏa Tôn Giả (#7)",
		"ĐỘT PHÁ ĐẤU TÔNG · Đạp Hư Không · Không Gian Phong Tỏa",
		"Quán Quân Đan Hội Trung Châu · #9 Tam Thiên Diễm Viêm Hỏa (Bất Tử Chi Thể)",
		"Thiếu Các Chủ TINH VẪN CÁC · Bán Thánh Dược Trần (#11 Cốt Linh · Ngũ Sắc Hỏa Liên)",
		"Thập Tuyệt Kim Khôi Trận · Long Hoàng Tử Nghiên · Thiên Giai Đại Thiên Tạo Hóa Chưởng",
		"Tổ Tiên TIÊU HUYỀN Hoán Huyết — Tộc Văn Đấu Đế Tiêu Tộc [X] & Cửu Chuyển Đấu Tôn!"
	]

	# Mở toàn bộ 28 ngọn Hỏa, vận chuyển #9 Tam Thiên Diễm Viêm Hỏa & ghép sẵn NGŨ SẮC PHẬT NỘ HỎA LIÊN!
	pd.unlocked_flames = []
	for fl in GameDatabase.flames_ordered:
		if fl is Dictionary:
			var fid: String = str(fl.get("id", ""))
			if fid != "":
				pd.unlocked_flames.append(fid)
	pd.equipped_flame_id = "di_hoa_09_tam_thien"
	pd.lotus_fusion_flames = ["di_hoa_19_thanh_lien", "di_hoa_14_van_lac", "di_hoa_11_cot_linh", "di_hoa_09_tam_thien", "hoa_sinh_hoa"]

	# Mở toàn bộ 28/28 Đấu Kỹ + [F] Ngũ Sắc Hỏa Liên + [T] Bán Thánh Dược Trần + [X] Tộc Văn Tiêu Tộc!
	pd.unlocked_skills = []
	for sid in GameDatabase.skills_by_id.keys():
		pd.unlocked_skills.append(str(sid))
	pd.slot_q_skill = "khong_gian_dai_thu_an"
	pd.slot_e_skill = "dai_thien_tao_hoa_chuong"
	pd.slot_r_skill = "thap_tuyet_kim_khoi_tran"
	pd.slot_f_skill = "phat_no_hoa_lien"
	pd.duoc_lao_assist_unlocked = true

	# Mở toàn bộ 9 Đồng Hành AI [G] (gồm Thanh Lân #8, Vân Vận Hoa Tông #9, Long Hoàng Tử Nghiên & Bán Thánh Dược Trần!)
	pd.unlocked_companions = ["duoc_lao_phantom", "tieu_y_tien", "thai_lan", "huan_nhi", "tu_nghien", "dia_yeu_khoi", "thien_hoa_ton_gia", "thanh_lan", "van_van_hoa_tong"]
	pd.active_companion_id = "van_van_hoa_tong"
	pd.weapon_core_sockets = ["core_nang_luong_9", "core_nang_luong_8", "core_tinh_7"]
	pd.fire_energy = 3200
	pd.ma_doc_ban_stacks = 0
	pd.is_nhi_bien_active = false
	pd.is_tam_bien_active = false
	pd.is_toc_van_active = false
	pd.is_kim_khoi_tran_active = false
	pd.immortal_revive_cd = 0.0
	pd.tam_thien_regen_tick = 0.0
	pd.tower_active_buffs.clear()
	pd.pan_gate_state = {
		"dan_duong": 3,
		"vo_duong": 3,
		"am_duong": 3,
		"am_vong": 3,
		"tinh_than_tran": 2,
		"last_harvest_playtime": -100.0,
		"total_harvests": 0,
		"ziyan_expeditions": 2,
		"strong_rank_cleared": {}
	}
	pd.van_lac_cultivation_tick = 0.0
	pd.am_duong_buff_timer = 0.0

	# Trang bị 10 Ô Full Bộ #9 Tinh Vẫn Thiên Mộ (Đế Phẩm) + Bảo Vật trong Nạp Giới!
	pd.equipped_gear = {
		"weapon": EquipmentSystem.roll_equipment_instance("wpn_xich_tao_hoa_thien_mo", "de"),
		"armor": EquipmentSystem.roll_equipment_instance("arm_tinh_van_thieu_cac_bao", "de"),
		"legs": EquipmentSystem.roll_equipment_instance("leg_bi_giap_kho", "de"),
		"boots": EquipmentSystem.roll_equipment_instance("boot_phong_hanh_hai", "de"),
		"gloves": EquipmentSystem.roll_equipment_instance("glv_ho_thu_am_thiet", "de"),
		"necklace": EquipmentSystem.roll_equipment_instance("neck_bang_hoang_tam", "de"),
		"pendant": EquipmentSystem.roll_equipment_instance("pend_thiet_kiem_trung_nghia", "de"),
		"ring": EquipmentSystem.roll_equipment_instance("ring_yeu_lien_co_ngoc", "de"),
		"wings": EquipmentSystem.roll_equipment_instance("wing_xe_rach_hu_khong", "de"),
		"cauldron": EquipmentSystem.roll_equipment_instance("caul_ban_thanh_tinh_than_dinh", "de")
	}
	pd.gear_bag = [
		EquipmentSystem.roll_equipment_instance("wpn_xich_tam_thien_tinh_viem", "de"),
		EquipmentSystem.roll_equipment_instance("arm_dan_hoi_quan_quan_bao", "de"),
		EquipmentSystem.roll_equipment_instance("wing_dap_hu_khong_anh", "de"),
		EquipmentSystem.roll_equipment_instance("pend_huyen_tam_ho_hon", "de"),
		EquipmentSystem.roll_equipment_instance("caul_thien_dinh_dan_thap", "de")
	]
	pd.is_ruler_sealed = false

	# Nguyên liệu luyện đan, Năng Lượng Hạch 8–9 & Đan Dược Bát Phẩm x20 mỗi loại!
	pd.inventory = {}
	for iid in GameDatabase.items_by_id.keys():
		pd.inventory[str(iid)] = 20
	pd.quick_hp_pill_id = "pill_phuc_hon_thanh_dan"
	pd.quick_qi_pill_id = "pill_cuu_chuyen_ton_nguyen"
	pd.enemies_killed_total = 40
	pd.claimed_affection_milestones = {}

	pd.active_quest_idx = GameDatabase.all_quests.size()
	pd.active_quest_id = ""
	pd.quest_progress = 0
	pd.all_quests_done = true
	pd.completed_quest_ids = {}
	pd.kim_viem_revive_used = false

	pd._rebuild_gear_cache()
	pd._rebuild_affection_cache()
	pd.current_exp = pd.get_required_exp()
	pd.recalculate_and_clamp(true)
	pd.save_user_settings()
	EventBus.equipment_changed.emit()
	EventBus.skills_updated.emit()
	EventBus.stats_changed.emit()
	EventBus.inventory_changed.emit()
	EventBus.quest_updated.emit()
	EventBus.flame_changed.emit(pd.equipped_flame_id)
	EventBus.companion_changed.emit(pd.active_companion_id)


static func init_canon_starter_state(pd) -> void:
	pd.current_map_id = GameDatabase.start_map_id
	pd.nine_turn_level = 0
	pd.is_toc_van_active = false
	pd.is_kim_khoi_tran_active = false
	pd.equipped_gear = {
		"weapon": {},
		"armor": EquipmentSystem.roll_equipment_instance("arm_ao_vai_tu_luyen", "pham"),
		"legs": EquipmentSystem.roll_equipment_instance("leg_hac_bao_kho", "pham"),
		"boots": {},
		"gloves": {},
		"necklace": {},
		"pendant": {},
		"ring": {},
		"wings": {},
		"cauldron": {}
	}
	pd.gear_bag = []
	pd.weapon_core_sockets = ["", "", ""]
	pd.fire_energy = 0
	pd.tower_best_floor = 0
	pd.tower_active_buffs.clear()
	pd.pan_gate_state = PanGateMgr.default_state()
	pd.van_lac_cultivation_tick = 0.0
	pd.auction_wins = 0
	pd.auction_consigned_total = 0
	pd.am_duong_buff_timer = 0.0
	pd.story_flags = {}
	pd.opened_chests = {}
	pd.affection = { "huan_nhi": 20, "tieu_y_tien": 0, "van_chi": 0, "thanh_lan": 0, "my_do_toa": 0 }
	pd.story_relics = []
	pd.claimed_affection_milestones = {}
	pd.lotus_shield_hp = 0.0
	pd.lotus_dmg_red_timer = 0.0
	pd.lotus_double_herb_timer = 0.0
	pd.player_slow_timer = 0.0
	pd.player_slow_ratio = 0.0
	pd.ma_doc_ban_stacks = 0
	pd.is_nhi_bien_active = false
	pd.unlocked_flames = []
	pd.lotus_fusion_flames = []
	pd.equipped_flame_id = ""
	pd.unlocked_skills = []
	pd.slot_q_skill = ""
	pd.slot_e_skill = ""
	pd.slot_r_skill = ""
	pd.slot_f_skill = ""
	pd.duoc_lao_assist_unlocked = false
	pd.is_ruler_sealed = false
	pd.is_duoc_lao_active = false
	pd.is_flame_buff_active = false
	pd.unlocked_companions = []
	pd.active_companion_id = ""
	pd.active_quest_idx = 0
	pd.active_quest_id = str(GameDatabase.all_quests[0].get("id", "")) if not GameDatabase.all_quests.is_empty() else ""
	pd.completed_quest_ids = {}
	pd.kim_viem_revive_used = false


static func set_story_flag(pd, flag_name: String) -> void:
	if flag_name == "" or pd.has_flag(flag_name):
		return
	pd.story_flags[flag_name] = true

	if flag_name == "tu_hon_done":
		pd.add_story_relic("Ấn Ký Tôn Nghiêm (+5% Công Kích)")
		pd.add_affection("huan_nhi", 15)
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Ước Hẹn 3 Năm đã định! Nhận Buff vĩnh viễn [Ấn Ký Tôn Nghiêm +5% ATK] & mở Cổng Bắc lên Hậu Sơn!")
	elif flag_name == "duoc_lao_awake":
		pd.unlock_flame("pham_hoa", true)
		pd.unlock_skill("toai_thach_chuong", "Q")
		pd.add_item("pill_hoi_khi_dan", 2)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("ĐÃ MỞ KHÓA: Dược Lão thức tỉnh! Mở Lò Luyện Đan [L], Phàm Hỏa [H], Kho Đấu Kỹ [K] và [Q] Toái Thạch Chưởng!")
	elif flag_name == "secret_lang_anh_done":
		pd.add_story_relic("Hắc Ảnh Phù (+8% Tốc Chạy)")
		EventBus.audio_sfx_requested.emit("chest_open")
	elif flag_name == "bought_bao_bo":
		pd.unlock_skill("bao_bo", "")
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("ĐÃ LĨNH NGỘ: Hoàng Giai Cao Cấp Đấu Kỹ [Bạo Bộ]! Bấm [K] để lắp vào ô Q/E/R!")
	elif flag_name == "bought_hap_chuong":
		pd.unlock_skill("hap_xuy_chuong", "Q")
		pd.story_flags["ready_thanh_nien_le"] = true
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("ĐÃ LĨNH NGỘ: Huyền Giai Đấu Kỹ [Hấp Chưởng]! Biểu Tỷ Tiêu Ngọc đã xuất hiện ở Hậu Sơn & Lôi Đài Tiêu Ninh đã mở!")
	elif flag_name == "unlocked_bat_cuc_bang":
		pd.unlock_skill("bat_cuc_bang", "E")
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("ĐÃ LĨNH NGỘ: [E] Bát Cực Băng! Nhược Lâm Đạo Sư của Học Viện Già Nam đang đứng chờ bên cạnh Lôi Đài!")
	elif flag_name == "got_gia_nam_leave":
		pd.add_story_relic("Già Nam Ngọc Bài (2 Năm Nghỉ Phép)")
		EventBus.audio_sfx_requested.emit("chest_open")
		EventBus.banter_triggered.emit("Nhận [Già Nam Ngọc Bài] từ Nhược Lâm Đạo Sư! Hãy rèn lên Đấu Chi Khí 9 Đoạn & đột phá Đấu Giả [B]!")
	elif flag_name == "killed_lieu_tich":
		EventBus.banter_triggered.emit("Ám sát Liễu Tịch thành công! Từ mái ngói đen, bóng ma Đấu Hoàng Lăng Ảnh khẽ gật đầu phất tay xóa sạch toàn bộ dấu vết hiện trường!")
	elif flag_name == "ch01_completed":
		pd.duoc_lao_assist_unlocked = true
		pd.unlock_skill("luc_hop_du_than_xich", "")
		pd.unlock_companion("duoc_lao_phantom", true)
		var xich: Dictionary = EquipmentSystem.roll_equipment_instance("wpn_huyen_trong_xich", "dia")
		pd.add_gear_to_bag(xich)
		if not pd.has_weapon_equipped():
			pd.equip_gear_from_bag(str(xich.get("uid", "")))
		pd.is_ruler_sealed = pd.has_huyen_trong_xich_equipped()
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.skills_updated.emit()
		EventBus.banter_triggered.emit("HOÀN THÀNH CHƯƠNG 01! Nhận [HUYỀN TRỌNG XÍCH] + [Lục Hợp Du Thân Xích] + [T] Phụ Thể + Đồng Hành [G] Dược Lão!")
	elif flag_name == "met_tieu_y_tien":
		pd.unlock_skill("diem_phan_phe_lang_xich", "R")
		pd.unlock_companion("tieu_y_tien", true)
		pd.add_affection("tieu_y_tien", 15)
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("CHƯƠNG 02: Tiểu Y Tiên gia nhập Đồng Hành [G], lĩnh ngộ [R] Diễm Phân Phệ Lãng Xích & mở Vách Đá Bắc vào Huyền Nhai Sơn Động!")
	elif flag_name == "found_doc_kinh":
		pd.add_story_relic("Thất Thải Độc Kinh (Tặng Tiểu Y Tiên)")
	elif flag_name == "got_tu_van_duc":
		pd.add_story_relic("Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (1/4)")
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("KỲ NGỘ ĐẠI THÀNH! Đoạt [Tử Vân Dực] (mặc vào để nâng cấp Lướt Space!), [Tử Vân Dực Kích] & [Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa 1/4]! Cổng Đông Bắc Nội Vi đã mở!")
	elif flag_name == "met_van_chi":
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Vân Chi đồng ý dụ Tử Tinh Dực Sư Vương rời ổ! Hãy tiến vào Hang Tím phía Đông hạ [Tiểu Tử Tinh Dực Sư Vương]!")
	elif flag_name == "killed_tieu_su_vuong":
		pd.add_story_relic("Tử Tinh Nguyên & Bầu Tử Linh Tinh")
		EventBus.audio_sfx_requested.emit("chest_open")
		EventBus.banter_triggered.emit("Đoạt được [Tử Tinh Nguyên] & [Tử Linh Tinh]! Mau quay lại Bờ Suối Trăng Bạc gặp Vân Chi [V] luyện hóa Tử Hỏa!")
	elif flag_name == "absorbed_tu_hoa":
		pd.unlock_flame("tu_tinh_thu_hoa", true)
		var hai_tam: Dictionary = EquipmentSystem.roll_equipment_instance("arm_hai_tam_giap", "dia")
		pd.add_gear_to_bag(hai_tam)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("THÔN PHỆ [TỬ TINH THÚ HỎA] THÀNH CÔNG! Phần Quyết thăng Hoàng Giai Đỉnh Phong + Vân Chi để lại [Hải Tâm Giáp (Địa Phẩm)] trong Nạp Giới [I]!")
	elif flag_name == "killed_muc_luc":
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Đã trừng trị Thiếu Đoàn Trưởng Mục Lực! Cổng Đông Nam dẫn tới Thác Nước Nghìn Trượng (Quyết chiến Mục Xà) đã mở!")
	elif flag_name == "killed_muc_xa":
		pd.unlock_skill("thien_hoa_tam_huyen_bien", "")
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("HẠ GỤC ĐOÀN TRƯỞNG MỤC XÀ! Lĩnh ngộ Bí Pháp [Thiên Hỏa Tam Huyền Biến]! Hãy tiến sang phải vào Thung Lũng U Lan gặp Tiểu Y Tiên [V]!")
	elif flag_name == "ch02_farewell_done":
		pd.story_flags["ch02_completed"] = true
		pd.add_story_relic("Bức Thư Chia Ly Tiểu Y Tiên (Xuất Vân)")
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("HOÀN TẤT CHƯƠNG 02! Cổng Đông sang [CHƯƠNG 03] Sa Mạc Tháp Qua Nhĩ (Thạch Mạc Thành) đã chính thức mở!")
	elif flag_name == "met_tieu_dinh_le":
		pd.add_story_relic("Huy Hiệu Mạc Thiết Đoàn (Tiêu Đỉnh · Tiêu Lệ)")
		pd.add_item("pill_ngung_huyet_tan", 2)
		pd.add_item("pill_hoi_khi_dan", 2)
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Đoàn tụ hai vị huynh trưởng Mạc Thiết Đoàn! Giờ xuống góc Tây Nam Thạch Mạc Thành tìm Tiệm Bản Đồ Cổ của Băng Hoàng Hải Ba Đông!")
	elif flag_name == "beat_hai_ba_dong":
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("Dược Lão hiện hồn phóng Cốt Linh Lãnh Hỏa áp chế Băng Hoàng! Hãy nói chuyện [V] với Hải Ba Đông ký giao ước Mảnh Tàn Đồ #2!")
	elif flag_name == "pact_hai_ba_dong":
		pd.add_story_relic("Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (2/4)")
		var hb_neck: Dictionary = EquipmentSystem.roll_equipment_instance("neck_bang_hoang_tam", "dia")
		pd.add_gear_to_bag(hb_neck)
		EventBus.audio_sfx_requested.emit("chest_open")
		EventBus.banter_triggered.emit("Ký giao ước 1 năm Bảo Tiêu với Hải Ba Đông! Nhận [Mảnh Tàn Đồ #2 (2/4)] & [Hàn Băng Chi Tâm]! Quay lên gặp Thanh Lân [V]!")
	elif flag_name == "met_thanh_lan":
		pd.add_story_relic("Bích Xà Tam Hoa Đồng (Thanh Lân)")
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Bích Xà Tam Hoa Đồng thức tỉnh! Hố Cát Sụt phía Bắc dẫn xuống Địa Huyệt Sông Dung Nham Ngầm đã mở!")
	elif flag_name == "got_thanh_lien_dai":
		pd.add_story_relic("Thanh Liên Đài (+15% EXP & +40% Hồi QI)")
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("ĐÀO THÀNH CÔNG [THANH LIÊN ĐÀI] TỪ ĐÁY DUNG NHAM! (+15% EXP & Hồi QI cực nhanh) — Cổng Đông sang Thánh Thành Xà Nhân đã mở!")
	elif flag_name == "beat_co_ha_mac_ba_tu":
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Đã phá tan phòng tuyến Mặc Ba Tư & Đan Vương Cổ Hà! Mau tiến sang Đảo Thánh Trì phía Đông gặp Nữ Vương Mỹ Đỗ Toa [V]!")
	elif flag_name == "snatched_thanh_lien_hoa":
		pd.add_story_relic("Hỏa Chủng Thanh Liên Địa Tâm Hỏa")
		pd.add_affection("my_do_toa", 15)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("CƯỚP THÀNH CÔNG [#19 THANH LIÊN ĐỊA TÂM HỎA] & [THẤT THẢI THÔN THIÊN MÃNG] NGAY TRƯỚC MŨI CỔ HÀ! Bay qua Cổng Đông Nam tới Ốc Đảo Diêm Lệ!")
	elif flag_name == "ch03_completed":
		pd.unlock_flame("di_hoa_19_thanh_lien", true)
		pd.unlock_skill("phat_no_hoa_lien", "F")
		pd.lotus_fusion_flames = []
		if pd.unlocked_flames.has("tu_tinh_thu_hoa"):
			pd.lotus_fusion_flames.append("tu_tinh_thu_hoa")
		pd.lotus_fusion_flames.append("di_hoa_19_thanh_lien")
		pd.unlock_companion("thai_lan", true)
		pd.add_story_relic("Sơ Hình Phật Nộ Hỏa Liên & Thần Thú Thải Lân")
		pd.add_affection("my_do_toa", 25)
		if pd.realm_index < 3:
			pd.realm_index = 3
			pd.stage = 9
		elif pd.realm_index == 3 and pd.stage < 9:
			pd.stage = 9
		pd.recalculate_and_clamp(true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.skills_updated.emit()
		EventBus.stats_changed.emit()
		EventBus.banter_triggered.emit("HOÀN TẤT CHƯƠNG 03! Thu phục [#19 THANH LIÊN ĐỊA TÂM HỎA] + Đồng Hành [G] THẢI LÂN + KHAI SINH TUYỆT KỸ [F] PHẬT NỘ HỎA LIÊN!!")

	# Data-Driven Story Engine: tự động thi hành hiệu ứng cấu hình trong JSON của từng chương (Ch04 -> Ch11)!
	if flag_name == "ch06_absorbed_van_lac":
		pd.lotus_fusion_flames = []
		if pd.unlocked_flames.has("di_hoa_19_thanh_lien") or pd.has_flag("ch03_completed"):
			pd.lotus_fusion_flames.append("di_hoa_19_thanh_lien")
		pd.lotus_fusion_flames.append("di_hoa_14_van_lac")
	elif flag_name == "ch07_duoc_lao_captured":
		pd.lotus_fusion_flames = []
		for fid_tri in ["di_hoa_19_thanh_lien", "di_hoa_14_van_lac", "di_hoa_11_cot_linh"]:
			if fid_tri == "di_hoa_11_cot_linh" or pd.unlocked_flames.has(fid_tri):
				pd.lotus_fusion_flames.append(fid_tri)
	elif flag_name == "ch08_completed":
		pd.lotus_fusion_flames = []
		for fid_quad in ["di_hoa_19_thanh_lien", "di_hoa_14_van_lac", "di_hoa_11_cot_linh", "di_hoa_09_tam_thien"]:
			if fid_quad == "di_hoa_09_tam_thien" or pd.unlocked_flames.has(fid_quad):
				pd.lotus_fusion_flames.append(fid_quad)

	var fe: Dictionary = GameDatabase.get_flag_effect(flag_name)
	if not fe.is_empty():
		execute_story_effect(pd, fe, flag_name)

	EventBus.story_flag_changed.emit(flag_name)
	pd._check_quest_flag(flag_name)
	pd.trigger_auto_save("cốt truyện")


static func evaluate_story_condition(pd, cond: Dictionary) -> bool:
	if cond.is_empty():
		return true
	var hf: String = str(cond.get("has_flag", ""))
	if hf != "" and not pd.has_flag(hf):
		return false
	var haf: Array = cond.get("has_all_flags", [])
	for f in haf:
		if not pd.has_flag(str(f)):
			return false
	var mf: String = str(cond.get("missing_flag", ""))
	if mf != "" and pd.has_flag(mf):
		return false
	var maf: Array = cond.get("missing_all_flags", [])
	for f in maf:
		if pd.has_flag(str(f)):
			return false
	var min_r: int = int(cond.get("min_realm", 0))
	if min_r > 0 and pd.realm_index < min_r:
		return false
	var max_r: int = int(cond.get("max_realm", 0))
	if max_r > 0 and pd.realm_index > max_r:
		return false
	var min_st: int = int(cond.get("min_stage", 0))
	if min_st > 0 and pd.stage < min_st:
		return false
	var hi: String = str(cond.get("has_item", ""))
	if hi != "" and pd.get_item_count(hi) <= 0:
		return false
	var his: Dictionary = cond.get("has_items", {})
	for ik in his.keys():
		if pd.get_item_count(str(ik)) < int(his[ik]):
			return false
	var mi: String = str(cond.get("missing_item", ""))
	if mi != "" and pd.get_item_count(mi) > 0:
		return false
	var cq: String = str(cond.get("current_quest", ""))
	if cq != "":
		var cur_q: Dictionary = pd.get_current_quest()
		if str(cur_q.get("id", "")) != cq:
			return false
	var ma: Dictionary = cond.get("min_affection", {})
	for hk in ma.keys():
		if pd.get_affection(str(hk)) < int(ma[hk]):
			return false
	return true


static func execute_story_effect(pd, eff: Dictionary, skip_flag_id: String = "") -> Dictionary:
	var result: Dictionary = { "heal_full": false, "banter": "", "open_shop": "" }
	if eff.is_empty():
		return result

	var consume_d: Dictionary = eff.get("consume_items", {})
	for ik in consume_d.keys():
		pd.remove_item(str(ik), int(consume_d[ik]))

	var give_d: Dictionary = eff.get("give_items", {})
	for ik in give_d.keys():
		pd.add_item(str(ik), int(give_d[ik]))

	var g_gold: int = int(eff.get("give_gold", 0))
	if g_gold != 0:
		pd.gold = max(0, pd.gold + g_gold)

	var g_stones: int = int(eff.get("give_stones", 0))
	if g_stones != 0:
		pd.enhance_stones = max(0, pd.enhance_stones + g_stones)

	var g_soul: int = int(eff.get("give_soul", 0))
	if g_soul != 0:
		pd.bonus_soul += g_soul

	var g_exp: int = int(eff.get("give_exp", 0))
	if g_exp > 0:
		pd.add_exp(g_exp)

	var g_fe: int = int(eff.get("give_fire_energy", 0))
	if g_fe != 0:
		pd.add_fire_energy(g_fe)

	var open_auc: String = str(eff.get("open_auction", ""))
	if open_auc != "":
		result["open_auction"] = open_auc

	var aff_d: Dictionary = eff.get("affection", {})
	for hk in aff_d.keys():
		pd.add_affection(str(hk), int(aff_d[hk]))

	var rel_s: String = str(eff.get("relic", ""))
	if rel_s != "":
		pd.add_story_relic(rel_s)
	var rel_arr: Array = eff.get("relics", [])
	for rs in rel_arr:
		pd.add_story_relic(str(rs))

	var sk_u = eff.get("unlock_skill", {})
	if sk_u is Dictionary and not sk_u.is_empty():
		pd.unlock_skill(str(sk_u.get("id", "")), str(sk_u.get("slot", "")))

	var fl_u = eff.get("unlock_flame", {})
	if fl_u is Dictionary and not fl_u.is_empty():
		pd.unlock_flame(str(fl_u.get("id", "")), bool(fl_u.get("auto_equip", false)))

	var cmp_u = eff.get("unlock_companion", {})
	if cmp_u is Dictionary and not cmp_u.is_empty():
		pd.unlock_companion(str(cmp_u.get("id", "")), bool(cmp_u.get("auto_summon", true)))

	var gear_arr: Array = eff.get("give_gear", [])
	for gd in gear_arr:
		if gd is Dictionary:
			var tpl_id: String = str(gd.get("template", ""))
			var rar_id: String = str(gd.get("rarity", "dia"))
			if tpl_id != "":
				var inst: Dictionary = EquipmentSystem.roll_equipment_instance(tpl_id, rar_id)
				if not inst.is_empty():
					pd.add_gear_to_bag(inst)
					if bool(gd.get("auto_equip", false)):
						pd.equip_gear_from_bag(str(inst.get("uid", "")))

	var realm_min = eff.get("set_realm_min", {})
	if realm_min is Dictionary and not realm_min.is_empty():
		var target_r: int = int(realm_min.get("realm", pd.realm_index))
		var target_s: int = int(realm_min.get("stage", pd.stage))
		if pd.realm_index < target_r:
			pd.realm_index = target_r
			pd.stage = target_s
			pd.current_exp = 0
		elif pd.realm_index == target_r and pd.stage < target_s:
			pd.stage = target_s
		pd.recalculate_and_clamp(true)
		EventBus.realm_updated.emit(pd.get_realm_display_title(), "Bạo cấp đột phá cốt truyện!")
		pd._check_quest_realm()

	if bool(eff.get("reset_duoc_lao_active", false)):
		pd.is_duoc_lao_active = false

	var sf: String = str(eff.get("set_flag", ""))
	if sf != "" and sf != skip_flag_id:
		set_story_flag(pd, sf)
	var sf_arr: Array = eff.get("set_flags", [])
	for f in sf_arr:
		var fs: String = str(f)
		if fs != "" and fs != skip_flag_id:
			set_story_flag(pd, fs)

	var sfx_s: String = str(eff.get("sfx", ""))
	if sfx_s != "":
		EventBus.audio_sfx_requested.emit(sfx_s)

	var sh_arr: Array = eff.get("shake", [])
	if sh_arr.size() >= 2:
		EventBus.screen_shake_requested.emit(float(sh_arr[0]), float(sh_arr[1]))

	var b_txt: String = str(eff.get("banter", ""))
	if b_txt != "":
		EventBus.banter_triggered.emit(b_txt)
		result["banter"] = b_txt

	if bool(eff.get("heal_full", false)):
		pd.recalculate_and_clamp(true)
		result["heal_full"] = true

	var oshop: String = str(eff.get("open_shop", ""))
	if oshop != "":
		result["open_shop"] = oshop

	var w_map: String = str(eff.get("warp_map", ""))
	if w_map != "":
		result["warp_map"] = w_map
		var w_sp = eff.get("warp_spawn", [])
		if w_sp is Array and w_sp.size() >= 2:
			result["warp_spawn"] = Vector2(float(w_sp[0]), float(w_sp[1]))

	EventBus.stats_changed.emit()
	return result
