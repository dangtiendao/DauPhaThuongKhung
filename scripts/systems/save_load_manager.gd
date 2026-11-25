class_name SaveLoadManager
extends RefCounted
## Hệ thống Quản lý Lưu / Tải 3 Ô Nạp Giới & Cài Đặt Người Dùng (tách từ PlayerData):
## - Hỗ trợ lưu/tải cài đặt an toàn (merge JSON không ghi đè mất phím tắt / âm lượng / hiển thị).
## - Hỗ trợ lưu/tải 3 ô Nạp Giới, tương thích ngược bản lưu legacy & tự nâng cấp bản lưu cũ khi thêm Chương mới.
## - Cung cấp API serialize/deserialize tách biệt (build_save_payload / apply_loaded_payload / save_to_path / load_from_path) cho kiểm thử tự động.

const SETTINGS_PATH: String = "user://dptk_settings.json"
const LEGACY_SAVE_PATH: String = "user://dptk_save_v1.json"
const MAX_SAVE_SLOTS: int = 3


static func get_save_slot_path(slot_idx: int) -> String:
	var s: int = clampi(slot_idx, 1, MAX_SAVE_SLOTS)
	return "user://dptk_save_slot_%d.json" % s


static func has_any_save() -> bool:
	for s in range(1, MAX_SAVE_SLOTS + 1):
		if FileAccess.file_exists(get_save_slot_path(s)):
			return true
	return FileAccess.file_exists(LEGACY_SAVE_PATH)


static func get_save_slot_summary(slot_idx: int) -> Dictionary:
	var p: String = get_save_slot_path(slot_idx)
	if not FileAccess.file_exists(p):
		if slot_idx == 1 and FileAccess.file_exists(LEGACY_SAVE_PATH):
			p = LEGACY_SAVE_PATH
		else:
			return { "exists": false, "slot": slot_idx, "label": "Ô Lưu %d — (Trống)" % slot_idx }
	var f := FileAccess.open(p, FileAccess.READ)
	if f == null:
		return { "exists": false, "slot": slot_idx, "label": "Ô Lưu %d — (Trống)" % slot_idx }
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return { "exists": false, "slot": slot_idx, "label": "Ô Lưu %d — (Lỗi tệp)" % slot_idx }
	var d: Dictionary = parsed
	var r_title: String = str(d.get("meta_realm", "Đấu Chi Khí"))
	var m_title: String = str(d.get("meta_map", str(d.get("current_map_id", "Tiêu Gia"))))
	var mins: int = int(float(d.get("playtime_sec", 0.0)) / 60.0)
	var saved_at: String = str(d.get("meta_saved_at", ""))
	var ng_cyc: int = int(d.get("ng_plus_cycle", 0))
	var demo_tag: String = "[DEMO] " if bool(d.get("is_demo_mode", false)) else ("[NG+%d] " % ng_cyc if ng_cyc > 0 else "")
	return {
		"exists": true,
		"slot": slot_idx,
		"is_demo": bool(d.get("is_demo_mode", false)),
		"label": "Ô %d: %s%s | %s (%d phút) %s" % [slot_idx, demo_tag, r_title, m_title, mins, saved_at]
	}


static func get_best_continue_slot(pd: Node) -> int:
	var last_slot: int = int(pd.get("last_played_slot"))
	if bool(get_save_slot_summary(last_slot).get("exists", false)):
		return last_slot
	for s in range(1, MAX_SAVE_SLOTS + 1):
		if bool(get_save_slot_summary(s).get("exists", false)):
			return s
	return -1


static func load_user_settings(pd: Node) -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return
	var d: Dictionary = parsed
	pd.auto_save_enabled = bool(d.get("auto_save_enabled", true))
	pd.auto_continue_on_start = bool(d.get("auto_continue_on_start", false))
	pd.last_played_slot = clampi(int(d.get("last_played_slot", 1)), 1, MAX_SAVE_SLOTS)
	# Truyền save_to_disk = false để không ghi đè mất file settings trong lúc đang đọc!
	if d.has("bgm_volume"):
		AudioManager.set_bgm_volume(float(d.get("bgm_volume", 0.65)), false)
	if d.has("sfx_volume"):
		AudioManager.set_sfx_volume(float(d.get("sfx_volume", 0.80)), false)
	if d.has("is_muted"):
		AudioManager.set_muted(bool(d.get("is_muted", false)), false)


static func save_user_settings(pd: Node) -> void:
	var payload: Dictionary = {}
	if FileAccess.file_exists(SETTINGS_PATH):
		var rf := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if rf != null:
			var parsed: Variant = JSON.parse_string(rf.get_as_text())
			if parsed is Dictionary:
				payload = parsed
	payload["auto_save_enabled"] = pd.auto_save_enabled
	payload["auto_continue_on_start"] = pd.auto_continue_on_start
	payload["last_played_slot"] = pd.last_played_slot
	payload["bgm_volume"] = AudioManager.bgm_volume
	payload["sfx_volume"] = AudioManager.sfx_volume
	payload["is_muted"] = AudioManager.is_muted
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(payload, "\t"))


static func build_save_payload(pd: Node) -> Dictionary:
	var m_def: Dictionary = GameDatabase.get_map_def(pd.current_map_id)
	var m_name: String = str(m_def.get("name", pd.current_map_id))
	var dt: Dictionary = Time.get_datetime_dict_from_system()
	var stamp: String = "%02d:%02d %02d/%02d" % [
		int(dt.get("hour", 0)),
		int(dt.get("minute", 0)),
		int(dt.get("day", 1)),
		int(dt.get("month", 1))
	]

	# Ghi nhận tọa độ chính xác hiện tại của Tiêu Viêm để lần sau vào đứng đúng chỗ cũ!
	var tree: SceneTree = pd.get_tree()
	if tree != null:
		var players: Array[Node] = tree.get_nodes_in_group("player")
		if not players.is_empty() and players[0] is Node2D:
			pd.saved_player_pos = (players[0] as Node2D).global_position
			pd.has_saved_player_pos = true

	return {
		"meta_realm": pd.get_realm_display_title(),
		"meta_map": m_name,
		"meta_saved_at": stamp,
		"is_demo_mode": pd.is_demo_mode,
		"has_player_pos": pd.has_saved_player_pos,
		"player_pos_x": pd.saved_player_pos.x,
		"player_pos_y": pd.saved_player_pos.y,
		"playtime_sec": pd.playtime_sec,
		"current_map_id": pd.current_map_id,
		"realm_index": pd.realm_index,
		"stage": pd.stage,
		"nine_turn_level": int(pd.nine_turn_level) if ("nine_turn_level" in pd) else 0,
		"ng_plus_cycle": int(pd.ng_plus_cycle) if ("ng_plus_cycle" in pd) else 0,
		"current_exp": pd.current_exp,
		"bonus_soul": pd.bonus_soul,
		"gold": pd.gold,
		"enhance_stones": pd.enhance_stones,
		"story_flags": pd.story_flags.duplicate(true),
		"opened_chests": pd.opened_chests.duplicate(true),
		"affection": pd.affection.duplicate(true),
		"story_relics": pd.story_relics.duplicate(true),
		"active_title_id": str(pd.active_title_id) if ("active_title_id" in pd) else "",
		"claimed_affection_milestones": pd.claimed_affection_milestones.duplicate(true),
		"enemies_killed_total": pd.enemies_killed_total,
		"enemy_kill_counts": pd.enemy_kill_counts.duplicate(true),
		"skill_mastery_uses": pd.skill_mastery_uses.duplicate(true),
		"boss_rush_records": pd.boss_rush_records.duplicate(true),
		"weapon_core_sockets": pd.weapon_core_sockets.duplicate(true),
		"fire_energy": pd.fire_energy,
		"tower_best_floor": pd.tower_best_floor,
		"pan_gate_state": pd.pan_gate_state.duplicate(true) if ("pan_gate_state" in pd and pd.pan_gate_state is Dictionary) else {},
		"ma_doc_ban_stacks": int(pd.ma_doc_ban_stacks) if ("ma_doc_ban_stacks" in pd) else 0,
		"auction_wins": pd.auction_wins,
		"auction_consigned_total": pd.auction_consigned_total,
		"quick_hp_pill_id": pd.quick_hp_pill_id,
		"quick_qi_pill_id": pd.quick_qi_pill_id,
		"equipped_gear": pd.equipped_gear.duplicate(true),
		"gear_bag": pd.gear_bag.duplicate(true),
		"is_ruler_sealed": pd.is_ruler_sealed,
		"equipped_flame_id": pd.equipped_flame_id,
		"unlocked_flames": pd.unlocked_flames.duplicate(true),
		"lotus_fusion_flames": pd.lotus_fusion_flames.duplicate(true),
		"unlocked_skills": pd.unlocked_skills.duplicate(true),
		"slot_q_skill": pd.slot_q_skill,
		"slot_e_skill": pd.slot_e_skill,
		"slot_r_skill": pd.slot_r_skill,
		"slot_f_skill": pd.slot_f_skill,
		"duoc_lao_assist_unlocked": pd.duoc_lao_assist_unlocked,
		"unlocked_companions": pd.unlocked_companions.duplicate(true),
		"active_companion_id": pd.active_companion_id,
		"inventory": pd.inventory.duplicate(true),
		"active_quest_idx": pd.active_quest_idx,
		"active_quest_id": pd.active_quest_id,
		"completed_quest_ids": pd.completed_quest_ids.duplicate(true),
		"kim_viem_revive_used": pd.kim_viem_revive_used,
		"quest_progress": pd.quest_progress,
		"all_quests_done": pd.all_quests_done
	}


static func apply_loaded_payload(pd: Node, d: Dictionary, persist_settings: bool = true) -> void:
	pd.is_demo_mode = bool(d.get("is_demo_mode", false))
	pd.has_saved_player_pos = bool(d.get("has_player_pos", false))
	pd.saved_player_pos = Vector2(float(d.get("player_pos_x", 0.0)), float(d.get("player_pos_y", 0.0)))
	pd.playtime_sec = float(d.get("playtime_sec", 0.0))
	pd.current_map_id = str(d.get("current_map_id", "ch01_tieu_gia"))
	pd.realm_index = int(d.get("realm_index", 1))
	pd.stage = int(d.get("stage", 3))
	if "nine_turn_level" in pd:
		pd.nine_turn_level = clampi(int(d.get("nine_turn_level", 0)), 0, 9)
	if "ng_plus_cycle" in pd:
		pd.ng_plus_cycle = maxi(0, int(d.get("ng_plus_cycle", 0)))
	pd.current_exp = int(d.get("current_exp", 0))
	pd.bonus_soul = int(d.get("bonus_soul", 0))
	pd.gold = int(d.get("gold", 35))
	pd.enhance_stones = int(d.get("enhance_stones", 0))
	pd.story_flags = d.get("story_flags", {})
	pd.opened_chests = d.get("opened_chests", {})
	if d.has("affection") and d["affection"] is Dictionary:
		pd.affection = d["affection"]
		for ak in ["huan_nhi", "tieu_y_tien", "van_chi", "thanh_lan", "my_do_toa", "tu_nghien", "nha_phi", "nap_lan_yen_nhien"]:
			if not pd.affection.has(ak):
				pd.affection[ak] = 0
	else:
		pd.affection = {
			"huan_nhi": 20, "tieu_y_tien": 0, "van_chi": 0, "thanh_lan": 0,
			"my_do_toa": 0, "tu_nghien": 0, "nha_phi": 0, "nap_lan_yen_nhien": 0
		}
	if d.has("story_relics") and d["story_relics"] is Array:
		pd.story_relics = d["story_relics"]
	else:
		pd.story_relics = []
	if "active_title_id" in pd:
		pd.active_title_id = str(d.get("active_title_id", ""))
	if d.has("claimed_affection_milestones") and d["claimed_affection_milestones"] is Dictionary:
		pd.claimed_affection_milestones = d["claimed_affection_milestones"]
	else:
		pd.claimed_affection_milestones = {}
	pd.enemies_killed_total = int(d.get("enemies_killed_total", 0))
	pd.enemy_kill_counts = d.get("enemy_kill_counts", {}) if (d.get("enemy_kill_counts", {}) is Dictionary) else {}
	pd.skill_mastery_uses = d.get("skill_mastery_uses", {}) if (d.get("skill_mastery_uses", {}) is Dictionary) else {}
	pd.boss_rush_records = d.get("boss_rush_records", {}) if (d.get("boss_rush_records", {}) is Dictionary) else {}
	var loaded_socks = d.get("weapon_core_sockets", ["", "", ""])
	if loaded_socks is Array and loaded_socks.size() == 3:
		pd.weapon_core_sockets = [str(loaded_socks[0]), str(loaded_socks[1]), str(loaded_socks[2])]
	else:
		pd.weapon_core_sockets = ["", "", ""]
	pd.fire_energy = int(d.get("fire_energy", 0))
	pd.tower_best_floor = int(d.get("tower_best_floor", 0))
	var loaded_pg = d.get("pan_gate_state", {})
	if loaded_pg is Dictionary and not loaded_pg.is_empty():
		pd.pan_gate_state = loaded_pg.duplicate(true)
	else:
		pd.pan_gate_state = {}
	if "ma_doc_ban_stacks" in pd:
		pd.ma_doc_ban_stacks = int(d.get("ma_doc_ban_stacks", 0))
	pd.auction_wins = int(d.get("auction_wins", 0))
	pd.auction_consigned_total = int(d.get("auction_consigned_total", 0))
	pd.tower_active_buffs.clear()
	pd.am_duong_buff_timer = 0.0
	pd.quick_hp_pill_id = str(d.get("quick_hp_pill_id", "pill_ngung_huyet_tan"))
	pd.quick_qi_pill_id = str(d.get("quick_qi_pill_id", "pill_hoi_khi_dan"))
	pd.lotus_shield_hp = 0.0
	pd.lotus_dmg_red_timer = 0.0
	pd.lotus_double_herb_timer = 0.0
	pd.player_slow_timer = 0.0
	pd.player_slow_ratio = 0.0
	if d.has("equipped_gear") and d["equipped_gear"] is Dictionary:
		pd.equipped_gear = d["equipped_gear"]
	if d.has("gear_bag") and d["gear_bag"] is Array:
		pd.gear_bag = d["gear_bag"]
	pd.is_ruler_sealed = bool(d.get("is_ruler_sealed", false))
	pd.is_duoc_lao_active = false
	pd.is_flame_buff_active = false
	if "is_nhi_bien_active" in pd:
		pd.is_nhi_bien_active = false
	if "is_tam_bien_active" in pd:
		pd.is_tam_bien_active = false
	if "is_toc_van_active" in pd:
		pd.is_toc_van_active = false
	if "is_kim_khoi_tran_active" in pd:
		pd.is_kim_khoi_tran_active = false
	if "is_tinh_lien_tran_active" in pd:
		pd.is_tinh_lien_tran_active = false
	if "is_de_hon_active" in pd:
		pd.is_de_hon_active = false
	if "huan_nhi_revive_used" in pd:
		pd.huan_nhi_revive_used = false
	if "immortal_revive_cd" in pd:
		pd.immortal_revive_cd = 0.0
	pd.equipped_flame_id = str(d.get("equipped_flame_id", ""))
	pd.unlocked_flames = d.get("unlocked_flames", [])
	pd.lotus_fusion_flames = d.get("lotus_fusion_flames", [])
	pd.unlocked_skills = d.get("unlocked_skills", [])
	pd.slot_q_skill = str(d.get("slot_q_skill", ""))
	pd.slot_e_skill = str(d.get("slot_e_skill", ""))
	pd.slot_r_skill = str(d.get("slot_r_skill", ""))
	pd.slot_f_skill = str(d.get("slot_f_skill", ""))
	for sk_s in [pd.slot_q_skill, pd.slot_e_skill, pd.slot_r_skill, pd.slot_f_skill]:
		if sk_s != "" and not pd.unlocked_skills.has(sk_s):
			pd.unlocked_skills.append(sk_s)
	pd.duoc_lao_assist_unlocked = bool(d.get("duoc_lao_assist_unlocked", false))
	pd.unlocked_companions = d.get("unlocked_companions", [])
	pd.active_companion_id = str(d.get("active_companion_id", ""))
	pd.inventory = d.get("inventory", {})
	pd.active_quest_idx = int(d.get("active_quest_idx", 0))
	pd.active_quest_id = str(d.get("active_quest_id", ""))
	if d.has("completed_quest_ids") and d["completed_quest_ids"] is Dictionary:
		pd.completed_quest_ids = d["completed_quest_ids"]
	else:
		pd.completed_quest_ids = {}
	pd.kim_viem_revive_used = bool(d.get("kim_viem_revive_used", false))
	pd.quest_progress = int(d.get("quest_progress", 0))
	pd.all_quests_done = bool(d.get("all_quests_done", false))
	# Tương thích tự động khi thêm chương mới: định vị lại active_quest_idx theo ID & tự mở tiếp chương mới cho bản lưu cũ!
	if pd.active_quest_id != "":
		var mapped_idx: int = GameDatabase.get_quest_index(pd.active_quest_id)
		if mapped_idx >= 0:
			pd.active_quest_idx = mapped_idx
	if pd.all_quests_done and not pd.is_demo_mode and pd.active_quest_idx < GameDatabase.all_quests.size():
		pd.all_quests_done = false
		pd.active_quest_id = str(GameDatabase.all_quests[pd.active_quest_idx].get("id", ""))
		pd.quest_progress = 0
	elif not pd.all_quests_done and pd.active_quest_idx >= 0 and pd.active_quest_idx < GameDatabase.all_quests.size():
		pd.active_quest_id = str(GameDatabase.all_quests[pd.active_quest_idx].get("id", ""))
	pd._rebuild_gear_cache()
	pd._rebuild_affection_cache()
	pd.recalculate_and_clamp(true)
	if persist_settings:
		save_user_settings(pd)
	EventBus.equipment_changed.emit()
	EventBus.skills_updated.emit()
	EventBus.stats_changed.emit()
	EventBus.inventory_changed.emit()
	EventBus.quest_updated.emit()
	EventBus.flame_changed.emit(pd.equipped_flame_id)
	EventBus.companion_changed.emit(pd.active_companion_id)


static func save_to_path(pd: Node, file_path: String) -> bool:
	var payload: Dictionary = build_save_payload(pd)
	var f := FileAccess.open(file_path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(payload, "\t"))
	return true


static func load_from_path(pd: Node, file_path: String, persist_settings: bool = false) -> bool:
	if not FileAccess.file_exists(file_path):
		return false
	var f := FileAccess.open(file_path, FileAccess.READ)
	if f == null:
		return false
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return false
	apply_loaded_payload(pd, parsed, persist_settings)
	return true


static func save_game(pd: Node, slot_idx: int = -1, silent: bool = false) -> bool:
	var target_slot: int = pd.active_save_slot if slot_idx <= 0 else clampi(slot_idx, 1, MAX_SAVE_SLOTS)
	pd.active_save_slot = target_slot
	pd.last_played_slot = target_slot
	if not save_to_path(pd, get_save_slot_path(target_slot)):
		return false
	save_user_settings(pd)
	if not silent:
		EventBus.audio_sfx_requested.emit("ui_click")
	return true


static func load_game(pd: Node, slot_idx: int = -1) -> bool:
	var target_slot: int = pd.active_save_slot if slot_idx <= 0 else clampi(slot_idx, 1, MAX_SAVE_SLOTS)
	var p: String = get_save_slot_path(target_slot)
	if not FileAccess.file_exists(p):
		if target_slot == 1 and FileAccess.file_exists(LEGACY_SAVE_PATH):
			p = LEGACY_SAVE_PATH
		else:
			return false
	pd.active_save_slot = target_slot
	pd.last_played_slot = target_slot
	return load_from_path(pd, p, true)
