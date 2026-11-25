class_name PanGateManager
extends RefCounted
## Hệ thống Quản Trị Thế Lực "BÀN MÔN" (Chương 06 — Nội Viện Già Nam) & Cường Bảng Top 10:
## - 3 Phân Đường nâng cấp Cấp 0 -> Cấp 3:
##   1. Đan Đường (Hàn Nhàn): Tạo Tinh Hỏa Năng + Kim Tệ thụ động & +5%/cấp tỷ lệ thành đan.
##   2. Võ Đường (Ngô Hạo & Hổ Gia): Thu Ma Hạch Cấp 4–5 + Đá Cường Hóa & +4%/cấp ATK.
##   3. Ám Đường / Tầm Bảo (Tử Nghiên): Đút Đan Hoàn Ngọt / Hỏa Năng cử Tử Nghiên đi đào linh dược Lục Phẩm!
## - Bảng Khiêu Chiến Cường Bảng Nội Viện (Top 10 Ranking) tích hợp mượt với Tâm Ma / Lôi Đài!

const MAX_HALL_LEVEL: int = 3
const HARVEST_INTERVAL_SEC: float = 45.0


static func default_state() -> Dictionary:
	return {
		"dan_duong": 0,
		"vo_duong": 0,
		"am_duong": 0,
		"am_vong": 0,
		"tinh_than_tran": 0,
		"last_harvest_playtime": -100.0,
		"total_harvests": 0,
		"ziyan_expeditions": 0,
		"strong_rank_cleared": {}
	}


static func ensure_state(pd: Node) -> Dictionary:
	if not ("pan_gate_state" in pd) or not (pd.pan_gate_state is Dictionary) or pd.pan_gate_state.is_empty():
		pd.pan_gate_state = default_state()
	var st: Dictionary = pd.pan_gate_state
	for k in ["dan_duong", "vo_duong", "am_duong", "am_vong", "tinh_than_tran", "total_harvests", "ziyan_expeditions"]:
		if not st.has(k):
			st[k] = 0
	if not st.has("last_harvest_playtime"):
		st["last_harvest_playtime"] = -100.0
	if not st.has("strong_rank_cleared") or not (st["strong_rank_cleared"] is Dictionary):
		st["strong_rank_cleared"] = {}
	return st


static func is_unlocked(pd: Node) -> bool:
	return pd.has_flag("ch06_ban_mon_founded") or pd.has_flag("ch07_viem_minh_founded") or pd.has_flag("ch09_broke_dau_ton") or pd.has_flag("ch09_duoc_tran_revived") or bool(pd.is_demo_mode)


static func is_viem_minh_evolved(pd: Node) -> bool:
	return pd.has_flag("ch07_viem_minh_founded") or pd.has_flag("ch09_broke_dau_ton") or pd.has_flag("ch09_duoc_tran_revived") or bool(pd.is_demo_mode)


static func is_tinh_van_cac_evolved(pd: Node) -> bool:
	return pd.has_flag("ch09_broke_dau_ton") or pd.has_flag("ch09_duoc_tran_revived") or pd.has_flag("FLAG_TINH_VAN_CAC_FOUNDED") or bool(pd.is_demo_mode)


static func get_faction_title(pd: Node) -> String:
	if is_tinh_van_cac_evolved(pd):
		return "✦ TINH VẪN CÁC (TRUNG CHÂU)"
	return "ĐẾ QUỐC VIÊM MINH" if is_viem_minh_evolved(pd) else "BÀN MÔN NỘI VIỆN"


static func get_hall_defs() -> Array:
	return [
		{
			"id": "dan_duong",
			"name": "Đan Đường (Hàn Nhàn · Cổ Hà)",
			"color": "#52B788",
			"desc": "Đệ tử Đan Đường luyện Hỏa Liên Đan & Viêm Minh Linh Đan tạo Tinh Hỏa Năng & Kim Tệ.",
			"per_lvl_desc": "Thu +40/80/125 Hỏa Năng & +1500/3200/5500 Kim Tệ mỗi lượt · +5%/cấp Luyện Đan",
			"costs_fe": [60, 140, 260],
			"costs_gold": [3500, 9000, 18000]
		},
		{
			"id": "vo_duong",
			"name": "Võ Đường / Hình Đường (Ngô Hạo · Thải Lân)",
			"color": "#FF4D6D",
			"desc": "Đội tuần tra Bàn Môn & Hình Đường Thải Lân săn Ma Hạch Cấp 5–6, bảo hộ lãnh thổ.",
			"per_lvl_desc": "Thu +4/8/14 Đá Cường Hóa + Ma Hạch Cấp 4–6 mỗi lượt · Vĩnh viễn +4%/cấp Công Kích",
			"costs_fe": [60, 140, 260],
			"costs_gold": [3500, 9000, 18000]
		},
		{
			"id": "am_duong",
			"name": "Ám Đường · Tầm Bảo (Tử Nghiên)",
			"color": "#C77DFF",
			"desc": "Tiểu Man Vương Tử Nghiên đánh hơi thiên tài địa bảo khắp Già Nam & Xuất Vân!",
			"per_lvl_desc": "Mở & tăng cấp độ Tầm Bảo: đào Thanh Mộc Tiên Đằng, Long Huyết Chi, Hủ Cốt Thảo & Ma Hạch!",
			"costs_fe": [50, 130, 240],
			"costs_gold": [3000, 8000, 16000]
		},
		{
			"id": "am_vong",
			"name": "Ám Võng Tình Báo (Mễ Đặc Nhĩ · Hoàng Thất)",
			"color": "#FFD166",
			"viem_minh_only": true,
			"desc": "Mạng lưới tình báo Đế Quốc Viêm Minh của Hải Ba Đông & Gia Hình Thiên theo dõi Hồn Điện!",
			"per_lvl_desc": "Thu thêm +35/75/120 Hỏa Năng + Hồn Tinh Đen / Hủ Cốt Thảo · Vĩnh viễn +4%/cấp Chí Mạng",
			"costs_fe": [90, 190, 340],
			"costs_gold": [6500, 15000, 28000]
		},
		{
			"id": "tinh_than_tran",
			"name": "Tinh Thần Hộ Các Đại Trận (Phong Tôn Giả · Bán Thánh Dược Trần)",
			"color": "#72EFDD",
			"tinh_van_only": true,
			"desc": "Đại trận thiên thạch bạc chấn giữ Tinh Vẫn Giới — mở kho dược tài Bát Phẩm & gia hộ toàn diện!",
			"per_lvl_desc": "Thu +75/150/240 Hỏa Năng + Hồn Anh Quả / Long Huyết Quả / Năng Lượng Hạch 8 · +5%/cấp ATK & DEF!",
			"costs_fe": [160, 320, 520],
			"costs_gold": [22000, 48000, 88000]
		}
	]


static func get_hall_defs_for(pd: Node) -> Array:
	var vm: bool = is_viem_minh_evolved(pd)
	var tv: bool = is_tinh_van_cac_evolved(pd)
	var out: Array = []
	for hd in get_hall_defs():
		if bool(hd.get("viem_minh_only", false)) and not vm:
			continue
		if bool(hd.get("tinh_van_only", false)) and not tv:
			continue
		out.append(hd)
	return out


static func get_hall_level(pd: Node, hall_id: String) -> int:
	var st: Dictionary = ensure_state(pd)
	return clampi(int(st.get(hall_id, 0)), 0, MAX_HALL_LEVEL)


static func get_atk_bonus_pct(pd: Node) -> float:
	if not is_unlocked(pd):
		return 0.0
	var base_a: float = float(get_hall_level(pd, "vo_duong")) * 4.0
	if is_tinh_van_cac_evolved(pd):
		base_a += float(get_hall_level(pd, "tinh_than_tran")) * 5.0
	return base_a


static func get_def_bonus_pct(pd: Node) -> float:
	if not is_tinh_van_cac_evolved(pd):
		return 0.0
	return float(get_hall_level(pd, "tinh_than_tran")) * 5.0


static func get_crit_bonus_pct(pd: Node) -> float:
	if not is_viem_minh_evolved(pd):
		return 0.0
	return float(get_hall_level(pd, "am_vong")) * 4.0


static func get_alchemy_bonus_pct(pd: Node) -> float:
	if not is_unlocked(pd):
		return 0.0
	return float(get_hall_level(pd, "dan_duong")) * 5.0


static func upgrade_hall(pd: Node, hall_id: String) -> Dictionary:
	if not is_unlocked(pd):
		return { "ok": false, "msg": "Hãy hạ Bạch Thành & đấu đan thắng Hàn Nhàn để sáng lập Bàn Môn trước!" }
	var st: Dictionary = ensure_state(pd)
	var cur_lvl: int = get_hall_level(pd, hall_id)
	if cur_lvl >= MAX_HALL_LEVEL:
		return { "ok": false, "msg": "Phân Đường này đã đạt cực hạn Cấp %d!" % MAX_HALL_LEVEL }
	var hdef: Dictionary = {}
	for hd in get_hall_defs():
		if str(hd["id"]) == hall_id:
			hdef = hd
			break
	if hdef.is_empty():
		return { "ok": false, "msg": "Phân Đường không hợp lệ!" }

	var cost_fe: int = int((hdef["costs_fe"] as Array)[cur_lvl])
	var cost_gold: int = int((hdef["costs_gold"] as Array)[cur_lvl])
	if pd.fire_energy < cost_fe or pd.gold < cost_gold:
		return {
			"ok": false,
			"msg": "Cần %d Tinh Hỏa Năng & %d Kim Tệ để nâng %s lên Cấp %d!" % [cost_fe, cost_gold, str(hdef["name"]), cur_lvl + 1]
		}

	pd.fire_energy -= cost_fe
	pd.gold -= cost_gold
	st[hall_id] = cur_lvl + 1
	if get_hall_level(pd, "dan_duong") >= MAX_HALL_LEVEL and get_hall_level(pd, "vo_duong") >= MAX_HALL_LEVEL and get_hall_level(pd, "am_duong") >= MAX_HALL_LEVEL:
		pd.set_story_flag("FLAG_PAN_GATE_LEVEL_MAX")
		pd.add_story_relic("Bàn Môn Cực Thịnh (Cả 3 Đường Cấp 3 — Cầu Nối Viêm Minh Ch.07)")
		if is_viem_minh_evolved(pd) and get_hall_level(pd, "am_vong") >= MAX_HALL_LEVEL:
			pd.set_story_flag("FLAG_YAN_ALLIANCE_MAX")
			pd.add_story_relic("Đế Quốc Viêm Minh Cực Thịnh (Cả 4 Đường Đế Quốc Cấp 3 — Sẵn Sàng Trung Châu)")
	pd.recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.stats_changed.emit()
	pd.trigger_auto_save("nâng cấp Bàn Môn", true)
	return {
		"ok": true,
		"msg": "NÂNG CẤP THÀNH CÔNG: %s -> CẤP %d!" % [str(hdef["name"]), cur_lvl + 1]
	}


static func get_harvest_cooldown_remaining(pd: Node) -> float:
	var st: Dictionary = ensure_state(pd)
	var last_t: float = float(st.get("last_harvest_playtime", -100.0))
	var elapsed: float = float(pd.playtime_sec) - last_t
	return maxf(0.0, HARVEST_INTERVAL_SEC - elapsed)


static func claim_passive_harvest(pd: Node) -> Dictionary:
	if not is_unlocked(pd):
		return { "ok": false, "msg": "Chưa thành lập Bàn Môn!" }
	var rem: float = get_harvest_cooldown_remaining(pd)
	if rem > 0.0:
		return { "ok": false, "msg": "Đệ tử Bàn Môn đang luyện đan & tuần tra — quay lại sau %.0fs!" % ceilf(rem) }
	var st: Dictionary = ensure_state(pd)
	var d_lvl: int = get_hall_level(pd, "dan_duong")
	var v_lvl: int = get_hall_level(pd, "vo_duong")
	var av_lvl: int = get_hall_level(pd, "am_vong") if is_viem_minh_evolved(pd) else 0
	var tv_lvl: int = get_hall_level(pd, "tinh_than_tran") if is_tinh_van_cac_evolved(pd) else 0
	var fe_table: Array = [30, 70, 115, 165]
	var av_fe_table: Array = [0, 35, 75, 120]
	var tv_fe_table: Array = [0, 75, 150, 240]
	var gold_table: Array = [1200, 2700, 4800, 7500]
	var stone_table: Array = [2, 6, 11, 18]

	var fe_gain: int = int(fe_table[d_lvl]) + int(av_fe_table[av_lvl]) + int(tv_fe_table[tv_lvl])
	var gold_gain: int = int(gold_table[d_lvl]) + (2200 * av_lvl) + (6500 * tv_lvl)
	var stone_gain: int = int(stone_table[v_lvl]) + (2 * av_lvl) + (4 * tv_lvl)
	pd.fire_energy += fe_gain
	pd.gold += gold_gain
	pd.enhance_stones += stone_gain

	var extra_str: String = ""
	if v_lvl >= 1:
		var core_id: String = "core_phong_4" if v_lvl == 1 else ("core_loi_5" if v_lvl == 2 else ("core_doc_6" if is_viem_minh_evolved(pd) else "core_huyet_5"))
		pd.add_item(core_id, 1)
		var cname: String = str(GameDatabase.get_item_def(core_id).get("name", core_id))
		extra_str = " + 1 [%s]" % cname
	if d_lvl >= 2:
		var pill_id: String = "pill_viem_minh_linh_dan" if is_viem_minh_evolved(pd) else "pill_hoa_lien_dan"
		pd.add_item(pill_id, 1)
		extra_str += " + 1 [%s]" % ("Viêm Minh Linh Đan" if is_viem_minh_evolved(pd) else "Hỏa Liên Đan")
	if av_lvl >= 1:
		pd.add_item("herb_hu_cot_thao", 1)
		extra_str += " + 1 [Hủ Cốt Thảo]"
	if av_lvl >= 2:
		pd.add_item("item_hon_tinh_den", 1)
		extra_str += " + 1 [Hồn Tinh Đen]"
	if tv_lvl >= 1:
		pd.add_item("herb_hon_anh_yeu_qua", 1)
		extra_str += " + 1 [Hồn Anh Yêu Quả]"
	if tv_lvl >= 2:
		pd.add_item("herb_long_huyet_qua", 1)
		extra_str += " + 1 [Long Huyết Quả]"
	if tv_lvl >= 3:
		pd.add_item("core_nang_luong_8", 1)
		extra_str += " + 1 [Năng Lượng Hạch Cấp 8]"

	st["last_harvest_playtime"] = float(pd.playtime_sec)
	st["total_harvests"] = int(st.get("total_harvests", 0)) + 1
	EventBus.audio_sfx_requested.emit("loot_rare")
	EventBus.stats_changed.emit()
	var ftitle: String = get_faction_title(pd)
	pd.trigger_auto_save("thu hoạch %s" % ftitle, true)
	return {
		"ok": true,
		"msg": "THU HOẠCH %s: +%d Tinh Hỏa Năng · +%d Kim Tệ · +%d Đá Cường Hóa%s!" % [ftitle, fe_gain, gold_gain, stone_gain, extra_str]
	}


static func send_ziyan_forage(pd: Node, use_candy: bool = true) -> Dictionary:
	if not is_unlocked(pd):
		return { "ok": false, "msg": "Hãy thành lập Bàn Môn trước!" }
	if not pd.has_flag("ch06_tu_nghien_joined") and not pd.is_demo_mode:
		return { "ok": false, "msg": "Hãy lên Hậu Sơn Dược Tài thu phục Tiểu Man Vương Tử Nghiên trước!" }
	var a_lvl: int = get_hall_level(pd, "am_duong")
	if use_candy:
		if pd.get_item_count("pill_dan_hoan_ngot") <= 0:
			return { "ok": false, "msg": "Không đủ [Đan Hoàn Ngọt] trong Nạp Giới — hãy luyện trong [L] hoặc dùng 45 Tinh Hỏa Năng!" }
		pd.remove_item("pill_dan_hoan_ngot", 1)
	else:
		if pd.fire_energy < 45:
			return { "ok": false, "msg": "Cần 45 Tinh Hỏa Năng để mua linh quả dụ Tử Nghiên đi tầm bảo!" }
		pd.fire_energy -= 45

	var st: Dictionary = ensure_state(pd)
	st["ziyan_expeditions"] = int(st.get("ziyan_expeditions", 0)) + 1

	var herb_cnt: int = 2 + a_lvl
	pd.add_item("herb_thanh_moc_tien_dang", herb_cnt)
	var extra_notes: Array = ["%dx Thanh Mộc Tiên Đằng" % herb_cnt]
	if a_lvl >= 1 or randf() < 0.65:
		var lh_cnt: int = 1 + int(a_lvl >= 2)
		pd.add_item("herb_long_huyet_chi", lh_cnt)
		extra_notes.append("%dx Long Huyết Chi" % lh_cnt)
	if a_lvl >= 2 or randf() < 0.45:
		pd.add_item("core_bang_5", 1)
		extra_notes.append("1x Băng Ma Hạch Cấp 5")
	if a_lvl >= 3:
		pd.enhance_stones += 8
		extra_notes.append("+8 Đá Cường Hóa")
	if is_viem_minh_evolved(pd):
		pd.add_item("herb_hu_cot_thao", 1 + int(a_lvl >= 2))
		extra_notes.append("%dx Hủ Cốt Thảo" % (1 + int(a_lvl >= 2)))
	if pd.has_flag("ch08_broke_dau_tong") or is_tinh_van_cac_evolved(pd) or pd.is_demo_mode:
		pd.add_item("herb_bach_cot_linh_chi", 1)
		extra_notes.append("1x Bạch Cốt Linh Chi")
	EventBus.audio_sfx_requested.emit("chest_open")
	EventBus.stats_changed.emit()
	pd.trigger_auto_save("Tử Nghiên tầm bảo", true)
	return {
		"ok": true,
		"msg": "Tử Nghiên ăn xong chạy vút vào Hậu Sơn đào về: %s!" % " · ".join(extra_notes)
	}


static func get_strong_ranking_roster() -> Array:
	return [
		{ "rank": 10, "name": "Bạch Thành (Thủ Lĩnh Bạch Bang)", "boss_id": "bach_thanh_boss", "diff": "normal", "realm": "Đấu Linh 7★", "reward_fe": 45 },
		{ "rank": 8, "name": "La Hầu (Hắc Bạch Quan Sát)", "boss_id": "la_hau_boss", "diff": "normal", "realm": "Đấu Linh 9★", "reward_fe": 65 },
		{ "rank": 6, "name": "Ngô Hạo (Tu La Huyết Kiếm)", "boss_id": "ngo_hao_boss", "diff": "nightmare", "realm": "Đấu Linh Đỉnh", "reward_fe": 85 },
		{ "rank": 3, "name": "Bá Thương Liễu Kình", "boss_id": "lieu_kinh_boss", "diff": "normal", "realm": "Bán Bộ Đấu Vương", "reward_fe": 120 },
		{ "rank": 2, "name": "Bá Thương Liễu Kình (Ác Mộng · Đại Liệt Trảo)", "boss_id": "lieu_kinh_boss", "diff": "nightmare", "realm": "Đấu Vương Sơ Kỳ", "reward_fe": 180 }
	]


static func get_strong_ranking_roster_for(pd: Node) -> Array:
	var roster: Array = get_strong_ranking_roster()
	if is_viem_minh_evolved(pd):
		roster.append({ "rank": 1, "name": "[VIÊM MINH] Lão Tông Chủ Vân Sơn (Tái Chiến)", "boss_id": "van_son_boss", "diff": "normal", "realm": "Tam Tinh Đấu Tông", "reward_fe": 240 })
		roster.append({ "rank": 0, "name": "[VIÊM MINH] Lão Tổ Vạn Hạt Môn Hạt Tất Nham", "boss_id": "hat_tat_nham_boss", "diff": "normal", "realm": "Tam Tinh Đấu Tông", "reward_fe": 280 })
		roster.append({ "rank": -1, "name": "[ĐỈNH QUYỂN II] Địa Ma Lão Quỷ (Ác Mộng Đấu Tông 7★)", "boss_id": "dia_ma_lao_quy_boss", "diff": "nightmare", "realm": "Thất Tinh Đấu Tông", "reward_fe": 380 })
	if pd.has_flag("ch08_broke_dau_tong") or is_tinh_van_cac_evolved(pd) or pd.is_demo_mode:
		roster.append({ "rank": -2, "name": "[TRUNG CHÂU] Thiên Kiêu Phượng Thanh Nhi (Phong Lôi Các #1)", "boss_id": "phuong_thanh_nhi_boss", "diff": "normal", "realm": "Ngũ Tinh Đấu Tông", "reward_fe": 440 })
		roster.append({ "rank": -3, "name": "[ĐAN HỘI] Đại Nghịch Đồ Mộ Cốt Lão Nhân (Hồn Điện)", "boss_id": "mo_cot_lao_nhan_boss", "diff": "normal", "realm": "Tam Tinh Đấu Tôn", "reward_fe": 520 })
		roster.append({ "rank": -4, "name": "[ĐỈNH CH.08] Thái Hư Tử Hắc Cự Long #9 (Ác Mộng)", "boss_id": "tam_thien_diem_viem_boss", "diff": "nightmare", "realm": "Chuẩn Đấu Tôn · Dị Hỏa #9", "reward_fe": 680 })
	if is_tinh_van_cac_evolved(pd):
		roster.append({ "rank": -5, "name": "[VONG HỒN] Thiên Tôn Hồn Điện Trích Tinh Lão Quỷ", "boss_id": "trich_tinh_lao_quy_boss", "diff": "normal", "realm": "Ngũ Tinh Đấu Tôn", "reward_fe": 760 })
		roster.append({ "rank": -6, "name": "[HOA TÔNG] Thiên Minh Song Sát Yêu Hoa Tà Quân", "boss_id": "yeu_hoa_ta_quan_boss", "diff": "normal", "realm": "Lục Tinh Đấu Tôn", "reward_fe": 840 })
		roster.append({ "rank": -7, "name": "[CỔ LONG] Phản Tặc Bắc Long Vương (Ngụy Bán Thánh)", "boss_id": "bac_long_vuong_boss", "diff": "nightmare", "realm": "Tam Tinh Bán Thánh Ngụy", "reward_fe": 980 })
		roster.append({ "rank": -8, "name": "[ĐỈNH QUYỂN III] Huyết Đao Thánh Giả — Tầng 3 Thiên Mộ", "boss_id": "huyet_dao_thanh_gia_boss", "diff": "nightmare", "realm": "Nhị Tinh Đấu Thánh", "reward_fe": 1250 })
	return roster
