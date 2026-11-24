extends Node2D
## Hệ thống Quản lý Đa Bản Đồ (11 Bản Đồ Quyển I: Chương 01 -> Chương 03 Đầy Đủ):
## - Chương 01 (3 map): Quảng Trường Tiêu Gia, Rừng Trúc Hậu Sơn, Phố Chợ Ô Thản Thành & Biệt Viện Gia Liệt Gia.
## - Chương 02 (4 map): Thanh Sơn Trấn & Ngoại Vi, Huyền Nhai Sơn Động (3 Thạch Thất), Bờ Suối Trăng Bạc & Hang Sư Vương, Thác Nước Nghìn Trượng & Thung Lũng U Lan.
## - Chương 03 (4 map): Thạch Mạc Thành & Mạc Thiết Đoàn, Địa Huyệt Sông Dung Nham, Thánh Thành Xà Nhân & Thánh Trì, Ốc Đảo Diêm Lệ.
## - Tương tác Ma Thạch Bi [V], 15 NPC cốt truyện & kỳ ngộ ẩn, Đối thoại Chọn Nhánh tăng Hảo Cảm Hồng Nhan, 14 Bảo Rương & 21 mốc Nhiệm Vụ!

const ENEMY_SCENE_PATH: String = "res://scenes/entities/enemy_base.tscn"
const COMPANION_SCENE_PATH: String = "res://scenes/entities/companion.tscn"

var current_map_id: String = ""
var current_map_bgm: String = "bgm_peaceful"
var current_is_forest: bool = false
var map_size: Vector2 = Vector2(1600, 1024)
var map_rect: Rect2 = Rect2(64, 64, 1472, 896)

var zone_draw_specs: Array = []
var spawn_slots: Array = []
var current_npc_defs: Array = []
var npc_entries: Array = []
var portal_entries: Array = []
var chest_entries: Array = []
var stele_positions: Array = []

var lantern_lights: Array = []
var bamboo_sprites: Array = []
var active_companion_node: Node2D = null
var interact_cooldown: float = 0.0

var map_backdrop_root: Node2D
var map_overlay_root: Node2D

@onready var entities_root: Node2D = $Entities
@onready var floating_layer: Node2D = $FloatingTexts
@onready var player_node: CharacterBody2D = $Entities/Player


func _ready() -> void:
	add_to_group("world_stage")

	map_backdrop_root = Node2D.new()
	map_backdrop_root.name = "MapBackdrop"
	map_backdrop_root.z_index = -10
	add_child(map_backdrop_root)
	move_child(map_backdrop_root, 0)

	map_overlay_root = Node2D.new()
	map_overlay_root.name = "MapOverlay"
	map_overlay_root.z_index = 2
	add_child(map_overlay_root)

	EventBus.floating_text_requested.connect(_spawn_floating_text)
	EventBus.story_flag_changed.connect(_on_story_flag_changed)
	EventBus.quest_updated.connect(_refresh_npc_quest_markers)
	EventBus.companion_changed.connect(_on_companion_changed)

	var init_spawn: Vector2 = Vector2.ZERO
	if PlayerData.has_saved_player_pos and PlayerData.saved_player_pos != Vector2.ZERO:
		init_spawn = PlayerData.saved_player_pos
		PlayerData.has_saved_player_pos = false
	load_map(PlayerData.current_map_id, init_spawn, false)
	call_deferred("_announce_initial_quest")


func _announce_initial_quest() -> void:
	if PlayerData.is_demo_mode:
		EventBus.banter_triggered.emit("CHẾ ĐỘ DEMO FULL: Mở toàn bộ %d Map (bấm [M] Dịch Chuyển Nhanh), Đấu Kỹ, [F] Phật Nộ Hỏa Liên 4 Hỏa, 28 Dị Hỏa [H] & 3 Đồng Hành [G]!" % GameDatabase.maps_ordered.size())
		EventBus.quest_updated.emit()
	else:
		PlayerData.trigger_initial_quest_banter()


func restore_map_bgm() -> void:
	EventBus.bgm_requested.emit(current_map_bgm)


func load_map(map_id: String, custom_spawn: Vector2 = Vector2.ZERO, should_autosave: bool = true) -> void:
	var m_def: Dictionary = GameDatabase.get_map_def(map_id)
	if m_def.is_empty():
		map_id = GameDatabase.start_map_id
		m_def = GameDatabase.get_map_def(map_id)
	if m_def.is_empty():
		return

	current_map_id = map_id
	PlayerData.current_map_id = map_id
	current_map_bgm = str(m_def.get("bgm", "bgm_peaceful"))
	current_is_forest = str(m_def.get("base_tile", "")).find("bamboo_grass") != -1
	interact_cooldown = 0.25

	var sz_arr: Array = m_def.get("size", [1600, 1024])
	map_size = Vector2(float(sz_arr[0]), float(sz_arr[1]))
	map_rect = Rect2(64.0, 64.0, map_size.x - 128.0, map_size.y - 128.0)

	_clear_current_map_nodes()
	_build_tiled_ground(m_def)
	_build_atmosphere_and_boundaries(m_def)
	_build_signs(m_def)
	_build_props(m_def)
	_build_chests(m_def)
	_build_portals(m_def)

	current_npc_defs = m_def.get("npcs", [])
	_sync_conditional_npcs()
	_setup_spawns(m_def)

	var spawn_pt: Vector2 = custom_spawn
	if spawn_pt == Vector2.ZERO:
		var ds: Array = m_def.get("default_spawn", [340, 520])
		spawn_pt = Vector2(float(ds[0]), float(ds[1]))

	if player_node != null:
		player_node.global_position = spawn_pt
		if player_node.has_method("set_camera_limits"):
			player_node.set_camera_limits(int(map_size.x), int(map_size.y))
		var cam_node: Camera2D = player_node.get_node_or_null("Camera2D") as Camera2D
		if cam_node != null:
			cam_node.reset_smoothing()

	_sync_active_companion(spawn_pt)
	EventBus.boss_status_updated.emit("", "", 0.0, 1.0, 1, false)
	EventBus.bgm_requested.emit(current_map_bgm)

	var ch_str: String = str(m_def.get("chapter", "Chương 01"))
	var nm_str: String = str(m_def.get("name", map_id))
	EventBus.map_changed.emit(current_map_id, "%s — %s" % [ch_str, nm_str])
	if should_autosave:
		PlayerData.trigger_auto_save("chuyển bản đồ", true)
	queue_redraw()


func _clear_current_map_nodes() -> void:
	for ch in map_backdrop_root.get_children():
		map_backdrop_root.remove_child(ch)
		ch.queue_free()

	for ch in map_overlay_root.get_children():
		map_overlay_root.remove_child(ch)
		ch.queue_free()

	var to_remove: Array = []
	for ch in entities_root.get_children():
		if ch != player_node:
			to_remove.append(ch)
	for ch in to_remove:
		entities_root.remove_child(ch)
		ch.queue_free()

	active_companion_node = null
	zone_draw_specs.clear()
	spawn_slots.clear()
	npc_entries.clear()
	portal_entries.clear()
	chest_entries.clear()
	stele_positions.clear()
	lantern_lights.clear()
	bamboo_sprites.clear()


func _on_companion_changed(_comp_id: String) -> void:
	var p_pos: Vector2 = player_node.global_position if player_node != null else Vector2(340, 520)
	_sync_active_companion(p_pos)


func _sync_active_companion(anchor_pos: Vector2) -> void:
	if active_companion_node != null and is_instance_valid(active_companion_node):
		if active_companion_node.get_parent() != null:
			active_companion_node.get_parent().remove_child(active_companion_node)
		active_companion_node.queue_free()
		active_companion_node = null

	var cid: String = PlayerData.active_companion_id
	if cid == "":
		return
	var packed: PackedScene = load(COMPANION_SCENE_PATH)
	if packed == null:
		return
	var comp: Node2D = packed.instantiate() as Node2D
	comp.global_position = anchor_pos + Vector2(-58, -16)
	entities_root.add_child(comp)
	if comp.has_method("configure_companion"):
		comp.configure_companion(cid)
	active_companion_node = comp


func _build_tiled_ground(m_def: Dictionary) -> void:
	var bg_void := ColorRect.new()
	bg_void.color = Color("#0A0F14")
	bg_void.position = Vector2(-500, -500)
	bg_void.size = map_size + Vector2(1000, 1000)
	bg_void.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_backdrop_root.add_child(bg_void)

	var base_tile: String = str(m_def.get("base_tile", "res://assets/sprites/tiles/courtyard_stone.png"))
	_add_tiled_rect(map_backdrop_root, map_rect, base_tile)

	var zones: Array = m_def.get("zones", [])
	for z in zones:
		if not (z is Dictionary):
			continue
		var z_dict: Dictionary = z
		var r_arr: Array = z_dict.get("rect", [0, 0, 128, 128])
		var rc := Rect2(float(r_arr[0]), float(r_arr[1]), float(r_arr[2]), float(r_arr[3]))
		var tile_p: String = str(z_dict.get("tile", ""))
		if tile_p != "":
			_add_tiled_rect(map_backdrop_root, rc, tile_p)
		zone_draw_specs.append({
			"rect": rc,
			"border_hex": str(z_dict.get("border_hex", "")),
			"arena_circle": bool(z_dict.get("arena_circle", false))
		})


func _add_tiled_rect(parent_node: Node2D, rect_area: Rect2, tex_path: String) -> void:
	var tex: Texture2D = load(tex_path)
	if tex == null:
		return
	var tr := TextureRect.new()
	tr.texture = tex
	tr.position = rect_area.position
	tr.size = rect_area.size
	tr.stretch_mode = TextureRect.STRETCH_TILE
	tr.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent_node.add_child(tr)


func _build_atmosphere_and_boundaries(m_def: Dictionary) -> void:
	var mod := CanvasModulate.new()
	mod.color = Color(str(m_def.get("ambient_hex", "#b2c0dc")))
	map_overlay_root.add_child(mod)

	if current_is_forest or current_map_id == "ch02_huyen_nhai_dong":
		var fireflies := CPUParticles2D.new()
		fireflies.position = map_size * 0.5
		fireflies.emitting = true
		fireflies.amount = 48
		fireflies.lifetime = 5.0
		fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		fireflies.emission_rect_extents = Vector2(map_size.x * 0.45, map_size.y * 0.45)
		fireflies.direction = Vector2(0.35, -1.0)
		fireflies.spread = 80.0
		fireflies.gravity = Vector2(0, -5)
		fireflies.initial_velocity_min = 8.0
		fireflies.initial_velocity_max = 22.0
		fireflies.scale_amount_min = 2.5
		fireflies.scale_amount_max = 4.5
		fireflies.color = Color("#70F5DF") if current_map_id == "ch02_huyen_nhai_dong" else (Color("#E0AAFF") if current_map_id == "ch02_noi_vi_su_vuong" else Color("#A8F5B0"))
		map_overlay_root.add_child(fireflies)

	var wall_body := StaticBody2D.new()
	map_overlay_root.add_child(wall_body)
	var thickness: float = 64.0
	var rects: Array = [
		Rect2(map_rect.position.x - thickness, map_rect.position.y - thickness, map_rect.size.x + thickness * 2.0, thickness),
		Rect2(map_rect.position.x - thickness, map_rect.end.y, map_rect.size.x + thickness * 2.0, thickness),
		Rect2(map_rect.position.x - thickness, map_rect.position.y, thickness, map_rect.size.y),
		Rect2(map_rect.end.x, map_rect.position.y, thickness, map_rect.size.y)
	]
	for r in rects:
		var rc: Rect2 = r
		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rc.size
		col.shape = shape
		col.position = rc.position + rc.size * 0.5
		wall_body.add_child(col)


func _build_signs(m_def: Dictionary) -> void:
	var signs: Array = m_def.get("signs", [])
	for s in signs:
		if not (s is Dictionary):
			continue
		var sd: Dictionary = s
		var p_arr: Array = sd.get("pos", [200, 200])
		var lbl := Label.new()
		lbl.position = Vector2(float(p_arr[0]), float(p_arr[1]))
		lbl.text = str(sd.get("text", ""))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.add_theme_color_override("font_color", Color(str(sd.get("color", "#FFE599"))))
		lbl.add_theme_color_override("font_outline_color", Color("#0B090A"))
		lbl.add_theme_constant_override("outline_size", 5)
		map_overlay_root.add_child(lbl)


func _add_solid_collider(parent_nd: Node2D, box_size: Vector2, offset_pos: Vector2) -> void:
	var sb := StaticBody2D.new()
	var col := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = box_size
	col.shape = sh
	col.position = offset_pos
	sb.add_child(col)
	parent_nd.add_child(sb)


func _build_props(m_def: Dictionary) -> void:
	var light_tex: Texture2D = load("res://assets/sprites/vfx/light_radial_128.png")
	var lantern_tex: Texture2D = load("res://assets/sprites/props/stone_lantern.png")
	var bamboo_tex: Texture2D = load("res://assets/sprites/props/bamboo_cluster.png")
	var stele_tex: Texture2D = load("res://assets/sprites/props/testing_stele.png")
	var gate_tex: Texture2D = load("res://assets/sprites/props/grand_hall_gate.png")
	var boulder_tex: Texture2D = load("res://assets/sprites/props/mountain_boulder.png")
	var pine_tex: Texture2D = load("res://assets/sprites/props/ancient_pine.png")

	var props_arr: Array = m_def.get("props", [])
	for pr in props_arr:
		if not (pr is Dictionary):
			continue
		var pd: Dictionary = pr
		var ptype: String = str(pd.get("type", ""))
		var p_arr: Array = pd.get("pos", [200, 200])
		var pos_v := Vector2(float(p_arr[0]), float(p_arr[1]))

		if ptype == "stele":
			stele_positions.append(pos_v)
			var stele := Sprite2D.new()
			stele.texture = stele_tex
			stele.position = pos_v
			stele.offset = Vector2(0, -64)
			entities_root.add_child(stele)
			_add_solid_collider(stele, Vector2(46, 26), Vector2(0, -10))
			var stele_light := PointLight2D.new()
			stele_light.texture = light_tex
			stele_light.texture_scale = 3.0
			stele_light.energy = 1.05
			stele_light.color = Color("#FFD166")
			stele_light.position = Vector2(0, -64)
			stele.add_child(stele_light)

		elif ptype == "gate":
			var gate := Sprite2D.new()
			gate.texture = gate_tex
			gate.position = pos_v
			gate.offset = Vector2(0, -96)
			entities_root.add_child(gate)
			_add_solid_collider(gate, Vector2(36, 30), Vector2(-66, -12))
			_add_solid_collider(gate, Vector2(36, 30), Vector2(66, -12))

		elif ptype == "boulder":
			var rock := Sprite2D.new()
			rock.texture = boulder_tex
			rock.position = pos_v
			rock.offset = Vector2(0, -54)
			entities_root.add_child(rock)
			_add_solid_collider(rock, Vector2(88, 36), Vector2(0, -16))

		elif ptype == "pine":
			var tree := Sprite2D.new()
			tree.texture = pine_tex
			tree.position = pos_v
			tree.offset = Vector2(0, -82)
			entities_root.add_child(tree)
			_add_solid_collider(tree, Vector2(42, 26), Vector2(0, -12))

		elif ptype == "lantern":
			var sp := Sprite2D.new()
			sp.texture = lantern_tex
			sp.position = pos_v
			sp.offset = Vector2(0, -48)
			entities_root.add_child(sp)
			var pl := PointLight2D.new()
			pl.texture = light_tex
			pl.texture_scale = 3.1
			pl.energy = 1.18
			pl.color = Color("#FFA94D")
			pl.position = Vector2(0, -62)
			sp.add_child(pl)
			lantern_lights.append(pl)

		elif ptype == "bamboo":
			var bsp := Sprite2D.new()
			bsp.texture = bamboo_tex
			bsp.position = pos_v
			bsp.offset = Vector2(0, -64)
			entities_root.add_child(bsp)
			bamboo_sprites.append(bsp)


func _build_chests(m_def: Dictionary) -> void:
	var closed_tex: Texture2D = load("res://assets/sprites/props/chest_closed.png")
	var open_tex: Texture2D = load("res://assets/sprites/props/chest_open.png")
	var light_tex: Texture2D = load("res://assets/sprites/vfx/light_radial_128.png")

	var chests_arr: Array = m_def.get("chests", [])
	for ch in chests_arr:
		if not (ch is Dictionary):
			continue
		var cd: Dictionary = ch
		var cid: String = str(cd.get("id", ""))
		var pos_arr: Array = cd.get("pos", [300, 300])
		var pos_v := Vector2(float(pos_arr[0]), float(pos_arr[1]))
		var is_opened: bool = PlayerData.is_chest_opened(cid)

		var root_ch := Node2D.new()
		root_ch.position = pos_v
		entities_root.add_child(root_ch)

		var sp := Sprite2D.new()
		sp.texture = open_tex if is_opened else closed_tex
		sp.position = Vector2(0, -28)
		root_ch.add_child(sp)

		var glow := PointLight2D.new()
		glow.texture = light_tex
		glow.texture_scale = 2.0
		glow.energy = 0.25 if is_opened else 1.15
		glow.color = Color("#FFD166")
		glow.position = Vector2(0, -24)
		root_ch.add_child(glow)

		var lbl := Label.new()
		lbl.text = str(cd.get("name", "Bảo Rương"))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(260, 0)
		lbl.position = Vector2(-130, -76)
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color("#ADB5BD") if is_opened else Color("#FFD166"))
		lbl.add_theme_color_override("font_outline_color", Color("#05060A"))
		lbl.add_theme_constant_override("outline_size", 4)
		root_ch.add_child(lbl)

		var prompt := Label.new()
		prompt.text = "[V] Mở Bảo Rương"
		prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prompt.custom_minimum_size = Vector2(180, 0)
		prompt.position = Vector2(-90, 12)
		prompt.add_theme_font_size_override("font_size", 13)
		prompt.add_theme_color_override("font_color", Color("#FFD166"))
		prompt.add_theme_color_override("font_outline_color", Color("#05060A"))
		prompt.add_theme_constant_override("outline_size", 4)
		prompt.visible = false
		root_ch.add_child(prompt)

		chest_entries.append({
			"id": cid,
			"def": cd,
			"pos": pos_v,
			"opened": is_opened,
			"sprite_node": sp,
			"glow_node": glow,
			"label_node": lbl,
			"prompt_node": prompt
		})


func _open_secret_chest(c_entry: Dictionary) -> void:
	if bool(c_entry.get("opened", false)):
		return
	var cid: String = str(c_entry.get("id", ""))
	var cd: Dictionary = c_entry.get("def", {})
	var pos_v: Vector2 = c_entry.get("pos", Vector2.ZERO)

	c_entry["opened"] = true
	PlayerData.mark_chest_opened(cid)

	var sp: Sprite2D = c_entry.get("sprite_node", null) as Sprite2D
	if sp != null and is_instance_valid(sp):
		sp.texture = load("res://assets/sprites/props/chest_open.png")
	var glow: PointLight2D = c_entry.get("glow_node", null) as PointLight2D
	if glow != null and is_instance_valid(glow):
		glow.energy = 0.25
	var lbl: Label = c_entry.get("label_node", null) as Label
	if lbl != null and is_instance_valid(lbl):
		lbl.add_theme_color_override("font_color", Color("#ADB5BD"))
	var pr: Label = c_entry.get("prompt_node", null) as Label
	if pr != null and is_instance_valid(pr):
		pr.visible = false

	EventBus.audio_sfx_requested.emit("chest_open")

	var reward_parts: Array = []
	var g_amt: int = int(cd.get("gold", 50))
	if g_amt > 0:
		PlayerData.gold += g_amt
		reward_parts.append("+%d Kim Tệ" % g_amt)
	var st_amt: int = int(cd.get("stones", 0))
	if st_amt > 0:
		PlayerData.enhance_stones += st_amt
		reward_parts.append("+%d Đá CH" % st_amt)

	var g_tpl: String = str(cd.get("gear_template", ""))
	if g_tpl != "":
		var g_rar: String = str(cd.get("gear_rarity", "linh"))
		var inst: Dictionary = EquipmentSystem.roll_equipment_instance(g_tpl, g_rar)
		if not inst.is_empty():
			PlayerData.add_gear_to_bag(inst)
			# Tự động đeo Tử Vân Dực nếu ô cánh đang trống!
			if g_tpl == "wing_tu_van_duc" and not PlayerData.has_tu_van_duc_equipped():
				PlayerData.equip_gear_from_bag(str(inst.get("uid", "")))
			reward_parts.append("[%s]" % EquipmentSystem.get_item_display_name(inst))

	var items_d: Dictionary = cd.get("items", {})
	for ik in items_d.keys():
		var cnt: int = int(items_d[ik])
		PlayerData.add_item(str(ik), cnt)
		var idef: Dictionary = GameDatabase.get_item_def(str(ik))
		reward_parts.append("%s x%d" % [str(idef.get("name", ik)), cnt])

	var sk_id: String = str(cd.get("skill_unlock", ""))
	if sk_id != "":
		PlayerData.unlock_skill(sk_id, "")
		var sdef: Dictionary = GameDatabase.get_skill_def(sk_id)
		reward_parts.append("ĐẤU KỸ: [%s]" % str(sdef.get("name", sk_id)))

	var aff_npc: String = str(cd.get("affection_npc", ""))
	var aff_gain: int = int(cd.get("affection_gain", 0))
	if aff_npc != "" and aff_gain > 0:
		PlayerData.add_affection(aff_npc, aff_gain)
		reward_parts.append("+%d Hảo Cảm Tiểu Y Tiên" % aff_gain)

	var sf: String = str(cd.get("story_flag", ""))
	if sf != "":
		PlayerData.set_story_flag(sf)

	EventBus.stats_changed.emit()
	EventBus.floating_text_requested.emit(pos_v + Vector2(0, -68), "MỞ BẢO RƯƠNG THÀNH CÔNG!", Color("#FFD166"))
	if sf == "":
		EventBus.banter_triggered.emit("KỲ NGỘ [%s]: Nhận %s!" % [str(cd.get("name", "Bảo Rương")), " | ".join(reward_parts)])


func _build_portals(m_def: Dictionary) -> void:
	var portals_arr: Array = m_def.get("portals", [])
	for pt in portals_arr:
		if not (pt is Dictionary):
			continue
		var ptd: Dictionary = pt
		var pos_arr: Array = ptd.get("pos", [400, 120])
		var pos_v := Vector2(float(pos_arr[0]), float(pos_arr[1]))
		var tsp_arr: Array = ptd.get("target_spawn", [340, 520])
		var target_sp := Vector2(float(tsp_arr[0]), float(tsp_arr[1]))

		var lbl := Label.new()
		lbl.text = str(ptd.get("label", "Cổng Dịch Chuyển"))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(360, 0)
		var lbl_x: float = clampf(pos_v.x - 180.0, map_rect.position.x + 8.0, map_rect.end.x - 368.0)
		lbl.position = Vector2(lbl_x, pos_v.y - 64.0)
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color("#70D6FF"))
		lbl.add_theme_color_override("font_outline_color", Color("#05060A"))
		lbl.add_theme_constant_override("outline_size", 4)
		map_overlay_root.add_child(lbl)

		var prompt := Label.new()
		prompt.text = "[V] Đi qua cổng"
		prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prompt.custom_minimum_size = Vector2(220, 0)
		prompt.position = pos_v + Vector2(-110, 32)
		prompt.add_theme_font_size_override("font_size", 14)
		prompt.add_theme_color_override("font_color", Color("#FFD166"))
		prompt.add_theme_color_override("font_outline_color", Color("#05060A"))
		prompt.add_theme_constant_override("outline_size", 4)
		prompt.visible = false
		map_overlay_root.add_child(prompt)

		portal_entries.append({
			"id": str(ptd.get("id", "")),
			"label": str(ptd.get("label", "")),
			"pos": pos_v,
			"target_map": str(ptd.get("target_map", "")),
			"target_spawn": target_sp,
			"require_flag": str(ptd.get("require_flag", "")),
			"locked_hint": str(ptd.get("locked_hint", "Cổng này hiện đang bị phong tỏa bởi cốt truyện!")),
			"label_node": lbl,
			"prompt_node": prompt
		})


func _sync_conditional_npcs() -> void:
	var kept_entries: Array = []
	for entry in npc_entries:
		var hide_f: String = str(entry.get("hide_if_flag", ""))
		if hide_f != "" and PlayerData.has_flag(hide_f):
			var nd: Node2D = entry.get("node", null) as Node2D
			if nd != null and is_instance_valid(nd):
				if nd.get_parent() != null:
					nd.get_parent().remove_child(nd)
				nd.queue_free()
		else:
			kept_entries.append(entry)
	npc_entries = kept_entries

	var light_tex: Texture2D = load("res://assets/sprites/vfx/light_radial_128.png")
	for ndef in current_npc_defs:
		if not (ndef is Dictionary):
			continue
		var d: Dictionary = ndef
		var nid: String = str(d.get("id", ""))
		var hide_f: String = str(d.get("hide_if_flag", ""))
		var req_f: String = str(d.get("require_flag", ""))
		if hide_f != "" and PlayerData.has_flag(hide_f):
			continue
		if req_f != "" and not PlayerData.has_flag(req_f):
			continue
		if _has_spawned_npc(nid):
			continue

		var pos_arr: Array = d.get("pos", [440, 440])
		var pos_v := Vector2(float(pos_arr[0]), float(pos_arr[1]))
		var role_str: String = str(d.get("role", ""))
		var sprite_path: String = str(d.get("sprite", ""))

		var npc_root := Node2D.new()
		npc_root.name = "NPC_" + nid
		npc_root.position = pos_v
		entities_root.add_child(npc_root)

		var shadow := Polygon2D.new()
		var pts := PackedVector2Array()
		for k in range(18):
			var ang: float = float(k) * TAU / 18.0
			pts.append(Vector2(cos(ang) * 26.0, 10.0 + sin(ang) * 10.5))
		shadow.polygon = pts
		shadow.color = Color(0.03, 0.02, 0.07, 0.48)
		npc_root.add_child(shadow)

		var sp := Sprite2D.new()
		var tex: Texture2D = load(sprite_path)
		var off_y: float = -46.0
		if tex != null:
			sp.texture = tex
			off_y = -float(tex.get_height()) * 0.46
		sp.centered = true
		sp.offset = Vector2(0.0, off_y)
		sp.position = Vector2(0.0, 8.0)
		var tint_hex: String = str(d.get("tint_hex", ""))
		if tint_hex != "":
			sp.modulate = Color(tint_hex)
		elif role_str == "story_duoc_lao" or role_str == "story_devour_thanh_lien":
			sp.modulate = Color(0.86, 0.96, 1.08, 0.92)
		elif role_str == "secret_lang_anh":
			sp.modulate = Color(0.88, 0.85, 0.96, 0.84)
		npc_root.add_child(sp)

		var glow := PointLight2D.new()
		glow.texture = light_tex
		glow.texture_scale = 2.4
		var is_floating: bool = bool(d.get("float_anim", false))
		glow.energy = 1.08 if (is_floating or role_str == "story_duoc_lao" or role_str == "story_van_chi" or role_str == "story_my_do_toa" or role_str == "story_devour_thanh_lien") else 0.72
		var glow_hex: String = str(d.get("glow_hex", ""))
		if glow_hex != "":
			glow.color = Color(glow_hex)
		elif role_str == "story_duoc_lao" or role_str == "story_hai_ba_dong":
			glow.color = Color("#70D6FF")
		elif role_str == "story_van_chi" or role_str == "story_thanh_lan" or role_str == "story_devour_thanh_lien":
			glow.color = Color("#2EC4B6")
		elif role_str == "secret_lang_anh" or role_str == "story_my_do_toa":
			glow.color = Color("#C77DFF")
		elif role_str == "story_thai_lan_pet":
			glow.color = Color("#72EFDD")
		else:
			glow.color = Color("#FFE599")
		glow.position = Vector2(0, -36)
		npc_root.add_child(glow)

		var name_lbl := Label.new()
		name_lbl.text = "%s\n<%s>" % [str(d.get("name", nid)), str(d.get("title", ""))]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.custom_minimum_size = Vector2(280, 0)
		name_lbl.position = Vector2(-140, -118)
		name_lbl.add_theme_font_size_override("font_size", 13)
		var nm_col: Color = Color(str(d.get("name_hex", "#FFE599"))) if str(d.get("name_hex", "")) != "" else Color("#FFE599")
		if str(d.get("name_hex", "")) == "":
			if role_str == "story_duoc_lao":
				nm_col = Color("#A8DADC")
			elif role_str == "story_van_chi":
				nm_col = Color("#80ED99")
			elif role_str == "secret_lang_anh":
				nm_col = Color("#C77DFF")
		name_lbl.add_theme_color_override("font_color", nm_col)
		name_lbl.add_theme_color_override("font_outline_color", Color("#07060B"))
		name_lbl.add_theme_constant_override("outline_size", 4)
		npc_root.add_child(name_lbl)

		var marker_lbl := Label.new()
		marker_lbl.text = "!"
		marker_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		marker_lbl.custom_minimum_size = Vector2(40, 0)
		marker_lbl.position = Vector2(-20, -148)
		marker_lbl.add_theme_font_size_override("font_size", 24)
		marker_lbl.add_theme_color_override("font_color", Color("#FFD166"))
		marker_lbl.add_theme_color_override("font_outline_color", Color("#07060B"))
		marker_lbl.add_theme_constant_override("outline_size", 5)
		marker_lbl.visible = false
		npc_root.add_child(marker_lbl)

		var prompt_lbl := Label.new()
		var custom_prompt: String = str(d.get("prompt_text", ""))
		prompt_lbl.text = custom_prompt if custom_prompt != "" else ("[V] Phòng Đấu Giá" if role_str == "shop_nha_phi" else "[V] Nói chuyện")
		prompt_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prompt_lbl.custom_minimum_size = Vector2(180, 0)
		prompt_lbl.position = Vector2(-90, 18)
		prompt_lbl.add_theme_font_size_override("font_size", 13)
		prompt_lbl.add_theme_color_override("font_color", Color("#80ED99"))
		prompt_lbl.add_theme_color_override("font_outline_color", Color("#07060B"))
		prompt_lbl.add_theme_constant_override("outline_size", 4)
		prompt_lbl.visible = false
		npc_root.add_child(prompt_lbl)

		npc_entries.append({
			"id": nid,
			"name": str(d.get("name", nid)),
			"role": role_str,
			"sprite": sprite_path,
			"pos": pos_v,
			"hide_if_flag": hide_f,
			"float_anim": is_floating,
			"node": npc_root,
			"sprite_node": sp,
			"marker_node": marker_lbl,
			"prompt_node": prompt_lbl
		})

	_refresh_npc_quest_markers()


func _has_spawned_npc(nid: String) -> bool:
	for entry in npc_entries:
		if str(entry.get("id", "")) == nid:
			return true
	return false


func _refresh_npc_quest_markers() -> void:
	var q: Dictionary = PlayerData.get_current_quest()
	var q_flag: String = str(q.get("flag_name", ""))
	for entry in npc_entries:
		var marker: Label = entry.get("marker_node", null) as Label
		if marker == null or not is_instance_valid(marker):
			continue
		var role_str: String = str(entry.get("role", ""))
		var show_bang: bool = false
		var dlg_def: Dictionary = GameDatabase.get_dialogue_def(role_str)
		if not dlg_def.is_empty() and dlg_def.has("marker_when"):
			var mw = dlg_def.get("marker_when")
			if mw is Dictionary:
				show_bang = PlayerData.evaluate_story_condition(mw)
			elif mw is Array:
				for cond in mw:
					if cond is Dictionary and PlayerData.evaluate_story_condition(cond):
						show_bang = true
						break
		elif role_str == "story_tu_hon" and q_flag == "tu_hon_done":
			show_bang = true
		elif role_str == "story_duoc_lao" and q_flag == "duoc_lao_awake":
			show_bang = true
		elif role_str == "shop_nha_phi" and q_flag == "bought_hap_chuong":
			show_bang = true
		elif role_str == "story_nhuoc_lam" and not PlayerData.has_flag("got_gia_nam_leave"):
			show_bang = true
		elif role_str == "secret_lang_anh" and not PlayerData.has_flag("secret_lang_anh_done"):
			show_bang = true
		elif role_str == "story_tieu_y_tien" and not PlayerData.has_flag("met_tieu_y_tien"):
			show_bang = true
		elif role_str == "story_van_chi" and (not PlayerData.has_flag("met_van_chi") or (PlayerData.has_flag("killed_tieu_su_vuong") and not PlayerData.has_flag("absorbed_tu_hoa"))):
			show_bang = true
		elif role_str == "story_tieu_y_tien_farewell" and not PlayerData.has_flag("ch02_farewell_done"):
			show_bang = true
		elif role_str == "story_huan_nhi" and not PlayerData.has_flag("huan_nhi_gift"):
			show_bang = true
		elif (role_str == "story_tieu_dinh" or role_str == "story_tieu_le") and not PlayerData.has_flag("met_tieu_dinh_le"):
			show_bang = true
		elif role_str == "story_hai_ba_dong" and not PlayerData.has_flag("pact_hai_ba_dong"):
			show_bang = true
		elif role_str == "story_thanh_lan" and not PlayerData.has_flag("met_thanh_lan"):
			show_bang = true
		elif role_str == "story_van_van_ch03" and not PlayerData.has_flag("van_van_ch03_done"):
			show_bang = true
		elif role_str == "story_my_do_toa" and not PlayerData.has_flag("snatched_thanh_lien_hoa"):
			show_bang = true
		elif role_str == "story_devour_thanh_lien" and not PlayerData.has_flag("ch03_completed"):
			show_bang = true
		marker.visible = show_bang


func _setup_spawns(m_def: Dictionary) -> void:
	var sp_arr: Array = m_def.get("spawns", [])
	for sp in sp_arr:
		if not (sp is Dictionary):
			continue
		var sd: Dictionary = sp
		var p_arr: Array = sd.get("pos", [500, 500])
		spawn_slots.append({
			"id": str(sd.get("enemy_id", "moc_nhan")),
			"pos": Vector2(float(p_arr[0]), float(p_arr[1])),
			"respawn": float(sd.get("respawn", 7.0)),
			"require_flag": str(sd.get("require_flag", "")),
			"hide_if_flag": str(sd.get("hide_if_flag", "")),
			"timer": 0.0,
			"ref": null
		})

	for i in range(spawn_slots.size()):
		var req_f: String = str(spawn_slots[i].get("require_flag", ""))
		var hide_f: String = str(spawn_slots[i].get("hide_if_flag", ""))
		if hide_f != "" and PlayerData.has_flag(hide_f):
			continue
		if req_f == "" or PlayerData.has_flag(req_f):
			_spawn_from_slot(i)


func _on_story_flag_changed(_flag_name: String) -> void:
	_sync_conditional_npcs()
	for i in range(spawn_slots.size()):
		var slot: Dictionary = spawn_slots[i]
		var req_f: String = str(slot.get("require_flag", ""))
		var hide_f: String = str(slot.get("hide_if_flag", ""))
		var cur_ref = slot.get("ref", null)
		if hide_f != "" and PlayerData.has_flag(hide_f):
			if cur_ref != null and is_instance_valid(cur_ref):
				(cur_ref as Node).queue_free()
				slot["ref"] = null
			continue
		if req_f != "" and PlayerData.has_flag(req_f) and (cur_ref == null or not is_instance_valid(cur_ref)):
			_spawn_from_slot(i)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if interact_cooldown > 0.0:
		interact_cooldown -= delta

	var t_sec: float = float(Time.get_ticks_msec()) * 0.001

	for i in range(lantern_lights.size()):
		var pl: PointLight2D = lantern_lights[i]
		if is_instance_valid(pl):
			pl.energy = 1.15 + sin(t_sec * 5.0 + float(i) * 1.7) * 0.14

	for j in range(bamboo_sprites.size()):
		var bsp: Sprite2D = bamboo_sprites[j]
		if is_instance_valid(bsp):
			bsp.skew = sin(t_sec * 1.7 + float(j) * 0.9) * 0.04

	var p_pos: Vector2 = player_node.global_position if player_node != null else Vector2.ZERO
	for k in range(npc_entries.size()):
		var entry: Dictionary = npc_entries[k]
		var sp_node: Sprite2D = entry.get("sprite_node", null) as Sprite2D
		if sp_node != null and is_instance_valid(sp_node):
			var r_str: String = str(entry.get("role", ""))
			if bool(entry.get("float_anim", false)) or r_str == "story_duoc_lao" or r_str == "story_devour_thanh_lien" or r_str == "story_hai_ba_dong" or r_str == "story_my_do_toa":
				sp_node.position.y = 4.0 + sin(t_sec * 2.8 + float(k)) * 4.5
				var br_f: float = sin(t_sec * 2.4 + float(k)) * 0.018
				sp_node.scale = Vector2(1.0 - br_f * 0.5, 1.0 + br_f)
			else:
				var br: float = sin(t_sec * 3.0 + float(k)) * 0.022
				sp_node.scale = Vector2(1.0 - br * 0.5, 1.0 + br)

		var pr_node: Label = entry.get("prompt_node", null) as Label
		if pr_node != null and is_instance_valid(pr_node):
			pr_node.visible = (p_pos.distance_to(entry.get("pos", Vector2.ZERO)) <= 140.0)

		var mk_node: Label = entry.get("marker_node", null) as Label
		if mk_node != null and is_instance_valid(mk_node) and mk_node.visible:
			mk_node.position.y = -150.0 + sin(t_sec * 5.5) * 4.5

	for ch_entry in chest_entries:
		var pr_c: Label = ch_entry.get("prompt_node", null) as Label
		if pr_c != null and is_instance_valid(pr_c):
			var closed: bool = not bool(ch_entry.get("opened", false))
			pr_c.visible = closed and (p_pos.distance_to(ch_entry.get("pos", Vector2.ZERO)) <= 115.0)

	for p_entry in portal_entries:
		var lbl_n: Label = p_entry.get("label_node", null) as Label
		var pr_n: Label = p_entry.get("prompt_node", null) as Label
		var req_f: String = str(p_entry.get("require_flag", ""))
		var unlocked: bool = _is_portal_unlocked(req_f)
		if lbl_n != null and is_instance_valid(lbl_n):
			lbl_n.add_theme_color_override("font_color", Color("#70D6FF") if unlocked else Color("#ADB5BD"))
		if pr_n != null and is_instance_valid(pr_n):
			pr_n.visible = (p_pos.distance_to(p_entry.get("pos", Vector2.ZERO)) <= 118.0)
			pr_n.text = "[V] Đi qua cổng" if unlocked else "[V] Kiểm tra phong ấn"
			pr_n.add_theme_color_override("font_color", Color("#FFD166") if unlocked else Color("#FF758F"))

	for i in range(spawn_slots.size()):
		var slot: Dictionary = spawn_slots[i]
		var req_f: String = str(slot.get("require_flag", ""))
		var hide_f: String = str(slot.get("hide_if_flag", ""))
		if hide_f != "" and PlayerData.has_flag(hide_f):
			continue
		if req_f != "" and not PlayerData.has_flag(req_f):
			continue
		var cur_ref = slot.get("ref", null)
		if cur_ref == null or not is_instance_valid(cur_ref):
			var tm: float = float(slot.get("timer", 0.0)) + delta
			if tm >= float(slot.get("respawn", 7.0)):
				slot["timer"] = 0.0
				_spawn_from_slot(i)
			else:
				slot["timer"] = tm

	var blocked: bool = false
	if player_node != null and "input_blocked_by_ui" in player_node:
		blocked = bool(player_node.get("input_blocked_by_ui"))
	if not blocked and interact_cooldown <= 0.0 and Input.is_action_just_pressed("interact"):
		_try_interact_nearest()

	queue_redraw()


func _find_closest_interactable() -> Dictionary:
	if player_node == null:
		return {}
	var p_pos: Vector2 = player_node.global_position
	var best_kind: String = ""
	var best_dist: float = 9999.0
	var best_payload: Variant = null

	for entry in npc_entries:
		var d: float = p_pos.distance_to(entry.get("pos", Vector2.ZERO))
		if d <= 140.0 and d < best_dist:
			best_dist = d
			best_kind = "npc"
			best_payload = entry

	for c_entry in chest_entries:
		if bool(c_entry.get("opened", false)):
			continue
		var d: float = p_pos.distance_to(c_entry.get("pos", Vector2.ZERO))
		if d <= 115.0 and d < best_dist:
			best_dist = d
			best_kind = "chest"
			best_payload = c_entry

	for sp_pos in stele_positions:
		var sv: Vector2 = sp_pos as Vector2
		var d: float = p_pos.distance_to(sv)
		if d <= 115.0 and d < best_dist:
			best_dist = d
			best_kind = "stele"
			best_payload = sv

	for p_entry in portal_entries:
		var d: float = p_pos.distance_to(p_entry.get("pos", Vector2.ZERO))
		if d <= 118.0 and d < best_dist:
			best_dist = d
			best_kind = "portal"
			best_payload = p_entry

	if best_kind == "":
		return {}
	return { "kind": best_kind, "payload": best_payload }


func _try_interact_nearest() -> void:
	var target: Dictionary = _find_closest_interactable()
	if target.is_empty():
		return
	var kind: String = str(target.get("kind", ""))
	if kind == "npc":
		interact_cooldown = 0.25
		EventBus.audio_sfx_requested.emit("ui_click")
		_trigger_npc_interaction(target.get("payload", {}) as Dictionary)
	elif kind == "chest":
		interact_cooldown = 0.25
		_open_secret_chest(target.get("payload", {}) as Dictionary)
	elif kind == "stele":
		interact_cooldown = 0.35
		_inspect_testing_stele(target.get("payload", Vector2.ZERO) as Vector2)
	elif kind == "portal":
		var best_pt: Dictionary = target.get("payload", {}) as Dictionary
		interact_cooldown = 0.30
		var req_f: String = str(best_pt.get("require_flag", ""))
		if _is_portal_unlocked(req_f):
			EventBus.audio_sfx_requested.emit("portal_warp")
			load_map(str(best_pt.get("target_map", "")), best_pt.get("target_spawn", Vector2.ZERO), true)
		else:
			EventBus.audio_sfx_requested.emit("alchemy_fail")
			var hint: String = str(best_pt.get("locked_hint", "Cổng hiện chưa mở!"))
			EventBus.floating_text_requested.emit(player_node.global_position + Vector2(0, -68), "Cổng chưa mở!", Color("#FF758F"))
			EventBus.banter_triggered.emit("Gợi ý cốt truyện: " + hint)


func _is_portal_unlocked(req_f: String) -> bool:
	if req_f == "":
		return true
	if req_f.ends_with("_future"):
		return false
	return PlayerData.is_demo_mode or PlayerData.has_flag(req_f)


func _inspect_testing_stele(stele_pos: Vector2) -> void:
	EventBus.audio_sfx_requested.emit("level_up")
	var r_title: String = PlayerData.get_realm_display_title()
	var grade_txt: String = "Đê Cấp!"
	var col: Color = Color("#FF758F")
	if PlayerData.realm_index >= 3:
		grade_txt = "CHẤN ĐỘNG Ô THẢN THÀNH — ĐẤU SƯ TUỔI TRẺ!"
		col = Color("#C77DFF")
	elif PlayerData.realm_index == 2:
		grade_txt = "ĐẤU GIẢ THIÊN TÀI — TIÊU GIA RUNG CHUYỂN!"
		col = Color("#FFD166")
	elif PlayerData.stage >= 8:
		grade_txt = "CAO CẤP! (Thiên Tài Năm Xưa Đã Trở Lại!)"
		col = Color("#80ED99")
	elif PlayerData.stage >= 5:
		grade_txt = "Trung Cấp — Tiến Bộ Thần Tốc!"
		col = Color("#70D6FF")
	EventBus.floating_text_requested.emit(stele_pos + Vector2(0, -108), "%s — %s" % [r_title, grade_txt], col)
	EventBus.banter_triggered.emit("Trắc Nghiệm Ma Thạch Bi phát sáng chữ vàng: [%s — %s]" % [r_title, grade_txt])


# --- KIỂM TRA ĐỐI TƯỢNG TƯƠNG TÁC GẦN NHẤT (CHO NÚT [V] MOBA) ---
func get_nearby_interact_label() -> String:
	var target: Dictionary = _find_closest_interactable()
	if target.is_empty():
		return ""
	var kind: String = str(target.get("kind", ""))
	if kind == "npc":
		var entry: Dictionary = target.get("payload", {}) as Dictionary
		return "Gặp " + str(entry.get("name", "NPC"))
	elif kind == "chest":
		var c_entry: Dictionary = target.get("payload", {}) as Dictionary
		return "Mở " + str((c_entry.get("def", {}) as Dictionary).get("name", "Bảo Rương"))
	elif kind == "stele":
		return "Chạm Ma Thạch Bi"
	elif kind == "portal":
		var p_entry: Dictionary = target.get("payload", {}) as Dictionary
		return str(p_entry.get("label", "Đi qua Cổng"))
	return ""


# --- DỮ LIỆU TIỂU BẢN ĐỒ & LA BÀN MỤC TIÊU NHIỆM VỤ 15 MỐC ---
func get_minimap_snapshot() -> Dictionary:
	var npcs_out: Array = []
	for n in npc_entries:
		var mk: Label = n.get("marker_node", null) as Label
		npcs_out.append({
			"pos": n.get("pos", Vector2.ZERO),
			"has_quest": mk != null and is_instance_valid(mk) and mk.visible
		})

	var portals_out: Array = []
	for pt in portal_entries:
		var rf: String = str(pt.get("require_flag", ""))
		portals_out.append({
			"pos": pt.get("pos", Vector2.ZERO),
			"unlocked": _is_portal_unlocked(rf)
		})

	var chests_out: Array = []
	for ch in chest_entries:
		chests_out.append({
			"pos": ch.get("pos", Vector2.ZERO),
			"opened": bool(ch.get("opened", false))
		})

	var enemies_out: Array = []
	for en in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(en) and en is Node2D:
			var en_nd: Node2D = en as Node2D
			var is_b: bool = bool(en_nd.get("is_boss_unit")) if "is_boss_unit" in en_nd else false
			enemies_out.append({
				"pos": en_nd.global_position,
				"is_boss": is_b
			})

	return {
		"map_size": map_size,
		"is_forest": current_is_forest,
		"zones": zone_draw_specs,
		"player_pos": player_node.global_position if player_node != null else Vector2.ZERO,
		"npcs": npcs_out,
		"portals": portals_out,
		"chests": chests_out,
		"enemies": enemies_out
	}


func get_quest_waypoint_world_pos() -> Vector2:
	var q: Dictionary = PlayerData.get_current_quest()
	if q.is_empty():
		return Vector2.ZERO

	# Data-Driven Waypoints trong JSON (hỗ trợ đa điều kiện cho Chương 04 -> 11 & sửa cốt truyện không cần đụng code!)
	if q.has("waypoint") and q["waypoint"] is Array:
		for step in q["waypoint"]:
			if not (step is Dictionary):
				continue
			var sd: Dictionary = step
			var is_def: bool = bool(sd.get("default", false))
			var cond_d: Dictionary = sd.get("when", {}) if (sd.get("when", {}) is Dictionary) else {}
			if is_def or PlayerData.evaluate_story_condition(cond_d):
				var kind: String = str(sd.get("kind", "npc"))
				var t_map: String = str(sd.get("map", current_map_id))
				var target_s: String = str(sd.get("target", ""))
				if kind == "breakthrough_ready":
					var req_pill: String = str(sd.get("pill_id", ""))
					if PlayerData.is_at_bottleneck() and (req_pill == "" or PlayerData.get_item_count(req_pill) > 0):
						return Vector2.ZERO
					if t_map != current_map_id:
						return _find_portal_towards(t_map)
					var pa: Array = sd.get("pos", [0, 0])
					return Vector2(float(pa[0]), float(pa[1])) if pa.size() >= 2 else Vector2.ZERO
				elif kind == "npc":
					return _find_npc_pos_or_portal(target_s, t_map)
				elif kind == "boss":
					return _find_boss_pos_or_portal(target_s, t_map)
				elif kind == "pos":
					if current_map_id == t_map:
						var pa: Array = sd.get("pos", [0, 0])
						return Vector2(float(pa[0]), float(pa[1])) if pa.size() >= 2 else Vector2.ZERO
					return _find_portal_towards(t_map)
				elif kind == "none":
					return Vector2.ZERO
		return Vector2.ZERO

	var qid: String = str(q.get("id", ""))

	if qid == "q01_dai_sanh_tu_hon":
		return _find_npc_pos_or_portal("story_tu_hon", "ch01_tieu_gia")
	elif qid == "q02_thuc_tinh_duoc_lao":
		return _find_npc_pos_or_portal("story_duoc_lao", "ch01_hau_son")
	elif qid == "q03_luyen_truc_co_linh_dich":
		return Vector2(480, 620) if current_map_id == "ch01_hau_son" else _find_portal_towards("ch01_hau_son")
	elif qid == "q04_dau_gia_me_dac_nhi":
		return _find_npc_pos_or_portal("shop_nha_phi", "ch01_o_than_thanh")
	elif qid == "q05_ty_thi_tieu_ngoc":
		return _find_boss_pos_or_portal("tieu_ngoc_boss", "ch01_hau_son")
	elif qid == "q06_le_thanh_nien_tieu_ninh":
		if not PlayerData.has_flag("unlocked_bat_cuc_bang"):
			return _find_boss_pos_or_portal("tieu_ninh_boss", "ch01_tieu_gia")
		return _find_npc_pos_or_portal("story_nhuoc_lam", "ch01_tieu_gia")
	elif qid == "q07_dot_pha_dau_gia":
		if PlayerData.is_at_bottleneck() and PlayerData.get_item_count("pill_tu_khi_tan") > 0:
			return Vector2.ZERO # Sẵn sàng bấm [B] đột phá ngay tại chỗ!
		return Vector2(1420, 560) if current_map_id == "ch01_hau_son" else _find_portal_towards("ch01_hau_son")
	elif qid == "q08_am_sat_lieu_tich":
		return _find_boss_pos_or_portal("lieu_tich_boss", "ch01_o_than_thanh")
	elif qid == "q09_diet_gia_liet_ao":
		return _find_boss_pos_or_portal("gia_liet_ao_boss", "ch01_o_than_thanh")
	elif qid == "q10_thanh_son_tieu_y_tien":
		return _find_npc_pos_or_portal("story_tieu_y_tien", "ch02_ma_thu_son_mach")
	elif qid == "q11_huyen_nhai_tu_van_duc":
		if current_map_id == "ch02_huyen_nhai_dong":
			return Vector2(1296, 320)
		return _find_portal_towards("ch02_huyen_nhai_dong")
	elif qid == "q12_bo_suoi_van_chi":
		return _find_npc_pos_or_portal("story_van_chi", "ch02_noi_vi_su_vuong")
	elif qid == "q13_hang_su_vuong_tu_hoa":
		if not PlayerData.has_flag("killed_tieu_su_vuong"):
			return _find_boss_pos_or_portal("tieu_tu_tinh_su_boss", "ch02_noi_vi_su_vuong")
		return _find_npc_pos_or_portal("story_van_chi", "ch02_noi_vi_su_vuong")
	elif qid == "q14_giai_vay_muc_luc":
		return _find_boss_pos_or_portal("muc_luc_boss", "ch02_ma_thu_son_mach")
	elif qid == "q15_quyet_tu_muc_xa_u_lan":
		if not PlayerData.has_flag("killed_muc_xa"):
			return _find_boss_pos_or_portal("muc_xa_boss", "ch02_thac_nuoc_muc_xa")
		return _find_npc_pos_or_portal("story_tieu_y_tien_farewell", "ch02_thac_nuoc_muc_xa")
	elif qid == "q16_thach_mac_mac_thiet":
		return _find_npc_pos_or_portal("story_tieu_dinh", "ch03_thach_mac_thanh")
	elif qid == "q17_bang_hoang_tan_do":
		if not PlayerData.has_flag("beat_hai_ba_dong"):
			return _find_boss_pos_or_portal("hai_ba_dong_boss", "ch03_thach_mac_thanh")
		return _find_npc_pos_or_portal("story_hai_ba_dong", "ch03_thach_mac_thanh")
	elif qid == "q18_thanh_lan_dia_huyet":
		if not PlayerData.has_flag("met_thanh_lan"):
			return _find_npc_pos_or_portal("story_thanh_lan", "ch03_thach_mac_thanh")
		if current_map_id == "ch03_dia_huyet_dung_nham":
			return Vector2(1490, 540)
		return _find_portal_towards("ch03_dia_huyet_dung_nham")
	elif qid == "q19_thanh_thanh_xa_nhan":
		if not PlayerData.has_flag("killed_mac_ba_tu"):
			return _find_boss_pos_or_portal("mac_ba_tu_boss", "ch03_thanh_thanh_xa_nhan")
		return _find_boss_pos_or_portal("co_ha_boss", "ch03_thanh_thanh_xa_nhan")
	elif qid == "q20_my_do_toa_doat_hoa":
		return _find_npc_pos_or_portal("story_my_do_toa", "ch03_thanh_thanh_xa_nhan")
	elif qid == "q21_thon_phe_di_hoa_lien":
		return _find_npc_pos_or_portal("story_devour_thanh_lien", "ch03_oc_dao_diem_le")
	return Vector2.ZERO


func _find_npc_pos_or_portal(target_role: String, target_map: String) -> Vector2:
	for n in npc_entries:
		if str(n.get("role", "")) == target_role:
			return n.get("pos", Vector2.ZERO)
	return _find_portal_towards(target_map)


func _find_boss_pos_or_portal(boss_id: String, target_map: String) -> Vector2:
	for sl in spawn_slots:
		if str(sl.get("id", "")) == boss_id:
			var ref = sl.get("ref", null)
			if ref != null and is_instance_valid(ref) and ref is Node2D:
				return (ref as Node2D).global_position
			return sl.get("pos", Vector2.ZERO)
	return _find_portal_towards(target_map)


func _find_portal_towards(target_map: String) -> Vector2:
	if target_map == "" or current_map_id == target_map:
		return Vector2.ZERO
	for pt in portal_entries:
		if str(pt.get("target_map", "")) == target_map:
			return pt.get("pos", Vector2.ZERO)

	# Thuật toán BFS tự động tìm đường ngắn nhất qua đồ thị cổng của toàn bộ bản đồ trong GameDatabase!
	# Ưu tiên đi qua cổng đã mở khóa trước; nếu chưa mở, tự tìm đường tổng quát để chỉ về cổng chốt cần mở.
	var hop: String = _bfs_next_hop_map(current_map_id, target_map, true)
	if hop == "":
		hop = _bfs_next_hop_map(current_map_id, target_map, false)
	if hop != "":
		for pt in portal_entries:
			if str(pt.get("target_map", "")) == hop:
				return pt.get("pos", Vector2.ZERO)
	return Vector2.ZERO


func _bfs_next_hop_map(start_id: String, goal_id: String, unlocked_only: bool) -> String:
	if start_id == goal_id or not GameDatabase.maps_by_id.has(goal_id):
		return ""
	var queue: Array = [start_id]
	var visited: Dictionary = { start_id: true }
	var first_hop: Dictionary = {}
	var head: int = 0

	while head < queue.size():
		var cur: String = str(queue[head])
		head += 1
		var m_def: Dictionary = GameDatabase.get_map_def(cur)
		var portals_arr: Array = m_def.get("portals", [])
		for pt in portals_arr:
			if not (pt is Dictionary):
				continue
			var req_f: String = str(pt.get("require_flag", ""))
			if req_f.ends_with("_future"):
				continue
			if unlocked_only and not _is_portal_unlocked(req_f):
				continue
			var nxt: String = str(pt.get("target_map", ""))
			if nxt == "" or visited.has(nxt) or not GameDatabase.maps_by_id.has(nxt):
				continue
			visited[nxt] = true
			var fh: String = nxt if cur == start_id else str(first_hop.get(cur, nxt))
			first_hop[nxt] = fh
			if nxt == goal_id:
				return fh
			queue.append(nxt)
	return ""


# =========================================================
# DATA-DRIVEN DIALOGUE RUNNER (CH.04 -> CH.11) + KỊCH BẢN CH.01–03
# =========================================================
func _run_data_driven_dialogue(dlg_def: Dictionary, npc_name: String, sprite_p: String) -> bool:
	var branches: Array = dlg_def.get("branches", [])
	if branches.is_empty():
		return false
	for br in branches:
		if not (br is Dictionary):
			continue
		var bd: Dictionary = br
		var is_def: bool = bool(bd.get("default", false))
		var cond_d: Dictionary = bd.get("when", {}) if (bd.get("when", {}) is Dictionary) else {}
		if not is_def and not PlayerData.evaluate_story_condition(cond_d):
			continue

		var sfx_s: String = str(bd.get("sfx", ""))
		if sfx_s != "":
			EventBus.audio_sfx_requested.emit(sfx_s)
		var sh_arr: Array = bd.get("shake", [])
		if sh_arr.size() >= 2:
			EventBus.screen_shake_requested.emit(float(sh_arr[0]), float(sh_arr[1]))

		var q_cur: Dictionary = PlayerData.get_current_quest()
		var q_hint: String = str(q_cur.get("objective", "Tiếp tục tu luyện nâng cao cảnh giới!"))
		var raw_lines: Array = bd.get("lines", [])
		var resolved_lines: Array = []
		for ln in raw_lines:
			resolved_lines.append(str(ln).replace("{quest_objective}", q_hint))

		var sp_override: String = str(bd.get("speaker", npc_name))
		var choices_raw: Array = bd.get("choices", [])
		if not choices_raw.is_empty():
			var filtered_choices: Array = []
			for ch in choices_raw:
				if not (ch is Dictionary):
					continue
				var ch_cond: Dictionary = ch.get("when", {}) if (ch.get("when", {}) is Dictionary) else {}
				if PlayerData.evaluate_story_condition(ch_cond):
					filtered_choices.append({
						"label": str(ch.get("label", "Tiếp tục")),
						"action": str(ch.get("action", ""))
					})
			if not filtered_choices.is_empty():
				EventBus.dialogue_choice_requested.emit(sp_override, sprite_p, resolved_lines, filtered_choices)
				return true

		EventBus.dialogue_requested.emit(sp_override, sprite_p, resolved_lines, str(bd.get("action", "")))
		return true
	return false


func _trigger_npc_interaction(npc_entry: Dictionary) -> void:
	var role_str: String = str(npc_entry.get("role", ""))
	var npc_name: String = str(npc_entry.get("name", "NPC"))
	var sprite_p: String = str(npc_entry.get("sprite", ""))

	# Ưu tiên đọc kịch bản Data-Driven JSON (dialogues_chXX.json) nếu tồn tại!
	var dlg_def: Dictionary = GameDatabase.get_dialogue_def(role_str)
	if not dlg_def.is_empty():
		if _run_data_driven_dialogue(dlg_def, npc_name, sprite_p):
			return

	if role_str == "story_tieu_chien":
		if not PlayerData.has_flag("tu_hon_done"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Chiến (vỗ vai con trai, ánh mắt trầm ổn): 'Viêm nhi, ba năm qua dù tộc nhân có bàn tán ra sao, trong lòng vi phụ con vẫn là niềm tự hào của Tiêu Gia!'",
				"Tiêu Chiến (nhíu mày): 'Hôm nay phái đoàn Vân Lam Tông bất ngờ ghé thăm — Nạp Lan Yên Nhiên đang đợi ở sân trước, con đi cùng ta xem chúng giở trò gì!'"
			], "")
		elif not PlayerData.has_flag("unlocked_bat_cuc_bang"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Chiến (cười lớn đầy khí phách): 'Viết Hưu Thư trả lại Tụ Khí Tán trước mặt Chấp sự Vân Lam Tông — thật xứng là con trai của Tiêu Chiến ta!'",
				"Tiêu Chiến: 'Cố gắng tu luyện chuẩn bị cho Lễ Thành Niên Tiêu Gia, đừng để tên Tiêu Ninh kia coi thường!'"
			], "heal_full")
		elif not PlayerData.has_flag("ch01_completed"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Chiến (tự hào): 'Một chiêu đánh bay Tiêu Ninh khỏi Lôi Đài! Đám trưởng lão nay câm nín hết rồi!'",
				"Tiêu Chiến (lo lắng): 'Gần đây Gia Liệt Gia thuê được Luyện Đan Sư Liễu Tịch chèn ép phường thị Tiêu Gia ở Ô Thản Thành... Con nhớ cẩn thận nếu ra thành!'"
			], "heal_full")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Chiến (rưng rưng tự hào): 'Gia Liệt Gia đã bị diệt, Tiêu Gia nay đứng đầu Ô Thản Thành! Con trai, đường lớn bên ngoài Ma Thú Sơn Mạch đang chờ con — hãy bình an trở về!'"
			], "heal_full")

	elif role_str == "story_huan_nhi":
		if not PlayerData.has_flag("huan_nhi_gift"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Huân Nhi (dịu dàng): 'Tiêu Viêm ca ca, huynh đừng buồn vì Ma Thạch Bi vẫn là Tam Đoạn... Muội nhớ suốt 2 năm thuở nhỏ mỗi đêm huynh đều vụng về ôn dưỡng kinh mạch cho muội.'",
				"Tiêu Huân Nhi (đưa túi thảo dược): 'Đây là 2 cây Ngưng Huyết Thảo và 1 viên Ngưng Huyết Tán muội để dành. Bên kia Nạp Lan Yên Nhiên của Vân Lam Tông đang đứng chờ kìa!'"
			], "gift_huan_nhi")
		elif not PlayerData.has_flag("duoc_lao_awake"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Huân Nhi (ánh mắt lấp lánh tia Kim Hỏa rồi dịu lại): 'Tiêu Viêm ca ca thật khí phách khi viết Hưu Thư trước mặt Vân Lam Tông! Huynh cứ lên Hậu Sơn cho khuây khỏa nhé.'"
			], "heal_full")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Huân Nhi (mỉm cười ấm áp): 'Khí tức trên người Tiêu Viêm ca ca mạnh lên từng ngày! Muội sẽ chờ huynh ở Học Viện Già Nam — để muội hồi đầy thể lực cho huynh nhé!'"
			], "heal_full")

	elif role_str == "story_tu_hon":
		EventBus.dialogue_requested.emit(npc_name, sprite_p, [
			"Nạp Lan Yên Nhiên (lạnh nhạt): 'Tiêu Viêm công tử, ba năm qua ngươi dậm chân tại Đấu Chi Khí Tam Đoạn. Khoảng cách giữa chúng ta đã là trời vực...'",
			"Cát Diệp Trưởng Lão (phóng uy áp Đấu Linh): 'Vân Lam Tông tặng Tiêu Gia một viên Tụ Khí Tán Tam Phẩm, chỉ mong công tử hủy bỏ hôn ước này!'",
			"Tiêu Viêm (rạch tay viết Hưu Thư đẫm máu): 'Lấy Tụ Khí Tán về đi! Không phải ngươi từ hôn ta, mà là TIÊU VIÊM TA HƯU NGƯƠI!'",
			"Tiêu Viêm (gằn từng chữ): 'TAM THẬP NIÊN HÀ ĐÔNG, TAM THẬP NIÊN HÀ TÂY — MẠC KHI THIẾU NIÊN CÙNG! Ba năm sau ta sẽ bước lên Vân Lam Sơn rửa nhục!'",
			"Nạp Lan Yên Nhiên tái mặt phất tay áo rời khỏi Tiêu Gia... (Nhận Buff [Ấn Ký Tôn Nghiêm +5% ATK] & mở Cổng Bắc lên Hậu Sơn!)"
		], "flag:tu_hon_done")

	elif role_str == "story_nhuoc_lam":
		if not PlayerData.has_flag("got_gia_nam_leave"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Nhược Lâm Đạo Sư (mỉm cười tán thưởng): 'Thật kinh ngạc! Một năm từ Tam Đoạn vọt lên đánh bại cả Tiêu Ninh uống Tăng Khí Tán — Học Viện Già Nam đặc cách tuyển thẳng em và Huân Nhi!'",
				"Tiêu Viêm (chắp tay kiên định): 'Đa tạ Đạo sư! Đệ tử có một Ước Hẹn 3 Năm cần tự mình khổ tu bên ngoài, xin Đạo sư cho phép nghỉ phép 2 năm trước khi nhập học!'",
				"Nhược Lâm Đạo Sư (trao ngọc bài xanh biếc): 'Chí khí đáng khen! Đây là [Già Nam Ngọc Bài] — hai năm sau ta chờ hai đứa tại Nội Viện Già Nam!'"
			], "flag:got_gia_nam_leave")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Nhược Lâm Đạo Sư: 'Cầm chắc Già Nam Ngọc Bài nhé! Hãy đột phá lên Đấu Giả rồi ra ngoài rèn luyện cho thật vững vàng.'"
			], "heal_full")

	elif role_str == "secret_lang_anh":
		EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
			"Dược Lão (truyền âm kinh hãi): 'Tiểu tử DỪNG LẠI NGAY! Trong bóng tối gốc tùng kia là một cường giả Đấu Hoàng Cửu Tinh ẩn thân — chắc chắn là ám vệ bảo vệ Huân Nhi!'",
			"Bóng đen mặc hắc bào khẽ hé đôi mắt tím sắc lạnh nhìn về phía bạn..."
		], [
			{ "label": "Nín thở đứng im không động đậy (Nghe lời Dược Lão -> Nhận Hắc Ảnh Phù +8% SPD!)", "action": "choice:lang_anh_quiet" },
			{ "label": "Chắp tay kính lễ cảm ơn tiền bối bảo vệ Huân Nhi (+10 Hảo Cảm Huân Nhi & +4 SOUL!)", "action": "choice:lang_anh_bow" }
		])

	elif role_str == "story_duoc_lao":
		if not PlayerData.has_flag("duoc_lao_awake"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Hắc giới mẫu thân để lại đột nhiên bốc khói trắng — một lão giả bạch bào lơ lửng hiện thân giữa Vách Đá Hậu Sơn!",
				"Dược Lão (cười khà khà): 'Hắc hắc tiểu tử, ba năm qua chính lão phu đã hấp thu Đấu Chi Khí của con để thức tỉnh linh hồn từ giấc ngủ say!'",
				"Tiêu Viêm (quỳ xuống hành lễ): 'Tiền bối là Luyện Dược Đại Sư?! Xin nhận đồ nhi một lạy — chỉ cần giúp con thắng ước hẹn ba năm, khổ cực mấy con cũng chịu!'",
				"Dược Lão: 'Khá lắm! Vi sư truyền cho con [Q] Toái Thạch Chưởng, ngọn [Phàm Hỏa], Kho Đấu Kỹ [K] và mở Lò Luyện Đan [L]! Hãy luyện Trúc Cơ Linh Dịch đầu đời đi!'"
			], "flag:duoc_lao_awake")
		else:
			var q: Dictionary = PlayerData.get_current_quest()
			var q_hint: String = str(q.get("objective", "Tiếp tục khổ tu nâng cao cảnh giới!"))
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Dược Lão: 'Tiểu tử cố lên! Mục tiêu hiện tại của con: %s'" % q_hint,
				"Dược Lão: 'Vi sư vừa dùng linh hồn lực điều tức lại toàn bộ HP và Đấu Khí cho con rồi đấy!'"
			], "heal_full")

	elif role_str == "shop_nha_phi":
		if not PlayerData.has_flag("met_nha_phi"):
			PlayerData.set_story_flag("met_nha_phi")
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Nhã Phi (mỉm cười quyến rũ): 'Ô kìa, đây chẳng phải Tam Thiếu Gia Tiêu Gia sao? Hoan nghênh tới Phòng Đấu Giá Mễ Đặc Nhĩ!'",
				"Nhã Phi: 'Bản phòng vừa nhập về Bí Tịch [Hấp Chưởng], [Bạo Bộ], Thanh Thiết Kiếm, Tinh Cương Chiến Đao và thảo dược luyện đan — mời công tử xem hàng!'"
			], "open_shop:nha_phi")
		else:
			EventBus.shop_requested.emit()

	elif role_str == "story_muc_luc_intro":
		EventBus.dialogue_requested.emit(npc_name, sprite_p, [
			"Mục Lực (khinh khỉnh dựa thương): 'Hừ, lại một tên lính đánh thuê vác thanh sắt đen rỉ sét muốn tiếp cận Tiểu Y Tiên à?'",
			"Mục Lực (cười lạnh): 'Thanh Sơn Trấn này là địa bàn của Lang Đầu Đoàn ta — thức thời thì đừng xía mũi vào chuyện của Vạn Dược Trai!'"
		], "")

	elif role_str == "story_tieu_y_tien":
		if not PlayerData.has_flag("met_tieu_y_tien"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiểu Y Tiên (mỉm cười trong trẻo): 'Chào vị lính đánh thuê trẻ tuổi! Cảm ơn huynh đã không bị lời đe dọa của Mục Lực làm cho chùn bước.'",
				"Tiểu Y Tiên: 'Ở Vách Đá Đoạn Hồn phía Bắc có một hang đá cổ bị mây mù che khuất — nghe đồn có nhiều linh dược hiếm! Muội sẽ đi cùng hỗ trợ hồi máu cho huynh (bấm phím [G])!'",
				"Dược Lão (truyền âm trong nhẫn): 'Huyền Trọng Xích đã quen tay rồi! Giờ vi sư truyền cho con Địa Giai Đấu Kỹ [R] — Diễm Phân Phệ Lãng Xích để xông pha Ma Thú Sơn Mạch!'"
			], "flag:met_tieu_y_tien")
		elif PlayerData.has_flag("found_doc_kinh") and not PlayerData.has_flag("absorbed_tu_hoa"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiểu Y Tiên (ôm chặt cuốn Thất Thải Độc Kinh, mắt sáng rỡ): 'Cảm ơn Tiêu Viêm đã chia sẻ linh dược và cuốn sách kỳ lạ này ở Huyền Nhai Sơn Động!'",
				"Tiểu Y Tiên: 'Nghe nói phía Đông Bắc gần Bờ Suối Trăng Bạc vừa có dị tượng Đấu Hoàng đại chiến — huynh nhớ cẩn thận nhé! Để muội hồi đầy HP & Đấu Khí cho huynh.'"
			], "heal_full")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiểu Y Tiên: 'Mục Lực và Lang Đầu Đoàn ngày càng hung hăng ở phía Đông! Huynh bấm [G] để muội luôn đi sát hỗ trợ hồi máu nhé!'"
			], "heal_full")

	elif role_str == "story_van_chi":
		if not PlayerData.has_flag("met_van_chi"):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Vân Chi (mỹ nhân áo trắng lạnh lùng tựa đá, Đấu Khí bị Tử Tinh Phong Ấn khóa chặt): 'Đa tạ tiểu huynh đệ đã cứu ta bên Bờ Suối Trăng Bạc... Hãy gọi ta là Vân Chi.'",
				"Bên đống lửa trại Hang Ẩn Tu, Tiêu Viêm nướng hai con cá suối thơm phức để bồi bổ cho mỹ nhân bị thương. Dược Lão trong nhẫn bỗng cười gian chỉ vào một lọ bột màu hồng nhạt..."
			], [
				{ "label": "Nướng cá thảo mộc thanh đạm chăm sóc chu đáo (+30 Hảo Cảm Vân Chi!)", "action": "choice:van_chi_herb_fish" },
				{ "label": "Rắc nhầm lọ 'muối tiêu hồng' của Dược Lão (Kỳ ngộ hài hước Vân Chi nhảy xuống suối lạnh!)", "action": "choice:van_chi_pink_powder" }
			])
		elif not PlayerData.has_flag("killed_tieu_su_vuong"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Vân Chi (khẽ gật đầu): 'Ta đã dụ Tử Tinh Dực Sư Vương rời khỏi ổ rồi! Ngươi hãy nhân cơ hội tiến sâu vào Hang Tím phía Đông hạ Tiểu Sư Vương đoạt [Tử Linh Tinh] nhé!'",
				"Vân Chi: 'Để ta dùng dược thảo hồi đầy thể lực cho ngươi trước khi xuất phát.'"
			], "heal_full")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Vân Chi (kinh ngạc nhận lấy một nửa Bầu Tử Linh Tinh): 'Ngươi thực sự đã đoạt được cả Tử Linh Tinh lẫn Tử Tinh Nguyên sao?! Phong ấn trên người ta đã giải trừ hoàn toàn rồi!'",
				"Vân Chi (lưu luyến cởi chiếc nội giáp lấp lánh lam quang đặt vào tay bạn): 'Ta phải trở về tông môn rồi... Chiếc [Hải Tâm Giáp] này tặng ngươi phòng thân. Hẹn một ngày hữu duyên tái ngộ!'",
				"Vân Chi vút bay lên tầng mây! Dược Lão lập tức hộ pháp giúp Tiêu Viêm vận chuyển Phần Quyết nuốt chửng ngọn [TỬ TINH THÚ HỎA] — Đấu Khí lột xác thành sắc TÍM RỰC LỬA!"
			], "flag:absorbed_tu_hoa")

	elif role_str == "story_tieu_y_tien_farewell":
		if not PlayerData.has_flag("ch02_farewell_done"):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Giữa Thung Lũng U Lan, toàn bộ cỏ hoa xung quanh bóng lưng nhỏ bé của Tiểu Y Tiên đều héo đen vì khí độc tím bốc lên từ cơ thể nàng!",
				"Tiểu Y Tiên (khóc nấc lùi lại): 'Tiêu Viêm đừng bước qua vạch cỏ héo! Ách Nan Độc Thể của muội đã thức tỉnh rồi — chạm vào muội huynh sẽ trúng kịch độc mất... Muội phải rời sang Xuất Vân Đế Quốc thôi!'"
			], [
				{ "label": "Bọc Tử Hỏa bước thẳng qua vòng cỏ độc ôm chặt nàng & hẹn ngày luyện Độc Đan (+40 Hảo Cảm!)", "action": "choice:u_lan_hug" },
				{ "label": "Đứng ngoài vòng độc nắm chặt tay thề trở thành Luyện Đan Tông Sư cứu nàng (+20 Hảo Cảm!)", "action": "choice:u_lan_promise" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiểu Y Tiên (mỉm cười qua làn nước mắt): 'Huynh hãy mạnh mẽ tiến về Sa Mạc Tháp Qua Nhĩ ở Chương 03 nhé... Muội sẽ luôn nhớ lời hẹn giữa chúng ta!'"
			], "heal_full")

	elif role_str == "story_tieu_dinh":
		if not PlayerData.has_flag("met_tieu_dinh_le"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Đỉnh (vỗ mạnh vai em trai, mắt ánh lên niềm vui khôn xiết): 'Hảo tiểu tử! Mới hơn một năm xa Ô Thản Thành, tam đệ nhà họ Tiêu chúng ta đã trở thành một vị Đấu Sư đường đường chính chính!'",
				"Tiêu Đỉnh (đưa bình nước lạnh & dược tán): 'Đệ muốn mua bản đồ vùng lõi Sa Mạc Tháp Qua Nhĩ? Ở góc Tây Nam thành có một lão quái vẽ bản đồ cổ cực kỳ bí ẩn — nhớ giữ an toàn nhé!'"
			], "flag:met_tieu_dinh_le")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Đỉnh (mỉm cười trầm ổn): 'Tổng bộ Mạc Thiết Đoàn mãi là nhà của tam đệ! Mệt mỏi cứ về đây đại ca chuẩn bị tiếp tế và hồi đầy thể lực cho!'"
			], "heal_full")

	elif role_str == "story_tieu_le":
		if not PlayerData.has_flag("met_tieu_dinh_le"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Lệ (cười gằn lạnh lùng bên ngọn Huyết Thương nhưng ánh mắt nhìn em trai cực kỳ ấm áp): 'Hắc! Ở cái Thạch Mạc Thành này, đứa nào dám động tới một cọng tóc của tam đệ, nhị ca đem cả đoàn đánh thuê nhà nó chôn sống dưới cát vàng!'",
				"Tiêu Lệ: 'Lão quái vẽ bản đồ ở góc Tây Nam sát khí nặng lắm đấy, nhưng tam đệ giờ đã là Đấu Sư, cứ đi thử xem sao!'"
			], "flag:met_tieu_dinh_le")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Lệ (vung Huyết Thương): 'Đám Sa Chi Đoàn & Xà Nhân ngoài thành mà dám cản đường đệ, cứ kêu nhị ca dẫn anh em Mạc Thiết chém sạch!'"
			], "heal_full")

	elif role_str == "story_hai_ba_dong":
		if not PlayerData.has_flag("pact_hai_ba_dong"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Hải Ba Đông (lau vết sương lạnh bên mép, ánh mắt kinh hãi nhìn hư ảnh bạch bào của Dược Lão): 'Cốt Linh Lãnh Hỏa?! Tiền bối... xin tha mạng! Lão phu vốn là Băng Hoàng Hải Ba Đông, bị Mỹ Đỗ Toa hạ Xà Chi Phong Ấn Chú nên thực lực rớt xuống Đấu Linh!'",
				"Dược Lão (cười khà khà): 'Hắc hắc, muốn đồ đệ ta sau này luyện Lục phẩm Phá Ách Đan giải phong ấn cho ngươi? Giao ngay Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa #2 ra đây, và ký giao ước làm Bảo Tiêu Đấu Hoàng miễn phí 1 năm!'",
				"Hải Ba Đông (cắn răng trao nửa mảnh da dê cổ & viên Hàn Băng Chi Tâm): 'Thành giao!! Ta giao [Mảnh Tàn Đồ #2 (2/4)] và bản đồ lõi sa mạc! Nghe nói cô bé Thanh Lân ở Mạc Thiết Đoàn cảm ứng được nguồn lửa cực mạnh dưới Hố Cát Bắc đấy!'"
			], "flag:pact_hai_ba_dong")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Hải Ba Đông (khoanh tay ngạo nghễ): 'Yên tâm tiểu tử, giao ước của Băng Hoàng ta nặng tựa núi! Chờ ngươi thu phục Thanh Liên Địa Tâm Hỏa rồi luyện Phá Ách Đan cho lão phu đấy!'"
			], "heal_full")

	elif role_str == "story_thanh_lan":
		if not PlayerData.has_flag("met_thanh_lan"):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Thanh Lân (cúi gằm mặt che cánh tay có vảy rắn xanh, nước mắt lưng tròng): 'Tam thiếu gia đừng chạm vào nô tỳ... Người trong thành đều gọi Thanh Lân là quái vật lai Xà Nhân, chạm vào sẽ gặp xui xẻo...'",
				"Đôi mắt xanh biếc của cô bé bỗng lấp lánh ba chấm hoa ngọc bích — Bích Xà Tam Hoa Đồng bắt đầu cảm ứng mãnh liệt về phía Hố Cát Bắc!"
			], [
				{ "label": "Dịu dàng xoa đầu gỡ băng vải: 'Từ nay muội là muội muội của 3 huynh đệ Tiêu Gia!' (+35 Hảo Cảm Thanh Lân!)", "action": "choice:thanh_lan_sister" },
				{ "label": "Đứng chắn trước mặt dặn hai huynh trưởng bảo vệ Thanh Lân thật tốt (+20 Hảo Cảm Thanh Lân!)", "action": "choice:thanh_lan_protect" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Thanh Lân (mỉm cười rạng rỡ với đôi mắt Bích Xà Tam Hoa Đồng): 'Tiêu Viêm thiếu gia cẩn thận nhé! Dưới Hố Cát phía Bắc có một con Song Đầu Hỏa Linh Xà rất hung dữ canh giữ đóa sen xanh khổng lồ!'"
			], "heal_full")

	elif role_str == "story_van_van_ch03":
		if not PlayerData.has_flag("van_van_ch03_done"):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Giữa chiến trường bão cát Thánh Thành Xà Nhân, tà váy trắng che mạng mỏng chặn đứng đường bạn! Kiếm phong xanh biếc xé rách vạt Hắc Bào, để lộ ánh sáng lam quen thuộc của chiếc [Hải Tâm Giáp] trên ngực Tiêu Viêm!",
				"Vân Vận — Tông Chủ Vân Lam Tông — đồng tử co rút kịch liệt, bàn tay cầm cổ kiếm run lên bần bật: 'Hải Tâm Giáp... Dược Nham?! Sao... sao lại là ngươi?!'"
			], [
				{ "label": "Khẽ thì thầm qua lớp áo choàng: 'Vân Chi... bảo trọng! Đừng để Cổ Hà cản ta!' (+35 Hảo Cảm Vân Vận!)", "action": "choice:van_van_call_name" },
				{ "label": "Im lặng cúi đầu vỗ Tử Vân Dực lướt qua mũi kiếm nghiêng ba tấc của nàng (+20 Hảo Cảm Vân Vận!)", "action": "choice:van_van_silent" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Vân Vận (mắt phượng u buồn quay mặt cản hướng gió): 'Ta sẽ giữ chân Phong Lê và Cổ Hà thêm vài nhịp... Ngươi mau đoạt lấy Dị Hỏa rồi rời khỏi đại mạc đi!'"
			], "heal_full")

	elif role_str == "story_my_do_toa":
		if not PlayerData.has_flag("beat_co_ha_mac_ba_tu"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Dược Lão (truyền âm khẩn cấp): 'Khoan đã tiểu tử! Đại Thống Lĩnh Mặc Ba Tư và Đan Vương Cổ Hà vẫn đang chặn bên ngoài — phải đánh bại cả HAI tên đó trước mới có thể đột kích Đảo Thánh Trì đoạt lửa an toàn!'"
			], "")
		else:
			EventBus.audio_sfx_requested.emit("boss_roar")
			EventBus.screen_shake_requested.emit(11.0, 0.45)
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Mỹ Đỗ Toa Nữ Vương (kiêu diễm đứng giữa Thánh Trì Đảo Tâm Hồ, ngẩng đầu đối diện chín tầng Tử Sắc Thiên Lôi): 'Xà Nhân Tộc ta đã khát máu nơi sa mạc cằn cỗi ngàn năm! Hôm nay bổn vương lấy thân nhập Dị Hỏa — hoặc hóa tro bụi, hoặc bước vào ĐẤU TÔNG!!'",
				"ẦM ẦM!! Chín đạo Thiên Lôi Tím giáng tan lớp vảy cháy đen! Từ trong ngọn lửa xanh ngọc chui ra một sinh vật nhỏ bé 7 màu cầu vồng lấp lánh — Thượng Cổ Thần Thú [THẤT THẢI THÔN THIÊN MÃNG] rơi vào hôn mê bên cạnh Hỏa Chủng Thanh Liên Địa Tâm Hỏa!",
				"Tiêu Viêm vỗ Tử Vân Dực lao như tia chớp đen đoạt gọn [HỎA CHỦNG THANH LIÊN ĐỊA TÂM HỎA] cùng con rắn nhỏ 7 màu nhét vào ngực áo! Vân Vận nghiêng mũi kiếm mở đường máu — mau bay qua Cổng Đông Nam tới [Ốc Đảo Diêm Lệ]!!"
			], "flag:snatched_thanh_lien_hoa")

	elif role_str == "story_devour_thanh_lien":
		if not PlayerData.has_flag("ch03_completed"):
			var has_bt: bool = PlayerData.get_item_count("pill_bang_tam_dan") > 0
			var opt1_lbl: String = "Uống [Băng Tâm Đan] + Vận Phần Quyết nuốt trọn #19 Thanh Liên Hỏa (+400 EXP & Mở [F] Hỏa Liên!)" if has_bt else "Vận Phần Quyết + Thanh Liên Đài nuốt trọn #19 Thanh Liên Hỏa (Mở [F] Phật Nộ Hỏa Liên!)"
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Dược Lão (giăng kết giới linh hồn quanh Thanh Liên Đài giữa Ốc Đảo Diêm Lệ): 'Hỏa Chủng sắp phá bình ngọc rồi! Thôn phệ Dị Hỏa là cửu tử nhất sinh — một khi thành công, Phần Quyết thăng thẳng Huyền Giai Trung Cấp và con có thể dung hợp Song Hỏa sáng tạo tuyệt kỹ độc tôn!'",
				"Ngọn lửa xanh ngọc #19 Thanh Liên Địa Tâm Hỏa bùng cháy rực trời trước mặt Tiêu Viêm..."
			], [
				{ "label": opt1_lbl, "action": "choice:devour_bang_tam" },
				{ "label": "Gầm vang lời thề Ước Hẹn 3 Năm dùng ý chí sắt đá nghiền nát Dị Hỏa (+6 SOUL & Mở [F] Hỏa Liên!)", "action": "choice:devour_iron_will" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Dược Lão (cười vang tự hào): 'TUYỆT ĐỈNH! Vừa thu phục [#19 Thanh Liên Địa Tâm Hỏa], vừa có Thần Thú [Thải Lân] hộ thân, lại tự sáng tạo ra [F] PHẬT NỘ HỎA LIÊN rung chuyển thiên địa! Mau ra Bãi Thử phía Đông bắn thử một đóa Hỏa Liên xem uy lực cỡ nào!!'"
			], "heal_full")

	elif role_str == "story_thai_lan_pet":
		EventBus.dialogue_requested.emit(npc_name, sprite_p, [
			"Thải Lân (con rắn nhỏ 7 màu đội vương miện vàng quấn quanh cổ tay Tiêu Viêm, mắt lấp lánh đòi ăn Hỏa Tinh như trẻ con): 'Xì xì~ ♪'",
			"Tiêu Viêm mỉm cười đút cho Thải Lân một mảnh Địa Tâm Hỏa Tinh — nàng vui vẻ tỏa ra luồng Thất Thải Quang Mang hồi đầy HP & Đấu Khí cho bạn (+15 Hảo Cảm Thải Lân / Mỹ Đỗ Toa)!"
		], "feed_thai_lan")


func _spawn_from_slot(idx: int) -> void:
	var packed: PackedScene = load(ENEMY_SCENE_PATH)
	if packed == null:
		return
	var slot: Dictionary = spawn_slots[idx]
	var inst: CharacterBody2D = packed.instantiate() as CharacterBody2D
	entities_root.add_child(inst)
	var pos_val: Vector2 = slot.get("pos", Vector2(540, 420))
	if inst.has_method("configure_enemy"):
		inst.configure_enemy(str(slot.get("id", "moc_nhan")), pos_val)
	slot["ref"] = inst


func _spawn_floating_text(world_pos: Vector2, text_value: String, text_color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text_value
	lbl.global_position = world_pos + Vector2(-42, -16)
	lbl.add_theme_font_size_override("font_size", 17)
	lbl.add_theme_color_override("font_color", text_color)
	lbl.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.07, 1.0))
	lbl.add_theme_constant_override("outline_size", 5)
	floating_layer.add_child(lbl)

	var tw := lbl.create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - 44.0, 0.72)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.72)
	tw.chain().tween_callback(lbl.queue_free)


func _draw() -> void:
	var t_sec: float = float(Time.get_ticks_msec()) * 0.001

	for z in zone_draw_specs:
		var rc: Rect2 = z.get("rect", Rect2())
		var b_hex: String = str(z.get("border_hex", ""))
		if b_hex != "":
			draw_rect(rc, Color(b_hex), false, 3.5)
		if bool(z.get("arena_circle", false)):
			var center: Vector2 = rc.position + rc.size * 0.5
			var rad: float = minf(rc.size.x, rc.size.y) * 0.34
			draw_arc(center, rad, 0.0, TAU, 56, Color(0.96, 0.75, 0.22, 0.50), 3.2)
			draw_arc(center, rad * 0.58, 0.0, TAU, 40, Color(0.96, 0.75, 0.22, 0.32), 2.2)

	draw_rect(map_rect, Color("#4D7EA8"), false, 4.5)

	for p_entry in portal_entries:
		var pos_v: Vector2 = p_entry.get("pos", Vector2.ZERO)
		var req_f: String = str(p_entry.get("require_flag", ""))
		var unlocked: bool = _is_portal_unlocked(req_f)
		var pulse: float = 0.78 + sin(t_sec * 4.2) * 0.22

		if unlocked:
			draw_circle(pos_v, 36.0, Color(0.18, 0.78, 0.96, 0.20 * pulse))
			draw_arc(pos_v, 36.0, t_sec * 1.4, t_sec * 1.4 + TAU * 0.78, 36, Color(0.44, 0.84, 1.0, 0.88), 3.5)
			draw_arc(pos_v, 24.0, -t_sec * 2.2, -t_sec * 2.2 + TAU * 0.70, 28, Color(1.0, 0.82, 0.40, 0.82), 2.5)
			draw_circle(pos_v, 8.0, Color(0.85, 0.97, 1.0, 0.85 * pulse))
		else:
			draw_circle(pos_v, 34.0, Color(0.65, 0.16, 0.24, 0.18))
			draw_arc(pos_v, 34.0, 0.0, TAU, 32, Color(0.85, 0.28, 0.36, 0.72), 3.0)
			draw_line(pos_v + Vector2(-14, -14), pos_v + Vector2(14, 14), Color(0.95, 0.35, 0.42, 0.85), 3.0)
			draw_line(pos_v + Vector2(14, -14), pos_v + Vector2(-14, 14), Color(0.95, 0.35, 0.42, 0.85), 3.0)
