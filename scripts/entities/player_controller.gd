extends CharacterBody2D
## Điều khiển Nhân vật chính TIÊU VIÊM — Phiên bản Giai Đoạn 1 & 2 Hoàn Chỉnh:
## - Đánh liền thân Quyền Cước / Kiếm / Đao / Huyền Trọng Xích + SFX từng loại vũ khí!
## - Hỗ trợ trọn bộ 10 Đấu Kỹ (bao gồm Bạo Bộ, Sư Tử Ngâm làm choáng, Lục Hợp Du Thân Xích miễn thương, Tử Vân Dực Kích, Thiên Hỏa Tam Huyền Biến!).
## - Phím [G] triệu hồi / chuyển Đồng Hành Trợ Chiến (Tiểu Y Tiên / Hồn Ảnh Dược Lão).
## - La bàn Mũi Tên Vàng chỉ hướng mục tiêu Nhiệm Vụ Cốt Truyện quanh chân nhân vật!

const SKILL_SCENE_PATH: String = "res://scenes/entities/skill_effect.tscn"

var idle_tex: Texture2D
var run_tex: Texture2D
var attack_tex: Texture2D

var anim_state: String = "idle"
var anim_timer: float = 0.0
var dust_timer: float = 0.0

var is_attacking: bool = false
var attack_anim_timer: float = 0.0
var attack_anim_duration: float = 0.24
var attack_windup_frame: int = 0
var attack_strike_frame: int = 1
var attack_hit_triggered: bool = false
var attack_aim_dir: Vector2 = Vector2.RIGHT
var attack_is_skill_pose: bool = false

var combo_step: int = 0
var combo_reset_timer: float = 0.0
var attack_cooldown: float = 0.0
var lunge_vel: Vector2 = Vector2.ZERO
var hitstop_timer: float = 0.0

var dash_timer: float = 0.0
var dash_cooldown: float = 0.0
var dash_dir: Vector2 = Vector2.RIGHT
var invuln_timer: float = 0.0

var knockback_vel: Vector2 = Vector2.ZERO
var duoc_lao_timer: float = 0.0
var flame_buff_timer: float = 0.0

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
var burst_ring_timer: float = 0.0
var burst_ring_radius: float = 115.0
var burst_ring_color: Color = Color("#FFE599")

var shake_strength: float = 0.0
var shake_timer: float = 0.0

var flame_light: PointLight2D
var ember_particles: CPUParticles2D
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
	_apply_body_sheet(idle_tex, 1, Vector2(0, -34))
	slash_vfx.visible = false
	_setup_lighting_and_particles()
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
		back_weapon_sprite.visible = not is_attacking
	else:
		back_weapon_sprite.visible = false

	var atk_path: String = PlayerData.get_equipped_attack_sheet_path()
	var loaded_atk: Texture2D = load(atk_path)
	if loaded_atk != null:
		attack_tex = loaded_atk


func _setup_lighting_and_particles() -> void:
	flame_light = PointLight2D.new()
	flame_light.texture = load("res://assets/sprites/vfx/light_radial_128.png")
	flame_light.texture_scale = 2.8
	flame_light.energy = 0.75
	flame_light.position = Vector2(0, -24)
	add_child(flame_light)

	ember_particles = CPUParticles2D.new()
	ember_particles.emitting = false
	ember_particles.amount = 20
	ember_particles.lifetime = 0.85
	ember_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	ember_particles.emission_sphere_radius = 28.0
	ember_particles.direction = Vector2(0, -1)
	ember_particles.spread = 45.0
	ember_particles.gravity = Vector2(0, -35)
	ember_particles.initial_velocity_min = 18.0
	ember_particles.initial_velocity_max = 46.0
	ember_particles.scale_amount_min = 2.5
	ember_particles.scale_amount_max = 4.5
	ember_particles.position = Vector2(0, -12)
	add_child(ember_particles)


func _apply_body_sheet(tex: Texture2D, h_frames: int, sprite_pos: Vector2) -> void:
	if tex == null or body_sprite == null:
		return
	body_sprite.texture = tex
	body_sprite.hframes = max(1, h_frames)
	body_sprite.vframes = 1
	body_sprite.position = sprite_pos
	body_sprite.scale = Vector2.ONE


func _on_flame_changed(_fid: String) -> void:
	_refresh_flame_shader()


func _refresh_flame_shader() -> void:
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var has_flame: bool = not f_def.is_empty()

	var core_c: Color = Color(str(f_def.get("core_hex", "#FFF3B0"))) if has_flame else Color("#FFFFFF")
	var mid_c: Color = Color(str(f_def.get("mid_hex", "#FF7B00"))) if has_flame else Color("#B8D4E8")
	var outer_c: Color = Color(str(f_def.get("outer_hex", "#9E2A2B"))) if has_flame else Color("#52687A")

	var sh: Shader = load("res://assets/shaders/di_hoa_palette.gdshader")
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("core_color", core_c)
	mat.set_shader_parameter("mid_color", mid_c)
	mat.set_shader_parameter("outer_color", outer_c)
	mat.set_shader_parameter("intensity", 1.65 if (has_flame or PlayerData.is_flame_buff_active) else 1.05)
	slash_vfx.material = mat

	if flame_light != null:
		flame_light.color = mid_c.lerp(core_c, 0.25) if has_flame else Color("#DCE6F5")
		flame_light.energy = 1.55 if (PlayerData.is_duoc_lao_active or PlayerData.is_flame_buff_active) else (1.10 if has_flame else 0.70)
	if ember_particles != null:
		ember_particles.emitting = has_flame or PlayerData.is_flame_buff_active
		ember_particles.color = core_c.lerp(mid_c, 0.45)


func _physics_process(delta: float) -> void:
	if hitstop_timer > 0.0:
		hitstop_timer -= delta
		return

	_tick_timers(delta)
	if input_blocked_by_ui:
		velocity = Vector2.ZERO
		_update_character_animation(delta, false)
		return

	_handle_aim_and_flip()
	_handle_combat_inputs()

	var move_input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_vel: Vector2 = Vector2.ZERO
	if dash_timer > 0.0:
		desired_vel = dash_dir * (695.0 if PlayerData.has_tu_van_duc_equipped() else 560.0)
		velocity = desired_vel
		if int(floor(dash_timer * 42.0)) != int(floor((dash_timer - delta) * 42.0)):
			_spawn_dash_afterimage()
	elif is_attacking:
		desired_vel = move_input * (PlayerData.get_move_speed() * 0.35) + lunge_vel + knockback_vel
		velocity = velocity.lerp(desired_vel, minf(1.0, delta * 22.0))
	else:
		desired_vel = move_input * PlayerData.get_move_speed() + lunge_vel + knockback_vel
		velocity = velocity.lerp(desired_vel, minf(1.0, delta * 18.0))

	_update_character_animation(delta, move_input.length() > 0.1)

	lunge_vel = lunge_vel.move_toward(Vector2.ZERO, 1650.0 * delta)
	knockback_vel = knockback_vel.move_toward(Vector2.ZERO, 1050.0 * delta)
	move_and_slide()
	queue_redraw()


func _update_character_animation(delta: float, is_moving: bool) -> void:
	var smooth_k: float = minf(1.0, delta * 18.0)
	if is_attacking:
		back_weapon_sprite.visible = false
		attack_anim_timer += delta
		var progress: float = attack_anim_timer / maxf(0.05, attack_anim_duration)
		var f_sign: float = -1.0 if body_sprite.flip_h else 1.0

		if progress < 0.26:
			body_sprite.frame = attack_windup_frame
			body_sprite.scale = body_sprite.scale.lerp(Vector2(0.92, 1.08), smooth_k)
			body_sprite.rotation = lerpf(body_sprite.rotation, -f_sign * 0.08, smooth_k)
		else:
			body_sprite.frame = attack_strike_frame
			var strike_t: float = clampf((progress - 0.26) / 0.74, 0.0, 1.0)
			var stretch_s: Vector2 = Vector2(1.12, 0.90).lerp(Vector2.ONE, strike_t)
			body_sprite.scale = body_sprite.scale.lerp(stretch_s, smooth_k)
			body_sprite.rotation = lerpf(body_sprite.rotation, f_sign * 0.09 * (1.0 - strike_t), smooth_k)
			if not attack_hit_triggered:
				attack_hit_triggered = true
				if not attack_is_skill_pose:
					_execute_melee_strike_impact()

		if attack_anim_timer >= attack_anim_duration:
			is_attacking = false
			back_weapon_sprite.visible = PlayerData.has_weapon_equipped()
			anim_state = ""
		return

	back_weapon_sprite.visible = PlayerData.has_weapon_equipped()
	var desired_state: String = "run" if is_moving else "idle"
	if desired_state != anim_state:
		anim_state = desired_state
		anim_timer = 0.0
		if is_moving:
			_apply_body_sheet(run_tex, 4, Vector2(0, -34))
		else:
			_apply_body_sheet(idle_tex, 1, Vector2(0, -34))

	var t_sec: float = float(Time.get_ticks_msec()) * 0.001
	if is_moving:
		anim_timer += delta * 10.5
		body_sprite.frame = int(anim_timer) % max(1, body_sprite.hframes)
		var hop: float = absf(sin(anim_timer * 1.5))
		var target_sc := Vector2(1.0 - 0.03 * hop, 1.0 + 0.04 * hop)
		var tilt: float = clampf(velocity.x / 260.0, -1.0, 1.0) * 0.06
		body_sprite.scale = body_sprite.scale.lerp(target_sc, smooth_k)
		body_sprite.rotation = lerpf(body_sprite.rotation, tilt, smooth_k)
		back_weapon_sprite.position.y = lerpf(back_weapon_sprite.position.y, -34.0 + sin(anim_timer * 1.6) * 2.2, smooth_k)
		if dash_timer <= 0.0:
			dust_timer -= delta
			if dust_timer <= 0.0:
				dust_timer = 0.15
				_spawn_footstep_dust()
	else:
		body_sprite.frame = 0
		var breath: float = sin(t_sec * 3.4) * 0.025
		body_sprite.scale = body_sprite.scale.lerp(Vector2(1.0 - breath * 0.5, 1.0 + breath), smooth_k)
		body_sprite.rotation = lerpf(body_sprite.rotation, 0.0, smooth_k)
		back_weapon_sprite.position.y = lerpf(back_weapon_sprite.position.y, -34.0 + sin(t_sec * 3.4) * 1.4, smooth_k)


func _spawn_footstep_dust() -> void:
	if get_parent() == null:
		return
	var p := CPUParticles2D.new()
	p.global_position = global_position + Vector2(0, 10)
	p.one_shot = true
	p.explosiveness = 0.9
	p.amount = 6
	p.lifetime = 0.35
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.gravity = Vector2(0, 20)
	p.initial_velocity_min = 16.0
	p.initial_velocity_max = 36.0
	p.scale_amount_min = 2.5
	p.scale_amount_max = 4.5
	p.color = Color(0.70, 0.74, 0.80, 0.52)
	get_parent().add_child(p)
	p.emitting = true
	get_tree().create_timer(0.45).timeout.connect(p.queue_free)


func _spawn_hit_sparks(world_pos: Vector2, spark_col: Color) -> void:
	if get_parent() == null:
		return
	var p := CPUParticles2D.new()
	p.global_position = world_pos
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 12
	p.lifetime = 0.30
	p.spread = 180.0
	p.gravity = Vector2(0, 110)
	p.initial_velocity_min = 70.0
	p.initial_velocity_max = 175.0
	p.scale_amount_min = 2.5
	p.scale_amount_max = 4.5
	p.color = spark_col
	get_parent().add_child(p)
	p.emitting = true
	get_tree().create_timer(0.42).timeout.connect(p.queue_free)


func _tick_timers(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if combo_reset_timer > 0.0:
		combo_reset_timer -= delta
		if combo_reset_timer <= 0.0:
			combo_step = 0
	if dash_timer > 0.0:
		dash_timer -= delta
	if dash_cooldown > 0.0:
		dash_cooldown = maxf(0.0, dash_cooldown - delta)
		EventBus.skill_cooldown_updated.emit("SPACE", dash_cooldown, dash_cooldown_total)
	if invuln_timer > 0.0:
		invuln_timer -= delta
	if slash_preview_timer > 0.0:
		slash_preview_timer -= delta
		if slash_preview_timer <= 0.0:
			slash_vfx.visible = false
	if burst_ring_timer > 0.0:
		burst_ring_timer -= delta

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

	var qi_regen: float = 3.6 + float(PlayerData.realm_index) * 1.8
	if PlayerData.has_flag("got_thanh_lien_dai"):
		qi_regen *= 1.40 # Thanh Liên Đài hồi Đấu Khí siêu tốc!
	if PlayerData.current_qi < PlayerData.get_max_qi():
		PlayerData.current_qi = minf(PlayerData.get_max_qi(), PlayerData.current_qi + qi_regen * delta)
		EventBus.stats_changed.emit()

	for k in skill_cooldowns.keys():
		var cur_cd: float = float(skill_cooldowns[k])
		if cur_cd > 0.0:
			cur_cd = maxf(0.0, cur_cd - delta)
			skill_cooldowns[k] = cur_cd
			EventBus.skill_cooldown_updated.emit(str(k), cur_cd, float(skill_cooldown_totals.get(k, 1.0)))

	if shake_timer > 0.0:
		shake_timer -= delta
		cam.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		if shake_timer <= 0.0:
			cam.offset = Vector2.ZERO


func _handle_aim_and_flip() -> void:
	if is_attacking:
		return
	var mouse_world: Vector2 = get_global_mouse_position()
	var aim_vec: Vector2 = mouse_world - global_position
	if aim_vec.x != 0.0:
		var facing_left: bool = aim_vec.x < 0.0
		body_sprite.flip_h = facing_left
		back_weapon_sprite.flip_h = facing_left
		back_weapon_sprite.position.x = 6.0 if facing_left else -6.0
		back_weapon_sprite.rotation = 0.68 if facing_left else -0.68


func _handle_combat_inputs() -> void:
	var mouse_over_ui: bool = (get_viewport().gui_get_hovered_control() != null)

	if Input.is_action_just_pressed("toggle_weight"):
		if not (mouse_over_ui and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
			trigger_ui_toggle_weight()

	if Input.is_action_just_pressed("toggle_companion"):
		trigger_ui_toggle_companion()

	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0:
		_perform_dash()

	if Input.is_action_pressed("attack") and attack_cooldown <= 0.0 and not mouse_over_ui:
		_start_integrated_combo_attack()

	if Input.is_action_just_pressed("skill_q"):
		trigger_ui_skill("Q")
	if Input.is_action_just_pressed("skill_e"):
		trigger_ui_skill("E")
	if Input.is_action_just_pressed("skill_r"):
		trigger_ui_skill("R")
	if Input.is_action_just_pressed("skill_ult"):
		trigger_ui_skill("F")
	if Input.is_action_just_pressed("skill_assist"):
		trigger_ui_skill("T")

	if Input.is_action_just_pressed("quick_pill_1"):
		trigger_ui_use_pill(1)
	if Input.is_action_just_pressed("quick_pill_2"):
		trigger_ui_use_pill(2)
	if Input.is_action_just_pressed("quick_pill_3"):
		trigger_ui_use_pill(3)


func trigger_ui_attack() -> void:
	if input_blocked_by_ui or attack_cooldown > 0.0:
		return
	_start_integrated_combo_attack()


func trigger_ui_dash() -> void:
	if input_blocked_by_ui or dash_cooldown > 0.0:
		return
	_perform_dash()


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
	if slot_num == 1:
		PlayerData.use_consumable("pill_ngung_huyet_tan", global_position + Vector2(0, -45))
	elif slot_num == 2:
		PlayerData.use_consumable("pill_hoi_khi_dan", global_position + Vector2(0, -45))
	elif slot_num == 3:
		PlayerData.use_consumable("pill_truc_co_linh_dich", global_position + Vector2(0, -45))


func _try_cast_slot(slot_key: String, lock_hint: String) -> void:
	var sk_id: String = PlayerData.get_skill_in_slot(slot_key)
	if sk_id == "":
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Chưa lắp Đấu Kỹ [%s]!" % slot_key, Color("#ADB5BD"))
		EventBus.banter_triggered.emit("Gợi ý cốt truyện: " + lock_hint)
		return
	_cast_skill_slot(slot_key, sk_id)


func _perform_dash() -> void:
	is_attacking = false
	var move_in: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if move_in.length() > 0.1:
		dash_dir = move_in.normalized()
	else:
		dash_dir = (get_global_mouse_position() - global_position).normalized()
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2.RIGHT

	var has_wings: bool = PlayerData.has_tu_van_duc_equipped()
	dash_timer = 0.24 if has_wings else 0.18
	dash_cooldown_total = (0.64 if has_wings else 0.72) * PlayerData.get_cooldown_multiplier()
	dash_cooldown = dash_cooldown_total
	invuln_timer = 0.34 if has_wings else 0.28
	EventBus.skill_cooldown_updated.emit("SPACE", dash_cooldown, dash_cooldown_total)
	EventBus.audio_sfx_requested.emit("dash_whoosh")
	_spawn_dash_afterimage()
	if has_wings:
		_spawn_hit_sparks(global_position + Vector2(0, -18), Color("#C77DFF"))


func _spawn_dash_afterimage() -> void:
	if get_parent() == null:
		return
	var ghost := Sprite2D.new()
	ghost.texture = body_sprite.texture
	ghost.hframes = body_sprite.hframes
	ghost.frame = body_sprite.frame
	ghost.flip_h = body_sprite.flip_h
	ghost.global_position = global_position + body_sprite.position
	ghost.modulate = Color(0.82, 0.45, 1.0, 0.68) if PlayerData.has_tu_van_duc_equipped() else Color(0.70, 0.85, 1.0, 0.55)
	get_parent().add_child(ghost)
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tw.tween_callback(ghost.queue_free)


func _start_integrated_combo_attack() -> void:
	combo_step = (combo_step % 3) + 1
	combo_reset_timer = 0.95

	var seal_slow: float = 1.16 if (PlayerData.is_ruler_sealed and PlayerData.has_huyen_trong_xich_equipped()) else 0.95
	var wpn_spd: float = maxf(0.55, PlayerData.get_weapon_attack_speed_mult())
	var dur: float = (0.24 * seal_slow) / wpn_spd
	attack_cooldown = dur + 0.04

	attack_aim_dir = (get_global_mouse_position() - global_position).normalized()
	if attack_aim_dir == Vector2.ZERO:
		attack_aim_dir = Vector2.RIGHT
	body_sprite.flip_h = attack_aim_dir.x < 0.0

	if combo_step == 1:
		attack_windup_frame = 0
		attack_strike_frame = 1
	elif combo_step == 2:
		attack_windup_frame = 2
		attack_strike_frame = 3
	else:
		attack_windup_frame = 0
		attack_strike_frame = 3
		dur *= 1.12

	is_attacking = true
	attack_is_skill_pose = false
	attack_anim_timer = 0.0
	attack_anim_duration = dur
	attack_hit_triggered = false

	if attack_tex != null:
		_apply_body_sheet(attack_tex, 4, Vector2(0, -58))
		body_sprite.frame = attack_windup_frame
	back_weapon_sprite.visible = false
	lunge_vel = attack_aim_dir * (210.0 if combo_step == 3 else 135.0)

	# Phát âm thanh vung tay / kiếm / trọng xích tương ứng!
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
	var base_sc: float = 1.85 if has_wpn else 1.05
	slash_vfx.scale = Vector2(base_sc * 1.25, base_sc * 1.25) if combo_step == 3 else Vector2(base_sc, base_sc)
	slash_preview_timer = 0.13

	var mult: float = 1.0
	var reach_px: float = 114.0 if has_wpn else 82.0
	var kb: float = 260.0 if has_wpn else 190.0
	if combo_step == 2:
		mult = 1.18
	elif combo_step == 3:
		mult = 1.55
		reach_px += 18.0
		kb += 110.0
		EventBus.screen_shake_requested.emit(4.2, 0.11)

	var dmg: float = PlayerData.get_atk() * mult
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var burn_val: float = 0.0
	var spark_col: Color = Color("#E0F0FF")
	if not f_def.is_empty():
		burn_val = dmg * float(f_def.get("burn_dps_ratio", 0.08)) * PlayerData.get_flame_dmg_multiplier()
		spark_col = Color(str(f_def.get("core_hex", "#FFF3B0")))

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
					enemy_node.receive_hit(dmg, attack_aim_dir * kb, 0.0, burn_val)
					_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), spark_col)
					hit_any = true

	if hit_any:
		hitstop_timer = 0.030 if combo_step == 3 else 0.018


func _trigger_skill_attack_pose(aim_dir: Vector2) -> void:
	if attack_tex == null:
		return
	body_sprite.flip_h = aim_dir.x < 0.0
	is_attacking = true
	attack_is_skill_pose = true
	attack_anim_timer = 0.0
	attack_anim_duration = 0.24
	attack_windup_frame = 0
	attack_strike_frame = 3
	attack_hit_triggered = true
	_apply_body_sheet(attack_tex, 4, Vector2(0, -58))
	body_sprite.frame = 3
	back_weapon_sprite.visible = false


func _cast_skill_slot(slot_key: String, skill_id: String) -> void:
	if float(skill_cooldowns.get(slot_key, 0.0)) > 0.0:
		return
	var sdef: Dictionary = GameDatabase.get_skill_def(skill_id)
	if sdef.is_empty():
		return

	var qi_cost: float = float(sdef.get("qi_cost", 15.0))
	if PlayerData.current_qi < qi_cost:
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -64), "Không đủ Đấu Khí!", Color("#4CC9F0"))
		return

	PlayerData.current_qi -= qi_cost
	EventBus.stats_changed.emit()

	var cd_total: float = float(sdef.get("cooldown", 5.0)) * PlayerData.get_cooldown_multiplier()
	skill_cooldowns[slot_key] = cd_total
	skill_cooldown_totals[slot_key] = cd_total
	EventBus.skill_cooldown_updated.emit(slot_key, cd_total, cd_total)

	var behavior: String = str(sdef.get("behavior", "melee_burst"))
	var dmg: float = (PlayerData.get_atk() * float(sdef.get("atk_ratio", 1.5)) + float(PlayerData.get_soul()) * float(sdef.get("soul_ratio", 0.2))) * PlayerData.get_flame_dmg_multiplier()
	var rad_px: float = float(sdef.get("radius_px", 110.0))
	var kb: float = float(sdef.get("knockback", 320.0))
	var r_pen: float = float(sdef.get("realm_pen", 0.15))
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var burn_val: float = dmg * float(f_def.get("burn_dps_ratio", 0.10)) * PlayerData.get_flame_dmg_multiplier() if not f_def.is_empty() else 0.0
	var spark_col: Color = Color(str(f_def.get("mid_hex", "#FF9F1C"))) if not f_def.is_empty() else Color("#FFE599")
	var aim_target: Vector2 = get_global_mouse_position()
	var aim_dir: Vector2 = (aim_target - global_position).normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.RIGHT

	if behavior == "pull_pulse":
		burst_ring_radius = rad_px
		burst_ring_color = Color("#70D6FF")
		burst_ring_timer = 0.28
		EventBus.audio_sfx_requested.emit("skill_burst")
		var pull_spot: Vector2 = global_position + aim_dir * 68.0
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "HẤP CHƯỞNG!", Color("#70D6FF"))
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= rad_px:
					var to_spot: Vector2 = (pull_spot - enemy_node.global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, to_spot * absf(kb), r_pen, burn_val)
						_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#70D6FF"))

	elif behavior == "melee_burst":
		_trigger_skill_attack_pose(aim_dir)
		lunge_vel = aim_dir * 340.0
		burst_ring_radius = rad_px
		burst_ring_color = spark_col
		burst_ring_timer = 0.28
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(6.5, 0.18)
		var sk_title: String = str(sdef.get("name", "Đấu Kỹ")).to_upper() + "!"
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), sk_title, Color("#FF9F1C"))
		var hit_center: Vector2 = global_position + aim_dir * 52.0
		_spawn_hit_sparks(hit_center + Vector2(0, -20), spark_col)
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if hit_center.distance_to(enemy_node.global_position) <= rad_px:
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, aim_dir * kb, r_pen, burn_val)

	elif behavior == "flame_dash":
		# BẠO BỘ: Nổ khí dưới chân lao vọt đi & đốt kẻ địch dọc đường!
		dash_dir = aim_dir
		dash_timer = 0.22
		invuln_timer = 0.35
		burst_ring_radius = rad_px
		burst_ring_color = Color("#FF9F1C")
		burst_ring_timer = 0.28
		_spawn_dash_afterimage()
		_spawn_hit_sparks(global_position, Color("#FF9F1C"))
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "BẠO BỘ!", Color("#FF9F1C"))
		var burst_pt: Vector2 = global_position + aim_dir * 75.0
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if enemy_node.global_position.distance_to(global_position) <= rad_px or enemy_node.global_position.distance_to(burst_pt) <= rad_px:
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, aim_dir * kb, r_pen, burn_val)

	elif behavior == "sonic_stun":
		# SƯ TỬ NGÂM: Sóng âm vàng kim làm CHOÁNG mọi quái xung quanh 1.8 giây!
		burst_ring_radius = rad_px
		burst_ring_color = Color("#FFD166")
		burst_ring_timer = 0.36
		var stun_s: float = float(sdef.get("stun_sec", 1.8))
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.screen_shake_requested.emit(7.0, 0.22)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "SƯ TỬ NGÂM!", Color("#FFD166"))
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, 0.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_s)

	elif behavior == "flame_shield":
		# LỤC HỢP DU THÂN XÍCH: Xoay 360° hất tung mọi kẻ địch + miễn thương 1.2 giây!
		_trigger_skill_attack_pose(aim_dir)
		invuln_timer = maxf(invuln_timer, 1.25)
		burst_ring_radius = rad_px
		burst_ring_color = spark_col
		burst_ring_timer = 0.42
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(7.0, 0.20)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "LỤC HỢP DU THÂN XÍCH! (MIỄN THƯƠNG)", Color("#FF9F1C"))
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val)
						_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), spark_col)

	elif behavior == "wing_cyclone":
		# TỬ VÂN DỰC KÍCH: Bay lướt kèm lốc xoáy tím càn quét!
		_trigger_skill_attack_pose(aim_dir)
		lunge_vel = aim_dir * 480.0
		invuln_timer = maxf(invuln_timer, 0.45)
		burst_ring_radius = rad_px
		burst_ring_color = Color("#C77DFF")
		burst_ring_timer = 0.34
		EventBus.audio_sfx_requested.emit("dash_whoosh")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(6.5, 0.18)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "TỬ VÂN DỰC KÍCH!", Color("#C77DFF"))
		var cyc_center: Vector2 = global_position + aim_dir * 68.0
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if cyc_center.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val)
						_spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#C77DFF"))

	elif behavior == "flame_buff":
		# THIÊN HỎA TAM HUYỀN BIẾN: Bộc phát sóng lửa đẩy lùi địch + Tăng +45% ATK & +20% SPD trong 10s!
		PlayerData.is_flame_buff_active = true
		flame_buff_timer = float(sdef.get("buff_duration", 10.0))
		_refresh_flame_shader()
		EventBus.stats_changed.emit()
		burst_ring_radius = rad_px
		burst_ring_color = Color("#FF4D6D")
		burst_ring_timer = 0.45
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.screen_shake_requested.emit(8.0, 0.25)
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -82), "THIÊN HỎA TAM HUYỀN BIẾN! (+45% ATK)", Color("#FF4D6D"))
		for en in get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val)

	elif behavior == "flame_wave" or behavior == "fire_lotus_ult":
		if behavior == "flame_wave":
			_trigger_skill_attack_pose(aim_dir)
		EventBus.audio_sfx_requested.emit("skill_fire")
		var packed: PackedScene = load(SKILL_SCENE_PATH)
		if packed != null and get_parent() != null:
			var proj: Area2D = packed.instantiate() as Area2D
			get_parent().add_child(proj)
			var spd: float = float(sdef.get("projectile_speed", 460.0))
			var use_flame: Dictionary = f_def if not f_def.is_empty() else GameDatabase.get_flame_def("pham_hoa")
			var fusion_bonus: float = 1.0 + float(max(0, PlayerData.lotus_fusion_flames.size() - 1)) * 0.28 if behavior == "fire_lotus_ult" else 1.0
			if proj.has_method("configure_skill"):
				proj.configure_skill(behavior, global_position + aim_dir * 36.0 + Vector2(0, -24), aim_target, dmg * fusion_bonus, kb, r_pen, rad_px, spd, use_flame)


func _activate_duoc_lao_assist() -> void:
	if not PlayerData.duoc_lao_assist_unlocked:
		EventBus.floating_text_requested.emit(global_position + Vector2(0, -72), "Chưa mở Cốt Linh Phụ Thể [T]!", Color("#ADB5BD"))
		EventBus.banter_triggered.emit("Gợi ý cốt truyện: Hoàn thành trận diệt Gia Liệt Áo (cuối Chương 01) để mở khóa Cốt Linh Phụ Thể [T]!")
		return
	if float(skill_cooldowns.get("T", 0.0)) > 0.0:
		return
	PlayerData.is_duoc_lao_active = true
	duoc_lao_timer = 12.0
	skill_cooldowns["T"] = 45.0
	skill_cooldown_totals["T"] = 45.0
	EventBus.skill_cooldown_updated.emit("T", 45.0, 45.0)
	_refresh_flame_shader()
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.stats_changed.emit()
	EventBus.screen_shake_requested.emit(8.5, 0.28)
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -78), "CỐT LINH PHỤ THỂ!", Color("#A8DADC"))
	EventBus.banter_triggered.emit("Dược Lão: 'Giao thân thể cho vi sư! Để chúng chiêm ngưỡng uy lực Cốt Linh Lãnh Hỏa!'")


func take_enemy_damage(raw_dmg: float, attacker_realm_idx: int, push_vec: Vector2) -> void:
	if invuln_timer > 0.0:
		return
	var realm_diff: int = max(0, attacker_realm_idx - PlayerData.realm_index)
	var suppression_bonus: float = 1.0 + float(realm_diff) * 0.25
	var raw_after_def: float = maxf(1.0, (raw_dmg * suppression_bonus) - PlayerData.get_def() * 0.45)
	# Đấu Khí Sa Y của Đấu Sư (realm >= 3): giảm 18% sát thương khi còn > 25% Đấu Khí!
	var sa_y_mult: float = 0.82 if (PlayerData.realm_index >= 3 and PlayerData.current_qi > PlayerData.get_max_qi() * 0.25) else 1.0
	var final_dmg: float = maxf(1.0, raw_after_def * sa_y_mult)

	PlayerData.current_hp = maxf(0.0, PlayerData.current_hp - final_dmg)
	invuln_timer = 0.35
	knockback_vel = push_vec
	EventBus.audio_sfx_requested.emit("player_hurt")
	EventBus.screen_shake_requested.emit(5.0, 0.14)
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -64), "-%d" % int(round(final_dmg)), Color("#FF4D6D"))
	EventBus.stats_changed.emit()

	if PlayerData.current_hp <= 0.0:
		PlayerData.recalculate_and_clamp(true)
		var m_def: Dictionary = GameDatabase.get_map_def(PlayerData.current_map_id)
		var sp: Array = m_def.get("default_spawn", [340, 520])
		global_position = Vector2(float(sp[0]), float(sp[1]))
		EventBus.stats_changed.emit()
		EventBus.banter_triggered.emit("Tiêu Viêm bị trọng thương, vội lui về điểm an toàn điều tức hồi phục!")


func _on_screen_shake(strength: float, duration: float) -> void:
	shake_strength = maxf(shake_strength, strength)
	shake_timer = maxf(shake_timer, duration)


func _draw() -> void:
	draw_set_transform(Vector2(0, 12), 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 28.0, Color(0.03, 0.02, 0.06, 0.50))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var f_def: Dictionary = PlayerData.get_active_flame_def()
	if not f_def.is_empty() or PlayerData.realm_index >= 2 or PlayerData.is_flame_buff_active:
		var aura_col: Color = Color("#FF4D6D") if PlayerData.is_flame_buff_active else (Color(str(f_def.get("mid_hex", "#FFE599"))) if not f_def.is_empty() else Color("#FFE599"))
		aura_col.a = 0.58 if (PlayerData.is_duoc_lao_active or PlayerData.is_flame_buff_active) else 0.28
		draw_arc(Vector2(0, 12), 34.0, 0.0, TAU, 36, aura_col, 2.8)
	# Vòng sáng Đấu Khí Sa Y hộ thân (Đấu Sư trở lên!)
	if PlayerData.realm_index >= 3:
		var sy_col: Color = Color(0.78, 0.48, 1.0, 0.42)
		draw_arc(Vector2(0, -24), 34.0, 0.0, TAU, 36, sy_col, 2.2)

	if burst_ring_timer > 0.0:
		var ring_c: Color = burst_ring_color
		ring_c.a = clampf(burst_ring_timer * 2.8, 0.0, 0.92)
		draw_arc(Vector2(0, -16), burst_ring_radius, 0.0, TAU, 44, ring_c, 3.8)

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
