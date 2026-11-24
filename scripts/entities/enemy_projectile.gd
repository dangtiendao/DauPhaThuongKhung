extends Area2D
## Đạn & Kiếm Khí Boss (hỗ trợ đa dạng hình thái cho từng Boss: Nguyệt Nha, Cầu Lửa/Băng, Thương Khí, rượt nhẹ & làm chậm!).

var velocity_vec: Vector2 = Vector2.RIGHT * 340.0
var speed_mag: float = 340.0
var damage_val: float = 18.0
var realm_idx: int = 2
var wave_color: Color = Color("#FF4D6D")
var lifetime: float = 2.2
var hit_done: bool = false
var proj_style: String = "wave" # "wave", "orb", "spear", "boulder"
var hit_radius: float = 32.0
var slow_ratio: float = 0.0
var slow_sec: float = 0.0
var homing_turn_rate: float = 0.0


func configure_projectile(
	start_pos: Vector2,
	dir: Vector2,
	speed: float,
	dmg: float,
	attacker_realm: int,
	col: Color,
	style: String = "wave",
	slow_r: float = 0.0,
	slow_dur: float = 0.0,
	homing_rate: float = 0.0
) -> void:
	global_position = start_pos
	speed_mag = speed
	var n_dir: Vector2 = dir.normalized() if dir.length() > 0.001 else Vector2.RIGHT
	velocity_vec = n_dir * speed_mag
	rotation = velocity_vec.angle()
	damage_val = dmg
	realm_idx = attacker_realm
	wave_color = col
	proj_style = style
	slow_ratio = slow_r
	slow_sec = slow_dur
	homing_turn_rate = homing_rate
	hit_radius = 28.0 if style == "spear" else (34.0 if style == "boulder" else 32.0)


func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var p: Node2D = players[0] as Node2D if not players.is_empty() else null

	if homing_turn_rate > 0.0 and p != null:
		var want_dir: Vector2 = ((p.global_position + Vector2(0, -16)) - global_position).normalized()
		var cur_dir: Vector2 = velocity_vec.normalized()
		var new_dir: Vector2 = cur_dir.lerp(want_dir, clampf(homing_turn_rate * delta, 0.0, 1.0)).normalized()
		velocity_vec = new_dir * speed_mag
		rotation = velocity_vec.angle()

	global_position += velocity_vec * delta
	queue_redraw()

	if hit_done or p == null:
		return
	if global_position.distance_to(p.global_position + Vector2(0, -16)) <= hit_radius:
		hit_done = true
		if slow_ratio > 0.0 and slow_sec > 0.0:
			PlayerData.apply_player_slow(slow_ratio, slow_sec)
			EventBus.floating_text_requested.emit(p.global_position + Vector2(0, -84), "BỊ HÀN BĂNG LÀM CHẬM!", Color("#70D6FF"))
		if p.has_method("take_enemy_damage"):
			p.take_enemy_damage(damage_val, realm_idx, velocity_vec.normalized() * 230.0)
		queue_free()


func _draw() -> void:
	if proj_style == "orb":
		draw_circle(Vector2.ZERO, 15.0, Color(wave_color.r, wave_color.g, wave_color.b, 0.38))
		draw_circle(Vector2.ZERO, 9.5, wave_color)
		draw_circle(Vector2.ZERO, 4.5, Color(1.0, 0.98, 0.88, 0.95))
	elif proj_style == "spear":
		var pts := PackedVector2Array([Vector2(22, 0), Vector2(-12, -7), Vector2(-6, 0), Vector2(-12, 7)])
		draw_colored_polygon(pts, wave_color)
		draw_line(Vector2(-16, 0), Vector2(20, 0), Color(1.0, 0.98, 0.92, 0.92), 2.5)
	elif proj_style == "boulder":
		draw_circle(Vector2.ZERO, 14.0, Color(0.28, 0.30, 0.34, 0.95))
		draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 16, wave_color, 2.8)
		draw_circle(Vector2(-3, -3), 4.0, Color(wave_color.r, wave_color.g, wave_color.b, 0.75))
	else:
		# Nguyệt nha Đấu Khí rực sáng
		draw_arc(Vector2.ZERO, 20.0, -1.05, 1.05, 18, wave_color, 6.0)
		draw_arc(Vector2(2, 0), 17.0, -0.85, 0.85, 14, Color(1.0, 0.96, 0.85, 0.92), 3.0)
		draw_circle(Vector2(6, 0), 5.0, Color(1.0, 1.0, 1.0, 0.85))
