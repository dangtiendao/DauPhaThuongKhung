extends CharacterBody2D
## Điều khiển Quái vật & Boss Đa Phase Mượt 60 FPS (Hướng A + Hướng B):
## - Hỗ trợ cả Sprite Sheet 4 khung hình động (0: Idle, 1: Stride/Dash, 2: Windup, 3: Strike/Cast) cho 8 Boss chính
##   lẫn hoạt ảnh động học mượt (Foot-anchored Pivot, Squash & Stretch, Lerp Quán Tính, Tàn Ảnh, Chém VFX, Hit-Squash, Tan Biến) cho toàn bộ 20 Quái & Boss!

@export var enemy_id: String = "moc_nhan"

const LOOT_SCENE: PackedScene = preload("res://scenes/entities/loot_pickup.tscn")
const ENEMY_PROJ_SCENE: PackedScene = preload("res://scenes/entities/enemy_projectile.tscn")
const TEX_LIGHT_RADIAL: Texture2D = preload("res://assets/sprites/vfx/light_radial_128.png")

var max_hp: float = 100.0
var cur_hp: float = 100.0
var atk_stat: float = 8.0
var def_stat: float = 2.0
var move_spd: float = 120.0
var detect_radius: float = 300.0
var attack_radius: float = 48.0
var realm_idx: int = 1
var exp_reward: int = 30
var ai_mode: String = "chaser"
var display_title: String = "Quái Vật"
var realm_badge: String = "Đấu Chi Khí"
var is_boss_unit: bool = false
var gold_reward: int = 15
var gear_drop_chance: float = 0.30
var gear_pool: Array = []
var allowed_rarities: Array = []
var drop_table: Array = []

var boss_phase: int = 1
var boss_bar_shown: bool = false
var wave_aim_dir: Vector2 = Vector2.RIGHT
var boss_special_cd: float = 2.4
var boss_shield_hp: float = 0.0
var boss_shield_timer: float = 0.0
var boss_combo_dashes_left: int = 0
var strafe_sign: float = 1.0
var spiral_angle_offset: float = 0.0

# Thanh Phá Thế (Boss Poise / Stagger), Cảnh Báo Giai Đoạn II & Chế Độ Đấu Trường Boss Rush
var max_poise: float = 100.0
var cur_poise: float = 0.0
var poise_stagger_timer: float = 0.0
var poise_decay_delay: float = 0.0
var is_boss_rush_instance: bool = false
var boss_rush_difficulty: String = "normal"
var _phase2_warned: bool = false
var _boss_rush_scaled: bool = false

# Thiên Phần Luyện Khí Tháp (Roguelite Tower)
var is_tower_instance: bool = false
var tower_floor_num: int = 1
var _tower_is_floor_boss: bool = false
var _tower_scaled: bool = false

# Linh Hồn Cảm Tri (Soul Radar Scanned Debuff)
var radar_scanned_timer: float = 0.0

# 4 Hình Thái Quái Mới: Burrower (Độn Thổ), Artillery (Pháo Kích), Shieldbearer (Khiên Trước), Bomber (Tự Bạo)
var burrow_cd: float = 0.0
var burrow_timer: float = 0.0
var is_burrowed: bool = false
var _burrow_dust_timer: float = 0.0
var _artillery_use_mortar: bool = true
var shield_dir: Vector2 = Vector2.RIGHT
var front_shield_broken_timer: float = 0.0
var is_priming_bomb: bool = false
var bomb_fuse_timer: float = 0.0

# Trạng thái bất lợi từ 28 Dị Hỏa (Làm chậm, Phá Giáp, Nổ Độc Dây Chuyền)
var slow_timer: float = 0.0
var slow_ratio: float = 0.0
var def_shred_timer: float = 0.0
var def_shred_ratio: float = 0.0
var poison_detonate_timer: float = 0.0
var poison_detonate_dmg: float = 0.0

# Động học mượt 60 FPS & Bộ điều khiển Sprite đa khung hình (4 / 6 / 8 / 12 / 16+ frame, dải ngang lẫn lưới)
var has_anim_sheet: bool = false
var anim_meta: Dictionary = {}
var is_floating_unit: bool = false
var is_dying: bool = false
var anim_phase: float = 0.0
var smooth_vel: Vector2 = Vector2.ZERO
var knockback_vel: Vector2 = Vector2.ZERO
var hit_flash_timer: float = 0.0
var hit_squash: float = 0.0
var attack_cd: float = 0.0
var stun_timer: float = 0.0

# Chuyển động trạng thái chiến đấu & VFX
var state_phase: String = "idle"
var state_timer: float = 0.0
var state_duration: float = 0.5
var charge_dir: Vector2 = Vector2.RIGHT
var strike_hold_timer: float = 0.0
var strike_dir: Vector2 = Vector2.RIGHT
var strike_vfx_timer: float = 0.0
var strike_vfx_radius: float = 85.0
var strike_vfx_is_nova: bool = false
var strike_vfx_color: Color = Color("#FF9F1C")
var afterimage_timer: float = 0.0
var gather_spark_timer: float = 0.0

var visual_scale: Vector2 = Vector2.ONE
var visual_rot: float = 0.0
var visual_offset: Vector2 = Vector2.ZERO
var base_scale_val: float = 1.0
var base_sprite_foot_y: float = 8.0
var sprite_offset_y: float = -48.0

var burn_dps_val: float = 0.0
var burn_remaining: float = 0.0
var burn_tick_accum: float = 0.0

var spawn_origin: Vector2 = Vector2.ZERO
var boss_light: PointLight2D
var char_motion_mat: ShaderMaterial
var _step_dust_cd: float = 0.0
var _windup_vfx_spawned: bool = false

@onready var body_sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("enemies")
	spawn_origin = global_position
	anim_phase = randf() * TAU
	_load_from_db()


func _exit_tree() -> void:
	if is_boss_unit and boss_bar_shown:
		boss_bar_shown = false
		EventBus.boss_status_updated.emit("", "", 0.0, 1.0, 1, false)
		EventBus.boss_poise_updated.emit(0.0, 1.0, false, false)


func configure_enemy(new_enemy_id: String, world_pos: Vector2) -> void:
	enemy_id = new_enemy_id
	global_position = world_pos
	spawn_origin = world_pos
	boss_phase = 1
	boss_bar_shown = false
	is_dying = false
	is_boss_rush_instance = false
	boss_rush_difficulty = "normal"
	_boss_rush_scaled = false
	is_tower_instance = false
	tower_floor_num = 1
	_tower_is_floor_boss = false
	_tower_scaled = false
	if is_inside_tree():
		_load_from_db()
		reset_physics_interpolation()


func configure_boss_rush(diff_key: String) -> void:
	is_boss_rush_instance = true
	boss_rush_difficulty = diff_key
	is_boss_unit = true
	detect_radius = maxf(detect_radius, 900.0)
	if is_inside_tree():
		if _boss_rush_scaled:
			_load_from_db()
		else:
			_apply_boss_rush_scaling()


func configure_tower_enemy(floor_num: int, is_floor_boss: bool) -> void:
	is_tower_instance = true
	tower_floor_num = maxi(1, floor_num)
	_tower_is_floor_boss = is_floor_boss
	detect_radius = maxf(detect_radius, 960.0)
	if is_floor_boss:
		is_boss_unit = true
	if is_inside_tree():
		if _tower_scaled:
			_load_from_db()
		else:
			_apply_tower_scaling()


func _apply_boss_rush_scaling() -> void:
	if _boss_rush_scaled:
		return
	_boss_rush_scaled = true
	is_boss_unit = true
	detect_radius = maxf(detect_radius, 900.0)
	if boss_rush_difficulty == "nightmare":
		max_hp *= 1.65
		cur_hp = max_hp
		atk_stat *= 1.35
		move_spd *= 1.12
		max_poise *= 1.25
	elif boss_rush_difficulty == "dau_tong":
		max_hp *= 2.45
		cur_hp = max_hp
		atk_stat *= 1.72
		move_spd *= 1.24
		max_poise *= 1.50
	else:
		cur_hp = max_hp


func _apply_tower_scaling() -> void:
	if _tower_scaled:
		return
	_tower_scaled = true
	detect_radius = maxf(detect_radius, 960.0)
	var floor_idx: float = float(maxi(1, tower_floor_num) - 1)
	var hp_scale: float = 1.0 + floor_idx * 0.28
	var atk_scale: float = 1.0 + floor_idx * 0.16
	var def_scale: float = 1.0 + floor_idx * 0.14
	var poise_scale: float = 1.0 + floor_idx * 0.12
	if _tower_is_floor_boss:
		is_boss_unit = true
		hp_scale *= 1.35
		poise_scale *= 1.25
	max_hp *= hp_scale
	cur_hp = max_hp
	atk_stat *= atk_scale
	def_stat *= def_scale
	max_poise *= poise_scale
	exp_reward = maxi(10, int(round(float(exp_reward) * (1.0 + floor_idx * 0.22))))
	if is_boss_unit:
		base_scale_val = 1.18
		visual_scale = Vector2(base_scale_val, base_scale_val)
		if body_sprite != null:
			body_sprite.scale = visual_scale
		if boss_light == null and is_inside_tree():
			boss_light = PointLight2D.new()
			boss_light.texture = TEX_LIGHT_RADIAL
			boss_light.texture_scale = 2.6
			boss_light.energy = 1.10
			boss_light.color = _get_signature_color()
			boss_light.position = Vector2(0, -32)
			add_child(boss_light)


func _load_from_db() -> void:
	var edef: Dictionary = GameDatabase.get_enemy_def(enemy_id)
	if edef.is_empty():
		return
	display_title = str(edef.get("name", enemy_id))
	realm_idx = int(edef.get("realm_index", 1))
	realm_badge = str(edef.get("realm_label", "Đấu Chi Khí"))
	ai_mode = str(edef.get("ai_type", "chaser"))
	max_hp = float(edef.get("max_hp", 100.0))
	cur_hp = max_hp
	atk_stat = float(edef.get("atk", 8.0))
	def_stat = float(edef.get("def", 2.0))
	move_spd = float(edef.get("move_speed", 120.0))
	detect_radius = float(edef.get("detect_range", 300.0))
	attack_radius = float(edef.get("attack_range", 48.0))
	exp_reward = int(edef.get("exp_reward", 30))
	gold_reward = int(edef.get("gold_reward", 15))
	gear_drop_chance = float(edef.get("gear_drop_chance", 0.30))
	gear_pool = edef.get("gear_pool", [])
	allowed_rarities = edef.get("allowed_rarities", [])
	is_boss_unit = bool(edef.get("is_boss", false))
	drop_table = edef.get("drops", [])
	is_floating_unit = (enemy_id == "hai_ba_dong_boss" or enemy_id == "co_ha_boss" or enemy_id == "tieu_tu_tinh_su_boss" or enemy_id == "lieu_tich_boss" or enemy_id == "van_lac_tam_viem_boss" or enemy_id == "han_phong_boss" or enemy_id == "van_son_boss" or enemy_id == "vu_ho_phap_boss" or enemy_id == "nhan_lac_thien_boss" or enemy_id == "han_phong_dau_tong_boss" or enemy_id == "dia_ma_lao_quy_boss" or enemy_id == "phi_thien_boss" or enemy_id == "phuong_thanh_nhi_boss" or enemy_id == "bang_ha_thanh_hai_boss" or enemy_id == "cuu_long_loi_cuong_boss" or enemy_id == "mo_cot_lao_nhan_boss" or enemy_id == "tam_thien_diem_viem_boss")
	boss_special_cd = 2.2
	boss_shield_hp = 0.0
	boss_shield_timer = 0.0
	boss_combo_dashes_left = 0
	strafe_sign = 1.0 if randf() < 0.5 else -1.0
	max_poise = 95.0 + float(realm_idx) * 28.0
	cur_poise = 0.0
	poise_stagger_timer = 0.0
	poise_decay_delay = 0.0
	_phase2_warned = false
	_boss_rush_scaled = false
	_tower_scaled = false
	radar_scanned_timer = 0.0
	burrow_cd = 0.0
	burrow_timer = 0.0
	is_burrowed = false
	_burrow_dust_timer = 0.0
	_artillery_use_mortar = true
	shield_dir = Vector2.RIGHT
	front_shield_broken_timer = 0.0
	is_priming_bomb = false
	bomb_fuse_timer = 0.0
	state_phase = "idle"
	state_timer = 0.0
	attack_cd = 0.0
	stun_timer = 0.0
	if is_boss_rush_instance:
		_apply_boss_rush_scaling()
	if is_tower_instance:
		_apply_tower_scaling()

	base_scale_val = 1.18 if is_boss_unit else 1.0
	visual_scale = Vector2(base_scale_val, base_scale_val)

	# Ưu tiên nạp Sprite Sheet đa khung hình (4 / 6 / 8 / 12 / 16+ frame, dải ngang hoặc lưới hframes×vframes)
	var anim_sheet_path: String = str(edef.get("anim_sheet", ""))
	var sprite_path: String = str(edef.get("sprite", ""))
	var explicit_anim_meta: Dictionary = edef.get("anim_meta", {}) if (edef.get("anim_meta", {}) is Dictionary) else {}
	if body_sprite != null:
		var loaded_anim: Texture2D = null
		if anim_sheet_path != "" and ResourceLoader.exists(anim_sheet_path):
			loaded_anim = load(anim_sheet_path)
		if loaded_anim != null:
			has_anim_sheet = true
			anim_meta = SpriteAnimHelper.inspect_sheet(loaded_anim, "enemy_anim", 4, 2, explicit_anim_meta)
			SpriteAnimHelper.apply_to_sprite(body_sprite, loaded_anim, anim_meta, base_sprite_foot_y)
			sprite_offset_y = float(anim_meta.get("foot_offset_y", -48.0))
			body_sprite.frame = 0
		elif sprite_path != "":
			var tex: Texture2D = load(sprite_path)
			if tex != null:
				anim_meta = SpriteAnimHelper.inspect_sheet(tex, "square", 1, 1, explicit_anim_meta)
				has_anim_sheet = (int(anim_meta.get("total_frames", 1)) > 1)
				SpriteAnimHelper.apply_to_sprite(body_sprite, tex, anim_meta, base_sprite_foot_y)
				sprite_offset_y = float(anim_meta.get("foot_offset_y", -48.0))
				body_sprite.frame = 0

		body_sprite.scale = visual_scale
		body_sprite.modulate = Color.WHITE

		if is_boss_unit or is_floating_unit:
			if char_motion_mat == null:
				char_motion_mat = VfxAssets.create_char_motion_material(_get_signature_color(), 0.008, 0.25 if is_boss_unit else 0.0)
			if char_motion_mat != null:
				body_sprite.material = char_motion_mat
				char_motion_mat.set_shader_parameter("hframes", float(body_sprite.hframes))
				char_motion_mat.set_shader_parameter("vframes", float(body_sprite.vframes))
				char_motion_mat.set_shader_parameter("rim_color", _get_signature_color())

		if is_boss_unit:
			if boss_light == null:
				boss_light = PointLight2D.new()
				boss_light.texture = TEX_LIGHT_RADIAL
				boss_light.texture_scale = 2.6
				boss_light.energy = 1.10
				boss_light.color = _get_signature_color()
				boss_light.position = Vector2(0, -32)
				add_child(boss_light)


func _get_signature_color() -> Color:
	if enemy_id == "phi_thien_boss":
		return Color("#72EFDD")
	elif enemy_id == "vuong_tran_boss":
		return Color("#E63946")
	elif enemy_id == "phuong_thanh_nhi_boss":
		return Color("#C77DFF")
	elif enemy_id == "bang_ha_thanh_hai_boss":
		return Color("#38BDF8")
	elif enemy_id == "cuu_long_loi_cuong_boss":
		return Color("#E2F1FF")
	elif enemy_id == "mo_cot_lao_nhan_boss":
		return Color("#9D4EDD")
	elif enemy_id == "tam_thien_diem_viem_boss":
		return Color("#A855F7")
	elif enemy_id == "van_son_boss":
		return Color("#72EFDD")
	elif enemy_id == "vu_ho_phap_boss":
		return Color("#E63946")
	elif enemy_id == "nhan_lac_thien_boss":
		return Color("#FFD166")
	elif enemy_id == "hat_tat_nham_boss":
		return Color("#70E000")
	elif enemy_id == "han_phong_dau_tong_boss":
		return Color("#38BDF8")
	elif enemy_id == "dia_ma_lao_quy_boss":
		return Color("#CAF0F8")
	elif enemy_id == "bach_thanh_boss":
		return Color("#90E0EF")
	elif enemy_id == "tuyet_ma_thien_vien_boss":
		return Color("#72EFDD")
	elif enemy_id == "lieu_kinh_boss":
		return Color("#FFD166")
	elif enemy_id == "van_lac_tam_viem_boss":
		return Color("#E0AAFF")
	elif enemy_id == "han_phong_boss":
		return Color("#00B4D8")
	elif enemy_id == "van_phan_boss":
		return Color("#70D6FF")
	elif enemy_id == "pham_lang_boss":
		return Color("#EF476F")
	elif enemy_id == "ngo_hao_boss":
		return Color("#FF2A5F")
	elif enemy_id == "la_hau_boss":
		return Color("#9D4EDD")
	elif enemy_id == "muc_xa_boss" or enemy_id == "tieu_tu_tinh_su_boss" or enemy_id == "mac_thua_boss" or enemy_id == "van_son_phan_than_boss":
		return Color("#C77DFF")
	elif enemy_id == "lieu_tich_boss" or enemy_id == "mac_ba_tu_boss" or enemy_id == "moc_chien_boss" or enemy_id == "viem_loi_boss":
		return Color("#52B788")
	elif enemy_id == "thach_khoi_boss" or enemy_id == "hai_ba_dong_boss" or enemy_id == "tieu_ninh_boss" or enemy_id == "nap_lan_yen_nhien_boss" or enemy_id == "van_yen_dai_tran_boss" or enemy_id == "van_lang_boss":
		return Color("#4CC9F0")
	elif enemy_id == "hoa_linh_xa_boss" or enemy_id == "co_ha_boss":
		return Color("#FF7B00")
	return Color("#FF4D6D")


func _get_ngo_hao_berserk_ratio() -> float:
	if enemy_id != "ngo_hao_boss":
		return 0.0
	var missing_ratio: float = clampf(1.0 - (cur_hp / maxf(1.0, max_hp)), 0.0, 1.0)
	return clampf(missing_ratio / 0.80, 0.0, 1.0)


func _get_effective_atk() -> float:
	var br: float = _get_ngo_hao_berserk_ratio()
	if br > 0.0:
		return atk_stat * (1.0 + 0.55 * br)
	return atk_stat


func mark_radar_scanned(duration: float = 8.0) -> void:
	if is_dying:
		return
	radar_scanned_timer = maxf(radar_scanned_timer, duration)
	if is_burrowed:
		is_burrowed = false
		burrow_timer = 0.0
		burrow_cd = maxf(burrow_cd, 4.5)
		if body_sprite != null:
			body_sprite.modulate.a = 1.0
		VfxAssets.spawn_dust_puff(get_parent(), global_position, Color(0.45, 0.94, 0.87, 0.55), 8, 120.0, 1.1)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "LỘ HÌNH!", Color("#72EFDD"))


func _update_body_modulate() -> void:
	if body_sprite == null or is_dying:
		return
	var target_a: float = 0.22 if is_burrowed else 1.0
	if enemy_id == "van_lac_tam_viem_boss" and radar_scanned_timer <= 0.0 and not is_burrowed:
		# Bản thể Vô Hình Tâm Hỏa (#14): nhấp nháy bán trong suốt trừ khi bị Linh Hồn Cảm Tri [Z] soi lộ hình!
		target_a = 0.62 + 0.30 * (0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.008))
	if hit_flash_timer > 0.0:
		if char_motion_mat != null:
			body_sprite.modulate = Color(1.0, 1.0, 1.0, target_a)
			char_motion_mat.set_shader_parameter("hit_flash", 1.0)
		else:
			body_sprite.modulate = Color(2.8, 2.8, 2.8, target_a)
	else:
		if char_motion_mat != null:
			char_motion_mat.set_shader_parameter("hit_flash", 0.0)
		if is_priming_bomb:
			var fuse_p: float = 1.0 - clampf(bomb_fuse_timer / 1.15, 0.0, 1.0)
			var flash_f: float = 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * (0.025 + 0.038 * fuse_p))
			var b_col: Color = Color("#FF3B30").lerp(Color("#FF9F1C"), flash_f)
			var boost: float = 1.30 + 0.55 * flash_f
			body_sprite.modulate = Color(b_col.r * boost, b_col.g * boost, b_col.b * boost, target_a)
		elif enemy_id == "ngo_hao_boss":
			var br: float = _get_ngo_hao_berserk_ratio()
			var base_c: Color = Color(1.16, 0.86, 0.90, 1.0) if boss_phase >= 2 else Color.WHITE
			var rage_c: Color = Color(1.38, 0.66, 0.72, 1.0)
			var c_out: Color = base_c.lerp(rage_c, br)
			body_sprite.modulate = Color(c_out.r, c_out.g, c_out.b, target_a)
		elif is_boss_unit and boss_phase >= 2:
			body_sprite.modulate = Color(1.16, 0.86, 0.90, target_a)
		else:
			body_sprite.modulate = Color(1.0, 1.0, 1.0, target_a)

	if char_motion_mat != null:
		var is_w: bool = (state_phase == "windup" or state_phase == "boss_nova" or state_phase == "boss_wave_windup" or state_phase == "boss_sig_windup")
		var rim_c: Color = Color("#FF2A5F") if (is_boss_unit and boss_phase >= 2) else _get_signature_color()
		var rim_s: float = 1.05 if is_w else (0.78 if (is_boss_unit and boss_phase >= 2) else (0.65 if strike_hold_timer > 0.0 else (0.28 if is_boss_unit else 0.0)))
		var sw_a: float = 0.013 if is_w else (0.010 if is_floating_unit else (0.008 if smooth_vel.length() <= 18.0 else 0.0045))
		var sw_s: float = 7.2 if is_w else (4.2 if is_floating_unit else 3.2)
		char_motion_mat.set_shader_parameter("rim_color", rim_c)
		char_motion_mat.set_shader_parameter("rim_strength", rim_s)
		char_motion_mat.set_shader_parameter("sway_amp", sw_a)
		char_motion_mat.set_shader_parameter("sway_speed", sw_s)


func _start_bomb_priming() -> void:
	if is_priming_bomb or is_dying:
		return
	is_priming_bomb = true
	bomb_fuse_timer = 1.15
	EventBus.audio_sfx_requested.emit("skill_fire")
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -96), "TỰ BẠO!", Color("#FF4D6D"))


func _detonate_bomber() -> void:
	if is_dying:
		return
	is_priming_bomb = false
	VfxAssets.spawn_spark_burst(get_parent(), global_position + Vector2(0, -24), Color("#FFF3B0"), Color("#FF3B30"), 34, 120.0, 320.0, 0.48, Vector2.UP, 180.0, 0.35, 0.78, true)
	VfxAssets.spawn_dust_puff(get_parent(), global_position + Vector2(0, -16), Color(0.95, 0.32, 0.16, 0.55), 10, 180.0, 1.55)
	EventBus.screen_shake_requested.emit(7.0, 0.28)
	EventBus.audio_sfx_requested.emit("skill_burst")
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "BÙM!!", Color("#FF4D6D"))
	var p_node: Node2D = _find_player()
	if p_node != null and global_position.distance_to(p_node.global_position) <= 125.0 and p_node.has_method("take_enemy_damage"):
		var push_d: Vector2 = (p_node.global_position - global_position).normalized()
		if push_d == Vector2.ZERO:
			push_d = Vector2.RIGHT
		p_node.take_enemy_damage(_get_effective_atk() * 1.9, realm_idx, push_d * 380.0)
	_die()


func _physics_process(delta: float) -> void:
	if is_dying:
		queue_redraw()
		return

	if hit_flash_timer > 0.0:
		hit_flash_timer = maxf(0.0, hit_flash_timer - delta)
	if radar_scanned_timer > 0.0:
		radar_scanned_timer = maxf(0.0, radar_scanned_timer - delta)
	if burrow_cd > 0.0 and not is_burrowed:
		burrow_cd = maxf(0.0, burrow_cd - delta)
	if front_shield_broken_timer > 0.0:
		front_shield_broken_timer = maxf(0.0, front_shield_broken_timer - delta)
	if is_priming_bomb:
		bomb_fuse_timer -= delta
		if bomb_fuse_timer <= 0.0:
			_detonate_bomber()
			return

	_update_body_modulate()

	if hit_squash > 0.0:
		hit_squash = maxf(0.0, hit_squash - delta * 6.5)
	if attack_cd > 0.0:
		attack_cd -= delta
	if boss_special_cd > 0.0:
		boss_special_cd -= delta
	if boss_shield_timer > 0.0:
		boss_shield_timer -= delta
		if boss_shield_timer <= 0.0:
			boss_shield_hp = 0.0
	if stun_timer > 0.0:
		stun_timer -= delta
	if poise_stagger_timer > 0.0:
		poise_stagger_timer = maxf(0.0, poise_stagger_timer - delta)
		if poise_stagger_timer <= 0.0:
			cur_poise = 0.0
	else:
		if poise_decay_delay > 0.0:
			poise_decay_delay = maxf(0.0, poise_decay_delay - delta)
		elif cur_poise > 0.0:
			cur_poise = maxf(0.0, cur_poise - max_poise * 0.09 * delta)
	if slow_timer > 0.0:
		slow_timer -= delta
		if slow_timer <= 0.0:
			slow_ratio = 0.0
	if def_shred_timer > 0.0:
		def_shred_timer -= delta
		if def_shred_timer <= 0.0:
			def_shred_ratio = 0.0
	if poison_detonate_timer > 0.0:
		poison_detonate_timer -= delta
	if strike_hold_timer > 0.0:
		strike_hold_timer -= delta
	if strike_vfx_timer > 0.0:
		strike_vfx_timer -= delta

	_process_burn_dot(delta)
	if is_dying:
		return
	knockback_vel = knockback_vel.move_toward(Vector2.ZERO, 980.0 * delta)

	var player_node: Node2D = _find_player()
	if is_boss_unit and player_node != null:
		_sync_boss_hud_bar(player_node)

	var ai_vel: Vector2 = Vector2.ZERO
	if stun_timer <= 0.0 and player_node != null:
		ai_vel = _compute_ai_velocity(delta, player_node)

	# Quán tính vận tốc mượt 60 FPS (không giật phanh đột ngột!)
	var accel_k: float = 15.0 if state_phase == "charging" else 9.5
	smooth_vel = smooth_vel.lerp(ai_vel, minf(1.0, delta * accel_k))

	# Cập nhật hoạt ảnh 4-frame & Động học Squash/Stretch + Tàn ảnh
	_update_smooth_animation(delta)

	velocity = smooth_vel + knockback_vel
	move_and_slide()
	queue_redraw()


func _update_smooth_animation(delta: float) -> void:
	if ai_mode == "dummy" or body_sprite == null:
		return

	var base_sc: float = (1.24 if boss_phase >= 2 else 1.18) if is_boss_unit else 1.0
	var spd: float = smooth_vel.length()
	var moving: bool = spd > 18.0
	var face_sign: float = -1.0 if body_sprite.flip_h else 1.0

	var target_scale := Vector2(base_sc, base_sc)
	var target_rot: float = 0.0
	var target_off := Vector2.ZERO
	var anim_key: String = "idle"
	var state_prog_norm: float = 0.0

	var is_winding: bool = (state_phase == "windup" or state_phase == "boss_nova" or state_phase == "boss_wave_windup" or state_phase == "boss_sig_windup")
	if not is_winding:
		_windup_vfx_spawned = false

	if strike_hold_timer > 0.0:
		# Pha TUNG ĐÒN: Nhào người (Overshoot) + Giãn ngang sắc bén!
		anim_key = "strike"
		var k_st: float = clampf(strike_hold_timer / 0.28, 0.0, 1.0)
		state_prog_norm = 1.0 - k_st
		target_scale = Vector2(base_sc * (1.0 + 0.14 * k_st), base_sc * (1.0 - 0.10 * k_st))
		target_rot = face_sign * 0.14 * k_st
		target_off = strike_dir * (16.0 * k_st)

	elif state_phase == "charging":
		# Pha LAO HÚC: Kéo giãn theo tốc độ + Tàn ảnh mờ nối đuôi!
		anim_key = "move"
		anim_phase += delta * 14.0
		target_scale = Vector2(base_sc * 1.15, base_sc * 0.87)
		target_rot = face_sign * 0.17
		target_off = Vector2(0.0, -4.0)
		afterimage_timer -= delta
		if afterimage_timer <= 0.0:
			afterimage_timer = 0.055
			_spawn_afterimage()

	elif is_winding:
		# Pha GỒNG CHIÊU (Anticipation): Co nén lùi lại + Rung tích tụ linh khí!
		anim_key = "windup"
		var prog: float = 1.0 - clampf(state_timer / maxf(0.1, state_duration), 0.0, 1.0)
		state_prog_norm = prog
		var tremor: float = sin(float(Time.get_ticks_msec()) * 0.055) * (2.6 * prog)
		target_scale = Vector2(base_sc * (1.0 + 0.12 * prog), base_sc * (1.0 - 0.14 * prog))
		target_rot = -face_sign * (0.11 * prog)
		target_off = Vector2(-face_sign * 7.0 * prog + tremor, 2.0 * prog)

		if boss_light != null:
			boss_light.energy = lerpf(boss_light.energy, 1.95 if boss_phase >= 2 else 1.55, minf(1.0, delta * 10.0))

		if is_boss_unit and not _windup_vfx_spawned:
			_windup_vfx_spawned = true
			_spawn_enemy_vfx("windup_charge", global_position + Vector2(0, -28), wave_aim_dir, 82.0, clampf(state_duration, 0.28, 0.72), _get_signature_color(), { "follow_target": self, "follow_offset": Vector2(0, -28) })

		gather_spark_timer -= delta
		if gather_spark_timer <= 0.0:
			gather_spark_timer = 0.12
			_spawn_gather_sparks()

	elif moving:
		_windup_vfx_spawned = false
		# Pha DI CHUYỂN: Lướt/bước nhịp nhàng, nghiêng thân theo đà & nhún giãn mềm mại + bụi bước chân cho Boss!
		anim_key = "move"
		anim_phase += delta * clampf(spd * 0.068, 6.5, 13.5)
		var hop: float = absf(sin(anim_phase))
		var tilt: float = clampf(smooth_vel.x / maxf(80.0, move_spd), -1.0, 1.0) * 0.09
		target_scale = Vector2(base_sc * (1.0 - 0.045 * hop), base_sc * (1.0 + 0.055 * hop))
		target_rot = tilt + sin(anim_phase) * 0.035
		target_off = Vector2(0.0, -hop * (6.5 if is_boss_unit else 5.0))
		if is_floating_unit:
			target_off.y -= 5.0 + sin(anim_phase * 0.7) * 3.0
		elif is_boss_unit and not is_burrowed:
			_step_dust_cd -= delta
			if _step_dust_cd <= 0.0:
				_step_dust_cd = 0.24
				VfxAssets.spawn_dust_puff(get_parent(), global_position + Vector2(0, 10), Color(0.74, 0.76, 0.82, 0.42), 5, 85.0, 1.05)
			if spd > move_spd * 1.12:
				afterimage_timer -= delta
				if afterimage_timer <= 0.0:
					afterimage_timer = 0.12
					_spawn_afterimage()

	else:
		_windup_vfx_spawned = false
		# Pha ĐỨNG THỦ (Idle): Thở nhịp êm ái neo chắc bàn chân trên mặt đất!
		anim_key = "idle"
		anim_phase += delta * 3.0
		var br: float = sin(anim_phase) * 0.032
		target_scale = Vector2(base_sc * (1.0 - br * 0.6), base_sc * (1.0 + br))
		target_rot = sin(anim_phase * 0.5) * 0.015
		if is_floating_unit:
			target_off = Vector2(0.0, -5.0 + sin(anim_phase * 1.1) * 4.5)

	# Quái Tự Bạo (Bomber): phồng căng dữ dội trước khi nổ!
	if is_priming_bomb:
		var fuse_p: float = 1.0 - clampf(bomb_fuse_timer / 1.15, 0.0, 1.0)
		var swell: float = 1.0 + 0.36 * fuse_p + 0.07 * sin(float(Time.get_ticks_msec()) * 0.045)
		target_scale *= swell
		target_off.x += sin(float(Time.get_ticks_msec()) * 0.075) * (3.2 * fuse_p)

	# Cộng thêm biến dạng đàn hồi khi bị đánh trúng (Hit-Squash)!
	if hit_squash > 0.0:
		target_scale.x *= (1.0 + 0.18 * hit_squash)
		target_scale.y *= (1.0 - 0.16 * hit_squash)
		target_rot += -face_sign * 0.12 * hit_squash

	# Nội suy mượt mọi thông số transform (hết hẳn cảm giác giật cứng!)
	var smooth_k: float = minf(1.0, delta * 16.0)
	visual_scale = visual_scale.lerp(target_scale, smooth_k)
	visual_rot = lerpf(visual_rot, target_rot, smooth_k)
	visual_offset = visual_offset.lerp(target_off, smooth_k)

	body_sprite.scale = visual_scale
	body_sprite.rotation = visual_rot
	body_sprite.position = Vector2(0.0, base_sprite_foot_y) + visual_offset
	if has_anim_sheet:
		var frames_arr: PackedInt32Array = SpriteAnimHelper.get_enemy_state_frames(anim_meta, anim_key)
		var max_f: int = maxi(0, body_sprite.hframes * body_sprite.vframes - 1)
		if frames_arr.size() <= 1:
			body_sprite.frame = clampi(frames_arr[0] if frames_arr.size() == 1 else 0, 0, max_f)
		elif anim_key == "windup" or anim_key == "strike":
			var p_idx: int = clampi(int(state_prog_norm * float(frames_arr.size())), 0, frames_arr.size() - 1)
			body_sprite.frame = clampi(frames_arr[p_idx], 0, max_f)
		elif anim_key == "move" and state_phase == "charging":
			# Khi lao húc ưu tiên khung lướt cuối hàng Move
			var c_idx: int = frames_arr.size() - 1 if frames_arr.size() <= 2 else (int(anim_phase * 0.6) % frames_arr.size())
			body_sprite.frame = clampi(frames_arr[c_idx], 0, max_f)
		else:
			var loop_rate: float = 0.72 if anim_key == "idle" else 0.55
			var loop_idx: int = int(absf(anim_phase) * loop_rate) % frames_arr.size()
			body_sprite.frame = clampi(frames_arr[loop_idx], 0, max_f)

	if boss_light != null and not is_winding:
		var rest_e: float = 1.60 if boss_phase >= 2 else 1.10
		if enemy_id == "ngo_hao_boss":
			var br: float = _get_ngo_hao_berserk_ratio()
			rest_e += 0.85 * br
			boss_light.color = Color("#FF2A5F").lerp(Color("#FF0033"), br)
		boss_light.energy = lerpf(boss_light.energy, rest_e, minf(1.0, delta * 6.0))


func _spawn_afterimage() -> void:
	if get_parent() == null or body_sprite == null or body_sprite.texture == null:
		return
	var ghost := Sprite2D.new()
	ghost.texture = body_sprite.texture
	ghost.hframes = body_sprite.hframes
	ghost.vframes = body_sprite.vframes
	ghost.frame = body_sprite.frame
	ghost.flip_h = body_sprite.flip_h
	ghost.centered = body_sprite.centered
	ghost.offset = body_sprite.offset
	ghost.scale = body_sprite.scale
	ghost.rotation = body_sprite.rotation
	ghost.global_position = body_sprite.global_position
	ghost.material = VfxAssets.get_additive_material()
	var sig: Color = _get_signature_color()
	ghost.modulate = Color(sig.r, sig.g, sig.b, 0.55)
	get_parent().add_child(ghost)
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.24)
	tw.tween_callback(ghost.queue_free)


func _spawn_gather_sparks() -> void:
	var sig: Color = _get_signature_color()
	VfxAssets.spawn_spark_burst(get_parent(), global_position + Vector2(0, -32), Color.WHITE.lerp(sig, 0.35), sig, 6, 35.0, 88.0, 0.28, Vector2.UP, 180.0, 0.22, 0.44, false)


func _spawn_enemy_vfx(mode: String, world_pos: Vector2, dir_vec: Vector2, rad: float, dur: float, sig_col: Color, opts: Dictionary = {}) -> void:
	if get_parent() == null:
		return
	var vfx := SkillVfxBurst.new()
	get_parent().add_child(vfx)
	var core_c: Color = Color.WHITE.lerp(sig_col, 0.22)
	var outer_c: Color = sig_col.darkened(0.38)
	vfx.configure(mode, world_pos, dir_vec, rad, dur, core_c, sig_col, outer_c, opts)


func is_phase2_warning() -> bool:
	return is_boss_unit and boss_phase == 1 and cur_hp > max_hp * 0.55 and cur_hp <= max_hp * 0.67


func _check_phase2_warning() -> void:
	if not _phase2_warned and is_phase2_warning():
		_phase2_warned = true
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -112), "⚠ SẮP BỘC PHÁT GIAI ĐOẠN II!", Color("#FF4D6D"))


func _trigger_poise_break() -> void:
	poise_stagger_timer = 2.6
	stun_timer = maxf(stun_timer, 2.6)
	state_phase = "idle"
	boss_combo_dashes_left = 0
	cur_poise = max_poise
	EventBus.audio_sfx_requested.emit("poise_break")
	EventBus.screen_shake_requested.emit(8.5, 0.25)
	EventBus.trigger_hitstop(0.045, 0.08)
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -118), "PHÁ THẾ! (+35% DMG)", Color("#FFD166"))
	VfxAssets.spawn_spark_burst(get_parent(), global_position + Vector2(0, -30), Color("#FFFFFF"), Color("#FFD166"), 26, 120.0, 280.0, 0.45, Vector2.UP, 180.0, 0.32, 0.68, true)


func _sync_boss_hud_bar(player_node: Node2D) -> void:
	var dist: float = global_position.distance_to(player_node.global_position)
	if dist <= 560.0 or cur_hp < max_hp or is_boss_rush_instance or is_tower_instance:
		if not boss_bar_shown:
			boss_bar_shown = true
			EventBus.bgm_requested.emit("bgm_boss")
		EventBus.boss_status_updated.emit(display_title, realm_badge, cur_hp, max_hp, boss_phase, true)
		EventBus.boss_poise_updated.emit(cur_poise, max_poise, poise_stagger_timer > 0.0, is_phase2_warning())
	elif boss_bar_shown and dist > 720.0:
		boss_bar_shown = false
		EventBus.boss_status_updated.emit("", "", 0.0, 1.0, 1, false)
		EventBus.boss_poise_updated.emit(0.0, 1.0, false, false)
		_request_restore_map_bgm()


func _request_restore_map_bgm() -> void:
	var worlds: Array[Node] = get_tree().get_nodes_in_group("world_stage")
	if not worlds.is_empty() and worlds[0].has_method("restore_map_bgm"):
		worlds[0].restore_map_bgm()


func _trigger_boss_phase_2() -> void:
	boss_phase = 2
	state_phase = "idle"
	attack_cd = 0.75
	strike_hold_timer = 0.30
	strike_dir = Vector2(0, -1)
	strike_vfx_timer = 0.32
	strike_vfx_radius = 148.0
	strike_vfx_is_nova = true
	strike_vfx_color = _get_signature_color()
	_update_body_modulate()
	if boss_light != null:
		boss_light.color = Color("#FF2A5F")
		boss_light.energy = 1.75
		boss_light.texture_scale = 3.5

	EventBus.audio_sfx_requested.emit("boss_roar")
	EventBus.screen_shake_requested.emit(9.0, 0.35)
	var cry: String = "BỘC PHÁT GIAI ĐOẠN II!"
	if enemy_id == "tieu_ninh_boss":
		cry = "TĂNG KHÍ TÁN BỘC PHÁT — PHONG QUYỂN TÀN VÂN!"
	elif enemy_id == "tieu_ngoc_boss":
		cry = "TIÊU VIÊM HỖN ĐẢN — ĂN ROI ĐÂY!"
	elif enemy_id == "lieu_tich_boss":
		cry = "ĐỘC HỎA ĐỈNH BỘC PHÁT — DÁM ÁM SÁT BẢN DƯỢC SƯ?!"
	elif enemy_id == "gia_liet_ao_boss":
		cry = "GIA LIỆT HUYẾT CHIẾN — ĐẤU KHÍ CUỒNG BẠO!"
	elif enemy_id == "thach_khoi_boss":
		cry = "CƠ QUAN HỘ ĐỘNG KÍCH HOẠT TOÀN LỰC!"
	elif enemy_id == "tieu_tu_tinh_su_boss":
		cry = "GÀO!! TỬ TINH THÚ HỎA THIÊU RỤI KẺ ĐỘT NHẬP!"
	elif enemy_id == "muc_luc_boss":
		cry = "CHẾT ĐI TIỂU TỬ — TIỂU Y TIÊN LÀ CỦA TA!"
	elif enemy_id == "muc_xa_boss":
		cry = "LANG ĐẦU TRẬN — ĐẤU SƯ 2 TINH TOÀN LỰC!"
	elif enemy_id == "hai_ba_dong_boss":
		cry = "HÀN BĂNG NGƯNG LONG! ĐÓNG BĂNG KẺ XÂM NHẬP TIỆM BẢN ĐỒ!"
	elif enemy_id == "hoa_linh_xa_boss":
		cry = "SONG ĐẦU HỎA LINH XÀ PHUN NUNG CHẢY ĐỊA HUYỆT!"
	elif enemy_id == "mac_ba_tu_boss":
		cry = "XÀ NHÂN BÁT ĐẠI THỦ LĨNH — XÉ XÁC KẺ ĐỘT NHẬP THÁNH THÀNH!"
	elif enemy_id == "co_ha_boss":
		cry = "LỤC PHẨM ĐAN VƯƠNG CHI HỎA — GIAO THANH LIÊN ĐỊA TÂM HỎA RA ĐÂY!"
	elif enemy_id == "van_phan_boss":
		cry = "PHONG LÔI ĐỘNG CỬU THIÊN — TRƯỞNG LÃO VÂN LAM TÔNG TRUY SÁT ĐẾN CÙNG!"
	elif enemy_id == "pham_lang_boss":
		cry = "HUYẾT TÔNG BÍ PHÁP — PHỆ HUYẾT ĐOẠT HỒN, CHẾT ĐI TIÊU VIÊM!"
	elif enemy_id == "ngo_hao_boss":
		cry = "TU LA HUYẾT KIẾM KHAI PHONG — CÀNG ĐỔ MÁU TA CÀNG CUỒNG BẠO!"
	elif enemy_id == "la_hau_boss":
		cry = "U MINH LIỆT ĐỊA ẤN — LÃO SINH HẮC BẠCH QUAN SÁT KHÔNG DỄ VƯỢT QUA!"
	elif enemy_id == "bach_thanh_boss":
		cry = "BẠCH BANG SƯƠNG ĐAO — TÂN SINH CÁC NGƯƠI DÁM LẬP BÀN MÔN GIÀNH ĐỊA BÀN?!"
	elif enemy_id == "tuyet_ma_thien_vien_boss":
		cry = "GÀO Ồ!! TUYẾT MA HỐNG ĐỘNG SƠN HÀ — ĐỂ LẠI ĐỊA TÂM TÔI THỂ NHŨ!!"
	elif enemy_id == "lieu_kinh_boss":
		cry = "HA HA HA! THỐNG KHOÁI — TIẾP CHIÊU ĐẠI LIỆT PHÁCH QUAN TRẢO TOÀN LỰC CỦA TA!!"
	elif enemy_id == "van_lac_tam_viem_boss":
		cry = "VÔ HÌNH TÂM HỎA PHẦN THÂN — ĐẠI XÀ NUỐT CHỬNG BẢN NGUYÊN DỊ HỎA!!"
	elif enemy_id == "han_phong_boss":
		cry = "HẢI TÂM DIỄM (#15) THỦY HỎA SONG TUYỆT — SƯ ĐỆ NGỐC, CHẾT THEO LÃO BẤT TỬ ĐI!!"
	elif enemy_id == "van_son_boss":
		cry = "PHONG CHI CỰC: VẪN SÁT!! TIÊU VIÊM — DÙ NGƯƠI LÊN ĐẤU HOÀNG CŨNG ĐỪNG HÒNG THOÁT KHỎI ĐỈNH VÂN LAM SƠN!!"
	elif enemy_id == "vu_ho_phap_boss":
		cry = "KHÀ KHÀ KHÀ!! THIẾT TỎA HỒN XÍCH — LINH HỒN DƯỢC TRẦN HÔM NAY PHẢI THEO HỒN ĐIỆN TA!!"
	elif enemy_id == "nhan_lac_thien_boss":
		cry = "KIM NHẠN LẠC NHẬT TRẢM!! ĐẾ QUỐC VIÊM MINH MỚI LẬP MÀ DÁM CẢN ĐƯỜNG KIM NHẠN TÔNG TA?!"
	elif enemy_id == "hat_tat_nham_boss":
		cry = "VẠN HẠT ĐỘC PHÁP THÂN!! DÙ TA CÓ CHẾT CŨNG ẤN [MA ĐỘC BAN] LÊN NGỰC NGƯƠI!!"
	elif enemy_id == "han_phong_dau_tong_boss":
		cry = "TA ĐÃ ĐOẠT XÁ LÊN ĐẤU TÔNG RỒI!! HẢI TÂM TÀ HỎA & HỒN VỤ SẼ THIÊU CHÁY XÁC NGƯƠI!!"
	elif enemy_id == "dia_ma_lao_quy_boss":
		cry = "CỬU U HÀN BĂNG KHÔNG GIAN!! ĐẤU TÔNG THẤT TINH RA TAY — ĐỂ LẠI BỒ ĐỀ HÓA THỂ TIÊN!!"
	elif enemy_id == "phi_thien_boss":
		cry = "TAM THIÊN LÔI ĐỘNG LÀ BÍ HỌC BẮC CÁC!! ĐỂ LẠI BÍ TỊCH TRƯỚC LÔI NGỤC CỦA THIÊN LÔI TỬ!!"
	elif enemy_id == "vuong_tran_boss":
		cry = "HOÀNG TUYỀN HUYẾT SÁT!! SUẤT NGÂM THIÊN SƠN HUYẾT ĐÀM NÀY THUỘC VỀ HOÀNG TUYỀN CÁC!!"
	elif enemy_id == "phuong_thanh_nhi_boss":
		cry = "YÊU HOÀNG LÔI DỰC — PHONG LÔI CỰC PHÁ!! TIÊU VIÊM, ĐỪNG MƠ BƯỚC XUỐNG KHỎI LÔI SƠN!!"
	elif enemy_id == "bang_ha_thanh_hai_boss":
		cry = "BĂNG HÀ ĐÓNG BĂNG VẠN DẶM × HỒN ĐIỆN TỎA HỒN!! NỘP ÁCH NAN ĐỘC THỂ & LINH HỒN RA ĐÂY!!"
	elif enemy_id == "cuu_long_loi_cuong_boss":
		cry = "GÀO Ồ!! CỬU LONG LÔI CƯƠNG (#12) NGÂN LONG PHẦN THIÊN — ĐÓN TRỌN 10 HIỆP KHẢO NGHIỆM!!"
	elif enemy_id == "mo_cot_lao_nhan_boss":
		cry = "KHÀ KHÀ KHÀ!! TIỂU SÚC SINH ĐỆ TỬ CỦA DƯỢC TRẦN — #9 TAM THIÊN DIỄM VIÊM HỎA LÀ CỦA HỒN ĐIỆN!!"
	elif enemy_id == "tam_thien_diem_viem_boss":
		cry = "RỐNG NGÂN HÀ!! BẢN TÔN THÁI HƯ TỬ HẮC CỰ LONG (#9) BẤT TỬ BẤT DIỆT — THIÊU RỤI TINH VỰC!!"

	EventBus.floating_text_requested.emit(global_position + Vector2(0, -108), "GIAI ĐOẠN II — CUỒNG BẠO!", Color("#FF4D6D"))
	EventBus.shockwave_requested.emit(global_position, 290.0, 0.048, _get_signature_color(), 0.38)
	EventBus.screen_flash_requested.emit(_get_signature_color(), 0.20, 0.16)
	EventBus.banter_triggered.emit("[%s]: '%s' (Cẩn thận 3 tia sóng Đấu Khí — bấm Space để lướt né!)" % [display_title, cry])
	EventBus.boss_status_updated.emit(display_title, realm_badge, cur_hp, max_hp, boss_phase, true)
	if boss_bar_shown:
		EventBus.boss_poise_updated.emit(cur_poise, max_poise, poise_stagger_timer > 0.0, is_phase2_warning())


func _compute_ai_velocity(delta: float, player_node: Node2D) -> Vector2:
	if ai_mode == "dummy":
		return Vector2.ZERO

	var to_player: Vector2 = player_node.global_position - global_position
	var dist: float = to_player.length()
	# Thêm deadzone 14px chống lỗi nhấp nháy lật trái-phải liên tục khi đứng cùng trục X!
	if absf(to_player.x) > 14.0 and state_phase == "idle":
		body_sprite.flip_h = to_player.x < 0.0

	var slow_m: float = (1.0 - clampf(slow_ratio, 0.0, 0.60)) if slow_timer > 0.0 else 1.0

	if ai_mode == "chaser":
		if dist <= detect_radius and dist > 44.0:
			return to_player.normalized() * (move_spd * slow_m)
		elif dist <= 56.0 and attack_cd <= 0.0:
			_deal_melee_hit(player_node, 1.0)
			attack_cd = 1.15
		return Vector2.ZERO

	elif ai_mode == "charger":
		if state_phase == "idle":
			if dist <= attack_radius and attack_cd <= 0.0:
				state_phase = "windup"
				state_duration = 0.65
				state_timer = state_duration
				charge_dir = to_player.normalized()
				if absf(charge_dir.x) > 0.08:
					body_sprite.flip_h = charge_dir.x < 0.0
				return Vector2.ZERO
			elif dist <= detect_radius:
				return to_player.normalized() * (move_spd * slow_m)
		elif state_phase == "windup":
			state_timer -= delta
			if state_timer <= 0.0:
				state_phase = "charging"
				state_duration = 0.44
				state_timer = state_duration
				afterimage_timer = 0.0
			return Vector2.ZERO
		elif state_phase == "charging":
			state_timer -= delta
			if dist <= 54.0 and attack_cd <= 0.0:
				_deal_melee_hit(player_node, 1.45)
				attack_cd = 2.0
			if state_timer <= 0.0:
				state_phase = "idle"
				attack_cd = maxf(attack_cd, 1.6)
			return charge_dir * (move_spd * 3.1 * slow_m)

	elif ai_mode == "burrower":
		# Độn Thổ (Huyết Ảnh / Đạo Tặc): lặn xuống đất tăng tốc 1.85x áp sát rồi trồi lên nổ Pillar 78px!
		if is_burrowed:
			burrow_timer -= delta
			_burrow_dust_timer -= delta
			if _burrow_dust_timer <= 0.0:
				_burrow_dust_timer = 0.22
				VfxAssets.spawn_dust_puff(get_parent(), global_position, Color(0.60, 0.22, 0.24, 0.50), 4, 95.0, 0.85)
			if burrow_timer <= 0.0:
				is_burrowed = false
				burrow_cd = 5.5
				if body_sprite != null:
					body_sprite.modulate.a = 1.0
				_spawn_boss_hazard(player_node.global_position, "pillar", 78.0, 0.40, 0.35, _get_effective_atk() * 1.35, Color("#EF476F"))
				VfxAssets.spawn_dust_puff(get_parent(), global_position, Color(0.65, 0.28, 0.24, 0.58), 10, 145.0, 1.25)
				strike_hold_timer = 0.26
				strike_dir = to_player.normalized() if dist > 2.0 else Vector2.RIGHT
				strike_vfx_timer = 0.22
				strike_vfx_radius = 78.0
				strike_vfx_is_nova = true
				strike_vfx_color = Color("#EF476F")
				attack_cd = 1.15
				return Vector2.ZERO
			return (to_player.normalized() * (move_spd * 1.85 * slow_m)) if dist > 10.0 else Vector2.ZERO
		else:
			if dist <= detect_radius and burrow_cd <= 0.0:
				is_burrowed = true
				burrow_timer = 1.25
				burrow_cd = 5.5
				_burrow_dust_timer = 0.0
				if body_sprite != null:
					body_sprite.modulate.a = 0.22
				EventBus.audio_sfx_requested.emit("dash_whoosh")
				EventBus.floating_text_requested.emit(global_position + Vector2(0, -86), "ĐỘN THỔ!", Color("#EF476F"))
				VfxAssets.spawn_dust_puff(get_parent(), global_position, Color(0.55, 0.24, 0.24, 0.55), 8, 120.0, 1.1)
				return to_player.normalized() * (move_spd * 1.85 * slow_m) if dist > 10.0 else Vector2.ZERO
			elif dist <= detect_radius and dist > 44.0:
				return to_player.normalized() * (move_spd * slow_m)
			elif dist <= 56.0 and attack_cd <= 0.0:
				_deal_melee_hit(player_node, 1.0)
				attack_cd = 1.15
			return Vector2.ZERO

	elif ai_mode == "artillery":
		# Pháo Kích (Chấp Sự Vân Lam / Lão Sinh): giữ tầm 210–350px, lùi kite khi < 150px, bắn pháo mortar hoặc 2 tia quạt!
		if state_phase == "windup":
			state_timer -= delta
			if state_timer <= 0.0:
				var aim_d: Vector2 = to_player.normalized() if dist > 2.0 else charge_dir
				var sig_c: Color = _get_signature_color()
				if _artillery_use_mortar:
					var pred_pos: Vector2 = player_node.global_position
					if player_node is CharacterBody2D:
						pred_pos += ((player_node as CharacterBody2D).velocity * 0.45).limit_length(115.0)
					_spawn_boss_hazard(pred_pos, "pillar", 74.0, 0.75, 0.35, _get_effective_atk() * 1.25, sig_c)
				else:
					var p_style: String = "wave" if randf() < 0.5 else "orb"
					var orig: Vector2 = global_position + Vector2(0, -20)
					_spawn_boss_projectile(orig, aim_d.rotated(-0.17), 345.0, _get_effective_atk() * 1.05, sig_c, p_style)
					_spawn_boss_projectile(orig, aim_d.rotated(0.17), 345.0, _get_effective_atk() * 1.05, sig_c, p_style)
				_artillery_use_mortar = not _artillery_use_mortar
				strafe_sign = -strafe_sign
				EventBus.audio_sfx_requested.emit("skill_fire")
				strike_hold_timer = 0.24
				strike_dir = aim_d
				strike_vfx_timer = 0.20
				strike_vfx_radius = 68.0
				strike_vfx_is_nova = false
				strike_vfx_color = sig_c
				state_phase = "idle"
				attack_cd = 2.6
			return Vector2.ZERO
		elif dist <= detect_radius:
			if attack_cd <= 0.0:
				state_phase = "windup"
				state_duration = 0.45
				state_timer = state_duration
				charge_dir = to_player.normalized() if dist > 2.0 else Vector2.RIGHT
				wave_aim_dir = charge_dir
				if absf(charge_dir.x) > 0.08:
					body_sprite.flip_h = charge_dir.x < 0.0
				return Vector2.ZERO
			var dir_n: Vector2 = to_player.normalized() if dist > 2.0 else Vector2.RIGHT
			var strafe_v: Vector2 = Vector2(-dir_n.y, dir_n.x) * strafe_sign
			if dist < 150.0:
				return (-dir_n * 0.86 + strafe_v * 0.34).normalized() * (move_spd * slow_m)
			elif dist > 350.0:
				return dir_n * (move_spd * slow_m)
			elif dist < 210.0:
				return (-dir_n * 0.45 + strafe_v * 0.65).normalized() * (move_spd * 0.72 * slow_m)
			return strafe_v * (move_spd * 0.42 * slow_m)
		return Vector2.ZERO

	elif ai_mode == "shieldbearer":
		# Khiên Trước (Tinh Nhuệ Ngoại Viện): xoay khiên mượt hướng người chơi, đánh mặt trước bị giảm 60% trừ khi phá khiên!
		if front_shield_broken_timer <= 0.0 and dist > 4.0 and dist <= detect_radius * 1.2:
			var desired_dir: Vector2 = to_player.normalized()
			var max_turn: float = 2.6 * delta
			shield_dir = shield_dir.rotated(clampf(shield_dir.angle_to(desired_dir), -max_turn, max_turn)).normalized()
			if absf(shield_dir.x) > 0.15:
				body_sprite.flip_h = shield_dir.x < 0.0
		if dist <= detect_radius and dist > 48.0:
			return to_player.normalized() * (move_spd * 0.86 * slow_m)
		elif dist <= 60.0 and attack_cd <= 0.0:
			_deal_melee_hit(player_node, 1.15)
			attack_cd = 1.35
		return Vector2.ZERO

	elif ai_mode == "bomber":
		# Tự Bạo (Ác Đồ Hắc Ấn Thành): lao nước rút 1.22x, áp sát <= 92px hoặc HP <= 28% sẽ kích nổ sau 1.15s!
		if not is_priming_bomb and ((dist <= 92.0 and dist <= detect_radius) or cur_hp <= max_hp * 0.28):
			_start_bomb_priming()
		if is_priming_bomb:
			return (to_player.normalized() * (move_spd * 0.55 * slow_m)) if dist > 18.0 else Vector2.ZERO
		if dist <= detect_radius and dist > 20.0:
			return to_player.normalized() * (move_spd * 1.22 * slow_m)
		return Vector2.ZERO

	elif ai_mode == "boss_duelist":
		var berserk_t: float = _get_ngo_hao_berserk_ratio()
		var berserk_spd: float = 1.0 + 0.30 * berserk_t
		var berserk_cd: float = 1.0 / (1.0 + 0.30 * berserk_t)
		var p2_spd: float = (1.22 if boss_phase >= 2 else 1.0) * slow_m * berserk_spd
		var p2_cd_mult: float = (0.78 if boss_phase >= 2 else 1.0) * berserk_cd
		var is_kiter_boss: bool = (enemy_id == "lieu_tich_boss" or enemy_id == "co_ha_boss" or enemy_id == "hai_ba_dong_boss" or enemy_id == "viem_loi_boss" or enemy_id == "van_yen_dai_tran_boss" or enemy_id == "van_son_phan_than_boss" or enemy_id == "van_lac_tam_viem_boss" or enemy_id == "han_phong_boss" or enemy_id == "vu_ho_phap_boss" or enemy_id == "hat_tat_nham_boss" or enemy_id == "han_phong_dau_tong_boss" or enemy_id == "dia_ma_lao_quy_boss" or enemy_id == "bang_ha_thanh_hai_boss" or enemy_id == "cuu_long_loi_cuong_boss" or enemy_id == "mo_cot_lao_nhan_boss" or enemy_id == "tam_thien_diem_viem_boss")
		var is_agile_boss: bool = (enemy_id == "tieu_ngoc_boss" or enemy_id == "tieu_ninh_boss" or enemy_id == "mac_ba_tu_boss" or enemy_id == "nap_lan_yen_nhien_boss" or enemy_id == "van_lang_boss" or enemy_id == "van_phan_boss" or enemy_id == "ngo_hao_boss" or enemy_id == "la_hau_boss" or enemy_id == "bach_thanh_boss" or enemy_id == "lieu_kinh_boss" or enemy_id == "van_son_boss" or enemy_id == "nhan_lac_thien_boss" or enemy_id == "phi_thien_boss" or enemy_id == "vuong_tran_boss" or enemy_id == "phuong_thanh_nhi_boss")

		if state_phase == "idle":
			# 1. Chiêu Đặc Thù Riêng Của Từng Boss (Signature Skill — 20+ Boss đa phong cách!)
			if boss_special_cd <= 0.0 and dist <= detect_radius * 1.05:
				state_phase = "boss_sig_windup"
				state_duration = (0.56 if boss_phase >= 2 else 0.66) * berserk_cd
				state_timer = state_duration
				wave_aim_dir = to_player.normalized() if dist > 2.0 else Vector2.RIGHT
				if absf(wave_aim_dir.x) > 0.08:
					body_sprite.flip_h = wave_aim_dir.x < 0.0
				return Vector2.ZERO
			# 2. Chiêu sóng / đạn cơ bản (P2 hoặc Boss đánh xa)
			elif (boss_phase >= 2 or is_kiter_boss) and dist <= 430.0 and dist > 115.0 and attack_cd <= 0.0 and randf() < 0.52:
				state_phase = "boss_wave_windup"
				state_duration = 0.54 * berserk_cd
				state_timer = state_duration
				wave_aim_dir = to_player.normalized() if dist > 2.0 else Vector2.RIGHT
				if absf(wave_aim_dir.x) > 0.08:
					body_sprite.flip_h = wave_aim_dir.x < 0.0
				return Vector2.ZERO
			# 3. Nova cận chiến
			elif dist <= 122.0 and attack_cd <= 0.0:
				state_phase = "boss_nova"
				state_duration = (0.54 if boss_phase >= 2 else 0.64) * berserk_cd
				state_timer = state_duration
				return Vector2.ZERO
			# 4. Lao húc (không ưu tiên nếu là Boss đánh xa như Cổ Hà / Liễu Tịch)
			elif not is_kiter_boss and dist <= attack_radius and dist > 122.0 and attack_cd <= 0.0:
				state_phase = "windup"
				state_duration = (0.44 if boss_phase >= 2 else 0.54) * berserk_cd
				state_timer = state_duration
				boss_combo_dashes_left = 1 if (boss_phase >= 2 and (enemy_id == "tieu_ninh_boss" or enemy_id == "mac_ba_tu_boss" or enemy_id == "muc_xa_boss" or enemy_id == "nap_lan_yen_nhien_boss" or enemy_id == "van_lang_boss" or enemy_id == "van_phan_boss" or enemy_id == "ngo_hao_boss" or enemy_id == "bach_thanh_boss" or enemy_id == "lieu_kinh_boss")) else 0
				charge_dir = to_player.normalized() if dist > 2.0 else Vector2.RIGHT
				if absf(charge_dir.x) > 0.08:
					body_sprite.flip_h = charge_dir.x < 0.0
				return Vector2.ZERO
			elif dist <= detect_radius:
				# Di chuyển theo phong cách: Boss đánh xa giữ khoảng cách, Boss linh hoạt đảo vòng, Boss cận chiến áp sát!
				var dir_n: Vector2 = to_player.normalized() if dist > 2.0 else Vector2.RIGHT
				if is_kiter_boss and dist < 175.0:
					var strafe_v: Vector2 = Vector2(-dir_n.y, dir_n.x) * strafe_sign
					return (-dir_n * 0.78 + strafe_v * 0.62).normalized() * (move_spd * p2_spd)
				elif is_agile_boss and dist < 240.0:
					var strafe_v: Vector2 = Vector2(-dir_n.y, dir_n.x) * strafe_sign
					return (dir_n * 0.55 + strafe_v * 0.85).normalized() * (move_spd * p2_spd * 1.12)
				return dir_n * (move_spd * p2_spd)
		elif state_phase == "windup":
			state_timer -= delta
			if state_timer <= 0.0:
				state_phase = "charging"
				state_duration = 0.34
				state_timer = state_duration
				afterimage_timer = 0.0
			return Vector2.ZERO
		elif state_phase == "charging":
			state_timer -= delta
			if dist <= 64.0 and attack_cd <= 0.0:
				_deal_melee_hit(player_node, 1.40 if boss_phase >= 2 else 1.30)
				attack_cd = 0.85 * p2_cd_mult
			if state_timer <= 0.0:
				if boss_combo_dashes_left > 0:
					boss_combo_dashes_left -= 1
					strafe_sign = -strafe_sign
					state_phase = "windup"
					state_duration = 0.24 * berserk_cd
					state_timer = state_duration
					charge_dir = (player_node.global_position - global_position).normalized()
					if enemy_id == "mac_ba_tu_boss":
						charge_dir = charge_dir.rotated(strafe_sign * 0.22)
					if absf(charge_dir.x) > 0.08:
						body_sprite.flip_h = charge_dir.x < 0.0
				else:
					state_phase = "idle"
					attack_cd = 1.30 * p2_cd_mult
			return charge_dir * (move_spd * 3.0 * p2_spd)
		elif state_phase == "boss_nova":
			state_timer -= delta
			if state_timer <= 0.0:
				var nova_r: float = 156.0 if boss_phase >= 2 else 135.0
				strike_hold_timer = 0.30
				strike_dir = to_player.normalized() if dist > 4.0 else Vector2.RIGHT
				strike_vfx_timer = 0.28
				strike_vfx_radius = nova_r
				strike_vfx_is_nova = true
				strike_vfx_color = _get_signature_color()
				if dist <= nova_r:
					if enemy_id == "hai_ba_dong_boss":
						PlayerData.apply_player_slow(0.35, 2.0)
					_deal_melee_hit(player_node, 1.65 if boss_phase >= 2 else 1.50, false)
				EventBus.audio_sfx_requested.emit("skill_burst")
				EventBus.screen_shake_requested.emit(7.5, 0.22)
				state_phase = "idle"
				attack_cd = 1.80 * p2_cd_mult
			return Vector2.ZERO
		elif state_phase == "boss_wave_windup":
			state_timer -= delta
			if state_timer <= 0.0:
				_fire_boss_triple_wave()
				strike_hold_timer = 0.28
				strike_dir = wave_aim_dir
				strike_vfx_timer = 0.22
				strike_vfx_radius = 96.0
				strike_vfx_is_nova = false
				strike_vfx_color = _get_signature_color()
				_spawn_afterimage()
				_spawn_enemy_vfx("boss_strike_arc", global_position + Vector2(0, -24), wave_aim_dir, 108.0, 0.24, strike_vfx_color, { "flip_dir": -1.0 if body_sprite.flip_h else 1.0, "follow_target": self, "follow_offset": Vector2(0, -24) })
				state_phase = "idle"
				attack_cd = 2.05 * p2_cd_mult
			return Vector2.ZERO
		elif state_phase == "boss_sig_windup":
			state_timer -= delta
			if state_timer <= 0.0:
				state_phase = "idle"
				_execute_boss_signature_skill(player_node)
				strike_hold_timer = 0.32
				strike_dir = wave_aim_dir
				strike_vfx_timer = 0.28
				strike_vfx_radius = 120.0
				strike_vfx_is_nova = true
				strike_vfx_color = _get_signature_color()
				_spawn_afterimage()
				_spawn_enemy_vfx("boss_strike_arc", global_position + Vector2(0, -24), wave_aim_dir, 118.0, 0.26, strike_vfx_color, { "flip_dir": -1.0 if body_sprite.flip_h else 1.0 })
				boss_special_cd = (3.4 if boss_phase >= 2 else 4.6) * berserk_cd
				if state_phase == "idle":
					attack_cd = maxf(attack_cd, 1.15 * p2_cd_mult)
				strafe_sign = -strafe_sign
			return Vector2.ZERO

	return Vector2.ZERO


func _spawn_boss_projectile(origin: Vector2, dir: Vector2, spd: float, dmg: float, col: Color, style: String = "wave", slow_r: float = 0.0, slow_d: float = 0.0, homing: float = 0.0) -> void:
	if get_parent() == null:
		return
	var proj: Area2D = ENEMY_PROJ_SCENE.instantiate() as Area2D
	get_parent().add_child(proj)
	if proj.has_method("configure_projectile"):
		proj.configure_projectile(origin, dir, spd, dmg, realm_idx, col, style, slow_r, slow_d, homing)


func _spawn_boss_hazard(pos: Vector2, mode_str: String, rad: float, tele_s: float, act_s: float, dmg: float, col: Color, slow_r: float = 0.0, slow_d: float = 0.0, pull_s: float = 0.0) -> void:
	if get_parent() == null:
		return
	var hz := BossHazardZone.new()
	get_parent().add_child(hz)
	hz.configure_hazard(pos, mode_str, rad, tele_s, act_s, dmg, realm_idx, col, slow_r, slow_d, pull_s)


func _activate_boss_shield(hp_ratio: float, dur: float, label_txt: String, col: Color) -> void:
	boss_shield_hp = max_hp * hp_ratio
	boss_shield_timer = dur
	EventBus.audio_sfx_requested.emit("level_up")
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), label_txt, col)


func _execute_boss_signature_skill(player_node: Node2D) -> void:
	var sig_col: Color = _get_signature_color()
	var origin: Vector2 = global_position + Vector2(0, -20)
	var to_p: Vector2 = (player_node.global_position - global_position).normalized()
	if to_p == Vector2.ZERO:
		to_p = Vector2.RIGHT
	var p2: bool = (boss_phase >= 2)

	if enemy_id == "tieu_ninh_boss":
		# PHONG QUYỂN TÀN VÂN: Lốc gió kéo nhẹ + 4 tia phong nhận xoay!
		EventBus.audio_sfx_requested.emit("dash_whoosh")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "PHONG QUYỂN TÀN VÂN!", sig_col)
		_spawn_boss_hazard(player_node.global_position, "vortex", 84.0, 0.55, 1.8, atk_stat * 0.95, sig_col, 0.0, 0.0, 95.0)
		var cnt: int = 5 if p2 else 3
		for i in range(cnt):
			var off: float = (float(i) - float(cnt - 1) * 0.5) * 0.24
			_spawn_boss_projectile(origin, to_p.rotated(off), 385.0, atk_stat * 1.05, sig_col, "wave")

	elif enemy_id == "tieu_ngoc_boss":
		# SONG TIÊN LIÊN KÍCH: Đánh roi tốc độ cực cao + nhảy né vòng!
		EventBus.audio_sfx_requested.emit("swing_blade")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "SONG TIÊN PHÁ PHONG!", Color("#FF4D6D"))
		var whip_cnt: int = 4 if p2 else 2
		for i in range(whip_cnt):
			var off: float = (float(i) - float(whip_cnt - 1) * 0.5) * 0.20
			_spawn_boss_projectile(origin, to_p.rotated(off), 430.0, atk_stat * 1.0, Color("#FF4D6D"), "spear")
		knockback_vel = Vector2(-to_p.y, to_p.x) * strafe_sign * 260.0

	elif enemy_id == "lieu_tich_boss":
		# ĐỘC HỎA DƯỢC ĐỈNH: Ném 2-3 vũng độc hỏa xanh cháy lâu trên sàn!
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "ĐỘC HỎA ĐỈNH TRÌ!", Color("#52B788"))
		_spawn_boss_hazard(player_node.global_position, "pool", 78.0, 0.65, 3.6, atk_stat * 1.15, Color("#52B788"))
		if p2:
			_spawn_boss_hazard(player_node.global_position + Vector2(110, 0).rotated(randf() * TAU), "pool", 72.0, 0.72, 3.6, atk_stat * 1.10, Color("#52B788"))
			for i in range(4):
				var ang: float = to_p.angle() + (float(i) - 1.5) * 0.24
				_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 330.0, atk_stat * 1.0, Color("#52B788"), "orb")

	elif enemy_id == "gia_liet_ao_boss":
		# HUYẾT CHIẾN THẬP TỰ ĐAO: Phóng đao khí chữ thập 4 hướng (8 hướng ở Phase 2)!
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "HUYẾT ĐAO THẬP TỰ TRẢM!", Color("#FF4D6D"))
		var rays: int = 8 if p2 else 4
		spiral_angle_offset += 0.39
		for i in range(rays):
			var ang: float = spiral_angle_offset + float(i) * (TAU / float(rays))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 360.0, atk_stat * 1.18, Color("#FF4D6D"), "wave")

	elif enemy_id == "thach_khoi_boss":
		# THẠCH GIÁP HỘ THUẪN + ĐỊA CHẤN ĐÁ LĂN!
		EventBus.audio_sfx_requested.emit("skill_burst")
		if boss_shield_hp <= 0.0:
			_activate_boss_shield(0.18, 6.5, "THẠCH GIÁP HỘ THUẪN!", Color("#4CC9F0"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "ĐỊA CHẤN THẠCH BẠO!", Color("#4CC9F0"))
		var stones: int = 8 if p2 else 6
		for i in range(stones):
			var ang: float = float(i) * (TAU / float(stones)) + to_p.angle()
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 290.0, atk_stat * 1.15, Color("#4CC9F0"), "boulder")

	elif enemy_id == "tieu_tu_tinh_su_boss":
		# TỬ TINH HỎA CẦU (RƯỢT NHẸ) + SƯ VƯƠNG CUỒNG HỐNG!
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "TỬ TINH HỎA CẦU!", Color("#C77DFF"))
		var orbs: int = 4 if p2 else 3
		for i in range(orbs):
			var off: float = (float(i) - float(orbs - 1) * 0.5) * 0.42
			_spawn_boss_projectile(origin, to_p.rotated(off), 275.0, atk_stat * 1.15, Color("#C77DFF"), "orb", 0.0, 0.0, 2.2)
		if p2:
			_spawn_boss_hazard(player_node.global_position, "pillar", 96.0, 0.78, 0.45, atk_stat * 1.40, Color("#C77DFF"))

	elif enemy_id == "muc_luc_boss":
		# LANG NHA LIÊN THƯƠNG: Loạt thương khí sắc bén lao cực nhanh!
		EventBus.audio_sfx_requested.emit("swing_blade")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "LANG NHA LIÊN THƯƠNG!", Color("#FF758F"))
		var sp_cnt: int = 5 if p2 else 3
		for i in range(sp_cnt):
			var off: float = (float(i) - float(sp_cnt - 1) * 0.5) * 0.16
			_spawn_boss_projectile(origin, to_p.rotated(off), 455.0, atk_stat * 1.12, Color("#FF758F"), "spear")

	elif enemy_id == "muc_xa_boss":
		# LANG ĐẦU ĐẠI TRẬN: Quạt 5 tia + 2 trụ xung kích khóa góc (Phase 2 nổ 8 tia xoắn ốc)!
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "LANG ĐẦU ĐẠI TRẬN!", Color("#C77DFF"))
		var fan: int = 7 if p2 else 5
		for i in range(fan):
			var off: float = (float(i) - float(fan - 1) * 0.5) * 0.22
			_spawn_boss_projectile(origin, to_p.rotated(off), 375.0, atk_stat * 1.15, Color("#C77DFF"), "wave")
		_spawn_boss_hazard(player_node.global_position, "pillar", 86.0, 0.80, 0.40, atk_stat * 1.35, Color("#C77DFF"))
		if p2:
			_spawn_boss_hazard(player_node.global_position + to_p * 95.0, "pillar", 82.0, 0.95, 0.40, atk_stat * 1.35, Color("#FF4D6D"))

	elif enemy_id == "hai_ba_dong_boss":
		# HÀN BĂNG NGƯNG LONG: Khiên Hàn Băng + Băng Tiễn Làm Chậm + 2-3 Băng Trụ!
		EventBus.audio_sfx_requested.emit("skill_stun")
		if boss_shield_hp <= 0.0 and randf() < 0.55:
			_activate_boss_shield(0.16, 6.0, "HÀN BĂNG HỘ THUẪN!", Color("#70D6FF"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "HÀN BĂNG NGƯNG LONG!", Color("#70D6FF"))
		var ice_cnt: int = 6 if p2 else 4
		spiral_angle_offset += 0.45
		for i in range(ice_cnt):
			var ang: float = to_p.angle() + (float(i) - float(ice_cnt - 1) * 0.5) * 0.28 if not p2 else spiral_angle_offset + float(i) * (TAU / 6.0)
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 350.0, atk_stat * 1.12, Color("#70D6FF"), "spear", 0.38, 2.2)
		var pillar_cnt: int = 3 if p2 else 2
		for pi in range(pillar_cnt):
			var offset_p: Vector2 = Vector2.ZERO if pi == 0 else Vector2(randf_range(-115, 115), randf_range(-95, 95))
			_spawn_boss_hazard(player_node.global_position + offset_p, "pillar", 78.0, 0.82 + float(pi) * 0.14, 0.45, atk_stat * 1.25, Color("#70D6FF"), 0.42, 2.4)

	elif enemy_id == "hoa_linh_xa_boss":
		# SONG ĐẦU DUNG NHAM: Phóng song tuyến nham thạch từ 2 đầu rắn + tạo Hồ Dung Nham!
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "SONG ĐẦU PHUN DUNG NHAM!", Color("#FF7B00"))
		var perp: Vector2 = Vector2(-to_p.y, to_p.x)
		for side in [-1.0, 1.0]:
			var head_pos: Vector2 = origin + perp * (side * 28.0)
			_spawn_boss_projectile(head_pos, to_p.rotated(-side * 0.08), 385.0, atk_stat * 1.15, Color("#FF7B00"), "orb")
			_spawn_boss_projectile(head_pos, to_p.rotated(side * 0.22), 340.0, atk_stat * 1.08, Color("#FF4D6D"), "orb")
		_spawn_boss_hazard(player_node.global_position, "pool", 92.0, 0.70, 4.0, atk_stat * 1.25, Color("#FF7B00"))
		if p2:
			for k in range(8):
				var ang: float = float(k) * (TAU / 8.0)
				_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 310.0, atk_stat * 1.10, Color("#FF7B00"), "orb")

	elif enemy_id == "mac_ba_tu_boss":
		# XÀ NHÂN BÃO CÁT & ĐỘC MÂU: Lốc cát hút tâm + 5 mũi độc mâu!
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "BÃO CÁT XÀ VỰC & ĐỘC MÂU!", Color("#52B788"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 104.0, 0.60, 2.8, atk_stat * 1.15, Color("#FFD166"), 0.0, 0.0, 125.0)
		var spears: int = 5 if p2 else 3
		for i in range(spears):
			var off: float = (float(i) - float(spears - 1) * 0.5) * 0.18
			_spawn_boss_projectile(origin, to_p.rotated(off), 430.0, atk_stat * 1.12, Color("#52B788"), "spear")

	elif enemy_id == "co_ha_boss":
		# LỤC PHẨM ĐAN VƯƠNG HỎA: Khiên Đan Hỏa + 3-4 Cột Thiên Hỏa Đan Lô + Vòng 8 Cầu Lửa ở Phase 2!
		EventBus.audio_sfx_requested.emit("breakthrough")
		if boss_shield_hp <= 0.0 and randf() < 0.50:
			_activate_boss_shield(0.18, 6.0, "LỤC PHẨM HỎA THUẪN!", Color("#FFD166"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "ĐAN VƯƠNG THIÊN HỎA TRỤ!", Color("#FF9F1C"))
		var pillars: int = 4 if p2 else 3
		for pi in range(pillars):
			var spread_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(float(pi) * 2.1), sin(float(pi) * 2.1)) * 105.0
			_spawn_boss_hazard(player_node.global_position + spread_off, "pillar", 86.0, 0.80 + float(pi) * 0.16, 0.45, atk_stat * 1.35, Color("#FF9F1C"))
		if p2:
			spiral_angle_offset += 0.32
			for k in range(8):
				var ang: float = spiral_angle_offset + float(k) * (TAU / 8.0)
				_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 325.0, atk_stat * 1.12, Color("#FFD166"), "orb")

	# =========================================================
	# 7 BOSS ĐỘC QUYỀN CHƯƠNG 04 (ĐẾ ĐÔ & VÂN LAM SƠN)
	# =========================================================
	elif enemy_id == "mac_thua_boss":
		# QUÁI NHÂN MẶC THỪA: Không Gian Vặn Vẹo (hố đen hút tâm!) + Khiên Thú Hóa + 6 tia vuốt dị biến!
		EventBus.audio_sfx_requested.emit("boss_roar")
		if p2 and boss_shield_hp <= 0.0 and randf() < 0.55:
			_activate_boss_shield(0.18, 6.0, "THÚ HÓA VẢY MA THÚ!", Color("#9D4EDD"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "KHÔNG GIAN VẶN VẸO!", Color("#9D4EDD"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 118.0, 0.55, 3.0, atk_stat * 1.18, Color("#9D4EDD"), 0.0, 0.0, 155.0)
		var claws: int = 7 if p2 else 5
		for i in range(claws):
			var off: float = (float(i) - float(claws - 1) * 0.5) * 0.22
			_spawn_boss_projectile(origin, to_p.rotated(off), 395.0, atk_stat * 1.12, Color("#C77DFF"), "wave")

	elif enemy_id == "moc_chien_boss":
		# THIẾU GIA MỘC CHIẾN: Thanh Mộc Cự Phủ Trảm — Bổ nứt đất + 6 tảng địa chấn!
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "THANH MỘC CỰ PHỦ TRẢM!", Color("#52B788"))
		_spawn_boss_hazard(player_node.global_position, "pillar", 98.0, 0.78, 0.45, atk_stat * 1.38, Color("#52B788"))
		var rocks: int = 8 if p2 else 5
		for i in range(rocks):
			var off: float = (float(i) - float(rocks - 1) * 0.5) * 0.28
			_spawn_boss_projectile(origin, to_p.rotated(off), 305.0, atk_stat * 1.15, Color("#52B788"), "boulder")

	elif enemy_id == "viem_loi_boss":
		# VIÊM LỢI (XUẤT VÂN): Tà Hỏa Chấn Đỉnh — 2 vũng tà độc hỏa + 6-8 cầu tà hỏa xoay!
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "TÀ HỎA CHẤN ĐỈNH!", Color("#80ED99"))
		_spawn_boss_hazard(player_node.global_position, "pool", 90.0, 0.65, 4.0, atk_stat * 1.22, Color("#52B788"))
		if p2:
			_spawn_boss_hazard(player_node.global_position + to_p * 110.0, "pool", 82.0, 0.72, 4.0, atk_stat * 1.18, Color("#9D4EDD"))
		spiral_angle_offset += 0.35
		var t_orbs: int = 8 if p2 else 6
		for k in range(t_orbs):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(t_orbs))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 330.0, atk_stat * 1.12, Color("#52B788"), "orb")

	elif enemy_id == "nap_lan_yen_nhien_boss":
		# NẠP LAN YÊN NHIÊN (ƯỚC HẸN 3 NĂM): Phase 1 Phong Linh Phân Hình Kiếm | Phase 2 PHONG CHI CỰC: LẠC NHẬT DIỆU!
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "swing_blade")
		if p2:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "PHONG CHI CỰC: LẠC NHẬT DIỆU!!", Color("#FFD166"))
			_spawn_boss_hazard(player_node.global_position, "pillar", 126.0, 0.92, 0.55, atk_stat * 1.50, Color("#FFD166"))
			spiral_angle_offset += 0.25
			for k in range(8):
				var ang: float = spiral_angle_offset + float(k) * (TAU / 8.0)
				_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 430.0, atk_stat * 1.15, Color("#70D6FF"), "spear")
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -98), "PHONG LINH PHÂN HÌNH KIẾM!", Color("#70D6FF"))
			for i in range(5):
				var off: float = (float(i) - 2.0) * 0.19
				_spawn_boss_projectile(origin, to_p.rotated(off), 455.0, atk_stat * 1.12, Color("#70D6FF"), "spear")
			knockback_vel = Vector2(-to_p.y, to_p.x) * strafe_sign * 280.0

	elif enemy_id == "van_yen_dai_tran_boss":
		# VÂN YÊN PHÚC NHẬT ĐẠI TRẬN: Khiên Đại Trận + Xoáy Kiếm Mây Trắng + 4 Trụ Cự Kiếm!
		EventBus.audio_sfx_requested.emit("skill_stun")
		if boss_shield_hp <= 0.0 and randf() < 0.60:
			_activate_boss_shield(0.20, 6.5, "VÂN YÊN HỘ SƠN ĐẠI TRẬN!", Color("#A8DADC"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -100), "VÂN YÊN PHÚC NHẬT KIẾM TRẬN!", Color("#70D6FF"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 96.0, 0.55, 2.4, atk_stat * 1.10, Color("#A8DADC"), 0.25, 1.5, 110.0)
		var sw_cnt: int = 4 if p2 else 3
		for pi in range(sw_cnt):
			var ang_p: float = float(pi) * (TAU / float(sw_cnt)) + spiral_angle_offset
			_spawn_boss_hazard(player_node.global_position + Vector2(cos(ang_p), sin(ang_p)) * 115.0, "pillar", 76.0, 0.85, 0.45, atk_stat * 1.32, Color("#70D6FF"))
		spiral_angle_offset += 0.50

	elif enemy_id == "van_lang_boss":
		# ĐẠI TRƯỞNG LÃO VÂN LĂNG + ĐẤU TÔNG VÂN SƠN CAN THIỆP (KHÔNG GIAN ĐẠI THỦ ẤN!)
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "VÂN SƠN VẠN KIẾM & KHÔNG GIAN ĐẠI THỦ ẤN!", Color("#C77DFF"))
		# Không Gian Đại Thủ Ấn của Đấu Tông Vân Sơn giáng xuống vị trí người chơi!
		_spawn_boss_hazard(player_node.global_position, "pillar", 128.0, 0.95, 0.55, atk_stat * 1.48, Color("#9D4EDD"), 0.52, 2.4)
		var swords: int = 8 if p2 else 6
		for i in range(swords):
			var off: float = (float(i) - float(swords - 1) * 0.5) * 0.20
			_spawn_boss_projectile(origin, to_p.rotated(off), 440.0, atk_stat * 1.15, Color("#70D6FF"), "spear")

	elif enemy_id == "van_son_phan_than_boss":
		# ĐẤU TÔNG VÂN SƠN (HƯ ẢNH KHÔNG GIAN): Không Gian Phong Tỏa + 2 Đại Thủ Ấn + 8 Trăng Khuyết Không Gian!
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -106), "ĐẤU TÔNG: KHÔNG GIAN PHONG TỎA!!", Color("#9D4EDD"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 118.0, 0.55, 2.6, atk_stat * 1.20, Color("#9D4EDD"), 0.42, 2.0, 145.0)
		_spawn_boss_hazard(player_node.global_position + to_p * 85.0, "pillar", 118.0, 0.90, 0.50, atk_stat * 1.48, Color("#C77DFF"), 0.50, 2.2)
		spiral_angle_offset += 0.30
		var crescents: int = 10 if p2 else 8
		for k in range(crescents):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(crescents))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 410.0, atk_stat * 1.18, Color("#C77DFF"), "wave")

	# =========================================================
	# 4 BOSS ĐỘC QUYỀN CHƯƠNG 05 (HẮC GIÁC VỰC & GIÀ NAM HỌC VIỆN)
	# =========================================================
	elif enemy_id == "van_phan_boss":
		# TRƯỞNG LÃO VÂN PHÀN (PHONG LÔI): Quạt 5 phong kiếm "wave" + Lao đâm tốc độ cao; P2 tạo 2 lốc xoáy hút mạnh!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("dash_whoosh")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "PHONG LÔI NHẤT KIẾM!", Color("#70D6FF"))
		for i in range(5):
			var off: float = (float(i) - 2.0) * 0.19
			_spawn_boss_projectile(origin, to_p.rotated(off), 435.0, eff_atk * 1.15, Color("#70D6FF"), "wave")
		if p2:
			var perp_vp: Vector2 = Vector2(-to_p.y, to_p.x)
			_spawn_boss_hazard(player_node.global_position + perp_vp * 96.0, "vortex", 94.0, 0.55, 2.6, eff_atk * 1.14, Color("#70D6FF"), 0.0, 0.0, 160.0)
			_spawn_boss_hazard(player_node.global_position - perp_vp * 96.0, "vortex", 94.0, 0.55, 2.6, eff_atk * 1.14, Color("#70D6FF"), 0.0, 0.0, 160.0)
		# Lao xuyên tốc độ cao (high-speed piercing lunge)
		charge_dir = to_p
		state_phase = "charging"
		state_duration = 0.36
		state_timer = state_duration
		afterimage_timer = 0.0
		attack_cd = 0.0
		if absf(charge_dir.x) > 0.08:
			body_sprite.flip_h = charge_dir.x < 0.0

	elif enemy_id == "pham_lang_boss":
		# THIẾU TÔNG CHỦ HUYẾT TÔNG PHẠM LĂNG: 3 huyết đao rượt đuổi + Vũng Huyết Trì; P2 hấp huyết tạo khiên + xoáy kéo!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar" if p2 else "skill_fire")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "PHỆ HUYẾT TUYỀN QUA!", Color("#EF476F"))
		for i in range(3):
			var off: float = (float(i) - 1.0) * 0.34
			_spawn_boss_projectile(origin, to_p.rotated(off), 335.0, eff_atk * 1.16, Color("#EF476F"), "wave", 0.0, 0.0, 2.4)
		_spawn_boss_hazard(player_node.global_position, "pool", 88.0, 0.62, 3.6, eff_atk * 1.20, Color("#EF476F"))
		if p2:
			_spawn_boss_hazard(player_node.global_position + to_p * 105.0, "pool", 78.0, 0.72, 3.4, eff_atk * 1.15, Color("#EF476F"))
			if boss_shield_hp <= 0.0:
				_activate_boss_shield(0.18, 6.0, "HUYẾT VỤ HỘ THỂ!", Color("#EF476F"))
			else:
				boss_shield_hp = maxf(boss_shield_hp, max_hp * 0.14)
				boss_shield_timer = maxf(boss_shield_timer, 5.0)
			var vortex_dist: float = minf(110.0, global_position.distance_to(player_node.global_position) * 0.72)
			_spawn_boss_hazard(global_position + to_p * vortex_dist, "vortex", 116.0, 0.50, 2.6, eff_atk * 1.15, Color("#EF476F"), 0.22, 1.6, 155.0)

	elif enemy_id == "ngo_hao_boss":
		# TU LA HUYẾT KIẾM NGÔ HẠO (CUỒNG BẠO): Song trảm lao cực nhanh + Sóng xung kích chữ thập đỏ máu!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "HUYẾT TRẢM THẬP TỰ!", Color("#FF2A5F"))
		var perp_nh: Vector2 = Vector2(-to_p.y, to_p.x)
		var cross_center: Vector2 = player_node.global_position
		_spawn_boss_hazard(cross_center, "pillar", 66.0, 0.66, 0.38, eff_atk * 1.32, Color("#FF2A5F"))
		var cross_dirs: Array[Vector2] = [to_p, -to_p, perp_nh, -perp_nh]
		for cd in cross_dirs:
			_spawn_boss_hazard(cross_center + cd * 84.0, "pillar", 62.0, 0.76, 0.38, eff_atk * 1.24, Color("#FF2A5F"))
		# Song trảm liên hoàn (rapid double dash slash)
		charge_dir = to_p
		state_phase = "charging"
		state_duration = 0.28
		state_timer = state_duration
		boss_combo_dashes_left = 1
		afterimage_timer = 0.0
		attack_cd = 0.0
		if absf(charge_dir.x) > 0.08:
			body_sprite.flip_h = charge_dir.x < 0.0

	elif enemy_id == "la_hau_boss":
		# THỦ LĨNH HẮC BẠCH QUAN SÁT LA HẦU: P1 Phá Thạch Ám Kình (3 ám thương + ẩn ảnh sau lưng) | P2 U Minh Liệt Địa Ấn!
		var eff_atk: float = _get_effective_atk()
		# Ẩn ảnh tức thời ra sau lưng người chơi (an toàn không xuyên tường)
		_spawn_afterimage()
		VfxAssets.spawn_spark_burst(get_parent(), global_position + Vector2(0, -24), Color("#FFFFFF"), Color("#9D4EDD"), 14, 70.0, 180.0, 0.30, Vector2.UP, 180.0, 0.26, 0.52, true)
		var behind_pos: Vector2 = player_node.global_position + to_p * 96.0
		var blink_delta: Vector2 = behind_pos - global_position
		if not test_move(global_transform, blink_delta):
			global_position = behind_pos
			reset_physics_interpolation()
		else:
			var alt_pos: Vector2 = player_node.global_position - to_p * 74.0
			if not test_move(global_transform, alt_pos - global_position):
				global_position = alt_pos
				reset_physics_interpolation()
		VfxAssets.spawn_spark_burst(get_parent(), global_position + Vector2(0, -24), Color("#FFD166"), Color("#9D4EDD"), 16, 80.0, 200.0, 0.32, Vector2.UP, 180.0, 0.28, 0.56, true)
		var post_to_p: Vector2 = (player_node.global_position - global_position).normalized()
		if post_to_p == Vector2.ZERO:
			post_to_p = -to_p
		wave_aim_dir = post_to_p
		if absf(post_to_p.x) > 0.08:
			body_sprite.flip_h = post_to_p.x < 0.0
		var post_origin: Vector2 = global_position + Vector2(0, -20)

		if p2:
			EventBus.audio_sfx_requested.emit("breakthrough")
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -108), "U MINH LIỆT ĐỊA ẤN!!", Color("#FFD166"))
			for pi in range(4):
				var p_ang: float = float(pi) * (TAU * 0.25) + spiral_angle_offset
				var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(p_ang), sin(p_ang)) * (72.0 + float(pi) * 26.0)
				_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 88.0, 0.72 + float(pi) * 0.16, 0.45, eff_atk * 1.44, Color("#E09F3E"))
			spiral_angle_offset += 0.38
			for k in range(8):
				var orb_ang: float = spiral_angle_offset + float(k) * (TAU / 8.0)
				var orb_col: Color = Color("#FFD166") if (k % 2 == 0) else Color("#9D4EDD")
				_spawn_boss_projectile(post_origin, Vector2(cos(orb_ang), sin(orb_ang)), 335.0, eff_atk * 1.15, orb_col, "orb")
		else:
			EventBus.audio_sfx_requested.emit("swing_blade")
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "PHÁ THẠCH ÁM KÌNH!", Color("#9D4EDD"))
			for i in range(3):
				var off: float = (float(i) - 1.0) * 0.19
				_spawn_boss_projectile(post_origin, post_to_p.rotated(off), 450.0, eff_atk * 1.18, Color("#9D4EDD"), "spear")

	# =========================================================
	# 5 BOSS ĐỘC QUYỀN CHƯƠNG 06 (NỘI VIỆN GIÀ NAM & ĐÁY THÁP THIÊN PHẦN)
	# =========================================================
	elif enemy_id == "bach_thanh_boss":
		# THỦ LĨNH BẠCH BANG BẠCH THÀNH: Quạt 5-7 đao khí sương trắng + Lao chém chớp nhoáng để lại trụ băng làm chậm!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("swing_blade")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "BẠCH SƯƠNG ĐAO MẠNG!", Color("#90E0EF"))
		var w_cnt: int = 7 if p2 else 5
		for i in range(w_cnt):
			var off: float = (float(i) - float(w_cnt - 1) * 0.5) * 0.17
			_spawn_boss_projectile(origin, to_p.rotated(off), 445.0, eff_atk * 1.15, Color("#90E0EF"), "wave", 0.25, 1.5)
		_spawn_boss_hazard(player_node.global_position, "pillar", 80.0, 0.72, 0.42, eff_atk * 1.26, Color("#90E0EF"), 0.30, 1.8)
		charge_dir = to_p
		state_phase = "charging"
		state_duration = 0.32
		state_timer = state_duration
		boss_combo_dashes_left = 1 if p2 else 0
		afterimage_timer = 0.0
		attack_cd = 0.0
		if absf(charge_dir.x) > 0.08:
			body_sprite.flip_h = charge_dir.x < 0.0

	elif enemy_id == "tuyet_ma_thien_vien_boss":
		# TUYẾT MA THIÊN VIÊN (MA THÚ CẤP 5 ĐỈNH PHONG): Khiên Băng Giáp + Mưa Trụ Băng Thạch + 5-7 Tảng Đá Băng!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.45):
			_activate_boss_shield(0.18, 6.0, "TUYẾT MA BĂNG GIÁP!", Color("#72EFDD"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -106), "TUYẾT MA BĂNG THẠCH TRỤY!", Color("#72EFDD"))
		var p_cnt: int = 4 if p2 else 3
		for pi in range(p_cnt):
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(float(pi) * 2.1 + spiral_angle_offset), sin(float(pi) * 2.1 + spiral_angle_offset)) * 112.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 92.0, 0.78 + float(pi) * 0.14, 0.45, eff_atk * 1.38, Color("#72EFDD"), 0.40, 2.4)
		spiral_angle_offset += 0.45
		var b_cnt: int = 7 if p2 else 5
		for i in range(b_cnt):
			var off: float = (float(i) - float(b_cnt - 1) * 0.5) * 0.24
			_spawn_boss_projectile(origin, to_p.rotated(off), 325.0, eff_atk * 1.18, Color("#72EFDD"), "boulder", 0.35, 2.0)

	elif enemy_id == "lieu_kinh_boss":
		# BÁ THƯƠNG LIỄU KÌNH (CƯỜNG BẢNG #3): 5 Kim Thương xuyên thấu + 3 Trảo Ấn ĐẠI LIỆT PHÁCH QUAN + Song kích tốc biến!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_burst")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -108), "ĐẠI LIỆT PHÁCH QUAN TRẢO!!" if p2 else "BÁ THƯƠNG PHÁ QUÂN!", Color("#FFD166"))
		var sp_cnt: int = 7 if p2 else 5
		for i in range(sp_cnt):
			var off: float = (float(i) - float(sp_cnt - 1) * 0.5) * 0.16
			_spawn_boss_projectile(origin, to_p.rotated(off), 470.0, eff_atk * 1.18, Color("#FFD166"), "spear")
		var c_cnt: int = 3 if p2 else 2
		for ci in range(c_cnt):
			var c_off: Vector2 = to_p * (float(ci) * 84.0)
			_spawn_boss_hazard(player_node.global_position + c_off, "pillar", 96.0, 0.72 + float(ci) * 0.16, 0.44, eff_atk * 1.44, Color("#FFD166"))
		charge_dir = to_p
		state_phase = "charging"
		state_duration = 0.30
		state_timer = state_duration
		boss_combo_dashes_left = 1 if p2 else 0
		afterimage_timer = 0.0
		attack_cd = 0.0
		if absf(charge_dir.x) > 0.08:
			body_sprite.flip_h = charge_dir.x < 0.0

	elif enemy_id == "van_lac_tam_viem_boss":
		# BẢN THỂ ĐẠI XÀ VẪN LẠC TÂM VIÊM (#14): Xoáy Vô Hình Tâm Hỏa hút tâm + Hồ Dung Nham + Vòng 8-12 Cầu Tâm Hỏa xoay!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -110), "VÔ HÌNH TÂM HỎA — PHẦN HỒN LONG TỨC!!", Color("#E0AAFF"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 122.0, 0.55, 2.8, eff_atk * 1.24, Color("#E0AAFF"), 0.25, 1.6, 160.0)
		_spawn_boss_hazard(player_node.global_position + to_p * 95.0, "pool", 92.0, 0.65, 4.2, eff_atk * 1.28, Color("#C77DFF"))
		if p2:
			_spawn_boss_hazard(player_node.global_position - to_p * 95.0, "pool", 86.0, 0.72, 4.2, eff_atk * 1.22, Color("#FF4D6D"))
		spiral_angle_offset += 0.34
		var orb_cnt: int = 12 if p2 else 8
		for k in range(orb_cnt):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(orb_cnt))
			var col_o: Color = Color("#FFFFFF") if (k % 2 == 0) else Color("#E0AAFF")
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 355.0, eff_atk * 1.18, col_o, "orb")

	elif enemy_id == "han_phong_boss":
		# FINAL BOSS CH.06 — DƯỢC HOÀNG HÀN PHONG (HẢI TÂM DIỄM #15): Khiên Hải Tâm + Xoáy Thâm Hải + 3-5 Trụ Thủy Hỏa + 3 Hỏa Long rượt đuổi!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_fire")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.50):
			_activate_boss_shield(0.20, 6.5, "HẢI TÂM DIỄM (#15) HỘ THUẪN!", Color("#00B4D8"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -110), "HẢI TÂM DIỄM — THÂM HẢI PHẦN THIÊN TRẬN!!", Color("#38BDF8"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 112.0, 0.52, 2.6, eff_atk * 1.22, Color("#00B4D8"), 0.32, 2.0, 150.0)
		var hp_cnt: int = 5 if p2 else 3
		for pi in range(hp_cnt):
			var ang_p: float = float(pi) * (TAU / float(hp_cnt)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 116.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 88.0, 0.74 + float(pi) * 0.14, 0.46, eff_atk * 1.46, Color("#00B4D8"), 0.35, 2.0)
		for hi in range(3):
			var h_off: float = (float(hi) - 1.0) * 0.42
			_spawn_boss_projectile(origin, to_p.rotated(h_off), 345.0, eff_atk * 1.20, Color("#38BDF8"), "orb", 0.25, 1.6, 2.6)
		if p2:
			spiral_angle_offset += 0.36
			for k in range(8):
				var w_ang: float = spiral_angle_offset + float(k) * (TAU / 8.0)
				_spawn_boss_projectile(origin, Vector2(cos(w_ang), sin(w_ang)), 405.0, eff_atk * 1.18, Color("#00B4D8"), "wave")

	# =========================================================
	# 6 BOSS ĐẤU TÔNG CHƯƠNG 07 (TAM THƯỢNG VÂN LAM & XUẤT VÂN ĐỘC TÔNG)
	# =========================================================
	elif enemy_id == "van_son_boss":
		# ĐẤU TÔNG VÂN SƠN THẬT: Không Gian Phong Tỏa + Phong Chi Cực: Vẫn Sát (Trụ Phong Lôi + 8–10 Lưỡi Gió Trắng)!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "boss_roar")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.48):
			_activate_boss_shield(0.20, 6.2, "ĐẤU TÔNG PHONG CHI THUẪN!", Color("#72EFDD"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -110), "PHONG CHI CỰC: VẪN SÁT!!" if p2 else "KHÔNG GIAN PHONG TỎA!", Color("#72EFDD"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 120.0, 0.52, 2.6, eff_atk * 1.24, Color("#72EFDD"), 0.38, 2.0, 160.0)
		var vs_pillars: int = 4 if p2 else 2
		for pi in range(vs_pillars):
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(float(pi) * 2.0 + spiral_angle_offset), sin(float(pi) * 2.0 + spiral_angle_offset)) * 108.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.78 + float(pi) * 0.14, 0.48, eff_atk * 1.48, Color("#CAF0F8"))
		spiral_angle_offset += 0.34
		var blades: int = 10 if p2 else 7
		for k in range(blades):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(blades))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 435.0, eff_atk * 1.18, Color("#72EFDD"), "wave")

	elif enemy_id == "vu_ho_phap_boss":
		# VỤ HỘ PHÁP (HỒN ĐIỆN): Thiết Tỏa Hồn Xích — Xoáy Hắc Vụ kéo giam + 4 Trụ Tỏa Hồn + 5 Hồn Xích rượt đuổi!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -110), "HỒN ĐIỆN: THIẾT TỎA HỒN XÍCH!!", Color("#E63946"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 128.0, 0.50, 2.9, eff_atk * 1.26, Color("#9D4EDD"), 0.42, 2.2, 175.0)
		var chain_cnt: int = 5 if p2 else 3
		for ci in range(chain_cnt):
			var c_off: float = (float(ci) - float(chain_cnt - 1) * 0.5) * 0.30
			_spawn_boss_projectile(origin, to_p.rotated(c_off), 375.0, eff_atk * 1.22, Color("#E63946"), "spear", 0.30, 1.8, 2.8)
		if p2:
			for pi in range(3):
				var p_off: Vector2 = Vector2(cos(float(pi) * 2.1 + spiral_angle_offset), sin(float(pi) * 2.1 + spiral_angle_offset)) * 100.0
				_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 86.0, 0.72 + float(pi) * 0.14, 0.44, eff_atk * 1.44, Color("#E63946"))
			spiral_angle_offset += 0.45

	elif enemy_id == "nhan_lac_thien_boss":
		# TÔNG CHỦ KIM NHẠN TÔNG NHẠN LẠC THIÊN: Kim Nhạn Lạc Nhật Trảm — Quạt 7–9 Vũ Tiễn Vàng + Song Kích Tốc Biến!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "swing_blade")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -108), "KIM NHẠN LẠC NHẬT TRẢM!!", Color("#FFD166"))
		var feath: int = 9 if p2 else 6
		for i in range(feath):
			var off: float = (float(i) - float(feath - 1) * 0.5) * 0.16
			_spawn_boss_projectile(origin, to_p.rotated(off), 475.0, eff_atk * 1.18, Color("#FFD166"), "spear")
		_spawn_boss_hazard(player_node.global_position + to_p * 60.0, "pillar", 104.0, 0.74, 0.46, eff_atk * 1.46, Color("#FF9F1C"))
		charge_dir = to_p
		state_phase = "charging"
		state_duration = 0.30
		state_timer = state_duration
		boss_combo_dashes_left = 1 if p2 else 0
		afterimage_timer = 0.0
		attack_cd = 0.0
		if absf(charge_dir.x) > 0.08:
			body_sprite.flip_h = charge_dir.x < 0.0

	elif enemy_id == "hat_tat_nham_boss":
		# LÃO TỔ VẠN HẠT MÔN HẠT TẤT NHAM: Vạn Hạt Độc Pháp Thân — 3 Vũng Kịch Độc + Khiên Độc Giáp + Vòng 10 Độc Cầu!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.50):
			_activate_boss_shield(0.22, 6.5, "VẠN HẠT ĐỘC PHÁP THÂN!", Color("#70E000"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -108), "MA ĐỘC BẠO ĐỘNG — VẠN HẠT CHI VĨ!!", Color("#70E000"))
		_spawn_boss_hazard(player_node.global_position, "pool", 98.0, 0.58, 4.4, eff_atk * 1.28, Color("#70E000"), 0.38, 2.2)
		if p2:
			_spawn_boss_hazard(player_node.global_position + to_p * 110.0, "pool", 88.0, 0.68, 4.2, eff_atk * 1.24, Color("#9D4EDD"), 0.38, 2.2)
			_spawn_boss_hazard(player_node.global_position - to_p * 110.0, "pool", 88.0, 0.68, 4.2, eff_atk * 1.24, Color("#70E000"), 0.38, 2.2)
		spiral_angle_offset += 0.32
		var p_orbs: int = 10 if p2 else 7
		for k in range(p_orbs):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(p_orbs))
			var col_p: Color = Color("#70E000") if (k % 2 == 0) else Color("#C77DFF")
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 350.0, eff_atk * 1.18, col_p, "orb", 0.30, 2.0)

	elif enemy_id == "han_phong_dau_tong_boss":
		# HÀN PHONG ĐOẠT XÁ ĐẤU TÔNG: Song Hệ Hải Tâm Diễm #15 + Hồn Vụ Hồn Điện! Khiên Kép + 4 Trụ Thâm Hải + 4 Long Cầu rượt đuổi!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_fire")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.52):
			_activate_boss_shield(0.22, 6.5, "HẢI TÂM TÀ HỎA THUẪN!", Color("#38BDF8"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -110), "HẢI TÂM DIỄM × HỒN ĐIỆN TÀ VỤ!!", Color("#38BDF8"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 118.0, 0.50, 2.7, eff_atk * 1.26, Color("#38BDF8"), 0.35, 2.0, 165.0)
		var hf_p: int = 5 if p2 else 3
		for pi in range(hf_p):
			var ang_p: float = float(pi) * (TAU / float(hf_p)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 116.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 92.0, 0.72 + float(pi) * 0.14, 0.46, eff_atk * 1.48, Color("#E63946") if (pi % 2 == 1) else Color("#38BDF8"), 0.36, 2.0)
		for hi in range(4 if p2 else 3):
			var h_off: float = (float(hi) - 1.5) * 0.36
			_spawn_boss_projectile(origin, to_p.rotated(h_off), 360.0, eff_atk * 1.22, Color("#38BDF8"), "orb", 0.28, 1.8, 2.8)
		spiral_angle_offset += 0.38

	elif enemy_id == "dia_ma_lao_quy_boss":
		# FINAL BOSS QUYỂN II — ĐỊA MA LÃO QUỶ (ĐẤU TÔNG 7 TINH): Cửu U Hàn Băng Không Gian — Khiên Băng Đấu Tông + Bão Băng Hút Tâm + 5 Cột Cửu U + 12 Băng Tiễn!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.55):
			_activate_boss_shield(0.24, 6.8, "CỬU U HÀN BĂNG THẦN GIÁP!", Color("#CAF0F8"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -112), "CỬU U HÀN BĂNG KHÔNG GIAN!! (ĐẤU TÔNG 7★)", Color("#CAF0F8"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 132.0, 0.50, 3.0, eff_atk * 1.30, Color("#90E0EF"), 0.46, 2.4, 175.0)
		var dm_p: int = 5 if p2 else 3
		for pi in range(dm_p):
			var ang_p: float = float(pi) * (TAU / float(dm_p)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 120.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 98.0, 0.72 + float(pi) * 0.14, 0.50, eff_atk * 1.54, Color("#CAF0F8"), 0.45, 2.4)
		spiral_angle_offset += 0.30
		var ice_sp: int = 12 if p2 else 8
		for k in range(ice_sp):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(ice_sp))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 405.0, eff_atk * 1.22, Color("#90E0EF"), "spear", 0.42, 2.2)

	elif enemy_id == "phi_thien_boss":
		# THIÊN LÔI TỬ PHÍ THIÊN (Bát Tinh Đấu Tông — Phong Lôi Bắc Các): Cửu Thiên Lôi Ngục + 8 Tia Lôi Điện Xoắn!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("skill_burst")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.45):
			_activate_boss_shield(0.20, 6.0, "LÔI CƯƠNG HỘ THÂN!", Color("#72EFDD"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -108), "CỬU THIÊN LÔI NGỤC!! (BẮC CÁC)", Color("#72EFDD"))
		var pt_p: int = 4 if p2 else 3
		for pi in range(pt_p):
			var ang_p: float = float(pi) * (TAU / float(pt_p)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 112.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 88.0, 0.66 + float(pi) * 0.14, 0.44, eff_atk * 1.42, Color("#72EFDD"), 0.25, 1.4)
		spiral_angle_offset += 0.34
		var l_cnt: int = 10 if p2 else 7
		for k in range(l_cnt):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(l_cnt))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 420.0, eff_atk * 1.18, Color("#72EFDD"), "spear", 0.0, 0.0)

	elif enemy_id == "vuong_tran_boss":
		# HUYẾT SÁT VƯƠNG TRẦN (Hoàng Tuyền Các): Huyết Sát Đao Vực hút tâm + 6 Huyết Đao Sóng Quét!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -108), "HOÀNG TUYỀN HUYẾT SÁT TRẢM!!", Color("#E63946"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 118.0, 0.46, 2.4, eff_atk * 1.24, Color("#E63946"), 0.30, 1.8, 165.0)
		var v_cnt: int = 7 if p2 else 5
		for k in range(v_cnt):
			var off_a: float = (float(k) - float(v_cnt - 1) * 0.5) * 0.24
			_spawn_boss_projectile(origin, to_p.rotated(off_a), 400.0, eff_atk * 1.22, Color("#E63946"), "wave", 0.0, 0.0)

	elif enemy_id == "phuong_thanh_nhi_boss":
		# PHƯỢNG THANH NHI (Thiên Yêu Hoàng · Phong Lôi Các #1): Yêu Hoàng Lôi Dực + 5 Trụ Lôi Phượng + 10 Vũ Lôi Tốc Độ Cao!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_burst")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.48):
			_activate_boss_shield(0.22, 6.2, "YÊU HOÀNG PHƯỢNG DỰC THUẪN!", Color("#C77DFF"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -110), "PHONG LÔI CỰC PHÁ — YÊU HOÀNG LÔI DỰC!!", Color("#C77DFF"))
		var pq_p: int = 5 if p2 else 3
		for pi in range(pq_p):
			var ang_p: float = float(pi) * (TAU / float(pq_p)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 116.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 92.0, 0.64 + float(pi) * 0.13, 0.46, eff_atk * 1.48, Color("#FFD166") if (pi % 2 == 1) else Color("#C77DFF"), 0.25, 1.4)
		spiral_angle_offset += 0.40
		var pf_cnt: int = 10 if p2 else 7
		for k in range(pf_cnt):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(pf_cnt))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 445.0, eff_atk * 1.24, Color("#C77DFF") if (k % 2 == 0) else Color("#FFD166"), "spear", 0.0, 0.0)
		for hi in range(2 if p2 else 1):
			_spawn_boss_projectile(origin, to_p.rotated((float(hi) - 0.5) * 0.42), 360.0, eff_atk * 1.26, Color("#FFD166"), "orb", 0.22, 1.5, 2.8)

	elif enemy_id == "bang_ha_thanh_hai_boss":
		# BĂNG HÀ CỐC CHỦ & THANH HẢI TÔN GIẢ (Đấu Tôn Liên Quân): Băng Hồn Song Tuyệt — Khiên Băng + Bão Tuyết Hút + 5 Trụ Băng-Hồn + 10 Băng Thương!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.54):
			_activate_boss_shield(0.24, 6.8, "BĂNG HÀ HỒN VỤ THẦN THUẪN!", Color("#38BDF8"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -112), "BĂNG HÀ ĐÓNG BĂNG × HỒN ĐIỆN TỎA HỒN!!", Color("#38BDF8"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 130.0, 0.48, 2.8, eff_atk * 1.28, Color("#38BDF8"), 0.44, 2.3, 175.0)
		var bh_p: int = 5 if p2 else 3
		for pi in range(bh_p):
			var ang_p: float = float(pi) * (TAU / float(bh_p)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 120.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.70 + float(pi) * 0.14, 0.48, eff_atk * 1.52, Color("#E63946") if (pi % 2 == 1) else Color("#38BDF8"), 0.42, 2.2)
		spiral_angle_offset += 0.30
		var bh_sp: int = 10 if p2 else 7
		for k in range(bh_sp):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(bh_sp))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 405.0, eff_atk * 1.24, Color("#38BDF8") if (k % 2 == 0) else Color("#E63946"), "spear", 0.40, 2.0)

	elif enemy_id == "cuu_long_loi_cuong_boss":
		# #12 CỬU LONG LÔI CƯƠNG HỎA (Phần Viêm Cốc): Cửu Long Ngân Viêm Trận — 5 Cột Ngân Long + 9 Long Cầu Xoắn + 3 Đuổi Mục Tiêu!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_fire")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.50):
			_activate_boss_shield(0.22, 6.4, "CỬU LONG NGÂN VIÊM GIÁP!", Color("#E2F1FF"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -112), "#12 CỬU LONG LÔI CƯƠNG — NGÂN LONG PHẦN THIÊN!!", Color("#E2F1FF"))
		var cl_p: int = 5 if p2 else 4
		for pi in range(cl_p):
			var ang_p: float = float(pi) * (TAU / float(cl_p)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 124.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.68 + float(pi) * 0.13, 0.48, eff_atk * 1.54, Color("#E2F1FF"), 0.24, 1.5)
		spiral_angle_offset += 0.36
		for k in range(9 if p2 else 6):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(9 if p2 else 6))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 385.0, eff_atk * 1.25, Color("#E2F1FF") if (k % 2 == 0) else Color("#4CC9F0"), "orb", 0.0, 0.0)
		for hi in range(3 if p2 else 2):
			_spawn_boss_projectile(origin, to_p.rotated((float(hi) - 1.0) * 0.40), 355.0, eff_atk * 1.28, Color("#4CC9F0"), "orb", 0.25, 1.6, 2.8)

	elif enemy_id == "mo_cot_lao_nhan_boss":
		# MỘ CỐT LÃO NHÂN (Hồn Điện — Tam Tinh Đấu Tôn): U Minh Mộ Cốt Tỏa Hồn Trận — Khiên Xương + Xoáy Hồn + 5 Trụ Hồn Đen + 8 Cầu Xương!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.55):
			_activate_boss_shield(0.24, 6.6, "U MINH MỘ CỐT HỒN THUẪN!", Color("#9D4EDD"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -112), "U MINH MỘ CỐT TỎA HỒN TRẬN!! (HỒN ĐIỆN)", Color("#9D4EDD"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 132.0, 0.48, 2.9, eff_atk * 1.32, Color("#9D4EDD"), 0.38, 2.2, 180.0)
		var mc_p: int = 5 if p2 else 3
		for pi in range(mc_p):
			var ang_p: float = float(pi) * (TAU / float(mc_p)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 118.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.70 + float(pi) * 0.14, 0.48, eff_atk * 1.56, Color("#E63946") if (pi % 2 == 1) else Color("#9D4EDD"), 0.36, 2.0)
		spiral_angle_offset += 0.35
		for k in range(8 if p2 else 6):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(8 if p2 else 6))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 375.0, eff_atk * 1.26, Color("#9D4EDD"), "orb", 0.30, 1.8, 2.4 if (k % 2 == 0) else 0.0)

	elif enemy_id == "tam_thien_diem_viem_boss":
		# FINAL BOSS CH.08 — #9 THÁI HƯ TỬ HẮC CỰ LONG (Tam Thiên Diễm Viêm Hỏa): Ngân Hà Tinh Vực — Khiên Tinh Thể + Hố Đen Tinh Hà + 6 Trụ Tinh Hỏa + 14 Tinh Cầu + Tự Hồi 4% HP ở P2!
		var eff_atk: float = _get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if p2 and cur_hp < max_hp * 0.85:
			var regen_d: float = max_hp * 0.04
			cur_hp = minf(max_hp, cur_hp + regen_d)
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -134), "✦ BẤT TỬ TINH THỂ +%d HP!" % int(round(regen_d)), Color("#C77DFF"))
		if boss_shield_hp <= 0.0 and (p2 or randf() < 0.58):
			_activate_boss_shield(0.26, 7.0, "TAM THIÊN TINH THỂ BẤT TỬ THUẪN!", Color("#A855F7"))
		else:
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -114), "#9 TAM THIÊN DIỄM VIÊM HỎA — NGÂN HÀ TINH VỰC!!", Color("#A855F7"))
		_spawn_boss_hazard(player_node.global_position, "vortex", 142.0, 0.48, 3.2, eff_atk * 1.36, Color("#A855F7"), 0.40, 2.4, 190.0)
		var tt_p: int = 6 if p2 else 4
		for pi in range(tt_p):
			var ang_p: float = float(pi) * (TAU / float(tt_p)) + spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 128.0
			_spawn_boss_hazard(player_node.global_position + p_off, "pillar", 102.0, 0.68 + float(pi) * 0.13, 0.52, eff_atk * 1.62, Color("#FFD166") if (pi % 2 == 1) else Color("#A855F7"), 0.36, 2.2)
		spiral_angle_offset += 0.28
		var star_cnt: int = 14 if p2 else 10
		for k in range(star_cnt):
			var ang: float = spiral_angle_offset + float(k) * (TAU / float(star_cnt))
			var s_col: Color = Color("#C77DFF") if (k % 3 == 0) else (Color("#FFD166") if (k % 3 == 1) else Color("#E0AAFF"))
			_spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 415.0, eff_atk * 1.28, s_col, "orb", 0.28, 1.8, 2.2 if (k % 4 == 0) else 0.0)


func _fire_boss_triple_wave() -> void:
	EventBus.audio_sfx_requested.emit("skill_fire")
	var wave_col: Color = _get_signature_color()
	var style_s: String = "orb" if (enemy_id == "co_ha_boss" or enemy_id == "lieu_tich_boss" or enemy_id == "hoa_linh_xa_boss" or enemy_id == "tieu_tu_tinh_su_boss" or enemy_id == "viem_loi_boss" or enemy_id == "van_lac_tam_viem_boss" or enemy_id == "han_phong_boss" or enemy_id == "hat_tat_nham_boss" or enemy_id == "han_phong_dau_tong_boss" or enemy_id == "cuu_long_loi_cuong_boss" or enemy_id == "mo_cot_lao_nhan_boss" or enemy_id == "tam_thien_diem_viem_boss") else ("spear" if (enemy_id == "muc_luc_boss" or enemy_id == "mac_ba_tu_boss" or enemy_id == "hai_ba_dong_boss" or enemy_id == "nap_lan_yen_nhien_boss" or enemy_id == "van_lang_boss" or enemy_id == "la_hau_boss" or enemy_id == "lieu_kinh_boss" or enemy_id == "vu_ho_phap_boss" or enemy_id == "nhan_lac_thien_boss" or enemy_id == "dia_ma_lao_quy_boss" or enemy_id == "phi_thien_boss" or enemy_id == "phuong_thanh_nhi_boss" or enemy_id == "bang_ha_thanh_hai_boss") else ("boulder" if (enemy_id == "moc_chien_boss" or enemy_id == "tuyet_ma_thien_vien_boss") else "wave"))
	var slow_r: float = 0.35 if (enemy_id == "hai_ba_dong_boss" or enemy_id == "tuyet_ma_thien_vien_boss" or enemy_id == "han_phong_boss" or enemy_id == "han_phong_dau_tong_boss" or enemy_id == "dia_ma_lao_quy_boss" or enemy_id == "hat_tat_nham_boss" or enemy_id == "bang_ha_thanh_hai_boss" or enemy_id == "mo_cot_lao_nhan_boss") else 0.0
	var slow_d: float = 2.0 if (enemy_id == "hai_ba_dong_boss" or enemy_id == "tuyet_ma_thien_vien_boss" or enemy_id == "han_phong_boss" or enemy_id == "han_phong_dau_tong_boss" or enemy_id == "dia_ma_lao_quy_boss" or enemy_id == "hat_tat_nham_boss" or enemy_id == "bang_ha_thanh_hai_boss" or enemy_id == "mo_cot_lao_nhan_boss") else 0.0
	var eff_atk: float = _get_effective_atk()
	var angles: Array = [-0.28, 0.0, 0.28]
	for ang_off in angles:
		_spawn_boss_projectile(global_position + Vector2(0, -20), wave_aim_dir.rotated(float(ang_off)), 360.0, eff_atk * 1.15, wave_col, style_s, slow_r, slow_d)


func _deal_melee_hit(player_node: Node2D, mult: float, trigger_slash_vfx: bool = true) -> void:
	var push_dir: Vector2 = (player_node.global_position - global_position).normalized()
	if push_dir == Vector2.ZERO:
		push_dir = Vector2.RIGHT
	if trigger_slash_vfx:
		strike_hold_timer = 0.26
		strike_dir = push_dir
		strike_vfx_timer = 0.20
		strike_vfx_radius = 86.0 if is_boss_unit else 62.0
		strike_vfx_is_nova = false
		strike_vfx_color = _get_signature_color()
		if is_boss_unit:
			_spawn_afterimage()
			_spawn_enemy_vfx("boss_strike_arc", global_position + Vector2(0, -24), push_dir, 96.0, 0.22, strike_vfx_color, { "flip_dir": -1.0 if body_sprite.flip_h else 1.0, "follow_target": self, "follow_offset": Vector2(0, -24) })
	if player_node.has_method("take_enemy_damage"):
		var raw_dmg: float = _get_effective_atk() * mult
		player_node.take_enemy_damage(raw_dmg, realm_idx, push_dir * 260.0, enemy_id, display_title)


func apply_stun(duration: float) -> void:
	if ai_mode == "dummy" or is_dying:
		return
	var resist: float = 0.55 if is_boss_unit else 1.0
	stun_timer = maxf(stun_timer, duration * resist)
	state_phase = "idle"
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -86), "CHOÁNG!", Color("#FFD166"))


func apply_slow(ratio: float, duration: float) -> void:
	if ai_mode == "dummy" or is_dying:
		return
	slow_ratio = maxf(slow_ratio, clampf(ratio, 0.1, 0.60))
	slow_timer = maxf(slow_timer, duration)
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -76), "LÀM CHẬM!", Color("#A8DADC"))


func apply_def_shred(ratio: float, duration: float) -> void:
	if is_dying:
		return
	def_shred_ratio = maxf(def_shred_ratio, clampf(ratio, 0.05, 0.65))
	def_shred_timer = maxf(def_shred_timer, duration)
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "PHÁ GIÁP -%d%%!" % int(round(def_shred_ratio * 100.0)), Color("#52B788"))


func apply_poison_detonate(dmg: float, duration: float) -> void:
	if is_dying:
		return
	poison_detonate_dmg = maxf(poison_detonate_dmg, dmg)
	poison_detonate_timer = maxf(poison_detonate_timer, duration)


func break_boss_shield() -> void:
	if boss_shield_hp > 0.0:
		boss_shield_hp = 0.0
		boss_shield_timer = 0.0
		EventBus.audio_sfx_requested.emit("hit_crit")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -110), "VỠ KHIÊN BOSS!", Color("#FFD166"))


func receive_hit(raw_atk_dmg: float, kb_vec: Vector2, skill_realm_pen: float = 0.0, apply_burn_dps: float = 0.0, ignore_def_ratio: float = 0.0, force_crit_mult: float = 1.0, poise_dmg: float = 12.0) -> void:
	if is_dying:
		return
	var realm_mult: float = PlayerData.compute_realm_damage_multiplier_against(realm_idx, skill_realm_pen)
	var eff_def: float = def_stat * (1.0 - (def_shred_ratio if def_shred_timer > 0.0 else 0.0)) * (1.0 - clampf(ignore_def_ratio, 0.0, 1.0))
	var bonus_vs_enemy: float = PlayerData.get_enemy_damage_bonus_mult(enemy_id, display_title)
	var reduced: float = maxf(1.0, (raw_atk_dmg * bonus_vs_enemy - eff_def * 0.45) * realm_mult)
	# Cơ chế nguyên tác Boss Mặc Thừa Phase 2: Song Sắc Phật Nộ Hỏa Liên phá tan Thú Hóa gây x2.2 sát thương bùng nổ!
	if enemy_id == "mac_thua_boss" and boss_phase >= 2 and skill_realm_pen >= 0.45:
		reduced *= 2.2
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -112), "SONG SẮC HỎA LIÊN PHÁ THÚ HÓA!", Color("#72EFDD"))

	if poise_stagger_timer > 0.0:
		reduced *= 1.35

	# Linh Hồn Cảm Tri (Soul Radar): mục tiêu bị quét nhận thêm +10% sát thương!
	if radar_scanned_timer > 0.0:
		reduced *= 1.10

	# Burrower đang độn thổ: giảm 70% sát thương trừ khi bị Linh Hồn Cảm Tri soi lộ hình!
	var burrow_mitigated: bool = false
	if is_burrowed and radar_scanned_timer <= 0.0:
		reduced *= 0.30
		burrow_mitigated = true

	# Shieldbearer: khiên mặt trước giảm 60% sát thương (trừ phá thế >= 35 hoặc choáng -> PHÁ KHIÊN!); đánh sau/sườn +25% DMG!
	var effective_kb: Vector2 = kb_vec
	if ai_mode == "shieldbearer":
		var hit_from_dir: Vector2 = Vector2.ZERO
		if kb_vec.length() > 4.0:
			hit_from_dir = -kb_vec.normalized()
		else:
			var p_ref: Node2D = _find_player()
			if p_ref != null and global_position.distance_to(p_ref.global_position) > 1.0:
				hit_from_dir = (p_ref.global_position - global_position).normalized()
		var front_dot: float = shield_dir.normalized().dot(hit_from_dir) if hit_from_dir != Vector2.ZERO else 0.0
		if front_shield_broken_timer > 0.0:
			reduced *= 1.35
		elif front_dot > 0.30:
			if poise_dmg >= 35.0 or stun_timer > 0.0:
				front_shield_broken_timer = 4.5
				reduced *= 1.35
				EventBus.audio_sfx_requested.emit("poise_break")
				EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "PHÁ KHIÊN! (+35% DMG)", Color("#FFD166"))
				VfxAssets.spawn_spark_burst(get_parent(), global_position + Vector2(0, -24) + shield_dir * 26.0, Color("#FFFFFF"), Color("#70D6FF"), 18, 95.0, 220.0, 0.36, shield_dir, 120.0, 0.28, 0.56, true)
			else:
				reduced *= 0.40
				effective_kb *= 0.35
				EventBus.floating_text_requested.emit(global_position + Vector2(0, -96), "CHẮN KHIÊN!", Color("#70D6FF"))
		else:
			reduced *= 1.25
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -92), "ĐÁNH SƯỜN +25%!", Color("#FFD166"))

	var is_crit: bool = (force_crit_mult > 1.0) or (randf() < PlayerData.get_crit_chance())
	if is_crit:
		reduced *= (1.65 * maxf(1.0, force_crit_mult))

	if boss_shield_hp > 0.0:
		var abs_sh: float = minf(boss_shield_hp, reduced)
		boss_shield_hp -= abs_sh
		reduced -= abs_sh
		if boss_shield_hp <= 0.0:
			boss_shield_timer = 0.0
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -104), "VỠ KHIÊN!", Color("#FFD166"))
		if reduced <= 0.5:
			hit_flash_timer = 0.08
			EventBus.audio_sfx_requested.emit("hit_impact")
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -68), "KHIÊN -%d" % int(round(abs_sh)), Color("#70D6FF"))
			return

	cur_hp -= reduced
	PlayerData.heal_from_lifesteal(reduced)
	hit_flash_timer = 0.11
	hit_squash = 1.0
	EventBus.audio_sfx_requested.emit("hit_crit" if is_crit else "hit_impact")

	if ai_mode != "dummy":
		var kb_resist: float = 0.38 if is_boss_unit else 1.0
		knockback_vel = effective_kb * kb_resist
	else:
		body_sprite.rotation = randf_range(-0.20, 0.20)
		var tw := create_tween()
		tw.tween_property(body_sprite, "rotation", 0.0, 0.16)

	if apply_burn_dps > 0.0:
		burn_dps_val = maxf(burn_dps_val, apply_burn_dps)
		burn_remaining = 3.0

	var col: Color = Color("#FFD166") if is_crit else Color("#FFFFFF")
	var txt: String = "%d!" % int(round(reduced)) if is_crit else "%d" % int(round(reduced))
	if burrow_mitigated:
		txt += " (Độn Thổ)"
		col = Color("#ADB5BD")
	elif realm_mult < 0.85:
		txt += " (Áp Chế)"
		col = Color("#ADB5BD")
	EventBus.floating_text_requested.emit(global_position + Vector2(randf_range(-16, 16), -68), txt, col)

	if cur_hp > 0.0:
		_check_phase2_warning()
		if ai_mode == "bomber" and not is_priming_bomb and cur_hp <= max_hp * 0.28:
			_start_bomb_priming()
		if is_boss_unit and boss_phase == 1 and cur_hp <= max_hp * 0.55:
			_trigger_boss_phase_2()
		if is_boss_unit and poise_stagger_timer <= 0.0 and poise_dmg > 0.0:
			cur_poise = minf(max_poise, cur_poise + poise_dmg)
			poise_decay_delay = 3.2
			if cur_poise >= max_poise:
				_trigger_poise_break()

	if is_boss_unit and boss_bar_shown:
		EventBus.boss_status_updated.emit(display_title, realm_badge, maxf(0.0, cur_hp), max_hp, boss_phase, true)
		EventBus.boss_poise_updated.emit(cur_poise, max_poise, poise_stagger_timer > 0.0, is_phase2_warning())

	if cur_hp <= 0.0:
		_die()


func _process_burn_dot(delta: float) -> void:
	if burn_remaining <= 0.0 or is_dying:
		return
	burn_remaining -= delta
	burn_tick_accum += delta
	if burn_tick_accum >= 0.6:
		burn_tick_accum = 0.0
		var dot_dmg: float = maxf(1.0, burn_dps_val * 0.6)
		cur_hp -= dot_dmg
		var f_def: Dictionary = PlayerData.get_active_flame_def()
		EventBus.floating_text_requested.emit(
			global_position + Vector2(randf_range(-12, 12), -52),
			"-%d Hỏa" % int(round(dot_dmg)),
			Color(str(f_def.get("mid_hex", "#FF7B00")))
		)
		if cur_hp > 0.0:
			_check_phase2_warning()
			if ai_mode == "bomber" and not is_priming_bomb and cur_hp <= max_hp * 0.28:
				_start_bomb_priming()
		if is_boss_unit and boss_phase == 1 and cur_hp > 0.0 and cur_hp <= max_hp * 0.55:
			_trigger_boss_phase_2()
		if cur_hp <= 0.0:
			_die()


func _die() -> void:
	if is_dying:
		return
	is_dying = true
	is_burrowed = false
	is_priming_bomb = false
	remove_from_group("enemies")
	set_collision_layer(0)
	set_collision_mask(0)

	if is_boss_unit and boss_bar_shown:
		boss_bar_shown = false
		EventBus.boss_status_updated.emit("", "", 0.0, 1.0, 1, false)
		EventBus.boss_poise_updated.emit(0.0, 1.0, false, false)
		_request_restore_map_bgm()

	if get_parent() != null:
		var f_def: Dictionary = PlayerData.get_active_flame_def()
		var d_col: Color = Color(str(f_def.get("mid_hex", "#FF7B00"))) if not f_def.is_empty() else _get_signature_color()
		var d_core: Color = Color(str(f_def.get("core_hex", "#FFF3B0"))) if not f_def.is_empty() else Color.WHITE
		VfxAssets.spawn_spark_burst(get_parent(), global_position + Vector2(0, -24), d_core, d_col, 32 if is_boss_unit else 16, 75.0, 210.0, 0.52, Vector2.UP, 180.0, 0.30, 0.65, true)
		VfxAssets.spawn_dust_puff(get_parent(), global_position + Vector2(0, -16), Color(d_col.r, d_col.g, d_col.b, 0.36), 8 if is_boss_unit else 4, 180.0, 1.35 if is_boss_unit else 0.9)

	if is_boss_rush_instance:
		var worlds: Array[Node] = get_tree().get_nodes_in_group("world_stage")
		if not worlds.is_empty() and worlds[0].has_method("on_boss_rush_boss_defeated"):
			worlds[0].on_boss_rush_boss_defeated(enemy_id)
	elif is_tower_instance:
		PlayerData.add_exp(exp_reward, global_position)
		var worlds: Array[Node] = get_tree().get_nodes_in_group("world_stage")
		if not worlds.is_empty() and worlds[0].has_method("on_tower_enemy_defeated"):
			worlds[0].on_tower_enemy_defeated(self)
	else:
		if get_parent() != null:
			var orb: Area2D = LOOT_SCENE.instantiate() as Area2D
			orb.global_position = global_position
			if orb.has_method("setup_exp_orb"):
				orb.setup_exp_orb(exp_reward)
			get_parent().call_deferred("add_child", orb)

			if gold_reward > 0:
				var g_orb: Area2D = LOOT_SCENE.instantiate() as Area2D
				g_orb.global_position = global_position
				if g_orb.has_method("setup_gold_drop"):
					g_orb.setup_gold_drop(gold_reward)
				get_parent().call_deferred("add_child", g_orb)

			if gear_pool.size() > 0 and randf() <= minf(1.0, gear_drop_chance + PlayerData.get_gear_drop_bonus_chance()):
				var pick_tpl: String = str(gear_pool[randi() % gear_pool.size()])
				var forced_rar: String = ""
				if allowed_rarities.size() > 0:
					forced_rar = str(allowed_rarities[randi() % allowed_rarities.size()])
				var rolled_gear: Dictionary = EquipmentSystem.roll_equipment_instance(pick_tpl, forced_rar)
				if not rolled_gear.is_empty():
					var eq_drop: Area2D = LOOT_SCENE.instantiate() as Area2D
					eq_drop.global_position = global_position
					if eq_drop.has_method("setup_gear_drop"):
						eq_drop.setup_gear_drop(rolled_gear)
					get_parent().call_deferred("add_child", eq_drop)

			for entry in drop_table:
				if entry is Dictionary:
					var chance: float = float(entry.get("chance", 0.3))
					if randf() <= chance:
						var drop_node: Area2D = LOOT_SCENE.instantiate() as Area2D
						drop_node.global_position = global_position
						if drop_node.has_method("setup_item_drop"):
							drop_node.setup_item_drop(str(entry.get("item_id", "")), 1)
						get_parent().call_deferred("add_child", drop_node)

		EventBus.enemy_killed.emit(enemy_id, is_boss_unit)

	# Hiệu ứng #20 U Minh Độc Hỏa: nổ dây chuyền sương độc sang quái xung quanh khi chết!
	if poison_detonate_timer > 0.0 and poison_detonate_dmg > 0.0:
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -76), "ĐỘC HỎA NỔ DÂY CHUYỀN!", Color("#52B788"))
		for near_en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(near_en) and near_en is Node2D and near_en != self:
				var en2: Node2D = near_en as Node2D
				if global_position.distance_to(en2.global_position) <= 185.0 and en2.has_method("receive_hit"):
					en2.receive_hit(poison_detonate_dmg, (en2.global_position - global_position).normalized() * 190.0, 0.25, 0.0)

	# Hoạt ảnh tan biến mượt (kéo giãn & mờ dần) thay vì biến mất cứng trong 1 frame!
	var tw := create_tween()
	tw.set_parallel(true)
	if body_sprite != null:
		body_sprite.modulate = Color(2.4, 2.4, 2.4, 1.0)
		tw.tween_property(body_sprite, "scale", Vector2(base_scale_val * 0.45, base_scale_val * 1.55), 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(body_sprite, "modulate:a", 0.0, 0.30)
	if boss_light != null:
		tw.tween_property(boss_light, "energy", 0.0, 0.30)
	tw.chain().tween_callback(queue_free)


func _find_player() -> Node2D:
	var list: Array[Node] = get_tree().get_nodes_in_group("player")
	if list.is_empty():
		return null
	return list[0] as Node2D


func _draw() -> void:
	if is_dying:
		return

	var sh_r: float = 38.0 if is_boss_unit else 28.0
	draw_set_transform(Vector2(0, 12), 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, sh_r, Color(0.03, 0.02, 0.06, 0.48))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Burrower đang độn thổ: vòng bụi đất / huyết vụ dập dìu trên mặt đất!
	if is_burrowed:
		var t_bur: float = float(Time.get_ticks_msec()) * 0.012
		for ring_i in range(2):
			var ph: float = fmod(t_bur * 0.45 + float(ring_i) * 0.5, 1.0)
			var rr: float = 12.0 + ph * 34.0
			var ra: float = (1.0 - ph) * 0.84
			var r_col: Color = Color("#9B2226").lerp(Color("#C98A5B"), 0.42)
			draw_set_transform(Vector2(0, 10), 0.0, Vector2(1.0, 0.52))
			draw_arc(Vector2.ZERO, rr, 0.0, TAU, 26, Color(r_col.r, r_col.g, r_col.b, ra), 3.4 * (1.0 - ph * 0.45))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_set_transform(Vector2(0, 10), 0.0, Vector2(1.0, 0.50))
		draw_circle(Vector2.ZERO, 20.0 + sin(t_bur * 1.5) * 3.0, Color(0.46, 0.16, 0.18, 0.40))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Ngô Hạo Tu La Cuồng Bạo: hào quang đỏ máu tăng dần theo lượng máu đã mất!
	if enemy_id == "ngo_hao_boss":
		var b_ratio: float = _get_ngo_hao_berserk_ratio()
		if b_ratio > 0.05:
			var t_br: float = float(Time.get_ticks_msec()) * 0.011
			var b_pulse: float = 0.5 + 0.5 * sin(t_br)
			var b_rad: float = 44.0 + b_ratio * 14.0 + b_pulse * 4.0
			draw_circle(Vector2(0, -22), b_rad * 0.82, Color(0.95, 0.14, 0.24, 0.10 + 0.18 * b_ratio))
			draw_arc(Vector2(0, -22), b_rad, 0.0, TAU, 36, Color(1.0, 0.20, 0.30, 0.35 + 0.55 * b_ratio), 2.4 + 2.4 * b_ratio)

	if is_boss_unit and boss_phase >= 2:
		var pulse_r: float = 42.0 + sin(float(Time.get_ticks_msec()) * 0.008) * 3.5
		draw_arc(Vector2(0, 12), pulse_r, 0.0, TAU, 36, Color(1.0, 0.22, 0.38, 0.65), 3.0)

	if is_phase2_warning():
		var t_warn: float = float(Time.get_ticks_msec()) * 0.012
		var warn_pulse: float = 0.5 + 0.5 * sin(t_warn)
		var warn_r: float = 40.0 + warn_pulse * 8.0
		var warn_col: Color = Color("#FF4D6D").lerp(Color("#FF9F1C"), warn_pulse)
		draw_arc(Vector2(0, 12), warn_r, 0.0, TAU, 36, Color(warn_col.r, warn_col.g, warn_col.b, 0.55 + 0.35 * warn_pulse), 3.4)
		draw_arc(Vector2(0, 12), warn_r * 0.76, t_warn * 0.8, t_warn * 0.8 + TAU * 0.72, 28, Color(1.0, 0.78, 0.28, 0.45 + 0.35 * warn_pulse), 2.2)

	if poise_stagger_timer > 0.0:
		var t_stag: float = float(Time.get_ticks_msec()) * 0.014
		var stag_pulse: float = 0.5 + 0.5 * sin(t_stag)
		var stag_r: float = 52.0 + stag_pulse * 5.0
		draw_circle(Vector2(0, -26), stag_r * 0.92, Color(1.0, 0.84, 0.32, 0.14 + 0.12 * stag_pulse))
		for seg_i in range(4):
			var a0: float = t_stag * 0.35 + float(seg_i) * (TAU * 0.25) + 0.14
			var a1: float = a0 + (TAU * 0.25) - 0.28
			draw_arc(Vector2(0, -26), stag_r, a0, a1, 14, Color(1.0, 0.88, 0.40, 0.80 + 0.20 * stag_pulse), 4.2)
			draw_arc(Vector2(0, -26), stag_r * 0.82, a0 + 0.08, a1 - 0.08, 10, Color(1.0, 0.98, 0.82, 0.55 + 0.30 * stag_pulse), 2.0)

	if boss_shield_hp > 0.0:
		var sh_col: Color = _get_signature_color()
		draw_arc(Vector2(0, -26), 54.0, 0.0, TAU, 36, Color(sh_col.r, sh_col.g, sh_col.b, 0.85), 4.0)
		draw_circle(Vector2(0, -26), 52.0, Color(sh_col.r, sh_col.g, sh_col.b, 0.14))

	# Shieldbearer: vòng cung khiên phát sáng xanh-vàng ±62° quanh hướng shield_dir!
	if ai_mode == "shieldbearer" and front_shield_broken_timer <= 0.0 and stun_timer <= 0.0:
		var sh_ang: float = shield_dir.angle()
		var half_arc: float = deg_to_rad(62.0)
		var sh_pulse: float = 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.008)
		var sh_center := Vector2(0.0, -24.0)
		draw_arc(sh_center, 41.0, sh_ang - half_arc, sh_ang + half_arc, 22, Color(0.44, 0.84, 1.0, 0.28 + 0.14 * sh_pulse), 11.0)
		draw_arc(sh_center, 44.0, sh_ang - half_arc, sh_ang + half_arc, 24, Color(0.44, 0.84, 1.0, 0.82 + 0.15 * sh_pulse), 5.0)
		draw_arc(sh_center, 47.0, sh_ang - half_arc * 0.92, sh_ang + half_arc * 0.92, 20, Color(1.0, 0.82, 0.40, 0.88), 2.6)

	# Bomber: vòng cảnh báo vùng tự bạo 125px nở rộng dập dìu đỏ rực!
	if is_priming_bomb:
		var fuse_p: float = 1.0 - clampf(bomb_fuse_timer / 1.15, 0.0, 1.0)
		var pulse_b: float = 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.032)
		var det_r: float = 125.0
		draw_circle(Vector2(0, -10), det_r * fuse_p, Color(1.0, 0.22, 0.14, 0.14 + 0.16 * fuse_p))
		draw_arc(Vector2(0, -10), det_r, 0.0, TAU, 44, Color(1.0, 0.22 + 0.26 * pulse_b, 0.16, 0.65 + 0.32 * pulse_b), 3.6 + 1.8 * pulse_b)
		draw_arc(Vector2(0, -10), det_r * maxf(0.18, fuse_p), 0.0, TAU, 36, Color(1.0, 0.72, 0.22, 0.86), 2.6)

	# Linh Hồn Cảm Tri (Soul Radar): tâm ngắm ngọc bích #72EFDD xoay sắc nét quanh mục tiêu!
	if radar_scanned_timer > 0.0:
		var t_rad: float = float(Time.get_ticks_msec()) * 0.0045
		var rad_r: float = 48.0 if is_boss_unit else 36.0
		var rad_col: Color = Color("#72EFDD")
		var rad_a: float = clampf(radar_scanned_timer / 1.2, 0.38, 0.92)
		var c_pos := Vector2(0.0, -24.0)
		for seg in range(4):
			var a0: float = t_rad + float(seg) * (TAU * 0.25) + 0.16
			var a1: float = a0 + (TAU * 0.25) - 0.32
			draw_arc(c_pos, rad_r, a0, a1, 12, Color(rad_col.r, rad_col.g, rad_col.b, rad_a), 2.6)
			var tick_a: float = t_rad + float(seg) * (TAU * 0.25)
			var d_tick := Vector2(cos(tick_a), sin(tick_a))
			draw_line(c_pos + d_tick * (rad_r - 6.0), c_pos + d_tick * (rad_r + 6.0), Color(rad_col.r, rad_col.g, rad_col.b, rad_a), 2.4)
		draw_arc(c_pos, rad_r * 0.72, -t_rad * 1.4, -t_rad * 1.4 + TAU * 0.65, 22, Color(rad_col.r, rad_col.g, rad_col.b, rad_a * 0.45), 1.6)

	if slow_timer > 0.0:
		draw_arc(Vector2(0, 12), 34.0, 0.0, TAU, 24, Color("#A8DADC"), 2.8)

	if stun_timer > 0.0:
		var ang: float = float(Time.get_ticks_msec()) * 0.008
		draw_arc(Vector2(0, -82), 16.0, ang, ang + TAU * 0.72, 18, Color("#FFD166"), 3.0)

	# Hiệu ứng cảnh báo gồng chiêu (Telegraph mượt theo tiến độ tích tụ!)
	if state_phase == "windup":
		var p: float = 1.0 - clampf(state_timer / maxf(0.1, state_duration), 0.0, 1.0)
		draw_line(Vector2(0, -16), charge_dir * (180.0 + 60.0 * p), Color(1.0, 0.25, 0.25, 0.45 + 0.45 * p), 4.0 + 3.0 * p)
	elif state_phase == "boss_nova":
		var nr: float = 152.0 if boss_phase >= 2 else 135.0
		var p: float = 1.0 - clampf(state_timer / maxf(0.1, state_duration), 0.0, 1.0)
		draw_circle(Vector2(0, -16), nr * p, Color(1.0, 0.35, 0.14, 0.18 * p))
		draw_arc(Vector2(0, -16), nr, 0.0, TAU, 44, Color(1.0, 0.35, 0.14, 0.88), 3.8)
	elif state_phase == "boss_wave_windup":
		var sig: Color = _get_signature_color()
		for ang_off in [-0.28, 0.0, 0.28]:
			draw_line(Vector2(0, -16), wave_aim_dir.rotated(float(ang_off)) * 215.0, Color(sig.r, sig.g, sig.b, 0.82), 4.0)
	elif state_phase == "boss_sig_windup":
		var sig: Color = _get_signature_color()
		var p: float = 1.0 - clampf(state_timer / maxf(0.1, state_duration), 0.0, 1.0)
		draw_arc(Vector2(0, -24), 48.0 + 32.0 * (1.0 - p), 0.0, TAU, 36, Color(sig.r, sig.g, sig.b, 0.90), 4.2)
		draw_line(Vector2(0, -18), wave_aim_dir * (160.0 + 90.0 * p), Color(1.0, 0.92, 0.65, 0.80), 3.6)

	# Hiệu ứng Vệt Chém / Sóng Xung Kích khi Boss & Quái tung đòn!
	if strike_vfx_timer > 0.0:
		var k_v: float = clampf(strike_vfx_timer / 0.28, 0.0, 1.0)
		var vc: Color = strike_vfx_color
		if strike_vfx_is_nova:
			var expand_r: float = strike_vfx_radius * (1.15 - 0.35 * k_v)
			draw_circle(Vector2(0, -18), expand_r, Color(vc.r, vc.g, vc.b, 0.22 * k_v))
			draw_arc(Vector2(0, -18), expand_r, 0.0, TAU, 48, Color(vc.r, vc.g, vc.b, 0.90 * k_v), 5.5 * k_v)
			draw_arc(Vector2(0, -18), expand_r * 0.65, 0.0, TAU, 36, Color(1.0, 0.95, 0.80, 0.80 * k_v), 3.0 * k_v)
		else:
			var base_a: float = strike_dir.angle()
			draw_arc(Vector2(0, -22), strike_vfx_radius, base_a - 1.05, base_a + 1.05, 22, Color(vc.r, vc.g, vc.b, 0.92 * k_v), 7.0 * k_v)
			draw_arc(Vector2(0, -22), strike_vfx_radius * 0.82, base_a - 0.85, base_a + 0.85, 18, Color(1.0, 0.98, 0.88, 0.85 * k_v), 3.5 * k_v)

	if (cur_hp < max_hp or is_boss_unit) and not boss_bar_shown:
		var bw: float = 88.0 if is_boss_unit else 58.0
		var bh: float = 8.0 if is_boss_unit else 6.0
		var y_off: float = -132.0 if is_boss_unit else -82.0
		draw_rect(Rect2(-bw * 0.5 - 2.0, y_off - 2.0, bw + 4.0, bh + 4.0), Color(0.06, 0.05, 0.10, 0.92))
		var ratio: float = clampf(cur_hp / maxf(1.0, max_hp), 0.0, 1.0)
		var bar_col: Color = Color("#FF2A5F") if (is_boss_unit and boss_phase >= 2) else (Color("#9D4EDD") if is_boss_unit else Color("#E63946"))
		draw_rect(Rect2(-bw * 0.5, y_off, bw * ratio, bh), bar_col)
