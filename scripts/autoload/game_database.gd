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
var quests_ch01: Array = []

var equipment_slots: Array = []
var equipment_rarities: Dictionary = {}
var equipment_affix_pool: Array = []
var equipment_sets: Dictionary = {}
var equipment_templates: Dictionary = {}

var maps_by_id: Dictionary = {}
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


func _load_json_dict(res_path: String) -> Dictionary:
	if not FileAccess.file_exists(res_path):
		push_warning("Không tìm thấy file dữ liệu: " + res_path)
		return {}
	var f := FileAccess.open(res_path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}


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
	enemies_by_id = e_data.get("enemies", {})

	var q_data: Dictionary = _load_json_dict("res://data/quests_ch01.json")
	quests_ch01 = q_data.get("quests", [])

	var eq_data: Dictionary = _load_json_dict("res://data/equipment.json")
	equipment_slots = eq_data.get("slots", [])
	equipment_rarities = eq_data.get("rarities", {})
	equipment_affix_pool = eq_data.get("affix_pool", [])
	equipment_sets = eq_data.get("sets", {})
	equipment_templates = eq_data.get("templates", {})

	var m_data: Dictionary = _load_json_dict("res://data/maps.json")
	maps_by_id = m_data.get("maps", {})
	start_map_id = str(m_data.get("start_map", "ch01_tieu_gia"))


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
