class_name BossSkillExecutor
extends RefCounted
## Bộ Chiêu Thức Độc Quyền, Màu Đặc Trưng & Bộc Phát Giai Đoạn II Cho Toàn Bộ 41+ Boss (Tách mô-đun từ enemy_controller.gd):
##   - get_signature_color(): Bảng màu ánh sáng/VFX đặc trưng của từng Boss Ch.01–Ch.08+
##   - trigger_boss_phase_2(): Khai mở Phase 2, thoại chiến đấu & sóng xung kích
##   - execute_boss_signature_skill(): Trọn bộ 41 bộ chiêu thức & pattern riêng biệt
##   - fire_boss_triple_wave(): Loạt 3 tia sóng Đấu Khí đặc trưng từng Boss


static func get_signature_color(enemy_id: String) -> Color:
	if enemy_id == "trich_tinh_lao_quy_boss":
		return Color("#A855F7")
	elif enemy_id == "hac_bach_thien_ton_boss":
		return Color("#E0FBFC")
	elif enemy_id == "yeu_hoa_ta_quan_boss":
		return Color("#FF4D6D")
	elif enemy_id == "tan_hon_tao_hoa_boss":
		return Color("#FFD166")
	elif enemy_id == "bac_long_vuong_boss":
		return Color("#E63946")
	elif enemy_id == "co_yeu_do_thong_boss":
		return Color("#38BDF8")
	elif enemy_id == "huyet_dao_thanh_gia_boss":
		return Color("#FF2A5F")
	elif enemy_id == "phi_thien_boss":
		return Color("#72EFDD")
	elif enemy_id == "vuong_tran_boss":
		return Color("#E63946")
	elif enemy_id == "phuong_thanh_nhi_boss":
		return Color("#C77DFF")
	elif enemy_id == "bang_ha_thanh_hai_boss":
		return Color("#38BDF8")
	elif enemy_id == "cuu_long_loi_cuong_boss":
		return Color("#E2F1FF")
	elif enemy_id == "mo_cot_lao_nhan_boss":
		return Color("#9D4EDD")
	elif enemy_id == "tam_thien_diem_viem_boss":
		return Color("#A855F7")
	elif enemy_id == "van_son_boss":
		return Color("#72EFDD")
	elif enemy_id == "vu_ho_phap_boss":
		return Color("#E63946")
	elif enemy_id == "nhan_lac_thien_boss":
		return Color("#FFD166")
	elif enemy_id == "hat_tat_nham_boss":
		return Color("#70E000")
	elif enemy_id == "han_phong_dau_tong_boss":
		return Color("#38BDF8")
	elif enemy_id == "dia_ma_lao_quy_boss":
		return Color("#CAF0F8")
	elif enemy_id == "bach_thanh_boss":
		return Color("#90E0EF")
	elif enemy_id == "tuyet_ma_thien_vien_boss":
		return Color("#72EFDD")
	elif enemy_id == "lieu_kinh_boss":
		return Color("#FFD166")
	elif enemy_id == "van_lac_tam_viem_boss":
		return Color("#E0AAFF")
	elif enemy_id == "han_phong_boss":
		return Color("#00B4D8")
	elif enemy_id == "van_phan_boss":
		return Color("#70D6FF")
	elif enemy_id == "pham_lang_boss":
		return Color("#EF476F")
	elif enemy_id == "ngo_hao_boss":
		return Color("#FF2A5F")
	elif enemy_id == "la_hau_boss":
		return Color("#9D4EDD")
	elif enemy_id == "muc_xa_boss" or enemy_id == "tieu_tu_tinh_su_boss" or enemy_id == "mac_thua_boss" or enemy_id == "van_son_phan_than_boss":
		return Color("#C77DFF")
	elif enemy_id == "lieu_tich_boss" or enemy_id == "mac_ba_tu_boss" or enemy_id == "moc_chien_boss" or enemy_id == "viem_loi_boss":
		return Color("#52B788")
	elif enemy_id == "thach_khoi_boss" or enemy_id == "hai_ba_dong_boss" or enemy_id == "tieu_ninh_boss" or enemy_id == "nap_lan_yen_nhien_boss" or enemy_id == "van_yen_dai_tran_boss" or enemy_id == "van_lang_boss":
		return Color("#4CC9F0")
	elif enemy_id == "hoa_linh_xa_boss" or enemy_id == "co_ha_boss":
		return Color("#FF7B00")
	return Color("#FF4D6D")



static func trigger_boss_phase_2(e) -> void:
	e.boss_phase = 2
	e.state_phase = "idle"
	e.attack_cd = 0.75
	e.strike_hold_timer = 0.30
	e.strike_dir = Vector2(0, -1)
	e.strike_vfx_timer = 0.32
	e.strike_vfx_radius = 148.0
	e.strike_vfx_is_nova = true
	e.strike_vfx_color = get_signature_color(e.enemy_id)
	e._update_body_modulate()
	if e.boss_light != null:
		e.boss_light.color = Color("#FF2A5F")
		e.boss_light.energy = 1.75
		e.boss_light.texture_scale = 3.5

	EventBus.audio_sfx_requested.emit("boss_roar")
	EventBus.screen_shake_requested.emit(9.0, 0.35)
	var cry: String = "BỘC PHÁT GIAI ĐOẠN II!"
	if e.enemy_id == "tieu_ninh_boss":
		cry = "TĂNG KHÍ TÁN BỘC PHÁT — PHONG QUYỂN TÀN VÂN!"
	elif e.enemy_id == "tieu_ngoc_boss":
		cry = "TIÊU VIÊM HỖN ĐẢN — ĂN ROI ĐÂY!"
	elif e.enemy_id == "lieu_tich_boss":
		cry = "ĐỘC HỎA ĐỈNH BỘC PHÁT — DÁM ÁM SÁT BẢN DƯỢC SƯ?!"
	elif e.enemy_id == "gia_liet_ao_boss":
		cry = "GIA LIỆT HUYẾT CHIẾN — ĐẤU KHÍ CUỒNG BẠO!"
	elif e.enemy_id == "thach_khoi_boss":
		cry = "CƠ QUAN HỘ ĐỘNG KÍCH HOẠT TOÀN LỰC!"
	elif e.enemy_id == "tieu_tu_tinh_su_boss":
		cry = "GÀO!! TỬ TINH THÚ HỎA THIÊU RỤI KẺ ĐỘT NHẬP!"
	elif e.enemy_id == "muc_luc_boss":
		cry = "CHẾT ĐI TIỂU TỬ — TIỂU Y TIÊN LÀ CỦA TA!"
	elif e.enemy_id == "muc_xa_boss":
		cry = "LANG ĐẦU TRẬN — ĐẤU SƯ 2 TINH TOÀN LỰC!"
	elif e.enemy_id == "hai_ba_dong_boss":
		cry = "HÀN BĂNG NGƯNG LONG! ĐÓNG BĂNG KẺ XÂM NHẬP TIỆM BẢN ĐỒ!"
	elif e.enemy_id == "hoa_linh_xa_boss":
		cry = "SONG ĐẦU HỎA LINH XÀ PHUN NUNG CHẢY ĐỊA HUYỆT!"
	elif e.enemy_id == "mac_ba_tu_boss":
		cry = "XÀ NHÂN BÁT ĐẠI THỦ LĨNH — XÉ XÁC KẺ ĐỘT NHẬP THÁNH THÀNH!"
	elif e.enemy_id == "co_ha_boss":
		cry = "LỤC PHẨM ĐAN VƯƠNG CHI HỎA — GIAO THANH LIÊN ĐỊA TÂM HỎA RA ĐÂY!"
	elif e.enemy_id == "van_phan_boss":
		cry = "PHONG LÔI ĐỘNG CỬU THIÊN — TRƯỞNG LÃO VÂN LAM TÔNG TRUY SÁT ĐẾN CÙNG!"
	elif e.enemy_id == "pham_lang_boss":
		cry = "HUYẾT TÔNG BÍ PHÁP — PHỆ HUYẾT ĐOẠT HỒN, CHẾT ĐI TIÊU VIÊM!"
	elif e.enemy_id == "ngo_hao_boss":
		cry = "TU LA HUYẾT KIẾM KHAI PHONG — CÀNG ĐỔ MÁU TA CÀNG CUỒNG BẠO!"
	elif e.enemy_id == "la_hau_boss":
		cry = "U MINH LIỆT ĐỊA ẤN — LÃO SINH HẮC BẠCH QUAN SÁT KHÔNG DỄ VƯỢT QUA!"
	elif e.enemy_id == "bach_thanh_boss":
		cry = "BẠCH BANG SƯƠNG ĐAO — TÂN SINH CÁC NGƯƠI DÁM LẬP BÀN MÔN GIÀNH ĐỊA BÀN?!"
	elif e.enemy_id == "tuyet_ma_thien_vien_boss":
		cry = "GÀO Ồ!! TUYẾT MA HỐNG ĐỘNG SƠN HÀ — ĐỂ LẠI ĐỊA TÂM TÔI THỂ NHŨ!!"
	elif e.enemy_id == "lieu_kinh_boss":
		cry = "HA HA HA! THỐNG KHOÁI — TIẾP CHIÊU ĐẠI LIỆT PHÁCH QUAN TRẢO TOÀN LỰC CỦA TA!!"
	elif e.enemy_id == "van_lac_tam_viem_boss":
		cry = "VÔ HÌNH TÂM HỎA PHẦN THÂN — ĐẠI XÀ NUỐT CHỬNG BẢN NGUYÊN DỊ HỎA!!"
	elif e.enemy_id == "han_phong_boss":
		cry = "HẢI TÂM DIỄM (#15) THỦY HỎA SONG TUYỆT — SƯ ĐỆ NGỐC, CHẾT THEO LÃO BẤT TỬ ĐI!!"
	elif e.enemy_id == "van_son_boss":
		cry = "PHONG CHI CỰC: VẪN SÁT!! TIÊU VIÊM — DÙ NGƯƠI LÊN ĐẤU HOÀNG CŨNG ĐỪNG HÒNG THOÁT KHỎI ĐỈNH VÂN LAM SƠN!!"
	elif e.enemy_id == "vu_ho_phap_boss":
		cry = "KHÀ KHÀ KHÀ!! THIẾT TỎA HỒN XÍCH — LINH HỒN DƯỢC TRẦN HÔM NAY PHẢI THEO HỒN ĐIỆN TA!!"
	elif e.enemy_id == "nhan_lac_thien_boss":
		cry = "KIM NHẠN LẠC NHẬT TRẢM!! ĐẾ QUỐC VIÊM MINH MỚI LẬP MÀ DÁM CẢN ĐƯỜNG KIM NHẠN TÔNG TA?!"
	elif e.enemy_id == "hat_tat_nham_boss":
		cry = "VẠN HẠT ĐỘC PHÁP THÂN!! DÙ TA CÓ CHẾT CŨNG ẤN [MA ĐỘC BAN] LÊN NGỰC NGƯƠI!!"
	elif e.enemy_id == "han_phong_dau_tong_boss":
		cry = "TA ĐÃ ĐOẠT XÁ LÊN ĐẤU TÔNG RỒI!! HẢI TÂM TÀ HỎA & HỒN VỤ SẼ THIÊU CHÁY XÁC NGƯƠI!!"
	elif e.enemy_id == "dia_ma_lao_quy_boss":
		cry = "CỬU U HÀN BĂNG KHÔNG GIAN!! ĐẤU TÔNG THẤT TINH RA TAY — ĐỂ LẠI BỒ ĐỀ HÓA THỂ TIÊN!!"
	elif e.enemy_id == "phi_thien_boss":
		cry = "TAM THIÊN LÔI ĐỘNG LÀ BÍ HỌC BẮC CÁC!! ĐỂ LẠI BÍ TỊCH TRƯỚC LÔI NGỤC CỦA THIÊN LÔI TỬ!!"
	elif e.enemy_id == "vuong_tran_boss":
		cry = "HOÀNG TUYỀN HUYẾT SÁT!! SUẤT NGÂM THIÊN SƠN HUYẾT ĐÀM NÀY THUỘC VỀ HOÀNG TUYỀN CÁC!!"
	elif e.enemy_id == "phuong_thanh_nhi_boss":
		cry = "YÊU HOÀNG LÔI DỰC — PHONG LÔI CỰC PHÁ!! TIÊU VIÊM, ĐỪNG MƠ BƯỚC XUỐNG KHỎI LÔI SƠN!!"
	elif e.enemy_id == "bang_ha_thanh_hai_boss":
		cry = "BĂNG HÀ ĐÓNG BĂNG VẠN DẶM × HỒN ĐIỆN TỎA HỒN!! NỘP ÁCH NAN ĐỘC THỂ & LINH HỒN RA ĐÂY!!"
	elif e.enemy_id == "cuu_long_loi_cuong_boss":
		cry = "GÀO Ồ!! CỬU LONG LÔI CƯƠNG (#12) NGÂN LONG PHẦN THIÊN — ĐÓN TRỌN 10 HIỆP KHẢO NGHIỆM!!"
	elif e.enemy_id == "mo_cot_lao_nhan_boss":
		cry = "KHÀ KHÀ KHÀ!! TIỂU SÚC SINH ĐỆ TỬ CỦA DƯỢC TRẦN — #9 TAM THIÊN DIỄM VIÊM HỎA LÀ CỦA HỒN ĐIỆN!!"
	elif e.enemy_id == "tam_thien_diem_viem_boss":
		cry = "RỐNG NGÂN HÀ!! BẢN TÔN THÁI HƯ TỬ HẮC CỰ LONG (#9) BẤT TỬ BẤT DIỆT — THIÊU RỤI TINH VỰC!!"
	elif e.enemy_id == "trich_tinh_lao_quy_boss":
		cry = "KHÔNG GIAN ĐÔNG CỨNG — TRÍCH TINH THỦ!! HÔM NAY TẤT CẢ CÁC NGƯƠI PHẢI CHÔN XÁC TẠI VONG HỒN ĐIỆN!!"
	elif e.enemy_id == "hac_bach_thien_ton_boss":
		cry = "HẮC BẠCH ÂM DƯƠNG TỎA HỒN!! PHÁ NÁT TINH THẦN ĐẠI TRẬN SAN PHẲNG TINH VẪN CÁC!!"
	elif e.enemy_id == "yeu_hoa_ta_quan_boss":
		cry = "VẠN HOA GIÁP × YÊU HOA TÀ THÍCH!! NHÃI RANH NHẤT TINH ĐẤU TÔN MÀ DÁM CẢN CHUYỆN HOA TÔNG?!"
	elif e.enemy_id == "tan_hon_tao_hoa_boss":
		cry = "TÀN HỒN TẠO HÓA THÁNH GIẢ THỨC TỈNH!! ĐẠI THIÊN TẠO HÓA CHƯỞNG — HỦY DIỆT KẺ TRỘM THÁNH CỐT!!"
	elif e.enemy_id == "bac_long_vuong_boss":
		cry = "GÀO Ồ!! HUYẾT MA CỔ LONG — THÔN LONG HẮC ĐỘNG!! ĐÔNG LONG ĐẢO & LONG HOÀNG HÔM NAY PHẢI THUỘC VỀ TA!!"
	elif e.enemy_id == "co_yeu_do_thong_boss":
		cry = "THIÊN GIAI SƠ CẤP: ĐẠI TỊCH DIỆT CHỈ!! CHO NGƯƠI THẤY KHOẢNG CÁCH GIỮA CỔ TỘC VÀ PHẾ TỘC!!"
	elif e.enemy_id == "huyet_dao_thanh_gia_boss":
		cry = "NHỊ TINH ĐẤU THÁNH — NHẤT ĐAO TRẢM THIÊN MỘ!! HÃY CHỨNG MINH NGƯƠI XỨNG ĐÁNG GẶP TIÊU HUYỀN!!"

	EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -108), "GIAI ĐOẠN II — CUỒNG BẠO!", Color("#FF4D6D"))
	EventBus.shockwave_requested.emit(e.global_position, 290.0, 0.048, get_signature_color(e.enemy_id), 0.38)
	EventBus.screen_flash_requested.emit(get_signature_color(e.enemy_id), 0.20, 0.16)
	EventBus.banter_triggered.emit("[%s]: '%s' (Cẩn thận 3 tia sóng Đấu Khí — bấm Space để lướt né!)" % [e.display_title, cry])
	EventBus.boss_status_updated.emit(e.display_title, e.realm_badge, e.cur_hp, e.max_hp, e.boss_phase, true)
	if e.boss_bar_shown:
		EventBus.boss_poise_updated.emit(e.cur_poise, e.max_poise, e.poise_stagger_timer > 0.0, e.is_phase2_warning())


static func execute_boss_signature_skill(e, player_node: Node2D) -> void:
	var sig_col: Color = get_signature_color(e.enemy_id)
	var origin: Vector2 = e.global_position + Vector2(0, -20)
	var to_p: Vector2 = (player_node.global_position - e.global_position).normalized()
	if to_p == Vector2.ZERO:
		to_p = Vector2.RIGHT
	var p2: bool = (e.boss_phase >= 2)

	if e.enemy_id == "tieu_ninh_boss":
		# PHONG QUYỂN TÀN VÂN: Lốc gió kéo nhẹ + 4 tia phong nhận xoay!
		EventBus.audio_sfx_requested.emit("dash_whoosh")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "PHONG QUYỂN TÀN VÂN!", sig_col)
		e._spawn_boss_hazard(player_node.global_position, "vortex", 84.0, 0.55, 1.8, e.atk_stat * 0.95, sig_col, 0.0, 0.0, 95.0)
		var cnt: int = 5 if p2 else 3
		for i in range(cnt):
			var off: float = (float(i) - float(cnt - 1) * 0.5) * 0.24
			e._spawn_boss_projectile(origin, to_p.rotated(off), 385.0, e.atk_stat * 1.05, sig_col, "wave")

	elif e.enemy_id == "tieu_ngoc_boss":
		# SONG TIÊN LIÊN KÍCH: Đánh roi tốc độ cực cao + nhảy né vòng!
		EventBus.audio_sfx_requested.emit("swing_blade")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "SONG TIÊN PHÁ PHONG!", Color("#FF4D6D"))
		var whip_cnt: int = 4 if p2 else 2
		for i in range(whip_cnt):
			var off: float = (float(i) - float(whip_cnt - 1) * 0.5) * 0.20
			e._spawn_boss_projectile(origin, to_p.rotated(off), 430.0, e.atk_stat * 1.0, Color("#FF4D6D"), "spear")
		e.knockback_vel = Vector2(-to_p.y, to_p.x) * e.strafe_sign * 260.0

	elif e.enemy_id == "lieu_tich_boss":
		# ĐỘC HỎA DƯỢC ĐỈNH: Ném 2-3 vũng độc hỏa xanh cháy lâu trên sàn!
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "ĐỘC HỎA ĐỈNH TRÌ!", Color("#52B788"))
		e._spawn_boss_hazard(player_node.global_position, "pool", 78.0, 0.65, 3.6, e.atk_stat * 1.15, Color("#52B788"))
		if p2:
			e._spawn_boss_hazard(player_node.global_position + Vector2(110, 0).rotated(randf() * TAU), "pool", 72.0, 0.72, 3.6, e.atk_stat * 1.10, Color("#52B788"))
			for i in range(4):
				var ang: float = to_p.angle() + (float(i) - 1.5) * 0.24
				e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 330.0, e.atk_stat * 1.0, Color("#52B788"), "orb")

	elif e.enemy_id == "gia_liet_ao_boss":
		# HUYẾT CHIẾN THẬP TỰ ĐAO: Phóng đao khí chữ thập 4 hướng (8 hướng ở Phase 2)!
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "HUYẾT ĐAO THẬP TỰ TRẢM!", Color("#FF4D6D"))
		var rays: int = 8 if p2 else 4
		e.spiral_angle_offset += 0.39
		for i in range(rays):
			var ang: float = e.spiral_angle_offset + float(i) * (TAU / float(rays))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 360.0, e.atk_stat * 1.18, Color("#FF4D6D"), "wave")

	elif e.enemy_id == "thach_khoi_boss":
		# THẠCH GIÁP HỘ THUẪN + ĐỊA CHẤN ĐÁ LĂN!
		EventBus.audio_sfx_requested.emit("skill_burst")
		if e.boss_shield_hp <= 0.0:
			e._activate_boss_shield(0.18, 6.5, "THẠCH GIÁP HỘ THUẪN!", Color("#4CC9F0"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "ĐỊA CHẤN THẠCH BẠO!", Color("#4CC9F0"))
		var stones: int = 8 if p2 else 6
		for i in range(stones):
			var ang: float = float(i) * (TAU / float(stones)) + to_p.angle()
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 290.0, e.atk_stat * 1.15, Color("#4CC9F0"), "boulder")

	elif e.enemy_id == "tieu_tu_tinh_su_boss":
		# TỬ TINH HỎA CẦU (RƯỢT NHẸ) + SƯ VƯƠNG CUỒNG HỐNG!
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "TỬ TINH HỎA CẦU!", Color("#C77DFF"))
		var orbs: int = 4 if p2 else 3
		for i in range(orbs):
			var off: float = (float(i) - float(orbs - 1) * 0.5) * 0.42
			e._spawn_boss_projectile(origin, to_p.rotated(off), 275.0, e.atk_stat * 1.15, Color("#C77DFF"), "orb", 0.0, 0.0, 2.2)
		if p2:
			e._spawn_boss_hazard(player_node.global_position, "pillar", 96.0, 0.78, 0.45, e.atk_stat * 1.40, Color("#C77DFF"))

	elif e.enemy_id == "muc_luc_boss":
		# LANG NHA LIÊN THƯƠNG: Loạt thương khí sắc bén lao cực nhanh!
		EventBus.audio_sfx_requested.emit("swing_blade")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "LANG NHA LIÊN THƯƠNG!", Color("#FF758F"))
		var sp_cnt: int = 5 if p2 else 3
		for i in range(sp_cnt):
			var off: float = (float(i) - float(sp_cnt - 1) * 0.5) * 0.16
			e._spawn_boss_projectile(origin, to_p.rotated(off), 455.0, e.atk_stat * 1.12, Color("#FF758F"), "spear")

	elif e.enemy_id == "muc_xa_boss":
		# LANG ĐẦU ĐẠI TRẬN: Quạt 5 tia + 2 trụ xung kích khóa góc (Phase 2 nổ 8 tia xoắn ốc)!
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "LANG ĐẦU ĐẠI TRẬN!", Color("#C77DFF"))
		var fan: int = 7 if p2 else 5
		for i in range(fan):
			var off: float = (float(i) - float(fan - 1) * 0.5) * 0.22
			e._spawn_boss_projectile(origin, to_p.rotated(off), 375.0, e.atk_stat * 1.15, Color("#C77DFF"), "wave")
		e._spawn_boss_hazard(player_node.global_position, "pillar", 86.0, 0.80, 0.40, e.atk_stat * 1.35, Color("#C77DFF"))
		if p2:
			e._spawn_boss_hazard(player_node.global_position + to_p * 95.0, "pillar", 82.0, 0.95, 0.40, e.atk_stat * 1.35, Color("#FF4D6D"))

	elif e.enemy_id == "hai_ba_dong_boss":
		# HÀN BĂNG NGƯNG LONG: Khiên Hàn Băng + Băng Tiễn Làm Chậm + 2-3 Băng Trụ!
		EventBus.audio_sfx_requested.emit("skill_stun")
		if e.boss_shield_hp <= 0.0 and randf() < 0.55:
			e._activate_boss_shield(0.16, 6.0, "HÀN BĂNG HỘ THUẪN!", Color("#70D6FF"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "HÀN BĂNG NGƯNG LONG!", Color("#70D6FF"))
		var ice_cnt: int = 6 if p2 else 4
		e.spiral_angle_offset += 0.45
		for i in range(ice_cnt):
			var ang: float = to_p.angle() + (float(i) - float(ice_cnt - 1) * 0.5) * 0.28 if not p2 else e.spiral_angle_offset + float(i) * (TAU / 6.0)
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 350.0, e.atk_stat * 1.12, Color("#70D6FF"), "spear", 0.38, 2.2)
		var pillar_cnt: int = 3 if p2 else 2
		for pi in range(pillar_cnt):
			var offset_p: Vector2 = Vector2.ZERO if pi == 0 else Vector2(randf_range(-115, 115), randf_range(-95, 95))
			e._spawn_boss_hazard(player_node.global_position + offset_p, "pillar", 78.0, 0.82 + float(pi) * 0.14, 0.45, e.atk_stat * 1.25, Color("#70D6FF"), 0.42, 2.4)

	elif e.enemy_id == "hoa_linh_xa_boss":
		# SONG ĐẦU DUNG NHAM: Phóng song tuyến nham thạch từ 2 đầu rắn + tạo Hồ Dung Nham!
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "SONG ĐẦU PHUN DUNG NHAM!", Color("#FF7B00"))
		var perp: Vector2 = Vector2(-to_p.y, to_p.x)
		for side in [-1.0, 1.0]:
			var head_pos: Vector2 = origin + perp * (side * 28.0)
			e._spawn_boss_projectile(head_pos, to_p.rotated(-side * 0.08), 385.0, e.atk_stat * 1.15, Color("#FF7B00"), "orb")
			e._spawn_boss_projectile(head_pos, to_p.rotated(side * 0.22), 340.0, e.atk_stat * 1.08, Color("#FF4D6D"), "orb")
		e._spawn_boss_hazard(player_node.global_position, "pool", 92.0, 0.70, 4.0, e.atk_stat * 1.25, Color("#FF7B00"))
		if p2:
			for k in range(8):
				var ang: float = float(k) * (TAU / 8.0)
				e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 310.0, e.atk_stat * 1.10, Color("#FF7B00"), "orb")

	elif e.enemy_id == "mac_ba_tu_boss":
		# XÀ NHÂN BÃO CÁT & ĐỘC MÂU: Lốc cát hút tâm + 5 mũi độc mâu!
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "BÃO CÁT XÀ VỰC & ĐỘC MÂU!", Color("#52B788"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 104.0, 0.60, 2.8, e.atk_stat * 1.15, Color("#FFD166"), 0.0, 0.0, 125.0)
		var spears: int = 5 if p2 else 3
		for i in range(spears):
			var off: float = (float(i) - float(spears - 1) * 0.5) * 0.18
			e._spawn_boss_projectile(origin, to_p.rotated(off), 430.0, e.atk_stat * 1.12, Color("#52B788"), "spear")

	elif e.enemy_id == "co_ha_boss":
		# LỤC PHẨM ĐAN VƯƠNG HỎA: Khiên Đan Hỏa + 3-4 Cột Thiên Hỏa Đan Lô + Vòng 8 Cầu Lửa ở Phase 2!
		EventBus.audio_sfx_requested.emit("breakthrough")
		if e.boss_shield_hp <= 0.0 and randf() < 0.50:
			e._activate_boss_shield(0.18, 6.0, "LỤC PHẨM HỎA THUẪN!", Color("#FFD166"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "ĐAN VƯƠNG THIÊN HỎA TRỤ!", Color("#FF9F1C"))
		var pillars: int = 4 if p2 else 3
		for pi in range(pillars):
			var spread_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(float(pi) * 2.1), sin(float(pi) * 2.1)) * 105.0
			e._spawn_boss_hazard(player_node.global_position + spread_off, "pillar", 86.0, 0.80 + float(pi) * 0.16, 0.45, e.atk_stat * 1.35, Color("#FF9F1C"))
		if p2:
			e.spiral_angle_offset += 0.32
			for k in range(8):
				var ang: float = e.spiral_angle_offset + float(k) * (TAU / 8.0)
				e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 325.0, e.atk_stat * 1.12, Color("#FFD166"), "orb")

	# =========================================================
	# 7 BOSS ĐỘC QUYỀN CHƯƠNG 04 (ĐẾ ĐÔ & VÂN LAM SƠN)
	# =========================================================
	elif e.enemy_id == "mac_thua_boss":
		# QUÁI NHÂN MẶC THỪA: Không Gian Vặn Vẹo (hố đen hút tâm!) + Khiên Thú Hóa + 6 tia vuốt dị biến!
		EventBus.audio_sfx_requested.emit("boss_roar")
		if p2 and e.boss_shield_hp <= 0.0 and randf() < 0.55:
			e._activate_boss_shield(0.18, 6.0, "THÚ HÓA VẢY MA THÚ!", Color("#9D4EDD"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "KHÔNG GIAN VẶN VẸO!", Color("#9D4EDD"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 118.0, 0.55, 3.0, e.atk_stat * 1.18, Color("#9D4EDD"), 0.0, 0.0, 155.0)
		var claws: int = 7 if p2 else 5
		for i in range(claws):
			var off: float = (float(i) - float(claws - 1) * 0.5) * 0.22
			e._spawn_boss_projectile(origin, to_p.rotated(off), 395.0, e.atk_stat * 1.12, Color("#C77DFF"), "wave")

	elif e.enemy_id == "moc_chien_boss":
		# THIẾU GIA MỘC CHIẾN: Thanh Mộc Cự Phủ Trảm — Bổ nứt đất + 6 tảng địa chấn!
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "THANH MỘC CỰ PHỦ TRẢM!", Color("#52B788"))
		e._spawn_boss_hazard(player_node.global_position, "pillar", 98.0, 0.78, 0.45, e.atk_stat * 1.38, Color("#52B788"))
		var rocks: int = 8 if p2 else 5
		for i in range(rocks):
			var off: float = (float(i) - float(rocks - 1) * 0.5) * 0.28
			e._spawn_boss_projectile(origin, to_p.rotated(off), 305.0, e.atk_stat * 1.15, Color("#52B788"), "boulder")

	elif e.enemy_id == "viem_loi_boss":
		# VIÊM LỢI (XUẤT VÂN): Tà Hỏa Chấn Đỉnh — 2 vũng tà độc hỏa + 6-8 cầu tà hỏa xoay!
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "TÀ HỎA CHẤN ĐỈNH!", Color("#80ED99"))
		e._spawn_boss_hazard(player_node.global_position, "pool", 90.0, 0.65, 4.0, e.atk_stat * 1.22, Color("#52B788"))
		if p2:
			e._spawn_boss_hazard(player_node.global_position + to_p * 110.0, "pool", 82.0, 0.72, 4.0, e.atk_stat * 1.18, Color("#9D4EDD"))
		e.spiral_angle_offset += 0.35
		var t_orbs: int = 8 if p2 else 6
		for k in range(t_orbs):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(t_orbs))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 330.0, e.atk_stat * 1.12, Color("#52B788"), "orb")

	elif e.enemy_id == "nap_lan_yen_nhien_boss":
		# NẠP LAN YÊN NHIÊN (ƯỚC HẸN 3 NĂM): Phase 1 Phong Linh Phân Hình Kiếm | Phase 2 PHONG CHI CỰC: LẠC NHẬT DIỆU!
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "swing_blade")
		if p2:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -104), "PHONG CHI CỰC: LẠC NHẬT DIỆU!!", Color("#FFD166"))
			e._spawn_boss_hazard(player_node.global_position, "pillar", 126.0, 0.92, 0.55, e.atk_stat * 1.50, Color("#FFD166"))
			e.spiral_angle_offset += 0.25
			for k in range(8):
				var ang: float = e.spiral_angle_offset + float(k) * (TAU / 8.0)
				e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 430.0, e.atk_stat * 1.15, Color("#70D6FF"), "spear")
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -98), "PHONG LINH PHÂN HÌNH KIẾM!", Color("#70D6FF"))
			for i in range(5):
				var off: float = (float(i) - 2.0) * 0.19
				e._spawn_boss_projectile(origin, to_p.rotated(off), 455.0, e.atk_stat * 1.12, Color("#70D6FF"), "spear")
			e.knockback_vel = Vector2(-to_p.y, to_p.x) * e.strafe_sign * 280.0

	elif e.enemy_id == "van_yen_dai_tran_boss":
		# VÂN YÊN PHÚC NHẬT ĐẠI TRẬN: Khiên Đại Trận + Xoáy Kiếm Mây Trắng + 4 Trụ Cự Kiếm!
		EventBus.audio_sfx_requested.emit("skill_stun")
		if e.boss_shield_hp <= 0.0 and randf() < 0.60:
			e._activate_boss_shield(0.20, 6.5, "VÂN YÊN HỘ SƠN ĐẠI TRẬN!", Color("#A8DADC"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -100), "VÂN YÊN PHÚC NHẬT KIẾM TRẬN!", Color("#70D6FF"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 96.0, 0.55, 2.4, e.atk_stat * 1.10, Color("#A8DADC"), 0.25, 1.5, 110.0)
		var sw_cnt: int = 4 if p2 else 3
		for pi in range(sw_cnt):
			var ang_p: float = float(pi) * (TAU / float(sw_cnt)) + e.spiral_angle_offset
			e._spawn_boss_hazard(player_node.global_position + Vector2(cos(ang_p), sin(ang_p)) * 115.0, "pillar", 76.0, 0.85, 0.45, e.atk_stat * 1.32, Color("#70D6FF"))
		e.spiral_angle_offset += 0.50

	elif e.enemy_id == "van_lang_boss":
		# ĐẠI TRƯỞNG LÃO VÂN LĂNG + ĐẤU TÔNG VÂN SƠN CAN THIỆP (KHÔNG GIAN ĐẠI THỦ ẤN!)
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -104), "VÂN SƠN VẠN KIẾM & KHÔNG GIAN ĐẠI THỦ ẤN!", Color("#C77DFF"))
		# Không Gian Đại Thủ Ấn của Đấu Tông Vân Sơn giáng xuống vị trí người chơi!
		e._spawn_boss_hazard(player_node.global_position, "pillar", 128.0, 0.95, 0.55, e.atk_stat * 1.48, Color("#9D4EDD"), 0.52, 2.4)
		var swords: int = 8 if p2 else 6
		for i in range(swords):
			var off: float = (float(i) - float(swords - 1) * 0.5) * 0.20
			e._spawn_boss_projectile(origin, to_p.rotated(off), 440.0, e.atk_stat * 1.15, Color("#70D6FF"), "spear")

	elif e.enemy_id == "van_son_phan_than_boss":
		# ĐẤU TÔNG VÂN SƠN (HƯ ẢNH KHÔNG GIAN): Không Gian Phong Tỏa + 2 Đại Thủ Ấn + 8 Trăng Khuyết Không Gian!
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -106), "ĐẤU TÔNG: KHÔNG GIAN PHONG TỎA!!", Color("#9D4EDD"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 118.0, 0.55, 2.6, e.atk_stat * 1.20, Color("#9D4EDD"), 0.42, 2.0, 145.0)
		e._spawn_boss_hazard(player_node.global_position + to_p * 85.0, "pillar", 118.0, 0.90, 0.50, e.atk_stat * 1.48, Color("#C77DFF"), 0.50, 2.2)
		e.spiral_angle_offset += 0.30
		var crescents: int = 10 if p2 else 8
		for k in range(crescents):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(crescents))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 410.0, e.atk_stat * 1.18, Color("#C77DFF"), "wave")

	# =========================================================
	# 4 BOSS ĐỘC QUYỀN CHƯƠNG 05 (HẮC GIÁC VỰC & GIÀ NAM HỌC VIỆN)
	# =========================================================
	elif e.enemy_id == "van_phan_boss":
		# TRƯỞNG LÃO VÂN PHÀN (PHONG LÔI): Quạt 5 phong kiếm "wave" + Lao đâm tốc độ cao; P2 tạo 2 lốc xoáy hút mạnh!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("dash_whoosh")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -104), "PHONG LÔI NHẤT KIẾM!", Color("#70D6FF"))
		for i in range(5):
			var off: float = (float(i) - 2.0) * 0.19
			e._spawn_boss_projectile(origin, to_p.rotated(off), 435.0, eff_atk * 1.15, Color("#70D6FF"), "wave")
		if p2:
			var perp_vp: Vector2 = Vector2(-to_p.y, to_p.x)
			e._spawn_boss_hazard(player_node.global_position + perp_vp * 96.0, "vortex", 94.0, 0.55, 2.6, eff_atk * 1.14, Color("#70D6FF"), 0.0, 0.0, 160.0)
			e._spawn_boss_hazard(player_node.global_position - perp_vp * 96.0, "vortex", 94.0, 0.55, 2.6, eff_atk * 1.14, Color("#70D6FF"), 0.0, 0.0, 160.0)
		# Lao xuyên tốc độ cao (high-speed piercing lunge)
		e.charge_dir = to_p
		e.state_phase = "charging"
		e.state_duration = 0.36
		e.state_timer = e.state_duration
		e.afterimage_timer = 0.0
		e.attack_cd = 0.0
		if absf(e.charge_dir.x) > 0.08:
			e.body_sprite.flip_h = e.charge_dir.x < 0.0

	elif e.enemy_id == "pham_lang_boss":
		# THIẾU TÔNG CHỦ HUYẾT TÔNG PHẠM LĂNG: 3 huyết đao rượt đuổi + Vũng Huyết Trì; P2 hấp huyết tạo khiên + xoáy kéo!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar" if p2 else "skill_fire")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -104), "PHỆ HUYẾT TUYỀN QUA!", Color("#EF476F"))
		for i in range(3):
			var off: float = (float(i) - 1.0) * 0.34
			e._spawn_boss_projectile(origin, to_p.rotated(off), 335.0, eff_atk * 1.16, Color("#EF476F"), "wave", 0.0, 0.0, 2.4)
		e._spawn_boss_hazard(player_node.global_position, "pool", 88.0, 0.62, 3.6, eff_atk * 1.20, Color("#EF476F"))
		if p2:
			e._spawn_boss_hazard(player_node.global_position + to_p * 105.0, "pool", 78.0, 0.72, 3.4, eff_atk * 1.15, Color("#EF476F"))
			if e.boss_shield_hp <= 0.0:
				e._activate_boss_shield(0.18, 6.0, "HUYẾT VỤ HỘ THỂ!", Color("#EF476F"))
			else:
				e.boss_shield_hp = maxf(e.boss_shield_hp, e.max_hp * 0.14)
				e.boss_shield_timer = maxf(e.boss_shield_timer, 5.0)
			var vortex_dist: float = minf(110.0, e.global_position.distance_to(player_node.global_position) * 0.72)
			e._spawn_boss_hazard(e.global_position + to_p * vortex_dist, "vortex", 116.0, 0.50, 2.6, eff_atk * 1.15, Color("#EF476F"), 0.22, 1.6, 155.0)

	elif e.enemy_id == "ngo_hao_boss":
		# TU LA HUYẾT KIẾM NGÔ HẠO (CUỒNG BẠO): Song trảm lao cực nhanh + Sóng xung kích chữ thập đỏ máu!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -104), "HUYẾT TRẢM THẬP TỰ!", Color("#FF2A5F"))
		var perp_nh: Vector2 = Vector2(-to_p.y, to_p.x)
		var cross_center: Vector2 = player_node.global_position
		e._spawn_boss_hazard(cross_center, "pillar", 66.0, 0.66, 0.38, eff_atk * 1.32, Color("#FF2A5F"))
		var cross_dirs: Array[Vector2] = [to_p, -to_p, perp_nh, -perp_nh]
		for cd in cross_dirs:
			e._spawn_boss_hazard(cross_center + cd * 84.0, "pillar", 62.0, 0.76, 0.38, eff_atk * 1.24, Color("#FF2A5F"))
		# Song trảm liên hoàn (rapid double dash slash)
		e.charge_dir = to_p
		e.state_phase = "charging"
		e.state_duration = 0.28
		e.state_timer = e.state_duration
		e.boss_combo_dashes_left = 1
		e.afterimage_timer = 0.0
		e.attack_cd = 0.0
		if absf(e.charge_dir.x) > 0.08:
			e.body_sprite.flip_h = e.charge_dir.x < 0.0

	elif e.enemy_id == "la_hau_boss":
		# THỦ LĨNH HẮC BẠCH QUAN SÁT LA HẦU: P1 Phá Thạch Ám Kình (3 ám thương + ẩn ảnh sau lưng) | P2 U Minh Liệt Địa Ấn!
		var eff_atk: float = e._get_effective_atk()
		# Ẩn ảnh tức thời ra sau lưng người chơi (an toàn không xuyên tường)
		e._spawn_afterimage()
		VfxAssets.spawn_spark_burst(e.get_parent(), e.global_position + Vector2(0, -24), Color("#FFFFFF"), Color("#9D4EDD"), 14, 70.0, 180.0, 0.30, Vector2.UP, 180.0, 0.26, 0.52, true)
		var behind_pos: Vector2 = player_node.global_position + to_p * 96.0
		var blink_delta: Vector2 = behind_pos - e.global_position
		if not e.test_move(e.global_transform, blink_delta):
			e.global_position = behind_pos
			e.reset_physics_interpolation()
		else:
			var alt_pos: Vector2 = player_node.global_position - to_p * 74.0
			if not e.test_move(e.global_transform, alt_pos - e.global_position):
				e.global_position = alt_pos
				e.reset_physics_interpolation()
		VfxAssets.spawn_spark_burst(e.get_parent(), e.global_position + Vector2(0, -24), Color("#FFD166"), Color("#9D4EDD"), 16, 80.0, 200.0, 0.32, Vector2.UP, 180.0, 0.28, 0.56, true)
		var post_to_p: Vector2 = (player_node.global_position - e.global_position).normalized()
		if post_to_p == Vector2.ZERO:
			post_to_p = -to_p
		e.wave_aim_dir = post_to_p
		if absf(post_to_p.x) > 0.08:
			e.body_sprite.flip_h = post_to_p.x < 0.0
		var post_origin: Vector2 = e.global_position + Vector2(0, -20)

		if p2:
			EventBus.audio_sfx_requested.emit("breakthrough")
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -108), "U MINH LIỆT ĐỊA ẤN!!", Color("#FFD166"))
			for pi in range(4):
				var p_ang: float = float(pi) * (TAU * 0.25) + e.spiral_angle_offset
				var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(p_ang), sin(p_ang)) * (72.0 + float(pi) * 26.0)
				e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 88.0, 0.72 + float(pi) * 0.16, 0.45, eff_atk * 1.44, Color("#E09F3E"))
			e.spiral_angle_offset += 0.38
			for k in range(8):
				var orb_ang: float = e.spiral_angle_offset + float(k) * (TAU / 8.0)
				var orb_col: Color = Color("#FFD166") if (k % 2 == 0) else Color("#9D4EDD")
				e._spawn_boss_projectile(post_origin, Vector2(cos(orb_ang), sin(orb_ang)), 335.0, eff_atk * 1.15, orb_col, "orb")
		else:
			EventBus.audio_sfx_requested.emit("swing_blade")
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -104), "PHÁ THẠCH ÁM KÌNH!", Color("#9D4EDD"))
			for i in range(3):
				var off: float = (float(i) - 1.0) * 0.19
				e._spawn_boss_projectile(post_origin, post_to_p.rotated(off), 450.0, eff_atk * 1.18, Color("#9D4EDD"), "spear")

	# =========================================================
	# 5 BOSS ĐỘC QUYỀN CHƯƠNG 06 (NỘI VIỆN GIÀ NAM & ĐÁY THÁP THIÊN PHẦN)
	# =========================================================
	elif e.enemy_id == "bach_thanh_boss":
		# THỦ LĨNH BẠCH BANG BẠCH THÀNH: Quạt 5-7 đao khí sương trắng + Lao chém chớp nhoáng để lại trụ băng làm chậm!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("swing_blade")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -104), "BẠCH SƯƠNG ĐAO MẠNG!", Color("#90E0EF"))
		var w_cnt: int = 7 if p2 else 5
		for i in range(w_cnt):
			var off: float = (float(i) - float(w_cnt - 1) * 0.5) * 0.17
			e._spawn_boss_projectile(origin, to_p.rotated(off), 445.0, eff_atk * 1.15, Color("#90E0EF"), "wave", 0.25, 1.5)
		e._spawn_boss_hazard(player_node.global_position, "pillar", 80.0, 0.72, 0.42, eff_atk * 1.26, Color("#90E0EF"), 0.30, 1.8)
		e.charge_dir = to_p
		e.state_phase = "charging"
		e.state_duration = 0.32
		e.state_timer = e.state_duration
		e.boss_combo_dashes_left = 1 if p2 else 0
		e.afterimage_timer = 0.0
		e.attack_cd = 0.0
		if absf(e.charge_dir.x) > 0.08:
			e.body_sprite.flip_h = e.charge_dir.x < 0.0

	elif e.enemy_id == "tuyet_ma_thien_vien_boss":
		# TUYẾT MA THIÊN VIÊN (MA THÚ CẤP 5 ĐỈNH PHONG): Khiên Băng Giáp + Mưa Trụ Băng Thạch + 5-7 Tảng Đá Băng!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.45):
			e._activate_boss_shield(0.18, 6.0, "TUYẾT MA BĂNG GIÁP!", Color("#72EFDD"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -106), "TUYẾT MA BĂNG THẠCH TRỤY!", Color("#72EFDD"))
		var p_cnt: int = 4 if p2 else 3
		for pi in range(p_cnt):
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(float(pi) * 2.1 + e.spiral_angle_offset), sin(float(pi) * 2.1 + e.spiral_angle_offset)) * 112.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 92.0, 0.78 + float(pi) * 0.14, 0.45, eff_atk * 1.38, Color("#72EFDD"), 0.40, 2.4)
		e.spiral_angle_offset += 0.45
		var b_cnt: int = 7 if p2 else 5
		for i in range(b_cnt):
			var off: float = (float(i) - float(b_cnt - 1) * 0.5) * 0.24
			e._spawn_boss_projectile(origin, to_p.rotated(off), 325.0, eff_atk * 1.18, Color("#72EFDD"), "boulder", 0.35, 2.0)

	elif e.enemy_id == "lieu_kinh_boss":
		# BÁ THƯƠNG LIỄU KÌNH (CƯỜNG BẢNG #3): 5 Kim Thương xuyên thấu + 3 Trảo Ấn ĐẠI LIỆT PHÁCH QUAN + Song kích tốc biến!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_burst")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -108), "ĐẠI LIỆT PHÁCH QUAN TRẢO!!" if p2 else "BÁ THƯƠNG PHÁ QUÂN!", Color("#FFD166"))
		var sp_cnt: int = 7 if p2 else 5
		for i in range(sp_cnt):
			var off: float = (float(i) - float(sp_cnt - 1) * 0.5) * 0.16
			e._spawn_boss_projectile(origin, to_p.rotated(off), 470.0, eff_atk * 1.18, Color("#FFD166"), "spear")
		var c_cnt: int = 3 if p2 else 2
		for ci in range(c_cnt):
			var c_off: Vector2 = to_p * (float(ci) * 84.0)
			e._spawn_boss_hazard(player_node.global_position + c_off, "pillar", 96.0, 0.72 + float(ci) * 0.16, 0.44, eff_atk * 1.44, Color("#FFD166"))
		e.charge_dir = to_p
		e.state_phase = "charging"
		e.state_duration = 0.30
		e.state_timer = e.state_duration
		e.boss_combo_dashes_left = 1 if p2 else 0
		e.afterimage_timer = 0.0
		e.attack_cd = 0.0
		if absf(e.charge_dir.x) > 0.08:
			e.body_sprite.flip_h = e.charge_dir.x < 0.0

	elif e.enemy_id == "van_lac_tam_viem_boss":
		# BẢN THỂ ĐẠI XÀ VẪN LẠC TÂM VIÊM (#14): Xoáy Vô Hình Tâm Hỏa hút tâm + Hồ Dung Nham + Vòng 8-12 Cầu Tâm Hỏa xoay!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -110), "VÔ HÌNH TÂM HỎA — PHẦN HỒN LONG TỨC!!", Color("#E0AAFF"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 122.0, 0.55, 2.8, eff_atk * 1.24, Color("#E0AAFF"), 0.25, 1.6, 160.0)
		e._spawn_boss_hazard(player_node.global_position + to_p * 95.0, "pool", 92.0, 0.65, 4.2, eff_atk * 1.28, Color("#C77DFF"))
		if p2:
			e._spawn_boss_hazard(player_node.global_position - to_p * 95.0, "pool", 86.0, 0.72, 4.2, eff_atk * 1.22, Color("#FF4D6D"))
		e.spiral_angle_offset += 0.34
		var orb_cnt: int = 12 if p2 else 8
		for k in range(orb_cnt):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(orb_cnt))
			var col_o: Color = Color("#FFFFFF") if (k % 2 == 0) else Color("#E0AAFF")
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 355.0, eff_atk * 1.18, col_o, "orb")

	elif e.enemy_id == "han_phong_boss":
		# FINAL BOSS CH.06 — DƯỢC HOÀNG HÀN PHONG (HẢI TÂM DIỄM #15): Khiên Hải Tâm + Xoáy Thâm Hải + 3-5 Trụ Thủy Hỏa + 3 Hỏa Long rượt đuổi!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_fire")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.50):
			e._activate_boss_shield(0.20, 6.5, "HẢI TÂM DIỄM (#15) HỘ THUẪN!", Color("#00B4D8"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -110), "HẢI TÂM DIỄM — THÂM HẢI PHẦN THIÊN TRẬN!!", Color("#38BDF8"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 112.0, 0.52, 2.6, eff_atk * 1.22, Color("#00B4D8"), 0.32, 2.0, 150.0)
		var hp_cnt: int = 5 if p2 else 3
		for pi in range(hp_cnt):
			var ang_p: float = float(pi) * (TAU / float(hp_cnt)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 116.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 88.0, 0.74 + float(pi) * 0.14, 0.46, eff_atk * 1.46, Color("#00B4D8"), 0.35, 2.0)
		for hi in range(3):
			var h_off: float = (float(hi) - 1.0) * 0.42
			e._spawn_boss_projectile(origin, to_p.rotated(h_off), 345.0, eff_atk * 1.20, Color("#38BDF8"), "orb", 0.25, 1.6, 2.6)
		if p2:
			e.spiral_angle_offset += 0.36
			for k in range(8):
				var w_ang: float = e.spiral_angle_offset + float(k) * (TAU / 8.0)
				e._spawn_boss_projectile(origin, Vector2(cos(w_ang), sin(w_ang)), 405.0, eff_atk * 1.18, Color("#00B4D8"), "wave")

	# =========================================================
	# 6 BOSS ĐẤU TÔNG CHƯƠNG 07 (TAM THƯỢNG VÂN LAM & XUẤT VÂN ĐỘC TÔNG)
	# =========================================================
	elif e.enemy_id == "van_son_boss":
		# ĐẤU TÔNG VÂN SƠN THẬT: Không Gian Phong Tỏa + Phong Chi Cực: Vẫn Sát (Trụ Phong Lôi + 8–10 Lưỡi Gió Trắng)!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "boss_roar")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.48):
			e._activate_boss_shield(0.20, 6.2, "ĐẤU TÔNG PHONG CHI THUẪN!", Color("#72EFDD"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -110), "PHONG CHI CỰC: VẪN SÁT!!" if p2 else "KHÔNG GIAN PHONG TỎA!", Color("#72EFDD"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 120.0, 0.52, 2.6, eff_atk * 1.24, Color("#72EFDD"), 0.38, 2.0, 160.0)
		var vs_pillars: int = 4 if p2 else 2
		for pi in range(vs_pillars):
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(float(pi) * 2.0 + e.spiral_angle_offset), sin(float(pi) * 2.0 + e.spiral_angle_offset)) * 108.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.78 + float(pi) * 0.14, 0.48, eff_atk * 1.48, Color("#CAF0F8"))
		e.spiral_angle_offset += 0.34
		var blades: int = 10 if p2 else 7
		for k in range(blades):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(blades))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 435.0, eff_atk * 1.18, Color("#72EFDD"), "wave")

	elif e.enemy_id == "vu_ho_phap_boss":
		# VỤ HỘ PHÁP (HỒN ĐIỆN): Thiết Tỏa Hồn Xích — Xoáy Hắc Vụ kéo giam + 4 Trụ Tỏa Hồn + 5 Hồn Xích rượt đuổi!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -110), "HỒN ĐIỆN: THIẾT TỎA HỒN XÍCH!!", Color("#E63946"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 128.0, 0.50, 2.9, eff_atk * 1.26, Color("#9D4EDD"), 0.42, 2.2, 175.0)
		var chain_cnt: int = 5 if p2 else 3
		for ci in range(chain_cnt):
			var c_off: float = (float(ci) - float(chain_cnt - 1) * 0.5) * 0.30
			e._spawn_boss_projectile(origin, to_p.rotated(c_off), 375.0, eff_atk * 1.22, Color("#E63946"), "spear", 0.30, 1.8, 2.8)
		if p2:
			for pi in range(3):
				var p_off: Vector2 = Vector2(cos(float(pi) * 2.1 + e.spiral_angle_offset), sin(float(pi) * 2.1 + e.spiral_angle_offset)) * 100.0
				e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 86.0, 0.72 + float(pi) * 0.14, 0.44, eff_atk * 1.44, Color("#E63946"))
			e.spiral_angle_offset += 0.45

	elif e.enemy_id == "nhan_lac_thien_boss":
		# TÔNG CHỦ KIM NHẠN TÔNG NHẠN LẠC THIÊN: Kim Nhạn Lạc Nhật Trảm — Quạt 7–9 Vũ Tiễn Vàng + Song Kích Tốc Biến!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "swing_blade")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -108), "KIM NHẠN LẠC NHẬT TRẢM!!", Color("#FFD166"))
		var feath: int = 9 if p2 else 6
		for i in range(feath):
			var off: float = (float(i) - float(feath - 1) * 0.5) * 0.16
			e._spawn_boss_projectile(origin, to_p.rotated(off), 475.0, eff_atk * 1.18, Color("#FFD166"), "spear")
		e._spawn_boss_hazard(player_node.global_position + to_p * 60.0, "pillar", 104.0, 0.74, 0.46, eff_atk * 1.46, Color("#FF9F1C"))
		e.charge_dir = to_p
		e.state_phase = "charging"
		e.state_duration = 0.30
		e.state_timer = e.state_duration
		e.boss_combo_dashes_left = 1 if p2 else 0
		e.afterimage_timer = 0.0
		e.attack_cd = 0.0
		if absf(e.charge_dir.x) > 0.08:
			e.body_sprite.flip_h = e.charge_dir.x < 0.0

	elif e.enemy_id == "hat_tat_nham_boss":
		# LÃO TỔ VẠN HẠT MÔN HẠT TẤT NHAM: Vạn Hạt Độc Pháp Thân — 3 Vũng Kịch Độc + Khiên Độc Giáp + Vòng 10 Độc Cầu!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.50):
			e._activate_boss_shield(0.22, 6.5, "VẠN HẠT ĐỘC PHÁP THÂN!", Color("#70E000"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -108), "MA ĐỘC BẠO ĐỘNG — VẠN HẠT CHI VĨ!!", Color("#70E000"))
		e._spawn_boss_hazard(player_node.global_position, "pool", 98.0, 0.58, 4.4, eff_atk * 1.28, Color("#70E000"), 0.38, 2.2)
		if p2:
			e._spawn_boss_hazard(player_node.global_position + to_p * 110.0, "pool", 88.0, 0.68, 4.2, eff_atk * 1.24, Color("#9D4EDD"), 0.38, 2.2)
			e._spawn_boss_hazard(player_node.global_position - to_p * 110.0, "pool", 88.0, 0.68, 4.2, eff_atk * 1.24, Color("#70E000"), 0.38, 2.2)
		e.spiral_angle_offset += 0.32
		var p_orbs: int = 10 if p2 else 7
		for k in range(p_orbs):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(p_orbs))
			var col_p: Color = Color("#70E000") if (k % 2 == 0) else Color("#C77DFF")
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 350.0, eff_atk * 1.18, col_p, "orb", 0.30, 2.0)

	elif e.enemy_id == "han_phong_dau_tong_boss":
		# HÀN PHONG ĐOẠT XÁ ĐẤU TÔNG: Song Hệ Hải Tâm Diễm #15 + Hồn Vụ Hồn Điện! Khiên Kép + 4 Trụ Thâm Hải + 4 Long Cầu rượt đuổi!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_fire")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.52):
			e._activate_boss_shield(0.22, 6.5, "HẢI TÂM TÀ HỎA THUẪN!", Color("#38BDF8"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -110), "HẢI TÂM DIỄM × HỒN ĐIỆN TÀ VỤ!!", Color("#38BDF8"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 118.0, 0.50, 2.7, eff_atk * 1.26, Color("#38BDF8"), 0.35, 2.0, 165.0)
		var hf_p: int = 5 if p2 else 3
		for pi in range(hf_p):
			var ang_p: float = float(pi) * (TAU / float(hf_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 116.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 92.0, 0.72 + float(pi) * 0.14, 0.46, eff_atk * 1.48, Color("#E63946") if (pi % 2 == 1) else Color("#38BDF8"), 0.36, 2.0)
		for hi in range(4 if p2 else 3):
			var h_off: float = (float(hi) - 1.5) * 0.36
			e._spawn_boss_projectile(origin, to_p.rotated(h_off), 360.0, eff_atk * 1.22, Color("#38BDF8"), "orb", 0.28, 1.8, 2.8)
		e.spiral_angle_offset += 0.38

	elif e.enemy_id == "dia_ma_lao_quy_boss":
		# FINAL BOSS QUYỂN II — ĐỊA MA LÃO QUỶ (ĐẤU TÔNG 7 TINH): Cửu U Hàn Băng Không Gian — Khiên Băng Đấu Tông + Bão Băng Hút Tâm + 5 Cột Cửu U + 12 Băng Tiễn!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.55):
			e._activate_boss_shield(0.24, 6.8, "CỬU U HÀN BĂNG THẦN GIÁP!", Color("#CAF0F8"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -112), "CỬU U HÀN BĂNG KHÔNG GIAN!! (ĐẤU TÔNG 7★)", Color("#CAF0F8"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 132.0, 0.50, 3.0, eff_atk * 1.30, Color("#90E0EF"), 0.46, 2.4, 175.0)
		var dm_p: int = 5 if p2 else 3
		for pi in range(dm_p):
			var ang_p: float = float(pi) * (TAU / float(dm_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 120.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 98.0, 0.72 + float(pi) * 0.14, 0.50, eff_atk * 1.54, Color("#CAF0F8"), 0.45, 2.4)
		e.spiral_angle_offset += 0.30
		var ice_sp: int = 12 if p2 else 8
		for k in range(ice_sp):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(ice_sp))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 405.0, eff_atk * 1.22, Color("#90E0EF"), "spear", 0.42, 2.2)

	elif e.enemy_id == "phi_thien_boss":
		# THIÊN LÔI TỬ PHÍ THIÊN (Bát Tinh Đấu Tông — Phong Lôi Bắc Các): Cửu Thiên Lôi Ngục + 8 Tia Lôi Điện Xoắn!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("skill_burst")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.45):
			e._activate_boss_shield(0.20, 6.0, "LÔI CƯƠNG HỘ THÂN!", Color("#72EFDD"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -108), "CỬU THIÊN LÔI NGỤC!! (BẮC CÁC)", Color("#72EFDD"))
		var pt_p: int = 4 if p2 else 3
		for pi in range(pt_p):
			var ang_p: float = float(pi) * (TAU / float(pt_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 112.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 88.0, 0.66 + float(pi) * 0.14, 0.44, eff_atk * 1.42, Color("#72EFDD"), 0.25, 1.4)
		e.spiral_angle_offset += 0.34
		var l_cnt: int = 10 if p2 else 7
		for k in range(l_cnt):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(l_cnt))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 420.0, eff_atk * 1.18, Color("#72EFDD"), "spear", 0.0, 0.0)

	elif e.enemy_id == "vuong_tran_boss":
		# HUYẾT SÁT VƯƠNG TRẦN (Hoàng Tuyền Các): Huyết Sát Đao Vực hút tâm + 6 Huyết Đao Sóng Quét!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -108), "HOÀNG TUYỀN HUYẾT SÁT TRẢM!!", Color("#E63946"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 118.0, 0.46, 2.4, eff_atk * 1.24, Color("#E63946"), 0.30, 1.8, 165.0)
		var v_cnt: int = 7 if p2 else 5
		for k in range(v_cnt):
			var off_a: float = (float(k) - float(v_cnt - 1) * 0.5) * 0.24
			e._spawn_boss_projectile(origin, to_p.rotated(off_a), 400.0, eff_atk * 1.22, Color("#E63946"), "wave", 0.0, 0.0)

	elif e.enemy_id == "phuong_thanh_nhi_boss":
		# PHƯỢNG THANH NHI (Thiên Yêu Hoàng · Phong Lôi Các #1): Yêu Hoàng Lôi Dực + 5 Trụ Lôi Phượng + 10 Vũ Lôi Tốc Độ Cao!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_burst")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.48):
			e._activate_boss_shield(0.22, 6.2, "YÊU HOÀNG PHƯỢNG DỰC THUẪN!", Color("#C77DFF"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -110), "PHONG LÔI CỰC PHÁ — YÊU HOÀNG LÔI DỰC!!", Color("#C77DFF"))
		var pq_p: int = 5 if p2 else 3
		for pi in range(pq_p):
			var ang_p: float = float(pi) * (TAU / float(pq_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 116.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 92.0, 0.64 + float(pi) * 0.13, 0.46, eff_atk * 1.48, Color("#FFD166") if (pi % 2 == 1) else Color("#C77DFF"), 0.25, 1.4)
		e.spiral_angle_offset += 0.40
		var pf_cnt: int = 10 if p2 else 7
		for k in range(pf_cnt):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(pf_cnt))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 445.0, eff_atk * 1.24, Color("#C77DFF") if (k % 2 == 0) else Color("#FFD166"), "spear", 0.0, 0.0)
		for hi in range(2 if p2 else 1):
			e._spawn_boss_projectile(origin, to_p.rotated((float(hi) - 0.5) * 0.42), 360.0, eff_atk * 1.26, Color("#FFD166"), "orb", 0.22, 1.5, 2.8)

	elif e.enemy_id == "bang_ha_thanh_hai_boss":
		# BĂNG HÀ CỐC CHỦ & THANH HẢI TÔN GIẢ (Đấu Tôn Liên Quân): Băng Hồn Song Tuyệt — Khiên Băng + Bão Tuyết Hút + 5 Trụ Băng-Hồn + 10 Băng Thương!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.54):
			e._activate_boss_shield(0.24, 6.8, "BĂNG HÀ HỒN VỤ THẦN THUẪN!", Color("#38BDF8"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -112), "BĂNG HÀ ĐÓNG BĂNG × HỒN ĐIỆN TỎA HỒN!!", Color("#38BDF8"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 130.0, 0.48, 2.8, eff_atk * 1.28, Color("#38BDF8"), 0.44, 2.3, 175.0)
		var bh_p: int = 5 if p2 else 3
		for pi in range(bh_p):
			var ang_p: float = float(pi) * (TAU / float(bh_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 120.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.70 + float(pi) * 0.14, 0.48, eff_atk * 1.52, Color("#E63946") if (pi % 2 == 1) else Color("#38BDF8"), 0.42, 2.2)
		e.spiral_angle_offset += 0.30
		var bh_sp: int = 10 if p2 else 7
		for k in range(bh_sp):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(bh_sp))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 405.0, eff_atk * 1.24, Color("#38BDF8") if (k % 2 == 0) else Color("#E63946"), "spear", 0.40, 2.0)

	elif e.enemy_id == "cuu_long_loi_cuong_boss":
		# #12 CỬU LONG LÔI CƯƠNG HỎA (Phần Viêm Cốc): Cửu Long Ngân Viêm Trận — 5 Cột Ngân Long + 9 Long Cầu Xoắn + 3 Đuổi Mục Tiêu!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough" if p2 else "skill_fire")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.50):
			e._activate_boss_shield(0.22, 6.4, "CỬU LONG NGÂN VIÊM GIÁP!", Color("#E2F1FF"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -112), "#12 CỬU LONG LÔI CƯƠNG — NGÂN LONG PHẦN THIÊN!!", Color("#E2F1FF"))
		var cl_p: int = 5 if p2 else 4
		for pi in range(cl_p):
			var ang_p: float = float(pi) * (TAU / float(cl_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 124.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.68 + float(pi) * 0.13, 0.48, eff_atk * 1.54, Color("#E2F1FF"), 0.24, 1.5)
		e.spiral_angle_offset += 0.36
		for k in range(9 if p2 else 6):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(9 if p2 else 6))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 385.0, eff_atk * 1.25, Color("#E2F1FF") if (k % 2 == 0) else Color("#4CC9F0"), "orb", 0.0, 0.0)
		for hi in range(3 if p2 else 2):
			e._spawn_boss_projectile(origin, to_p.rotated((float(hi) - 1.0) * 0.40), 355.0, eff_atk * 1.28, Color("#4CC9F0"), "orb", 0.25, 1.6, 2.8)

	elif e.enemy_id == "mo_cot_lao_nhan_boss":
		# MỘ CỐT LÃO NHÂN (Hồn Điện — Tam Tinh Đấu Tôn): U Minh Mộ Cốt Tỏa Hồn Trận — Khiên Xương + Xoáy Hồn + 5 Trụ Hồn Đen + 8 Cầu Xương!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.55):
			e._activate_boss_shield(0.24, 6.6, "U MINH MỘ CỐT HỒN THUẪN!", Color("#9D4EDD"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -112), "U MINH MỘ CỐT TỎA HỒN TRẬN!! (HỒN ĐIỆN)", Color("#9D4EDD"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 132.0, 0.48, 2.9, eff_atk * 1.32, Color("#9D4EDD"), 0.38, 2.2, 180.0)
		var mc_p: int = 5 if p2 else 3
		for pi in range(mc_p):
			var ang_p: float = float(pi) * (TAU / float(mc_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 118.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.70 + float(pi) * 0.14, 0.48, eff_atk * 1.56, Color("#E63946") if (pi % 2 == 1) else Color("#9D4EDD"), 0.36, 2.0)
		e.spiral_angle_offset += 0.35
		for k in range(8 if p2 else 6):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(8 if p2 else 6))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 375.0, eff_atk * 1.26, Color("#9D4EDD"), "orb", 0.30, 1.8, 2.4 if (k % 2 == 0) else 0.0)

	elif e.enemy_id == "tam_thien_diem_viem_boss":
		# FINAL BOSS CH.08 — #9 THÁI HƯ TỬ HẮC CỰ LONG (Tam Thiên Diễm Viêm Hỏa): Ngân Hà Tinh Vực — Khiên Tinh Thể + Hố Đen Tinh Hà + 6 Trụ Tinh Hỏa + 14 Tinh Cầu + Tự Hồi 4% HP ở P2!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if p2 and e.cur_hp < e.max_hp * 0.85:
			var regen_d: float = e.max_hp * 0.04
			e.cur_hp = minf(e.max_hp, e.cur_hp + regen_d)
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -134), "✦ BẤT TỬ TINH THỂ +%d HP!" % int(round(regen_d)), Color("#C77DFF"))
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.58):
			e._activate_boss_shield(0.26, 7.0, "TAM THIÊN TINH THỂ BẤT TỬ THUẪN!", Color("#A855F7"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -114), "#9 TAM THIÊN DIỄM VIÊM HỎA — NGÂN HÀ TINH VỰC!!", Color("#A855F7"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 142.0, 0.48, 3.2, eff_atk * 1.36, Color("#A855F7"), 0.40, 2.4, 190.0)
		var tt_p: int = 6 if p2 else 4
		for pi in range(tt_p):
			var ang_p: float = float(pi) * (TAU / float(tt_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 128.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 102.0, 0.68 + float(pi) * 0.13, 0.52, eff_atk * 1.62, Color("#FFD166") if (pi % 2 == 1) else Color("#A855F7"), 0.36, 2.2)
		e.spiral_angle_offset += 0.28
		var star_cnt: int = 14 if p2 else 10
		for k in range(star_cnt):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(star_cnt))
			var s_col: Color = Color("#C77DFF") if (k % 3 == 0) else (Color("#FFD166") if (k % 3 == 1) else Color("#E0AAFF"))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 415.0, eff_atk * 1.28, s_col, "orb", 0.28, 1.8, 2.2 if (k % 4 == 0) else 0.0)

	# =========================================================
	# 7 BOSS ĐỘC QUYỀN CHƯƠNG 09 (VONG HỒN ĐIỆN · HOA TÔNG · DI TÍCH · CỔ LONG · CỔ GIỚI · THIÊN MỘ)
	# =========================================================
	elif e.enemy_id == "trich_tinh_lao_quy_boss":
		# TRÍCH TINH LÃO QUỶ (Ngũ Tinh Đấu Tôn Hồn Điện): Không Gian Đông Cứng + Trích Tinh Thủ giáng trụ sao đen!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.52):
			e._activate_boss_shield(0.24, 6.8, "HẮC ÁM KHÔNG GIAN THUẪN!", Color("#A855F7"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -114), "TRÍCH TINH THỦ — KHÓA CỨNG HƯ KHÔNG!!", Color("#A855F7"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 142.0, 0.46, 3.0, eff_atk * 1.32, Color("#A855F7"), 0.42, 2.4, 195.0)
		var tt_cnt: int = 5 if p2 else 3
		for pi in range(tt_cnt):
			var ang_p: float = float(pi) * (TAU / float(tt_cnt)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 124.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 100.0, 0.68 + float(pi) * 0.13, 0.50, eff_atk * 1.56, Color("#7B2CBF"), 0.36, 2.0)
		e.spiral_angle_offset += 0.32
		for k in range(10 if p2 else 7):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(10 if p2 else 7))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 405.0, eff_atk * 1.24, Color("#A855F7"), "orb", 0.30, 1.8, 2.2 if (k % 3 == 0) else 0.0)

	elif e.enemy_id == "hac_bach_thien_ton_boss":
		# HẮC BẠCH THIÊN TÔN & CỬU THIÊN TÔN: Song Hồn Âm Dương Trận + Sét Hắc Bạch Truy Đuổi!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.54):
			e._activate_boss_shield(0.24, 6.6, "HẮC BẠCH ÂM DƯƠNG THUẪN!", Color("#E0FBFC"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -114), "HẮC BẠCH THIÊN TÔN — ÂM DƯƠNG TỎA HỒN!!", Color("#E0FBFC"))
		var hb_p: int = 5 if p2 else 4
		for pi in range(hb_p):
			var ang_p: float = float(pi) * (TAU / float(hb_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 120.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.66 + float(pi) * 0.13, 0.48, eff_atk * 1.54, Color("#E0FBFC") if (pi % 2 == 0) else Color("#7B2CBF"), 0.35, 2.0)
		e.spiral_angle_offset += 0.38
		for k in range(10 if p2 else 8):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(10 if p2 else 8))
			var col_hb: Color = Color("#E0FBFC") if (k % 2 == 0) else Color("#9D4EDD")
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 415.0, eff_atk * 1.24, col_hb, "spear", 0.25, 1.6, 2.2 if (k % 4 == 0) else 0.0)

	elif e.enemy_id == "yeu_hoa_ta_quan_boss":
		# YÊU HOA TÀ QUÂN & HOA CẨM: Vạn Hoa Giáp + Độc Hoa Mạn Đà La Hồi Phục + 10 Mũi Yêu Hoa Tà Thích!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("skill_burst")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.56):
			e._activate_boss_shield(0.25, 6.8, "VẠN HOA GIÁP HỘ THUẪN!", Color("#FF4D6D"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -114), "YÊU HOA TÀ THÍCH × ĐỘC HOA MẠN ĐÀ LA!!", Color("#FF4D6D"))
		e._spawn_boss_hazard(player_node.global_position, "pool", 112.0, 0.55, 4.2, eff_atk * 1.30, Color("#FF4D6D"), 0.35, 2.0)
		var yh_cnt: int = 10 if p2 else 7
		for i in range(yh_cnt):
			var off: float = (float(i) - float(yh_cnt - 1) * 0.5) * 0.19
			e._spawn_boss_projectile(origin, to_p.rotated(off), 450.0, eff_atk * 1.24, Color("#FF4D6D") if (i % 2 == 0) else Color("#FFAFCC"), "spear", 0.25, 1.8)

	elif e.enemy_id == "tan_hon_tao_hoa_boss":
		# TÀN HỒN TẠO HÓA THÁNH GIẢ (Đấu Thánh Viễn Cổ): Thánh Cốt Kim Quang + 6 Thiên Trụ Tạo Hóa + 12 Sóng Thánh Uy!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.55):
			e._activate_boss_shield(0.26, 7.0, "TẠO HÓA THÁNH CỐT THUẪN!", Color("#FFD166"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -116), "TÀN HỒN ĐẤU THÁNH — ĐẠI THIÊN TẠO HÓA CHƯỞNG!!", Color("#FFD166"))
		var th_p: int = 6 if p2 else 4
		for pi in range(th_p):
			var ang_p: float = float(pi) * (TAU / float(th_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 132.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 104.0, 0.68 + float(pi) * 0.13, 0.52, eff_atk * 1.62, Color("#FFD166"), 0.30, 1.8)
		e.spiral_angle_offset += 0.30
		for k in range(12 if p2 else 8):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(12 if p2 else 8))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 420.0, eff_atk * 1.28, Color("#FFD166") if (k % 2 == 0) else Color("#FF4D6D"), "wave", 0.0, 0.0)

	elif e.enemy_id == "bac_long_vuong_boss":
		# BẮC LONG VƯƠNG (Ngụy Bán Thánh): Huyết Long Trảo + Thôn Long Hắc Động Hút Tâm + P2 Huyết Tế Hồi 3% HP!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("boss_roar")
		if p2 and e.cur_hp < e.max_hp * 0.85:
			var regen_bl: float = e.max_hp * 0.03
			e.cur_hp = minf(e.max_hp, e.cur_hp + regen_bl)
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -134), "✦ HUYẾT LONG THÔN PHỆ +%d HP!" % int(round(regen_bl)), Color("#E63946"))
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.55):
			e._activate_boss_shield(0.26, 7.0, "HUYẾT LONG LÂN GIÁP!", Color("#E63946"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -116), "THÔN LONG HẮC ĐỘNG × HUYẾT LONG TRẢO!!", Color("#E63946"))
		e._spawn_boss_hazard(player_node.global_position, "vortex", 150.0, 0.45, 3.2, eff_atk * 1.38, Color("#E63946"), 0.40, 2.2, 205.0)
		var bl_p: int = 5 if p2 else 4
		for pi in range(bl_p):
			var ang_p: float = float(pi) * (TAU / float(bl_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 126.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 102.0, 0.66 + float(pi) * 0.12, 0.50, eff_atk * 1.60, Color("#FF4D6D"), 0.32, 2.0)
		e.spiral_angle_offset += 0.34
		for k in range(12 if p2 else 8):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(12 if p2 else 8))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 435.0, eff_atk * 1.28, Color("#E63946") if (k % 2 == 0) else Color("#FFD166"), "spear", 0.25, 1.6)

	elif e.enemy_id == "co_yeu_do_thong_boss":
		# TU LA ĐÔ THỐNG CỔ YÊU (Bát Tinh Đấu Tôn Đỉnh): Hắc Cực Băng Linh + Thiên Giai Đại Tịch Diệt Chỉ!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.54):
			e._activate_boss_shield(0.25, 6.8, "HẮC CỰC BĂNG LINH THUẪN!", Color("#38BDF8"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -116), "THIÊN GIAI: ĐẠI TỊCH DIỆT CHỈ!! (CỔ TỘC)", Color("#38BDF8"))
		var cy_p: int = 6 if p2 else 4
		for pi in range(cy_p):
			var p_off: Vector2 = to_p * (float(pi) * 68.0 - 90.0)
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 96.0, 0.62 + float(pi) * 0.11, 0.52, eff_atk * 1.62, Color("#38BDF8"), 0.48, 2.5)
		e.spiral_angle_offset += 0.36
		for k in range(12 if p2 else 8):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(12 if p2 else 8))
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 450.0, eff_atk * 1.30, Color("#38BDF8") if (k % 2 == 0) else Color("#90E0EF"), "spear", 0.44, 2.2)

	elif e.enemy_id == "huyet_dao_thanh_gia_boss":
		# FINAL BOSS CH.09 & QUYỂN III — HUYẾT ĐAO THÁNH GIẢ (Nhị Tinh Đấu Thánh): Bão Đao Huyết Hải + Nhất Đao Trảm Thiên Mộ + P2 Huyết Hải Tái Sinh!
		var eff_atk: float = e._get_effective_atk()
		EventBus.audio_sfx_requested.emit("breakthrough")
		if p2 and e.cur_hp < e.max_hp * 0.85:
			var regen_hd: float = e.max_hp * 0.03
			e.cur_hp = minf(e.max_hp, e.cur_hp + regen_hd)
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -138), "✦ HUYẾT HẢI THÁNH THỂ +%d HP!" % int(round(regen_hd)), Color("#FF2A5F"))
		if e.boss_shield_hp <= 0.0 and (p2 or randf() < 0.60):
			e._activate_boss_shield(0.28, 7.2, "HUYẾT ĐAO THÁNH GIẢ HỘ THUẪN!", Color("#FF2A5F"))
		else:
			EventBus.floating_text_requested.emit(e.global_position + Vector2(0, -118), "NHỊ TINH ĐẤU THÁNH — NHẤT ĐAO TRẢM THIÊN MỘ!!", Color("#FF2A5F"))
		e._spawn_boss_hazard(player_node.global_position, "pool", 132.0, 0.52, 4.4, eff_atk * 1.40, Color("#FF2A5F"), 0.38, 2.2)
		var hd_p: int = 6 if p2 else 4
		for pi in range(hd_p):
			var ang_p: float = float(pi) * (TAU / float(hd_p)) + e.spiral_angle_offset
			var p_off: Vector2 = Vector2.ZERO if pi == 0 else Vector2(cos(ang_p), sin(ang_p)) * 136.0
			e._spawn_boss_hazard(player_node.global_position + p_off, "pillar", 106.0, 0.64 + float(pi) * 0.12, 0.54, eff_atk * 1.68, Color("#FF2A5F") if (pi % 2 == 0) else Color("#FFD166"), 0.35, 2.0)
		e.spiral_angle_offset += 0.26
		var hd_cnt: int = 14 if p2 else 10
		for k in range(hd_cnt):
			var ang: float = e.spiral_angle_offset + float(k) * (TAU / float(hd_cnt))
			var b_col: Color = Color("#FF2A5F") if (k % 2 == 0) else Color("#FFD166")
			e._spawn_boss_projectile(origin, Vector2(cos(ang), sin(ang)), 460.0, eff_atk * 1.32, b_col, "wave", 0.30, 1.8, 2.2 if (k % 5 == 0) else 0.0)


static func fire_boss_triple_wave(e) -> void:
	EventBus.audio_sfx_requested.emit("skill_fire")
	var wave_col: Color = get_signature_color(e.enemy_id)
	var style_s: String = "orb" if (e.enemy_id == "co_ha_boss" or e.enemy_id == "lieu_tich_boss" or e.enemy_id == "hoa_linh_xa_boss" or e.enemy_id == "tieu_tu_tinh_su_boss" or e.enemy_id == "viem_loi_boss" or e.enemy_id == "van_lac_tam_viem_boss" or e.enemy_id == "han_phong_boss" or e.enemy_id == "hat_tat_nham_boss" or e.enemy_id == "han_phong_dau_tong_boss" or e.enemy_id == "cuu_long_loi_cuong_boss" or e.enemy_id == "mo_cot_lao_nhan_boss" or e.enemy_id == "tam_thien_diem_viem_boss" or e.enemy_id == "trich_tinh_lao_quy_boss") else ("spear" if (e.enemy_id == "muc_luc_boss" or e.enemy_id == "mac_ba_tu_boss" or e.enemy_id == "hai_ba_dong_boss" or e.enemy_id == "nap_lan_yen_nhien_boss" or e.enemy_id == "van_lang_boss" or e.enemy_id == "la_hau_boss" or e.enemy_id == "lieu_kinh_boss" or e.enemy_id == "vu_ho_phap_boss" or e.enemy_id == "nhan_lac_thien_boss" or e.enemy_id == "dia_ma_lao_quy_boss" or e.enemy_id == "phi_thien_boss" or e.enemy_id == "phuong_thanh_nhi_boss" or e.enemy_id == "bang_ha_thanh_hai_boss" or e.enemy_id == "hac_bach_thien_ton_boss" or e.enemy_id == "yeu_hoa_ta_quan_boss" or e.enemy_id == "bac_long_vuong_boss" or e.enemy_id == "co_yeu_do_thong_boss") else ("boulder" if (e.enemy_id == "moc_chien_boss" or e.enemy_id == "tuyet_ma_thien_vien_boss") else "wave"))
	var slow_r: float = 0.35 if (e.enemy_id == "hai_ba_dong_boss" or e.enemy_id == "tuyet_ma_thien_vien_boss" or e.enemy_id == "han_phong_boss" or e.enemy_id == "han_phong_dau_tong_boss" or e.enemy_id == "dia_ma_lao_quy_boss" or e.enemy_id == "hat_tat_nham_boss" or e.enemy_id == "bang_ha_thanh_hai_boss" or e.enemy_id == "mo_cot_lao_nhan_boss" or e.enemy_id == "trich_tinh_lao_quy_boss" or e.enemy_id == "co_yeu_do_thong_boss") else 0.0
	var slow_d: float = 2.0 if slow_r > 0.0 else 0.0
	var eff_atk: float = e._get_effective_atk()
	var angles: Array = [-0.28, 0.0, 0.28]
	for ang_off in angles:
		e._spawn_boss_projectile(e.global_position + Vector2(0, -20), e.wave_aim_dir.rotated(float(ang_off)), 360.0, eff_atk * 1.15, wave_col, style_s, slow_r, slow_d)
