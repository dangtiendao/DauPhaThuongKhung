class_name SaintRealmManager
extends RefCounted
## Hệ thống Đấu Thánh Chương 10 (Quyển IV — Bồ Đề Hóa Thánh & Tịnh Liên Yêu Hỏa):
## - Quản lý Ảo Cảnh Bách Thế Luân Hồi (3 kiếp thủy mặc -> Thánh Giả Đạo Tâm + ACH_10_02).
## - Quản lý Đấu Thánh Không Gian (realm >= 11: Xé Không Gian CD 1.5s, kiếm khí LMB tầm xa, +25% Thánh Uy).
## - Quản lý Khí Linh Yêu Hỏa "Tiểu Y" (#3 Tịnh Liên Yêu Hỏa): Auto-Refine đan Phẩm 1–8 trong [L],
##   30% Tịnh Liên Thanh Hóa Hỏa chặn đạn tà hồi +8% QI, và Lục Sắc Hỏa Liên (6 Dị Hỏa).
## - Quản lý Thành Tựu Vĩnh Viễn Ch.10 (ACH_10_01 -> ACH_10_04) & Bắc Vương Thất Tinh Kim Lôi.

const SAINT_DASH_COOLDOWN: float = 1.5
const SAINT_DASH_SPEED: float = 1120.0
const SAINT_DASH_IFRAME: float = 0.70
const TIEU_Y_PURIFY_CHANCE: float = 0.30
const TIEU_Y_PURIFY_QI_PCT: float = 0.08


static func is_half_saint_or_above(pd: Node) -> bool:
	if pd == null:
		return false
	return int(pd.realm_index) >= 10 or pd.has_flag("ch10_viem_minh_saved")


static func has_dau_thanh_domain(pd: Node) -> bool:
	if pd == null:
		return false
	return int(pd.realm_index) >= 11 or pd.has_flag("ch10_broke_dau_thanh") or bool(pd.is_demo_mode)


static func has_thanh_gia_dao_tam(pd: Node) -> bool:
	if pd == null:
		return false
	return pd.has_flag("ch10_bach_the_enlightened") or has_dau_thanh_domain(pd)


static func has_tieu_y_spirit(pd: Node) -> bool:
	if pd == null:
		return false
	return pd.has_flag("ch10_tinh_lien_tamed") or pd.unlocked_flames.has("di_hoa_03_tinh_lien") or bool(pd.is_demo_mode)


static func has_bac_vuong_seven_star(pd: Node) -> bool:
	if pd == null:
		return false
	return pd.has_flag("sq_10_04_bac_vuong_7star") or bool(pd.is_demo_mode)


static func has_huan_nhi_soul_revive(pd: Node) -> bool:
	if pd == null:
		return false
	return pd.has_flag("ch10_tinh_lien_tamed") or bool(pd.is_demo_mode)


static func get_bach_the_benevolent_count(pd: Node) -> int:
	if pd == null:
		return 0
	var cnt: int = 0
	if pd.has_flag("ch10_bt_life1_nhan"):
		cnt += 1
	if pd.has_flag("ch10_bt_life50_tin"):
		cnt += 1
	if pd.has_flag("ch10_bt_life100_chan"):
		cnt += 1
	return cnt


static func get_bach_the_stage(pd: Node) -> int:
	if pd == null:
		return 0
	if pd.has_flag("ch10_bach_the_enlightened"):
		return 3
	if pd.has_flag("ch10_bt_life50_done"):
		return 2
	if pd.has_flag("ch10_bt_life1_done"):
		return 1
	return 0


static func is_ink_wash_illusion_active(pd: Node) -> bool:
	if pd == null:
		return false
	if str(pd.current_map_id) != "ch10_bo_de_co_thu":
		return false
	return pd.has_flag("ch10_bt_illusion_started") and not pd.has_flag("ch10_bach_the_enlightened")


static func get_achievement_atk_bonus_pct(pd: Node) -> float:
	if pd == null:
		return 0.0
	var bonus: float = 0.0
	if pd.has_flag("ach_10_01_viem_minh_chi_ton"):
		bonus += 5.0
	if pd.has_flag("sq_10_02_bo_de_dan_gifted"):
		bonus += 6.0
	return bonus


static func get_achievement_soul_bonus(pd: Node) -> int:
	if pd == null:
		return 0
	var bonus: int = 0
	if pd.has_flag("ach_10_02_tram_kiep_so_tam"):
		bonus += 250
	if pd.has_flag("sq_10_03_sieu_do_van_hon"):
		bonus += 350
	return bonus


static func get_hoang_tuyen_cd_mult(pd: Node) -> float:
	if pd == null:
		return 1.0
	return 0.80 if pd.has_flag("ach_10_03_thien_phu_thong_soai") else 1.0


static func get_saint_supremacy_mult(pd: Node, enemy_realm_idx: int) -> float:
	if not has_dau_thanh_domain(pd):
		return 1.0
	return 1.25 if enemy_realm_idx < 11 else 1.0


static func try_tieu_y_purify_hit(pd: Node, roll_override: float = -1.0) -> bool:
	if not has_tieu_y_spirit(pd):
		return false
	var r: float = roll_override if roll_override >= 0.0 else randf()
	if r >= TIEU_Y_PURIFY_CHANCE:
		return false
	var qi_gain: float = float(pd.get_max_qi()) * TIEU_Y_PURIFY_QI_PCT
	pd.current_qi = minf(float(pd.get_max_qi()), float(pd.current_qi) + qi_gain)
	EventBus.qi_updated.emit(pd.current_qi, pd.get_max_qi())
	return true


static func can_tieu_y_auto_refine(pd: Node, recipe: Dictionary) -> Dictionary:
	if not has_tieu_y_spirit(pd):
		return {"ok": false, "reason": "Cần thu phục Khí Linh Tiểu Y (#3 Tịnh Liên Yêu Hỏa — Ch.10) để mở Luyện Đan Tức Thì!"}
	var tier: int = int(recipe.get("tier", 1))
	if tier > 8:
		return {"ok": false, "reason": "Đan Chuẩn Cửu Phẩm (Hắc Kim Đan Lôi) cần tự tay khai lò vượt kiếp!"}
	var req_soul: int = int(recipe.get("req_soul", 0))
	if int(pd.get_soul()) < req_soul:
		return {"ok": false, "reason": "Chưa đủ Linh Hồn (%d SOUL) để Tiểu Y tự động luyện đan này." % req_soul}
	var ings: Dictionary = recipe.get("ingredients", {})
	for item_id in ings.keys():
		var need: int = int(ings[item_id])
		if pd.get_item_count(str(item_id)) < need:
			var iname: String = str(GameDatabase.get_item_def(str(item_id)).get("name", str(item_id)))
			return {"ok": false, "reason": "Thiếu nguyên liệu: %dx %s" % [need, iname]}
	return {"ok": true, "reason": ""}


static func run_tieu_y_auto_refine(pd: Node, recipe: Dictionary) -> Dictionary:
	var chk: Dictionary = can_tieu_y_auto_refine(pd, recipe)
	if not bool(chk.get("ok", false)):
		return chk
	var ings: Dictionary = recipe.get("ingredients", {})
	for item_id in ings.keys():
		pd.remove_item(str(item_id), int(ings[item_id]))
	var out_id: String = str(recipe.get("output_item", ""))
	var out_cnt: int = max(1, int(recipe.get("output_count", 1)))
	pd.add_item(out_id, out_cnt)
	var soul_gain: int = max(1, int(round(float(recipe.get("soul_exp_gain", 15)) * 0.65)))
	pd.bonus_soul += soul_gain
	pd.notify_pill_crafted(out_id)
	pd.recalculate_and_clamp(false)
	EventBus.inventory_changed.emit()
	EventBus.stats_changed.emit()
	EventBus.audio_sfx_requested.emit("alchemy_success")
	var out_name: String = str(GameDatabase.get_item_def(out_id).get("name", out_id))
	return {
		"ok": true,
		"output_item": out_id,
		"output_count": out_cnt,
		"msg": "✦ Tiểu Y phun Tịnh Liên Hỏa nhả tức thì %dx [%s] (+%d Hồn Lực)! \"Y Y nha~ Xong rồi nè!\"" % [out_cnt, out_name, soul_gain]
	}


static func get_hud_domain_badge(pd: Node) -> String:
	if pd == null:
		return ""
	if is_ink_wash_illusion_active(pd):
		return "☯ BÁCH THẾ LUÂN HỒI · THỦY MẶC (%d/3)" % get_bach_the_stage(pd)
	if has_tieu_y_spirit(pd) and has_dau_thanh_domain(pd):
		return "✿ ĐẤU THÁNH KHÔNG GIAN · KHÍ LINH TIỂU Y (#3)"
	if has_dau_thanh_domain(pd):
		return "✦ ĐẤU THÁNH KHÔNG GIAN · XÉ KHÔNG 1.5s"
	if is_half_saint_or_above(pd):
		return "◈ BÁN THÁNH THÁNH UY · MÃNG HOANG"
	return ""
