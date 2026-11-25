class_name EmperorRealmManager
extends RefCounted
## Hệ thống Cảnh Giới 12: VIÊM ĐẾ (ĐẤU ĐẾ), ĐẾ CẢNH LINH HỒN, 17 Bí Cảnh Dị Hỏa Ẩn & New Game+ (Chương 11 — v1.0.0):
## - Quản lý Đế Cảnh Linh Hồn (3.500+ SOUL · max tier 10 Đế Phẩm · Đế Hồn Pháp Tướng +100% SOUL sát thương chuẩn).
## - Quản lý Viêm Đế Vạn Hỏa Triều Tông (23 Dị Hỏa -> #1 Đế Viêm · Dị Hỏa Hằng Cổ Xích · Đế Bước Hư Không 1.280 px/s).
## - Quản lý 17 Bí Cảnh Dị Hỏa Ẩn (sưu tầm đủ 23/23 Chân Hỏa Bản Nguyên Ấn), 5 Thành Tựu Bạch Kim (ACH_11_01..05)
##   và Đà Xá Đế Phẩm Hoàn Đan (+25% toàn chỉ số vĩnh viễn).
## - Quản lý Chế Độ Luân Hồi Chuyển Thế (New Game+): giữ trọn 28 Dị Hỏa, 37 Đấu Kỹ, Tiểu Y & công thức,
##   nâng toàn bộ quái/Boss lên độ khó Thương Khung Khốc Liệt (+200% HP, +50% ATK, +35% SPD).

const EMPEROR_DASH_COOLDOWN: float = 1.1
const EMPEROR_DASH_SPEED: float = 1280.0
const EMPEROR_DASH_IFRAME: float = 0.85

const HIDDEN_17_FLAME_IDS: Array[String] = [
	"di_hoa_23_huyen_hoang", "di_hoa_22_van_thu", "di_hoa_21_am_duong", "di_hoa_20_u_minh_doc",
	"di_hoa_18_phong_loi", "di_hoa_17_hoa_son", "di_hoa_16_hoa_van", "di_hoa_13_quy_linh",
	"di_hoa_12_cuu_long", "di_hoa_10_cuu_u_phong", "di_hoa_08_hong_lien", "di_hoa_07_cuu_u_kim_to",
	"di_hoa_06_bat_hoang", "di_hoa_05_sinh_linh", "di_hoa_04_kim_de", "di_hoa_02_hu_vo", "di_hoa_01_de_viem"
]


static func has_de_canh_soul(pd: Node) -> bool:
	if pd == null:
		return false
	return pd.get_soul() >= 3500 or pd.has_flag("ch11_de_canh_soul_awakened") or bool(pd.is_demo_mode)


static func is_viem_de_emperor(pd: Node) -> bool:
	if pd == null:
		return false
	return int(pd.realm_index) >= 12 or pd.has_flag("ch11_viem_de_ascended") or bool(pd.is_demo_mode)


static func has_hang_co_xich(pd: Node) -> bool:
	if pd == null:
		return false
	var w = pd.equipped_gear.get("weapon", {})
	if w is Dictionary and str(w.get("template_id", "")) == "wpn_di_hoa_hang_co_xich":
		return true
	return is_viem_de_emperor(pd) and pd.has_huyen_trong_xich_equipped()


static func has_all_23_heavenly_flames(pd: Node) -> bool:
	if pd == null:
		return false
	if pd.has_flag("ch11_all_23_flames_hunted") or bool(pd.is_demo_mode):
		return true
	var cnt: int = 0
	for fid in pd.unlocked_flames:
		if str(fid).begins_with("di_hoa_"):
			cnt += 1
	return cnt >= 23


static func get_heavenly_flame_count(pd: Node) -> int:
	if pd == null:
		return 0
	var cnt: int = 0
	for fid in pd.unlocked_flames:
		if str(fid).begins_with("di_hoa_"):
			cnt += 1
	return cnt


static func unlock_all_23_heavenly_flames(pd: Node) -> int:
	if pd == null:
		return 0
	var added: int = 0
	for fl in GameDatabase.flames_ordered:
		if fl is Dictionary:
			var fid: String = str(fl.get("id", ""))
			if fid.begins_with("di_hoa_") and not pd.unlocked_flames.has(fid):
				pd.unlocked_flames.append(fid)
				added += 1
	pd.recalculate_and_clamp(false)
	EventBus.flame_changed.emit(pd.equipped_flame_id)
	EventBus.stats_changed.emit()
	return added


static func get_epilogue_done_count(pd: Node) -> int:
	if pd == null:
		return 0
	var c: int = 0
	for fk in ["eq_11_01_tieu_y_tien_done", "eq_11_02_van_van_done", "eq_11_03_nha_phi_done", "eq_11_04_candy_party_done", "eq_11_05_ancestor_oath_done"]:
		if pd.has_flag(fk):
			c += 1
	return c


static func check_and_award_epilogue_platinum(pd: Node) -> bool:
	if pd == null:
		return false
	if pd.has_flag("ch11_wedding_completed") and get_epilogue_done_count(pd) >= 5:
		if not pd.has_flag("ach_11_04_song_hau_dong_quy"):
			pd.story_flags["ach_11_04_song_hau_dong_quy"] = true
			pd.add_story_relic("Thành Tựu Bạch Kim ACH_11_04: Song Hậu Đồng Quy — Bách Niên Giai Lão (+10% Toàn Chỉ Số!)")
			EventBus.banter_triggered.emit("★ THÀNH TỰU BẠCH KIM [SONG HẬU ĐỒNG QUY]: Hoàn tất Đại Hôn & 5/5 Hậu Truyện (+10% Toàn Chỉ Số Vĩnh Viễn!)")
			return true
	return false


static func get_emperor_stat_mult(pd: Node) -> float:
	if pd == null:
		return 1.0
	var mult: float = 1.0
	if pd.has_flag("ch11_da_xa_pill_eaten"):
		mult *= 1.25 # Đà Xá Đế Phẩm Hoàn Đan (+25% toàn bộ chỉ số vĩnh viễn!)
	if pd.has_flag("ach_11_04_song_hau_dong_quy"):
		mult *= 1.10 # Song Hậu Đồng Quy (+10% toàn chỉ số!)
	if pd.has_flag("ach_11_05_chua_te_dai_thien"):
		mult *= 1.15 # Cúp Bạch Kim Chúa Tể Đại Thiên (+15% toàn chỉ số!)
	return mult


static func get_de_hon_true_damage_bonus(pd: Node) -> float:
	if pd == null:
		return 0.0
	if bool(pd.is_de_hon_active) or (bool(pd.is_duoc_lao_active) and pd.get_assist_mode() == "viem_de_phap_tuong"):
		return float(pd.get_soul())
	return 0.0


static func get_emperor_supremacy_mult(pd: Node, enemy_realm_idx: int) -> float:
	if not is_viem_de_emperor(pd):
		return 1.0
	return 1.45 if enemy_realm_idx < 12 else 1.0


static func get_ng_plus_cycle(pd: Node) -> int:
	if pd == null or not ("ng_plus_cycle" in pd):
		return 0
	return maxi(0, int(pd.ng_plus_cycle))


static func is_ng_plus_active(pd: Node) -> bool:
	return get_ng_plus_cycle(pd) > 0


static func get_ng_plus_enemy_multipliers(pd: Node) -> Dictionary:
	var cyc: int = get_ng_plus_cycle(pd)
	if cyc <= 0:
		return { "hp": 1.0, "atk": 1.0, "spd": 1.0, "exp": 1.0 }
	# Thương Khung Khốc Liệt (New Game+): +200% HP, +50% ATK, +35% SPD mỗi vòng Luân Hồi (giới hạn SPD để dễ điều khiển)!
	return {
		"hp": 1.0 + 2.0 * float(cyc),
		"atk": 1.0 + 0.50 * float(cyc),
		"spd": minf(1.80, 1.0 + 0.35 * float(cyc)),
		"exp": 1.0 + 1.50 * float(cyc)
	}


static func start_new_game_plus(pd: Node) -> Dictionary:
	if pd == null:
		return { "ok": false, "msg": "Dữ liệu người chơi không hợp lệ!" }
	if not (pd.has_flag("ch11_hon_thien_de_sealed") or pd.has_flag("ch11_completed") or bool(pd.is_demo_mode)):
		return { "ok": false, "msg": "Cần đánh bại & phong ấn Hồn Đế Hồn Thiên Đế (Chương 11) để mở khóa Luân Hồi Chuyển Thế (New Game+)!" }

	var next_cycle: int = get_ng_plus_cycle(pd) + 1
	var kept_flames: Array = pd.unlocked_flames.duplicate()
	var kept_skills: Array = pd.unlocked_skills.duplicate()
	var kept_mastery: Dictionary = pd.skill_mastery_uses.duplicate(true)
	var kept_gold: int = maxi(50000, int(pd.gold))
	var kept_stones: int = maxi(50, int(pd.enhance_stones))
	var kept_relics: Array = pd.story_relics.duplicate()
	var kept_ach_flags: Dictionary = {}
	for fk in pd.story_flags.keys():
		var fks: String = str(fk)
		if fks.begins_with("ach_") or fks == "ch11_da_xa_pill_eaten" or fks == "ch11_all_23_flames_hunted":
			kept_ach_flags[fks] = true
	var kept_eq: Dictionary = pd.equipped_gear.duplicate(true)
	var kept_bag: Array = pd.gear_bag.duplicate(true)
	var kept_sockets: Array = pd.weapon_core_sockets.duplicate()
	var kept_bestiary: Dictionary = pd.enemy_kill_counts.duplicate(true)
	var kept_br: Dictionary = pd.boss_rush_records.duplicate(true)
	var slot_id: int = int(pd.active_save_slot)

	pd.reset_for_new_game(slot_id)
	pd.ng_plus_cycle = next_cycle
	pd.unlocked_flames = kept_flames
	if pd.unlocked_flames.has("di_hoa_01_de_viem"):
		pd.equipped_flame_id = "di_hoa_01_de_viem"
	pd.unlocked_skills = kept_skills
	pd.skill_mastery_uses = kept_mastery
	pd.gold = kept_gold
	pd.enhance_stones = kept_stones
	pd.story_relics = kept_relics
	for ak in kept_ach_flags.keys():
		pd.story_flags[ak] = true
	pd.story_flags["FLAG_NG_PLUS_ACTIVE"] = true
	pd.story_flags["FLAG_TIEU_Y_ACTIVE"] = true
	pd.story_flags["ch10_tinh_lien_tamed"] = true # Giữ Khí Linh Tiểu Y đồng hành ngay từ Chương 01 Ô Thản Thành!
	pd.equipped_gear = kept_eq
	pd.gear_bag = kept_bag
	pd.weapon_core_sockets = kept_sockets
	pd.enemy_kill_counts = kept_bestiary
	pd.boss_rush_records = kept_br
	pd.add_item("item_hong_tran_de_tinh", 2)
	pd.add_story_relic("☯ Luân Hồi Chuyển Thế — New Game+ Vòng %d (Thương Khung Khốc Liệt · Giữ 23 Dị Hỏa & Tiểu Y!)" % next_cycle)
	pd._rebuild_gear_cache()
	pd.recalculate_and_clamp(true)
	EventBus.stats_changed.emit()
	EventBus.equipment_changed.emit()
	EventBus.skills_updated.emit()
	EventBus.quest_updated.emit()
	pd.trigger_auto_save("Luân Hồi NG+ Vòng %d" % next_cycle, true)
	return {
		"ok": true,
		"cycle": next_cycle,
		"msg": "☯ LUÂN HỒI CHUYỂN THẾ — NEW GAME+ VÒNG %d! Toàn bộ Dị Hỏa, Đấu Kỹ, Trang Bị & Tiểu Y được kế thừa — Quái & Boss hóa Thương Khung Khốc Liệt (+%d%% HP)!" % [next_cycle, 200 * next_cycle]
	}


static func get_hud_emperor_badge(pd: Node) -> String:
	if pd == null:
		return ""
	var parts: Array[String] = []
	if is_ng_plus_active(pd):
		parts.append("☯ NG+ VÒNG %d" % get_ng_plus_cycle(pd))
	if is_viem_de_emperor(pd):
		var fc: int = get_heavenly_flame_count(pd)
		if pd.has_flag("ach_11_05_chua_te_dai_thien"):
			parts.append("👑 CHÚA TỂ ĐẠI THIÊN · 23/23 DỊ HỎA")
		else:
			parts.append("👑 VIÊM ĐẾ · %d/23 DỊ HỎA" % fc)
	elif has_de_canh_soul(pd):
		parts.append("✦ ĐẾ CẢNH LINH HỒN · PHÁP TƯỚNG")
	return " · ".join(parts)
