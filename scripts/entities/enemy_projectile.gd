extends Area2D
## Sóng Đấu Khí / Kiếm Khí do Boss phóng ra ở Giai Đoạn II (có thể né bằng Space I-frame!).

var velocity_vec: Vector2 = Vector2.RIGHT * 340.0
var damage_val: float = 18.0
var realm_idx: int = 2
var wave_color: Color = Color("#FF4D6D")
var lifetime: float = 2.2
var hit_done: bool = false


func configure_projectile(start_pos: Vector2, dir: Vector2, speed: float, dmg: float, attacker_realm: int, col: Color) -> void:
	global_position = start_pos
	velocity_vec = dir.normalized() * speed
	rotation = velocity_vec.angle()
	damage_val = dmg
	realm_idx = attacker_realm
	wave_color = col


func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	global_position += velocity_vec * delta
	queue_redraw()

	if hit_done:
		return
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var p: Node2D = players[0] as Node2D
	if p != null and global_position.distance_to(p.global_position + Vector2(0, -16)) <= 32.0:
		hit_done = true
		if p.has_method("take_enemy_damage"):
			p.take_enemy_damage(damage_val, realm_idx, velocity_vec.normalized() * 230.0)
		queue_free()


func _draw() -> void:
	# Vẽ vầng nguyệt nha Đấu Khí rực sáng
	draw_arc(Vector2.ZERO, 20.0, -1.05, 1.05, 18, wave_color, 6.0)
	draw_arc(Vector2(2, 0), 17.0, -0.85, 0.85, 14, Color(1.0, 0.96, 0.85, 0.92), 3.0)
	draw_circle(Vector2(6, 0), 5.0, Color(1.0, 1.0, 1.0, 0.85))
