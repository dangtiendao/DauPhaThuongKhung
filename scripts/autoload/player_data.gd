extends Node
## Lưu trữ toàn bộ trạng thái tu luyện Chuẩn Cốt Truyện 100% — Chương 01 -> Chương 06 (Quyển I & II):
## - Khởi đầu phút 0: Đấu Chi Khí 3 Đoạn, TAY KHÔNG, chưa có Dược Lão, chưa có vũ khí, chưa có Đấu Kỹ, chưa có Hỏa Liên!
## - Hỗ trợ Save 3 Ô, Auto-Save/Auto-Continue, Chế Độ DEMO, 10 Ô Trang Bị + Khảm Ma Hạch, 17 Đấu Kỹ, 31 Bản Đồ, 47 Mốc Cốt Truyện, Bàn Môn & 5 Đồng Hành!

const LEGACY_SAVE_PATH: String = "user://dptk_savegame.json"
const SaveLoadMgr = preload("res://scripts/systems/save_load_manager.gd")
const PanGateMgr = preload("res://scripts/systems/pan_gate_manager.gd")

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
	active_save_slot = clampi(slot_idx, 1, MAX_SAVE_SLOTS)
	last_played_slot = active_save_slot
	is_demo_mode = true
	has_saved_player_pos = false
	saved_player_pos = Vector2.ZERO
	auto_save_timer = 0.0
	current_map_id = "ch01_tieu_gia"

	realm_index = 6 # Đấu Vương 9 Tinh Đỉnh Phong (kích hoạt Đấu Khí Hóa Dực, sẵn sàng bấm [B] lên Đấu Hoàng & trải nghiệm trọn Ch01–Ch06!)
	stage = 9
	bonus_soul = 240
	gold = 80000
	enhance_stones = 999

	# Mở toàn bộ cờ cốt truyện để đi tất cả bản đồ Ch01–Ch06 & Bàn Môn / Lò Đan / Dị Hỏa (giữ Boss trọng điểm để test đánh Boss!)
	story_flags = {
		"tu_hon_done": true,
		"duoc_lao_awake": true,
		"huan_nhi_gift": true,
		"bought_bao_bo": true,
		"bought_hap_chuong": true,
		"ready_thanh_nien_le": true,
		"unlocked_bat_cuc_bang": true,
		"got_gia_nam_leave": true,
		"killed_lieu_tich": true,
		"ch01_completed": true,
		"met_tieu_y_tien": true,
		"found_doc_kinh": true,
		"got_tu_van_duc": true,
		"met_van_chi": true,
		"killed_tieu_su_vuong": true,
		"absorbed_tu_hoa": true,
		"killed_muc_luc": true,
		"killed_muc_xa": true,
		"ch02_farewell_done": true,
		"ch02_completed": true,
		"met_tieu_dinh_le": true,
		"pact_hai_ba_dong": true,
		"met_thanh_lan": true,
		"got_thanh_lien_dai": true,
		"beat_co_ha_mac_ba_tu": true,
		"snatched_thanh_lien_hoa": true,
		"ch03_completed": true,
		"ch04_pha_ach_done": true,
		"ch04_mac_gia_done": true,
		"ch04_nham_kieu_mask": true,
		"ch04_cured_nap_lan_kiet": true,
		"ch04_dan_hoi_champion": true,
		"ch04_uoc_hen_revealed": true,
		"ch04_van_yen_started": true,
		"ch04_medusa_saved": true,
		"ch04_hon_dien_clue": true,
		"ch04_second_van_lam_ready": true,
		"ch04_killed_van_lang": true,
		"ch04_tieu_toc_no_huyet": true,
		"ch04_kim_viem_ngoc": true,
		"ch04_completed": true,
		"ch05_killed_van_phan": true,
		"ch05_killed_pham_lang": true,
		"ch05_duoc_lao_awakened_ch05": true,
		"ch05_auction_done": true,
		"ch05_read_mang_thien_xich": true,
		"ch05_huan_nhi_reunited": true,
		"ch05_beat_ngo_hao": true,
		"ch05_got_su_ho": true,
		"ch05_killed_la_hau": true,
		"ch05_completed": true,
		"ch06_ban_mon_founded": true,
		"ch06_tu_nghien_joined": true,
		"ch06_got_dia_tam_nhu": true,
		"ch06_got_top10_pass": true,
		"ch06_tower_eruption_done": true,
		"ch06_absorbed_van_lac": true,
		"ch06_completed": true,
		"FLAG_ZI_YAN_COMPANION": true,
		"FLAG_MEDUSA_SOUL_BOND": true,
		"FLAG_FALLING_HEART_FLAME": true,
		"FLAG_HAN_FENG_SOUL_ESCAPED": true
	}
	affection = { "huan_nhi": 100, "tieu_y_tien": 100, "van_chi": 100, "thanh_lan": 100, "my_do_toa": 100 }
	story_relics = [
		"Chế Độ DEMO — Mở Khóa Toàn Bộ (%d Map · Ch01–Ch06 · 28 Hỏa)" % GameDatabase.maps_ordered.size(),
		"Ấn Ký Tôn Nghiêm (+5% Công Kích)",
		"Hắc Ảnh Phù (+8% Tốc Chạy)",
		"Thanh Liên Đài (+15% EXP & +40% Hồi QI)",
		"Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (3/4 Đủ)",
		"Sơ Hình Phật Nộ Hỏa Liên & Thần Thú Thải Lân",
		"Quán Quân Đan Hội Gia Mã · Lạc Độc Ấn",
		"Tàn Dư Hắc Vụ Xiềng Xích (Manh Mối Hồn Điện)",
		"Kim Viêm Hộ Hồn Ngọc (Hồi Sinh 1 Lần 50% HP)",
		"Hỏa Năng Tinh Tạp · Tân Sinh Vương Già Nam (480 Hỏa Năng)",
		"Ấn Lệnh Môn Chủ Bàn Môn · Ngọc Bài Top 10 Cường Bảng",
		"Lưu Ly Liên Tâm Hỏa (#19 + #14) · Đấu Khí Hóa Dực"
	]

	# Mở toàn bộ 28 ngọn Hỏa (từ Phàm Hỏa tới #1 Đế Viêm!), vận chuyển #14 Vẫn Lạc Tâm Viêm & ghép sẵn 4 Dị Hỏa Liên!
	unlocked_flames = []
	for fl in GameDatabase.flames_ordered:
		if fl is Dictionary:
			var fid: String = str(fl.get("id", ""))
			if fid != "":
				unlocked_flames.append(fid)
	equipped_flame_id = "di_hoa_14_van_lac"
	lotus_fusion_flames = ["di_hoa_19_thanh_lien", "di_hoa_14_van_lac", "di_hoa_11_cot_linh", "di_hoa_04_kim_de"]

	# Mở toàn bộ 17 Đấu Kỹ + [F] Phật Nộ Hỏa Liên + [T] Bảo Tiêu Mỹ Đỗ Toa!
	unlocked_skills = []
	for sid in GameDatabase.skills_by_id.keys():
		unlocked_skills.append(str(sid))
	slot_q_skill = "dai_liet_phach_quan"
	slot_e_skill = "luu_ly_lien_tam"
	slot_r_skill = "de_an_quyet"
	slot_f_skill = "phat_no_hoa_lien"
	duoc_lao_assist_unlocked = true

	# Mở toàn bộ 5 Đồng Hành AI [G] (Dược Lão, Tiểu Y Tiên, Thải Lân, Tiêu Huân Nhi & Tử Nghiên!)
	unlocked_companions = ["duoc_lao_phantom", "tieu_y_tien", "thai_lan", "huan_nhi", "tu_nghien"]
	active_companion_id = "tu_nghien"
	weapon_core_sockets = ["core_bang_5", "core_phong_4", "core_loi_5"]
	fire_energy = 480
	tower_active_buffs.clear()
	pan_gate_state = {
		"dan_duong": 2,
		"vo_duong": 2,
		"am_duong": 2,
		"last_harvest_playtime": -100.0,
		"total_harvests": 0,
		"ziyan_expeditions": 1,
		"strong_rank_cleared": {}
	}
	van_lac_cultivation_tick = 0.0
	am_duong_buff_timer = 0.0

	# Trang bị 10 Ô Full Bộ Nội Viện Bá Chủ & Thiên/Đế Phẩm + Bảo Vật trong Nạp Giới!
	equipped_gear = {
		"weapon": EquipmentSystem.roll_equipment_instance("wpn_xich_luu_ly_viem", "de"),
		"armor": EquipmentSystem.roll_equipment_instance("arm_luu_ly_dau_vuong_bao", "de"),
		"legs": EquipmentSystem.roll_equipment_instance("leg_bi_giap_kho", "thien"),
		"boots": EquipmentSystem.roll_equipment_instance("boot_phong_hanh_hai", "thien"),
		"gloves": EquipmentSystem.roll_equipment_instance("glv_thiet_quyen_uyen", "thien"),
		"necklace": EquipmentSystem.roll_equipment_instance("neck_bang_hoang_tam", "thien"),
		"pendant": EquipmentSystem.roll_equipment_instance("pend_thanh_lien_dai", "thien"),
		"ring": EquipmentSystem.roll_equipment_instance("ring_duoc_hoang_nap_gioi", "de"),
		"wings": EquipmentSystem.roll_equipment_instance("wing_dau_khi_hoa_duc", "de"),
		"cauldron": EquipmentSystem.roll_equipment_instance("caul_hai_tam_dinh", "de")
	}
	gear_bag = [
		EquipmentSystem.roll_equipment_instance("wpn_huyen_trong_xich", "thien"),
		EquipmentSystem.roll_equipment_instance("wpn_thiet_kiem", "thien"),
		EquipmentSystem.roll_equipment_instance("arm_hai_tam_giap", "thien"),
		EquipmentSystem.roll_equipment_instance("pend_co_de_ngoc", "de")
	]
	is_ruler_sealed = false

	# Nguyên liệu luyện đan, Ma Hạch & Đan Dược x20 mỗi loại!
	inventory = {}
	for iid in GameDatabase.items_by_id.keys():
		inventory[str(iid)] = 20
	quick_hp_pill_id = "pill_bang_tam_dan"
	quick_qi_pill_id = "pill_thanh_lien_tu"
	enemies_killed_total = 40
	claimed_affection_milestones = {}

	active_quest_idx = GameDatabase.all_quests.size()
	active_quest_id = ""
	quest_progress = 0
	all_quests_done = true
	completed_quest_ids = {}
	kim_viem_revive_used = false

	_rebuild_gear_cache()
	_rebuild_affection_cache()
	current_exp = get_required_exp()
	recalculate_and_clamp(true)
	save_user_settings()
	EventBus.equipment_changed.emit()
	EventBus.skills_updated.emit()
	EventBus.stats_changed.emit()
	EventBus.inventory_changed.emit()
	EventBus.quest_updated.emit()
	EventBus.flame_changed.emit(equipped_flame_id)
	EventBus.companion_changed.emit(active_companion_id)


func _init_canon_starter_state() -> void:
	current_map_id = GameDatabase.start_map_id
	equipped_gear = {
		"weapon": {},
		"armor": EquipmentSystem.roll_equipment_instance("arm_ao_vai_tu_luyen", "pham"),
		"legs": EquipmentSystem.roll_equipment_instance("leg_hac_bao_kho", "pham"),
		"boots": {},
		"gloves": {},
		"necklace": {},
		"pendant": {},
		"ring": {},
		"wings": {},
		"cauldron": {}
	}
	gear_bag = []
	weapon_core_sockets = ["", "", ""]
	fire_energy = 0
	tower_best_floor = 0
	tower_active_buffs.clear()
	pan_gate_state = PanGateMgr.default_state()
	van_lac_cultivation_tick = 0.0
	auction_wins = 0
	auction_consigned_total = 0
	am_duong_buff_timer = 0.0
	story_flags = {}
	opened_chests = {}
	affection = { "huan_nhi": 20, "tieu_y_tien": 0, "van_chi": 0, "thanh_lan": 0, "my_do_toa": 0 }
	story_relics = []
	claimed_affection_milestones = {}
	lotus_shield_hp = 0.0
	lotus_dmg_red_timer = 0.0
	lotus_double_herb_timer = 0.0
	player_slow_timer = 0.0
	player_slow_ratio = 0.0
	unlocked_flames = []
	lotus_fusion_flames = []
	equipped_flame_id = ""
	unlocked_skills = []
	slot_q_skill = ""
	slot_e_skill = ""
	slot_r_skill = ""
	slot_f_skill = ""
	duoc_lao_assist_unlocked = false
	is_ruler_sealed = false
	is_duoc_lao_active = false
	is_flame_buff_active = false
	unlocked_companions = []
	active_companion_id = ""
	active_quest_idx = 0
	active_quest_id = str(GameDatabase.all_quests[0].get("id", "")) if not GameDatabase.all_quests.is_empty() else ""
	completed_quest_ids = {}
	kim_viem_revive_used = false


func _rebuild_gear_cache() -> void:
	cached_gear_bonuses = EquipmentSystem.compute_total_bonuses(equipped_gear)


func trigger_initial_quest_banter() -> void:
	var q: Dictionary = get_current_quest()
	if not q.is_empty():
		EventBus.banter_triggered.emit(str(q.get("intro_log", "")))
		EventBus.quest_updated.emit()


# --- HẢO CẢM HỒNG NHAN (MỐC THƯỞNG BUFF, TẶNG QUÀ & QUÀ TRI KỶ) ---
func get_heroine_profiles() -> Array:
	return [
		{
			"key": "huan_nhi",
			"name": "Tiêu Huân Nhi",
			"title": "Cổ Tộc Thánh Nữ · Kim Đế Phần Thiên",
			"sprite": "res://assets/sprites/npcs/npc_huan_nhi.png",
			"color": "#FFD166",
			"favorite_items": ["pill_truc_co_linh_dich", "herb_tu_diep_lan", "pill_thanh_lien_tu"],
			"fav_hint": "Trúc Cơ Linh Dịch, Tử Diệp Lan Thảo, Hạt Thanh Liên Tử",
			"milestones": [
				{ "req": 25, "desc": "+5% Công Kích (ATK)" },
				{ "req": 50, "desc": "+8% EXP Đấu Khí + Quà Tri Kỷ (Trúc Cơ Linh Dịch x2, Đá CH x4)", "gift_items": { "pill_truc_co_linh_dich": 2 }, "gift_stones": 4, "gift_gold": 120 },
				{ "req": 75, "desc": "+10% Sát thương Hỏa" },
				{ "req": 100, "desc": "Kim Đế Chúc Phúc: +12% ATK & +12 SOUL + Quà (Đá CH x8, 400V)", "gift_items": { "pill_bang_tam_dan": 1 }, "gift_stones": 8, "gift_gold": 400 }
			]
		},
		{
			"key": "tieu_y_tien",
			"name": "Tiểu Y Tiên",
			"title": "Vạn Dược Trai · Ách Nan Độc Thể",
			"sprite": "res://assets/sprites/npcs/npc_tieu_y_tien.png",
			"color": "#80ED99",
			"favorite_items": ["herb_ngung_huyet_thao", "herb_tay_cot_hoa", "herb_sa_chi_man_da_la"],
			"fav_hint": "Ngưng Huyết Thảo, Tẩy Cốt Hoa, Sa Chi Mạn Đà La",
			"milestones": [
				{ "req": 25, "desc": "+8% Sinh Lực Tối Đa (HP)" },
				{ "req": 50, "desc": "+20% Hiệu quả Hồi Máu + Quà Tri Kỷ (Ngưng Huyết Tán x4, Đá CH x4)", "gift_items": { "pill_ngung_huyet_tan": 4, "herb_sa_chi_man_da_la": 2 }, "gift_stones": 4, "gift_gold": 150 },
				{ "req": 75, "desc": "+12% Tỷ lệ & Vùng Đan Tâm Luyện Đan" },
				{ "req": 100, "desc": "Độc Tôn Hộ Thể: +15% Max HP & +5% Hút máu + Quà (Băng Tâm Đan x2)", "gift_items": { "pill_bang_tam_dan": 2 }, "gift_stones": 8, "gift_gold": 420 }
			]
		},
		{
			"key": "van_chi",
			"name": "Vân Chi (Vân Vận)",
			"title": "Đấu Hoàng Phong Hệ · Tông Chủ Vân Lam",
			"sprite": "res://assets/sprites/npcs/npc_van_chi.png",
			"color": "#70D6FF",
			"favorite_items": ["herb_hoat_khi_qua", "pill_hoi_khi_dan", "core_moc_2"],
			"fav_hint": "Hoạt Khí Quả, Hồi Khí Đan, Mộc Ma Hạch (Cấp 2)",
			"milestones": [
				{ "req": 25, "desc": "+6% Tốc Độ Di Chuyển (SPD)" },
				{ "req": 50, "desc": "-8% Hồi chiêu Đấu Kỹ + Quà Tri Kỷ (Hồi Khí Đan x4, Đá CH x5)", "gift_items": { "pill_hoi_khi_dan": 4 }, "gift_stones": 5, "gift_gold": 180 },
				{ "req": 75, "desc": "+8% Tỷ lệ Chí Mạng (Crit)" },
				{ "req": 100, "desc": "Phong Chi Cực Kiếm Ý: -10% CD & +8% SPD + Quà (Hạt Thanh Liên Tử x2)", "gift_items": { "pill_thanh_lien_tu": 2 }, "gift_stones": 8, "gift_gold": 480 }
			]
		},
		{
			"key": "thanh_lan",
			"name": "Thanh Lân",
			"title": "Bích Xà Tam Hoa Đồng · Muội Muội Tiêu Gia",
			"sprite": "res://assets/sprites/npcs/npc_thanh_lan.png",
			"color": "#2EC4B6",
			"favorite_items": ["core_hoa_1", "core_hoa_3", "pill_thanh_lien_tu"],
			"fav_hint": "Hỏa Ma Hạch, Viêm Xà Ma Hạch, Hạt Thanh Liên Tử",
			"milestones": [
				{ "req": 25, "desc": "+55px Tầm Hút Vật Phẩm" },
				{ "req": 50, "desc": "+10% EXP & +15% Kim Tệ rơi + Quà Tri Kỷ (Viêm Xà Hạch x2, Liên Tử x2)", "gift_items": { "core_hoa_3": 2, "pill_thanh_lien_tu": 2 }, "gift_stones": 5, "gift_gold": 220 },
				{ "req": 75, "desc": "+12 Linh Hồn Lực (SOUL)" },
				{ "req": 100, "desc": "Bích Xà Đồng Cảm: +15% Sát thương Hỏa & +12% Rớt đồ hiếm", "gift_items": { "pill_pha_chuong_dan": 1 }, "gift_stones": 9, "gift_gold": 520 }
			]
		},
		{
			"key": "my_do_toa",
			"name": "Thải Lân (Mỹ Đỗ Toa)",
			"title": "Nữ Vương Xà Nhân · Thất Thải Thôn Thiên Mãng",
			"sprite": "res://assets/sprites/npcs/npc_my_do_toa.png",
			"color": "#E0AAFF",
			"favorite_items": ["core_hoa_3", "pill_bang_tam_dan", "pill_thanh_lien_tu"],
			"fav_hint": "Viêm Xà Ma Hạch, Băng Tâm Đan, Hạt Thanh Liên Tử",
			"milestones": [
				{ "req": 25, "desc": "+8% Tỷ lệ Chí Mạng (Crit)" },
				{ "req": 50, "desc": "+12% Xuyên Áp Chế Cảnh Giới + Quà Tri Kỷ (Băng Tâm Đan x2, Đá CH x6)", "gift_items": { "pill_bang_tam_dan": 2 }, "gift_stones": 6, "gift_gold": 280 },
				{ "req": 75, "desc": "+18% Uy lực Phật Nộ Hỏa Liên" },
				{ "req": 100, "desc": "Nữ Vương Long Uy: +15% ATK & +15% DEF + Quà (Phá Chướng Đan x1, Đá CH x10)", "gift_items": { "pill_pha_chuong_dan": 1 }, "gift_stones": 10, "gift_gold": 650 }
			]
		}
	]


func _rebuild_affection_cache() -> void:
	var b: Dictionary = {
		"atk_pct": 0.0,
		"hp_pct": 0.0,
		"def_pct": 0.0,
		"spd_pct": 0.0,
		"exp_bonus": 0.0,
		"flame_dmg": 0.0,
		"lotus_dmg_pct": 0.0,
		"soul": 0.0,
		"heal_pct": 0.0,
		"alchemy_bonus": 0.0,
		"lifesteal": 0.0,
		"cooldown_red": 0.0,
		"crit_chance": 0.0,
		"loot_magnet": 0.0,
		"gold_pct": 0.0,
		"gear_drop_pct": 0.0,
		"realm_pen": 0.0
	}
	var hn: int = get_affection("huan_nhi")
	if hn >= 25:
		b["atk_pct"] += 5.0
	if hn >= 50:
		b["exp_bonus"] += 8.0
	if hn >= 75:
		b["flame_dmg"] += 10.0
	if hn >= 100:
		b["atk_pct"] += 12.0
		b["soul"] += 12.0

	var yt: int = get_affection("tieu_y_tien")
	if yt >= 25:
		b["hp_pct"] += 8.0
	if yt >= 50:
		b["heal_pct"] += 20.0
	if yt >= 75:
		b["alchemy_bonus"] += 12.0
	if yt >= 100:
		b["hp_pct"] += 15.0
		b["lifesteal"] += 5.0

	var vc: int = get_affection("van_chi")
	if vc >= 25:
		b["spd_pct"] += 6.0
	if vc >= 50:
		b["cooldown_red"] += 8.0
	if vc >= 75:
		b["crit_chance"] += 8.0
	if vc >= 100:
		b["cooldown_red"] += 10.0
		b["spd_pct"] += 8.0

	var tl: int = get_affection("thanh_lan")
	if tl >= 25:
		b["loot_magnet"] += 55.0
	if tl >= 50:
		b["exp_bonus"] += 10.0
		b["gold_pct"] += 15.0
	if tl >= 75:
		b["soul"] += 12.0
	if tl >= 100:
		b["flame_dmg"] += 15.0
		b["gear_drop_pct"] += 12.0

	var md: int = get_affection("my_do_toa")
	if md >= 25:
		b["crit_chance"] += 8.0
	if md >= 50:
		b["realm_pen"] += 12.0
	if md >= 75:
		b["lotus_dmg_pct"] += 18.0
	if md >= 100:
		b["atk_pct"] += 15.0
		b["def_pct"] += 15.0

	cached_affection_bonuses = b


func get_affection_bonus(stat_key: String) -> float:
	if cached_affection_bonuses.is_empty():
		_rebuild_affection_cache()
	return float(cached_affection_bonuses.get(stat_key, 0.0))


func is_affection_milestone_claimed(heroine_key: String, req_pts: int) -> bool:
	return bool(claimed_affection_milestones.get("%s_%d" % [heroine_key, req_pts], false))


func claim_affection_milestone(heroine_key: String, req_pts: int) -> Dictionary:
	var key_id: String = "%s_%d" % [heroine_key, req_pts]
	if is_affection_milestone_claimed(heroine_key, req_pts):
		return { "ok": false, "msg": "Quà Tri Kỷ mốc này đã nhận rồi!" }
	if get_affection(heroine_key) < req_pts:
		return { "ok": false, "msg": "Chưa đạt %d điểm Hảo Cảm!" % req_pts }

	for prof in get_heroine_profiles():
		if str(prof.get("key", "")) != heroine_key:
			continue
		for ms in prof.get("milestones", []):
			if int(ms.get("req", 0)) == req_pts:
				claimed_affection_milestones[key_id] = true
				var parts: Array = []
				var g_gold: int = int(ms.get("gift_gold", 0))
				if g_gold > 0:
					gold += g_gold
					parts.append("+%d Kim Tệ" % g_gold)
				var g_st: int = int(ms.get("gift_stones", 0))
				if g_st > 0:
					enhance_stones += g_st
					parts.append("+%d Đá CH" % g_st)
				var g_items: Dictionary = ms.get("gift_items", {})
				for iid in g_items.keys():
					var cnt: int = int(g_items[iid])
					add_item(str(iid), cnt)
					var idef: Dictionary = GameDatabase.get_item_def(str(iid))
					parts.append("%s x%d" % [str(idef.get("name", iid)), cnt])
				EventBus.audio_sfx_requested.emit("chest_open")
				EventBus.stats_changed.emit()
				trigger_auto_save("nhận quà hồng nhan")
				return {
					"ok": true,
					"msg": "NHẬN QUÀ TRI KỶ (%s · Mốc %d): %s!" % [str(prof.get("name", "")), req_pts, ", ".join(parts)]
				}
	return { "ok": false, "msg": "Không tìm thấy mốc quà!" }


func give_gift_to_heroine(heroine_key: String, item_id: String) -> Dictionary:
	if get_item_count(item_id) <= 0:
		return { "ok": false, "msg": "Trong Nạp Giới không có vật phẩm này!" }
	if get_affection(heroine_key) >= 100:
		return { "ok": false, "msg": "Hảo Cảm đã đạt cực hạn 100/100 (Tri Kỷ Trọn Đời)!" }
	var idef: Dictionary = GameDatabase.get_item_def(item_id)
	var itype: String = str(idef.get("type", ""))
	if itype == "breakthrough":
		return { "ok": false, "msg": "Không nên tặng Đan Đột Phá quý hiếm!" }

	var is_fav: bool = false
	var h_name: String = heroine_key
	for prof in get_heroine_profiles():
		if str(prof.get("key", "")) == heroine_key:
			h_name = str(prof.get("name", heroine_key))
			is_fav = (prof.get("favorite_items", []) as Array).has(item_id)
			break

	remove_item(item_id, 1)
	var tier_v: int = maxi(1, int(idef.get("tier", 1)))
	var gain: int = (8 + tier_v * 4) if is_fav else (4 + tier_v * 2)
	add_affection(heroine_key, gain)
	EventBus.audio_sfx_requested.emit("loot_rare" if is_fav else "loot_pickup")
	var fav_tag: String = " [ĐÚNG SỞ THÍCH x2!]" if is_fav else ""
	return {
		"ok": true,
		"msg": "Đã tặng [%s] cho %s -> +%d Hảo Cảm%s (%d/100)!" % [
			str(idef.get("name", item_id)), h_name, gain, fav_tag, get_affection(heroine_key)
		]
	}


func get_active_affection_summary_text() -> String:
	if cached_affection_bonuses.is_empty():
		_rebuild_affection_cache()
	var parts: Array = []
	var labels: Array = [
		["atk_pct", "ATK +%d%%"], ["hp_pct", "HP +%d%%"], ["def_pct", "DEF +%d%%"],
		["spd_pct", "SPD +%d%%"], ["exp_bonus", "EXP +%d%%"], ["flame_dmg", "Hỏa +%d%%"],
		["lotus_dmg_pct", "Hỏa Liên +%d%%"], ["crit_chance", "Crit +%d%%"],
		["cooldown_red", "Giảm CD %d%%"], ["alchemy_bonus", "Đan Đạo +%d%%"],
		["heal_pct", "Hồi Máu +%d%%"], ["lifesteal", "Hút Máu +%d%%"],
		["realm_pen", "Xuyên Áp Chế +%d%%"], ["soul", "SOUL +%d"],
		["loot_magnet", "Hút Đồ +%dpx"], ["gold_pct", "Kim Tệ +%d%%"], ["gear_drop_pct", "Rớt Đồ +%d%%"]
	]
	for pair in labels:
		var v: int = int(round(float(cached_affection_bonuses.get(str(pair[0]), 0.0))))
		if v > 0:
			parts.append(str(pair[1]) % v)
	return " · ".join(parts) if not parts.is_empty() else "Chưa kích hoạt (Đạt >= 25 Hảo Cảm với bất kỳ Hồng Nhan nào!)"


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


func toggle_lotus_fusion_flame(flame_id: String) -> String:
	if not unlocked_flames.has(flame_id):
		return "Bạn chưa thu phục ngọn Hỏa này!"
	if lotus_fusion_flames.has(flame_id):
		lotus_fusion_flames.erase(flame_id)
		EventBus.skills_updated.emit()
		return "Đã tháo %s khỏi khe dung hợp Hỏa Liên." % str(GameDatabase.get_flame_def(flame_id).get("name", flame_id))
	if lotus_fusion_flames.size() >= 4:
		return "Tối đa dung hợp 4 loại Hỏa trong Phật Nộ Hỏa Liên!"
	lotus_fusion_flames.append(flame_id)
	EventBus.skills_updated.emit()
	return "Đã ghép %s vào Hỏa Liên (%d/4 khe)!" % [str(GameDatabase.get_flame_def(flame_id).get("name", flame_id)), lotus_fusion_flames.size()]


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
		return "Tiểu Y Tiên (Hồi Máu & Độc Châm)"
	elif comp_id == "duoc_lao_phantom":
		return "Hồn Ảnh Dược Lão (Cốt Linh Hộ Pháp)"
	elif comp_id == "thai_lan":
		return "Thải Lân (Thất Thải Thôn Thiên Mãng)"
	elif comp_id == "huan_nhi":
		return "Tiêu Huân Nhi (Kim Đế Phần Thiên Viêm)"
	elif comp_id == "tu_nghien":
		return "Tử Nghiên (Thái Hư Cổ Long · Choáng & Tầm Bảo)"
	return "Thu Hồi"


func has_van_lac_passive() -> bool:
	return unlocked_flames.has("di_hoa_14_van_lac") or has_flag("ch06_absorbed_van_lac")


func has_dau_vuong_wings() -> bool:
	if realm_index >= 6:
		return true
	var wg = equipped_gear.get("wings", {})
	if wg is Dictionary and not wg.is_empty():
		return str(wg.get("template_id", "")) == "wing_dau_khi_hoa_duc"
	return false


func set_story_flag(flag_name: String) -> void:
	if flag_name == "" or has_flag(flag_name):
		return
	story_flags[flag_name] = true

	if flag_name == "tu_hon_done":
		add_story_relic("Ấn Ký Tôn Nghiêm (+5% Công Kích)")
		add_affection("huan_nhi", 15)
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Ước Hẹn 3 Năm đã định! Nhận Buff vĩnh viễn [Ấn Ký Tôn Nghiêm +5% ATK] & mở Cổng Bắc lên Hậu Sơn!")
	elif flag_name == "duoc_lao_awake":
		unlock_flame("pham_hoa", true)
		unlock_skill("toai_thach_chuong", "Q")
		add_item("pill_hoi_khi_dan", 2)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("ĐÃ MỞ KHÓA: Dược Lão thức tỉnh! Mở Lò Luyện Đan [L], Phàm Hỏa [H], Kho Đấu Kỹ [K] và [Q] Toái Thạch Chưởng!")
	elif flag_name == "secret_lang_anh_done":
		add_story_relic("Hắc Ảnh Phù (+8% Tốc Chạy)")
		EventBus.audio_sfx_requested.emit("chest_open")
	elif flag_name == "bought_bao_bo":
		unlock_skill("bao_bo", "")
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("ĐÃ LĨNH NGỘ: Hoàng Giai Cao Cấp Đấu Kỹ [Bạo Bộ]! Bấm [K] để lắp vào ô Q/E/R!")
	elif flag_name == "bought_hap_chuong":
		unlock_skill("hap_xuy_chuong", "Q")
		story_flags["ready_thanh_nien_le"] = true
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("ĐÃ LĨNH NGỘ: Huyền Giai Đấu Kỹ [Hấp Chưởng]! Biểu Tỷ Tiêu Ngọc đã xuất hiện ở Hậu Sơn & Lôi Đài Tiêu Ninh đã mở!")
	elif flag_name == "unlocked_bat_cuc_bang":
		unlock_skill("bat_cuc_bang", "E")
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("ĐÃ LĨNH NGỘ: [E] Bát Cực Băng! Nhược Lâm Đạo Sư của Học Viện Già Nam đang đứng chờ bên cạnh Lôi Đài!")
	elif flag_name == "got_gia_nam_leave":
		add_story_relic("Già Nam Ngọc Bài (2 Năm Nghỉ Phép)")
		EventBus.audio_sfx_requested.emit("chest_open")
		EventBus.banter_triggered.emit("Nhận [Già Nam Ngọc Bài] từ Nhược Lâm Đạo Sư! Hãy rèn lên Đấu Chi Khí 9 Đoạn & đột phá Đấu Giả [B]!")
	elif flag_name == "killed_lieu_tich":
		EventBus.banter_triggered.emit("Ám sát Liễu Tịch thành công! Từ mái ngói đen, bóng ma Đấu Hoàng Lăng Ảnh khẽ gật đầu phất tay xóa sạch toàn bộ dấu vết hiện trường!")
	elif flag_name == "ch01_completed":
		duoc_lao_assist_unlocked = true
		unlock_skill("luc_hop_du_than_xich", "")
		unlock_companion("duoc_lao_phantom", true)
		var xich: Dictionary = EquipmentSystem.roll_equipment_instance("wpn_huyen_trong_xich", "dia")
		add_gear_to_bag(xich)
		if not has_weapon_equipped():
			equip_gear_from_bag(str(xich.get("uid", "")))
		is_ruler_sealed = has_huyen_trong_xich_equipped()
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.skills_updated.emit()
		EventBus.banter_triggered.emit("HOÀN THÀNH CHƯƠNG 01! Nhận [HUYỀN TRỌNG XÍCH] + [Lục Hợp Du Thân Xích] + [T] Phụ Thể + Đồng Hành [G] Dược Lão!")
	elif flag_name == "met_tieu_y_tien":
		unlock_skill("diem_phan_phe_lang_xich", "R")
		unlock_companion("tieu_y_tien", true)
		add_affection("tieu_y_tien", 15)
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("CHƯƠNG 02: Tiểu Y Tiên gia nhập Đồng Hành [G], lĩnh ngộ [R] Diễm Phân Phệ Lãng Xích & mở Vách Đá Bắc vào Huyền Nhai Sơn Động!")
	elif flag_name == "found_doc_kinh":
		add_story_relic("Thất Thải Độc Kinh (Tặng Tiểu Y Tiên)")
	elif flag_name == "got_tu_van_duc":
		add_story_relic("Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (1/4)")
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("KỲ NGỘ ĐẠI THÀNH! Đoạt [Tử Vân Dực] (mặc vào để nâng cấp Lướt Space!), [Tử Vân Dực Kích] & [Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa 1/4]! Cổng Đông Bắc Nội Vi đã mở!")
	elif flag_name == "met_van_chi":
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Vân Chi đồng ý dụ Tử Tinh Dực Sư Vương rời ổ! Hãy tiến vào Hang Tím phía Đông hạ [Tiểu Tử Tinh Dực Sư Vương]!")
	elif flag_name == "killed_tieu_su_vuong":
		add_story_relic("Tử Tinh Nguyên & Bầu Tử Linh Tinh")
		EventBus.audio_sfx_requested.emit("chest_open")
		EventBus.banter_triggered.emit("Đoạt được [Tử Tinh Nguyên] & [Tử Linh Tinh]! Mau quay lại Bờ Suối Trăng Bạc gặp Vân Chi [V] luyện hóa Tử Hỏa!")
	elif flag_name == "absorbed_tu_hoa":
		unlock_flame("tu_tinh_thu_hoa", true)
		var hai_tam: Dictionary = EquipmentSystem.roll_equipment_instance("arm_hai_tam_giap", "dia")
		add_gear_to_bag(hai_tam)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("THÔN PHỆ [TỬ TINH THÚ HỎA] THÀNH CÔNG! Phần Quyết thăng Hoàng Giai Đỉnh Phong + Vân Chi để lại [Hải Tâm Giáp (Địa Phẩm)] trong Nạp Giới [I]!")
	elif flag_name == "killed_muc_luc":
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Đã trừng trị Thiếu Đoàn Trưởng Mục Lực! Cổng Đông Nam dẫn tới Thác Nước Nghìn Trượng (Quyết chiến Mục Xà) đã mở!")
	elif flag_name == "killed_muc_xa":
		unlock_skill("thien_hoa_tam_huyen_bien", "")
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("HẠ GỤC ĐOÀN TRƯỞNG MỤC XÀ! Lĩnh ngộ Bí Pháp [Thiên Hỏa Tam Huyền Biến]! Hãy tiến sang phải vào Thung Lũng U Lan gặp Tiểu Y Tiên [V]!")
	elif flag_name == "ch02_farewell_done":
		story_flags["ch02_completed"] = true
		add_story_relic("Bức Thư Chia Ly Tiểu Y Tiên (Xuất Vân)")
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("HOÀN TẤT CHƯƠNG 02! Cổng Đông sang [CHƯƠNG 03] Sa Mạc Tháp Qua Nhĩ (Thạch Mạc Thành) đã chính thức mở!")
	elif flag_name == "met_tieu_dinh_le":
		add_story_relic("Huy Hiệu Mạc Thiết Đoàn (Tiêu Đỉnh · Tiêu Lệ)")
		add_item("pill_ngung_huyet_tan", 2)
		add_item("pill_hoi_khi_dan", 2)
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Đoàn tụ hai vị huynh trưởng Mạc Thiết Đoàn! Giờ xuống góc Tây Nam Thạch Mạc Thành tìm Tiệm Bản Đồ Cổ của Băng Hoàng Hải Ba Đông!")
	elif flag_name == "beat_hai_ba_dong":
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("Dược Lão hiện hồn phóng Cốt Linh Lãnh Hỏa áp chế Băng Hoàng! Hãy nói chuyện [V] với Hải Ba Đông ký giao ước Mảnh Tàn Đồ #2!")
	elif flag_name == "pact_hai_ba_dong":
		add_story_relic("Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (2/4)")
		var hb_neck: Dictionary = EquipmentSystem.roll_equipment_instance("neck_bang_hoang_tam", "dia")
		add_gear_to_bag(hb_neck)
		EventBus.audio_sfx_requested.emit("chest_open")
		EventBus.banter_triggered.emit("Ký giao ước 1 năm Bảo Tiêu với Hải Ba Đông! Nhận [Mảnh Tàn Đồ #2 (2/4)] & [Hàn Băng Chi Tâm]! Quay lên gặp Thanh Lân [V]!")
	elif flag_name == "met_thanh_lan":
		add_story_relic("Bích Xà Tam Hoa Đồng (Thanh Lân)")
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Bích Xà Tam Hoa Đồng thức tỉnh! Hố Cát Sụt phía Bắc dẫn xuống Địa Huyệt Sông Dung Nham Ngầm đã mở!")
	elif flag_name == "got_thanh_lien_dai":
		add_story_relic("Thanh Liên Đài (+15% EXP & +40% Hồi QI)")
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("ĐÀO THÀNH CÔNG [THANH LIÊN ĐÀI] TỪ ĐÁY DUNG NHAM! (+15% EXP & Hồi QI cực nhanh) — Cổng Đông sang Thánh Thành Xà Nhân đã mở!")
	elif flag_name == "beat_co_ha_mac_ba_tu":
		EventBus.audio_sfx_requested.emit("level_up")
		EventBus.banter_triggered.emit("Đã phá tan phòng tuyến Mặc Ba Tư & Đan Vương Cổ Hà! Mau tiến sang Đảo Thánh Trì phía Đông gặp Nữ Vương Mỹ Đỗ Toa [V]!")
	elif flag_name == "snatched_thanh_lien_hoa":
		add_story_relic("Hỏa Chủng Thanh Liên Địa Tâm Hỏa")
		add_affection("my_do_toa", 15)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.banter_triggered.emit("CƯỚP THÀNH CÔNG [#19 THANH LIÊN ĐỊA TÂM HỎA] & [THẤT THẢI THÔN THIÊN MÃNG] NGAY TRƯỚC MŨI CỔ HÀ! Bay qua Cổng Đông Nam tới Ốc Đảo Diêm Lệ!")
	elif flag_name == "ch03_completed":
		unlock_flame("di_hoa_19_thanh_lien", true)
		unlock_skill("phat_no_hoa_lien", "F")
		# Tự động dung hợp Song Hỏa (Tử Hỏa + Thanh Liên Hỏa) vào Xưởng Phật Nộ Hỏa Liên!
		lotus_fusion_flames = []
		if unlocked_flames.has("tu_tinh_thu_hoa"):
			lotus_fusion_flames.append("tu_tinh_thu_hoa")
		lotus_fusion_flames.append("di_hoa_19_thanh_lien")
		unlock_companion("thai_lan", true)
		add_story_relic("Sơ Hình Phật Nộ Hỏa Liên & Thần Thú Thải Lân")
		add_affection("my_do_toa", 25)
		if realm_index < 3:
			realm_index = 3
			stage = 9
		elif realm_index == 3 and stage < 9:
			stage = 9
		recalculate_and_clamp(true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.skills_updated.emit()
		EventBus.stats_changed.emit()
		EventBus.banter_triggered.emit("HOÀN TẤT CHƯƠNG 03! Thu phục [#19 THANH LIÊN ĐỊA TÂM HỎA] + Đồng Hành [G] THẢI LÂN + KHAI SINH TUYỆT KỸ [F] PHẬT NỘ HỎA LIÊN!!")

	# Data-Driven Story Engine: tự động thi hành hiệu ứng cấu hình trong JSON của từng chương (Ch04 -> Ch11)!
	if flag_name == "ch06_absorbed_van_lac":
		# Tự động dung hợp Song Dị Hỏa (Thanh Liên #19 + Vẫn Lạc Tâm Viêm #14) vào Xưởng Phật Nộ Hỏa Liên!
		lotus_fusion_flames = []
		if unlocked_flames.has("di_hoa_19_thanh_lien") or has_flag("ch03_completed"):
			lotus_fusion_flames.append("di_hoa_19_thanh_lien")
		lotus_fusion_flames.append("di_hoa_14_van_lac")
	var fe: Dictionary = GameDatabase.get_flag_effect(flag_name)
	if not fe.is_empty():
		execute_story_effect(fe, flag_name)

	EventBus.story_flag_changed.emit(flag_name)
	_check_quest_flag(flag_name)
	trigger_auto_save("cốt truyện")


# =========================================================
# DATA-DRIVEN STORY ENGINE — ĐIỀU KIỆN & HIỆU ỨNG JSON
# =========================================================
func evaluate_story_condition(cond: Dictionary) -> bool:
	if cond.is_empty():
		return true
	var hf: String = str(cond.get("has_flag", ""))
	if hf != "" and not has_flag(hf):
		return false
	var haf: Array = cond.get("has_all_flags", [])
	for f in haf:
		if not has_flag(str(f)):
			return false
	var mf: String = str(cond.get("missing_flag", ""))
	if mf != "" and has_flag(mf):
		return false
	var maf: Array = cond.get("missing_all_flags", [])
	for f in maf:
		if has_flag(str(f)):
			return false
	var min_r: int = int(cond.get("min_realm", 0))
	if min_r > 0 and realm_index < min_r:
		return false
	var max_r: int = int(cond.get("max_realm", 0))
	if max_r > 0 and realm_index > max_r:
		return false
	var min_st: int = int(cond.get("min_stage", 0))
	if min_st > 0 and stage < min_st:
		return false
	var hi: String = str(cond.get("has_item", ""))
	if hi != "" and get_item_count(hi) <= 0:
		return false
	var his: Dictionary = cond.get("has_items", {})
	for ik in his.keys():
		if get_item_count(str(ik)) < int(his[ik]):
			return false
	var mi: String = str(cond.get("missing_item", ""))
	if mi != "" and get_item_count(mi) > 0:
		return false
	var cq: String = str(cond.get("current_quest", ""))
	if cq != "":
		var cur_q: Dictionary = get_current_quest()
		if str(cur_q.get("id", "")) != cq:
			return false
	var ma: Dictionary = cond.get("min_affection", {})
	for hk in ma.keys():
		if get_affection(str(hk)) < int(ma[hk]):
			return false
	return true


func execute_story_effect(eff: Dictionary, skip_flag_id: String = "") -> Dictionary:
	var result: Dictionary = { "heal_full": false, "banter": "", "open_shop": "" }
	if eff.is_empty():
		return result

	var consume_d: Dictionary = eff.get("consume_items", {})
	for ik in consume_d.keys():
		remove_item(str(ik), int(consume_d[ik]))

	var give_d: Dictionary = eff.get("give_items", {})
	for ik in give_d.keys():
		add_item(str(ik), int(give_d[ik]))

	var g_gold: int = int(eff.get("give_gold", 0))
	if g_gold != 0:
		gold = max(0, gold + g_gold)

	var g_stones: int = int(eff.get("give_stones", 0))
	if g_stones != 0:
		enhance_stones = max(0, enhance_stones + g_stones)

	var g_soul: int = int(eff.get("give_soul", 0))
	if g_soul != 0:
		bonus_soul += g_soul

	var g_exp: int = int(eff.get("give_exp", 0))
	if g_exp > 0:
		add_exp(g_exp)

	var g_fe: int = int(eff.get("give_fire_energy", 0))
	if g_fe != 0:
		add_fire_energy(g_fe)

	var open_auc: String = str(eff.get("open_auction", ""))
	if open_auc != "":
		result["open_auction"] = open_auc

	var aff_d: Dictionary = eff.get("affection", {})
	for hk in aff_d.keys():
		add_affection(str(hk), int(aff_d[hk]))

	var rel_s: String = str(eff.get("relic", ""))
	if rel_s != "":
		add_story_relic(rel_s)
	var rel_arr: Array = eff.get("relics", [])
	for rs in rel_arr:
		add_story_relic(str(rs))

	var sk_u = eff.get("unlock_skill", {})
	if sk_u is Dictionary and not sk_u.is_empty():
		unlock_skill(str(sk_u.get("id", "")), str(sk_u.get("slot", "")))

	var fl_u = eff.get("unlock_flame", {})
	if fl_u is Dictionary and not fl_u.is_empty():
		unlock_flame(str(fl_u.get("id", "")), bool(fl_u.get("auto_equip", false)))

	var cmp_u = eff.get("unlock_companion", {})
	if cmp_u is Dictionary and not cmp_u.is_empty():
		unlock_companion(str(cmp_u.get("id", "")), bool(cmp_u.get("auto_summon", true)))

	var gear_arr: Array = eff.get("give_gear", [])
	for gd in gear_arr:
		if gd is Dictionary:
			var tpl_id: String = str(gd.get("template", ""))
			var rar_id: String = str(gd.get("rarity", "dia"))
			if tpl_id != "":
				var inst: Dictionary = EquipmentSystem.roll_equipment_instance(tpl_id, rar_id)
				if not inst.is_empty():
					add_gear_to_bag(inst)
					if bool(gd.get("auto_equip", false)):
						equip_gear_from_bag(str(inst.get("uid", "")))

	var realm_min = eff.get("set_realm_min", {})
	if realm_min is Dictionary and not realm_min.is_empty():
		var target_r: int = int(realm_min.get("realm", realm_index))
		var target_s: int = int(realm_min.get("stage", stage))
		if realm_index < target_r:
			realm_index = target_r
			stage = target_s
			current_exp = 0
		elif realm_index == target_r and stage < target_s:
			stage = target_s
		recalculate_and_clamp(true)
		EventBus.realm_updated.emit(get_realm_display_title(), "Bạo cấp đột phá cốt truyện!")
		_check_quest_realm()

	if bool(eff.get("reset_duoc_lao_active", false)):
		is_duoc_lao_active = false

	var sf: String = str(eff.get("set_flag", ""))
	if sf != "" and sf != skip_flag_id:
		set_story_flag(sf)
	var sf_arr: Array = eff.get("set_flags", [])
	for f in sf_arr:
		var fs: String = str(f)
		if fs != "" and fs != skip_flag_id:
			set_story_flag(fs)

	var sfx_s: String = str(eff.get("sfx", ""))
	if sfx_s != "":
		EventBus.audio_sfx_requested.emit(sfx_s)

	var sh_arr: Array = eff.get("shake", [])
	if sh_arr.size() >= 2:
		EventBus.screen_shake_requested.emit(float(sh_arr[0]), float(sh_arr[1]))

	var b_txt: String = str(eff.get("banter", ""))
	if b_txt != "":
		EventBus.banter_triggered.emit(b_txt)
		result["banter"] = b_txt

	if bool(eff.get("heal_full", false)):
		recalculate_and_clamp(true)
		result["heal_full"] = true

	var oshop: String = str(eff.get("open_shop", ""))
	if oshop != "":
		result["open_shop"] = oshop

	var w_map: String = str(eff.get("warp_map", ""))
	if w_map != "":
		result["warp_map"] = w_map
		var w_sp = eff.get("warp_spawn", [])
		if w_sp is Array and w_sp.size() >= 2:
			result["warp_spawn"] = Vector2(float(w_sp[0]), float(w_sp[1]))

	EventBus.stats_changed.emit()
	return result


func get_assist_mode() -> String:
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
	if has_flag("ch04_tieu_toc_no_huyet"):
		if low_id.find("van_lam") != -1 or low_id.find("van_yen") != -1 or low_id.find("van_lang") != -1 or low_id.find("van_son") != -1 or low_id.find("nap_lan") != -1 or low_id.find("mac_thua") != -1 or low_id.find("hon_dien") != -1 or low_nm.find("vân lam") != -1 or low_nm.find("hồn điện") != -1:
			mult *= 1.15 # Tiêu Tộc Nộ Huyết (+15% ATK vs Vân Lam Tông & Hồn Điện!)
	if has_flag("ch06_duoc_lao_memory_done"):
		if low_id.find("han_phong") != -1 or low_id.find("hon_dien") != -1 or low_nm.find("hàn phong") != -1 or low_nm.find("hồn điện") != -1:
			mult *= 1.25 # Ký Ức Phản Sư Dược Lão (+25% ATK vs Hàn Phong & Hồn Điện!)
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
		return tid in ["wpn_huyen_trong_xich", "wpn_xich_ngung_vat", "wpn_xich_luu_ly_viem"]
	return false


func has_tu_van_duc_equipped() -> bool:
	var wg = equipped_gear.get("wings", {})
	if wg is Dictionary and not wg.is_empty():
		var tid: String = str(wg.get("template_id", ""))
		return tid in ["wing_tu_van_duc", "wing_hac_diem_tu_van_duc", "wing_dau_khi_hoa_duc"]
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
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += float(st_dict.get("hp", 20.0)) * float(stages_cnt)
	total *= (1.0 + (get_affection_bonus("hp_pct") + float(tower_active_buffs.get("hp_pct", 0.0))) / 100.0)
	return total


func get_max_qi() -> float:
	var total: float = 35.0 + get_gear_bonus("qi")
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += float(st_dict.get("qi", 12.0)) * float(stages_cnt)
	return total


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
	mult *= (1.0 + (get_affection_bonus("atk_pct") + float(tower_active_buffs.get("atk_pct", 0.0)) + PanGateMgr.get_atk_bonus_pct(self)) / 100.0)
	if has_flag("tu_hon_done"):
		mult *= 1.05 # Ấn Ký Tôn Nghiêm!
	if has_flag("ch05_completed"):
		mult *= 1.05 # Đệ Nhất Tân Sinh Vương!
	if is_duoc_lao_active:
		mult *= 2.45 if get_assist_mode() == "medusa_dau_tong" else 2.2
	if is_flame_buff_active:
		mult *= 1.45
	if am_duong_buff_timer > 0.0:
		mult *= 1.25 # Âm Dương Huyền Long Đan!
	return base_atk * mult


func get_def() -> float:
	var total: float = 3.0 + get_gear_bonus("def")
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += float(st_dict.get("def", 2.0)) * float(stages_cnt)
	total *= (1.0 + (get_affection_bonus("def_pct") + float(tower_active_buffs.get("def_pct", 0.0))) / 100.0)
	if has_flag("ch06_got_dia_tam_nhu"):
		total *= 1.15 # Địa Tâm Tôi Thể Nhũ (+15% DEF vĩnh viễn!)
	if realm_index >= 6:
		total *= 1.52 # Đấu Vương — Đấu Khí Hóa Dực & Hộ Thể Cương Khí!
	elif realm_index >= 5:
		total *= 1.42 # Đấu Linh — Đấu Khí Ngưng Vật!
	elif realm_index >= 4:
		total *= 1.32 # Đấu Khí Khải Giáp của Đại Đấu Sư!
	elif realm_index >= 3:
		total *= 1.18 # Đấu Khí Sa Y của Đấu Sư!
	return total


func get_move_speed() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var base_spd: float = 220.0 + (get_gear_bonus("spd") + float(core_t.get("spd", 0.0))) * 1.35
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		base_spd += float(st_dict.get("spd", 2.0)) * float(stages_cnt) * 1.15
	base_spd = minf(base_spd, 465.0)
	base_spd *= (1.0 + (get_affection_bonus("spd_pct") + float(tower_active_buffs.get("spd_pct", 0.0))) / 100.0)
	if has_dau_vuong_wings():
		base_spd *= 1.15 # Đấu Vương: Đấu Khí Hóa Dực ngự không phi hành (+15% SPD)!
	if has_flag("secret_lang_anh_done"):
		base_spd *= 1.08 # Hắc Ảnh Phù!
	if is_ruler_sealed and has_huyen_trong_xich_equipped():
		base_spd *= 0.85
	if is_duoc_lao_active:
		base_spd *= 1.40 if get_assist_mode() == "medusa_dau_tong" else 1.35
	if is_flame_buff_active:
		base_spd *= 1.20
	if player_slow_timer > 0.0:
		base_spd *= (1.0 - clampf(player_slow_ratio, 0.0, 0.55))
	return base_spd


func get_soul() -> int:
	var total: int = 5 + bonus_soul + int(round(get_gear_bonus("soul") + get_affection_bonus("soul")))
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += int(st_dict.get("soul", 2)) * stages_cnt
	return total


func get_crit_chance() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var total_pct: float = get_gear_bonus("crit_chance") + get_affection_bonus("crit_chance") + float(core_t.get("crit_pct", 0.0)) + float(tower_active_buffs.get("crit_pct", 0.0))
	return clampf(0.12 + total_pct / 100.0, 0.05, 0.92)


func get_lifesteal_ratio() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var total_pct: float = get_gear_bonus("lifesteal") + get_affection_bonus("lifesteal") + float(core_t.get("lifesteal_pct", 0.0)) + float(tower_active_buffs.get("lifesteal_pct", 0.0))
	return clampf(total_pct / 100.0, 0.0, 0.45)


func get_cooldown_multiplier() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var cdr: float = clampf((get_gear_bonus("cooldown_red") + get_affection_bonus("cooldown_red") + float(core_t.get("cd_red_pct", 0.0)) + float(tower_active_buffs.get("cd_red_pct", 0.0))) / 100.0, 0.0, 0.65)
	return 1.0 - cdr


func get_poise_dmg_multiplier() -> float:
	var core_t: Dictionary = get_core_socket_totals()
	var bonus_pct: float = float(core_t.get("poise_pct", 0.0)) + float(tower_active_buffs.get("poise_pct", 0.0))
	if realm_index >= 6:
		bonus_pct += 25.0 # Đấu Vương: Đấu Khí Hóa Dực & Bá Khí Phá Thế!
	elif realm_index >= 5:
		bonus_pct += 15.0 # Đấu Linh: Đấu Khí Ngưng Vật tăng lực phá thế!
	return 1.0 + bonus_pct / 100.0


func get_attack_reach_multiplier() -> float:
	if realm_index >= 6:
		return 1.28
	return 1.20 if realm_index >= 5 else 1.0


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
	var bonus_pct: float = get_gear_bonus("flame_dmg") + get_affection_bonus("flame_dmg")
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
	return 1.0 + get_affection_bonus("heal_pct") / 100.0


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
	if is_flame_buff_active:
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
	return "%s — %d %s" % [r_name, stage, unit]


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
	return mult


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
		return 1.0 + float(-diff) * 0.12
	var f_def: Dictionary = get_active_flame_def()
	var f_pen: float = float(f_def.get("realm_penetration", 0.0)) if not f_def.is_empty() else 0.0
	var aff_pen: float = get_affection_bonus("realm_pen") / 100.0
	var total_pen: float = clampf(f_pen + skill_realm_pen + aff_pen, 0.0, 1.0)
	var penalty_per: float = float(GameDatabase.suppression_rules.get("damage_penalty_per_major_realm", 0.38))
	var raw_penalty: float = float(diff) * penalty_per * (1.0 - total_pen)
	var min_mult: float = float(GameDatabase.suppression_rules.get("min_damage_multiplier", 0.10))
	return maxf(min_mult, 1.0 - raw_penalty)


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
		for cand in ["pill_huyet_ngung_dan", "pill_bang_tam_dan", "pill_ngung_huyet_tan"]:
			if get_item_count(cand) > 0:
				return cand
		return quick_hp_pill_id
	elif slot_num == 2:
		if get_item_count(quick_qi_pill_id) > 0:
			return quick_qi_pill_id
		var alt_qi: String = "pill_thanh_lien_tu" if quick_qi_pill_id == "pill_hoi_khi_dan" else "pill_hoi_khi_dan"
		if get_item_count(alt_qi) > 0:
			return alt_qi
		return quick_qi_pill_id
	return "pill_truc_co_linh_dich"


func set_quick_pill_slot(slot_num: int, item_id: String) -> void:
	if slot_num == 1 and item_id in ["pill_ngung_huyet_tan", "pill_bang_tam_dan", "pill_huyet_ngung_dan"]:
		quick_hp_pill_id = item_id
	elif slot_num == 2 and (item_id == "pill_hoi_khi_dan" or item_id == "pill_thanh_lien_tu"):
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
		if current_qi >= get_max_qi():
			return false
		remove_item(item_id, 1)
		var rest: float = float(idef.get("restore_qi", 50.0))
		current_qi = minf(get_max_qi(), current_qi + rest)
		EventBus.audio_sfx_requested.emit("loot_pickup")
		if world_pos != Vector2.ZERO:
			EventBus.floating_text_requested.emit(world_pos, "+%d Đấu Khí" % int(round(rest)), Color("#4CC9F0"))
		EventBus.stats_changed.emit()
		return true
	elif itype == "consumable_exp":
		remove_item(item_id, 1)
		EventBus.audio_sfx_requested.emit("level_up")
		var g_exp: int = int(idef.get("grant_exp", 240))
		add_exp(g_exp, world_pos)
		return true
	elif itype == "consumable_buff":
		remove_item(item_id, 1)
		recalculate_and_clamp(true)
		am_duong_buff_timer = maxf(am_duong_buff_timer, float(idef.get("buff_sec", 30.0)))
		EventBus.audio_sfx_requested.emit("breakthrough")
		if world_pos != Vector2.ZERO:
			EventBus.floating_text_requested.emit(world_pos + Vector2(0, -68), "PHÁ HẬU NHI LẬP! (+25% ATK & FULL HP/QI)", Color("#FFD166"))
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


func _on_enemy_killed(enemy_id: String, _is_boss: bool) -> void:
	enemies_killed_total += 1
	enemy_kill_counts[enemy_id] = int(enemy_kill_counts.get(enemy_id, 0)) + 1
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
			EventBus.banter_triggered.emit("CHÚC MỪNG! Bạn đã chinh phục trọn vẹn %d mốc cốt truyện Quyển I & II (Chương 01 – 06: Ô Thản Thành -> Đỉnh Vân Lam Sơn -> Già Nam Nội Viện & Vẫn Lạc Tâm Viêm)!" % GameDatabase.all_quests.size())
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
	match core_id:
		"core_hoa_1":
			return { "id": core_id, "name": "Hỏa Ma Hạch (Cấp 1)", "atk": 14.0, "burn_dps": 6.0, "color": Color("#FF7B00"), "desc": "+14 ATK · +6 Thiêu Đốt/s" }
		"core_moc_2":
			return { "id": core_id, "name": "Mộc Ma Hạch (Cấp 2)", "hp": 120.0, "hp_regen": 3.0, "color": Color("#2EC4B6"), "desc": "+120 HP · Hồi +3 HP/s" }
		"core_hoa_3":
			return { "id": core_id, "name": "Viêm Xà Ma Hạch (Cấp 3)", "atk": 32.0, "crit_pct": 8.0, "burn_dps": 16.0, "color": Color("#FF4D6D"), "desc": "+32 ATK · +8% Crit · +16 Thiêu Đốt/s" }
		"core_phong_4":
			return { "id": core_id, "name": "Phong Ma Hạch (Cấp 4)", "spd": 24.0, "crit_pct": 12.0, "cd_red_pct": 8.0, "color": Color("#70D6FF"), "desc": "+24 SPD · +12% Crit · -8% Hồi Chiêu" }
		"core_loi_5":
			return { "id": core_id, "name": "Lôi Ma Hạch (Cấp 5)", "atk": 58.0, "crit_pct": 10.0, "poise_pct": 22.0, "color": Color("#E0AAFF"), "desc": "+58 ATK · +10% Crit · +22% Phá Thế Boss" }
		"core_huyet_5":
			return { "id": core_id, "name": "Huyết Ma Hạch (Cấp 5)", "atk": 48.0, "hp": 280.0, "lifesteal_pct": 6.0, "color": Color("#EF476F"), "desc": "+48 ATK · +280 HP · +6% Hút Máu" }
		"core_bang_5":
			return { "id": core_id, "name": "Băng Ma Hạch Tuyết Ma (Cấp 5)", "atk": 55.0, "hp": 320.0, "cd_red_pct": 10.0, "color": Color("#72EFDD"), "desc": "+55 ATK · +320 HP · -10% Hồi Chiêu" }
		_:
			return {}


func get_core_socket_totals() -> Dictionary:
	var totals: Dictionary = {
		"atk": 0.0, "hp": 0.0, "spd": 0.0, "crit_pct": 0.0,
		"burn_dps": 0.0, "hp_regen": 0.0, "cd_red_pct": 0.0,
		"poise_pct": 0.0, "lifesteal_pct": 0.0
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
