class_name RegionalWeatherBuilder
extends RefCounted
## Bộ Xây Dựng Thời Tiết & Khí Quyển Động Theo Vùng (Tách mô-đun từ world_stage_manager.gd):
##   - Thiên Phần Tháp, Hắc Giác Vực, Học Viện Già Nam, Vân Lam Sơn, Dung Nham, Sa Mạc, Rừng Trúc, Tâm Ma & Quảng Trường.


static func make_soft_ambient_gradient(base_col: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.18, 0.78, 1.0])
	g.colors = PackedColorArray([
		Color(base_col.r, base_col.g, base_col.b, 0.0),
		base_col,
		Color(base_col.r, base_col.g, base_col.b, base_col.a * 0.80),
		Color(base_col.r, base_col.g, base_col.b, 0.0)
	])
	return g


static func build_regional_weather(stage, m_def: Dictionary) -> void:
	var current_map_id: String = str(stage.current_map_id)
	var map_size: Vector2 = stage.map_size
	var map_overlay_root: Node2D = stage.map_overlay_root
	var base_tile: String = str(m_def.get("base_tile", m_def.get("ground_tile", "")))
	var is_tower_arena: bool = (bool(stage.is_tower_active) or current_map_id == "thien_phan_thap")
	var is_hac_giac_vuc: bool = (
		current_map_id == "ch05_rung_dem_huyet_vu"
		or current_map_id == "ch05_hac_an_thanh"
		or current_map_id == "ch05_hem_nui_hac_phong"
	)
	var is_gia_nam: bool = (
		current_map_id == "ch05_hoa_binh_tran"
		or current_map_id == "ch05_ngoai_vien_gia_nam"
		or current_map_id == "ch05_rung_san_hoa_nang"
	)
	var is_yunlan_high: bool = (
		current_map_id == "ch04_thien_thang_van_lam"
		or current_map_id == "ch04_dinh_van_lam_son"
		or current_map_id == "ch04_rung_phong_toa"
	)
	var is_volcanic: bool = (
		base_tile.find("volcanic_basalt") != -1
		or current_map_id == "ch03_dia_huyet_dung_nham"
	)
	var is_desert: bool = (
		base_tile.find("desert_sand") != -1
		or base_tile.find("sandstone_plaza") != -1
		or base_tile.find("oasis_turquoise") != -1
	)
	var is_forest_or_cave: bool = (
		bool(stage.current_is_forest)
		or base_tile.find("bamboo_grass") != -1
		or current_map_id == "ch02_huyen_nhai_dong"
	)
	var is_boss_rush_arena: bool = (
		bool(stage.is_boss_rush_active)
		or current_map_id == "tam_ma_luyen_canh"
		or base_tile.find("arena_violet") != -1
	)
	var amb_weather: String = str(m_def.get("ambient_weather", ""))
	if amb_weather == "sakura_petals" or current_map_id == "ch09_hoa_tong_thanh_dia":
		# Hoa Tông Thánh Địa: Cánh hoa anh đào hồng phấn bay nhẹ lãng mạn khắp thung lũng!
		var sakura := CPUParticles2D.new()
		sakura.position = map_size * 0.5
		sakura.emitting = true
		sakura.preprocess = 2.4
		sakura.amount = 54
		sakura.lifetime = 6.5
		sakura.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		sakura.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		sakura.direction = Vector2(0.58, 0.80).normalized()
		sakura.spread = 28.0
		sakura.gravity = Vector2(6.0, 10.0)
		sakura.initial_velocity_min = 22.0
		sakura.initial_velocity_max = 48.0
		sakura.angle_min = -180.0
		sakura.angle_max = 180.0
		sakura.angular_velocity_min = -80.0
		sakura.angular_velocity_max = 80.0
		sakura.scale_amount_min = 0.30
		sakura.scale_amount_max = 0.58
		sakura.texture = VfxAssets.get_spark_streak_texture()
		sakura.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		sakura.color_ramp = make_soft_ambient_gradient(Color(1.0, 0.72, 0.84, 0.86))
		sakura.color = Color.WHITE
		map_overlay_root.add_child(sakura)
		return
	elif amb_weather == "soul_mist" or current_map_id == "ch09_vong_hon_son_mach":
		# Vong Hồn Sơn Mạch: Phệ Hồn Mê Vụ xanh lục ma quái + tàn hồn bay lờ mờ!
		var smist := CPUParticles2D.new()
		smist.position = map_size * 0.5
		smist.emitting = true
		smist.preprocess = 2.4
		smist.amount = 28
		smist.lifetime = 7.0
		smist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		smist.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.48)
		smist.direction = Vector2(-1.0, 0.10).normalized()
		smist.spread = 20.0
		smist.gravity = Vector2(-6.0, 0.0)
		smist.initial_velocity_min = 18.0
		smist.initial_velocity_max = 40.0
		smist.scale_amount_min = 3.2
		smist.scale_amount_max = 6.0
		smist.texture = VfxAssets.get_smoke_puff_texture()
		smist.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		smist.color_ramp = make_soft_ambient_gradient(Color(0.18, 0.78, 0.58, 0.16))
		smist.color = Color.WHITE
		map_overlay_root.add_child(smist)
		return
	elif amb_weather == "void_lightning" or current_map_id == "ch09_co_long_loi_tri":
		# Hư Không Lôi Trì (Cổ Long Đảo): Tia sét Hắc Ma Lôi tím-vàng nhảy tách tách giữa hư không!
		var vsparks := CPUParticles2D.new()
		vsparks.position = map_size * 0.5
		vsparks.emitting = true
		vsparks.preprocess = 1.6
		vsparks.amount = 64
		vsparks.lifetime = 1.6
		vsparks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		vsparks.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		vsparks.direction = Vector2(0.0, 1.0)
		vsparks.spread = 180.0
		vsparks.gravity = Vector2(0.0, 12.0)
		vsparks.initial_velocity_min = 45.0
		vsparks.initial_velocity_max = 125.0
		vsparks.scale_amount_min = 0.24
		vsparks.scale_amount_max = 0.56
		VfxAssets.configure_glow_particles(vsparks, Color("#FFD166"), Color("#9D4EDD"), true)
		map_overlay_root.add_child(vsparks)
		return
	elif amb_weather == "tomb_energy" or current_map_id == "ch09_thien_mo_tam_tang":
		# Thiên Mộ Tam Tầng: Hạt năng lượng bạc-vàng cổ đại bốc lên chậm rãi tạo cảm giác dòng chảy thời gian x5!
		var tmotes := CPUParticles2D.new()
		tmotes.position = map_size * 0.5
		tmotes.emitting = true
		tmotes.preprocess = 2.2
		tmotes.amount = 60
		tmotes.lifetime = 4.6
		tmotes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		tmotes.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		tmotes.direction = Vector2(0.0, -1.0)
		tmotes.spread = 35.0
		tmotes.gravity = Vector2(0.0, -16.0)
		tmotes.initial_velocity_min = 18.0
		tmotes.initial_velocity_max = 46.0
		tmotes.scale_amount_min = 0.22
		tmotes.scale_amount_max = 0.50
		VfxAssets.configure_glow_particles(tmotes, Color("#FFF3B0"), Color("#ADB5BD"), false)
		map_overlay_root.add_child(tmotes)
		return
	elif amb_weather == "emerald_bodhi":
		# Mãng Hoang & Bồ Đề Cổ Thụ: Lá Bồ Đề ngọc bích phát sáng (#34D399) bay bồng bềnh thiền định!
		var bleaves := CPUParticles2D.new()
		bleaves.position = map_size * 0.5
		bleaves.emitting = true
		bleaves.preprocess = 2.4
		bleaves.amount = 56
		bleaves.lifetime = 6.2
		bleaves.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		bleaves.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		bleaves.direction = Vector2(0.35, 0.90).normalized()
		bleaves.spread = 32.0
		bleaves.gravity = Vector2(4.0, 8.0)
		bleaves.initial_velocity_min = 20.0
		bleaves.initial_velocity_max = 46.0
		bleaves.scale_amount_min = 0.26
		bleaves.scale_amount_max = 0.54
		VfxAssets.configure_glow_particles(bleaves, Color("#A7F3D0"), Color("#34D399"), false)
		map_overlay_root.add_child(bleaves)
		return
	elif amb_weather == "siege_embers":
		# Chiến Trường Viêm Minh & Pháo Đài Nhân Điện: Tro tàn & tàn lửa công thành bay xiên rực rỡ!
		var embers := CPUParticles2D.new()
		embers.position = map_size * 0.5
		embers.emitting = true
		embers.preprocess = 1.8
		embers.amount = 72
		embers.lifetime = 3.2
		embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		embers.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		embers.direction = Vector2(-0.52, -0.85).normalized()
		embers.spread = 28.0
		embers.gravity = Vector2(-12.0, -24.0)
		embers.initial_velocity_min = 42.0
		embers.initial_velocity_max = 108.0
		embers.scale_amount_min = 0.24
		embers.scale_amount_max = 0.54
		VfxAssets.configure_glow_particles(embers, Color("#FDE047"), Color("#EF4444"), true)
		map_overlay_root.add_child(embers)
		return
	elif amb_weather == "abyss_mist":
		# Cửu U Hoàng Tuyền Huyết Đàm: Âm khí vàng đất & hàn vụ u minh cuộn chậm dưới đáy vực!
		var amist := CPUParticles2D.new()
		amist.position = map_size * 0.5
		amist.emitting = true
		amist.preprocess = 2.4
		amist.amount = 30
		amist.lifetime = 6.8
		amist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		amist.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.48)
		amist.direction = Vector2(0.85, -0.25).normalized()
		amist.spread = 22.0
		amist.gravity = Vector2(4.0, -4.0)
		amist.initial_velocity_min = 18.0
		amist.initial_velocity_max = 42.0
		amist.scale_amount_min = 3.2
		amist.scale_amount_max = 5.8
		amist.texture = VfxAssets.get_smoke_puff_texture()
		amist.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		amist.color_ramp = make_soft_ambient_gradient(Color(0.79, 0.54, 0.04, 0.16))
		amist.color = Color.WHITE
		map_overlay_root.add_child(amist)
		return
	elif amb_weather == "lotus_flames":
		# Yêu Hỏa Không Gian: Cánh sen lửa trắng sữa & hồng ngọc (#FFF1F2 / #FDA4AF) bay cuộn đẹp mê hồn!
		var lflames := CPUParticles2D.new()
		lflames.position = map_size * 0.5
		lflames.emitting = true
		lflames.preprocess = 2.0
		lflames.amount = 74
		lflames.lifetime = 3.8
		lflames.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		lflames.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		lflames.direction = Vector2(0.18, -0.98).normalized()
		lflames.spread = 36.0
		lflames.gravity = Vector2(0.0, -26.0)
		lflames.initial_velocity_min = 32.0
		lflames.initial_velocity_max = 86.0
		lflames.scale_amount_min = 0.28
		lflames.scale_amount_max = 0.60
		VfxAssets.configure_glow_particles(lflames, Color("#FFF1F2"), Color("#FDA4AF"), true)
		map_overlay_root.add_child(lflames)
		return
	elif amb_weather == "pill_realm_ash":
		# Dược Giới Vạn Dược Sơn (Ch.11): Dược phấn xanh ngọc xen tro tàn tím Hư Vô bay lững lờ!
		var pash := CPUParticles2D.new()
		pash.position = map_size * 0.5
		pash.emitting = true
		pash.preprocess = 2.0
		pash.amount = 64
		pash.lifetime = 4.8
		pash.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		pash.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		pash.direction = Vector2(-0.35, -0.92).normalized()
		pash.spread = 34.0
		pash.gravity = Vector2(-6.0, -14.0)
		pash.initial_velocity_min = 24.0
		pash.initial_velocity_max = 62.0
		pash.scale_amount_min = 0.24
		pash.scale_amount_max = 0.52
		VfxAssets.configure_glow_particles(pash, Color("#4ADE80"), Color("#A855F7"), false)
		map_overlay_root.add_child(pash)
		return
	elif amb_weather == "blood_sky":
		# Táng Thiên Sơn Mạch & Cửu Tiêu Thương Khung (Ch.11): Tàn huyết vụ & sét đỏ Song Đế Chi Chiến!
		var bsky := CPUParticles2D.new()
		bsky.position = map_size * 0.5
		bsky.emitting = true
		bsky.preprocess = 1.8
		bsky.amount = 82
		bsky.lifetime = 2.8
		bsky.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		bsky.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		bsky.direction = Vector2(-0.45, -0.88).normalized()
		bsky.spread = 38.0
		bsky.gravity = Vector2(-14.0, -28.0)
		bsky.initial_velocity_min = 48.0
		bsky.initial_velocity_max = 128.0
		bsky.scale_amount_min = 0.26
		bsky.scale_amount_max = 0.58
		VfxAssets.configure_glow_particles(bsky, Color("#FCA5A5"), Color("#DC2626"), true)
		map_overlay_root.add_child(bsky)
		return
	elif amb_weather == "emperor_flames":
		# Đà Xá Cổ Đế Động Phủ (Ch.11): Tàn lửa ngũ sắc 23 Dị Hỏa bốc lên rực rỡ quanh 22 cột đá!
		var efl := CPUParticles2D.new()
		efl.position = map_size * 0.5
		efl.emitting = true
		efl.preprocess = 2.0
		efl.amount = 84
		efl.lifetime = 3.8
		efl.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		efl.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		efl.direction = Vector2(0.0, -1.0)
		efl.spread = 32.0
		efl.gravity = Vector2(0.0, -28.0)
		efl.initial_velocity_min = 34.0
		efl.initial_velocity_max = 94.0
		efl.scale_amount_min = 0.26
		efl.scale_amount_max = 0.62
		VfxAssets.configure_glow_particles(efl, Color("#00F5D4"), Color("#FFD700"), true)
		map_overlay_root.add_child(efl)
		return
	elif amb_weather == "wedding_petals":
		# Ô Thản Thành Đại Hôn (Ch.11): Cánh hoa hồng đỏ & kim phấn tung bay ngập tràn hỷ khí!
		var wpet := CPUParticles2D.new()
		wpet.position = map_size * 0.5
		wpet.emitting = true
		wpet.preprocess = 2.4
		wpet.amount = 70
		wpet.lifetime = 6.0
		wpet.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		wpet.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		wpet.direction = Vector2(0.45, 0.88).normalized()
		wpet.spread = 34.0
		wpet.gravity = Vector2(4.0, 9.0)
		wpet.initial_velocity_min = 20.0
		wpet.initial_velocity_max = 46.0
		wpet.scale_amount_min = 0.28
		wpet.scale_amount_max = 0.56
		VfxAssets.configure_glow_particles(wpet, Color("#FB7185"), Color("#FDE047"), false)
		map_overlay_root.add_child(wpet)
		return
	elif amb_weather == "cosmic_rift":
		# Thương Khung Vị Diện Giao Giới (Ch.11 Post-Game): Tinh tú lam ngọc & ánh vàng Đại Thiên xoay bồng bềnh!
		var crift := CPUParticles2D.new()
		crift.position = map_size * 0.5
		crift.emitting = true
		crift.preprocess = 2.2
		crift.amount = 76
		crift.lifetime = 4.6
		crift.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		crift.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		crift.direction = Vector2(0.24, -0.96).normalized()
		crift.spread = 52.0
		crift.gravity = Vector2(0.0, -14.0)
		crift.initial_velocity_min = 22.0
		crift.initial_velocity_max = 68.0
		crift.scale_amount_min = 0.24
		crift.scale_amount_max = 0.58
		VfxAssets.configure_glow_particles(crift, Color("#38BDF8"), Color("#FFD700"), true)
		map_overlay_root.add_child(crift)
		return

	if is_tower_arena:
		# Thiên Phần Luyện Khí Tháp: Tàn lửa Vẫn Lạc Tâm Viêm (#FF4D6D / #FFD166) bốc cuộn dày đặc khắp đấu trường!
		var heart_embers := CPUParticles2D.new()
		heart_embers.position = map_size * 0.5
		heart_embers.emitting = true
		heart_embers.preprocess = 2.0
		heart_embers.amount = 74
		heart_embers.lifetime = 3.2
		heart_embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		heart_embers.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.48)
		heart_embers.direction = Vector2(0.08, -1.0).normalized()
		heart_embers.spread = 28.0
		heart_embers.gravity = Vector2(0.0, -34.0)
		heart_embers.initial_velocity_min = 42.0
		heart_embers.initial_velocity_max = 104.0
		heart_embers.scale_amount_min = 0.24
		heart_embers.scale_amount_max = 0.56
		VfxAssets.configure_glow_particles(heart_embers, Color("#FFD166"), Color("#FF4D6D"), false)
		map_overlay_root.add_child(heart_embers)

		var heart_streaks := CPUParticles2D.new()
		heart_streaks.position = map_size * 0.5
		heart_streaks.emitting = true
		heart_streaks.preprocess = 1.6
		heart_streaks.amount = 34
		heart_streaks.lifetime = 2.2
		heart_streaks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		heart_streaks.emission_rect_extents = Vector2(map_size.x * 0.46, map_size.y * 0.46)
		heart_streaks.direction = Vector2(0.0, -1.0)
		heart_streaks.spread = 18.0
		heart_streaks.gravity = Vector2(0.0, -48.0)
		heart_streaks.initial_velocity_min = 78.0
		heart_streaks.initial_velocity_max = 152.0
		heart_streaks.scale_amount_min = 0.28
		heart_streaks.scale_amount_max = 0.62
		VfxAssets.configure_glow_particles(heart_streaks, Color("#FFF3B0"), Color("#FF4D6D"), true)
		map_overlay_root.add_child(heart_streaks)

		var magma_haze := CPUParticles2D.new()
		magma_haze.position = map_size * 0.5
		magma_haze.emitting = true
		magma_haze.preprocess = 2.0
		magma_haze.amount = 18
		magma_haze.lifetime = 4.8
		magma_haze.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		magma_haze.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.46)
		magma_haze.direction = Vector2(0.06, -1.0).normalized()
		magma_haze.spread = 24.0
		magma_haze.gravity = Vector2(0.0, -12.0)
		magma_haze.initial_velocity_min = 18.0
		magma_haze.initial_velocity_max = 38.0
		magma_haze.scale_amount_min = 2.4
		magma_haze.scale_amount_max = 4.6
		magma_haze.texture = VfxAssets.get_smoke_puff_texture()
		magma_haze.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		magma_haze.color_ramp = make_soft_ambient_gradient(Color(1.0, 0.30, 0.38, 0.12))
		magma_haze.color = Color.WHITE
		map_overlay_root.add_child(magma_haze)

	elif is_hac_giac_vuc:
		# Hắc Giác Vực (Rừng Đêm Huyết Vũ / Hắc Ấn Thành / Hẻm Núi Hắc Phong): Mưa đêm huyết-bạc xiên chéo + sương mù máu trôi lững lờ!
		var blood_rain := CPUParticles2D.new()
		blood_rain.position = map_size * 0.5
		blood_rain.emitting = true
		blood_rain.preprocess = 1.4
		blood_rain.amount = 76
		blood_rain.lifetime = 1.45
		blood_rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		blood_rain.emission_rect_extents = Vector2(map_size.x * 0.54, map_size.y * 0.52)
		blood_rain.direction = Vector2(-0.32, 1.0).normalized()
		blood_rain.spread = 4.0
		blood_rain.gravity = Vector2(-18.0, 65.0)
		blood_rain.initial_velocity_min = 270.0
		blood_rain.initial_velocity_max = 395.0
		blood_rain.particle_flag_align_y = true
		blood_rain.scale_amount_min = 0.50
		blood_rain.scale_amount_max = 1.15
		blood_rain.texture = VfxAssets.get_spark_streak_texture()
		blood_rain.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		var rain_grad := Gradient.new()
		rain_grad.offsets = PackedFloat32Array([0.0, 0.22, 0.78, 1.0])
		rain_grad.colors = PackedColorArray([
			Color(0.84, 0.88, 0.96, 0.0),
			Color(0.82, 0.86, 0.94, 0.48),
			Color(0.76, 0.14, 0.26, 0.42),
			Color(0.55, 0.08, 0.18, 0.0)
		])
		blood_rain.color_ramp = rain_grad
		blood_rain.color = Color.WHITE
		map_overlay_root.add_child(blood_rain)

		var blood_mist := CPUParticles2D.new()
		blood_mist.position = map_size * 0.5
		blood_mist.emitting = true
		blood_mist.preprocess = 2.4
		blood_mist.amount = 22
		blood_mist.lifetime = 6.8
		blood_mist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		blood_mist.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.48)
		blood_mist.direction = Vector2(-1.0, 0.12).normalized()
		blood_mist.spread = 18.0
		blood_mist.gravity = Vector2(-6.0, 0.0)
		blood_mist.initial_velocity_min = 18.0
		blood_mist.initial_velocity_max = 42.0
		blood_mist.scale_amount_min = 3.0
		blood_mist.scale_amount_max = 5.8
		blood_mist.texture = VfxAssets.get_smoke_puff_texture()
		blood_mist.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		blood_mist.color_ramp = make_soft_ambient_gradient(Color(0.62, 0.12, 0.22, 0.15))
		blood_mist.color = Color.WHITE
		map_overlay_root.add_child(blood_mist)

	elif is_gia_nam:
		# Học Viện Già Nam (Hòa Bình Trấn / Ngoại Viện / Rừng Săn Hỏa Năng): Bụi nắng vàng ấm áp + cánh lá ngọc bích bay lả tả!
		var sunlit_motes := CPUParticles2D.new()
		sunlit_motes.position = map_size * 0.5
		sunlit_motes.emitting = true
		sunlit_motes.preprocess = 2.4
		sunlit_motes.amount = 44
		sunlit_motes.lifetime = 5.6
		sunlit_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		sunlit_motes.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.48)
		sunlit_motes.direction = Vector2(0.32, -1.0).normalized()
		sunlit_motes.spread = 65.0
		sunlit_motes.gravity = Vector2(2.0, -5.0)
		sunlit_motes.initial_velocity_min = 10.0
		sunlit_motes.initial_velocity_max = 26.0
		sunlit_motes.scale_amount_min = 0.20
		sunlit_motes.scale_amount_max = 0.42
		VfxAssets.configure_glow_particles(sunlit_motes, Color("#FFF9DB"), Color("#FFD166"), false)
		sunlit_motes.modulate.a = 0.80
		map_overlay_root.add_child(sunlit_motes)

		var jade_petals := CPUParticles2D.new()
		jade_petals.position = map_size * 0.5
		jade_petals.emitting = true
		jade_petals.preprocess = 2.4
		jade_petals.amount = 36
		jade_petals.lifetime = 6.2
		jade_petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		jade_petals.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		jade_petals.direction = Vector2(0.68, 0.72).normalized()
		jade_petals.spread = 24.0
		jade_petals.gravity = Vector2(8.0, 10.0)
		jade_petals.initial_velocity_min = 24.0
		jade_petals.initial_velocity_max = 54.0
		jade_petals.angle_min = -180.0
		jade_petals.angle_max = 180.0
		jade_petals.angular_velocity_min = -70.0
		jade_petals.angular_velocity_max = 70.0
		jade_petals.scale_amount_min = 0.28
		jade_petals.scale_amount_max = 0.54
		jade_petals.texture = VfxAssets.get_spark_streak_texture()
		jade_petals.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		var jade_grad := Gradient.new()
		jade_grad.offsets = PackedFloat32Array([0.0, 0.22, 0.76, 1.0])
		jade_grad.colors = PackedColorArray([
			Color(0.50, 0.93, 0.60, 0.0),
			Color(0.50, 0.93, 0.60, 0.78),
			Color(0.18, 0.77, 0.71, 0.58),
			Color(0.18, 0.77, 0.71, 0.0)
		])
		jade_petals.color_ramp = jade_grad
		jade_petals.color = Color.WHITE
		map_overlay_root.add_child(jade_petals)

	elif is_yunlan_high:
		# Vân Lam Sơn / Cao Nguyên Mây Trắng: Sương mây bồng bềnh + cánh hoa/mây xanh lam bay ngang!
		var cloud_mist := CPUParticles2D.new()
		cloud_mist.position = map_size * 0.5
		cloud_mist.emitting = true
		cloud_mist.preprocess = 2.6
		cloud_mist.amount = 24
		cloud_mist.lifetime = 7.6
		cloud_mist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		cloud_mist.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.48)
		cloud_mist.direction = Vector2(1.0, 0.14).normalized()
		cloud_mist.spread = 16.0
		cloud_mist.gravity = Vector2(4.0, 0.0)
		cloud_mist.initial_velocity_min = 24.0
		cloud_mist.initial_velocity_max = 52.0
		cloud_mist.scale_amount_min = 3.2
		cloud_mist.scale_amount_max = 6.4
		cloud_mist.texture = VfxAssets.get_smoke_puff_texture()
		cloud_mist.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		cloud_mist.color_ramp = make_soft_ambient_gradient(Color(0.88, 0.94, 1.0, 0.16))
		cloud_mist.color = Color.WHITE
		map_overlay_root.add_child(cloud_mist)

		var cloud_petals := CPUParticles2D.new()
		cloud_petals.position = map_size * 0.5
		cloud_petals.emitting = true
		cloud_petals.preprocess = 2.2
		cloud_petals.amount = 36
		cloud_petals.lifetime = 6.2
		cloud_petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		cloud_petals.emission_rect_extents = Vector2(map_size.x * 0.50, map_size.y * 0.48)
		cloud_petals.direction = Vector2(0.86, 0.50).normalized()
		cloud_petals.spread = 24.0
		cloud_petals.gravity = Vector2(8.0, 6.0)
		cloud_petals.initial_velocity_min = 28.0
		cloud_petals.initial_velocity_max = 64.0
		cloud_petals.angle_min = -180.0
		cloud_petals.angle_max = 180.0
		cloud_petals.angular_velocity_min = -60.0
		cloud_petals.angular_velocity_max = 60.0
		cloud_petals.scale_amount_min = 0.28
		cloud_petals.scale_amount_max = 0.54
		cloud_petals.texture = VfxAssets.get_spark_streak_texture()
		cloud_petals.material = VfxAssets.get_additive_material()
		cloud_petals.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		var petal_grad := Gradient.new()
		petal_grad.offsets = PackedFloat32Array([0.0, 0.20, 0.72, 1.0])
		petal_grad.colors = PackedColorArray([
			Color(0.94, 0.98, 1.0, 0.0),
			Color(0.92, 0.98, 1.0, 0.78),
			Color(0.56, 0.86, 1.0, 0.52),
			Color(0.56, 0.86, 1.0, 0.0)
		])
		cloud_petals.color_ramp = petal_grad
		cloud_petals.color = Color.WHITE
		map_overlay_root.add_child(cloud_petals)

	elif is_volcanic:
		# Địa Huyệt Dung Nham / Phế Tích Tro Tàn: Tàn lửa nham thạch rực cháy bay lên khắp hang!
		var embers := CPUParticles2D.new()
		embers.position = map_size * 0.5
		embers.emitting = true
		embers.preprocess = 2.0
		embers.amount = 56
		embers.lifetime = 3.8
		embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		embers.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.48)
		embers.direction = Vector2(0.14, -1.0).normalized()
		embers.spread = 32.0
		embers.gravity = Vector2(0.0, -24.0)
		embers.initial_velocity_min = 26.0
		embers.initial_velocity_max = 66.0
		embers.scale_amount_min = 0.20
		embers.scale_amount_max = 0.48
		VfxAssets.configure_glow_particles(embers, Color("#FFF3B0"), Color("#FF6B00"), false)
		map_overlay_root.add_child(embers)

		var heat_haze := CPUParticles2D.new()
		heat_haze.position = map_size * 0.5
		heat_haze.emitting = true
		heat_haze.preprocess = 2.0
		heat_haze.amount = 16
		heat_haze.lifetime = 5.4
		heat_haze.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		heat_haze.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.46)
		heat_haze.direction = Vector2(0.08, -1.0).normalized()
		heat_haze.spread = 22.0
		heat_haze.gravity = Vector2(0.0, -10.0)
		heat_haze.initial_velocity_min = 14.0
		heat_haze.initial_velocity_max = 32.0
		heat_haze.scale_amount_min = 2.2
		heat_haze.scale_amount_max = 4.2
		heat_haze.texture = VfxAssets.get_smoke_puff_texture()
		heat_haze.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		heat_haze.color_ramp = make_soft_ambient_gradient(Color(0.95, 0.42, 0.16, 0.10))
		heat_haze.color = Color.WHITE
		map_overlay_root.add_child(heat_haze)

	elif is_desert:
		# Sa Mạc Tháp Qua Nhĩ / Quảng Trường Sa Thạch: Luồng bão cát vàng quét chéo phải-xuống!
		var sand_streaks := CPUParticles2D.new()
		sand_streaks.position = map_size * 0.5
		sand_streaks.emitting = true
		sand_streaks.preprocess = 1.6
		sand_streaks.amount = 54
		sand_streaks.lifetime = 2.4
		sand_streaks.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		sand_streaks.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.50)
		sand_streaks.direction = Vector2(1.0, 0.32).normalized()
		sand_streaks.spread = 10.0
		sand_streaks.gravity = Vector2(28.0, 10.0)
		sand_streaks.initial_velocity_min = 140.0
		sand_streaks.initial_velocity_max = 245.0
		sand_streaks.particle_flag_align_y = true
		sand_streaks.scale_amount_min = 0.55
		sand_streaks.scale_amount_max = 1.25
		sand_streaks.texture = VfxAssets.get_spark_streak_texture()
		sand_streaks.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		sand_streaks.color_ramp = make_soft_ambient_gradient(Color(0.95, 0.80, 0.50, 0.36))
		sand_streaks.color = Color.WHITE
		map_overlay_root.add_child(sand_streaks)

		var sand_haze := CPUParticles2D.new()
		sand_haze.position = map_size * 0.5
		sand_haze.emitting = true
		sand_haze.preprocess = 2.0
		sand_haze.amount = 16
		sand_haze.lifetime = 5.2
		sand_haze.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		sand_haze.emission_rect_extents = Vector2(map_size.x * 0.52, map_size.y * 0.48)
		sand_haze.direction = Vector2(1.0, 0.28).normalized()
		sand_haze.spread = 14.0
		sand_haze.gravity = Vector2(10.0, 3.0)
		sand_haze.initial_velocity_min = 52.0
		sand_haze.initial_velocity_max = 96.0
		sand_haze.scale_amount_min = 2.4
		sand_haze.scale_amount_max = 4.6
		sand_haze.texture = VfxAssets.get_smoke_puff_texture()
		sand_haze.scale_amount_curve = VfxAssets.get_scale_smoke_curve()
		sand_haze.color_ramp = make_soft_ambient_gradient(Color(0.95, 0.80, 0.50, 0.09))
		sand_haze.color = Color.WHITE
		map_overlay_root.add_child(sand_haze)

	elif is_forest_or_cave:
		# Rừng Trúc / Sơn Động: Đom đóm phát sáng dịu + lá trúc xanh lục lơ lửng rơi chéo xuống!
		var fireflies := CPUParticles2D.new()
		fireflies.position = map_size * 0.5
		fireflies.emitting = true
		fireflies.preprocess = 2.0
		fireflies.amount = 46
		fireflies.lifetime = 5.0
		fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		fireflies.emission_rect_extents = Vector2(map_size.x * 0.46, map_size.y * 0.46)
		fireflies.direction = Vector2(0.35, -1.0).normalized()
		fireflies.spread = 80.0
		fireflies.gravity = Vector2(0.0, -5.0)
		fireflies.initial_velocity_min = 8.0
		fireflies.initial_velocity_max = 22.0
		fireflies.scale_amount_min = 0.22
		fireflies.scale_amount_max = 0.44
		var ff_col: Color = Color("#70F5DF") if current_map_id == "ch02_huyen_nhai_dong" else (Color("#E0AAFF") if current_map_id == "ch02_noi_vi_su_vuong" else Color("#A8F5B0"))
		VfxAssets.configure_glow_particles(fireflies, Color.WHITE.lerp(ff_col, 0.35), ff_col, false)
		map_overlay_root.add_child(fireflies)

		var bamboo_leaves := CPUParticles2D.new()
		bamboo_leaves.position = map_size * 0.5
		bamboo_leaves.emitting = true
		bamboo_leaves.preprocess = 2.4
		bamboo_leaves.amount = 34
		bamboo_leaves.lifetime = 6.0
		bamboo_leaves.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		bamboo_leaves.emission_rect_extents = Vector2(map_size.x * 0.48, map_size.y * 0.48)
		bamboo_leaves.direction = Vector2(0.58, 0.82).normalized()
		bamboo_leaves.spread = 22.0
		bamboo_leaves.gravity = Vector2(6.0, 12.0)
		bamboo_leaves.initial_velocity_min = 24.0
		bamboo_leaves.initial_velocity_max = 52.0
		bamboo_leaves.angle_min = -180.0
		bamboo_leaves.angle_max = 180.0
		bamboo_leaves.angular_velocity_min = -65.0
		bamboo_leaves.angular_velocity_max = 65.0
		bamboo_leaves.scale_amount_min = 0.28
		bamboo_leaves.scale_amount_max = 0.54
		bamboo_leaves.texture = VfxAssets.get_spark_streak_texture()
		bamboo_leaves.scale_amount_curve = VfxAssets.get_scale_ember_curve()
		var leaf_col := Color("#74C69D")
		bamboo_leaves.color_ramp = make_soft_ambient_gradient(Color(leaf_col.r, leaf_col.g, leaf_col.b, 0.72))
		bamboo_leaves.color = Color.WHITE
		map_overlay_root.add_child(bamboo_leaves)

	elif is_boss_rush_arena:
		# Tâm Ma Luyện Cảnh: Linh khí tím huyền bí & tàn quang vàng bốc nhẹ quanh đấu trường!
		var arena_wisps := CPUParticles2D.new()
		arena_wisps.position = map_size * 0.5
		arena_wisps.emitting = true
		arena_wisps.preprocess = 2.0
		arena_wisps.amount = 42
		arena_wisps.lifetime = 4.6
		arena_wisps.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		arena_wisps.emission_rect_extents = Vector2(map_size.x * 0.46, map_size.y * 0.44)
		arena_wisps.direction = Vector2(0.0, -1.0)
		arena_wisps.spread = 45.0
		arena_wisps.gravity = Vector2(0.0, -12.0)
		arena_wisps.initial_velocity_min = 14.0
		arena_wisps.initial_velocity_max = 38.0
		arena_wisps.scale_amount_min = 0.20
		arena_wisps.scale_amount_max = 0.44
		VfxAssets.configure_glow_particles(arena_wisps, Color("#F3D5FF"), Color("#9D4EDD"), false)
		map_overlay_root.add_child(arena_wisps)

	else:
		# Đế Đô / Gia Tộc / Quảng Trường (courtyard_stone mặc định): Hạt linh khí vàng nhẹ bay lên êm ái!
		var qi_motes := CPUParticles2D.new()
		qi_motes.position = map_size * 0.5
		qi_motes.emitting = true
		qi_motes.preprocess = 2.4
		qi_motes.amount = 30
		qi_motes.lifetime = 6.2
		qi_motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		qi_motes.emission_rect_extents = Vector2(map_size.x * 0.46, map_size.y * 0.46)
		qi_motes.direction = Vector2(0.18, -1.0).normalized()
		qi_motes.spread = 55.0
		qi_motes.gravity = Vector2(0.0, -4.0)
		qi_motes.initial_velocity_min = 6.0
		qi_motes.initial_velocity_max = 18.0
		qi_motes.scale_amount_min = 0.16
		qi_motes.scale_amount_max = 0.34
		VfxAssets.configure_glow_particles(qi_motes, Color("#FFF8D6"), Color("#FFD166"), false)
		qi_motes.modulate.a = 0.72
		map_overlay_root.add_child(qi_motes)
