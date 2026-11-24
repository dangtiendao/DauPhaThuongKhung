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

# 6 Panel UI mô-đun tách biệt (scripts/ui/panels/)
var panel_pause_settings: RefCounted
var panel_world_map_bestiary: RefCounted
var panel_tower_boss_rush: RefCounted
var panel_alchemy: RefCounted
var panel_auction: RefCounted
var panel_equipment: RefCounted

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

var world_map_tab: String = "maps" # "maps" | "heroines" | "boss_rush" | "bestiary"
var selected_gift_heroine: String = "huan_nhi"
var boss_rush_diff: String = "normal" # "normal" | "nightmare" | "dau_tong"
var bestiary_filter: String = "all" # "all" | "boss" | "mob"
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
	for p in [panel_pause_settings, panel_world_map_bestiary, panel_tower_boss_rush, panel_alchemy, panel_auction, panel_equipment]:
		if p != null:
			p.hud = null
	panel_pause_settings = null
	panel_world_map_bestiary = null
	panel_tower_boss_rush = null
	panel_alchemy = null
	panel_auction = null
	panel_equipment = null


func _ready() -> void:
	panel_pause_settings = PanelPauseSettingsScript.new(self)
	panel_world_map_bestiary = PanelWorldMapBestiaryScript.new(self)
	panel_tower_boss_rush = PanelTowerBossRushScript.new(self)
	panel_alchemy = PanelAlchemyScript.new(self)
	panel_auction = PanelAuctionScript.new(self)
	panel_equipment = PanelEquipmentScript.new(self)
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_hud_layout()
	_refresh_all()

	# Khởi tạo giá trị thanh ban đầu không bị giật
	hp_bar.value = target_hp_val
	qi_bar.value = target_qi_val
	exp_bar.value = target_exp_val

	var init_m: Dictionary = GameDatabase.get_map_def(PlayerData.current_map_id)
	if not init_m.is_empty():
		map_banner_lbl.text = "%s — %s" % [str(init_m.get("chapter", "Chương 01")), str(init_m.get("name", ""))]

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
			qi_val_lbl.text = "Đấu Khí  %d / %d" % [cur_i, max_i]
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
	# 1. Ô Đánh Thường [LMB]
	if slot_lmb != null:
		var has_w: bool = PlayerData.has_weapon_equipped()
		var w_icon_p: String = "res://assets/sprites/icons/skill_unarmed.png"
		var w_name: String = "Quyền Cước (Tay Không)"
		if has_w:
			var w_inst: Dictionary = PlayerData.equipped_gear.get("weapon", {})
			var tdef: Dictionary = GameDatabase.get_equipment_template(str(w_inst.get("template_id", "")))
			w_icon_p = str(tdef.get("icon", w_icon_p))
			w_name = EquipmentSystem.get_item_display_name(w_inst)
		slot_lmb.set_slot_visual(_get_cached_tex(w_icon_p), "ATK %d" % int(PlayerData.get_atk()), false, false, false, Color("#FFE599"))
		slot_lmb.set_tooltip_info(
			"Đánh Thường [Chuột Trái] — %s" % w_name,
			"Combo 3 nhịp liền thân · Công kích: %d" % int(PlayerData.get_atk()),
			"Nhấp Chuột Trái lên màn hình để tung 3 đòn liên hoàn theo hướng con trỏ chuột (nhịp 3 đánh diện rộng + rung chấn).",
			Color("#FFE599")
		)

	# 2. 4 Ô Đấu Kỹ [Q] [E] [R] [F]
	var default_locked_icons: Dictionary = {
		"Q": "res://assets/sprites/icons/skill_toai_thach.png",
		"E": "res://assets/sprites/icons/skill_bat_cuc_bang.png",
		"R": "res://assets/sprites/icons/skill_phe_lang_xich.png",
		"F": "res://assets/sprites/icons/skill_hoa_lien.png"
	}
	var lock_hints: Dictionary = {
		"Q": "Bái sư Dược Lão tại Vách Đá Hậu Sơn để học Toái Thạch Chưởng [Q]!",
		"E": "Đánh bại Tiêu Ninh ở Lễ Thành Niên hoặc mở Rương Cổ Hậu Sơn!",
		"R": "Sang Chương 02 (Ma Thú Sơn Mạch) gặp Tiểu Y Tiên để học Diễm Phân Phệ Lãng Xích!",
		"F": "Chỉ mở khóa ở Chương 03 Sa Mạc Tháp Qua Nhĩ sau khi thu phục Thanh Liên Địa Tâm Hỏa (#19)!"
	}
	_slot_qi_costs.clear()
	for slot_k in ["Q", "E", "R", "F"]:
		var btn: MobaSlotButton = skill_slots[slot_k]
		var sid: String = PlayerData.get_skill_in_slot(slot_k)
		if sid == "":
			btn.set_slot_visual(_get_cached_tex(str(default_locked_icons[slot_k])), "KHÓA", true, false, false)
			btn.set_tooltip_info(
				"Ô Đấu Kỹ [%s] — Chưa Mở Khóa" % slot_k,
				"Chuẩn nguyên tác · Mở dần theo cốt truyện",
				str(lock_hints[slot_k]),
				Color("#ADB5BD")
			)
		else:
			var sdef: Dictionary = GameDatabase.get_skill_def(sid)
			var ic_p: String = str(sdef.get("icon", default_locked_icons[slot_k]))
			var qi_c: float = float(sdef.get("qi_cost", 15.0))
			if str(sdef.get("behavior", "")) == "fire_lotus_ult":
				qi_c *= PlayerData.get_lotus_qi_cost_multiplier()
			_slot_qi_costs[slot_k] = qi_c
			var low_qi: bool = (PlayerData.current_qi < qi_c)
			var is_buff_on: bool = (sid == "thien_hoa_tam_huyen_bien" and PlayerData.is_flame_buff_active)
			var mi: Dictionary = PlayerData.get_skill_mastery_info(sid)
			var eff_cd: float = float(sdef.get("cooldown", 5.0)) * float(mi.get("cd_mult", 1.0))
			var dmg_pct: int = int(round((float(mi.get("dmg_mult", 1.0)) - 1.0) * 100.0))
			var m_tag: String = " · %s (+%d%% DMG)" % [str(mi.get("tier_name", "Sơ Khuy")), dmg_pct] if dmg_pct > 0 else " · %s" % str(mi.get("tier_name", "Sơ Khuy"))
			btn.set_slot_visual(_get_cached_tex(ic_p), "%d QI" % int(qi_c), false, is_buff_on, low_qi, Color("#FF758F") if low_qi else Color("#70D6FF"))
			btn.set_tooltip_info(
				"[%s] %s" % [slot_k, str(sdef.get("name", sid))],
				"%s%s · Tốn %d Đấu Khí · Hồi %.1fs" % [str(sdef.get("grade", "")), m_tag, int(qi_c), eff_cd],
				str(sdef.get("description", "")) + "\n(Thông thạo: %d lần xuất chiêu · Mở [K] để xem thưởng Thông Thạo & đổi chiêu!)" % int(mi.get("uses", 0)),
				mi.get("color", Color("#FFD166")) as Color
			)

	# 3. Ô Trợ Chiến [T] Cốt Linh Phụ Thể / Mỹ Đỗ Toa Đấu Tông Hộ Pháp
	var btn_t: MobaSlotButton = skill_slots["T"]
	var t_mode: String = PlayerData.get_assist_mode()
	if t_mode == "medusa_dau_tong":
		btn_t.set_slot_visual(
			_get_cached_tex("res://assets/sprites/npcs/npc_my_do_toa.png"),
			"ĐẤU TÔNG",
			false,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#E0AAFF")
		)
		btn_t.set_tooltip_info(
			"[T] Đấu Tông Mỹ Đỗ Toa Hộ Pháp",
			"Hồi 45s · Duy trì 12s · ATK x2.45 · SPD +40% · Sóng Không Gian",
			"Thỏa thuận Phục Linh Tử Đan! Triệu hồi bản thể Đấu Tông Mỹ Đỗ Toa bộc phát sóng xung kích Thất Thải & tăng cường chiến lực cực hạn!",
			Color("#E0AAFF")
		)
	elif t_mode == "sleeping":
		btn_t.set_slot_visual(
			_get_cached_tex("res://assets/sprites/icons/skill_duoc_lao_assist.png"),
			"NGỦ SAY",
			true,
			false,
			false,
			Color("#ADB5BD")
		)
		btn_t.set_tooltip_info(
			"[T] Dược Lão Đang Ngủ Say Trong Nhẫn Đen",
			"Tạm khóa theo cốt truyện Chương 04 (sau vụ nổ Song Sắc Hỏa Liên tại Mặc Gia)",
			"Dược Lão đã tiêu hao toàn bộ tàn hồn che chở cho bạn trước Mặc Thừa & Bát Dực Hắc Xà Hoàng! Hãy tự lực chinh phục Đế Đô & Vân Lam Sơn (tới khi Đấu Tông Mỹ Đỗ Toa xuất thế bảo hộ)!",
			Color("#ADB5BD")
		)
	else:
		var t_unl: bool = (t_mode == "duoc_lao")
		btn_t.set_slot_visual(
			_get_cached_tex("res://assets/sprites/icons/skill_duoc_lao_assist.png"),
			"PHỤ THỂ" if t_unl else "KHÓA",
			not t_unl,
			PlayerData.is_duoc_lao_active,
			false,
			Color("#A8DADC")
		)
		btn_t.set_tooltip_info(
			"[T] Cốt Linh Phụ Thể (Dược Lão)" + ("" if t_unl else " — Chưa Mở Khóa"),
			"Hồi 45s · Duy trì 12s · ATK x2.2 & Cốt Linh Lãnh Hỏa" if t_unl else "Mở khóa khi hạ Boss Chương 01: Gia Liệt Áo",
			"Dược Lão mượn thân thể Tiêu Viêm xuất chiến trong 12 giây, bùng phát ngọn Cốt Linh Lãnh Hỏa (#11)!" if t_unl else "Hoàn thành trận đánh bại Gia Liệt Áo cuối Chương 01 để mở khóa chiêu này.",
			Color("#70D6FF") if t_unl else Color("#ADB5BD")
		)

	# 4. Ô Lướt [Space] (Tự nâng cấp hiển thị Tam Thiên Lôi Động hoặc Tử Vân Dực!)
	var has_thunder: bool = PlayerData.is_skill_unlocked("tam_thien_loi_dong")
	var has_wings: bool = PlayerData.has_tu_van_duc_equipped()
	var dash_sub: String = "Lôi Động" if has_thunder else ("Tử Vân" if has_wings else "Lướt")
	var dash_col: Color = Color("#72EFDD") if has_thunder else (Color("#E0AAFF") if has_wings else Color("#70D6FF"))
	var dash_tex: Texture2D = _get_cached_tex("res://assets/sprites/icons/skill_tam_thien_loi_dong.png") if has_thunder else (
		_get_cached_tex("res://assets/sprites/icons/skill_tu_van_duc.png") if has_wings else _get_cached_tex("res://assets/sprites/icons/skill_dash.png")
	)
	slot_dash.set_slot_visual(
		dash_tex,
		dash_sub,
		false,
		has_wings or has_thunder,
		false,
		dash_col
	)
	if has_thunder:
		slot_dash.set_tooltip_info(
			"[Space] Tam Thiên Lôi Động — Thân Pháp Lôi Thiểm!",
			"Hồi 0.62s · I-frame 0.42s · Để lại Tàn Ảnh Lôi Điện giật chậm & phá thế địch!",
			"Thân pháp Địa Giai của Phong Lôi Các: mỗi lần lướt né hóa hồ quang sấm sét để lại Lôi Ảnh gây tê liệt kẻ địch áp sát!",
			Color("#72EFDD")
		)
	else:
		slot_dash.set_tooltip_info(
			"[Space] Lướt Tử Vân Dực (ĐÃ NÂNG CẤP!)" if has_wings else "[Space] Thân Pháp Lướt Né",
			"Hồi 0.64s · Tăng +35% cự ly & I-frame dài hơn!" if has_wings else "Hồi 0.7s · Có khung bất tử (I-frame)",
			"Đôi cánh Tử Vân Dực bùng phát lông vũ tím giúp bay vọt vượt đạn Boss cực nhanh!" if has_wings else "Lướt nhanh né cú húc Sơn Trư và 3 tia Nguyệt Nha của Boss! (Lấy Tử Vân Dực ở Huyền Nhai Sơn Động để nâng cấp!)",
			Color("#C77DFF") if has_wings else Color("#4CC9F0")
		)

	# 5. Ô Trọng Áp [C]
	var has_xich: bool = PlayerData.has_huyen_trong_xich_equipped()
	var sealed: bool = has_xich and PlayerData.is_ruler_sealed
	slot_weight.set_slot_visual(
		_get_cached_tex("res://assets/sprites/weapons/huyen_trong_xich.png"),
		"+30%" if sealed else ("Mở" if has_xich else "KHÓA"),
		not has_xich,
		sealed,
		false,
		Color("#70D6FF") if sealed else Color("#FFE599")
	)
	slot_weight.set_tooltip_info(
		"[C] Phong Ấn Huyền Trọng Xích" + (" (ĐANG BẬT)" if sealed else ""),
		"Trạng thái: Trọng Áp (-15% SPD, +30% EXP) <-> Giải Phong" if has_xich else "Cần đeo vũ khí [Huyền Trọng Xích]",
		"Bấm để chuyển đổi tức thì giữa chế độ Khổ Tu (+30% EXP) và Giải Phong toàn tốc khi đánh Boss!" if has_xich else "Hạ Boss Gia Liệt Áo cuối Chương 01 để Dược Lão trao Huyền Trọng Xích.",
		Color("#70D6FF")
	)

	# 6. Ô Đồng Hành [G]
	var has_comp: bool = not PlayerData.unlocked_companions.is_empty()
	var cur_c: String = PlayerData.active_companion_id
	var c_tex: Texture2D = _get_cached_tex("res://assets/sprites/npcs/npc_duoc_lao.png")
	var c_sub: String = "Bật" if cur_c != "" else ("Tắt" if has_comp else "KHÓA")
	var c_col: Color = Color("#80ED99")
	if cur_c == "tieu_y_tien":
		c_tex = _get_cached_tex("res://assets/sprites/npcs/npc_tieu_y_tien.png")
		c_sub = "Y Tiên"
	elif cur_c == "thai_lan":
		c_tex = _get_cached_tex("res://assets/sprites/enemies/pet_thai_lan.png")
		c_sub = "Thải Lân"
		c_col = Color("#72EFDD")
	elif cur_c == "huan_nhi":
		c_tex = _get_cached_tex("res://assets/sprites/npcs/npc_huan_nhi.png")
		c_sub = "Huân Nhi"
		c_col = Color("#FFD166")
	elif cur_c == "duoc_lao_phantom":
		c_sub = "Dược Lão"
		c_col = Color("#70D6FF")
	slot_companion.set_slot_visual(
		c_tex,
		c_sub,
		not has_comp,
		cur_c != "",
		false,
		c_col
	)
	slot_companion.set_tooltip_info(
		"[G] Đồng Hành Trợ Chiến — " + (PlayerData.get_companion_display_name(cur_c) if has_comp else "Chưa mở"),
		"Bấm để triệu hồi hoặc chuyển đổi Đồng Hành" if has_comp else "Mở khóa: Dược Lão (Ch.01), Tiểu Y Tiên (Ch.02), Thải Lân (Ch.03)",
		"Tiểu Y Tiên hồi máu & phóng độc châm; Hồn Ảnh Dược Lão phóng Cốt Linh Hỏa; Thần Thú Thải Lân bắn tia 7 màu siêu mạnh & Hộ Chủ cứu nguy khi HP < 35%!",
		c_col
	)

	# 7. 3 Ô Đan Dược Bấm Uống Ngay [1] [2] [3] (hỗ trợ cả Băng Tâm Đan & Hạt Thanh Liên Tử!)
	var pill_visual_meta: Dictionary = {
		"pill_ngung_huyet_tan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Hồi ngay +%d HP", "col": Color("#EF476F") },
		"pill_bang_tam_dan": { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Tứ Phẩm · Hồi ngay +%d HP!", "col": Color("#70D6FF") },
		"pill_hoi_khi_dan": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Hồi ngay +%d Đấu Khí (QI)", "col": Color("#38BDF8") },
		"pill_thanh_lien_tu": { "icon": "res://assets/sprites/icons/pill_qi_blue.png", "sub": "Kỳ Bảo · Hồi ngay +%d Đấu Khí!", "col": Color("#2EC4B6") },
		"pill_truc_co_linh_dich": { "icon": "res://assets/sprites/icons/pill_exp_jade.png", "sub": "Nhận ngay +%d EXP Đấu Khí", "col": Color("#06D6A0") }
	}
	for pi in range(3):
		var slot_n: int = pi + 1
		var pid: String = PlayerData.get_effective_quick_pill(slot_n)
		var idef: Dictionary = GameDatabase.get_item_def(pid)
		var pmeta: Dictionary = pill_visual_meta.get(pid, { "icon": "res://assets/sprites/icons/pill_hp_red.png", "sub": "Đan dược", "col": Color("#FFE599") })
		var cnt: int = PlayerData.get_item_count(pid)
		var pb: MobaSlotButton = pill_slots[pi]
		var badge_col: Color = Color("#72EFDD") if (pid == "pill_bang_tam_dan" or pid == "pill_thanh_lien_tu") and cnt > 0 else (Color("#FFFFFF") if cnt > 0 else Color("#6C757D"))
		pb.set_slot_visual(_get_cached_tex(str(pmeta["icon"])), "x%d" % cnt, false, false, cnt <= 0, badge_col)

		var eff_amt: int = 0
		var itype: String = str(idef.get("type", ""))
		if itype == "consumable_hp":
			eff_amt = int(round(float(idef.get("heal_hp", 75.0)) * PlayerData.get_heal_effectiveness_mult()))
		elif itype == "consumable_qi":
			eff_amt = int(round(float(idef.get("restore_qi", 55.0))))
		elif itype == "consumable_exp":
			eff_amt = int(idef.get("grant_exp", 240))
		var sub_str: String = (str(pmeta["sub"]) % eff_amt) if str(pmeta["sub"]).find("%d") != -1 else str(pmeta["sub"])
		pb.set_tooltip_info(
			"[%d] %s (Đang có: %d)" % [slot_n, str(idef.get("name", pid)), cnt],
			sub_str,
			str(idef.get("description", "")) + "\n(Tự động chuyển sang Băng Tâm Đan / Hạt Thanh Liên Tử khi hết đan sơ cấp — hoặc đổi trực tiếp trong [L] / [I]!)",
			pmeta["col"] as Color
		)

	# 8. 8 Nút Hệ Thống góc trái dưới
	var sys_meta: Dictionary = {
		"I": { "icon": "res://assets/sprites/icons/icon_armor.png", "sub": "Đồ", "locked": false, "glow": false, "t": "[I] Trang Bị 10 Ô & Cường Hóa", "d": "Mặc/tháo 10 ô trang bị, xem Set Bonus, cường hóa & phân giải đồ thừa." },
		"K": { "icon": "res://assets/sprites/icons/skill_toai_thach.png", "sub": "Kỹ", "locked": false, "glow": false, "t": "[K] Kho %d Đấu Kỹ & Xưởng Hỏa Liên" % GameDatabase.skills_by_id.size(), "d": "Tự do lắp các Đấu Kỹ đã lĩnh ngộ vào phím Q/E/R, xem Độ Thông Thạo và ghép Hỏa cho Phật Nộ Hỏa Liên." },
		"B": { "icon": "res://assets/sprites/icons/icon_stone.png", "sub": "Đột!" if PlayerData.is_at_bottleneck() else "Cảnh", "locked": false, "glow": PlayerData.is_at_bottleneck(), "t": "[B] Cảnh Giới & Đột Phá", "d": "Xem tiến độ 12 Đại Cảnh Giới, Linh Hồn Lực và bấm Đột Phá khi đạt 9 Đoạn/Tinh Đỉnh Phong!" },
		"L": { "icon": "res://assets/sprites/icons/icon_cauldron.png", "sub": "Đan", "locked": not PlayerData.is_alchemy_unlocked(), "glow": false, "t": "[L] Lò Luyện Đan Tương Tác", "d": "Khai lò luyện đan qua Mini-game Khống Hỏa [Space] & Chắn Đan Lôi [E]!" },
		"H": { "icon": "res://assets/sprites/icons/skill_hoa_lien.png", "sub": "Hỏa", "locked": not PlayerData.is_flames_unlocked(), "glow": false, "t": "[H] Dị Hỏa Bảng & Phần Quyết", "d": "Xem và vận chuyển các Thú Hỏa / Dị Hỏa đã thu phục theo đúng cốt truyện." },
		"M": { "icon": "res://assets/sprites/icons/icon_pendant.png", "sub": "Map", "locked": false, "glow": false, "t": "[M] Thế Giới · Hồng Nhan · Tâm Ma · Tháp & Đồ Giám", "d": "Xem 25 bản đồ, Buff Hồng Nhan, Tâm Ma Luyện Cảnh (23 Boss), Thiên Phần Tháp Roguelite & Đồ Giám Vạn Thú!" },
		"F5": { "icon": "res://assets/sprites/icons/icon_ring.png", "sub": "Lưu", "locked": false, "glow": false, "t": "[F5] Lưu Nhanh Vào Ô %d" % PlayerData.active_save_slot, "d": "Lưu tức thì toàn bộ tiến độ tu luyện, bản đồ & trang bị vào ô hiện tại." },
		"ESC": { "icon": "res://assets/sprites/icons/icon_necklace.png", "sub": "Menu", "locked": false, "glow": false, "t": "[ESC] Menu Tạm Dừng & Hiển Thị", "d": "Lưu/Tải 3 Ô Nạp Giới, chỉnh Fullscreen/VSync/FPS/Rung màn hình & Âm lượng BGM/SFX." }
	}
	for k in sys_meta.keys():
		if sys_buttons.has(k):
			var sm: Dictionary = sys_meta[k]
			var b: MobaSlotButton = sys_buttons[k]
			b.set_slot_visual(_get_cached_tex(str(sm["icon"])), str(sm["sub"]), bool(sm["locked"]), bool(sm["glow"]), false)
			b.set_tooltip_info(str(sm["t"]), "Bấm chuột trực tiếp hoặc nhấn phím [%s]" % str(k), str(sm["d"]), Color("#FFD166"))

	_refresh_interact_button()


func _on_boss_status_updated(boss_name: String, realm_badge: String, cur_hp: float, max_hp: float, phase: int, visible_bar: bool) -> void:
	boss_bar_panel.visible = visible_bar
	if not visible_bar:
		boss_is_staggered = false
		boss_p2_warning = false
		return
	boss_title_lbl.text = "%s  <%s>" % [boss_name, realm_badge]
	if not boss_p2_warning:
		boss_phase_lbl.text = "GIAI ĐOẠN II — CUỒNG BẠO!" if phase >= 2 else "GIAI ĐOẠN I"
		boss_phase_lbl.add_theme_color_override("font_color", Color("#FF2A5F") if phase >= 2 else Color("#FFD166"))
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
func _open_dialogue(speaker: String, avatar_path: String, lines: Array, finish_action: String) -> void:
	if lines.is_empty():
		return
	if current_modal != "":
		_close_modal()
	_hide_slot_tooltip()

	dialogue_active = true
	dialogue_lines = lines
	dialogue_index = 0
	dialogue_finish_action = finish_action
	dialogue_choices = []
	dlg_speaker_lbl.text = speaker
	if avatar_path != "":
		dlg_avatar_rect.texture = load(avatar_path)
	dialogue_panel.visible = true
	_render_dialogue_line()
	_sync_player_input_block()


func _open_choice_dialogue(speaker: String, avatar_path: String, lines: Array, choices: Array) -> void:
	if lines.is_empty():
		return
	if current_modal != "":
		_close_modal()
	_hide_slot_tooltip()

	dialogue_active = true
	dialogue_lines = lines
	dialogue_index = 0
	dialogue_finish_action = ""
	dialogue_choices = choices
	dlg_speaker_lbl.text = speaker
	if avatar_path != "":
		dlg_avatar_rect.texture = load(avatar_path)
	dialogue_panel.visible = true
	_render_dialogue_line()
	_sync_player_input_block()


func _render_dialogue_line() -> void:
	if dialogue_index >= dialogue_lines.size():
		return
	dlg_body_lbl.text = str(dialogue_lines[dialogue_index])
	var is_last: bool = (dialogue_index >= dialogue_lines.size() - 1)

	for ch in dlg_choices_vbox.get_children():
		ch.queue_free()

	if is_last and not dialogue_choices.is_empty():
		dialogue_panel.offset_top = -336
		dlg_choices_vbox.visible = true
		dlg_next_btn.visible = false
		for c_entry in dialogue_choices:
			if not (c_entry is Dictionary):
				continue
			var cd: Dictionary = c_entry
			var act_str: String = str(cd.get("action", ""))
			var cb := Button.new()
			cb.text = "▸ " + str(cd.get("label", "Chọn"))
			cb.alignment = HORIZONTAL_ALIGNMENT_LEFT
			cb.custom_minimum_size = Vector2(0, 30)
			cb.add_theme_font_size_override("font_size", 13)
			cb.add_theme_color_override("font_color", Color("#FFD166"))
			cb.pressed.connect(func() -> void:
				AudioManager.play_sfx("ui_click")
				dialogue_finish_action = act_str
				_close_dialogue(true)
			)
			dlg_choices_vbox.add_child(cb)
	else:
		dialogue_panel.offset_top = -288
		dlg_choices_vbox.visible = false
		dlg_next_btn.visible = true
		dlg_next_btn.text = ("Hoàn tất [V / Enter] (%d/%d)" % [dialogue_index + 1, dialogue_lines.size()]) if is_last else ("Tiếp tục [V / Enter] (%d/%d)" % [dialogue_index + 1, dialogue_lines.size()])


func _advance_dialogue() -> void:
	if not dialogue_active:
		return
	AudioManager.play_sfx("ui_click")
	dialogue_index += 1
	if dialogue_index < dialogue_lines.size():
		_render_dialogue_line()
	else:
		_close_dialogue(true)


func _close_dialogue(run_finish_action: bool) -> void:
	var act: String = dialogue_finish_action
	dialogue_active = false
	dialogue_lines = []
	dialogue_index = 0
	dialogue_finish_action = ""
	dialogue_choices = []
	dlg_choices_vbox.visible = false
	dialogue_panel.visible = false
	_sync_player_input_block()

	if run_finish_action and act != "":
		_execute_dialogue_action(act)


func _execute_dialogue_action(act: String) -> void:
	if act.begins_with("effect:"):
		var eff_id: String = act.substr(7)
		var eff: Dictionary = GameDatabase.get_story_effect(eff_id)
		if not eff.is_empty():
			var res: Dictionary = PlayerData.execute_story_effect(eff)
			if bool(res.get("heal_full", false)):
				_heal_player_full("")
			var oshop: String = str(res.get("open_shop", ""))
			if oshop != "":
				shop_venue_id = "nha_phi"
				shop_tab = "shop"
				_open_nha_phi_shop()
			var oauc: String = str(res.get("open_auction", ""))
			if oauc != "":
				_open_auction_house(oauc)
			var warp_m: String = str(eff.get("warp_map", ""))
			if warp_m != "":
				var w: Node = _find_world()
				if w != null and w.has_method("load_map"):
					var wsp_arr: Array = eff.get("warp_spawn", [])
					var wsp: Vector2 = Vector2(float(wsp_arr[0]), float(wsp_arr[1])) if wsp_arr.size() >= 2 else Vector2.ZERO
					w.load_map(warp_m, wsp, true)
		return
	elif act.begins_with("flag:"):
		var flag_id: String = act.substr(5)
		PlayerData.set_story_flag(flag_id)
		if flag_id == "met_tieu_y_tien" or flag_id == "met_tieu_dinh_le" or flag_id == "pact_hai_ba_dong":
			_heal_player_full("")
		elif flag_id == "absorbed_tu_hoa":
			PlayerData.set_story_flag("van_chi_departed")
			_heal_player_full("")
	elif act == "choice:lang_anh_quiet":
		PlayerData.set_story_flag("secret_lang_anh_done")
		_on_banter("Lăng Ảnh khẽ gật đầu rồi tan biến vào bóng đêm, để lại kỳ vật [Hắc Ảnh Phù (+8% Tốc Chạy)]!")
	elif act == "choice:lang_anh_bow":
		PlayerData.set_story_flag("secret_lang_anh_done")
		PlayerData.add_affection("huan_nhi", 10)
		PlayerData.bonus_soul += 4
		EventBus.stats_changed.emit()
		_on_banter("Lăng Ảnh hơi kinh ngạc trước sự bình tĩnh của bạn, để lại [Hắc Ảnh Phù], +10 Hảo Cảm Huân Nhi & +4 Linh Hồn!")
	elif act == "choice:van_chi_herb_fish":
		PlayerData.add_affection("van_chi", 30)
		PlayerData.set_story_flag("met_van_chi")
		_heal_player_full("Vân Chi khẽ mỉm cười trước tài nướng cá thảo mộc (+30 Hảo Cảm Vân Chi)! Giờ tiến vào Hang Tím phía Đông hạ Tiểu Sư Vương!")
	elif act == "choice:van_chi_pink_powder":
		PlayerData.add_affection("van_chi", 15)
		PlayerData.add_story_relic("Kỷ Niệm Ẩn: Bữa Cá Nướng 'Bỏng Môi' Bên Suối")
		PlayerData.set_story_flag("met_van_chi")
		_heal_player_full("Vân Chi ăn xong đỏ bừng mặt lao thẳng xuống Bờ Suối Trăng Bạc mắng 'tiểu tặc vô sỉ'! (+15 Hảo Cảm & Kỷ Niệm Ẩn!)")
	elif act == "choice:u_lan_hug":
		PlayerData.add_affection("tieu_y_tien", 40)
		PlayerData.set_story_flag("ch02_farewell_done")
		_heal_player_full("Tiêu Viêm bọc Tử Hỏa ôm chặt Tiểu Y Tiên giữa vòng cỏ héo (+40 Hảo Cảm)! Hẹn ngày tương phùng tại Xuất Vân Đế Quốc!")
	elif act == "choice:u_lan_promise":
		PlayerData.add_affection("tieu_y_tien", 20)
		PlayerData.set_story_flag("ch02_farewell_done")
		_heal_player_full("Tiểu Y Tiên lau nước mắt mỉm cười (+20 Hảo Cảm) rồi lặng lẽ để lại bức thư chia ly hướng về Xuất Vân Đế Quốc!")
	elif act == "choice:thanh_lan_sister":
		PlayerData.add_affection("thanh_lan", 35)
		PlayerData.set_story_flag("met_thanh_lan")
		_heal_player_full("Thanh Lân bật khóc cảm động (+35 Hảo Cảm Thanh Lân)! Bích Xà Tam Hoa Đồng mở lối xuống Hố Cát Bắc Địa Huyệt Dung Nham!")
	elif act == "choice:thanh_lan_protect":
		PlayerData.add_affection("thanh_lan", 20)
		PlayerData.set_story_flag("met_thanh_lan")
		_heal_player_full("Thanh Lân gật đầu biết ơn (+20 Hảo Cảm Thanh Lân)! Hố Cát Bắc dẫn xuống Địa Huyệt Dung Nham đã mở!")
	elif act == "choice:van_van_call_name":
		PlayerData.add_affection("van_chi", 35)
		PlayerData.set_story_flag("van_van_ch03_done")
		PlayerData.add_story_relic("Kỷ Niệm: Mũi Kiếm Nghiêng Ba Tấc Của Vân Vận")
		_heal_player_full("Đôi mắt phượng của Vân Vận nhòe đi, nàng khẽ nghiêng kiếm mở lối giữa bão cát (+35 Hảo Cảm Vân Vận)!")
	elif act == "choice:van_van_silent":
		PlayerData.add_affection("van_chi", 20)
		PlayerData.set_story_flag("van_van_ch03_done")
		_heal_player_full("Vân Vận nghiêng mũi kiếm ba tấc giữ kín bí mật cho Tiêu Viêm (+20 Hảo Cảm Vân Vận)!")
	elif act == "choice:devour_bang_tam":
		if PlayerData.get_item_count("pill_bang_tam_dan") > 0:
			PlayerData.remove_item("pill_bang_tam_dan", 1)
			PlayerData.add_exp(400)
		PlayerData.set_story_flag("ch03_completed")
		EventBus.screen_shake_requested.emit(12.0, 0.45)
		_heal_player_full("NIẾT BÀN THÀNH CÔNG! Băng Tâm Đan bảo vệ kinh mạch — thu phục [#19 Thanh Liên Địa Tâm Hỏa] + Thần Thú [Thải Lân] + Tuyệt Kỹ [F] PHẬT NỘ HỎA LIÊN!!")
	elif act == "choice:devour_iron_will":
		PlayerData.bonus_soul += 6
		PlayerData.set_story_flag("ch03_completed")
		EventBus.screen_shake_requested.emit(12.0, 0.45)
		_heal_player_full("Ý CHÍ ƯỚC HẸN 3 NĂM BẤT KHUẤT (+6 SOUL)! Thu phục [#19 Thanh Liên Địa Tâm Hỏa] + Thần Thú [Thải Lân] + Tuyệt Kỹ [F] PHẬT NỘ HỎA LIÊN!!")
	elif act == "feed_thai_lan":
		PlayerData.add_affection("my_do_toa", 15)
		_heal_player_full("Thải Lân vui vẻ nuốt Hỏa Tinh tỏa Thất Thải Quang Mang (+15 Hảo Cảm Thải Lân / Mỹ Đỗ Toa)!")
	elif act == "gift_huan_nhi":
		PlayerData.set_story_flag("huan_nhi_gift")
		PlayerData.add_affection("huan_nhi", 15)
		PlayerData.add_item("herb_ngung_huyet_thao", 2)
		PlayerData.add_item("pill_ngung_huyet_tan", 1)
		AudioManager.play_sfx("loot_rare")
		_on_banter("Tiêu Huân Nhi tặng bạn: Ngưng Huyết Thảo x2 & Ngưng Huyết Tán x1 (+15 Hảo Cảm)! Hãy tới gặp Nạp Lan Yên Nhiên [V].")
	elif act == "heal_full":
		_heal_player_full("Đã hồi phục toàn bộ HP & Đấu Khí!")
	elif act == "open_shop:nha_phi":
		_open_nha_phi_shop()


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
	realm_lbl.text = "%s%s" % [PlayerData.get_realm_display_title(), bottleneck_tag]
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

	sub_stat_lbl.text = "ATK %d · DEF %d · EXP %d/%d · Hỏa: %s" % [
		int(PlayerData.get_atk()), int(PlayerData.get_def()), PlayerData.current_exp, req_e, f_tag
	]
	_refresh_moba_dock()


func _refresh_quest_ui() -> void:
	var q: Dictionary = PlayerData.get_current_quest()
	if q.is_empty():
		if PlayerData.is_demo_mode:
			quest_lbl.text = "★ CHẾ ĐỘ DEMO — MỞ KHÓA TẤT CẢ ★\nBấm [M] Dịch Chuyển Nhanh %d Map (Ch01–Ch05), thử [F] Hỏa Liên, [H] 28 Hỏa & [K] Đấu Kỹ!" % GameDatabase.maps_ordered.size()
		else:
			quest_lbl.text = "★ HOÀN TẤT CHƯƠNG 05 (HẮC GIÁC VỰC & NGOẠI VIỆN) ★\nTự do khiêu chiến Thiên Phần Tháp, Tâm Ma Luyện Cảnh (23 Boss) & chuẩn bị vào Chương 06: Nội Viện!"
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
	if current_modal != "":
		_populate_modal()


func _on_map_changed(_map_id: String, map_title: String) -> void:
	map_banner_lbl.text = map_title


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
	modal_title_lbl.text = "[K] KHO ĐẤU KỸ (%d / %d ĐÃ LĨNH NGỘ) & XƯỞNG DUNG HỢP HỎA LIÊN" % [PlayerData.unlocked_skills.size(), GameDatabase.skills_by_id.size()]

	var active_bar := _make_styled_panel(Color(0.10, 0.11, 0.20, 0.94), Color("#FFD166"), 1, 8)
	vbox.add_child(active_bar)
	var q_n: String = str(GameDatabase.get_skill_def(PlayerData.slot_q_skill).get("name", "(Trống)")) if PlayerData.slot_q_skill != "" else "(Trống)"
	var e_n: String = str(GameDatabase.get_skill_def(PlayerData.slot_e_skill).get("name", "(Trống)")) if PlayerData.slot_e_skill != "" else "(Trống)"
	var r_n: String = str(GameDatabase.get_skill_def(PlayerData.slot_r_skill).get("name", "(Trống)")) if PlayerData.slot_r_skill != "" else "(Trống)"
	var f_n: String = str(GameDatabase.get_skill_def(PlayerData.slot_f_skill).get("name", "(Khóa — Ch.03)")) if PlayerData.slot_f_skill != "" else "(Khóa — Chương 03)"
	active_bar.add_child(_make_label("Bộ Chiêu Đang Lắp:  [Q] %s   |   [E] %s   |   [R] %s   |   [F] %s" % [q_n, e_n, r_n, f_n], 13, Color("#FFE599")))

	for sid in GameDatabase.skills_by_id.keys():
		var sdef: Dictionary = GameDatabase.get_skill_def(str(sid))
		var is_unl: bool = PlayerData.is_skill_unlocked(str(sid))
		var is_ult: bool = (str(sid) == "phat_no_hoa_lien")
		var border_c: Color = Color("#FF9F1C") if is_unl else Color("#343A40")
		var card := _make_styled_panel(Color(0.08, 0.09, 0.16, 0.94), border_c, 1, 7)
		vbox.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		var ic_p: String = str(sdef.get("icon", "res://assets/sprites/icons/skill_toai_thach.png"))
		var ic_box: PanelContainer = _make_icon_box(ic_p, border_c, 44)
		if not is_unl:
			ic_box.modulate = Color(0.45, 0.48, 0.55, 0.70)
		row.add_child(ic_box)

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info_v)

		var title_col: Color = Color("#FFD166") if is_unl else Color("#6C757D")
		var lock_tag: String = "" if is_unl else " [KHÓA]"
		var mi: Dictionary = PlayerData.get_skill_mastery_info(str(sid))
		var eff_cd: float = float(sdef.get("cooldown", 5.0)) * float(mi.get("cd_mult", 1.0))
		info_v.add_child(_make_label("%s  <%s>%s   |   QI: %d  |  CD: %.1fs" % [
			str(sdef.get("name", sid)), str(sdef.get("grade", "")), lock_tag,
			int(sdef.get("qi_cost", 15)), eff_cd
		], 13, title_col))

		if is_unl:
			var m_tier_idx: int = int(mi.get("tier", 0))
			var m_tier: String = str(mi.get("tier_name", "Sơ Khuy"))
			var m_uses: int = int(mi.get("uses", 0))
			var m_next: int = int(mi.get("next_uses", 8))
			var dmg_b: int = int(round((float(mi.get("dmg_mult", 1.0)) - 1.0) * 100.0))
			var cd_b: int = int(round((1.0 - float(mi.get("cd_mult", 1.0))) * 100.0))
			var rad_b: int = int(round((float(mi.get("radius_mult", 1.0)) - 1.0) * 100.0))
			var m_col: Color = mi.get("color", Color("#A8DADC")) as Color
			var prog_s: String = "ĐẠT TỐI ĐA (%d lần)" % m_uses if m_tier_idx >= 3 else "%d / %d lần" % [m_uses, m_next]
			var bonus_s: String = "+%d%% DMG · -%d%% CD · +%d%% Phạm Vi" % [dmg_b, cd_b, rad_b] if dmg_b > 0 else "Dùng %d lần để đạt Tiểu Thành (+12%% DMG, -6%% CD)" % m_next
			info_v.add_child(_make_label("★ Thông Thạo: %s (%s) — %s" % [m_tier, prog_s, bonus_s], 11, m_col))
			var m_bar := _make_bar(m_col, 5, 220)
			m_bar.max_value = 100.0
			m_bar.value = 100.0 if m_tier_idx >= 3 else clampf(100.0 * float(m_uses) / float(max(1, m_next)), 0.0, 100.0)
			info_v.add_child(m_bar)

		var sub_txt: String = str(sdef.get("description", "")) if is_unl else ("Nguồn mở khóa: " + str(sdef.get("unlock_source", "")))
		var dl := _make_label(sub_txt, 11, Color("#CED4DA") if is_unl else Color("#868E96"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(dl)

		if is_unl and not is_ult:
			var sk_key: String = str(sid)
			for slot_k in ["Q", "E", "R"]:
				var k_cap: String = slot_k
				var is_here: bool = (PlayerData.get_skill_in_slot(k_cap) == sk_key)
				var b := Button.new()
				b.text = "Đang ở [%s]" % k_cap if is_here else "Gắn [%s]" % k_cap
				b.disabled = is_here
				b.add_theme_font_size_override("font_size", 11)
				b.pressed.connect(func() -> void:
					PlayerData.assign_skill_to_slot(k_cap, sk_key)
					modal_status_lbl.text = "Đã lắp [%s] vào ô [%s] trên thanh MOBA!" % [str(sdef.get("name", sk_key)), k_cap]
				)
				row.add_child(b)

	var lotus_card := _make_styled_panel(Color(0.12, 0.06, 0.14, 0.94), Color("#C77DFF"), 2, 10)
	vbox.add_child(lotus_card)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 6)
	lotus_card.add_child(lv)

	var bonus_pct: int = max(0, PlayerData.lotus_fusion_flames.size() - 1) * 28
	lv.add_child(_make_label("XƯỞNG DUNG HỢP PHẬT NỘ HỎA LIÊN (%d/4 Hỏa đã ghép — Uy lực +%d%% + Hiệu ứng riêng từng Hỏa!)" % [PlayerData.lotus_fusion_flames.size(), bonus_pct], 14, Color("#E0AAFF")))
	if PlayerData.unlocked_flames.is_empty():
		lv.add_child(_make_label("Chưa thu phục ngọn Hỏa nào! Hãy bái sư Dược Lão (Phàm Hỏa) -> Hạ Mục Xà (Tử Hỏa) -> Sa Mạc Chương 03 (Thanh Liên Địa Tâm Hỏa).", 12, Color("#ADB5BD")))
	else:
		# Đổi sang HFlowContainer để tự xuống dòng gọn gàng kể cả khi mở đủ 28 Hỏa trong Chế Độ DEMO!
		var f_flow := HFlowContainer.new()
		f_flow.add_theme_constant_override("h_separation", 6)
		f_flow.add_theme_constant_override("v_separation", 6)
		lv.add_child(f_flow)
		for fid in PlayerData.unlocked_flames:
			var f_str: String = str(fid)
			var fdef: Dictionary = GameDatabase.get_flame_def(f_str)
			var in_lotus: bool = PlayerData.lotus_fusion_flames.has(f_str)
			var fb := Button.new()
			fb.text = ("★ " if in_lotus else "+ ") + str(fdef.get("name", f_str))
			fb.tooltip_text = "Hiệu ứng Hỏa Liên: " + str(fdef.get("lotus_effect", ""))
			fb.add_theme_font_size_override("font_size", 11)
			if in_lotus:
				fb.add_theme_color_override("font_color", Color(str(fdef.get("mid_hex", "#FFD166"))).lightened(0.28))
			fb.pressed.connect(func() -> void:
				modal_status_lbl.text = PlayerData.toggle_lotus_fusion_flame(f_str)
			)
			f_flow.add_child(fb)

		if not PlayerData.lotus_fusion_flames.is_empty():
			var eff_lines: Array = []
			for lf in PlayerData.lotus_fusion_flames:
				var ldef: Dictionary = GameDatabase.get_flame_def(str(lf))
				eff_lines.append("• %s: %s" % [str(ldef.get("name", lf)), str(ldef.get("lotus_effect", ""))])
			var eff_lbl := _make_label("Hiệu ứng Đang Kích Hoạt trong [F] Phật Nộ Hỏa Liên:\n" + "\n".join(eff_lines), 11, Color("#80ED99"))
			eff_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lv.add_child(eff_lbl)


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
	modal_title_lbl.text = "[B] TU LUYỆN CẢNH GIỚI & LINH HỒN (12 ĐẠI CẢNH GIỚI)"
	var r_def: Dictionary = GameDatabase.get_realm_def(PlayerData.realm_index)
	var req_item_id: String = str(r_def.get("breakthrough_item", "none"))
	var req_item_name: String = "Không cần"
	var owned_cnt: int = 0
	if req_item_id != "none":
		var idef: Dictionary = GameDatabase.get_item_def(req_item_id)
		req_item_name = str(idef.get("name", req_item_id))
		owned_cnt = PlayerData.get_item_count(req_item_id)

	var info_txt: String = (
		"• Cảnh giới hiện tại: %s (EXP: %d / %d)\n" % [PlayerData.get_realm_display_title(), PlayerData.current_exp, PlayerData.get_required_exp()]
		+ "• Cảnh giới Linh Hồn: %s (%d SOUL)\n" % [PlayerData.get_soul_realm_name(), PlayerData.get_soul()]
		+ "• Hệ số nhận EXP hiện tại: x%.2f\n" % PlayerData.get_exp_multiplier()
		+ "• Đan dược đột phá Đại Cảnh Giới kế tiếp: %s (Đang có: %d)\n" % [req_item_name, owned_cnt]
		+ "• Đặc quyền cảnh giới hiện tại: %s" % str(r_def.get("unlock_feature", ""))
	)
	var info_lbl := _make_label(info_txt, 14, Color("#E9ECEF"))
	info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(info_lbl)

	var bt_btn := Button.new()
	bt_btn.text = "PHÁ QUAN ĐỘT PHÁ ĐẠI CẢNH GIỚI!"
	bt_btn.add_theme_font_size_override("font_size", 15)
	bt_btn.pressed.connect(func() -> void:
		var res: Dictionary = PlayerData.try_breakthrough()
		modal_status_lbl.text = str(res.get("msg", ""))
		_populate_modal()
	)
	vbox.add_child(bt_btn)


# =========================================================
# [H] DỊ HỎA BẢNG & PHẦN QUYẾT
# =========================================================
func _build_flames_content(vbox: VBoxContainer) -> void:
	modal_title_lbl.text = "[H] DỊ HỎA BẢNG & PHẦN QUYẾT (ĐÃ THU PHỤC: %d / %d)" % [PlayerData.unlocked_flames.size(), GameDatabase.flames_ordered.size()]
	var hint := _make_label("Chuẩn cốt truyện: Chỉ những ngọn Hỏa bạn thực sự thu phục qua các Chương mới có thể vận chuyển!", 13, Color("#A8DADC"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint)

	for fl in GameDatabase.flames_ordered:
		if not (fl is Dictionary):
			continue
		var f_dict: Dictionary = fl
		var fid: String = str(f_dict.get("id", ""))
		var fname: String = str(f_dict.get("name", fid))
		var pq: String = str(f_dict.get("phan_quyet_tier", ""))
		var ch_src: String = str(f_dict.get("chapter_source", "Chưa mở khóa"))
		var atk_m: float = float(f_dict.get("atk_mult", 1.0))
		var exp_b: float = float(f_dict.get("exp_bonus_pct", 0.0))

		var is_unlocked: bool = PlayerData.unlocked_flames.has(fid)
		var is_cur: bool = (PlayerData.equipped_flame_id == fid)

		var row := HBoxContainer.new()
		vbox.add_child(row)

		var swatch := ColorRect.new()
		swatch.custom_minimum_size = Vector2(22, 22)
		swatch.color = Color(str(f_dict.get("mid_hex", "#FF7B00"))) if is_unlocked else Color("#2A2E39")
		row.add_child(swatch)

		var txt_str: String = ""
		var txt_col: Color = Color("#6C757D")
		if is_unlocked:
			var leff: String = str(f_dict.get("lotus_effect", ""))
			txt_str = " %s  |  Phần Quyết: %s  |  ATK x%.2f  |  +%d%% EXP  |  Luyện Đan +%d%%\n    ✦ Hỏa Liên: %s" % [
				fname, pq, atk_m, int(exp_b), int(float(f_dict.get("alchemy_bonus_pct", 0.0))), leff
			]
			txt_col = Color("#FFD166") if is_cur else Color("#F8F9FA")
		else:
			txt_str = " ???  [Chưa thu phục — %s]" % ch_src
			txt_col = Color("#6C757D")

		var lbl := _make_label(txt_str, 12, txt_col)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var btn := Button.new()
		if not is_unlocked:
			btn.text = "Khóa"
			btn.disabled = true
		elif is_cur:
			btn.text = "Đang dùng"
			btn.disabled = true
		else:
			btn.text = "Vận Chuyển"
			btn.pressed.connect(func() -> void:
				PlayerData.equip_flame(fid)
				modal_status_lbl.text = "Đã vận chuyển %s — Phần Quyết: %s!" % [fname, pq]
				_populate_modal()
			)
		btn.add_theme_font_size_override("font_size", 12)
		row.add_child(btn)
