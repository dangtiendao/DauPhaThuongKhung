class_name StoryDialogueRunner
extends RefCounted
## Trình chạy Hội Thoại & Kịch Bản NPC (tách từ WorldStageManager):
## - Ưu tiên nạp động kịch bản Data-Driven JSON (dialogues_ch04.json, dialogues_ch05.json, ch06..ch11).
## - Giữ trọn vẹn kịch bản tương tác nguyên tác Chương 01–03.


static func run_data_driven_dialogue(dlg_def: Dictionary, npc_name: String, sprite_p: String) -> bool:
	var branches: Array = dlg_def.get("branches", [])
	if branches.is_empty():
		return false
	for br in branches:
		if not (br is Dictionary):
			continue
		var bd: Dictionary = br
		var is_def: bool = bool(bd.get("default", false))
		var cond_d: Dictionary = bd.get("when", {}) if (bd.get("when", {}) is Dictionary) else {}
		if not is_def and not PlayerData.evaluate_story_condition(cond_d):
			continue

		var sfx_s: String = str(bd.get("sfx", ""))
		if sfx_s != "":
			EventBus.audio_sfx_requested.emit(sfx_s)
		var sh_arr: Array = bd.get("shake", [])
		if sh_arr.size() >= 2:
			EventBus.screen_shake_requested.emit(float(sh_arr[0]), float(sh_arr[1]))

		var q_cur: Dictionary = PlayerData.get_current_quest()
		var q_hint: String = str(q_cur.get("objective", "Tiếp tục tu luyện nâng cao cảnh giới!"))
		var raw_lines: Array = bd.get("lines", [])
		var resolved_lines: Array = []
		for ln in raw_lines:
			resolved_lines.append(str(ln).replace("{quest_objective}", q_hint))

		var sp_override: String = str(bd.get("speaker", npc_name))
		var choices_raw: Array = bd.get("choices", [])
		if not choices_raw.is_empty():
			var filtered_choices: Array = []
			for ch in choices_raw:
				if not (ch is Dictionary):
					continue
				var ch_cond: Dictionary = ch.get("when", {}) if (ch.get("when", {}) is Dictionary) else {}
				if PlayerData.evaluate_story_condition(ch_cond):
					filtered_choices.append({
						"label": str(ch.get("label", "Tiếp tục")),
						"action": str(ch.get("action", ""))
					})
			if not filtered_choices.is_empty():
				EventBus.dialogue_choice_requested.emit(sp_override, sprite_p, resolved_lines, filtered_choices)
				return true

		EventBus.dialogue_requested.emit(sp_override, sprite_p, resolved_lines, str(bd.get("action", "")))
		return true
	return false


static func trigger_npc_interaction(npc_entry: Dictionary) -> void:
	var role_str: String = str(npc_entry.get("role", ""))
	var npc_name: String = str(npc_entry.get("name", "NPC"))
	var sprite_p: String = str(npc_entry.get("sprite", ""))

	# Ưu tiên đọc kịch bản Data-Driven JSON (dialogues_chXX.json) nếu tồn tại!
	var dlg_def: Dictionary = GameDatabase.get_dialogue_def(role_str)
	if not dlg_def.is_empty():
		if run_data_driven_dialogue(dlg_def, npc_name, sprite_p):
			return

	if role_str == "story_tieu_chien":
		if not PlayerData.has_flag("tu_hon_done"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Chiến (vỗ vai con trai, ánh mắt trầm ổn): 'Viêm nhi, ba năm qua dù tộc nhân có bàn tán ra sao, trong lòng vi phụ con vẫn là niềm tự hào của Tiêu Gia!'",
				"Tiêu Chiến (nhíu mày): 'Hôm nay phái đoàn Vân Lam Tông bất ngờ ghé thăm — Nạp Lan Yên Nhiên đang đợi ở sân trước, con đi cùng ta xem chúng giở trò gì!'"
			], "")
		elif not PlayerData.has_flag("unlocked_bat_cuc_bang"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Chiến (cười lớn đầy khí phách): 'Viết Hưu Thư trả lại Tụ Khí Tán trước mặt Chấp sự Vân Lam Tông — thật xứng là con trai của Tiêu Chiến ta!'",
				"Tiêu Chiến: 'Cố gắng tu luyện chuẩn bị cho Lễ Thành Niên Tiêu Gia, đừng để tên Tiêu Ninh kia coi thường!'"
			], "heal_full")
		elif not PlayerData.has_flag("ch01_completed"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Chiến (tự hào): 'Một chiêu đánh bay Tiêu Ninh khỏi Lôi Đài! Đám trưởng lão nay câm nín hết rồi!'",
				"Tiêu Chiến (lo lắng): 'Gần đây Gia Liệt Gia thuê được Luyện Đan Sư Liễu Tịch chèn ép phường thị Tiêu Gia ở Ô Thản Thành... Con nhớ cẩn thận nếu ra thành!'"
			], "heal_full")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Chiến (rưng rưng tự hào): 'Gia Liệt Gia đã bị diệt, Tiêu Gia nay đứng đầu Ô Thản Thành! Con trai, đường lớn bên ngoài Ma Thú Sơn Mạch đang chờ con — hãy bình an trở về!'"
			], "heal_full")

	elif role_str == "story_huan_nhi":
		if not PlayerData.has_flag("huan_nhi_gift"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Huân Nhi (dịu dàng): 'Tiêu Viêm ca ca, huynh đừng buồn vì Ma Thạch Bi vẫn là Tam Đoạn... Muội nhớ suốt 2 năm thuở nhỏ mỗi đêm huynh đều vụng về ôn dưỡng kinh mạch cho muội.'",
				"Tiêu Huân Nhi (đưa túi thảo dược): 'Đây là 2 cây Ngưng Huyết Thảo và 1 viên Ngưng Huyết Tán muội để dành. Bên kia Nạp Lan Yên Nhiên của Vân Lam Tông đang đứng chờ kìa!'"
			], "gift_huan_nhi")
		elif not PlayerData.has_flag("duoc_lao_awake"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Huân Nhi (ánh mắt lấp lánh tia Kim Hỏa rồi dịu lại): 'Tiêu Viêm ca ca thật khí phách khi viết Hưu Thư trước mặt Vân Lam Tông! Huynh cứ lên Hậu Sơn cho khuây khỏa nhé.'"
			], "heal_full")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Huân Nhi (mỉm cười ấm áp): 'Khí tức trên người Tiêu Viêm ca ca mạnh lên từng ngày! Muội sẽ chờ huynh ở Học Viện Già Nam — để muội hồi đầy thể lực cho huynh nhé!'"
			], "heal_full")

	elif role_str == "story_tu_hon":
		if EmperorRealmManager.is_ng_plus_active(PlayerData):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Nạp Lan Yên Nhiên (lạnh nhạt): 'Tiêu Viêm công tử, ba năm qua ngươi dậm chân tại Đấu Chi Khí Tam Đoạn. Khoảng cách giữa chúng ta đã là trời vực...'",
				"Cát Diệp Trưởng Lão (phóng uy áp Đấu Linh): 'Vân Lam Tông tặng Tiêu Gia một viên Tụ Khí Tán Tam Phẩm, chỉ mong công tử hủy bỏ hôn ước này!'",
				"Tiểu Y (ngồi trên vai Tiêu Viêm nháy mắt tinh nghịch — chỉ Tiêu Viêm thấy): 'Y Y nha~ Ông lão Đấu Linh này dám khoe uy áp trước mặt Đế Cảnh Viêm Đế sao?!'"
			], [
				{ "label": "☯ [NG+ Đế Cảnh] Phóng 0,01% Uy Áp Đế Cảnh Linh Hồn làm Cát Diệp & Nạp Lan đánh rơi chén trà ngơ ngác!", "action": "choice:tu_hon_ng_plus_flex" },
				{ "label": "Rạch tay viết Hưu Thư chuẩn nguyên tác: 'Tam Thập Niên Hà Đông, Tam Thập Niên Hà Tây!'", "action": "flag:tu_hon_done" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Nạp Lan Yên Nhiên (lạnh nhạt): 'Tiêu Viêm công tử, ba năm qua ngươi dậm chân tại Đấu Chi Khí Tam Đoạn. Khoảng cách giữa chúng ta đã là trời vực...'",
				"Cát Diệp Trưởng Lão (phóng uy áp Đấu Linh): 'Vân Lam Tông tặng Tiêu Gia một viên Tụ Khí Tán Tam Phẩm, chỉ mong công tử hủy bỏ hôn ước này!'",
				"Tiêu Viêm (rạch tay viết Hưu Thư đẫm máu): 'Lấy Tụ Khí Tán về đi! Không phải ngươi từ hôn ta, mà là TIÊU VIÊM TA HƯU NGƯƠI!'",
				"Tiêu Viêm (gằn từng chữ): 'TAM THẬP NIÊN HÀ ĐÔNG, TAM THẬP NIÊN HÀ TÂY — MẠC KHI THIẾU NIÊN CÙNG! Ba năm sau ta sẽ bước lên Vân Lam Sơn rửa nhục!'",
				"Nạp Lan Yên Nhiên tái mặt phất tay áo rời khỏi Tiêu Gia... (Nhận Buff [Ấn Ký Tôn Nghiêm +5% ATK] & mở Cổng Bắc lên Hậu Sơn!)"
			], "flag:tu_hon_done")

	elif role_str == "story_nhuoc_lam":
		if not PlayerData.has_flag("got_gia_nam_leave"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Nhược Lâm Đạo Sư (mỉm cười tán thưởng): 'Thật kinh ngạc! Một năm từ Tam Đoạn vọt lên đánh bại cả Tiêu Ninh uống Tăng Khí Tán — Học Viện Già Nam đặc cách tuyển thẳng em và Huân Nhi!'",
				"Tiêu Viêm (chắp tay kiên định): 'Đa tạ Đạo sư! Đệ tử có một Ước Hẹn 3 Năm cần tự mình khổ tu bên ngoài, xin Đạo sư cho phép nghỉ phép 2 năm trước khi nhập học!'",
				"Nhược Lâm Đạo Sư (trao ngọc bài xanh biếc): 'Chí khí đáng khen! Đây là [Già Nam Ngọc Bài] — hai năm sau ta chờ hai đứa tại Nội Viện Già Nam!'"
			], "flag:got_gia_nam_leave")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Nhược Lâm Đạo Sư: 'Cầm chắc Già Nam Ngọc Bài nhé! Hãy đột phá lên Đấu Giả rồi ra ngoài rèn luyện cho thật vững vàng.'"
			], "heal_full")

	elif role_str == "secret_lang_anh":
		EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
			"Dược Lão (truyền âm kinh hãi): 'Tiểu tử DỪNG LẠI NGAY! Trong bóng tối gốc tùng kia là một cường giả Đấu Hoàng Cửu Tinh ẩn thân — chắc chắn là ám vệ bảo vệ Huân Nhi!'",
			"Bóng đen mặc hắc bào khẽ hé đôi mắt tím sắc lạnh nhìn về phía bạn..."
		], [
			{ "label": "Nín thở đứng im không động đậy (Nghe lời Dược Lão -> Nhận Hắc Ảnh Phù +8% SPD!)", "action": "choice:lang_anh_quiet" },
			{ "label": "Chắp tay kính lễ cảm ơn tiền bối bảo vệ Huân Nhi (+10 Hảo Cảm Huân Nhi & +4 SOUL!)", "action": "choice:lang_anh_bow" }
		])

	elif role_str == "story_duoc_lao":
		if not PlayerData.has_flag("duoc_lao_awake"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Hắc giới mẫu thân để lại đột nhiên bốc khói trắng — một lão giả bạch bào lơ lửng hiện thân giữa Vách Đá Hậu Sơn!",
				"Dược Lão (cười khà khà): 'Hắc hắc tiểu tử, ba năm qua chính lão phu đã hấp thu Đấu Chi Khí của con để thức tỉnh linh hồn từ giấc ngủ say!'",
				"Tiêu Viêm (quỳ xuống hành lễ): 'Tiền bối là Luyện Dược Đại Sư?! Xin nhận đồ nhi một lạy — chỉ cần giúp con thắng ước hẹn ba năm, khổ cực mấy con cũng chịu!'",
				"Dược Lão: 'Khá lắm! Vi sư truyền cho con [Q] Toái Thạch Chưởng, ngọn [Phàm Hỏa], Kho Đấu Kỹ [K] và mở Lò Luyện Đan [L]! Hãy luyện Trúc Cơ Linh Dịch đầu đời đi!'"
			], "flag:duoc_lao_awake")
		else:
			var q: Dictionary = PlayerData.get_current_quest()
			var q_hint: String = str(q.get("objective", "Tiếp tục khổ tu nâng cao cảnh giới!"))
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Dược Lão: 'Tiểu tử cố lên! Mục tiêu hiện tại của con: %s'" % q_hint,
				"Dược Lão: 'Vi sư vừa dùng linh hồn lực điều tức lại toàn bộ HP và Đấu Khí cho con rồi đấy!'"
			], "heal_full")

	elif role_str == "shop_nha_phi":
		if not PlayerData.has_flag("met_nha_phi"):
			PlayerData.set_story_flag("met_nha_phi")
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Nhã Phi (mỉm cười quyến rũ): 'Ô kìa, đây chẳng phải Tam Thiếu Gia Tiêu Gia sao? Hoan nghênh tới Phòng Đấu Giá Mễ Đặc Nhĩ!'",
				"Nhã Phi: 'Bản phòng vừa nhập về Bí Tịch [Hấp Chưởng], [Bạo Bộ], Thanh Thiết Kiếm, Tinh Cương Chiến Đao và thảo dược luyện đan — mời công tử xem hàng!'"
			], "open_shop:nha_phi")
		else:
			EventBus.shop_requested.emit()

	elif role_str == "story_muc_luc_intro":
		EventBus.dialogue_requested.emit(npc_name, sprite_p, [
			"Mục Lực (khinh khỉnh dựa thương): 'Hừ, lại một tên lính đánh thuê vác thanh sắt đen rỉ sét muốn tiếp cận Tiểu Y Tiên à?'",
			"Mục Lực (cười lạnh): 'Thanh Sơn Trấn này là địa bàn của Lang Đầu Đoàn ta — thức thời thì đừng xía mũi vào chuyện của Vạn Dược Trai!'"
		], "")

	elif role_str == "story_tieu_y_tien":
		if not PlayerData.has_flag("met_tieu_y_tien"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiểu Y Tiên (mỉm cười trong trẻo): 'Chào vị lính đánh thuê trẻ tuổi! Cảm ơn huynh đã không bị lời đe dọa của Mục Lực làm cho chùn bước.'",
				"Tiểu Y Tiên: 'Ở Vách Đá Đoạn Hồn phía Bắc có một hang đá cổ bị mây mù che khuất — nghe đồn có nhiều linh dược hiếm! Muội sẽ đi cùng hỗ trợ hồi máu cho huynh (bấm phím [G])!'",
				"Dược Lão (truyền âm trong nhẫn): 'Huyền Trọng Xích đã quen tay rồi! Giờ vi sư truyền cho con Địa Giai Đấu Kỹ [R] — Diễm Phân Phệ Lãng Xích để xông pha Ma Thú Sơn Mạch!'"
			], "flag:met_tieu_y_tien")
		elif PlayerData.has_flag("found_doc_kinh") and not PlayerData.has_flag("absorbed_tu_hoa"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiểu Y Tiên (ôm chặt cuốn Thất Thải Độc Kinh, mắt sáng rỡ): 'Cảm ơn Tiêu Viêm đã chia sẻ linh dược và cuốn sách kỳ lạ này ở Huyền Nhai Sơn Động!'",
				"Tiểu Y Tiên: 'Nghe nói phía Đông Bắc gần Bờ Suối Trăng Bạc vừa có dị tượng Đấu Hoàng đại chiến — huynh nhớ cẩn thận nhé! Để muội hồi đầy HP & Đấu Khí cho huynh.'"
			], "heal_full")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiểu Y Tiên: 'Mục Lực và Lang Đầu Đoàn ngày càng hung hăng ở phía Đông! Huynh bấm [G] để muội luôn đi sát hỗ trợ hồi máu nhé!'"
			], "heal_full")

	elif role_str == "story_van_chi":
		if not PlayerData.has_flag("met_van_chi"):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Vân Chi (mỹ nhân áo trắng lạnh lùng tựa đá, Đấu Khí bị Tử Tinh Phong Ấn khóa chặt): 'Đa tạ tiểu huynh đệ đã cứu ta bên Bờ Suối Trăng Bạc... Hãy gọi ta là Vân Chi.'",
				"Bên đống lửa trại Hang Ẩn Tu, Tiêu Viêm nướng hai con cá suối thơm phức để bồi bổ cho mỹ nhân bị thương. Dược Lão trong nhẫn bỗng cười gian chỉ vào một lọ bột màu hồng nhạt..."
			], [
				{ "label": "Nướng cá thảo mộc thanh đạm chăm sóc chu đáo (+30 Hảo Cảm Vân Chi!)", "action": "choice:van_chi_herb_fish" },
				{ "label": "Rắc nhầm lọ 'muối tiêu hồng' của Dược Lão (Kỳ ngộ hài hước Vân Chi nhảy xuống suối lạnh!)", "action": "choice:van_chi_pink_powder" }
			])
		elif not PlayerData.has_flag("killed_tieu_su_vuong"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Vân Chi (khẽ gật đầu): 'Ta đã dụ Tử Tinh Dực Sư Vương rời khỏi ổ rồi! Ngươi hãy nhân cơ hội tiến sâu vào Hang Tím phía Đông hạ Tiểu Sư Vương đoạt [Tử Linh Tinh] nhé!'",
				"Vân Chi: 'Để ta dùng dược thảo hồi đầy thể lực cho ngươi trước khi xuất phát.'"
			], "heal_full")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Vân Chi (kinh ngạc nhận lấy một nửa Bầu Tử Linh Tinh): 'Ngươi thực sự đã đoạt được cả Tử Linh Tinh lẫn Tử Tinh Nguyên sao?! Phong ấn trên người ta đã giải trừ hoàn toàn rồi!'",
				"Vân Chi (lưu luyến cởi chiếc nội giáp lấp lánh lam quang đặt vào tay bạn): 'Ta phải trở về tông môn rồi... Chiếc [Hải Tâm Giáp] này tặng ngươi phòng thân. Hẹn một ngày hữu duyên tái ngộ!'",
				"Vân Chi vút bay lên tầng mây! Dược Lão lập tức hộ pháp giúp Tiêu Viêm vận chuyển Phần Quyết nuốt chửng ngọn [TỬ TINH THÚ HỎA] — Đấu Khí lột xác thành sắc TÍM RỰC LỬA!"
			], "flag:absorbed_tu_hoa")

	elif role_str == "story_tieu_y_tien_farewell":
		if not PlayerData.has_flag("ch02_farewell_done"):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Giữa Thung Lũng U Lan, toàn bộ cỏ hoa xung quanh bóng lưng nhỏ bé của Tiểu Y Tiên đều héo đen vì khí độc tím bốc lên từ cơ thể nàng!",
				"Tiểu Y Tiên (khóc nấc lùi lại): 'Tiêu Viêm đừng bước qua vạch cỏ héo! Ách Nan Độc Thể của muội đã thức tỉnh rồi — chạm vào muội huynh sẽ trúng kịch độc mất... Muội phải rời sang Xuất Vân Đế Quốc thôi!'"
			], [
				{ "label": "Bọc Tử Hỏa bước thẳng qua vòng cỏ độc ôm chặt nàng & hẹn ngày luyện Độc Đan (+40 Hảo Cảm!)", "action": "choice:u_lan_hug" },
				{ "label": "Đứng ngoài vòng độc nắm chặt tay thề trở thành Luyện Đan Tông Sư cứu nàng (+20 Hảo Cảm!)", "action": "choice:u_lan_promise" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiểu Y Tiên (mỉm cười qua làn nước mắt): 'Huynh hãy mạnh mẽ tiến về Sa Mạc Tháp Qua Nhĩ ở Chương 03 nhé... Muội sẽ luôn nhớ lời hẹn giữa chúng ta!'"
			], "heal_full")

	elif role_str == "story_tieu_dinh":
		if not PlayerData.has_flag("met_tieu_dinh_le"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Đỉnh (vỗ mạnh vai em trai, mắt ánh lên niềm vui khôn xiết): 'Hảo tiểu tử! Mới hơn một năm xa Ô Thản Thành, tam đệ nhà họ Tiêu chúng ta đã trở thành một vị Đấu Sư đường đường chính chính!'",
				"Tiêu Đỉnh (đưa bình nước lạnh & dược tán): 'Đệ muốn mua bản đồ vùng lõi Sa Mạc Tháp Qua Nhĩ? Ở góc Tây Nam thành có một lão quái vẽ bản đồ cổ cực kỳ bí ẩn — nhớ giữ an toàn nhé!'"
			], "flag:met_tieu_dinh_le")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Đỉnh (mỉm cười trầm ổn): 'Tổng bộ Mạc Thiết Đoàn mãi là nhà của tam đệ! Mệt mỏi cứ về đây đại ca chuẩn bị tiếp tế và hồi đầy thể lực cho!'"
			], "heal_full")

	elif role_str == "story_tieu_le":
		if not PlayerData.has_flag("met_tieu_dinh_le"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Lệ (cười gằn lạnh lùng bên ngọn Huyết Thương nhưng ánh mắt nhìn em trai cực kỳ ấm áp): 'Hắc! Ở cái Thạch Mạc Thành này, đứa nào dám động tới một cọng tóc của tam đệ, nhị ca đem cả đoàn đánh thuê nhà nó chôn sống dưới cát vàng!'",
				"Tiêu Lệ: 'Lão quái vẽ bản đồ ở góc Tây Nam sát khí nặng lắm đấy, nhưng tam đệ giờ đã là Đấu Sư, cứ đi thử xem sao!'"
			], "flag:met_tieu_dinh_le")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Tiêu Lệ (vung Huyết Thương): 'Đám Sa Chi Đoàn & Xà Nhân ngoài thành mà dám cản đường đệ, cứ kêu nhị ca dẫn anh em Mạc Thiết chém sạch!'"
			], "heal_full")

	elif role_str == "story_hai_ba_dong":
		if not PlayerData.has_flag("pact_hai_ba_dong"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Hải Ba Đông (lau vết sương lạnh bên mép, ánh mắt kinh hãi nhìn hư ảnh bạch bào của Dược Lão): 'Cốt Linh Lãnh Hỏa?! Tiền bối... xin tha mạng! Lão phu vốn là Băng Hoàng Hải Ba Đông, bị Mỹ Đỗ Toa hạ Xà Chi Phong Ấn Chú nên thực lực rớt xuống Đấu Linh!'",
				"Dược Lão (cười khà khà): 'Hắc hắc, muốn đồ đệ ta sau này luyện Lục phẩm Phá Ách Đan giải phong ấn cho ngươi? Giao ngay Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa #2 ra đây, và ký giao ước làm Bảo Tiêu Đấu Hoàng miễn phí 1 năm!'",
				"Hải Ba Đông (cắn răng trao nửa mảnh da dê cổ & viên Hàn Băng Chi Tâm): 'Thành giao!! Ta giao [Mảnh Tàn Đồ #2 (2/4)] và bản đồ lõi sa mạc! Nghe nói cô bé Thanh Lân ở Mạc Thiết Đoàn cảm ứng được nguồn lửa cực mạnh dưới Hố Cát Bắc đấy!'"
			], "flag:pact_hai_ba_dong")
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Hải Ba Đông (khoanh tay ngạo nghễ): 'Yên tâm tiểu tử, giao ước của Băng Hoàng ta nặng tựa núi! Chờ ngươi thu phục Thanh Liên Địa Tâm Hỏa rồi luyện Phá Ách Đan cho lão phu đấy!'"
			], "heal_full")

	elif role_str == "story_thanh_lan":
		if not PlayerData.has_flag("met_thanh_lan"):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Thanh Lân (cúi gằm mặt che cánh tay có vảy rắn xanh, nước mắt lưng tròng): 'Tam thiếu gia đừng chạm vào nô tỳ... Người trong thành đều gọi Thanh Lân là quái vật lai Xà Nhân, chạm vào sẽ gặp xui xẻo...'",
				"Đôi mắt xanh biếc của cô bé bỗng lấp lánh ba chấm hoa ngọc bích — Bích Xà Tam Hoa Đồng bắt đầu cảm ứng mãnh liệt về phía Hố Cát Bắc!"
			], [
				{ "label": "Dịu dàng xoa đầu gỡ băng vải: 'Từ nay muội là muội muội của 3 huynh đệ Tiêu Gia!' (+35 Hảo Cảm Thanh Lân!)", "action": "choice:thanh_lan_sister" },
				{ "label": "Đứng chắn trước mặt dặn hai huynh trưởng bảo vệ Thanh Lân thật tốt (+20 Hảo Cảm Thanh Lân!)", "action": "choice:thanh_lan_protect" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Thanh Lân (mỉm cười rạng rỡ với đôi mắt Bích Xà Tam Hoa Đồng): 'Tiêu Viêm thiếu gia cẩn thận nhé! Dưới Hố Cát phía Bắc có một con Song Đầu Hỏa Linh Xà rất hung dữ canh giữ đóa sen xanh khổng lồ!'"
			], "heal_full")

	elif role_str == "story_van_van_ch03":
		if not PlayerData.has_flag("van_van_ch03_done"):
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Giữa chiến trường bão cát Thánh Thành Xà Nhân, tà váy trắng che mạng mỏng chặn đứng đường bạn! Kiếm phong xanh biếc xé rách vạt Hắc Bào, để lộ ánh sáng lam quen thuộc của chiếc [Hải Tâm Giáp] trên ngực Tiêu Viêm!",
				"Vân Vận — Tông Chủ Vân Lam Tông — đồng tử co rút kịch liệt, bàn tay cầm cổ kiếm run lên bần bật: 'Hải Tâm Giáp... Dược Nham?! Sao... sao lại là ngươi?!'"
			], [
				{ "label": "Khẽ thì thầm qua lớp áo choàng: 'Vân Chi... bảo trọng! Đừng để Cổ Hà cản ta!' (+35 Hảo Cảm Vân Vận!)", "action": "choice:van_van_call_name" },
				{ "label": "Im lặng cúi đầu vỗ Tử Vân Dực lướt qua mũi kiếm nghiêng ba tấc của nàng (+20 Hảo Cảm Vân Vận!)", "action": "choice:van_van_silent" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Vân Vận (mắt phượng u buồn quay mặt cản hướng gió): 'Ta sẽ giữ chân Phong Lê và Cổ Hà thêm vài nhịp... Ngươi mau đoạt lấy Dị Hỏa rồi rời khỏi đại mạc đi!'"
			], "heal_full")

	elif role_str == "story_my_do_toa":
		if not PlayerData.has_flag("beat_co_ha_mac_ba_tu"):
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Dược Lão (truyền âm khẩn cấp): 'Khoan đã tiểu tử! Đại Thống Lĩnh Mặc Ba Tư và Đan Vương Cổ Hà vẫn đang chặn bên ngoài — phải đánh bại cả HAI tên đó trước mới có thể đột kích Đảo Thánh Trì đoạt lửa an toàn!'"
			], "")
		else:
			EventBus.audio_sfx_requested.emit("boss_roar")
			EventBus.screen_shake_requested.emit(11.0, 0.45)
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Mỹ Đỗ Toa Nữ Vương (kiêu diễm đứng giữa Thánh Trì Đảo Tâm Hồ, ngẩng đầu đối diện chín tầng Tử Sắc Thiên Lôi): 'Xà Nhân Tộc ta đã khát máu nơi sa mạc cằn cỗi ngàn năm! Hôm nay bổn vương lấy thân nhập Dị Hỏa — hoặc hóa tro bụi, hoặc bước vào ĐẤU TÔNG!!'",
				"ẦM ẦM!! Chín đạo Thiên Lôi Tím giáng tan lớp vảy cháy đen! Từ trong ngọn lửa xanh ngọc chui ra một sinh vật nhỏ bé 7 màu cầu vồng lấp lánh — Thượng Cổ Thần Thú [THẤT THẢI THÔN THIÊN MÃNG] rơi vào hôn mê bên cạnh Hỏa Chủng Thanh Liên Địa Tâm Hỏa!",
				"Tiêu Viêm vỗ Tử Vân Dực lao như tia chớp đen đoạt gọn [HỎA CHỦNG THANH LIÊN ĐỊA TÂM HỎA] cùng con rắn nhỏ 7 màu nhét vào ngực áo! Vân Vận nghiêng mũi kiếm mở đường máu — mau bay qua Cổng Đông Nam tới [Ốc Đảo Diêm Lệ]!!"
			], "flag:snatched_thanh_lien_hoa")

	elif role_str == "story_devour_thanh_lien":
		if not PlayerData.has_flag("ch03_completed"):
			var has_bt: bool = PlayerData.get_item_count("pill_bang_tam_dan") > 0
			var opt1_lbl: String = "Uống [Băng Tâm Đan] + Vận Phần Quyết nuốt trọn #19 Thanh Liên Hỏa (+400 EXP & Mở [F] Hỏa Liên!)" if has_bt else "Vận Phần Quyết + Thanh Liên Đài nuốt trọn #19 Thanh Liên Hỏa (Mở [F] Phật Nộ Hỏa Liên!)"
			EventBus.dialogue_choice_requested.emit(npc_name, sprite_p, [
				"Dược Lão (giăng kết giới linh hồn quanh Thanh Liên Đài giữa Ốc Đảo Diêm Lệ): 'Hỏa Chủng sắp phá bình ngọc rồi! Thôn phệ Dị Hỏa là cửu tử nhất sinh — một khi thành công, Phần Quyết thăng thẳng Huyền Giai Trung Cấp và con có thể dung hợp Song Hỏa sáng tạo tuyệt kỹ độc tôn!'",
				"Ngọn lửa xanh ngọc #19 Thanh Liên Địa Tâm Hỏa bùng cháy rực trời trước mặt Tiêu Viêm..."
			], [
				{ "label": opt1_lbl, "action": "choice:devour_bang_tam" },
				{ "label": "Gầm vang lời thề Ước Hẹn 3 Năm dùng ý chí sắt đá nghiền nát Dị Hỏa (+6 SOUL & Mở [F] Hỏa Liên!)", "action": "choice:devour_iron_will" }
			])
		else:
			EventBus.dialogue_requested.emit(npc_name, sprite_p, [
				"Dược Lão (cười vang tự hào): 'TUYỆT ĐỈNH! Vừa thu phục [#19 Thanh Liên Địa Tâm Hỏa], vừa có Thần Thú [Thải Lân] hộ thân, lại tự sáng tạo ra [F] PHẬT NỘ HỎA LIÊN rung chuyển thiên địa! Mau ra Bãi Thử phía Đông bắn thử một đóa Hỏa Liên xem uy lực cỡ nào!!'"
			], "heal_full")

	elif role_str == "story_thai_lan_pet":
		EventBus.dialogue_requested.emit(npc_name, sprite_p, [
			"Thải Lân (con rắn nhỏ 7 màu đội vương miện vàng quấn quanh cổ tay Tiêu Viêm, mắt lấp lánh đòi ăn Hỏa Tinh như trẻ con): 'Xì xì~ ♪'",
			"Tiêu Viêm mỉm cười đút cho Thải Lân một mảnh Địa Tâm Hỏa Tinh — nàng vui vẻ tỏa ra luồng Thất Thải Quang Mang hồi đầy HP & Đấu Khí cho bạn (+15 Hảo Cảm Thải Lân / Mỹ Đỗ Toa)!"
		], "feed_thai_lan")
