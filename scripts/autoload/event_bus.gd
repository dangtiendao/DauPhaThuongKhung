extends Node
## Kênh sự kiện toàn cục (EventBus) giúp UI, Âm thanh, Bản đồ, Boss, Đồng hành, Nhân vật & Quái giao tiếp mượt mà.

signal stats_changed()
signal qi_updated(current_qi: float, max_qi: float)
signal exp_changed(current_exp: int, required_exp: int)
signal realm_updated(realm_title: String, unlock_text: String)
signal flame_changed(flame_id: String)
signal equipment_changed()
signal skills_updated()
signal story_flag_changed(flag_name: String)
signal map_changed(map_id: String, map_title: String)
signal dialogue_requested(speaker: String, avatar_path: String, lines: Array, finish_action: String)
signal dialogue_choice_requested(speaker: String, avatar_path: String, lines: Array, choices: Array)
signal shop_requested()
signal weight_seal_toggled(is_sealed: bool)
signal inventory_changed()
signal quest_updated()
signal banter_triggered(message: String)
signal floating_text_requested(world_pos: Vector2, text_value: String, text_color: Color)
signal screen_shake_requested(strength: float, duration: float)
signal skill_cooldown_updated(slot_key: String, remaining: float, total: float)
signal enemy_killed(enemy_id: String, is_boss: bool)
signal boss_status_updated(boss_name: String, realm_badge: String, cur_hp: float, max_hp: float, phase: int, visible_bar: bool)
signal boss_poise_updated(cur_poise: float, max_poise: float, staggered: bool, phase2_warning: bool)
signal boss_rush_requested(boss_id: String, difficulty: String)
signal boss_rush_completed(boss_id: String, difficulty: String, grade: String, elapsed_sec: float, reward_stones: int, reward_gold: int)
signal tower_start_requested(start_floor: int)
signal tower_state_updated(floor_num: int, enemies_left: int, enemies_total: int, heat_dps: float, active: bool)
signal tower_blessing_requested(floor_num: int, choices: Array)
signal tower_blessing_picked(blessing_id: String)
signal tower_exit_requested()
signal auction_requested(venue_id: String)
signal soul_radar_pulsed(origin: Vector2, radius_px: float)
signal keybinds_changed()
signal display_settings_changed()
signal chest_opened(chest_id: String)
signal companion_changed(companion_id: String)
signal audio_sfx_requested(sfx_name: String)
signal bgm_requested(track_name: String)
signal auto_saved(slot_idx: int, reason: String)

# Hitstop toàn cục an toàn theo đồng hồ thực (tự trả Engine.time_scale về 1.0 dù tạm dừng hay đổi map)
var _hitstop_end_usec: int = 0
var _hitstop_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func trigger_hitstop(duration_sec: float, scale: float = 0.08) -> void:
	if duration_sec <= 0.0:
		return
	var now_usec: int = Time.get_ticks_usec()
	var target_end: int = now_usec + int(duration_sec * 1_000_000.0)
	_hitstop_end_usec = maxi(_hitstop_end_usec, target_end)
	if not _hitstop_active or scale < Engine.time_scale:
		Engine.time_scale = clampf(scale, 0.02, 1.0)
	_hitstop_active = true


func _process(_delta: float) -> void:
	if not _hitstop_active:
		return
	if get_tree().paused or Time.get_ticks_usec() >= _hitstop_end_usec:
		Engine.time_scale = 1.0
		_hitstop_active = false
		_hitstop_end_usec = 0
