extends CharacterBody2D
## Điều khiển Nhân vật chính TIÊU VIÊM — Phiên bản Tối Ưu Mượt 60–144 FPS & VFX Chiêu Thức:
## - Neo trục xoay bàn chân (Foot-Anchored Pivot) -> hết hẳn hiện tượng chân nhảy/trượt 12px khi đánh hay chạy!
## - Hỗ trợ linh hoạt 4 / 6 / 8 / 12 / 16+ frame (dải ngang lẫn lưới hframes × vframes) cho Idle, Run, Attack, Cast, Dash.
## - Combo 3 nhịp nối liền mượt không còn khe hở 40ms nhấp nháy + Input Buffer (0.14s) + Cancel bằng Dash/Skill + Hitstop toàn cục!
## - Weapon Trail (Line2D Additive), Shader Dị Hỏa chảy động và VFX 60 FPS riêng biệt cho trọn bộ 10+ Đấu Kỹ & Phật Nộ Hỏa Liên!

const SKILL_SCENE: PackedScene = preload("res://scenes/entities/skill_effect.tscn")
const TEX_LIGHT_RADIAL: Texture2D = preload("res://assets/sprites/vfx/light_radial_128.png")
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

# Hỏa Liên Phân Thân (3 quả cầu Dị Hỏa xoay quanh thân)
var flame_clone_timer: float = 0.0
var flame_clone_tick: float = 0.0
var flame_clone_dmg: float = 0.0
var flame_clone_radius: float = 135.0
var flame_clone_angle: float = 0.0
var flame_clone_r_pen: float = 0.30

# Linh Hồn Cảm Tri — Soul Radar [Z]
var soul_radar_cd: float = 0.0

var skill_cooldowns: Dictionary = {
	"Q": 0.0,
	"E": 0.0,
	"R": 0.0,
	"F": 0.0,
	"T": 0.0
}
var skill_cooldown_totals: Dictionary = {
	"Q": 1.0,
	"E": 1.0,
	"R": 1.0,
	"F": 1.0,
	"T": 1.0
}
var dash_cooldown_total: float = 0.72

var slash_preview_timer: float = 0.0
var slash_preview_duration: float = 0.16
var slash_shader_mat: ShaderMaterial

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

	idle_meta = SpriteAnimHelper.inspect_sheet(idle_tex, "square", 1, 1)
	run_meta = SpriteAnimHelper.inspect_sheet(run_tex, "square", 4, 1)
	if cast_tex != null:
		cast_meta = SpriteAnimHelper.inspect_sheet(cast_tex, "square", 4, 1)
	if dash_tex != null:
		dash_meta = SpriteAnimHelper.inspect_sheet(dash_tex, "square", 3, 1)

	_apply_body_sheet(idle_tex, idle_meta)
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
		attack_meta = SpriteAnimHelper.inspect_sheet(attack_tex, "player_attack", 4, 1)


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


func _apply_body_sheet(tex: Texture2D, meta: Dictionary) -> void:
	if tex == null or body_sprite == null:
		return
	SpriteAnimHelper.apply_to_sprite(body_sprite, tex, meta, BASE_FOOT_Y)


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
	queue_redraw()


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

	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_vel: Vector2 = Vector2.ZERO
	if dash_timer > 0.0:
		var d_spd: float = dash_speed_override if dash_speed_override > 0.0 else (695.0 if PlayerData.has_tu_van_duc_equipped() else 560.0)
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
			# Quét mượt qua toàn bộ danh sách attack_frames (2, 3, 4, 5, 6+ frame tùy sheet!)
			var hit_threshold: float = 0.24 if n_frames <= 2 else 0.30
			var f_idx: int = 0
			if n_frames == 2:
				f_idx = 0 if progress < hit_threshold else 1
			else:
				# Dành ~28% cho Windup, phần còn lại quét mượt qua các frame Smear -> Strike -> Follow-through!
				if progress < hit_threshold:
					f_idx = 0
				else:
					var rem_p: float = clampf((progress - hit_threshold) / (1.0 - hit_threshold), 0.0, 0.999)
					f_idx = 1 + int(rem_p * float(n_frames - 1))
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
		var idle_total: int = maxi(1, int(idle_meta.get("total_frames", 1)))
		if idle_total > 1:
			anim_timer += delta * 5.8
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

	if PlayerData.is_flame_buff_active:
		flame_buff_timer -= delta
		if flame_buff_timer <= 0.0:
			PlayerData.is_flame_buff_active = false
			_refresh_flame_shader()
			EventBus.stats_changed.emit()
			EventBus.floating_text_requested.emit(global_position + Vector2(0, -68), "Hết Thiên Hỏa Tam Huyền Biến", Color("#ADB5BD"))

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
	var has_wings: bool = PlayerData.has_tu_van_duc_equipped()
	var has_thunder: bool = PlayerData.is_skill_unlocked("tam_thien_loi_dong")
	dash_duration_cur = 0.24 if has_wings else 0.18
	dash_timer = dash_duration_cur
	dash_speed_override = 0.0
	dash_cooldown_total = (0.64 if has_wings else 0.72) * PlayerData.get_cooldown_multiplier()
	dash_cooldown = dash_cooldown_total
	invuln_timer = maxf(invuln_timer, 0.42 if has_thunder else (0.34 if has_wings else 0.28))
	EventBus.skill_cooldown_updated.emit("SPACE", dash_cooldown, dash_cooldown_total)
	EventBus.audio_sfx_requested.emit("thunder_blink" if has_thunder else "dash_whoosh")
	_spawn_dash_afterimage()
	VfxAssets.spawn_dust_puff(get_parent(), global_position + Vector2(0, 10), Color(0.75, 0.84, 0.96, 0.48), 7, 110.0, 1.15)
	if has_wings:
		_spawn_hit_sparks(global_position + Vector2(0, -20), Color("#C77DFF"), -dash_dir, 14)
	if has_thunder:
		var est_spd: float = 695.0 if has_wings else 560.0
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


func _execute_melee_strike_impact() -> void:
	var has_wpn: bool = PlayerData.has_weapon_equipped()
	weapon_pivot.rotation = attack_aim_dir.angle()
	slash_vfx.visible = true
	slash_vfx.flip_v = (combo_step == 2)
	slash_vfx.modulate.a = 0.92
	var base_sc: float = 1.85 if has_wpn else 1.10
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
					enemy_node.receive_hit(dmg, attack_aim_dir * kb, 0.0, burn_val, 0.0, 1.0, poise_val)
					_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), spark_col, attack_aim_dir, 14 if combo_step == 3 else 10)
					hit_any = true

	if hit_any:
		EventBus.trigger_hitstop(0.032 if combo_step == 3 else 0.018, 0.10)

	# ĐẠI ĐẤU SƯ (Cảnh giới >= 4): ĐẤU KHÍ NGOẠI PHÓNG — mỗi cú vung vũ khí khi QI > 40% phóng kiếm khí/xích khí lửa xuyên địch!
	if PlayerData.realm_index >= 4 and has_wpn and PlayerData.current_qi > PlayerData.get_max_qi() * 0.40:
		if get_parent() != null:
			var wave_proj: Area2D = SKILL_SCENE.instantiate() as Area2D
			get_parent().add_child(wave_proj)
			var use_fl: Dictionary = f_def if not f_def.is_empty() else GameDatabase.get_flame_def("di_hoa_19_thanh_lien")
			if wave_proj.has_method("configure_skill"):
				wave_proj.configure_skill(
					"flame_wave",
					global_position + attack_aim_dir * 34.0 + Vector2(0, -24),
					global_position + attack_aim_dir * 320.0,
					dmg * 0.58,
					160.0,
					0.16,
					52.0,
					540.0,
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
	elif attack_tex != null:
		anim_state = "attack"
		attack_frames = SpriteAnimHelper.get_player_attack_frames(attack_meta, 3, true)
		_apply_body_sheet(attack_tex, attack_meta)
		body_sprite.frame = attack_frames[0]
		weapon_trail_active = (style == "weapon")
		weapon_trail_points.clear()
	back_weapon_sprite.visible = false


func _launch_pending_fire_lotus() -> void:
	var p: Dictionary = pending_lotus_payload
	pending_lotus_payload = {}
	if get_parent() == null:
		return
	var proj: Area2D = SKILL_SCENE.instantiate() as Area2D
	get_parent().add_child(proj)
	var aim_t: Vector2 = p.get("aim_target", global_position + Vector2.RIGHT * 220.0) as Vector2
	var a_dir: Vector2 = (aim_t - global_position).normalized()
	if a_dir == Vector2.ZERO:
		a_dir = Vector2.RIGHT
	EventBus.audio_sfx_requested.emit("skill_fire")
	EventBus.screen_shake_requested.emit(4.5, 0.14)
	_spawn_hit_sparks(global_position + a_dir * 32.0 + Vector2(0, -24), active_core_col, a_dir, 18)
	if proj.has_method("configure_skill"):
		proj.configure_skill(
			"fire_lotus_ult",
			global_position + a_dir * 36.0 + Vector2(0, -24),
			aim_t,
			float(p.get("dmg", 80.0)),
			float(p.get("kb", 520.0)),
			float(p.get("r_pen", 0.5)),
			float(p.get("rad_px", 215.0)),
			float(p.get("spd", 360.0)),
			p.get("flame_def", {}) as Dictionary,
			p.get("fusion_list", []) as Array
		)


func _cast_skill_slot(slot_key: String, skill_id: String) -> void:
	if float(skill_cooldowns.get(slot_key, 0.0)) > 0.0:
		return
	var sdef: Dictionary = GameDatabase.get_skill_def(skill_id)
	if sdef.is_empty():
		return

	var behavior: String = str(sdef.get("behavior", "melee_burst"))
	var qi_cost: float = float(sdef.get("qi_cost", 15.0))
	if behavior == "fire_lotus_ult":
		qi_cost *= PlayerData.get_lotus_qi_cost_multiplier()
	if PlayerData.current_qi < qi_cost:
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -64), "Không đủ Đấu Khí!", Color("#4CC9F0"))
		return

	PlayerData.current_qi -= qi_cost
	EventBus.qi_updated.emit(PlayerData.current_qi, PlayerData.get_max_qi())

	# Độ Thông Thạo Đấu Kỹ (Sơ Khuy -> Tiểu Thành -> Đại Thành -> Đỉnh Phong)
	var mastery: Dictionary = PlayerData.record_skill_use(skill_id, global_position)
	var m_dmg_mult: float = float(mastery.get("dmg_mult", 1.0))
	var m_cd_mult: float = float(mastery.get("cd_mult", 1.0))
	var m_rad_mult: float = float(mastery.get("radius_mult", 1.0))

	var cd_total: float = float(sdef.get("cooldown", 5.0)) * PlayerData.get_cooldown_multiplier() * m_cd_mult
	skill_cooldowns[slot_key] = cd_total
	skill_cooldown_totals[slot_key] = cd_total
	EventBus.skill_cooldown_updated.emit(slot_key, cd_total, cd_total)

	var dmg: float = (PlayerData.get_atk() * float(sdef.get("atk_ratio", 1.5)) + float(PlayerData.get_soul()) * float(sdef.get("soul_ratio", 0.2))) * PlayerData.get_flame_dmg_multiplier() * m_dmg_mult
	var rad_px: float = float(sdef.get("radius_px", 110.0)) * m_rad_mult
	var kb: float = float(sdef.get("knockback", 320.0))
	var r_pen: float = float(sdef.get("realm_pen", 0.15))
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var burn_val: float = (dmg * float(f_def.get("burn_dps_ratio", 0.10)) * PlayerData.get_flame_dmg_multiplier() if not f_def.is_empty() else 0.0) + PlayerData.get_core_burn_dps()
	var poise_mult: float = PlayerData.get_poise_dmg_multiplier()
	var aim_target: Vector2 = get_global_mouse_position()
	var aim_dir: Vector2 = (aim_target - global_position).normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.RIGHT

	if behavior == "pull_pulse":
		_start_skill_pose(aim_dir, 0.28, "cast")
		var pull_spot: Vector2 = global_position + aim_dir * 68.0
		_spawn_skill_vfx("pull_pulse", pull_spot + Vector2(0, -18), aim_dir, rad_px, 0.46, Color("#E0FBFC"), Color("#70D6FF"), Color("#0077B6"))
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "HẤP CHƯỞNG!", Color("#70D6FF"))
		var hit_pull: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= rad_px:
					var to_spot: Vector2 = (pull_spot - enemy_node.global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, to_spot * absf(kb), r_pen, burn_val, 0.0, 1.0, 24.0 * poise_mult)
						_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#70D6FF"), to_spot, 10)
						hit_pull = true
		if hit_pull:
			EventBus.trigger_hitstop(0.024, 0.12)

	elif behavior == "melee_burst":
		var is_bat_cuc: bool = (skill_id == "bat_cuc_bang")
		_start_skill_pose(aim_dir, 0.26, "weapon")
		lunge_vel = aim_dir * (420.0 if is_bat_cuc else 330.0)
		var hit_center: Vector2 = global_position + aim_dir * (60.0 if is_bat_cuc else 52.0)
		_spawn_skill_vfx(
			"bat_cuc_bang" if is_bat_cuc else "toai_thach",
			hit_center + Vector2(0, -18),
			aim_dir,
			rad_px,
			0.40 if is_bat_cuc else 0.36,
			active_core_col,
			Color("#FF9F1C") if is_bat_cuc else active_mid_col,
			active_outer_col
		)
		_spawn_hit_sparks(hit_center + Vector2(0, -20), active_mid_col, aim_dir, 20 if is_bat_cuc else 16)
		VfxAssets.spawn_dust_puff(get_parent(), hit_center + Vector2(0, 8), Color(0.82, 0.76, 0.68, 0.50), 9, 145.0, 1.4)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(7.8 if is_bat_cuc else 6.0, 0.20)
		var sk_title: String = str(sdef.get("name", "Đấu Kỹ")).to_upper() + "!"
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), sk_title, Color("#FF9F1C"))
		var burst_poise: float = (48.0 if is_bat_cuc else 34.0) * poise_mult
		var hit_any: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if hit_center.distance_to(enemy_node.global_position) <= rad_px:
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, aim_dir * kb, r_pen, burn_val, 0.0, 1.0, burst_poise)
						hit_any = true
		if hit_any:
			EventBus.trigger_hitstop(0.038 if is_bat_cuc else 0.028, 0.09)

	elif behavior == "flame_dash":
		var start_p: Vector2 = global_position
		var burst_pt: Vector2 = start_p + aim_dir * 135.0
		dash_dir = aim_dir
		dash_duration_cur = 0.22
		dash_timer = 0.22
		dash_speed_override = 0.0
		invuln_timer = 0.35
		_spawn_dash_afterimage()
		_spawn_skill_vfx("flame_dash", start_p + Vector2(0, -14), aim_dir, rad_px, 0.38, active_core_col, Color("#FF9F1C"), Color("#E63946"), { "end_world_pos": burst_pt + Vector2(0, -14) })
		_spawn_hit_sparks(start_p + Vector2(0, -12), Color("#FF9F1C"), -aim_dir, 18)
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.screen_shake_requested.emit(5.0, 0.14)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "BẠO BỘ!", Color("#FF9F1C"))
		var mid_pt: Vector2 = start_p + aim_dir * 75.0
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if enemy_node.global_position.distance_to(start_p) <= rad_px or enemy_node.global_position.distance_to(mid_pt) <= rad_px:
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, aim_dir * kb, r_pen, burn_val, 0.0, 1.0, 24.0 * poise_mult)
						_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FF9F1C"), aim_dir, 10)

	elif behavior == "sonic_stun":
		_start_skill_pose(aim_dir, 0.30, "cast")
		_spawn_skill_vfx("sonic_stun", global_position + Vector2(0, -26), aim_dir, rad_px, 0.56, Color("#FFF8D6"), Color("#FFD166"), Color("#FF9F1C"), { "follow_target": self, "follow_offset": Vector2(0, -26) })
		_spawn_hit_sparks(global_position + Vector2(0, -26), Color("#FFD166"), Vector2.RIGHT, 22)
		var stun_s: float = float(sdef.get("stun_sec", 1.8))
		var core_burn: float = PlayerData.get_core_burn_dps()
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.screen_shake_requested.emit(7.5, 0.24)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "SƯ TỬ NGÂM!", Color("#FFD166"))
		var hit_s: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, core_burn, 0.0, 1.0, 38.0 * poise_mult)
						hit_s = true
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_s)
		if hit_s:
			EventBus.trigger_hitstop(0.032, 0.10)

	elif behavior == "flame_shield":
		_start_skill_pose(aim_dir, 0.28, "weapon")
		invuln_timer = maxf(invuln_timer, 1.25)
		_spawn_skill_vfx("flame_shield", global_position + Vector2(0, -24), aim_dir, rad_px, 1.25, active_core_col, active_mid_col, active_outer_col, { "follow_target": self, "follow_offset": Vector2(0, -24) })
		_spawn_hit_sparks(global_position + Vector2(0, -24), active_mid_col, Vector2.RIGHT, 24)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(7.2, 0.22)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "LỤC HỢP DU THÂN XÍCH! (MIỄN THƯƠNG)", Color("#FF9F1C"))
		var hit_sh: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 36.0 * poise_mult)
						_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), active_mid_col, push_d, 10)
						hit_sh = true
		if hit_sh:
			EventBus.trigger_hitstop(0.032, 0.10)

	elif behavior == "wing_cyclone":
		_start_skill_pose(aim_dir, 0.32, "weapon")
		lunge_vel = aim_dir * 490.0
		invuln_timer = maxf(invuln_timer, 0.45)
		_spawn_skill_vfx("wing_cyclone", global_position + Vector2(0, -24), aim_dir, rad_px, 0.44, Color("#F3D5FF"), Color("#C77DFF"), Color("#7B2CBF"), { "follow_target": self, "follow_offset": Vector2(0, -24) })
		_spawn_hit_sparks(global_position + Vector2(0, -24), Color("#C77DFF"), -aim_dir, 22)
		EventBus.audio_sfx_requested.emit("dash_whoosh")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(6.8, 0.20)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "TỬ VÂN DỰC KÍCH!", Color("#C77DFF"))
		var cyc_center: Vector2 = global_position + aim_dir * 68.0
		var hit_w: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if cyc_center.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 34.0 * poise_mult)
						_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#C77DFF"), push_d, 12)
						hit_w = true
		if hit_w:
			EventBus.trigger_hitstop(0.030, 0.10)

	elif behavior == "flame_buff":
		_start_skill_pose(aim_dir, 0.34, "cast")
		PlayerData.is_flame_buff_active = true
		flame_buff_timer = float(sdef.get("buff_duration", 10.0))
		_refresh_flame_shader()
		EventBus.stats_changed.emit()
		_spawn_skill_vfx("flame_buff", global_position + Vector2(0, -16), Vector2.UP, rad_px, 0.62, Color("#FFF3B0"), Color("#FF4D6D"), Color("#9D0208"), { "follow_target": self, "follow_offset": Vector2(0, -16) })
		_spawn_hit_sparks(global_position + Vector2(0, -20), Color("#FF4D6D"), Vector2.UP, 26)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.screen_shake_requested.emit(8.5, 0.26)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -82), "THIÊN HỎA TAM HUYỀN BIẾN! (+45% ATK)", Color("#FF4D6D"))
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 32.0 * poise_mult)

	elif behavior == "poison_palm":
		_start_skill_pose(aim_dir, 0.28, "cast")
		var palm_center: Vector2 = global_position + aim_dir * 72.0
		_spawn_skill_vfx("poison_palm", global_position + Vector2(0, -22), aim_dir, rad_px, 0.46, Color("#B7E4C7"), Color("#52B788"), Color("#1B4332"))
		_spawn_hit_sparks(palm_center + Vector2(0, -20), Color("#52B788"), aim_dir, 20)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(6.5, 0.18)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "LẠC ĐỘC ÁM CHƯỞNG! (-30% DEF)", Color("#52B788"))
		var hit_p: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if palm_center.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.30, 10.0)
					if enemy_node.has_method("apply_poison_detonate"):
						enemy_node.apply_poison_detonate(dmg * 0.65, 6.0)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 30.0 * poise_mult)
						_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#2EC4B6"), push_d, 12)
						hit_p = true
		if hit_p:
			EventBus.trigger_hitstop(0.030, 0.10)

	elif behavior == "thunder_blink":
		# TAM THIÊN LÔI ĐỘNG: Chớp lôi tốc độ cao 175px + 0.45s bất tử + Sét giật dọc quỹ đạo & nổ Lôi Ảnh tại chỗ cũ!
		is_attacking = false
		attack_follow_hold_timer = 0.0
		weapon_trail_active = false
		if absf(aim_dir.x) > 0.05:
			body_sprite.flip_h = aim_dir.x < 0.0
		var start_p: Vector2 = global_position
		var end_p: Vector2 = start_p + aim_dir * 175.0
		if cam != null and cam.limit_right > cam.limit_left:
			end_p.x = clampf(end_p.x, float(cam.limit_left) + 32.0, float(cam.limit_right) - 32.0)
			end_p.y = clampf(end_p.y, float(cam.limit_top) + 32.0, float(cam.limit_bottom) - 32.0)
		dash_dir = aim_dir
		dash_duration_cur = 0.16
		dash_timer = 0.16
		dash_speed_override = 1100.0
		invuln_timer = maxf(invuln_timer, 0.45)
		_spawn_dash_afterimage()
		_spawn_skill_vfx(
			"thunder_blink",
			start_p + Vector2(0, -22),
			aim_dir,
			rad_px,
			0.44,
			Color("#F8F9FA"),
			Color("#B8C0FF"),
			Color("#7B2CBF"),
			{ "end_world_pos": end_p + Vector2(0, -22) }
		)
		VfxAssets.spawn_spark_burst(get_parent(), start_p + Vector2(0, -20), Color("#E0FBFC"), Color("#9D4EDD"), 24, 110.0, 290.0, 0.38, -aim_dir, 180.0, 0.30, 0.65, true)
		VfxAssets.spawn_spark_burst(get_parent(), end_p + Vector2(0, -20), Color("#FFFFFF"), Color("#72EFDD"), 16, 85.0, 230.0, 0.32, aim_dir, 150.0, 0.25, 0.55, true)
		EventBus.audio_sfx_requested.emit("thunder_blink")
		EventBus.screen_shake_requested.emit(6.5, 0.18)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "TAM THIÊN LÔI ĐỘNG!", Color("#C77DFF"))
		var path_width: float = maxf(66.0, rad_px * 0.58)
		var hit_tb: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				var closest_pt: Vector2 = Geometry2D.get_closest_point_to_segment(enemy_node.global_position, start_p, end_p)
				var on_path: bool = enemy_node.global_position.distance_to(closest_pt) <= path_width
				var in_afterimage: bool = enemy_node.global_position.distance_to(start_p) <= rad_px
				if on_path or in_afterimage:
					var push_d: Vector2 = (enemy_node.global_position - start_p).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("apply_slow"):
						enemy_node.apply_slow(0.45, 2.2)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 34.0 * poise_mult)
						VfxAssets.spawn_spark_burst(get_parent(), enemy_node.global_position + Vector2(0, -24), Color("#E0FBFC"), Color("#C77DFF"), 12, 90.0, 220.0, 0.30, push_d, 150.0, 0.26, 0.55, true)
						hit_tb = true
		if hit_tb:
			EventBus.trigger_hitstop(0.028, 0.10)

	elif behavior == "golden_roar":
		# SƯ HỔ TOÁI KIM NGÂM: Sóng âm Sư Hổ nón vàng kim ±48° phá giáp -35% + làm choáng + phá thế mạnh!
		_start_skill_pose(aim_dir, 0.32, "cast")
		_spawn_skill_vfx("golden_roar", global_position + Vector2(0, -24), aim_dir, rad_px, 0.54, Color("#FFF8D6"), Color("#FFD166"), Color("#E07A00"), { "follow_target": self, "follow_offset": Vector2(0, -24) })
		_spawn_hit_sparks(global_position + aim_dir * 32.0 + Vector2(0, -24), Color("#FFD166"), aim_dir, 24)
		var stun_s: float = float(sdef.get("stun_sec", 2.0))
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.screen_shake_requested.emit(8.5, 0.26)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -80), "SƯ HỔ TOÁI KIM NGÂM!", Color("#FFD166"))
		var hit_gr: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				var to_en: Vector2 = enemy_node.global_position - global_position
				var dist: float = to_en.length()
				if dist <= rad_px:
					var push_d: Vector2 = to_en.normalized() if dist > 4.0 else aim_dir
					if aim_dir.dot(push_d) >= 0.25 or dist <= 95.0:
						if enemy_node.has_method("apply_def_shred"):
							enemy_node.apply_def_shred(0.35, 8.0)
						if enemy_node.has_method("apply_stun"):
							enemy_node.apply_stun(stun_s)
						if enemy_node.has_method("receive_hit"):
							enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 48.0 * poise_mult)
							_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FFD166"), push_d, 12)
							hit_gr = true
		if hit_gr:
			EventBus.trigger_hitstop(0.036, 0.09)

	elif behavior == "mountain_seal":
		# ĐẾ ẤN QUYẾT — KHAI SƠN ẤN: Giáng Cổ Ấn vàng ngọc xuống điểm trỏ (trong 220px), làm choáng & phá thế cực mạnh!
		_start_skill_pose(aim_dir, 0.34, "cast")
		var m_vec: Vector2 = aim_target - global_position
		var m_dist: float = m_vec.length()
		var seal_pos: Vector2 = (global_position + aim_dir * 135.0) if m_dist < 24.0 else (global_position + aim_dir * minf(m_dist, 220.0))
		_spawn_skill_vfx("mountain_seal", seal_pos, aim_dir, rad_px, 0.68, Color("#FFF8D6"), Color("#FFD166"), Color("#2EC4B6"), { "z_index": 6 })
		VfxAssets.spawn_spark_burst(get_parent(), seal_pos + Vector2(0, -16), Color("#FFF8D6"), Color("#FFD166"), 28, 120.0, 310.0, 0.48, Vector2.UP, 180.0, 0.32, 0.72, true)
		VfxAssets.spawn_dust_puff(get_parent(), seal_pos + Vector2(0, 8), Color(0.95, 0.85, 0.55, 0.52), 12, 165.0, 1.75)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.audio_sfx_requested.emit("poise_break")
		EventBus.screen_shake_requested.emit(10.5, 0.30)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -82), "ĐẾ ẤN QUYẾT — KHAI SƠN ẤN!", Color("#FFD166"))
		var stun_ms: float = float(sdef.get("stun_sec", 1.6))
		var hit_ms: bool = false
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if seal_pos.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - seal_pos).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_ms)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 58.0 * poise_mult)
						VfxAssets.spawn_spark_burst(get_parent(), enemy_node.global_position + Vector2(0, -24), Color("#FFFFFF"), Color("#FFD166"), 14, 95.0, 235.0, 0.34, push_d, 150.0, 0.28, 0.58, true)
						hit_ms = true
		if hit_ms:
			EventBus.trigger_hitstop(0.045, 0.08)

	elif behavior == "flame_clone":
		# HỎA LIÊN PHÂN THÂN: Triệu hồi 3 quả cầu Dị Hỏa xoay quanh thân trong 6.5s, tự động đốt nổ địch mỗi 0.55s!
		_start_skill_pose(aim_dir, 0.30, "cast")
		var fc_dur: float = float(sdef.get("buff_duration", 6.5))
		flame_clone_timer = fc_dur
		flame_clone_tick = 0.10
		flame_clone_dmg = dmg * 0.55
		flame_clone_radius = maxf(110.0, rad_px)
		flame_clone_r_pen = r_pen
		_spawn_skill_vfx(
			"flame_clone",
			global_position + Vector2(0, -24),
			aim_dir,
			flame_clone_radius,
			fc_dur,
			active_core_col,
			active_mid_col,
			active_outer_col,
			{ "follow_target": self, "follow_offset": Vector2(0, -24) }
		)
		_spawn_hit_sparks(global_position + Vector2(0, -24), active_mid_col, Vector2.UP, 24)
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.screen_shake_requested.emit(5.5, 0.18)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -80), "HỎA LIÊN PHÂN THÂN!", active_mid_col)

	elif behavior == "flame_wave":
		_start_skill_pose(aim_dir, 0.28, "weapon")
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.screen_shake_requested.emit(5.2, 0.15)
		_spawn_hit_sparks(global_position + aim_dir * 32.0 + Vector2(0, -24), active_mid_col, aim_dir, 16)
		if get_parent() != null:
			var proj: Area2D = SKILL_SCENE.instantiate() as Area2D
			get_parent().add_child(proj)
			var spd: float = float(sdef.get("projectile_speed", 460.0))
			var use_flame: Dictionary = f_def if not f_def.is_empty() else GameDatabase.get_flame_def("pham_hoa")
			if proj.has_method("configure_skill"):
				proj.configure_skill("flame_wave", global_position + aim_dir * 36.0 + Vector2(0, -24), aim_target, dmg, kb, r_pen, rad_px, spd, use_flame, [])

	elif behavior == "fire_lotus_ult":
		# PHẬT NỘ HỎA LIÊN: Pha tụ ấn 0.22s gom năng lượng nhiều ngọn Dị Hỏa giữa tay trước khi phóng!
		_start_skill_pose(aim_dir, 0.34, "cast")
		var use_flame: Dictionary = f_def if not f_def.is_empty() else GameDatabase.get_flame_def("pham_hoa")
		var fusion_list: Array = PlayerData.lotus_fusion_flames.duplicate()
		if fusion_list.is_empty():
			fusion_list = [str(use_flame.get("id", "pham_hoa"))]
		var fusion_cols: Array = []
		for fid in fusion_list:
			var fd: Dictionary = GameDatabase.get_flame_def(str(fid))
			if not fd.is_empty():
				fusion_cols.append(Color(str(fd.get("mid_hex", "#2EC4B6"))))
		_spawn_skill_vfx(
			"lotus_cast",
			global_position + aim_dir * 26.0 + Vector2(0, -26),
			aim_dir,
			90.0,
			0.24,
			active_core_col,
			active_mid_col,
			active_outer_col,
			{ "follow_target": self, "follow_offset": aim_dir * 26.0 + Vector2(0, -26), "extra_colors": fusion_cols }
		)
		EventBus.audio_sfx_requested.emit("skill_stun")
		var fusion_bonus: float = (1.0 + float(max(0, fusion_list.size() - 1)) * 0.28) * PlayerData.get_lotus_affection_dmg_mult()
		pending_lotus_timer = 0.22
		pending_lotus_payload = {
			"aim_target": aim_target,
			"dmg": dmg * fusion_bonus,
			"kb": kb,
			"r_pen": r_pen,
			"rad_px": rad_px,
			"spd": float(sdef.get("projectile_speed", 360.0)),
			"flame_def": use_flame,
			"fusion_list": fusion_list
		}


func _pulse_flame_clone_burst() -> void:
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var burn_val: float = (flame_clone_dmg * float(f_def.get("burn_dps_ratio", 0.10)) * PlayerData.get_flame_dmg_multiplier() if not f_def.is_empty() else 0.0) + PlayerData.get_core_burn_dps()
	var poise_val: float = 14.0 * PlayerData.get_poise_dmg_multiplier()
	var struck: bool = false
	for en in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(en) or not (en is Node2D):
			continue
		var enemy_node: Node2D = en as Node2D
		if global_position.distance_to(enemy_node.global_position) <= flame_clone_radius:
			var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
			if push_d == Vector2.ZERO:
				push_d = Vector2.RIGHT
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(flame_clone_dmg, push_d * 145.0, flame_clone_r_pen, burn_val, 0.0, 1.0, poise_val)
				_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), active_mid_col, push_d, 8)
				struck = true
	if struck:
		EventBus.audio_sfx_requested.emit("skill_fire")


func _detonate_flame_clone_finale() -> void:
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var finale_dmg: float = flame_clone_dmg * 1.65
	var burn_val: float = (finale_dmg * float(f_def.get("burn_dps_ratio", 0.12)) * PlayerData.get_flame_dmg_multiplier() if not f_def.is_empty() else 0.0) + PlayerData.get_core_burn_dps()
	var poise_val: float = 28.0 * PlayerData.get_poise_dmg_multiplier()
	_spawn_skill_vfx(
		"lotus_detonate",
		global_position + Vector2(0, -24),
		Vector2.RIGHT,
		flame_clone_radius * 1.08,
		0.46,
		active_core_col,
		active_mid_col,
		active_outer_col,
		{ "extra_colors": [active_mid_col, active_core_col] }
	)
	_spawn_hit_sparks(global_position + Vector2(0, -24), active_mid_col, Vector2.UP, 24)
	EventBus.audio_sfx_requested.emit("skill_burst")
	EventBus.screen_shake_requested.emit(6.5, 0.20)
	for en in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(en) or not (en is Node2D):
			continue
		var enemy_node: Node2D = en as Node2D
		if global_position.distance_to(enemy_node.global_position) <= flame_clone_radius * 1.12:
			var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
			if push_d == Vector2.ZERO:
				push_d = Vector2.RIGHT
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(finale_dmg, push_d * 290.0, flame_clone_r_pen, burn_val, 0.0, 1.0, poise_val)


func _activate_duoc_lao_assist() -> void:
	var mode: String = PlayerData.get_assist_mode()
	if mode == "locked":
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Chưa mở Cốt Linh Phụ Thể [T]!", Color("#ADB5BD"))
		EventBus.banter_triggered.emit("Gợi ý cốt truyện: Hoàn thành trận diệt Gia Liệt Áo (cuối Chương 01) để mở khóa Cốt Linh Phụ Thể [T]!")
		return
	if mode == "sleeping":
		EventBus.audio_sfx_requested.emit("alchemy_fail")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -74), "Dược Lão Đang Ngủ Say Trong Nhẫn Đen!", Color("#A8DADC"))
		EventBus.banter_triggered.emit("Cốt truyện Chương 04: Dược Lão đã tiêu hao tàn hồn sau vụ nổ Mặc Gia! Hãy tự lực chinh phục Đế Đô & Vân Lam Sơn!")
		return
	if float(skill_cooldowns.get("T", 0.0)) > 0.0:
		return
	_start_skill_pose(Vector2.RIGHT if not body_sprite.flip_h else Vector2.LEFT, 0.36, "cast")
	PlayerData.is_duoc_lao_active = true
	duoc_lao_timer = 12.0
	skill_cooldowns["T"] = 45.0
	skill_cooldown_totals["T"] = 45.0
	EventBus.skill_cooldown_updated.emit("T", 45.0, 45.0)
	_refresh_flame_shader()
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.stats_changed.emit()
	EventBus.screen_shake_requested.emit(10.5 if mode == "medusa_dau_tong" else 8.5, 0.32)
	EventBus.trigger_hitstop(0.042, 0.08)
	if mode == "medusa_dau_tong":
		_spawn_skill_vfx("medusa_assist", global_position + Vector2(0, -20), Vector2.UP, 235.0, 0.65, Color("#FFFFFF"), Color("#E0AAFF"), Color("#7B2CBF"), { "follow_target": self, "follow_offset": Vector2(0, -20) })
		_spawn_hit_sparks(global_position + Vector2(0, -24), Color("#E0AAFF"), Vector2.RIGHT, 30)
		var m_dmg: float = PlayerData.get_atk() * 2.4
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var en_nd: Node2D = en as Node2D
				if global_position.distance_to(en_nd.global_position) <= 235.0:
					var push_d: Vector2 = (en_nd.global_position - global_position).normalized()
					if en_nd.has_method("receive_hit"):
						en_nd.receive_hit(m_dmg, push_d * 540.0, 0.75, PlayerData.get_core_burn_dps(), 0.0, 1.0, 55.0 * PlayerData.get_poise_dmg_multiplier())
					if en_nd.has_method("apply_stun"):
						en_nd.apply_stun(1.4)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -82), "ĐẤU TÔNG MỸ ĐỖ TOA HỘ PHÁP!", Color("#E0AAFF"))
		EventBus.banter_triggered.emit("Mỹ Đỗ Toa Nữ Vương (Đạp Hư Không): 'Kẻ giữ đan phương của bổn vương, đám sâu kiến các ngươi cũng dám động vào sao?!'")
	else:
		_spawn_skill_vfx("duoc_lao_assist", global_position + Vector2(0, -20), Vector2.UP, 175.0, 0.60, Color("#FFFFFF"), Color("#A8DADC"), Color("#457B9D"), { "follow_target": self, "follow_offset": Vector2(0, -20) })
		_spawn_hit_sparks(global_position + Vector2(0, -24), Color("#A8DADC"), Vector2.UP, 26)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "CỐT LINH PHỤ THỂ!", Color("#A8DADC"))
		EventBus.banter_triggered.emit("Dược Lão: 'Giao thân thể cho vi sư! Để chúng chiêm ngưỡng uy lực Cốt Linh Lãnh Hỏa!'")


func take_enemy_damage(raw_dmg: float, attacker_realm_idx: int, push_vec: Vector2) -> void:
	if invuln_timer > 0.0:
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
	var final_dmg: float = maxf(1.0, raw_after_def * armor_mult * quy_linh_mult)

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
