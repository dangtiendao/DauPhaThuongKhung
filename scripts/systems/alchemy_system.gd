class_name AlchemySystem
extends RefCounted
## Xử lý logic Lò Luyện Đan (hỗ trợ cả Khai Lò nhanh & Mini-game Khống Hỏa + Đón Đan Lôi!):
## - Kiểm tra nguyên liệu trong Nạp Giới, Linh Hồn Lực (SOUL), thưởng Dị Hỏa & Dược Đỉnh.

static func can_craft(recipe: Dictionary) -> Dictionary:
	var req_soul: int = int(recipe.get("req_soul", 1))
	if PlayerData.get_soul() < req_soul:
		return { "ok": false, "reason": "Cần %d Linh Hồn Lực (Hiện có: %d)" % [req_soul, PlayerData.get_soul()] }

	var ing: Dictionary = recipe.get("ingredients", {})
	for item_id in ing.keys():
		var needed: int = int(ing[item_id])
		var owned: int = PlayerData.get_item_count(str(item_id))
		if owned < needed:
			var idef: Dictionary = GameDatabase.get_item_def(str(item_id))
			var iname: String = str(idef.get("name", item_id))
			return { "ok": false, "reason": "Thiếu %s (%d/%d)" % [iname, owned, needed] }

	return { "ok": true, "reason": "Đủ điều kiện khai lò!" }


static func get_success_chance(recipe: Dictionary) -> float:
	var base_rate: float = float(recipe.get("base_success_rate", 0.80))
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var flame_bonus: float = float(f_def.get("alchemy_bonus_pct", 0.0)) / 100.0 if not f_def.is_empty() else 0.0
	var gear_bonus: float = PlayerData.get_alchemy_equipment_bonus()
	var soul_diff: int = max(0, PlayerData.get_soul() - int(recipe.get("req_soul", 5)))
	var soul_bonus: float = float(soul_diff) * 0.005
	return clampf(base_rate + flame_bonus + gear_bonus + soul_bonus, 0.15, 1.0)


static func consume_ingredients(recipe: Dictionary) -> void:
	var ing: Dictionary = recipe.get("ingredients", {})
	for item_id in ing.keys():
		PlayerData.remove_item(str(item_id), int(ing[item_id]))


static func finish_minigame_craft(recipe: Dictionary, quality_tier: int, lightning_blocked: bool) -> Dictionary:
	# quality_tier: 0 = nổ lò (fail), 1 = thành đan thường, 2 = Đan Văn Hoàn Mỹ!
	var out_id: String = str(recipe.get("output_item", ""))
	var out_cnt: int = int(recipe.get("output_count", 1))
	var out_def: Dictionary = GameDatabase.get_item_def(out_id)
	var out_name: String = str(out_def.get("name", out_id))
	var base_soul: int = int(recipe.get("soul_exp_gain", 2))

	if quality_tier <= 0:
		PlayerData.bonus_soul += 1
		EventBus.audio_sfx_requested.emit("alchemy_fail")
		EventBus.stats_changed.emit()
		return {
			"ok": false,
			"msg": "HỎA HẦU THẤT BẠI — NỔ LÒ! (Nhận +1 Linh Hồn kinh nghiệm khống hỏa)"
		}

	var bonus_pill: int = 1 if (quality_tier >= 2 or lightning_blocked) else 0
	var final_cnt: int = out_cnt + bonus_pill
	var soul_gain: int = int(round(float(base_soul) * (1.5 if quality_tier >= 2 else 1.0)))
	PlayerData.add_item(out_id, final_cnt)
	PlayerData.bonus_soul += soul_gain
	PlayerData.notify_pill_crafted(out_id)
	EventBus.audio_sfx_requested.emit("alchemy_success")
	EventBus.stats_changed.emit()

	var tag: String = ""
	if quality_tier >= 2 and lightning_blocked:
		tag = " [CHẮN ĐAN LÔI — ĐAN VĂN HOÀN MỸ +1 viên!]"
	elif quality_tier >= 2:
		tag = " [ĐAN HƯƠNG ĐẠI THÀNH +1 viên!]"
	elif lightning_blocked:
		tag = " [CHẮN ĐAN LÔI +1 viên!]"

	return {
		"ok": true,
		"msg": "RA LÒ THÀNH CÔNG: %s x%d%s (+%d Linh Hồn)" % [out_name, final_cnt, tag, soul_gain]
	}


static func craft_recipe(recipe: Dictionary) -> Dictionary:
	var check: Dictionary = can_craft(recipe)
	if not bool(check.get("ok", false)):
		return { "ok": false, "msg": str(check.get("reason", "Không đủ nguyên liệu!")) }
	consume_ingredients(recipe)
	var chance: float = get_success_chance(recipe)
	var roll: float = randf()
	if roll <= chance:
		var q_tier: int = 2 if randf() < 0.22 else 1
		return finish_minigame_craft(recipe, q_tier, false)
	return finish_minigame_craft(recipe, 0, false)
