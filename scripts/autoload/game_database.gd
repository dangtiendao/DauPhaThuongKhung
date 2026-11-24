extends Node
## Quản lý toàn bộ Cơ sở dữ liệu JSON trong thư mục res://data/
## và tự động đăng ký phím điều khiển chuẩn (InputMap) khi khởi động game.

var realms_list: Array = []
var soul_realms_list: Array = []
var suppression_rules: Dictionary = {}

var flames_by_id: Dictionary = {}
var flames_ordered: Array = []

var skills_by_id: Dictionary = {}
var items_by_id: Dictionary = {}
var recipes_list: Array = []
var enemies_by_id: Dictionary = {}
var quests_ch01: Array = [] # Alias cho toàn bộ tuyến nhiệm vụ chính (Ch01 -> Ch11) để tương thích ngược
var all_quests: Array = []
var quests_by_id: Dictionary = {}

var dialogues_by_role: Dictionary = {}
var story_effects_by_id: Dictionary = {}
var flag_effects_by_flag: Dictionary = {}
var enemy_kill_flags: Dictionary = {}

var equipment_slots: Array = []
var equipment_rarities: Dictionary = {}
var equipment_affix_pool: Array = []
var equipment_sets: Dictionary = {}
var equipment_templates: Dictionary = {}

var maps_by_id: Dictionary = {}
var maps_ordered: Array = []
var start_map_id: String = "ch01_tieu_gia"


func _init() -> void:
	_setup_default_input_map()


func _ready() -> void:
	_load_all_databases()


func _setup_default_input_map() -> void:
	_bind_key("move_up", KEY_W)
	_bind_key("move_up", KEY_UP)
	_bind_key("move_down", KEY_S)
	_bind_key("move_down", KEY_DOWN)
	_bind_key("move_left", KEY_A)
	_bind_key("move_left", KEY_LEFT)
	_bind_key("move_right", KEY_D)
	_bind_key("move_right", KEY_RIGHT)

	_bind_mouse("attack", MOUSE_BUTTON_LEFT)
	_bind_mouse("toggle_weight", MOUSE_BUTTON_RIGHT)
	_bind_key("toggle_weight", KEY_C)

	_bind_key("dash", KEY_SPACE)
	_bind_key("interact", KEY_V)
	_bind_key("interact", KEY_ENTER)

	_bind_key("skill_q", KEY_Q)
	_bind_key("skill_e", KEY_E)
	_bind_key("skill_r", KEY_R)
	_bind_key("skill_ult", KEY_F)
	_bind_key("skill_assist", KEY_T)

	_bind_key("quick_pill_1", KEY_1)
	_bind_key("quick_pill_2", KEY_2)
	_bind_key("quick_pill_3", KEY_3)

	_bind_key("panel_breakthrough", KEY_B)
	_bind_key("panel_alchemy", KEY_L)
	_bind_key("panel_flames", KEY_H)
	_bind_key("panel_equipment", KEY_I)
	_bind_key("panel_skills", KEY_K)
	_bind_key("toggle_world_map", KEY_M)
	_bind_key("toggle_companion", KEY_G)


func _bind_key(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventKey and existing.physical_keycode == keycode:
			return
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action_name, ev)


func _bind_mouse(action_name: String, button: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventMouseButton and existing.button_index == button:
			return
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action_name, ev)


func _load_json_dict(res_path: String, silent_if_missing: bool = false) -> Dictionary:
	if not FileAccess.file_exists(res_path):
		if not silent_if_missing:
			push_warning("Không tìm thấy file dữ liệu: " + res_path)
		return {}
	var f := FileAccess.open(res_path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}


func _merge_quest_pack(q_data: Dictionary) -> void:
	if q_data.is_empty():
		return
	var q_arr: Array = q_data.get("quests", [])
	for q_item in q_arr:
		if q_item is Dictionary:
			var qid: String = str(q_item.get("id", ""))
			if qid != "" and not quests_by_id.has(qid):
				all_quests.append(q_item)
				quests_by_id[qid] = q_item
	var fe: Dictionary = q_data.get("flag_effects", {})
	for fk in fe.keys():
		flag_effects_by_flag[str(fk)] = fe[fk]
	var ekf: Dictionary = q_data.get("enemy_kill_flags", {})
	for ek in ekf.keys():
		enemy_kill_flags[str(ek)] = ekf[ek]


func _merge_dialogue_pack(d_data: Dictionary) -> void:
	if d_data.is_empty():
		return
	var dlgs: Dictionary = d_data.get("dialogues", {})
	for rk in dlgs.keys():
		dialogues_by_role[str(rk)] = dlgs[rk]
	var effs: Dictionary = d_data.get("effects", {})
	for ek in effs.keys():
		story_effects_by_id[str(ek)] = effs[ek]


func _merge_map_pack(m_data: Dictionary, fallback_order: Array = []) -> void:
	if m_data.is_empty():
		return
	var m_dict: Dictionary = m_data.get("maps", {})
	for mk in m_dict.keys():
		maps_by_id[str(mk)] = m_dict[mk]
	var ord_arr: Array = m_data.get("map_order", [])
	if ord_arr.is_empty():
		ord_arr = fallback_order if not fallback_order.is_empty() else m_dict.keys()
	for mid in ord_arr:
		var mid_s: String = str(mid)
		if maps_by_id.has(mid_s) and not maps_ordered.has(mid_s):
			maps_ordered.append(mid_s)
	for mk in m_dict.keys():
		var mk_s: String = str(mk)
		if not maps_ordered.has(mk_s):
			maps_ordered.append(mk_s)


func _load_all_databases() -> void:
	var r_data: Dictionary = _load_json_dict("res://data/realms.json")
	realms_list = r_data.get("major_realms", [])
	soul_realms_list = r_data.get("soul_realms", [])
	suppression_rules = r_data.get("suppression_rules", {})

	var f_data: Dictionary = _load_json_dict("res://data/flames.json")
	flames_ordered = f_data.get("flames", [])
	flames_by_id.clear()
	for entry in flames_ordered:
		if entry is Dictionary:
			var fid: String = str(entry.get("id", ""))
			flames_by_id[fid] = entry

	var s_data: Dictionary = _load_json_dict("res://data/skills.json")
	skills_by_id.clear()
	var s_arr: Array = s_data.get("skills", [])
	for sk in s_arr:
		if sk is Dictionary:
			skills_by_id[str(sk.get("id", ""))] = sk

	var a_data: Dictionary = _load_json_dict("res://data/alchemy_items.json")
	items_by_id = a_data.get("items", {})
	recipes_list = a_data.get("recipes", [])

	var e_data: Dictionary = _load_json_dict("res://data/enemies.json")
	enemies_by_id = e_data.get("enemies", {}).duplicate(true)

	# Nạp tuyến nhiệm vụ, kịch bản đối thoại & bản đồ theo từng Chương (Data-Driven Story Engine!)
	all_quests.clear()
	quests_by_id.clear()
	dialogues_by_role.clear()
	story_effects_by_id.clear()
	flag_effects_by_flag.clear()
	enemy_kill_flags.clear()
	maps_by_id.clear()
	maps_ordered.clear()

	_merge_quest_pack(_load_json_dict("res://data/quests_ch01.json"))
	_merge_dialogue_pack(_load_json_dict("res://data/dialogues_ch01.json", true))

	var eq_data: Dictionary = _load_json_dict("res://data/equipment.json")
	equipment_slots = eq_data.get("slots", [])
	equipment_rarities = eq_data.get("rarities", {})
	equipment_affix_pool = eq_data.get("affix_pool", [])
	equipment_sets = eq_data.get("sets", {})
	equipment_templates = eq_data.get("templates", {})

	var m_data: Dictionary = _load_json_dict("res://data/maps.json")
	start_map_id = str(m_data.get("start_map", "ch01_tieu_gia"))
	var base_map_order: Array = [
		"ch01_tieu_gia", "ch01_hau_son", "ch01_o_than_thanh",
		"ch02_ma_thu_son_mach", "ch02_huyen_nhai_dong", "ch02_noi_vi_su_vuong", "ch02_thac_nuoc_muc_xa",
		"ch03_thach_mac_thanh", "ch03_dia_huyet_dung_nham", "ch03_thanh_thanh_xa_nhan", "ch03_oc_dao_diem_le"
	]
	_merge_map_pack(m_data, base_map_order)

	# Tự động nạp mở rộng từng Chương (ch02 -> ch11): chỉ cần thêm file JSON chương mới!
	for ch_num in range(2, 12):
		var suffix: String = "ch%02d" % ch_num
		_merge_quest_pack(_load_json_dict("res://data/quests_%s.json" % suffix, true))
		_merge_dialogue_pack(_load_json_dict("res://data/dialogues_%s.json" % suffix, true))
		_merge_map_pack(_load_json_dict("res://data/maps_%s.json" % suffix, true))
		var ce_data: Dictionary = _load_json_dict("res://data/enemies_%s.json" % suffix, true)
		if not ce_data.is_empty():
			var ce_map: Dictionary = ce_data.get("enemies", {})
			for ek in ce_map.keys():
				enemies_by_id[str(ek)] = ce_map[ek]

	quests_ch01 = all_quests


func get_realm_def(realm_idx: int) -> Dictionary:
	for r in realms_list:
		if r is Dictionary and int(r.get("index", 0)) == realm_idx:
			return r
	if realms_list.size() > 0 and realms_list[0] is Dictionary:
		return realms_list[0]
	return {}


func get_flame_def(flame_id: String) -> Dictionary:
	if flames_by_id.has(flame_id):
		return flames_by_id[flame_id]
	return flames_by_id.get("pham_hoa", {})


func get_skill_def(skill_id: String) -> Dictionary:
	return skills_by_id.get(skill_id, {})


func get_item_def(item_id: String) -> Dictionary:
	return items_by_id.get(item_id, {})


func get_enemy_def(enemy_id: String) -> Dictionary:
	return enemies_by_id.get(enemy_id, {})


func get_equipment_template(template_id: String) -> Dictionary:
	return equipment_templates.get(template_id, {})


func get_map_def(map_id: String) -> Dictionary:
	return maps_by_id.get(map_id, {})


func get_quest_def(quest_id: String) -> Dictionary:
	return quests_by_id.get(quest_id, {})


func get_quest_index(quest_id: String) -> int:
	for i in range(all_quests.size()):
		var q = all_quests[i]
		if q is Dictionary and str(q.get("id", "")) == quest_id:
			return i
	return -1


func get_dialogue_def(role_str: String) -> Dictionary:
	return dialogues_by_role.get(role_str, {})


func get_story_effect(effect_id: String) -> Dictionary:
	return story_effects_by_id.get(effect_id, {})


func get_flag_effect(flag_name: String) -> Dictionary:
	return flag_effects_by_flag.get(flag_name, {})


func get_enemy_kill_rule(enemy_id: String) -> Dictionary:
	return enemy_kill_flags.get(enemy_id, {})
