extends Area2D
## Vật phẩm rớt trên mặt đất HD (Hạt Đấu Khí EXP, Thảo Dược, Ma Hạch, Kim Tệ & Trang Bị 10 Ô).
## Trang bị rớt sẽ có Cột Ánh Sáng Phẩm Chất (Trắng/Lục/Lam/Tím/Cam/Đỏ) nổi bật giống Diablo / ARPG!

var pickup_kind: String = "exp" # "exp", "item", "gold", "gear"
var item_id: String = ""
var amount: int = 10
var gear_instance: Dictionary = {}
var rarity_col: Color = Color.WHITE

var fly_speed: float = 420.0
var spawn_timer: float = 0.0
var pop_velocity: Vector2 = Vector2.ZERO

@onready var sprite_node: Sprite2D = $Sprite2D


func setup_exp_orb(exp_val: int) -> void:
	pickup_kind = "exp"
	amount = exp_val
	_init_pop()


func setup_gold_drop(gold_val: int) -> void:
	pickup_kind = "gold"
	amount = gold_val
	_init_pop()


func setup_item_drop(drop_item_id: String, count_val: int = 1) -> void:
	pickup_kind = "item"
	item_id = drop_item_id
	amount = count_val
	_init_pop()


func setup_gear_drop(inst: Dictionary) -> void:
	pickup_kind = "gear"
	gear_instance = inst
	rarity_col = EquipmentSystem.get_rarity_color(str(inst.get("rarity", "pham")))
	_init_pop()


func _init_pop() -> void:
	var angle: float = randf() * TAU
	pop_velocity = Vector2(cos(angle), sin(angle)) * randf_range(70.0, 145.0)


func _ready() -> void:
	if pickup_kind == "exp":
		sprite_node.scale = Vector2(0.88, 0.88)
		sprite_node.texture = load("res://assets/sprites/pickups/qi_orb.png")
	elif pickup_kind == "gold":
		sprite_node.scale = Vector2(0.84, 0.84)
		sprite_node.texture = load("res://assets/sprites/pickups/qi_orb.png")
		sprite_node.modulate = Color("#FFD166")
	elif pickup_kind == "gear":
		var tdef: Dictionary = GameDatabase.get_equipment_template(str(gear_instance.get("template_id", "")))
		var icon_path: String = str(tdef.get("icon", "res://assets/sprites/icons/icon_armor.png"))
		sprite_node.texture = load(icon_path)
		sprite_node.scale = Vector2(0.65, 0.65)
	else:
		sprite_node.scale = Vector2(0.94, 0.94)
		var idef: Dictionary = GameDatabase.get_item_def(item_id)
		var itype: String = str(idef.get("type", "herb"))
		if itype == "monster_core":
			sprite_node.texture = load("res://assets/sprites/pickups/monster_core.png")
		else:
			sprite_node.texture = load("res://assets/sprites/pickups/herb_item.png")
		var hex_col: String = str(idef.get("color_hex", "#FFFFFF"))
		sprite_node.modulate = Color(hex_col)
		rarity_col = Color(hex_col)


func _physics_process(delta: float) -> void:
	spawn_timer += delta
	queue_redraw()
	if spawn_timer < 0.28:
		global_position += pop_velocity * delta
		pop_velocity = pop_velocity.move_toward(Vector2.ZERO, 340.0 * delta)
		return

	sprite_node.position.y = sin(spawn_timer * 6.0) * 4.5

	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player_node: Node2D = players[0] as Node2D
	if player_node == null:
		return

	var magnet_r: float = PlayerData.get_loot_magnet_radius()
	var dist: float = global_position.distance_to(player_node.global_position)
	if dist <= magnet_r:
		var dir: Vector2 = (player_node.global_position - global_position).normalized()
		fly_speed = minf(800.0, fly_speed + 860.0 * delta)
		global_position += dir * fly_speed * delta
		if dist <= 26.0:
			_collect(player_node.global_position)


func _collect(collect_pos: Vector2) -> void:
	if pickup_kind == "exp":
		EventBus.audio_sfx_requested.emit("loot_pickup")
		PlayerData.add_exp(amount, collect_pos + Vector2(0, -40))
	elif pickup_kind == "gold":
		EventBus.audio_sfx_requested.emit("loot_pickup")
		var final_g: int = maxi(1, int(round(float(amount) * PlayerData.get_gold_reward_mult())))
		PlayerData.gold += final_g
		EventBus.stats_changed.emit()
		EventBus.floating_text_requested.emit(collect_pos + Vector2(0, -48), "+%d Kim Tệ" % final_g, Color("#FFD166"))
	elif pickup_kind == "gear":
		EventBus.audio_sfx_requested.emit("loot_rare")
		PlayerData.add_gear_to_bag(gear_instance)
		var title: String = EquipmentSystem.get_item_display_name(gear_instance)
		var af_cnt: int = (gear_instance.get("affixes", []) as Array).size()
		var suffix: String = " (%d dòng!)" % af_cnt if af_cnt > 0 else ""
		EventBus.floating_text_requested.emit(collect_pos + Vector2(0, -70), "NHẶT: %s%s" % [title, suffix], rarity_col)
	else:
		EventBus.audio_sfx_requested.emit("loot_pickup")
		var idef: Dictionary = GameDatabase.get_item_def(item_id)
		var final_cnt: int = amount
		if str(idef.get("type", "")) == "herb" and PlayerData.lotus_double_herb_timer > 0.0:
			final_cnt *= 2
		PlayerData.add_item(item_id, final_cnt)
		var iname: String = str(idef.get("name", item_id))
		var hex_col: String = str(idef.get("color_hex", "#FFE599"))
		EventBus.floating_text_requested.emit(collect_pos + Vector2(0, -56), "+%d %s" % [final_cnt, iname], Color(hex_col))
	queue_free()


func _draw() -> void:
	var pulse: float = 0.78 + 0.22 * sin(spawn_timer * 6.0)
	if pickup_kind == "gear":
		# Cột ánh sáng Phẩm chất VFX 2.0 (Đa tầng thuôn nhọn + Vòng sáng xoay + Hạt bay lên trời!)
		var top_y: float = -108.0 - sin(spawn_timer * 4.0) * 8.0
		var poly_outer := PackedVector2Array([Vector2(-12, 8), Vector2(12, 8), Vector2(4, top_y), Vector2(-4, top_y)])
		draw_colored_polygon(poly_outer, Color(rarity_col.r, rarity_col.g, rarity_col.b, 0.26 * pulse))
		var poly_mid := PackedVector2Array([Vector2(-6, 6), Vector2(6, 6), Vector2(2, top_y * 0.88), Vector2(-2, top_y * 0.88)])
		draw_colored_polygon(poly_mid, Color(rarity_col.r, rarity_col.g, rarity_col.b, 0.54 * pulse))
		draw_line(Vector2(0, 6), Vector2(0, top_y * 0.76), Color(1.0, 1.0, 1.0, 0.82 * pulse), 2.4)
		# 3 đốm sáng bay dọc cột
		for si in range(3):
			var sy: float = 4.0 - fmod(spawn_timer * 42.0 + float(si) * 32.0, 96.0)
			var sx: float = sin(spawn_timer * 5.0 + float(si) * 2.1) * 5.5
			draw_circle(Vector2(sx, sy), 2.4, Color(1.0, 1.0, 1.0, 0.78))
		draw_set_transform(Vector2(0, 7), 0.0, Vector2(1.0, 0.48))
		draw_arc(Vector2.ZERO, 18.0, spawn_timer * 2.2, spawn_timer * 2.2 + TAU * 0.85, 28, rarity_col, 2.4)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	elif pickup_kind == "item" and item_id.begins_with("core_"):
		# Ma Hạch quý cũng tỏa tia cột nhỏ + vòng phát sáng
		var c_poly := PackedVector2Array([Vector2(-7, 6), Vector2(7, 6), Vector2(2, -58), Vector2(-2, -58)])
		draw_colored_polygon(c_poly, Color(rarity_col.r, rarity_col.g, rarity_col.b, 0.30 * pulse))
		draw_set_transform(Vector2(0, 6), 0.0, Vector2(1.0, 0.48))
		draw_arc(Vector2.ZERO, 13.0, -spawn_timer * 2.5, -spawn_timer * 2.5 + TAU * 0.8, 22, rarity_col, 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
