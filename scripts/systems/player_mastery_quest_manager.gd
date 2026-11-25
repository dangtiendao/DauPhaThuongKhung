class_name PlayerMasteryQuestManager
extends RefCounted
## Quản Lý Nhiệm Vụ Chính Tuyến Data-Driven, Độ Thông Thạo Đấu Kỹ, Tâm Ma Luyện Cảnh & Tháp Thiên Phần (Tách từ player_data.gd — v1.1.0).


# =========================================================
# HỆ THỐNG NHIỆM VỤ CHÍNH TUYẾN DATA-DRIVEN
# =========================================================
static func get_current_quest(pd) -> Dictionary:
	if pd.all_quests_done or GameDatabase.all_quests.is_empty():
		return {}
	if pd.active_quest_id != "":
		var idx_by_id: int = GameDatabase.get_quest_index(pd.active_quest_id)
		if idx_by_id >= 0:
			pd.active_quest_idx = idx_by_id
	if pd.active_quest_idx < 0 or pd.active_quest_idx >= GameDatabase.all_quests.size():
		return {}
	var q = GameDatabase.all_quests[pd.active_quest_idx]
	if q is Dictionary:
		pd.active_quest_id = str(q.get("id", ""))
		return q
	return {}


static func is_current_quest_auto_satisfied(pd, q: Dictionary) -> bool:
	if q.is_empty():
		return false
	var q_type: String = str(q.get("type", ""))
	if q_type == "story_flag":
		return pd.has_flag(str(q.get("flag_name", "")))
	elif q_type == "all_flags":
		var flist: Array = q.get("flag_names", [])
		if flist.is_empty():
			return false
		for f in flist:
			if not pd.has_flag(str(f)):
				return false
		return true
	elif q_type == "reach_realm":
		return pd.realm_index >= int(q.get("target_realm_index", 2))
	elif q_type == "craft_pill":
		var allow_inv: bool = bool(q.get("auto_pass_if_owned", false))
		return allow_inv and pd.get_item_count(str(q.get("target_id", ""))) > 0
	return false


static func check_quest_flag(pd, flag_name: String) -> void:
	var q: Dictionary = get_current_quest(pd)
	if q.is_empty():
		return
	var q_type: String = str(q.get("type", ""))
	if q_type == "story_flag" and str(q.get("flag_name", "")) == flag_name:
		advance_quest_progress(pd, 1)
	elif q_type == "all_flags":
		if is_current_quest_auto_satisfied(pd, q):
			advance_quest_progress(pd, 1)


static func on_enemy_killed(pd, enemy_id: String, is_boss: bool) -> void:
	pd.enemies_killed_total += 1
	pd.enemy_kill_counts[enemy_id] = int(pd.enemy_kill_counts.get(enemy_id, 0)) + 1
	if is_boss and pd.has_ma_doc_ban() and pd.ma_doc_ban_stacks < 20:
		pd.ma_doc_ban_stacks += 1
		EventBus.stats_changed.emit()
		EventBus.banter_triggered.emit("☠ Ma Độc Ban cộng hưởng sát khí Boss -> Tích lũy %d/20 (+%d%% ATK)!" % [pd.ma_doc_ban_stacks, pd.ma_doc_ban_stacks])
	if enemy_id == "tieu_ninh_boss":
		pd.set_story_flag("unlocked_bat_cuc_bang")
	elif enemy_id == "lieu_tich_boss":
		pd.set_story_flag("killed_lieu_tich")
	elif enemy_id == "gia_liet_ao_boss":
		pd.set_story_flag("ch01_completed")
	elif enemy_id == "tieu_tu_tinh_su_boss":
		pd.set_story_flag("killed_tieu_su_vuong")
	elif enemy_id == "muc_luc_boss":
		pd.set_story_flag("killed_muc_luc")
	elif enemy_id == "muc_xa_boss":
		pd.set_story_flag("killed_muc_xa")
	elif enemy_id == "hai_ba_dong_boss":
		pd.set_story_flag("beat_hai_ba_dong")
	elif enemy_id == "hoa_linh_xa_boss":
		pd.set_story_flag("killed_hoa_linh_xa")
	elif enemy_id == "mac_ba_tu_boss":
		pd.set_story_flag("killed_mac_ba_tu")
		if pd.has_flag("killed_co_ha"):
			pd.set_story_flag("beat_co_ha_mac_ba_tu")
	elif enemy_id == "co_ha_boss":
		pd.set_story_flag("killed_co_ha")
		if pd.has_flag("killed_mac_ba_tu"):
			pd.set_story_flag("beat_co_ha_mac_ba_tu")

	# Data-Driven enemy kill rules (Ch04 -> Ch11)
	var k_rule: Dictionary = GameDatabase.get_enemy_kill_rule(enemy_id)
	if not k_rule.is_empty():
		var sf: String = str(k_rule.get("set_flag", ""))
		if sf != "":
			pd.set_story_flag(sf)
		for f in k_rule.get("set_flags", []):
			pd.set_story_flag(str(f))
		for combo in k_rule.get("combo_flags", []):
			if combo is Dictionary:
				var all_ok: bool = true
				for rf in combo.get("require_flags", []):
					if not pd.has_flag(str(rf)):
						all_ok = false
						break
				if all_ok:
					var gf: String = str(combo.get("grant_flag", ""))
					if gf != "":
						pd.set_story_flag(gf)

	var q: Dictionary = get_current_quest(pd)
	if q.is_empty():
		return
	if str(q.get("type", "")) == "kill_any" and enemy_id == str(q.get("target_id", "")):
		advance_quest_progress(pd, 1)


static func notify_pill_crafted(pd, pill_id: String) -> void:
	if pill_id == "pill_tam_van_thanh_linh" and pd.has_flag("ch04_beat_viem_loi"):
		pd.set_story_flag("ch04_dan_hoi_champion")
	var q: Dictionary = get_current_quest(pd)
	if q.is_empty():
		return
	if str(q.get("type", "")) == "craft_pill" and pill_id == str(q.get("target_id", "")):
		advance_quest_progress(pd, 1)


static func check_quest_realm(pd) -> void:
	var q: Dictionary = get_current_quest(pd)
	if q.is_empty():
		return
	if str(q.get("type", "")) == "reach_realm":
		if pd.realm_index >= int(q.get("target_realm_index", 2)):
			advance_quest_progress(pd, 1)


static func advance_quest_progress(pd, delta_cnt: int) -> void:
	var q: Dictionary = get_current_quest(pd)
	if q.is_empty():
		return
	pd.quest_progress += delta_cnt
	var goal: int = int(q.get("target_count", 1))
	if pd.quest_progress >= goal:
		var done_id: String = str(q.get("id", ""))
		if done_id != "":
			pd.completed_quest_ids[done_id] = true
		var rew_exp: int = int(q.get("reward_exp", 50))
		pd.add_exp(rew_exp)
		pd.gold += int(q.get("reward_gold", 0))
		var rew_items: Dictionary = q.get("reward_items", {})
		for k in rew_items.keys():
			pd.add_item(str(k), int(rew_items[k]))
		var comp_eff = q.get("on_complete_effect", {})
		if comp_eff is Dictionary and not comp_eff.is_empty():
			pd.execute_story_effect(comp_eff)
		pd.active_quest_idx += 1
		pd.quest_progress = 0
		if pd.active_quest_idx >= GameDatabase.all_quests.size():
			pd.all_quests_done = true
			pd.active_quest_id = ""
			EventBus.banter_triggered.emit("👑 CHÚC MỪNG ĐẠI KẾT CỤC! Bạn đã chinh phục trọn vẹn %d/96 mốc cốt truyện Quyển I–IV (Chương 01 – 11: Ô Thản Thành -> Cổ Đế Động Phủ -> Song Đế Chi Chiến -> Viêm Đế Đại Hôn & Đại Thiên Thế Giới)!" % GameDatabase.all_quests.size())
		else:
			var next_q: Dictionary = GameDatabase.all_quests[pd.active_quest_idx]
			pd.active_quest_id = str(next_q.get("id", ""))
			EventBus.banter_triggered.emit(str(next_q.get("intro_log", "")))
			if is_current_quest_auto_satisfied(pd, next_q):
				advance_quest_progress(pd, 1)
		pd.trigger_auto_save("hoàn thành nhiệm vụ")
	EventBus.quest_updated.emit()


# =========================================================
# ĐỘ THÔNG THẠO ĐẤU KỸ (MASTERY) · TÂM MA LUYỆN CẢNH · THÁP THIÊN PHẦN
# =========================================================
static func get_skill_mastery_info(pd, skill_id: String) -> Dictionary:
	var uses: int = int(pd.skill_mastery_uses.get(skill_id, 0))
	if uses >= 40:
		return {
			"tier": 3, "tier_name": "Đỉnh Phong", "uses": uses, "next_uses": 40,
			"dmg_mult": 1.40, "cd_mult": 0.80, "radius_mult": 1.22, "color": Color("#FFD166")
		}
	elif uses >= 20:
		return {
			"tier": 2, "tier_name": "Đại Thành", "uses": uses, "next_uses": 40,
			"dmg_mult": 1.25, "cd_mult": 0.88, "radius_mult": 1.14, "color": Color("#C77DFF")
		}
	elif uses >= 8:
		return {
			"tier": 1, "tier_name": "Tiểu Thành", "uses": uses, "next_uses": 20,
			"dmg_mult": 1.12, "cd_mult": 0.94, "radius_mult": 1.06, "color": Color("#70D6FF")
		}
	return {
		"tier": 0, "tier_name": "Sơ Khuy", "uses": uses, "next_uses": 8,
		"dmg_mult": 1.00, "cd_mult": 1.00, "radius_mult": 1.00, "color": Color("#ADB5BD")
	}


static func record_skill_use(pd, skill_id: String, world_pos: Vector2 = Vector2.ZERO) -> Dictionary:
	if skill_id == "":
		return get_skill_mastery_info(pd, "")
	var old_tier: int = int(get_skill_mastery_info(pd, skill_id).get("tier", 0))
	pd.skill_mastery_uses[skill_id] = int(pd.skill_mastery_uses.get(skill_id, 0)) + 1
	var info: Dictionary = get_skill_mastery_info(pd, skill_id)
	var new_tier: int = int(info.get("tier", 0))
	if new_tier > old_tier:
		var sdef: Dictionary = GameDatabase.get_skill_def(skill_id)
		var sname: String = str(sdef.get("name", skill_id))
		EventBus.audio_sfx_requested.emit("level_up")
		if world_pos != Vector2.ZERO:
			EventBus.floating_text_requested.emit(world_pos + Vector2(0, -96), "THÔNG THẠO [%s] -> %s!" % [sname, str(info["tier_name"]).to_upper()], info["color"] as Color)
		EventBus.banter_triggered.emit("Đấu Kỹ [%s] đột phá Thông Thạo bậc [%s]: +%d%% Sát thương · -%d%% Hồi chiêu · +%d%% Tầm VFX!" % [
			sname, str(info["tier_name"]),
			int(round((float(info["dmg_mult"]) - 1.0) * 100.0)),
			int(round((1.0 - float(info["cd_mult"])) * 100.0)),
			int(round((float(info["radius_mult"]) - 1.0) * 100.0))
		])
		EventBus.skills_updated.emit()
	return info


static func get_boss_rush_record(pd, boss_id: String, diff_key: String) -> Dictionary:
	var k: String = "%s|%s" % [boss_id, diff_key]
	var rec = pd.boss_rush_records.get(k, {})
	return rec as Dictionary if rec is Dictionary else {}


static func record_boss_rush_clear(pd, boss_id: String, diff_key: String, elapsed_sec: float, dmg_taken: float) -> Dictionary:
	var grade_order: Dictionary = { "C": 1, "B": 2, "A": 3, "S": 4, "SS": 5, "SSS": 6 }
	var hp_ref: float = maxf(100.0, pd.get_max_hp())
	var dmg_ratio: float = dmg_taken / hp_ref
	var grade: String = "B"
	if elapsed_sec <= 22.0 and dmg_ratio <= 0.15:
		grade = "SSS"
	elif elapsed_sec <= 36.0 and dmg_ratio <= 0.35:
		grade = "SS"
	elif elapsed_sec <= 52.0 and dmg_ratio <= 0.65:
		grade = "S"
	elif elapsed_sec <= 75.0:
		grade = "A"
	elif elapsed_sec <= 105.0:
		grade = "B"
	else:
		grade = "C"

	var diff_mult: float = 1.0 if diff_key == "normal" else (1.75 if diff_key == "nightmare" else 2.6)
	var grade_bonus: float = float(grade_order.get(grade, 1))
	var stones_rew: int = maxi(1, int(round(grade_bonus * diff_mult)))
	var gold_rew: int = int(round((28.0 + grade_bonus * 16.0) * diff_mult))
	pd.enhance_stones += stones_rew
	pd.gold += gold_rew

	var k: String = "%s|%s" % [boss_id, diff_key]
	var prev: Dictionary = get_boss_rush_record(pd, boss_id, diff_key)
	var prev_g: String = str(prev.get("best_grade", ""))
	var best_g: String = grade if int(grade_order.get(grade, 0)) >= int(grade_order.get(prev_g, 0)) else prev_g
	var prev_t: float = float(prev.get("best_time", 9999.0))
	var best_t: float = minf(prev_t, elapsed_sec)
	pd.boss_rush_records[k] = {
		"best_grade": best_g,
		"best_time": snappedf(best_t, 0.1),
		"clears": int(prev.get("clears", 0)) + 1
	}
	EventBus.stats_changed.emit()
	pd.trigger_auto_save("Tâm Ma Luyện Cảnh", true)
	return {
		"grade": grade,
		"elapsed_sec": elapsed_sec,
		"stones": stones_rew,
		"gold": gold_rew
	}


static func add_tower_buff(pd, stat_key: String, value: float, heal_ratio: float = 0.0) -> void:
	if stat_key != "":
		pd.tower_active_buffs[stat_key] = float(pd.tower_active_buffs.get(stat_key, 0.0)) + value
	pd.recalculate_and_clamp(false)
	if heal_ratio > 0.0:
		pd.current_hp = minf(pd.get_max_hp(), pd.current_hp + pd.get_max_hp() * heal_ratio)
		pd.current_qi = minf(pd.get_max_qi(), pd.current_qi + pd.get_max_qi() * heal_ratio)
	EventBus.stats_changed.emit()


static func record_tower_floor_clear(pd, floor_num: int) -> Dictionary:
	if floor_num > pd.tower_best_floor:
		pd.tower_best_floor = floor_num
	var fe_gain: int = 12 + floor_num * 5
	var stones_gain: int = 1 + int(floor_num / 3)
	var gold_gain: int = 55 + floor_num * 28
	pd.fire_energy += fe_gain
	pd.enhance_stones += stones_gain
	pd.gold += gold_gain
	EventBus.stats_changed.emit()
	pd.trigger_auto_save("Thiên Phần Tháp Tầng %d" % floor_num, true)
	return { "fire_energy": fe_gain, "stones": stones_gain, "gold": gold_gain, "best_floor": pd.tower_best_floor }
