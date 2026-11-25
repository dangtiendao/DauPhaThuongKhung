class_name NineTurnManager
extends RefCounted
## Hệ thống Cửu Chuyển Đấu Tôn (9-Turn Nirvana Tier — Chương 09) & Bí Cảnh Thiên Mộ x5 Thời Gian:
## - Khi đạt cảnh giới Đấu Tôn (realm >= 9), cho phép tích tụ 1 -> 9 Chuyển Luân Niết Bàn.
## - Mỗi Chuyển Luân cộng vĩnh viễn +8% toàn bộ chỉ số cơ bản (HP / QI / ATK / DEF / SPD / SOUL) -> tối đa +72% tại Cửu Chuyển!
## - Tiêu thụ Năng Lượng Hạch Cấp 8/9 (săn trong Thiên Mộ Tam Tầng) hoặc Cửu Chuyển Tôn Nguyên Đan (Bát Phẩm).
## - Trong Thiên Mộ Tam Tầng (ch09_thien_mo_tam_tang): tự động kích hoạt Dòng Chảy Thời Gian x5 (5x EXP & hồi tu luyện).

const MAX_TURNS: int = 9
const BONUS_PER_TURN: float = 0.08
const THIEN_MO_MAP_ID: String = "ch09_thien_mo_tam_tang"
const THIEN_MO_EXP_MULT: float = 5.0


static func get_turn_level(pd: Node) -> int:
	if pd == null or not ("nine_turn_level" in pd):
		return 0
	return clampi(int(pd.nine_turn_level), 0, MAX_TURNS)


static func get_stat_multiplier(pd: Node) -> float:
	return 1.0 + float(get_turn_level(pd)) * BONUS_PER_TURN


static func is_in_thien_mo(pd: Node) -> bool:
	if pd == null or not ("current_map_id" in pd):
		return false
	return str(pd.current_map_id) == THIEN_MO_MAP_ID


static func get_map_exp_multiplier(pd: Node) -> float:
	if is_in_thien_mo(pd):
		return THIEN_MO_EXP_MULT
	return 1.0


static func is_unlocked(pd: Node) -> bool:
	if pd == null:
		return false
	return int(pd.realm_index) >= 9 or pd.has_flag("ch09_broke_dau_ton") or bool(pd.is_demo_mode)


static func get_next_turn_requirement(pd: Node) -> Dictionary:
	var cur: int = get_turn_level(pd)
	if cur >= MAX_TURNS:
		return {"maxed": true, "turn": MAX_TURNS}
	var next_t: int = cur + 1
	var req_item: String = "core_nang_luong_8" if next_t <= 5 else "core_nang_luong_9"
	var req_qty: int = 2 if next_t <= 5 else 2
	var alt_pill: String = "pill_cuu_chuyen_ton_nguyen"
	var gold_cost: int = 45000 + next_t * 20000
	return {
		"maxed": false,
		"next_turn": next_t,
		"req_item": req_item,
		"req_qty": req_qty,
		"alt_pill": alt_pill,
		"gold_cost": gold_cost
	}


static func can_condense_next_turn(pd: Node) -> Dictionary:
	if pd == null:
		return {"ok": false, "reason": "Không có dữ liệu tu luyện."}
	if not is_unlocked(pd):
		return {"ok": false, "reason": "Cần đột phá cảnh giới Đấu Tôn (Chương 09) để mở Cửu Chuyển!"}
	var req: Dictionary = get_next_turn_requirement(pd)
	if bool(req.get("maxed", false)):
		return {"ok": false, "reason": "Đã viên mãn Cửu Chuyển Đấu Tôn Đỉnh Phong (9/9 Chuyển)!"}
	var gold_cost: int = int(req.get("gold_cost", 65000))
	if int(pd.gold) < gold_cost:
		return {"ok": false, "reason": "Cần %d Kim Tệ để ổn định Chuyển Luân." % gold_cost}
	var pill_id: String = str(req.get("alt_pill", ""))
	if int(pd.inventory.get(pill_id, 0)) >= 1:
		return {"ok": true, "use_pill": true, "req": req}
	var item_id: String = str(req.get("req_item", ""))
	var qty: int = int(req.get("req_qty", 2))
	if int(pd.inventory.get(item_id, 0)) >= qty:
		return {"ok": true, "use_pill": false, "req": req}
	var item_name: String = str(GameDatabase.get_item_def(item_id).get("name", item_id))
	return {"ok": false, "reason": "Cần %dx %s (săn trong Thiên Mộ) hoặc 1x Cửu Chuyển Tôn Nguyên Đan." % [qty, item_name]}


static func condense_next_turn(pd: Node) -> Dictionary:
	var chk: Dictionary = can_condense_next_turn(pd)
	if not bool(chk.get("ok", false)):
		return chk
	var req: Dictionary = chk.get("req", {})
	var gold_cost: int = int(req.get("gold_cost", 65000))
	pd.gold = max(0, int(pd.gold) - gold_cost)
	if bool(chk.get("use_pill", false)):
		pd.remove_item(str(req.get("alt_pill", "")), 1)
	else:
		pd.remove_item(str(req.get("req_item", "")), int(req.get("req_qty", 2)))
	pd.nine_turn_level = clampi(int(pd.nine_turn_level) + 1, 0, MAX_TURNS)
	if int(pd.nine_turn_level) >= MAX_TURNS:
		pd.set_story_flag("FLAG_NINE_TURN_PEAK")
		if int(pd.realm_index) == 9 and int(pd.stage) < 9:
			pd.stage = 9
	pd.recalculate_and_clamp(true)
	EventBus.inventory_changed.emit()
	EventBus.stats_changed.emit()
	EventBus.qi_updated.emit(pd.current_qi, pd.get_max_qi())
	EventBus.realm_updated.emit(pd.get_realm_display_title(), "Ngưng tụ Chuyển Luân Niết Bàn (%d/9)!" % int(pd.nine_turn_level))
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.screen_shake_requested.emit(12.0, 0.45)
	return {
		"ok": true,
		"turn": int(pd.nine_turn_level),
		"bonus_pct": int(round(float(pd.nine_turn_level) * BONUS_PER_TURN * 100.0))
	}


static func get_display_tag(pd: Node) -> String:
	var t: int = get_turn_level(pd)
	if t <= 0:
		return ""
	if t >= MAX_TURNS:
		return "Cửu Chuyển Đỉnh Phong (+72%)"
	return "Chuyển %d/9 (+%d%%)" % [t, int(round(float(t) * BONUS_PER_TURN * 100.0))]
