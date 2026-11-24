class_name MobaSlotButton
extends Button
## Ô Kỹ Năng / Vật Phẩm Phong Cách MOBA (Clickable Slot Button):
## - Khung kim loại cổ phong bo góc mượt, hiệu ứng sáng viền khi di chuột & phát sáng khi kích hoạt.
## - Lớp phủ hồi chiêu quét dọc thời gian thực (Cooldown Sweep) kèm số đếm giây sắc nét ở giữa ô.
## - Nhãn phím tắt (Q/E/R/F/T/1/2/3/Space...) góc trái trên & Nhãn Đấu Khí / Số lượng góc phải dưới.
## - Phát tín hiệu hover để hiển thị Tooltip Tiên Hiệp mượt mà ngay phía trên thanh kỹ năng!

signal slot_hovered(info: Dictionary, anchor_global_pos: Vector2)
signal slot_unhovered()

var key_label_text: String = ""
var sub_badge_text: String = ""
var accent_color: Color = Color("#2EC4B6")
var is_locked: bool = false
var is_active_glow: bool = false
var is_low_resource: bool = false

var cd_remaining: float = 0.0
var cd_total: float = 1.0
var pulse_phase: float = 0.0

var tooltip_data: Dictionary = {}

var icon_rect: TextureRect
var key_badge_lbl: Label
var sub_badge_lbl: Label
var cd_center_lbl: Label


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	clip_contents = true
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func configure_slot(key_txt: String, slot_px: int = 56, accent: Color = Color("#2EC4B6")) -> void:
	key_label_text = key_txt
	accent_color = accent
	custom_minimum_size = Vector2(slot_px, slot_px)
	size = Vector2(slot_px, slot_px)

	_apply_frame_styles()

	if icon_rect == null:
		icon_rect = TextureRect.new()
		icon_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon_rect.offset_left = 4
		icon_rect.offset_top = 4
		icon_rect.offset_right = -4
		icon_rect.offset_bottom = -4
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon_rect)

	if key_badge_lbl == null:
		key_badge_lbl = Label.new()
		key_badge_lbl.position = Vector2(3, 1)
		key_badge_lbl.add_theme_font_size_override("font_size", 10 if slot_px >= 48 else 9)
		key_badge_lbl.add_theme_color_override("font_color", Color("#FFD166"))
		key_badge_lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.05, 1.0))
		key_badge_lbl.add_theme_constant_override("outline_size", 3)
		key_badge_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(key_badge_lbl)
	key_badge_lbl.text = key_label_text

	if sub_badge_lbl == null:
		sub_badge_lbl = Label.new()
		sub_badge_lbl.anchor_left = 0.0
		sub_badge_lbl.anchor_right = 1.0
		sub_badge_lbl.anchor_top = 1.0
		sub_badge_lbl.anchor_bottom = 1.0
		sub_badge_lbl.offset_left = 2
		sub_badge_lbl.offset_right = -3
		sub_badge_lbl.offset_top = -15
		sub_badge_lbl.offset_bottom = -1
		sub_badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		sub_badge_lbl.add_theme_font_size_override("font_size", 10)
		sub_badge_lbl.add_theme_color_override("font_color", Color("#F8F9FA"))
		sub_badge_lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.05, 1.0))
		sub_badge_lbl.add_theme_constant_override("outline_size", 3)
		sub_badge_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(sub_badge_lbl)

	if cd_center_lbl == null:
		cd_center_lbl = Label.new()
		cd_center_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
		cd_center_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cd_center_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cd_center_lbl.add_theme_font_size_override("font_size", 16 if slot_px >= 52 else 13)
		cd_center_lbl.add_theme_color_override("font_color", Color("#FFFFFF"))
		cd_center_lbl.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.05, 1.0))
		cd_center_lbl.add_theme_constant_override("outline_size", 4)
		cd_center_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cd_center_lbl.visible = false
		add_child(cd_center_lbl)


func _apply_frame_styles() -> void:
	var border_base: Color = Color("#343C4E") if is_locked else accent_color
	var bg_base: Color = Color(0.05, 0.06, 0.10, 0.88) if is_locked else Color(0.09, 0.11, 0.18, 0.94)

	var sb_n := StyleBoxFlat.new()
	sb_n.bg_color = bg_base
	sb_n.border_color = border_base
	sb_n.set_border_width_all(2)
	sb_n.set_corner_radius_all(7)

	var sb_h := StyleBoxFlat.new()
	sb_h.bg_color = bg_base.lightened(0.10)
	sb_h.border_color = Color("#FFD166") if not is_locked else Color("#6C757D")
	sb_h.set_border_width_all(2)
	sb_h.set_corner_radius_all(7)

	var sb_p := StyleBoxFlat.new()
	sb_p.bg_color = bg_base.lightened(0.22)
	sb_p.border_color = Color("#FFFFFF")
	sb_p.set_border_width_all(2)
	sb_p.set_corner_radius_all(7)

	add_theme_stylebox_override("normal", sb_n)
	add_theme_stylebox_override("hover", sb_h)
	add_theme_stylebox_override("pressed", sb_p)
	add_theme_stylebox_override("disabled", sb_n)


func set_slot_visual(icon_tex: Texture2D, badge_txt: String, locked: bool, active_glow: bool = false, low_resource: bool = false, sub_col: Color = Color("#E9ECEF")) -> void:
	var lock_changed: bool = (is_locked != locked)
	is_locked = locked
	is_active_glow = active_glow
	is_low_resource = low_resource
	sub_badge_text = badge_txt
	if lock_changed:
		_apply_frame_styles()

	if icon_rect != null:
		icon_rect.texture = icon_tex
		if is_locked:
			icon_rect.modulate = Color(0.32, 0.34, 0.40, 0.45)
		elif is_low_resource:
			icon_rect.modulate = Color(0.50, 0.58, 0.78, 0.85)
		else:
			icon_rect.modulate = Color.WHITE

	if sub_badge_lbl != null:
		sub_badge_lbl.text = "KHÓA" if is_locked else sub_badge_text
		sub_badge_lbl.add_theme_color_override("font_color", Color("#6C757D") if is_locked else sub_col)

	if key_badge_lbl != null:
		key_badge_lbl.add_theme_color_override("font_color", Color("#6C757D") if is_locked else Color("#FFD166"))

	queue_redraw()


func set_cooldown(remaining: float, total: float) -> void:
	cd_remaining = maxf(0.0, remaining)
	cd_total = maxf(0.05, total)
	if cd_center_lbl != null:
		if cd_remaining > 0.05:
			cd_center_lbl.visible = true
			cd_center_lbl.text = "%.1f" % cd_remaining if cd_remaining < 10.0 else "%d" % int(ceil(cd_remaining))
		else:
			cd_center_lbl.visible = false
	queue_redraw()


func set_tooltip_info(title: String, subtitle: String, desc: String, title_col: Color = Color("#FFD166")) -> void:
	tooltip_data = {
		"title": title,
		"subtitle": subtitle,
		"desc": desc,
		"color": title_col
	}


func _process(delta: float) -> void:
	if is_active_glow:
		pulse_phase += delta * 5.2
		queue_redraw()


func _draw() -> void:
	# Ánh bóng kính nhẹ nửa trên ô nút (cảm giác nút MOBA cao cấp)
	if not is_locked:
		draw_rect(Rect2(2, 2, size.x - 4, size.y * 0.36), Color(1.0, 1.0, 1.0, 0.06), true)

	# Hào quang viền sáng nhấp nháy khi ô đang kích hoạt (Trọng Áp / Tương tác / Đột phá)
	if is_active_glow and not is_locked:
		var a: float = 0.55 + sin(pulse_phase) * 0.35
		var glow_c := Color(accent_color.r, accent_color.g, accent_color.b, a)
		draw_rect(Rect2(2, 2, size.x - 4, size.y - 4), glow_c, false, 3.0)

	# Lớp phủ Hồi Chiêu quét dọc (Cooldown Sweep Overlay)
	if cd_remaining > 0.05 and cd_total > 0.0:
		var ratio: float = clampf(cd_remaining / cd_total, 0.0, 1.0)
		var mask_h: float = (size.y - 4.0) * ratio
		var top_y: float = size.y - 2.0 - mask_h
		draw_rect(Rect2(2, top_y, size.x - 4, mask_h), Color(0.02, 0.03, 0.07, 0.76), true)
		draw_line(Vector2(2, top_y), Vector2(size.x - 2, top_y), Color(0.45, 0.85, 1.0, 0.90), 2.0)


func _on_mouse_entered() -> void:
	if not tooltip_data.is_empty():
		slot_hovered.emit(tooltip_data, global_position + Vector2(size.x * 0.5, 0.0))


func _on_mouse_exited() -> void:
	slot_unhovered.emit()
