extends CharacterBody2D
## Điều khiển Quái vật & Boss Đa Phase Mượt 60 FPS (Hướng A + Hướng B):
## - Hỗ trợ cả Sprite Sheet 4 khung hình động (0: Idle, 1: Stride/Dash, 2: Windup, 3: Strike/Cast) cho 8 Boss chính
##   lẫn hoạt ảnh động học mượt (Foot-anchored Pivot, Squash & Stretch, Lerp Quán Tính, Tàn Ảnh, Chém VFX, Hit-Squash, Tan Biến) cho toàn bộ 20 Quái & Boss!

@export var enemy_id: String = "moc_nhan"

const LOOT_SCENE_PATH: String = "res://scenes/entities/loot_pickup.tscn"
const ENEMY_PROJ_SCENE_PATH: String = "res://scenes/entities/enemy_projectile.tscn"

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

# Động học mượt 60 FPS & Bộ điều khiển Sprite 4 khung hình
var has_anim_sheet: bool = false
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


func configure_enemy(new_enemy_id: String, world_pos: Vector2) -> void:
	enemy_id = new_enemy_id
	global_position = world_pos
	spawn_origin = world_pos
	boss_phase = 1
	boss_bar_shown = false
	is_dying = false
	if is_inside_tree():
		_load_from_db()


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
	is_floating_unit = (enemy_id == "hai_ba_dong_boss" or enemy_id == "co_ha_boss" or enemy_id == "tieu_tu_tinh_su_boss")

	base_scale_val = 1.18 if is_boss_unit else 1.0
	visual_scale = Vector2(base_scale_val, base_scale_val)

	# Ưu tiên nạp Sprite Sheet 4 khung hình (Hướng B) nếu Boss có khai báo anim_sheet!
	var anim_sheet_path: String = str(edef.get("anim_sheet", ""))
	var sprite_path: String = str(edef.get("sprite", ""))
	if body_sprite != null:
		var loaded_anim: Texture2D = null
		if anim_sheet_path != "" and ResourceLoader.exists(anim_sheet_path):
			loaded_anim = load(anim_sheet_path)
		if loaded_anim != null:
			has_anim_sheet = true
			body_sprite.texture = loaded_anim
			body_sprite.hframes = 4
			body_sprite.vframes = 1
			body_sprite.frame = 0
			sprite_offset_y = -float(loaded_anim.get_height()) * 0.46
		elif sprite_path != "":
			has_anim_sheet = false
			var tex: Texture2D = load(sprite_path)
			if tex != null:
				body_sprite.texture = tex
				body_sprite.hframes = 1
				body_sprite.vframes = 1
				body_sprite.frame = 0
				sprite_offset_y = -float(tex.get_height()) * 0.46

		# Neo tâm xoay & co giãn (Pivot) tại bàn chân (y = +8) giúp chân bám chặt mặt đất!
		body_sprite.centered = true
		body_sprite.offset = Vector2(0.0, sprite_offset_y)
		body_sprite.position = Vector2(0.0, base_sprite_foot_y)
		body_sprite.scale = visual_scale

		if is_boss_unit:
			if boss_light == null:
				boss_light = PointLight2D.new()
				boss_light.texture = load("res://assets/sprites/vfx/light_radial_128.png")
				boss_light.texture_scale = 2.6
				boss_light.energy = 1.10
				boss_light.color = _get_signature_color()
				boss_light.position = Vector2(0, -32)
				add_child(boss_light)


func _get_signature_color() -> Color:
	if enemy_id == "muc_xa_boss" or enemy_id == "tieu_tu_tinh_su_boss":
		return Color("#C77DFF")
	elif enemy_id == "lieu_tich_boss" or enemy_id == "mac_ba_tu_boss":
		return Color("#52B788")
	elif enemy_id == "thach_khoi_boss" or enemy_id == "hai_ba_dong_boss" or enemy_id == "tieu_ninh_boss":
		return Color("#4CC9F0")
	elif enemy_id == "hoa_linh_xa_boss" or enemy_id == "co_ha_boss":
		return Color("#FF7B00")
	return Color("#FF4D6D")


func _physics_process(delta: float) -> void:
	if is_dying:
		queue_redraw()
		return

	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
		if hit_flash_timer > 0.0:
			body_sprite.modulate = Color(2.8, 2.8, 2.8, 1.0)
		else:
			body_sprite.modulate = Color(1.16, 0.86, 0.90, 1.0) if (is_boss_unit and boss_phase >= 2) else Color.WHITE

	if hit_squash > 0.0:
		hit_squash = maxf(0.0, hit_squash - delta * 6.5)
	if attack_cd > 0.0:
		attack_cd -= delta
	if stun_timer > 0.0:
		stun_timer -= delta
	if strike_hold_timer > 0.0:
		strike_hold_timer -= delta
	if strike_vfx_timer > 0.0:
		strike_vfx_timer -= delta

	_process_burn_dot(delta)
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
	var target_frame: int = 0

	var is_winding: bool = (state_phase == "windup" or state_phase == "boss_nova" or state_phase == "boss_wave_windup")

	if strike_hold_timer > 0.0:
		# Pha TUNG ĐÒN: Khung hình 3 + Nhào người (Overshoot) + Giãn ngang sắc bén!
		target_frame = 3
		var k_st: float = clampf(strike_hold_timer / 0.28, 0.0, 1.0)
		target_scale = Vector2(base_sc * (1.0 + 0.14 * k_st), base_sc * (1.0 - 0.10 * k_st))
		target_rot = face_sign * 0.14 * k_st
		target_off = strike_dir * (16.0 * k_st)

	elif state_phase == "charging":
		# Pha LAO HÚC: Khung hình 1 + Kéo giãn theo tốc độ + Tàn ảnh mờ nối đuôi!
		target_frame = 1
		target_scale = Vector2(base_sc * 1.15, base_sc * 0.87)
		target_rot = face_sign * 0.17
		target_off = Vector2(0.0, -4.0)
		afterimage_timer -= delta
		if afterimage_timer <= 0.0:
			afterimage_timer = 0.055
			_spawn_afterimage()

	elif is_winding:
		# Pha GỒNG CHIÊU (Anticipation): Khung hình 2 + Co nén lùi lại + Rung tích tụ linh khí!
		target_frame = 2
		var prog: float = 1.0 - clampf(state_timer / maxf(0.1, state_duration), 0.0, 1.0)
		var tremor: float = sin(float(Time.get_ticks_msec()) * 0.055) * (2.6 * prog)
		target_scale = Vector2(base_sc * (1.0 + 0.12 * prog), base_sc * (1.0 - 0.14 * prog))
		target_rot = -face_sign * (0.11 * prog)
		target_off = Vector2(-face_sign * 7.0 * prog + tremor, 2.0 * prog)

		if boss_light != null:
			boss_light.energy = lerpf(boss_light.energy, 1.95 if boss_phase >= 2 else 1.55, minf(1.0, delta * 10.0))

		gather_spark_timer -= delta
		if gather_spark_timer <= 0.0:
			gather_spark_timer = 0.12
			_spawn_gather_sparks()

	elif moving:
		# Pha DI CHUYỂN: Lướt/bước nhịp nhàng, nghiêng thân theo đà & nhún giãn mềm mại!
		anim_phase += delta * clampf(spd * 0.068, 6.5, 13.5)
		if has_anim_sheet:
			target_frame = 1 if sin(anim_phase) >= 0.0 else 0
		var hop: float = absf(sin(anim_phase))
		var tilt: float = clampf(smooth_vel.x / maxf(80.0, move_spd), -1.0, 1.0) * 0.09
		target_scale = Vector2(base_sc * (1.0 - 0.045 * hop), base_sc * (1.0 + 0.055 * hop))
		target_rot = tilt + sin(anim_phase) * 0.035
		target_off = Vector2(0.0, -hop * (6.5 if is_boss_unit else 5.0))
		if is_floating_unit:
			target_off.y -= 5.0 + sin(anim_phase * 0.7) * 3.0

	else:
		# Pha ĐỨNG THỦ (Idle): Thở nhịp êm ái neo chắc bàn chân trên mặt đất!
		anim_phase += delta * 3.0
		target_frame = 0
		var br: float = sin(anim_phase) * 0.032
		target_scale = Vector2(base_sc * (1.0 - br * 0.6), base_sc * (1.0 + br))
		target_rot = sin(anim_phase * 0.5) * 0.015
		if is_floating_unit:
			target_off = Vector2(0.0, -5.0 + sin(anim_phase * 1.1) * 4.5)

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
		body_sprite.frame = clampi(target_frame, 0, 3)

	if boss_light != null and not is_winding:
		var rest_e: float = 1.60 if boss_phase >= 2 else 1.10
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
	var sig: Color = _get_signature_color()
	ghost.modulate = Color(sig.r, sig.g, sig.b, 0.52)
	get_parent().add_child(ghost)
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.24)
	tw.tween_callback(ghost.queue_free)


func _spawn_gather_sparks() -> void:
	if get_parent() == null:
		return
	var p := CPUParticles2D.new()
	p.global_position = global_position + Vector2(0, -32)
	p.one_shot = true
	p.explosiveness = 0.75
	p.amount = 6
	p.lifetime = 0.28
	p.spread = 180.0
	p.gravity = Vector2(0, -35)
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 75.0
	p.scale_amount_min = 2.5
	p.scale_amount_max = 4.5
	p.color = _get_signature_color()
	get_parent().add_child(p)
	p.emitting = true
	get_tree().create_timer(0.38).timeout.connect(p.queue_free)


func _sync_boss_hud_bar(player_node: Node2D) -> void:
	var dist: float = global_position.distance_to(player_node.global_position)
	if dist <= 560.0 or cur_hp < max_hp:
		if not boss_bar_shown:
			boss_bar_shown = true
			EventBus.bgm_requested.emit("bgm_boss")
		EventBus.boss_status_updated.emit(display_title, realm_badge, cur_hp, max_hp, boss_phase, true)
	elif boss_bar_shown and dist > 720.0:
		boss_bar_shown = false
		EventBus.boss_status_updated.emit("", "", 0.0, 1.0, 1, false)
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
	body_sprite.modulate = Color(1.16, 0.86, 0.90, 1.0)
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

	EventBus.floating_text_requested.emit(global_position + Vector2(0, -108), "GIAI ĐOẠN II — CUỒNG BẠO!", Color("#FF4D6D"))
	EventBus.banter_triggered.emit("[%s]: '%s' (Cẩn thận 3 tia sóng Đấu Khí — bấm Space để lướt né!)" % [display_title, cry])
	EventBus.boss_status_updated.emit(display_title, realm_badge, cur_hp, max_hp, boss_phase, true)


func _compute_ai_velocity(delta: float, player_node: Node2D) -> Vector2:
	if ai_mode == "dummy":
		return Vector2.ZERO

	var to_player: Vector2 = player_node.global_position - global_position
	var dist: float = to_player.length()
	# Thêm deadzone 14px chống lỗi nhấp nháy lật trái-phải liên tục khi đứng cùng trục X!
	if absf(to_player.x) > 14.0 and state_phase == "idle":
		body_sprite.flip_h = to_player.x < 0.0

	if ai_mode == "chaser":
		if dist <= detect_radius and dist > 44.0:
			return to_player.normalized() * move_spd
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
				return to_player.normalized() * move_spd
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
			return charge_dir * (move_spd * 3.1)

	elif ai_mode == "boss_duelist":
		var p2_spd: float = 1.22 if boss_phase >= 2 else 1.0
		var p2_cd_mult: float = 0.78 if boss_phase >= 2 else 1.0
		if state_phase == "idle":
			if boss_phase >= 2 and dist <= 420.0 and dist > 125.0 and attack_cd <= 0.0 and randf() < 0.55:
				state_phase = "boss_wave_windup"
				state_duration = 0.58
				state_timer = state_duration
				wave_aim_dir = to_player.normalized()
				if absf(wave_aim_dir.x) > 0.08:
					body_sprite.flip_h = wave_aim_dir.x < 0.0
				return Vector2.ZERO
			elif dist <= 122.0 and attack_cd <= 0.0:
				state_phase = "boss_nova"
				state_duration = 0.56 if boss_phase >= 2 else 0.64
				state_timer = state_duration
				return Vector2.ZERO
			elif dist <= attack_radius and dist > 122.0 and attack_cd <= 0.0:
				state_phase = "windup"
				state_duration = 0.46 if boss_phase >= 2 else 0.54
				state_timer = state_duration
				charge_dir = to_player.normalized()
				if absf(charge_dir.x) > 0.08:
					body_sprite.flip_h = charge_dir.x < 0.0
				return Vector2.ZERO
			elif dist <= detect_radius:
				return to_player.normalized() * (move_spd * p2_spd)
		elif state_phase == "windup":
			state_timer -= delta
			if state_timer <= 0.0:
				state_phase = "charging"
				state_duration = 0.36
				state_timer = state_duration
				afterimage_timer = 0.0
			return Vector2.ZERO
		elif state_phase == "charging":
			state_timer -= delta
			if dist <= 64.0 and attack_cd <= 0.0:
				_deal_melee_hit(player_node, 1.40 if boss_phase >= 2 else 1.30)
				attack_cd = 1.35 * p2_cd_mult
			if state_timer <= 0.0:
				state_phase = "idle"
				attack_cd = 1.35 * p2_cd_mult
			return charge_dir * (move_spd * 3.0 * p2_spd)
		elif state_phase == "boss_nova":
			state_timer -= delta
			if state_timer <= 0.0:
				var nova_r: float = 152.0 if boss_phase >= 2 else 135.0
				strike_hold_timer = 0.30
				strike_dir = to_player.normalized() if dist > 4.0 else Vector2.RIGHT
				strike_vfx_timer = 0.28
				strike_vfx_radius = nova_r
				strike_vfx_is_nova = true
				strike_vfx_color = _get_signature_color()
				if dist <= nova_r:
					_deal_melee_hit(player_node, 1.65 if boss_phase >= 2 else 1.50, false)
				EventBus.audio_sfx_requested.emit("skill_burst")
				EventBus.screen_shake_requested.emit(7.5, 0.22)
				state_phase = "idle"
				attack_cd = 1.85 * p2_cd_mult
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
				state_phase = "idle"
				attack_cd = 2.1 * p2_cd_mult
			return Vector2.ZERO

	return Vector2.ZERO


func _fire_boss_triple_wave() -> void:
	var packed: PackedScene = load(ENEMY_PROJ_SCENE_PATH)
	if packed == null or get_parent() == null:
		return
	EventBus.audio_sfx_requested.emit("skill_fire")
	var wave_col: Color = _get_signature_color()
	var angles: Array = [-0.28, 0.0, 0.28]
	for ang_off in angles:
		var proj: Area2D = packed.instantiate() as Area2D
		get_parent().add_child(proj)
		var dir_v: Vector2 = wave_aim_dir.rotated(float(ang_off))
		if proj.has_method("configure_projectile"):
			proj.configure_projectile(global_position + Vector2(0, -20), dir_v, 360.0, atk_stat * 1.15, realm_idx, wave_col)


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
	if player_node.has_method("take_enemy_damage"):
		var raw_dmg: float = atk_stat * mult
		player_node.take_enemy_damage(raw_dmg, realm_idx, push_dir * 260.0)


func apply_stun(duration: float) -> void:
	if ai_mode == "dummy" or is_dying:
		return
	var resist: float = 0.55 if is_boss_unit else 1.0
	stun_timer = maxf(stun_timer, duration * resist)
	state_phase = "idle"
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -86), "CHOÁNG!", Color("#FFD166"))


func receive_hit(raw_atk_dmg: float, kb_vec: Vector2, skill_realm_pen: float = 0.0, apply_burn_dps: float = 0.0) -> void:
	if is_dying:
		return
	var realm_mult: float = PlayerData.compute_realm_damage_multiplier_against(realm_idx, skill_realm_pen)
	var reduced: float = maxf(1.0, (raw_atk_dmg - def_stat * 0.45) * realm_mult)

	var is_crit: bool = randf() < PlayerData.get_crit_chance()
	if is_crit:
		reduced *= 1.65

	cur_hp -= reduced
	PlayerData.heal_from_lifesteal(reduced)
	hit_flash_timer = 0.11
	hit_squash = 1.0
	EventBus.audio_sfx_requested.emit("hit_crit" if is_crit else "hit_impact")

	if ai_mode != "dummy":
		var kb_resist: float = 0.38 if is_boss_unit else 1.0
		knockback_vel = kb_vec * kb_resist
	else:
		body_sprite.rotation = randf_range(-0.20, 0.20)
		var tw := create_tween()
		tw.tween_property(body_sprite, "rotation", 0.0, 0.16)

	if apply_burn_dps > 0.0:
		burn_dps_val = maxf(burn_dps_val, apply_burn_dps)
		burn_remaining = 3.0

	var col: Color = Color("#FFD166") if is_crit else Color("#FFFFFF")
	var txt: String = "%d!" % int(round(reduced)) if is_crit else "%d" % int(round(reduced))
	if realm_mult < 0.85:
		txt += " (Áp Chế)"
		col = Color("#ADB5BD")
	EventBus.floating_text_requested.emit(global_position + Vector2(randf_range(-16, 16), -68), txt, col)

	if is_boss_unit and boss_phase == 1 and cur_hp > 0.0 and cur_hp <= max_hp * 0.55:
		_trigger_boss_phase_2()

	if is_boss_unit and boss_bar_shown:
		EventBus.boss_status_updated.emit(display_title, realm_badge, maxf(0.0, cur_hp), max_hp, boss_phase, true)

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
		if is_boss_unit and boss_phase == 1 and cur_hp > 0.0 and cur_hp <= max_hp * 0.55:
			_trigger_boss_phase_2()
		if cur_hp <= 0.0:
			_die()


func _die() -> void:
	if is_dying:
		return
	is_dying = true
	remove_from_group("enemies")
	set_collision_layer(0)
	set_collision_mask(0)

	if is_boss_unit and boss_bar_shown:
		boss_bar_shown = false
		EventBus.boss_status_updated.emit("", "", 0.0, 1.0, 1, false)
		_request_restore_map_bgm()

	if get_parent() != null:
		var f_def: Dictionary = PlayerData.get_active_flame_def()
		var p := CPUParticles2D.new()
		p.global_position = global_position + Vector2(0, -24)
		p.one_shot = true
		p.explosiveness = 1.0
		p.amount = 34 if is_boss_unit else 16
		p.lifetime = 0.55
		p.spread = 180.0
		p.gravity = Vector2(0, -30)
		p.initial_velocity_min = 70.0
		p.initial_velocity_max = 190.0
		p.scale_amount_min = 3.0
		p.scale_amount_max = 6.0
		p.color = Color(str(f_def.get("mid_hex", "#FF7B00"))) if not f_def.is_empty() else _get_signature_color()
		get_parent().add_child(p)
		p.emitting = true
		get_tree().create_timer(0.70).timeout.connect(p.queue_free)

	var loot_packed: PackedScene = load(LOOT_SCENE_PATH)
	if loot_packed != null and get_parent() != null:
		var orb: Area2D = loot_packed.instantiate() as Area2D
		orb.global_position = global_position
		if orb.has_method("setup_exp_orb"):
			orb.setup_exp_orb(exp_reward)
		get_parent().call_deferred("add_child", orb)

		if gold_reward > 0:
			var g_orb: Area2D = loot_packed.instantiate() as Area2D
			g_orb.global_position = global_position
			if g_orb.has_method("setup_gold_drop"):
				g_orb.setup_gold_drop(gold_reward)
			get_parent().call_deferred("add_child", g_orb)

		if gear_pool.size() > 0 and randf() <= gear_drop_chance:
			var pick_tpl: String = str(gear_pool[randi() % gear_pool.size()])
			var forced_rar: String = ""
			if allowed_rarities.size() > 0:
				forced_rar = str(allowed_rarities[randi() % allowed_rarities.size()])
			var rolled_gear: Dictionary = EquipmentSystem.roll_equipment_instance(pick_tpl, forced_rar)
			if not rolled_gear.is_empty():
				var eq_drop: Area2D = loot_packed.instantiate() as Area2D
				eq_drop.global_position = global_position
				if eq_drop.has_method("setup_gear_drop"):
					eq_drop.setup_gear_drop(rolled_gear)
				get_parent().call_deferred("add_child", eq_drop)

		for entry in drop_table:
			if entry is Dictionary:
				var chance: float = float(entry.get("chance", 0.3))
				if randf() <= chance:
					var drop_node: Area2D = loot_packed.instantiate() as Area2D
					drop_node.global_position = global_position
					if drop_node.has_method("setup_item_drop"):
						drop_node.setup_item_drop(str(entry.get("item_id", "")), 1)
					get_parent().call_deferred("add_child", drop_node)

	EventBus.enemy_killed.emit(enemy_id, is_boss_unit)

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

	if is_boss_unit and boss_phase >= 2:
		var pulse_r: float = 42.0 + sin(float(Time.get_ticks_msec()) * 0.008) * 3.5
		draw_arc(Vector2(0, 12), pulse_r, 0.0, TAU, 36, Color(1.0, 0.22, 0.38, 0.65), 3.0)

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
