extends CanvasLayer
## Giao Diện HUD Phong Cách MOBA / Tiên Hiệp Cao Cấp (1280x720 HD):
## - Góc Trái Trên: Khung chân dung Tiêu Viêm + Thanh HP/QI/EXP có số trực tiếp & hiệu ứng trượt mượt.
## - Giữa Trên: Biển tên Chương/Bản Đồ + Thanh Máu BOSS Đa Phase (tự hiện khi vào tầm đánh Boss).
## - Góc Phải Trên: Khung Nhiệm Vụ gọn gàng.
## - Góc Trái Dưới: Cụm 8 nút Hệ Thống bấm trực tiếp ([I] Đồ, [K] Kỹ, [B] Đột Phá, [L] Đan, [H] Hỏa, [M] Map, [ESC], [F5]).
## - Giữa Dưới: Thanh Chiêu Thức & Vật Phẩm MOBA bấm được bằng chuột lẫn phím tắt ([LMB][Q][E][R][F][T] | [SPC][C][G][V] | [1][2][3])
##   kèm lớp phủ hồi chiêu quét dọc thời gian thực & Tooltip chi tiết khi di chuột!
## - Góc Phải Dưới: Tiểu Bản Đồ Thời Gian Thực (Live Mini-Map).

const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const PanelPauseSettingsScript = preload("res://scripts/ui/panels/panel_pause_settings.gd")
const PanelWorldMapBestiaryScript = preload("res://scripts/ui/panels/panel_world_map_bestiary.gd")
const PanelTowerBossRushScript = preload("res://scripts/ui/panels/panel_tower_boss_rush.gd")
const PanelAlchemyScript = preload("res://scripts/ui/panels/panel_alchemy.gd")
const PanelAuctionScript = preload("res://scripts/ui/panels/panel_auction.gd")
const PanelEquipmentScript = preload("res://scripts/ui/panels/panel_equipment.gd")
const PanelSkillsCultivationScript = preload("res://scripts/ui/panels/panel_skills_cultivation.gd")
const PanelEndingCreditsScript = preload("res://scripts/ui/panels/panel_ending_credits.gd")
const PanelAchievementsScript = preload("res://scripts/ui/panels/panel_achievements.gd")
const HudMobaDock = preload("res://scripts/ui/panels/hud_moba_dock_helper.gd")
const HudDialogueCtrl = preload("res://scripts/ui/panels/hud_dialogue_controller.gd")

# 9 Panel UI mô-đun tách biệt (scripts/ui/panels/)
var panel_pause_settings: RefCounted
var panel_world_map_bestiary: RefCounted
var panel_tower_boss_rush: RefCounted
var panel_alchemy: RefCounted
var panel_auction: RefCounted
var panel_equipment: RefCounted
var panel_skills_cultivation: RefCounted
var panel_ending_credits: RefCounted
var panel_achievements: RefCounted

# Khung trạng thái góc trái trên (lerp mượt)
var hp_bar: ProgressBar
var qi_bar: ProgressBar
var exp_bar: ProgressBar
var hp_val_lbl: Label
var qi_val_lbl: Label
var realm_lbl: Label
var currency_lbl: Label
var sub_stat_lbl: Label
var target_hp_val: float = 130.0
var target_qi_val: float = 70.0
var target_exp_val: float = 0.0
var target_boss_hp: float = 0.0
var target_boss_poise: float = 0.0

var map_banner_lbl: Label
var quest_lbl: Label
var banter_lbl: Label

# Thanh máu BOSS Đa Phase + Thanh Phá Thế (Poise / Stagger)
var boss_bar_panel: PanelContainer
var boss_title_lbl: Label
var boss_phase_lbl: Label
var boss_hp_bar: ProgressBar
var boss_poise_bar: ProgressBar
var boss_poise_lbl: Label
var boss_is_staggered: bool = false
var boss_p2_warning: bool = false
var boss_pulse_t: float = 0.0

# Chỉ báo FPS góc phải trên (bật/tắt trong [ESC] Cài Đặt Hiển Thị)
var fps_panel: PanelContainer
var fps_lbl: Label
var fps_poll_accum: float = 0.0

# Thanh trạng thái Thiên Phần Luyện Khí Tháp (Roguelite)
var tower_bar_panel: PanelContainer
var tower_info_lbl: Label
var pending_tower_floor: int = 1
var pending_tower_choices: Array = []

# Trạng thái Đấu Giá Đấu Trí, Ký Gửi, Đổi Phím & Khảm Ma Hạch
var shop_tab: String = "shop" # "shop" | "auction" | "consign"
var shop_venue_id: String = "nha_phi" # "nha_phi" | "bat_phien_mon"
var auction_lots: Array = []
var active_auction_lot_idx: int = 0
var rebinding_action: String = ""
var selected_core_slot: int = 0

# Tiểu Bản Đồ góc phải dưới
var minimap_panel: PanelContainer
var minimap_widget: MinimapWidget

# Các nút MOBA bấm trực tiếp
var slot_lmb: MobaSlotButton
var skill_slots: Dictionary = {} # "Q", "E", "R", "F", "T" -> MobaSlotButton
var slot_dash: MobaSlotButton
var slot_weight: MobaSlotButton
var slot_companion: MobaSlotButton
var slot_interact: MobaSlotButton
var pill_slots: Array[MobaSlotButton] = []
var sys_buttons: Dictionary = {} # "I","K","B","L","H","M","ESC","F5" -> MobaSlotButton

# Tooltip nổi phong cách MOBA
var tooltip_panel: PanelContainer
var tt_title_lbl: Label
var tt_sub_lbl: Label
var tt_desc_lbl: Label

# Cửa sổ đa năng trung tâm
var modal_dim_bg: ColorRect
var modal_panel: PanelContainer
var modal_title_lbl: Label
var modal_content_host: Control
var modal_status_lbl: Label
var current_modal: String = ""

# Hộp Thoại NPC Cốt Truyện
var dialogue_panel: PanelContainer
var dlg_avatar_rect: TextureRect
var dlg_speaker_lbl: Label
var dlg_body_lbl: Label
var dlg_next_btn: Button
var dlg_choices_vbox: VBoxContainer
var dialogue_active: bool = false
var dialogue_lines: Array = []
var dialogue_index: int = 0
var dialogue_finish_action: String = ""
var dialogue_choices: Array = []

# Mini-Game Lò Luyện Đan (Khống Hỏa + Đón Đan Lôi — có thưởng Dị Hỏa, Dược Đỉnh, SOUL & Tiểu Y Tiên!)
var alc_active: bool = false
var alc_recipe: Dictionary = {}
var alc_time_left: float = 0.0
var alc_duration: float = 5.0
var alc_heat: float = 52.0
var alc_in_zone_sec: float = 0.0
var alc_zone_min: float = 38.0
var alc_zone_max: float = 66.0
var alc_cool_mult: float = 1.0
var alc_perfect_req: float = 0.62
var alc_pass_req: float = 0.28
var alc_bonus_summary: String = ""
var alc_lightning_pending: bool = false
var alc_lightning_triggered: bool = false
var alc_lightning_window: float = 0.0
var alc_lightning_blocked: bool = false
var alc_heat_bar: ProgressBar
var alc_progress_bar: ProgressBar
var alc_info_lbl: Label
var alc_lightning_btn: Button
var alc_pulse_btn: Button

var world_map_tab: String = "maps" # "maps" | "heroines" | "boss_rush" | "bestiary" | "tower" | "pan_gate" | "achievements"
var selected_gift_heroine: String = "huan_nhi"
var boss_rush_diff: String = "normal" # "normal" | "nightmare" | "dau_tong"
var bestiary_filter: String = "all" # "all" | "boss" | "mob"
var achievements_filter: String = "all" # "all" | "story" | "grind"
var _bestiary_thumb_cache: Dictionary = {}

var interact_poll_accum: float = 0.0
var last_nearby_interact: String = "__init__"

# Cache icon & theo dõi hồi Đấu Khí nhẹ (cắt bỏ hoàn toàn bão _refresh_moba_dock 60Hz!)
var _icon_cache: Dictionary = {}
var _last_qi_display: int = -1
var _last_max_qi_display: int = -1
var _slot_qi_costs: Dictionary = {}

# Chỉ báo Tự Động Lưu nhẹ góc trái dưới
var autosave_toast_panel: PanelContainer
var autosave_toast_lbl: Label
var autosave_toast_timer: float = 0.0


func _exit_tree() -> void:
	for p in [panel_pause_settings, panel_world_map_bestiary, panel_tower_boss_rush, panel_alchemy, panel_auction, panel_equipment, panel_skills_cultivation, panel_ending_credits, panel_achievements]:
		if p != null:
			p.hud = null
	panel_pause_settings = null
	panel_world_map_bestiary = null
	panel_tower_boss_rush = null
	panel_alchemy = null
	panel_auction = null
	panel_equipment = null
	panel_skills_cultivation = null
	panel_ending_credits = null
	panel_achievements = null


func _ready() -> void:
	panel_pause_settings = PanelPauseSettingsScript.new(self)
	panel_world_map_bestiary = PanelWorldMapBestiaryScript.new(self)
	panel_tower_boss_rush = PanelTowerBossRushScript.new(self)
	panel_alchemy = PanelAlchemyScript.new(self)
	panel_auction = PanelAuctionScript.new(self)
	panel_equipment = PanelEquipmentScript.new(self)
	panel_skills_cultivation = PanelSkillsCultivationScript.new(self)
	panel_ending_credits = PanelEndingCreditsScript.new(self)
	panel_achievements = PanelAchievementsScript.new(self)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_hud_layout()
	_refresh_all()

	# Khởi tạo giá trị thanh ban đầu không bị giật
	hp_bar.value = target_hp_val
	qi_bar.value = target_qi_val
	exp_bar.value = target_exp_val

	_refresh_current_map_banner()

	EventBus.stats_changed.connect(_refresh_stats)
	EventBus.qi_updated.connect(_on_qi_updated)
	EventBus.exp_changed.connect(_on_exp_changed)
	EventBus.realm_updated.connect(_on_realm_updated)
	EventBus.inventory_changed.connect(_refresh_inventory_ui)
	EventBus.equipment_changed.connect(_on_equipment_changed)
	EventBus.skills_updated.connect(_on_skills_updated)
	EventBus.story_flag_changed.connect(_on_story_flag_changed)
	EventBus.map_changed.connect(_on_map_changed)
	EventBus.dialogue_requested.connect(_open_dialogue)
	EventBus.dialogue_choice_requested.connect(_open_choice_dialogue)
	EventBus.shop_requested.connect(_open_nha_phi_shop)
	EventBus.quest_updated.connect(_refresh_quest_ui)
	EventBus.banter_triggered.connect(_on_banter)
	EventBus.flame_changed.connect(_on_flame_changed)
	EventBus.weight_seal_toggled.connect(_on_seal_toggled)
	EventBus.boss_status_updated.connect(_on_boss_status_updated)
	EventBus.boss_poise_updated.connect(_on_boss_poise_updated)
	EventBus.boss_rush_completed.connect(_on_boss_rush_completed)
	EventBus.tower_state_updated.connect(_on_tower_state_updated)
	EventBus.tower_blessing_requested.connect(_on_tower_blessing_requested)
	EventBus.auction_requested.connect(_open_auction_house)
	EventBus.keybinds_changed.connect(_sync_keybind_labels)
	EventBus.display_settings_changed.connect(_sync_display_widgets)
	EventBus.companion_changed.connect(_on_companion_changed)
	EventBus.skill_cooldown_updated.connect(_on_skill_cooldown_updated)
	EventBus.auto_saved.connect(_on_auto_saved)
	_sync_display_widgets()
	_sync_keybind_labels()


func _process(delta: float) -> void:
	# Hiệu ứng trượt thanh HP / Đấu Khí / EXP / Boss & Thanh Phá Thế cực mượt
	var smooth_k: float = clampf(delta * 12.0, 0.0, 1.0)
	if hp_bar != null:
		hp_bar.value = lerpf(hp_bar.value, target_hp_val, smooth_k)
	if qi_bar != null:
		qi_bar.value = lerpf(qi_bar.value, target_qi_val, smooth_k)
	if exp_bar != null:
		exp_bar.value = lerpf(exp_bar.value, target_exp_val, smooth_k)
	if boss_hp_bar != null and boss_bar_panel.visible:
		boss_hp_bar.value = lerpf(boss_hp_bar.value, target_boss_hp, smooth_k)
	if boss_poise_bar != null and boss_bar_panel.visible:
		boss_poise_bar.value = lerpf(boss_poise_bar.value, target_boss_poise, clampf(delta * 15.0, 0.0, 1.0))
		if boss_is_staggered or boss_p2_warning:
			boss_pulse_t += delta * 9.5
			var pulse_a: float = 0.68 + 0.32 * sin(boss_pulse_t)
			if boss_poise_lbl != null:
				boss_poise_lbl.modulate.a = pulse_a
			if boss_p2_warning and boss_phase_lbl != null:
				boss_phase_lbl.modulate.a = pulse_a
		else:
			if boss_poise_lbl != null:
				boss_poise_lbl.modulate.a = 1.0
			if boss_phase_lbl != null:
				boss_phase_lbl.modulate.a = 1.0

	if fps_panel != null and fps_panel.visible:
		fps_poll_accum += delta
		if fps_poll_accum >= 0.25:
			fps_poll_accum = 0.0
			var cur_fps: int = Engine.get_frames_per_second()
			fps_lbl.text = "FPS: %d" % cur_fps
			var fps_col: Color = Color("#80ED99") if cur_fps >= 55 else (Color("#FFD166") if cur_fps >= 35 else Color("#FF4D6D"))
			fps_lbl.add_theme_color_override("font_color", fps_col)

	if alc_active:
		_tick_alchemy_minigame(delta)

	if autosave_toast_timer > 0.0 and autosave_toast_panel != null:
		autosave_toast_timer -= delta
		if autosave_toast_timer <= 0.0:
			autosave_toast_panel.visible = false
		elif autosave_toast_timer < 0.5:
			autosave_toast_panel.modulate.a = clampf(autosave_toast_timer / 0.5, 0.0, 1.0)
		else:
			autosave_toast_panel.modulate.a = 1.0

	# Cập nhật phát sáng cho nút [V] Tương tác khi tiến gần NPC / Rương / Cổng
	interact_poll_accum += delta
	if interact_poll_accum >= 0.12:
		interact_poll_accum = 0.0
		_refresh_interact_button()


func _unhandled_input(event: InputEvent) -> void:
	if rebinding_action != "":
		if event is InputEventKey and event.pressed and not event.echo:
			var k_ev: InputEventKey = event as InputEventKey
			if k_ev.physical_keycode == KEY_ESCAPE:
				rebinding_action = ""
				modal_status_lbl.text = "Đã hủy đổi phím."
			else:
				AudioManager.rebind_action_key(rebinding_action, k_ev.physical_keycode)
				modal_status_lbl.text = "Đã gán phím [%s] thành công!" % AudioManager.get_action_key_label(rebinding_action)
				rebinding_action = ""
			AudioManager.play_sfx("ui_click")
			_populate_modal()
			get_viewport().set_input_as_handled()
			return
		return

	if alc_active:
		if event.is_action_pressed("dash"):
			_alchemy_pulse_heat()
			get_viewport().set_input_as_handled()
			return
		elif event.is_action_pressed("skill_e") and alc_lightning_window > 0.0:
			_alchemy_block_lightning()
			get_viewport().set_input_as_handled()
			return
		return

	if dialogue_active:
		var is_enter: bool = (event is InputEventKey and event.pressed and (event.physical_keycode == KEY_ENTER or event.physical_keycode == KEY_KP_ENTER))
		if event.is_action_pressed("interact") or event.is_action_pressed("dash") or is_enter:
			# Nếu đang ở dòng cuối có lựa chọn nhánh thì để người chơi bấm chuột chọn phương án!
			if not (dialogue_choices.size() > 0 and dialogue_index >= dialogue_lines.size() - 1):
				_advance_dialogue()
			get_viewport().set_input_as_handled()
			return
		elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
			_close_dialogue(false)
			get_viewport().set_input_as_handled()
			return
		return

	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		if current_modal == "tower_blessing":
			get_viewport().set_input_as_handled()
			return
		if current_modal != "":
			_close_modal()
		else:
			_toggle_modal("pause")
		get_viewport().set_input_as_handled()
		return

	if current_modal == "pause" or current_modal == "tower_blessing":
		return

	if event.is_action_pressed("panel_equipment"):
		_toggle_modal("equipment")
	elif event.is_action_pressed("panel_skills"):
		_toggle_modal("skills")
	elif event.is_action_pressed("panel_breakthrough"):
		_toggle_modal("breakthrough")
	elif event.is_action_pressed("toggle_world_map"):
		_toggle_modal("world_map")
	elif event.is_action_pressed("panel_alchemy"):
		_try_open_alchemy()
	elif event.is_action_pressed("panel_flames"):
		_try_open_flames()
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_F5:
		_quick_save()
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_F9:
		if PlayerData.load_game(PlayerData.active_save_slot):
			_sync_world_after_load()
			_refresh_all()
			_on_banter("Hệ thống: Đã tải lại Ô Lưu %d thành công!" % PlayerData.active_save_slot)


func _try_open_alchemy() -> void:
	if not PlayerData.is_alchemy_unlocked():
		AudioManager.play_sfx("alchemy_fail")
		_on_banter("Lò Luyện Đan [L] chưa mở! Hãy giải quyết Từ Hôn rồi lên Vách Đá Hậu Sơn bái sư Dược Lão trước!")
		return
	_toggle_modal("alchemy")


func _try_open_flames() -> void:
	if not PlayerData.is_flames_unlocked():
		AudioManager.play_sfx("alchemy_fail")
		_on_banter("Bảng Dị Hỏa [H] chưa mở! Hãy bái sư Dược Lão tại Hậu Sơn để đánh thức Hỏa thuộc tính!")
		return
	_toggle_modal("flames")


func _quick_save() -> void:
	if PlayerData.save_game(PlayerData.active_save_slot):
		_on_banter("Hệ thống: Đã lưu nhanh vào Ô Lưu %d!" % PlayerData.active_save_slot)


func _find_player() -> Node:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	return players[0] if not players.is_empty() else null


func _find_world() -> Node:
	var worlds: Array[Node] = get_tree().get_nodes_in_group("world_stage")
	return worlds[0] if not worlds.is_empty() else null


func _sync_world_after_load() -> void:
	var w: Node = _find_world()
	if w != null and w.has_method("load_map"):
		var sp: Vector2 = Vector2.ZERO
		if PlayerData.has_saved_player_pos and PlayerData.saved_player_pos != Vector2.ZERO:
			sp = PlayerData.saved_player_pos
			PlayerData.has_saved_player_pos = false
		w.load_map(PlayerData.current_map_id, sp, false)


func _on_auto_saved(slot_idx: int, reason: String) -> void:
	if autosave_toast_panel == null or autosave_toast_lbl == null:
		return
	autosave_toast_lbl.text = "● Đã tự động lưu (Ô %d · %s)" % [slot_idx, reason]
	autosave_toast_panel.modulate.a = 1.0
	autosave_toast_panel.visible = true
	autosave_toast_timer = 2.4


func _sync_player_input_block() -> void:
	get_tree().paused = (current_modal == "pause")
	var blocked: bool = (current_modal != "" or dialogue_active)
	var p: Node = _find_player()
	if p != null and "input_blocked_by_ui" in p:
		p.set("input_blocked_by_ui", blocked)
	if not blocked:
		var w: Node = _find_world()
		if w != null and "interact_cooldown" in w:
			w.set("interact_cooldown", 0.25)


# =========================================================
# DỰNG TOÀN BỘ BỐ CỤC HUD MỊN MÀNG CHUẨN MOBA / ARPG
# =========================================================
func _build_hud_layout() -> void:
	var root_ctrl := Control.new()
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_ctrl)

	# 1. KHUNG CHÂN DUNG & CHỈ SỐ TIÊU VIÊM (GÓC TRÁI TRÊN — GỌN SẠCH, CÓ SỐ TRÊN THANH)
	var top_left := _make_styled_panel(Color(0.05, 0.07, 0.12, 0.90), Color("#2EC4B6"), 2, 8, 9)
	top_left.anchor_left = 0.0
	top_left.anchor_top = 0.0
	top_left.offset_left = 14
	top_left.offset_top = 12
	top_left.custom_minimum_size = Vector2(394, 106)
	root_ctrl.add_child(top_left)

	var tl_hbox := HBoxContainer.new()
	tl_hbox.add_theme_constant_override("separation", 10)
	top_left.add_child(tl_hbox)

	# Khung chân dung nhân vật Tiêu Viêm
	var hero_frame := _make_styled_panel(Color(0.09, 0.11, 0.18, 0.96), Color("#FFD166"), 2, 3, 8)
	hero_frame.custom_minimum_size = Vector2(74, 86)
	tl_hbox.add_child(hero_frame)

	var hero_tex := TextureRect.new()
	var idle_sheet: Texture2D = load("res://assets/sprites/player/tieu_viem_idle.png")
	if idle_sheet != null:
		var idle_m: Dictionary = SpriteAnimHelper.inspect_sheet(idle_sheet, "square", 1, 1)
		if int(idle_m.get("total_frames", 1)) > 1:
			var portrait_atlas := AtlasTexture.new()
			portrait_atlas.atlas = idle_sheet
			portrait_atlas.region = Rect2(0, 0, float(idle_m.get("cell_w", 96)), float(idle_m.get("cell_h", 96)))
			hero_tex.texture = portrait_atlas
		else:
			hero_tex.texture = idle_sheet
	hero_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_tex.custom_minimum_size = Vector2(66, 78)
	hero_frame.add_child(hero_tex)

	var tl_vbox := VBoxContainer.new()
	tl_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tl_vbox.add_theme_constant_override("separation", 4)
	tl_hbox.add_child(tl_vbox)

	var hdr_row := HBoxContainer.new()
	tl_vbox.add_child(hdr_row)

	realm_lbl = _make_label("Đấu Chi Khí — 3 Đoạn", 13, Color("#FFD166"))
	realm_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hdr_row.add_child(realm_lbl)

	currency_lbl = _make_label("35V · 0Đ", 11, Color("#FFE599"))
	hdr_row.add_child(currency_lbl)

	# Thanh HP có chữ trực tiếp ở giữa
	hp_bar = _make_bar(Color("#E63946"), 17, 290)
	hp_val_lbl = _make_bar_overlay_label("206 / 206")
	hp_bar.add_child(hp_val_lbl)
	tl_vbox.add_child(hp_bar)

	# Thanh Đấu Khí có chữ trực tiếp ở giữa
	qi_bar = _make_bar(Color("#38BDF8"), 15, 290)
	qi_val_lbl = _make_bar_overlay_label("92 / 92")
	qi_bar.add_child(qi_val_lbl)
	tl_vbox.add_child(qi_bar)

	# Thanh EXP mảnh mượt
	exp_bar = _make_bar(Color("#52B788"), 8, 290)
	tl_vbox.add_child(exp_bar)

	sub_stat_lbl = _make_label("ATK 32 · DEF 20 · Tay Không · Hỏa: Chưa mở", 10, Color("#CED4DA"))
	tl_vbox.add_child(sub_stat_lbl)

	# 2. BIỂN TÊN CHƯƠNG & BẢN ĐỒ HIỆN TẠI (CHÍNH GIỮA TRÊN)
	var map_banner := _make_styled_panel(Color(0.05, 0.07, 0.13, 0.88), Color("#70D6FF"), 2, 6, 14)
	map_banner.anchor_left = 0.5
	map_banner.anchor_right = 0.5
	map_banner.anchor_top = 0.0
	map_banner.offset_left = -212
	map_banner.offset_right = 212
	map_banner.offset_top = 12
	root_ctrl.add_child(map_banner)

	map_banner_lbl = _make_label("Chương 01 — Quảng Trường & Đại Sảnh Tiêu Gia", 13, Color("#A8DADC"))
	map_banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_banner_lbl.clip_text = true
	map_banner.add_child(map_banner_lbl)

	# 2B. THANH MÁU BOSS ĐA PHASE (CHÍNH GIỮA NGAY DƯỚI BIỂN TÊN BẢN ĐỒ)
	boss_bar_panel = _make_styled_panel(Color(0.11, 0.03, 0.07, 0.94), Color("#FF4D6D"), 2, 7, 8)
	boss_bar_panel.anchor_left = 0.5
	boss_bar_panel.anchor_right = 0.5
	boss_bar_panel.anchor_top = 0.0
	boss_bar_panel.offset_left = -212
	boss_bar_panel.offset_right = 212
	boss_bar_panel.offset_top = 56
	boss_bar_panel.visible = false
	root_ctrl.add_child(boss_bar_panel)

	var boss_v := VBoxContainer.new()
	boss_v.add_theme_constant_override("separation", 3)
	boss_bar_panel.add_child(boss_v)

	boss_title_lbl = _make_label("[BOSS]", 12, Color("#FFD166"))
	boss_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_title_lbl.clip_text = true
	boss_title_lbl.custom_minimum_size = Vector2(406, 0)
	boss_v.add_child(boss_title_lbl)

	boss_phase_lbl = _make_label("GIAI ĐOẠN I", 11, Color("#FF9770"))
	boss_phase_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_v.add_child(boss_phase_lbl)

	boss_hp_bar = _make_bar(Color("#C77DFF"), 13, 406)
	boss_v.add_child(boss_hp_bar)

	boss_poise_bar = _make_bar(Color("#FFD166"), 7, 406)
	boss_poise_bar.max_value = 100.0
	boss_poise_bar.value = 0.0
	boss_v.add_child(boss_poise_bar)

	boss_poise_lbl = _make_label("Tích Lũy Phá Thế (Poise): 0%", 10, Color("#FFE599"))
	boss_poise_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_v.add_child(boss_poise_lbl)

	# 2C. THANH TRẠNG THÁI THIÊN PHẦN LUYỆN KHÍ THÁP (ROGUELITE)
	tower_bar_panel = _make_styled_panel(Color(0.14, 0.04, 0.04, 0.92), Color("#FF7B00"), 2, 6, 8)
	tower_bar_panel.anchor_left = 0.5
	tower_bar_panel.anchor_right = 0.5
	tower_bar_panel.anchor_top = 0.0
	tower_bar_panel.offset_left = -212
	tower_bar_panel.offset_right = 212
	tower_bar_panel.offset_top = 56
	tower_bar_panel.visible = false
	root_ctrl.add_child(tower_bar_panel)

	tower_info_lbl = _make_label("🔥 THIÊN PHẦN THÁP — TẦNG 1", 12, Color("#FFD166"))
	tower_info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tower_bar_panel.add_child(tower_info_lbl)

	# 3. KHUNG NHIỆM VỤ GỌN SẠCH (GÓC PHẢI TRÊN — KHÔNG RÁC PHÍM CHỮ)
	var top_right := _make_styled_panel(Color(0.05, 0.07, 0.12, 0.88), Color("#FFD166"), 2, 9, 9)
	top_right.anchor_left = 1.0
	top_right.anchor_right = 1.0
	top_right.anchor_top = 0.0
	top_right.offset_left = -390
	top_right.offset_right = -14
	top_right.offset_top = 12
	top_right.custom_minimum_size = Vector2(376, 86)
	root_ctrl.add_child(top_right)

	quest_lbl = _make_label("", 12, Color("#F8F9FA"))
	quest_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top_right.add_child(quest_lbl)

	# 3B. CHỈ BÁO FPS NHỎ GỌN (BẬT/TẮT TRONG [ESC] CÀI ĐẶT HIỂN THỊ)
	fps_panel = _make_styled_panel(Color(0.04, 0.06, 0.11, 0.86), Color("#52B788"), 1, 4, 6)
	fps_panel.anchor_left = 1.0
	fps_panel.anchor_right = 1.0
	fps_panel.anchor_top = 0.0
	fps_panel.offset_left = -98
	fps_panel.offset_right = -14
	fps_panel.offset_top = 104
	fps_panel.visible = false
	fps_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(fps_panel)

	fps_lbl = _make_label("FPS: 60", 11, Color("#80ED99"))
	fps_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fps_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fps_panel.add_child(fps_lbl)

	# 4. CỤM 8 NÚT HỆ THỐNG BẤM TRỰC TIẾP (GÓC TRÁI DƯỚI: 2 HÀNG x 4 Ô VUÔNG MỊN)
	var sys_dock := _make_styled_panel(Color(0.05, 0.06, 0.11, 0.90), Color("#3A506B"), 2, 6, 10)
	sys_dock.anchor_left = 0.0
	sys_dock.anchor_top = 1.0
	sys_dock.anchor_bottom = 1.0
	sys_dock.offset_left = 14
	sys_dock.offset_top = -114
	sys_dock.offset_bottom = -12
	sys_dock.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(sys_dock)

	var sys_grid := GridContainer.new()
	sys_grid.columns = 4
	sys_grid.add_theme_constant_override("h_separation", 5)
	sys_grid.add_theme_constant_override("v_separation", 5)
	sys_dock.add_child(sys_grid)

	var sys_specs: Array = [
		{ "k": "I", "sub": "Đồ", "icon": "res://assets/sprites/icons/icon_armor.png", "col": Color("#52B788"), "fn": func() -> void: _toggle_modal("equipment") },
		{ "k": "K", "sub": "Kỹ", "icon": "res://assets/sprites/icons/skill_toai_thach.png", "col": Color("#FF9F1C"), "fn": func() -> void: _toggle_modal("skills") },
		{ "k": "B", "sub": "Cảnh", "icon": "res://assets/sprites/icons/icon_stone.png", "col": Color("#FFD166"), "fn": func() -> void: _toggle_modal("breakthrough") },
		{ "k": "L", "sub": "Đan", "icon": "res://assets/sprites/icons/icon_cauldron.png", "col": Color("#2EC4B6"), "fn": func() -> void: _try_open_alchemy() },
		{ "k": "H", "sub": "Hỏa", "icon": "res://assets/sprites/icons/skill_hoa_lien.png", "col": Color("#FF4D6D"), "fn": func() -> void: _try_open_flames() },
		{ "k": "M", "sub": "Map", "icon": "res://assets/sprites/icons/icon_pendant.png", "col": Color("#70D6FF"), "fn": func() -> void: _toggle_modal("world_map") },
		{ "k": "F5", "sub": "Lưu", "icon": "res://assets/sprites/icons/icon_ring.png", "col": Color("#A8DADC"), "fn": func() -> void: _quick_save() },
		{ "k": "ESC", "sub": "Menu", "icon": "res://assets/sprites/icons/icon_necklace.png", "col": Color("#C77DFF"), "fn": func() -> void: _toggle_modal("pause") }
	]
	for sp in sys_specs:
		var btn := MobaSlotButton.new()
		btn.configure_slot(str(sp["k"]), 43, sp["col"] as Color)
		btn.pressed.connect(sp["fn"] as Callable)
		btn.slot_hovered.connect(_show_slot_tooltip)
		btn.slot_unhovered.connect(_hide_slot_tooltip)
		sys_grid.add_child(btn)
		sys_buttons[str(sp["k"])] = btn

	# 5. DẢI NHẬT KÝ CỐT TRUYỆN MẢNH NỔI PHÍA TRÊN THANH MOBA (TỰ XUỐNG DÒNG, KHÔNG CẮT CHỮ)
	var banter_pill := _make_styled_panel(Color(0.05, 0.06, 0.11, 0.88), Color("#6C5CE7"), 1, 5, 8)
	banter_pill.anchor_left = 0.5
	banter_pill.anchor_right = 0.5
	banter_pill.anchor_top = 1.0
	banter_pill.anchor_bottom = 1.0
	banter_pill.offset_left = -402
	banter_pill.offset_right = 402
	banter_pill.offset_top = -132
	banter_pill.offset_bottom = -90
	banter_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(banter_pill)

	banter_lbl = _make_label("Tiêu Viêm: 'Lại là Tam Đoạn Đấu Chi Khí... Hãy tiến tới gặp Nạp Lan Yên Nhiên và bấm [V] đối thoại!'", 11, Color("#A8DADC"))
	banter_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banter_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banter_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banter_pill.add_child(banter_lbl)

	# 6. THANH CHIÊU THỨC & VẬT PHẨM PHONG CÁCH MOBA (CHÍNH GIỮA DƯỚI — BẤM CHUỘT HOẶC PHÍM!)
	var moba_dock := _make_styled_panel(Color(0.04, 0.06, 0.11, 0.94), Color("#D4A351"), 2, 8, 12)
	moba_dock.anchor_left = 0.5
	moba_dock.anchor_right = 0.5
	moba_dock.anchor_top = 1.0
	moba_dock.anchor_bottom = 1.0
	moba_dock.offset_left = -402
	moba_dock.offset_right = 402
	moba_dock.offset_top = -86
	moba_dock.offset_bottom = -10
	moba_dock.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(moba_dock)

	var dock_h := HBoxContainer.new()
	dock_h.alignment = BoxContainer.ALIGNMENT_CENTER
	dock_h.add_theme_constant_override("separation", 6)
	moba_dock.add_child(dock_h)

	# 6A. Đánh thường [LMB]
	slot_lmb = MobaSlotButton.new()
	slot_lmb.configure_slot("LMB", 54, Color("#E9ECEF"))
	slot_lmb.pressed.connect(func() -> void:
		var p: Node = _find_player()
		if p != null and p.has_method("trigger_ui_attack"):
			p.trigger_ui_attack()
	)
	slot_lmb.slot_hovered.connect(_show_slot_tooltip)
	slot_lmb.slot_unhovered.connect(_hide_slot_tooltip)
	dock_h.add_child(slot_lmb)

	dock_h.add_child(_make_v_divider())

	# 6B. 5 Ô Kỹ Năng Chính [Q] [E] [R] [F] [T]
	var sk_specs: Array = [
		{ "k": "Q", "sz": 56, "col": Color("#38BDF8") },
		{ "k": "E", "sz": 56, "col": Color("#FF9F1C") },
		{ "k": "R", "sz": 56, "col": Color("#C77DFF") },
		{ "k": "F", "sz": 60, "col": Color("#FFD166") },
		{ "k": "T", "sz": 56, "col": Color("#70D6FF") }
	]
	for sk_s in sk_specs:
		var sk_key: String = str(sk_s["k"])
		var btn := MobaSlotButton.new()
		btn.configure_slot(sk_key, int(sk_s["sz"]), sk_s["col"] as Color)
		btn.pressed.connect(func() -> void:
			var p: Node = _find_player()
			if p != null and p.has_method("trigger_ui_skill"):
				p.trigger_ui_skill(sk_key)
		)
		btn.slot_hovered.connect(_show_slot_tooltip)
		btn.slot_unhovered.connect(_hide_slot_tooltip)
		dock_h.add_child(btn)
		skill_slots[sk_key] = btn

	dock_h.add_child(_make_v_divider())

	# 6C. 4 Ô Cơ Động & Tương Tác [SPC] [C] [G] [V]
	slot_dash = MobaSlotButton.new()
	slot_dash.configure_slot("SPC", 46, Color("#4CC9F0"))
	slot_dash.pressed.connect(func() -> void:
		var p: Node = _find_player()
		if p != null and p.has_method("trigger_ui_dash"):
			p.trigger_ui_dash()
	)
	slot_dash.slot_hovered.connect(_show_slot_tooltip)
	slot_dash.slot_unhovered.connect(_hide_slot_tooltip)
	dock_h.add_child(slot_dash)

	slot_weight = MobaSlotButton.new()
	slot_weight.configure_slot("C", 46, Color("#70D6FF"))
	slot_weight.pressed.connect(func() -> void:
		var p: Node = _find_player()
		if p != null and p.has_method("trigger_ui_toggle_weight"):
			p.trigger_ui_toggle_weight()
	)
	slot_weight.slot_hovered.connect(_show_slot_tooltip)
	slot_weight.slot_unhovered.connect(_hide_slot_tooltip)
	dock_h.add_child(slot_weight)

	slot_companion = MobaSlotButton.new()
	slot_companion.configure_slot("G", 46, Color("#80ED99"))
	slot_companion.pressed.connect(func() -> void:
		var p: Node = _find_player()
		if p != null and p.has_method("trigger_ui_toggle_companion"):
			p.trigger_ui_toggle_companion()
	)
	slot_companion.slot_hovered.connect(_show_slot_tooltip)
	slot_companion.slot_unhovered.connect(_hide_slot_tooltip)
	dock_h.add_child(slot_companion)

	slot_interact = MobaSlotButton.new()
	slot_interact.configure_slot("V", 46, Color("#FFD166"))
	slot_interact.pressed.connect(func() -> void:
		var w: Node = _find_world()
		if w != null and w.has_method("_try_interact_nearest"):
			w._try_interact_nearest()
	)
	slot_interact.slot_hovered.connect(_show_slot_tooltip)
	slot_interact.slot_unhovered.connect(_hide_slot_tooltip)
	dock_h.add_child(slot_interact)

	dock_h.add_child(_make_v_divider())

	# 6D. 3 Ô Đan Dược Bấm Uống Ngay [1] [2] [3]
	var pill_cols: Array = [Color("#EF476F"), Color("#38BDF8"), Color("#06D6A0")]
	for pi in range(3):
		var slot_idx: int = pi + 1
		var pb := MobaSlotButton.new()
		pb.configure_slot(str(slot_idx), 48, pill_cols[pi] as Color)
		pb.pressed.connect(func() -> void:
			var p: Node = _find_player()
			if p != null and p.has_method("trigger_ui_use_pill"):
				p.trigger_ui_use_pill(slot_idx)
		)
		pb.slot_hovered.connect(_show_slot_tooltip)
		pb.slot_unhovered.connect(_hide_slot_tooltip)
		dock_h.add_child(pb)
		pill_slots.append(pb)

	# 7. TIỂU BẢN ĐỒ THỜI GIAN THỰC (GÓC PHẢI DƯỚI — ĐỒNG ĐỀU VỚI CỤM HỆ THỐNG BÊN TRÁI)
	minimap_panel = _make_styled_panel(Color(0.05, 0.06, 0.11, 0.90), Color("#2EC4B6"), 2, 5, 10)
	minimap_panel.anchor_left = 1.0
	minimap_panel.anchor_right = 1.0
	minimap_panel.anchor_top = 1.0
	minimap_panel.anchor_bottom = 1.0
	minimap_panel.offset_left = -204
	minimap_panel.offset_right = -14
	minimap_panel.offset_top = -146
	minimap_panel.offset_bottom = -12
	minimap_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(minimap_panel)

	var mm_v := VBoxContainer.new()
	mm_v.add_theme_constant_override("separation", 2)
	mm_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_panel.add_child(mm_v)

	var mm_hdr := _make_label("TIỂU BẢN ĐỒ · [M] Map Lớn", 10, Color("#70D6FF"))
	mm_hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mm_v.add_child(mm_hdr)

	minimap_widget = MinimapWidget.new()
	minimap_widget.custom_minimum_size = Vector2(180, 108)
	mm_v.add_child(minimap_widget)

	# 7B. CHỈ BÁO TỰ ĐỘNG LƯU GỌN NHẸ (TRÊN CỤM HỆ THỐNG GÓC TRÁI DƯỚI — LUÔN NỔI TRÊN MODAL)
	autosave_toast_panel = _make_styled_panel(Color(0.04, 0.11, 0.10, 0.94), Color("#2EC4B6"), 1, 5, 8)
	autosave_toast_panel.anchor_left = 0.0
	autosave_toast_panel.anchor_top = 1.0
	autosave_toast_panel.anchor_bottom = 1.0
	autosave_toast_panel.offset_left = 14
	autosave_toast_panel.offset_top = -146
	autosave_toast_panel.offset_bottom = -120
	autosave_toast_panel.z_index = 40
	autosave_toast_panel.visible = false
	autosave_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(autosave_toast_panel)

	autosave_toast_lbl = _make_label("● Đã tự động lưu (Ô 1)", 11, Color("#72EFDD"))
	autosave_toast_panel.add_child(autosave_toast_lbl)

	# 8. TOOLTIP NỔI PHONG CÁCH MOBA (HIỆN NGAY TRÊN Ô KHI DI CHUỘT)
	tooltip_panel = _make_styled_panel(Color(0.04, 0.05, 0.10, 0.96), Color("#FFD166"), 2, 10, 8)
	tooltip_panel.custom_minimum_size = Vector2(310, 0)
	tooltip_panel.visible = false
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(tooltip_panel)

	var tt_v := VBoxContainer.new()
	tt_v.add_theme_constant_override("separation", 3)
	tt_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.add_child(tt_v)

	tt_title_lbl = _make_label("Tên Chiêu Thức", 14, Color("#FFD166"))
	tt_v.add_child(tt_title_lbl)

	tt_sub_lbl = _make_label("Huyền Giai · 15 QI · Hồi 4.2s", 11, Color("#70D6FF"))
	tt_v.add_child(tt_sub_lbl)

	tt_desc_lbl = _make_label("", 12, Color("#E9ECEF"))
	tt_desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tt_desc_lbl.custom_minimum_size = Vector2(290, 0)
	tt_v.add_child(tt_desc_lbl)

	# 9. HỘP THOẠI NPC CỐT TRUYỆN
	dialogue_panel = _make_styled_panel(Color(0.05, 0.06, 0.12, 0.96), Color("#FFD166"), 2, 12, 10)
	dialogue_panel.anchor_left = 0.5
	dialogue_panel.anchor_right = 0.5
	dialogue_panel.anchor_top = 1.0
	dialogue_panel.anchor_bottom = 1.0
	dialogue_panel.offset_left = -450
	dialogue_panel.offset_right = 450
	dialogue_panel.offset_top = -288
	dialogue_panel.offset_bottom = -132
	dialogue_panel.visible = false
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(dialogue_panel)

	var dlg_hbox := HBoxContainer.new()
	dlg_hbox.add_theme_constant_override("separation", 14)
	dialogue_panel.add_child(dlg_hbox)

	var avatar_frame := _make_styled_panel(Color(0.10, 0.11, 0.18, 0.95), Color("#FFD166"), 2, 4, 8)
	avatar_frame.custom_minimum_size = Vector2(118, 118)
	dlg_hbox.add_child(avatar_frame)

	dlg_avatar_rect = TextureRect.new()
	dlg_avatar_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dlg_avatar_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dlg_avatar_rect.custom_minimum_size = Vector2(108, 108)
	avatar_frame.add_child(dlg_avatar_rect)

	var dlg_right := VBoxContainer.new()
	dlg_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dlg_right.add_theme_constant_override("separation", 6)
	dlg_hbox.add_child(dlg_right)

	dlg_speaker_lbl = _make_label("Nhân vật", 17, Color("#FFD166"))
	dlg_right.add_child(dlg_speaker_lbl)

	dlg_body_lbl = _make_label("", 14, Color("#F8F9FA"))
	dlg_body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dlg_body_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dlg_right.add_child(dlg_body_lbl)

	dlg_choices_vbox = VBoxContainer.new()
	dlg_choices_vbox.add_theme_constant_override("separation", 6)
	dlg_choices_vbox.visible = false
	dlg_right.add_child(dlg_choices_vbox)

	var dlg_btn_row := HBoxContainer.new()
	dlg_btn_row.alignment = BoxContainer.ALIGNMENT_END
	dlg_right.add_child(dlg_btn_row)

	dlg_next_btn = Button.new()
	dlg_next_btn.text = "Tiếp tục [V / Enter]"
	dlg_next_btn.add_theme_font_size_override("font_size", 13)
	dlg_next_btn.pressed.connect(_advance_dialogue)
	dlg_btn_row.add_child(dlg_next_btn)

	# 10. LỚP PHỦ TỐI MỜ + CỬA SỔ ĐA NĂNG TRUNG TÂM
	modal_dim_bg = ColorRect.new()
	modal_dim_bg.color = Color(0.02, 0.02, 0.05, 0.64)
	modal_dim_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_dim_bg.visible = false
	modal_dim_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(modal_dim_bg)

	modal_panel = _make_styled_panel(Color(0.06, 0.07, 0.13, 0.98), Color("#2EC4B6"), 2, 14, 10)
	modal_panel.anchor_left = 0.5
	modal_panel.anchor_right = 0.5
	modal_panel.anchor_top = 0.5
	modal_panel.anchor_bottom = 0.5
	modal_panel.offset_left = -520
	modal_panel.offset_right = 520
	modal_panel.offset_top = -275
	modal_panel.offset_bottom = 265
	modal_panel.visible = false
	modal_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ctrl.add_child(modal_panel)

	var m_outer := VBoxContainer.new()
	m_outer.add_theme_constant_override("separation", 8)
	modal_panel.add_child(m_outer)

	var header_hbox := HBoxContainer.new()
	m_outer.add_child(header_hbox)

	modal_title_lbl = _make_label("BẢNG TU LUYỆN", 17, Color("#FFD166"))
	modal_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(modal_title_lbl)

	var close_btn := Button.new()
	close_btn.text = "Đóng [ESC]"
	close_btn.add_theme_font_size_override("font_size", 13)
	close_btn.pressed.connect(_close_modal)
	header_hbox.add_child(close_btn)

	modal_content_host = Control.new()
	modal_content_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_content_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_content_host.custom_minimum_size = Vector2(1008, 445)
	m_outer.add_child(modal_content_host)

	modal_status_lbl = _make_label("", 13, Color("#80ED99"))
	m_outer.add_child(modal_status_lbl)


func _make_v_divider() -> ColorRect:
	var sep := ColorRect.new()
	sep.color = Color(0.83, 0.64, 0.32, 0.40)
	sep.custom_minimum_size = Vector2(2, 46)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return sep


func _make_styled_panel(bg_col: Color, border_col: Color, border_w: int = 2, pad: int = 8, radius: int = 7) -> PanelContainer:
	var pc := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.set_content_margin_all(pad)
	pc.add_theme_stylebox_override("panel", sb)
	return pc


func _make_label(txt: String, fsize: int, col: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.05, 0.96))
	l.add_theme_constant_override("outline_size", 3)
	return l


func _make_bar(fill_col: Color, min_h: int, min_w: int = 290) -> ProgressBar:
	var pb := ProgressBar.new()
	pb.custom_minimum_size = Vector2(min_w, min_h)
	pb.show_percentage = false
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.10, 0.12, 0.19, 1.0)
	bg.set_corner_radius_all(4)
	var fg := StyleBoxFlat.new()
	fg.bg_color = fill_col
	fg.set_corner_radius_all(4)
	pb.add_theme_stylebox_override("background", bg)
	pb.add_theme_stylebox_override("fill", fg)
	return pb


func _make_bar_overlay_label(txt: String) -> Label:
	var l := Label.new()
	l.text = txt
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color("#FFFFFF"))
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.05, 1.0))
	l.add_theme_constant_override("outline_size", 3)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _make_icon_box(tex_path: String, border_col: Color, box_px: int = 38) -> PanelContainer:
	return _make_icon_box_from_tex(_get_cached_tex(tex_path), border_col, box_px)


func _make_icon_box_from_tex(tex: Texture2D, border_col: Color, box_px: int = 38) -> PanelContainer:
	var frame := _make_styled_panel(Color(0.10, 0.11, 0.18, 0.95), border_col, 2, 2, 6)
	frame.custom_minimum_size = Vector2(box_px, box_px)
	var tr := TextureRect.new()
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.custom_minimum_size = Vector2(box_px - 6, box_px - 6)
	frame.add_child(tr)
	return frame


func _get_enemy_thumb_tex(edef: Dictionary) -> Texture2D:
	var eid: String = str(edef.get("id", ""))
	if _bestiary_thumb_cache.has(eid):
		return _bestiary_thumb_cache[eid] as Texture2D
	var sheet_p: String = str(edef.get("anim_sheet", ""))
	var raw_p: String = sheet_p if (sheet_p != "" and ResourceLoader.exists(sheet_p)) else str(edef.get("sprite", ""))
	var base_tex: Texture2D = _get_cached_tex(raw_p)
	if base_tex == null:
		return null
	var res_tex: Texture2D = base_tex
	var meta: Dictionary = SpriteAnimHelper.inspect_sheet(base_tex, "square", 1, 1)
	var hf: int = int(meta.get("hframes", 1))
	var vf: int = int(meta.get("vframes", 1))
	if hf > 1 or vf > 1:
		var at := AtlasTexture.new()
		at.atlas = base_tex
		var fw: float = float(base_tex.get_width()) / float(hf)
		var fh: float = float(base_tex.get_height()) / float(vf)
		at.region = Rect2(0.0, 0.0, fw, fh)
		res_tex = at
	_bestiary_thumb_cache[eid] = res_tex
	return res_tex


# =========================================================
# TOOLTIP MOBA & CẬP NHẬT TRẠNG THÁI TOÀN BỘ Ô NÚT BẤM
# =========================================================
func _show_slot_tooltip(info: Dictionary, anchor_pos: Vector2) -> void:
	if current_modal != "":
		return
	tt_title_lbl.text = str(info.get("title", ""))
	tt_title_lbl.add_theme_color_override("font_color", info.get("color", Color("#FFD166")) as Color)
	tt_sub_lbl.text = str(info.get("subtitle", ""))
	tt_sub_lbl.visible = (tt_sub_lbl.text != "")
	tt_desc_lbl.text = str(info.get("desc", ""))
	tooltip_panel.visible = true
	tooltip_panel.reset_size()
	var vp_w: float = get_viewport().get_visible_rect().size.x
	var tw: float = maxf(310.0, tooltip_panel.size.x)
	var th: float = maxf(76.0, tooltip_panel.size.y)
	var tx: float = clampf(anchor_pos.x - tw * 0.5, 12.0, vp_w - tw - 12.0)
	var ty: float = maxf(12.0, anchor_pos.y - th - 14.0)
	tooltip_panel.position = Vector2(tx, ty)


func _hide_slot_tooltip() -> void:
	tooltip_panel.visible = false


func _get_cached_tex(tex_path: String) -> Texture2D:
	if _icon_cache.has(tex_path):
		return _icon_cache[tex_path] as Texture2D
	var loaded: Texture2D = load(tex_path)
	_icon_cache[tex_path] = loaded
	return loaded


func _on_qi_updated(cur_q: float, max_q: float) -> void:
	if qi_bar != null:
		qi_bar.max_value = max_q
	target_qi_val = cur_q
	var cur_i: int = int(cur_q)
	var max_i: int = int(max_q)
	if cur_i != _last_qi_display or max_i != _last_max_qi_display:
		_last_qi_display = cur_i
		_last_max_qi_display = max_i
		if qi_val_lbl != null:
			var mdb_tag: String = "  [☠ Ma Độc +%d%% ATK]" % int(round(PlayerData.get_ma_doc_ban_atk_bonus_pct())) if PlayerData.has_ma_doc_ban() else ""
			qi_val_lbl.text = "Đấu Khí  %d / %d%s" % [cur_i, max_i, mdb_tag]
	for slot_k in _slot_qi_costs.keys():
		if skill_slots.has(slot_k):
			var btn: MobaSlotButton = skill_slots[slot_k]
			var low_q: bool = (cur_q < float(_slot_qi_costs[slot_k]))
			btn.set_low_resource_state(low_q, Color("#FF758F") if low_q else Color("#70D6FF"))


func _on_skill_cooldown_updated(slot_key: String, remaining: float, total: float) -> void:
	if slot_key == "SPACE" and slot_dash != null:
		slot_dash.set_cooldown(remaining, total)
	elif skill_slots.has(slot_key):
		var btn: MobaSlotButton = skill_slots[slot_key]
		btn.set_cooldown(remaining, total)


func _refresh_interact_button() -> void:
	if slot_interact == null:
		return
	var w: Node = _find_world()
	var near_txt: String = ""
	if w != null and w.has_method("get_nearby_interact_label"):
		near_txt = str(w.get_nearby_interact_label())
	if near_txt == last_nearby_interact:
		return
	last_nearby_interact = near_txt
	var has_near: bool = (near_txt != "")
	slot_interact.set_slot_visual(
		_get_cached_tex("res://assets/sprites/props/chest_open.png") if has_near else _get_cached_tex("res://assets/sprites/icons/icon_pendant.png"),
		"BẤM!" if has_near else "Gần",
		false,
		has_near,
		not has_near,
		Color("#FFD166") if has_near else Color("#6C757D")
	)
	slot_interact.set_tooltip_info(
		"Tương Tác [V] — " + (near_txt if has_near else "Chưa ở gần đối tượng"),
		"Bấm chuột hoặc phím [V] / [Enter]",
		"Dùng để trò chuyện NPC cốt truyện, mở Phòng Đấu Giá Nhã Phi, mở Bảo Rương Bí Mật hoặc đi qua Cổng Chuyển Bản Đồ.",
		Color("#FFD166")
	)


func _refresh_moba_dock() -> void:
	HudMobaDock.refresh_moba_dock(self)


func _on_boss_status_updated(boss_name: String, realm_badge: String, cur_hp: float, max_hp: float, phase: int, visible_bar: bool) -> void:
	boss_bar_panel.visible = visible_bar
	if not visible_bar:
		boss_is_staggered = false
		boss_p2_warning = false
		return
	boss_title_lbl.text = "%s  <%s>" % [boss_name, realm_badge]
	if not boss_p2_warning:
		boss_phase_lbl.text = "★ GIAI ĐOẠN III — HỦY DIỆT!!" if phase >= 3 else ("GIAI ĐOẠN II — CUỒNG BẠO!" if phase >= 2 else "GIAI ĐOẠN I")
		boss_phase_lbl.add_theme_color_override("font_color", Color("#FF0054") if phase >= 3 else (Color("#FF2A5F") if phase >= 2 else Color("#FFD166")))
	boss_hp_bar.max_value = maxf(1.0, max_hp)
	target_boss_hp = clampf(cur_hp, 0.0, max_hp)


func _on_boss_poise_updated(cur_poise: float, max_poise: float, staggered: bool, phase2_warning: bool) -> void:
	boss_is_staggered = staggered
	boss_p2_warning = phase2_warning
	if boss_poise_bar == null or boss_poise_lbl == null:
		return
	boss_poise_bar.max_value = maxf(1.0, max_poise)
	target_boss_poise = clampf(cur_poise, 0.0, max_poise)
	var fill_sb: StyleBox = boss_poise_bar.get_theme_stylebox("fill")
	if staggered:
		boss_poise_lbl.text = "⚡ VỠ THẾ (STAGGER) — ĐÁNH TĂNG +35% SÁT THƯƠNG!"
		boss_poise_lbl.add_theme_color_override("font_color", Color("#FF4D6D"))
		if fill_sb is StyleBoxFlat:
			(fill_sb as StyleBoxFlat).bg_color = Color("#FF4D6D")
	elif phase2_warning:
		boss_poise_lbl.text = "⚠ SẮP BỘC PHÁT GIAI ĐOẠN II — CHUẨN BỊ NÉ CHIÊU!"
		boss_poise_lbl.add_theme_color_override("font_color", Color("#FF9F1C"))
		boss_phase_lbl.text = "⚠ CẢNH BÁO: SẮP VÀO GIAI ĐOẠN II!"
		boss_phase_lbl.add_theme_color_override("font_color", Color("#FF9F1C"))
		if fill_sb is StyleBoxFlat:
			(fill_sb as StyleBoxFlat).bg_color = Color("#FF7B00")
	else:
		var pct: int = int(round(100.0 * clampf(cur_poise / maxf(1.0, max_poise), 0.0, 1.0)))
		boss_poise_lbl.text = "Tích Lũy Phá Thế (Poise): %d%%" % pct
		boss_poise_lbl.add_theme_color_override("font_color", Color("#FFE599"))
		if fill_sb is StyleBoxFlat:
			(fill_sb as StyleBoxFlat).bg_color = Color("#FFD166")


func _on_boss_rush_completed(boss_id: String, difficulty: String, grade: String, elapsed_sec: float, reward_stones: int, reward_gold: int) -> void:
	var edef: Dictionary = GameDatabase.get_enemy_def(boss_id)
	var bname: String = str(edef.get("name", boss_id))
	var d_label: String = "ĐẤU TÔNG" if difficulty == "dau_tong" else ("ÁC MỘNG" if difficulty == "nightmare" else "THƯỜNG")
	_on_banter("⚔ TÂM MA LUYỆN CẢNH THẮNG LỢI! %s [%s] · HẠNG %s · %.1fs · +%d Đá CH · +%d Kim Tệ!" % [
		bname, d_label, grade, elapsed_sec, reward_stones, reward_gold
	])
	_refresh_stats()
	if current_modal == "world_map":
		_populate_modal()


func _sync_display_widgets() -> void:
	if fps_panel != null:
		fps_panel.visible = AudioManager.show_fps


func _sync_keybind_labels() -> void:
	var pairs: Dictionary = {
		"Q": "skill_q", "E": "skill_e", "R": "skill_r", "F": "skill_ult", "T": "skill_assist"
	}
	for k in pairs.keys():
		if skill_slots.has(k):
			var b: MobaSlotButton = skill_slots[k]
			var lbl_s: String = AudioManager.get_action_key_label(str(pairs[k]))
			b.key_label_text = lbl_s
			if b.key_badge_lbl != null:
				b.key_badge_lbl.text = lbl_s
	var extra: Array = [
		[slot_dash, "dash"], [slot_weight, "toggle_weight"],
		[slot_companion, "toggle_companion"], [slot_interact, "interact"]
	]
	for item in extra:
		var btn: MobaSlotButton = item[0] as MobaSlotButton
		if btn != null:
			var lbl_s: String = AudioManager.get_action_key_label(str(item[1]))
			btn.key_label_text = lbl_s
			if btn.key_badge_lbl != null:
				btn.key_badge_lbl.text = lbl_s


func _on_tower_state_updated(floor_num: int, enemies_left: int, enemies_total: int, heat_dps: float, active: bool) -> void:
	if tower_bar_panel == null or tower_info_lbl == null:
		return
	tower_bar_panel.visible = active
	if active:
		tower_info_lbl.text = "🔥 THIÊN PHẦN THÁP — TẦNG %d  ·  Địch còn: %d/%d  ·  Tâm Hỏa: -%.0f HP/s" % [
			floor_num, enemies_left, enemies_total, heat_dps
		]
		# Đẩy thanh Boss xuống gọn gàng nếu đang đánh Boss tầng 3/6/9
		boss_bar_panel.offset_top = 92
	else:
		boss_bar_panel.offset_top = 56


func _on_tower_blessing_requested(floor_num: int, choices: Array) -> void:
	pending_tower_floor = floor_num
	pending_tower_choices = choices
	_hide_slot_tooltip()
	current_modal = "tower_blessing"
	modal_dim_bg.visible = true
	modal_panel.visible = true
	modal_status_lbl.text = "Chọn 1 trong 3 Chúc Phúc Tâm Hỏa để tiến lên Tầng %d!" % (floor_num + 1)
	_populate_modal()
	_sync_player_input_block()


func _open_auction_house(venue_id: String = "nha_phi") -> void:
	shop_venue_id = venue_id if venue_id != "" else "nha_phi"
	shop_tab = "auction"
	auction_lots = AuctionSystem.generate_auction_lots(shop_venue_id)
	active_auction_lot_idx = 0
	_open_nha_phi_shop()


# =========================================================
# HỘP THOẠI CỐT TRUYỆN NPC & CHỌN NHÁNH HẢO CẢM
# =========================================================
func _open_dialogue(speaker: String, avatar_path: String, lines_arr: Array, finish_action: String) -> void:
	HudDialogueCtrl.open_dialogue(self, speaker, avatar_path, lines_arr, finish_action)


func _open_choice_dialogue(speaker: String, avatar_path: String, lines_arr: Array, choices: Array) -> void:
	HudDialogueCtrl.open_choice_dialogue(self, speaker, avatar_path, lines_arr, choices)


func _render_dialogue_line() -> void:
	HudDialogueCtrl.render_dialogue_line(self)


func _advance_dialogue() -> void:
	HudDialogueCtrl.advance_dialogue(self)


func _close_dialogue(run_finish_action: bool) -> void:
	HudDialogueCtrl.close_dialogue(self, run_finish_action)


func _execute_dialogue_action(act: String) -> void:
	HudDialogueCtrl.execute_dialogue_action(self, act)


func _heal_player_full(msg: String) -> void:
	PlayerData.recalculate_and_clamp(true)
	EventBus.stats_changed.emit()
	AudioManager.play_sfx("loot_pickup")
	var p: Node = _find_player()
	if p != null and p is Node2D:
		EventBus.floating_text_requested.emit((p as Node2D).global_position + Vector2(0, -68), "HỒI ĐẦY HP & ĐẤU KHÍ!", Color("#80ED99"))
	if msg != "":
		_on_banter(msg)


func _open_nha_phi_shop() -> void:
	_hide_slot_tooltip()
	current_modal = "shop_nha_phi"
	modal_dim_bg.visible = true
	modal_panel.visible = true
	modal_status_lbl.text = ""
	_populate_modal()
	_sync_player_input_block()


# =========================================================
# CẬP NHẬT CHỈ SỐ, NHIỆM VỤ & DOCK MOBA
# =========================================================
func _refresh_all() -> void:
	_refresh_stats()
	_refresh_quest_ui()
	_refresh_moba_dock()


func _refresh_stats() -> void:
	var bottleneck_tag: String = " [ĐỈNH PHONG!]" if PlayerData.is_at_bottleneck() else ""
	var title_tag: String = PlayerData.get_active_title_display()
	var title_prefix: String = ("%s " % title_tag) if title_tag != "" else ""
	realm_lbl.text = "%s%s%s" % [title_prefix, PlayerData.get_realm_display_title(), bottleneck_tag]
	var fe_txt: String = " · %d Hỏa Năng" % PlayerData.fire_energy if PlayerData.fire_energy > 0 else ""
	currency_lbl.text = "%d Kim Tệ · %d Đá%s" % [PlayerData.gold, PlayerData.enhance_stones, fe_txt]

	var m_hp: float = PlayerData.get_max_hp()
	var m_qi: float = PlayerData.get_max_qi()
	var req_e: int = max(1, PlayerData.get_required_exp())

	hp_bar.max_value = m_hp
	target_hp_val = PlayerData.current_hp
	var sh_txt: String = "  (+%d Khiên)" % int(round(PlayerData.lotus_shield_hp)) if PlayerData.lotus_shield_hp > 1.0 else ""
	hp_val_lbl.text = "HP  %d / %d%s" % [int(PlayerData.current_hp), int(m_hp), sh_txt]

	qi_bar.max_value = m_qi
	target_qi_val = PlayerData.current_qi
	_last_qi_display = int(PlayerData.current_qi)
	_last_max_qi_display = int(m_qi)
	qi_val_lbl.text = "Đấu Khí  %d / %d" % [_last_qi_display, _last_max_qi_display]

	exp_bar.max_value = req_e
	target_exp_val = float(PlayerData.current_exp)

	var f_tag: String = "Chưa mở"
	if PlayerData.is_flames_unlocked():
		var f_def: Dictionary = PlayerData.get_active_flame_def()
		if not f_def.is_empty():
			f_tag = str(f_def.get("name", "Phàm Hỏa"))

	var vl_tag: String = " · ✦Tâm Hỏa 24/7" if PlayerData.has_van_lac_passive() else ""
	sub_stat_lbl.text = "ATK %d · DEF %d · EXP %d/%d · Hỏa: %s%s" % [
		int(PlayerData.get_atk()), int(PlayerData.get_def()), PlayerData.current_exp, req_e, f_tag, vl_tag
	]
	_refresh_moba_dock()


func _refresh_quest_ui() -> void:
	var q: Dictionary = PlayerData.get_current_quest()
	if q.is_empty():
		if PlayerData.is_demo_mode:
			quest_lbl.text = "★ CHẾ ĐỘ DEMO — MỞ KHÓA 100%% CHƯƠNG 01–11 (VIÊM ĐẾ 23/23 DỊ HỎA) ★\nBấm [M] Dịch Chuyển %d Map, thử [F] Hằng Cổ Dị Hỏa Liên, [T] Viêm Đế Pháp Tướng, Superboss Lâm Động–Mục Trần & [ESC] Credits/NG+!" % GameDatabase.maps_ordered.size()
		else:
			quest_lbl.text = "★ HOÀN TẤT 100% CHƯƠNG 11 (CH.01–11 · ĐẠI KẾT CỤC VIÊM ĐẾ v1.0.0) ★\nThu phục 23/23 Dị Hỏa, chinh phục Võ Tổ Lâm Động & Mục Trần, mở [ESC] True Ending Credits & Luân Hồi New Game+!"
	else:
		var goal: int = int(q.get("target_count", 1))
		quest_lbl.text = "★ %s (%d/%d)\n%s" % [
			str(q.get("title", "")),
			PlayerData.quest_progress,
			goal,
			str(q.get("objective", ""))
		]


func _on_exp_changed(_c: int, _r: int) -> void:
	_refresh_stats()
	if current_modal == "breakthrough":
		_populate_modal()


func _on_realm_updated(title: String, unlock_txt: String) -> void:
	_on_banter("ĐỘT PHÁ: %s — %s" % [title, unlock_txt])
	_refresh_stats()
	_refresh_current_map_banner()
	if current_modal != "":
		_populate_modal()


func _on_skills_updated() -> void:
	_refresh_all()
	if current_modal == "skills":
		_populate_modal()


func _on_companion_changed(_cid: String) -> void:
	_refresh_moba_dock()


func _on_story_flag_changed(_flag_name: String) -> void:
	_refresh_all()
	_refresh_current_map_banner()
	if current_modal != "":
		_populate_modal()


func _format_map_banner(map_id: String, map_title: String) -> String:
	var badges: Array[String] = []
	if map_id == NineTurnManager.THIEN_MO_MAP_ID:
		badges.append("[⏳ THIÊN MỘ · x5 EXP]")
	var emp_badge: String = EmperorRealmManager.get_hud_emperor_badge(PlayerData)
	if emp_badge != "":
		badges.append("[%s]" % emp_badge)
	else:
		var saint_badge: String = SaintRealmManager.get_hud_domain_badge(PlayerData)
		if saint_badge != "":
			badges.append("[%s]" % saint_badge)
	if badges.is_empty():
		return map_title
	return "%s   %s" % [map_title, "  ".join(badges)]


func _refresh_current_map_banner() -> void:
	var mid: String = PlayerData.current_map_id
	if not GameDatabase.maps_by_id.has(mid):
		return
	var m_def: Dictionary = GameDatabase.get_map_def(mid)
	var ch_str: String = str(m_def.get("chapter", "Chương 01"))
	var nm_str: String = str(m_def.get("name", mid))
	map_banner_lbl.text = _format_map_banner(mid, "%s — %s" % [ch_str, nm_str])


func _on_map_changed(map_id: String, map_title: String) -> void:
	map_banner_lbl.text = _format_map_banner(map_id, map_title)


func _refresh_inventory_ui() -> void:
	_refresh_moba_dock()
	if current_modal == "alchemy" and not alc_active:
		_populate_modal()
	elif current_modal == "breakthrough" or current_modal == "shop_nha_phi":
		_populate_modal()


func _on_equipment_changed() -> void:
	_refresh_stats()
	if current_modal == "equipment" or current_modal == "shop_nha_phi":
		_populate_modal()


func _on_banter(msg: String) -> void:
	if msg != "":
		banter_lbl.text = msg


func _on_flame_changed(_fid: String) -> void:
	_refresh_stats()
	if current_modal == "flames" or current_modal == "skills":
		_populate_modal()


func _on_seal_toggled(_sealed: bool) -> void:
	_refresh_stats()


func _toggle_modal(kind: String) -> void:
	if alc_active:
		return
	AudioManager.play_sfx("ui_click")
	_hide_slot_tooltip()
	if current_modal == kind:
		_close_modal()
		return
	current_modal = kind
	modal_dim_bg.visible = true
	modal_panel.visible = true
	modal_status_lbl.text = ""
	_populate_modal()
	_sync_player_input_block()


func _close_modal() -> void:
	if alc_active:
		return
	rebinding_action = ""
	current_modal = ""
	modal_dim_bg.visible = false
	modal_panel.visible = false
	_sync_player_input_block()


func _clear_modal_host() -> void:
	for ch in modal_content_host.get_children():
		ch.queue_free()


func _populate_modal() -> void:
	_clear_modal_host()
	if current_modal == "equipment":
		_build_equipment_modal()
	elif current_modal == "skills":
		_build_single_scroll_modal(_build_skills_codex_content)
	elif current_modal == "breakthrough":
		_build_single_scroll_modal(_build_breakthrough_content)
	elif current_modal == "alchemy":
		_build_single_scroll_modal(_build_alchemy_content)
	elif current_modal == "flames":
		_build_single_scroll_modal(_build_flames_content)
	elif current_modal == "shop_nha_phi":
		_build_single_scroll_modal(_build_nha_phi_shop_content)
	elif current_modal == "world_map":
		_build_single_scroll_modal(_build_world_map_content)
	elif current_modal == "pause":
		_build_single_scroll_modal(_build_pause_menu_content)
	elif current_modal == "tower_blessing":
		_build_single_scroll_modal(_build_tower_blessing_content)
	elif current_modal == "ending_credits":
		_build_single_scroll_modal(_build_ending_credits_content)


func _build_single_scroll_modal(builder_fn: Callable) -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_content_host.add_child(scroll)
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)
	builder_fn.call(vbox)


# =========================================================
# PANEL MÔ-ĐUN [ESC] · [M] · TÂM MA · THIÊN PHẦN THÁP (scripts/ui/panels/)
# =========================================================
func _build_pause_menu_content(vbox: VBoxContainer) -> void:
	panel_pause_settings.build_content(vbox)


func _build_world_map_content(vbox: VBoxContainer) -> void:
	panel_world_map_bestiary.build_content(vbox)


func _build_tower_blessing_content(vbox: VBoxContainer) -> void:
	panel_tower_boss_rush.build_blessing_content(vbox)


# =========================================================
# [K] KHO ĐẤU KỸ (CÓ ICON HD RIÊNG TỪNG CHIÊU + LẮP Q/E/R + HỎA LIÊN)
# =========================================================
func _build_skills_codex_content(vbox: VBoxContainer) -> void:
	panel_skills_cultivation.build_skills_codex_content(vbox)


# =========================================================
# PANEL MÔ-ĐUN [L] LUYỆN ĐAN · ĐẤU GIÁ · [I] TRANG BỊ (scripts/ui/panels/)
# =========================================================
func _build_alchemy_content(vbox: VBoxContainer) -> void:
	panel_alchemy.build_content(vbox)


func _alchemy_pulse_heat() -> void:
	panel_alchemy.pulse_heat()


func _alchemy_block_lightning() -> void:
	panel_alchemy.block_lightning()


func _tick_alchemy_minigame(delta: float) -> void:
	panel_alchemy.tick_minigame(delta)


func _build_nha_phi_shop_content(vbox: VBoxContainer) -> void:
	panel_auction.build_content(vbox)


func _build_equipment_modal() -> void:
	panel_equipment.build_modal()


# =========================================================
# [B] TU LUYỆN & ĐỘT PHÁ CẢNH GIỚI
# =========================================================
func _build_breakthrough_content(vbox: VBoxContainer) -> void:
	panel_skills_cultivation.build_breakthrough_content(vbox)


func _build_flames_content(vbox: VBoxContainer) -> void:
	panel_skills_cultivation.build_flames_content(vbox)


func _build_ending_credits_content(vbox: VBoxContainer) -> void:
	panel_ending_credits.build_content(vbox)
