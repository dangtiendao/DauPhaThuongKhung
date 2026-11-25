extends CharacterBody2D
## Điều khiển Nhân vật chính TIÊU VIÊM — Phiên bản Tối Ưu Mượt 60–144 FPS & VFX Chiêu Thức:
## - Neo trục xoay bàn chân (Foot-Anchored Pivot) -> hết hẳn hiện tượng chân nhảy/trượt 12px khi đánh hay chạy!
## - Hỗ trợ linh hoạt 4 / 6 / 8 / 12 / 16+ frame (dải ngang lẫn lưới hframes × vframes) cho Idle, Run, Attack, Cast, Dash.
## - Combo 3 nhịp nối liền mượt không còn khe hở 40ms nhấp nháy + Input Buffer (0.14s) + Cancel bằng Dash/Skill + Hitstop toàn cục!
## - Weapon Trail (Line2D Additive), Shader Dị Hỏa chảy động và VFX 60 FPS riêng biệt cho trọn bộ 10+ Đấu Kỹ & Phật Nộ Hỏa Liên!

const SKILL_SCENE: PackedScene = preload("res://scenes/entities/skill_effect.tscn")
const TEX_LIGHT_RADIAL: Texture2D = preload("res://assets/sprites/vfx/light_radial_128.png")
const TEX_WING_PLUME: Texture2D = preload("res://assets/sprites/vfx/wing_plume.png")
const PlayerSkillExec = preload("res://scripts/entities/player_skill_executor.gd")
const BASE_FOOT_Y: float = 11.0
const INPUT_BUFFER_WINDOW: float = 0.14

var idle_tex: Texture2D
var run_tex: Texture2D
var attack_tex: Texture2D
var cast_tex: Texture2D
var dash_tex: Texture2D

var idle_meta: Dictionary = {}
var run_meta: Dictionary = {}
var attack_meta: Dictionary = {}
var cast_meta: Dictionary = {}
var dash_meta: Dictionary = {}

var anim_state: String = "idle"
var anim_timer: float = 0.0
var dust_timer: float = 0.0

# Động học mượt neo bàn chân (không reset cứng scale khi đổi sheet!)
var visual_scale: Vector2 = Vector2.ONE
var visual_rot: float = 0.0

var is_attacking: bool = false
var attack_anim_timer: float = 0.0
var attack_anim_duration: float = 0.24
var attack_frames: PackedInt32Array = PackedInt32Array([0, 1])
var attack_hit_triggered: bool = false
var attack_aim_dir: Vector2 = Vector2.RIGHT
var attack_is_skill_pose: bool = false
var attack_skill_style: String = "weapon" # "weapon" hoặc "cast"
var attack_follow_hold_timer: float = 0.0

# Pha tụ ấn 0.22s trước khi phóng Phật Nộ Hỏa Liên [F]
var pending_lotus_timer: float = 0.0
var pending_lotus_payload: Dictionary = {}

var combo_step: int = 0
var combo_reset_timer: float = 0.0
var attack_cooldown: float = 0.0
var lunge_vel: Vector2 = Vector2.ZERO

# Input Buffer 0.14s chống nuốt phím khi bấm nối combo / lướt / tung chiêu
var buffered_action: String = ""
var buffered_timer: float = 0.0

var dash_timer: float = 0.0
var dash_duration_cur: float = 0.18
var dash_speed_override: float = 0.0
var dash_cooldown: float = 0.0
var dash_dir: Vector2 = Vector2.RIGHT
var invuln_timer: float = 0.0

var knockback_vel: Vector2 = Vector2.ZERO
var duoc_lao_timer: float = 0.0
var flame_buff_timer: float = 0.0
var toc_van_timer: float = 0.0
var toc_van_free_casts: int = 0
var kim_khoi_tran_timer: float = 0.0
var kim_khoi_tran_tick: float = 0.0
var kim_khoi_tran_dmg: float = 0.0
var kim_khoi_tran_rad: float = 285.0
var tinh_lien_tran_timer: float = 0.0
var tinh_lien_tran_tick: float = 0.0
var tinh_lien_tran_dmg: float = 0.0
var tinh_lien_tran_rad: float = 390.0
var tieu_y_sprite: Sprite2D = null

# Hỏa Liên Phân Thân (3 quả cầu Dị Hỏa xoay quanh thân)
var flame_clone_timer: float = 0.0
var flame_clone_tick: float = 0.0
var flame_clone_dmg: float = 0.0
var flame_clone_radius: float = 135.0
var flame_clone_angle: float = 0.0
var flame_clone_r_pen: float = 0.30

# Linh Hồn Cảm Tri — Soul Radar [Z] & Đếm đòn Nội Thiêu Vẫn Lạc Tâm Viêm (#14)
var soul_radar_cd: float = 0.0
var inner_flame_hit_counter: int = 0

var skill_cooldowns: Dictionary = {
	"Q": 0.0,
	"E": 0.0,
	"R": 0.0,
	"F": 0.0,
	"T": 0.0,
	"X": 0.0
}
var skill_cooldown_totals: Dictionary = {
	"Q": 1.0,
	"E": 1.0,
	"R": 1.0,
	"F": 1.0,
	"T": 1.0,
	"X": 1.0
}
var dash_cooldown_total: float = 0.72

var slash_preview_timer: float = 0.0
var slash_preview_duration: float = 0.16
var slash_shader_mat: ShaderMaterial
var char_motion_mat: ShaderMaterial
var wing_shader_mat: ShaderMaterial
var wing_left_sprite: Sprite2D
var wing_right_sprite: Sprite2D
var hurt_flash_timer: float = 0.0

var shake_strength: float = 0.0
var shake_timer: float = 0.0
var shake_duration: float = 0.15
var cam_look_offset: Vector2 = Vector2.ZERO
var aim_reticle_alpha: float = 0.0

var active_core_col: Color = Color("#FFFFFF")
var active_mid_col: Color = Color("#70D6FF")
var active_outer_col: Color = Color("#2C5282")

var flame_light: PointLight2D
var ember_particles: CPUParticles2D
var weapon_trail: Line2D
var weapon_trail_points: Array[Vector2] = []
var weapon_trail_active: bool = false
var weapon_trail_fade: float = 0.0

var input_blocked_by_ui: bool = false

@onready var back_weapon_sprite: Sprite2D = $BackWeaponSprite
@onready var body_sprite: Sprite2D = $BodySprite
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var slash_vfx: Sprite2D = $WeaponPivot/SlashVfx
@onready var cam: Camera2D = $Camera2D


func _ready() -> void:
	add_to_group("player")
	idle_tex = load("res://assets/sprites/player/tieu_viem_idle.png")
	run_tex = load("res://assets/sprites/player/tieu_viem_run.png")
	if ResourceLoader.exists("res://assets/sprites/player/tieu_viem_cast.png"):
		cast_tex = load("res://assets/sprites/player/tieu_viem_cast.png")
	if ResourceLoader.exists("res://assets/sprites/player/tieu_viem_dash.png"):
		dash_tex = load("res://assets/sprites/player/tieu_viem_dash.png")

	idle_meta = SpriteAnimHelper.inspect_sheet(idle_tex, "square", 4, 2)
	run_meta = SpriteAnimHelper.inspect_sheet(run_tex, "square", 4, 2)
	if cast_tex != null:
		cast_meta = SpriteAnimHelper.inspect_sheet(cast_tex, "square", 8, 1)
	if dash_tex != null:
		dash_meta = SpriteAnimHelper.inspect_sheet(dash_tex, "square", 8, 1)

	_apply_body_sheet(idle_tex, idle_meta)
	char_motion_mat = VfxAssets.create_char_motion_material(active_mid_col, 0.007, 0.0)
	if char_motion_mat != null and body_sprite != null:
		body_sprite.material = char_motion_mat
		char_motion_mat.set_shader_parameter("hframes", float(body_sprite.hframes))
		char_motion_mat.set_shader_parameter("vframes", float(body_sprite.vframes))
	slash_vfx.visible = false
	_setup_lighting_particles_and_trail()
	_refresh_flame_shader()
	_refresh_equipped_weapon_visual()
	EventBus.flame_changed.connect(_on_flame_changed)
	EventBus.equipment_changed.connect(_refresh_equipped_weapon_visual)
	EventBus.screen_shake_requested.connect(_on_screen_shake)


func set_camera_limits(map_w: int, map_h: int) -> void:
	if cam == null:
		return
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = map_w
	cam.limit_bottom = map_h


func _refresh_equipped_weapon_visual() -> void:
	var has_wpn: bool = PlayerData.has_weapon_equipped()
	if has_wpn:
		var w_path: String = PlayerData.get_equipped_weapon_sprite_path()
		var back_tex: Texture2D = load(w_path)
		if back_tex != null and back_weapon_sprite != null:
			back_weapon_sprite.texture = back_tex
		back_weapon_sprite.visible = (not is_attacking and attack_follow_hold_timer <= 0.0)
	else:
		back_weapon_sprite.visible = false

	var atk_path: String = PlayerData.get_equipped_attack_sheet_path()
	var loaded_atk: Texture2D = load(atk_path)
	if loaded_atk != null:
		attack_tex = loaded_atk
		attack_meta = SpriteAnimHelper.inspect_sheet(attack_tex, "player_attack", 4, 2)


func _setup_lighting_particles_and_trail() -> void:
	flame_light = PointLight2D.new()
	flame_light.texture = TEX_LIGHT_RADIAL
	flame_light.texture_scale = 2.8
	flame_light.energy = 0.75
	flame_light.position = Vector2(0, -24)
	add_child(flame_light)

	ember_particles = CPUParticles2D.new()
	ember_particles.emitting = false
	ember_particles.amount = 22
	ember_particles.lifetime = 0.85
	ember_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	ember_particles.emission_sphere_radius = 28.0
	ember_particles.direction = Vector2(0, -1)
	ember_particles.spread = 45.0
	ember_particles.gravity = Vector2(0, -35)
	ember_particles.initial_velocity_min = 18.0
	ember_particles.initial_velocity_max = 48.0
	ember_particles.scale_amount_min = 0.18
	ember_particles.scale_amount_max = 0.40
	ember_particles.position = Vector2(0, -12)
	ember_particles.z_index = 2
	add_child(ember_particles)

	# Weapon Trail 60 FPS (vệt sáng cong đuôi vũ khí dùng Additive Blend)
	weapon_trail = Line2D.new()
	weapon_trail.top_level = false
	weapon_trail.z_index = 4
	weapon_trail.width = 18.0
	weapon_trail.joint_mode = Line2D.LINE_JOINT_ROUND
	weapon_trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	weapon_trail.end_cap_mode = Line2D.LINE_CAP_ROUND
	weapon_trail.antialiased = true
	weapon_trail.material = VfxAssets.get_additive_material()
	var w_curve := Curve.new()
	w_curve.add_point(Vector2(0.0, 0.08))
	w_curve.add_point(Vector2(0.65, 0.78))
	w_curve.add_point(Vector2(1.0, 1.0))
	weapon_trail.width_curve = w_curve
	add_child(weapon_trail)

	# Đôi Cánh Đấu Khí Hóa Dực VFX 2.0 (Texture lông vũ đa tầng + Shader cháy mép vfx_energy_dissolve!)
	wing_shader_mat = VfxAssets.create_energy_dissolve_material(Color("#FFFFFF"), Color("#00F5D4"), Color("#9D4EDD"), 1.38, 3.4, 0.024)
	wing_left_sprite = Sprite2D.new()
	wing_left_sprite.texture = TEX_WING_PLUME
	wing_left_sprite.flip_h = true
	wing_left_sprite.centered = false
	wing_left_sprite.offset = Vector2(-88.0, -72.0)
	wing_left_sprite.position = Vector2(-8.0, -34.0)
	wing_left_sprite.z_index = -1
	wing_left_sprite.visible = false
	if wing_shader_mat != null:
		wing_left_sprite.material = wing_shader_mat
	add_child(wing_left_sprite)

	wing_right_sprite = Sprite2D.new()
	wing_right_sprite.texture = TEX_WING_PLUME
	wing_right_sprite.flip_h = false
	wing_right_sprite.centered = false
	wing_right_sprite.offset = Vector2(-8.0, -72.0)
	wing_right_sprite.position = Vector2(8.0, -34.0)
	wing_right_sprite.z_index = -1
	wing_right_sprite.visible = false
	if wing_shader_mat != null:
		wing_right_sprite.material = wing_shader_mat
	add_child(wing_right_sprite)


func _apply_body_sheet(tex: Texture2D, meta: Dictionary) -> void:
	if tex == null or body_sprite == null:
		return
	SpriteAnimHelper.apply_to_sprite(body_sprite, tex, meta, BASE_FOOT_Y)
	if char_motion_mat != null:
		char_motion_mat.set_shader_parameter("hframes", float(body_sprite.hframes))
		char_motion_mat.set_shader_parameter("vframes", float(body_sprite.vframes))


func _on_flame_changed(_fid: String) -> void:
	_refresh_flame_shader()


func _refresh_flame_shader() -> void:
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var has_flame: bool = not f_def.is_empty()

	active_core_col = Color(str(f_def.get("core_hex", "#FFF3B0"))) if has_flame else Color("#FFFFFF")
	active_mid_col = Color(str(f_def.get("mid_hex", "#FF7B00"))) if has_flame else Color("#90D5FF")
	active_outer_col = Color(str(f_def.get("outer_hex", "#9E2A2B"))) if has_flame else Color("#3A6EA5")

	slash_shader_mat = VfxAssets.create_flame_material(
		active_core_col,
		active_mid_col,
		active_outer_col,
		1.75 if (has_flame or PlayerData.is_flame_buff_active) else 1.25,
		3.8,
		0.07
	)
	slash_vfx.material = slash_shader_mat

	if weapon_trail != null:
		var tg := Gradient.new()
		tg.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
		tg.colors = PackedColorArray([
			Color(active_outer_col.r, active_outer_col.g, active_outer_col.b, 0.0),
			Color(active_mid_col.r, active_mid_col.g, active_mid_col.b, 0.78),
			Color(active_core_col.r, active_core_col.g, active_core_col.b, 0.98)
		])
		weapon_trail.gradient = tg

	if flame_light != null:
		flame_light.color = active_mid_col.lerp(active_core_col, 0.25) if has_flame else Color("#DCE6F5")
		flame_light.energy = 1.50 if (PlayerData.is_duoc_lao_active or PlayerData.is_flame_buff_active) else (1.05 if has_flame else 0.65)
	if ember_particles != null:
		ember_particles.emitting = has_flame or PlayerData.is_flame_buff_active or PlayerData.is_duoc_lao_active
		VfxAssets.configure_glow_particles(ember_particles, active_core_col, active_mid_col, false)


func _process(delta: float) -> void:
	# Cập nhật Weapon Trail & Slash VFX theo _process() để mượt tối đa 60/120/144Hz
	if slash_preview_timer > 0.0:
		slash_preview_timer = maxf(0.0, slash_preview_timer - delta)
		var st: float = 1.0 - (slash_preview_timer / maxf(0.01, slash_preview_duration))
		if slash_shader_mat != null:
			slash_shader_mat.set_shader_parameter("dissolve", clampf(st * 1.15, 0.0, 1.0))
		slash_vfx.modulate.a = clampf(1.0 - st * st, 0.0, 1.0)
		if slash_preview_timer <= 0.0:
			slash_vfx.visible = false

	_update_weapon_trail(delta)
	_update_char_motion_shader(delta)
	_update_energy_wings(delta)
	queue_redraw()


func _update_energy_wings(_delta: float) -> void:
	if wing_left_sprite == null or wing_right_sprite == null:
		return
	var show_w: bool = PlayerData.has_dau_vuong_wings()
	wing_left_sprite.visible = show_w
	wing_right_sprite.visible = show_w
	if not show_w:
		return
	var t_sec: float = float(Time.get_ticks_msec()) * 0.001
	var is_dt: bool = PlayerData.has_dau_tong_void_step()
	var is_dh: bool = (PlayerData.realm_index >= 7)
	var is_dash: bool = (dash_timer > 0.0)
	var flap: float = sin(t_sec * (13.0 if is_dash else 5.4))
	var base_sc: float = (0.76 if is_dt else (0.70 if is_dh else 0.62)) * (1.22 if is_dash else 1.0)
	var rot_mag: float = (0.24 if is_dash else 0.14) * flap
	wing_left_sprite.scale = Vector2(base_sc, base_sc * (0.94 + 0.08 * flap))
	wing_right_sprite.scale = Vector2(base_sc, base_sc * (0.94 + 0.08 * flap))
	wing_left_sprite.rotation = rot_mag - (0.14 if is_dash else 0.04)
	wing_right_sprite.rotation = -rot_mag + (0.14 if is_dash else 0.04)
	if wing_shader_mat != null:
		if PlayerData.is_tam_bien_active:
			wing_shader_mat.set_shader_parameter("core_color", Color("#FFFFFF"))
			wing_shader_mat.set_shader_parameter("mid_color", Color("#FFD166"))
			wing_shader_mat.set_shader_parameter("outer_color", Color("#C77DFF"))
			wing_shader_mat.set_shader_parameter("intensity", 1.72 if is_dash else 1.52)
		elif is_dt:
			wing_shader_mat.set_shader_parameter("core_color", Color("#FFFFFF"))
			wing_shader_mat.set_shader_parameter("mid_color", Color("#72EFDD"))
			wing_shader_mat.set_shader_parameter("outer_color", Color("#A855F7"))
			wing_shader_mat.set_shader_parameter("intensity", 1.62 if is_dash else 1.42)
		elif is_dh:
			wing_shader_mat.set_shader_parameter("core_color", Color("#FFF8D6"))
			wing_shader_mat.set_shader_parameter("mid_color", Color("#FFD166"))
			wing_shader_mat.set_shader_parameter("outer_color", Color("#00F5D4"))
			wing_shader_mat.set_shader_parameter("intensity", 1.55 if is_dash else 1.36)
		else:
			var has_vl: bool = PlayerData.has_van_lac_passive()
			wing_shader_mat.set_shader_parameter("core_color", Color("#FFFFFF"))
			wing_shader_mat.set_shader_parameter("mid_color", Color("#E0AAFF") if has_vl else Color("#48CAE4"))
			wing_shader_mat.set_shader_parameter("outer_color", Color("#00F5D4") if has_vl else Color("#3A6EA5"))
			wing_shader_mat.set_shader_parameter("intensity", 1.45 if is_dash else 1.28)


func _update_char_motion_shader(delta: float) -> void:
	if char_motion_mat == null:
		return
	if hurt_flash_timer > 0.0:
		hurt_flash_timer = maxf(0.0, hurt_flash_timer - delta)
	var sway_a: float = 0.0085 if anim_state == "idle" else (0.0115 if dash_timer > 0.0 else (0.0032 if anim_state == "run" else 0.0045))
	var sway_s: float = 3.4 if anim_state == "idle" else (8.5 if dash_timer > 0.0 else 5.2)
	var rim_c: Color = active_mid_col
	var rim_s: float = 0.24 if not PlayerData.get_active_flame_def().is_empty() else 0.0
	if PlayerData.is_toc_van_active:
		rim_c = Color("#FF4D6D")
		rim_s = 1.42
	elif PlayerData.is_kim_khoi_tran_active:
		rim_c = Color("#FFD166")
		rim_s = 1.32
	elif PlayerData.is_tam_bien_active:
		rim_c = Color("#FFD166")
		rim_s = 1.28
	elif PlayerData.is_nhi_bien_active:
		rim_c = Color("#00F5D4")
		rim_s = 1.18
	elif PlayerData.is_flame_buff_active:
		rim_c = Color("#FF4D6D")
		rim_s = 1.05
	elif PlayerData.is_duoc_lao_active:
		var am_s: String = PlayerData.get_assist_mode()
		rim_c = Color("#FFD166") if am_s == "thien_yeu_khoi" else (Color("#CAF0F8") if am_s == "dia_yeu_khoi" else (Color("#E0AAFF") if am_s == "medusa_dau_tong" else Color("#A8DADC")))
		rim_s = 1.24 if am_s == "thien_yeu_khoi" else 1.12
	elif PlayerData.has_dau_tong_void_step():
		rim_c = Color("#72EFDD")
		rim_s = maxf(rim_s, 0.80)
	elif PlayerData.realm_index >= 7:
		rim_c = Color("#FFD166")
		rim_s = maxf(rim_s, 0.72)
	elif PlayerData.has_dau_vuong_wings():
		rim_c = Color("#00F5D4") if not PlayerData.has_van_lac_passive() else Color("#E0AAFF")
		rim_s = maxf(rim_s, 0.62)
	if is_attacking:
		rim_s = maxf(rim_s, 0.85)
	elif dash_timer > 0.0:
		rim_s = maxf(rim_s, 0.72)
	char_motion_mat.set_shader_parameter("sway_amp", sway_a)
	char_motion_mat.set_shader_parameter("sway_speed", sway_s)
	char_motion_mat.set_shader_parameter("rim_color", rim_c)
	char_motion_mat.set_shader_parameter("rim_strength", rim_s)
	char_motion_mat.set_shader_parameter("hit_flash", clampf(hurt_flash_timer / 0.11, 0.0, 1.0))


func _update_weapon_trail(delta: float) -> void:
	if weapon_trail == null:
		return
	if weapon_trail_active and is_attacking and attack_skill_style == "weapon":
		var prog: float = clampf(attack_anim_timer / maxf(0.05, attack_anim_duration), 0.0, 1.0)
		var sweep_t: float = clampf((prog - 0.16) / 0.68, 0.0, 1.0)
		if sweep_t > 0.0 and sweep_t < 1.0:
			var ease_s: float = 1.0 - pow(1.0 - sweep_t, 3.0)
			var flip_s: float = -1.0 if (combo_step == 2) else 1.0
			var span: float = 2.35 if combo_step >= 3 else 1.75
			var ang: float = attack_aim_dir.angle() + flip_s * lerpf(-span * 0.52, span * 0.52, ease_s)
			var reach_r: float = (94.0 if PlayerData.has_weapon_equipped() else 64.0) * (1.14 if combo_step >= 3 else 1.0) * PlayerData.get_attack_reach_multiplier()
			var pt: Vector2 = Vector2(0.0, -26.0) + Vector2(cos(ang), sin(ang)) * reach_r
			weapon_trail_points.append(pt)
			if weapon_trail_points.size() > 11:
				weapon_trail_points.pop_front()
			weapon_trail_fade = 1.0
	else:
		weapon_trail_active = false
		if not weapon_trail_points.is_empty():
			weapon_trail_fade = maxf(0.0, weapon_trail_fade - delta * 8.5)
			if weapon_trail_points.size() > 2 and weapon_trail_fade < 0.85:
				weapon_trail_points.pop_front()
			if weapon_trail_fade <= 0.02:
				weapon_trail_points.clear()

	weapon_trail.clear_points()
	for p in weapon_trail_points:
		weapon_trail.add_point(p)
	weapon_trail.modulate.a = weapon_trail_fade


func _physics_process(delta: float) -> void:
	_tick_timers(delta)
	if input_blocked_by_ui:
		velocity = Vector2.ZERO
		_update_character_animation(delta, false)
		return

	_handle_aim_and_flip()
	_handle_combat_inputs()
	_try_consume_input_buffer()

	# Hỏa Liên Phân Thân: xoay 3 quả cầu Dị Hỏa quanh thân và tự động đánh lan mỗi 0.55s!
	if flame_clone_timer > 0.0:
		flame_clone_timer = maxf(0.0, flame_clone_timer - delta)
		flame_clone_angle += delta * 4.4
		flame_clone_tick -= delta
		if flame_clone_tick <= 0.0:
			flame_clone_tick = 0.55
			_pulse_flame_clone_burst()
		if flame_clone_timer <= 0.0:
			_detonate_flame_clone_finale()

	# Thập Tuyệt Kim Khôi Trận (Ch.09): 10 Kim Sắc Thiên Yêu Khôi giật thiên lôi quanh thân mỗi 1.2s!
	if kim_khoi_tran_timer > 0.0:
		kim_khoi_tran_timer = maxf(0.0, kim_khoi_tran_timer - delta)
		kim_khoi_tran_tick -= delta
		if kim_khoi_tran_tick <= 0.0:
			kim_khoi_tran_tick = 1.20
			PlayerSkillExec.pulse_kim_khoi_tran(self)
		if kim_khoi_tran_timer <= 0.0:
			PlayerData.is_kim_khoi_tran_active = false
			_refresh_flame_shader()
			EventBus.stats_changed.emit()
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Thu Hồi Thập Tuyệt Kim Khôi Trận", Color("#ADB5BD"))

	# Tịnh Liên Yêu Trận (Ch.10): 12 Cánh Sen Lửa Trắng-Hồng thiêu đốt 5% HP/s mỗi 1.0s!
	if tinh_lien_tran_timer > 0.0:
		tinh_lien_tran_timer = maxf(0.0, tinh_lien_tran_timer - delta)
		tinh_lien_tran_tick -= delta
		if tinh_lien_tran_tick <= 0.0:
			tinh_lien_tran_tick = 1.0
			PlayerSkillExec.pulse_tinh_lien_tran(self)
		if tinh_lien_tran_timer <= 0.0:
			PlayerData.is_tinh_lien_tran_active = false
			_refresh_flame_shader()
			EventBus.stats_changed.emit()
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Thu Hồi Tịnh Liên Yêu Trận", Color("#FDA4AF"))

	# Khí Linh Yêu Hỏa "Tiểu Y" (#3 Tịnh Liên) bay hộ vệ thường trực bên vai phải Tiêu Viêm!
	var want_tieu_y: bool = SaintRealmManager.has_tieu_y_spirit(PlayerData)
	if want_tieu_y:
		if tieu_y_sprite == null:
			tieu_y_sprite = Sprite2D.new()
			tieu_y_sprite.texture = load("res://assets/sprites/npcs/npc_tieu_y.png")
			tieu_y_sprite.scale = Vector2(0.46, 0.46)
			tieu_y_sprite.z_index = 4
			add_child(tieu_y_sprite)
		tieu_y_sprite.visible = true
		var ty_t: float = float(Time.get_ticks_msec()) * 0.004
		var side_x: float = -34.0 if body_sprite.flip_h else 34.0
		tieu_y_sprite.position = Vector2(side_x + cos(ty_t * 0.8) * 5.0, -56.0 + sin(ty_t * 1.4) * 6.0)
	elif tieu_y_sprite != null:
		tieu_y_sprite.visible = false

	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_vel: Vector2 = Vector2.ZERO
	if dash_timer > 0.0:
		var has_dt_dom: bool = SaintRealmManager.has_dau_thanh_domain(PlayerData)
		var d_spd: float = dash_speed_override if dash_speed_override > 0.0 else (SaintRealmManager.SAINT_DASH_SPEED if has_dt_dom else (980.0 if PlayerData.has_dau_ton_spatial_blink() else (860.0 if PlayerData.has_dau_tong_void_step() else (780.0 if PlayerData.has_dau_vuong_wings() else (695.0 if PlayerData.has_tu_van_duc_equipped() else 560.0)))))
		desired_vel = dash_dir * d_spd
		velocity = desired_vel
		if int(floor(dash_timer * 46.0)) != int(floor((dash_timer - delta) * 46.0)):
			_spawn_dash_afterimage()
	elif is_attacking:
		var move_factor: float = 0.25 if attack_skill_style == "cast" else 0.40
		desired_vel = move_input * (PlayerData.get_move_speed() * move_factor) + lunge_vel + knockback_vel
		velocity = velocity.lerp(desired_vel, minf(1.0, delta * 24.0))
	else:
		if move_input.length() > 0.15 and attack_follow_hold_timer > 0.0:
			# Di chuyển chủ động thoát mượt khỏi tư thế dư lực sau đòn đánh!
			attack_follow_hold_timer = 0.0
		desired_vel = move_input * PlayerData.get_move_speed() + lunge_vel + knockback_vel
		velocity = velocity.lerp(desired_vel, minf(1.0, delta * 20.0))

	_update_character_animation(delta, move_input.length() > 0.1)

	lunge_vel = lunge_vel.move_toward(Vector2.ZERO, 1750.0 * delta)
	knockback_vel = knockback_vel.move_toward(Vector2.ZERO, 1080.0 * delta)
	move_and_slide()


func _update_character_animation(delta: float, is_moving: bool) -> void:
	var smooth_k: float = minf(1.0, delta * 20.0)
	var target_sc := Vector2.ONE
	var target_rot: float = 0.0

	if dash_timer > 0.0:
		back_weapon_sprite.visible = PlayerData.has_weapon_equipped()
		if dash_tex != null:
			if anim_state != "dash":
				anim_state = "dash"
				_apply_body_sheet(dash_tex, dash_meta)
			var df_cnt: int = maxi(1, int(dash_meta.get("total_frames", 1)))
			var dash_prog: float = 1.0 - clampf(dash_timer / maxf(0.05, dash_duration_cur), 0.0, 1.0)
			body_sprite.frame = clampi(int(dash_prog * float(df_cnt)), 0, df_cnt - 1)
		else:
			if anim_state != "run":
				anim_state = "run"
				_apply_body_sheet(run_tex, run_meta)
			var rf_cnt: int = maxi(1, int(run_meta.get("total_frames", 4)))
			body_sprite.frame = mini(1, rf_cnt - 1)
		var f_s: float = -1.0 if body_sprite.flip_h else 1.0
		target_sc = Vector2(1.16, 0.86)
		target_rot = f_s * 0.16
		visual_scale = visual_scale.lerp(target_sc, smooth_k)
		visual_rot = lerpf(visual_rot, target_rot, smooth_k)
		body_sprite.scale = visual_scale
		body_sprite.rotation = visual_rot
		return

	if is_attacking:
		back_weapon_sprite.visible = false
		attack_anim_timer += delta
		var progress: float = clampf(attack_anim_timer / maxf(0.05, attack_anim_duration), 0.0, 1.0)
		var f_sign: float = -1.0 if body_sprite.flip_h else 1.0
		var n_frames: int = maxi(1, attack_frames.size())

		if attack_skill_style == "cast":
			var c_idx: int = clampi(int(progress * float(n_frames)), 0, n_frames - 1)
			body_sprite.frame = attack_frames[c_idx]
			if progress < 0.45:
				var p_t: float = progress / 0.45
				target_sc = Vector2(0.92 - 0.04 * p_t, 1.08 + 0.05 * p_t)
				target_rot = -f_sign * 0.07 * p_t
			else:
				var r_t: float = (progress - 0.45) / 0.55
				target_sc = Vector2(1.14, 0.89).lerp(Vector2.ONE, r_t)
				target_rot = f_sign * 0.09 * (1.0 - r_t)
		else:
			# Quét mượt qua toàn bộ danh sách attack_frames (chuẩn 8-frame sheet: 4f/combo & 7f combo 3!)
			var hit_threshold: float = 0.24 if n_frames <= 2 else 0.30
			var f_idx: int = 0
			if n_frames == 2:
				f_idx = 0 if progress < hit_threshold else 1
			elif n_frames >= 4:
				# Dành 2 frame đầu (0 -> 1) cho pha Windup & Đà vung, các frame sau cho Impact -> Follow-through!
				if progress < hit_threshold:
					var w_p: float = clampf(progress / hit_threshold, 0.0, 0.999)
					f_idx = int(w_p * 2.0)
				else:
					var rem_p: float = clampf((progress - hit_threshold) / (1.0 - hit_threshold), 0.0, 0.999)
					f_idx = 2 + int(rem_p * float(n_frames - 2))
			else:
				if progress < hit_threshold:
					f_idx = 0
				else:
					var rem_p3: float = clampf((progress - hit_threshold) / (1.0 - hit_threshold), 0.0, 0.999)
					f_idx = 1 + int(rem_p3 * float(n_frames - 1))
			body_sprite.frame = attack_frames[clampi(f_idx, 0, n_frames - 1)]

			if progress < hit_threshold:
				target_sc = Vector2(0.91, 1.09)
				target_rot = -f_sign * 0.09
			else:
				var strike_t: float = clampf((progress - hit_threshold) / (1.0 - hit_threshold), 0.0, 1.0)
				target_sc = Vector2(1.13, 0.89).lerp(Vector2.ONE, strike_t)
				target_rot = f_sign * 0.11 * (1.0 - strike_t)
				if not attack_hit_triggered:
					attack_hit_triggered = true
					if not attack_is_skill_pose:
						_execute_melee_strike_impact()

		visual_scale = visual_scale.lerp(target_sc, smooth_k)
		visual_rot = lerpf(visual_rot, target_rot, smooth_k)
		body_sprite.scale = visual_scale
		body_sprite.rotation = visual_rot

		if attack_anim_timer >= attack_anim_duration:
			is_attacking = false
			weapon_trail_active = false
			# Giữ mượt tư thế dư lực 0.11s nếu người chơi đang chuẩn bị nối Combo -> TRIỆT TIÊU nhấp nháy 40ms về Idle!
			var mouse_over_ui: bool = (get_viewport().gui_get_hovered_control() != null)
			var chaining: bool = (buffered_action == "attack") or (Input.is_action_pressed("attack") and not mouse_over_ui)
			if chaining and not attack_is_skill_pose:
				attack_follow_hold_timer = 0.0
				_start_integrated_combo_attack()
				return
			else:
				attack_follow_hold_timer = 0.11
		return

	# Tư thế dư lực ngắn (follow-through hold) sau khi kết thúc đòn đánh
	if attack_follow_hold_timer > 0.0:
		back_weapon_sprite.visible = false
		visual_scale = visual_scale.lerp(Vector2.ONE, smooth_k)
		visual_rot = lerpf(visual_rot, 0.0, smooth_k)
		body_sprite.scale = visual_scale
		body_sprite.rotation = visual_rot
		return

	back_weapon_sprite.visible = PlayerData.has_weapon_equipped()
	var desired_state: String = "run" if is_moving else "idle"
	if desired_state != anim_state:
		anim_state = desired_state
		anim_timer = 0.0
		if is_moving:
			_apply_body_sheet(run_tex, run_meta)
		else:
			_apply_body_sheet(idle_tex, idle_meta)

	var t_sec: float = float(Time.get_ticks_msec()) * 0.001
	if is_moving:
		var run_total: int = maxi(1, int(run_meta.get("total_frames", 4)))
		var spd_ratio: float = clampf(velocity.length() / 245.0, 0.78, 1.38)
		var base_run_fps: float = clampf(8.5 + float(run_total) * 0.65, 9.5, 15.0)
		anim_timer += delta * base_run_fps * spd_ratio
		body_sprite.frame = int(anim_timer) % run_total
		var hop: float = absf(sin(anim_timer * (PI / maxf(2.0, float(run_total) * 0.5))))
		var hop_amp: float = 0.014 if run_total >= 6 else 0.028
		target_sc = Vector2(1.0 - hop_amp * hop, 1.0 + hop_amp * 1.25 * hop)
		target_rot = clampf(velocity.x / 260.0, -1.0, 1.0) * (0.045 if run_total >= 6 else 0.065)
		back_weapon_sprite.position.y = lerpf(back_weapon_sprite.position.y, -34.0 + sin(anim_timer * 1.4) * 2.0, smooth_k)
		dust_timer -= delta
		if dust_timer <= 0.0:
			dust_timer = 0.16
			VfxAssets.spawn_dust_puff(get_parent(), global_position + Vector2(0, 11), Color(0.74, 0.78, 0.84, 0.42), 5, 75.0, 0.9)
	else:
		var idle_total: int = maxi(1, int(idle_meta.get("total_frames", 8)))
		if idle_total > 1:
			var idle_fps: float = clampf(4.2 + float(idle_total) * 0.62, 5.8, 10.5)
			anim_timer += delta * idle_fps
			body_sprite.frame = int(anim_timer) % idle_total
			var breath_s: float = sin(t_sec * 3.0) * 0.008
			target_sc = Vector2(1.0 - breath_s * 0.5, 1.0 + breath_s)
		else:
			body_sprite.frame = 0
			var breath: float = sin(t_sec * 3.4) * 0.022
			target_sc = Vector2(1.0 - breath * 0.5, 1.0 + breath)
		target_rot = 0.0
		back_weapon_sprite.position.y = lerpf(back_weapon_sprite.position.y, -34.0 + sin(t_sec * 3.2) * 1.3, smooth_k)

	visual_scale = visual_scale.lerp(target_sc, smooth_k)
	visual_rot = lerpf(visual_rot, target_rot, smooth_k)
	body_sprite.scale = visual_scale
	body_sprite.rotation = visual_rot


func _spawn_hit_sparks(world_pos: Vector2, spark_col: Color, dir_v: Vector2 = Vector2.RIGHT, count: int = 12) -> void:
	VfxAssets.spawn_spark_burst(get_parent(), world_pos, Color.WHITE.lerp(spark_col, 0.35), spark_col, count, 85.0, 215.0, 0.30, dir_v, 145.0, 0.25, 0.55, true)


func _spawn_skill_vfx(mode: String, world_pos: Vector2, dir_vec: Vector2, rad: float, dur: float, c_core: Color, c_mid: Color, c_outer: Color, opts: Dictionary = {}) -> void:
	if get_parent() == null:
		return
	var vfx := SkillVfxBurst.new()
	get_parent().add_child(vfx)
	vfx.configure(mode, world_pos, dir_vec, rad, dur, c_core, c_mid, c_outer, opts)


func _tick_timers(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown = maxf(0.0, attack_cooldown - delta)
	if attack_follow_hold_timer > 0.0:
		attack_follow_hold_timer = maxf(0.0, attack_follow_hold_timer - delta)
		if attack_follow_hold_timer <= 0.0 and not is_attacking:
			anim_state = ""
	if buffered_timer > 0.0:
		buffered_timer -= delta
		if buffered_timer <= 0.0:
			buffered_action = ""
	if combo_reset_timer > 0.0:
		combo_reset_timer -= delta
		if combo_reset_timer <= 0.0:
			combo_step = 0
	if dash_timer > 0.0:
		dash_timer = maxf(0.0, dash_timer - delta)
		if dash_timer <= 0.0:
			dash_speed_override = 0.0
	if dash_cooldown > 0.0:
		dash_cooldown = maxf(0.0, dash_cooldown - delta)
		EventBus.skill_cooldown_updated.emit("SPACE", dash_cooldown, dash_cooldown_total)
	if invuln_timer > 0.0:
		invuln_timer = maxf(0.0, invuln_timer - delta)
	if soul_radar_cd > 0.0:
		soul_radar_cd = maxf(0.0, soul_radar_cd - delta)

	# Hoàn tất pha tụ ấn 0.22s của Phật Nộ Hỏa Liên -> phóng Đóa Sen Lửa!
	if pending_lotus_timer > 0.0:
		pending_lotus_timer -= delta
		if pending_lotus_timer <= 0.0 and not pending_lotus_payload.is_empty():
			_launch_pending_fire_lotus()

	if PlayerData.is_duoc_lao_active:
		duoc_lao_timer -= delta
		body_sprite.modulate = Color(0.84, 0.96, 1.12, 1.0)
		if duoc_lao_timer <= 0.0:
			PlayerData.is_duoc_lao_active = false
			body_sprite.modulate = Color.WHITE
			_refresh_flame_shader()
			EventBus.stats_changed.emit()
			EventBus.banter_triggered.emit("Dược Lão: 'Hồn lực lão phu tiêu hao không ít rồi, phần còn lại giao cho con!'")

	if PlayerData.is_flame_buff_active or PlayerData.is_nhi_bien_active or PlayerData.is_tam_bien_active:
		flame_buff_timer -= delta
		if flame_buff_timer <= 0.0:
			var was_t3: bool = PlayerData.is_tam_bien_active
			var was_t2: bool = PlayerData.is_nhi_bien_active
			PlayerData.is_flame_buff_active = false
			PlayerData.is_nhi_bien_active = false
			PlayerData.is_tam_bien_active = false
			_refresh_flame_shader()
			EventBus.stats_changed.emit()
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -68), "Hết Thiên Hỏa Tam Biến" if was_t3 else ("Hết Thiên Hỏa Nhị Biến" if was_t2 else "Hết Thiên Hỏa Tam Huyền Biến"), Color("#ADB5BD"))

	if PlayerData.is_toc_van_active:
		toc_van_timer -= delta
		if toc_van_timer <= 0.0:
			PlayerData.is_toc_van_active = false
			toc_van_free_casts = 0
			_refresh_flame_shader()
			EventBus.stats_changed.emit()
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Hết Tộc Văn Tiêu Tộc", Color("#ADB5BD"))

	# Nội tại #9 Tam Thiên Diễm Viêm Hỏa (Bất Tử Chi Thân): hồi 3.5% Max HP/giây khi HP < 45%!
	if PlayerData.immortal_revive_cd > 0.0:
		PlayerData.immortal_revive_cd = maxf(0.0, PlayerData.immortal_revive_cd - delta)
	if PlayerData.has_tam_thien_immortal_body() and PlayerData.current_hp > 0.0:
		var max_hp_tt: float = PlayerData.get_max_hp()
		if PlayerData.current_hp < max_hp_tt * 0.45:
			PlayerData.tam_thien_regen_tick += delta
			if PlayerData.tam_thien_regen_tick >= 1.0:
				PlayerData.tam_thien_regen_tick -= 1.0
				var regen_amt: float = max_hp_tt * 0.035
				PlayerData.current_hp = minf(max_hp_tt, PlayerData.current_hp + regen_amt)
				EventBus.floating_text_requested.emit(global_position + Vector2(0, -70), "✦ Tinh Thể +%d HP" % int(round(regen_amt)), Color("#C77DFF"))
				EventBus.stats_changed.emit()
		else:
			PlayerData.tam_thien_regen_tick = 0.0

	# Hồi Đấu Khí dùng tín hiệu qi_updated siêu nhẹ (KHÔNG gây bão _refresh_moba_dock 60Hz!)
	var max_qi: float = PlayerData.get_max_qi()
	var qi_regen: float = 3.6 + float(PlayerData.realm_index) * 1.8
	if PlayerData.has_flag("got_thanh_lien_dai"):
		qi_regen *= 1.40
	if PlayerData.current_qi < max_qi:
		PlayerData.current_qi = minf(max_qi, PlayerData.current_qi + qi_regen * delta)
		EventBus.qi_updated.emit(PlayerData.current_qi, max_qi)

	for k in skill_cooldowns.keys():
		var cur_cd: float = float(skill_cooldowns[k])
		if cur_cd > 0.0:
			cur_cd = maxf(0.0, cur_cd - delta)
			skill_cooldowns[k] = cur_cd
			EventBus.skill_cooldown_updated.emit(str(k), cur_cd, float(skill_cooldown_totals.get(k, 1.0)))

	# Camera Look-Ahead mượt theo con trỏ chuột (Task 3) + Rung màn hình có hệ số shake_scale!
	var look_target: Vector2 = Vector2.ZERO
	if not input_blocked_by_ui:
		var m_off: Vector2 = get_global_mouse_position() - global_position
		var look_len: float = minf(m_off.length() * 0.14, 58.0)
		if m_off.length() > 24.0:
			look_target = m_off.normalized() * look_len
			look_target.y *= 0.68
	cam_look_offset = cam_look_offset.lerp(look_target, minf(1.0, delta * 6.5))

	var shake_vec: Vector2 = Vector2.ZERO
	if shake_timer > 0.0:
		shake_timer = maxf(0.0, shake_timer - delta)
		var decay: float = clampf(shake_timer / maxf(0.02, shake_duration), 0.0, 1.0)
		var user_shake_mult: float = float(AudioManager.get("shake_scale")) if "shake_scale" in AudioManager else 1.0
		var cur_str: float = shake_strength * decay * user_shake_mult
		shake_vec = Vector2(randf_range(-cur_str, cur_str), randf_range(-cur_str, cur_str))
		if shake_timer <= 0.0:
			shake_strength = 0.0
	if cam != null:
		cam.offset = cam_look_offset + shake_vec

	aim_reticle_alpha = lerpf(aim_reticle_alpha, 0.0 if input_blocked_by_ui else 0.72, minf(1.0, delta * 10.0))


func _handle_aim_and_flip() -> void:
	if is_attacking or dash_timer > 0.0:
		return
	var mouse_world: Vector2 = get_global_mouse_position()
	var aim_vec: Vector2 = mouse_world - global_position
	if absf(aim_vec.x) > 4.0:
		var facing_left: bool = aim_vec.x < 0.0
		body_sprite.flip_h = facing_left
		back_weapon_sprite.flip_h = facing_left
		back_weapon_sprite.position.x = 6.0 if facing_left else -6.0
		back_weapon_sprite.rotation = 0.68 if facing_left else -0.68


func _queue_buffer(action_name: String) -> void:
	buffered_action = action_name
	buffered_timer = INPUT_BUFFER_WINDOW


func _can_cancel_attack_early() -> bool:
	return (not is_attacking) or attack_hit_triggered


func _handle_combat_inputs() -> void:
	var mouse_over_ui: bool = (get_viewport().gui_get_hovered_control() != null)

	if Input.is_action_just_pressed("toggle_weight"):
		if not (mouse_over_ui and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
			trigger_ui_toggle_weight()

	if Input.is_action_just_pressed("toggle_companion"):
		trigger_ui_toggle_companion()

	if InputMap.has_action("soul_radar") and Input.is_action_just_pressed("soul_radar"):
		if soul_radar_cd <= 0.0:
			soul_radar_cd = 6.0
			EventBus.soul_radar_pulsed.emit(global_position, PlayerData.get_soul_radar_radius())
			EventBus.audio_sfx_requested.emit("radar_ping")
		else:
			EventBus.floating_text_requested.emit(
				global_position + Vector2(0, -68),
				"Linh Hồn Cảm Tri hồi chiêu: %.1fs" % soul_radar_cd,
				Color("#ADB5BD")
			)

	if Input.is_action_just_pressed("dash"):
		if dash_cooldown <= 0.0 and _can_cancel_attack_early():
			_perform_dash()
		else:
			_queue_buffer("dash")

	if Input.is_action_just_pressed("skill_q"):
		if _can_cancel_attack_early() and float(skill_cooldowns.get("Q", 0.0)) <= 0.0:
			trigger_ui_skill("Q")
		else:
			_queue_buffer("skill_Q")
	if Input.is_action_just_pressed("skill_e"):
		if _can_cancel_attack_early() and float(skill_cooldowns.get("E", 0.0)) <= 0.0:
			trigger_ui_skill("E")
		else:
			_queue_buffer("skill_E")
	if Input.is_action_just_pressed("skill_r"):
		if _can_cancel_attack_early() and float(skill_cooldowns.get("R", 0.0)) <= 0.0:
			trigger_ui_skill("R")
		else:
			_queue_buffer("skill_R")
	if Input.is_action_just_pressed("skill_ult"):
		if _can_cancel_attack_early() and float(skill_cooldowns.get("F", 0.0)) <= 0.0:
			trigger_ui_skill("F")
		else:
			_queue_buffer("skill_F")
	if Input.is_action_just_pressed("skill_assist"):
		if _can_cancel_attack_early() and float(skill_cooldowns.get("T", 0.0)) <= 0.0:
			trigger_ui_skill("T")
		else:
			_queue_buffer("skill_T")
	if InputMap.has_action("toc_van_crest") and Input.is_action_just_pressed("toc_van_crest"):
		trigger_ui_toc_van()

	if not mouse_over_ui:
		if Input.is_action_just_pressed("attack"):
			if attack_cooldown <= 0.0 and not is_attacking and dash_timer <= 0.0:
				_start_integrated_combo_attack()
			else:
				_queue_buffer("attack")
		elif Input.is_action_pressed("attack") and attack_cooldown <= 0.0 and not is_attacking and dash_timer <= 0.0:
			_start_integrated_combo_attack()

	if Input.is_action_just_pressed("quick_pill_1"):
		trigger_ui_use_pill(1)
	if Input.is_action_just_pressed("quick_pill_2"):
		trigger_ui_use_pill(2)
	if Input.is_action_just_pressed("quick_pill_3"):
		trigger_ui_use_pill(3)


func _try_consume_input_buffer() -> void:
	if buffered_action == "" or buffered_timer <= 0.0:
		return
	if buffered_action == "dash":
		if dash_cooldown <= 0.0 and _can_cancel_attack_early():
			buffered_action = ""
			buffered_timer = 0.0
			_perform_dash()
	elif buffered_action == "attack":
		if attack_cooldown <= 0.0 and not is_attacking and dash_timer <= 0.0:
			buffered_action = ""
			buffered_timer = 0.0
			_start_integrated_combo_attack()
	elif buffered_action.begins_with("skill_"):
		var sk_key: String = buffered_action.substr(6)
		if _can_cancel_attack_early() and float(skill_cooldowns.get(sk_key, 0.0)) <= 0.0:
			buffered_action = ""
			buffered_timer = 0.0
			trigger_ui_skill(sk_key)


func trigger_ui_attack() -> void:
	if input_blocked_by_ui:
		return
	if attack_cooldown <= 0.0 and not is_attacking:
		_start_integrated_combo_attack()
	else:
		_queue_buffer("attack")


func trigger_ui_dash() -> void:
	if input_blocked_by_ui:
		return
	if dash_cooldown <= 0.0:
		_perform_dash()
	else:
		_queue_buffer("dash")


func trigger_ui_toggle_weight() -> void:
	if input_blocked_by_ui:
		return
	if PlayerData.toggle_ruler_seal():
		var seal_txt: String = "PHONG ẤN TRỌNG XÍCH (+30% EXP)" if PlayerData.is_ruler_sealed else "GIẢI PHONG TRỌNG XÍCH (Tốc độ 100%)"
		var seal_col: Color = Color("#70D6FF") if PlayerData.is_ruler_sealed else Color("#FF9F1C")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -68), seal_txt, seal_col)
	else:
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -68), "Cần đeo Huyền Trọng Xích để bật Trọng Áp!", Color("#ADB5BD"))


func trigger_ui_toggle_companion() -> void:
	if input_blocked_by_ui:
		return
	if PlayerData.unlocked_companions.is_empty():
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -70), "Chưa mở Đồng Hành [G]!", Color("#ADB5BD"))
		EventBus.banter_triggered.emit("Gợi ý cốt truyện: Hoàn thành Chương 01 (Hồn Ảnh Dược Lão) hoặc gặp Tiểu Y Tiên (Chương 02) để triệu hồi Đồng Hành [G]!")
	else:
		var next_c: String = PlayerData.cycle_companion()
		EventBus.audio_sfx_requested.emit("portal_warp")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Đồng Hành: %s" % PlayerData.get_companion_display_name(next_c), Color("#80ED99"))


func trigger_ui_skill(slot_key: String) -> void:
	if input_blocked_by_ui:
		return
	if slot_key == "Q":
		_try_cast_slot("Q", "Bái sư Dược Lão (Vách Đá Hậu Sơn) để học Đấu Kỹ [Q] — bấm [K] để đổi chiêu!")
	elif slot_key == "E":
		_try_cast_slot("E", "Hạ Tiêu Ninh tại Lễ Thành Niên hoặc mở Rương Cổ Hậu Sơn để học chiêu [E]!")
	elif slot_key == "R":
		_try_cast_slot("R", "Sang Chương 02 (Ma Thú Sơn Mạch) để học Diễm Phân Phệ Lãng Xích [R]!")
	elif slot_key == "F":
		_try_cast_slot("F", "Phật Nộ Hỏa Liên [F] chỉ mở ở Chương 03 (Sau khi thu Thanh Liên Địa Tâm Hỏa)!")
	elif slot_key == "T":
		_activate_duoc_lao_assist()


func trigger_ui_toc_van() -> void:
	if input_blocked_by_ui:
		return
	if not PlayerData.is_skill_unlocked("toc_van_tieu_toc"):
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Chưa thức tỉnh Tộc Văn Tiêu Tộc [X]!", Color("#ADB5BD"))
		EventBus.banter_triggered.emit("Gợi ý cốt truyện: Hoàn thành Hồi 9.7 (Gặp Tổ Tiên Tiêu Huyền dưới Tầng 3 Thiên Mộ) để thức tỉnh [Tộc Văn Đấu Đế Tiêu Tộc [X]]!")
		return
	_cast_skill_slot("X", "toc_van_tieu_toc")


func trigger_ui_use_pill(slot_num: int) -> void:
	if input_blocked_by_ui:
		return
	var pill_id: String = PlayerData.get_effective_quick_pill(slot_num)
	if pill_id != "":
		PlayerData.use_consumable(pill_id, global_position + Vector2(0, -45))


func _try_cast_slot(slot_key: String, lock_hint: String) -> void:
	var sk_id: String = PlayerData.get_skill_in_slot(slot_key)
	if sk_id == "":
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Chưa lắp Đấu Kỹ [%s]!" % slot_key, Color("#ADB5BD"))
		EventBus.banter_triggered.emit("Gợi ý cốt truyện: " + lock_hint)
		return
	_cast_skill_slot(slot_key, sk_id)


func _perform_dash() -> void:
	is_attacking = false
	attack_follow_hold_timer = 0.0
	weapon_trail_active = false
	var move_in: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if move_in.length() > 0.1:
		dash_dir = move_in.normalized()
	else:
		dash_dir = (get_global_mouse_position() - global_position).normalized()
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2.RIGHT

	if absf(dash_dir.x) > 0.05:
		body_sprite.flip_h = dash_dir.x < 0.0

	var start_p: Vector2 = global_position
	var has_saint_dom: bool = SaintRealmManager.has_dau_thanh_domain(PlayerData)
	var has_spatial: bool = PlayerData.has_dau_ton_spatial_blink() or has_saint_dom
	var has_dw_wings: bool = PlayerData.has_dau_vuong_wings()
	var has_wings: bool = PlayerData.has_tu_van_duc_equipped() or has_dw_wings
	var has_thunder: bool = PlayerData.is_skill_unlocked("tam_thien_loi_dong")
	var van_van_dash_mult: float = 0.75 if PlayerData.active_companion_id == "van_van_hoa_tong" else 1.0
	dash_duration_cur = 0.30 if has_saint_dom else (0.29 if has_spatial else (0.27 if has_dw_wings else (0.24 if has_wings else 0.18)))
	dash_timer = dash_duration_cur
	dash_speed_override = 0.0
	dash_cooldown_total = (0.38 if has_saint_dom else (0.48 if has_spatial else (0.56 if has_dw_wings else (0.64 if has_wings else 0.72)))) * PlayerData.get_cooldown_multiplier() * van_van_dash_mult
	dash_cooldown = dash_cooldown_total
	invuln_timer = maxf(invuln_timer, SaintRealmManager.SAINT_DASH_IFRAME if has_saint_dom else (0.60 if has_spatial else (0.48 if has_dw_wings else (0.42 if has_thunder else (0.34 if has_wings else 0.28)))))
	EventBus.skill_cooldown_updated.emit("SPACE", dash_cooldown, dash_cooldown_total)
	EventBus.audio_sfx_requested.emit("portal_warp" if has_spatial else ("thunder_blink" if has_thunder else "dash_whoosh"))
	_spawn_dash_afterimage()
	VfxAssets.spawn_dust_puff(get_parent(), global_position + Vector2(0, 10), Color(0.75, 0.84, 0.96, 0.48), 7, 110.0, 1.15)
	if has_spatial:
		EventBus.shockwave_requested.emit(start_p + Vector2(0, -18), 145.0, 0.036, Color("#72EFDD"), 0.26)
		_spawn_hit_sparks(start_p + Vector2(0, -24), Color("#72EFDD"), -dash_dir, 16)
		_spawn_hit_sparks(start_p + Vector2(0, -24), Color("#C77DFF"), dash_dir, 12)
	elif has_dw_wings:
		_spawn_hit_sparks(global_position + Vector2(0, -24), Color("#00F5D4"), -dash_dir, 14)
		_spawn_hit_sparks(global_position + Vector2(0, -24), Color("#E0AAFF"), -dash_dir, 10)
	elif has_wings:
		_spawn_hit_sparks(global_position + Vector2(0, -20), Color("#C77DFF"), -dash_dir, 14)
	if has_thunder:
		var est_spd: float = 780.0 if has_dw_wings else (695.0 if has_wings else 560.0)
		var trail_end: Vector2 = start_p + dash_dir * (est_spd * dash_duration_cur)
		_spawn_skill_vfx(
			"thunder_blink",
			start_p + Vector2(0, -20),
			dash_dir,
			108.0,
			0.28,
			Color("#F8F9FA"),
			Color("#B8C0FF"),
			Color("#7B2CBF"),
			{ "end_world_pos": trail_end + Vector2(0, -20) }
		)
		VfxAssets.spawn_spark_burst(get_parent(), start_p + Vector2(0, -20), Color("#E0FBFC"), Color("#B8C0FF"), 16, 85.0, 220.0, 0.30, -dash_dir, 180.0, 0.26, 0.56, true)
		var zap_dmg: float = PlayerData.get_atk() * 0.65
		var zap_burn: float = PlayerData.get_core_burn_dps()
		var zap_poise: float = 18.0 * PlayerData.get_poise_dmg_multiplier()
		for en in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(en) or not (en is Node2D):
				continue
			var enemy_node: Node2D = en as Node2D
			if start_p.distance_to(enemy_node.global_position) <= 118.0:
				var push_d: Vector2 = (enemy_node.global_position - start_p).normalized()
				if push_d == Vector2.ZERO:
					push_d = -dash_dir
				if enemy_node.has_method("apply_slow"):
					enemy_node.apply_slow(0.35, 1.5)
				if enemy_node.has_method("receive_hit"):
					enemy_node.receive_hit(zap_dmg, push_d * 180.0, 0.15, zap_burn, 0.0, 1.0, zap_poise)
				VfxAssets.spawn_spark_burst(get_parent(), enemy_node.global_position + Vector2(0, -24), Color("#E0FBFC"), Color("#C77DFF"), 8, 70.0, 170.0, 0.24, push_d, 140.0, 0.22, 0.48, true)


func _spawn_dash_afterimage() -> void:
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
	var g_col: Color = Color(0.75, 0.80, 1.0, 0.70) if (dash_speed_override > 0.0 or PlayerData.is_skill_unlocked("tam_thien_loi_dong")) else (Color(0.82, 0.45, 1.0, 0.65) if PlayerData.has_tu_van_duc_equipped() else Color(active_mid_col.r, active_mid_col.g, active_mid_col.b, 0.52))
	ghost.modulate = g_col
	get_parent().add_child(ghost)
	var tw := ghost.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ghost, "modulate:a", 0.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(ghost, "scale", ghost.scale * Vector2(1.06, 0.96), 0.24)
	tw.chain().tween_callback(ghost.queue_free)


func _start_integrated_combo_attack() -> void:
	combo_step = (combo_step % 3) + 1
	combo_reset_timer = 0.95
	attack_follow_hold_timer = 0.0

	var seal_slow: float = 1.15 if (PlayerData.is_ruler_sealed and PlayerData.has_huyen_trong_xich_equipped()) else 0.94
	var wpn_spd: float = maxf(0.55, PlayerData.get_weapon_attack_speed_mult())
	if PlayerData.active_companion_id == "thai_lan_tieu_tieu" and PlayerData.has_huyen_trong_xich_equipped():
		wpn_spd *= 1.20 # Thải Lân & Tiêu Tiêu cộng hưởng (+20% tốc độ vung Huyền Trọng Xích!)
	var dur: float = (0.23 * seal_slow) / wpn_spd
	if combo_step == 3:
		dur *= 1.14
	# Bỏ khe hở +0.04s -> nối combo tức thì không bị nhấp nháy về Idle!
	attack_cooldown = dur

	attack_aim_dir = (get_global_mouse_position() - global_position).normalized()
	if attack_aim_dir == Vector2.ZERO:
		attack_aim_dir = Vector2.RIGHT
	body_sprite.flip_h = attack_aim_dir.x < 0.0

	attack_frames = SpriteAnimHelper.get_player_attack_frames(attack_meta, combo_step, false)
	is_attacking = true
	attack_is_skill_pose = false
	attack_skill_style = "weapon"
	attack_anim_timer = 0.0
	attack_anim_duration = dur
	attack_hit_triggered = false
	weapon_trail_active = true
	weapon_trail_points.clear()

	if attack_tex != null:
		anim_state = "attack"
		_apply_body_sheet(attack_tex, attack_meta)
		body_sprite.frame = attack_frames[0]
	back_weapon_sprite.visible = false
	lunge_vel = attack_aim_dir * (225.0 if combo_step == 3 else 145.0)

	if PlayerData.has_huyen_trong_xich_equipped():
		EventBus.audio_sfx_requested.emit("swing_heavy")
	elif PlayerData.has_weapon_equipped():
		EventBus.audio_sfx_requested.emit("swing_blade")
	else:
		EventBus.audio_sfx_requested.emit("swing_unarmed")


func _spawn_action_afterimage(tint_col: Color, fade_dur: float = 0.20, pos_offset: Vector2 = Vector2.ZERO) -> void:
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
	ghost.global_position = body_sprite.global_position + pos_offset
	ghost.material = VfxAssets.get_additive_material()
	ghost.modulate = Color(tint_col.r, tint_col.g, tint_col.b, 0.54)
	get_parent().add_child(ghost)
	var tw := ghost.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ghost, "modulate:a", 0.0, fade_dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(ghost, "scale", ghost.scale * Vector2(1.07, 0.96), fade_dur)
	tw.chain().tween_callback(ghost.queue_free)


func _execute_melee_strike_impact() -> void:
	var has_wpn: bool = PlayerData.has_weapon_equipped()
	# Tàn ảnh hành động nối mượt Windup -> Impact + bụi chân khi tung nhịp 3!
	_spawn_action_afterimage(active_mid_col, 0.18, -attack_aim_dir * 8.0)
	if combo_step == 3:
		_spawn_action_afterimage(active_core_col, 0.22, -attack_aim_dir * 18.0)
		VfxAssets.spawn_dust_puff(get_parent(), global_position + Vector2(0, 10), Color(0.84, 0.78, 0.68, 0.50), 8, 125.0, 1.25)
	weapon_pivot.rotation = attack_aim_dir.angle()
	slash_vfx.visible = true
	slash_vfx.flip_v = (combo_step == 2)
	slash_vfx.modulate.a = 0.92
	var base_sc: float = 0.96 if has_wpn else 0.58
	slash_vfx.scale = Vector2(base_sc * 1.28, base_sc * 1.28) if combo_step == 3 else Vector2(base_sc, base_sc)
	slash_preview_duration = 0.18 if combo_step == 3 else 0.14
	slash_preview_timer = slash_preview_duration
	if slash_shader_mat != null:
		slash_shader_mat.set_shader_parameter("dissolve", 0.0)

	# Sinh vệt chém lưỡi liềm sắc nét 60 FPS (Additive Blend + 3 tầng Dị Hỏa)
	var reach_mult: float = PlayerData.get_attack_reach_multiplier()
	var slash_r: float = (108.0 if has_wpn else 76.0) * (1.16 if combo_step == 3 else 1.0) * reach_mult
	_spawn_skill_vfx(
		"melee_slash",
		global_position + Vector2(0, -26),
		attack_aim_dir,
		slash_r,
		0.22 if combo_step == 3 else 0.17,
		active_core_col,
		active_mid_col,
		active_outer_col,
		{ "flip_dir": -1.0 if combo_step == 2 else 1.0, "combo_idx": combo_step, "follow_target": self, "follow_offset": Vector2(0, -26) }
	)

	var mult: float = 1.0
	var reach_px: float = 116.0 if has_wpn else 84.0
	var kb: float = 260.0 if has_wpn else 190.0
	if combo_step == 2:
		mult = 1.18
	elif combo_step == 3:
		mult = 1.55
		reach_px += 18.0
		kb += 110.0
		EventBus.screen_shake_requested.emit(4.8, 0.13)
	reach_px *= reach_mult

	var dmg: float = PlayerData.get_atk() * mult
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var burn_val: float = 0.0
	var spark_col: Color = active_mid_col
	if not f_def.is_empty():
		burn_val = dmg * float(f_def.get("burn_dps_ratio", 0.08)) * PlayerData.get_flame_dmg_multiplier()
		spark_col = Color(str(f_def.get("core_hex", "#FFF3B0")))
	burn_val += PlayerData.get_core_burn_dps()

	var poise_val: float = (28.0 if (combo_step == 3 and PlayerData.has_huyen_trong_xich_equipped()) else (20.0 if combo_step == 3 else (14.0 if PlayerData.has_huyen_trong_xich_equipped() else 10.0))) * PlayerData.get_poise_dmg_multiplier()
	var hit_any: bool = false
	for en in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(en):
			continue
		var enemy_node: Node2D = en as Node2D
		if enemy_node == null:
			continue
		var to_en: Vector2 = enemy_node.global_position - global_position
		var dist: float = to_en.length()
		if dist <= reach_px:
			var dot_val: float = attack_aim_dir.dot(to_en.normalized()) if dist > 8.0 else 1.0
			if combo_step == 3 or dot_val >= 0.12:
				if enemy_node.has_method("receive_hit"):
					var er_melee: int = int(enemy_node.get("realm_index")) if ("realm_index" in enemy_node) else 1
					var saint_m: float = SaintRealmManager.get_saint_supremacy_mult(PlayerData, er_melee)
					enemy_node.receive_hit(dmg * saint_m, attack_aim_dir * kb, 0.0, burn_val, 0.0, 1.0, poise_val)
					_try_trigger_inner_heart_ignition(enemy_node)
					_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), spark_col, attack_aim_dir, 14 if combo_step == 3 else 10)
					hit_any = true

	if hit_any:
		EventBus.trigger_hitstop(0.032 if combo_step == 3 else 0.018, 0.10)

	# ĐẤU THÁNH KHÔNG GIAN (realm >= 11) hoặc ĐẠI ĐẤU SƯ / THIÊN HỎA NHỊ BIẾN: tự động phóng sóng kiếm khí xé không gian!
	var has_dt_wave: bool = SaintRealmManager.has_dau_thanh_domain(PlayerData)
	if (has_dt_wave or (PlayerData.realm_index >= 4 and has_wpn and PlayerData.current_qi > PlayerData.get_max_qi() * 0.40) or PlayerData.is_nhi_bien_active) and get_parent() != null:
		var use_fl: Dictionary = f_def if not f_def.is_empty() else GameDatabase.get_flame_def("di_hoa_03_tinh_lien" if has_dt_wave else "di_hoa_14_van_lac")
		var wave_angles: Array = [-0.24, 0.0, 0.24] if (has_dt_wave or PlayerData.is_tam_bien_active) else ([-0.14, 0.14] if PlayerData.is_nhi_bien_active else [0.0])
		var wave_dmg_m: float = 0.96 if has_dt_wave else (0.78 if PlayerData.is_tam_bien_active else (0.68 if PlayerData.is_nhi_bien_active else 0.58))
		for w_ang in wave_angles:
			var w_dir: Vector2 = attack_aim_dir.rotated(float(w_ang))
			var wave_proj: Area2D = SKILL_SCENE.instantiate() as Area2D
			get_parent().add_child(wave_proj)
			if wave_proj.has_method("configure_skill"):
				wave_proj.configure_skill(
					"flame_wave",
					global_position + w_dir * 34.0 + Vector2(0, -24),
					global_position + w_dir * (480.0 if has_dt_wave else 340.0),
					dmg * wave_dmg_m,
					180.0 if has_dt_wave else 160.0,
					0.65 if has_dt_wave else (0.34 if PlayerData.is_tam_bien_active else (0.24 if PlayerData.is_nhi_bien_active else 0.16)),
					64.0 if has_dt_wave else 54.0,
					660.0 if has_dt_wave else 560.0,
					use_fl,
					[]
				)


func _start_skill_pose(aim_dir: Vector2, dur: float = 0.25, style: String = "weapon") -> void:
	attack_follow_hold_timer = 0.0
	attack_aim_dir = aim_dir
	if absf(aim_dir.x) > 0.05:
		body_sprite.flip_h = aim_dir.x < 0.0

	is_attacking = true
	attack_is_skill_pose = true
	attack_skill_style = style
	attack_anim_timer = 0.0
	attack_anim_duration = dur
	attack_hit_triggered = true # Không gọi đòn đánh thường trùng lên chiêu thức!

	if style == "cast" and cast_tex != null:
		anim_state = "cast"
		var cnt: int = maxi(1, int(cast_meta.get("total_frames", 4)))
		attack_frames = PackedInt32Array()
		for i in range(cnt):
			attack_frames.append(i)
		_apply_body_sheet(cast_tex, cast_meta)
		body_sprite.frame = attack_frames[0]
		weapon_trail_active = false
		_spawn_skill_vfx("windup_charge", global_position + Vector2(0, -24), aim_dir, 66.0, minf(0.28, dur), active_core_col, active_mid_col, active_outer_col, { "follow_target": self, "follow_offset": Vector2(0, -24) })
	elif attack_tex != null:
		anim_state = "attack"
		attack_frames = SpriteAnimHelper.get_player_attack_frames(attack_meta, 3, true)
		_apply_body_sheet(attack_tex, attack_meta)
		body_sprite.frame = attack_frames[0]
		weapon_trail_active = (style == "weapon")
		weapon_trail_points.clear()
		_spawn_action_afterimage(active_mid_col, 0.22, -aim_dir * 10.0)
	back_weapon_sprite.visible = false


func _launch_pending_fire_lotus() -> void:
	PlayerSkillExec.launch_pending_fire_lotus(self)


func _cast_skill_slot(slot_key: String, skill_id: String) -> void:
	PlayerSkillExec.cast_skill_slot(self, slot_key, skill_id)


func _try_trigger_inner_heart_ignition(enemy_node: Node2D) -> void:
	PlayerSkillExec.try_trigger_inner_heart_ignition(self, enemy_node)


func _pulse_flame_clone_burst() -> void:
	PlayerSkillExec.pulse_flame_clone_burst(self)


func _detonate_flame_clone_finale() -> void:
	PlayerSkillExec.detonate_flame_clone_finale(self)


func _activate_duoc_lao_assist() -> void:
	PlayerSkillExec.activate_duoc_lao_assist(self)


func take_enemy_damage(raw_dmg: float, attacker_realm_idx: int, push_vec: Vector2, attacker_id: String = "", attacker_name: String = "") -> void:
	if invuln_timer > 0.0:
		return
	# Khí Linh Yêu Hỏa Tiểu Y (#3 Tịnh Liên): 30% Tịnh Liên Thanh Hóa Hỏa chặn đòn tà & chuyển thành +8% QI!
	if SaintRealmManager.try_tieu_y_purify_hit(PlayerData):
		invuln_timer = 0.28
		VfxAssets.spawn_spark_burst(get_parent(), global_position + Vector2(0, -32), Color("#FFFFFF"), Color("#FDA4AF"), 14, 70.0, 180.0, 0.30, Vector2.UP, 180.0, 0.24, 0.54, true)
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -76), "✿ Tiểu Y Tịnh Hóa! (+8% QI)", Color("#FFAFCC"))
		return
	var realm_diff: int = max(0, attacker_realm_idx - PlayerData.realm_index)
	var taken_per_realm: float = float(GameDatabase.suppression_rules.get("damage_taken_bonus_per_major_realm", 0.30))
	var suppression_bonus: float = 1.0 + float(realm_diff) * taken_per_realm
	var raw_after_def: float = maxf(1.0, (raw_dmg * suppression_bonus) - PlayerData.get_def() * 0.45)
	var armor_mult: float = 1.0
	if PlayerData.realm_index >= 4 and PlayerData.current_qi > PlayerData.get_max_qi() * 0.20:
		armor_mult = 0.70
	elif PlayerData.realm_index >= 3 and PlayerData.current_qi > PlayerData.get_max_qi() * 0.25:
		armor_mult = 0.82
	var quy_linh_mult: float = 0.70 if PlayerData.lotus_dmg_red_timer > 0.0 else 1.0
	var faction_def_mult: float = PlayerData.get_enemy_damage_taken_mult(attacker_id, attacker_name)
	var final_dmg: float = maxf(1.0, raw_after_def * armor_mult * quy_linh_mult * faction_def_mult)

	if PlayerData.lotus_shield_hp > 0.0:
		var absorbed: float = minf(PlayerData.lotus_shield_hp, final_dmg)
		PlayerData.lotus_shield_hp -= absorbed
		final_dmg -= absorbed
		if final_dmg <= 0.5:
			invuln_timer = 0.25
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -68), "KHIÊN CHẮN -%d" % int(round(absorbed)), Color("#D4A373"))
			EventBus.stats_changed.emit()
			return

	PlayerData.current_hp = maxf(0.0, PlayerData.current_hp - final_dmg)
	var ws_list: Array[Node] = get_tree().get_nodes_in_group("world_stage")
	if not ws_list.is_empty() and ws_list[0].has_method("record_boss_rush_player_damage"):
		ws_list[0].record_boss_rush_player_damage(final_dmg)
	invuln_timer = 0.35
	hurt_flash_timer = 0.11
	knockback_vel = push_vec
	visual_scale = Vector2(1.16, 0.86)
	EventBus.audio_sfx_requested.emit("player_hurt")
	EventBus.screen_shake_requested.emit(5.2, 0.15)
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -64), "-%d" % int(round(final_dmg)), Color("#FF4D6D"))
	EventBus.stats_changed.emit()

	if PlayerData.current_hp <= 0.0:
		if not ws_list.is_empty() and ws_list[0].has_method("on_player_died_in_boss_rush"):
			if bool(ws_list[0].on_player_died_in_boss_rush()):
				return
		if not ws_list.is_empty() and ws_list[0].has_method("on_player_died_in_tower"):
			if bool(ws_list[0].on_player_died_in_tower()):
				return
		if SaintRealmManager.has_huan_nhi_soul_revive(PlayerData) and not PlayerData.huan_nhi_revive_used:
			PlayerData.huan_nhi_revive_used = true
			PlayerData.current_hp = PlayerData.get_max_hp() * 0.65
			PlayerData.current_qi = maxf(PlayerData.current_qi, PlayerData.get_max_qi() * 0.65)
			invuln_timer = 3.2
			_spawn_skill_vfx("bac_vuong_tinh_lien_assist", global_position + Vector2(0, -22), Vector2.UP, 340.0, 0.90, Color("#FFFFFF"), Color("#FFD700"), Color("#FFAFCC"))
			EventBus.audio_sfx_requested.emit("breakthrough")
			EventBus.screen_shake_requested.emit(16.0, 0.45)
			EventBus.shockwave_requested.emit(global_position, 420.0, 0.072, Color("#FFAFCC"), 0.50)
			EventBus.screen_flash_requested.emit(Color("#FFF1F2"), 0.38, 0.28)
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -96), "✿ TÂM Ý TƯƠNG THÔNG (HUÂN NHI) — HỒI SINH 65% HP/QI!", Color("#FFD700"))
			EventBus.banter_triggered.emit("Cổ Huân Nhi (Kim Đế Tịnh Liên Đồng Tâm): 'Mạng của Huân Nhi đã gắn liền với Tiêu Viêm ca ca — hồi sinh tức thì 65% HP & QI!'")
			EventBus.stats_changed.emit()
			return
		if PlayerData.has_tam_thien_immortal_body() and PlayerData.immortal_revive_cd <= 0.0:
			PlayerData.immortal_revive_cd = 180.0
			PlayerData.current_hp = PlayerData.get_max_hp() * 0.45
			PlayerData.current_qi = maxf(PlayerData.current_qi, PlayerData.get_max_qi() * 0.50)
			invuln_timer = 3.0
			_spawn_skill_vfx("flame_buff_tier3", global_position + Vector2(0, -18), Vector2.UP, 260.0, 0.75, Color("#FFFFFF"), Color("#C77DFF"), Color("#FFD166"))
			EventBus.audio_sfx_requested.emit("breakthrough")
			EventBus.screen_shake_requested.emit(13.0, 0.42)
			EventBus.shockwave_requested.emit(global_position, 360.0, 0.062, Color("#C77DFF"), 0.46)
			EventBus.screen_flash_requested.emit(Color("#C77DFF"), 0.34, 0.26)
			EventBus.trigger_hitstop(0.050, 0.08)
			for en in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(en) and en is Node2D and global_position.distance_to((en as Node2D).global_position) <= 260.0:
					var pd_tt: Vector2 = ((en as Node2D).global_position - global_position).normalized()
					if en.has_method("receive_hit"):
						en.receive_hit(PlayerData.get_atk() * 2.6, pd_tt * 560.0, 0.65, 0.0)
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -92), "✦ TINH THẦN BẤT DIỆT (#9) — HỒI SINH 45% HP!", Color("#C77DFF"))
			EventBus.banter_triggered.emit("[#9 Tam Thiên Diễm Viêm Hỏa — Bất Tử Chi Thân] bùng sáng tinh hà tái tạo sinh cơ (Hồi 45% HP & 3.0s Bất Tử · Hồi chiêu 180s)!")
			EventBus.stats_changed.emit()
			return
		if PlayerData.has_flag("ch04_kim_viem_ngoc") and not PlayerData.kim_viem_revive_used:
			PlayerData.kim_viem_revive_used = true
			PlayerData.current_hp = PlayerData.get_max_hp() * 0.50
			PlayerData.current_qi = maxf(PlayerData.current_qi, PlayerData.get_max_qi() * 0.50)
			invuln_timer = 2.5
			_spawn_skill_vfx("flame_buff", global_position + Vector2(0, -18), Vector2.UP, 210.0, 0.65, Color("#FFFFFF"), Color("#FFD166"), Color("#FF9F1C"))
			EventBus.audio_sfx_requested.emit("breakthrough")
			EventBus.screen_shake_requested.emit(10.0, 0.35)
			EventBus.trigger_hitstop(0.045, 0.08)
			for en in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(en) and en is Node2D and global_position.distance_to((en as Node2D).global_position) <= 210.0:
					var pd: Vector2 = ((en as Node2D).global_position - global_position).normalized()
					if en.has_method("receive_hit"):
						en.receive_hit(PlayerData.get_atk() * 2.0, pd * 480.0, 0.5, 0.0)
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -86), "KIM VIÊM HỘ HỒN NGỌC — HỒI SINH 50% HP!", Color("#FFD166"))
			EventBus.banter_triggered.emit("Lá Ngọc Vàng Cổ Tộc của Huân Nhi bùng cháy cứu mạng bạn (Hồi 50% HP & 2.5s Bất Tử)!")
			EventBus.stats_changed.emit()
			return

		PlayerData.recalculate_and_clamp(true)
		var m_def: Dictionary = GameDatabase.get_map_def(PlayerData.current_map_id)
		var sp: Array = m_def.get("default_spawn", [340, 520])
		global_position = Vector2(float(sp[0]), float(sp[1]))
		reset_physics_interpolation()
		EventBus.stats_changed.emit()
		EventBus.banter_triggered.emit("Tiêu Viêm bị trọng thương, vội lui về điểm an toàn điều tức hồi phục!")


func _on_screen_shake(strength: float, duration: float) -> void:
	shake_strength = maxf(shake_strength, strength)
	shake_duration = maxf(0.05, maxf(shake_duration, duration))
	shake_timer = maxf(shake_timer, duration)


func _draw() -> void:
	var t_sec: float = float(Time.get_ticks_msec()) * 0.001

	# Bóng tiếp đất neo chính xác dưới bàn chân
	draw_set_transform(Vector2(0, 12), 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 28.0, Color(0.03, 0.02, 0.06, 0.50))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Vòng Điều Động Thiên Địa Năng Lượng (Đấu Hoàng >= 7) xoay tỏa ánh vàng kim (Cánh Hóa Dực đã chuyển lên wing_left/right_sprite Shader!)
	if PlayerData.has_dau_vuong_wings() and PlayerData.realm_index >= 7:
		var dh_p: float = 0.86 + 0.14 * sin(t_sec * 4.4)
		draw_arc(Vector2(0, -26), 44.0, t_sec * 1.4, t_sec * 1.4 + TAU * 0.75, 40, Color(1.0, 0.85, 0.32, 0.56 * dh_p), 2.4)
		draw_arc(Vector2(0, -26), 49.0, -t_sec * 1.1, -t_sec * 1.1 + TAU * 0.55, 36, Color(0.0, 0.96, 0.83, 0.42 * dh_p), 1.8)

	# ĐẤU TÔNG (>= 8): Đạp Hư Không — Sóng không gian bạc-ngọc tỏa gợn dưới bàn chân!
	if PlayerData.has_dau_tong_void_step():
		var dt_pulse: float = 0.82 + 0.18 * sin(t_sec * 5.6)
		var r_void: float = 46.0 + fmod(t_sec * 24.0, 14.0)
		var a_void: float = clampf(1.0 - (r_void - 46.0) / 14.0, 0.15, 0.90)
		draw_set_transform(Vector2(0, 13), 0.0, Vector2(1.0, 0.42))
		draw_arc(Vector2.ZERO, r_void, 0.0, TAU, 44, Color(0.45, 0.94, 0.87, 0.62 * a_void * dt_pulse), 2.6)
		draw_arc(Vector2.ZERO, 38.0, -t_sec * 1.8, -t_sec * 1.8 + TAU * 0.72, 36, Color(0.88, 0.96, 1.0, 0.78 * dt_pulse), 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Hào quang Dị Hỏa / Bí Pháp xoay nhẹ quanh chân
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	if not f_def.is_empty() or PlayerData.realm_index >= 2 or PlayerData.is_flame_buff_active:
		var aura_col: Color = Color("#FF4D6D") if PlayerData.is_flame_buff_active else (Color(str(f_def.get("mid_hex", "#FFE599"))) if not f_def.is_empty() else Color("#FFE599"))
		var pulse: float = 0.85 + sin(t_sec * 4.5) * 0.15
		aura_col.a = (0.62 if (PlayerData.is_duoc_lao_active or PlayerData.is_flame_buff_active) else 0.32) * pulse
		draw_set_transform(Vector2(0, 12), 0.0, Vector2(1.0, 0.46))
		draw_arc(Vector2.ZERO, 34.0, t_sec * 1.4, t_sec * 1.4 + TAU * 0.82, 36, aura_col, 3.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# 3 đốm hỏa ấn xoay quanh người khi đang kích hoạt Thiên Hỏa Tam Huyền Biến
	if PlayerData.is_flame_buff_active:
		for bi in range(3):
			var ba: float = t_sec * 4.8 + float(bi) * (TAU / 3.0)
			var bp := Vector2(cos(ba) * 38.0, -24.0 + sin(ba) * 16.0)
			draw_circle(bp, 6.5, Color(1.0, 0.30, 0.42, 0.48))
			draw_circle(bp, 3.2, Color(1.0, 0.95, 0.72, 0.95))

	# 3 quả cầu Hỏa Liên Phân Thân xoay rực sáng theo bảng màu Dị Hỏa đang kích hoạt!
	if flame_clone_timer > 0.0:
		var fc_alpha: float = clampf(flame_clone_timer / 0.45, 0.0, 1.0)
		var orbit_rx: float = 52.0
		var orbit_ry: float = 28.0
		for oi in range(3):
			var oa: float = flame_clone_angle + float(oi) * (TAU / 3.0)
			var op := Vector2(cos(oa) * orbit_rx, -24.0 + sin(oa) * orbit_ry)
			var tail_a: float = oa - 0.38
			var tp := Vector2(cos(tail_a) * orbit_rx, -24.0 + sin(tail_a) * orbit_ry)
			draw_line(tp, op, Color(active_outer_col.r, active_outer_col.g, active_outer_col.b, 0.52 * fc_alpha), 7.5)
			draw_line(tp, op, Color(active_mid_col.r, active_mid_col.g, active_mid_col.b, 0.85 * fc_alpha), 3.6)
			draw_circle(op, 12.5, Color(active_outer_col.r, active_outer_col.g, active_outer_col.b, 0.36 * fc_alpha))
			draw_circle(op, 8.2, Color(active_mid_col.r, active_mid_col.g, active_mid_col.b, 0.86 * fc_alpha))
			draw_circle(op, 4.2, Color(active_core_col.r, active_core_col.g, active_core_col.b, 0.96 * fc_alpha))
			for pk in range(4):
				var pa: float = oa * 2.0 + float(pk) * (TAU * 0.25)
				var p_tip: Vector2 = op + Vector2(cos(pa), sin(pa)) * 11.5
				draw_line(op, p_tip, Color(active_core_col.r, active_core_col.g, active_core_col.b, 0.74 * fc_alpha), 2.0)

	# ĐẤU LINH (Cảnh giới >= 5): Đấu Khí Ngưng Vật — Vòng tinh thể tím-vàng sắc nét quanh chân!
	if PlayerData.realm_index >= 5:
		var dl_pulse: float = 0.88 + 0.12 * sin(t_sec * 5.2)
		draw_set_transform(Vector2(0, 12), 0.0, Vector2(1.0, 0.46))
		draw_arc(Vector2.ZERO, 43.0, t_sec * 1.6, t_sec * 1.6 + TAU * 0.90, 44, Color(0.78, 0.49, 1.0, 0.72 * dl_pulse), 3.2)
		draw_arc(Vector2.ZERO, 37.5, -t_sec * 2.1, -t_sec * 2.1 + TAU * 0.82, 40, Color(1.0, 0.82, 0.40, 0.68 * dl_pulse), 2.2)
		for ci in range(6):
			var ca: float = t_sec * 1.6 + float(ci) * (TAU / 6.0)
			var c_dir := Vector2(cos(ca), sin(ca))
			var c_perp := Vector2(-c_dir.y, c_dir.x)
			var c_pos: Vector2 = c_dir * 43.0
			var shard := PackedVector2Array([
				c_pos + c_dir * 7.5,
				c_pos + c_perp * 3.8,
				c_pos - c_dir * 4.5,
				c_pos - c_perp * 3.8
			])
			var c_col: Color = Color(1.0, 0.86, 0.42, 0.92 * dl_pulse) if (ci % 2 == 0) else Color(0.84, 0.56, 1.0, 0.92 * dl_pulse)
			draw_colored_polygon(shard, c_col)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Vòng sáng Đấu Khí Khải Giáp (Đại Đấu Sư >= 4) hoặc Đấu Khí Sa Y (Đấu Sư == 3)!
	if PlayerData.realm_index >= 4:
		var kg_col: Color = Color(0.18, 0.88, 0.78, 0.56)
		draw_arc(Vector2(0, -24), 36.0, t_sec * 1.2, t_sec * 1.2 + TAU * 0.86, 40, kg_col, 2.8)
		draw_arc(Vector2(0, -24), 31.0, -t_sec * 1.8, -t_sec * 1.8 + TAU * 0.72, 32, Color(1.0, 0.86, 0.40, 0.38), 1.8)
	elif PlayerData.realm_index >= 3:
		var sy_col: Color = Color(0.78, 0.48, 1.0, 0.40)
		draw_arc(Vector2(0, -24), 34.0, t_sec * 1.1, t_sec * 1.1 + TAU * 0.82, 36, sy_col, 2.2)

	# Vòng Khiên Đất Huyền Hoàng (#23) hoặc Khiên Quy Linh (#13)
	if PlayerData.lotus_shield_hp > 1.0:
		draw_arc(Vector2(0, -24), 40.0, 0.0, TAU, 40, Color(0.85, 0.65, 0.42, 0.78), 3.2)
	if PlayerData.lotus_dmg_red_timer > 0.0:
		draw_arc(Vector2(0, -24), 44.0, 0.0, TAU, 40, Color(0.74, 0.42, 0.15, 0.58), 2.4)
	if PlayerData.is_tinh_lien_tran_active:
		var tl_p: float = 0.78 + 0.22 * sin(t_sec * 5.0)
		draw_arc(Vector2(0, -20), 64.0, t_sec * 1.4, t_sec * 1.4 + TAU * 0.94, 48, Color(1.0, 0.69, 0.80, 0.72 * tl_p), 3.4)
		draw_arc(Vector2(0, -20), 54.0, -t_sec * 2.0, -t_sec * 2.0 + TAU * 0.86, 40, Color(1.0, 0.96, 0.98, 0.64 * tl_p), 2.2)
	if PlayerData.player_slow_timer > 0.0:
		draw_arc(Vector2(0, 10), 30.0, 0.0, TAU, 28, Color(0.44, 0.84, 1.0, 0.80), 3.0)

	# Vòng cung nhỏ chỉ hướng ngắm chiêu về phía con trỏ chuột (Task 3)
	if aim_reticle_alpha > 0.05:
		var m_dir: Vector2 = get_global_mouse_position() - global_position
		if m_dir.length() > 14.0:
			var a_ang: float = m_dir.angle()
			var rc: Color = Color(active_core_col.r, active_core_col.g, active_core_col.b, 0.42 * aim_reticle_alpha)
			draw_arc(Vector2(0, 12), 42.0, a_ang - 0.34, a_ang + 0.34, 14, rc, 2.2)
			var a_tip: Vector2 = Vector2(0, 12) + m_dir.normalized() * 48.0
			draw_circle(a_tip, 2.6, Color(active_core_col.r, active_core_col.g, active_core_col.b, 0.72 * aim_reticle_alpha))

	# Mũi tên La Bàn Vàng chỉ hướng Mục Tiêu Nhiệm Vụ Cốt Truyện!
	var worlds: Array[Node] = get_tree().get_nodes_in_group("world_stage")
	if not worlds.is_empty() and worlds[0].has_method("get_quest_waypoint_world_pos"):
		var wp: Vector2 = worlds[0].get_quest_waypoint_world_pos()
		if wp != Vector2.ZERO:
			var to_wp: Vector2 = wp - global_position
			if to_wp.length() > 145.0:
				var dir: Vector2 = to_wp.normalized()
				var tip: Vector2 = dir * 56.0
				var perp: Vector2 = Vector2(-dir.y, dir.x)
				var p1: Vector2 = tip - dir * 13.0 + perp * 7.5
				var p2: Vector2 = tip - dir * 13.0 - perp * 7.5
				var tri := PackedVector2Array([tip, p1, p2])
				draw_colored_polygon(tri, Color(1.0, 0.85, 0.28, 0.88))
				draw_polyline(PackedVector2Array([tip, p1, p2, tip]), Color(0.08, 0.05, 0.02, 0.95), 1.8)
