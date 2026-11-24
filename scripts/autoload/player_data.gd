extends Node
## Lưu trữ toàn bộ trạng thái tu luyện Chuẩn Cốt Truyện 100% — Chương 01 -> Chương 03 (Quyển I):
## - Khởi đầu phút 0: Đấu Chi Khí 3 Đoạn, TAY KHÔNG, chưa có Dược Lão, chưa có vũ khí, chưa có Đấu Kỹ, chưa có Hỏa Liên!
## - Hỗ trợ Save 3 Ô, Auto-Save/Auto-Continue, Chế Độ DEMO, 10 Ô Trang Bị, 10 Đấu Kỹ, 11 Bản Đồ, 21 Mốc Cốt Truyện, Hảo Cảm Hồng Nhan (Buff & Tặng Quà) & Kỳ Vật!

const LEGACY_SAVE_PATH: String = "user://dptk_savegame.json"
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

# Trang bị 10 Ô & Túi đồ
var equipped_gear: Dictionary = {}
var gear_bag: Array = []
var cached_gear_bonuses: Dictionary = {}

# Cơ chế Đấu Phá Thương Khung (Mở dần theo truyện)
var is_ruler_sealed: bool = false
var is_duoc_lao_active: bool = false
var is_flame_buff_active: bool = false
var equipped_flame_id: String = ""
var unlocked_flames: Array = []
var lotus_fusion_flames: Array = []

# Trạng thái chiến đấu tạm thời từ Dị Hỏa (Phật Nộ Hỏa Liên) & Boss
var enemies_killed_total: int = 0
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
var quest_progress: int = 0
var all_quests_done: bool = false


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
		if auto_save_enabled and is_in_gameplay_session():
			auto_save_timer += delta
			if auto_save_timer >= 30.0:
				auto_save_timer = 0.0
				trigger_auto_save("định kỳ 30s")


func is_in_gameplay_session() -> bool:
	return not get_tree().get_nodes_in_group("world_stage").is_empty()


func load_user_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return
	var d: Dictionary = parsed
	auto_save_enabled = bool(d.get("auto_save_enabled", true))
	auto_continue_on_start = bool(d.get("auto_continue_on_start", false))
	last_played_slot = clampi(int(d.get("last_played_slot", 1)), 1, MAX_SAVE_SLOTS)
	# Truyền save_to_disk = false để không ghi đè mất file settings trong lúc đang đọc!
	if d.has("bgm_volume"):
		AudioManager.set_bgm_volume(float(d.get("bgm_volume", 0.65)), false)
	if d.has("sfx_volume"):
		AudioManager.set_sfx_volume(float(d.get("sfx_volume", 0.80)), false)
	if d.has("is_muted"):
		AudioManager.set_muted(bool(d.get("is_muted", false)), false)


func save_user_settings() -> void:
	var payload: Dictionary = {}
	if FileAccess.file_exists(SETTINGS_PATH):
		var rf := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if rf != null:
			var parsed: Variant = JSON.parse_string(rf.get_as_text())
			if parsed is Dictionary:
				payload = parsed
	payload["auto_save_enabled"] = auto_save_enabled
	payload["auto_continue_on_start"] = auto_continue_on_start
	payload["last_played_slot"] = last_played_slot
	payload["bgm_volume"] = AudioManager.bgm_volume
	payload["sfx_volume"] = AudioManager.sfx_volume
	payload["is_muted"] = AudioManager.is_muted
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(payload, "\t"))


func set_auto_save_enabled(enabled: bool) -> void:
	auto_save_enabled = enabled
	auto_save_timer = 0.0
	save_user_settings()


func set_auto_continue_on_start(enabled: bool) -> void:
	auto_continue_on_start = enabled
	save_user_settings()


func get_best_continue_slot() -> int:
	if bool(get_save_slot_summary(last_played_slot).get("exists", false)):
		return last_played_slot
	for s in range(1, MAX_SAVE_SLOTS + 1):
		if bool(get_save_slot_summary(s).get("exists", false)):
			return s
	return -1


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
	quest_progress = 0
	all_quests_done = false
	inventory = { "pill_ngung_huyet_tan": 1 }
	quick_hp_pill_id = "pill_ngung_huyet_tan"
	quick_qi_pill_id = "pill_hoi_khi_dan"
	enemies_killed_total = 0
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

	realm_index = 3 # Đấu Sư 9 Tinh Đỉnh Phong (sẵn sàng bấm [B] lên Đại Đấu Sư!)
	stage = 9
	bonus_soul = 120
	gold = 50000
	enhance_stones = 999

	# Mở toàn bộ cờ cốt truyện để đi tất cả 11 bản đồ & Lò Đan/Dị Hỏa (giữ Boss Hải Ba Đông để test đánh Boss!)
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
		"ch03_completed": true
	}
	affection = { "huan_nhi": 100, "tieu_y_tien": 100, "van_chi": 100, "thanh_lan": 100, "my_do_toa": 100 }
	story_relics = [
		"Chế Độ DEMO — Mở Khóa Toàn Bộ (11 Map · 10 Đấu Kỹ · 28 Hỏa)",
		"Ấn Ký Tôn Nghiêm (+5% Công Kích)",
		"Hắc Ảnh Phù (+8% Tốc Chạy)",
		"Thanh Liên Đài (+15% EXP & +40% Hồi QI)",
		"Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (2/4)",
		"Sơ Hình Phật Nộ Hỏa Liên & Thần Thú Thải Lân"
	]

	# Mở toàn bộ 28 ngọn Hỏa (từ Phàm Hỏa tới #1 Đế Viêm!), vận chuyển #19 Thanh Liên Địa Tâm Hỏa & ghép sẵn 4 Hỏa Liên!
	unlocked_flames = []
	for fl in GameDatabase.flames_ordered:
		if fl is Dictionary:
			var fid: String = str(fl.get("id", ""))
			if fid != "":
				unlocked_flames.append(fid)
	equipped_flame_id = "di_hoa_19_thanh_lien"
	lotus_fusion_flames = ["tu_tinh_thu_hoa", "di_hoa_19_thanh_lien", "di_hoa_11_cot_linh", "di_hoa_04_kim_de"]

	# Mở toàn bộ 10 Đấu Kỹ + [F] Phật Nộ Hỏa Liên + [T] Cốt Linh Phụ Thể!
	unlocked_skills = []
	for sid in GameDatabase.skills_by_id.keys():
		unlocked_skills.append(str(sid))
	slot_q_skill = "hap_xuy_chuong"
	slot_e_skill = "bat_cuc_bang"
	slot_r_skill = "diem_phan_phe_lang_xich"
	slot_f_skill = "phat_no_hoa_lien"
	duoc_lao_assist_unlocked = true

	# Mở toàn bộ 3 Đồng Hành AI [G] (mặc định triệu hồi Thần Thú Thải Lân!)
	unlocked_companions = ["duoc_lao_phantom", "tieu_y_tien", "thai_lan"]
	active_companion_id = "thai_lan"

	# Trang bị 10 Ô Full Thiên Phẩm + 3 Vũ Khí & Bảo Vật trong Nạp Giới!
	equipped_gear = {
		"weapon": EquipmentSystem.roll_equipment_instance("wpn_huyen_trong_xich", "thien"),
		"armor": EquipmentSystem.roll_equipment_instance("arm_giap_vay_xa_hoang", "thien"),
		"legs": EquipmentSystem.roll_equipment_instance("leg_bi_giap_kho", "thien"),
		"boots": EquipmentSystem.roll_equipment_instance("boot_phong_hanh_hai", "thien"),
		"gloves": EquipmentSystem.roll_equipment_instance("glv_thiet_quyen_uyen", "thien"),
		"necklace": EquipmentSystem.roll_equipment_instance("neck_bang_hoang_tam", "thien"),
		"pendant": EquipmentSystem.roll_equipment_instance("pend_thanh_lien_dai", "thien"),
		"ring": EquipmentSystem.roll_equipment_instance("ring_cot_viem_gioi", "thien"),
		"wings": EquipmentSystem.roll_equipment_instance("wing_tu_van_duc", "thien"),
		"cauldron": EquipmentSystem.roll_equipment_instance("caul_hac_ma_dinh", "thien")
	}
	gear_bag = [
		EquipmentSystem.roll_equipment_instance("wpn_thiet_kiem", "thien"),
		EquipmentSystem.roll_equipment_instance("wpn_tinh_cuong_dao", "thien"),
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

	active_quest_idx = GameDatabase.quests_ch01.size()
	quest_progress = 0
	all_quests_done = true

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
	return "Thu Hồi"


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

	EventBus.story_flag_changed.emit(flag_name)
	_check_quest_flag(flag_name)
	trigger_auto_save("cốt truyện")


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
		return str(w.get("template_id", "")) == "wpn_huyen_trong_xich"
	return false


func has_tu_van_duc_equipped() -> bool:
	var wg = equipped_gear.get("wings", {})
	if wg is Dictionary and not wg.is_empty():
		return str(wg.get("template_id", "")) == "wing_tu_van_duc"
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
	var total: float = 65.0 + get_gear_bonus("hp")
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += float(st_dict.get("hp", 20.0)) * float(stages_cnt)
	total *= (1.0 + get_affection_bonus("hp_pct") / 100.0)
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
	var base_atk: float = 8.0 + get_gear_bonus("atk")
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		base_atk += float(st_dict.get("atk", 4.0)) * float(stages_cnt)
	var f_def: Dictionary = get_active_flame_def()
	var mult: float = float(f_def.get("atk_mult", 1.0)) if not f_def.is_empty() else 1.0
	mult *= (1.0 + get_affection_bonus("atk_pct") / 100.0)
	if has_flag("tu_hon_done"):
		mult *= 1.05 # Ấn Ký Tôn Nghiêm!
	if is_duoc_lao_active:
		mult *= 2.2
	if is_flame_buff_active:
		mult *= 1.45
	return base_atk * mult


func get_def() -> float:
	var total: float = 3.0 + get_gear_bonus("def")
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		total += float(st_dict.get("def", 2.0)) * float(stages_cnt)
	total *= (1.0 + get_affection_bonus("def_pct") / 100.0)
	if realm_index >= 3:
		total *= 1.18 # Đấu Khí Sa Y của Đấu Sư!
	return total


func get_move_speed() -> float:
	var base_spd: float = 220.0 + get_gear_bonus("spd") * 1.35
	for r_idx in range(1, realm_index + 1):
		var r_def: Dictionary = GameDatabase.get_realm_def(r_idx)
		var st_dict: Dictionary = r_def.get("stats_per_stage", {})
		var stages_cnt: int = int(r_def.get("max_stage", 9)) if r_idx < realm_index else stage
		base_spd += float(st_dict.get("spd", 2.0)) * float(stages_cnt) * 1.15
	base_spd = minf(base_spd, 450.0)
	base_spd *= (1.0 + get_affection_bonus("spd_pct") / 100.0)
	if has_flag("secret_lang_anh_done"):
		base_spd *= 1.08 # Hắc Ảnh Phù!
	if is_ruler_sealed and has_huyen_trong_xich_equipped():
		base_spd *= 0.85
	if is_duoc_lao_active:
		base_spd *= 1.35
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
	return clampf(0.12 + (get_gear_bonus("crit_chance") + get_affection_bonus("crit_chance")) / 100.0, 0.05, 0.90)


func get_lifesteal_ratio() -> float:
	return clampf((get_gear_bonus("lifesteal") + get_affection_bonus("lifesteal")) / 100.0, 0.0, 0.40)


func get_cooldown_multiplier() -> float:
	var cdr: float = clampf((get_gear_bonus("cooldown_red") + get_affection_bonus("cooldown_red")) / 100.0, 0.0, 0.60)
	return 1.0 - cdr


func get_flame_dmg_multiplier() -> float:
	return 1.0 + (get_gear_bonus("flame_dmg") + get_affection_bonus("flame_dmg")) / 100.0


func get_alchemy_equipment_bonus() -> float:
	return get_gear_bonus("alchemy_bonus") / 100.0


func get_loot_magnet_radius() -> float:
	return 175.0 + get_gear_bonus("loot_magnet") + get_affection_bonus("loot_magnet")


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
	if is_duoc_lao_active:
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
		var alt_hp: String = "pill_bang_tam_dan" if quick_hp_pill_id == "pill_ngung_huyet_tan" else "pill_ngung_huyet_tan"
		if get_item_count(alt_hp) > 0:
			return alt_hp
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
	if slot_num == 1 and (item_id == "pill_ngung_huyet_tan" or item_id == "pill_bang_tam_dan"):
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
	return false


func heal_from_lifesteal(damage_dealt: float) -> void:
	var ls: float = get_lifesteal_ratio()
	if ls <= 0.0:
		return
	var gain: float = damage_dealt * ls
	if gain >= 1.0 and current_hp < get_max_hp():
		current_hp = minf(get_max_hp(), current_hp + gain)
		EventBus.stats_changed.emit()


# --- NHIỆM VỤ TUYẾN TÍNH 15 MỐC CHUẨN CHƯƠNG 01 & 02 ---
func get_current_quest() -> Dictionary:
	if all_quests_done or active_quest_idx >= GameDatabase.quests_ch01.size():
		return {}
	var q = GameDatabase.quests_ch01[active_quest_idx]
	if q is Dictionary:
		return q
	return {}


func _check_quest_flag(flag_name: String) -> void:
	var q: Dictionary = get_current_quest()
	if q.is_empty():
		return
	if str(q.get("type", "")) == "story_flag" and str(q.get("flag_name", "")) == flag_name:
		_advance_quest_progress(1)


func _on_enemy_killed(enemy_id: String, _is_boss: bool) -> void:
	enemies_killed_total += 1
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

	var q: Dictionary = get_current_quest()
	if q.is_empty():
		return
	if str(q.get("type", "")) == "kill_any" and enemy_id == str(q.get("target_id", "")):
		_advance_quest_progress(1)


func notify_pill_crafted(pill_id: String) -> void:
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
		var rew_exp: int = int(q.get("reward_exp", 50))
		add_exp(rew_exp)
		gold += int(q.get("reward_gold", 0))
		var rew_items: Dictionary = q.get("reward_items", {})
		for k in rew_items.keys():
			add_item(str(k), int(rew_items[k]))
		active_quest_idx += 1
		quest_progress = 0
		if active_quest_idx >= GameDatabase.quests_ch01.size():
			all_quests_done = true
			EventBus.banter_triggered.emit("CHÚC MỪNG! Bạn đã chinh phục trọn vẹn 21 mốc cốt truyện Chương 01, Chương 02 & Chương 03 Sa Mạc Tháp Qua Nhĩ!")
		else:
			var next_q: Dictionary = get_current_quest()
			EventBus.banter_triggered.emit(str(next_q.get("intro_log", "")))
			if str(next_q.get("type", "")) == "story_flag" and has_flag(str(next_q.get("flag_name", ""))):
				_advance_quest_progress(1)
			elif str(next_q.get("type", "")) == "reach_realm":
				_check_quest_realm()
		trigger_auto_save("hoàn thành nhiệm vụ")
	EventBus.quest_updated.emit()


# --- HỆ THỐNG LƯU / TẢI 3 Ô ---
func get_save_slot_path(slot_idx: int) -> String:
	var s: int = clampi(slot_idx, 1, MAX_SAVE_SLOTS)
	return "user://dptk_save_slot_%d.json" % s


func has_any_save() -> bool:
	for s in range(1, MAX_SAVE_SLOTS + 1):
		if FileAccess.file_exists(get_save_slot_path(s)):
			return true
	return FileAccess.file_exists(LEGACY_SAVE_PATH)


func get_save_slot_summary(slot_idx: int) -> Dictionary:
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
	var demo_tag: String = "[DEMO] " if bool(d.get("is_demo_mode", false)) else ""
	return {
		"exists": true,
		"slot": slot_idx,
		"is_demo": bool(d.get("is_demo_mode", false)),
		"label": "Ô %d: %s%s | %s (%d phút) %s" % [slot_idx, demo_tag, r_title, m_title, mins, saved_at]
	}


func save_game(slot_idx: int = -1, silent: bool = false) -> bool:
	var target_slot: int = active_save_slot if slot_idx <= 0 else clampi(slot_idx, 1, MAX_SAVE_SLOTS)
	active_save_slot = target_slot
	last_played_slot = target_slot
	var m_def: Dictionary = GameDatabase.get_map_def(current_map_id)
	var m_name: String = str(m_def.get("name", current_map_id))
	var dt: Dictionary = Time.get_datetime_dict_from_system()
	var stamp: String = "%02d:%02d %02d/%02d" % [int(dt.get("hour", 0)), int(dt.get("minute", 0)), int(dt.get("day", 1)), int(dt.get("month", 1))]

	# Ghi nhận tọa độ chính xác hiện tại của Tiêu Viêm để lần sau vào đứng đúng chỗ cũ!
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty() and players[0] is Node2D:
		saved_player_pos = (players[0] as Node2D).global_position
		has_saved_player_pos = true

	var payload: Dictionary = {
		"meta_realm": get_realm_display_title(),
		"meta_map": m_name,
		"meta_saved_at": stamp,
		"is_demo_mode": is_demo_mode,
		"has_player_pos": has_saved_player_pos,
		"player_pos_x": saved_player_pos.x,
		"player_pos_y": saved_player_pos.y,
		"playtime_sec": playtime_sec,
		"current_map_id": current_map_id,
		"realm_index": realm_index,
		"stage": stage,
		"current_exp": current_exp,
		"bonus_soul": bonus_soul,
		"gold": gold,
		"enhance_stones": enhance_stones,
		"story_flags": story_flags,
		"opened_chests": opened_chests,
		"affection": affection,
		"story_relics": story_relics,
		"claimed_affection_milestones": claimed_affection_milestones,
		"enemies_killed_total": enemies_killed_total,
		"quick_hp_pill_id": quick_hp_pill_id,
		"quick_qi_pill_id": quick_qi_pill_id,
		"equipped_gear": equipped_gear,
		"gear_bag": gear_bag,
		"is_ruler_sealed": is_ruler_sealed,
		"equipped_flame_id": equipped_flame_id,
		"unlocked_flames": unlocked_flames,
		"lotus_fusion_flames": lotus_fusion_flames,
		"unlocked_skills": unlocked_skills,
		"slot_q_skill": slot_q_skill,
		"slot_e_skill": slot_e_skill,
		"slot_r_skill": slot_r_skill,
		"slot_f_skill": slot_f_skill,
		"duoc_lao_assist_unlocked": duoc_lao_assist_unlocked,
		"unlocked_companions": unlocked_companions,
		"active_companion_id": active_companion_id,
		"inventory": inventory,
		"active_quest_idx": active_quest_idx,
		"quest_progress": quest_progress,
		"all_quests_done": all_quests_done
	}
	var f := FileAccess.open(get_save_slot_path(target_slot), FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(payload, "\t"))
	save_user_settings()
	if not silent:
		EventBus.audio_sfx_requested.emit("ui_click")
	return true


func load_game(slot_idx: int = -1) -> bool:
	var target_slot: int = active_save_slot if slot_idx <= 0 else clampi(slot_idx, 1, MAX_SAVE_SLOTS)
	var p: String = get_save_slot_path(target_slot)
	if not FileAccess.file_exists(p):
		if target_slot == 1 and FileAccess.file_exists(LEGACY_SAVE_PATH):
			p = LEGACY_SAVE_PATH
		else:
			return false
	var f := FileAccess.open(p, FileAccess.READ)
	if f == null:
		return false
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return false

	active_save_slot = target_slot
	last_played_slot = target_slot
	var d: Dictionary = parsed
	is_demo_mode = bool(d.get("is_demo_mode", false))
	has_saved_player_pos = bool(d.get("has_player_pos", false))
	saved_player_pos = Vector2(float(d.get("player_pos_x", 0.0)), float(d.get("player_pos_y", 0.0)))
	playtime_sec = float(d.get("playtime_sec", 0.0))
	current_map_id = str(d.get("current_map_id", "ch01_tieu_gia"))
	realm_index = int(d.get("realm_index", 1))
	stage = int(d.get("stage", 3))
	current_exp = int(d.get("current_exp", 0))
	bonus_soul = int(d.get("bonus_soul", 0))
	gold = int(d.get("gold", 35))
	enhance_stones = int(d.get("enhance_stones", 0))
	story_flags = d.get("story_flags", {})
	opened_chests = d.get("opened_chests", {})
	if d.has("affection") and d["affection"] is Dictionary:
		affection = d["affection"]
		for ak in ["huan_nhi", "tieu_y_tien", "van_chi", "thanh_lan", "my_do_toa"]:
			if not affection.has(ak):
				affection[ak] = 0
	else:
		affection = { "huan_nhi": 20, "tieu_y_tien": 0, "van_chi": 0, "thanh_lan": 0, "my_do_toa": 0 }
	if d.has("story_relics") and d["story_relics"] is Array:
		story_relics = d["story_relics"]
	else:
		story_relics = []
	if d.has("claimed_affection_milestones") and d["claimed_affection_milestones"] is Dictionary:
		claimed_affection_milestones = d["claimed_affection_milestones"]
	else:
		claimed_affection_milestones = {}
	enemies_killed_total = int(d.get("enemies_killed_total", 0))
	quick_hp_pill_id = str(d.get("quick_hp_pill_id", "pill_ngung_huyet_tan"))
	quick_qi_pill_id = str(d.get("quick_qi_pill_id", "pill_hoi_khi_dan"))
	lotus_shield_hp = 0.0
	lotus_dmg_red_timer = 0.0
	lotus_double_herb_timer = 0.0
	player_slow_timer = 0.0
	player_slow_ratio = 0.0
	if d.has("equipped_gear") and d["equipped_gear"] is Dictionary:
		equipped_gear = d["equipped_gear"]
	if d.has("gear_bag") and d["gear_bag"] is Array:
		gear_bag = d["gear_bag"]
	is_ruler_sealed = bool(d.get("is_ruler_sealed", false))
	is_duoc_lao_active = false
	is_flame_buff_active = false
	equipped_flame_id = str(d.get("equipped_flame_id", ""))
	unlocked_flames = d.get("unlocked_flames", [])
	lotus_fusion_flames = d.get("lotus_fusion_flames", [])
	unlocked_skills = d.get("unlocked_skills", [])
	slot_q_skill = str(d.get("slot_q_skill", ""))
	slot_e_skill = str(d.get("slot_e_skill", ""))
	slot_r_skill = str(d.get("slot_r_skill", ""))
	slot_f_skill = str(d.get("slot_f_skill", ""))
	for sk_s in [slot_q_skill, slot_e_skill, slot_r_skill, slot_f_skill]:
		if sk_s != "" and not unlocked_skills.has(sk_s):
			unlocked_skills.append(sk_s)
	duoc_lao_assist_unlocked = bool(d.get("duoc_lao_assist_unlocked", false))
	unlocked_companions = d.get("unlocked_companions", [])
	active_companion_id = str(d.get("active_companion_id", ""))
	inventory = d.get("inventory", {})
	active_quest_idx = int(d.get("active_quest_idx", 0))
	quest_progress = int(d.get("quest_progress", 0))
	all_quests_done = bool(d.get("all_quests_done", false))
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
	return true
