extends Area2D
## Thực thể Kỹ năng Đấu Kỹ bay trên bản đồ HD (1280x720):
## - Diễm Phân Phệ Lãng Xích & Phật Nộ Hỏa Liên kích thước hoành tráng kèm Đèn 2D & Hạt Lửa!

var behavior_mode: String = "flame_wave"
var move_dir: Vector2 = Vector2.RIGHT
var speed_px: float = 480.0
var damage_amount: float = 35.0
var knockback_force: float = 340.0
var realm_pen: float = 0.25
var explosion_radius: float = 210.0
var burn_dps: float = 8.0

var lifetime: float = 1.4
var elapsed: float = 0.0
var lotus_detonated: bool = false
var target_point: Vector2 = Vector2.ZERO
var hit_enemies: Dictionary = {}

var glow_light: PointLight2D
var trail_particles: CPUParticles2D

@onready var visual_sprite: Sprite2D = $Sprite2D


func configure_skill(
	mode_str: String,
	origin: Vector2,
	aim_target: Vector2,
	dmg: float,
	kb: float,
	r_pen: float,
	rad_px: float,
	spd: float,
	flame_def: Dictionary
) -> void:
	behavior_mode = mode_str
	global_position = origin
	target_point = aim_target
	move_dir = (aim_target - origin).normalized()
	if move_dir == Vector2.ZERO:
		move_dir = Vector2.RIGHT
	damage_amount = dmg
	knockback_force = kb
	realm_pen = r_pen
	explosion_radius = rad_px
	speed_px = spd
	burn_dps = dmg * float(flame_def.get("burn_dps_ratio", 0.15))

	if behavior_mode == "fire_lotus_ult":
		lifetime = 1.60
	else:
		lifetime = 0.95
		rotation = move_dir.angle()

	call_deferred("_apply_flame_visuals", flame_def)


func _apply_flame_visuals(flame_def: Dictionary) -> void:
	if visual_sprite == null:
		return
	var core_c := Color(str(flame_def.get("core_hex", "#FFF3B0")))
	var mid_c := Color(str(flame_def.get("mid_hex", "#FF7B00")))
	var outer_c := Color(str(flame_def.get("outer_hex", "#9E2A2B")))

	if behavior_mode == "fire_lotus_ult":
		visual_sprite.texture = load("res://assets/sprites/vfx/fire_lotus.png")
		visual_sprite.scale = Vector2(1.8, 1.8)
	else:
		visual_sprite.texture = load("res://assets/sprites/vfx/slash_arc.png")
		visual_sprite.scale = Vector2(2.2, 2.2)

	var shader_res: Shader = load("res://assets/shaders/di_hoa_palette.gdshader")
	var mat := ShaderMaterial.new()
	mat.shader = shader_res
	mat.set_shader_parameter("core_color", core_c)
	mat.set_shader_parameter("mid_color", mid_c)
	mat.set_shader_parameter("outer_color", outer_c)
	mat.set_shader_parameter("intensity", 1.85)
	visual_sprite.material = mat

	glow_light = PointLight2D.new()
	glow_light.texture = load("res://assets/sprites/vfx/light_radial_128.png")
	glow_light.texture_scale = 3.8 if behavior_mode == "fire_lotus_ult" else 2.8
	glow_light.energy = 1.75
	glow_light.color = mid_c.lerp(core_c, 0.35)
	add_child(glow_light)

	trail_particles = CPUParticles2D.new()
	trail_particles.emitting = true
	trail_particles.amount = 32
	trail_particles.lifetime = 0.45
	trail_particles.spread = 180.0
	trail_particles.gravity = Vector2(0, -24)
	trail_particles.initial_velocity_min = 35.0
	trail_particles.initial_velocity_max = 110.0
	trail_particles.scale_amount_min = 3.0
	trail_particles.scale_amount_max = 6.0
	trail_particles.color = core_c.lerp(mid_c, 0.5)
	add_child(trail_particles)


func _physics_process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

	if behavior_mode == "flame_wave":
		global_position += move_dir * speed_px * delta
		_check_wave_hits()
		if elapsed >= lifetime:
			queue_free()
	elif behavior_mode == "fire_lotus_ult":
		visual_sprite.rotation += 10.5 * delta
		if global_position.distance_to(target_point) > 16.0 and elapsed < 0.55:
			global_position = global_position.move_toward(target_point, speed_px * delta)
		else:
			_pull_enemies_toward_lotus(delta)
			var pulse: float = 1.9 + sin(elapsed * 26.0) * 0.45
			visual_sprite.scale = Vector2(pulse, pulse)

		if elapsed >= 1.15 and not lotus_detonated:
			_detonate_fire_lotus()

		if elapsed >= lifetime:
			queue_free()


func _check_wave_hits() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for en in enemies:
		if not is_instance_valid(en):
			continue
		var enemy_node: Node2D = en as Node2D
		if enemy_node == null or hit_enemies.has(enemy_node.get_instance_id()):
			continue
		if global_position.distance_to(enemy_node.global_position) <= explosion_radius:
			hit_enemies[enemy_node.get_instance_id()] = true
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(damage_amount, move_dir * knockback_force, realm_pen, burn_dps)


func _pull_enemies_toward_lotus(delta: float) -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for en in enemies:
		if not is_instance_valid(en):
			continue
		var enemy_node: Node2D = en as Node2D
		if enemy_node == null:
			continue
		var dist: float = global_position.distance_to(enemy_node.global_position)
		if dist <= explosion_radius * 1.25 and dist > 16.0:
			var pull_dir: Vector2 = (global_position - enemy_node.global_position).normalized()
			enemy_node.global_position += pull_dir * 185.0 * delta


func _detonate_fire_lotus() -> void:
	lotus_detonated = true
	visual_sprite.scale = Vector2(4.4, 4.4)
	if glow_light != null:
		glow_light.texture_scale = 7.2
		glow_light.energy = 2.8
	if trail_particles != null:
		trail_particles.amount = 64
		trail_particles.initial_velocity_max = 280.0
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.audio_sfx_requested.emit("skill_burst")
	EventBus.screen_shake_requested.emit(13.5, 0.42)
	var f_cnt: int = max(1, PlayerData.lotus_fusion_flames.size())
	var lotus_cry: String = "PHẬT NỘ HỎA LIÊN (%d HỎA DUNG HỢP)!" % f_cnt if f_cnt >= 2 else "PHẬT NỘ HỎA LIÊN!"
	EventBus.floating_text_requested.emit(global_position + Vector2(0, -52), lotus_cry, Color("#FFD166"))

	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	for en in enemies:
		if not is_instance_valid(en):
			continue
		var enemy_node: Node2D = en as Node2D
		if enemy_node == null:
			continue
		if global_position.distance_to(enemy_node.global_position) <= explosion_radius:
			var out_dir: Vector2 = (enemy_node.global_position - global_position).normalized()
			if out_dir == Vector2.ZERO:
				out_dir = Vector2.RIGHT
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(damage_amount, out_dir * knockback_force, realm_pen, burn_dps * 1.5)


func _draw() -> void:
	if behavior_mode == "fire_lotus_ult":
		var f_list: Array = PlayerData.lotus_fusion_flames
		var c1 := Color("#2EC4B6")
		var c2 := Color("#9D4EDD")
		if f_list.size() >= 1:
			c1 = Color(str(GameDatabase.get_flame_def(str(f_list[0])).get("mid_hex", "#2EC4B6")))
		if f_list.size() >= 2:
			c2 = Color(str(GameDatabase.get_flame_def(str(f_list[1])).get("mid_hex", "#9D4EDD")))
		else:
			var f_def: Dictionary = PlayerData.get_active_flame_def()
			c1 = Color(str(f_def.get("mid_hex", "#2EC4B6")))
			c2 = Color(str(f_def.get("core_hex", "#FFD166")))

		var alpha_v: float = 0.52 if not lotus_detonated else 0.92
		# Vòng ngoài Song Hỏa xoay ngược chiều cực kỳ hoành tráng!
		draw_arc(Vector2.ZERO, explosion_radius, elapsed * 3.0, elapsed * 3.0 + TAU * 0.85, 52, Color(c1.r, c1.g, c1.b, alpha_v), 4.2)
		draw_arc(Vector2.ZERO, explosion_radius * 0.72, -elapsed * 4.5, -elapsed * 4.5 + TAU * 0.80, 44, Color(c2.r, c2.g, c2.b, alpha_v * 0.95), 3.4)
		# 8 cánh sen lửa Song Hỏa xoay quanh tâm đóa sen!
		var petal_r: float = explosion_radius * (0.42 if not lotus_detonated else 0.88)
		for k in range(8):
			var ang: float = elapsed * 5.2 + float(k) * (TAU / 8.0)
			var p_pos: Vector2 = Vector2(cos(ang), sin(ang)) * petal_r
			var pc: Color = c1 if (k % 2 == 0) else c2
			draw_circle(p_pos, 14.0 if not lotus_detonated else 28.0, Color(pc.r, pc.g, pc.b, 0.42))
			draw_circle(p_pos, 7.0 if not lotus_detonated else 14.0, Color(1.0, 0.96, 0.85, 0.78))
		if lotus_detonated:
			draw_circle(Vector2.ZERO, explosion_radius * 0.92, Color(c1.r, c1.g, c1.b, 0.22))
			draw_circle(Vector2.ZERO, explosion_radius * 0.50, Color(1.0, 0.96, 0.82, 0.35))
