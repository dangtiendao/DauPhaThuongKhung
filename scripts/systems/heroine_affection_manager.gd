class_name HeroineAffectionManager
extends RefCounted
## Quản Lý Hảo Cảm 5 Hồng Nhan Tri Kỷ (Tách mô-đun từ player_data.gd):
##   - Hồ sơ 5 Hồng Nhan (Huân Nhi, Tiểu Y Tiên, Vân Chi, Thanh Lân, Mỹ Đỗ Toa)
##   - Tính bộ chỉ số Buff tích lũy (25/50/75/100)
##   - Nhận Quà Tri Kỷ theo mốc & Tặng vật phẩm tăng Hảo Cảm x2 sở thích


static func get_heroine_profiles() -> Array:
	return [
		{
			"key": "huan_nhi",
			"name": "Tiêu Huân Nhi",
			"title": "Cổ Tộc Thánh Nữ · Kim Đế Phần Thiên",
			"sprite": "res://assets/sprites/npcs/npc_huan_nhi.png",
			"color": "#FFD166",
			"favorite_items": ["pill_truc_co_linh_dich", "herb_tu_diep_lan", "pill_thanh_lien_tu"],
			"fav_hint": "Trúc Cơ Linh Dịch, Tử Diệp Lan Thảo, Hạt Thanh Liên Tử",
			"milestones": [
				{ "req": 25, "desc": "+5% Công Kích (ATK)" },
				{ "req": 50, "desc": "+8% EXP Đấu Khí + Quà Tri Kỷ (Trúc Cơ Linh Dịch x2, Đá CH x4)", "gift_items": { "pill_truc_co_linh_dich": 2 }, "gift_stones": 4, "gift_gold": 120 },
				{ "req": 75, "desc": "+10% Sát thương Hỏa" },
				{ "req": 100, "desc": "Kim Đế Chúc Phúc: +12% ATK & +12 SOUL + Quà (Đá CH x8, 400V)", "gift_items": { "pill_bang_tam_dan": 1 }, "gift_stones": 8, "gift_gold": 400 }
			]
		},
		{
			"key": "tieu_y_tien",
			"name": "Tiểu Y Tiên",
			"title": "Vạn Dược Trai · Ách Nan Độc Thể",
			"sprite": "res://assets/sprites/npcs/npc_tieu_y_tien.png",
			"color": "#80ED99",
			"favorite_items": ["herb_ngung_huyet_thao", "herb_tay_cot_hoa", "herb_sa_chi_man_da_la"],
			"fav_hint": "Ngưng Huyết Thảo, Tẩy Cốt Hoa, Sa Chi Mạn Đà La",
			"milestones": [
				{ "req": 25, "desc": "+8% Sinh Lực Tối Đa (HP)" },
				{ "req": 50, "desc": "+20% Hiệu quả Hồi Máu + Quà Tri Kỷ (Ngưng Huyết Tán x4, Đá CH x4)", "gift_items": { "pill_ngung_huyet_tan": 4, "herb_sa_chi_man_da_la": 2 }, "gift_stones": 4, "gift_gold": 150 },
				{ "req": 75, "desc": "+12% Tỷ lệ & Vùng Đan Tâm Luyện Đan" },
				{ "req": 100, "desc": "Độc Tôn Hộ Thể: +15% Max HP & +5% Hút máu + Quà (Băng Tâm Đan x2)", "gift_items": { "pill_bang_tam_dan": 2 }, "gift_stones": 8, "gift_gold": 420 }
			]
		},
		{
			"key": "van_chi",
			"name": "Vân Chi (Vân Vận)",
			"title": "Đấu Hoàng Phong Hệ · Tông Chủ Vân Lam",
			"sprite": "res://assets/sprites/npcs/npc_van_chi.png",
			"color": "#70D6FF",
			"favorite_items": ["herb_hoat_khi_qua", "pill_hoi_khi_dan", "core_moc_2"],
			"fav_hint": "Hoạt Khí Quả, Hồi Khí Đan, Mộc Ma Hạch (Cấp 2)",
			"milestones": [
				{ "req": 25, "desc": "+6% Tốc Độ Di Chuyển (SPD)" },
				{ "req": 50, "desc": "-8% Hồi chiêu Đấu Kỹ + Quà Tri Kỷ (Hồi Khí Đan x4, Đá CH x5)", "gift_items": { "pill_hoi_khi_dan": 4 }, "gift_stones": 5, "gift_gold": 180 },
				{ "req": 75, "desc": "+8% Tỷ lệ Chí Mạng (Crit)" },
				{ "req": 100, "desc": "Phong Chi Cực Kiếm Ý: -10% CD & +8% SPD + Quà (Hạt Thanh Liên Tử x2)", "gift_items": { "pill_thanh_lien_tu": 2 }, "gift_stones": 8, "gift_gold": 480 }
			]
		},
		{
			"key": "thanh_lan",
			"name": "Thanh Lân",
			"title": "Bích Xà Tam Hoa Đồng · Muội Muội Tiêu Gia",
			"sprite": "res://assets/sprites/npcs/npc_thanh_lan.png",
			"color": "#2EC4B6",
			"favorite_items": ["core_hoa_1", "core_hoa_3", "pill_thanh_lien_tu"],
			"fav_hint": "Hỏa Ma Hạch, Viêm Xà Ma Hạch, Hạt Thanh Liên Tử",
			"milestones": [
				{ "req": 25, "desc": "+55px Tầm Hút Vật Phẩm" },
				{ "req": 50, "desc": "+10% EXP & +15% Kim Tệ rơi + Quà Tri Kỷ (Viêm Xà Hạch x2, Liên Tử x2)", "gift_items": { "core_hoa_3": 2, "pill_thanh_lien_tu": 2 }, "gift_stones": 5, "gift_gold": 220 },
				{ "req": 75, "desc": "+12 Linh Hồn Lực (SOUL)" },
				{ "req": 100, "desc": "Bích Xà Đồng Cảm: +15% Sát thương Hỏa & +12% Rớt đồ hiếm", "gift_items": { "pill_pha_chuong_dan": 1 }, "gift_stones": 9, "gift_gold": 520 }
			]
		},
		{
			"key": "my_do_toa",
			"name": "Thải Lân (Mỹ Đỗ Toa)",
			"title": "Nữ Vương Xà Nhân · Thất Thải Thôn Thiên Mãng",
			"sprite": "res://assets/sprites/npcs/npc_my_do_toa.png",
			"color": "#E0AAFF",
			"favorite_items": ["core_hoa_3", "pill_bang_tam_dan", "pill_thanh_lien_tu"],
			"fav_hint": "Viêm Xà Ma Hạch, Băng Tâm Đan, Hạt Thanh Liên Tử",
			"milestones": [
				{ "req": 25, "desc": "+8% Tỷ lệ Chí Mạng (Crit)" },
				{ "req": 50, "desc": "+12% Xuyên Áp Chế Cảnh Giới + Quà Tri Kỷ (Băng Tâm Đan x2, Đá CH x6)", "gift_items": { "pill_bang_tam_dan": 2 }, "gift_stones": 6, "gift_gold": 280 },
				{ "req": 75, "desc": "+18% Uy lực Phật Nộ Hỏa Liên" },
				{ "req": 100, "desc": "Nữ Vương Long Uy: +15% ATK & +15% DEF + Quà (Phá Chướng Đan x1, Đá CH x10)", "gift_items": { "pill_pha_chuong_dan": 1 }, "gift_stones": 10, "gift_gold": 650 }
			]
		}
	]


static func rebuild_affection_cache(pd) -> void:
	var b: Dictionary = {
		"atk_pct": 0.0,
		"hp_pct": 0.0,
		"def_pct": 0.0,
		"spd_pct": 0.0,
		"exp_bonus": 0.0,
		"flame_dmg": 0.0,
		"lotus_dmg_pct": 0.0,
		"soul": 0.0,
		"heal_pct": 0.0,
		"alchemy_bonus": 0.0,
		"lifesteal": 0.0,
		"cooldown_red": 0.0,
		"crit_chance": 0.0,
		"loot_magnet": 0.0,
		"gold_pct": 0.0,
		"gear_drop_pct": 0.0,
		"realm_pen": 0.0
	}
	var hn: int = pd.get_affection("huan_nhi")
	if hn >= 25:
		b["atk_pct"] += 5.0
	if hn >= 50:
		b["exp_bonus"] += 8.0
	if hn >= 75:
		b["flame_dmg"] += 10.0
	if hn >= 100:
		b["atk_pct"] += 12.0
		b["soul"] += 12.0

	var yt: int = pd.get_affection("tieu_y_tien")
	if yt >= 25:
		b["hp_pct"] += 8.0
	if yt >= 50:
		b["heal_pct"] += 20.0
	if yt >= 75:
		b["alchemy_bonus"] += 12.0
	if yt >= 100:
		b["hp_pct"] += 15.0
		b["lifesteal"] += 5.0

	var vc: int = pd.get_affection("van_chi")
	if vc >= 25:
		b["spd_pct"] += 6.0
	if vc >= 50:
		b["cooldown_red"] += 8.0
	if vc >= 75:
		b["crit_chance"] += 8.0
	if vc >= 100:
		b["cooldown_red"] += 10.0
		b["spd_pct"] += 8.0

	var tl: int = pd.get_affection("thanh_lan")
	if tl >= 25:
		b["loot_magnet"] += 55.0
	if tl >= 50:
		b["exp_bonus"] += 10.0
		b["gold_pct"] += 15.0
	if tl >= 75:
		b["soul"] += 12.0
	if tl >= 100:
		b["flame_dmg"] += 15.0
		b["gear_drop_pct"] += 12.0

	var md: int = pd.get_affection("my_do_toa")
	if md >= 25:
		b["crit_chance"] += 8.0
	if md >= 50:
		b["realm_pen"] += 12.0
	if md >= 75:
		b["lotus_dmg_pct"] += 18.0
	if md >= 100:
		b["atk_pct"] += 15.0
		b["def_pct"] += 15.0

	pd.cached_affection_bonuses = b


static func claim_affection_milestone(pd, heroine_key: String, req_pts: int) -> Dictionary:
	var key_id: String = "%s_%d" % [heroine_key, req_pts]
	if pd.is_affection_milestone_claimed(heroine_key, req_pts):
		return { "ok": false, "msg": "Quà Tri Kỷ mốc này đã nhận rồi!" }
	if pd.get_affection(heroine_key) < req_pts:
		return { "ok": false, "msg": "Chưa đạt %d điểm Hảo Cảm!" % req_pts }

	for prof in get_heroine_profiles():
		if str(prof.get("key", "")) != heroine_key:
			continue
		for ms in prof.get("milestones", []):
			if int(ms.get("req", 0)) == req_pts:
				pd.claimed_affection_milestones[key_id] = true
				var parts: Array = []
				var g_gold: int = int(ms.get("gift_gold", 0))
				if g_gold > 0:
					pd.gold += g_gold
					parts.append("+%d Kim Tệ" % g_gold)
				var g_st: int = int(ms.get("gift_stones", 0))
				if g_st > 0:
					pd.enhance_stones += g_st
					parts.append("+%d Đá CH" % g_st)
				var g_items: Dictionary = ms.get("gift_items", {})
				for iid in g_items.keys():
					var cnt: int = int(g_items[iid])
					pd.add_item(str(iid), cnt)
					var idef: Dictionary = GameDatabase.get_item_def(str(iid))
					parts.append("%s x%d" % [str(idef.get("name", iid)), cnt])
				EventBus.audio_sfx_requested.emit("chest_open")
				EventBus.stats_changed.emit()
				pd.trigger_auto_save("nhận quà hồng nhan")
				return {
					"ok": true,
					"msg": "NHẬN QUÀ TRI KỶ (%s · Mốc %d): %s!" % [str(prof.get("name", "")), req_pts, ", ".join(parts)]
				}
	return { "ok": false, "msg": "Không tìm thấy mốc quà!" }


static func give_gift_to_heroine(pd, heroine_key: String, item_id: String) -> Dictionary:
	if pd.get_item_count(item_id) <= 0:
		return { "ok": false, "msg": "Trong Nạp Giới không có vật phẩm này!" }
	if pd.get_affection(heroine_key) >= 100:
		return { "ok": false, "msg": "Hảo Cảm đã đạt cực hạn 100/100 (Tri Kỷ Trọn Đời)!" }
	var idef: Dictionary = GameDatabase.get_item_def(item_id)
	var itype: String = str(idef.get("type", ""))
	if itype == "breakthrough":
		return { "ok": false, "msg": "Không nên tặng Đan Đột Phá quý hiếm!" }

	var is_fav: bool = false
	var h_name: String = heroine_key
	for prof in get_heroine_profiles():
		if str(prof.get("key", "")) == heroine_key:
			h_name = str(prof.get("name", heroine_key))
			is_fav = (prof.get("favorite_items", []) as Array).has(item_id)
			break

	pd.remove_item(item_id, 1)
	var tier_v: int = maxi(1, int(idef.get("tier", 1)))
	var gain: int = (8 + tier_v * 4) if is_fav else (4 + tier_v * 2)
	pd.add_affection(heroine_key, gain)
	EventBus.audio_sfx_requested.emit("loot_rare" if is_fav else "loot_pickup")
	var fav_tag: String = " [ĐÚNG SỞ THÍCH x2!]" if is_fav else ""
	return {
		"ok": true,
		"msg": "Đã tặng [%s] cho %s -> +%d Hảo Cảm%s (%d/100)!" % [
			str(idef.get("name", item_id)), h_name, gain, fav_tag, pd.get_affection(heroine_key)
		]
	}


static func get_active_affection_summary_text(pd) -> String:
	if pd.cached_affection_bonuses.is_empty():
		rebuild_affection_cache(pd)
	var parts: Array = []
	var labels: Array = [
		["atk_pct", "ATK +%d%%"], ["hp_pct", "HP +%d%%"], ["def_pct", "DEF +%d%%"],
		["spd_pct", "SPD +%d%%"], ["exp_bonus", "EXP +%d%%"], ["flame_dmg", "Hỏa +%d%%"],
		["lotus_dmg_pct", "Hỏa Liên +%d%%"], ["crit_chance", "Crit +%d%%"],
		["cooldown_red", "Giảm CD %d%%"], ["alchemy_bonus", "Đan Đạo +%d%%"],
		["heal_pct", "Hồi Máu +%d%%"], ["lifesteal", "Hút Máu +%d%%"],
		["realm_pen", "Xuyên Áp Chế +%d%%"], ["soul", "SOUL +%d"],
		["loot_magnet", "Hút Đồ +%dpx"], ["gold_pct", "Kim Tệ +%d%%"], ["gear_drop_pct", "Rớt Đồ +%d%%"]
	]
	for pair in labels:
		var v: int = int(round(float(pd.cached_affection_bonuses.get(str(pair[0]), 0.0))))
		if v > 0:
			parts.append(str(pair[1]) % v)
	return " · ".join(parts) if not parts.is_empty() else "Chưa kích hoạt (Đạt >= 25 Hảo Cảm với bất kỳ Hồng Nhan nào!)"
