extends Node2D
## AI Đồng Hành Trợ Chiến (Companion AI):
## - tieu_y_tien: Theo sát Tiêu Viêm, phóng Độc Châm Ngọc Bích vào quái & định kỳ hồi máu (+12% HP) khi Tiêu Viêm mất máu!
## - duoc_lao_phantom: Hồn ảnh Dược Lão lơ lửng hộ pháp, phóng tia Cốt Linh Lãnh Hỏa gây thiêu đốt kẻ địch xung quanh!
## - thai_lan: Thất Thải Thôn Thiên Mãng tốc công cực cao + kỹ năng Hộ Chủ cứu nguy khi HP < 38%!
## - huan_nhi: Tiêu Huân Nhi (Kim Đế Phần Thiên Viêm) — phóng kim diễm sát thương & thiêu đốt cực mạnh + hồi +10% Max QI mỗi 6.5s!

var companion_id: String = "tieu_y_tien"
var attack_timer: float = 0.8
var heal_timer: float = 5.0
var anim_t: float = 0.0
var active_bolts: Array = [] # { pos, target, color, dmg, burn }

var body_sprite: Sprite2D
var aura_light: PointLight2D
var name_lbl: Label


func _ready() -> void:
	_build_visuals()
	configure_companion(companion_id)


func _build_visuals() -> void:
	body_sprite = Sprite2D.new()
	body_sprite.position = Vector2(0, -36)
	body_sprite.scale = Vector2(0.86, 0.86)
	add_child(body_sprite)

	aura_light = PointLight2D.new()
	aura_light.texture = load("res://assets/sprites/vfx/light_radial_128.png")
	aura_light.texture_scale = 2.0
	aura_light.energy = 0.85
	aura_light.position = Vector2(0, -32)
	add_child(aura_light)

	name_lbl = Label.new()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.custom_minimum_size = Vector2(240, 0)
	name_lbl.position = Vector2(-120, -96)
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.add_theme_color_override("font_outline_color", Color("#05060A"))
	name_lbl.add_theme_constant_override("outline_size", 3)
	add_child(name_lbl)


func configure_companion(new_id: String) -> void:
	companion_id = new_id
	if body_sprite == null:
		return
	if companion_id == "tieu_y_tien":
		body_sprite.texture = load("res://assets/sprites/npcs/npc_tieu_y_tien.png")
		body_sprite.scale = Vector2(0.86, 0.86)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#52B788")
		aura_light.energy = 0.85
		name_lbl.text = "Đồng Hành: Tiểu Y Tiên"
		name_lbl.add_theme_color_override("font_color", Color("#80ED99"))
	elif companion_id == "thai_lan":
		body_sprite.texture = load("res://assets/sprites/enemies/pet_thai_lan.png")
		body_sprite.scale = Vector2(0.92, 0.92)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#72EFDD")
		aura_light.energy = 0.90
		name_lbl.text = "Thần Thú: Thải Lân"
		name_lbl.add_theme_color_override("font_color", Color("#72EFDD"))
	elif companion_id == "huan_nhi":
		body_sprite.texture = load("res://assets/sprites/npcs/npc_huan_nhi.png")
		body_sprite.scale = Vector2(0.86, 0.86)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#FFD166")
		aura_light.energy = 1.12
		name_lbl.text = "Đồng Hành: Tiêu Huân Nhi (Kim Đế Viêm)"
		name_lbl.add_theme_color_override("font_color", Color("#FFD166"))
	else:
		body_sprite.texture = load("res://assets/sprites/npcs/npc_duoc_lao.png")
		body_sprite.scale = Vector2(0.86, 0.86)
		body_sprite.modulate = Color(0.84, 0.96, 1.12, 0.90)
		aura_light.color = Color("#70D6FF")
		aura_light.energy = 0.85
		name_lbl.text = "Hộ Pháp: Dược Lão"
		name_lbl.add_theme_color_override("font_color", Color("#A8DADC"))


func _physics_process(delta: float) -> void:
	anim_t += delta
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node2D = players[0] as Node2D
	if player == null:
		return

	# Bám theo mượt phía sau vai Tiêu Viêm
	var desired_offset := Vector2(62.0, -24.0)
	if companion_id == "tieu_y_tien":
		desired_offset = Vector2(-62.0, -18.0)
	elif companion_id == "thai_lan":
		desired_offset = Vector2(-52.0, -28.0)
	elif companion_id == "huan_nhi":
		desired_offset = Vector2(58.0, -20.0)
	var target_pos: Vector2 = player.global_position + desired_offset
	var dist_p: float = global_position.distance_to(target_pos)
	if dist_p > 520.0:
		global_position = target_pos
	elif dist_p > 10.0:
		var spd: float = clampf(dist_p * 4.5, 90.0, 420.0)
		var move_v: Vector2 = (target_pos - global_position).normalized() * spd
		global_position += move_v * delta
		if absf(move_v.x) > 8.0:
			body_sprite.flip_h = move_v.x < 0.0

	# Hoạt ảnh lơ lửng / nhấp nhô nhẹ
	if companion_id == "duoc_lao_phantom":
		body_sprite.position.y = -40.0 + sin(anim_t * 3.4) * 5.0
	elif companion_id == "thai_lan":
		body_sprite.position.y = -34.0 + sin(anim_t * 5.2) * 4.5
		if aura_light != null:
			aura_light.color = Color.from_hsv(fmod(anim_t * 0.25, 1.0), 0.52, 1.0)
	elif companion_id == "huan_nhi":
		body_sprite.position.y = -36.0 + sin(anim_t * 4.0) * 2.8
		if aura_light != null:
			aura_light.energy = 1.08 + sin(anim_t * 5.0) * 0.18
	else:
		body_sprite.position.y = -36.0 + sin(anim_t * 4.2) * 2.2

	# 1. Kỹ năng hỗ trợ định kỳ: Tiểu Y Tiên hồi HP / Thải Lân Hộ Chủ / Tiêu Huân Nhi hồi +10% Max QI!
	if companion_id == "tieu_y_tien":
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_hp < PlayerData.get_max_hp() * 0.92:
			heal_timer = 7.5
			var heal_amt: float = maxf(24.0, PlayerData.get_max_hp() * 0.12) * PlayerData.get_heal_effectiveness_mult()
			PlayerData.current_hp = minf(PlayerData.get_max_hp(), PlayerData.current_hp + heal_amt)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("loot_pickup")
			EventBus.floating_text_requested.emit(player.global_position + Vector2(0, -68), "Tiểu Y Tiên +%d HP" % int(round(heal_amt)), Color("#80ED99"))
	elif companion_id == "thai_lan":
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_hp < PlayerData.get_max_hp() * 0.38:
			heal_timer = 16.0
			var save_heal: float = maxf(65.0, PlayerData.get_max_hp() * 0.22)
			PlayerData.current_hp = minf(PlayerData.get_max_hp(), PlayerData.current_hp + save_heal)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("breakthrough")
			EventBus.floating_text_requested.emit(player.global_position + Vector2(0, -74), "THẢI LÂN HỘ CHỦ! +%d HP" % int(round(save_heal)), Color("#72EFDD"))
			for en_n in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(en_n) and en_n is Node2D:
					var en2: Node2D = en_n as Node2D
					if player.global_position.distance_to(en2.global_position) <= 210.0 and en2.has_method("receive_hit"):
						var push_d: Vector2 = (en2.global_position - player.global_position).normalized()
						en2.receive_hit(PlayerData.get_atk() * 1.4, push_d * 420.0, 0.30, 0.0)
	elif companion_id == "huan_nhi":
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_qi < PlayerData.get_max_qi() * 0.88:
			heal_timer = 6.5
			var max_qi: float = PlayerData.get_max_qi()
			var qi_gain: float = maxf(10.0, max_qi * 0.10)
			PlayerData.current_qi = minf(max_qi, PlayerData.current_qi + qi_gain)
			EventBus.qi_updated.emit(PlayerData.current_qi, max_qi)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("loot_pickup")
			EventBus.floating_text_requested.emit(player.global_position + Vector2(0, -70), "Huân Nhi Kim Viêm +%d QI" % int(round(qi_gain)), Color("#FFD166"))

	# 2. Tấn công kẻ địch gần nhất trong bán kính 385px
	attack_timer -= delta
	if attack_timer <= 0.0:
		var target_en: Node2D = _find_nearest_enemy(385.0)
		if target_en != null:
			if companion_id == "thai_lan":
				attack_timer = 1.22
			elif companion_id == "huan_nhi":
				attack_timer = 1.32
			elif companion_id == "tieu_y_tien":
				attack_timer = 1.65
			else:
				attack_timer = 1.45
			body_sprite.flip_h = (target_en.global_position.x < global_position.x)
			var base_atk: float = PlayerData.get_atk()
			var dmg_mult: float = 0.88 if companion_id == "thai_lan" else (0.78 if companion_id == "huan_nhi" else (0.48 if companion_id == "tieu_y_tien" else 0.62))
			var bolt_dmg: float = base_atk * dmg_mult
			var bolt_col: Color = Color.from_hsv(fmod(anim_t * 0.6, 1.0), 0.72, 1.0) if companion_id == "thai_lan" else (Color("#FFD166") if companion_id == "huan_nhi" else (Color("#52B788") if companion_id == "tieu_y_tien" else Color("#A8DADC")))
			var burn_v: float = bolt_dmg * 0.32 if companion_id == "thai_lan" else (base_atk * 0.28 if companion_id == "huan_nhi" else (bolt_dmg * 0.20 if companion_id == "duoc_lao_phantom" else 0.0))
			active_bolts.append({
				"pos": global_position + Vector2(0, -30),
				"target": target_en,
				"color": bolt_col,
				"dmg": bolt_dmg,
				"burn": burn_v
			})
			EventBus.audio_sfx_requested.emit("skill_fire")

	# Cập nhật tia năng lượng bay tới mục tiêu
	var kept_bolts: Array = []
	for b in active_bolts:
		var tgt: Node2D = b.get("target", null) as Node2D
		if tgt == null or not is_instance_valid(tgt):
			continue
		var cur_p: Vector2 = b.get("pos", global_position)
		var dest: Vector2 = tgt.global_position + Vector2(0, -24)
		var to_t: Vector2 = dest - cur_p
		if to_t.length() <= 24.0:
			if tgt.has_method("receive_hit"):
				tgt.receive_hit(float(b.get("dmg", 10.0)), to_t.normalized() * 90.0, 0.15, float(b.get("burn", 0.0)))
		else:
			b["pos"] = cur_p + to_t.normalized() * 520.0 * delta
			kept_bolts.append(b)
	active_bolts = kept_bolts
	queue_redraw()


func _find_nearest_enemy(max_range: float) -> Node2D:
	var best: Node2D = null
	var best_d: float = max_range
	for en in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(en):
			continue
		var en_node: Node2D = en as Node2D
		if en_node == null:
			continue
		if "ai_mode" in en_node and str(en_node.get("ai_mode")) == "dummy":
			continue
		var d: float = global_position.distance_to(en_node.global_position)
		if d < best_d:
			best_d = d
			best = en_node
	return best


func _draw() -> void:
	draw_set_transform(Vector2(0, 10), 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 20.0, Color(0.03, 0.02, 0.06, 0.40))
	if companion_id == "huan_nhi":
		var g_pulse: float = 0.85 + 0.15 * sin(anim_t * 5.0)
		draw_arc(Vector2.ZERO, 26.0, anim_t * 2.2, anim_t * 2.2 + TAU * 0.85, 32, Color(1.0, 0.82, 0.40, 0.62 * g_pulse), 2.8)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for b in active_bolts:
		var local_p: Vector2 = (b.get("pos", global_position) as Vector2) - global_position
		var col: Color = b.get("color", Color("#70D6FF"))
		draw_circle(local_p, 10.0 if companion_id == "huan_nhi" else 8.0, Color(col.r, col.g, col.b, 0.44))
		draw_circle(local_p, 5.2 if companion_id == "huan_nhi" else 4.5, col)
		draw_circle(local_p, 2.4, Color.WHITE)
