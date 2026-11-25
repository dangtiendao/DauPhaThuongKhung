class_name ScreenFxOverlay
extends CanvasLayer
## Lớp Hiệu Ứng Toàn Màn Hình VFX 2.0 (Tương thích 100% GL Compatibility, 60–144 FPS):
## - Layer = 6: nằm TRÊN bản đồ/nhân vật/hạt lửa nhưng DƯỚI GameHUD (layer 10) nên không che hay làm méo UI!
## - 1. Sóng Biến Dạng Không Gian Thực (space_shockwave.gdshader: khúc xạ bẻ cong bản đồ + tách sắc RGB).
## - 2. Chớp Sáng Màn Hình (Screen Flash Additive) khi nổ Phật Nộ Hỏa Liên / Cổ Đế Ấn / Đột Phá / Đan Lôi.
## - 3. Viền Cảm Xúc (Low-HP Pulse đỏ khi HP < 25% + Viền Ngân Hà Tinh Vực huyền bí).

var shockwave_rect: ColorRect
var shockwave_mat: ShaderMaterial
var flash_rect: ColorRect
var vignette_ctrl: Control

# Trạng thái sóng khúc xạ đang chạy
var sw_active: bool = false
var sw_elapsed: float = 0.0
var sw_duration: float = 0.40
var sw_world_pos: Vector2 = Vector2.ZERO
var sw_max_radius_uv: float = 0.45
var sw_max_force: float = 0.055
var sw_tint: Color = Color("#72EFDD")

# Trạng thái chớp sáng toàn màn hình
var fl_elapsed: float = 0.0
var fl_duration: float = 0.0
var fl_peak_alpha: float = 0.0
var fl_color: Color = Color.WHITE

var _t_sec: float = 0.0


func _ready() -> void:
	layer = 6
	name = "ScreenFxOverlay"

	shockwave_rect = ColorRect.new()
	shockwave_rect.name = "SpaceShockwaveRect"
	shockwave_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	shockwave_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shockwave_rect.color = Color(1.0, 1.0, 1.0, 1.0)
	shockwave_mat = VfxAssets.create_space_shockwave_material()
	if shockwave_mat != null:
		shockwave_rect.material = shockwave_mat
	shockwave_rect.visible = false
	add_child(shockwave_rect)

	flash_rect = ColorRect.new()
	flash_rect.name = "ScreenFlashRect"
	flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_rect.material = VfxAssets.get_additive_material()
	flash_rect.color = Color(1.0, 1.0, 1.0, 0.0)
	flash_rect.visible = false
	add_child(flash_rect)

	vignette_ctrl = Control.new()
	vignette_ctrl.name = "VignetteBorder"
	vignette_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette_ctrl.draw.connect(_draw_vignette)
	add_child(vignette_ctrl)

	EventBus.shockwave_requested.connect(trigger_shockwave)
	EventBus.screen_flash_requested.connect(trigger_flash)


func _exit_tree() -> void:
	if EventBus.shockwave_requested.is_connected(trigger_shockwave):
		EventBus.shockwave_requested.disconnect(trigger_shockwave)
	if EventBus.screen_flash_requested.is_connected(trigger_flash):
		EventBus.screen_flash_requested.disconnect(trigger_flash)


func trigger_shockwave(world_pos: Vector2, max_radius_px: float, strength: float, tint_col: Color, duration: float = 0.42) -> void:
	if shockwave_mat == null:
		return
	var shake_sc: float = float(AudioManager.get("shake_scale")) if "shake_scale" in AudioManager else 1.0
	if shake_sc <= 0.05:
		return
	var vp_sz: Vector2 = get_viewport().get_visible_rect().size
	var ref_h: float = maxf(360.0, vp_sz.y)
	sw_active = true
	sw_elapsed = 0.0
	sw_duration = maxf(0.12, duration)
	sw_world_pos = world_pos
	sw_max_radius_uv = clampf(max_radius_px / ref_h, 0.14, 1.05)
	sw_max_force = clampf(strength * (0.45 + 0.55 * shake_sc), 0.01, 0.09)
	sw_tint = tint_col
	shockwave_rect.visible = true
	_sync_shockwave_uniforms(0.0)


func trigger_flash(flash_col: Color, intensity: float = 0.28, duration: float = 0.22) -> void:
	var shake_sc: float = float(AudioManager.get("shake_scale")) if "shake_scale" in AudioManager else 1.0
	if shake_sc <= 0.05:
		return
	fl_elapsed = 0.0
	fl_duration = maxf(0.08, duration)
	fl_peak_alpha = clampf(intensity * (0.45 + 0.55 * shake_sc), 0.04, 0.50)
	fl_color = flash_col
	flash_rect.visible = true
	flash_rect.color = Color(fl_color.r, fl_color.g, fl_color.b, fl_peak_alpha)


func _sync_shockwave_uniforms(t: float) -> void:
	if shockwave_mat == null:
		return
	var vp: Viewport = get_viewport()
	if vp == null:
		return
	var vp_sz: Vector2 = vp.get_visible_rect().size
	if vp_sz.x <= 1.0 or vp_sz.y <= 1.0:
		return
	var screen_pt: Vector2 = vp.get_canvas_transform() * sw_world_pos
	var center_uv := Vector2(
		clampf(screen_pt.x / vp_sz.x, -0.25, 1.25),
		clampf(screen_pt.y / vp_sz.y, -0.25, 1.25)
	)
	var ease_t: float = 1.0 - pow(1.0 - clampf(t, 0.0, 1.0), 3.0)
	var cur_force: float = sw_max_force * (1.0 - t) * (1.0 - 0.35 * t)
	shockwave_mat.set_shader_parameter("center_uv", center_uv)
	shockwave_mat.set_shader_parameter("radius", sw_max_radius_uv * (0.06 + 0.94 * ease_t))
	shockwave_mat.set_shader_parameter("thickness", lerpf(0.065, 0.125, ease_t))
	shockwave_mat.set_shader_parameter("force", cur_force)
	shockwave_mat.set_shader_parameter("chroma_shift", cur_force * 0.16)
	shockwave_mat.set_shader_parameter("ring_tint", sw_tint)
	shockwave_mat.set_shader_parameter("ring_glow", 0.52 * (1.0 - t))
	shockwave_mat.set_shader_parameter("aspect_ratio", vp_sz.x / vp_sz.y)


func _process(delta: float) -> void:
	_t_sec += delta
	if sw_active:
		sw_elapsed += delta
		var t: float = clampf(sw_elapsed / sw_duration, 0.0, 1.0)
		if t >= 1.0:
			sw_active = false
			shockwave_rect.visible = false
		else:
			_sync_shockwave_uniforms(t)

	if fl_duration > 0.0:
		fl_elapsed += delta
		var ft: float = clampf(fl_elapsed / fl_duration, 0.0, 1.0)
		if ft >= 1.0:
			fl_duration = 0.0
			flash_rect.visible = false
		else:
			var a: float = fl_peak_alpha * pow(1.0 - ft, 2.0)
			flash_rect.color = Color(fl_color.r, fl_color.g, fl_color.b, a)

	if vignette_ctrl != null:
		vignette_ctrl.queue_redraw()


func _draw_vignette() -> void:
	if vignette_ctrl == null:
		return
	var sz: Vector2 = vignette_ctrl.size
	if sz.x < 10.0 or sz.y < 10.0:
		return

	# 1. Viền đỏ nhịp tim khi HP < 25%
	var max_hp: float = maxf(1.0, PlayerData.get_max_hp())
	var hp_ratio: float = PlayerData.current_hp / max_hp
	if hp_ratio < 0.25 and PlayerData.current_hp > 0.0:
		var urg: float = clampf((0.25 - hp_ratio) / 0.25, 0.0, 1.0)
		var pulse: float = 0.55 + 0.45 * sin(_t_sec * 6.8)
		var a_red: float = (0.14 + 0.22 * urg) * pulse
		var b_w: float = 34.0 + 18.0 * urg
		var c_red := Color(0.92, 0.12, 0.22, a_red)
		vignette_ctrl.draw_rect(Rect2(0, 0, sz.x, b_w), c_red)
		vignette_ctrl.draw_rect(Rect2(0, sz.y - b_w, sz.x, b_w), c_red)
		vignette_ctrl.draw_rect(Rect2(0, b_w, b_w, sz.y - b_w * 2.0), c_red)
		vignette_ctrl.draw_rect(Rect2(sz.x - b_w, b_w, b_w, sz.y - b_w * 2.0), c_red)

	# 2. Ánh viền ngân hà huyền bí khi đang ở Ngân Hà Tinh Vực (Ch.08 Final Map)
	if PlayerData.current_map_id == "ch08_tinh_vuc_phong_an":
		var sp_p: float = 0.72 + 0.28 * sin(_t_sec * 2.6)
		var c_star := Color(0.55, 0.22, 0.88, 0.11 * sp_p)
		vignette_ctrl.draw_rect(Rect2(0, 0, sz.x, 22.0), c_star)
		vignette_ctrl.draw_rect(Rect2(0, sz.y - 22.0, sz.x, 22.0), c_star)

	# 3. Ảo Cảnh Bách Thế Luân Hồi (Ch.10): Màng phủ Thủy Mặc Đen–Trắng + Điểm Sắc Ngọc Bích Bồ Đề!
	if SaintRealmManager.is_ink_wash_illusion_active(PlayerData):
		var ink_p: float = 0.82 + 0.18 * sin(_t_sec * 1.9)
		vignette_ctrl.draw_rect(Rect2(0, 0, sz.x, sz.y), Color(0.08, 0.10, 0.11, 0.56))
		var ink_edge := Color(0.03, 0.04, 0.05, 0.44 * ink_p)
		vignette_ctrl.draw_rect(Rect2(0, 0, sz.x, 42.0), ink_edge)
		vignette_ctrl.draw_rect(Rect2(0, sz.y - 42.0, sz.x, 42.0), ink_edge)
		vignette_ctrl.draw_rect(Rect2(0, 42.0, 42.0, sz.y - 84.0), ink_edge)
		vignette_ctrl.draw_rect(Rect2(sz.x - 42.0, 42.0, 42.0, sz.y - 84.0), ink_edge)
		vignette_ctrl.draw_rect(Rect2(0, 0, sz.x, 6.0), Color(0.20, 0.83, 0.60, 0.42 * ink_p))
		vignette_ctrl.draw_rect(Rect2(0, sz.y - 6.0, sz.x, 6.0), Color(0.20, 0.83, 0.60, 0.42 * ink_p))
	elif PlayerData.current_map_id == "ch10_yeu_hoa_khong_gian":
		# 4. Viền Trắng Hồng Yêu Dị của Yêu Hỏa Không Gian (Song Nguyệt Đồng Hiện)
		var yh_p: float = 0.75 + 0.25 * sin(_t_sec * 3.1)
		var c_yh := Color(0.99, 0.64, 0.69, 0.13 * yh_p)
		vignette_ctrl.draw_rect(Rect2(0, 0, sz.x, 24.0), c_yh)
		vignette_ctrl.draw_rect(Rect2(0, sz.y - 24.0, sz.x, 24.0), c_yh)
	elif SaintRealmManager.has_dau_thanh_domain(PlayerData):
		# 5. Viền Hoàng Kim Thánh Uy nhẹ khi đã bước vào Đấu Thánh Không Gian
		var st_p: float = 0.70 + 0.30 * sin(_t_sec * 2.2)
		var c_st := Color(1.0, 0.78, 0.22, 0.08 * st_p)
		vignette_ctrl.draw_rect(Rect2(0, 0, sz.x, 14.0), c_st)
		vignette_ctrl.draw_rect(Rect2(0, sz.y - 14.0, sz.x, 14.0), c_st)
