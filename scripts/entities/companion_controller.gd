extends Node2D
## AI Đồng Hành Trợ Chiến (Companion AI):
## - tieu_y_tien: Theo sát Tiêu Viêm, phóng Độc Châm Ngọc Bích vào quái & định kỳ hồi máu (+12% HP) khi Tiêu Viêm mất máu!
## - duoc_lao_phantom: Hồn ảnh Dược Lão lơ lửng hộ pháp, phóng tia Cốt Linh Lãnh Hỏa gây thiêu đốt kẻ địch xung quanh!
## - thai_lan: Thất Thải Thôn Thiên Mãng tốc công cực cao + kỹ năng Hộ Chủ cứu nguy khi HP < 38%!
## - huan_nhi: Tiêu Huân Nhi (Kim Đế Phần Thiên Viêm) — phóng kim diễm sát thương & thiêu đốt cực mạnh + hồi +10% Max QI mỗi 6.5s!
## - tu_nghien: Tiểu Man Vương Tử Nghiên (Thái Hư Cổ Long) — tung Cổ Long Nhất Quyền sát thương cực cao + LÀM CHOÁNG kẻ địch & mở rộng Radar Tầm Bảo +45%!

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
		if PlayerData.has_flag("ch08_ma_doc_ban_cured"):
			body_sprite.texture = load("res://assets/sprites/npcs/npc_thien_doc_nu.png")
			body_sprite.scale = Vector2(0.90, 0.90)
			body_sprite.modulate = Color(1.04, 0.96, 1.08, 1.0)
			aura_light.color = Color("#C77DFF")
			aura_light.energy = 1.32
			name_lbl.text = "Thiên Độc Nữ · Tiểu Y Tiên (Tam Tinh Đấu Tôn)"
			name_lbl.add_theme_color_override("font_color", Color("#E0AAFF"))
		elif PlayerData.has_flag("ch07_thien_doc_nu_joined"):
			body_sprite.texture = load("res://assets/sprites/npcs/npc_thien_doc_nu.png")
			body_sprite.scale = Vector2(0.88, 0.88)
			body_sprite.modulate = Color.WHITE
			aura_light.color = Color("#E0AAFF")
			aura_light.energy = 1.18
			name_lbl.text = "Thiên Độc Nữ · Tiểu Y Tiên (Đấu Tông)"
			name_lbl.add_theme_color_override("font_color", Color("#E0AAFF"))
		else:
			body_sprite.texture = load("res://assets/sprites/npcs/npc_tieu_y_tien.png")
			body_sprite.scale = Vector2(0.86, 0.86)
			body_sprite.modulate = Color.WHITE
			aura_light.color = Color("#52B788")
			aura_light.energy = 0.85
			name_lbl.text = "Đồng Hành: Tiểu Y Tiên"
			name_lbl.add_theme_color_override("font_color", Color("#80ED99"))
	elif companion_id == "dia_yeu_khoi":
		var is_tyk: bool = PlayerData.has_flag("ch08_dan_hoi_champion")
		body_sprite.texture = load("res://assets/sprites/npcs/npc_dia_yeu_khoi.png")
		body_sprite.scale = Vector2(0.96, 0.96) if is_tyk else Vector2(0.92, 0.92)
		body_sprite.modulate = Color(1.12, 1.02, 0.82, 1.0) if is_tyk else Color(0.95, 0.99, 1.08, 1.0)
		aura_light.color = Color("#FFD166") if is_tyk else Color("#90E0EF")
		aura_light.energy = 1.40 if is_tyk else 1.25
		name_lbl.text = "Vệ Sĩ Hoàng Kim: Chuẩn Thiên Yêu Khôi (Ngũ Lôi)" if is_tyk else "Vệ Sĩ Bất Tử: Địa Yêu Khôi (Đấu Tông)"
		name_lbl.add_theme_color_override("font_color", Color("#FFD166") if is_tyk else Color("#CAF0F8"))
	elif companion_id == "thien_hoa_ton_gia":
		body_sprite.texture = load("res://assets/sprites/npcs/npc_thien_hoa_ton_gia.png")
		body_sprite.scale = Vector2(0.92, 0.92)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#FF9F1C")
		aura_light.energy = 1.34
		name_lbl.text = "Đồng Hành #7: Thiên Hỏa Tôn Giả (Ngũ Luân Ly Hỏa)"
		name_lbl.add_theme_color_override("font_color", Color("#FFBF69"))
	elif companion_id == "thai_lan":
		body_sprite.texture = load("res://assets/sprites/enemies/pet_thai_lan.png")
		body_sprite.scale = Vector2(0.92, 0.92)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#72EFDD")
		aura_light.energy = 0.90
		name_lbl.text = "Thần Thú: Thải Lân"
		name_lbl.add_theme_color_override("font_color", Color("#72EFDD"))
	elif companion_id == "huan_nhi":
		var is_hn_st: bool = PlayerData.has_flag("ch10_tinh_lien_tamed")
		body_sprite.texture = load("res://assets/sprites/npcs/npc_huan_nhi_dau_thanh.png" if is_hn_st else "res://assets/sprites/npcs/npc_huan_nhi.png")
		body_sprite.scale = Vector2(0.92, 0.92) if is_hn_st else Vector2(0.86, 0.86)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#FFD700")
		aura_light.energy = 1.48 if is_hn_st else 1.12
		name_lbl.text = "Cổ Huân Nhi (Tứ Tinh Đấu Thánh · Kim Đế Viêm)" if is_hn_st else "Đồng Hành: Tiêu Huân Nhi (Kim Đế Viêm)"
		name_lbl.add_theme_color_override("font_color", Color("#FFD700") if is_hn_st else Color("#FFD166"))
	elif companion_id == "tu_nghien":
		var is_lh: bool = PlayerData.has_flag("ch09_co_long_unified")
		body_sprite.texture = load("res://assets/sprites/npcs/npc_tu_nghien_long_hoang.png" if is_lh else "res://assets/sprites/npcs/npc_tu_nghien.png")
		body_sprite.scale = Vector2(0.92, 0.92) if is_lh else Vector2(0.84, 0.84)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#FFD166") if is_lh else Color("#C77DFF")
		aura_light.energy = 1.38 if is_lh else 1.15
		name_lbl.text = "Long Hoàng Tử Nghiên (Thái Hư Cổ Long Hoàng)" if is_lh else "Đồng Hành: Tử Nghiên (Thái Hư Cổ Long)"
		name_lbl.add_theme_color_override("font_color", Color("#FFD166") if is_lh else Color("#E0AAFF"))
	elif companion_id == "thanh_lan":
		body_sprite.texture = load("res://assets/sprites/npcs/npc_thanh_lan_dau_ton.png")
		body_sprite.scale = Vector2(0.90, 0.90)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#52B788")
		aura_light.energy = 1.28
		name_lbl.text = "Đồng Hành #8: Thanh Lân (Bích Xà Tam Hoa Đồng)"
		name_lbl.add_theme_color_override("font_color", Color("#80ED99"))
	elif companion_id == "van_van_hoa_tong":
		body_sprite.texture = load("res://assets/sprites/npcs/npc_van_van_hoa_tong.png")
		body_sprite.scale = Vector2(0.92, 0.92)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#FFAFCC")
		aura_light.energy = 1.32
		name_lbl.text = "Đồng Hành #9: Tông Chủ Vân Vận (Hoa Tông)"
		name_lbl.add_theme_color_override("font_color", Color("#FFC8DD"))
	elif companion_id == "bac_vuong":
		var is_7star: bool = SaintRealmManager.has_bac_vuong_seven_star(PlayerData)
		body_sprite.texture = load("res://assets/sprites/npcs/npc_bac_vuong.png")
		body_sprite.scale = Vector2(1.04, 1.04) if is_7star else Vector2(0.98, 0.98)
		body_sprite.modulate = Color(1.12, 1.06, 0.92, 1.0) if is_7star else Color.WHITE
		aura_light.color = Color("#FFD700")
		aura_light.energy = 1.62 if is_7star else 1.45
		name_lbl.text = "BẮC VƯƠNG (Thất Tinh Đấu Thánh · Kim Lôi)" if is_7star else "Đồng Hành #10: BẮC VƯƠNG (Lục Tinh Đấu Thánh)"
		name_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	elif companion_id == "thai_lan_tieu_tieu":
		body_sprite.texture = load("res://assets/sprites/npcs/npc_tieu_tieu.png")
		body_sprite.scale = Vector2(0.92, 0.92)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#FF4D6D")
		aura_light.energy = 1.42
		name_lbl.text = "Đồng Hành #11: Thải Lân & Tiêu Tiêu (Thất Thải Mãng)"
		name_lbl.add_theme_color_override("font_color", Color("#FBCFE8"))
	elif companion_id == "chuc_khon_long_hoang":
		body_sprite.texture = load("res://assets/sprites/npcs/npc_chuc_khon_long_hoang.png")
		body_sprite.scale = Vector2(1.06, 1.06)
		body_sprite.modulate = Color.WHITE
		aura_light.color = Color("#C084FC")
		aura_light.energy = 1.72
		name_lbl.text = "Đồng Hành #12: LÃO LONG HOÀNG CHÚC KHÔN (Cửu Tinh Đỉnh)"
		name_lbl.add_theme_color_override("font_color", Color("#E9D5FF"))
	else:
		var is_bt: bool = PlayerData.has_flag("ch09_duoc_tran_revived")
		body_sprite.texture = load("res://assets/sprites/npcs/npc_duoc_tran_ban_thanh.png" if is_bt else "res://assets/sprites/npcs/npc_duoc_lao.png")
		body_sprite.scale = Vector2(0.92, 0.92) if is_bt else Vector2(0.86, 0.86)
		body_sprite.modulate = Color.WHITE if is_bt else Color(0.84, 0.96, 1.12, 0.90)
		aura_light.color = Color("#E0FBFC") if is_bt else Color("#70D6FF")
		aura_light.energy = 1.38 if is_bt else 0.85
		name_lbl.text = "Bán Thánh Dược Trần (Bản Thể Phục Sinh)" if is_bt else "Hộ Pháp: Dược Lão"
		name_lbl.add_theme_color_override("font_color", Color("#E0FBFC") if is_bt else Color("#A8DADC"))


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
	elif companion_id == "tu_nghien":
		desired_offset = Vector2(-56.0, -24.0)
	elif companion_id == "dia_yeu_khoi":
		desired_offset = Vector2(68.0, -18.0)
	elif companion_id == "thien_hoa_ton_gia":
		desired_offset = Vector2(64.0, -26.0)
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
	elif companion_id == "tu_nghien":
		body_sprite.position.y = -33.0 + absf(sin(anim_t * 5.6)) * -4.2
		if aura_light != null:
			aura_light.energy = 1.10 + sin(anim_t * 6.2) * 0.22
	elif companion_id == "dia_yeu_khoi":
		body_sprite.position.y = -36.0 + sin(anim_t * 3.0) * 2.4
		if aura_light != null:
			aura_light.energy = 1.18 + sin(anim_t * 7.5) * 0.24
	elif companion_id == "thien_hoa_ton_gia":
		body_sprite.position.y = -39.0 + sin(anim_t * 3.8) * 3.8
		if aura_light != null:
			aura_light.energy = 1.26 + sin(anim_t * 6.0) * 0.22
	else:
		body_sprite.position.y = -36.0 + sin(anim_t * 4.2) * 2.2

	# 1. Kỹ năng hỗ trợ định kỳ: Tiểu Y Tiên hồi HP / Thải Lân Hộ Chủ / Tiêu Huân Nhi & Thiên Hỏa hồi QI!
	if companion_id == "tieu_y_tien":
		var is_tdn_t3: bool = PlayerData.has_flag("ch08_ma_doc_ban_cured")
		var is_tdn: bool = is_tdn_t3 or PlayerData.has_flag("ch07_thien_doc_nu_joined")
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_hp < PlayerData.get_max_hp() * 0.92:
			heal_timer = 5.4 if is_tdn_t3 else (6.2 if is_tdn else 7.5)
			var heal_ratio: float = 0.22 if is_tdn_t3 else (0.18 if is_tdn else 0.12)
			var heal_amt: float = maxf(24.0, PlayerData.get_max_hp() * heal_ratio) * PlayerData.get_heal_effectiveness_mult()
			PlayerData.current_hp = minf(PlayerData.get_max_hp(), PlayerData.current_hp + heal_amt)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("loot_pickup")
			EventBus.floating_text_requested.emit(
				player.global_position + Vector2(0, -68),
				"%s +%d HP" % ["Đấu Tôn Tiểu Y Tiên" if is_tdn_t3 else ("Thiên Độc Nữ" if is_tdn else "Tiểu Y Tiên"), int(round(heal_amt))],
				Color("#E0AAFF") if is_tdn else Color("#80ED99")
			)
	elif companion_id == "dia_yeu_khoi":
		# Vệ Sĩ Bất Tử Địa Yêu Khôi / Chuẩn Thiên Yêu Khôi: Định kỳ tạo Sóng Lôi Khôi đẩy lùi quái áp sát & hộ thân khi HP < 58%!
		var is_tyk_h: bool = PlayerData.has_flag("ch08_dan_hoi_champion")
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_hp < PlayerData.get_max_hp() * (0.60 if is_tyk_h else 0.55):
			heal_timer = 9.5 if is_tyk_h else 11.0
			var shield_gain: float = maxf(240.0 if is_tyk_h else 140.0, PlayerData.get_max_hp() * (0.22 if is_tyk_h else 0.16))
			PlayerData.lotus_shield_hp = maxf(PlayerData.lotus_shield_hp, shield_gain)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("skill_burst")
			EventBus.floating_text_requested.emit(
				player.global_position + Vector2(0, -78),
				"%s (+%d KHIÊN)" % ["CHUẨN THIÊN YÊU KHÔI HỘ CHỦ!" if is_tyk_h else "ĐỊA YÊU KHÔI HỘ CHỦ!", int(round(shield_gain))],
				Color("#FFD166") if is_tyk_h else Color("#CAF0F8")
			)
			for en_n in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(en_n) and en_n is Node2D:
					var en2: Node2D = en_n as Node2D
					if player.global_position.distance_to(en2.global_position) <= (275.0 if is_tyk_h else 240.0) and en2.has_method("receive_hit"):
						var push_d: Vector2 = (en2.global_position - player.global_position).normalized()
						en2.receive_hit(PlayerData.get_atk() * (2.05 if is_tyk_h else 1.65), push_d * 520.0, 0.55, 0.0)
						if en2.has_method("apply_stun"):
							en2.apply_stun(1.8 if is_tyk_h else 1.4)
	elif companion_id == "thien_hoa_ton_gia":
		# Thiên Hỏa Tôn Giả (#7): Hồi +12% Max QI định kỳ nhờ Ngũ Luân Ly Hỏa Pháp!
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_qi < PlayerData.get_max_qi() * 0.90:
			heal_timer = 6.5
			var max_qi_th: float = PlayerData.get_max_qi()
			var qi_gain_th: float = maxf(18.0, max_qi_th * 0.12)
			PlayerData.current_qi = minf(max_qi_th, PlayerData.current_qi + qi_gain_th)
			EventBus.qi_updated.emit(PlayerData.current_qi, max_qi_th)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("loot_pickup")
			EventBus.floating_text_requested.emit(player.global_position + Vector2(0, -74), "Thiên Hỏa Ngũ Luân +%d QI" % int(round(qi_gain_th)), Color("#FF9F1C"))
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
	elif companion_id == "van_van_hoa_tong":
		# Tông Chủ Vân Vận (#9): Phong Hoa Dưỡng Khí hồi +14% HP định kỳ & giảm 25% hồi chiêu Lướt [Space]!
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_hp < PlayerData.get_max_hp() * 0.90:
			heal_timer = 6.0
			var vv_heal: float = maxf(60.0, PlayerData.get_max_hp() * 0.14) * PlayerData.get_heal_effectiveness_mult()
			PlayerData.current_hp = minf(PlayerData.get_max_hp(), PlayerData.current_hp + vv_heal)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("loot_pickup")
			EventBus.floating_text_requested.emit(player.global_position + Vector2(0, -72), "Vân Vận Hoa Vũ +%d HP" % int(round(vv_heal)), Color("#FFC8DD"))
	elif companion_id == "bac_vuong":
		# Siêu Khôi Lỗi BẮC VƯƠNG (#10): Tự động dựng Khiên Kim Cương 28% HP & đấm sóng Cửu Huyền Kim Lôi khi HP < 68%!
		var is_bv7: bool = SaintRealmManager.has_bac_vuong_seven_star(PlayerData)
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_hp < PlayerData.get_max_hp() * 0.68:
			heal_timer = 8.2 if is_bv7 else 9.5
			var bv_shield: float = maxf(600.0, PlayerData.get_max_hp() * (0.32 if is_bv7 else 0.26))
			PlayerData.lotus_shield_hp = maxf(PlayerData.lotus_shield_hp, bv_shield)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("skill_burst")
			EventBus.floating_text_requested.emit(player.global_position + Vector2(0, -82), "BẮC VƯƠNG KIM CƯƠNG HỘ CHỦ! (+%d KHIÊN)" % int(round(bv_shield)), Color("#FFD700"))
			for en_n in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(en_n) and en_n is Node2D:
					var en2: Node2D = en_n as Node2D
					if player.global_position.distance_to(en2.global_position) <= 310.0 and en2.has_method("receive_hit"):
						var push_d: Vector2 = (en2.global_position - player.global_position).normalized()
						en2.receive_hit(PlayerData.get_atk() * (2.95 if is_bv7 else 2.35), push_d * 600.0, 0.85, 0.0)
						if en2.has_method("apply_stun"):
							en2.apply_stun(2.4 if is_bv7 else 1.9)
	elif companion_id == "thai_lan_tieu_tieu":
		# Thải Lân & Công Chúa Nhỏ Tiêu Tiêu (#11): Huyết mạch cộng sinh hồi +2% HP/giây (mỗi 3s hồi +6% HP) & +20% tốc độ Xích!
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_hp < PlayerData.get_max_hp() * 0.96:
			heal_timer = 3.0
			var fam_heal: float = maxf(80.0, PlayerData.get_max_hp() * 0.06) * PlayerData.get_heal_effectiveness_mult()
			PlayerData.current_hp = minf(PlayerData.get_max_hp(), PlayerData.current_hp + fam_heal)
			EventBus.stats_changed.emit()
			EventBus.floating_text_requested.emit(player.global_position + Vector2(0, -72), "Thải Lân & Tiêu Tiêu +%d HP" % int(round(fam_heal)), Color("#FBCFE8"))
	elif companion_id == "chuc_khon_long_hoang":
		# Lão Long Hoàng CHÚC KHÔN (#12): Dựng Khiên Cổ Long Hoàng 35% HP & gầm xé hư không làm choáng 2.8s khi HP < 72%!
		heal_timer -= delta
		if heal_timer <= 0.0 and PlayerData.current_hp < PlayerData.get_max_hp() * 0.72:
			heal_timer = 7.5
			var ck_shield: float = maxf(1200.0, PlayerData.get_max_hp() * 0.35)
			PlayerData.lotus_shield_hp = maxf(PlayerData.lotus_shield_hp, ck_shield)
			EventBus.stats_changed.emit()
			EventBus.audio_sfx_requested.emit("boss_roar")
			EventBus.floating_text_requested.emit(player.global_position + Vector2(0, -86), "LÃO LONG HOÀNG CHÚC KHÔN HỘ GIÁ! (+%d KHIÊN)" % int(round(ck_shield)), Color("#E9D5FF"))
			for en_n in get_tree().get_nodes_in_group("enemies"):
				if is_instance_valid(en_n) and en_n is Node2D:
					var en2: Node2D = en_n as Node2D
					if player.global_position.distance_to(en2.global_position) <= 360.0 and en2.has_method("receive_hit"):
						var push_d: Vector2 = (en2.global_position - player.global_position).normalized()
						en2.receive_hit(PlayerData.get_atk() * 3.80, push_d * 680.0, 1.0, 0.0)
						if en2.has_method("apply_stun"):
							en2.apply_stun(2.8)

	# 2. Tấn công kẻ địch gần nhất trong bán kính 385px
	attack_timer -= delta
	if attack_timer <= 0.0:
		var target_en: Node2D = _find_nearest_enemy(385.0)
		if target_en != null:
			var is_tdn_t3_atk: bool = (companion_id == "tieu_y_tien" and PlayerData.has_flag("ch08_ma_doc_ban_cured"))
			var is_tdn_atk: bool = is_tdn_t3_atk or (companion_id == "tieu_y_tien" and PlayerData.has_flag("ch07_thien_doc_nu_joined"))
			var is_tyk_atk: bool = (companion_id == "dia_yeu_khoi" and PlayerData.has_flag("ch08_dan_hoi_champion"))
			var is_lh_atk: bool = (companion_id == "tu_nghien" and PlayerData.has_flag("ch09_co_long_unified"))
			var is_bt_atk: bool = (companion_id == "duoc_lao_phantom" and PlayerData.has_flag("ch09_duoc_tran_revived"))
			var is_bv7_atk: bool = (companion_id == "bac_vuong" and SaintRealmManager.has_bac_vuong_seven_star(PlayerData))
			var is_hn_st_atk: bool = (companion_id == "huan_nhi" and PlayerData.has_flag("ch10_tinh_lien_tamed"))
			var bode_dan_mult: float = (1.18 if PlayerData.has_flag("sq_10_02_bo_de_dan_gifted") else 1.0) * (1.25 if PlayerData.has_flag("eq_11_04_candy_party_done") else 1.0)
			if companion_id == "chuc_khon_long_hoang":
				attack_timer = 0.85
			elif companion_id == "bac_vuong":
				attack_timer = 0.92 if is_bv7_atk else 1.02
			elif companion_id == "thai_lan_tieu_tieu":
				attack_timer = 0.98
			elif companion_id == "van_van_hoa_tong":
				attack_timer = 1.05
			elif companion_id == "thanh_lan":
				attack_timer = 1.24
			elif companion_id == "thien_hoa_ton_gia":
				attack_timer = 1.18
			elif companion_id == "dia_yeu_khoi":
				attack_timer = 1.12 if is_tyk_atk else 1.28
			elif companion_id == "thai_lan":
				attack_timer = 1.22
			elif companion_id == "tu_nghien":
				attack_timer = 1.16 if is_lh_atk else 1.48
			elif companion_id == "huan_nhi":
				attack_timer = 1.04 if is_hn_st_atk else 1.32
			elif companion_id == "tieu_y_tien":
				attack_timer = 1.18 if is_tdn_t3_atk else (1.30 if is_tdn_atk else 1.65)
			else:
				attack_timer = 1.10 if is_bt_atk else 1.45
			body_sprite.flip_h = (target_en.global_position.x < global_position.x)
			var base_atk: float = PlayerData.get_atk() * bode_dan_mult
			var dmg_mult: float = 3.45 if companion_id == "chuc_khon_long_hoang" else (2.65 if is_bv7_atk else (2.15 if companion_id == "bac_vuong" else (1.92 if companion_id == "thai_lan_tieu_tieu" else (1.88 if is_hn_st_atk else (1.72 if is_bt_atk else (1.60 if is_lh_atk else (1.56 if companion_id == "van_van_hoa_tong" else (1.48 if companion_id == "thanh_lan" else (1.45 if is_tyk_atk else (1.32 if companion_id == "thien_hoa_ton_gia" else (1.24 if companion_id == "dia_yeu_khoi" else (1.22 if is_tdn_t3_atk else (1.06 if is_tdn_atk else (0.96 if companion_id == "tu_nghien" else (0.88 if companion_id == "thai_lan" else (0.78 if companion_id == "huan_nhi" else (0.48 if companion_id == "tieu_y_tien" else 0.62)))))))))))))))))
			var bolt_dmg: float = base_atk * dmg_mult
			var bolt_col: Color = Color("#C084FC") if companion_id == "chuc_khon_long_hoang" else (Color("#FFD700") if (companion_id == "bac_vuong" or is_hn_st_atk) else (Color.from_hsv(fmod(anim_t * 0.75, 1.0), 0.72, 1.0) if companion_id == "thai_lan_tieu_tieu" else (Color("#E0FBFC") if is_bt_atk else (Color("#FFC8DD") if companion_id == "van_van_hoa_tong" else (Color("#52B788") if companion_id == "thanh_lan" else (Color("#FFD166") if (is_tyk_atk or is_lh_atk) else (Color("#FF9F1C") if companion_id == "thien_hoa_ton_gia" else (Color("#90E0EF") if companion_id == "dia_yeu_khoi" else (Color("#E0AAFF") if is_tdn_atk else (Color("#C77DFF") if companion_id == "tu_nghien" else (Color.from_hsv(fmod(anim_t * 0.6, 1.0), 0.72, 1.0) if companion_id == "thai_lan" else (Color("#FFD166") if companion_id == "huan_nhi" else (Color("#52B788") if companion_id == "tieu_y_tien" else Color("#A8DADC"))))))))))))))
			var burn_v: float = bolt_dmg * 0.65 if companion_id == "chuc_khon_long_hoang" else (bolt_dmg * 0.55 if (companion_id == "bac_vuong" or is_hn_st_atk or companion_id == "thai_lan_tieu_tieu") else (bolt_dmg * 0.50 if is_bt_atk else (bolt_dmg * 0.44 if companion_id == "thien_hoa_ton_gia" else (bolt_dmg * 0.36 if is_tdn_atk else (bolt_dmg * 0.32 if companion_id == "thai_lan" else (base_atk * 0.28 if companion_id == "huan_nhi" else (bolt_dmg * 0.20 if companion_id == "duoc_lao_phantom" else 0.0)))))))
			var stun_s: float = 2.8 if companion_id == "chuc_khon_long_hoang" else (2.6 if is_bv7_atk else (2.2 if companion_id == "bac_vuong" else (2.4 if (companion_id == "thanh_lan" and PlayerData.has_flag("ch09_sq03_thanh_lan_serpent_done")) else (2.0 if companion_id == "thanh_lan" else (1.8 if is_bt_atk else ((1.8 if is_tyk_atk else 1.4) if companion_id == "dia_yeu_khoi" else ((2.5 if (is_lh_atk or PlayerData.has_flag("ch06_tu_nghien_candy_done")) else 1.5) if companion_id == "tu_nghien" else 0.0)))))))
			active_bolts.append({
				"pos": global_position + Vector2(0, -30),
				"trail": [global_position + Vector2(0, -30)],
				"target": target_en,
				"color": bolt_col,
				"dmg": bolt_dmg,
				"burn": burn_v,
				"stun": stun_s,
				"aoe": (companion_id in ["dia_yeu_khoi", "thien_hoa_ton_gia", "van_van_hoa_tong", "thanh_lan", "bac_vuong", "thai_lan_tieu_tieu", "chuc_khon_long_hoang"] or is_lh_atk or is_bt_atk or is_tdn_atk or is_hn_st_atk)
			})
			EventBus.audio_sfx_requested.emit("skill_burst" if (companion_id == "tu_nghien" or companion_id == "dia_yeu_khoi" or companion_id == "thien_hoa_ton_gia") else "skill_fire")

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
			var b_col_hit: Color = b.get("color", Color("#70D6FF"))
			VfxAssets.spawn_spark_burst(get_parent(), dest, Color.WHITE, b_col_hit, 10 if bool(b.get("aoe", false)) else 6, 70.0, 195.0, 0.28, to_t.normalized(), 160.0, 0.22, 0.52, true)
			if tgt.has_method("receive_hit"):
				var kb_str: float = 280.0 if float(b.get("stun", 0.0)) > 0.0 else 90.0
				tgt.receive_hit(float(b.get("dmg", 10.0)), to_t.normalized() * kb_str, 0.28, float(b.get("burn", 0.0)))
			var st_val: float = float(b.get("stun", 0.0))
			if st_val > 0.0 and tgt.has_method("apply_stun"):
				tgt.apply_stun(st_val)
				var stun_lbl: String = "BÍCH XÀ KHỐNG THÚ! CHOÁNG %.1fs" % st_val if companion_id == "thanh_lan" else ("CỐT LINH BĂNG PHONG! %.1fs" % st_val if companion_id == "duoc_lao_phantom" else ("ĐỊA YÊU LÔI QUYỀN! CHOÁNG %.1fs" % st_val if companion_id == "dia_yeu_khoi" else "CỔ LONG NHẤT QUYỀN! CHOÁNG %.1fs" % st_val))
				EventBus.floating_text_requested.emit(tgt.global_position + Vector2(0, -82), stun_lbl, Color("#80ED99") if companion_id == "thanh_lan" else (Color("#E0FBFC") if companion_id == "duoc_lao_phantom" else (Color("#CAF0F8") if companion_id == "dia_yeu_khoi" else Color("#E0AAFF"))))
			if bool(b.get("aoe", false)):
				# Địa Yêu Khôi, Thiên Hỏa Tôn Giả & Thiên Độc Nữ: nổ lan sóng chấn động / độc vụ quanh mục tiêu!
				for splash_n in get_tree().get_nodes_in_group("enemies"):
					if is_instance_valid(splash_n) and splash_n != tgt and splash_n is Node2D:
						var s2: Node2D = splash_n as Node2D
						if tgt.global_position.distance_to(s2.global_position) <= 130.0 and s2.has_method("receive_hit"):
							s2.receive_hit(float(b.get("dmg", 10.0)) * 0.55, (s2.global_position - tgt.global_position).normalized() * 160.0, 0.30, float(b.get("burn", 0.0)) * 0.6)
		else:
			var next_p: Vector2 = cur_p + to_t.normalized() * 540.0 * delta
			b["pos"] = next_p
			var tr: Array = b.get("trail", [])
			tr.append(next_p)
			if tr.size() > 8:
				tr.pop_front()
			b["trail"] = tr
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
	elif companion_id == "dia_yeu_khoi":
		var is_tyk_d: bool = PlayerData.has_flag("ch08_dan_hoi_champion")
		var s_pulse: float = 0.85 + 0.15 * sin(anim_t * 7.0)
		var dc: Color = Color(1.0, 0.84, 0.35, 0.82 * s_pulse) if is_tyk_d else Color(0.56, 0.88, 0.98, 0.72 * s_pulse)
		draw_arc(Vector2.ZERO, 28.0, -anim_t * 2.8, -anim_t * 2.8 + TAU * 0.90, 32, dc, 3.0)
	elif companion_id == "thien_hoa_ton_gia":
		var th_p: float = 0.86 + 0.14 * sin(anim_t * 6.0)
		draw_arc(Vector2.ZERO, 28.0, anim_t * 2.6, anim_t * 2.6 + TAU * 0.92, 36, Color(1.0, 0.62, 0.12, 0.78 * th_p), 3.0)
	elif companion_id == "tieu_y_tien" and PlayerData.has_flag("ch07_thien_doc_nu_joined"):
		var v_pulse: float = 0.82 + 0.18 * sin(anim_t * 5.5)
		draw_arc(Vector2.ZERO, 26.0, anim_t * 2.0, anim_t * 2.0 + TAU * 0.85, 32, Color(0.84, 0.48, 1.0, 0.64 * v_pulse), 2.8)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Ngũ Luân Ly Hỏa Pháp (VFX 2.0): 5 đĩa hỏa luân xoay nghiêng giả lập 3D phát tàn lửa quanh Thiên Hỏa Tôn Giả!
	if companion_id == "thien_hoa_ton_gia":
		var ring_cols: Array = [Color("#FF595E"), Color("#FF9F1C"), Color("#FFD166"), Color("#FF6B35"), Color("#FFF3B0")]
		for ri in range(5):
			var ra: float = anim_t * 3.2 + float(ri) * (TAU / 5.0)
			var depth_s: float = 0.78 + 0.28 * sin(ra)
			var rp := Vector2(cos(ra) * 38.0, -38.0 + sin(ra) * 15.0)
			var rc: Color = ring_cols[ri]
			draw_set_transform(rp, anim_t * 4.5 + float(ri), Vector2(depth_s, depth_s * 0.62))
			draw_circle(Vector2.ZERO, 10.5, Color(rc.r, rc.g, rc.b, 0.26))
			draw_arc(Vector2.ZERO, 9.2, 0.0, TAU, 20, Color(rc.r, rc.g, rc.b, 0.92), 2.8)
			draw_arc(Vector2.ZERO, 6.0, anim_t * 5.0, anim_t * 5.0 + TAU * 0.65, 14, Color(1.0, 0.96, 0.78, 0.95), 1.8)
			for sp in range(3):
				var sa: float = anim_t * 6.0 + float(sp) * (TAU / 3.0)
				draw_line(Vector2(cos(sa), sin(sa)) * 5.0, Vector2(cos(sa), sin(sa)) * 11.5, Color(1.0, 0.94, 0.70, 0.85), 1.4)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Đạn đồng hành VFX 2.0: Vệt đuôi năng lượng thuôn nhọn mượt mà + lõi sáng rực!
	for b in active_bolts:
		var local_p: Vector2 = (b.get("pos", global_position) as Vector2) - global_position
		var col: Color = b.get("color", Color("#70D6FF"))
		var tr: Array = b.get("trail", [])
		if tr.size() >= 2:
			for ti in range(tr.size() - 1):
				var u: float = float(ti + 1) / float(tr.size())
				var p_a: Vector2 = (tr[ti] as Vector2) - global_position
				var p_b: Vector2 = (tr[ti + 1] as Vector2) - global_position
				draw_line(p_a, p_b, Color(col.r, col.g, col.b, 0.55 * u), (9.5 if companion_id == "thien_hoa_ton_gia" else 7.2) * u)
				draw_line(p_a, p_b, Color(1.0, 1.0, 1.0, 0.72 * u), 2.8 * u)
		draw_circle(local_p, 11.5 if (companion_id == "huan_nhi" or companion_id == "thien_hoa_ton_gia") else 9.0, Color(col.r, col.g, col.b, 0.44))
		draw_circle(local_p, 5.6 if (companion_id == "huan_nhi" or companion_id == "thien_hoa_ton_gia") else 4.6, col)
		draw_circle(local_p, 2.6, Color.WHITE)
