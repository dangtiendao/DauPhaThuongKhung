class_name AlchemySystem
extends RefCounted
## Xử lý logic Lò Luyện Đan (hỗ trợ cả Khai Lò nhanh & Mini-game Khống Hỏa + Đón Đan Lôi!):
## - Kiểm tra nguyên liệu trong Nạp Giới, Linh Hồn Lực (SOUL), thưởng Dị Hỏa & Dược Đỉnh.

static func get_required_soul_realm_for_tier(tier: int) -> Dictionary:
	for entry in GameDatabase.soul_realms_list:
		if entry is Dictionary and int(entry.get("alchemy_max_tier", 6)) >= tier:
			return entry
	return { "id": "de_canh", "name": "Đế Cảnh Linh Hồn", "min_soul": 3500, "alchemy_max_tier": 10 }


static func can_craft(recipe: Dictionary) -> Dictionary:
	var recipe_tier: int = int(recipe.get("tier", 1))
	var sr: Dictionary = PlayerData.get_soul_realm_info()
	var max_tier: int = int(sr.get("alchemy_max_tier", 6))
	if recipe_tier > max_tier:
		var req_sr: Dictionary = get_required_soul_realm_for_tier(recipe_tier)
		var cur_sr_name: String = str(sr.get("name", "Phàm Cảnh Linh Hồn"))
		var req_sr_name: String = str(req_sr.get("name", "Linh Cảnh Linh Hồn"))
		var req_min_soul: int = int(req_sr.get("min_soul", 250))
		return {
			"ok": false,
			"reason": "Phẩm %d vượt giới hạn %s (tối đa Phẩm %d) — cần %s (%d+ SOUL)" % [
				recipe_tier, cur_sr_name, max_tier, req_sr_name, req_min_soul
			]
		}

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


static func get_total_alchemy_bonus(recipe: Dictionary) -> Dictionary:
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var flame_bonus: float = float(f_def.get("alchemy_bonus_pct", 0.0)) / 100.0 if not f_def.is_empty() else 0.0
	var gear_bonus: float = PlayerData.get_alchemy_equipment_bonus()
	var aff_bonus: float = PlayerData.get_affection_bonus("alchemy_bonus") / 100.0
	var soul_diff: int = max(0, PlayerData.get_soul() - int(recipe.get("req_soul", 5)))
	var soul_bonus: float = minf(0.35, float(soul_diff) * 0.005)
	return {
		"flame": flame_bonus,
		"gear": gear_bonus,
		"affection": aff_bonus,
		"soul": soul_bonus,
		"total": flame_bonus + gear_bonus + aff_bonus + soul_bonus
	}


static func get_success_chance(recipe: Dictionary) -> float:
	var base_rate: float = float(recipe.get("base_success_rate", 0.80))
	var b: Dictionary = get_total_alchemy_bonus(recipe)
	return clampf(base_rate + float(b.get("total", 0.0)), 0.15, 1.0)


static func get_minigame_modifiers(recipe: Dictionary) -> Dictionary:
	var b: Dictionary = get_total_alchemy_bonus(recipe)
	var total_b: float = float(b.get("total", 0.0))
	# Dị Hỏa + Dược Đỉnh + Hảo Cảm Tiểu Y Tiên + Linh Hồn mở rộng vùng Đan Tâm, làm dịu tốc độ nguội & kéo dài cửa sổ Chắn Đan Lôi!
	var expand_half: float = clampf(total_b * 18.0, 0.0, 14.0)
	var zone_min: float = clampf(38.0 - expand_half, 24.0, 38.0)
	var zone_max: float = clampf(66.0 + expand_half, 66.0, 80.0)
	var cool_mult: float = clampf(1.0 - total_b * 0.34, 0.58, 1.0)
	var lightning_extra: float = clampf(total_b * 0.85, 0.0, 0.85)
	var quality_shift: float = clampf(total_b * 0.14, 0.0, 0.16)
	return {
		"zone_min": zone_min,
		"zone_max": zone_max,
		"cool_mult": cool_mult,
		"lightning_extra_sec": lightning_extra,
		"perfect_ratio_req": maxf(0.46, 0.62 - quality_shift),
		"pass_ratio_req": maxf(0.18, 0.28 - quality_shift * 0.5),
		"flame_pct": int(round(float(b.get("flame", 0.0)) * 100.0)),
		"gear_pct": int(round(float(b.get("gear", 0.0)) * 100.0)),
		"aff_pct": int(round(float(b.get("affection", 0.0)) * 100.0)),
		"soul_pct": int(round(float(b.get("soul", 0.0)) * 100.0)),
		"total_pct": int(round(total_b * 100.0))
	}


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
