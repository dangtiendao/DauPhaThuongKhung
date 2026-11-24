class_name BossRushManager
extends RefCounted
## Quản lý Phó bản Tâm Ma Luyện Cảnh — Boss Rush Arena (tách từ WorldStageManager):
## - Tái đấu toàn bộ Boss ở các độ khó (Thường / Ác Mộng / Đấu Tông), chấm hạng C -> SSS & trao thưởng Đá Cường Hóa + Kim Tệ.

var world: Node2D
var is_active: bool = false
var boss_id: String = ""
var diff: String = "normal"
var elapsed: float = 0.0
var dmg_taken: float = 0.0
var return_map: String = "ch01_tieu_gia"
var return_pos: Vector2 = Vector2(340, 520)
var boss_node: Node2D = null
var _session_token: int = 0


func _init(stage_ref: Node2D) -> void:
	world = stage_ref


func reset_state() -> void:
	is_active = false
	boss_node = null
	_session_token += 1


func tick(delta: float) -> void:
	if is_active:
		elapsed += delta


func get_diff_label(diff_key: String) -> String:
	if diff_key == "normal":
		return "Thường"
	elif diff_key == "nightmare":
		return "Ác Mộng"
	elif diff_key == "dau_tong":
		return "Đấu Tông"
	elif diff_key == "di_hoa":
		return "Dị Hỏa"
	return "Địa Ngục"


func record_player_damage(amount: float) -> void:
	if is_active and amount > 0.0:
		dmg_taken += amount


func start_boss_rush(target_boss_id: String, diff_key: String = "normal") -> void:
	var b_def: Dictionary = GameDatabase.get_enemy_def(target_boss_id)
	if b_def.is_empty():
		return

	if world.tower_mgr != null and world.tower_mgr.is_active:
		var saved_t_map: String = world.tower_mgr.return_map
		var saved_t_pos: Vector2 = world.tower_mgr.return_pos
		world.tower_mgr.reset_state(true)
		return_map = saved_t_map if (saved_t_map != "" and saved_t_map != "thien_phan_thap") else GameDatabase.start_map_id
		return_pos = saved_t_pos if saved_t_pos != Vector2.ZERO else Vector2(340.0, 520.0)
	elif not is_active and world.current_map_id != "tam_ma_luyen_canh":
		return_map = world.current_map_id if world.current_map_id != "" else GameDatabase.start_map_id
		return_pos = world.player_node.global_position if world.player_node != null else Vector2(340.0, 520.0)

	_session_token += 1
	is_active = true
	boss_id = target_boss_id
	diff = diff_key
	elapsed = 0.0
	dmg_taken = 0.0
	boss_node = null

	var diff_label: String = get_diff_label(diff_key)
	var boss_name: String = str(b_def.get("name", target_boss_id))
	var arena_def: Dictionary = {
		"id": "tam_ma_luyen_canh",
		"name": "Tâm Ma Luyện Cảnh",
		"bgm": "bgm_boss",
		"size": [1280, 896],
		"ambient_hex": "#a8b0d8",
		"base_tile": "res://assets/sprites/tiles/arena_violet.png",
		"zones": [
			{
				"rect": [192, 128, 896, 640],
				"tile": "res://assets/sprites/tiles/arena_violet.png",
				"border_hex": "#C77DFF",
				"arena_circle": true
			}
		],
		"signs": [
			{
				"pos": [420, 80],
				"text": "TÂM MA LUYỆN CẢNH — %s (%s)" % [boss_name.to_upper(), diff_label],
				"color": "#E0AAFF"
			}
		],
		"props": [
			{ "type": "lantern", "pos": [140, 160] },
			{ "type": "lantern", "pos": [1140, 160] },
			{ "type": "lantern", "pos": [140, 760] },
			{ "type": "lantern", "pos": [1140, 760] }
		],
		"chests": [],
		"portals": [],
		"npcs": [],
		"spawns": []
	}

	world.setup_arena_stage(arena_def, Vector2(340.0, 448.0))

	var boss_inst: CharacterBody2D = world.ENEMY_SCENE.instantiate() as CharacterBody2D
	world.entities_root.add_child(boss_inst)
	var boss_pos := Vector2(920.0, 448.0)
	if boss_inst.has_method("configure_enemy"):
		boss_inst.configure_enemy(target_boss_id, boss_pos)
	if boss_inst.has_method("configure_boss_rush"):
		boss_inst.configure_boss_rush(diff_key)
	boss_node = boss_inst

	EventBus.audio_sfx_requested.emit("portal_warp")
	EventBus.bgm_requested.emit("bgm_boss")
	EventBus.map_changed.emit("tam_ma_luyen_canh", "Tâm Ma Luyện Cảnh — %s" % diff_label)
	EventBus.banter_triggered.emit("TÂM MA LUYỆN CẢNH [%s]: Đối đầu [%s] — Kết liễu nhanh & né đòn hoàn hảo để đạt hạng SSS!" % [diff_label, boss_name])
	if world.player_node != null:
		EventBus.floating_text_requested.emit(world.player_node.global_position + Vector2(0, -84), "TÂM MA KHAI CHIẾN!", Color("#E0AAFF"))
	world.queue_redraw()


func on_boss_defeated(defeated_id: String) -> void:
	if not is_active or defeated_id != boss_id:
		return

	var res: Dictionary = PlayerData.record_boss_rush_clear(boss_id, diff, elapsed, dmg_taken)
	is_active = false
	boss_node = null

	var grade_str: String = str(res["grade"])
	var rew_stones: int = int(res["stones"])
	var rew_gold: int = int(res["gold"])
	var elapsed_final: float = elapsed
	var diff_label: String = get_diff_label(diff)
	var b_def: Dictionary = GameDatabase.get_enemy_def(defeated_id)
	var boss_name: String = str(b_def.get("name", defeated_id))

	EventBus.boss_rush_completed.emit(boss_id, diff, grade_str, elapsed_final, rew_stones, rew_gold)
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.screen_shake_requested.emit(7.5, 0.28)
	if world.player_node != null:
		EventBus.floating_text_requested.emit(world.player_node.global_position + Vector2(0, -92), "HẠNG %s!" % grade_str, Color("#FFD166"))
	EventBus.banter_triggered.emit("TÂM MA LUYỆN CẢNH THẮNG LỢI! Hạ [%s · %s] trong %.1fs — Hạng [%s] (+%d Đá CH · +%d Kim Tệ)!" % [
		boss_name, diff_label, elapsed_final, grade_str, rew_stones, rew_gold
	])

	var token: int = _session_token
	world.get_tree().create_timer(2.2).timeout.connect(func() -> void:
		if world != null and world.is_inside_tree() and not is_active and token == _session_token and world.current_map_id == "tam_ma_luyen_canh":
			exit_boss_rush()
	)


func exit_boss_rush() -> void:
	reset_state()
	var ret_map: String = return_map if (return_map != "" and return_map != "tam_ma_luyen_canh") else GameDatabase.start_map_id
	world.load_map(ret_map, return_pos, false)


func on_player_died() -> bool:
	if not is_active:
		return false
	PlayerData.recalculate_and_clamp(true)
	EventBus.stats_changed.emit()
	EventBus.audio_sfx_requested.emit("alchemy_fail")
	if world.player_node != null:
		EventBus.floating_text_requested.emit(world.player_node.global_position + Vector2(0, -82), "TÂM MA BẠI TRẬN!", Color("#FF4D6D"))
	EventBus.banter_triggered.emit("Thất bại trong Tâm Ma Luyện Cảnh! Tâm ma tan biến — Tiêu Viêm điều tức hồi đầy sinh lực và trở về vị trí cũ.")
	exit_boss_rush()
	return true
