extends Node
## Bộ Kiểm Thử Tự Động (Godot Headless Test Suite) cho Đấu Phá Thương Khung:
## Chạy qua: Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/test_runner.tscn
## Hoặc chạy trực tiếp: tests\run_tests.bat

const SaveLoadMgr = preload("res://scripts/systems/save_load_manager.gd")
const StoryDlgRunner = preload("res://scripts/systems/story_dialogue_runner.gd")
const ThienPhanTowerMgr = preload("res://scripts/systems/thien_phan_tower_manager.gd")
const PanGateMgr = preload("res://scripts/systems/pan_gate_manager.gd")

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
		"res://data/enemies.json", "res://data/enemies_ch04.json", "res://data/enemies_ch05.json", "res://data/enemies_ch06.json", "res://data/enemies_ch07.json", "res://data/enemies_ch08.json",
		"res://data/maps.json", "res://data/maps_ch04.json", "res://data/maps_ch05.json", "res://data/maps_ch06.json", "res://data/maps_ch07.json", "res://data/maps_ch08.json",
		"res://data/quests_ch01.json", "res://data/quests_ch04.json", "res://data/quests_ch05.json", "res://data/quests_ch06.json", "res://data/quests_ch07.json", "res://data/quests_ch08.json",
		"res://data/dialogues_ch04.json", "res://data/dialogues_ch05.json", "res://data/dialogues_ch06.json", "res://data/dialogues_ch07.json", "res://data/dialogues_ch08.json"
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

	_assert(GameDatabase.skills_by_id.size() == 24, "24 skills loaded", "got %d" % GameDatabase.skills_by_id.size())
	for sid in GameDatabase.skills_by_id.keys():
		var sk: Dictionary = GameDatabase.skills_by_id[sid]
		_assert(str(sk.get("name", "")) != "" and str(sk.get("icon", "")).begins_with("res://"), "Skill valid: " + str(sid))

	_assert(GameDatabase.items_by_id.size() >= 52, "52+ alchemy items loaded", "got %d" % GameDatabase.items_by_id.size())
	_assert(GameDatabase.recipes_list.size() >= 24, "24+ alchemy recipes loaded", "got %d" % GameDatabase.recipes_list.size())
	for rec in GameDatabase.recipes_list:
		var out_id: String = str(rec.get("output_item", ""))
		_assert(GameDatabase.items_by_id.has(out_id), "Recipe output exists: " + out_id)
		var ings: Dictionary = rec.get("ingredients", {})
		for ik in ings.keys():
			_assert(GameDatabase.items_by_id.has(str(ik)), "Recipe ingredient exists: " + str(ik))
		_assert(int(rec.get("tier", 0)) >= 1, "Recipe tier >= 1: " + str(rec.get("id", "")))

	_assert(GameDatabase.equipment_slots.size() == 10, "10 equipment slots")
	_assert(GameDatabase.equipment_rarities.size() == 6, "6 equipment rarities")
	_assert(GameDatabase.equipment_sets.size() >= 8, "8+ equipment sets")
	_assert(GameDatabase.equipment_templates.size() >= 46, "46+ equipment templates")
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
	_assert(GameDatabase.enemies_by_id.size() >= 79, "79+ enemies loaded", "got %d" % GameDatabase.enemies_by_id.size())
	_assert(boss_cnt >= 41, "41+ bosses loaded", "got %d" % boss_cnt)

	_assert(GameDatabase.all_quests.size() >= 66, "66+ quests loaded", "got %d" % GameDatabase.all_quests.size())
	var seen_qids: Dictionary = {}
	for q in GameDatabase.all_quests:
		var qid: String = str(q.get("id", ""))
		_assert(qid != "" and not seen_qids.has(qid), "Quest ID unique: " + qid)
		seen_qids[qid] = true

	_assert(GameDatabase.maps_ordered.size() >= 46, "46+ maps loaded", "got %d" % GameDatabase.maps_ordered.size())
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
# SUITE 3: WORLD PORTAL GRAPH CONNECTIVITY (46 MAPS BFS)
# =========================================================
func _suite_03_portal_graph_bfs() -> void:
	print("[Suite 3] World Portal Graph Connectivity (46 Maps BFS)...")
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
		"dan_duong": 2, "vo_duong": 1, "am_duong": 3, "am_vong": 2,
		"last_harvest_playtime": 12.5, "total_harvests": 3, "ziyan_expeditions": 4, "strong_rank_cleared": {}
	}
	PlayerData.ma_doc_ban_stacks = 7
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
	_assert(PlayerData.realm_index == 5 and PlayerData.stage == 4, "Restored realm & stage")
	_assert(PlayerData.gold == 12345 and PlayerData.enhance_stones == 77, "Restored currency")
	_assert(PlayerData.fire_energy == 195 and PlayerData.tower_best_floor == 9, "Restored tower stats")
	_assert(PlayerData.auction_wins == 4 and PlayerData.auction_consigned_total == 17, "Restored auction stats")
	_assert(PlayerData.weapon_core_sockets == ["core_hoa_3", "core_loi_5", ""], "Restored 3 weapon core sockets")
	_assert(PlayerData.has_flag("ch05_huan_nhi_reunited"), "Restored story_flags")
	_assert(PlayerData.get_affection("huan_nhi") == 85, "Restored heroine affection")
	_assert(int(PlayerData.skill_mastery_uses.get("bat_cuc_bang", 0)) == 42, "Restored skill mastery")
	_assert(str(PlayerData.get_boss_rush_record("la_hau_boss", "nightmare").get("best_grade", "")) == "SS", "Restored boss rush record")
	_assert(PanGateMgr.get_hall_level(PlayerData, "dan_duong") == 2 and PanGateMgr.get_hall_level(PlayerData, "am_duong") == 3 and PanGateMgr.get_hall_level(PlayerData, "am_vong") == 2, "Restored pan_gate_state 4 halls")
	_assert(PlayerData.ma_doc_ban_stacks == 7, "Restored ma_doc_ban_stacks")
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
	_assert(PlayerData.realm_index == 8 and PlayerData.stage == 9, "DEMO realm is Dau Tong 9 Tinh")
	_assert(PlayerData.has_flag("ch04_completed") and PlayerData.has_flag("ch05_completed") and PlayerData.has_flag("ch06_completed") and PlayerData.has_flag("ch07_completed") and PlayerData.has_flag("ch08_completed") and PlayerData.has_flag("ch07_viem_minh_founded"), "DEMO unlocks Ch01-Ch08 story flags")
	_assert(PlayerData.unlocked_flames.size() == 28, "DEMO unlocks all 28 flames")
	_assert(PlayerData.unlocked_skills.size() == GameDatabase.skills_by_id.size(), "DEMO unlocks all 24 skills")
	_assert(PlayerData.unlocked_companions.size() == 7 and PlayerData.unlocked_companions.has("thien_hoa_ton_gia"), "DEMO unlocks all 7 companions incl. Thien Hoa Ton Gia")
	_assert(PlayerData.has_van_lac_passive() and PlayerData.has_dau_vuong_wings() and PlayerData.has_dau_tong_void_step() and PlayerData.has_tam_thien_immortal_body(), "DEMO enables Van Lac, Dau Tong Void Step & #9 Tam Thien Immortal Body")
	_assert(PlayerData.get_assist_mode() == "thien_yeu_khoi", "DEMO upgrades [T] Assist to Chuan Thien Yeu Khoi")
	_assert(PanGateMgr.is_viem_minh_evolved(PlayerData) and PanGateMgr.get_hall_level(PlayerData, "am_vong") == 2, "DEMO initializes Viem Minh Lv.2 x4 halls")
	_assert(PlayerData.weapon_core_sockets.size() == 3 and PlayerData.weapon_core_sockets[0] == "core_tinh_7", "DEMO sockets 3 cores incl. core_tinh_7")
	var has_34: bool = false
	for r in PlayerData.story_relics:
		if str(r).find("3/4") != -1:
			has_34 = true
	_assert(has_34, "DEMO relic displays 3/4 Tinh Lien Yeu Hoa fragments")


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
	_assert(world.get("boss_rush_mgr") != null and world.get("tower_mgr") != null, "WorldStage delegates initialized")
	_assert(
		hud.get("panel_pause_settings") != null
		and hud.get("panel_world_map_bestiary") != null
		and hud.get("panel_tower_boss_rush") != null
		and hud.get("panel_alchemy") != null
		and hud.get("panel_auction") != null
		and hud.get("panel_equipment") != null,
		"All 6 extracted HUD panels initialized"
	)

	# Mở toàn bộ modal & tab để đảm bảo 0 lỗi dựng UI sau refactor
	var modal_host: Control = hud.get("modal_content_host") as Control
	for mk in ["pause", "equipment", "skills", "breakthrough", "alchemy", "flames"]:
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
# SUITE 9: 8-FRAME DEFAULT SPRITESHEET & CH.04-08 ART VERIFICATION
# =========================================================
func _suite_09_8frame_spritesheets() -> void:
	print("[Suite 9] 8-Frame Default Spritesheet & Unique Art Verification (8 Player + 41 Boss + 24 Skills + 13 Tiles + 23 NPCs)...")
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
	_assert(checked_boss_sheets.size() == 41, "Verified all 41/41 unique boss anim sheets are 8 frames", "got %d" % checked_boss_sheets.size())

	# Kiểm tra 24/24 Đấu Kỹ đều có icon riêng biệt (không tái sử dụng trùng lặp)
	var unique_skill_icons: Dictionary = {}
	for sid in GameDatabase.skills_by_id.keys():
		var sk: Dictionary = GameDatabase.skills_by_id[sid]
		var ip: String = str(sk.get("icon", ""))
		var itex: Texture2D = load(ip)
		_assert(itex != null and itex.get_width() == 56 and itex.get_height() == 56, "Skill icon is 56x56: " + ip)
		unique_skill_icons[ip] = true
	_assert(unique_skill_icons.size() == 24, "All 24 skills have 24 unique icons", "got %d" % unique_skill_icons.size())

	# Kiểm tra 13 tileset vùng mới Ch.04–08 chuẩn 128x128
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
		"res://assets/sprites/tiles/tinh_vuc_starfield.png"
	]
	for tp in new_tiles:
		var ttex: Texture2D = load(tp)
		_assert(ttex != null and ttex.get_width() == 128 and ttex.get_height() == 128, "New regional tile is 128x128: " + tp)

	# Kiểm tra 23 sprite NPC mới Ch.04–08
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
		"res://assets/sprites/npcs/npc_hung_chien.png"
	]
	for np in new_npcs:
		var ntex: Texture2D = load(np)
		_assert(ntex != null and ntex.get_width() >= 92 and ntex.get_height() >= 92, "New Ch.04-08 NPC sprite loads cleanly: " + np)


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

	for v8 in ["space_lock", "emperor_five_seals", "flame_buff_tier3", "soul_shock_palm", "thunder_clone", "thien_yeu_khoi_assist"]:
		var vb8 := SkillVfxBurst.new()
		add_child(vb8)
		vb8.configure(v8, Vector2.ZERO, Vector2.RIGHT, 210.0, 0.65, Color("#FFFFFF"), Color("#C77DFF"), Color("#FFD166"))
		_assert(vb8.vfx_mode == v8, "SkillVfxBurst configures Ch.08 mode cleanly: " + v8)
		vb8.queue_free()


