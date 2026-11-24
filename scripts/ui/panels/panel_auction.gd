class_name PanelAuction
extends RefCounted
## Panel Phòng Đấu Giá Mễ Đặc Nhĩ (Nhã Phi) & Bát Phiến Môn — Mua Trực Tiếp, Đấu Giá Đấu Trí & Ký Gửi Đan Dược.

var hud: CanvasLayer


func _init(hud_ref: CanvasLayer) -> void:
	hud = hud_ref


func build_content(vbox: VBoxContainer) -> void:
	var venue_title: String = "ĐẠI ĐẤU GIÁ HỘI HẮC HOÀNG TÔNG (HẮC HOÀNG THÀNH · CH.07)" if hud.shop_venue_id == "hac_hoang_tong" else ("ĐẠI ĐẤU GIÁ TRƯỜNG BÁT PHIẾN MÔN (HẮC ẤN THÀNH)" if hud.shop_venue_id == "bat_phien_mon" else "PHÒNG ĐẤU GIÁ MỄ ĐẶC NHĨ (NHÃ PHI)")
	hud.modal_title_lbl.text = "%s   |   Kim Tệ: %d   |   SOUL: %d" % [venue_title, PlayerData.gold, PlayerData.get_soul()]

	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 8)
	vbox.add_child(tab_row)

	var t_shop := Button.new()
	t_shop.text = ("★ " if hud.shop_tab == "shop" else "") + "🛒 Mua Trực Tiếp"
	t_shop.disabled = (hud.shop_tab == "shop")
	t_shop.add_theme_font_size_override("font_size", 12)
	t_shop.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.shop_tab = "shop"
		hud._populate_modal()
	)
	tab_row.add_child(t_shop)

	var t_auc := Button.new()
	t_auc.text = ("★ " if hud.shop_tab == "auction" else "") + "⚖ Phiên Đấu Giá Đấu Trí"
	t_auc.disabled = (hud.shop_tab == "auction")
	t_auc.add_theme_font_size_override("font_size", 12)
	t_auc.add_theme_color_override("font_color", Color("#FFD166"))
	t_auc.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.shop_tab = "auction"
		if hud.auction_lots.is_empty():
			hud.auction_lots = AuctionSystem.generate_auction_lots(hud.shop_venue_id)
			hud.active_auction_lot_idx = 0
		hud._populate_modal()
	)
	tab_row.add_child(t_auc)

	var t_con := Button.new()
	t_con.text = ("★ " if hud.shop_tab == "consign" else "") + "💰 Ký Gửi Bán Đan Dược"
	t_con.disabled = (hud.shop_tab == "consign")
	t_con.add_theme_font_size_override("font_size", 12)
	t_con.add_theme_color_override("font_color", Color("#80ED99"))
	t_con.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.shop_tab = "consign"
		hud._populate_modal()
	)
	tab_row.add_child(t_con)

	if hud.shop_tab == "auction":
		build_auction_tab(vbox)
		return
	elif hud.shop_tab == "consign":
		build_consign_tab(vbox)
		return

	var intro: Label = hud._make_label("Nhã Phi: 'Chọn vật phẩm công tử cần! Hoặc chuyển sang tab [⚖ Phiên Đấu Giá Đấu Trí] & [💰 Ký Gửi Bán Đan Dược] để săn chí bảo và kiếm Kim Tệ giá cao!'", 13, Color("#FFE599"))
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
		var card: PanelContainer = hud._make_styled_panel(Color(0.09, 0.10, 0.17, 0.94), col, 1, 6)
		vbox.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		card.add_child(row)

		row.add_child(hud._make_icon_box(str(item_d.get("icon", "res://assets/sprites/icons/icon_armor.png")), col, 42))

		var info_v := VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(info_v)
		info_v.add_child(hud._make_label(str(item_d.get("name", "")), 13, col))
		var desc_l: Label = hud._make_label(str(item_d.get("desc", "")), 11, Color("#CED4DA"))
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
			handle_shop_purchase(item_d)
		)
		row.add_child(buy_btn)


func handle_shop_purchase(item_d: Dictionary) -> void:
	var price: int = int(item_d.get("price", 50))
	if PlayerData.gold < price:
		AudioManager.play_sfx("alchemy_fail")
		hud.modal_status_lbl.text = "Không đủ Kim Tệ! Cần %d Kim Tệ (Hiện có: %d)." % [price, PlayerData.gold]
		return

	var kind: String = str(item_d.get("kind", "item"))
	var entry_id: String = str(item_d.get("id", ""))
	if kind == "skill_book":
		if PlayerData.has_flag(entry_id):
			return
		PlayerData.gold -= price
		PlayerData.set_story_flag(entry_id)
		hud.modal_status_lbl.text = "Đã lĩnh ngộ thành công: %s!" % str(item_d.get("name", ""))
	elif kind == "weapon":
		PlayerData.gold -= price
		AudioManager.play_sfx("loot_rare")
		var rar: String = str(item_d.get("rarity", "linh"))
		var inst: Dictionary = EquipmentSystem.roll_equipment_instance(entry_id, rar)
		PlayerData.add_gear_to_bag(inst)
		if not PlayerData.has_weapon_equipped():
			PlayerData.equip_gear_from_bag(str(inst.get("uid", "")))
			hud.modal_status_lbl.text = "Đã mua & tự động trang bị: %s!" % EquipmentSystem.get_item_display_name(inst)
		else:
			hud.modal_status_lbl.text = "Đã mua %s bỏ vào Nạp Giới (Bấm [I] để mặc)!" % EquipmentSystem.get_item_display_name(inst)
	else:
		PlayerData.gold -= price
		AudioManager.play_sfx("loot_pickup")
		PlayerData.add_item(entry_id, 1)
		hud.modal_status_lbl.text = "Đã mua %s (Còn %d Kim Tệ)!" % [str(item_d.get("name", "")), PlayerData.gold]

	EventBus.stats_changed.emit()
	hud._populate_modal()


func build_auction_tab(vbox: VBoxContainer) -> void:
	if hud.auction_lots.is_empty():
		hud.auction_lots = AuctionSystem.generate_auction_lots(hud.shop_venue_id)
		hud.active_auction_lot_idx = 0
	hud.active_auction_lot_idx = clampi(hud.active_auction_lot_idx, 0, hud.auction_lots.size() - 1)

	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 8)
	vbox.add_child(top_bar)
	for i in range(hud.auction_lots.size()):
		var l_dict: Dictionary = hud.auction_lots[i]
		var idx_cap: int = i
		var lb := Button.new()
		var done_tag: String = " ✓" if bool(l_dict.get("closed", false)) else ""
		lb.text = ("★ " if i == hud.active_auction_lot_idx else "") + "Lô #%d: %s%s" % [i + 1, str(l_dict.get("name", "")).left(24), done_tag]
		lb.disabled = (i == hud.active_auction_lot_idx)
		lb.add_theme_font_size_override("font_size", 11)
		lb.pressed.connect(func() -> void:
			AudioManager.play_sfx("ui_click")
			hud.active_auction_lot_idx = idx_cap
			hud._populate_modal()
		)
		top_bar.add_child(lb)

	var reroll_b := Button.new()
	reroll_b.text = "↻ Mở Phiên Mới"
	reroll_b.add_theme_font_size_override("font_size", 11)
	reroll_b.add_theme_color_override("font_color", Color("#70D6FF"))
	reroll_b.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		hud.auction_lots = AuctionSystem.generate_auction_lots(hud.shop_venue_id)
		hud.active_auction_lot_idx = 0
		hud.modal_status_lbl.text = "Đã khai mạc phiên đấu giá mới với 3 bảo vật!"
		hud._populate_modal()
	)
	top_bar.add_child(reroll_b)

	var lot: Dictionary = hud.auction_lots[hud.active_auction_lot_idx]
	var col := Color(str(lot.get("color_hex", "#FFD166")))
	var card: PanelContainer = hud._make_styled_panel(Color(0.11, 0.08, 0.16, 0.96), col, 2, 12)
	vbox.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	card.add_child(v)

	v.add_child(hud._make_label("⚖ BẢO VẬT ĐANG ĐẤU GIÁ: %s" % str(lot.get("name", "")), 15, col))
	var dl: Label = hud._make_label(str(lot.get("desc", "")), 12, Color("#E2E8F0"))
	dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(dl)

	var cur_bid: int = int(lot.get("current_bid", 100))
	var holder: String = str(lot.get("highest_bidder", "Chưa có ai"))
	var rd: int = int(lot.get("round", 0))
	var max_rd: int = int(lot.get("max_rounds", 5))
	v.add_child(hud._make_label("Giá hiện tại: %d Kim Tệ   |   Người giữ giá: %s   |   Hiệp: %d / %d" % [cur_bid, holder, rd, max_rd], 13, Color("#FFD166")))

	var is_scanned: bool = bool(lot.get("scanned", false))
	var r_box: PanelContainer = hud._make_styled_panel(Color(0.07, 0.09, 0.14, 0.92), Color("#3A506B"), 1, 8)
	v.add_child(r_box)
	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 3)
	r_box.add_child(rv)
	rv.add_child(hud._make_label("ĐỐI THỦ TRONG KHÁN PHÒNG (%s):" % ("ĐÃ QUÉT LINH HỒN!" if is_scanned else "Bấm Thăm Dò để xem ngân sách!"), 11, Color("#72EFDD")))
	for riv in lot.get("rivals", []):
		if riv is Dictionary:
			var r_folded: bool = bool(riv.get("folded", false))
			var st_txt: String = "[ĐÃ BỎ CUỘC]" if r_folded else (
				"[Ngân sách tối đa: %d V · Bình tĩnh: %d]" % [int(riv.get("max_budget", 0)), int(riv.get("patience", 1))] if is_scanned else "[Đang theo giá...]"
			)
			rv.add_child(hud._make_label("• %s — %s" % [str(riv.get("name", "Đối thủ")), st_txt], 11, Color("#6C757D") if r_folded else Color("#F8F9FA")))

	if bool(lot.get("closed", false)):
		v.add_child(hud._make_label("Phiên của bảo vật này đã khép lại (%s). Hãy chọn lô khác hoặc bấm [Mở Phiên Mới]!" % str(lot.get("result_text", "Kết thúc")), 12, Color("#80ED99")))
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
		run_auction_action(lot, "bid")
	)
	act_row.add_child(b_norm)

	var b_over := Button.new()
	b_over.text = "⚡ Áp Chế Linh Hồn — Đè Giá (%d V · SOUL %d)" % [cur_bid + step30, PlayerData.get_soul()]
	b_over.add_theme_font_size_override("font_size", 12)
	b_over.add_theme_color_override("font_color", Color("#FFD166"))
	b_over.pressed.connect(func() -> void:
		run_auction_action(lot, "overbid")
	)
	act_row.add_child(b_over)

	var b_scan := Button.new()
	b_scan.text = "👁 Thăm Dò Hậu Đài (Miễn phí)"
	b_scan.disabled = is_scanned
	b_scan.add_theme_font_size_override("font_size", 12)
	b_scan.add_theme_color_override("font_color", Color("#72EFDD"))
	b_scan.pressed.connect(func() -> void:
		run_auction_action(lot, "scan")
	)
	act_row.add_child(b_scan)


func run_auction_action(lot: Dictionary, act_name: String) -> void:
	var res: Dictionary = AuctionSystem.process_bid_turn(lot, act_name, PlayerData.get_soul(), PlayerData.gold)
	var st: String = str(res.get("status", "ongoing"))
	if st == "won":
		lot["closed"] = true
		var win_msg: String = AuctionSystem.award_won_lot(lot)
		lot["result_text"] = "THẮNG ĐẤU GIÁ!"
		hud.modal_status_lbl.text = win_msg
		hud._on_banter(win_msg)
	elif st == "lost":
		lot["closed"] = true
		lot["result_text"] = "Đối thủ mua mất"
		AudioManager.play_sfx("alchemy_fail")
		hud.modal_status_lbl.text = str(res.get("msg", "Đối thủ đã chốt giá cao hơn!"))
	elif st == "insufficient_gold":
		AudioManager.play_sfx("alchemy_fail")
		hud.modal_status_lbl.text = str(res.get("msg", "Không đủ Kim Tệ!"))
	else:
		AudioManager.play_sfx("radar_ping" if act_name == "scan" else "ui_click")
		hud.modal_status_lbl.text = str(res.get("msg", ""))
	hud._populate_modal()


func build_consign_tab(vbox: VBoxContainer) -> void:
	var items: Array = AuctionSystem.get_consignable_items()
	vbox.add_child(hud._make_label("💰 KÝ GỬI BÁN ĐAN DƯỢC & NGUYÊN LIỆU (Giá bán được thưởng x1.25–1.85 theo Linh Hồn & Hảo Cảm Nhã Phi!)", 12, Color("#80ED99")))
	if items.is_empty():
		vbox.add_child(hud._make_label("Bạn chưa có đan dược, dược thảo hay Ma Hạch dư để ký gửi! Hãy khai lò [L] hoặc săn Ma Thú rồi quay lại.", 12, Color("#ADB5BD")))
		return
	for entry in items:
		if not (entry is Dictionary):
			continue
		var ed: Dictionary = entry
		var iid: String = str(ed.get("id", ""))
		var qty: int = int(ed.get("qty", 0))
		var u_price: int = int(ed.get("unit_price", 20))
		var col := Color(str(ed.get("color_hex", "#FFE599")))

		var card: PanelContainer = hud._make_styled_panel(Color(0.08, 0.10, 0.16, 0.94), col, 1, 7)
		vbox.add_child(card)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		card.add_child(row)

		var iv := VBoxContainer.new()
		iv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(iv)
		iv.add_child(hud._make_label("%s  (x%d trong Nạp Giới)" % [str(ed.get("name", iid)), qty], 13, col))
		iv.add_child(hud._make_label("Giá ký gửi: %d Kim Tệ / cái  ·  Bán hết thu: %d Kim Tệ" % [u_price, u_price * qty], 11, Color("#CED4DA")))

		var cap_id: String = iid
		var cap_qty: int = qty
		var sell1 := Button.new()
		sell1.text = "Bán x1 (+%d V)" % u_price
		sell1.add_theme_font_size_override("font_size", 11)
		sell1.pressed.connect(func() -> void:
			var r: Dictionary = AuctionSystem.consign_item(cap_id, 1)
			hud.modal_status_lbl.text = str(r.get("msg", ""))
			hud._populate_modal()
		)
		row.add_child(sell1)

		if qty > 1:
			var sell_all := Button.new()
			sell_all.text = "Bán Hết (+%d V)" % (u_price * qty)
			sell_all.add_theme_font_size_override("font_size", 11)
			sell_all.add_theme_color_override("font_color", Color("#FFD166"))
			sell_all.pressed.connect(func() -> void:
				var r: Dictionary = AuctionSystem.consign_item(cap_id, cap_qty)
				hud.modal_status_lbl.text = str(r.get("msg", ""))
				hud._populate_modal()
			)
			row.add_child(sell_all)
