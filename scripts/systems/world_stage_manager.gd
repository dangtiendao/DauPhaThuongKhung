extends Node2D
## Hệ thống Quản lý Đa Bản Đồ (Data-Driven Story Engine: 25 Bản Đồ Ch.01 -> Ch.05 + Tâm Ma + Thiên Phần Tháp):
## - Chương 01 (3 map): Quảng Trường Tiêu Gia, Rừng Trúc Hậu Sơn, Phố Chợ Ô Thản Thành & Biệt Viện Gia Liệt Gia.
## - Chương 02 (4 map): Thanh Sơn Trấn & Ngoại Vi, Huyền Nhai Sơn Động (3 Thạch Thất), Bờ Suối Trăng Bạc & Hang Sư Vương, Thác Nước Nghìn Trượng & Thung Lũng U Lan.
## - Chương 03 (4 map): Thạch Mạc Thành & Mạc Thiết Đoàn, Địa Huyệt Sông Dung Nham, Thánh Thành Xà Nhân & Thánh Trì, Ốc Đảo Diêm Lệ.
## - Tương tác Ma Thạch Bi [V], 15 NPC cốt truyện & kỳ ngộ ẩn, Đối thoại Chọn Nhánh tăng Hảo Cảm Hồng Nhan, 14 Bảo Rương & 21 mốc Nhiệm Vụ!

const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy_base.tscn")
const COMPANION_SCENE: PackedScene = preload("res://scenes/entities/companion.tscn")
const TEX_LIGHT_RADIAL: Texture2D = preload("res://assets/sprites/vfx/light_radial_128.png")
const StoryDlgRunner = preload("res://scripts/systems/story_dialogue_runner.gd")
const BossRushMgrScript = preload("res://scripts/systems/boss_rush_manager.gd")
const ThienPhanTowerMgrScript = preload("res://scripts/systems/thien_phan_tower_manager.gd")

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

# Trình quản lý Phó bản tách biệt (Tâm Ma Luyện Cảnh & Thiên Phần Luyện Khí Tháp)
var boss_rush_mgr: RefCounted = null
var tower_mgr: RefCounted = null

var is_boss_rush_active: bool:
	get:
		return boss_rush_mgr.is_active if boss_rush_mgr != null else false
	set(v):
		if boss_rush_mgr != null:
			boss_rush_mgr.is_active = v

var is_tower_active: bool:
	get:
		return tower_mgr.is_active if tower_mgr != null else false
	set(v):
		if tower_mgr != null:
			tower_mgr.is_active = v

# Soul Radar Wave (Cảm Ứng Linh Hồn [Z])
var radar_wave_timer: float = 0.0
var radar_wave_duration: float = 0.95
var radar_wave_origin: Vector2 = Vector2.ZERO
var radar_wave_max_radius: float = 420.0
var radar_ping_timer: float = 0.0
var radar_pinged_chests: Array = []

var map_backdrop_root: Node2D
var map_overlay_root: Node2D
var screen_fx_overlay: ScreenFxOverlay
var _dan_lei_queue: Array = [] # { delay: float, pos: Vector2, color: Color }

@onready var entities_root: Node2D = $Entities
@onready var floating_layer: Node2D = $FloatingTexts
@onready var player_node: CharacterBody2D = $Entities/Player


func _ready() -> void:
	add_to_group("world_stage")
	boss_rush_mgr = BossRushMgrScript.new(self)
	tower_mgr = ThienPhanTowerMgrScript.new(self)

	map_backdrop_root = Node2D.new()
	map_backdrop_root.name = "MapBackdrop"
	map_backdrop_root.z_index = -10
	add_child(map_backdrop_root)
	move_child(map_backdrop_root, 0)

	map_overlay_root = Node2D.new()
	map_overlay_root.name = "MapOverlay"
	map_overlay_root.z_index = 2
	add_child(map_overlay_root)

	screen_fx_overlay = ScreenFxOverlay.new()
	add_child(screen_fx_overlay)

	EventBus.floating_text_requested.connect(_spawn_floating_text)
	EventBus.story_flag_changed.connect(_on_story_flag_changed)
	EventBus.quest_updated.connect(_refresh_npc_quest_markers)
	EventBus.companion_changed.connect(_on_companion_changed)
	EventBus.boss_rush_requested.connect(start_boss_rush)
	EventBus.enemy_killed.connect(_on_enemy_killed_boss_rush)
	EventBus.tower_start_requested.connect(start_tower)
	EventBus.tower_blessing_picked.connect(apply_tower_blessing)
	EventBus.tower_exit_requested.connect(exit_tower)
	EventBus.soul_radar_pulsed.connect(_on_soul_radar_pulsed)
	EventBus.dan_lei_strike_requested.connect(_on_dan_lei_strike_requested)
	EventBus.realm_updated.connect(_on_realm_updated_fx)

	var init_spawn: Vector2 = Vector2.ZERO
	if PlayerData.has_saved_player_pos and PlayerData.saved_player_pos != Vector2.ZERO:
		init_spawn = PlayerData.saved_player_pos
		PlayerData.has_saved_player_pos = false
	load_map(PlayerData.current_map_id, init_spawn, false)
	call_deferred("_announce_initial_quest")


func _exit_tree() -> void:
	if EventBus.dan_lei_strike_requested.is_connected(_on_dan_lei_strike_requested):
		EventBus.dan_lei_strike_requested.disconnect(_on_dan_lei_strike_requested)
	if EventBus.realm_updated.is_connected(_on_realm_updated_fx):
		EventBus.realm_updated.disconnect(_on_realm_updated_fx)
	if boss_rush_mgr != null:
		boss_rush_mgr.world = null
		boss_rush_mgr = null
	if tower_mgr != null:
		tower_mgr.world = null
		tower_mgr = null


func _on_realm_updated_fx(_realm_title: String, _unlock_text: String) -> void:
	if player_node == null or not is_instance_valid(player_node):
		return
	EventBus.shockwave_requested.emit(player_node.global_position, 320.0, 0.052, Color("#FFD166"), 0.44)
	EventBus.screen_flash_requested.emit(Color("#FFD166"), 0.28, 0.22)


func _on_dan_lei_strike_requested(world_pos: Vector2, color_count: int = 5) -> void:
	var five_cols: Array = [Color("#FF595E"), Color("#4CC9F0"), Color("#FFFFFF"), Color("#FFD166"), Color("#C77DFF")]
	var n: int = clampi(color_count, 1, 5)
	var base_pos: Vector2 = world_pos
	if base_pos == Vector2.ZERO and player_node != null and is_instance_valid(player_node):
		base_pos = player_node.global_position
	for i in range(n):
		var ang: float = float(i) * (TAU / float(maxi(1, n)))
		var off: Vector2 = Vector2.ZERO if i == n - 1 else Vector2(cos(ang), sin(ang) * 0.55) * 92.0
		_dan_lei_queue.append({
			"delay": float(i) * 0.17,
			"pos": base_pos + off,
			"color": five_cols[i % five_cols.size()],
			"is_finale": (i == n - 1)
		})


func _tick_dan_lei_queue(delta: float) -> void:
	if _dan_lei_queue.is_empty():
		return
	var remain: Array = []
	for item in _dan_lei_queue:
		var d: float = float(item.get("delay", 0.0)) - delta
		if d <= 0.0:
			_spawn_dan_lei_bolt(item.get("pos", Vector2.ZERO) as Vector2, item.get("color", Color("#FFD166")) as Color, bool(item.get("is_finale", false)))
		else:
			item["delay"] = d
			remain.append(item)
	_dan_lei_queue = remain


func _spawn_dan_lei_bolt(strike_pos: Vector2, bolt_col: Color, is_finale: bool) -> void:
	var entities_root: Node = get_node_or_null("Entities")
	if entities_root == null:
		return
	var pillar := SkillVfxBurst.new()
	entities_root.add_child(pillar)
	pillar.configure(
		"dan_lei_pillar",
		strike_pos,
		Vector2.DOWN,
		220.0 if is_finale else 160.0,
		0.72 if is_finale else 0.56,
		Color("#FFFFFF"),
		bolt_col,
		bolt_col.darkened(0.40),
		{ "z_index": 7 }
	)
	VfxAssets.spawn_ground_crater(entities_root, strike_pos, 115.0 if is_finale else 80.0, bolt_col, 3.0)
	VfxAssets.spawn_spark_burst(entities_root, strike_pos + Vector2(0, -16), Color.WHITE, bolt_col, 24 if is_finale else 14, 110.0, 320.0, 0.44, Vector2.UP, 180.0, 0.28, 0.72, true)
	EventBus.audio_sfx_requested.emit("breakthrough" if is_finale else "skill_burst")
	EventBus.screen_shake_requested.emit(14.0 if is_finale else 8.0, 0.32 if is_finale else 0.18)
	EventBus.shockwave_requested.emit(strike_pos, 340.0 if is_finale else 220.0, 0.056 if is_finale else 0.036, bolt_col, 0.40)
	EventBus.screen_flash_requested.emit(bolt_col, 0.30 if is_finale else 0.18, 0.20)


func _announce_initial_quest() -> void:
	if PlayerData.is_demo_mode:
		EventBus.banter_triggered.emit("CHẾ ĐỘ DEMO FULL: Mở toàn bộ %d Map (bấm [M] Dịch Chuyển Nhanh), 15 Đấu Kỹ, [F] Phật Nộ Hỏa Liên 4 Hỏa, 28 Dị Hỏa [H] & 4 Đồng Hành [G]!" % GameDatabase.maps_ordered.size())
		EventBus.quest_updated.emit()
	else:
		PlayerData.trigger_initial_quest_banter()


func restore_map_bgm() -> void:
	EventBus.bgm_requested.emit(current_map_bgm)


func setup_arena_stage(arena_def: Dictionary, spawn_pt: Vector2) -> void:
	current_map_id = str(arena_def.get("id", "tam_ma_luyen_canh"))
	current_map_bgm = str(arena_def.get("bgm", "bgm_boss"))
	current_is_forest = false
	interact_cooldown = 0.25

	var sz_arr: Array = arena_def.get("size", [1280, 896])
	map_size = Vector2(float(sz_arr[0]), float(sz_arr[1]))
	map_rect = Rect2(64.0, 64.0, map_size.x - 128.0, map_size.y - 128.0)

	_clear_current_map_nodes()
	current_npc_defs = []
	_build_tiled_ground(arena_def)
	_build_atmosphere_and_boundaries(arena_def)
	_build_signs(arena_def)
	_build_props(arena_def)

	PlayerData.recalculate_and_clamp(true)
	EventBus.stats_changed.emit()

	if player_node != null:
		player_node.global_position = spawn_pt
		player_node.reset_physics_interpolation()
		if player_node.has_method("set_camera_limits"):
			player_node.set_camera_limits(int(map_size.x), int(map_size.y))
		var cam_node: Camera2D = player_node.get_node_or_null("Camera2D") as Camera2D
		if cam_node != null:
			cam_node.reset_smoothing()
			cam_node.reset_physics_interpolation()

	_sync_active_companion(spawn_pt)
	EventBus.boss_status_updated.emit("", "", 0.0, 1.0, 1, false)
	EventBus.boss_poise_updated.emit(0.0, 1.0, false, false)


func load_map(map_id: String, custom_spawn: Vector2 = Vector2.ZERO, should_autosave: bool = true) -> void:
	if boss_rush_mgr != null:
		boss_rush_mgr.reset_state()
	if tower_mgr != null and tower_mgr.is_active:
		tower_mgr.reset_state(true)

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
		player_node.reset_physics_interpolation()
		if player_node.has_method("set_camera_limits"):
			player_node.set_camera_limits(int(map_size.x), int(map_size.y))
		var cam_node: Camera2D = player_node.get_node_or_null("Camera2D") as Camera2D
		if cam_node != null:
			cam_node.reset_smoothing()
			cam_node.reset_physics_interpolation()

	_sync_active_companion(spawn_pt)
	EventBus.boss_status_updated.emit("", "", 0.0, 1.0, 1, false)
	EventBus.boss_poise_updated.emit(0.0, 1.0, false, false)
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
	if tower_mgr != null:
		tower_mgr.sign_lbl = null
	radar_wave_timer = 0.0
	radar_ping_timer = 0.0
	radar_pinged_chests.clear()


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
	var comp: Node2D = COMPANION_SCENE.instantiate() as Node2D
	comp.global_position = anchor_pos + Vector2(-58, -16)
	entities_root.add_child(comp)
	comp.reset_physics_interpolation()
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

	_build_regional_weather(m_def)

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


func _make_soft_ambient_gradient(base_col: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.18, 0.78, 1.0])
	g.colors = PackedColorArray([
		Color(base_col.r, base_col.g, base_col.b, 0.0),
		base_col,
		Color(base_col.r, base_col.g, base_col.b, base_col.a * 0.80),
		Color(base_col.r, base_col.g, base_col.b, 0.0)
	])
	return g


func _build_regional_weather(m_def: Dictionary) -> void:
	var base_tile: String = str(m_def.get("base_tile", ""))
	var is_tower_arena: bool = (is_tower_active or current_map_id == "thien_phan_thap")
	var is_hac_giac_vuc: bool = (
		current_map_id == "ch05_rung_dem_huyet_vu"
		or current_map_id == "ch05_hac_an_thanh"
		or current_map_id == "ch05_hem_nui_hac_phong"
	)
	var is_gia_nam: bool = (
		current_map_id == "ch05_hoa_binh_tran"
		or current_map_id == "ch05_ngoai_vien_gia_nam"
		or current_map_id == "ch05_rung_san_hoa_nang"
	)
	var is_yunlan_high: bool = (
		current_map_id == "ch04_thien_thang_van_lam"
		or current_map_id == "ch04_dinh_van_lam_son"
		or current_map_id == "ch04_rung_phong_toa"
	)
	var is_volcanic: bool = (
		base_tile.find("volcanic_basalt") != -1
		or current_map_id == "ch03_dia_huyet_dung_nham"
	)
	var is_desert: bool = (
		base_tile.find("desert_sand") != -1
		or base_tile.find("sandstone_plaza") != -1
		or base_tile.find("oasis_turquoise") != -1
	)
	var is_forest_or_cave: bool = (
		current_is_forest
		or base_tile.find("bamboo_grass") != -1
		or current_map_id == "ch02_huyen_nhai_dong"
	)
	var is_boss_rush_arena: bool = (
		is_boss_rush_active
		or current_map_id == "tam_ma_luyen_canh"
		or base_tile.find("arena_violet") != -1
	)

	if is_tower_arena:
		# Thiên Phần Luyện Khí Tháp: Tàn lửa Vẫn Lạc Tâm Viêm (#FF4D6D / #FFD166) bốc cuộn dày đặc khắp đấu trường!
		var heart_embers := CPUParticles2D.new()
		heart_embers.position = map_size * 0.5
		heart_embers.emitting = true
		heart_embers.preprocess = 2.0
		heart_embers.amount = 74
		heart_embers.lifetime = 3.2
		heart_embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		heart_embers.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.48)
		heart_embers.direction = Vector2(0.08, -1.0).normalized()
		heart_embers.spread = 28.0
		heart_embers.gravity = Vector2(0.0, -34.0)
		heart_embers.initial_velocity_min = 42.0
		heart_embers.initial_velocity_max = 104.0
		heart_embers.scale_amount_min = 0.24
		heart_embers.scale_amount_max = 0.56
		VfxAssets.configure_glow_particles(heart_embers, Color("#FFD166"), Color("#FF4D6D"), false)
		map_overlay_root.add_child(heart_embers)

		var heart_streaks := CPUParticles2D.new()
		heart_streaks.position = map_size * 0.5
		heart_streaks.emitting = true
		heart_streaks.preprocess = 1.6
		heart_streaks.amount = 34
		heart_streaks.lifetime = 2.2
		heart_streaks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		heart_streaks.emission_rect_extents = Vector2(map_size.x * 0.46, map_size.y * 0.46)
		heart_streaks.direction = Vector2(0.0, -1.0)
		heart_streaks.spread = 18.0
		heart_streaks.gravity = Vector2(0.0, -48.0)
		heart_streaks.initial_velocity_min = 78.0
		heart_streaks.initial_velocity_max = 152.0
		heart_streaks.scale_amount_min = 0.28
		heart_streaks.scale_amount_max = 0.62
		VfxAssets.configure_glow_particles(heart_streaks, Color("#FFF3B0"), Color("#FF4D6D"), true)
		map_overlay_root.add_child(heart_streaks)

		var magma_haze := CPUParticles2D.new()
		magma_haze.position = map_size * 0.5
		magma_haze.emitting = true
		magma_haze.preprocess = 2.0
		magma_haze.amount = 18
		magma_haze.lifetime = 4.8
		magma_haze.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		magma_haze.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.46)
		magma_haze.direction = Vector2(0.06, -1.0).normalized()
		magma_haze.spread = 24.0
		magma_haze.gravity = Vector2(0.0, -12.0)
		magma_haze.initial_velocity_min = 18.0
		magma_haze.initial_velocity_max = 38.0
		magma_haze.scale_amount_min = 2.4
		magma_haze.scale_amount_max = 4.6
		magma_haze.texture = VfxAssets.get_smoke_puff_texture()
		magma_haze.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		magma_haze.color_ramp = _make_soft_ambient_gradient(Color(1.0, 0.30, 0.38, 0.12))
		magma_haze.color = Color.WHITE
		map_overlay_root.add_child(magma_haze)

	elif is_hac_giac_vuc:
		# Hắc Giác Vực (Rừng Đêm Huyết Vũ / Hắc Ấn Thành / Hẻm Núi Hắc Phong): Mưa đêm huyết-bạc xiên chéo + sương mù máu trôi lững lờ!
		var blood_rain := CPUParticles2D.new()
		blood_rain.position = map_size * 0.5
		blood_rain.emitting = true
		blood_rain.preprocess = 1.4
		blood_rain.amount = 76
		blood_rain.lifetime = 1.45
		blood_rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		blood_rain.emission_rect_extents = Vector2(map_size.x * 0.54, map_size.y * 0.52)
		blood_rain.direction = Vector2(-0.32, 1.0).normalized()
		blood_rain.spread = 4.0
		blood_rain.gravity = Vector2(-18.0, 65.0)
		blood_rain.initial_velocity_min = 270.0
		blood_rain.initial_velocity_max = 395.0
		blood_rain.particle_flag_align_y = true
		blood_rain.scale_amount_min = 0.50
		blood_rain.scale_amount_max = 1.15
		blood_rain.texture = VfxAssets.get_spark_streak_texture()
		blood_rain.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		var rain_grad := Gradient.new()
		rain_grad.offsets = PackedFloat32Array([0.0, 0.22, 0.78, 1.0])
		rain_grad.colors = PackedColorArray([
			Color(0.84, 0.88, 0.96, 0.0),
			Color(0.82, 0.86, 0.94, 0.48),
			Color(0.76, 0.14, 0.26, 0.42),
			Color(0.55, 0.08, 0.18, 0.0)
		])
		blood_rain.color_ramp = rain_grad
		blood_rain.color = Color.WHITE
		map_overlay_root.add_child(blood_rain)

		var blood_mist := CPUParticles2D.new()
		blood_mist.position = map_size * 0.5
		blood_mist.emitting = true
		blood_mist.preprocess = 2.4
		blood_mist.amount = 22
		blood_mist.lifetime = 6.8
		blood_mist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		blood_mist.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.48)
		blood_mist.direction = Vector2(-1.0, 0.12).normalized()
		blood_mist.spread = 18.0
		blood_mist.gravity = Vector2(-6.0, 0.0)
		blood_mist.initial_velocity_min = 18.0
		blood_mist.initial_velocity_max = 42.0
		blood_mist.scale_amount_min = 3.0
		blood_mist.scale_amount_max = 5.8
		blood_mist.texture = VfxAssets.get_smoke_puff_texture()
		blood_mist.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		blood_mist.color_ramp = _make_soft_ambient_gradient(Color(0.62, 0.12, 0.22, 0.15))
		blood_mist.color = Color.WHITE
		map_overlay_root.add_child(blood_mist)

	elif is_gia_nam:
		# Học Viện Già Nam (Hòa Bình Trấn / Ngoại Viện / Rừng Săn Hỏa Năng): Bụi nắng vàng ấm áp + cánh lá ngọc bích bay lả tả!
		var sunlit_motes := CPUParticles2D.new()
		sunlit_motes.position = map_size * 0.5
		sunlit_motes.emitting = true
		sunlit_motes.preprocess = 2.4
		sunlit_motes.amount = 44
		sunlit_motes.lifetime = 5.6
		sunlit_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		sunlit_motes.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.48)
		sunlit_motes.direction = Vector2(0.32, -1.0).normalized()
		sunlit_motes.spread = 65.0
		sunlit_motes.gravity = Vector2(2.0, -5.0)
		sunlit_motes.initial_velocity_min = 10.0
		sunlit_motes.initial_velocity_max = 26.0
		sunlit_motes.scale_amount_min = 0.20
		sunlit_motes.scale_amount_max = 0.42
		VfxAssets.configure_glow_particles(sunlit_motes, Color("#FFF9DB"), Color("#FFD166"), false)
		sunlit_motes.modulate.a = 0.80
		map_overlay_root.add_child(sunlit_motes)

		var jade_petals := CPUParticles2D.new()
		jade_petals.position = map_size * 0.5
		jade_petals.emitting = true
		jade_petals.preprocess = 2.4
		jade_petals.amount = 36
		jade_petals.lifetime = 6.2
		jade_petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		jade_petals.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		jade_petals.direction = Vector2(0.68, 0.72).normalized()
		jade_petals.spread = 24.0
		jade_petals.gravity = Vector2(8.0, 10.0)
		jade_petals.initial_velocity_min = 24.0
		jade_petals.initial_velocity_max = 54.0
		jade_petals.angle_min = -180.0
		jade_petals.angle_max = 180.0
		jade_petals.angular_velocity_min = -70.0
		jade_petals.angular_velocity_max = 70.0
		jade_petals.scale_amount_min = 0.28
		jade_petals.scale_amount_max = 0.54
		jade_petals.texture = VfxAssets.get_spark_streak_texture()
		jade_petals.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		var jade_grad := Gradient.new()
		jade_grad.offsets = PackedFloat32Array([0.0, 0.22, 0.76, 1.0])
		jade_grad.colors = PackedColorArray([
			Color(0.50, 0.93, 0.60, 0.0),
			Color(0.50, 0.93, 0.60, 0.78),
			Color(0.18, 0.77, 0.71, 0.58),
			Color(0.18, 0.77, 0.71, 0.0)
		])
		jade_petals.color_ramp = jade_grad
		jade_petals.color = Color.WHITE
		map_overlay_root.add_child(jade_petals)

	elif is_yunlan_high:
		# Vân Lam Sơn / Cao Nguyên Mây Trắng: Sương mây bồng bềnh + cánh hoa/mây xanh lam bay ngang!
		var cloud_mist := CPUParticles2D.new()
		cloud_mist.position = map_size * 0.5
		cloud_mist.emitting = true
		cloud_mist.preprocess = 2.6
		cloud_mist.amount = 24
		cloud_mist.lifetime = 7.6
		cloud_mist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		cloud_mist.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.48)
		cloud_mist.direction = Vector2(1.0, 0.14).normalized()
		cloud_mist.spread = 16.0
		cloud_mist.gravity = Vector2(4.0, 0.0)
		cloud_mist.initial_velocity_min = 24.0
		cloud_mist.initial_velocity_max = 52.0
		cloud_mist.scale_amount_min = 3.2
		cloud_mist.scale_amount_max = 6.4
		cloud_mist.texture = VfxAssets.get_smoke_puff_texture()
		cloud_mist.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		cloud_mist.color_ramp = _make_soft_ambient_gradient(Color(0.88, 0.94, 1.0, 0.16))
		cloud_mist.color = Color.WHITE
		map_overlay_root.add_child(cloud_mist)

		var cloud_petals := CPUParticles2D.new()
		cloud_petals.position = map_size * 0.5
		cloud_petals.emitting = true
		cloud_petals.preprocess = 2.2
		cloud_petals.amount = 36
		cloud_petals.lifetime = 6.2
		cloud_petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		cloud_petals.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		cloud_petals.direction = Vector2(0.86, 0.50).normalized()
		cloud_petals.spread = 24.0
		cloud_petals.gravity = Vector2(8.0, 6.0)
		cloud_petals.initial_velocity_min = 28.0
		cloud_petals.initial_velocity_max = 64.0
		cloud_petals.angle_min = -180.0
		cloud_petals.angle_max = 180.0
		cloud_petals.angular_velocity_min = -60.0
		cloud_petals.angular_velocity_max = 60.0
		cloud_petals.scale_amount_min = 0.28
		cloud_petals.scale_amount_max = 0.54
		cloud_petals.texture = VfxAssets.get_spark_streak_texture()
		cloud_petals.material = VfxAssets.get_additive_material()
		cloud_petals.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		var petal_grad := Gradient.new()
		petal_grad.offsets = PackedFloat32Array([0.0, 0.20, 0.72, 1.0])
		petal_grad.colors = PackedColorArray([
			Color(0.94, 0.98, 1.0, 0.0),
			Color(0.92, 0.98, 1.0, 0.78),
			Color(0.56, 0.86, 1.0, 0.52),
			Color(0.56, 0.86, 1.0, 0.0)
		])
		cloud_petals.color_ramp = petal_grad
		cloud_petals.color = Color.WHITE
		map_overlay_root.add_child(cloud_petals)

	elif is_volcanic:
		# Địa Huyệt Dung Nham / Phế Tích Tro Tàn: Tàn lửa nham thạch rực cháy bay lên khắp hang!
		var embers := CPUParticles2D.new()
		embers.position = map_size * 0.5
		embers.emitting = true
		embers.preprocess = 2.0
		embers.amount = 56
		embers.lifetime = 3.8
		embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		embers.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.48)
		embers.direction = Vector2(0.14, -1.0).normalized()
		embers.spread = 32.0
		embers.gravity = Vector2(0.0, -24.0)
		embers.initial_velocity_min = 26.0
		embers.initial_velocity_max = 66.0
		embers.scale_amount_min = 0.20
		embers.scale_amount_max = 0.48
		VfxAssets.configure_glow_particles(embers, Color("#FFF3B0"), Color("#FF6B00"), false)
		map_overlay_root.add_child(embers)

		var heat_haze := CPUParticles2D.new()
		heat_haze.position = map_size * 0.5
		heat_haze.emitting = true
		heat_haze.preprocess = 2.0
		heat_haze.amount = 16
		heat_haze.lifetime = 5.4
		heat_haze.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		heat_haze.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.46)
		heat_haze.direction = Vector2(0.08, -1.0).normalized()
		heat_haze.spread = 22.0
		heat_haze.gravity = Vector2(0.0, -10.0)
		heat_haze.initial_velocity_min = 14.0
		heat_haze.initial_velocity_max = 32.0
		heat_haze.scale_amount_min = 2.2
		heat_haze.scale_amount_max = 4.2
		heat_haze.texture = VfxAssets.get_smoke_puff_texture()
		heat_haze.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		heat_haze.color_ramp = _make_soft_ambient_gradient(Color(0.95, 0.42, 0.16, 0.10))
		heat_haze.color = Color.WHITE
		map_overlay_root.add_child(heat_haze)

	elif is_desert:
		# Sa Mạc Tháp Qua Nhĩ / Quảng Trường Sa Thạch: Luồng bão cát vàng quét chéo phải-xuống!
		var sand_streaks := CPUParticles2D.new()
		sand_streaks.position = map_size * 0.5
		sand_streaks.emitting = true
		sand_streaks.preprocess = 1.6
		sand_streaks.amount = 54
		sand_streaks.lifetime = 2.4
		sand_streaks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		sand_streaks.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.50)
		sand_streaks.direction = Vector2(1.0, 0.32).normalized()
		sand_streaks.spread = 10.0
		sand_streaks.gravity = Vector2(28.0, 10.0)
		sand_streaks.initial_velocity_min = 140.0
		sand_streaks.initial_velocity_max = 245.0
		sand_streaks.particle_flag_align_y = true
		sand_streaks.scale_amount_min = 0.55
		sand_streaks.scale_amount_max = 1.25
		sand_streaks.texture = VfxAssets.get_spark_streak_texture()
		sand_streaks.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		sand_streaks.color_ramp = _make_soft_ambient_gradient(Color(0.95, 0.80, 0.50, 0.36))
		sand_streaks.color = Color.WHITE
		map_overlay_root.add_child(sand_streaks)

		var sand_haze := CPUParticles2D.new()
		sand_haze.position = map_size * 0.5
		sand_haze.emitting = true
		sand_haze.preprocess = 2.0
		sand_haze.amount = 16
		sand_haze.lifetime = 5.2
		sand_haze.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		sand_haze.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.48)
		sand_haze.direction = Vector2(1.0, 0.28).normalized()
		sand_haze.spread = 14.0
		sand_haze.gravity = Vector2(10.0, 3.0)
		sand_haze.initial_velocity_min = 52.0
		sand_haze.initial_velocity_max = 96.0
		sand_haze.scale_amount_min = 2.4
		sand_haze.scale_amount_max = 4.6
		sand_haze.texture = VfxAssets.get_smoke_puff_texture()
		sand_haze.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		sand_haze.color_ramp = _make_soft_ambient_gradient(Color(0.95, 0.80, 0.50, 0.09))
		sand_haze.color = Color.WHITE
		map_overlay_root.add_child(sand_haze)

	elif is_forest_or_cave:
		# Rừng Trúc / Sơn Động: Đom đóm phát sáng dịu + lá trúc xanh lục lơ lửng rơi chéo xuống!
		var fireflies := CPUParticles2D.new()
		fireflies.position = map_size * 0.5
		fireflies.emitting = true
		fireflies.preprocess = 2.0
		fireflies.amount = 46
		fireflies.lifetime = 5.0
		fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		fireflies.emission_rect_extents = Vector2(map_size.x * 0.46, map_size.y * 0.46)
		fireflies.direction = Vector2(0.35, -1.0).normalized()
		fireflies.spread = 80.0
		fireflies.gravity = Vector2(0.0, -5.0)
		fireflies.initial_velocity_min = 8.0
		fireflies.initial_velocity_max = 22.0
		fireflies.scale_amount_min = 0.22
		fireflies.scale_amount_max = 0.44
		var ff_col: Color = Color("#70F5DF") if current_map_id == "ch02_huyen_nhai_dong" else (Color("#E0AAFF") if current_map_id == "ch02_noi_vi_su_vuong" else Color("#A8F5B0"))
		VfxAssets.configure_glow_particles(fireflies, Color.WHITE.lerp(ff_col, 0.35), ff_col, false)
		map_overlay_root.add_child(fireflies)

		var bamboo_leaves := CPUParticles2D.new()
		bamboo_leaves.position = map_size * 0.5
		bamboo_leaves.emitting = true
		bamboo_leaves.preprocess = 2.4
		bamboo_leaves.amount = 34
		bamboo_leaves.lifetime = 6.0
		bamboo_leaves.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		bamboo_leaves.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.48)
		bamboo_leaves.direction = Vector2(0.58, 0.82).normalized()
		bamboo_leaves.spread = 22.0
		bamboo_leaves.gravity = Vector2(6.0, 12.0)
		bamboo_leaves.initial_velocity_min = 24.0
		bamboo_leaves.initial_velocity_max = 52.0
		bamboo_leaves.angle_min = -180.0
		bamboo_leaves.angle_max = 180.0
		bamboo_leaves.angular_velocity_min = -65.0
		bamboo_leaves.angular_velocity_max = 65.0
		bamboo_leaves.scale_amount_min = 0.28
		bamboo_leaves.scale_amount_max = 0.54
		bamboo_leaves.texture = VfxAssets.get_spark_streak_texture()
		bamboo_leaves.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		var leaf_col := Color("#74C69D")
		bamboo_leaves.color_ramp = _make_soft_ambient_gradient(Color(leaf_col.r, leaf_col.g, leaf_col.b, 0.72))
		bamboo_leaves.color = Color.WHITE
		map_overlay_root.add_child(bamboo_leaves)

	elif is_boss_rush_arena:
		# Tâm Ma Luyện Cảnh: Linh khí tím huyền bí & tàn quang vàng bốc nhẹ quanh đấu trường!
		var arena_wisps := CPUParticles2D.new()
		arena_wisps.position = map_size * 0.5
		arena_wisps.emitting = true
		arena_wisps.preprocess = 2.0
		arena_wisps.amount = 42
		arena_wisps.lifetime = 4.6
		arena_wisps.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		arena_wisps.emission_rect_extents = Vector2(map_size.x * 0.46, map_size.y * 0.44)
		arena_wisps.direction = Vector2(0.0, -1.0)
		arena_wisps.spread = 45.0
		arena_wisps.gravity = Vector2(0.0, -12.0)
		arena_wisps.initial_velocity_min = 14.0
		arena_wisps.initial_velocity_max = 38.0
		arena_wisps.scale_amount_min = 0.20
		arena_wisps.scale_amount_max = 0.44
		VfxAssets.configure_glow_particles(arena_wisps, Color("#F3D5FF"), Color("#9D4EDD"), false)
		map_overlay_root.add_child(arena_wisps)

	else:
		# Đế Đô / Gia Tộc / Quảng Trường (courtyard_stone mặc định): Hạt linh khí vàng nhẹ bay lên êm ái!
		var qi_motes := CPUParticles2D.new()
		qi_motes.position = map_size * 0.5
		qi_motes.emitting = true
		qi_motes.preprocess = 2.4
		qi_motes.amount = 30
		qi_motes.lifetime = 6.2
		qi_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		qi_motes.emission_rect_extents = Vector2(map_size.x * 0.46, map_size.y * 0.46)
		qi_motes.direction = Vector2(0.18, -1.0).normalized()
		qi_motes.spread = 55.0
		qi_motes.gravity = Vector2(0.0, -4.0)
		qi_motes.initial_velocity_min = 6.0
		qi_motes.initial_velocity_max = 18.0
		qi_motes.scale_amount_min = 0.16
		qi_motes.scale_amount_max = 0.34
		VfxAssets.configure_glow_particles(qi_motes, Color("#FFF8D6"), Color("#FFD166"), false)
		qi_motes.modulate.a = 0.72
		map_overlay_root.add_child(qi_motes)


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
	var light_tex: Texture2D = TEX_LIGHT_RADIAL
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
	var halo_tex: Texture2D = VfxAssets.get_soft_halo_texture()

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

		# Quầng sáng Additive siêu nhẹ thay cho PointLight2D (giảm tải GPU gl_compatibility!)
		var glow := Sprite2D.new()
		glow.texture = halo_tex
		glow.material = VfxAssets.get_additive_material()
		glow.scale = Vector2(1.65, 1.65)
		glow.modulate = Color(1.0, 0.82, 0.40, 0.14 if is_opened else 0.48)
		glow.position = Vector2(0, -24)
		glow.z_index = -1
		root_ch.add_child(glow)

		var sp := Sprite2D.new()
		sp.texture = open_tex if is_opened else closed_tex
		sp.position = Vector2(0, -28)
		root_ch.add_child(sp)

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
	if not radar_pinged_chests.is_empty():
		var kept_rc: Array = []
		for rc_item in radar_pinged_chests:
			if rc_item is Dictionary and str(rc_item.get("id", "")) == cid:
				continue
			kept_rc.append(rc_item)
		radar_pinged_chests = kept_rc

	var sp: Sprite2D = c_entry.get("sprite_node", null) as Sprite2D
	if sp != null and is_instance_valid(sp):
		sp.texture = load("res://assets/sprites/props/chest_open.png")
	var glow: Sprite2D = c_entry.get("glow_node", null) as Sprite2D
	if glow != null and is_instance_valid(glow):
		glow.modulate.a = 0.14
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

		var halo_col: Color = Color("#FFE599")
		var glow_hex: String = str(d.get("glow_hex", ""))
		if glow_hex != "":
			halo_col = Color(glow_hex)
		elif role_str == "story_duoc_lao" or role_str == "story_hai_ba_dong":
			halo_col = Color("#70D6FF")
		elif role_str == "story_van_chi" or role_str == "story_thanh_lan" or role_str == "story_devour_thanh_lien":
			halo_col = Color("#2EC4B6")
		elif role_str == "secret_lang_anh" or role_str == "story_my_do_toa":
			halo_col = Color("#C77DFF")
		elif role_str == "story_thai_lan_pet":
			halo_col = Color("#72EFDD")

		# Quầng linh khí Additive siêu nhẹ thay cho PointLight2D trên từng NPC (giữ map < 12 đèn thực -> mượt GPU!)
		var glow := Sprite2D.new()
		glow.texture = VfxAssets.get_soft_halo_texture()
		glow.material = VfxAssets.get_additive_material()
		var is_floating: bool = bool(d.get("float_anim", false))
		var is_strong_aura: bool = (is_floating or role_str == "story_duoc_lao" or role_str == "story_van_chi" or role_str == "story_my_do_toa" or role_str == "story_devour_thanh_lien")
		glow.scale = Vector2(2.0, 2.0) if is_strong_aura else Vector2(1.55, 1.55)
		glow.modulate = Color(halo_col.r, halo_col.g, halo_col.b, 0.42 if is_strong_aura else 0.26)
		glow.position = Vector2(0, -36)
		glow.z_index = -1
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


func _on_story_flag_changed(flag_name: String) -> void:
	_sync_conditional_npcs()
	if flag_name == "ch08_dan_hoi_champion" and player_node != null and is_instance_valid(player_node):
		EventBus.dan_lei_strike_requested.emit(player_node.global_position, 5)
	elif (flag_name == "ch08_broke_dau_tong" or flag_name == "ch08_completed") and player_node != null and is_instance_valid(player_node):
		EventBus.shockwave_requested.emit(player_node.global_position, 390.0, 0.064, Color("#C77DFF") if flag_name == "ch08_completed" else Color("#72EFDD"), 0.48)
		EventBus.screen_flash_requested.emit(Color("#C77DFF") if flag_name == "ch08_completed" else Color("#72EFDD"), 0.34, 0.26)
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
	_tick_dan_lei_queue(delta)
	if boss_rush_mgr != null:
		boss_rush_mgr.tick(delta)

	if radar_wave_timer > 0.0:
		radar_wave_timer = maxf(0.0, radar_wave_timer - delta)
	if radar_ping_timer > 0.0:
		radar_ping_timer = maxf(0.0, radar_ping_timer - delta)
		if radar_ping_timer <= 0.0:
			radar_pinged_chests.clear()

	if tower_mgr != null:
		tower_mgr.tick(delta)

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
		"map_id": current_map_id,
		"map_size": map_size,
		"is_forest": current_is_forest,
		"zones": zone_draw_specs,
		"player_pos": player_node.global_position if player_node != null else Vector2.ZERO,
		"npcs": npcs_out,
		"portals": portals_out,
		"chests": chests_out,
		"enemies": enemies_out,
		"radar_active": radar_ping_timer > 0.0,
		"radar_radius": PlayerData.get_soul_radar_radius(),
		"radar_chests": radar_pinged_chests
	}


func get_quest_waypoint_world_pos() -> Vector2:
	if is_boss_rush_active or current_map_id == "tam_ma_luyen_canh" or is_tower_active or current_map_id == "thien_phan_thap":
		return Vector2.ZERO
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
# DATA-DRIVEN DIALOGUE RUNNER (ỦY QUYỀN SANG StoryDialogueRunner)
# =========================================================
func _run_data_driven_dialogue(dlg_def: Dictionary, npc_name: String, sprite_p: String) -> bool:
	return StoryDlgRunner.run_data_driven_dialogue(dlg_def, npc_name, sprite_p)


func _trigger_npc_interaction(npc_entry: Dictionary) -> void:
	StoryDlgRunner.trigger_npc_interaction(npc_entry)


func _spawn_from_slot(idx: int) -> void:
	var slot: Dictionary = spawn_slots[idx]
	var inst: CharacterBody2D = ENEMY_SCENE.instantiate() as CharacterBody2D
	entities_root.add_child(inst)
	var pos_val: Vector2 = slot.get("pos", Vector2(540, 420))
	if inst.has_method("configure_enemy"):
		inst.configure_enemy(str(slot.get("id", "moc_nhan")), pos_val)
	slot["ref"] = inst


# =========================================================
# PHÓ BẢN TÂM MA & THIÊN PHẦN THÁP (ỦY QUYỀN SANG BossRushManager / ThienPhanTowerManager)
# =========================================================
func record_boss_rush_player_damage(amount: float) -> void:
	if boss_rush_mgr != null:
		boss_rush_mgr.record_player_damage(amount)


func start_boss_rush(boss_id: String, diff_key: String = "normal") -> void:
	if boss_rush_mgr != null:
		boss_rush_mgr.start_boss_rush(boss_id, diff_key)


func _on_enemy_killed_boss_rush(enemy_id: String, _is_boss: bool) -> void:
	if boss_rush_mgr != null and boss_rush_mgr.is_active and enemy_id == boss_rush_mgr.boss_id:
		boss_rush_mgr.on_boss_defeated(enemy_id)
	if tower_mgr != null and tower_mgr.is_active and not tower_mgr.waiting_blessing:
		tower_mgr.prune_enemies()


func on_boss_rush_boss_defeated(defeated_id: String) -> void:
	if boss_rush_mgr != null:
		boss_rush_mgr.on_boss_defeated(defeated_id)


func exit_boss_rush() -> void:
	if boss_rush_mgr != null:
		boss_rush_mgr.exit_boss_rush()


func on_player_died_in_boss_rush() -> bool:
	return boss_rush_mgr.on_player_died() if boss_rush_mgr != null else false


func start_tower(start_floor: int = 1) -> void:
	if tower_mgr != null:
		tower_mgr.start_tower(start_floor)


func on_tower_enemy_defeated(enemy_node: Node) -> void:
	if tower_mgr != null:
		tower_mgr.on_enemy_defeated(enemy_node)


func apply_tower_blessing(blessing_id: String) -> void:
	if tower_mgr != null:
		tower_mgr.apply_blessing(blessing_id)


func exit_tower() -> void:
	if tower_mgr != null:
		tower_mgr.exit_tower()


func on_player_died_in_tower() -> bool:
	return tower_mgr.on_player_died() if tower_mgr != null else false


# =========================================================
# SOUL RADAR WAVE — CẢM ỨNG LINH HỒN QUÉT RƯƠNG & KẺ ĐỊCH
# =========================================================
func trigger_soul_radar(origin: Vector2 = Vector2.ZERO, radius_px: float = -1.0) -> void:
	var use_origin: Vector2 = origin
	if use_origin == Vector2.ZERO:
		if player_node == null:
			return
		use_origin = player_node.global_position
	var use_radius: float = radius_px if radius_px > 0.0 else PlayerData.get_soul_radar_radius()
	EventBus.soul_radar_pulsed.emit(use_origin, use_radius)


func _on_soul_radar_pulsed(origin: Vector2, radius_px: float) -> void:
	radar_wave_origin = origin
	radar_wave_max_radius = maxf(180.0, radius_px)
	radar_wave_duration = 0.95
	radar_wave_timer = radar_wave_duration
	radar_ping_timer = 8.0
	radar_pinged_chests.clear()

	for ch in chest_entries:
		if bool(ch.get("opened", false)):
			continue
		var cpos: Vector2 = ch.get("pos", Vector2.ZERO)
		if origin.distance_to(cpos) <= radar_wave_max_radius:
			radar_pinged_chests.append({
				"id": str(ch.get("id", "")),
				"pos": cpos
			})

	var enemies_found: int = 0
	for en in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(en) and en is Node2D:
			var en_nd: Node2D = en as Node2D
			if origin.distance_to(en_nd.global_position) <= radar_wave_max_radius:
				enemies_found += 1
				if en_nd.has_method("mark_radar_scanned"):
					en_nd.mark_radar_scanned(8.0)

	var soul_realm_name: String = PlayerData.get_soul_realm_name()
	EventBus.floating_text_requested.emit(
		origin + Vector2(0, -108),
		"PHÁT HIỆN: %d RƯƠNG · %d KẺ ĐỊCH" % [radar_pinged_chests.size(), enemies_found],
		Color("#72EFDD")
	)
	EventBus.banter_triggered.emit(
		"RADAR LINH HỒN (%s): Phát hiện %d Rương & %d Kẻ Địch!" % [soul_realm_name, radar_pinged_chests.size(), enemies_found]
	)
	queue_redraw()


func _spawn_floating_text(world_pos: Vector2, text_value: String, text_color: Color) -> void:
	var is_crit: bool = text_value.ends_with("!") and text_value.length() <= 14
	var is_big_cry: bool = text_value.length() > 14

	var lbl := Label.new()
	lbl.text = text_value
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font_sz: int = 23 if is_crit else (18 if is_big_cry else 17)
	lbl.add_theme_font_size_override("font_size", font_sz)

	if is_crit:
		lbl.add_theme_color_override("font_color", text_color.lerp(Color("#FFF8D6"), 0.28))
		lbl.add_theme_color_override("font_outline_color", Color("#3B1900"))
		lbl.add_theme_constant_override("outline_size", 6)
		lbl.add_theme_color_override("font_shadow_color", Color(1.0, 0.84, 0.24, 0.85))
		lbl.add_theme_constant_override("shadow_outline_size", 5)
		lbl.add_theme_constant_override("shadow_offset_x", 0)
		lbl.add_theme_constant_override("shadow_offset_y", 2)
		lbl.custom_minimum_size = Vector2(72.0, 0.0)
		lbl.pivot_offset = Vector2(36.0, 12.0)
		lbl.global_position = world_pos + Vector2(-36.0, -18.0)
		lbl.z_index = 14
	elif is_big_cry:
		lbl.add_theme_color_override("font_color", text_color)
		lbl.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.07, 1.0))
		lbl.add_theme_constant_override("outline_size", 5)
		lbl.custom_minimum_size = Vector2(240.0, 0.0)
		lbl.pivot_offset = Vector2(120.0, 12.0)
		lbl.global_position = world_pos + Vector2(-120.0, -20.0)
		lbl.z_index = 12
	else:
		lbl.add_theme_color_override("font_color", text_color)
		lbl.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.07, 1.0))
		lbl.add_theme_constant_override("outline_size", 5)
		lbl.custom_minimum_size = Vector2(72.0, 0.0)
		lbl.pivot_offset = Vector2(36.0, 12.0)
		lbl.global_position = world_pos + Vector2(-36.0, -16.0)
		lbl.z_index = 10

	floating_layer.add_child(lbl)

	var tw := lbl.create_tween()
	if is_crit:
		lbl.scale = Vector2(1.55, 1.55)
		var drift_x: float = randf_range(-28.0, 28.0)
		var start_y: float = lbl.position.y
		var peak_y: float = start_y - 56.0
		tw.set_parallel(true)
		tw.tween_property(lbl, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(lbl, "position:x", lbl.position.x + drift_x, 0.82).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(lbl, "modulate:a", 0.0, 0.50).set_delay(0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		var arc_tw := lbl.create_tween()
		arc_tw.tween_property(lbl, "position:y", peak_y, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		arc_tw.tween_property(lbl, "position:y", peak_y + 14.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(lbl.queue_free)
	elif is_big_cry:
		lbl.scale = Vector2(1.22, 1.22)
		tw.set_parallel(true)
		tw.tween_property(lbl, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(lbl, "position:y", lbl.position.y - 48.0, 1.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(lbl, "modulate:a", 0.0, 0.44).set_delay(0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.chain().tween_callback(lbl.queue_free)
	else:
		lbl.scale = Vector2(1.15, 1.15)
		tw.set_parallel(true)
		tw.tween_property(lbl, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(lbl, "position:y", lbl.position.y - 42.0, 0.76).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(lbl, "modulate:a", 0.0, 0.44).set_delay(0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
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
			if current_map_id == "thien_phan_thap":
				var pulse_f: float = 0.78 + sin(t_sec * 4.4) * 0.22
				draw_arc(center, rad, 0.0, TAU, 56, Color(1.0, 0.30, 0.42, 0.62 * pulse_f), 4.0)
				draw_arc(center, rad * 0.64, -t_sec * 0.65, -t_sec * 0.65 + TAU * 0.80, 44, Color(1.0, 0.82, 0.40, 0.52 * pulse_f), 2.6)
			elif current_map_id == "tam_ma_luyen_canh":
				var pulse_a: float = 0.78 + sin(t_sec * 3.2) * 0.22
				draw_arc(center, rad, 0.0, TAU, 56, Color(0.78, 0.48, 1.0, 0.58 * pulse_a), 3.6)
				draw_arc(center, rad * 0.62, t_sec * 0.45, t_sec * 0.45 + TAU * 0.82, 44, Color(1.0, 0.82, 0.38, 0.44 * pulse_a), 2.4)
			else:
				draw_arc(center, rad, 0.0, TAU, 56, Color(0.96, 0.75, 0.22, 0.50), 3.2)
				draw_arc(center, rad * 0.58, 0.0, TAU, 40, Color(0.96, 0.75, 0.22, 0.32), 2.2)

	var border_c: Color = Color("#FF6B00") if current_map_id == "thien_phan_thap" else (Color("#9D4EDD") if current_map_id == "tam_ma_luyen_canh" else Color("#4D7EA8"))
	draw_rect(map_rect, border_c, false, 4.5)

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

	# Sóng Radar Linh Hồn (Expanding Jade-Cyan Shockwave Ring)
	if radar_wave_timer > 0.0:
		var prog: float = 1.0 - (radar_wave_timer / maxf(0.01, radar_wave_duration))
		var ease_p: float = 1.0 - pow(1.0 - prog, 2.3)
		var cur_r: float = radar_wave_max_radius * ease_p
		var wave_a: float = clampf(1.0 - prog * prog, 0.0, 1.0)
		draw_circle(radar_wave_origin, cur_r, Color(0.18, 0.88, 0.78, 0.08 * wave_a))
		draw_arc(radar_wave_origin, cur_r, 0.0, TAU, 64, Color(0.45, 0.96, 0.88, 0.88 * wave_a), 4.2)
		if cur_r > 24.0:
			draw_arc(radar_wave_origin, cur_r * 0.78, 0.0, TAU, 56, Color(0.80, 1.0, 0.96, 0.50 * wave_a), 2.2)

	# Mũi tên định hướng & hào quang Rương kho báu được Radar Linh Hồn phát hiện
	if radar_ping_timer > 0.0 and not radar_pinged_chests.is_empty():
		var ping_a: float = clampf(radar_ping_timer / 1.2, 0.0, 1.0)
		var pulse_r: float = 0.65 + 0.35 * sin(t_sec * 6.5)
		var p_origin: Vector2 = player_node.global_position if player_node != null else radar_wave_origin
		for rc_item in radar_pinged_chests:
			if not (rc_item is Dictionary):
				continue
			var cpos: Vector2 = rc_item.get("pos", Vector2.ZERO)
			var ring_rad: float = 28.0 + sin(t_sec * 6.5) * 9.0
			draw_arc(cpos, ring_rad, 0.0, TAU, 32, Color(0.28, 0.96, 0.86, 0.85 * ping_a * pulse_r), 3.0)
			draw_arc(cpos, ring_rad + 12.0, t_sec * 2.0, t_sec * 2.0 + TAU * 0.65, 28, Color(1.0, 0.86, 0.42, 0.72 * ping_a), 2.2)

			var to_c: Vector2 = cpos - p_origin
			var dist_c: float = to_c.length()
			if dist_c > 96.0:
				var dir_c: Vector2 = to_c / dist_c
				var perp_c := Vector2(-dir_c.y, dir_c.x)
				var tip: Vector2 = p_origin + dir_c * (78.0 + sin(t_sec * 7.0) * 5.0)
				var base_l: Vector2 = tip - dir_c * 14.0 + perp_c * 9.0
				var base_r: Vector2 = tip - dir_c * 14.0 - perp_c * 9.0
				var chevron := PackedVector2Array([tip, base_l, tip - dir_c * 9.0, base_r])
				draw_colored_polygon(chevron, Color(0.32, 0.98, 0.86, 0.86 * ping_a * pulse_r))
				draw_polyline(PackedVector2Array([base_l, tip, base_r]), Color(1.0, 0.92, 0.55, 0.90 * ping_a), 2.0)
