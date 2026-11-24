class_name EquipmentSystem
extends RefCounted
## Quản lý toàn bộ logic Hệ thống Trang Bị 10 Ô (ARPG Gear Engine):
## - Roll Phẩm chất ngẫu nhiên (Phàm -> Đế) & Dòng thuộc tính phụ (Random Affixes).
## - Tính chỉ số cộng dồn theo cấp Cường hóa (+0 -> +15) & Kích hoạt Bộ Trang Bị (Set Bonuses).
## - Tính chi phí Cường hóa & Tài nguyên Phân giải (Salvage).

const MAX_ENHANCE_LEVEL: int = 15


static func roll_equipment_instance(template_id: String, forced_rarity: String = "") -> Dictionary:
	var tdef: Dictionary = GameDatabase.get_equipment_template(template_id)
	if tdef.is_empty():
		return {}

	var rarity_id: String = forced_rarity
	if rarity_id == "" or not GameDatabase.equipment_rarities.has(rarity_id):
		rarity_id = _roll_weighted_rarity()

	var rdef: Dictionary = GameDatabase.equipment_rarities.get(rarity_id, {})
	var affix_cnt: int = int(rdef.get("affix_count", 0))
	var r_mult: float = float(rdef.get("stat_mult", 1.0))

	var rolled_affixes: Array = []
	var pool_copy: Array = GameDatabase.equipment_affix_pool.duplicate()
	pool_copy.shuffle()
	for i in range(mini(affix_cnt, pool_copy.size())):
		var af: Dictionary = pool_copy[i]
		var mn: int = int(af.get("min", 1))
		var mx: int = int(af.get("max", 5))
		var val: int = maxi(1, int(round(float(randi_range(mn, mx)) * (0.75 + r_mult * 0.25))))
		rolled_affixes.append({
			"stat": str(af.get("stat", "atk")),
			"label": str(af.get("label", "")),
			"unit": str(af.get("unit", "")),
			"value": val
		})

	var uid: String = "eq_%d_%d" % [Time.get_ticks_usec(), randi_range(1000, 9999)]
	return {
		"uid": uid,
		"template_id": template_id,
		"rarity": rarity_id,
		"enhance": 0,
		"affixes": rolled_affixes
	}


static func _roll_weighted_rarity() -> String:
	var total_w: int = 0
	for k in GameDatabase.equipment_rarities.keys():
		var rd: Dictionary = GameDatabase.equipment_rarities[k]
		total_w += int(rd.get("weight", 1))
	var pick: int = randi_range(1, maxi(1, total_w))
	var acc: int = 0
	for k in GameDatabase.equipment_rarities.keys():
		var rd: Dictionary = GameDatabase.equipment_rarities[k]
		acc += int(rd.get("weight", 1))
		if pick <= acc:
			return str(k)
	return "pham"


static func get_rarity_color(rarity_id: String) -> Color:
	var rd: Dictionary = GameDatabase.equipment_rarities.get(rarity_id, {})
	return Color(str(rd.get("color_hex", "#E0E1DD")))


static func get_rarity_name(rarity_id: String) -> String:
	var rd: Dictionary = GameDatabase.equipment_rarities.get(rarity_id, {})
	return str(rd.get("name", "Phàm Phẩm"))


static func get_item_display_name(inst: Dictionary) -> String:
	var tdef: Dictionary = GameDatabase.get_equipment_template(str(inst.get("template_id", "")))
	var base_name: String = str(tdef.get("name", "Trang Bị"))
	var enh: int = int(inst.get("enhance", 0))
	var rname: String = get_rarity_name(str(inst.get("rarity", "pham")))
	if enh > 0:
		return "[%s] %s +%d" % [rname, base_name, enh]
	return "[%s] %s" % [rname, base_name]


static func compute_item_stats(inst: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	if inst.is_empty():
		return out
	var tdef: Dictionary = GameDatabase.get_equipment_template(str(inst.get("template_id", "")))
	var rdef: Dictionary = GameDatabase.equipment_rarities.get(str(inst.get("rarity", "pham")), {})
	var r_mult: float = float(rdef.get("stat_mult", 1.0))
	var enh_mult: float = 1.0 + float(int(inst.get("enhance", 0))) * 0.12

	var base_stats: Dictionary = tdef.get("base_stats", {})
	for st_key in base_stats.keys():
		var k_str: String = str(st_key)
		var scaled_val: float = float(base_stats[st_key]) * r_mult * enh_mult
		out[k_str] = float(out.get(k_str, 0.0)) + scaled_val

	var affixes: Array = inst.get("affixes", [])
	for af in affixes:
		if af is Dictionary:
			var ak: String = str(af.get("stat", ""))
			out[ak] = float(out.get(ak, 0.0)) + float(af.get("value", 0.0))
	return out


static func compute_total_bonuses(equipped_slots: Dictionary) -> Dictionary:
	var totals: Dictionary = {
		"hp": 0.0, "qi": 0.0, "atk": 0.0, "def": 0.0, "spd": 0.0, "soul": 0.0,
		"crit_chance": 0.0, "lifesteal": 0.0, "exp_bonus": 0.0,
		"cooldown_red": 0.0, "flame_dmg": 0.0, "alchemy_bonus": 0.0, "loot_magnet": 0.0
	}
	var set_counts: Dictionary = {}

	for slot_id in equipped_slots.keys():
		var inst = equipped_slots[slot_id]
		if not (inst is Dictionary) or inst.is_empty():
			continue
		var st: Dictionary = compute_item_stats(inst)
		for k in st.keys():
			totals[k] = float(totals.get(k, 0.0)) + float(st[k])

		var tdef: Dictionary = GameDatabase.get_equipment_template(str(inst.get("template_id", "")))
		var sid: String = str(tdef.get("set_id", ""))
		if sid != "":
			set_counts[sid] = int(set_counts.get(sid, 0)) + 1

	# Cộng thưởng kích hoạt Bộ Trang Bị (Set Bonuses)
	var active_set_lines: Array = []
	for sid in set_counts.keys():
		var cnt: int = int(set_counts[sid])
		var sdef: Dictionary = GameDatabase.equipment_sets.get(str(sid), {})
		var bonuses: Array = sdef.get("bonuses", [])
		for b in bonuses:
			if b is Dictionary and cnt >= int(b.get("pieces", 99)):
				active_set_lines.append("%s (%d món): %s" % [str(sdef.get("name", "")), int(b.get("pieces", 2)), str(b.get("desc", ""))])
				var b_stats: Dictionary = b.get("stats", {})
				for bk in b_stats.keys():
					totals[bk] = float(totals.get(bk, 0.0)) + float(b_stats[bk])

	totals["_active_sets"] = active_set_lines
	return totals


static func format_stats_line(inst: Dictionary) -> String:
	var st: Dictionary = compute_item_stats(inst)
	var labels: Dictionary = {
		"hp": ["HP", ""], "qi": ["QI", ""], "atk": ["ATK", ""], "def": ["DEF", ""],
		"spd": ["SPD", ""], "soul": ["SOUL", ""], "crit_chance": ["Chí mạng", "%"],
		"lifesteal": ["Hút máu", "%"], "exp_bonus": ["EXP", "%"], "cooldown_red": ["Giảm CD", "%"],
		"flame_dmg": ["Sát thương Hỏa", "%"], "alchemy_bonus": ["Luyện Đan", "%"], "loot_magnet": ["Hút đồ", "px"]
	}
	var parts: Array = []
	for k in st.keys():
		var val: int = int(round(float(st[k])))
		if val <= 0:
			continue
		var meta: Array = labels.get(str(k), [str(k), ""])
		parts.append("+%d%s %s" % [val, str(meta[1]), str(meta[0])])
	return ", ".join(parts)


static func get_enhance_cost(inst: Dictionary) -> Dictionary:
	var enh: int = int(inst.get("enhance", 0))
	return {
		"gold": 40 + enh * 35,
		"stones": 1 + int(enh / 2)
	}


static func get_salvage_yield(inst: Dictionary) -> Dictionary:
	var rdef: Dictionary = GameDatabase.equipment_rarities.get(str(inst.get("rarity", "pham")), {})
	var enh: int = int(inst.get("enhance", 0))
	return {
		"gold": int(rdef.get("salvage_gold", 15)) + enh * 20,
		"stones": int(rdef.get("salvage_stones", 1)) + enh
	}
