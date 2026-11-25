class_name AchievementManager
extends RefCounted
## Hệ Thống Thành Tựu & Danh Hiệu Vinh Quang (v1.1.0):
## - Theo dõi 20 Thành Tựu & Danh Hiệu: 9 Thành Tựu Cốt Truyện/Bạch Kim (ACH_10_*, ACH_11_*) + 11 Danh Hiệu Tu Luyện & Cày Cuốc.
## - Hiển thị tiến độ trực tiếp, phần thưởng vĩnh viễn và cho phép trang bị Danh Hiệu hiển thị trên HUD!

const HeroineMgr = preload("res://scripts/systems/heroine_affection_manager.gd")
const EmperorMgr = preload("res://scripts/systems/emperor_realm_manager.gd")
const SaintMgr = preload("res://scripts/systems/saint_realm_manager.gd")


static func get_all_definitions() -> Array:
	return [
		# === NHÓM 1: THÀNH TỰU CỐT TRUYỆN & BẠCH KIM (ACH_10 & ACH_11) ===
		{
			"id": "ach_10_01_viem_minh_chi_ton",
			"code": "ACH_10_01",
			"category": "story",
			"tier": "gold",
			"name": "Viêm Minh Chí Tôn",
			"title_tag": "Viêm Minh Chí Tôn",
			"desc": "Xuyên Trùng Động kịp giải vây Viêm Minh và bóp nát Sư Thiên & Cửu Thiên Tôn (Ch.10).",
			"reward": "+5% ATK vĩnh viễn",
			"flag": "ach_10_01_viem_minh_chi_ton"
		},
		{
			"id": "ach_10_02_tram_kiep_so_tam",
			"code": "ACH_10_02",
			"category": "story",
			"tier": "gold",
			"name": "Trăm Kiếp Không Quên Sơ Tâm",
			"title_tag": "Thánh Giả Đạo Tâm",
			"desc": "Hoàn tất Ảo Cảnh Thủy Mặc Bách Thế Luân Hồi với đủ 3/3 lựa chọn vị tha (Ch.10).",
			"reward": "+250 SOUL vĩnh viễn",
			"flag": "ach_10_02_tram_kiep_so_tam"
		},
		{
			"id": "ach_10_03_thien_phu_thong_soai",
			"code": "ACH_10_03",
			"category": "story",
			"tier": "gold",
			"name": "Thiên Phủ Thống Soái",
			"title_tag": "Thiên Phủ Minh Chủ",
			"desc": "Công phá Pháo Đài Nhân Điện, trảm Phó Điện Chủ & sáng tạo Phật Nộ Luân Hồi (Ch.10).",
			"reward": "-20% hồi chiêu Hoàng Tuyền Tam Tuyệt",
			"flag": "ach_10_03_thien_phu_thong_soai"
		},
		{
			"id": "ach_10_04_song_phung_yeu_lien",
			"code": "ACH_10_04",
			"category": "story",
			"tier": "gold",
			"name": "Song Phụng Yêu Liên",
			"title_tag": "Chủ Nhân Tịnh Liên",
			"desc": "Song luyện Đài Sen cùng Cổ Huân Nhi thu phục #3 Tịnh Liên Yêu Hỏa & Khí Linh Tiểu Y (Ch.10).",
			"reward": "Tâm Ý Tương Thông (Hồi sinh 65% HP)",
			"flag": "ach_10_04_song_phung_yeu_lien"
		},
		{
			"id": "ach_11_01_dan_thap_vo_thuong",
			"code": "ACH_11_01",
			"category": "story",
			"tier": "platinum",
			"name": "Đan Tháp Vô Thượng Tôn",
			"title_tag": "Đế Phẩm Đan Thần",
			"desc": "Dùng Cửu Phẩm Huyền Đan nghiền nát Hồn Hư Tử tại Đại Hội Dược Điển (Ch.11).",
			"reward": "Dược Đế Bạch Kim Đỉnh (Đế Phẩm)",
			"flag": "ach_11_01_dan_thap_vo_thuong"
		},
		{
			"id": "ach_11_02_phu_tu_tinh_tham",
			"code": "ACH_11_02",
			"category": "story",
			"tier": "platinum",
			"name": "Phụ Tử Tình Thâm · Tái Lập Đế Tộc",
			"title_tag": "Tiêu Tộc Vinh Quang",
			"desc": "Cứu phụ thân Tiêu Chiến và dâng hương bái tế Tổ Tiên Tiêu Huyền (Hậu Truyện EQ_11_05).",
			"reward": "+500 SOUL vĩnh viễn",
			"flag": "ach_11_02_phu_tu_tinh_tham"
		},
		{
			"id": "ach_11_03_tam_thap_nien",
			"code": "ACH_11_03",
			"category": "story",
			"tier": "platinum",
			"name": "Tam Thập Niên Hà Đông · Song Đế Phong Ấn",
			"title_tag": "VIÊM ĐẾ TIÊU VIÊM",
			"desc": "Chứng đạo Viêm Đế, thắng Song Đế Chi Chiến 3-Phase và phong ấn vạn cổ Hồn Thiên Đế (Ch.11).",
			"reward": "Mở khóa Dị Hỏa Quảng Trường & New Game+",
			"flag": "ach_11_03_tam_thap_nien"
		},
		{
			"id": "ach_11_04_song_hau_dong_quy",
			"code": "ACH_11_04",
			"category": "story",
			"tier": "platinum",
			"name": "Song Hậu Đồng Quy · Bách Niên Giai Lão",
			"title_tag": "Song Hậu Đồng Quy",
			"desc": "Hoàn tất Đại Hôn Ô Thản Thành cùng Cổ Huân Nhi & Thải Lân và trọn 5/5 Hậu Truyện (EQ_11_01..05).",
			"reward": "+10% Toàn Bộ Chỉ Số vĩnh viễn",
			"flag": "ach_11_04_song_hau_dong_quy"
		},
		{
			"id": "ach_11_05_chua_te_dai_thien",
			"code": "ACH_11_05",
			"category": "story",
			"tier": "platinum",
			"name": "Chúa Tể Đại Thiên · Vạn Hỏa Độc Tôn",
			"title_tag": "Chúa Tể Đại Thiên",
			"desc": "Thu trọn 23/23 Dị Hỏa và tỷ thí chiến thắng cả Võ Tổ Lâm Động lẫn Đại Chúa Tể Mục Trần!",
			"reward": "+15% Toàn Bộ Chỉ Số vĩnh viễn",
			"flag": "ach_11_05_chua_te_dai_thien"
		},

		# === NHÓM 2: DANH HIỆU TU LUYỆN & CÀY CUỐC ===
		{
			"id": "ach_gp_01_dau_su",
			"code": "TITLE_01",
			"category": "grind",
			"tier": "bronze",
			"name": "Hắc Bào Thiếu Niên Hiệp Khách",
			"title_tag": "Hắc Bào Hiệp Khách",
			"desc": "Đột phá cảnh giới Đấu Sư (Bậc 3+) và mở khóa Đấu Khí Sa Y.",
			"reward": "Mở Danh Hiệu Hiển Thị"
		},
		{
			"id": "ach_gp_02_thanh_lien",
			"code": "TITLE_02",
			"category": "grind",
			"tier": "silver",
			"name": "Khống Hỏa Sơ Thành",
			"title_tag": "Thanh Liên Hỏa Sư",
			"desc": "Thu phục #19 Thanh Liên Địa Tâm Hỏa và khai sinh Phật Nộ Hỏa Liên.",
			"reward": "Mở Danh Hiệu Hiển Thị"
		},
		{
			"id": "ach_gp_03_van_lac",
			"code": "TITLE_03",
			"category": "grind",
			"tier": "silver",
			"name": "Tân Sinh Vương Nội Viện",
			"title_tag": "Nội Viện Đệ Nhất",
			"desc": "Thu phục #14 Vẫn Lạc Tâm Viêm và mở khóa Đấu Khí Hóa Dực.",
			"reward": "Mở Danh Hiệu Hiển Thị"
		},
		{
			"id": "ach_gp_04_dau_tong",
			"code": "TITLE_04",
			"category": "grind",
			"tier": "gold",
			"name": "Đạp Hư Không · Tông Sư Trung Châu",
			"title_tag": "Nham Kiêu Tông Sư",
			"desc": "Đột phá cảnh giới Đấu Tông (Bậc 8+) và đăng quang Quán Quân Đan Hội Trung Châu.",
			"reward": "Mở Danh Hiệu Hiển Thị"
		},
		{
			"id": "ach_gp_05_cuu_chuyen",
			"code": "TITLE_05",
			"category": "grind",
			"tier": "gold",
			"name": "Cửu Chuyển Đỉnh Phong",
			"title_tag": "Cửu Chuyển Đấu Tôn",
			"desc": "Ngưng tụ đủ 9/9 Chuyển Luân Cửu Chuyển Đấu Tôn trong [B].",
			"reward": "+72% Toàn Chỉ Số (Cửu Chuyển)"
		},
		{
			"id": "ach_gp_06_thien_phu_max",
			"code": "TITLE_06",
			"category": "grind",
			"tier": "gold",
			"name": "Bá Chủ Trung Châu · Lục Đường Viên Mãn",
			"title_tag": "Thiên Phủ Bá Chủ",
			"desc": "Nâng tối đa Cấp 3 toàn bộ 6/6 công trình của Thiên Phủ Liên Minh.",
			"reward": "Tối đa hóa Buff Thế Lực (+18% SOUL)"
		},
		{
			"id": "ach_gp_07_thap_chinh_phuc",
			"code": "TITLE_07",
			"category": "grind",
			"tier": "silver",
			"name": "Tâm Hỏa Cuồng Đồ",
			"title_tag": "Tâm Hỏa Cuồng Đồ",
			"desc": "Chinh phục từ Tầng 9 trở lên trong Phó bản Roguelite Thiên Phần Luyện Khí Tháp.",
			"reward": "Mở Danh Hiệu Hiển Thị"
		},
		{
			"id": "ach_gp_08_tam_ma_sss",
			"code": "TITLE_08",
			"category": "grind",
			"tier": "gold",
			"name": "Vô Địch Tâm Ma",
			"title_tag": "Tâm Ma Bất Bại",
			"desc": "Đạt ít nhất 1 xếp hạng [SSS] khi tái đấu Boss trong Tâm Ma Luyện Cảnh.",
			"reward": "Mở Danh Hiệu Hiển Thị"
		},
		{
			"id": "ach_gp_09_van_thu_50",
			"code": "TITLE_09",
			"category": "grind",
			"tier": "silver",
			"name": "Đồ Giám Vạn Thú Đại Sư",
			"title_tag": "Vạn Thú Đồ Giám Sư",
			"desc": "Tiêu diệt ít nhất 50 loài Quái & Boss khác nhau trong Đồ Giám Vạn Thú.",
			"reward": "Mở Danh Hiệu Hiển Thị"
		},
		{
			"id": "ach_gp_10_hong_nhan_8",
			"code": "TITLE_10",
			"category": "grind",
			"tier": "gold",
			"name": "Tri Kỷ Bát Mỹ · Phong Lưu Viêm Đế",
			"title_tag": "Tri Kỷ Bát Mỹ",
			"desc": "Đạt tối thiểu 50/100 Hảo Cảm với trọn bộ 8/8 Hồng Nhan Tri Kỷ.",
			"reward": "Kích hoạt bộ Buff Đa Hồng Nhan"
		},
		{
			"id": "ach_gp_11_luan_hoi_ng_plus",
			"code": "TITLE_11",
			"category": "grind",
			"tier": "platinum",
			"name": "Đế Giả Trọng Lâm · Luân Hồi Chuyển Thế",
			"title_tag": "Đế Giả Trọng Lâm",
			"desc": "Khởi động Chế Độ Luân Hồi Chuyển Thế (New Game+ Vòng 1+).",
			"reward": "Độc quyền Hồng Trần Đế Tinh & Easter Egg NG+"
		}
	]


static func evaluate_achievement(pd, def: Dictionary) -> Dictionary:
	var aid: String = str(def.get("id", ""))
	var flag_k: String = str(def.get("flag", ""))
	var unlocked: bool = false
	var cur_v: int = 0
	var max_v: int = 1
	var prog_txt: String = ""

	if flag_k != "":
		unlocked = pd.has_flag(flag_k)
		if aid == "ach_11_04_song_hau_dong_quy":
			cur_v = EmperorMgr.get_epilogue_done_count(pd)
			max_v = 5
			prog_txt = "Hậu Truyện: %d/5 · Đại Hôn: %s" % [cur_v, "Xong" if pd.has_flag("ch11_wedding_completed") else "Chưa"]
		elif aid == "ach_11_05_chua_te_dai_thien":
			var fc: int = EmperorMgr.get_heavenly_flame_count(pd)
			var sb: int = int(pd.has_flag("ch11_beat_lam_dong")) + int(pd.has_flag("ch11_beat_muc_tran"))
			cur_v = mini(23, fc) + sb
			max_v = 25
			prog_txt = "Dị Hỏa: %d/23 · Superboss: %d/2" % [fc, sb]
		elif aid == "ach_10_02_tram_kiep_so_tam":
			cur_v = SaintMgr.get_bach_the_benevolent_count(pd)
			max_v = 3
			prog_txt = "Lựa chọn vị tha Bách Thế: %d/3" % cur_v
		else:
			cur_v = 1 if unlocked else 0
			prog_txt = "Đã hoàn thành!" if unlocked else "Chưa đạt"
	elif aid == "ach_gp_01_dau_su":
		cur_v = mini(int(pd.realm_index), 3)
		max_v = 3
		unlocked = int(pd.realm_index) >= 3
		prog_txt = "Cảnh giới: %d/3 (Đấu Sư)" % cur_v
	elif aid == "ach_gp_02_thanh_lien":
		unlocked = pd.unlocked_flames.has("di_hoa_19_thanh_lien") or pd.has_flag("ch03_completed")
		cur_v = 1 if unlocked else 0
		prog_txt = "Đã thu phục #19 Thanh Liên" if unlocked else "Chưa thu phục"
	elif aid == "ach_gp_03_van_lac":
		unlocked = pd.unlocked_flames.has("di_hoa_14_van_lac") or pd.has_flag("ch06_absorbed_van_lac")
		cur_v = 1 if unlocked else 0
		prog_txt = "Đã thu phục #14 Vẫn Lạc" if unlocked else "Chưa thu phục"
	elif aid == "ach_gp_04_dau_tong":
		var ok_r: bool = int(pd.realm_index) >= 8
		var ok_dh: bool = pd.has_flag("ch08_dan_hoi_champion")
		cur_v = int(ok_r) + int(ok_dh)
		max_v = 2
		unlocked = ok_r and ok_dh
		prog_txt = "Đấu Tông: %s · Đan Hội Trung Châu: %s" % ["✓" if ok_r else "○", "✓" if ok_dh else "○"]
	elif aid == "ach_gp_05_cuu_chuyen":
		cur_v = clampi(int(pd.nine_turn_level), 0, 9)
		max_v = 9
		unlocked = cur_v >= 9
		prog_txt = "Cửu Chuyển: %d/9 Chuyển" % cur_v
	elif aid == "ach_gp_06_thien_phu_max":
		unlocked = pd.has_flag("FLAG_THIEN_PHU_MAX")
		var sum_lv: int = 0
		for hid in ["dan_duong", "vo_duong", "am_duong", "am_vong", "tinh_than_tran", "thien_phu_lien_quan"]:
			sum_lv += int(pd.pan_gate_state.get(hid, 0)) if (pd.pan_gate_state is Dictionary) else 0
		cur_v = mini(sum_lv, 18)
		max_v = 18
		prog_txt = "Tổng cấp 6 Công Trình: %d/18" % cur_v
	elif aid == "ach_gp_07_thap_chinh_phuc":
		cur_v = mini(int(pd.tower_best_floor), 9)
		max_v = 9
		unlocked = int(pd.tower_best_floor) >= 9
		prog_txt = "Tầng cao nhất: %d / 9" % int(pd.tower_best_floor)
	elif aid == "ach_gp_08_tam_ma_sss":
		var sss_cnt: int = 0
		for rk in pd.boss_rush_records.keys():
			var rec = pd.boss_rush_records[rk]
			if rec is Dictionary and str(rec.get("best_grade", "")) == "SSS":
				sss_cnt += 1
		cur_v = mini(sss_cnt, 1)
		max_v = 1
		unlocked = sss_cnt >= 1
		prog_txt = "Số trận hạng SSS: %d" % sss_cnt
	elif aid == "ach_gp_09_van_thu_50":
		var sp_cnt: int = 0
		for ek in pd.enemy_kill_counts.keys():
			if int(pd.enemy_kill_counts[ek]) > 0:
				sp_cnt += 1
		cur_v = mini(sp_cnt, 50)
		max_v = 50
		unlocked = sp_cnt >= 50
		prog_txt = "Loài đã hạ: %d / 50" % sp_cnt
	elif aid == "ach_gp_10_hong_nhan_8":
		var h_ok: int = 0
		for hk in HeroineMgr.HEROINE_KEYS:
			if pd.get_affection(hk) >= 50:
				h_ok += 1
		cur_v = h_ok
		max_v = HeroineMgr.HEROINE_KEYS.size()
		unlocked = h_ok >= max_v
		prog_txt = "Hồng Nhan >=50 Hảo Cảm: %d / %d" % [h_ok, max_v]
	elif aid == "ach_gp_11_luan_hoi_ng_plus":
		var cyc: int = EmperorMgr.get_ng_plus_cycle(pd)
		cur_v = mini(cyc, 1)
		max_v = 1
		unlocked = cyc >= 1 or pd.has_flag("FLAG_NG_PLUS_ACTIVE")
		prog_txt = "Vòng Luân Hồi NG+: %d" % cyc

	return {
		"id": aid,
		"unlocked": unlocked,
		"cur": cur_v,
		"max": maxi(1, max_v),
		"progress_text": prog_txt
	}


static func get_summary(pd) -> Dictionary:
	var defs: Array = get_all_definitions()
	var unlocked_cnt: int = 0
	var platinum_cnt: int = 0
	var platinum_total: int = 0
	for d in defs:
		var ev: Dictionary = evaluate_achievement(pd, d)
		if bool(ev["unlocked"]):
			unlocked_cnt += 1
			if str(d.get("tier", "")) == "platinum":
				platinum_cnt += 1
		if str(d.get("tier", "")) == "platinum":
			platinum_total += 1
	return {
		"unlocked": unlocked_cnt,
		"total": defs.size(),
		"platinum_unlocked": platinum_cnt,
		"platinum_total": platinum_total
	}


static func get_active_title_display(pd) -> String:
	if pd == null or not ("active_title_id" in pd):
		return ""
	var tid: String = str(pd.active_title_id)
	if tid == "":
		return ""
	for d in get_all_definitions():
		if str(d.get("id", "")) == tid:
			if bool(evaluate_achievement(pd, d).get("unlocked", false)):
				return "《%s》" % str(d.get("title_tag", d.get("name", "")))
			return ""
	return ""


static func equip_title(pd, achievement_id: String) -> Dictionary:
	if achievement_id == "":
		pd.active_title_id = ""
		EventBus.audio_sfx_requested.emit("ui_click")
		EventBus.stats_changed.emit()
		return { "ok": true, "msg": "Đã ẩn Danh Hiệu hiển thị." }
	for d in get_all_definitions():
		if str(d.get("id", "")) == achievement_id:
			var ev: Dictionary = evaluate_achievement(pd, d)
			if not bool(ev["unlocked"]):
				return { "ok": false, "msg": "Bạn chưa mở khóa Thành Tựu [%s]!" % str(d["name"]) }
			pd.active_title_id = achievement_id
			EventBus.audio_sfx_requested.emit("level_up")
			EventBus.stats_changed.emit()
			pd.trigger_auto_save("đổi danh hiệu")
			return { "ok": true, "msg": "Đã đeo Danh Hiệu: 《%s》!" % str(d["title_tag"]) }
	return { "ok": false, "msg": "Danh hiệu không tồn tại!" }
