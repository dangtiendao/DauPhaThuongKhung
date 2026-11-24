class_name VfxAssets
extends RefCounted
## Kho tài nguyên VFX sinh thủ tục & Cache dùng chung (Zero Disk I/O, 60-144 FPS mượt):
## - Tạo sẵn 3 texture hạt mềm mịn (đốm sáng tròn, tia lửa nhọn, khói mềm) thay cho ô vuông pixel mặc định của CPUParticles2D.
## - Cache sẵn CanvasItemMaterial (BLEND_MODE_ADD), Shader Dị Hỏa động, Curve co giãn và hàm sinh hạt 1 dòng.

const FLAME_SHADER_PATH: String = "res://assets/shaders/di_hoa_palette.gdshader"

static var _glow_dot_tex: Texture2D
static var _spark_streak_tex: Texture2D
static var _smoke_puff_tex: Texture2D
static var _ring_soft_tex: Texture2D
static var _add_material: CanvasItemMaterial
static var _flame_shader: Shader
static var _scale_pop_curve: Curve
static var _scale_smoke_curve: Curve
static var _scale_ember_curve: Curve


static func get_glow_dot_texture() -> Texture2D:
	if _glow_dot_tex != null:
		return _glow_dot_tex
	var sz: int = 32
	var img := Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	var half: float = float(sz - 1) * 0.5
	for y in range(sz):
		for x in range(sz):
			var d: float = Vector2(float(x) - half, float(y) - half).length() / half
			if d >= 1.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
			else:
				var a: float = pow(1.0 - d, 2.2)
				var core: float = pow(clampf(1.0 - d * 1.45, 0.0, 1.0), 1.8)
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(a + core * 0.35, 0.0, 1.0)))
	_glow_dot_tex = ImageTexture.create_from_image(img)
	return _glow_dot_tex


static func get_spark_streak_texture() -> Texture2D:
	if _spark_streak_tex != null:
		return _spark_streak_tex
	var w: int = 16
	var h: int = 32
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var cx: float = float(w - 1) * 0.5
	var cy: float = float(h - 1) * 0.5
	for y in range(h):
		for x in range(w):
			var nx: float = (float(x) - cx) / cx
			var ny: float = (float(y) - cy) / cy
			var d: float = sqrt(nx * nx * 2.2 + ny * ny)
			if d >= 1.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
			else:
				var a: float = pow(1.0 - d, 1.85)
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
	_spark_streak_tex = ImageTexture.create_from_image(img)
	return _spark_streak_tex


static func get_smoke_puff_texture() -> Texture2D:
	if _smoke_puff_tex != null:
		return _smoke_puff_tex
	var sz: int = 32
	var img := Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	var half: float = float(sz - 1) * 0.5
	for y in range(sz):
		for x in range(sz):
			var dx: float = (float(x) - half) / half
			var dy: float = (float(y) - half) / half
			var d: float = sqrt(dx * dx + dy * dy)
			if d >= 1.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
			else:
				var soft: float = smoothstep(1.0, 0.15, d) * 0.72
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, soft))
	_smoke_puff_tex = ImageTexture.create_from_image(img)
	return _smoke_puff_tex


static func get_soft_halo_texture() -> Texture2D:
	if _ring_soft_tex != null:
		return _ring_soft_tex
	var sz: int = 96
	var img := Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	var half: float = float(sz - 1) * 0.5
	for y in range(sz):
		for x in range(sz):
			var d: float = Vector2(float(x) - half, float(y) - half).length() / half
			if d >= 1.0:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
			else:
				var a: float = pow(1.0 - d, 2.4)
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
	_ring_soft_tex = ImageTexture.create_from_image(img)
	return _ring_soft_tex


static func get_additive_material() -> CanvasItemMaterial:
	if _add_material == null:
		_add_material = CanvasItemMaterial.new()
		_add_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _add_material


static func get_flame_shader() -> Shader:
	if _flame_shader == null:
		_flame_shader = load(FLAME_SHADER_PATH)
	return _flame_shader


static func create_flame_material(core_c: Color, mid_c: Color, outer_c: Color, intensity_val: float = 1.55, flow_spd: float = 2.6, turb: float = 0.055) -> ShaderMaterial:
	var mat := ShaderMaterial.new()
	mat.shader = get_flame_shader()
	mat.set_shader_parameter("core_color", core_c)
	mat.set_shader_parameter("mid_color", mid_c)
	mat.set_shader_parameter("outer_color", outer_c)
	mat.set_shader_parameter("intensity", intensity_val)
	mat.set_shader_parameter("flow_speed", flow_spd)
	mat.set_shader_parameter("turbulence", turb)
	mat.set_shader_parameter("dissolve", 0.0)
	return mat


static func get_scale_pop_curve() -> Curve:
	if _scale_pop_curve == null:
		_scale_pop_curve = Curve.new()
		_scale_pop_curve.add_point(Vector2(0.0, 0.35))
		_scale_pop_curve.add_point(Vector2(0.18, 1.0))
		_scale_pop_curve.add_point(Vector2(0.70, 0.55))
		_scale_pop_curve.add_point(Vector2(1.0, 0.0))
	return _scale_pop_curve


static func get_scale_smoke_curve() -> Curve:
	if _scale_smoke_curve == null:
		_scale_smoke_curve = Curve.new()
		_scale_smoke_curve.add_point(Vector2(0.0, 0.45))
		_scale_smoke_curve.add_point(Vector2(0.45, 1.0))
		_scale_smoke_curve.add_point(Vector2(1.0, 1.35))
	return _scale_smoke_curve


static func get_scale_ember_curve() -> Curve:
	if _scale_ember_curve == null:
		_scale_ember_curve = Curve.new()
		_scale_ember_curve.add_point(Vector2(0.0, 0.15))
		_scale_ember_curve.add_point(Vector2(0.25, 1.0))
		_scale_ember_curve.add_point(Vector2(0.80, 0.65))
		_scale_ember_curve.add_point(Vector2(1.0, 0.0))
	return _scale_ember_curve


static func make_fade_gradient(core_col: Color, mid_col: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.25, 0.72, 1.0])
	g.colors = PackedColorArray([
		Color(core_col.r, core_col.g, core_col.b, 0.95),
		Color(mid_col.r, mid_col.g, mid_col.b, 0.88),
		Color(mid_col.r, mid_col.g, mid_col.b, 0.38),
		Color(mid_col.r, mid_col.g, mid_col.b, 0.0)
	])
	return g


static func make_smoke_gradient(base_col: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	g.colors = PackedColorArray([
		Color(base_col.r, base_col.g, base_col.b, base_col.a),
		Color(base_col.r, base_col.g, base_col.b, base_col.a * 0.65),
		Color(base_col.r, base_col.g, base_col.b, 0.0)
	])
	return g


## Tiện ích cấu hình CPUParticles2D tỏa sáng mềm mượt (dùng cho tàn lửa, tia đánh trúng, bụi bước chân).
static func configure_glow_particles(p: CPUParticles2D, core_col: Color, mid_col: Color, use_streak: bool = false) -> void:
	p.texture = get_spark_streak_texture() if use_streak else get_glow_dot_texture()
	p.material = get_additive_material()
	p.scale_amount_curve = get_scale_pop_curve() if use_streak else get_scale_ember_curve()
	p.color_ramp = make_fade_gradient(core_col, mid_col)
	p.color = Color.WHITE
	if use_streak:
		p.particle_flag_align_y = true


## Tiện ích sinh nhanh chùm hạt phát sáng 1 lần tự giải phóng.
static func spawn_spark_burst(
	parent_node: Node,
	world_pos: Vector2,
	core_col: Color,
	mid_col: Color,
	count: int = 14,
	vel_min: float = 80.0,
	vel_max: float = 210.0,
	life: float = 0.32,
	dir_vec: Vector2 = Vector2.RIGHT,
	spread_deg: float = 180.0,
	scale_min: float = 0.28,
	scale_max: float = 0.58,
	use_streak: bool = true
) -> void:
	if parent_node == null:
		return
	var p := CPUParticles2D.new()
	p.global_position = world_pos
	p.one_shot = true
	p.explosiveness = 0.96
	p.amount = count
	p.lifetime = life
	p.direction = dir_vec.normalized() if dir_vec.length() > 0.01 else Vector2.RIGHT
	p.spread = spread_deg
	p.gravity = Vector2(0, 70) if spread_deg >= 140.0 else Vector2(0, 20)
	p.damping_min = 90.0
	p.damping_max = 180.0
	p.initial_velocity_min = vel_min
	p.initial_velocity_max = vel_max
	p.scale_amount_min = scale_min
	p.scale_amount_max = scale_max
	p.z_index = 4
	configure_glow_particles(p, core_col, mid_col, use_streak)
	parent_node.add_child(p)
	p.emitting = true
	parent_node.get_tree().create_timer(life + 0.14).timeout.connect(p.queue_free)


## Sinh bụi bước chân / bụi đất mềm mờ dần (không còn ô vuông trắng cứng).
static func spawn_dust_puff(parent_node: Node, world_pos: Vector2, dust_col: Color = Color(0.76, 0.80, 0.86, 0.42), count: int = 6, spread_deg: float = 75.0, scale_mult: float = 1.0) -> void:
	if parent_node == null:
		return
	var p := CPUParticles2D.new()
	p.global_position = world_pos
	p.one_shot = true
	p.explosiveness = 0.88
	p.amount = count
	p.lifetime = 0.38
	p.direction = Vector2(0, -1)
	p.spread = spread_deg
	p.gravity = Vector2(0, -14)
	p.damping_min = 35.0
	p.damping_max = 75.0
	p.initial_velocity_min = 18.0
	p.initial_velocity_max = 46.0
	p.scale_amount_min = 0.32 * scale_mult
	p.scale_amount_max = 0.62 * scale_mult
	p.texture = get_smoke_puff_texture()
	p.scale_amount_curve = get_scale_smoke_curve()
	p.color_ramp = make_smoke_gradient(dust_col)
	p.color = Color.WHITE
	p.z_index = -1
	parent_node.add_child(p)
	p.emitting = true
	parent_node.get_tree().create_timer(0.50).timeout.connect(p.queue_free)
