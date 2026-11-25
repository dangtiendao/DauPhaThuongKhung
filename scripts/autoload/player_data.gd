extends Node
## Lưu trữ toàn bộ trạng thái tu luyện Chuẩn Cốt Truyện 100% — Chương 01 -> Chương 08 (Quyển I, II & Mở Màn Quyển III):
## - Khởi đầu phút 0: Đấu Chi Khí 3 Đoạn, TAY KHÔNG, chưa có Dược Lão, chưa có vũ khí, chưa có Đấu Kỹ, chưa có Hỏa Liên!
## - Hỗ trợ Save 3 Ô, Auto-Save/Auto-Continue, Chế Độ DEMO, 10 Ô Trang Bị + Khảm Ma Hạch, 24 Đấu Kỹ, 46 Bản Đồ, 66 Mốc Cốt Truyện, Viêm Minh & 7 Đồng Hành!

const LEGACY_SAVE_PATH: String = "user://dptk_savegame.json"
const SaveLoadMgr = preload("res://scripts/systems/save_load_manager.gd")
const PanGateMgr = preload("res://scripts/systems/pan_gate_manager.gd")
const HeroineAffectionMgr = preload("res://scripts/systems/heroine_affection_manager.gd")
const StoryProgHelper = preload("res://scripts/systems/story_progression_helper.gd")
const NineTurnMgr = preload("res://scripts/systems/nine_turn_manager.gd")
const SaintRealmMgr = preload("res://scripts/systems/saint_realm_manager.gd")
const EmperorRealmMgr = preload("res://scripts/systems/emperor_realm_manager.gd")
const REALM_DEF_MULT: Dictionary = { 3: 1.18, 4: 1.32, 5: 1.42, 6: 1.52, 7: 1.64, 8: 1.78, 9: 1.95, 10: 2.12, 11: 2.35, 12: 2.85 }
const REALM_SPD_MULT: Dictionary = { 7: 1.22, 8: 1.30, 9: 1.36, 10: 1.42, 11: 1.48, 12: 1.60 }
const REALM_POISE_BONUS: Dictionary = { 5: 15.0, 6: 25.0, 7: 35.0, 8: 48.0, 9: 62.0, 10: 72.0, 11: 82.0, 12: 95.0 }
const REALM_REACH_MULT: Dictionary = { 5: 1.20, 6: 1.28, 7: 1.35, 8: 1.42, 9: 1.50, 10: 1.54, 11: 1.58, 12: 1.65 }

const SETTINGS_PATH: String = "user://dptk_settings.json"
const MAX_SAVE_SLOTS: int = 3

var active_save_slot: int = 1
var last_played_slot: int = 1
var auto_save_enabled: bool = true
var auto_continue_on_start: bool = false
var session_returned_to_menu: bool = false
var is_demo_mode: bool = false

var auto_save_timer: float = 0.0
var auto_save_cooldown: float = 0.0
var saved_player_pos: Vector2 = Vector2.ZERO
var has_saved_player_pos: bool = false

var playtime_sec: float = 0.0
var current_map_id: String = "ch01_tieu_gia"

# Cảnh giới khởi đầu: Đấu Chi Khí 3 Đoạn (0 EXP)
var realm_index: int = 1
var stage: int = 3
var nine_turn_level: int = 0 # Cửu Chuyển Đấu Tôn (0..9 Chuyển Luân, +8%/Chuyển -> tối đa +72%)
var current_exp: int = 0
var bonus_soul: int = 0

var current_hp: float = 130.0
var current_qi: float = 70.0

var gold: int = 35
var enhance_stones: int = 0

# Cờ cốt truyện, Rương bí mật, Hảo Cảm Hồng Nhan & Kỳ Vật Cốt Truyện
var story_flags: Dictionary = {}
var opened_chests: Dictionary = {}
var affection: Dictionary = {
	"huan_nhi": 20,
	"tieu_y_tien": 0,
	"van_chi": 0,
	"thanh_lan": 0,
	"my_do_toa": 0
}
var story_relics: Array = []
var claimed_affection_milestones: Dictionary = {}
var cached_affection_bonuses: Dictionary = {}

# Trang bị 10 Ô, Khảm Ma Hạch (3 Rãnh Vũ Khí / Huyền Trọng Xích) & Túi đồ
var equipped_gear: Dictionary = {}
var gear_bag: Array = []
var cached_gear_bonuses: Dictionary = {}
var weapon_core_sockets: Array = ["", "", ""] # 3 rãnh khảm Ma Hạch (core_hoa_1..core_huyet_5)

# Tinh Hỏa Năng (Chương 05–06 & Thiên Phần Luyện Khí Tháp), Tháp Roguelite, Bàn Môn & Đấu Giá
var fire_energy: int = 0
var tower_best_floor: int = 0
var tower_active_buffs: Dictionary = {} # Chỉ tồn tại trong lượt leo Tháp hiện tại
var pan_gate_state: Dictionary = {}
var van_lac_cultivation_tick: float = 0.0
var auction_wins: int = 0
var auction_consigned_total: int = 0
var am_duong_buff_timer: float = 0.0

# Cơ chế Đấu Phá Thương Khung (Mở dần theo truyện)
var is_ruler_sealed: bool = false
var is_duoc_lao_active: bool = false
var is_flame_buff_active: bool = false
var equipped_flame_id: String = ""
var unlocked_flames: Array = []
var lotus_fusion_flames: Array = []

# Trạng thái chiến đấu tạm thời từ Dị Hỏa (Phật Nộ Hỏa Liên) & Boss
var enemies_killed_total: int = 0
var enemy_kill_counts: Dictionary = {} # enemy_id -> int (cho Đồ Giám Vạn Thú)
var skill_mastery_uses: Dictionary = {} # skill_id -> int (Thông Thạo Đấu Kỹ: Sơ Khuy -> Đỉnh Phong)
var boss_rush_records: Dictionary = {} # "boss_id|diff" -> { "best_grade", "best_time", "clears" }
var lotus_shield_hp: float = 0.0
var lotus_dmg_red_timer: float = 0.0
var lotus_double_herb_timer: float = 0.0
var player_slow_timer: float = 0.0
var player_slow_ratio: float = 0.0
var ma_doc_ban_stacks: int = 0
var is_nhi_bien_active: bool = false
var is_tam_bien_active: bool = false
var is_toc_van_active: bool = false
var is_kim_khoi_tran_active: bool = false
var is_tinh_lien_tran_active: bool = false
var is_de_hon_active: bool = false
var ng_plus_cycle: int = 0
var huan_nhi_revive_used: bool = false
var immortal_revive_cd: float = 0.0
var tam_thien_regen_tick: float = 0.0

# Kho Đấu Kỹ đã học & Tùy biến gắn phím Q / E / R / F / T
var unlocked_skills: Array = []
var slot_q_skill: String = ""
var slot_e_skill: String = ""
var slot_r_skill: String = ""
var slot_f_skill: String = ""
var duoc_lao_assist_unlocked: bool = false

# Hệ thống Đồng Hành Trợ Chiến ([G] Triệu hồi / Chuyển đổi)
var unlocked_companions: Array = []
var active_companion_id: String = ""

# Túi Nạp Giới & Đan dược gắn nhanh phím [1] [2] [3]
var inventory: Dictionary = {
	"pill_ngung_huyet_tan": 1
}
var quick_hp_pill_id: String = "pill_ngung_huyet_tan"
var quick_qi_pill_id: String = "pill_hoi_khi_dan"

var active_quest_idx: int = 0
var active_quest_id: String = ""
var quest_progress: int = 0
var all_quests_done: bool = false
var completed_quest_ids: Dictionary = {}
var kim_viem_revive_used: bool = false


func _ready() -> void:
	load_user_settings()
	_init_canon_starter_state()
	_rebuild_gear_cache()
	_rebuild_affection_cache()
	recalculate_and_clamp(true)
	EventBus.enemy_killed.connect(_on_enemy_killed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if auto_save_enabled and is_in_gameplay_session():
			trigger_auto_save("đóng game", true)
		save_user_settings()


func _process(delta: float) -> void:
	if auto_save_cooldown > 0.0:
		auto_save_cooldown = maxf(0.0, auto_save_cooldown - delta)
	if not get_tree().paused:
		playtime_sec += delta
		if lotus_dmg_red_timer > 0.0:
			lotus_dmg_red_timer = maxf(0.0, lotus_dmg_red_timer - delta)
		if lotus_double_herb_timer > 0.0:
			lotus_double_herb_timer = maxf(0.0, lotus_double_herb_timer - delta)
		if player_slow_timer > 0.0:
			player_slow_timer = maxf(0.0, player_slow_timer - delta)
			if player_slow_timer <= 0.0:
				player_slow_ratio = 0.0
		if am_duong_buff_timer > 0.0:
			am_duong_buff_timer = maxf(0.0, am_duong_buff_timer - delta)
			if am_duong_buff_timer <= 0.0:
				EventBus.stats_changed.emit()
		# Hồi HP tự nhiên nhẹ từ Ma Hạch Mộc khảm trên vũ khí
		var core_regen: float = float(get_core_socket_totals().get("hp_regen", 0.0))
		if core_regen > 0.0 and current_hp > 0.0 and current_hp < get_max_hp():
			current_hp = minf(get_max_hp(), current_hp + core_regen * delta)
		# Nội tại thần thánh Vẫn Lạc Tâm Viêm (#14): "Tu Luyện Gian Lận Khí" — Tự nhảy +EXP Đấu Khí & +4% Max QI mỗi giây 24/7!
		if has_van_lac_passive() and is_in_gameplay_session():
			van_lac_cultivation_tick += delta
			if van_lac_cultivation_tick >= 1.0:
				van_lac_cultivation_tick -= 1.0
				var req_e: int = maxi(1000, get_required_exp())
				var passive_exp: int = clampi(int(round(float(req_e) * 0.004)), 120, 45000)
				add_exp(passive_exp)
				var mq: float = get_max_qi()
				if current_qi < mq:
					current_qi = minf(mq, current_qi + mq * 0.04)
					EventBus.qi_updated.emit(current_qi, mq)
		if auto_save_enabled and is_in_gameplay_session():
			auto_save_timer += delta
			if auto_save_timer >= 30.0:
				auto_save_timer = 0.0
				trigger_auto_save("định kỳ 30s")


func is_in_gameplay_session() -> bool:
	return not get_tree().get_nodes_in_group("world_stage").is_empty()


func load_user_settings() -> void:
	SaveLoadMgr.load_user_settings(self)


func save_user_settings() -> void:
	SaveLoadMgr.save_user_settings(self)


func set_auto_save_enabled(enabled: bool) -> void:
	auto_save_enabled = enabled
	auto_save_timer = 0.0
	save_user_settings()


func set_auto_continue_on_start(enabled: bool) -> void:
	auto_continue_on_start = enabled
	save_user_settings()


func get_best_continue_slot() -> int:
	return SaveLoadMgr.get_best_continue_slot(self)


func trigger_auto_save(reason: String = "tự động", force: bool = false) -> bool:
	if not auto_save_enabled:
		return false
	if not is_in_gameplay_session() and not force:
		return false
	if not force and auto_save_cooldown > 0.0:
		return false
	auto_save_cooldown = 3.0
	auto_save_timer = 0.0
	var ok: bool = save_game(active_save_slot, true)
	if ok:
		EventBus.auto_saved.emit(active_save_slot, reason)
	return ok


func reset_for_new_game(slot_idx: int = 1) -> void:
	active_save_slot = clampi(slot_idx, 1, MAX_SAVE_SLOTS)
	last_played_slot = active_save_slot
	is_demo_mode = false
	has_saved_player_pos = false
	saved_player_pos = Vector2.ZERO
	auto_save_timer = 0.0
	playtime_sec = 0.0
	realm_index = 1
	stage = 3
	nine_turn_level = 0
	current_exp = 0
	bonus_soul = 0
	gold = 35
	enhance_stones = 0
	active_quest_idx = 0
	active_quest_id = str(GameDatabase.all_quests[0].get("id", "")) if not GameDatabase.all_quests.is_empty() else ""
	quest_progress = 0
	all_quests_done = false
	completed_quest_ids = {}
	kim_viem_revive_used = false
	is_nhi_bien_active = false
	is_tam_bien_active = false
	is_toc_van_active = false
	is_kim_khoi_tran_active = false
	immortal_revive_cd = 0.0
	tam_thien_regen_tick = 0.0
	inventory = { "pill_ngung_huyet_tan": 1 }
	quick_hp_pill_id = "pill_ngung_huyet_tan"
	quick_qi_pill_id = "pill_hoi_khi_dan"
	enemies_killed_total = 0
	enemy_kill_counts = {}
	skill_mastery_uses = {}
	boss_rush_records = {}
	pan_gate_state = PanGateMgr.default_state()
	van_lac_cultivation_tick = 0.0
	_init_canon_starter_state()
	_rebuild_gear_cache()
	_rebuild_affection_cache()
	recalculate_and_clamp(true)
	save_user_settings()
	EventBus.equipment_changed.emit()
	EventBus.skills_updated.emit()
	EventBus.stats_changed.emit()
	EventBus.inventory_changed.emit()
	EventBus.quest_updated.emit()
	EventBus.flame_changed.emit(equipped_flame_id)
	EventBus.companion_changed.emit(active_companion_id)


func activate_demo_unlock_all(slot_idx: int = 3) -> void:
	StoryProgHelper.activate_demo_unlock_all(self, slot_idx)


func _init_canon_starter_state() -> void:
	StoryProgHelper.init_canon_starter_state(self)


func _rebuild_gear_cache() -> void:
	cached_gear_bonuses = EquipmentSystem.compute_total_bonuses(equipped_gear)


func trigger_initial_quest_banter() -> void:
	var q: Dictionary = get_current_quest()
	if not q.is_empty():
		EventBus.banter_triggered.emit(str(q.get("intro_log", "")))
		EventBus.quest_updated.emit()


# --- HẢO CẢM HỒNG NHAN (Ủy quyền cho HeroineAffectionManager) ---
func get_heroine_profiles() -> Array:
	return HeroineAffectionMgr.get_heroine_profiles()


func _rebuild_affection_cache() -> void:
	HeroineAffectionMgr.rebuild_affection_cache(self)


func get_affection_bonus(stat_key: String) -> float:
	if cached_affection_bonuses.is_empty():
		_rebuild_affection_cache()
	return float(cached_affection_bonuses.get(stat_key, 0.0))


func is_affection_milestone_claimed(heroine_key: String, req_pts: int) -> bool:
	return bool(claimed_affection_milestones.get("%s_%d" % [heroine_key, req_pts], false))


func claim_affection_milestone(heroine_key: String, req_pts: int) -> Dictionary:
	return HeroineAffectionMgr.claim_affection_milestone(self, heroine_key, req_pts)


func give_gift_to_heroine(heroine_key: String, item_id: String) -> Dictionary:
	return HeroineAffectionMgr.give_gift_to_heroine(self, heroine_key, item_id)


func get_active_affection_summary_text() -> String:
	return HeroineAffectionMgr.get_active_affection_summary_text(self)


func add_affection(npc_key: String, delta_pts: int) -> void:
	if npc_key == "" or delta_pts == 0:
		return
	var prev_v: int = int(affection.get(npc_key, 0))
	var next_v: int = clampi(prev_v + delta_pts, 0, 100)
	affection[npc_key] = next_v
	_rebuild_affection_cache()
	recalculate_and_clamp(false)
	for m in [25, 50, 75, 100]:
		if prev_v < m and next_v >= m:
			EventBus.banter_triggered.emit("HỒNG NHAN THĂNG CẤP! Hảo cảm đạt mốc %d/100 — Mở khóa Buff mới (bấm [M] nhận Quà Tri Kỷ)!" % m)
	EventBus.stats_changed.emit()


func get_affection(npc_key: String) -> int:
	return int(affection.get(npc_key, 0))


func add_story_relic(relic_title: String) -> void:
	if relic_title == "" or story_relics.has(relic_title):
		return
	story_relics.append(relic_title)
	EventBus.stats_changed.emit()


# --- CỜ CỐT TRUYỆN, RƯƠNG ẨN, KHO ĐẤU KỸ & ĐỒNG HÀNH ---
func has_flag(flag_name: String) -> bool:
	if flag_name == "":
		return true
	return bool(story_flags.get(flag_name, false))


func is_chest_opened(chest_id: String) -> bool:
	return bool(opened_chests.get(chest_id, false))


func mark_chest_opened(chest_id: String) -> void:
	if chest_id == "":
		return
	opened_chests[chest_id] = true
	EventBus.chest_opened.emit(chest_id)
	trigger_auto_save("mở bảo rương")


func unlock_skill(skill_id: String, preferred_slot: String = "") -> bool:
	if skill_id == "" or not GameDatabase.skills_by_id.has(skill_id):
		return false
	var newly_added: bool = false
	if not unlocked_skills.has(skill_id):
		unlocked_skills.append(skill_id)
		newly_added = true

	if preferred_slot == "Q":
		slot_q_skill = skill_id
	elif preferred_slot == "E":
		slot_e_skill = skill_id
	elif preferred_slot == "R":
		slot_r_skill = skill_id
	elif preferred_slot == "F":
		slot_f_skill = skill_id
	elif newly_added:
		if slot_q_skill == "":
			slot_q_skill = skill_id
		elif slot_e_skill == "":
			slot_e_skill = skill_id
		elif slot_r_skill == "":
			slot_r_skill = skill_id

	EventBus.skills_updated.emit()
	return newly_added


func is_skill_unlocked(skill_id: String) -> bool:
	return unlocked_skills.has(skill_id)


func assign_skill_to_slot(slot_key: String, skill_id: String) -> bool:
	if not unlocked_skills.has(skill_id):
		return false
	if slot_key == "Q":
		slot_q_skill = skill_id
	elif slot_key == "E":
		slot_e_skill = skill_id
	elif slot_key == "R":
		slot_r_skill = skill_id
	elif slot_key == "F" and skill_id == "phat_no_hoa_lien":
		slot_f_skill = skill_id
	else:
		return false
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.skills_updated.emit()
	return true


func get_lotus_max_flames() -> int:
	if EmperorRealmMgr.is_viem_de_emperor(self):
		return 23
	if SaintRealmMgr.has_tieu_y_spirit(self):
		return 6
	if has_flag("FLAG_FIVE_FLAME_LOTUS") or has_flag("ch09_duoc_tran_revived") or is_demo_mode:
		return 5
	return 4


func toggle_lotus_fusion_flame(flame_id: String) -> String:
	if not unlocked_flames.has(flame_id):
		return "Bạn chưa thu phục ngọn Hỏa này!"
	if lotus_fusion_flames.has(flame_id):
		lotus_fusion_flames.erase(flame_id)
		EventBus.skills_updated.emit()
		return "Đã tháo %s khỏi khe dung hợp Hỏa Liên." % str(GameDatabase.get_flame_def(flame_id).get("name", flame_id))
	var max_f: int = get_lotus_max_flames()
	if lotus_fusion_flames.size() >= max_f:
		return "Tối đa dung hợp %d loại Hỏa trong Phật Nộ Hỏa Liên!" % max_f
	lotus_fusion_flames.append(flame_id)
	EventBus.skills_updated.emit()
	return "Đã ghép %s vào Hỏa Liên (%d/%d khe)!" % [str(GameDatabase.get_flame_def(flame_id).get("name", flame_id)), lotus_fusion_flames.size(), max_f]


func unlock_companion(comp_id: String, auto_summon: bool = true) -> void:
	if comp_id == "":
		return
	if not unlocked_companions.has(comp_id):
		unlocked_companions.append(comp_id)
	if auto_summon or active_companion_id == "":
		active_companion_id = comp_id
	EventBus.companion_changed.emit(active_companion_id)


func cycle_companion() -> String:
	if unlocked_companions.is_empty():
		return ""
	if active_companion_id == "":
		active_companion_id = str(unlocked_companions[0])
	else:
		var idx: int = unlocked_companions.find(active_companion_id)
		if idx == -1 or idx >= unlocked_companions.size() - 1:
			active_companion_id = ""
		else:
			active_companion_id = str(unlocked_companions[idx + 1])
	EventBus.companion_changed.emit(active_companion_id)
	return active_companion_id


func get_companion_display_name(comp_id: String) -> String:
	if comp_id == "tieu_y_tien":
		if has_flag("ch08_ma_doc_ban_cured"):
			return "Thiên Độc Nữ Tiểu Y Tiên (Tam Tinh Đấu Tôn · Bổn Mệnh Độc Đan)"
		if has_flag("ch07_thien_doc_nu_joined"):
			return "Thiên Độc Nữ Tiểu Y Tiên (Đấu Tông Tóc Bạc · Độc Cầu & Trị Liệu)"
		return "Tiểu Y Tiên (Hồi Máu & Độc Châm)"
	elif comp_id == "duoc_lao_phantom":
		if has_flag("ch09_duoc_tran_revived"):
			return "Bán Thánh Dược Trần (Bản Thể Phục Sinh · Cốt Linh Băng Phong)"
		return "Hồn Ảnh Dược Lão (Cốt Linh Hộ Pháp)"
	elif comp_id == "thai_lan":
		return "Thải Lân (Thất Thải Thôn Thiên Mãng)"
	elif comp_id == "huan_nhi":
		if has_flag("ch10_tinh_lien_tamed"):
			return "Cổ Huân Nhi (Tứ Tinh Đấu Thánh · Kim Đế Phần Thiên Viêm & Tâm Ý Hồi Sinh)"
		return "Tiêu Huân Nhi (Kim Đế Phần Thiên Viêm)"
	elif comp_id == "tu_nghien":
		if has_flag("ch09_co_long_unified"):
			return "Long Hoàng Tử Nghiên (Thái Hư Cổ Long Hoàng · Cổ Long Kiếm & Tầm Bảo)"
		return "Tử Nghiên (Thái Hư Cổ Long · Choáng & Tầm Bảo)"
	elif comp_id == "dia_yeu_khoi":
		if has_flag("ch09_forged_ten_puppets"):
			return "Thiên Yêu Khôi Thống Lĩnh (Kim Sắc Lôi Trì · Cửu Tinh Đấu Tôn)"
		if has_flag("ch08_dan_hoi_champion"):
			return "Chuẩn Thiên Yêu Khôi (Khôi Lỗi Hoàng Kim Ngũ Lôi · Đấu Tôn Đỉnh)"
		return "Địa Yêu Khôi (Khôi Lỗi Đấu Tông Bất Hoại · Lôi Bộc & Phá Thế)"
	elif comp_id == "thien_hoa_ton_gia":
		return "Thiên Hỏa Tôn Giả (Đấu Tôn · Ngũ Luân Ly Hỏa Pháp & Hồi Đấu Khí)"
	elif comp_id == "thanh_lan":
		if has_flag("sq_10_02_bo_de_dan_gifted"):
			return "Thanh Lân (Nhất Tinh Đấu Thánh · Cửu Đầu Bích Xà Khống Thú)"
		return "Thanh Lân (Thiên Xà Phủ Đấu Tôn · Bích Xà Tam Hoa Khống Thú)"
	elif comp_id == "van_van_hoa_tong":
		return "Tông Chủ Vân Vận (Hoa Tông Bát Tinh Đấu Tôn · Phong Cực Hoa Vũ)"
	elif comp_id == "bac_vuong":
		if SaintRealmMgr.has_bac_vuong_seven_star(self):
			return "Siêu Khôi Lỗi BẮC VƯƠNG (Thất Tinh Đấu Thánh · Cửu Huyền Kim Lôi)"
		return "Siêu Khôi Lỗi BẮC VƯƠNG (Lục Tinh Đấu Thánh · Kim Cương Bất Hoại)"
	elif comp_id == "thai_lan_tieu_tieu":
		return "Thải Lân & Công Chúa Nhỏ TIÊU TIÊU (Thất Thải Thôn Thiên Liên Kích)"
	elif comp_id == "chuc_khon_long_hoang":
		return "Lão Long Hoàng CHÚC KHÔN (Thái Hư Cổ Long · Cửu Tinh Đỉnh)"
	return "Thu Hồi"


func has_dau_ton_spatial_blink() -> bool:
	return realm_index >= 9 or has_flag("ch09_nirvana_awakened") or has_flag("ch09_broke_dau_ton")


func has_van_lac_passive() -> bool:
	return unlocked_flames.has("di_hoa_14_van_lac") or has_flag("ch06_absorbed_van_lac")


func has_tam_thien_immortal_body() -> bool:
	return unlocked_flames.has("di_hoa_09_tam_thien") or has_flag("ch08_completed")


func has_dau_tong_void_step() -> bool:
	return realm_index >= 8 or has_flag("ch08_broke_dau_tong")


func has_ma_doc_ban() -> bool:
	return has_flag("ch07_ma_doc_ban_active") and not has_flag("ch08_ma_doc_ban_cured")


func get_ma_doc_ban_atk_bonus_pct() -> float:
	if not has_ma_doc_ban():
		return 0.0
	return float(clampi(ma_doc_ban_stacks, 0, 20))


func has_dau_vuong_wings() -> bool:
	if realm_index >= 6:
		return true
	var wg = equipped_gear.get("wings", {})
	if wg is Dictionary and not wg.is_empty():
		var tid: String = str(wg.get("template_id", ""))
		return tid in ["wing_dau_khi_hoa_duc", "wing_thien_yeu_hoang_canh", "wing_dap_hu_khong_anh", "wing_xe_rach_hu_khong", "wing_tinh_lien_song_phung_duc", "wing_van_hoa_thai_so_duc"]
	return false


func set_story_flag(flag_name: String) -> void:
	StoryProgHelper.set_story_flag(self, flag_name)


# =========================================================
# DATA-DRIVEN STORY ENGINE (Ủy quyền cho StoryProgressionHelper)
# =========================================================
func evaluate_story_condition(cond: Dictionary) -> bool:
	return StoryProgHelper.evaluate_story_condition(self, cond)


func execute_story_effect(eff: Dictionary, skip_flag_id: String = "") -> Dictionary:
	return StoryProgHelper.execute_story_effect(self, eff, skip_flag_id)


func get_assist_mode() -> String:
	if EmperorRealmMgr.is_viem_de_emperor(self):
		return "viem_de_phap_tuong"
	if has_flag("ch10_tinh_lien_tamed"):
		return "tinh_lien_hop_bich"
	if has_flag("ch10_bac_vuong_forged"):
		return "bac_vuong"
	if has_flag("ch09_duoc_tran_revived"):
		return "ban_thanh_duoc_tran"
	if has_flag("ch08_dan_hoi_champion"):
		return "thien_yeu_khoi"
	if has_flag("ch07_dia_yeu_khoi_forged"):
		return "dia_yeu_khoi"
	if has_flag("ch04_medusa_saved"):
		return "medusa_dau_tong"
	if has_flag("ch04_duoc_lao_sleeping"):
		return "sleeping"
	if duoc_lao_assist_unlocked:
		return "duoc_lao"
	return "locked"


func get_enemy_damage_bonus_mult(target_enemy_id: String, target_enemy_name: String = "") -> float:
	var mult: float = 1.0
	var low_id: String = target_enemy_id.to_lower()
	var low_nm: String = target_enemy_name.to_lower()
	var is_soul_hall: bool = (low_id.find("hon_dien") != -1 or low_id.find("vu_ho_phap") != -1 or low_id.find("am_anh_hon_su") != -1 or low_id.find("mo_cot") != -1 or low_id.find("thanh_hai") != -1 or low_id.find("trich_tinh") != -1 or low_id.find("hac_bach") != -1 or low_id.find("vong_hon") != -1 or low_id.find("hon_ngoc") != -1 or low_id.find("nhan_dien") != -1 or low_id.find("pho_dien_chu") != -1 or low_id.find("hon_diet_sinh") != -1 or low_id.find("su_thien") != -1 or low_id.find("hon_hu_tu") != -1 or low_id.find("hu_vo") != -1 or low_id.find("tu_ma_thanh") != -1 or low_id.find("hon_thien_de") != -1 or low_id.find("huyet_ve") != -1 or low_nm.find("hồn điện") != -1 or low_nm.find("hồn đế") != -1 or low_nm.find("trích tinh") != -1 or low_nm.find("thiên tôn") != -1 or low_nm.find("hồn diệt") != -1)
	if has_flag("ch04_tieu_toc_no_huyet"):
		if is_soul_hall or low_id.find("van_lam") != -1 or low_id.find("van_yen") != -1 or low_id.find("van_lang") != -1 or low_id.find("van_son") != -1 or low_id.find("nap_lan") != -1 or low_id.find("mac_thua") != -1 or low_nm.find("vân lam") != -1:
			mult *= 1.15 # Tiêu Tộc Nộ Huyết (+15% ATK vs Vân Lam Tông & Hồn Điện!)
	if has_flag("ch06_duoc_lao_memory_done"):
		if is_soul_hall or low_id.find("han_phong") != -1 or low_nm.find("hàn phong") != -1:
			mult *= 1.25 # Ký Ức Phản Sư Dược Lão (+25% ATK vs Hàn Phong & Hồn Điện!)
	if has_flag("ch07_tieu_chien_relic_done"):
		if is_soul_hall or low_id.find("han_phong") != -1 or low_nm.find("hồn sứ") != -1:
			mult *= 1.15 # Di Nguyện Phụ Thân Tiêu Chiến (+15% ATK vs Hồn Điện!)
	if has_flag("ch08_huyen_y_memory_done"):
		if is_soul_hall or low_nm.find("mộ cốt") != -1:
			mult *= 1.15 # Hồi Ức Dược Trần & Huyền Y (+15% ATK vs Hồn Điện!)
	return mult


func get_enemy_damage_taken_mult(attacker_id: String, attacker_name: String = "") -> float:
	var mult: float = 1.0
	var low_id: String = attacker_id.to_lower()
	var low_nm: String = attacker_name.to_lower()
	var is_hon_dien: bool = (low_id.find("hon_dien") != -1 or low_id.find("mo_cot") != -1 or low_id.find("thanh_hai") != -1 or low_id.find("vu_ho_phap") != -1 or low_id.find("am_anh_hon_su") != -1 or low_id.find("trich_tinh") != -1 or low_id.find("hac_bach") != -1 or low_id.find("vong_hon") != -1 or low_id.find("hon_ngoc") != -1 or low_id.find("nhan_dien") != -1 or low_id.find("pho_dien_chu") != -1 or low_id.find("hon_diet_sinh") != -1 or low_nm.find("hồn điện") != -1 or low_nm.find("mộ cốt") != -1 or low_nm.find("thanh hải") != -1 or low_nm.find("trích tinh") != -1 or low_nm.find("hồn diệt") != -1)
	if is_hon_dien:
		var pend = equipped_gear.get("pendant", {})
		var has_pend: bool = (pend is Dictionary and str(pend.get("template_id", "")) == "pend_huyen_tam_ho_hon")
		if has_flag("ch08_huyen_y_memory_done") or has_pend:
			mult *= 0.75 # Huyền Tâm Hộ Hồn Bội (-25% sát thương Hồn Điện!)
	if is_kim_khoi_tran_active:
		mult *= 0.50 # Thập Tuyệt Kim Khôi Trận (-50% sát thương nhận vào!)
	if is_tinh_lien_tran_active:
		mult *= 0.50 # Tịnh Liên Yêu Trận (-50% ATK kẻ địch bên trong!)
	return mult


func is_alchemy_unlocked() -> bool:
	return has_flag("duoc_lao_awake")


func is_flames_unlocked() -> bool:
	return has_flag("duoc_lao_awake")


func has_weapon_equipped() -> bool:
	var w = equipped_gear.get("weapon", {})
	return (w is Dictionary) and not w.is_empty()


func has_huyen_trong_xich_equipped() -> bool:
	var w = equipped_gear.get("weapon", {})
	if w is Dictionary and not w.is_empty():
		var tid: String = str(w.get("template_id", ""))
		return tid in ["wpn_huyen_trong_xich", "wpn_xich_ngung_vat", "wpn_xich_luu_ly_viem", "wpn_xich_tam_sac_viem", "wpn_xich_tam_thien_tinh_viem", "wpn_xich_tao_hoa_thien_mo", "wpn_xich_tinh_lien_luan_hoi", "wpn_di_hoa_hang_co_xich"]
	return false


func has_tu_van_duc_equipped() -> bool:
	var wg = equipped_gear.get("wings", {})
	if wg is Dictionary and not wg.is_empty():
		var tid: String = str(wg.get("template_id", ""))
		return tid in ["wing_tu_van_duc", "wing_hac_diem_tu_van_duc", "wing_dau_khi_hoa_duc", "wing_thien_yeu_hoang_canh", "wing_dap_hu_khong_anh", "wing_xe_rach_hu_khong", "wing_tinh_lien_song_phung_duc", "wing_van_hoa_thai_so_duc"]
	return false


func get_skill_in_slot(slot_key: String) -> String:
	if slot_key == "Q":
		return slot_q_skill
	elif slot_key == "E":
		return slot_e_skill
	elif slot_key == "R":
		return slot_r_skill
	elif slot_key == "F":
		return slot_f_skill
	return ""


# --- 6 CHỈ SỐ CỐT LÕI + TRANG BỊ 10 Ô + KỲ VẬT + HẢO CẢM HỒNG NHAN ---
func get_gear_bonus(stat_key: String) -> float:
	return float(cached_gear_bonuses.get(stat_key, 0.0))


func get_max_hp() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var total: float = 65.0 + get_gear_bonus("hp") + float(core_t.get("hp", 0.0))
	if has_flag("ch06_got_dia_tam_nhu"):
		total += 1200.0 # Địa Tâm Tôi Thể Nhũ tẩy tủy rèn cốt!
	if has_flag("ch06_tu_nghien_candy_done"):
		total += 500.0 # Long Huyết Chi Tử Nghiên tặng!
	if has_flag("ch07_thai_lan_pill_done"):
		total += 1200.0 # Thiên Hồn Dung Huyết Đan — Thải Lân & Tiểu Tiêu Tiêu hộ mệnh!
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += float(st_dict.get("hp", 20.0)) * float(stages_cnt)
	total *= (1.0 + (get_affection_bonus("hp_pct") + float(tower_active_buffs.get("hp_pct", 0.0))) / 100.0)
	return total * NineTurnMgr.get_stat_multiplier(self) * EmperorRealmMgr.get_emperor_stat_mult(self)


func get_max_qi() -> float:
	var total: float = 35.0 + get_gear_bonus("qi")
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += float(st_dict.get("qi", 12.0)) * float(stages_cnt)
	if has_ma_doc_ban():
		total *= 0.90 # Phong ấn Ma Độc Ban (Hạt Tất Nham): khóa 10% Đấu Khí cho tới khi giải ở Trung Châu!
	if is_toc_van_active:
		total *= 1.50 # Tộc Văn Tiêu Tộc: +50% Đấu Khí tối đa trong lúc bùng nổ!
	return total * NineTurnMgr.get_stat_multiplier(self)


func get_atk() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var base_atk: float = 8.0 + get_gear_bonus("atk") + float(core_t.get("atk", 0.0))
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		base_atk += float(st_dict.get("atk", 4.0)) * float(stages_cnt)
	var f_def: Dictionary = get_active_flame_def()
	var mult: float = float(f_def.get("atk_mult", 1.0)) if not f_def.is_empty() else 1.0
	mult *= (1.0 + (get_affection_bonus("atk_pct") + float(tower_active_buffs.get("atk_pct", 0.0)) + PanGateMgr.get_atk_bonus_pct(self) + SaintRealmMgr.get_achievement_atk_bonus_pct(self) + get_ma_doc_ban_atk_bonus_pct()) / 100.0)
	if has_flag("tu_hon_done"):
		mult *= 1.05 # Ấn Ký Tôn Nghiêm!
	if has_flag("ch05_completed"):
		mult *= 1.05 # Đệ Nhất Tân Sinh Vương!
	if has_flag("ch07_lien_quan_aura"):
		mult *= 1.15 # Liên Quân Già Nam (Tô Thiên áp trận Ma Viêm Cốc)!
	if has_flag("ch08_ma_doc_ban_cured"):
		mult *= 1.15 # Cộng Hưởng Bổn Mệnh Độc Đan (Giải Ma Độc Ban -> +15% ATK vĩnh viễn!)
	if is_duoc_lao_active:
		var amode: String = get_assist_mode()
		mult *= 5.00 if amode == "viem_de_phap_tuong" else (4.35 if amode == "tinh_lien_hop_bich" else (3.80 if amode == "bac_vuong" else (3.35 if amode == "ban_thanh_duoc_tran" else (3.05 if amode == "thien_yeu_khoi" else (2.70 if amode == "dia_yeu_khoi" else (2.45 if amode == "medusa_dau_tong" else 2.2))))))
	if is_tam_bien_active:
		mult *= 1.85 # Thiên Hỏa Tam Huyền Biến — Tam Biến (Phần Viêm Cốc)!
	elif is_nhi_bien_active:
		mult *= 1.65 # Thiên Hỏa Tam Huyền Biến — Nhị Biến!
	elif is_flame_buff_active:
		mult *= 1.45
	if is_toc_van_active:
		mult *= 1.35 if is_tam_bien_active else 1.55 # Tộc Văn Tiêu Tộc (cộng dồn Tam Biến đạt +150% ATK!)
	var pend = equipped_gear.get("pendant", {})
	if pend is Dictionary:
		var ptid: String = str(pend.get("template_id", ""))
		if ptid == "pend_loi_de_to_phu_an":
			mult *= 1.15 # Lôi Đế Tổ Phù Ấn (+15% Công Kích & Đấu Kỹ!)
		elif current_hp < get_max_hp() * 0.5:
			if ptid == "pend_thiet_kiem_trung_nghia":
				mult *= 1.15
			elif ptid == "pend_phu_nu_dong_tam_ket":
				mult *= 1.10
	if am_duong_buff_timer > 0.0:
		mult *= 1.25 # Âm Dương Huyền Long Đan!
	return base_atk * mult * NineTurnMgr.get_stat_multiplier(self) * EmperorRealmMgr.get_emperor_stat_mult(self)


func get_def() -> float:
	var total: float = 3.0 + get_gear_bonus("def")
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += float(st_dict.get("def", 2.0)) * float(stages_cnt)
	total *= (1.0 + (get_affection_bonus("def_pct") + float(tower_active_buffs.get("def_pct", 0.0)) + PanGateMgr.get_def_bonus_pct(self)) / 100.0)
	if has_flag("ch06_got_dia_tam_nhu"):
		total *= 1.15
	total *= float(REALM_DEF_MULT.get(mini(realm_index, 12), 1.0))
	var pend_d = equipped_gear.get("pendant", {})
	if pend_d is Dictionary and str(pend_d.get("template_id", "")) == "pend_phu_nu_dong_tam_ket" and current_hp < get_max_hp() * 0.5:
		total *= 1.10
	return total * NineTurnMgr.get_stat_multiplier(self) * EmperorRealmMgr.get_emperor_stat_mult(self)


func get_move_speed() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var base_spd: float = 220.0 + (get_gear_bonus("spd") + float(core_t.get("spd", 0.0))) * 1.35
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		base_spd += float(st_dict.get("spd", 2.0)) * float(stages_cnt) * 1.15
	base_spd = minf(base_spd, 485.0)
	base_spd *= (1.0 + (get_affection_bonus("spd_pct") + float(tower_active_buffs.get("spd_pct", 0.0))) / 100.0)
	if realm_index >= 7:
		base_spd *= float(REALM_SPD_MULT.get(mini(realm_index, 12), 1.22))
	elif has_dau_vuong_wings():
		base_spd *= 1.15
	if has_flag("secret_lang_anh_done"):
		base_spd *= 1.08
	if has_flag("ch08_escaped_phi_thien"):
		base_spd *= 1.03
	if is_ruler_sealed and has_huyen_trong_xich_equipped():
		base_spd *= 0.85
	if is_duoc_lao_active:
		var amode: String = get_assist_mode()
		base_spd *= 1.82 if amode == "viem_de_phap_tuong" else (1.70 if amode == "tinh_lien_hop_bich" else (1.64 if amode == "bac_vuong" else (1.58 if amode == "ban_thanh_duoc_tran" else (1.52 if amode == "thien_yeu_khoi" else (1.45 if amode == "dia_yeu_khoi" else (1.40 if amode == "medusa_dau_tong" else 1.35))))))
	if is_tam_bien_active:
		base_spd *= 1.45
	elif is_nhi_bien_active:
		base_spd *= 1.30
	elif is_flame_buff_active:
		base_spd *= 1.20
	if is_toc_van_active:
		base_spd *= 1.18
	base_spd *= (1.0 + float(NineTurnMgr.get_turn_level(self)) * 0.025)
	var amode_slow: String = get_assist_mode()
	if player_slow_timer > 0.0 and not is_de_hon_active and not (is_duoc_lao_active and (amode_slow in ["dia_yeu_khoi", "thien_yeu_khoi", "ban_thanh_duoc_tran", "bac_vuong", "tinh_lien_hop_bich", "viem_de_phap_tuong"])):
		base_spd *= (1.0 - clampf(player_slow_ratio, 0.0, 0.55))
	return base_spd


func get_soul() -> int:
	var core_t: Dictionary = get_core_socket_totals()
	var total: int = 5 + bonus_soul + SaintRealmMgr.get_achievement_soul_bonus(self) + int(round(get_gear_bonus("soul") + get_affection_bonus("soul") + float(core_t.get("soul", 0.0))))
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += int(st_dict.get("soul", 2)) * stages_cnt
	var soul_mult: float = 1.0 + PanGateMgr.get_soul_bonus_pct(self) / 100.0
	return int(round(float(total) * soul_mult * NineTurnMgr.get_stat_multiplier(self) * EmperorRealmMgr.get_emperor_stat_mult(self)))


func get_crit_chance() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var bonus_le: float = 6.0 if has_flag("ch07_tieu_le_cured") else 0.0
	var total_pct: float = get_gear_bonus("crit_chance") + get_affection_bonus("crit_chance") + float(core_t.get("crit_pct", 0.0)) + float(tower_active_buffs.get("crit_pct", 0.0)) + PanGateMgr.get_crit_bonus_pct(self) + bonus_le
	return clampf(0.12 + total_pct / 100.0, 0.05, 0.94)


func get_lifesteal_ratio() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var total_pct: float = get_gear_bonus("lifesteal") + get_affection_bonus("lifesteal") + float(core_t.get("lifesteal_pct", 0.0)) + float(tower_active_buffs.get("lifesteal_pct", 0.0))
	return clampf(total_pct / 100.0, 0.0, 0.45)


func get_cooldown_multiplier() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var tam_bien_cdr: float = 30.0 if is_tam_bien_active else 0.0
	var cdr: float = clampf((get_gear_bonus("cooldown_red") + get_affection_bonus("cooldown_red") + float(core_t.get("cd_red_pct", 0.0)) + float(tower_active_buffs.get("cd_red_pct", 0.0)) + tam_bien_cdr) / 100.0, 0.0, 0.72)
	return 1.0 - cdr


func get_poise_dmg_multiplier() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var bonus_pct: float = float(core_t.get("poise_pct", 0.0)) + float(tower_active_buffs.get("poise_pct", 0.0)) + float(REALM_POISE_BONUS.get(mini(realm_index, 12), 0.0))
	return 1.0 + bonus_pct / 100.0


func get_attack_reach_multiplier() -> float:
	return float(REALM_REACH_MULT.get(mini(realm_index, 12), 1.0))


func get_core_burn_dps() -> float:
	return float(get_core_socket_totals().get("burn_dps", 0.0))


func get_soul_realm_info() -> Dictionary:
	var cur_soul: int = get_soul()
	var best: Dictionary = { "id": "pham_canh", "name": "Phàm Cảnh Linh Hồn", "min_soul": 0, "alchemy_max_tier": 6, "radar_radius_px": 140 }
	for sr in GameDatabase.soul_realms_list:
		if sr is Dictionary and cur_soul >= int(sr.get("min_soul", 0)):
			best = sr
	return best


func get_soul_radar_radius() -> float:
	var sr: Dictionary = get_soul_realm_info()
	var rad: float = clampf(float(sr.get("radar_radius_px", 140.0)) * 2.8, 360.0, 1400.0)
	if active_companion_id == "tu_nghien":
		rad *= 1.45 # Tử Nghiên: Khứu Giác Tầm Bảo Cổ Long (+45% Radar)!
	return rad


func get_flame_dmg_multiplier() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var bonus_pct: float = get_gear_bonus("flame_dmg") + get_affection_bonus("flame_dmg") + float(core_t.get("flame_dmg_pct", 0.0))
	if has_flag("ch06_luu_ly_tinh_done"):
		bonus_pct += 15.0 # Địa Hỏa Lưu Ly Tinh!
	return 1.0 + bonus_pct / 100.0


func get_alchemy_equipment_bonus() -> float:
	return (get_gear_bonus("alchemy_bonus") + PanGateMgr.get_alchemy_bonus_pct(self)) / 100.0


func get_loot_magnet_radius() -> float:
	var rad: float = 175.0 + get_gear_bonus("loot_magnet") + get_affection_bonus("loot_magnet")
	if active_companion_id == "tu_nghien":
		rad *= 1.45 # Tử Nghiên: Tự động đánh hơi & hút kho báu (+45%)!
	return rad


func get_heal_effectiveness_mult() -> float:
	var bonus_han: float = 10.0 if has_flag("ch08_han_secret_gift_done") else 0.0
	return 1.0 + (get_affection_bonus("heal_pct") + bonus_han) / 100.0


func get_gold_reward_mult() -> float:
	return 1.0 + get_affection_bonus("gold_pct") / 100.0


func get_gear_drop_bonus_chance() -> float:
	return get_affection_bonus("gear_drop_pct") / 100.0


func get_lotus_qi_cost_multiplier() -> float:
	return 0.80 if lotus_fusion_flames.has("hoa_sinh_hoa") else 1.0


func get_lotus_affection_dmg_mult() -> float:
	return 1.0 + get_affection_bonus("lotus_dmg_pct") / 100.0


func apply_player_slow(ratio: float, duration: float) -> void:
	player_slow_ratio = maxf(player_slow_ratio, clampf(ratio, 0.1, 0.55))
	player_slow_timer = maxf(player_slow_timer, duration)


func get_equipped_weapon_sprite_path() -> String:
	var w_inst = equipped_gear.get("weapon", {})
	if w_inst is Dictionary and not w_inst.is_empty():
		var tdef: Dictionary = GameDatabase.get_equipment_template(str(w_inst.get("template_id", "")))
		return str(tdef.get("weapon_sprite", ""))
	return ""


func get_equipped_attack_sheet_path() -> String:
	var w_inst = equipped_gear.get("weapon", {})
	if w_inst is Dictionary and not w_inst.is_empty():
		var tdef: Dictionary = GameDatabase.get_equipment_template(str(w_inst.get("template_id", "")))
		var sp: String = str(tdef.get("attack_sheet", ""))
		if sp != "":
			return sp
	return "res://assets/sprites/player/tieu_viem_attack_unarmed.png"


func get_weapon_attack_speed_mult() -> float:
	var w_inst = equipped_gear.get("weapon", {})
	var base_m: float = 1.25
	if w_inst is Dictionary and not w_inst.is_empty():
		var tdef: Dictionary = GameDatabase.get_equipment_template(str(w_inst.get("template_id", "")))
		base_m = float(tdef.get("attack_speed_mult", 1.0))
	if is_tam_bien_active:
		base_m *= 1.35
	elif is_nhi_bien_active:
		base_m *= 1.25
	elif is_flame_buff_active:
		base_m *= 1.20
	return base_m


func get_soul_realm_name() -> String:
	var cur_soul: int = get_soul()
	var best_name: String = "Phàm Cảnh Linh Hồn"
	for sr in GameDatabase.soul_realms_list:
		if sr is Dictionary and cur_soul >= int(sr.get("min_soul", 0)):
			best_name = str(sr.get("name", best_name))
	return best_name


func get_active_flame_def() -> Dictionary:
	if is_duoc_lao_active and get_assist_mode() == "duoc_lao":
		return GameDatabase.get_flame_def("di_hoa_11_cot_linh")
	if equipped_flame_id == "":
		return {}
	return GameDatabase.get_flame_def(equipped_flame_id)


func get_realm_display_title() -> String:
	var r_def: Dictionary = GameDatabase.get_realm_def(realm_index)
	var r_name: String = str(r_def.get("name", "Đấu Chi Khí"))
	var unit: String = str(r_def.get("stage_unit", "Đoạn"))
	if realm_index >= 12:
		return r_name
	var base_title: String = "%s — %d %s" % [r_name, stage, unit]
	var nt_tag: String = NineTurnMgr.get_display_tag(self)
	if nt_tag != "":
		return "%s · %s" % [base_title, nt_tag]
	return base_title


func get_required_exp() -> int:
	var r_def: Dictionary = GameDatabase.get_realm_def(realm_index)
	var base_e: float = float(r_def.get("base_exp", 180.0))
	var growth: float = float(r_def.get("exp_growth", 1.40))
	return int(round(base_e * pow(growth, float(max(0, stage - 1)))))


func is_at_bottleneck() -> bool:
	var r_def: Dictionary = GameDatabase.get_realm_def(realm_index)
	var max_st: int = int(r_def.get("max_stage", 9))
	return stage >= max_st and current_exp >= get_required_exp() and realm_index < 12


func get_exp_multiplier() -> float:
	var mult: float = 1.0 + (get_gear_bonus("exp_bonus") + get_affection_bonus("exp_bonus")) / 100.0
	if is_ruler_sealed and has_huyen_trong_xich_equipped():
		mult += 0.30
	if has_flag("got_thanh_lien_dai"):
		mult += 0.15 # Tọa đài Thanh Liên Đài tăng tốc tu luyện!
	var f_def: Dictionary = get_active_flame_def()
	if not f_def.is_empty():
		mult += float(f_def.get("exp_bonus_pct", 0.0)) / 100.0
	return mult * NineTurnMgr.get_map_exp_multiplier(self)


# --- TRANG BỊ 10 Ô ---
func add_gear_to_bag(inst: Dictionary) -> void:
	if inst.is_empty():
		return
	gear_bag.append(inst)
	EventBus.equipment_changed.emit()


func equip_gear_from_bag(uid: String) -> String:
	var found_idx: int = -1
	for i in range(gear_bag.size()):
		if str(gear_bag[i].get("uid", "")) == uid:
			found_idx = i
			break
	if found_idx == -1:
		return "Không tìm thấy trang bị!"
	var inst: Dictionary = gear_bag[found_idx]
	var tdef: Dictionary = GameDatabase.get_equipment_template(str(inst.get("template_id", "")))
	var slot_id: String = str(tdef.get("slot", "weapon"))

	gear_bag.remove_at(found_idx)
	var prev = equipped_gear.get(slot_id, {})
	if prev is Dictionary and not prev.is_empty():
		gear_bag.append(prev)
	equipped_gear[slot_id] = inst

	if not has_huyen_trong_xich_equipped():
		is_ruler_sealed = false
	_rebuild_gear_cache()
	recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return "Đã trang bị: %s!" % EquipmentSystem.get_item_display_name(inst)


func unequip_slot(slot_id: String) -> String:
	var prev = equipped_gear.get(slot_id, {})
	if not (prev is Dictionary) or prev.is_empty():
		return ""
	equipped_gear[slot_id] = {}
	gear_bag.append(prev)
	if not has_huyen_trong_xich_equipped():
		is_ruler_sealed = false
	_rebuild_gear_cache()
	recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return "Đã tháo: %s vào Nạp Giới." % EquipmentSystem.get_item_display_name(prev)


func enhance_gear_by_uid(uid: String) -> Dictionary:
	var target: Dictionary = _find_gear_ref(uid)
	if target.is_empty():
		return { "ok": false, "msg": "Không tìm thấy trang bị!" }
	var cur_enh: int = int(target.get("enhance", 0))
	if cur_enh >= EquipmentSystem.MAX_ENHANCE_LEVEL:
		return { "ok": false, "msg": "Trang bị đã đạt cực hạn +%d!" % EquipmentSystem.MAX_ENHANCE_LEVEL }
	var cost: Dictionary = EquipmentSystem.get_enhance_cost(target)
	var c_gold: int = int(cost.get("gold", 50))
	var c_stones: int = int(cost.get("stones", 1))
	if gold < c_gold or enhance_stones < c_stones:
		return { "ok": false, "msg": "Cần %d Kim Tệ & %d Đá Cường Hóa! (Hiện có: %d Kim Tệ, %d Đá)" % [c_gold, c_stones, gold, enhance_stones] }
	gold -= c_gold
	enhance_stones -= c_stones
	target["enhance"] = cur_enh + 1
	_rebuild_gear_cache()
	recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("level_up")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return { "ok": true, "msg": "CƯỜNG HÓA THÀNH CÔNG: %s (+12%% chỉ số gốc)!" % EquipmentSystem.get_item_display_name(target) }


func salvage_gear_by_uid(uid: String) -> String:
	for i in range(gear_bag.size()):
		if str(gear_bag[i].get("uid", "")) == uid:
			var inst: Dictionary = gear_bag[i]
			var y: Dictionary = EquipmentSystem.get_salvage_yield(inst)
			gold += int(y.get("gold", 15))
			enhance_stones += int(y.get("stones", 1))
			gear_bag.remove_at(i)
			EventBus.audio_sfx_requested.emit("loot_pickup")
			EventBus.equipment_changed.emit()
			EventBus.stats_changed.emit()
			return "Đã phân giải %s -> +%d Kim Tệ, +%d Đá Cường Hóa!" % [
				EquipmentSystem.get_item_display_name(inst), int(y.get("gold", 15)), int(y.get("stones", 1))
			]
	return "Chỉ có thể phân giải đồ trong túi."


func salvage_low_rarity_gear() -> String:
	var count_s: int = 0
	var total_g: int = 0
	var total_st: int = 0
	var kept: Array = []
	for item in gear_bag:
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
	gear_bag = kept
	gold += total_g
	enhance_stones += total_st
	EventBus.audio_sfx_requested.emit("loot_pickup")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return "Đã phân giải %d món Phàm/Linh -> +%d Kim Tệ, +%d Đá Cường Hóa!" % [count_s, total_g, total_st]


func _find_gear_ref(uid: String) -> Dictionary:
	for sid in equipped_gear.keys():
		var eq = equipped_gear[sid]
		if eq is Dictionary and str(eq.get("uid", "")) == uid:
			return eq
	for item in gear_bag:
		if item is Dictionary and str(item.get("uid", "")) == uid:
			return item
	return {}


# --- EXP, ĐỘT PHÁ & HỎA ---
func add_exp(raw_amount: int, world_pos: Vector2 = Vector2.ZERO) -> void:
	var final_gain: int = max(1, int(round(float(raw_amount) * get_exp_multiplier())))
	current_exp += final_gain
	if world_pos != Vector2.ZERO:
		EventBus.floating_text_requested.emit(world_pos + Vector2(0, -14), "+%d Đấu Khí" % final_gain, Color("#70D6FF"))

	var r_def: Dictionary = GameDatabase.get_realm_def(realm_index)
	var max_st: int = int(r_def.get("max_stage", 9))
	while stage < max_st and current_exp >= get_required_exp():
		current_exp -= get_required_exp()
		stage += 1
		recalculate_and_clamp(true)
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.realm_updated.emit(get_realm_display_title(), "Đột phá tiểu cảnh giới!")

	if stage >= max_st and current_exp > get_required_exp():
		current_exp = get_required_exp()

	EventBus.exp_changed.emit(current_exp, get_required_exp())
	EventBus.stats_changed.emit()


func try_breakthrough() -> Dictionary:
	if realm_index >= 12:
		return { "ok": false, "msg": "Đã đạt đỉnh cao Viêm Đế!" }
	if not is_at_bottleneck():
		return { "ok": false, "msg": "Chưa đạt Đỉnh Phong (9 Đoạn/Tinh) đầy thanh Đấu Khí để đột phá!" }

	var r_def: Dictionary = GameDatabase.get_realm_def(realm_index)
	var req_item_id: String = str(r_def.get("breakthrough_item", "none"))
	if req_item_id != "none" and get_item_count(req_item_id) <= 0:
		var item_def: Dictionary = GameDatabase.get_item_def(req_item_id)
		var item_name: String = str(item_def.get("name", req_item_id))
		return { "ok": false, "msg": "Cần có [%s] để đột phá an toàn! Hãy mở Lò Luyện Đan [L]." % item_name }

	if req_item_id != "none":
		remove_item(req_item_id, 1)

	realm_index += 1
	stage = 1
	current_exp = 0
	recalculate_and_clamp(true)

	var new_def: Dictionary = GameDatabase.get_realm_def(realm_index)
	var unlock_txt: String = str(new_def.get("unlock_feature", ""))
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.realm_updated.emit(get_realm_display_title(), unlock_txt)
	EventBus.exp_changed.emit(current_exp, get_required_exp())
	EventBus.stats_changed.emit()
	_check_quest_realm()
	trigger_auto_save("đột phá cảnh giới", true)
	return { "ok": true, "msg": "ĐỘT PHÁ THÀNH CÔNG: %s!\nMở khóa: %s" % [get_realm_display_title(), unlock_txt] }


func compute_realm_damage_multiplier_against(target_realm_idx: int, skill_realm_pen: float = 0.0) -> float:
	var diff: int = target_realm_idx - realm_index
	if diff <= 0:
		return (1.0 + float(-diff) * 0.12) * EmperorRealmMgr.get_emperor_supremacy_mult(self, target_realm_idx)
	var f_def: Dictionary = get_active_flame_def()
	var f_pen: float = float(f_def.get("realm_penetration", 0.0)) if not f_def.is_empty() else 0.0
	var aff_pen: float = get_affection_bonus("realm_pen") / 100.0
	var total_pen: float = clampf(f_pen + skill_realm_pen + aff_pen, 0.0, 1.0)
	var penalty_per: float = float(GameDatabase.suppression_rules.get("damage_penalty_per_major_realm", 0.38))
	var raw_penalty: float = float(diff) * penalty_per * (1.0 - total_pen)
	var min_mult: float = float(GameDatabase.suppression_rules.get("min_damage_multiplier", 0.10))
	return maxf(min_mult, 1.0 - raw_penalty) * EmperorRealmMgr.get_emperor_supremacy_mult(self, target_realm_idx)


func recalculate_and_clamp(refill: bool = false) -> void:
	var m_hp: float = get_max_hp()
	var m_qi: float = get_max_qi()
	if refill:
		current_hp = m_hp
		current_qi = m_qi
	else:
		current_hp = minf(current_hp, m_hp)
		current_qi = minf(current_qi, m_qi)


func toggle_ruler_seal() -> bool:
	if not has_huyen_trong_xich_equipped():
		return false
	is_ruler_sealed = not is_ruler_sealed
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.weight_seal_toggled.emit(is_ruler_sealed)
	EventBus.stats_changed.emit()
	return true


func unlock_flame(flame_id: String, auto_equip: bool = false) -> void:
	if not GameDatabase.flames_by_id.has(flame_id):
		return
	if not unlocked_flames.has(flame_id):
		unlocked_flames.append(flame_id)
	if not lotus_fusion_flames.has(flame_id) and lotus_fusion_flames.size() < 2:
		lotus_fusion_flames.append(flame_id)
	if auto_equip or equipped_flame_id == "":
		equipped_flame_id = flame_id
	EventBus.flame_changed.emit(equipped_flame_id)
	EventBus.stats_changed.emit()


func equip_flame(flame_id: String) -> bool:
	if not unlocked_flames.has(flame_id):
		return false
	equipped_flame_id = flame_id
	EventBus.audio_sfx_requested.emit("skill_fire")
	EventBus.flame_changed.emit(equipped_flame_id)
	EventBus.stats_changed.emit()
	return true


# --- NẠP GIỚI & ĐAN DƯỢC ---
func get_item_count(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


func add_item(item_id: String, amount: int = 1) -> void:
	if amount <= 0:
		return
	inventory[item_id] = get_item_count(item_id) + amount
	EventBus.inventory_changed.emit()


func remove_item(item_id: String, amount: int = 1) -> bool:
	var cur: int = get_item_count(item_id)
	if cur < amount:
		return false
	var left: int = cur - amount
	if left <= 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = left
	EventBus.inventory_changed.emit()
	return true


func get_effective_quick_pill(slot_num: int) -> String:
	if slot_num == 1:
		if get_item_count(quick_hp_pill_id) > 0:
			return quick_hp_pill_id
		for cand in ["pill_tru_nhan_thanh_dan", "pill_cuu_duong_hoan_cot", "pill_kim_cuong_bat_hoai", "pill_duong_dau_dan", "pill_bach_hoa_ngoc_lo", "pill_hoa_bo_dan", "pill_thanh_hon_dan", "pill_viem_minh_linh_dan", "pill_hoa_lien_dan", "pill_huyet_ngung_dan", "pill_bang_tam_dan", "pill_ngung_huyet_tan"]:
			if get_item_count(cand) > 0:
				return cand
		return quick_hp_pill_id
	elif slot_num == 2:
		if get_item_count(quick_qi_pill_id) > 0:
			return quick_qi_pill_id
		for cand in ["pill_thanh_linh_phuc_nguyen", "pill_phuc_hon_thanh_dan", "pill_thang_linh_dan", "pill_thanh_hon_hoa_sinh", "pill_dan_hoan_ngot", "pill_thanh_lien_tu", "pill_hoi_khi_dan"]:
			if get_item_count(cand) > 0:
				return cand
		return quick_qi_pill_id
	return "pill_truc_co_linh_dich"


func set_quick_pill_slot(slot_num: int, item_id: String) -> void:
	if slot_num == 1 and item_id in ["pill_ngung_huyet_tan", "pill_bang_tam_dan", "pill_huyet_ngung_dan", "pill_hoa_lien_dan", "pill_viem_minh_linh_dan", "pill_thanh_hon_dan", "pill_hoa_bo_dan", "pill_bach_hoa_ngoc_lo", "pill_kim_cuong_bat_hoai", "pill_duong_dau_dan", "pill_cuu_duong_hoan_cot", "pill_tru_nhan_thanh_dan"]:
		quick_hp_pill_id = item_id
	elif slot_num == 2 and item_id in ["pill_hoi_khi_dan", "pill_thanh_lien_tu", "pill_dan_hoan_ngot", "pill_thanh_hon_hoa_sinh", "pill_thang_linh_dan", "pill_phuc_hon_thanh_dan", "pill_thanh_linh_phuc_nguyen"]:
		quick_qi_pill_id = item_id
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.inventory_changed.emit()


func use_consumable(item_id: String, world_pos: Vector2 = Vector2.ZERO) -> bool:
	if get_item_count(item_id) <= 0:
		return false
	var idef: Dictionary = GameDatabase.get_item_def(item_id)
	var itype: String = str(idef.get("type", ""))
	if itype == "consumable_hp":
		if current_hp >= get_max_hp():
			return false
		remove_item(item_id, 1)
		var heal: float = float(idef.get("heal_hp", 60.0)) * get_heal_effectiveness_mult()
		current_hp = minf(get_max_hp(), current_hp + heal)
		EventBus.audio_sfx_requested.emit("loot_pickup")
		if world_pos != Vector2.ZERO:
			EventBus.floating_text_requested.emit(world_pos, "+%d HP" % int(round(heal)), Color("#52B788"))
		EventBus.stats_changed.emit()
		return true
	elif itype == "consumable_qi":
		var bonus_hp: float = float(idef.get("heal_hp", 0.0))
		if current_qi >= get_max_qi() and (bonus_hp <= 0.0 or current_hp >= get_max_hp()):
			return false
		remove_item(item_id, 1)
		var rest: float = float(idef.get("restore_qi", 50.0))
		current_qi = minf(get_max_qi(), current_qi + rest)
		if bonus_hp > 0.0:
			current_hp = minf(get_max_hp(), current_hp + bonus_hp * get_heal_effectiveness_mult())
		EventBus.audio_sfx_requested.emit("loot_pickup")
		if world_pos != Vector2.ZERO:
			var qi_txt: String = "+%d HP & +%d QI" % [int(round(bonus_hp)), int(round(rest))] if bonus_hp > 0.0 else "+%d Đấu Khí" % int(round(rest))
			EventBus.floating_text_requested.emit(world_pos, qi_txt, Color("#4CC9F0"))
		EventBus.stats_changed.emit()
		return true
	elif itype == "consumable_exp":
		remove_item(item_id, 1)
		if item_id == "pill_da_xa_de_pham_hoan_dan" and not has_flag("ch11_da_xa_pill_eaten"):
			story_flags["ch11_da_xa_pill_eaten"] = true
			add_story_relic("Đà Xá Đế Phẩm Hoàn Đan (+25% Toàn Bộ Chỉ Số Vĩnh Viễn!)")
			recalculate_and_clamp(true)
		elif item_id == "pill_loi_kiep_huyen_dan":
			bonus_soul += 150
			recalculate_and_clamp(false)
		EventBus.audio_sfx_requested.emit("breakthrough" if item_id == "pill_da_xa_de_pham_hoan_dan" else "level_up")
		var g_exp: int = int(idef.get("grant_exp", idef.get("exp_gain", 240)))
		add_exp(g_exp, world_pos)
		return true
	elif itype == "consumable_buff":
		remove_item(item_id, 1)
		if item_id == "pill_da_xa_de_pham_hoan_dan" and not has_flag("ch11_da_xa_pill_eaten"):
			story_flags["ch11_da_xa_pill_eaten"] = true
			add_story_relic("Đà Xá Đế Phẩm Hoàn Đan (+25% Toàn Bộ Chỉ Số Vĩnh Viễn!)")
		elif item_id == "pill_loi_kiep_huyen_dan":
			bonus_soul += 150
		recalculate_and_clamp(true)
		am_duong_buff_timer = maxf(am_duong_buff_timer, float(idef.get("buff_sec", 30.0)))
		EventBus.audio_sfx_requested.emit("breakthrough")
		if world_pos != Vector2.ZERO:
			var btxt: String = "👑 ĐÀ XÁ ĐẾ PHẨM HOÀN ĐAN (+25%% TOÀN CHỈ SỐ VĨNH VIỄN!)" if item_id == "pill_da_xa_de_pham_hoan_dan" else ("✦ LÔI KIẾP HUYỀN ĐAN (+150 SOUL & FULL HP/QI!)" if item_id == "pill_loi_kiep_huyen_dan" else "PHÁ HẬU NHI LẬP! (+25%% ATK & FULL HP/QI)")
			EventBus.floating_text_requested.emit(world_pos + Vector2(0, -68), btxt, Color("#FFD166"))
		EventBus.stats_changed.emit()
		return true
	return false


func heal_from_lifesteal(damage_dealt: float) -> void:
	var ls: float = get_lifesteal_ratio()
	if ls <= 0.0:
		return
	var gain: float = damage_dealt * ls
	if gain >= 1.0 and current_hp < get_max_hp():
		current_hp = minf(get_max_hp(), current_hp + gain)
		EventBus.stats_changed.emit()


# --- HỆ THỐNG NHIỆM VỤ CHÍNH TUYẾN DATA-DRIVEN (THEO ID, TƯƠNG THÍCH MỌI CHƯƠNG) ---
func get_current_quest() -> Dictionary:
	if all_quests_done or GameDatabase.all_quests.is_empty():
		return {}
	if active_quest_id != "":
		var idx_by_id: int = GameDatabase.get_quest_index(active_quest_id)
		if idx_by_id >= 0:
			active_quest_idx = idx_by_id
	if active_quest_idx < 0 or active_quest_idx >= GameDatabase.all_quests.size():
		return {}
	var q = GameDatabase.all_quests[active_quest_idx]
	if q is Dictionary:
		active_quest_id = str(q.get("id", ""))
		return q
	return {}


func _is_current_quest_auto_satisfied(q: Dictionary) -> bool:
	if q.is_empty():
		return false
	var q_type: String = str(q.get("type", ""))
	if q_type == "story_flag":
		return has_flag(str(q.get("flag_name", "")))
	elif q_type == "all_flags":
		var flist: Array = q.get("flag_names", [])
		if flist.is_empty():
			return false
		for f in flist:
			if not has_flag(str(f)):
				return false
		return true
	elif q_type == "reach_realm":
		return realm_index >= int(q.get("target_realm_index", 2))
	elif q_type == "craft_pill":
		var allow_inv: bool = bool(q.get("auto_pass_if_owned", false))
		return allow_inv and get_item_count(str(q.get("target_id", ""))) > 0
	return false


func _check_quest_flag(flag_name: String) -> void:
	var q: Dictionary = get_current_quest()
	if q.is_empty():
		return
	var q_type: String = str(q.get("type", ""))
	if q_type == "story_flag" and str(q.get("flag_name", "")) == flag_name:
		_advance_quest_progress(1)
	elif q_type == "all_flags":
		if _is_current_quest_auto_satisfied(q):
			_advance_quest_progress(1)


func _on_enemy_killed(enemy_id: String, is_boss: bool) -> void:
	enemies_killed_total += 1
	enemy_kill_counts[enemy_id] = int(enemy_kill_counts.get(enemy_id, 0)) + 1
	if is_boss and has_ma_doc_ban() and ma_doc_ban_stacks < 20:
		ma_doc_ban_stacks += 1
		EventBus.stats_changed.emit()
		EventBus.banter_triggered.emit("☠ Ma Độc Ban cộng hưởng sát khí Boss -> Tích lũy %d/20 (+%d%% ATK)!" % [ma_doc_ban_stacks, ma_doc_ban_stacks])
	if enemy_id == "tieu_ninh_boss":
		set_story_flag("unlocked_bat_cuc_bang")
	elif enemy_id == "lieu_tich_boss":
		set_story_flag("killed_lieu_tich")
	elif enemy_id == "gia_liet_ao_boss":
		set_story_flag("ch01_completed")
	elif enemy_id == "tieu_tu_tinh_su_boss":
		set_story_flag("killed_tieu_su_vuong")
	elif enemy_id == "muc_luc_boss":
		set_story_flag("killed_muc_luc")
	elif enemy_id == "muc_xa_boss":
		set_story_flag("killed_muc_xa")
	elif enemy_id == "hai_ba_dong_boss":
		set_story_flag("beat_hai_ba_dong")
	elif enemy_id == "hoa_linh_xa_boss":
		set_story_flag("killed_hoa_linh_xa")
	elif enemy_id == "mac_ba_tu_boss":
		set_story_flag("killed_mac_ba_tu")
		if has_flag("killed_co_ha"):
			set_story_flag("beat_co_ha_mac_ba_tu")
	elif enemy_id == "co_ha_boss":
		set_story_flag("killed_co_ha")
		if has_flag("killed_mac_ba_tu"):
			set_story_flag("beat_co_ha_mac_ba_tu")

	# Data-Driven enemy kill rules (Ch04 -> Ch11)!
	var k_rule: Dictionary = GameDatabase.get_enemy_kill_rule(enemy_id)
	if not k_rule.is_empty():
		var sf: String = str(k_rule.get("set_flag", ""))
		if sf != "":
			set_story_flag(sf)
		for f in k_rule.get("set_flags", []):
			set_story_flag(str(f))
		for combo in k_rule.get("combo_flags", []):
			if combo is Dictionary:
				var all_ok: bool = true
				for rf in combo.get("require_flags", []):
					if not has_flag(str(rf)):
						all_ok = false
						break
				if all_ok:
					var gf: String = str(combo.get("grant_flag", ""))
					if gf != "":
						set_story_flag(gf)

	var q: Dictionary = get_current_quest()
	if q.is_empty():
		return
	if str(q.get("type", "")) == "kill_any" and enemy_id == str(q.get("target_id", "")):
		_advance_quest_progress(1)


func notify_pill_crafted(pill_id: String) -> void:
	if pill_id == "pill_tam_van_thanh_linh" and has_flag("ch04_beat_viem_loi"):
		set_story_flag("ch04_dan_hoi_champion")
	var q: Dictionary = get_current_quest()
	if q.is_empty():
		return
	if str(q.get("type", "")) == "craft_pill" and pill_id == str(q.get("target_id", "")):
		_advance_quest_progress(1)


func _check_quest_realm() -> void:
	var q: Dictionary = get_current_quest()
	if q.is_empty():
		return
	if str(q.get("type", "")) == "reach_realm":
		if realm_index >= int(q.get("target_realm_index", 2)):
			_advance_quest_progress(1)


func _advance_quest_progress(delta_cnt: int) -> void:
	var q: Dictionary = get_current_quest()
	if q.is_empty():
		return
	quest_progress += delta_cnt
	var goal: int = int(q.get("target_count", 1))
	if quest_progress >= goal:
		var done_id: String = str(q.get("id", ""))
		if done_id != "":
			completed_quest_ids[done_id] = true
		var rew_exp: int = int(q.get("reward_exp", 50))
		add_exp(rew_exp)
		gold += int(q.get("reward_gold", 0))
		var rew_items: Dictionary = q.get("reward_items", {})
		for k in rew_items.keys():
			add_item(str(k), int(rew_items[k]))
		var comp_eff = q.get("on_complete_effect", {})
		if comp_eff is Dictionary and not comp_eff.is_empty():
			execute_story_effect(comp_eff)
		active_quest_idx += 1
		quest_progress = 0
		if active_quest_idx >= GameDatabase.all_quests.size():
			all_quests_done = true
			active_quest_id = ""
			EventBus.banter_triggered.emit("👑 CHÚC MỪNG ĐẠI KẾT CỤC! Bạn đã chinh phục trọn vẹn %d/96 mốc cốt truyện Quyển I–IV (Chương 01 – 11: Ô Thản Thành -> Cổ Đế Động Phủ -> Song Đế Chi Chiến -> Viêm Đế Đại Hôn & Đại Thiên Thế Giới)!" % GameDatabase.all_quests.size())
		else:
			var next_q: Dictionary = GameDatabase.all_quests[active_quest_idx]
			active_quest_id = str(next_q.get("id", ""))
			EventBus.banter_triggered.emit(str(next_q.get("intro_log", "")))
			if _is_current_quest_auto_satisfied(next_q):
				_advance_quest_progress(1)
		trigger_auto_save("hoàn thành nhiệm vụ")
	EventBus.quest_updated.emit()


# --- HỆ THỐNG LƯU / TẢI 3 Ô (ỦY QUYỀN SANG SaveLoadManager) ---
func get_save_slot_path(slot_idx: int) -> String:
	return SaveLoadMgr.get_save_slot_path(slot_idx)


func has_any_save() -> bool:
	return SaveLoadMgr.has_any_save()


func get_save_slot_summary(slot_idx: int) -> Dictionary:
	return SaveLoadMgr.get_save_slot_summary(slot_idx)


func save_game(slot_idx: int = -1, silent: bool = false) -> bool:
	return SaveLoadMgr.save_game(self, slot_idx, silent)


func load_game(slot_idx: int = -1) -> bool:
	return SaveLoadMgr.load_game(self, slot_idx)


# =========================================================
# ĐỘ THÔNG THẠO ĐẤU KỸ (MASTERY) · TÂM MA LUYỆN CẢNH · ĐỒ GIÁM VẠN THÚ
# =========================================================
func get_skill_mastery_info(skill_id: String) -> Dictionary:
	var uses: int = int(skill_mastery_uses.get(skill_id, 0))
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


func record_skill_use(skill_id: String, world_pos: Vector2 = Vector2.ZERO) -> Dictionary:
	if skill_id == "":
		return get_skill_mastery_info("")
	var old_tier: int = int(get_skill_mastery_info(skill_id).get("tier", 0))
	skill_mastery_uses[skill_id] = int(skill_mastery_uses.get(skill_id, 0)) + 1
	var info: Dictionary = get_skill_mastery_info(skill_id)
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


func get_enemy_kill_count(enemy_id: String) -> int:
	return int(enemy_kill_counts.get(enemy_id, 0))


func get_boss_rush_record(boss_id: String, diff_key: String) -> Dictionary:
	var k: String = "%s|%s" % [boss_id, diff_key]
	var rec = boss_rush_records.get(k, {})
	return rec as Dictionary if rec is Dictionary else {}


func record_boss_rush_clear(boss_id: String, diff_key: String, elapsed_sec: float, dmg_taken: float) -> Dictionary:
	var grade_order: Dictionary = { "C": 1, "B": 2, "A": 3, "S": 4, "SS": 5, "SSS": 6 }
	var hp_ref: float = maxf(100.0, get_max_hp())
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
	enhance_stones += stones_rew
	gold += gold_rew

	var k: String = "%s|%s" % [boss_id, diff_key]
	var prev: Dictionary = get_boss_rush_record(boss_id, diff_key)
	var prev_g: String = str(prev.get("best_grade", ""))
	var best_g: String = grade if int(grade_order.get(grade, 0)) >= int(grade_order.get(prev_g, 0)) else prev_g
	var prev_t: float = float(prev.get("best_time", 9999.0))
	var best_t: float = minf(prev_t, elapsed_sec)
	boss_rush_records[k] = {
		"best_grade": best_g,
		"best_time": snappedf(best_t, 0.1),
		"clears": int(prev.get("clears", 0)) + 1
	}
	EventBus.stats_changed.emit()
	trigger_auto_save("Tâm Ma Luyện Cảnh", true)
	return {
		"grade": grade,
		"elapsed_sec": elapsed_sec,
		"stones": stones_rew,
		"gold": gold_rew
	}


# =========================================================
# KHẢM MA HẠCH LÊN VŨ KHÍ / HUYỀN TRỌNG XÍCH (3 RÃNH)
# =========================================================
func get_core_socket_def(core_id: String) -> Dictionary:
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


func get_core_socket_totals() -> Dictionary:
	var totals: Dictionary = {
		"atk": 0.0, "hp": 0.0, "spd": 0.0, "crit_pct": 0.0,
		"burn_dps": 0.0, "hp_regen": 0.0, "cd_red_pct": 0.0,
		"poise_pct": 0.0, "lifesteal_pct": 0.0,
		"soul": 0.0, "flame_dmg_pct": 0.0
	}
	for cid in weapon_core_sockets:
		var cid_s: String = str(cid)
		if cid_s == "":
			continue
		var cdef: Dictionary = get_core_socket_def(cid_s)
		for k in totals.keys():
			totals[k] = float(totals[k]) + float(cdef.get(k, 0.0))
	return totals


func socket_monster_core(slot_idx: int, core_id: String) -> Dictionary:
	if slot_idx < 0 or slot_idx >= 3:
		return { "ok": false, "msg": "Rãnh khảm không hợp lệ!" }
	var cdef: Dictionary = get_core_socket_def(core_id)
	if cdef.is_empty():
		return { "ok": false, "msg": "Vật phẩm này không thể khảm lên vũ khí!" }
	if get_item_count(core_id) <= 0:
		return { "ok": false, "msg": "Bạn không có [%s] trong Nạp Giới!" % str(cdef["name"]) }
	var prev: String = str(weapon_core_sockets[slot_idx])
	if prev != "":
		add_item(prev, 1)
	remove_item(core_id, 1)
	weapon_core_sockets[slot_idx] = core_id
	recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("level_up")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return { "ok": true, "msg": "Đã khảm [%s] vào Rãnh #%d (%s)!" % [str(cdef["name"]), slot_idx + 1, str(cdef["desc"])] }


func unsocket_monster_core(slot_idx: int) -> Dictionary:
	if slot_idx < 0 or slot_idx >= 3:
		return { "ok": false, "msg": "Rãnh khảm không hợp lệ!" }
	var prev: String = str(weapon_core_sockets[slot_idx])
	if prev == "":
		return { "ok": false, "msg": "Rãnh #%d đang trống!" % (slot_idx + 1) }
	weapon_core_sockets[slot_idx] = ""
	add_item(prev, 1)
	recalculate_and_clamp(false)
	EventBus.audio_sfx_requested.emit("ui_click")
	EventBus.equipment_changed.emit()
	EventBus.stats_changed.emit()
	return { "ok": true, "msg": "Đã tháo [%s] khỏi Rãnh #%d về lại Nạp Giới!" % [str(get_core_socket_def(prev).get("name", prev)), slot_idx + 1] }


# =========================================================
# TINH HỎA NĂNG & CHÚC PHÚC ROGUELITE THIÊN PHẦN LUYỆN KHÍ THÁP
# =========================================================
func add_fire_energy(amount: int) -> void:
	fire_energy = maxi(0, fire_energy + amount)
	EventBus.stats_changed.emit()


func clear_tower_buffs() -> void:
	tower_active_buffs.clear()
	recalculate_and_clamp(false)
	EventBus.stats_changed.emit()


func add_tower_buff(stat_key: String, value: float, heal_ratio: float = 0.0) -> void:
	if stat_key != "":
		tower_active_buffs[stat_key] = float(tower_active_buffs.get(stat_key, 0.0)) + value
	recalculate_and_clamp(false)
	if heal_ratio > 0.0:
		current_hp = minf(get_max_hp(), current_hp + get_max_hp() * heal_ratio)
		current_qi = minf(get_max_qi(), current_qi + get_max_qi() * heal_ratio)
	EventBus.stats_changed.emit()


func record_tower_floor_clear(floor_num: int) -> Dictionary:
	if floor_num > tower_best_floor:
		tower_best_floor = floor_num
	var fe_gain: int = 12 + floor_num * 5
	var stones_gain: int = 1 + int(floor_num / 3)
	var gold_gain: int = 55 + floor_num * 28
	fire_energy += fe_gain
	enhance_stones += stones_gain
	gold += gold_gain
	EventBus.stats_changed.emit()
	trigger_auto_save("Thiên Phần Tháp Tầng %d" % floor_num, true)
	return { "fire_energy": fe_gain, "stones": stones_gain, "gold": gold_gain, "best_floor": tower_best_floor }
