class_name PlayerGearCoreManager
extends RefCounted
## Quản Lý Trang Bị 10 Ô, Biến Thể Vũ Khí & Khảm Ma Hạch 3 Rãnh (Tách mô-đun từ player_data.gd — v1.1.0).


static func add_gear_to_bag(pd, inst: Dictionary) -> void:
	if inst.is_empty():
		return
	pd.gear_bag.append(inst)
	EventBus.equipment_changed.emit()


static func equip_gear_from_bag(pd, uid: String) -> String:
	var found_idx: int = -1
	for i in range(pd.gear_bag.size()):
		if str(pd.gear_bag[i].get("uid", "")) == uid:
			found_idx = i
			break
	if found_idx == -1:
		return "Không tìm thấy trang bị!"
	var inst: Dictionary = pd.gear_bag[found_idx]
	var tdef: Dictionary = GameDatabase.get_equipment_template(str(inst.get("template_id", "")))
	var slot_id: String = str(tdef.get("slot", "weapon"))

	pd.gear_bag.remove_at(found_idx)
	var prev = pd.equipped_gear.get(slot_id, {})
	if prev is Dictionary and not prev.is_empty():
		pd.gear_bag.append(prev)
	pd.equipped_gear[slot_id] = inst

	if not pd.has_huyen_trong_xich_equipped():
		pd.is_ruler_sealed = false
	pd._rebuild_gear_cache()
	pd.recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return "Đã trang bị: %s!" % EquipmentSystem.get_item_display_name(inst)


static func unequip_slot(pd, slot_id: String) -> String:
	var prev = pd.equipped_gear.get(slot_id, {})
	if not (prev is Dictionary) or prev.is_empty():
		return ""
	pd.equipped_gear[slot_id] = {}
	pd.gear_bag.append(prev)
	if not pd.has_huyen_trong_xich_equipped():
		pd.is_ruler_sealed = false
	pd._rebuild_gear_cache()
	pd.recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return "Đã tháo: %s vào Nạp Giới." % EquipmentSystem.get_item_display_name(prev)


static func enhance_gear_by_uid(pd, uid: String) -> Dictionary:
	var target: Dictionary = find_gear_ref(pd, uid)
	if target.is_empty():
		return { "ok": false, "msg": "Không tìm thấy trang bị!" }
	var cur_enh: int = int(target.get("enhance", 0))
	if cur_enh >= EquipmentSystem.MAX_ENHANCE_LEVEL:
		return { "ok": false, "msg": "Trang bị đã đạt cực hạn +%d!" % EquipmentSystem.MAX_ENHANCE_LEVEL }
	var cost: Dictionary = EquipmentSystem.get_enhance_cost(target)
	var c_gold: int = int(cost.get("gold", 50))
	var c_stones: int = int(cost.get("stones", 1))
	if pd.gold < c_gold or pd.enhance_stones < c_stones:
		return { "ok": false, "msg": "Cần %d Kim Tệ & %d Đá Cường Hóa! (Hiện có: %d Kim Tệ, %d Đá)" % [c_gold, c_stones, pd.gold, pd.enhance_stones] }
	pd.gold -= c_gold
	pd.enhance_stones -= c_stones
	target["enhance"] = cur_enh + 1
	pd._rebuild_gear_cache()
	pd.recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("level_up")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return { "ok": true, "msg": "CƯỜNG HÓA THÀNH CÔNG: %s (+12%% chỉ số gốc)!" % EquipmentSystem.get_item_display_name(target) }


static func salvage_gear_by_uid(pd, uid: String) -> String:
	for i in range(pd.gear_bag.size()):
		if str(pd.gear_bag[i].get("uid", "")) == uid:
			var inst: Dictionary = pd.gear_bag[i]
			var y: Dictionary = EquipmentSystem.get_salvage_yield(inst)
			pd.gold += int(y.get("gold", 15))
			pd.enhance_stones += int(y.get("stones", 1))
			pd.gear_bag.remove_at(i)
			EventBus.audio_sfx_requested.emit("loot_pickup")
			EventBus.equipment_changed.emit()
			EventBus.stats_changed.emit()
			return "Đã phân giải %s -> +%d Kim Tệ, +%d Đá Cường Hóa!" % [
				EquipmentSystem.get_item_display_name(inst), int(y.get("gold", 15)), int(y.get("stones", 1))
			]
	return "Chỉ có thể phân giải đồ trong túi."


static func salvage_low_rarity_gear(pd) -> String:
	var count_s: int = 0
	var total_g: int = 0
	var total_st: int = 0
	var kept: Array = []
	for item in pd.gear_bag:
		var rid: String = str(item.get("rarity", "pham"))
		if (rid == "pham" or rid == "linh") and int(item.get("enhance", 0)) == 0:
			var y: Dictionary = EquipmentSystem.get_salvage_yield(item)
			total_g += int(y.get("gold", 15))
			total_st += int(y.get("stones", 1))
			count_s += 1
		else:
			kept.append(item)
	if count_s == 0:
		return "Không có đồ Phàm/Linh (+0) nào trong túi để phân giải."
	pd.gear_bag = kept
	pd.gold += total_g
	pd.enhance_stones += total_st
	EventBus.audio_sfx_requested.emit("loot_pickup")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return "Đã phân giải %d món Phàm/Linh -> +%d Kim Tệ, +%d Đá Cường Hóa!" % [count_s, total_g, total_st]


static func find_gear_ref(pd, uid: String) -> Dictionary:
	for sid in pd.equipped_gear.keys():
		var eq = pd.equipped_gear[sid]
		if eq is Dictionary and str(eq.get("uid", "")) == uid:
			return eq
	for item in pd.gear_bag:
		if item is Dictionary and str(item.get("uid", "")) == uid:
			return item
	return {}


static func get_core_socket_def(core_id: String) -> Dictionary:
	const DEFS: Dictionary = {
		"core_hoa_1": { "name": "Hỏa Ma Hạch (Cấp 1)", "atk": 14.0, "burn_dps": 6.0, "color": Color("#FF7B00"), "desc": "+14 ATK · +6 Thiêu Đốt/s" },
		"core_moc_2": { "name": "Mộc Ma Hạch (Cấp 2)", "hp": 120.0, "hp_regen": 3.0, "color": Color("#2EC4B6"), "desc": "+120 HP · Hồi +3 HP/s" },
		"core_hoa_3": { "name": "Viêm Xà Ma Hạch (Cấp 3)", "atk": 32.0, "crit_pct": 8.0, "burn_dps": 16.0, "color": Color("#FF4D6D"), "desc": "+32 ATK · +8% Crit · +16 Thiêu Đốt/s" },
		"core_phong_4": { "name": "Phong Ma Hạch (Cấp 4)", "spd": 24.0, "crit_pct": 12.0, "cd_red_pct": 8.0, "color": Color("#70D6FF"), "desc": "+24 SPD · +12% Crit · -8% Hồi Chiêu" },
		"core_loi_5": { "name": "Lôi Ma Hạch (Cấp 5)", "atk": 58.0, "crit_pct": 10.0, "poise_pct": 22.0, "color": Color("#E0AAFF"), "desc": "+58 ATK · +10% Crit · +22% Phá Thế Boss" },
		"core_huyet_5": { "name": "Huyết Ma Hạch (Cấp 5)", "atk": 48.0, "hp": 280.0, "lifesteal_pct": 6.0, "color": Color("#EF476F"), "desc": "+48 ATK · +280 HP · +6% Hút Máu" },
		"core_bang_5": { "name": "Băng Ma Hạch Tuyết Ma (Cấp 5)", "atk": 55.0, "hp": 320.0, "cd_red_pct": 10.0, "color": Color("#72EFDD"), "desc": "+55 ATK · +320 HP · -10% Hồi Chiêu" },
		"core_doc_6": { "name": "Vạn Hạt Độc Hạch (Cấp 6)", "atk": 75.0, "hp": 420.0, "crit_pct": 10.0, "burn_dps": 28.0, "color": Color("#70E000"), "desc": "+75 ATK · +420 HP · +10% Crit · +28 Độc/Hỏa Thiêu Đốt/s" },
		"core_loi_7": { "name": "Lôi Hoàng Ma Hạch (Cấp 7)", "atk": 105.0, "hp": 580.0, "crit_pct": 14.0, "cd_red_pct": 14.0, "color": Color("#C77DFF"), "desc": "+105 ATK · +580 HP · +14% Crit · -14% Hồi Chiêu" },
		"core_tinh_7": { "name": "Tinh Thần Cổ Long Hạch (Cấp 7)", "atk": 120.0, "hp": 720.0, "soul": 80.0, "flame_dmg_pct": 35.0, "color": Color("#9D4EDD"), "desc": "+120 ATK · +720 HP · +80 SOUL · +35% Sát Thương Dị Hỏa" },
		"core_nang_luong_8": { "name": "Năng Lượng Hạch Cấp 8 (Đấu Tôn Thiên Mộ)", "atk": 165.0, "hp": 960.0, "soul": 120.0, "crit_pct": 16.0, "color": Color("#4CC9F0"), "desc": "+165 ATK · +960 HP · +120 SOUL · +16% Crit (Hoặc ngưng tụ Cửu Chuyển [B])" },
		"core_nang_luong_9": { "name": "Năng Lượng Hạch Cấp 9 (Bán Thánh Kim Sắc)", "atk": 230.0, "hp": 1400.0, "soul": 180.0, "flame_dmg_pct": 45.0, "poise_pct": 35.0, "color": Color("#FFD166"), "desc": "+230 ATK · +1400 HP · +180 SOUL · +45% Dị Hỏa · +35% Phá Thế" },
		"core_kim_loi_9": { "name": "Cửu Huyền Kim Lôi Hạch Cấp 9 (Thánh Hạch)", "atk": 420.0, "hp": 3200.0, "soul": 280.0, "flame_dmg_pct": 68.0, "poise_pct": 48.0, "crit_pct": 20.0, "color": Color("#FBBF24"), "desc": "+420 ATK · +3200 HP · +280 SOUL · +68% Dị Hỏa · +20% Crit" },
		"core_de_viem_10": { "name": "Đế Viêm Thần Hạch Cấp 10 (Đấu Đế Hạch)", "atk": 950.0, "hp": 7200.0, "soul": 520.0, "flame_dmg_pct": 95.0, "poise_pct": 65.0, "crit_pct": 25.0, "color": Color("#00F5D4"), "desc": "+950 ATK · +7200 HP · +520 SOUL · +95% Dị Hỏa · +25% Crit" }
	}
	if not DEFS.has(core_id):
		return {}
	var d: Dictionary = (DEFS[core_id] as Dictionary).duplicate()
	d["id"] = core_id
	return d


static func get_core_socket_totals(pd) -> Dictionary:
	var totals: Dictionary = {
		"atk": 0.0, "hp": 0.0, "spd": 0.0, "crit_pct": 0.0,
		"burn_dps": 0.0, "hp_regen": 0.0, "cd_red_pct": 0.0,
		"poise_pct": 0.0, "lifesteal_pct": 0.0,
		"soul": 0.0, "flame_dmg_pct": 0.0
	}
	for cid in pd.weapon_core_sockets:
		var cid_s: String = str(cid)
		if cid_s == "":
			continue
		var cdef: Dictionary = get_core_socket_def(cid_s)
		for k in totals.keys():
			totals[k] = float(totals[k]) + float(cdef.get(k, 0.0))
	return totals


static func socket_monster_core(pd, slot_idx: int, core_id: String) -> Dictionary:
	if slot_idx < 0 or slot_idx >= 3:
		return { "ok": false, "msg": "Rãnh khảm không hợp lệ!" }
	var cdef: Dictionary = get_core_socket_def(core_id)
	if cdef.is_empty():
		return { "ok": false, "msg": "Vật phẩm này không thể khảm lên vũ khí!" }
	if pd.get_item_count(core_id) <= 0:
		return { "ok": false, "msg": "Bạn không có [%s] trong Nạp Giới!" % str(cdef["name"]) }
	var prev: String = str(pd.weapon_core_sockets[slot_idx])
	if prev != "":
		pd.add_item(prev, 1)
	pd.remove_item(core_id, 1)
	pd.weapon_core_sockets[slot_idx] = core_id
	pd.recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("level_up")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return { "ok": true, "msg": "Đã khảm [%s] vào Rãnh #%d (%s)!" % [str(cdef["name"]), slot_idx + 1, str(cdef["desc"])] }


static func unsocket_monster_core(pd, slot_idx: int) -> Dictionary:
	if slot_idx < 0 or slot_idx >= 3:
		return { "ok": false, "msg": "Rãnh khảm không hợp lệ!" }
	var prev: String = str(pd.weapon_core_sockets[slot_idx])
	if prev == "":
		return { "ok": false, "msg": "Rãnh #%d đang trống!" % (slot_idx + 1) }
	pd.weapon_core_sockets[slot_idx] = ""
	pd.add_item(prev, 1)
	pd.recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return { "ok": true, "msg": "Đã tháo [%s] khỏi Rãnh #%d về lại Nạp Giới!" % [str(get_core_socket_def(prev).get("name", prev)), slot_idx + 1] }
