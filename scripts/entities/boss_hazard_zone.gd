class_name BossHazardZone
extends Node2D
## Vùng Kỹ Năng Mặt Đất của Boss (Cột Lửa Đan Vương Cổ Hà, Vũng Độc Liễu Tịch, Băng Trụ Hải Ba Đông, Hồ Dung Nham Hỏa Linh Xà, Lốc Cát Mặc Ba Tư).

var zone_mode: String = "pillar" # "pillar" (báo trước rồi nổ 1 lần), "pool" (tồn tại gây DoT), "vortex" (hút + DoT)
var radius_px: float = 82.0
var telegraph_sec: float = 0.85
var active_sec: float = 0.35
var damage_val: float = 24.0
var attacker_realm: int = 3
var zone_color: Color = Color("#FF7B00")
var apply_slow_ratio: float = 0.0
var apply_slow_sec: float = 0.0
var pull_strength: float = 0.0

var elapsed: float = 0.0
var exploded: bool = false
var tick_accum: float = 0.0


func configure_hazard(
	pos: Vector2,
	mode_str: String,
	rad: float,
	tele_s: float,
	act_s: float,
	dmg: float,
	realm_i: int,
	col: Color,
	slow_r: float = 0.0,
	slow_d: float = 0.0,
	pull_s: float = 0.0
) -> void:
	global_position = pos
	zone_mode = mode_str
	radius_px = rad
	telegraph_sec = tele_s
	active_sec = act_s
	damage_val = dmg
	attacker_realm = realm_i
	zone_color = col
	apply_slow_ratio = slow_r
	apply_slow_sec = slow_d
	pull_strength = pull_s
	z_index = -1


func _physics_process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var p: Node2D = players[0] as Node2D if not players.is_empty() else null

	if elapsed < telegraph_sec:
		return

	if not exploded:
		exploded = true
		EventBus.audio_sfx_requested.emit("skill_burst" if zone_mode == "pillar" else "skill_fire")
		if zone_mode == "pillar":
			EventBus.screen_shake_requested.emit(5.5, 0.16)
			if p != null and global_position.distance_to(p.global_position) <= radius_px:
				_hit_player(p, damage_val)

	if zone_mode == "pool" or zone_mode == "vortex":
		if p != null and pull_strength > 0.0:
			var dist_p: float = global_position.distance_to(p.global_position)
			if dist_p <= radius_px * 1.45 and dist_p > 18.0:
				var pull_d: Vector2 = (global_position - p.global_position).normalized()
				p.global_position += pull_d * pull_strength * delta
		tick_accum += delta
		if tick_accum >= 0.55:
			tick_accum = 0.0
			if p != null and global_position.distance_to(p.global_position) <= radius_px:
				_hit_player(p, damage_val * 0.45)

	if elapsed >= telegraph_sec + active_sec:
		queue_free()


func _hit_player(p: Node2D, dmg_amt: float) -> void:
	if apply_slow_ratio > 0.0 and apply_slow_sec > 0.0:
		PlayerData.apply_player_slow(apply_slow_ratio, apply_slow_sec)
		EventBus.floating_text_requested.emit(p.global_position + Vector2(0, -82), "LÀM CHẬM!", zone_color)
	if p.has_method("take_enemy_damage"):
		var push_d: Vector2 = (p.global_position - global_position).normalized()
		if push_d == Vector2.ZERO:
			push_d = Vector2.RIGHT
		p.take_enemy_damage(dmg_amt, attacker_realm, push_d * (140.0 if zone_mode == "pillar" else 60.0))


func _draw() -> void:
	if elapsed < telegraph_sec:
		var prog: float = clampf(elapsed / maxf(0.05, telegraph_sec), 0.0, 1.0)
		draw_circle(Vector2.ZERO, radius_px * prog, Color(zone_color.r, zone_color.g, zone_color.b, 0.16 + 0.14 * prog))
		draw_arc(Vector2.ZERO, radius_px, 0.0, TAU, 36, Color(zone_color.r, zone_color.g, zone_color.b, 0.85), 3.0)
		draw_arc(Vector2.ZERO, radius_px * prog, 0.0, TAU, 28, Color(1.0, 0.95, 0.80, 0.82), 2.0)
	else:
		var rem_ratio: float = clampf(1.0 - (elapsed - telegraph_sec) / maxf(0.05, active_sec), 0.0, 1.0)
		var fill_a: float = 0.36 * rem_ratio if zone_mode == "pillar" else (0.24 * clampf(rem_ratio * 2.5, 0.25, 1.0))
		draw_circle(Vector2.ZERO, radius_px, Color(zone_color.r, zone_color.g, zone_color.b, fill_a))
		draw_arc(Vector2.ZERO, radius_px, elapsed * 2.8, elapsed * 2.8 + TAU * 0.84, 36, Color(zone_color.r, zone_color.g, zone_color.b, 0.88 * clampf(rem_ratio * 2.0, 0.2, 1.0)), 4.0)
		if zone_mode == "vortex":
			draw_arc(Vector2.ZERO, radius_px * 0.58, -elapsed * 5.2, -elapsed * 5.2 + TAU * 0.78, 28, Color(1.0, 0.90, 0.55, 0.72), 2.8)
		elif zone_mode == "pillar":
			draw_circle(Vector2.ZERO, radius_px * 0.55, Color(1.0, 0.96, 0.84, 0.45 * rem_ratio))
