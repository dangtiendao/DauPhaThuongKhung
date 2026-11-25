extends Node
## Bộ Kiểm Thử Tự Động (Godot Headless Test Suite) cho Đấu Phá Thương Khung:
## Chạy qua: Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/test_runner.tscn
## Hoặc chạy trực tiếp: tests\run_tests.bat

const SaveLoadMgr = preload("res://scripts/systems/save_load_manager.gd")
const StoryDlgRunner = preload("res://scripts/systems/story_dialogue_runner.gd")
const ThienPhanTowerMgr = preload("res://scripts/systems/thien_phan_tower_manager.gd")
const PanGateMgr = preload("res://scripts/systems/pan_gate_manager.gd")
const NineTurnMgr = preload("res://scripts/systems/nine_turn_manager.gd")
const SaintRealmMgr = preload("res://scripts/systems/saint_realm_manager.gd")
const EmperorRealmMgr = preload("res://scripts/systems/emperor_realm_manager.gd")

var passed_count: int = 0
var failed_count: int = 0
var failure_logs: Array[String] = []
var _backup_settings_existed: bool = false
var _backup_settings_raw: String = ""


func _ready() -> void:
	_backup_user_settings()
	call_deferred("_run_all_suites")


func _backup_user_settings() -> void:
	var p: String = SaveLoadMgr.SETTINGS_PATH
	if FileAccess.file_exists(p):
		_backup_settings_existed = true
		var f := FileAccess.open(p, FileAccess.READ)
		if f != null:
			_backup_settings_raw = f.get_as_text()


func _restore_user_settings() -> void:
	var p: String = SaveLoadMgr.SETTINGS_PATH
	if _backup_settings_existed:
		var f := FileAccess.open(p, FileAccess.WRITE)
		if f != null:
			f.store_string(_backup_settings_raw)
	elif FileAccess.file_exists(p):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(p))


func _assert(cond: bool, label: String, detail: String = "") -> void:
	if cond:
		passed_count += 1
	else:
		failed_count += 1
		var msg: String = "[FAIL] %s%s" % [label, (" — " + detail) if detail != "" else ""]
		failure_logs.append(msg)
		printerr(msg)


func _run_all_suites() -> void:
	print("============================================================")
	print("  DAU PHA THUONG KHUNG — AUTOMATED HEADLESS TEST SUITE")
	print("============================================================")

	_suite_01_json_schema()
	_suite_02_assets_exist()
	_suite_03_portal_graph_bfs()
	_suite_04_alchemy_max_tier()
	_suite_05_save_load_roundtrip()
	_suite_06_demo_mode()
	_suite_07_systems_integration()
	await _suite_08_live_scene_and_panels()
	_suite_09_8frame_spritesheets()
	_suite_10_ch06_systems()
	_suite_11_ch07_systems()
	_suite_12_ch08_systems()
	_suite_13_audio_and_modular_refactor()
	_suite_14_ch09_systems()
	_suite_15_ch10_systems()
	await _suite_16_ch11_systems()

	_restore_user_settings()

	print("============================================================")
	print("  RESULT: %d PASSED | %d FAILED" % [passed_count, failed_count])
	if failed_count > 0:
		for fl in failure_logs:
			printerr("  " + fl)
		print("============================================================")
		get_tree().quit(1)
	else:
		print("  ALL AUTOMATED TESTS PASSED!")
		print("============================================================")
		get_tree().quit(0)


# =========================================================
# SUITE 1: JSON SCHEMA & DATABASE INTEGRITY
# =========================================================
func _suite_01_json_schema() -> void:
	print("[Suite 1] JSON Schema & Database Integrity...")
	var json_files: Array = [
		"res://data/realms.json", "res://data/flames.json", "res://data/skills.json",
		"res://data/alchemy_items.json", "res://data/equipment.json",
		"res://data/enemies.json", "res://data/enemies_ch04.json", "res://data/enemies_ch05.json", "res://data/enemies_ch06.json", "res://data/enemies_ch07.json", "res://data/enemies_ch08.json", "res://data/enemies_ch09.json", "res://data/enemies_ch10.json", "res://data/enemies_ch11.json",
		"res://data/maps.json", "res://data/maps_ch04.json", "res://data/maps_ch05.json", "res://data/maps_ch06.json", "res://data/maps_ch07.json", "res://data/maps_ch08.json", "res://data/maps_ch09.json", "res://data/maps_ch10.json", "res://data/maps_ch11.json",
		"res://data/quests_ch01.json", "res://data/quests_ch04.json", "res://data/quests_ch05.json", "res://data/quests_ch06.json", "res://data/quests_ch07.json", "res://data/quests_ch08.json", "res://data/quests_ch09.json", "res://data/quests_ch10.json", "res://data/quests_ch11.json",
		"res://data/dialogues_ch04.json", "res://data/dialogues_ch05.json", "res://data/dialogues_ch06.json", "res://data/dialogues_ch07.json", "res://data/dialogues_ch08.json", "res://data/dialogues_ch09.json", "res://data/dialogues_ch10.json", "res://data/dialogues_ch11.json"
	]
	for jf in json_files:
		_assert(FileAccess.file_exists(jf), "JSON exists: " + jf)
		var f := FileAccess.open(jf, FileAccess.READ)
		var parsed: Variant = JSON.parse_string(f.get_as_text()) if f != null else null
		_assert(parsed is Dictionary, "JSON parses as Dictionary: " + jf)

	_assert(GameDatabase.realms_list.size() == 12, "12 major realms loaded", "got %d" % GameDatabase.realms_list.size())
	_assert(GameDatabase.soul_realms_list.size() == 4, "4 soul realms loaded", "got %d" % GameDatabase.soul_realms_list.size())
	for sr in GameDatabase.soul_realms_list:
		_assert(sr is Dictionary and sr.has("min_soul") and sr.has("alchemy_max_tier") and sr.has("radar_radius_px"), "Soul realm schema valid")

	_assert(GameDatabase.flames_ordered.size() == 28, "28 flames loaded", "got %d" % GameDatabase.flames_ordered.size())
	for fl in GameDatabase.flames_ordered:
		_assert(fl is Dictionary and str(fl.get("id", "")) != "" and str(fl.get("lotus_effect", "")) != "", "Flame entry valid: %s" % str(fl.get("id", "")))

	_assert(GameDatabase.skills_by_id.size() == 37, "37 skills loaded", "got %d" % GameDatabase.skills_by_id.size())
	for sid in GameDatabase.skills_by_id.keys():
		var sk: Dictionary = GameDatabase.skills_by_id[sid]
		_assert(str(sk.get("name", "")) != "" and str(sk.get("icon", "")).begins_with("res://"), "Skill valid: " + str(sid))

	_assert(GameDatabase.items_by_id.size() >= 83, "83+ alchemy items loaded", "got %d" % GameDatabase.items_by_id.size())
	_assert(GameDatabase.recipes_list.size() >= 36, "36+ alchemy recipes loaded", "got %d" % GameDatabase.recipes_list.size())
	for rec in GameDatabase.recipes_list:
		var out_id: String = str(rec.get("output_item", ""))
		_assert(GameDatabase.items_by_id.has(out_id), "Recipe output exists: " + out_id)
		var ings: Dictionary = rec.get("ingredients", {})
		for ik in ings.keys():
			_assert(GameDatabase.items_by_id.has(str(ik)), "Recipe ingredient exists: " + str(ik))
		_assert(int(rec.get("tier", 0)) >= 1, "Recipe tier >= 1: " + str(rec.get("id", "")))

	_assert(GameDatabase.equipment_slots.size() == 10, "10 equipment slots")
	_assert(GameDatabase.equipment_rarities.size() == 6, "6 equipment rarities")
	_assert(GameDatabase.equipment_sets.size() >= 11, "11+ equipment sets")
	_assert(GameDatabase.equipment_templates.size() >= 64, "64+ equipment templates")
	var valid_slots: Dictionary = {}
	for sl in GameDatabase.equipment_slots:
		valid_slots[str(sl.get("id", ""))] = true
	for tid in GameDatabase.equipment_templates.keys():
		var td: Dictionary = GameDatabase.equipment_templates[tid]
		_assert(valid_slots.has(str(td.get("slot", ""))), "Equipment template slot valid: " + str(tid))

	var boss_cnt: int = 0
	for eid in GameDatabase.enemies_by_id.keys():
		var ed: Dictionary = GameDatabase.enemies_by_id[eid]
		_assert(float(ed.get("max_hp", 0.0)) > 0.0, "Enemy max_hp > 0: " + str(eid))
		if bool(ed.get("is_boss", false)):
			boss_cnt += 1
			_assert(str(ed.get("anim_sheet", "")) != "", "Boss has anim_sheet: " + str(eid))
	_assert(GameDatabase.enemies_by_id.size() >= 118, "118+ enemies loaded", "got %d" % GameDatabase.enemies_by_id.size())
	_assert(boss_cnt >= 64, "64+ bosses loaded", "got %d" % boss_cnt)

	_assert(GameDatabase.all_quests.size() >= 96, "96+ quests loaded", "got %d" % GameDatabase.all_quests.size())
	var seen_qids: Dictionary = {}
	for q in GameDatabase.all_quests:
		var qid: String = str(q.get("id", ""))
		_assert(qid != "" and not seen_qids.has(qid), "Quest ID unique: " + qid)
		seen_qids[qid] = true

	_assert(GameDatabase.maps_ordered.size() >= 67, "67+ maps loaded", "got %d" % GameDatabase.maps_ordered.size())
	_assert(GameDatabase.maps_by_id.has(GameDatabase.start_map_id), "Start map exists: " + GameDatabase.start_map_id)
	for mid in GameDatabase.maps_by_id.keys():
		var md: Dictionary = GameDatabase.maps_by_id[mid]
		for sp in md.get("spawns", []):
			var se_id: String = str(sp.get("enemy_id", ""))
			_assert(GameDatabase.enemies_by_id.has(se_id), "Map spawn enemy exists: %s -> %s" % [str(mid), se_id])


# =========================================================
# SUITE 2: ASSET EXISTENCE (res://)
# =========================================================
func _suite_02_assets_exist() -> void:
	print("[Suite 2] Asset Existence Verification...")
	var paths_to_check: Dictionary = {}

	for eid in GameDatabase.enemies_by_id.keys():
		var ed: Dictionary = GameDatabase.enemies_by_id[eid]
		for k in ["sprite", "anim_sheet"]:
			var p: String = str(ed.get(k, ""))
			if p != "":
				paths_to_check[p] = "enemy:" + str(eid)

	for sid in GameDatabase.skills_by_id.keys():
		var p: String = str(GameDatabase.skills_by_id[sid].get("icon", ""))
		if p != "":
			paths_to_check[p] = "skill:" + str(sid)

	for sl in GameDatabase.equipment_slots:
		var p: String = str(sl.get("default_icon", ""))
		if p != "":
			paths_to_check[p] = "slot:" + str(sl.get("id", ""))

	for tid in GameDatabase.equipment_templates.keys():
		var p: String = str(GameDatabase.equipment_templates[tid].get("icon", ""))
		if p != "":
			paths_to_check[p] = "equip:" + str(tid)

	for mid in GameDatabase.maps_by_id.keys():
		var md: Dictionary = GameDatabase.maps_by_id[mid]
		for tk in ["base_tile", "ground_tile", "path_tile"]:
			var bt: String = str(md.get(tk, ""))
			if bt != "":
				paths_to_check[bt] = "map_tile:" + str(mid)
		for z in md.get("zones", []):
			var zt: String = str(z.get("tile", ""))
			if zt != "":
				paths_to_check[zt] = "zone_tile:" + str(mid)
		for n in md.get("npcs", []):
			var np: String = str(n.get("sprite", ""))
			if np != "":
				paths_to_check[np] = "npc:" + str(mid)

	for prof in PlayerData.get_heroine_profiles():
		var sp: String = str(prof.get("sprite", ""))
		if sp != "":
			paths_to_check[sp] = "heroine:" + str(prof.get("key", ""))

	for b in ThienPhanTowerMgr.get_blessing_pool():
		var ic: String = str(b.get("icon", ""))
		if ic != "":
			paths_to_check[ic] = "tower_blessing:" + str(b.get("id", ""))

	for core_scene in [
		"res://scenes/ui/main_menu.tscn",
		"res://scenes/main_prototype.tscn",
		"res://scenes/entities/player.tscn",
		"res://scenes/entities/enemy_base.tscn",
		"res://scenes/entities/companion.tscn",
		"res://assets/shaders/di_hoa_palette.gdshader",
		"res://assets/shaders/char_motion_polish.gdshader",
		"res://assets/shaders/space_shockwave.gdshader",
		"res://assets/shaders/vfx_energy_dissolve.gdshader",
		"res://assets/sprites/vfx/fire_lotus.png",
		"res://assets/sprites/vfx/slash_arc.png",
		"res://assets/sprites/vfx/wing_plume.png",
		"res://assets/sprites/pickups/qi_orb.png",
		"res://assets/sprites/pickups/monster_core.png",
		"res://assets/sprites/pickups/herb_item.png",
		"res://icon.svg",
		"res://icon.ico"
	]:
		paths_to_check[core_scene] = "core"

	var missing_cnt: int = 0
	for p in paths_to_check.keys():
		var exists: bool = FileAccess.file_exists(str(p)) or ResourceLoader.exists(str(p))
		if not exists:
			missing_cnt += 1
			_assert(false, "Asset missing: " + str(p), "referenced by " + str(paths_to_check[p]))
	_assert(missing_cnt == 0, "All %d referenced res:// assets exist" % paths_to_check.size(), "missing=%d" % missing_cnt)


# =========================================================
# SUITE 3: WORLD PORTAL GRAPH CONNECTIVITY (67 MAPS BFS)
# =========================================================
func _suite_03_portal_graph_bfs() -> void:
	print("[Suite 3] World Portal Graph Connectivity (67 Maps BFS)...")
	var adj: Dictionary = {}
	for mid in GameDatabase.maps_by_id.keys():
		adj[str(mid)] = []
		var md: Dictionary = GameDatabase.maps_by_id[mid]
		var non_future_out: int = 0
		for pt in md.get("portals", []):
			var tgt: String = str(pt.get("target_map", ""))
			var req_f: String = str(pt.get("require_flag", ""))
			_assert(GameDatabase.maps_by_id.has(tgt), "Portal target exists: %s -> %s" % [str(mid), tgt])
			if not req_f.ends_with("_future") and tgt != str(mid):
				adj[str(mid)].append(tgt)
				non_future_out += 1
		_assert(non_future_out >= 1, "Map has at least 1 active outgoing portal: " + str(mid))

	# BFS from start_map_id
	var visited: Dictionary = { GameDatabase.start_map_id: true }
	var queue: Array = [GameDatabase.start_map_id]
	while not queue.is_empty():
		var cur: String = str(queue.pop_front())
		for nxt in adj.get(cur, []):
			if not visited.has(nxt):
				visited[nxt] = true
				queue.append(nxt)

	var unreachable: Array = []
	for mid in GameDatabase.maps_ordered:
		if not visited.has(str(mid)):
			unreachable.append(str(mid))
	_assert(
		unreachable.is_empty(),
		"All %d maps reachable via BFS from %s" % [GameDatabase.maps_ordered.size(), GameDatabase.start_map_id],
		"unreachable: " + str(unreachable)
	)


# =========================================================
# SUITE 4: ALCHEMY_MAX_TIER (SOUL REALM ENFORCEMENT)
# =========================================================
func _suite_04_alchemy_max_tier() -> void:
	print("[Suite 4] AlchemySystem alchemy_max_tier Enforcement...")
	PlayerData.reset_for_new_game(1)

	var rec_t1: Dictionary = {}
	var rec_t7: Dictionary = {}
	for r in GameDatabase.recipes_list:
		if str(r.get("id", "")) == "recipe_ngung_huyet_tan":
			rec_t1 = r
		elif str(r.get("id", "")) == "recipe_am_duong_huyen_long":
			rec_t7 = r
	_assert(not rec_t1.is_empty() and not rec_t7.is_empty(), "Located Tier 1 and Tier 7 test recipes")

	# Cấp đủ nguyên liệu cho cả 2 công thức
	for rec in [rec_t1, rec_t7]:
		var ings: Dictionary = rec.get("ingredients", {})
		for ik in ings.keys():
			PlayerData.add_item(str(ik), int(ings[ik]) + 2)

	# 1. Phàm Cảnh (SOUL ~ 170 >= req_soul 160, nhưng < 250 nên max_tier = 6) -> Phải CHẶN Phẩm 7, CHO Phẩm 1!
	PlayerData.bonus_soul = 165
	var sr_low: Dictionary = PlayerData.get_soul_realm_info()
	_assert(int(sr_low.get("alchemy_max_tier", 6)) == 6, "Soul ~170 is Pham Canh (max_tier=6)", "got %s" % str(sr_low))
	var chk_t1: Dictionary = AlchemySystem.can_craft(rec_t1)
	_assert(bool(chk_t1.get("ok", false)), "Tier 1 allowed in Pham Canh", str(chk_t1))
	var chk_t7_blocked: Dictionary = AlchemySystem.can_craft(rec_t7)
	_assert(not bool(chk_t7_blocked.get("ok", true)), "Tier 7 BLOCKED in Pham Canh despite req_soul=160 met", str(chk_t7_blocked))
	_assert(str(chk_t7_blocked.get("reason", "")).find("vượt giới hạn") != -1, "Block reason explains Soul Realm tier cap")

	# 2. Đột phá lên Linh Cảnh (SOUL >= 250 -> max_tier = 7) -> Phải CHO PHÉP Phẩm 7!
	PlayerData.bonus_soul = 260
	var sr_high: Dictionary = PlayerData.get_soul_realm_info()
	_assert(int(sr_high.get("alchemy_max_tier", 6)) >= 7, "Soul >= 250 reaches Linh Canh (max_tier>=7)", "got %s" % str(sr_high))
	var chk_t7_ok: Dictionary = AlchemySystem.can_craft(rec_t7)
	_assert(bool(chk_t7_ok.get("ok", false)), "Tier 7 ALLOWED once Linh Canh is reached", str(chk_t7_ok))


# =========================================================
# SUITE 5: SAVE / LOAD MANAGER ROUNDTRIP & MIGRATION
# =========================================================
func _suite_05_save_load_roundtrip() -> void:
	print("[Suite 5] SaveLoadManager Roundtrip & Legacy Migration...")
	var tmp_path: String = "user://dptk_autotest_tmp.json"

	PlayerData.reset_for_new_game(1)
	PlayerData.current_map_id = "ch05_ngoai_vien_gia_nam"
	PlayerData.realm_index = 5
	PlayerData.stage = 4
	PlayerData.nine_turn_level = 6
	PlayerData.gold = 12345
	PlayerData.enhance_stones = 77
	PlayerData.bonus_soul = 88
	PlayerData.fire_energy = 195
	PlayerData.tower_best_floor = 9
	PlayerData.auction_wins = 4
	PlayerData.auction_consigned_total = 17
	PlayerData.weapon_core_sockets = ["core_hoa_3", "core_loi_5", ""]
	PlayerData.story_flags["ch05_huan_nhi_reunited"] = true
	PlayerData.affection["huan_nhi"] = 85
	PlayerData.skill_mastery_uses["bat_cuc_bang"] = 42
	PlayerData.boss_rush_records["la_hau_boss|nightmare"] = { "best_grade": "SS", "best_time": 24.5, "clears": 2 }
	PlayerData.pan_gate_state = {
		"dan_duong": 2, "vo_duong": 1, "am_duong": 3, "am_vong": 2, "tinh_than_tran": 3, "thien_phu_lien_quan": 2,
		"last_harvest_playtime": 12.5, "total_harvests": 3, "ziyan_expeditions": 4, "strong_rank_cleared": {}
	}
	PlayerData.ma_doc_ban_stacks = 7
	PlayerData.ng_plus_cycle = 2
	PlayerData.saved_player_pos = Vector2(777.0, 333.0)
	PlayerData.has_saved_player_pos = true

	var ok_save: bool = SaveLoadMgr.save_to_path(PlayerData, tmp_path)
	_assert(ok_save and FileAccess.file_exists(tmp_path), "SaveLoadManager.save_to_path succeeded")

	# Reset hoàn toàn sang trạng thái mới
	PlayerData.reset_for_new_game(1)
	_assert(PlayerData.gold != 12345 and PlayerData.current_map_id == "ch01_tieu_gia", "Reset cleared previous state")

	# Tải lại từ tệp tạm
	var ok_load: bool = SaveLoadMgr.load_from_path(PlayerData, tmp_path, false)
	_assert(ok_load, "SaveLoadManager.load_from_path succeeded")
	_assert(PlayerData.current_map_id == "ch05_ngoai_vien_gia_nam", "Restored current_map_id")
	_assert(PlayerData.realm_index == 5 and PlayerData.stage == 4 and PlayerData.nine_turn_level == 6, "Restored realm, stage & nine_turn_level")
	_assert(PlayerData.gold == 12345 and PlayerData.enhance_stones == 77, "Restored currency")
	_assert(PlayerData.fire_energy == 195 and PlayerData.tower_best_floor == 9, "Restored tower stats")
	_assert(PlayerData.auction_wins == 4 and PlayerData.auction_consigned_total == 17, "Restored auction stats")
	_assert(PlayerData.weapon_core_sockets == ["core_hoa_3", "core_loi_5", ""], "Restored 3 weapon core sockets")
	_assert(PlayerData.has_flag("ch05_huan_nhi_reunited"), "Restored story_flags")
	_assert(PlayerData.get_affection("huan_nhi") == 85, "Restored heroine affection")
	_assert(int(PlayerData.skill_mastery_uses.get("bat_cuc_bang", 0)) == 42, "Restored skill mastery")
	_assert(str(PlayerData.get_boss_rush_record("la_hau_boss", "nightmare").get("best_grade", "")) == "SS", "Restored boss rush record")
	_assert(PanGateMgr.get_hall_level(PlayerData, "dan_duong") == 2 and PanGateMgr.get_hall_level(PlayerData, "am_duong") == 3 and PanGateMgr.get_hall_level(PlayerData, "am_vong") == 2 and PanGateMgr.get_hall_level(PlayerData, "tinh_than_tran") == 3 and PanGateMgr.get_hall_level(PlayerData, "thien_phu_lien_quan") == 2, "Restored pan_gate_state 6 halls")
	_assert(PlayerData.ma_doc_ban_stacks == 7 and PlayerData.ng_plus_cycle == 2, "Restored ma_doc_ban_stacks & ng_plus_cycle")
	_assert(PlayerData.has_saved_player_pos and PlayerData.saved_player_pos.is_equal_approx(Vector2(777.0, 333.0)), "Restored player position")

	# Kiểm thử tự nâng cấp bản lưu cũ (v0.3 dừng ở mốc 21 -> tự mở tiếp Ch.04/Ch.05)
	var legacy_payload: Dictionary = SaveLoadMgr.build_save_payload(PlayerData)
	legacy_payload["is_demo_mode"] = false
	legacy_payload["all_quests_done"] = true
	legacy_payload["active_quest_idx"] = 21
	legacy_payload["active_quest_id"] = ""
	SaveLoadMgr.apply_loaded_payload(PlayerData, legacy_payload, false)
	_assert(not PlayerData.all_quests_done, "Legacy completed v0.3 save automatically re-opens Ch.04+ quests")
	_assert(PlayerData.active_quest_id == str(GameDatabase.all_quests[21].get("id", "")), "Legacy save maps to quest #22")

	# Dọn tệp tạm
	if FileAccess.file_exists(tmp_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(tmp_path))


# =========================================================
# SUITE 6: DEMO MODE VERIFICATION
# =========================================================
func _suite_06_demo_mode() -> void:
	print("[Suite 6] DEMO Mode (activate_demo_unlock_all)...")
	PlayerData.activate_demo_unlock_all(3)
	_assert(PlayerData.is_demo_mode, "DEMO flag active")
	_assert(PlayerData.realm_index == 12 and PlayerData.nine_turn_level == 9, "DEMO realm is Viem De (Realm 12) + Cuu Chuyen 9/9")
	_assert(PlayerData.has_flag("ch04_completed") and PlayerData.has_flag("ch05_completed") and PlayerData.has_flag("ch06_completed") and PlayerData.has_flag("ch07_completed") and PlayerData.has_flag("ch08_completed") and PlayerData.has_flag("ch09_completed") and PlayerData.has_flag("ch10_completed") and PlayerData.has_flag("ch11_completed") and PlayerData.has_flag("ch11_viem_de_ascended"), "DEMO unlocks Ch01-Ch11 story flags")
	_assert(PlayerData.unlocked_flames.size() == 28, "DEMO unlocks all 28 flames")
	_assert(PlayerData.unlocked_skills.size() == GameDatabase.skills_by_id.size() and PlayerData.unlocked_skills.size() == 37, "DEMO unlocks all 37 skills")
	_assert(PlayerData.unlocked_companions.size() == 12 and PlayerData.unlocked_companions.has("bac_vuong") and PlayerData.unlocked_companions.has("chuc_khon_long_hoang"), "DEMO unlocks all 12 companions incl. Chuc Khon Long Hoang")
	_assert(PlayerData.has_van_lac_passive() and PlayerData.has_dau_vuong_wings() and PlayerData.has_dau_tong_void_step() and PlayerData.has_dau_ton_spatial_blink() and PlayerData.has_tam_thien_immortal_body() and SaintRealmMgr.has_dau_thanh_domain(PlayerData) and SaintRealmMgr.has_tieu_y_spirit(PlayerData) and EmperorRealmMgr.has_de_canh_soul(PlayerData) and EmperorRealmMgr.is_viem_de_emperor(PlayerData), "DEMO enables Viem De Emperor & De Canh Soul")
	_assert(PlayerData.get_assist_mode() == "viem_de_phap_tuong", "DEMO upgrades [T] Assist to Viem De Phap Tuong")
	_assert(PlayerData.lotus_fusion_flames.size() == 8 and PlayerData.get_lotus_max_flames() == 23, "DEMO equips 8-Flame Hang Co Di Hoa Lien (max 23)")
	_assert(PanGateMgr.is_thien_phu_evolved(PlayerData) and PanGateMgr.get_hall_level(PlayerData, "thien_phu_lien_quan") == 2, "DEMO initializes Thien Phu Lien Minh Tier-4 with 6th hall Lv.2")
	_assert(PlayerData.weapon_core_sockets.size() == 3 and PlayerData.weapon_core_sockets[0] == "core_de_viem_10", "DEMO sockets 3 cores incl. core_de_viem_10")
	var has_44: bool = false
	for r in PlayerData.story_relics:
		if str(r).find("4/4") != -1:
			has_44 = true
	_assert(has_44, "DEMO relic displays 4/4 Tinh Lien Yeu Hoa fragments")


# =========================================================
# SUITE 7: SYSTEMS INTEGRATION (AUCTION, EQUIPMENT, STORY RUNNER)
# =========================================================
func _suite_07_systems_integration() -> void:
	print("[Suite 7] AuctionSystem, EquipmentSystem & StoryDialogueRunner...")
	var lots_np: Array = AuctionSystem.generate_auction_lots("nha_phi")
	var lots_bpm: Array = AuctionSystem.generate_auction_lots("bat_phien_mon")
	_assert(lots_np.size() == 3 and lots_bpm.size() == 3, "AuctionSystem generates 3 lots for both venues")
	var scan_res: Dictionary = AuctionSystem.process_bid_turn(lots_bpm[0], "scan", 200, 50000)
	_assert(bool(lots_bpm[0].get("scanned", false)) and str(scan_res.get("status", "")) == "ongoing", "Auction Soul Scan reveals rivals")

	var gear_inst: Dictionary = EquipmentSystem.roll_equipment_instance("wpn_huyen_trong_xich", "thien")
	_assert(not gear_inst.is_empty() and str(gear_inst.get("uid", "")) != "", "EquipmentSystem rolls valid gear instance")
	_assert(EquipmentSystem.format_stats_line(gear_inst) != "", "EquipmentSystem formats stat line")

	var d5: Dictionary = GameDatabase.get_dialogue_def("ch05_huan_nhi_reunion")
	_assert(not d5.is_empty(), "Ch.05 dialogue role loaded in GameDatabase")
	var emitted: Array = [false]
	var cb := func(_s: String, _a: String, _l: Array, _x: Variant) -> void: emitted[0] = true
	var cb2 := func(_s: String, _a: String, _l: Array, _x: String) -> void: emitted[0] = true
	EventBus.dialogue_choice_requested.connect(cb)
	EventBus.dialogue_requested.connect(cb2)
	var ran: bool = StoryDlgRunner.run_data_driven_dialogue(d5, "Tiêu Huân Nhi", "res://assets/sprites/npcs/npc_huan_nhi.png")
	EventBus.dialogue_choice_requested.disconnect(cb)
	EventBus.dialogue_requested.disconnect(cb2)
	_assert(ran and bool(emitted[0]), "StoryDialogueRunner runs Ch.05 JSON dialogue cleanly")


# =========================================================
# SUITE 8: LIVE SCENE, 6 REFACTORED HUD PANELS, BOSS RUSH & TOWER
# =========================================================
func _suite_08_live_scene_and_panels() -> void:
	print("[Suite 8] Live Scene, 6 Refactored HUD Panels, BossRush & ThienPhanTower...")
	PlayerData.activate_demo_unlock_all(3)
	var proto_scene: PackedScene = load("res://scenes/main_prototype.tscn")
	_assert(proto_scene != null, "main_prototype.tscn loads")
	var inst: Node = proto_scene.instantiate()
	add_child(inst)
	await get_tree().process_frame

	var world: Node = inst
	var hud: Node = inst.get_node_or_null("GameHUD")
	var player_nd: Node = get_tree().get_first_node_in_group("player")
	_assert(world != null and hud != null, "WorldStage and GameHUD instantiated")
	_assert(player_nd != null and player_nd.get("char_motion_mat") != null, "PlayerController attached char_motion_polish shader material")
	_assert(player_nd != null and player_nd.get("wing_shader_mat") != null and player_nd.get("wing_left_sprite") != null and player_nd.get("wing_right_sprite") != null, "PlayerController attached VFX 2.0 feathered Energy Wings shader & sprites")
	var sfx_overlay: Node = world.get("screen_fx_overlay") as Node
	_assert(sfx_overlay != null and sfx_overlay.get("shockwave_mat") != null, "WorldStage attached ScreenFxOverlay (VFX 2.0) with SpaceShockwave shader")
	# Smoke-test VFX 2.0 global signals (Shockwave + Flash + 5-Color Dan Lei sequence)
	EventBus.shockwave_requested.emit(Vector2(640, 360), 220.0, 0.045, Color("#72EFDD"), 0.35)
	EventBus.screen_flash_requested.emit(Color("#FFD166"), 0.20, 0.16)
	EventBus.dan_lei_strike_requested.emit(Vector2(640, 360), 5)
	await get_tree().physics_frame
	_assert(bool(sfx_overlay.get("sw_active")), "ScreenFxOverlay activated space shockwave on signal")
	_assert(world.get("boss_rush_mgr") != null and world.get("tower_mgr") != null, "WorldStage delegates initialized")
	_assert(
		hud.get("panel_pause_settings") != null
		and hud.get("panel_world_map_bestiary") != null
		and hud.get("panel_tower_boss_rush") != null
		and hud.get("panel_alchemy") != null
		and hud.get("panel_auction") != null
		and hud.get("panel_equipment") != null
		and hud.get("panel_skills_cultivation") != null
		and hud.get("panel_ending_credits") != null,
		"All 8 extracted HUD panels initialized"
	)

	# Mở toàn bộ modal & tab để đảm bảo 0 lỗi dựng UI sau refactor
	var modal_host: Control = hud.get("modal_content_host") as Control
	for mk in ["pause", "equipment", "skills", "breakthrough", "alchemy", "flames", "ending_credits"]:
		hud.set("current_modal", mk)
		hud.call("_populate_modal")
		_assert(modal_host.get_child_count() > 0, "HUD modal populated: " + mk)

	for st in ["shop", "auction", "consign"]:
		hud.set("shop_tab", st)
		hud.set("current_modal", "shop_nha_phi")
		hud.call("_populate_modal")
		_assert(modal_host.get_child_count() > 0, "HUD auction/shop tab populated: " + st)

	for wt in ["maps", "heroines", "boss_rush", "bestiary", "tower", "pan_gate"]:
		hud.set("world_map_tab", wt)
		hud.set("current_modal", "world_map")
		hud.call("_populate_modal")
		_assert(modal_host.get_child_count() > 0, "HUD world_map tab populated: " + wt)

	hud.set("pending_tower_floor", 1)
	hud.set("pending_tower_choices", ThienPhanTowerMgr.get_blessing_pool().slice(0, 3))
	hud.set("current_modal", "tower_blessing")
	hud.call("_populate_modal")
	_assert(modal_host.get_child_count() > 0, "HUD tower_blessing modal populated")
	hud.call("_close_modal")

	# Kiểm thử vào/ra Tâm Ma Luyện Cảnh (BossRushManager)
	world.call("start_boss_rush", "tieu_ninh_boss", "normal")
	_assert(bool(world.get("is_boss_rush_active")) and str(world.get("current_map_id")) == "tam_ma_luyen_canh", "BossRushManager entered arena")
	world.call("exit_boss_rush")
	_assert(not bool(world.get("is_boss_rush_active")), "BossRushManager exited cleanly")

	# Kiểm thử vào/ra Thiên Phần Luyện Khí Tháp (ThienPhanTowerManager)
	world.call("start_tower", 1)
	var tmgr = world.get("tower_mgr")
	_assert(bool(world.get("is_tower_active")) and str(world.get("current_map_id")) == "thien_phan_thap", "ThienPhanTowerManager entered floor 1")
	_assert(tmgr.enemies_alive.size() >= 4, "Tower floor 1 spawned enemies", "count=%d" % tmgr.enemies_alive.size())
	world.call("exit_tower")
	_assert(not bool(world.get("is_tower_active")), "ThienPhanTowerManager exited cleanly")

	inst.queue_free()
	await get_tree().process_frame


# =========================================================
# SUITE 9: 8-FRAME DEFAULT SPRITESHEET & CH.04-11 ART VERIFICATION
# =========================================================
func _suite_09_8frame_spritesheets() -> void:
	print("[Suite 9] 8-Frame Default Spritesheet & Unique Art Verification (8 Player + 64 Boss + 37 Skills + 34 Tiles + 47 NPCs)...")
	var player_sheets: Array = [
		{ "p": "res://assets/sprites/player/tieu_viem_idle.png", "kind": "square", "fh": 4, "fv": 2 },
		{ "p": "res://assets/sprites/player/tieu_viem_run.png", "kind": "square", "fh": 4, "fv": 2 },
		{ "p": "res://assets/sprites/player/tieu_viem_cast.png", "kind": "square", "fh": 8, "fv": 1 },
		{ "p": "res://assets/sprites/player/tieu_viem_dash.png", "kind": "square", "fh": 8, "fv": 1 },
		{ "p": "res://assets/sprites/player/tieu_viem_attack_unarmed.png", "kind": "player_attack", "fh": 4, "fv": 2 },
		{ "p": "res://assets/sprites/player/tieu_viem_attack_sword.png", "kind": "player_attack", "fh": 4, "fv": 2 },
		{ "p": "res://assets/sprites/player/tieu_viem_attack_sabre.png", "kind": "player_attack", "fh": 4, "fv": 2 },
		{ "p": "res://assets/sprites/player/tieu_viem_attack_ruler.png", "kind": "player_attack", "fh": 4, "fv": 2 }
	]
	for spec in player_sheets:
		var tex: Texture2D = load(str(spec["p"]))
		_assert(tex != null, "Player sheet loads: " + str(spec["p"]))
		var meta: Dictionary = SpriteAnimHelper.inspect_sheet(tex, str(spec["kind"]), int(spec["fh"]), int(spec["fv"]))
		_assert(int(meta.get("total_frames", 0)) == 8, "Player sheet is 8 frames: " + str(spec["p"]), "got %s" % str(meta))
		if str(spec["kind"]) == "player_attack":
			var c1: PackedInt32Array = SpriteAnimHelper.get_player_attack_frames(meta, 1, false)
			var c2: PackedInt32Array = SpriteAnimHelper.get_player_attack_frames(meta, 2, false)
			var c3: PackedInt32Array = SpriteAnimHelper.get_player_attack_frames(meta, 3, false)
			_assert(c1.size() == 4 and c2.size() == 4 and c3.size() == 7, "8-frame attack combo mapping valid")

	var checked_boss_sheets: Dictionary = {}
	for eid in GameDatabase.enemies_by_id.keys():
		var ed: Dictionary = GameDatabase.enemies_by_id[eid]
		if not bool(ed.get("is_boss", false)):
			continue
		var ap: String = str(ed.get("anim_sheet", ""))
		_assert(ap != "", "Boss has dedicated anim_sheet: " + str(eid))
		if ap == "" or checked_boss_sheets.has(ap):
			continue
		checked_boss_sheets[ap] = true
		var btex: Texture2D = load(ap)
		_assert(btex != null, "Boss anim sheet loads: " + ap)
		var bmeta: Dictionary = SpriteAnimHelper.inspect_sheet(btex, "enemy_anim", 4, 2)
		_assert(int(bmeta.get("hframes", 0)) == 4 and int(bmeta.get("vframes", 0)) == 2 and int(bmeta.get("total_frames", 0)) == 8, "Boss sheet is 4x2 (8 frames): " + ap, "got %s" % str(bmeta))
		for st in ["idle", "move", "windup", "strike"]:
			var st_arr: PackedInt32Array = SpriteAnimHelper.get_enemy_state_frames(bmeta, st)
			_assert(st_arr.size() == 2, "Boss 8f state has 2 crisp frames (%s): %s" % [st, ap], "got %s" % str(st_arr))
	_assert(checked_boss_sheets.size() == 64, "Verified all 64/64 unique boss anim sheets are 8 frames", "got %d" % checked_boss_sheets.size())

	# Kiểm tra 37/37 Đấu Kỹ đều có icon riêng biệt (không tái sử dụng trùng lặp)
	var unique_skill_icons: Dictionary = {}
	for sid in GameDatabase.skills_by_id.keys():
		var sk: Dictionary = GameDatabase.skills_by_id[sid]
		var ip: String = str(sk.get("icon", ""))
		var itex: Texture2D = load(ip)
		_assert(itex != null and itex.get_width() == 56 and itex.get_height() == 56, "Skill icon is 56x56: " + ip)
		unique_skill_icons[ip] = true
	_assert(unique_skill_icons.size() == 37, "All 37 skills have 37 unique icons", "got %d" % unique_skill_icons.size())

	# Kiểm tra 34 tileset vùng mới Ch.04–11 chuẩn 128x128
	var new_tiles: Array = [
		"res://assets/sprites/tiles/de_do_palace.png",
		"res://assets/sprites/tiles/yunlan_marble.png",
		"res://assets/sprites/tiles/hac_giac_obsidian.png",
		"res://assets/sprites/tiles/gia_nam_courtyard.png",
		"res://assets/sprites/tiles/noi_vien_jade.png",
		"res://assets/sprites/tiles/thien_phan_magma.png",
		"res://assets/sprites/tiles/xuat_van_poison_marsh.png",
		"res://assets/sprites/tiles/thien_nhai_wormhole.png",
		"res://assets/sprites/tiles/bac_vuc_storm_slate.png",
		"res://assets/sprites/tiles/thien_son_blood_pool.png",
		"res://assets/sprites/tiles/lac_than_frost_poison.png",
		"res://assets/sprites/tiles/thanh_dan_white_marble.png",
		"res://assets/sprites/tiles/tinh_vuc_starfield.png",
		"res://assets/sprites/tiles/tinh_van_star_pavilion.png",
		"res://assets/sprites/tiles/vong_hon_mist_stone.png",
		"res://assets/sprites/tiles/hoa_tong_blossom_jade.png",
		"res://assets/sprites/tiles/di_tich_ancient_relic.png",
		"res://assets/sprites/tiles/co_long_void_thunder.png",
		"res://assets/sprites/tiles/co_gioi_golden_plaza.png",
		"res://assets/sprites/tiles/thien_mo_ancient_tomb.png",
		"res://assets/sprites/tiles/viem_minh_siege_wall.png",
		"res://assets/sprites/tiles/mang_hoang_ancient_jungle.png",
		"res://assets/sprites/tiles/bo_de_emerald_sanctum.png",
		"res://assets/sprites/tiles/thien_phu_grand_citadel.png",
		"res://assets/sprites/tiles/hoang_tuyen_abyss_stone.png",
		"res://assets/sprites/tiles/nhan_dien_bone_fortress.png",
		"res://assets/sprites/tiles/yeu_hoa_lotus_sea.png",
		"res://assets/sprites/tiles/duoc_gioi_herb_terrace.png",
		"res://assets/sprites/tiles/tang_thien_shattered_ridge.png",
		"res://assets/sprites/tiles/gia_nam_deep_magma.png",
		"res://assets/sprites/tiles/co_de_palace_floor.png",
		"res://assets/sprites/tiles/cuu_tieu_blood_clouds.png",
		"res://assets/sprites/tiles/o_than_wedding_plaza.png",
		"res://assets/sprites/tiles/dai_thien_cosmic_bridge.png"
	]
	for tp in new_tiles:
		var ttex: Texture2D = load(tp)
		_assert(ttex != null and ttex.get_width() == 128 and ttex.get_height() == 128, "New regional tile is 128x128: " + tp)

	# Kiểm tra 47 sprite NPC mới Ch.04–11
	var new_npcs: Array = [
		"res://assets/sprites/npcs/npc_nap_lan_kiet.png",
		"res://assets/sprites/npcs/npc_phap_ma.png",
		"res://assets/sprites/npcs/npc_gia_hinh_thien.png",
		"res://assets/sprites/npcs/npc_van_son.png",
		"res://assets/sprites/npcs/npc_ho_can.png",
		"res://assets/sprites/npcs/npc_to_thien.png",
		"res://assets/sprites/npcs/npc_bat_phien_auctioneer.png",
		"res://assets/sprites/npcs/npc_thuong_nhan_gia_ma.png",
		"res://assets/sprites/npcs/npc_tu_nghien.png",
		"res://assets/sprites/npcs/npc_han_nhan.png",
		"res://assets/sprites/npcs/npc_lam_tu_nhai.png",
		"res://assets/sprites/npcs/npc_lieu_kinh.png",
		"res://assets/sprites/npcs/npc_thien_doc_nu.png",
		"res://assets/sprites/npcs/npc_vu_ho_phap.png",
		"res://assets/sprites/npcs/npc_dia_yeu_khoi.png",
		"res://assets/sprites/npcs/npc_mac_thien_hanh.png",
		"res://assets/sprites/npcs/npc_han_tuyet.png",
		"res://assets/sprites/npcs/npc_phong_ton_gia.png",
		"res://assets/sprites/npcs/npc_thien_hoa_ton_gia.png",
		"res://assets/sprites/npcs/npc_duong_chan.png",
		"res://assets/sprites/npcs/npc_huyen_khong_tu.png",
		"res://assets/sprites/npcs/npc_tao_dinh.png",
		"res://assets/sprites/npcs/npc_hung_chien.png",
		"res://assets/sprites/npcs/npc_thiet_kiem.png",
		"res://assets/sprites/npcs/npc_van_van_hoa_tong.png",
		"res://assets/sprites/npcs/npc_thanh_lan_dau_ton.png",
		"res://assets/sprites/npcs/npc_duoc_tran_ban_thanh.png",
		"res://assets/sprites/npcs/npc_tu_nghien_long_hoang.png",
		"res://assets/sprites/npcs/npc_hac_kinh.png",
		"res://assets/sprites/npcs/npc_co_nguyen.png",
		"res://assets/sprites/npcs/npc_tieu_huyen.png",
		"res://assets/sprites/npcs/npc_tieu_tieu.png",
		"res://assets/sprites/npcs/npc_bo_de_co_thu.png",
		"res://assets/sprites/npcs/npc_dan_thap_lao_to.png",
		"res://assets/sprites/npcs/npc_yeu_minh.png",
		"res://assets/sprites/npcs/npc_bac_vuong.png",
		"res://assets/sprites/npcs/npc_tinh_lien_yeu_thanh.png",
		"res://assets/sprites/npcs/npc_tieu_y.png",
		"res://assets/sprites/npcs/npc_huan_nhi_dau_thanh.png",
		"res://assets/sprites/npcs/npc_duoc_dien_lao_to.png",
		"res://assets/sprites/npcs/npc_viem_tan_loi_doanh.png",
		"res://assets/sprites/npcs/npc_tieu_chien_reunion.png",
		"res://assets/sprites/npcs/npc_chuc_khon_long_hoang.png",
		"res://assets/sprites/npcs/npc_da_xa_co_de_statue.png",
		"res://assets/sprites/npcs/npc_huan_nhi_bride.png",
		"res://assets/sprites/npcs/npc_thai_lan_bride.png",
		"res://assets/sprites/npcs/npc_dai_thien_portal.png"
	]
	for np in new_npcs:
		var ntex: Texture2D = load(np)
		_assert(ntex != null and ntex.get_width() >= 92 and ntex.get_height() >= 92, "New Ch.04-11 NPC sprite loads cleanly: " + np)


# =========================================================
# SUITE 10: CH.06 SYSTEMS (PAN GATE, ZI YAN, VAN LAC, DAU VUONG)
# =========================================================
func _suite_10_ch06_systems() -> void:
	print("[Suite 10] Ch.06 Systems (Pan Gate, Zi Yan #5, Van Lac #14, Dau Vuong Wings, Core Bang 5)...")
	PlayerData.reset_for_new_game(1)

	# 1. Bàn Môn khóa trước khi có cờ ch06_ban_mon_founded
	_assert(not PanGateMgr.is_unlocked(PlayerData), "Pan Gate locked on new game")
	var pre_up: Dictionary = PanGateMgr.upgrade_hall(PlayerData, "dan_duong")
	_assert(not bool(pre_up.get("ok", true)), "Upgrade blocked while Pan Gate locked")

	# 2. Thành lập Bàn Môn & nâng tối đa cả 3 Phân Đường -> FLAG_PAN_GATE_LEVEL_MAX
	PlayerData.set_story_flag("ch06_ban_mon_founded")
	_assert(PanGateMgr.is_unlocked(PlayerData), "Pan Gate unlocked after ch06_ban_mon_founded")
	PlayerData.fire_energy = 5000
	PlayerData.gold = 200000
	for hid in ["dan_duong", "vo_duong", "am_duong"]:
		for lv in range(1, 4):
			var ur: Dictionary = PanGateMgr.upgrade_hall(PlayerData, hid)
			_assert(bool(ur.get("ok", false)), "Pan Gate upgraded %s -> Lv.%d" % [hid, lv], str(ur))
	_assert(PlayerData.has_flag("FLAG_PAN_GATE_LEVEL_MAX"), "Maxing all 3 Pan Gate halls grants FLAG_PAN_GATE_LEVEL_MAX")
	_assert(is_equal_approx(PanGateMgr.get_atk_bonus_pct(PlayerData), 12.0), "Vo Duong Lv.3 grants +12% ATK")
	_assert(is_equal_approx(PanGateMgr.get_alchemy_bonus_pct(PlayerData), 15.0), "Dan Duong Lv.3 grants +15% Alchemy")

	# 3. Thu hoạch thụ động Bàn Môn & chống spam cooldown 45s
	PlayerData.playtime_sec = 200.0
	var fe_before: int = PlayerData.fire_energy
	var hv1: Dictionary = PanGateMgr.claim_passive_harvest(PlayerData)
	_assert(bool(hv1.get("ok", false)) and PlayerData.fire_energy > fe_before, "Pan Gate passive harvest succeeded", str(hv1))
	var hv2: Dictionary = PanGateMgr.claim_passive_harvest(PlayerData)
	_assert(not bool(hv2.get("ok", true)), "Pan Gate passive harvest enforces cooldown")

	# 4. Đồng hành #5 Tử Nghiên: tầm bảo & tăng +45% Radar + Hút đồ
	var base_radar: float = PlayerData.get_soul_radar_radius()
	var base_magnet: float = PlayerData.get_loot_magnet_radius()
	PlayerData.set_story_flag("ch06_tu_nghien_joined")
	_assert(PlayerData.unlocked_companions.has("tu_nghien"), "ch06_tu_nghien_joined unlocks Companion #5 tu_nghien")
	PlayerData.active_companion_id = "tu_nghien"
	_assert(PlayerData.get_soul_radar_radius() > base_radar * 1.40, "Zi Yan boosts Soul Radar by +45%")
	_assert(PlayerData.get_loot_magnet_radius() > base_magnet * 1.40, "Zi Yan boosts Loot Magnet by +45%")
	PlayerData.add_item("pill_dan_hoan_ngot", 2)
	var fg1: Dictionary = PanGateMgr.send_ziyan_forage(PlayerData, true)
	var fg2: Dictionary = PanGateMgr.send_ziyan_forage(PlayerData, false)
	_assert(bool(fg1.get("ok", false)) and bool(fg2.get("ok", false)), "Zi Yan forage works with candy and fire_energy")
	_assert(PlayerData.get_item_count("herb_thanh_moc_tien_dang") >= 10, "Zi Yan forage yielded Ch.06 herbs")

	# 5. Luyện hóa #14 Vẫn Lạc Tâm Viêm -> Passive 24/7 + Song Dị Hỏa Liên + Đấu Vương Hóa Dực + Lưu Ly Liên Tâm Ấn
	PlayerData.unlock_flame("di_hoa_19_thanh_lien", false)
	PlayerData.set_story_flag("ch06_absorbed_van_lac")
	_assert(PlayerData.has_van_lac_passive(), "Van Lac passive enabled after ch06_absorbed_van_lac")
	_assert(PlayerData.has_dau_vuong_wings() and PlayerData.realm_index >= 6, "Dau Vuong wings & realm>=6 enabled")
	_assert(PlayerData.lotus_fusion_flames.has("di_hoa_14_van_lac") and PlayerData.lotus_fusion_flames.has("di_hoa_19_thanh_lien"), "Dual Heavenly Flames auto-fused into Fire Lotus")
	_assert(PlayerData.is_skill_unlocked("luu_ly_lien_tam"), "Skill luu_ly_lien_tam unlocked")

	# 6. Khảm Ma Hạch mới core_bang_5 & Buff Ký Ức Phản Sư vs Hàn Phong
	PlayerData.add_item("core_bang_5", 1)
	var sock_res: Dictionary = PlayerData.socket_monster_core(0, "core_bang_5")
	_assert(bool(sock_res.get("ok", false)) and PlayerData.weapon_core_sockets[0] == "core_bang_5", "Socketed core_bang_5 cleanly")
	PlayerData.set_story_flag("ch06_duoc_lao_memory_done")
	_assert(PlayerData.get_enemy_damage_bonus_mult("han_phong_boss", "Dược Hoàng Hàn Phong") >= 1.24, "Duoc Lao memory grants +25% DMG vs Han Feng")

	# 7. Kịch bản đối thoại JSON Chương 06
	var d6: Dictionary = GameDatabase.get_dialogue_def("ch06_han_nhan_ban_mon")
	_assert(not d6.is_empty(), "Ch.06 dialogue role ch06_han_nhan_ban_mon loaded")
	var emitted6: Array = [false]
	var cb6a := func(_s: String, _a: String, _l: Array, _x: Variant) -> void: emitted6[0] = true
	var cb6b := func(_s: String, _a: String, _l: Array, _x: String) -> void: emitted6[0] = true
	EventBus.dialogue_choice_requested.connect(cb6a)
	EventBus.dialogue_requested.connect(cb6b)
	var ran6: bool = StoryDlgRunner.run_data_driven_dialogue(d6, "Hàn Nhàn", "res://assets/sprites/npcs/npc_han_nhan.png")
	EventBus.dialogue_choice_requested.disconnect(cb6a)
	EventBus.dialogue_requested.disconnect(cb6b)
	_assert(ran6 and bool(emitted6[0]), "StoryDialogueRunner runs Ch.06 JSON dialogue cleanly")

	# 8. Kiểm thử gói Combat VFX & Procedural Polish 60 FPS (char_motion_polish.gdshader + 4 mode SkillVfxBurst mới)
	var cm_mat: ShaderMaterial = VfxAssets.create_char_motion_material(Color("#00F5D4"), 0.008, 0.5)
	_assert(cm_mat != null and cm_mat.shader != null, "char_motion_polish.gdshader loads and creates ShaderMaterial")
	for v_mode in ["melee_slash", "windup_charge", "boss_strike_arc", "tyrant_claw", "glazed_lotus_vortex"]:
		var vb := SkillVfxBurst.new()
		add_child(vb)
		vb.configure(v_mode, Vector2.ZERO, Vector2.RIGHT, 120.0, 0.40, Color("#FFFFFF"), Color("#00F5D4"), Color("#9D4EDD"))
		_assert(vb.vfx_mode == v_mode, "SkillVfxBurst configures mode cleanly: " + v_mode)
		vb.queue_free()


# =========================================================
# SUITE 11: CH.07 SYSTEMS (VIÊM MINH, MA ĐỘC BAN, TAM SẮC HỎA LIÊN, ĐỊA YÊU KHÔI, HẮC HOÀNG TÔNG)
# =========================================================
func _suite_11_ch07_systems() -> void:
	print("[Suite 11] Ch.07 Systems (Viem Minh 4-Hall, Ma Doc Ban, Tri-Flame Lotus, Dia Yeu Khoi #6, Hac Hoang Auction)...")
	PlayerData.reset_for_new_game(1)

	# 1. Đỉnh Núi Chia Ly -> Phiên Hải Ấn & Đột Phá Đấu Hoàng -> Thiên Hỏa Nhị Biến
	PlayerData.set_story_flag("ch07_huan_nhi_farewell_done")
	_assert(PlayerData.is_skill_unlocked("phien_hai_an"), "ch07_huan_nhi_farewell_done unlocks phien_hai_an")
	PlayerData.set_story_flag("ch07_broke_dau_hoang")
	_assert(PlayerData.realm_index >= 7 and PlayerData.is_skill_unlocked("thien_hoa_nhi_bien"), "ch07_broke_dau_hoang grants Dau Hoang & thien_hoa_nhi_bien")
	_assert(is_equal_approx(PlayerData.get_attack_reach_multiplier(), 1.35), "Dau Hoang attack reach multiplier is 1.35")

	# 2. Tam Sắc Phật Nộ Hỏa Liên khi Dược Lão bị bắt + Ấn Ký #11 Cốt Linh Lãnh Hỏa
	PlayerData.unlock_flame("di_hoa_19_thanh_lien", false)
	PlayerData.unlock_flame("di_hoa_14_van_lac", false)
	PlayerData.set_story_flag("ch07_duoc_lao_captured")
	_assert(PlayerData.has_flag("FLAG_DUOC_LAO_CAPTURED"), "FLAG_DUOC_LAO_CAPTURED set")
	_assert(PlayerData.unlocked_flames.has("di_hoa_11_cot_linh"), "Duoc Lao imprint unlocks #11 Cot Linh Lanh Hoa")
	_assert(PlayerData.lotus_fusion_flames.size() == 3 and PlayerData.lotus_fusion_flames.has("di_hoa_11_cot_linh"), "Tri-Flame Lotus auto-fused (3 flames)")

	# 3. Tiến hóa Bàn Môn -> Đế Quốc VIÊM MINH (4 Đường + FLAG_YAN_ALLIANCE_MAX + 3 Đấu Tông khiêu chiến)
	PlayerData.set_story_flag("ch07_viem_minh_founded")
	_assert(PanGateMgr.is_viem_minh_evolved(PlayerData), "Viem Minh evolved after ch07_viem_minh_founded")
	_assert(PanGateMgr.get_hall_defs_for(PlayerData).size() == 4, "Viem Minh exposes all 4 Imperial halls")
	_assert(PanGateMgr.get_strong_ranking_roster_for(PlayerData).size() == 8, "Viem Minh adds 3 Dau Tong challengers (total 8)")
	PlayerData.fire_energy = 10000
	PlayerData.gold = 500000
	for hid in ["dan_duong", "vo_duong", "am_duong", "am_vong"]:
		for lv in range(1, 4):
			var ur: Dictionary = PanGateMgr.upgrade_hall(PlayerData, hid)
			_assert(bool(ur.get("ok", false)), "Viem Minh upgraded %s -> Lv.%d" % [hid, lv], str(ur))
	_assert(PlayerData.has_flag("FLAG_YAN_ALLIANCE_MAX"), "Maxing all 4 Viem Minh halls sets FLAG_YAN_ALLIANCE_MAX")
	_assert(is_equal_approx(PanGateMgr.get_crit_bonus_pct(PlayerData), 12.0), "Am Vong Lv.3 grants +12% Crit Chance")

	# 4. Đoàn tụ Thiên Độc Nữ Tiểu Y Tiên (tiến hóa nhãn & đồng hành)
	PlayerData.set_story_flag("ch07_thien_doc_nu_joined")
	_assert(PlayerData.get_companion_display_name("tieu_y_tien").find("Thiên Độc Nữ") != -1, "Tieu Y Tien evolves to Thien Doc Nu display title")

	# 5. Phong ấn Ma Độc Ban: khóa 10% Max QI + tích lũy +1% ATK mỗi lần hạ Boss!
	PlayerData.set_story_flag("ch07_killed_hat_tat_nham")
	_assert(PlayerData.has_ma_doc_ban(), "Ma Doc Ban active after killing Hat Tat Nham")
	var atk_before_mdb: float = PlayerData.get_atk()
	PlayerData._on_enemy_killed("van_son_boss", true)
	PlayerData._on_enemy_killed("dia_ma_lao_quy_boss", true)
	_assert(PlayerData.ma_doc_ban_stacks == 2, "Boss kills increment ma_doc_ban_stacks", "got %d" % PlayerData.ma_doc_ban_stacks)
	_assert(PlayerData.get_atk() > atk_before_mdb, "Ma Doc Ban stacks boost ATK")
	# So sánh Max QI cùng cảnh giới khi có Ma Độc Ban (90%) so với khi giải trừ (100%)
	var qi_with_mdb: float = PlayerData.get_max_qi()
	PlayerData.story_flags["ch08_ma_doc_ban_cured"] = true
	var qi_without_mdb: float = PlayerData.get_max_qi()
	PlayerData.story_flags.erase("ch08_ma_doc_ban_cured")
	_assert(is_equal_approx(qi_with_mdb, qi_without_mdb * 0.90), "Ma Doc Ban caps Max QI to 90%", "with=%.1f without=%.1f" % [qi_with_mdb, qi_without_mdb])

	# 6. Nhốt hồn Hàn Phong -> #15 Hải Tâm Diễm & Rèn Vệ Sĩ Bất Tử Địa Yêu Khôi (#6 [G] + [T] Assist!)
	PlayerData.set_story_flag("ch07_captured_han_phong_jar")
	_assert(PlayerData.unlocked_flames.has("di_hoa_15_hai_tam") and PlayerData.has_flag("FLAG_HAN_FENG_CAPTURED_JAR"), "Capturing Han Feng unlocks #15 Hai Tam Diem")
	PlayerData.set_story_flag("ch07_dia_yeu_khoi_forged")
	_assert(PlayerData.unlocked_companions.has("dia_yeu_khoi"), "Dia Yeu Khoi unlocked as Companion #6")
	_assert(PlayerData.get_assist_mode() == "dia_yeu_khoi", "[T] Assist mode upgrades to dia_yeu_khoi")

	# 7. Khảm Vạn Hạt Độc Hạch Cấp 6 (core_doc_6) & Đấu Giá Hắc Hoàng Tông (#3 Venue)
	PlayerData.add_item("core_doc_6", 1)
	var sock6: Dictionary = PlayerData.socket_monster_core(0, "core_doc_6")
	_assert(bool(sock6.get("ok", false)) and PlayerData.weapon_core_sockets[0] == "core_doc_6", "Socketed core_doc_6 cleanly")
	var lots_hht: Array = AuctionSystem.generate_auction_lots("hac_hoang_tong")
	_assert(lots_hht.size() == 3 and AuctionSystem.get_venue_name("hac_hoang_tong").find("Hắc Hoàng Tông") != -1, "Hac Hoang Tong 3rd auction venue generates 3 lots")

	# 8. Công thức Thất Phẩm Phá Tông Đan (recipe_pha_tong_dan) tôn trọng Cảnh Linh Hồn (SOUL >= 250)
	var rec_pt: Dictionary = {}
	for r in GameDatabase.recipes_list:
		if str(r.get("id", "")) == "recipe_pha_tong_dan":
			rec_pt = r
			break
	_assert(not rec_pt.is_empty() and int(rec_pt.get("tier", 0)) == 7, "recipe_pha_tong_dan Tier 7 loaded")
	PlayerData.reset_for_new_game(1)
	for ik in (rec_pt.get("ingredients", {}) as Dictionary).keys():
		PlayerData.add_item(str(ik), int((rec_pt["ingredients"] as Dictionary)[ik]) + 1)
	PlayerData.bonus_soul = 170
	_assert(not bool(AlchemySystem.can_craft(rec_pt).get("ok", true)), "Pha Tong Dan blocked in Pham Canh (SOUL < 250)")
	PlayerData.bonus_soul = 260
	_assert(bool(AlchemySystem.can_craft(rec_pt).get("ok", false)), "Pha Tong Dan craftable in Linh Canh (SOUL >= 250)")

	# 9. Kịch bản đối thoại JSON Ch.07 & 3 VFX Mode mới (ocean_seal, flame_buff_tier2, dia_yeu_khoi_assist)
	var d7: Dictionary = GameDatabase.get_dialogue_def("ch07_wormhole_departure")
	_assert(not d7.is_empty(), "Ch.07 dialogue role ch07_wormhole_departure loaded")
	var emitted7: Array = [false]
	var cb7a := func(_s: String, _a: String, _l: Array, _x: Variant) -> void: emitted7[0] = true
	var cb7b := func(_s: String, _a: String, _l: Array, _x: String) -> void: emitted7[0] = true
	EventBus.dialogue_choice_requested.connect(cb7a)
	EventBus.dialogue_requested.connect(cb7b)
	var ran7: bool = StoryDlgRunner.run_data_driven_dialogue(d7, "Đội Hình Trung Châu", "res://assets/sprites/npcs/npc_dia_yeu_khoi.png")
	EventBus.dialogue_choice_requested.disconnect(cb7a)
	EventBus.dialogue_requested.disconnect(cb7b)
	_assert(ran7 and bool(emitted7[0]), "StoryDialogueRunner runs Ch.07 JSON dialogue cleanly")

	for v7 in ["ocean_seal", "flame_buff_tier2", "dia_yeu_khoi_assist"]:
		var vb7 := SkillVfxBurst.new()
		add_child(vb7)
		vb7.configure(v7, Vector2.ZERO, Vector2.RIGHT, 180.0, 0.55, Color("#FFFFFF"), Color("#38BDF8"), Color("#FFD166"))
		_assert(vb7.vfx_mode == v7, "SkillVfxBurst configures Ch.07 mode cleanly: " + v7)
		vb7.queue_free()


# =========================================================
# SUITE 12: CH.08 SYSTEMS (ĐẤU TÔNG, MA ĐỘC BAN CURE, THIÊN HỎA #7, #12/#9 DỊ HỎA, BÁT PHẨM, THIÊN BẢO PHƯỜNG)
# =========================================================
func _suite_12_ch08_systems() -> void:
	print("[Suite 12] Ch.08 Systems (Dau Tong, Ma Doc Ban Cure, Thien Hoa #7, #12/#9 Flames, Tier 8 Pill, Thien Bao Phuong)...")
	PlayerData.reset_for_new_game(1)

	# 1. Thiên Sơn Huyết Đàm -> Đột phá Đấu Tông, Đạp Hư Không, Không Gian Phong Tỏa & mở rộng Đấu Trường Cường Bảng lên 11 Boss!
	PlayerData.set_story_flag("ch07_viem_minh_founded")
	PlayerData.set_story_flag("ch08_broke_dau_tong")
	_assert(PlayerData.realm_index >= 8 and PlayerData.has_dau_tong_void_step(), "ch08_broke_dau_tong grants Dau Tong & Void Step")
	_assert(PlayerData.is_skill_unlocked("khong_gian_phong_toa"), "ch08_broke_dau_tong unlocks khong_gian_phong_toa")
	_assert(is_equal_approx(PlayerData.get_attack_reach_multiplier(), 1.42), "Dau Tong attack reach multiplier is 1.42")
	_assert(PanGateMgr.get_strong_ranking_roster_for(PlayerData).size() == 11, "Ch.08 expands Strong Ranking roster to 11 challengers")

	# 2. Hóa giải Ma Độc Ban -> khôi phục 100% Max QI, +15% ATK cộng hưởng, tiến hóa Tiểu Y Tiên & phục sinh Đồng Hành #7 Thiên Hỏa Tôn Giả!
	PlayerData.story_flags["ch07_ma_doc_ban_active"] = true
	var qi_before_cure: float = PlayerData.get_max_qi()
	PlayerData.set_story_flag("ch08_ma_doc_ban_cured")
	_assert(not PlayerData.has_ma_doc_ban(), "Ma Doc Ban fully cured after ch08_ma_doc_ban_cured")
	_assert(PlayerData.get_max_qi() > qi_before_cure * 1.09, "Curing Ma Doc Ban restores 100% Max QI")
	_assert(PlayerData.unlocked_companions.has("thien_hoa_ton_gia"), "Companion #7 thien_hoa_ton_gia unlocked")
	_assert(PlayerData.get_companion_display_name("tieu_y_tien").find("Tam Tinh Đấu Tôn") != -1, "Tieu Y Tien evolves to Tam Tinh Dau Ton")

	# 3. Cổ Huân Nhi giáng lâm -> Ngũ Ấn Hợp Nhất Cổ Đế Ấn & Phần Viêm Cốc -> #12 Cửu Long + Thiên Hỏa Tam Biến (+85% ATK, -30% CD)!
	PlayerData.set_story_flag("ch08_huan_nhi_de_an_done")
	_assert(PlayerData.is_skill_unlocked("de_an_co_de_an"), "ch08_huan_nhi_de_an_done unlocks de_an_co_de_an")
	PlayerData.set_story_flag("ch08_got_tam_huyen_tam_bien")
	_assert(PlayerData.unlocked_flames.has("di_hoa_12_cuu_long") and PlayerData.is_skill_unlocked("thien_hoa_tam_bien"), "Phan Viem Coc grants #12 Cuu Long & thien_hoa_tam_bien")
	var atk_pre_tb: float = PlayerData.get_atk()
	var cd_pre_tb: float = PlayerData.get_cooldown_multiplier()
	PlayerData.is_tam_bien_active = true
	_assert(PlayerData.get_atk() > atk_pre_tb * 1.80, "Thien Hoa Tam Bien boosts ATK by +85%")
	_assert(PlayerData.get_cooldown_multiplier() < cd_pre_tb, "Thien Hoa Tam Bien reduces skill cooldowns by 30%")
	PlayerData.is_tam_bien_active = false

	# 4. Nổ tung Bia Trắc Hồn -> Kinh Hồn Chưởng & Đan Hội Quán Quân -> Tam Thiên Lôi Huyễn Thân + Chuẩn Thiên Yêu Khôi [T]!
	var soul_pre_st: int = PlayerData.get_soul()
	PlayerData.set_story_flag("ch08_stele_shattered")
	_assert(PlayerData.is_skill_unlocked("kinh_hon_chuong") and PlayerData.get_soul() >= soul_pre_st + 400, "Shattering Soul Stele unlocks kinh_hon_chuong & +420 SOUL")
	PlayerData.set_story_flag("ch07_dia_yeu_khoi_forged")
	PlayerData.set_story_flag("ch08_dan_hoi_champion")
	_assert(PlayerData.is_skill_unlocked("tam_thien_loi_huyen_than"), "Dan Hoi Champion unlocks tam_thien_loi_huyen_than")
	_assert(PlayerData.get_assist_mode() == "thien_yeu_khoi", "[T] Assist upgrades to Chuan Thien Yeu Khoi")
	_assert(PlayerData.get_companion_display_name("dia_yeu_khoi").find("Chuẩn Thiên Yêu Khôi") != -1, "Dia Yeu Khoi companion evolves to Chuan Thien Yeu Khoi")

	# 5. Đấu Giá Thiên Bảo Phường (#4 Venue) & Khảm Song Ma Hạch Cấp 7 (core_loi_7, core_tinh_7) + Hồi ức Huyền Y (-25% DMG Hồn Điện)!
	var lots_tbp: Array = AuctionSystem.generate_auction_lots("thien_bao_phuong")
	_assert(lots_tbp.size() == 3 and AuctionSystem.get_venue_name("thien_bao_phuong").find("Thiên Bảo Phường") != -1, "Thien Bao Phuong 4th auction venue generates 3 lots")
	var soul_pre_c7: int = PlayerData.get_soul()
	var flame_pre_c7: float = PlayerData.get_flame_dmg_multiplier()
	PlayerData.add_item("core_loi_7", 1)
	PlayerData.add_item("core_tinh_7", 1)
	var sc_l7: Dictionary = PlayerData.socket_monster_core(0, "core_loi_7")
	var sc_t7: Dictionary = PlayerData.socket_monster_core(1, "core_tinh_7")
	_assert(bool(sc_l7.get("ok", false)) and bool(sc_t7.get("ok", false)), "Socketed Tier 7 monster cores core_loi_7 & core_tinh_7 cleanly")
	_assert(PlayerData.get_soul() >= soul_pre_c7 + 80 and PlayerData.get_flame_dmg_multiplier() >= flame_pre_c7 + 0.34, "core_tinh_7 grants +80 SOUL & +35% Flame DMG")
	PlayerData.set_story_flag("ch08_huyen_y_memory_done")
	_assert(is_equal_approx(PlayerData.get_enemy_damage_taken_mult("mo_cot_lao_nhan_boss", "Mộ Cốt Lão Nhân"), 0.75), "Huyen Y memory / pendant reduces Soul Hall damage by 25%")

	# 6. Bát Phẩm Sinh Cốt Dung Huyết Đan (Tier 8): Chặn ở Linh Cảnh (SOUL < 900), Cho phép ở Thiên Cảnh (SOUL >= 900)!
	var rec_t8: Dictionary = {}
	for r in GameDatabase.recipes_list:
		if str(r.get("id", "")) == "recipe_sinh_cot_dung_huyet":
			rec_t8 = r
			break
	_assert(not rec_t8.is_empty() and int(rec_t8.get("tier", 0)) == 8, "Tier 8 recipe_sinh_cot_dung_huyet loaded")
	PlayerData.reset_for_new_game(1)
	for ik in (rec_t8.get("ingredients", {}) as Dictionary).keys():
		PlayerData.add_item(str(ik), int((rec_t8["ingredients"] as Dictionary)[ik]) + 1)
	PlayerData.bonus_soul = 750
	_assert(not bool(AlchemySystem.can_craft(rec_t8).get("ok", true)), "Tier 8 Pill blocked in Linh Canh (SOUL < 900)")
	PlayerData.bonus_soul = 920
	_assert(bool(AlchemySystem.can_craft(rec_t8).get("ok", false)), "Tier 8 Pill craftable in Thien Canh (SOUL >= 900)")

	# 7. Chốt Chương 08 -> #9 Tam Thiên Diễm Viêm Hỏa (Bất Tử Chi Thân) & Tự động hợp nhất Tứ Sắc Hủy Diệt Hỏa Liên!
	PlayerData.unlock_flame("di_hoa_19_thanh_lien", false)
	PlayerData.unlock_flame("di_hoa_14_van_lac", false)
	PlayerData.unlock_flame("di_hoa_11_cot_linh", false)
	PlayerData.set_story_flag("ch08_completed")
	_assert(PlayerData.has_tam_thien_immortal_body() and PlayerData.unlocked_flames.has("di_hoa_09_tam_thien"), "ch08_completed unlocks #9 Tam Thien Diem Viem Hoa & Immortal Body")
	_assert(PlayerData.lotus_fusion_flames.size() == 4 and PlayerData.lotus_fusion_flames.has("di_hoa_09_tam_thien"), "Quad-Flame Lotus auto-fused (4 Heavenly Flames)")

	# 8. Kịch bản đối thoại JSON Ch.08 & 6 VFX Mode 60 FPS mới của Ch.08
	var d8: Dictionary = GameDatabase.get_dialogue_def("ch08_dan_hoi_finals")
	_assert(not d8.is_empty(), "Ch.08 dialogue role ch08_dan_hoi_finals loaded")
	var emitted8: Array = [false]
	var cb8a := func(_s: String, _a: String, _l: Array, _x: Variant) -> void: emitted8[0] = true
	var cb8b := func(_s: String, _a: String, _l: Array, _x: String) -> void: emitted8[0] = true
	EventBus.dialogue_choice_requested.connect(cb8a)
	EventBus.dialogue_requested.connect(cb8b)
	var ran8: bool = StoryDlgRunner.run_data_driven_dialogue(d8, "Thánh Đan Quảng Trường", "res://assets/sprites/npcs/npc_tao_dinh.png")
	EventBus.dialogue_choice_requested.disconnect(cb8a)
	EventBus.dialogue_requested.disconnect(cb8b)
	_assert(ran8 and bool(emitted8[0]), "StoryDialogueRunner runs Ch.08 JSON dialogue cleanly")

	for v8 in ["space_lock", "emperor_five_seals", "flame_buff_tier3", "soul_shock_palm", "thunder_clone", "thien_yeu_khoi_assist", "ground_crater", "dan_lei_pillar"]:
		var vb8 := SkillVfxBurst.new()
		add_child(vb8)
		vb8.configure(v8, Vector2.ZERO, Vector2.RIGHT, 210.0, 0.65, Color("#FFFFFF"), Color("#C77DFF"), Color("#FFD166"))
		_assert(vb8.vfx_mode == v8, "SkillVfxBurst configures Ch.08/VFX 2.0 mode cleanly: " + v8)
		vb8.queue_free()

	# 9. Kiểm thử gói VFX 2.0 (v0.7.1): 2 Shader mới + 6 Texture nâng cấp HD (128x128 / 96x128 / 32x32)
	var sw_mat: ShaderMaterial = VfxAssets.create_space_shockwave_material()
	var ed_mat: ShaderMaterial = VfxAssets.create_energy_dissolve_material(Color("#FFFFFF"), Color("#00F5D4"), Color("#9D4EDD"))
	_assert(sw_mat != null and sw_mat.shader != null, "VFX 2.0 space_shockwave.gdshader loads cleanly")
	_assert(ed_mat != null and ed_mat.shader != null, "VFX 2.0 vfx_energy_dissolve.gdshader loads cleanly")
	var vfx_dims: Dictionary = {
		"res://assets/sprites/vfx/fire_lotus.png": Vector2i(128, 128),
		"res://assets/sprites/vfx/slash_arc.png": Vector2i(128, 128),
		"res://assets/sprites/vfx/wing_plume.png": Vector2i(96, 128),
		"res://assets/sprites/pickups/qi_orb.png": Vector2i(32, 32),
		"res://assets/sprites/pickups/monster_core.png": Vector2i(32, 32),
		"res://assets/sprites/pickups/herb_item.png": Vector2i(32, 32)
	}
	for vp in vfx_dims.keys():
		var vtex: Texture2D = load(str(vp))
		var exp_sz: Vector2i = vfx_dims[vp]
		_assert(vtex != null and vtex.get_width() == exp_sz.x and vtex.get_height() == exp_sz.y, "VFX 2.0 HD texture matches %dx%d: %s" % [exp_sz.x, exp_sz.y, str(vp)], "got %s" % (str(vtex.get_size()) if vtex != null else "null"))


# =========================================================
# SUITE 13: v0.7.2 AUDIO CH.05–08 (11 BGMs) & MODULAR REFACTOR GUARD
# =========================================================
func _suite_13_audio_and_modular_refactor() -> void:
	print("[Suite 13] v0.7.2 Ch.05-08 BGMs (11 Tracks), 46-Map BGM Links & 10 Extracted Modules...")
	var expected_bgms: Array[String] = [
		"bgm_peaceful", "bgm_wild", "bgm_boss", "bgm_desert", "bgm_lava", "bgm_capital", "bgm_yunlan",
		"bgm_hac_giac", "bgm_gia_nam", "bgm_poison", "bgm_zhongzhou"
	]
	_assert(AudioManager.bgm_tracks.size() >= 11, "AudioManager built 11+ procedural BGM tracks", "got %d" % AudioManager.bgm_tracks.size())
	for bk in expected_bgms:
		var st = AudioManager.bgm_tracks.get(bk, null)
		_assert(st is AudioStreamWAV and (st as AudioStreamWAV).data.size() > 10000 and (st as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD, "BGM track valid looping WAV: " + bk)

	# Xác nhận toàn bộ 46 bản đồ dùng khóa chuẩn "bgm" (không còn "bgm_track" lỗi) và trỏ tới track hợp lệ
	var used_bgms: Dictionary = {}
	for mid in GameDatabase.maps_by_id.keys():
		var md: Dictionary = GameDatabase.maps_by_id[mid]
		var bm: String = str(md.get("bgm", ""))
		_assert(not md.has("bgm_track"), "Map has no stale bgm_track key: " + str(mid))
		_assert(bm != "" and AudioManager.bgm_tracks.has(bm), "Map BGM resolves to valid AudioManager track: %s -> %s" % [str(mid), bm])
		used_bgms[bm] = true
	for new_bk in ["bgm_hac_giac", "bgm_gia_nam", "bgm_poison", "bgm_zhongzhou"]:
		_assert(used_bgms.has(new_bk), "New Ch.05-08 BGM actively wired to maps: " + new_bk)
		AudioManager.play_bgm(new_bk)
		_assert(AudioManager.current_bgm_name == new_bk, "AudioManager switches active BGM cleanly: " + new_bk)

	# Xác nhận toàn bộ 10 mô-đun mới tách ở v0.7.2 nạp sạch & hoạt động đúng hợp đồng
	var new_modules: Array[String] = [
		"res://scripts/systems/audio_bgm_ch05_08.gd",
		"res://scripts/systems/heroine_affection_manager.gd",
		"res://scripts/systems/story_progression_helper.gd",
		"res://scripts/systems/regional_weather_builder.gd",
		"res://scripts/systems/world_navigation_helper.gd",
		"res://scripts/entities/boss_skill_executor.gd",
		"res://scripts/entities/player_skill_executor.gd",
		"res://scripts/ui/panels/panel_skills_cultivation.gd",
		"res://scripts/ui/panels/hud_moba_dock_helper.gd",
		"res://scripts/ui/panels/hud_dialogue_controller.gd"
	]
	for mp in new_modules:
		var sc: Script = load(mp)
		_assert(sc != null, "Extracted module script loads cleanly: " + mp)

	var h_mod = load("res://scripts/systems/heroine_affection_manager.gd")
	_assert(h_mod.get_heroine_profiles().size() == 5, "HeroineAffectionManager returns all 5 heroines")
	var b_mod = load("res://scripts/entities/boss_skill_executor.gd")
	for bid in ["gia_liet_ao_boss", "nap_lan_yen_nhien_boss", "la_hau_boss", "han_phong_boss", "dia_ma_lao_quy_boss", "tam_thien_diem_viem_boss"]:
		var col: Color = b_mod.get_signature_color(bid)
		_assert(col.a > 0.9, "BossSkillExecutor signature color valid for " + bid)

	# Bảo vệ kiến trúc: không script cốt lõi nào trong 5 file đã refactor vượt quá 2.000 dòng
	for core_p in [
		"res://scripts/autoload/player_data.gd",
		"res://scripts/entities/enemy_controller.gd",
		"res://scripts/entities/player_controller.gd",
		"res://scripts/ui/hud_controller.gd",
		"res://scripts/systems/world_stage_manager.gd"
	]:
		var f := FileAccess.open(core_p, FileAccess.READ)
		var loc: int = f.get_as_text().split("\n").size() if f != null else 99999
		_assert(loc < 2000, "Refactored core script stays under 2000 LOC: %s (%d LOC)" % [core_p, loc])


# =========================================================
# SUITE 14: v0.8.0 CH.09 SYSTEMS (VONG HỒN · TINH VẪN CÁC · CỬU CHUYỂN · THIÊN MỘ x5 · TỘC VĂN [X])
# =========================================================
func _suite_14_ch09_systems() -> void:
	print("[Suite 14] v0.8.0 Ch.09 Systems (7 Maps, 7 Bosses, 14 BGMs, Nine-Turn, Thien Mo x5, 9 Companions, Tinh Van Cac, Toc Van [X])...")
	PlayerData.reset_for_new_game(1)

	# 1. 3 Bản nhạc nền Ch.09 mới -> tổng 14 BGM hợp lệ & gắn lên 7 map Ch.09
	_assert(AudioManager.bgm_tracks.size() >= 14, "AudioManager built 14+ procedural BGM tracks", "got %d" % AudioManager.bgm_tracks.size())
	for ch09_bk in ["bgm_tinh_van", "bgm_vong_hon", "bgm_thien_mo"]:
		var st = AudioManager.bgm_tracks.get(ch09_bk, null)
		_assert(st is AudioStreamWAV and (st as AudioStreamWAV).data.size() > 10000 and (st as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD, "Ch.09 BGM track valid looping WAV: " + ch09_bk)
		AudioManager.play_bgm(ch09_bk)
		_assert(AudioManager.current_bgm_name == ch09_bk, "AudioManager plays Ch.09 BGM cleanly: " + ch09_bk)
	_assert(load("res://scripts/systems/audio_bgm_ch09.gd") != null, "audio_bgm_ch09.gd loads cleanly")
	_assert(load("res://scripts/systems/nine_turn_manager.gd") != null, "nine_turn_manager.gd loads cleanly")

	# 2. Niết Bàn Đấu Tôn -> Xé Rách Không Gian + Không Gian Đại Thủ Ấn + Thế Lực Cấp 3 Tinh Vẫn Các (5 công trình & 15 Boss Cường Bảng)
	_assert(not NineTurnMgr.is_unlocked(PlayerData), "Nine-Turn locked before Realm 9")
	PlayerData.set_story_flag("ch09_nirvana_awakened")
	_assert(PlayerData.realm_index >= 9 and PlayerData.has_dau_ton_spatial_blink(), "ch09_nirvana_awakened grants Dau Ton & True Spatial Blink")
	_assert(PlayerData.is_skill_unlocked("khong_gian_dai_thu_an"), "ch09_nirvana_awakened unlocks khong_gian_dai_thu_an")
	_assert(is_equal_approx(PlayerData.get_attack_reach_multiplier(), 1.50), "Dau Ton attack reach multiplier is 1.50")
	PlayerData.set_story_flag("ch09_broke_dau_ton")
	_assert(PanGateMgr.is_tinh_van_cac_evolved(PlayerData), "Tinh Van Cac Tier-3 unlocked after ch09_broke_dau_ton")
	_assert(PanGateMgr.get_faction_title(PlayerData).find("TINH VẪN CÁC") != -1, "Faction title evolves to TINH VAN CAC")
	_assert(PanGateMgr.get_hall_defs_for(PlayerData).size() == 5, "Tinh Van Cac exposes all 5 structures incl. Tinh Than Tran")
	_assert(PanGateMgr.get_strong_ranking_roster_for(PlayerData).size() == 15, "Ch.09 expands Strong Ranking roster to 15 Bosses")
	PlayerData.fire_energy = 8000
	PlayerData.gold = 500000
	for lv in range(1, 4):
		var ur_tv: Dictionary = PanGateMgr.upgrade_hall(PlayerData, "tinh_than_tran")
		_assert(bool(ur_tv.get("ok", false)), "Tinh Than Tran upgraded to Lv.%d" % lv, str(ur_tv))
	_assert(is_equal_approx(PanGateMgr.get_def_bonus_pct(PlayerData), 15.0), "Tinh Than Tran Lv.3 grants +15% DEF")

	# 3. Đồng Hành #8 Thanh Lân & #9 Vân Vận + Tiến hóa Long Hoàng Tử Nghiên & Bán Thánh Dược Trần
	PlayerData.set_story_flag("ch09_hoa_tong_saved")
	_assert(PlayerData.unlocked_companions.has("van_van_hoa_tong"), "Companion #9 van_van_hoa_tong unlocked")
	PlayerData.set_story_flag("ch09_thanh_lan_reunited")
	_assert(PlayerData.unlocked_companions.has("thanh_lan"), "Companion #8 thanh_lan unlocked")
	PlayerData.set_story_flag("ch09_got_tao_hoa_palm")
	_assert(PlayerData.is_skill_unlocked("dai_thien_tao_hoa_chuong"), "Viễn Cổ Di Tích unlocks dai_thien_tao_hoa_chuong")
	PlayerData.set_story_flag("ch09_duoc_tran_revived")
	_assert(PlayerData.unlocked_flames.has("di_hoa_11_cot_linh"), "Reviving Ban Thanh Duoc Tran unlocks #11 Cot Linh")
	_assert(PlayerData.get_assist_mode() == "ban_thanh_duoc_tran", "[T] Assist upgrades to Ban Thanh Duoc Tran")
	_assert(PlayerData.get_lotus_max_flames() == 5, "Reviving Duoc Tran unlocks 5-Flame Ngu Sac Hoa Lien")
	_assert(PlayerData.get_companion_display_name("duoc_lao_phantom").find("Bán Thánh") != -1, "Duoc Lao companion evolves to Ban Thanh title")

	# 4. Ngũ Sắc Hỏa Liên (5 ngọn Hỏa) + Thập Tuyệt Kim Khôi Trận (-50% DMG) + Long Hoàng Tử Nghiên
	for fid in ["di_hoa_19_thanh_lien", "di_hoa_14_van_lac", "di_hoa_11_cot_linh", "di_hoa_09_tam_thien", "hoa_sinh_hoa"]:
		PlayerData.unlock_flame(fid, false)
	PlayerData.lotus_fusion_flames = []
	for fid in ["di_hoa_19_thanh_lien", "di_hoa_14_van_lac", "di_hoa_11_cot_linh", "di_hoa_09_tam_thien", "hoa_sinh_hoa"]:
		PlayerData.toggle_lotus_fusion_flame(fid)
	_assert(PlayerData.lotus_fusion_flames.size() == 5, "Ngu Sac Hoa Lien supports 5 fused flames")
	PlayerData.set_story_flag("ch09_forged_ten_puppets")
	_assert(PlayerData.is_skill_unlocked("thap_tuyet_kim_khoi_tran"), "Loi Tri unlocks thap_tuyet_kim_khoi_tran")
	PlayerData.is_kim_khoi_tran_active = true
	_assert(PlayerData.get_enemy_damage_taken_mult("bac_long_vuong_boss", "Bắc Long Vương") <= 0.51, "Thap Tuyet Kim Khoi Tran halves incoming damage (-50%)")
	PlayerData.is_kim_khoi_tran_active = false
	PlayerData.set_story_flag("ch09_co_long_unified")
	_assert(PlayerData.get_companion_display_name("tu_nghien").find("Long Hoàng") != -1, "Tu Nghien evolves to Long Hoang title")

	# 5. Hệ thống Cửu Chuyển Đấu Tôn (0 -> 9 Chuyển = +72% chỉ số) & Thiên Mộ x5 EXP
	PlayerData.set_story_flag("ch09_beat_co_yeu")
	_assert(NineTurnMgr.is_unlocked(PlayerData), "Nine-Turn unlocked at Realm 9")
	PlayerData.current_map_id = "ch09_tinh_van_cac"
	var exp_m_normal: float = PlayerData.get_exp_multiplier()
	PlayerData.current_map_id = "ch09_thien_mo_tam_tang"
	var exp_m_thien_mo: float = PlayerData.get_exp_multiplier()
	_assert(is_equal_approx(exp_m_thien_mo, exp_m_normal * 5.0), "Thien Mo map grants 5.0x EXP multiplier", "norm=%.2f tm=%.2f" % [exp_m_normal, exp_m_thien_mo])
	var atk_turn0: float = PlayerData.get_atk()
	PlayerData.gold = 2000000
	PlayerData.add_item("core_nang_luong_8", 12)
	PlayerData.add_item("core_nang_luong_9", 12)
	for t_step in range(1, 10):
		var c_res: Dictionary = NineTurnMgr.condense_next_turn(PlayerData)
		_assert(bool(c_res.get("ok", false)) and PlayerData.nine_turn_level == t_step, "NineTurn condensed turn %d/9" % t_step, str(c_res))
	_assert(PlayerData.has_flag("FLAG_NINE_TURN_PEAK"), "Reaching 9/9 sets FLAG_NINE_TURN_PEAK")
	_assert(is_equal_approx(NineTurnMgr.get_stat_multiplier(PlayerData), 1.72), "Nine-Turn 9/9 multiplier is 1.72 (+72%)")
	_assert(is_equal_approx(PlayerData.get_atk(), atk_turn0 * 1.72), "Nine-Turn 9/9 scales PlayerData ATK by +72%")
	_assert(PlayerData.get_realm_display_title().find("Cửu Chuyển") != -1, "Realm title shows Cuu Chuyen tag")

	# 6. Tổ Tiên Tiêu Huyền -> Tộc Văn Đấu Đế Tiêu Tộc [X] cộng dồn với Thiên Hỏa Tam Biến (+150% ATK)
	_assert(InputMap.has_action("toc_van_crest"), "InputMap binds [X] toc_van_crest")
	PlayerData.set_story_flag("ch09_completed")
	_assert(PlayerData.is_skill_unlocked("toc_van_tieu_toc") and PlayerData.has_flag("FLAG_BOOK_03_COMPLETED"), "ch09_completed unlocks toc_van_tieu_toc & completes Book III")
	var atk_base_tv: float = PlayerData.get_atk()
	PlayerData.is_tam_bien_active = true
	PlayerData.is_toc_van_active = true
	var atk_stacked: float = PlayerData.get_atk()
	_assert(atk_stacked >= atk_base_tv * 2.48, "Tam Bien + Toc Van stack cleanly to ~+150% ATK", "ratio=%.2f" % (atk_stacked / maxf(1.0, atk_base_tv)))
	PlayerData.is_tam_bien_active = false
	PlayerData.is_toc_van_active = false

	# 7. Khảm Năng Lượng Hạch 8 & 9 + 4 công thức Bát Phẩm mới + Đối thoại Tiêu Huyền + 5 VFX Ch.09 + 7 Boss signature colors
	PlayerData.add_item("core_nang_luong_8", 1)
	PlayerData.add_item("core_nang_luong_9", 1)
	_assert(bool(PlayerData.socket_monster_core(0, "core_nang_luong_8").get("ok", false)), "Socketed core_nang_luong_8 cleanly")
	_assert(bool(PlayerData.socket_monster_core(1, "core_nang_luong_9").get("ok", false)), "Socketed core_nang_luong_9 cleanly")
	var ch09_rec_ids: Dictionary = {}
	for r in GameDatabase.recipes_list:
		ch09_rec_ids[str(r.get("id", ""))] = int(r.get("tier", 0))
	for rid in ["recipe_phuc_hon_thanh_dan", "recipe_cuu_chuyen_ton_nguyen", "recipe_kim_cuong_bat_hoai", "recipe_bo_de_hoa_the_dan"]:
		_assert(int(ch09_rec_ids.get(rid, 0)) == 8, "Ch.09 Tier-8 recipe loaded: " + rid)

	var d9: Dictionary = GameDatabase.get_dialogue_def("ch09_tieu_huyen_tomb")
	_assert(not d9.is_empty(), "Ch.09 dialogue role ch09_tieu_huyen_tomb loaded")
	var emitted9: Array = [false]
	var cb9a := func(_s: String, _a: String, _l: Array, _x: Variant) -> void: emitted9[0] = true
	var cb9b := func(_s: String, _a: String, _l: Array, _x: String) -> void: emitted9[0] = true
	EventBus.dialogue_choice_requested.connect(cb9a)
	EventBus.dialogue_requested.connect(cb9b)
	var ran9: bool = StoryDlgRunner.run_data_driven_dialogue(d9, "Tổ Tiên Tiêu Huyền", "res://assets/sprites/npcs/npc_tieu_huyen.png")
	EventBus.dialogue_choice_requested.disconnect(cb9a)
	EventBus.dialogue_requested.disconnect(cb9b)
	_assert(ran9 and bool(emitted9[0]), "StoryDialogueRunner runs Ch.09 JSON dialogue cleanly")

	for v9 in ["spatial_giant_palm", "creation_heaven_palm", "ten_golden_puppets", "xiao_clan_crest", "ban_thanh_duoc_tran_assist"]:
		var vb9 := SkillVfxBurst.new()
		add_child(vb9)
		vb9.configure(v9, Vector2.ZERO, Vector2.RIGHT, 240.0, 0.75, Color("#FFFFFF"), Color("#FFD166"), Color("#FF4D6D"))
		_assert(vb9.vfx_mode == v9, "SkillVfxBurst configures Ch.09 mode cleanly: " + v9)
		vb9.queue_free()

	var b_mod9 = load("res://scripts/entities/boss_skill_executor.gd")
	for bid9 in ["trich_tinh_lao_quy_boss", "hac_bach_thien_ton_boss", "yeu_hoa_ta_quan_boss", "tan_hon_tao_hoa_boss", "bac_long_vuong_boss", "co_yeu_do_thong_boss", "huyet_dao_thanh_gia_boss"]:
		var col9: Color = b_mod9.get_signature_color(bid9)
		_assert(col9.a > 0.9, "BossSkillExecutor Ch.09 signature color valid: " + bid9)


# =========================================================
# SUITE 15: v0.9.0 CH.10 SYSTEMS (BỒ ĐỀ HÓA THÁNH · BÁCH THẾ · THIÊN PHỦ · BẮC VƯƠNG · #3 TỊNH LIÊN TIỂU Y)
# =========================================================
func _suite_15_ch10_systems() -> void:
	print("[Suite 15] v0.9.0 Ch.10 Systems (7 Maps, 8 Bosses, 18 BGMs, SaintRealm, Bach The, Thien Phu, Bac Vuong, Tieu Y #3)...")
	PlayerData.reset_for_new_game(1)

	# 1. 4 Bản nhạc nền Ch.10 mới -> tổng 18 BGM hợp lệ & nạp sạch 2 mô-đun mới
	_assert(AudioManager.bgm_tracks.size() >= 18, "AudioManager built 18+ procedural BGM tracks", "got %d" % AudioManager.bgm_tracks.size())
	for ch10_bk in ["bgm_bo_de", "bgm_thien_phu", "bgm_nhan_dien", "bgm_yeu_hoa"]:
		var st = AudioManager.bgm_tracks.get(ch10_bk, null)
		_assert(st is AudioStreamWAV and (st as AudioStreamWAV).data.size() > 10000 and (st as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD, "Ch.10 BGM track valid looping WAV: " + ch10_bk)
		AudioManager.play_bgm(ch10_bk)
		_assert(AudioManager.current_bgm_name == ch10_bk, "AudioManager plays Ch.10 BGM cleanly: " + ch10_bk)
	_assert(load("res://scripts/systems/audio_bgm_ch10.gd") != null, "audio_bgm_ch10.gd loads cleanly")
	_assert(load("res://scripts/systems/saint_realm_manager.gd") != null, "saint_realm_manager.gd loads cleanly")

	# 2. Xác nhận 7 Map Ch.10, 10 Main Quests q77..q86, 8 Boss kill flags & 13 NPC dialogue roles
	for m10 in [
		"ch10_viem_minh_chien_truong", "ch10_mang_hoang_co_vuc", "ch10_bo_de_co_thu",
		"ch10_thien_phu_lien_minh", "ch10_cuu_u_hoang_tuyen", "ch10_nhan_dien_hon_dien", "ch10_yeu_hoa_khong_gian"
	]:
		_assert(GameDatabase.maps_by_id.has(m10), "Ch.10 map loaded: " + m10)
	for q10 in [
		"q77_ch10_cuu_vien_viem_minh", "q78_ch10_mang_hoang_hon_ngoc", "q79_ch10_bo_de_ac_niem",
		"q80_ch10_bach_the_hoa_thanh", "q81_ch10_thien_phu_lien_minh", "q82_ch10_hoang_tuyen_tam_tuyet",
		"q83_ch10_cong_pha_nhan_dien", "q84_ch10_yeu_hoa_bac_vuong", "q85_ch10_song_luyen_tinh_lien",
		"q86_ch10_tram_hon_diet_sinh"
	]:
		_assert(GameDatabase.quests_by_id.has(q10), "Ch.10 quest loaded: " + q10)
	for r10 in [
		"ch10_hai_ba_dong_siege", "ch10_thai_lan_tieu_tieu", "ch10_huan_nhi_mang_hoang", "ch10_bo_de_co_thu",
		"ch10_dan_thap_lao_to", "ch10_tieu_tieu_hub", "ch10_thien_phu_steward", "ch10_yeu_minh",
		"ch10_hoang_tuyen_stele", "ch10_nhan_dien_souls", "ch10_bac_vuong_forge", "ch10_tinh_lien_yeu_thanh",
		"ch10_huan_nhi_dai_sen"
	]:
		_assert(not GameDatabase.get_dialogue_def(r10).is_empty(), "Ch.10 dialogue role loaded: " + r10)

	# 3. Cứu Viêm Minh -> ACH_10_01 (+5% ATK), Đoàn tụ Thải Lân & Bé Tiêu Tiêu (#11 [G], Bán Thánh, +75 my_do_toa) & SQ_10_01 Phụ Nữ Đồng Tâm Kết
	var atk_pre_a1: float = PlayerData.get_atk()
	PlayerData.set_story_flag("ch10_beat_su_thien")
	_assert(PlayerData.has_flag("ach_10_01_viem_minh_chi_ton") and PlayerData.get_atk() > atk_pre_a1, "ACH_10_01 Viem Minh Chi Ton boosts ATK +5%")
	PlayerData.set_story_flag("ch10_viem_minh_saved")
	_assert(PlayerData.realm_index >= 10 and SaintRealmMgr.is_half_saint_or_above(PlayerData), "ch10_viem_minh_saved reaches Half-Saint (Realm 10)")
	_assert(PlayerData.unlocked_companions.has("thai_lan_tieu_tieu") and PlayerData.get_affection("my_do_toa") >= 75, "Companion #11 Thai Lan & Tieu Tieu unlocked & my_do_toa affection raised")
	PlayerData.set_story_flag("sq_10_01_tieu_tieu_candy")
	var found_pend: bool = false
	for g_it in PlayerData.gear_bag:
		if str((g_it as Dictionary).get("template_id", "")) == "pend_phu_nu_dong_tam_ket":
			found_pend = true
			PlayerData.equip_gear_from_bag(str((g_it as Dictionary).get("uid", "")))
			break
	_assert(found_pend, "SQ_10_01 grants pend_phu_nu_dong_tam_ket")
	PlayerData.current_hp = PlayerData.get_max_hp()
	var atk_full_hp: float = PlayerData.get_atk()
	PlayerData.current_hp = PlayerData.get_max_hp() * 0.30
	_assert(PlayerData.get_atk() > atk_full_hp * 1.09, "pend_phu_nu_dong_tam_ket grants +10% ATK when HP < 50%")
	PlayerData.current_hp = PlayerData.get_max_hp()

	# 4. Ảo Cảnh Bách Thế Luân Hồi (Thủy Mặc 0/3 -> 3/3 -> ACH_10_02 +250 SOUL) & Đấu Thánh Không Gian (+25% Thánh Uy)
	PlayerData.current_map_id = "ch10_bo_de_co_thu"
	PlayerData.set_story_flag("ch10_bt_illusion_started")
	_assert(SaintRealmMgr.is_ink_wash_illusion_active(PlayerData), "Ink-wash illusion activates on Bo De map")
	_assert(SaintRealmMgr.get_hud_domain_badge(PlayerData).find("THỦY MẶC") != -1, "HUD badge displays Bach The Ink-Wash counter")
	var soul_pre_bt: int = PlayerData.get_soul()
	PlayerData.set_story_flag("ch10_bt_life1_done")
	PlayerData.set_story_flag("ch10_bt_life1_nhan")
	PlayerData.set_story_flag("ch10_bt_life50_done")
	PlayerData.set_story_flag("ch10_bt_life50_tin")
	PlayerData.set_story_flag("ch10_bt_life100_chan")
	PlayerData.set_story_flag("ch10_bach_the_enlightened")
	_assert(not SaintRealmMgr.is_ink_wash_illusion_active(PlayerData), "Ink-wash illusion ends after enlightenment")
	_assert(SaintRealmMgr.get_bach_the_benevolent_count(PlayerData) == 3 and PlayerData.has_flag("ach_10_02_tram_kiep_so_tam"), "3/3 Benevolent choices unlock ACH_10_02 Tram Kiep So Tam")
	_assert(PlayerData.get_soul() >= soul_pre_bt + 400, "Enlightenment + ACH_10_02 boosts SOUL significantly")
	_assert(PlayerData.realm_index >= 11 and SaintRealmMgr.has_dau_thanh_domain(PlayerData), "Enlightenment grants Dau Thanh Domain (Realm 11)")
	_assert(is_equal_approx(SaintRealmMgr.get_saint_supremacy_mult(PlayerData, 10), 1.25) and is_equal_approx(SaintRealmMgr.get_saint_supremacy_mult(PlayerData, 11), 1.0), "Saint Domain deals +25% supremacy vs below-Saint")

	# 5. Thế Lực Cấp 4 THIÊN PHỦ LIÊN MINH (6 Công Trình, +18% SOUL, 20 Boss Cường Bảng, FLAG_THIEN_PHU_MAX)
	PlayerData.set_story_flag("ch10_thien_phu_founded")
	_assert(PanGateMgr.is_thien_phu_evolved(PlayerData) and PanGateMgr.get_faction_title(PlayerData).find("THIÊN PHỦ") != -1, "Tier-4 Thien Phu Lien Minh evolved")
	_assert(PanGateMgr.get_hall_defs_for(PlayerData).size() == 6, "Thien Phu exposes all 6 structures incl. thien_phu_lien_quan")
	_assert(PanGateMgr.get_strong_ranking_roster_for(PlayerData).size() == 20, "Thien Phu expands Strong Ranking roster to 20 Bosses")
	PlayerData.fire_energy = 50000
	PlayerData.gold = 10000000
	for hid10 in ["dan_duong", "vo_duong", "am_duong", "am_vong", "tinh_than_tran", "thien_phu_lien_quan"]:
		for lv10 in range(1, 4):
			var ur10: Dictionary = PanGateMgr.upgrade_hall(PlayerData, hid10)
			_assert(bool(ur10.get("ok", false)), "Thien Phu upgraded %s -> Lv.%d" % [hid10, lv10], str(ur10))
	_assert(PlayerData.has_flag("FLAG_THIEN_PHU_MAX") and is_equal_approx(PanGateMgr.get_soul_bonus_pct(PlayerData), 18.0), "Maxing all 6 Thien Phu halls sets FLAG_THIEN_PHU_MAX & +18% SOUL")

	# 6. Hoàng Tuyền Tam Tuyệt, Nhân Điện (Phật Nộ Luân Hồi + ACH_10_03 -20% CD) & SQ_10_03 (+350 SOUL)
	PlayerData.set_story_flag("ch10_hoang_tuyen_mastered")
	_assert(PlayerData.is_skill_unlocked("hoang_tuyen_chuong") and PlayerData.is_skill_unlocked("hoang_tuyen_thien_no"), "Hoang Tuyen mastery unlocks both Heavenly skills")
	PlayerData.set_story_flag("ch10_nhan_dien_destroyed")
	_assert(PlayerData.is_skill_unlocked("phat_no_luan_hoi") and PlayerData.has_flag("ach_10_03_thien_phu_thong_soai"), "Destroying Nhan Dien unlocks phat_no_luan_hoi & ACH_10_03")
	_assert(is_equal_approx(SaintRealmMgr.get_hoang_tuyen_cd_mult(PlayerData), 0.80), "ACH_10_03 reduces Hoang Tuyen cooldowns by 20%")
	var soul_pre_sq3: int = PlayerData.get_soul()
	PlayerData.set_story_flag("sq_10_03_sieu_do_van_hon")
	_assert(PlayerData.get_soul() > soul_pre_sq3 + 300, "SQ_10_03 Sieu Do Van Hon grants +350 SOUL")

	# 7. Yêu Hỏa Không Gian: Bắc Vương (#10 -> 7★ via SQ_10_04), Tịnh Liên Yêu Trận, Song Luyện #3 Tịnh Liên + #4 Kim Đế + Khí Linh Tiểu Y & Lục Sắc Hỏa Liên!
	PlayerData.set_story_flag("ch10_bac_vuong_forged")
	_assert(PlayerData.unlocked_companions.has("bac_vuong") and PlayerData.get_assist_mode() == "bac_vuong", "Bac Vuong (#10) forged & upgrades [T] Assist")
	PlayerData.set_story_flag("sq_10_04_bac_vuong_7star")
	_assert(SaintRealmMgr.has_bac_vuong_seven_star(PlayerData) and PlayerData.get_companion_display_name("bac_vuong").find("Thất Tinh") != -1, "SQ_10_04 upgrades Bac Vuong to 7-Star Gold Lightning")
	PlayerData.set_story_flag("ch10_yeu_thanh_legacy")
	_assert(PlayerData.is_skill_unlocked("tinh_lien_yeu_tran"), "Yeu Thanh legacy unlocks tinh_lien_yeu_tran")

	for f_pre in ["di_hoa_19_thanh_lien", "di_hoa_14_van_lac", "di_hoa_11_cot_linh", "di_hoa_09_tam_thien"]:
		PlayerData.unlock_flame(f_pre, false)
	PlayerData.set_story_flag("ch10_tinh_lien_tamed")
	_assert(PlayerData.unlocked_flames.has("di_hoa_03_tinh_lien") and PlayerData.unlocked_flames.has("di_hoa_04_kim_de"), "Taming Tinh Lien unlocks #3 Tinh Lien & #4 Kim De")
	_assert(SaintRealmMgr.has_tieu_y_spirit(PlayerData) and SaintRealmMgr.has_huan_nhi_soul_revive(PlayerData), "Khi Linh Tieu Y & Huan Nhi Soul Revive unlocked")
	_assert(PlayerData.get_lotus_max_flames() == 6 and PlayerData.lotus_fusion_flames.size() == 6, "6-Flame Luc Sac Thanh Lien unlocked & auto-fused")
	_assert(PlayerData.get_assist_mode() == "tinh_lien_hop_bich", "[T] Assist upgrades to Tinh Lien Hop Bich")
	_assert(PlayerData.get_companion_display_name("huan_nhi").find("Đấu Thánh") != -1, "Huan Nhi companion evolves to Dau Thanh title")

	# 8. Khí Linh Tiểu Y: 30% Tịnh Hóa Đạn (+8% QI) & Auto-Refine Phẩm 1–8 (Chặn Phẩm 9!)
	PlayerData.current_qi = 0.0
	_assert(SaintRealmMgr.try_tieu_y_purify_hit(PlayerData, 0.10) and PlayerData.current_qi > 0.0, "Tieu Y purifies dark attack (roll=0.10) & restores +8% QI")
	_assert(not SaintRealmMgr.try_tieu_y_purify_hit(PlayerData, 0.85), "Tieu Y does not trigger on high roll (0.85)")

	var rec_bode: Dictionary = {}
	var rec_t9: Dictionary = {}
	for r in GameDatabase.recipes_list:
		if str(r.get("id", "")) == "recipe_bo_de_dai_hoan":
			rec_bode = r
		elif str(r.get("id", "")) == "recipe_thanh_linh_phuc_nguyen":
			rec_t9 = r
	_assert(not rec_bode.is_empty() and int(rec_bode.get("tier", 0)) == 8, "Ch.10 Tier-8 recipe_bo_de_dai_hoan loaded")
	_assert(not rec_t9.is_empty() and int(rec_t9.get("tier", 0)) == 9, "Ch.10 Tier-9 recipe_thanh_linh_phuc_nguyen loaded")
	for rec10 in [rec_bode, rec_t9]:
		for ik10 in (rec10.get("ingredients", {}) as Dictionary).keys():
			PlayerData.add_item(str(ik10), int((rec10["ingredients"] as Dictionary)[ik10]) + 2)
	var cnt_bode_pre: int = PlayerData.get_item_count("pill_bo_de_dai_hoan")
	var ar_ok: Dictionary = SaintRealmMgr.run_tieu_y_auto_refine(PlayerData, rec_bode)
	_assert(bool(ar_ok.get("ok", false)) and PlayerData.get_item_count("pill_bo_de_dai_hoan") == cnt_bode_pre + 1, "Tieu Y Auto-Refine crafts Tier-8 pill cleanly", str(ar_ok))
	var ar_t9: Dictionary = SaintRealmMgr.can_tieu_y_auto_refine(PlayerData, rec_t9)
	_assert(not bool(ar_t9.get("ok", true)), "Tieu Y Auto-Refine correctly blocks Quasi-Tier-9 pill")

	# 9. Khảm Cửu Huyền Kim Lôi Hạch (core_kim_loi_9), Set #10, Đối thoại Đài Sen, 5 VFX Ch.10, 8 Boss signature colors & giới hạn <1800 LOC
	PlayerData.add_item("core_kim_loi_9", 1)
	_assert(bool(PlayerData.socket_monster_core(0, "core_kim_loi_9").get("ok", false)), "Socketed core_kim_loi_9 cleanly")
	_assert(GameDatabase.equipment_sets.has("set_tinh_lien_dau_thanh"), "Set #10 set_tinh_lien_dau_thanh loaded")
	var d10: Dictionary = GameDatabase.get_dialogue_def("ch10_huan_nhi_dai_sen")
	var emitted10: Array = [false]
	var cb10a := func(_s: String, _a: String, _l: Array, _x: Variant) -> void: emitted10[0] = true
	var cb10b := func(_s: String, _a: String, _l: Array, _x: String) -> void: emitted10[0] = true
	EventBus.dialogue_choice_requested.connect(cb10a)
	EventBus.dialogue_requested.connect(cb10b)
	var ran10: bool = StoryDlgRunner.run_data_driven_dialogue(d10, "Đài Sen Tịnh Liên", "res://assets/sprites/npcs/npc_huan_nhi_dau_thanh.png")
	EventBus.dialogue_choice_requested.disconnect(cb10a)
	EventBus.dialogue_requested.disconnect(cb10b)
	_assert(ran10 and bool(emitted10[0]), "StoryDialogueRunner runs Ch.10 JSON dialogue cleanly")

	for v10 in ["yellow_springs_palm", "yellow_springs_wrath", "reincarnation_fire_disc", "purifying_lotus_array", "bac_vuong_tinh_lien_assist"]:
		var vb10 := SkillVfxBurst.new()
		add_child(vb10)
		vb10.configure(v10, Vector2.ZERO, Vector2.RIGHT, 260.0, 0.80, Color("#FFFFFF"), Color("#F8A5C2"), Color("#FBBF24"))
		_assert(vb10.vfx_mode == v10, "SkillVfxBurst configures Ch.10 mode cleanly: " + v10)
		vb10.queue_free()

	var b_mod10 = load("res://scripts/entities/boss_skill_executor.gd")
	for bid10 in [
		"su_thien_cuu_thien_ton_boss", "hon_ngoc_ban_thanh_boss", "ac_niem_dau_de_boss", "thien_minh_lao_yeu_boss",
		"hoang_tuyen_yeu_thanh_boss", "pho_dien_chu_nhan_dien_boss", "tinh_lien_yeu_hoa_boss", "hon_diet_sinh_boss"
	]:
		var col10: Color = b_mod10.get_signature_color(bid10)
		_assert(col10.a > 0.9, "BossSkillExecutor Ch.10 signature color valid: " + bid10)

	for core_p10 in [
		"res://scripts/autoload/player_data.gd",
		"res://scripts/entities/enemy_controller.gd",
		"res://scripts/entities/player_controller.gd",
		"res://scripts/ui/hud_controller.gd",
		"res://scripts/systems/world_stage_manager.gd"
	]:
		var f10 := FileAccess.open(core_p10, FileAccess.READ)
		var loc10: int = f10.get_as_text().split("\n").size() if f10 != null else 99999
		_assert(loc10 < 1800, "Core script stays strictly under 1800 LOC: %s (%d LOC)" % [core_p10, loc10])


# =========================================================
# SUITE 16: v1.0.0 CH.11 ĐẠI KẾT CỤC VIÊM ĐẾ (ĐẾ CẢNH · PHẨM 10 · 23 DỊ HỎA · 3-PHASE BOSS · NG+)
# =========================================================
func _suite_16_ch11_systems() -> void:
	print("[Suite 16] v1.0.0 Ch.11 Systems (7 Maps, 8 Bosses, 22 BGMs, De Canh Tier-10, Viem De 23 Flames, 3-Phase Boss, Chuc Khon #12, NG+)...")
	PlayerData.reset_for_new_game(1)

	# 1. 4 Bản nhạc nền Ch.11 mới -> tổng 22 BGM hợp lệ & nạp sạch 3 mô-đun mới
	_assert(AudioManager.bgm_tracks.size() >= 22, "AudioManager built 22+ procedural BGM tracks", "got %d" % AudioManager.bgm_tracks.size())
	for ch11_bk in ["bgm_co_de_dong_phu", "bgm_song_de_chi_chien", "bgm_o_than_dai_hon", "bgm_dai_thien_the_gioi"]:
		var st = AudioManager.bgm_tracks.get(ch11_bk, null)
		_assert(st is AudioStreamWAV and (st as AudioStreamWAV).data.size() > 10000 and (st as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD, "Ch.11 BGM track valid looping WAV: " + ch11_bk)
		AudioManager.play_bgm(ch11_bk)
		_assert(AudioManager.current_bgm_name == ch11_bk, "AudioManager plays Ch.11 BGM cleanly: " + ch11_bk)
	_assert(load("res://scripts/systems/audio_bgm_ch11.gd") != null, "audio_bgm_ch11.gd loads cleanly")
	_assert(load("res://scripts/systems/emperor_realm_manager.gd") != null, "emperor_realm_manager.gd loads cleanly")
	_assert(load("res://scripts/ui/panels/panel_ending_credits.gd") != null, "panel_ending_credits.gd loads cleanly")

	# 2. Xác nhận 7 Map Ch.11, 10 Main Quests q87..q96, 14 NPC dialogue roles, Set #11 & 5 Đấu Kỹ Đế Cảnh
	for m11 in [
		"ch11_duoc_gioi_van_duoc_son", "ch11_tang_thien_son_mach", "ch11_day_thap_gia_nam",
		"ch11_co_de_dong_phu", "ch11_cuu_tieu_thuong_khung", "ch11_o_than_thanh_dai_hon", "ch11_dai_thien_giao_gioi"
	]:
		_assert(GameDatabase.maps_by_id.has(m11), "Ch.11 map loaded: " + m11)
	for q11 in [
		"q87_ch11_duoc_dien_huyen_dan", "q88_ch11_duoc_gioi_pha_vay", "q89_ch11_de_canh_tang_thien",
		"q90_ch11_cuu_phu_than_tieu_chien", "q91_ch11_day_thap_chuc_khon", "q92_ch11_de_pham_so_dan",
		"q93_ch11_van_hoa_trieu_tong", "q94_ch11_song_de_chi_chien", "q95_ch11_o_than_dai_hon",
		"q96_ch11_dai_thien_chi_mon"
	]:
		_assert(GameDatabase.quests_by_id.has(q11), "Ch.11 quest loaded: " + q11)
	for r11 in [
		"ch11_duoc_dien_lao_to", "ch11_viem_tan_alliance", "ch11_tieu_chien_rescue", "ch11_chuc_khon_reunion",
		"ch11_tu_nghien_father", "ch11_da_xa_co_de_statue", "ch11_song_de_victory", "ch11_wedding_ceremony",
		"ch11_eq01_tieu_y_tien", "ch11_eq02_van_van", "ch11_eq03_nha_phi", "ch11_eq04_candy_party",
		"ch11_eq05_ancestor_oath", "ch11_dai_thien_monolith"
	]:
		_assert(not GameDatabase.get_dialogue_def(r11).is_empty(), "Ch.11 dialogue role loaded: " + r11)
	_assert(GameDatabase.equipment_sets.has("set_vinh_hang_viem_de"), "Set #11 set_vinh_hang_viem_de loaded")
	for sk11 in ["de_hon_phap_tuong", "van_hoa_phan_thuong_khung", "di_hoa_quang_truong", "hang_co_xich_tram", "hang_co_di_hoa_lien"]:
		_assert(GameDatabase.skills_by_id.has(sk11), "Ch.11 Emperor skill loaded: " + sk11)

	# 3. Đế Cảnh Linh Hồn (SOUL >= 3500, max_tier = 10), Luyện Đan Phẩm 10 (Đà Xá Đế Phẩm Hoàn Đan +25% chỉ số) & Lôi Kiếp Huyền Đan (+150 SOUL)
	var rec_t10: Dictionary = {}
	for r in GameDatabase.recipes_list:
		if str(r.get("id", "")) == "recipe_da_xa_de_pham_hoan_dan":
			rec_t10 = r
			break
	_assert(not rec_t10.is_empty() and int(rec_t10.get("tier", 0)) == 10, "Tier 10 recipe_da_xa_de_pham_hoan_dan loaded")
	for ik11 in (rec_t10.get("ingredients", {}) as Dictionary).keys():
		PlayerData.add_item(str(ik11), int((rec_t10["ingredients"] as Dictionary)[ik11]) + 2)
	PlayerData.bonus_soul = 1500
	_assert(int(PlayerData.get_soul_realm_info().get("alchemy_max_tier", 6)) == 9, "SOUL 1500 is Thien Canh (max_tier=9)")
	_assert(not bool(AlchemySystem.can_craft(rec_t10).get("ok", true)), "Tier 10 Pill BLOCKED in Thien Canh (SOUL < 3500)")

	PlayerData.bonus_soul = 2300
	PlayerData.set_story_flag("ch11_de_canh_soul_awakened")
	_assert(EmperorRealmMgr.has_de_canh_soul(PlayerData) and PlayerData.get_soul() >= 3500, "ch11_de_canh_soul_awakened reaches De Canh Soul (3500+ SOUL)")
	_assert(int(PlayerData.get_soul_realm_info().get("alchemy_max_tier", 6)) == 10, "De Canh Soul unlocks alchemy_max_tier=10")
	_assert(PlayerData.is_skill_unlocked("de_hon_phap_tuong"), "De Canh Soul unlocks de_hon_phap_tuong")
	_assert(bool(AlchemySystem.can_craft(rec_t10).get("ok", false)), "Tier 10 Da Xa De Pham Hoan Dan ALLOWED in De Canh")

	var soul_pre_lk: int = PlayerData.get_soul()
	PlayerData.add_item("pill_loi_kiep_huyen_dan", 1)
	_assert(PlayerData.use_consumable("pill_loi_kiep_huyen_dan", Vector2.ZERO) and PlayerData.get_soul() >= soul_pre_lk + 150, "pill_loi_kiep_huyen_dan permanently adds +150 SOUL")

	var atk_pre_dx: float = PlayerData.get_atk()
	PlayerData.add_item("pill_da_xa_de_pham_hoan_dan", 1)
	_assert(PlayerData.use_consumable("pill_da_xa_de_pham_hoan_dan", Vector2.ZERO) and PlayerData.has_flag("ch11_da_xa_pill_eaten"), "pill_da_xa_de_pham_hoan_dan consumed cleanly")
	_assert(PlayerData.get_atk() >= atk_pre_dx * 1.24, "Da Xa De Pham Hoan Dan boosts all stats by +25% permanently")

	# 4. Dược Giới (#5/#10), Long Hoàng Chúc Khôn (#12), Chứng Đạo Viêm Đế (Realm 12, #1 Đế Viêm, 25 Boss Cường Bảng, [T] Viêm Đế, 23 Hỏa Liên)
	PlayerData.set_story_flag("ch11_beat_hon_hu_tu")
	_assert(PlayerData.has_flag("ach_11_01_dan_thap_vo_thuong"), "Beating Hon Hu Tu grants ACH_11_01")
	PlayerData.set_story_flag("ch11_duoc_gioi_escaped")
	_assert(PlayerData.unlocked_flames.has("di_hoa_05_sinh_linh") and PlayerData.unlocked_flames.has("di_hoa_10_cuu_u_phong"), "Escaping Duoc Gioi grants #5 Sinh Linh & #10 Cuu U")
	PlayerData.set_story_flag("ch11_chuc_khon_allied")
	_assert(PlayerData.unlocked_companions.has("chuc_khon_long_hoang"), "Companion #12 Chuc Khon Long Hoang unlocked")
	PlayerData.set_story_flag("ch10_thien_phu_founded")
	PlayerData.set_story_flag("ch11_viem_de_ascended")
	_assert(PlayerData.realm_index == 12 and EmperorRealmMgr.is_viem_de_emperor(PlayerData), "ch11_viem_de_ascended reaches Realm 12 Viem De")
	_assert(PlayerData.unlocked_flames.has("di_hoa_01_de_viem") and PlayerData.unlocked_flames.has("di_hoa_02_hu_vo"), "Viem De ascension unlocks #1 De Viem & #2 Hu Vo")
	_assert(EmperorRealmMgr.has_hang_co_xich(PlayerData), "Viem De auto-equips wpn_di_hoa_hang_co_xich")
	_assert(PlayerData.get_assist_mode() == "viem_de_phap_tuong", "[T] Assist upgrades to Viem De Phap Tuong")
	_assert(PlayerData.get_lotus_max_flames() == 23, "Viem De unlocks 23-Flame Hang Co Di Hoa Lien")
	_assert(is_equal_approx(EmperorRealmMgr.get_emperor_supremacy_mult(PlayerData, 11), 1.45) and is_equal_approx(EmperorRealmMgr.get_emperor_supremacy_mult(PlayerData, 12), 1.0), "Viem De grants +45% Emperor Supremacy vs below-Emperor")
	_assert(PanGateMgr.get_strong_ranking_roster_for(PlayerData).size() == 25, "Ch.11 expands Strong Ranking roster to 25 Bosses")
	PlayerData.add_item("core_de_viem_10", 1)
	_assert(bool(PlayerData.socket_monster_core(0, "core_de_viem_10").get("ok", false)), "Socketed Tier 10 core_de_viem_10 cleanly")

	# 5. Live Final Boss 3-Phase State Machine (hon_thien_de_boss: Phase 1 -> Phase 2 <=65% -> Phase 3 <=25%)
	var enemy_scene: PackedScene = load("res://scenes/entities/enemy_base.tscn")
	var htd: Node = enemy_scene.instantiate()
	htd.set("enemy_id", "hon_thien_de_boss")
	add_child(htd)
	await get_tree().process_frame
	_assert(bool(htd.get("is_boss_unit")) and bool(htd.get("is_three_phase_boss")) and int(htd.get("boss_phase")) == 1, "Hon Thien De spawns in Phase 1 with is_three_phase_boss=true")
	var htd_max: float = float(htd.get("max_hp"))
	htd.set("cur_hp", htd_max * 0.62)
	htd.call("receive_hit", 50.0, Vector2.RIGHT, 1.0, 0.0, 1.0, 1.0, 12.0)
	_assert(int(htd.get("boss_phase")) == 2, "Hon Thien De transitions to Phase 2 below 65% HP", "got phase %d" % int(htd.get("boss_phase")))
	htd.set("cur_hp", htd_max * 0.22)
	htd.call("receive_hit", 50.0, Vector2.RIGHT, 1.0, 0.0, 1.0, 1.0, 12.0)
	_assert(int(htd.get("boss_phase")) == 3, "Hon Thien De transitions to Phase 3 below 25% HP", "got phase %d" % int(htd.get("boss_phase")))
	htd.queue_free()
	await get_tree().process_frame

	# 6. Song Đế Phong Ấn, Đại Hôn, 5 Hậu Truyện -> ACH_11_04 (+10%), 17 Bí Cảnh (23/23 Dị Hỏa) & ACH_11_05 (+15%)
	PlayerData.set_story_flag("ch11_beat_hon_thien_de")
	PlayerData.set_story_flag("ch11_hon_thien_de_sealed")
	_assert(PlayerData.has_flag("ach_11_03_tam_thap_nien") and PlayerData.is_skill_unlocked("di_hoa_quang_truong"), "Sealing Hon Thien De unlocks di_hoa_quang_truong & ACH_11_03")
	PlayerData.set_story_flag("ch11_wedding_completed")
	_assert(PlayerData.is_skill_unlocked("hang_co_di_hoa_lien"), "Wedding ceremony unlocks hang_co_di_hoa_lien")
	var atk_pre_ep: float = PlayerData.get_atk()
	for eqf in ["eq_11_01_tieu_y_tien_done", "eq_11_02_van_van_done", "eq_11_03_nha_phi_done", "eq_11_04_candy_party_done", "eq_11_05_ancestor_oath_done"]:
		PlayerData.set_story_flag(eqf)
	_assert(EmperorRealmMgr.get_epilogue_done_count(PlayerData) == 5, "All 5 Ch.11 Epilogue quests completed")
	_assert(PlayerData.has_flag("ach_11_02_phu_tu_tinh_tham") and PlayerData.has_flag("ach_11_04_song_hau_dong_quy"), "5/5 Epilogue + Wedding awards ACH_11_02 & ACH_11_04")
	_assert(PlayerData.get_atk() >= atk_pre_ep * 1.09, "ACH_11_04 Song Hau Dong Quy grants +10% permanent stats")

	PlayerData.set_story_flag("ch11_all_23_flames_hunted")
	_assert(EmperorRealmMgr.get_heavenly_flame_count(PlayerData) == 23 and EmperorRealmMgr.has_all_23_heavenly_flames(PlayerData), "17 Hidden Flame Realms unlock full 23/23 Heavenly Flames")
	var atk_pre_a5: float = PlayerData.get_atk()
	PlayerData.set_story_flag("ach_11_05_chua_te_dai_thien")
	_assert(PlayerData.get_atk() >= atk_pre_a5 * 1.14, "ACH_11_05 Chua Te Dai Thien grants +15% permanent stats")
	_assert(EmperorRealmMgr.get_hud_emperor_badge(PlayerData).find("CHÚA TỂ ĐẠI THIÊN") != -1, "HUD Emperor badge displays Chua Te Dai Thien")

	# 7. Luân Hồi Chuyển Thế (New Game+) & Đối thoại Bia Đại Thiên
	var d11: Dictionary = GameDatabase.get_dialogue_def("ch11_dai_thien_monolith")
	var emitted11: Array = [false]
	var cb11a := func(_s: String, _a: String, _l: Array, _x: Variant) -> void: emitted11[0] = true
	var cb11b := func(_s: String, _a: String, _l: Array, _x: String) -> void: emitted11[0] = true
	EventBus.dialogue_choice_requested.connect(cb11a)
	EventBus.dialogue_requested.connect(cb11b)
	var ran11: bool = StoryDlgRunner.run_data_driven_dialogue(d11, "Bia Đại Thiên", "res://assets/sprites/npcs/npc_dai_thien_portal.png")
	EventBus.dialogue_choice_requested.disconnect(cb11a)
	EventBus.dialogue_requested.disconnect(cb11b)
	_assert(ran11 and bool(emitted11[0]), "StoryDialogueRunner runs Ch.11 JSON dialogue cleanly")

	var ng_res: Dictionary = EmperorRealmMgr.start_new_game_plus(PlayerData)
	_assert(bool(ng_res.get("ok", false)) and PlayerData.ng_plus_cycle == 1, "New Game+ started cleanly (Cycle 1)", str(ng_res))
	_assert(PlayerData.current_map_id == "ch01_tieu_gia" and PlayerData.has_flag("FLAG_NG_PLUS_ACTIVE") and PlayerData.has_flag("FLAG_TIEU_Y_ACTIVE"), "NG+ resets map to O Than Thanh while keeping Tieu Y & NG+ flag")
	_assert(EmperorRealmMgr.get_heavenly_flame_count(PlayerData) == 23 and PlayerData.unlocked_skills.size() >= 5, "NG+ carries over 23/23 Heavenly Flames & unlocked Emperor skills")
	var ng_m: Dictionary = EmperorRealmMgr.get_ng_plus_enemy_multipliers(PlayerData)
	_assert(is_equal_approx(float(ng_m.get("hp", 1.0)), 3.0) and is_equal_approx(float(ng_m.get("atk", 1.0)), 1.5) and is_equal_approx(float(ng_m.get("spd", 1.0)), 1.35), "NG+ Cycle 1 enemy scaling is +200% HP, +50% ATK, +35% SPD")

	# 8. 6 Ch.11 VFX Modes + 8 Ch.11 Boss/Superboss Signature Colors + <1800 LOC Guard
	for v11 in ["emperor_soul_avatar", "myriad_flames_meteor", "flame_plaza_seal", "eternal_ruler_cleave", "genesis_fire_lotus", "chuc_khon_assist"]:
		var vb11 := SkillVfxBurst.new()
		add_child(vb11)
		vb11.configure(v11, Vector2.ZERO, Vector2.RIGHT, 280.0, 0.85, Color("#FFFFFF"), Color("#FFD700"), Color("#FF0054"))
		_assert(vb11.vfx_mode == v11, "SkillVfxBurst configures Ch.11 mode cleanly: " + v11)
		vb11.queue_free()

	var b_mod11 = load("res://scripts/entities/boss_skill_executor.gd")
	for bid11 in [
		"hon_hu_tu_boss", "hu_vo_thon_viem_boss", "tu_ma_thanh_boss", "de_pham_so_dan_boss",
		"hon_thien_de_boss", "ho_ve_di_hoa_boss", "vo_to_lam_dong_boss", "muc_ton_muc_tran_boss"
	]:
		var col11: Color = b_mod11.get_signature_color(bid11)
		_assert(col11.a > 0.9, "BossSkillExecutor Ch.11 signature color valid: " + bid11)

	for core_p11 in [
		"res://scripts/autoload/player_data.gd",
		"res://scripts/entities/enemy_controller.gd",
		"res://scripts/entities/player_controller.gd",
		"res://scripts/ui/hud_controller.gd",
		"res://scripts/systems/world_stage_manager.gd"
	]:
		var f11 := FileAccess.open(core_p11, FileAccess.READ)
		var loc11: int = f11.get_as_text().split("\n").size() if f11 != null else 99999
		_assert(loc11 < 1800, "v1.0.0 core script stays strictly under 1800 LOC: %s (%d LOC)" % [core_p11, loc11])




