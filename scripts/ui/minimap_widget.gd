class_name MinimapWidget
extends Control
## Tiểu Bản Đồ Thời Gian Thực (Live Mini-Map):
## - Hiển thị khu vực bản đồ, Tiêu Viêm (chấm vàng sáng), NPC (xanh lá + vòng vàng nếu có nhiệm vụ!),
##   Cổng chuyển map (lam/đỏ), Rương bí mật (ô vuông vàng), Quái (đỏ) & Boss (kim cương tím)!

var pulse_t: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(180, 114)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	pulse_t += delta
	queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(0, 0, w, h), Color(0.04, 0.05, 0.09, 0.90), true)

	var worlds: Array[Node] = get_tree().get_nodes_in_group("world_stage")
	if worlds.is_empty() or not worlds[0].has_method("get_minimap_snapshot"):
		return
	var snap: Dictionary = worlds[0].get_minimap_snapshot()
	var m_size: Vector2 = snap.get("map_size", Vector2(1600, 1024))
	if m_size.x <= 1.0 or m_size.y <= 1.0:
		return

	var pad: float = 6.0
	var inner_w: float = w - pad * 2.0
	var inner_h: float = h - pad * 2.0
	var sx: float = inner_w / m_size.x
	var sy: float = inner_h / m_size.y

	# Nền vùng bản đồ
	var is_forest: bool = bool(snap.get("is_forest", false))
	var base_c: Color = Color(0.11, 0.24, 0.18, 0.85) if is_forest else Color(0.16, 0.20, 0.28, 0.85)
	draw_rect(Rect2(pad, pad, inner_w, inner_h), base_c, true)

	# Khu vực phụ (Lôi đài / Đường đá)
	var zones: Array = snap.get("zones", [])
	for z in zones:
		var rc: Rect2 = z.get("rect", Rect2())
		var is_arena: bool = bool(z.get("arena_circle", false))
		var zc: Color = Color(0.36, 0.20, 0.42, 0.85) if is_arena else Color(0.26, 0.30, 0.36, 0.72)
		draw_rect(Rect2(pad + rc.position.x * sx, pad + rc.position.y * sy, rc.size.x * sx, rc.size.y * sy), zc, true)

	# Cổng chuyển bản đồ
	var portals: Array = snap.get("portals", [])
	for pt in portals:
		var pp: Vector2 = pt.get("pos", Vector2.ZERO)
		var mp := Vector2(pad + pp.x * sx, pad + pp.y * sy)
		var unlocked: bool = bool(pt.get("unlocked", true))
		var pc: Color = Color("#38BDF8") if unlocked else Color("#FF4D6D")
		draw_arc(mp, 4.5, 0.0, TAU, 14, pc, 1.8)

	# Rương bí mật chưa mở (Ô vuông vàng phát sáng)
	var chests: Array = snap.get("chests", [])
	for ch in chests:
		if bool(ch.get("opened", false)):
			continue
		var cp: Vector2 = ch.get("pos", Vector2.ZERO)
		var mc := Vector2(pad + cp.x * sx, pad + cp.y * sy)
		draw_rect(Rect2(mc.x - 3.0, mc.y - 3.0, 6.0, 6.0), Color("#FFD166"), true)

	# Quái & Boss
	var enemies: Array = snap.get("enemies", [])
	for en in enemies:
		var ep: Vector2 = en.get("pos", Vector2.ZERO)
		var me := Vector2(pad + ep.x * sx, pad + ep.y * sy)
		if bool(en.get("is_boss", false)):
			var pts := PackedVector2Array([me + Vector2(0, -5), me + Vector2(5, 0), me + Vector2(0, 5), me + Vector2(-5, 0)])
			draw_colored_polygon(pts, Color("#C77DFF"))
		else:
			draw_circle(me, 2.2, Color("#FF595E"))

	# NPC (chấm xanh lá + vòng vàng nhấp nháy nếu là NPC nhiệm vụ!)
	var npcs: Array = snap.get("npcs", [])
	for n in npcs:
		var np: Vector2 = n.get("pos", Vector2.ZERO)
		var mn := Vector2(pad + np.x * sx, pad + np.y * sy)
		draw_circle(mn, 3.2, Color("#80ED99"))
		if bool(n.get("has_quest", false)):
			var pr: float = 4.5 + sin(pulse_t * 6.0) * 1.5
			draw_arc(mn, pr, 0.0, TAU, 14, Color("#FFD166"), 1.6)

	# Vị trí Tiêu Viêm (Chấm trắng viền vàng nổi bật)
	var player_pos: Vector2 = snap.get("player_pos", Vector2.ZERO)
	var mp_hero := Vector2(pad + player_pos.x * sx, pad + player_pos.y * sy)
	draw_circle(mp_hero, 4.2, Color("#FFD166"))
	draw_circle(mp_hero, 2.4, Color.WHITE)

	# Viền khung ngoài
	draw_rect(Rect2(0, 0, w, h), Color("#2EC4B6"), false, 1.5)
