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


func _ready() -> void:
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
	slot_dash.set_slot_visual(
		_get_cached_tex("res://assets/sprites/icons/skill_tu_van_duc.png") if (has_wings or has_thunder) else _get_cached_tex("res://assets/sprites/icons/skill_dash.png"),
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
# [ESC] MENU TẠM DỪNG — SAVE / LOAD 3 Ô + ÂM THANH + VỀ MENU CHÍNH
# =========================================================
func _build_pause_menu_content(vbox: VBoxContainer) -> void:
	modal_title_lbl.text = "[ESC] TẠM DỪNG — TỰ ĐỘNG LƯU · CHẾ ĐỘ DEMO · 3 Ô NẠP GIỚI"

	var top_btns := HBoxContainer.new()
	top_btns.add_theme_constant_override("separation", 10)
	vbox.add_child(top_btns)

	var resume_b := Button.new()
	resume_b.text = "Tiếp Tục Tu Luyện [ESC]"
	resume_b.add_theme_font_size_override("font_size", 13)
	resume_b.pressed.connect(_close_modal)
	top_btns.add_child(resume_b)

	var cur_world: Node = _find_world()
	if cur_world != null and bool(cur_world.get("is_boss_rush_active")):
		var exit_br_b := Button.new()
		exit_br_b.text = "← Rời Tâm Ma Luyện Cảnh"
		exit_br_b.add_theme_font_size_override("font_size", 13)
		exit_br_b.add_theme_color_override("font_color", Color("#FF758F"))
		exit_br_b.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			_close_modal()
			if cur_world.has_method("exit_boss_rush"):
				cur_world.exit_boss_rush()
		)
		top_btns.add_child(exit_br_b)
	elif cur_world != null and bool(cur_world.get("is_tower_active")):
		var exit_tw_b := Button.new()
		exit_tw_b.text = "← Rời Thiên Phần Luyện Khí Tháp"
		exit_tw_b.add_theme_font_size_override("font_size", 13)
		exit_tw_b.add_theme_color_override("font_color", Color("#FF9F1C"))
		exit_tw_b.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			_close_modal()
			EventBus.tower_exit_requested.emit()
		)
		top_btns.add_child(exit_tw_b)

	var main_b := Button.new()
	main_b.text = "Lưu & Về Màn Hình Chính"
	main_b.add_theme_font_size_override("font_size", 13)
	main_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.trigger_auto_save("về menu chính", true)
		PlayerData.session_returned_to_menu = true
		get_tree().paused = false
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	)
	top_btns.add_child(main_b)

	var demo_b := Button.new()
	demo_b.text = "✓ Đang Ở Chế Độ DEMO FULL (Bấm [M] Dịch Chuyển)" if PlayerData.is_demo_mode else "★ Bật Chế Độ DEMO — Mở Khóa Tất Cả Ngay!"
	demo_b.add_theme_font_size_override("font_size", 13)
	demo_b.add_theme_color_override("font_color", Color("#E0AAFF"))
	demo_b.disabled = PlayerData.is_demo_mode
	demo_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("breakthrough")
		PlayerData.activate_demo_unlock_all(3)
		if PlayerData.auto_save_enabled:
			PlayerData.save_game(3, true)
		_close_modal()
		_sync_world_after_load()
		_refresh_all()
		_on_banter("ĐÃ BẬT CHẾ ĐỘ DEMO FULL (Ô 3)! Bấm [M] Dịch Chuyển Nhanh %d bản đồ (Ch01–Ch05), bấm [F] thử Phật Nộ Hỏa Liên 4 Hỏa!" % GameDatabase.maps_ordered.size())
	)
	top_btns.add_child(demo_b)

	# Khung Tùy Chọn Tự Động Lưu & Tự Động Chơi Tiếp
	var auto_card := _make_styled_panel(Color(0.07, 0.11, 0.17, 0.94), Color("#2EC4B6"), 1, 9)
	vbox.add_child(auto_card)
	var auto_v := VBoxContainer.new()
	auto_v.add_theme_constant_override("separation", 4)
	auto_card.add_child(auto_v)

	var chk_as := CheckButton.new()
	chk_as.text = "Tự Động Lưu Dữ Liệu (Auto-Save 30s · Chuyển Map · Hoàn Thành NV · Đóng Game)"
	chk_as.button_pressed = PlayerData.auto_save_enabled
	chk_as.add_theme_font_size_override("font_size", 12)
	chk_as.add_theme_color_override("font_color", Color("#72EFDD"))
	chk_as.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.set_auto_save_enabled(on)
		modal_status_lbl.text = "Đã BẬT Tự Động Lưu (Auto-Save)!" if on else "Đã TẮT Tự Động Lưu!"
	)
	auto_v.add_child(chk_as)

	var chk_ac := CheckButton.new()
	chk_ac.text = "Tự Động Vào Chơi Tiếp Bản Lưu Gần Nhất Khi Mở Game Lần Sau"
	chk_ac.button_pressed = PlayerData.auto_continue_on_start
	chk_ac.add_theme_font_size_override("font_size", 12)
	chk_ac.add_theme_color_override("font_color", Color("#FFE599"))
	chk_ac.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		PlayerData.set_auto_continue_on_start(on)
		modal_status_lbl.text = "Lần sau mở game sẽ tự động tiếp tục từ Ô %d!" % PlayerData.active_save_slot if on else "Đã tắt tự động vào game khi khởi động."
	)
	auto_v.add_child(chk_ac)

	var aud_card := _make_styled_panel(Color(0.09, 0.11, 0.19, 0.94), Color("#70D6FF"), 1, 9)
	vbox.add_child(aud_card)
	var aud_v := VBoxContainer.new()
	aud_v.add_theme_constant_override("separation", 5)
	aud_card.add_child(aud_v)

	var bgm_l := _make_label("Nhạc Nền Cổ Phong (BGM): %d%%" % int(round(AudioManager.bgm_volume * 100.0)), 13, Color("#FFE599"))
	aud_v.add_child(bgm_l)
	var bgm_s := HSlider.new()
	bgm_s.min_value = 0.0
	bgm_s.max_value = 1.0
	bgm_s.step = 0.05
	bgm_s.value = AudioManager.bgm_volume
	bgm_s.value_changed.connect(func(v: float) -> void:
		AudioManager.set_bgm_volume(v)
		PlayerData.save_user_settings()
		bgm_l.text = "Nhạc Nền Cổ Phong (BGM): %d%%" % int(round(v * 100.0))
	)
	aud_v.add_child(bgm_s)

	var sfx_l := _make_label("Hiệu Ứng Chiến Đấu & Luyện Đan (SFX): %d%%" % int(round(AudioManager.sfx_volume * 100.0)), 13, Color("#70D6FF"))
	aud_v.add_child(sfx_l)
	var sfx_s := HSlider.new()
	sfx_s.min_value = 0.0
	sfx_s.max_value = 1.0
	sfx_s.step = 0.05
	sfx_s.value = AudioManager.sfx_volume
	sfx_s.value_changed.connect(func(v: float) -> void:
		AudioManager.set_sfx_volume(v)
		PlayerData.save_user_settings()
		sfx_l.text = "Hiệu Ứng Chiến Đấu & Luyện Đan (SFX): %d%%" % int(round(v * 100.0))
		AudioManager.play_sfx("loot_pickup", 0.0)
	)
	aud_v.add_child(sfx_s)

	# Khung Cài Đặt Hiển Thị & Cảm Giác Chiến Đấu (Fullscreen / VSync / FPS / Rung Màn Hình)
	var disp_card := _make_styled_panel(Color(0.08, 0.10, 0.18, 0.94), Color("#FFD166"), 1, 9)
	vbox.add_child(disp_card)
	var disp_v := VBoxContainer.new()
	disp_v.add_theme_constant_override("separation", 5)
	disp_card.add_child(disp_v)
	disp_v.add_child(_make_label("HIỂN THỊ & CẢM GIÁC CHIẾN ĐẤU", 13, Color("#FFD166")))

	var disp_row := HFlowContainer.new()
	disp_row.add_theme_constant_override("h_separation", 14)
	disp_row.add_theme_constant_override("v_separation", 4)
	disp_v.add_child(disp_row)

	var chk_fs := CheckButton.new()
	chk_fs.text = "Toàn Màn Hình (Fullscreen)"
	chk_fs.button_pressed = AudioManager.is_fullscreen
	chk_fs.add_theme_font_size_override("font_size", 12)
	chk_fs.add_theme_color_override("font_color", Color("#F8F9FA"))
	chk_fs.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		AudioManager.set_fullscreen(on)
		modal_status_lbl.text = "Đã chuyển sang Toàn Màn Hình!" if on else "Đã chuyển về chế độ Cửa Sổ 1280×720!"
	)
	disp_row.add_child(chk_fs)

	var chk_vs := CheckButton.new()
	chk_vs.text = "Đồng Bộ Khung Hình (VSync)"
	chk_vs.button_pressed = AudioManager.vsync_enabled
	chk_vs.add_theme_font_size_override("font_size", 12)
	chk_vs.add_theme_color_override("font_color", Color("#A8DADC"))
	chk_vs.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		AudioManager.set_vsync(on)
		modal_status_lbl.text = "Đã BẬT VSync (Chống xé hình)!" if on else "Đã TẮT VSync (Mở khóa FPS tối đa)!"
	)
	disp_row.add_child(chk_vs)

	var chk_fps := CheckButton.new()
	chk_fps.text = "Hiện FPS Góc Phải"
	chk_fps.button_pressed = AudioManager.show_fps
	chk_fps.add_theme_font_size_override("font_size", 12)
	chk_fps.add_theme_color_override("font_color", Color("#80ED99"))
	chk_fps.toggled.connect(func(on: bool) -> void:
		AudioManager.play_sfx("ui_click")
		AudioManager.set_show_fps(on)
		modal_status_lbl.text = "Đã BẬT hiển thị FPS!" if on else "Đã ẩn hiển thị FPS."
	)
	disp_row.add_child(chk_fps)

	var shk_l := _make_label("Cường Độ Rung Màn Hình (Screen Shake): %d%%" % int(round(AudioManager.shake_scale * 100.0)), 12, Color("#FF9F1C"))
	disp_v.add_child(shk_l)
	var shk_s := HSlider.new()
	shk_s.min_value = 0.0
	shk_s.max_value = 1.0
	shk_s.step = 0.1
	shk_s.value = AudioManager.shake_scale
	shk_s.value_changed.connect(func(v: float) -> void:
		AudioManager.set_shake_scale(v)
		shk_l.text = "Cường Độ Rung Màn Hình (Screen Shake): %d%%" % int(round(v * 100.0))
	)
	disp_v.add_child(shk_s)

	# Khung Đổi Phím Tùy Chỉnh (Key Rebinding — Tự Lưu & Đồng Bộ Thanh MOBA!)
	var kb_card := _make_styled_panel(Color(0.07, 0.09, 0.16, 0.94), Color("#C77DFF"), 1, 9)
	vbox.add_child(kb_card)
	var kb_v := VBoxContainer.new()
	kb_v.add_theme_constant_override("separation", 6)
	kb_card.add_child(kb_v)

	var kb_hdr := HBoxContainer.new()
	kb_v.add_child(kb_hdr)
	var kb_title := _make_label("ĐỔI PHÍM TÙY CHỈNH (KEY REBINDING — Bấm ô phím rồi nhấn phím mới)", 13, Color("#E0AAFF"))
	kb_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kb_hdr.add_child(kb_title)

	var kb_reset := Button.new()
	kb_reset.text = "Khôi Phục Mặc Định"
	kb_reset.add_theme_font_size_override("font_size", 11)
	kb_reset.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		rebinding_action = ""
		AudioManager.reset_default_keybinds()
		modal_status_lbl.text = "Đã khôi phục toàn bộ phím điều khiển mặc định!"
		_populate_modal()
	)
	kb_hdr.add_child(kb_reset)

	var kb_grid := HFlowContainer.new()
	kb_grid.add_theme_constant_override("h_separation", 8)
	kb_grid.add_theme_constant_override("v_separation", 6)
	kb_v.add_child(kb_grid)

	var kb_specs: Array = [
		["move_up", "Đi Lên"], ["move_down", "Đi Xuống"], ["move_left", "Sang Trái"], ["move_right", "Sang Phải"],
		["dash", "Lướt Né"], ["interact", "Tương Tác"], ["skill_q", "Đấu Kỹ 1"], ["skill_e", "Đấu Kỹ 2"],
		["skill_r", "Đấu Kỹ 3"], ["skill_ult", "Hỏa Liên"], ["skill_assist", "Trợ Chiến"],
		["toggle_weight", "Trọng Áp"], ["toggle_companion", "Đồng Hành"], ["soul_radar", "Radar Hồn"]
	]
	for spec in kb_specs:
		var act_k: String = str(spec[0])
		var act_lbl: String = str(spec[1])
		var is_wait: bool = (rebinding_action == act_k)
		var kb_btn := Button.new()
		kb_btn.text = "%s: [Nhấn phím...]" % act_lbl if is_wait else "%s: [%s]" % [act_lbl, AudioManager.get_action_key_label(act_k)]
		kb_btn.add_theme_font_size_override("font_size", 11)
		if is_wait:
			kb_btn.add_theme_color_override("font_color", Color("#FFD166"))
		kb_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			rebinding_action = act_k
			modal_status_lbl.text = "Đang đổi phím [%s] — Hãy nhấn phím bất kỳ trên bàn phím (ESC để hủy)!" % act_lbl
			_populate_modal()
		)
		kb_grid.add_child(kb_btn)

	vbox.add_child(_make_label("3 Ô LƯU TIẾN ĐỘ NẠP GIỚI (Ô hiện tại: Ô %d)" % PlayerData.active_save_slot, 14, Color("#FFD166")))
	for s in range(1, PlayerData.MAX_SAVE_SLOTS + 1):
		var info: Dictionary = PlayerData.get_save_slot_summary(s)
		var exists: bool = bool(info.get("exists", false))
		var card := _make_styled_panel(Color(0.09, 0.10, 0.17, 0.94), Color("#FFD166") if exists else Color("#495057"), 1, 8)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		card.add_child(row)

		var l := _make_label(str(info.get("label", "")), 13, Color("#F8F9FA") if exists else Color("#ADB5BD"))
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(l)

		var slot_n: int = s
		var save_b := Button.new()
		save_b.text = "Lưu Vào Ô %d" % slot_n
		save_b.pressed.connect(func() -> void:
			if PlayerData.save_game(slot_n):
				modal_status_lbl.text = "Đã lưu thành công vào Ô %d!" % slot_n
				_populate_modal()
		)
		row.add_child(save_b)

		var load_b := Button.new()
		load_b.text = "Tải Ô %d" % slot_n
		load_b.disabled = not exists
		load_b.pressed.connect(func() -> void:
			if PlayerData.load_game(slot_n):
				_close_modal()
				_sync_world_after_load()
				_refresh_all()
				_on_banter("Đã tải tiến độ từ Ô Lưu %d!" % slot_n)
		)
		row.add_child(load_b)


# =========================================================
# [M] BẢN ĐỒ THẾ GIỚI (25 BẢN ĐỒ CH.01–05), HỒNG NHAN, TÂM MA, THIÊN PHẦN THÁP & ĐỒ GIÁM
# =========================================================
func _build_world_map_content(vbox: VBoxContainer) -> void:
	var total_maps: int = GameDatabase.maps_ordered.size()
	modal_title_lbl.text = "[M] THẾ GIỚI (%d MAP) • HỒNG NHAN • TÂM MA LUYỆN CẢNH • ĐỒ GIÁM VẠN THÚ" % total_maps
	vbox.add_theme_constant_override("separation", 6)

	# Thanh chuyển 4 tab gọn gàng (HFlowContainer chống tràn ngang)
	var tab_row := HFlowContainer.new()
	tab_row.add_theme_constant_override("h_separation", 7)
	tab_row.add_theme_constant_override("v_separation", 6)
	vbox.add_child(tab_row)

	var unclaimed_gifts: int = 0
	for prof in PlayerData.get_heroine_profiles():
		var hk: String = str(prof.get("key", ""))
		var cur_a: int = PlayerData.get_affection(hk)
		for ms in prof.get("milestones", []):
			var req_v: int = int(ms.get("req", 999))
			if ms.has("gift_items") and cur_a >= req_v and not PlayerData.is_affection_milestone_claimed(hk, req_v):
				unclaimed_gifts += 1

	var tab_maps_btn := Button.new()
	tab_maps_btn.text = ("★ " if world_map_tab == "maps" else "") + "Bản Đồ (%d)" % total_maps
	tab_maps_btn.disabled = (world_map_tab == "maps")
	tab_maps_btn.add_theme_font_size_override("font_size", 12)
	tab_maps_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		world_map_tab = "maps"
		_populate_modal()
	)
	tab_row.add_child(tab_maps_btn)

	var gift_badge: String = " [%d QUÀ!]" % unclaimed_gifts if unclaimed_gifts > 0 else ""
	var tab_her_btn := Button.new()
	tab_her_btn.text = ("★ " if world_map_tab == "heroines" else "") + "Hồng Nhan" + gift_badge
	tab_her_btn.disabled = (world_map_tab == "heroines")
	tab_her_btn.add_theme_font_size_override("font_size", 12)
	tab_her_btn.add_theme_color_override("font_color", Color("#FFD166") if unclaimed_gifts > 0 else Color("#E0AAFF"))
	tab_her_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		world_map_tab = "heroines"
		_populate_modal()
	)
	tab_row.add_child(tab_her_btn)

	var tab_br_btn := Button.new()
	tab_br_btn.text = ("★ " if world_map_tab == "boss_rush" else "") + "⚔ Tâm Ma Luyện Cảnh"
	tab_br_btn.disabled = (world_map_tab == "boss_rush")
	tab_br_btn.add_theme_font_size_override("font_size", 12)
	tab_br_btn.add_theme_color_override("font_color", Color("#FF758F"))
	tab_br_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		world_map_tab = "boss_rush"
		_populate_modal()
	)
	tab_row.add_child(tab_br_btn)

	var tab_best_btn := Button.new()
	tab_best_btn.text = ("★ " if world_map_tab == "bestiary" else "") + "📖 Đồ Giám Vạn Thú"
	tab_best_btn.disabled = (world_map_tab == "bestiary")
	tab_best_btn.add_theme_font_size_override("font_size", 12)
	tab_best_btn.add_theme_color_override("font_color", Color("#72EFDD"))
	tab_best_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		world_map_tab = "bestiary"
		_populate_modal()
	)
	tab_row.add_child(tab_best_btn)

	var tab_tw_btn := Button.new()
	tab_tw_btn.text = ("★ " if world_map_tab == "tower" else "") + "🔥 Thiên Phần Tháp"
	tab_tw_btn.disabled = (world_map_tab == "tower")
	tab_tw_btn.add_theme_font_size_override("font_size", 12)
	tab_tw_btn.add_theme_color_override("font_color", Color("#FF9F1C"))
	tab_tw_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		world_map_tab = "tower"
		_populate_modal()
	)
	tab_row.add_child(tab_tw_btn)

	if world_map_tab == "heroines":
		_build_heroines_affection_tab(vbox)
		return
	elif world_map_tab == "boss_rush":
		_build_boss_rush_tab(vbox)
		return
	elif world_map_tab == "bestiary":
		_build_bestiary_tab(vbox)
		return
	elif world_map_tab == "tower":
		_build_tower_tab(vbox)
		return

	# 1. Tóm tắt Buff Hồng Nhan & Kỳ Vật Cốt Truyện
	var lore_card := _make_styled_panel(Color(0.11, 0.08, 0.16, 0.94), Color("#E0AAFF"), 1, 7)
	vbox.add_child(lore_card)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 3)
	lore_card.add_child(lv)
	lv.add_child(_make_label(
		"HỒNG NHAN:  Huân Nhi %d  |  Tiểu Y Tiên %d  |  Vân Chi %d  |  Thanh Lân %d  |  Thải Lân %d" % [
			PlayerData.get_affection("huan_nhi"),
			PlayerData.get_affection("tieu_y_tien"),
			PlayerData.get_affection("van_chi"),
			PlayerData.get_affection("thanh_lan"),
			PlayerData.get_affection("my_do_toa")
		],
		12,
		Color("#FFD166")
	))
	var buff_l := _make_label("Buff Hảo Cảm Đang Kích Hoạt: " + PlayerData.get_active_affection_summary_text(), 11, Color("#80ED99"))
	buff_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(buff_l)
	var relic_txt: String = " · ".join(PlayerData.story_relics) if not PlayerData.story_relics.is_empty() else "(Chưa thu thập — Hãy hoàn thành các mốc cốt truyện & kỳ ngộ ẩn!)"
	var rl := _make_label("Kỳ Vật & Danh Hiệu Đã Đạt (%d): %s" % [PlayerData.story_relics.size(), relic_txt], 11, Color("#A8DADC"))
	rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(rl)

	var last_chapter: String = ""
	for mid in GameDatabase.maps_ordered:
		var m_def: Dictionary = GameDatabase.get_map_def(str(mid))
		if m_def.is_empty():
			continue
		var ch_lbl: String = str(m_def.get("chapter", ""))
		if ch_lbl != "" and ch_lbl != last_chapter:
			last_chapter = ch_lbl
			var ch_hdr := _make_label("═══ %s ═══" % ch_lbl.to_upper(), 13, Color("#70D6FF"))
			vbox.add_child(ch_hdr)
		var is_here: bool = (PlayerData.current_map_id == str(mid))
		var ch_list: Array = m_def.get("chests", [])
		var opened_cnt: int = 0
		for c in ch_list:
			if c is Dictionary and PlayerData.is_chest_opened(str(c.get("id", ""))):
				opened_cnt += 1

		var border_c: Color = Color("#FFD166") if is_here else Color("#3A506B")
		var card := _make_styled_panel(Color(0.09, 0.11, 0.19, 0.94), border_c, 2 if is_here else 1, 5)
		vbox.add_child(card)
		var row_m := HBoxContainer.new()
		row_m.add_theme_constant_override("separation", 8)
		card.add_child(row_m)

		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_theme_constant_override("separation", 1)
		row_m.add_child(v)

		var here_tag: String = "   [★ BẠN ĐANG Ở ĐÂY]" if is_here else ""
		v.add_child(_make_label("%s — %s%s" % [str(m_def.get("chapter", "")), str(m_def.get("name", "")), here_tag], 12, Color("#FFD166") if is_here else Color("#F8F9FA")))

		var npc_names: Array = []
		for n in m_def.get("npcs", []):
			if n is Dictionary:
				npc_names.append(str(n.get("name", "")))
		var npc_str: String = ", ".join(npc_names) if not npc_names.is_empty() else "(Khu bí cảnh chiến đấu)"
		v.add_child(_make_label("• NPC: %s   |   Bảo Rương: %d / %d đã mở" % [npc_str, opened_cnt, ch_list.size()], 11, Color("#CED4DA")))

		if PlayerData.is_demo_mode and not is_here:
			var target_mid: String = str(mid)
			var tp_btn := Button.new()
			tp_btn.text = "Dịch Chuyển ->"
			tp_btn.add_theme_font_size_override("font_size", 12)
			tp_btn.add_theme_color_override("font_color", Color("#E0AAFF"))
			tp_btn.pressed.connect(func() -> void:
				AudioManager.play_sfx("portal_warp")
				_close_modal()
				var w: Node = _find_world()
				if w != null and w.has_method("load_map"):
					w.load_map(target_mid, Vector2.ZERO, true)
			)
			row_m.add_child(tp_btn)


func _build_heroines_affection_tab(vbox: VBoxContainer) -> void:
	var sum_card := _make_styled_panel(Color(0.11, 0.08, 0.17, 0.95), Color("#FFD166"), 1, 8)
	vbox.add_child(sum_card)
	var sum_v := VBoxContainer.new()
	sum_v.add_theme_constant_override("separation", 3)
	sum_card.add_child(sum_v)
	sum_v.add_child(_make_label("TỔNG BUFF HẢO CẢM HỒNG NHAN ĐANG KÍCH HOẠT (CỘNG THẲNG VÀO CHỈ SỐ TIÊU VIÊM):", 12, Color("#FFD166")))
	var s_lbl := _make_label(PlayerData.get_active_affection_summary_text(), 12, Color("#80ED99"))
	s_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sum_v.add_child(s_lbl)

	# Khu vực Tặng Quà cho Hồng Nhan đang chọn
	var gift_card := _make_styled_panel(Color(0.08, 0.11, 0.17, 0.94), Color("#2EC4B6"), 1, 8)
	vbox.add_child(gift_card)
	var gv := VBoxContainer.new()
	gv.add_theme_constant_override("separation", 5)
	gift_card.add_child(gv)

	var sel_name: String = selected_gift_heroine
	var sel_favs: Array = []
	var sel_fav_hint: String = ""
	for p in PlayerData.get_heroine_profiles():
		if str(p.get("key", "")) == selected_gift_heroine:
			sel_name = str(p.get("name", ""))
			sel_favs = p.get("favorite_items", [])
			sel_fav_hint = str(p.get("fav_hint", ""))
			break
	gv.add_child(_make_label("TẶNG QUÀ TĂNG HẢO CẢM -> Đang chọn: %s (%d/100)  |  Sở thích (x2 điểm): %s" % [
		sel_name, PlayerData.get_affection(selected_gift_heroine), sel_fav_hint
	], 12, Color("#72EFDD")))

	var gift_flow := HFlowContainer.new()
	gift_flow.add_theme_constant_override("h_separation", 6)
	gift_flow.add_theme_constant_override("v_separation", 5)
	gv.add_child(gift_flow)

	var any_gift: bool = false
	for iid in PlayerData.inventory.keys():
		var cnt: int = int(PlayerData.inventory[iid])
		if cnt <= 0:
			continue
		var idef: Dictionary = GameDatabase.get_item_def(str(iid))
		if str(idef.get("type", "")) == "breakthrough":
			continue
		any_gift = true
		var is_fav: bool = sel_favs.has(str(iid))
		var item_key: String = str(iid)
		var gb := Button.new()
		gb.text = "%s%s (x%d)" % ["★ " if is_fav else "", str(idef.get("name", item_key)), cnt]
		gb.add_theme_font_size_override("font_size", 11)
		if is_fav:
			gb.add_theme_color_override("font_color", Color("#FFD166"))
		gb.pressed.connect(func() -> void:
			var res: Dictionary = PlayerData.give_gift_to_heroine(selected_gift_heroine, item_key)
			modal_status_lbl.text = str(res.get("msg", ""))
			_populate_modal()
		)
		gift_flow.add_child(gb)
	if not any_gift:
		gv.add_child(_make_label("(Nạp Giới chưa có thảo dược / ma hạch / đan dược nào để tặng — hãy đánh quái hoặc mua tại Nhã Phi!)", 11, Color("#ADB5BD")))

	# 5 Thẻ Hồng Nhan chi tiết: thanh tiến độ, 4 mốc 25/50/75/100, nút Chọn Tặng Quà & Nhận Quà Tri Kỷ
	for prof in PlayerData.get_heroine_profiles():
		var hk: String = str(prof.get("key", ""))
		var col := Color(str(prof.get("color", "#FFD166")))
		var cur_a: int = PlayerData.get_affection(hk)
		var is_sel: bool = (hk == selected_gift_heroine)
		var card := _make_styled_panel(Color(0.09, 0.10, 0.17, 0.95), col if is_sel else Color("#3A4760"), 2 if is_sel else 1, 7)
		vbox.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		row.add_child(_make_icon_box(str(prof.get("sprite", "res://assets/sprites/npcs/npc_huan_nhi.png")), col, 52))

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_v.add_theme_constant_override("separation", 3)
		row.add_child(info_v)

		var hdr := HBoxContainer.new()
		hdr.add_theme_constant_override("separation", 8)
		info_v.add_child(hdr)

		var nm_l := _make_label("%s  <%s>  —  Hảo Cảm: %d / 100" % [str(prof.get("name", "")), str(prof.get("title", "")), cur_a], 13, col)
		nm_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hdr.add_child(nm_l)

		var sel_b := Button.new()
		sel_b.text = "Đang Chọn Tặng Quà" if is_sel else "Chọn Tặng Quà"
		sel_b.disabled = is_sel
		sel_b.add_theme_font_size_override("font_size", 11)
		sel_b.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			selected_gift_heroine = hk
			_populate_modal()
		)
		hdr.add_child(sel_b)

		var pbar := _make_bar(col, 9, 400)
		pbar.max_value = 100.0
		pbar.value = float(cur_a)
		info_v.add_child(pbar)

		var ms_flow := HFlowContainer.new()
		ms_flow.add_theme_constant_override("h_separation", 8)
		ms_flow.add_theme_constant_override("v_separation", 4)
		info_v.add_child(ms_flow)

		for ms in prof.get("milestones", []):
			var req_v: int = int(ms.get("req", 25))
			var reached: bool = (cur_a >= req_v)
			var desc_m: String = str(ms.get("desc", ""))
			var m_lbl := _make_label("%s [%d]: %s" % ["✓" if reached else "○", req_v, desc_m], 11, Color("#80ED99") if reached else Color("#868E96"))
			ms_flow.add_child(m_lbl)

			if ms.has("gift_items") and reached:
				var claimed: bool = PlayerData.is_affection_milestone_claimed(hk, req_v)
				var cb := Button.new()
				cb.text = "Đã nhận quà %d" % req_v if claimed else "★ Nhận Quà Mốc %d!" % req_v
				cb.disabled = claimed
				cb.add_theme_font_size_override("font_size", 11)
				if not claimed:
					cb.add_theme_color_override("font_color", Color("#FFD166"))
				cb.pressed.connect(func() -> void:
					var res: Dictionary = PlayerData.claim_affection_milestone(hk, req_v)
					modal_status_lbl.text = str(res.get("msg", ""))
					_populate_modal()
				)
				ms_flow.add_child(cb)


func _boss_rush_grade_color(g: String) -> Color:
	match g:
		"SSS":
			return Color("#FFD166")
		"SS":
			return Color("#FF4D6D")
		"S":
			return Color("#C77DFF")
		"A":
			return Color("#80ED99")
		"B":
			return Color("#70D6FF")
		_:
			return Color("#CED4DA")


func _build_boss_rush_tab(vbox: VBoxContainer) -> void:
	var sum_card := _make_styled_panel(Color(0.13, 0.05, 0.09, 0.95), Color("#FF4D6D"), 2, 9)
	vbox.add_child(sum_card)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 5)
	sum_card.add_child(sv)
	sv.add_child(_make_label("⚔ TÂM MA LUYỆN CẢNH — TÁI CHIẾN TOÀN BỘ 19 ĐẠI BOSS (XẾP HẠNG C → SSS)", 14, Color("#FFD166")))
	var desc_l := _make_label("Bước vào Đấu Trường Tâm Ma 1v1 để thử sức với bất kỳ Đại Boss nào mà KHÔNG ảnh hưởng nhiệm vụ cốt truyện! Đánh nhanh & ít mất máu đạt hạng SSS nhận tối đa Đá Cường Hóa + Kim Tệ.", 11, Color("#E2E8F0"))
	desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sv.add_child(desc_l)

	var cur_world: Node = _find_world()
	if cur_world != null and bool(cur_world.get("is_boss_rush_active")):
		var leave_btn := Button.new()
		leave_btn.text = "← Rời Tâm Ma Luyện Cảnh (Trở Về Bản Đồ Cũ)"
		leave_btn.add_theme_font_size_override("font_size", 13)
		leave_btn.add_theme_color_override("font_color", Color("#FF758F"))
		leave_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			_close_modal()
			if cur_world.has_method("exit_boss_rush"):
				cur_world.exit_boss_rush()
		)
		sv.add_child(leave_btn)

	# Chọn độ khó (Thường / Ác Mộng / Đấu Tông)
	var diff_row := HFlowContainer.new()
	diff_row.add_theme_constant_override("h_separation", 8)
	diff_row.add_theme_constant_override("v_separation", 5)
	sv.add_child(diff_row)

	var diff_specs: Array = [
		{ "k": "normal", "t": "Thường (HP x1.0 · ATK x1.0 · Thưởng x1.0)", "hp_m": 1.0, "atk_m": 1.0, "col": Color("#80ED99") },
		{ "k": "nightmare", "t": "Ác Mộng (HP x1.65 · ATK x1.35 · Thưởng x1.75)", "hp_m": 1.65, "atk_m": 1.35, "col": Color("#FF9F1C") },
		{ "k": "dau_tong", "t": "Đấu Tông (HP x2.45 · ATK x1.72 · Thưởng x2.6)", "hp_m": 2.45, "atk_m": 1.72, "col": Color("#FF4D6D") }
	]
	var cur_hp_m: float = 1.0
	var cur_atk_m: float = 1.0
	for ds in diff_specs:
		var dk: String = str(ds["k"])
		if dk == boss_rush_diff:
			cur_hp_m = float(ds["hp_m"])
			cur_atk_m = float(ds["atk_m"])
		var db := Button.new()
		db.text = ("★ " if dk == boss_rush_diff else "") + str(ds["t"])
		db.disabled = (dk == boss_rush_diff)
		db.add_theme_font_size_override("font_size", 11)
		db.add_theme_color_override("font_color", ds["col"] as Color)
		db.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			boss_rush_diff = dk
			_populate_modal()
		)
		diff_row.add_child(db)

	# Danh sách toàn bộ Boss từ GameDatabase, sắp theo Cảnh giới & HP
	var bosses: Array = []
	for eid in GameDatabase.enemies_by_id.keys():
		var ed: Dictionary = GameDatabase.get_enemy_def(str(eid))
		if bool(ed.get("is_boss", false)):
			bosses.append(ed)
	bosses.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra: int = int(a.get("realm_index", 1))
		var rb: int = int(b.get("realm_index", 1))
		if ra != rb:
			return ra < rb
		return float(a.get("max_hp", 0)) < float(b.get("max_hp", 0))
	)

	var cleared_cnt: int = 0
	for bd in bosses:
		if not PlayerData.get_boss_rush_record(str(bd.get("id", "")), boss_rush_diff).is_empty():
			cleared_cnt += 1
	sv.add_child(_make_label("Tiến độ độ khó đang chọn: Đã chinh phục %d / %d Đại Boss" % [cleared_cnt, bosses.size()], 12, Color("#72EFDD")))

	for bd in bosses:
		var bid: String = str(bd.get("id", ""))
		var rec: Dictionary = PlayerData.get_boss_rush_record(bid, boss_rush_diff)
		var has_clear: bool = not rec.is_empty()
		var best_g: String = str(rec.get("best_grade", ""))
		var border_c: Color = _boss_rush_grade_color(best_g) if has_clear else Color("#495057")

		var card := _make_styled_panel(Color(0.09, 0.08, 0.15, 0.95), border_c, 2 if has_clear else 1, 7)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		row.add_child(_make_icon_box_from_tex(_get_enemy_thumb_tex(bd), border_c, 46))

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_v.add_theme_constant_override("separation", 2)
		row.add_child(info_v)

		var sc_hp: int = int(round(float(bd.get("max_hp", 300.0)) * cur_hp_m))
		var sc_atk: int = int(round(float(bd.get("atk", 20.0)) * cur_atk_m))
		info_v.add_child(_make_label("%s  <%s>" % [str(bd.get("name", bid)), str(bd.get("realm_label", ""))], 13, Color("#FFD166")))
		info_v.add_child(_make_label("HP Tâm Ma: %d  ·  ATK: %d  ·  DEF: %d  |  Đã hạ thực chiến: %d lần" % [
			sc_hp, sc_atk, int(bd.get("def", 5)), PlayerData.get_enemy_kill_count(bid)
		], 11, Color("#CED4DA")))

		if has_clear:
			info_v.add_child(_make_label("★ Kỷ lục [%s]: HẠNG %s  ·  Nhanh nhất %.1fs  ·  Thắng %d lần" % [
				boss_rush_diff.to_upper(), best_g, float(rec.get("best_time", 0.0)), int(rec.get("clears", 1))
			], 11, _boss_rush_grade_color(best_g)))
		else:
			info_v.add_child(_make_label("Chưa có kỷ lục ở độ khó này — Hãy khiêu chiến ngay!", 11, Color("#ADB5BD")))

		var cap_bid: String = bid
		var cap_diff: String = boss_rush_diff
		var fight_btn := Button.new()
		fight_btn.text = "⚔ Khiêu Chiến!"
		fight_btn.add_theme_font_size_override("font_size", 12)
		fight_btn.add_theme_color_override("font_color", Color("#FF9F1C"))
		fight_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			_close_modal()
			EventBus.boss_rush_requested.emit(cap_bid, cap_diff)
		)
		row.add_child(fight_btn)


func _build_bestiary_tab(vbox: VBoxContainer) -> void:
	var all_enemies: Array = []
	var total_bosses: int = 0
	var defeated_species: int = 0
	var total_kills: int = 0
	for eid in GameDatabase.enemies_by_id.keys():
		var ed: Dictionary = GameDatabase.get_enemy_def(str(eid))
		all_enemies.append(ed)
		if bool(ed.get("is_boss", false)):
			total_bosses += 1
		var kc: int = PlayerData.get_enemy_kill_count(str(eid))
		if kc > 0:
			defeated_species += 1
			total_kills += kc

	all_enemies.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ra: int = int(a.get("realm_index", 1))
		var rb: int = int(b.get("realm_index", 1))
		if ra != rb:
			return ra < rb
		var ba: int = 1 if bool(a.get("is_boss", false)) else 0
		var bb: int = 1 if bool(b.get("is_boss", false)) else 0
		if ba != bb:
			return ba < bb
		return float(a.get("max_hp", 0)) < float(b.get("max_hp", 0))
	)

	var sum_card := _make_styled_panel(Color(0.06, 0.11, 0.15, 0.95), Color("#72EFDD"), 2, 9)
	vbox.add_child(sum_card)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 5)
	sum_card.add_child(sv)
	sv.add_child(_make_label("📖 ĐỒ GIÁM VẠN THÚ — %d / %d LOÀI ĐÃ TIÊU DIỆT (%d BOSS · %d QUÁI · TỔNG %d TRẬN HẠ)" % [
		defeated_species, all_enemies.size(), total_bosses, all_enemies.size() - total_bosses, total_kills
	], 13, Color("#72EFDD")))

	var f_row := HBoxContainer.new()
	f_row.add_theme_constant_override("separation", 8)
	sv.add_child(f_row)
	for fs in [
		{ "k": "all", "t": "Tất Cả (%d)" % all_enemies.size() },
		{ "k": "boss", "t": "Đại Boss (%d)" % total_bosses },
		{ "k": "mob", "t": "Ma Thú & Quái Thường (%d)" % (all_enemies.size() - total_bosses) }
	]:
		var fk: String = str(fs["k"])
		var fb := Button.new()
		fb.text = ("★ " if bestiary_filter == fk else "") + str(fs["t"])
		fb.disabled = (bestiary_filter == fk)
		fb.add_theme_font_size_override("font_size", 11)
		fb.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			bestiary_filter = fk
			_populate_modal()
		)
		f_row.add_child(fb)

	for ed in all_enemies:
		var is_b: bool = bool(ed.get("is_boss", false))
		if bestiary_filter == "boss" and not is_b:
			continue
		if bestiary_filter == "mob" and is_b:
			continue
		var eid: String = str(ed.get("id", ""))
		var kills: int = PlayerData.get_enemy_kill_count(eid)
		var border_c: Color = (Color("#FF4D6D") if is_b else Color("#52B788")) if kills > 0 else Color("#343A40")

		var card := _make_styled_panel(Color(0.08, 0.10, 0.16, 0.94), border_c, 1, 6)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		var icon_box := _make_icon_box_from_tex(_get_enemy_thumb_tex(ed), border_c, 44)
		if kills <= 0:
			icon_box.modulate = Color(0.55, 0.58, 0.65, 0.80)
		row.add_child(icon_box)

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_v.add_theme_constant_override("separation", 1)
		row.add_child(info_v)

		var kind_tag: String = "[ĐẠI BOSS]" if is_b else "[QUÁI]"
		var map_id_tag: String = str(ed.get("map_tag", ""))
		var map_name: String = str(GameDatabase.get_map_def(map_id_tag).get("name", map_id_tag))
		info_v.add_child(_make_label("%s %s  <%s>   |   Khu vực: %s" % [
			kind_tag, str(ed.get("name", eid)), str(ed.get("realm_label", "")), map_name
		], 12, Color("#FFD166") if is_b else Color("#F8F9FA")))

		info_v.add_child(_make_label("HP: %d  ·  ATK: %d  ·  DEF: %d  ·  Thưởng: %d EXP / %d Kim Tệ" % [
			int(ed.get("max_hp", 0)), int(ed.get("atk", 0)), int(ed.get("def", 0)),
			int(ed.get("exp_reward", 0)), int(ed.get("gold_reward", 0))
		], 11, Color("#CED4DA")))

		var drop_names: Array = []
		for dr in ed.get("drops", []):
			if dr is Dictionary:
				var it_id: String = str(dr.get("item_id", ""))
				var it_def: Dictionary = GameDatabase.get_item_def(it_id)
				drop_names.append(str(it_def.get("name", it_id)))
		var drop_txt: String = ", ".join(drop_names) if not drop_names.is_empty() else "Trang bị & Nguyên liệu ngẫu nhiên"
		var dl := _make_label("Vật phẩm rơi: %s" % drop_txt, 10, Color("#A8DADC"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(dl)

		var k_lbl := _make_label("Đã hạ: %d" % kills if kills > 0 else "Chưa gặp", 12, Color("#80ED99") if kills > 0 else Color("#6C757D"))
		row.add_child(k_lbl)


func _build_tower_tab(vbox: VBoxContainer) -> void:
	var sr: Dictionary = PlayerData.get_soul_realm_info()
	var card := _make_styled_panel(Color(0.14, 0.05, 0.05, 0.96), Color("#FF7B00"), 2, 12)
	vbox.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	card.add_child(v)

	v.add_child(_make_label("🔥 THIÊN PHẦN LUYỆN KHÍ THÁP — PHÓ BẢN ROGUELITE VÔ TẬN", 15, Color("#FFD166")))
	var desc := _make_label(
		"Thánh địa tu luyện trứ danh của Học Viện Già Nam! Bên trong Tháp có Tâm Hỏa Chước Đốt liên tục (Dị Hỏa giảm 45% thiêu đốt). Vượt mỗi tầng nhận ngay Tinh Hỏa Năng, Đá Cường Hóa, Kim Tệ và được chọn 1 trong 3 Chúc Phúc Tâm Hỏa cộng dồn suốt lượt leo!\n• Mỗi 3 tầng (Tầng 3, 6, 9, 12...) chạm trán Đại Boss Thủ Tháp!\n• Trọng thương trong Tháp sẽ an toàn truyền tống ra ngoài, giữ trọn 100% chiến lợi phẩm.",
		12,
		Color("#E2E8F0")
	)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(desc)

	v.add_child(_make_label("★ Kỷ lục cao nhất: Tầng %d   |   Tinh Hỏa Năng: %d   |   Radar Linh Hồn [%s]: %s (Tầm %dpx)" % [
		PlayerData.tower_best_floor,
		PlayerData.fire_energy,
		AudioManager.get_action_key_label("soul_radar"),
		str(sr.get("name", "Phàm Cảnh Linh Hồn")),
		int(round(PlayerData.get_soul_radar_radius()))
	], 12, Color("#72EFDD")))

	var btn_row := HFlowContainer.new()
	btn_row.add_theme_constant_override("h_separation", 10)
	btn_row.add_theme_constant_override("v_separation", 8)
	v.add_child(btn_row)

	var cur_world: Node = _find_world()
	if cur_world != null and bool(cur_world.get("is_tower_active")):
		var leave_b := Button.new()
		leave_b.text = "← Rời Thiên Phần Luyện Khí Tháp (Về Bản Đồ Cũ)"
		leave_b.add_theme_font_size_override("font_size", 13)
		leave_b.add_theme_color_override("font_color", Color("#FF758F"))
		leave_b.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			_close_modal()
			EventBus.tower_exit_requested.emit()
		)
		btn_row.add_child(leave_b)
	else:
		var start1 := Button.new()
		start1.text = "🔥 Khởi Hành Từ Tầng 1"
		start1.custom_minimum_size = Vector2(210, 40)
		start1.add_theme_font_size_override("font_size", 13)
		start1.add_theme_color_override("font_color", Color("#FFD166"))
		start1.pressed.connect(func() -> void:
			AudioManager.play_sfx("portal_warp")
			_close_modal()
			EventBus.tower_start_requested.emit(1)
		)
		btn_row.add_child(start1)

		for cp in [4, 7, 10]:
			if PlayerData.tower_best_floor >= cp:
				var cp_f: int = cp
				var cp_btn := Button.new()
				cp_btn.text = "⚡ Vào Nhanh Tầng %d" % cp_f
				cp_btn.custom_minimum_size = Vector2(165, 40)
				cp_btn.add_theme_font_size_override("font_size", 12)
				cp_btn.add_theme_color_override("font_color", Color("#FF9F1C"))
				cp_btn.pressed.connect(func() -> void:
					AudioManager.play_sfx("portal_warp")
					_close_modal()
					EventBus.tower_start_requested.emit(cp_f)
				)
				btn_row.add_child(cp_btn)

	# Đổi Tinh Hỏa Năng lấy phần thưởng trực tiếp!
	var shop_card := _make_styled_panel(Color(0.08, 0.10, 0.17, 0.95), Color("#FFD166"), 1, 10)
	vbox.add_child(shop_card)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 6)
	shop_card.add_child(sv)
	sv.add_child(_make_label("ĐỔI TINH HỎA NĂNG (Hiện có: %d Hỏa Năng)" % PlayerData.fire_energy, 13, Color("#FFD166")))

	var ex_row := HFlowContainer.new()
	ex_row.add_theme_constant_override("h_separation", 8)
	ex_row.add_theme_constant_override("v_separation", 6)
	sv.add_child(ex_row)

	var ex_items: Array = [
		{ "t": "Đổi 5 Đá Cường Hóa (40 Hỏa Năng)", "cost": 40, "kind": "stones", "val": 5 },
		{ "t": "Đổi 1 Lôi Ma Hạch Cấp 5 (90 Hỏa Năng)", "cost": 90, "kind": "item", "id": "core_loi_5" },
		{ "t": "Đổi 1 Huyết Ma Hạch Cấp 5 (90 Hỏa Năng)", "cost": 90, "kind": "item", "id": "core_huyet_5" },
		{ "t": "Đổi 1 Đấu Linh Đan (120 Hỏa Năng)", "cost": 120, "kind": "item", "id": "pill_dau_linh_dan" }
	]
	for ex in ex_items:
		var cost_v: int = int(ex["cost"])
		var eb := Button.new()
		eb.text = str(ex["t"])
		eb.disabled = (PlayerData.fire_energy < cost_v)
		eb.add_theme_font_size_override("font_size", 11)
		eb.pressed.connect(func() -> void:
			if PlayerData.fire_energy < cost_v:
				return
			PlayerData.add_fire_energy(-cost_v)
			if str(ex["kind"]) == "stones":
				PlayerData.enhance_stones += int(ex["val"])
				EventBus.stats_changed.emit()
			else:
				PlayerData.add_item(str(ex["id"]), 1)
			AudioManager.play_sfx("loot_rare")
			modal_status_lbl.text = "Đổi thành công: %s!" % str(ex["t"])
			_populate_modal()
		)
		ex_row.add_child(eb)


func _build_tower_blessing_content(vbox: VBoxContainer) -> void:
	modal_title_lbl.text = "🔥 CHÚC PHÚC TÂM HỎA — VƯỢT TẦNG %d THÀNH CÔNG!" % pending_tower_floor
	vbox.add_theme_constant_override("separation", 10)
	vbox.add_child(_make_label("Tâm Hỏa trong Tháp tôi luyện kinh mạch! Chọn 1 trong 3 Chúc Phúc để cộng dồn sức mạnh cho Tầng %d:" % (pending_tower_floor + 1), 13, Color("#FFE599")))

	for ch in pending_tower_choices:
		if not (ch is Dictionary):
			continue
		var cd: Dictionary = ch
		var bid: String = str(cd.get("id", ""))
		var col := Color(str(cd.get("color_hex", "#FFD166")))
		var card := _make_styled_panel(Color(0.10, 0.08, 0.16, 0.96), col, 2, 12)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		card.add_child(row)

		var iv := VBoxContainer.new()
		iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		iv.add_theme_constant_override("separation", 3)
		row.add_child(iv)
		iv.add_child(_make_label("✦ " + str(cd.get("name", bid)), 15, col))
		var dl := _make_label(str(cd.get("desc", "")), 12, Color("#E2E8F0"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		iv.add_child(dl)

		var cap_id: String = bid
		var pick_btn := Button.new()
		pick_btn.text = "Chọn Chúc Phúc →"
		pick_btn.custom_minimum_size = Vector2(170, 44)
		pick_btn.add_theme_font_size_override("font_size", 13)
		pick_btn.add_theme_color_override("font_color", col)
		pick_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("breakthrough")
			_close_modal()
			EventBus.tower_blessing_picked.emit(cap_id)
		)
		row.add_child(pick_btn)

	var exit_b := Button.new()
	exit_b.text = "← Dừng Leo & Rút Lui An Toàn (Giữ Toàn Bộ Hỏa Năng & Đá CH)"
	exit_b.add_theme_font_size_override("font_size", 12)
	exit_b.add_theme_color_override("font_color", Color("#ADB5BD"))
	exit_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("portal_warp")
		_close_modal()
		EventBus.tower_exit_requested.emit()
	)
	vbox.add_child(exit_b)


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
# [L] LÒ LUYỆN ĐAN TƯƠNG TÁC (MINI-GAME HỎA HẦU + ĐÓN ĐAN LÔI)
# =========================================================
func _build_alchemy_content(vbox: VBoxContainer) -> void:
	modal_title_lbl.text = "[L] LÒ LUYỆN ĐAN — KHỐNG HỎA & ĐÓN ĐAN LÔI (SOUL: %d)" % PlayerData.get_soul()

	if alc_active:
		_build_alchemy_minigame_view(vbox)
		return

	var inv_str: String = "Dược Liệu & Đan Dược: "
	if PlayerData.inventory.is_empty():
		inv_str += "(Trống)"
	else:
		var parts: Array = []
		for item_id in PlayerData.inventory.keys():
			var idef: Dictionary = GameDatabase.get_item_def(str(item_id))
			parts.append("%s x%d" % [str(idef.get("name", item_id)), int(PlayerData.inventory[item_id])])
		inv_str += "  |  ".join(parts)

	var inv_lbl := _make_label(inv_str, 13, Color("#FFE599"))
	inv_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(inv_lbl)

	# Khung Đan Dược Sử Dụng Trực Tiếp (cho phép uống Băng Tâm Đan, Hạt Thanh Liên Tử & chọn gắn lên phím [1]/[2]!)
	var pill_card := _make_styled_panel(Color(0.08, 0.11, 0.17, 0.94), Color("#70D6FF"), 1, 7)
	vbox.add_child(pill_card)
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 4)
	pill_card.add_child(pv)
	pv.add_child(_make_label("ĐAN DƯỢC HỒI PHỤC TRONG NẠP GIỚI (Bấm Uống trực tiếp hoặc Gắn vào ô [1] / [2]):", 12, Color("#70D6FF")))
	var p_flow := HFlowContainer.new()
	p_flow.add_theme_constant_override("h_separation", 6)
	p_flow.add_theme_constant_override("v_separation", 5)
	pv.add_child(p_flow)
	for c_id in ["pill_ngung_huyet_tan", "pill_bang_tam_dan", "pill_hoi_khi_dan", "pill_thanh_lien_tu", "pill_truc_co_linh_dich"]:
		var cid_s: String = str(c_id)
		var owned_p: int = PlayerData.get_item_count(cid_s)
		var cdef: Dictionary = GameDatabase.get_item_def(cid_s)
		var ctype: String = str(cdef.get("type", ""))
		var p_box := HBoxContainer.new()
		p_box.add_theme_constant_override("separation", 3)
		p_flow.add_child(p_box)

		var drink_b := Button.new()
		drink_b.text = "Uống %s (x%d)" % [str(cdef.get("name", cid_s)), owned_p]
		drink_b.disabled = (owned_p <= 0)
		drink_b.add_theme_font_size_override("font_size", 11)
		drink_b.add_theme_color_override("font_color", Color(str(cdef.get("color_hex", "#FFE599"))) if owned_p > 0 else Color("#6C757D"))
		drink_b.pressed.connect(func() -> void:
			var p_nd: Node = _find_player()
			var wp: Vector2 = (p_nd as Node2D).global_position + Vector2(0, -45) if (p_nd != null and p_nd is Node2D) else Vector2.ZERO
			if PlayerData.use_consumable(cid_s, wp):
				modal_status_lbl.text = "Đã uống [%s] thành công!" % str(cdef.get("name", cid_s))
				_populate_modal()
			else:
				modal_status_lbl.text = "HP / Đấu Khí đã đầy hoặc đã hết đan dược này!"
		)
		p_box.add_child(drink_b)

		if ctype == "consumable_hp" or ctype == "consumable_qi":
			var slot_n: int = 1 if ctype == "consumable_hp" else 2
			var is_assigned: bool = (PlayerData.quick_hp_pill_id == cid_s) if slot_n == 1 else (PlayerData.quick_qi_pill_id == cid_s)
			var pin_b := Button.new()
			pin_b.text = "★[%d]" % slot_n if is_assigned else "Gắn[%d]" % slot_n
			pin_b.disabled = is_assigned
			pin_b.add_theme_font_size_override("font_size", 10)
			pin_b.pressed.connect(func() -> void:
				PlayerData.set_quick_pill_slot(slot_n, cid_s)
				modal_status_lbl.text = "Đã gắn [%s] làm đan ưu tiên cho phím [%d]!" % [str(cdef.get("name", cid_s)), slot_n]
				_populate_modal()
			)
			p_box.add_child(pin_b)

	var sample_rec: Dictionary = GameDatabase.recipes_list[0] if not GameDatabase.recipes_list.is_empty() else {}
	var preview_mods: Dictionary = AlchemySystem.get_minigame_modifiers(sample_rec)
	var tip := _make_label(
		"Thưởng Khống Hỏa Hiện Tại (+%d%% = Dị Hỏa +%d%% · Dược Đỉnh +%d%% · Tiểu Y Tiên +%d%% · Linh Hồn +%d%%) -> Vùng Đan Tâm mở rộng: [%d – %d]!" % [
			int(preview_mods.get("total_pct", 0)),
			int(preview_mods.get("flame_pct", 0)),
			int(preview_mods.get("gear_pct", 0)),
			int(preview_mods.get("aff_pct", 0)),
			int(preview_mods.get("soul_pct", 0)),
			int(round(float(preview_mods.get("zone_min", 38.0)))),
			int(round(float(preview_mods.get("zone_max", 66.0))))
		],
		12,
		Color("#80ED99")
	)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(tip)

	for rec in GameDatabase.recipes_list:
		if not (rec is Dictionary):
			continue
		var r_dict: Dictionary = rec
		var out_def: Dictionary = GameDatabase.get_item_def(str(r_dict.get("output_item", "")))
		var out_name: String = str(out_def.get("name", ""))
		var ing_dict: Dictionary = r_dict.get("ingredients", {})
		var ing_parts: Array = []
		for ik in ing_dict.keys():
			var idef: Dictionary = GameDatabase.get_item_def(str(ik))
			ing_parts.append("%s %d/%d" % [str(idef.get("name", ik)), PlayerData.get_item_count(str(ik)), int(ing_dict[ik])])

		var tier_v: int = int(r_dict.get("tier", 1))
		var rate_pct: int = int(round(AlchemySystem.get_success_chance(r_dict) * 100.0))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		vbox.add_child(row)

		var desc := _make_label(
			"[Phẩm %d] %s (Cần %d SOUL) — Nguyên liệu: %s" % [tier_v, out_name, int(r_dict.get("req_soul", 5)), ", ".join(ing_parts)],
			13,
			Color("#DEE2E6")
		)
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(desc)

		var mini_btn := Button.new()
		mini_btn.text = "Khai Lò Khống Hỏa"
		mini_btn.add_theme_font_size_override("font_size", 12)
		mini_btn.pressed.connect(func() -> void:
			_start_alchemy_minigame(r_dict)
		)
		row.add_child(mini_btn)

		if tier_v <= 1:
			var fast_btn := Button.new()
			fast_btn.text = "Luyện Nhanh (%d%%)" % rate_pct
			fast_btn.add_theme_font_size_override("font_size", 11)
			fast_btn.pressed.connect(func() -> void:
				var res: Dictionary = AlchemySystem.craft_recipe(r_dict)
				modal_status_lbl.text = str(res.get("msg", ""))
				_populate_modal()
			)
			row.add_child(fast_btn)


func _start_alchemy_minigame(recipe: Dictionary) -> void:
	var check: Dictionary = AlchemySystem.can_craft(recipe)
	if not bool(check.get("ok", false)):
		modal_status_lbl.text = str(check.get("reason", "Không đủ nguyên liệu!"))
		AudioManager.play_sfx("alchemy_fail")
		return

	AlchemySystem.consume_ingredients(recipe)
	var mods: Dictionary = AlchemySystem.get_minigame_modifiers(recipe)
	alc_zone_min = float(mods.get("zone_min", 38.0))
	alc_zone_max = float(mods.get("zone_max", 66.0))
	alc_cool_mult = float(mods.get("cool_mult", 1.0))
	alc_perfect_req = float(mods.get("perfect_ratio_req", 0.62))
	alc_pass_req = float(mods.get("pass_ratio_req", 0.28))
	alc_bonus_summary = "Thưởng Dị Hỏa +%d%% · Dược Đỉnh +%d%% · Hồng Nhan +%d%% · Linh Hồn +%d%% (Vùng xanh %d–%d · Nguội x%.2f)" % [
		int(mods.get("flame_pct", 0)), int(mods.get("gear_pct", 0)),
		int(mods.get("aff_pct", 0)), int(mods.get("soul_pct", 0)),
		int(round(alc_zone_min)), int(round(alc_zone_max)), alc_cool_mult
	]
	alc_active = true
	alc_recipe = recipe
	alc_duration = 4.8 if int(recipe.get("tier", 1)) >= 2 else 3.8
	alc_time_left = alc_duration
	alc_heat = (alc_zone_min + alc_zone_max) * 0.5
	alc_in_zone_sec = 0.0
	alc_lightning_pending = (int(recipe.get("tier", 1)) >= 2)
	alc_lightning_triggered = false
	alc_lightning_window = 0.0
	alc_lightning_blocked = false
	AudioManager.play_sfx("skill_fire")
	modal_status_lbl.text = "ĐANG NUNG LÒ! Giữ Hỏa Hầu trong vùng [%d–%d] bằng phím [Space] hoặc nút [THÚC HỎA]!" % [int(round(alc_zone_min)), int(round(alc_zone_max))]
	_populate_modal()


func _build_alchemy_minigame_view(vbox: VBoxContainer) -> void:
	var out_def: Dictionary = GameDatabase.get_item_def(str(alc_recipe.get("output_item", "")))
	var card := _make_styled_panel(Color(0.11, 0.07, 0.09, 0.96), Color("#FF9F1C"), 2, 16)
	vbox.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	card.add_child(v)

	v.add_child(_make_label("ĐANG LUYỆN CHẾ: %s  (Phẩm %d)" % [str(out_def.get("name", "")), int(alc_recipe.get("tier", 1))], 18, Color("#FFD166")))
	var b_lbl := _make_label(alc_bonus_summary, 12, Color("#72EFDD"))
	b_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(b_lbl)

	alc_info_lbl = _make_label("Hỏa Hầu: 52 / 100  (Vùng Đan Tâm chuẩn: %d — %d)" % [int(round(alc_zone_min)), int(round(alc_zone_max))], 14, Color("#80ED99"))
	v.add_child(alc_info_lbl)

	alc_heat_bar = _make_bar(Color("#FF9F1C"), 26, 920)
	alc_heat_bar.max_value = 100.0
	alc_heat_bar.value = alc_heat
	v.add_child(alc_heat_bar)

	v.add_child(_make_label("Tiến độ ngưng tụ Đan Dược:", 13, Color("#A8DADC")))
	alc_progress_bar = _make_bar(Color("#52B788"), 18, 920)
	alc_progress_bar.max_value = alc_duration
	alc_progress_bar.value = 0.0
	v.add_child(alc_progress_bar)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 16)
	v.add_child(btn_row)

	alc_pulse_btn = Button.new()
	alc_pulse_btn.text = "THÚC HỎA (+16 Nhiệt)  [Phím Space]"
	alc_pulse_btn.custom_minimum_size = Vector2(360, 48)
	alc_pulse_btn.add_theme_font_size_override("font_size", 15)
	alc_pulse_btn.pressed.connect(_alchemy_pulse_heat)
	btn_row.add_child(alc_pulse_btn)

	alc_lightning_btn = Button.new()
	alc_lightning_btn.text = "ĐAN LÔI: Chưa xuất hiện"
	alc_lightning_btn.custom_minimum_size = Vector2(360, 48)
	alc_lightning_btn.disabled = true
	alc_lightning_btn.add_theme_font_size_override("font_size", 15)
	alc_lightning_btn.pressed.connect(_alchemy_block_lightning)
	btn_row.add_child(alc_lightning_btn)


func _alchemy_pulse_heat() -> void:
	if not alc_active:
		return
	alc_heat = clampf(alc_heat + 16.0, 0.0, 100.0)
	AudioManager.play_sfx("alchemy_tick")


func _alchemy_block_lightning() -> void:
	if not alc_active or alc_lightning_window <= 0.0:
		return
	alc_lightning_blocked = true
	alc_lightning_window = 0.0
	AudioManager.play_sfx("hit_crit")
	modal_status_lbl.text = "TUYỆT VỜI! Bạn đã đánh tan ĐAN LÔI — Chắc chắn thưởng +1 viên Đan Dược!"
	if alc_lightning_btn != null and is_instance_valid(alc_lightning_btn):
		alc_lightning_btn.text = "ĐÃ CHẮN ĐAN LÔI THÀNH CÔNG!"
		alc_lightning_btn.disabled = true


func _tick_alchemy_minigame(delta: float) -> void:
	alc_time_left -= delta
	var tier_f: float = float(alc_recipe.get("tier", 1))
	var cool_rate: float = (20.0 + tier_f * 4.5 + sin(alc_time_left * 5.0) * 6.0) * alc_cool_mult
	alc_heat = clampf(alc_heat - cool_rate * delta, 0.0, 100.0)

	var in_sweet: bool = (alc_heat >= alc_zone_min and alc_heat <= alc_zone_max)
	if in_sweet:
		alc_in_zone_sec += delta

	if alc_lightning_pending and not alc_lightning_triggered and alc_time_left <= alc_duration * 0.52:
		alc_lightning_triggered = true
		var mods: Dictionary = AlchemySystem.get_minigame_modifiers(alc_recipe)
		alc_lightning_window = 1.85 + float(mods.get("lightning_extra_sec", 0.0))
		AudioManager.play_sfx("boss_roar")
		modal_status_lbl.text = "CẢNH BÁO ĐAN LÔI GIÁNG XUỐNG! Bấm ngay nút [CHẮN ĐAN LÔI] hoặc phím [E]!"

	if alc_lightning_window > 0.0:
		alc_lightning_window -= delta
		if alc_lightning_btn != null and is_instance_valid(alc_lightning_btn):
			alc_lightning_btn.disabled = false
			alc_lightning_btn.text = "CHẮN ĐAN LÔI NGAY! [E] (%.1fs)" % maxf(0.0, alc_lightning_window)
		if alc_lightning_window <= 0.0 and not alc_lightning_blocked:
			alc_heat = clampf(alc_heat - 18.0, 0.0, 100.0)
			if alc_lightning_btn != null and is_instance_valid(alc_lightning_btn):
				alc_lightning_btn.disabled = true
				alc_lightning_btn.text = "Đan Lôi đánh trúng lò (-18 nhiệt)!"

	if alc_heat_bar != null and is_instance_valid(alc_heat_bar):
		alc_heat_bar.value = alc_heat
	if alc_progress_bar != null and is_instance_valid(alc_progress_bar):
		alc_progress_bar.value = alc_duration - maxf(0.0, alc_time_left)
	if alc_info_lbl != null and is_instance_valid(alc_info_lbl):
		var z_txt: String = "ĐÚNG ĐAN TÂM" if in_sweet else ("HỎA QUÁ MẠNH!" if alc_heat > alc_zone_max else "HỎA YẾU — THÚC HỎA!")
		alc_info_lbl.text = "Hỏa Hầu: %d / 100  (Chuẩn: %d–%d)  ->  %s   |   Còn %.1fs" % [
			int(round(alc_heat)), int(round(alc_zone_min)), int(round(alc_zone_max)), z_txt, maxf(0.0, alc_time_left)
		]
		alc_info_lbl.add_theme_color_override("font_color", Color("#80ED99") if in_sweet else Color("#FF758F"))

	if alc_time_left <= 0.0:
		var ratio_ok: float = alc_in_zone_sec / maxf(0.1, alc_duration)
		var q_tier: int = 0
		if ratio_ok >= alc_perfect_req:
			q_tier = 2
		elif ratio_ok >= alc_pass_req:
			q_tier = 1
		var finished_rec: Dictionary = alc_recipe
		var blocked_l: bool = alc_lightning_blocked
		alc_active = false
		alc_recipe = {}
		var res: Dictionary = AlchemySystem.finish_minigame_craft(finished_rec, q_tier, blocked_l)
		modal_status_lbl.text = str(res.get("msg", ""))
		_populate_modal()


# =========================================================
# PHÒNG ĐẤU GIÁ MỄ ĐẶC NHĨ (NHÃ PHI) & BÁT PHIẾN MÔN (ĐẤU TRÍ · KÝ GỬI)
# =========================================================
func _build_nha_phi_shop_content(vbox: VBoxContainer) -> void:
	var venue_title: String = "ĐẠI ĐẤU GIÁ TRƯỜNG BÁT PHIẾN MÔN (HẮC ẤN THÀNH)" if shop_venue_id == "bat_phien_mon" else "PHÒNG ĐẤU GIÁ MỄ ĐẶC NHĨ (NHÃ PHI)"
	modal_title_lbl.text = "%s   |   Kim Tệ: %d   |   SOUL: %d" % [venue_title, PlayerData.gold, PlayerData.get_soul()]

	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 8)
	vbox.add_child(tab_row)

	var t_shop := Button.new()
	t_shop.text = ("★ " if shop_tab == "shop" else "") + "🛒 Mua Trực Tiếp"
	t_shop.disabled = (shop_tab == "shop")
	t_shop.add_theme_font_size_override("font_size", 12)
	t_shop.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		shop_tab = "shop"
		_populate_modal()
	)
	tab_row.add_child(t_shop)

	var t_auc := Button.new()
	t_auc.text = ("★ " if shop_tab == "auction" else "") + "⚖ Phiên Đấu Giá Đấu Trí"
	t_auc.disabled = (shop_tab == "auction")
	t_auc.add_theme_font_size_override("font_size", 12)
	t_auc.add_theme_color_override("font_color", Color("#FFD166"))
	t_auc.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		shop_tab = "auction"
		if auction_lots.is_empty():
			auction_lots = AuctionSystem.generate_auction_lots(shop_venue_id)
			active_auction_lot_idx = 0
		_populate_modal()
	)
	tab_row.add_child(t_auc)

	var t_con := Button.new()
	t_con.text = ("★ " if shop_tab == "consign" else "") + "💰 Ký Gửi Bán Đan Dược"
	t_con.disabled = (shop_tab == "consign")
	t_con.add_theme_font_size_override("font_size", 12)
	t_con.add_theme_color_override("font_color", Color("#80ED99"))
	t_con.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		shop_tab = "consign"
		_populate_modal()
	)
	tab_row.add_child(t_con)

	if shop_tab == "auction":
		_build_auction_tab(vbox)
		return
	elif shop_tab == "consign":
		_build_consign_tab(vbox)
		return

	var intro := _make_label("Nhã Phi: 'Chọn vật phẩm công tử cần! Hoặc chuyển sang tab [⚖ Phiên Đấu Giá Đấu Trí] & [💰 Ký Gửi Bán Đan Dược] để săn chí bảo và kiếm Kim Tệ giá cao!'", 13, Color("#FFE599"))
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(intro)

	var catalog: Array = [
		{
			"kind": "skill_book",
			"id": "bought_hap_chuong",
			"name": "Bí Tịch Huyền Giai: Hấp Chưởng & Xuy Hỏa Chưởng",
			"desc": "Nâng cấp phím [Q] hút gom quái & mở khóa Lôi Đài Lễ Thành Niên Tiêu Ninh!",
			"price": 120,
			"icon": "res://assets/sprites/icons/skill_hap_chuong.png",
			"color": "#38BDF8"
		},
		{
			"kind": "skill_book",
			"id": "bought_bao_bo",
			"name": "Bí Tịch Hoàng Giai Cao Cấp: Bạo Bộ",
			"desc": "Học thêm Đấu Kỹ thân pháp lao nổ thiêu đốt dọc đường (tự lắp phím trong [K])!",
			"price": 85,
			"icon": "res://assets/sprites/icons/skill_bao_bo.png",
			"color": "#FF9F1C"
		},
		{
			"kind": "weapon",
			"id": "wpn_thiet_kiem",
			"rarity": "linh",
			"name": "Thanh Thiết Kiếm (Linh Phẩm)",
			"desc": "Vũ khí đầu đời của đệ tử Tiêu Gia: ATK +11, SPD +17, đánh nhanh mượt (tự trang bị nếu đang tay không!).",
			"price": 90,
			"icon": "res://assets/sprites/weapons/thanh_thiet_kiem.png",
			"color": "#52B788"
		},
		{
			"kind": "weapon",
			"id": "wpn_tinh_cuong_dao",
			"rarity": "huyen",
			"name": "Tinh Cương Chiến Đao (Huyền Phẩm)",
			"desc": "Chiến đao thợ săn sắc bén: ATK +23, Chí mạng +15%, Sát thương Hỏa +15% + 2 dòng ngẫu nhiên!",
			"price": 260,
			"icon": "res://assets/sprites/weapons/tinh_cuong_dao.png",
			"color": "#38BDF8"
		},
		{
			"kind": "item",
			"id": "herb_tu_diep_lan",
			"name": "Tử Diệp Lan Thảo x1",
			"desc": "Dược thảo Nhất Phẩm thiết yếu để luyện Trúc Cơ Linh Dịch & Tụ Khí Tán.",
			"price": 25,
			"icon": "res://assets/sprites/pickups/herb_item.png",
			"color": "#B5838D"
		},
		{
			"kind": "item",
			"id": "herb_tay_cot_hoa",
			"name": "Tẩy Cốt Hoa x1",
			"desc": "Linh hoa âm hàn giúp tẩy kinh mạch khi luyện Trúc Cơ Linh Dịch & Tụ Khí Tán.",
			"price": 30,
			"icon": "res://assets/sprites/pickups/herb_item.png",
			"color": "#EDE0D4"
		},
		{
			"kind": "item",
			"id": "core_hoa_1",
			"name": "Hỏa Ma Hạch (Cấp 1) x1",
			"desc": "Tinh hạch Ma Thú Cấp 1 dùng dung hòa dược lực khi khai lò luyện đan.",
			"price": 45,
			"icon": "res://assets/sprites/pickups/monster_core.png",
			"color": "#FF7B00"
		},
		{
			"kind": "item",
			"id": "pill_ngung_huyet_tan",
			"name": "Ngưng Huyết Tán x1 (Ô [1])",
			"desc": "Nhất Phẩm dược tán hồi ngay 75 HP trong giao tranh.",
			"price": 20,
			"icon": "res://assets/sprites/icons/pill_hp_red.png",
			"color": "#EF476F"
		},
		{
			"kind": "item",
			"id": "pill_hoi_khi_dan",
			"name": "Hồi Khí Đan x1 (Ô [2])",
			"desc": "Nhất Phẩm đan dược hồi ngay 55 Đấu Khí (QI).",
			"price": 20,
			"icon": "res://assets/sprites/icons/pill_qi_blue.png",
			"color": "#4CC9F0"
		}
	]

	# Hàng cao cấp tại Tổng Bộ Mễ Đặc Nhĩ (mở từ cuối Chương 03 / Chương 04 Đế Đô!)
	if PlayerData.has_flag("ch03_completed") or PlayerData.is_demo_mode:
		catalog.append_array([
			{
				"kind": "item",
				"id": "herb_sa_chi_man_da_la",
				"name": "[Đế Đô VIP] Sa Chi Mạn Đà La x1",
				"desc": "Dược liệu quý luyện Phá Ách Đan (giải phong ấn Hải Ba Đông), Băng Tâm Đan & Phá Chướng Đan!",
				"price": 140,
				"icon": "res://assets/sprites/pickups/herb_item.png",
				"color": "#FFD166"
			},
			{
				"kind": "item",
				"id": "core_hoa_3",
				"name": "[Đế Đô VIP] Viêm Xà Ma Hạch (Cấp 3) x1",
				"desc": "Ma Hạch cấp 3 dùng luyện Phá Chướng Đan & Tam Văn Thanh Linh Đan.",
				"price": 180,
				"icon": "res://assets/sprites/pickups/monster_core.png",
				"color": "#FF4D6D"
			},
			{
				"kind": "item",
				"id": "core_phong_4",
				"name": "[Đế Đô VIP] Phong Ma Hạch (Cấp 4) x1",
				"desc": "Tinh hạch Ma Thú Cấp 4 nguyên liệu đúc Tam Văn Thanh Linh Đan tại Đại Hội Luyện Đan!",
				"price": 240,
				"icon": "res://assets/sprites/pickups/monster_core.png",
				"color": "#72EFDD"
			},
			{
				"kind": "item",
				"id": "pill_bang_tam_dan",
				"name": "[Đế Đô VIP] Băng Tâm Đan (Tứ Phẩm) x1",
				"desc": "Hồi ngay +185 HP! Cực kỳ hữu ích khi đánh Boss Đế Đô & Vân Lam Sơn.",
				"price": 120,
				"icon": "res://assets/sprites/icons/pill_hp_red.png",
				"color": "#70D6FF"
			},
			{
				"kind": "item",
				"id": "pill_thanh_lien_tu",
				"name": "[Đế Đô VIP] Hạt Thanh Liên Tử x1",
				"desc": "Hồi ngay +140 Đấu Khí (QI) — xả liên hoàn Phật Nộ Hỏa Liên!",
				"price": 120,
				"icon": "res://assets/sprites/icons/pill_qi_blue.png",
				"color": "#2EC4B6"
			}
		])

	for entry in catalog:
		var item_d: Dictionary = entry
		var col := Color(str(item_d.get("color", "#FFE599")))
		var card := _make_styled_panel(Color(0.09, 0.10, 0.17, 0.94), col, 1, 6)
		vbox.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		row.add_child(_make_icon_box(str(item_d.get("icon", "res://assets/sprites/icons/icon_armor.png")), col, 42))

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info_v)
		info_v.add_child(_make_label(str(item_d.get("name", "")), 13, col))
		var desc_l := _make_label(str(item_d.get("desc", "")), 11, Color("#CED4DA"))
		desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_v.add_child(desc_l)

		var price: int = int(item_d.get("price", 50))
		var kind: String = str(item_d.get("kind", "item"))
		var entry_id: String = str(item_d.get("id", ""))
		var already_owned: bool = (kind == "skill_book" and PlayerData.has_flag(entry_id))

		var buy_btn := Button.new()
		buy_btn.text = "Đã lĩnh ngộ" if already_owned else "Mua (%d Kim Tệ)" % price
		buy_btn.disabled = already_owned
		buy_btn.add_theme_font_size_override("font_size", 12)
		buy_btn.pressed.connect(func() -> void:
			_handle_shop_purchase(item_d)
		)
		row.add_child(buy_btn)


func _handle_shop_purchase(item_d: Dictionary) -> void:
	var price: int = int(item_d.get("price", 50))
	if PlayerData.gold < price:
		AudioManager.play_sfx("alchemy_fail")
		modal_status_lbl.text = "Không đủ Kim Tệ! Cần %d Kim Tệ (Hiện có: %d)." % [price, PlayerData.gold]
		return

	var kind: String = str(item_d.get("kind", "item"))
	var entry_id: String = str(item_d.get("id", ""))
	if kind == "skill_book":
		if PlayerData.has_flag(entry_id):
			return
		PlayerData.gold -= price
		PlayerData.set_story_flag(entry_id)
		modal_status_lbl.text = "Đã lĩnh ngộ thành công: %s!" % str(item_d.get("name", ""))
	elif kind == "weapon":
		PlayerData.gold -= price
		AudioManager.play_sfx("loot_rare")
		var rar: String = str(item_d.get("rarity", "linh"))
		var inst: Dictionary = EquipmentSystem.roll_equipment_instance(entry_id, rar)
		PlayerData.add_gear_to_bag(inst)
		if not PlayerData.has_weapon_equipped():
			PlayerData.equip_gear_from_bag(str(inst.get("uid", "")))
			modal_status_lbl.text = "Đã mua & tự động trang bị: %s!" % EquipmentSystem.get_item_display_name(inst)
		else:
			modal_status_lbl.text = "Đã mua %s bỏ vào Nạp Giới (Bấm [I] để mặc)!" % EquipmentSystem.get_item_display_name(inst)
	else:
		PlayerData.gold -= price
		AudioManager.play_sfx("loot_pickup")
		PlayerData.add_item(entry_id, 1)
		modal_status_lbl.text = "Đã mua %s (Còn %d Kim Tệ)!" % [str(item_d.get("name", "")), PlayerData.gold]

	EventBus.stats_changed.emit()
	_populate_modal()


func _build_auction_tab(vbox: VBoxContainer) -> void:
	if auction_lots.is_empty():
		auction_lots = AuctionSystem.generate_auction_lots(shop_venue_id)
		active_auction_lot_idx = 0
	active_auction_lot_idx = clampi(active_auction_lot_idx, 0, auction_lots.size() - 1)

	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 8)
	vbox.add_child(top_bar)
	for i in range(auction_lots.size()):
		var l_dict: Dictionary = auction_lots[i]
		var idx_cap: int = i
		var lb := Button.new()
		var done_tag: String = " ✓" if bool(l_dict.get("closed", false)) else ""
		lb.text = ("★ " if i == active_auction_lot_idx else "") + "Lô #%d: %s%s" % [i + 1, str(l_dict.get("name", "")).left(24), done_tag]
		lb.disabled = (i == active_auction_lot_idx)
		lb.add_theme_font_size_override("font_size", 11)
		lb.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			active_auction_lot_idx = idx_cap
			_populate_modal()
		)
		top_bar.add_child(lb)

	var reroll_b := Button.new()
	reroll_b.text = "↻ Mở Phiên Mới"
	reroll_b.add_theme_font_size_override("font_size", 11)
	reroll_b.add_theme_color_override("font_color", Color("#70D6FF"))
	reroll_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		auction_lots = AuctionSystem.generate_auction_lots(shop_venue_id)
		active_auction_lot_idx = 0
		modal_status_lbl.text = "Đã khai mạc phiên đấu giá mới với 3 bảo vật!"
		_populate_modal()
	)
	top_bar.add_child(reroll_b)

	var lot: Dictionary = auction_lots[active_auction_lot_idx]
	var col := Color(str(lot.get("color_hex", "#FFD166")))
	var card := _make_styled_panel(Color(0.11, 0.08, 0.16, 0.96), col, 2, 12)
	vbox.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	card.add_child(v)

	v.add_child(_make_label("⚖ BẢO VẬT ĐANG ĐẤU GIÁ: %s" % str(lot.get("name", "")), 15, col))
	var dl := _make_label(str(lot.get("desc", "")), 12, Color("#E2E8F0"))
	dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(dl)

	var cur_bid: int = int(lot.get("current_bid", 100))
	var holder: String = str(lot.get("highest_bidder", "Chưa có ai"))
	var rd: int = int(lot.get("round", 0))
	var max_rd: int = int(lot.get("max_rounds", 5))
	v.add_child(_make_label("Giá hiện tại: %d Kim Tệ   |   Người giữ giá: %s   |   Hiệp: %d / %d" % [cur_bid, holder, rd, max_rd], 13, Color("#FFD166")))

	# Trạng thái 3 Đối thủ NPC
	var is_scanned: bool = bool(lot.get("scanned", false))
	var r_box := _make_styled_panel(Color(0.07, 0.09, 0.14, 0.92), Color("#3A506B"), 1, 8)
	v.add_child(r_box)
	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 3)
	r_box.add_child(rv)
	rv.add_child(_make_label("ĐỐI THỦ TRONG KHÁN PHÒNG (%s):" % ("ĐÃ QUÉT LINH HỒN!" if is_scanned else "Bấm Thăm Dò để xem ngân sách!"), 11, Color("#72EFDD")))
	for riv in lot.get("rivals", []):
		if riv is Dictionary:
			var r_folded: bool = bool(riv.get("folded", false))
			var st_txt: String = "[ĐÃ BỎ CUỘC]" if r_folded else (
				"[Ngân sách tối đa: %d V · Bình tĩnh: %d]" % [int(riv.get("max_budget", 0)), int(riv.get("patience", 1))] if is_scanned else "[Đang theo giá...]"
			)
			rv.add_child(_make_label("• %s — %s" % [str(riv.get("name", "Đối thủ")), st_txt], 11, Color("#6C757D") if r_folded else Color("#F8F9FA")))

	if bool(lot.get("closed", false)):
		v.add_child(_make_label("Phiên của bảo vật này đã khép lại (%s). Hãy chọn lô khác hoặc bấm [Mở Phiên Mới]!" % str(lot.get("result_text", "Kết thúc")), 12, Color("#80ED99")))
		return

	var act_row := HFlowContainer.new()
	act_row.add_theme_constant_override("h_separation", 8)
	act_row.add_theme_constant_override("v_separation", 6)
	v.add_child(act_row)

	var step15: int = maxi(20, int(round(float(cur_bid) * 0.15)))
	var step30: int = maxi(40, int(round(float(cur_bid) * 0.30)))

	var b_norm := Button.new()
	b_norm.text = "Ra Giá Thường (%d V)" % (cur_bid + step15)
	b_norm.add_theme_font_size_override("font_size", 12)
	b_norm.pressed.connect(func() -> void:
		_run_auction_action(lot, "bid")
	)
	act_row.add_child(b_norm)

	var b_over := Button.new()
	b_over.text = "⚡ Áp Chế Linh Hồn — Đè Giá (%d V · SOUL %d)" % [cur_bid + step30, PlayerData.get_soul()]
	b_over.add_theme_font_size_override("font_size", 12)
	b_over.add_theme_color_override("font_color", Color("#FFD166"))
	b_over.pressed.connect(func() -> void:
		_run_auction_action(lot, "overbid")
	)
	act_row.add_child(b_over)

	var b_scan := Button.new()
	b_scan.text = "👁 Thăm Dò Hậu Đài (Miễn phí)"
	b_scan.disabled = is_scanned
	b_scan.add_theme_font_size_override("font_size", 12)
	b_scan.add_theme_color_override("font_color", Color("#72EFDD"))
	b_scan.pressed.connect(func() -> void:
		_run_auction_action(lot, "scan")
	)
	act_row.add_child(b_scan)


func _run_auction_action(lot: Dictionary, act_name: String) -> void:
	var res: Dictionary = AuctionSystem.process_bid_turn(lot, act_name, PlayerData.get_soul(), PlayerData.gold)
	var st: String = str(res.get("status", "ongoing"))
	if st == "won":
		lot["closed"] = true
		var win_msg: String = AuctionSystem.award_won_lot(lot)
		lot["result_text"] = "THẮNG ĐẤU GIÁ!"
		modal_status_lbl.text = win_msg
		_on_banter(win_msg)
	elif st == "lost":
		lot["closed"] = true
		lot["result_text"] = "Đối thủ mua mất"
		AudioManager.play_sfx("alchemy_fail")
		modal_status_lbl.text = str(res.get("msg", "Đối thủ đã chốt giá cao hơn!"))
	elif st == "insufficient_gold":
		AudioManager.play_sfx("alchemy_fail")
		modal_status_lbl.text = str(res.get("msg", "Không đủ Kim Tệ!"))
	else:
		AudioManager.play_sfx("radar_ping" if act_name == "scan" else "ui_click")
		modal_status_lbl.text = str(res.get("msg", ""))
	_populate_modal()


func _build_consign_tab(vbox: VBoxContainer) -> void:
	var items: Array = AuctionSystem.get_consignable_items()
	vbox.add_child(_make_label("💰 KÝ GỬI BÁN ĐAN DƯỢC & NGUYÊN LIỆU (Giá bán được thưởng x1.25–1.85 theo Linh Hồn & Hảo Cảm Nhã Phi!)", 12, Color("#80ED99")))
	if items.is_empty():
		vbox.add_child(_make_label("Bạn chưa có đan dược, dược thảo hay Ma Hạch dư để ký gửi! Hãy khai lò [L] hoặc săn Ma Thú rồi quay lại.", 12, Color("#ADB5BD")))
		return
	for entry in items:
		if not (entry is Dictionary):
			continue
		var ed: Dictionary = entry
		var iid: String = str(ed.get("id", ""))
		var qty: int = int(ed.get("qty", 0))
		var u_price: int = int(ed.get("unit_price", 20))
		var col := Color(str(ed.get("color_hex", "#FFE599")))

		var card := _make_styled_panel(Color(0.08, 0.10, 0.16, 0.94), col, 1, 7)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		card.add_child(row)

		var iv := VBoxContainer.new()
		iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(iv)
		iv.add_child(_make_label("%s  (x%d trong Nạp Giới)" % [str(ed.get("name", iid)), qty], 13, col))
		iv.add_child(_make_label("Giá ký gửi: %d Kim Tệ / cái  ·  Bán hết thu: %d Kim Tệ" % [u_price, u_price * qty], 11, Color("#CED4DA")))

		var cap_id: String = iid
		var cap_qty: int = qty
		var sell1 := Button.new()
		sell1.text = "Bán x1 (+%d V)" % u_price
		sell1.add_theme_font_size_override("font_size", 11)
		sell1.pressed.connect(func() -> void:
			var r: Dictionary = AuctionSystem.consign_item(cap_id, 1)
			modal_status_lbl.text = str(r.get("msg", ""))
			_populate_modal()
		)
		row.add_child(sell1)

		if qty > 1:
			var sell_all := Button.new()
			sell_all.text = "Bán Hết (+%d V)" % (u_price * qty)
			sell_all.add_theme_font_size_override("font_size", 11)
			sell_all.add_theme_color_override("font_color", Color("#FFD166"))
			sell_all.pressed.connect(func() -> void:
				var r: Dictionary = AuctionSystem.consign_item(cap_id, cap_qty)
				modal_status_lbl.text = str(r.get("msg", ""))
				_populate_modal()
			)
			row.add_child(sell_all)


# =========================================================
# [I] NHÂN VẬT & TRANG BỊ 10 Ô
# =========================================================
func _build_equipment_modal() -> void:
	modal_title_lbl.text = "[I] NHÂN VẬT, TRANG BỊ 10 Ô & CƯỜNG HÓA   |   Kim Tệ: %d   |   Đá Cường Hóa: %d" % [PlayerData.gold, PlayerData.enhance_stones]

	var split := HBoxContainer.new()
	split.set_anchors_preset(Control.PRESET_FULL_RECT)
	split.add_theme_constant_override("separation", 12)
	modal_content_host.add_child(split)

	var left_scroll := ScrollContainer.new()
	left_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_scroll.size_flags_stretch_ratio = 1.05
	split.add_child(left_scroll)

	var left_v := VBoxContainer.new()
	left_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_v.add_theme_constant_override("separation", 5)
	left_scroll.add_child(left_v)

	var set_lines: Array = PlayerData.cached_gear_bonuses.get("_active_sets", [])
	var set_txt: String = " | ".join(set_lines) if set_lines.size() > 0 else "Chưa kích hoạt (Mặc >= 2 món cùng bộ Tiêu Gia / Ma Thú)"
	var summary_panel := _make_styled_panel(Color(0.09, 0.11, 0.19, 0.92), Color("#FFD166"), 1, 6)
	left_v.add_child(summary_panel)
	var sum_lbl := _make_label(
		"Chỉ số: ATK %d | DEF %d | SPD %d | SOUL %d | Chí mạng %d%% | Hút máu %d%% | Giảm CD %d%% | Hỏa +%d%%\nBộ Trang Bị: %s" % [
			int(PlayerData.get_atk()), int(PlayerData.get_def()), int(PlayerData.get_move_speed()), PlayerData.get_soul(),
			int(round(PlayerData.get_crit_chance() * 100.0)), int(round(PlayerData.get_lifesteal_ratio() * 100.0)),
			int(round((1.0 - PlayerData.get_cooldown_multiplier()) * 100.0)),
			int(round((PlayerData.get_flame_dmg_multiplier() - 1.0) * 100.0)),
			set_txt
		],
		11,
		Color("#FFE599")
	)
	sum_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_panel.add_child(sum_lbl)

	# Khung Khảm Ma Hạch lên Huyền Trọng Xích / Vũ Khí (3 Rãnh)
	var core_card := _make_styled_panel(Color(0.10, 0.07, 0.16, 0.94), Color("#E0AAFF"), 1, 7)
	left_v.add_child(core_card)
	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 5)
	core_card.add_child(cv)
	cv.add_child(_make_label("💎 KHẢM MA HẠCH LÊN VŨ KHÍ / HUYỀN TRỌNG XÍCH (3 RÃNH — Chọn rãnh rồi bấm Ma Hạch để khảm)", 11, Color("#E0AAFF")))

	var sock_row := HBoxContainer.new()
	sock_row.add_theme_constant_override("separation", 6)
	cv.add_child(sock_row)
	for s_idx in range(3):
		var cid_s: String = str(PlayerData.weapon_core_sockets[s_idx]) if s_idx < PlayerData.weapon_core_sockets.size() else ""
		var cdef: Dictionary = PlayerData.get_core_socket_def(cid_s) if cid_s != "" else {}
		var is_sel: bool = (selected_core_slot == s_idx)
		var cap_i: int = s_idx
		var s_btn := Button.new()
		s_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s_btn.add_theme_font_size_override("font_size", 10)
		if cdef.is_empty():
			s_btn.text = ("★ " if is_sel else "") + "Rãnh #%d: (Trống)" % (s_idx + 1)
			s_btn.add_theme_color_override("font_color", Color("#FFD166") if is_sel else Color("#ADB5BD"))
		else:
			s_btn.text = ("★ " if is_sel else "") + "Rãnh #%d: %s" % [s_idx + 1, str(cdef["name"]).left(18)]
			s_btn.tooltip_text = str(cdef.get("desc", ""))
			s_btn.add_theme_color_override("font_color", cdef.get("color", Color("#FFD166")) as Color)
		s_btn.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			selected_core_slot = cap_i
			_populate_modal()
		)
		sock_row.add_child(s_btn)
		if not cdef.is_empty():
			var rm_b := Button.new()
			rm_b.text = "×"
			rm_b.tooltip_text = "Tháo Ma Hạch khỏi Rãnh #%d về lại Nạp Giới" % (s_idx + 1)
			rm_b.add_theme_font_size_override("font_size", 10)
			rm_b.pressed.connect(func() -> void:
				var res: Dictionary = PlayerData.unsocket_monster_core(cap_i)
				modal_status_lbl.text = str(res.get("msg", ""))
			)
			sock_row.add_child(rm_b)

	var core_bag_row := HFlowContainer.new()
	core_bag_row.add_theme_constant_override("h_separation", 5)
	core_bag_row.add_theme_constant_override("v_separation", 4)
	cv.add_child(core_bag_row)
	var has_any_core: bool = false
	for core_k in ["core_hoa_1", "core_moc_2", "core_hoa_3", "core_phong_4", "core_loi_5", "core_huyet_5"]:
		var cnt: int = PlayerData.get_item_count(core_k)
		if cnt <= 0:
			continue
		has_any_core = true
		var cd: Dictionary = PlayerData.get_core_socket_def(core_k)
		var cap_ck: String = core_k
		var cb := Button.new()
		cb.text = "+ %s (x%d)" % [str(cd.get("name", core_k)), cnt]
		cb.tooltip_text = "Khảm vào Rãnh #%d: %s" % [selected_core_slot + 1, str(cd.get("desc", ""))]
		cb.add_theme_font_size_override("font_size", 10)
		cb.add_theme_color_override("font_color", cd.get("color", Color("#FFD166")) as Color)
		cb.pressed.connect(func() -> void:
			var res: Dictionary = PlayerData.socket_monster_core(selected_core_slot, cap_ck)
			modal_status_lbl.text = str(res.get("msg", ""))
		)
		core_bag_row.add_child(cb)
	if not has_any_core:
		core_bag_row.add_child(_make_label("(Chưa có Ma Hạch trong túi — Săn Ma Thú hoặc đổi bằng Hỏa Năng trong Thiên Phần Tháp!)", 10, Color("#868E96")))

	for s_entry in GameDatabase.equipment_slots:
		if not (s_entry is Dictionary):
			continue
		var slot_id: String = str(s_entry.get("id", ""))
		var slot_name: String = str(s_entry.get("name", slot_id))
		var def_icon: String = str(s_entry.get("default_icon", "res://assets/sprites/icons/icon_armor.png"))
		var eq = PlayerData.equipped_gear.get(slot_id, {})
		var has_item: bool = (eq is Dictionary) and not eq.is_empty()

		var r_col: Color = EquipmentSystem.get_rarity_color(str(eq.get("rarity", "pham"))) if has_item else Color("#3A4258")
		var row_card := _make_styled_panel(Color(0.09, 0.10, 0.16, 0.92), r_col, 1, 5)
		left_v.add_child(row_card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row_card.add_child(row)

		var icon_path: String = def_icon
		if has_item:
			var tdef: Dictionary = GameDatabase.get_equipment_template(str(eq.get("template_id", "")))
			icon_path = str(tdef.get("icon", def_icon))
		row.add_child(_make_icon_box(icon_path, r_col, 38))

		var txt_col := VBoxContainer.new()
		txt_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(txt_col)

		if has_item:
			txt_col.add_child(_make_label("%s: %s" % [slot_name, EquipmentSystem.get_item_display_name(eq)], 12, r_col))
			var st_l := _make_label(EquipmentSystem.format_stats_line(eq), 11, Color("#CED4DA"))
			st_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			txt_col.add_child(st_l)

			var uid_str: String = str(eq.get("uid", ""))
			var cost: Dictionary = EquipmentSystem.get_enhance_cost(eq)
			var enh_btn := Button.new()
			enh_btn.text = "+1 (%dV/%dĐ)" % [int(cost.get("gold", 40)), int(cost.get("stones", 1))]
			enh_btn.add_theme_font_size_override("font_size", 11)
			enh_btn.pressed.connect(func() -> void:
				var res: Dictionary = PlayerData.enhance_gear_by_uid(uid_str)
				modal_status_lbl.text = str(res.get("msg", ""))
			)
			row.add_child(enh_btn)

			var un_btn := Button.new()
			un_btn.text = "Tháo"
			un_btn.add_theme_font_size_override("font_size", 11)
			un_btn.pressed.connect(func() -> void:
				modal_status_lbl.text = PlayerData.unequip_slot(slot_id)
			)
			row.add_child(un_btn)
		else:
			var empty_hint: String = "%s: (Tay Không — Mua tại Nhã Phi hoặc đánh Boss)" % slot_name if slot_id == "weapon" else "%s: (Chưa trang bị)" % slot_name
			txt_col.add_child(_make_label(empty_hint, 12, Color("#6C757D")))

	var right_col := VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.size_flags_stretch_ratio = 0.95
	right_col.add_theme_constant_override("separation", 6)
	split.add_child(right_col)

	var bag_hdr := HBoxContainer.new()
	right_col.add_child(bag_hdr)
	var bag_title := _make_label("TÚI TRANG BỊ TRONG NẠP GIỚI (%d món)" % PlayerData.gear_bag.size(), 13, Color("#70D6FF"))
	bag_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_hdr.add_child(bag_title)

	var bulk_salvage_btn := Button.new()
	bulk_salvage_btn.text = "Phân giải Phàm/Linh (+0)"
	bulk_salvage_btn.add_theme_font_size_override("font_size", 11)
	bulk_salvage_btn.pressed.connect(func() -> void:
		modal_status_lbl.text = PlayerData.salvage_low_rarity_gear()
	)
	bag_hdr.add_child(bulk_salvage_btn)

	# Thanh uống đan nhanh ngay trong Nạp Giới [I] (tiện uống Băng Tâm Đan / Hạt Thanh Liên Tử bất kỳ lúc nào!)
	var quick_pill_flow := HFlowContainer.new()
	quick_pill_flow.add_theme_constant_override("h_separation", 4)
	quick_pill_flow.add_theme_constant_override("v_separation", 4)
	right_col.add_child(quick_pill_flow)
	for cid in ["pill_ngung_huyet_tan", "pill_bang_tam_dan", "pill_huyet_ngung_dan", "pill_hoi_khi_dan", "pill_thanh_lien_tu", "pill_truc_co_linh_dich", "pill_am_duong_huyen_long"]:
		var cid_s: String = str(cid)
		var p_cnt: int = PlayerData.get_item_count(cid_s)
		if p_cnt <= 0:
			continue
		var cdef: Dictionary = GameDatabase.get_item_def(cid_s)
		var ub := Button.new()
		ub.text = "Uống %s (x%d)" % [str(cdef.get("name", cid_s)), p_cnt]
		ub.add_theme_font_size_override("font_size", 10)
		ub.add_theme_color_override("font_color", Color(str(cdef.get("color_hex", "#FFE599"))))
		ub.pressed.connect(func() -> void:
			var p_nd: Node = _find_player()
			var wp: Vector2 = (p_nd as Node2D).global_position + Vector2(0, -45) if (p_nd != null and p_nd is Node2D) else Vector2.ZERO
			if PlayerData.use_consumable(cid_s, wp):
				modal_status_lbl.text = "Đã uống [%s]!" % str(cdef.get("name", cid_s))
				_populate_modal()
			else:
				modal_status_lbl.text = "HP / Đấu Khí hiện đã đầy!"
		)
		quick_pill_flow.add_child(ub)

	var right_scroll := ScrollContainer.new()
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_col.add_child(right_scroll)

	var bag_v := VBoxContainer.new()
	bag_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_v.add_theme_constant_override("separation", 6)
	right_scroll.add_child(bag_v)

	if PlayerData.gear_bag.is_empty():
		bag_v.add_child(_make_label("Túi trống! Hãy đánh quái, mở Bảo Rương ẩn hoặc ghé Phòng Đấu Giá Nhã Phi!", 12, Color("#ADB5BD")))
	else:
		for item in PlayerData.gear_bag:
			if not (item is Dictionary):
				continue
			var inst: Dictionary = item
			var tdef: Dictionary = GameDatabase.get_equipment_template(str(inst.get("template_id", "")))
			var r_col: Color = EquipmentSystem.get_rarity_color(str(inst.get("rarity", "pham")))
			var card := _make_styled_panel(Color(0.09, 0.10, 0.17, 0.94), r_col, 1, 6)
			bag_v.add_child(card)

			var h := HBoxContainer.new()
			h.add_theme_constant_override("separation", 8)
			card.add_child(h)

			var icon_p: String = str(tdef.get("icon", "res://assets/sprites/icons/icon_armor.png"))
			h.add_child(_make_icon_box(icon_p, r_col, 40))

			var info_v := VBoxContainer.new()
			info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h.add_child(info_v)

			info_v.add_child(_make_label(EquipmentSystem.get_item_display_name(inst), 12, r_col))
			var stat_l := _make_label(EquipmentSystem.format_stats_line(inst), 11, Color("#DEE2E6"))
			stat_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			info_v.add_child(stat_l)

			var btn_v := VBoxContainer.new()
			btn_v.add_theme_constant_override("separation", 3)
			h.add_child(btn_v)

			var uid_val: String = str(inst.get("uid", ""))
			var eq_btn := Button.new()
			eq_btn.text = "Mặc"
			eq_btn.add_theme_font_size_override("font_size", 11)
			eq_btn.pressed.connect(func() -> void:
				modal_status_lbl.text = PlayerData.equip_gear_from_bag(uid_val)
			)
			btn_v.add_child(eq_btn)

			var sal_btn := Button.new()
			sal_btn.text = "Phân giải"
			sal_btn.add_theme_font_size_override("font_size", 11)
			sal_btn.pressed.connect(func() -> void:
				modal_status_lbl.text = PlayerData.salvage_gear_by_uid(uid_val)
			)
			btn_v.add_child(sal_btn)


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
