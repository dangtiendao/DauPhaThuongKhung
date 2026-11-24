class_name AuctionSystem
extends RefCounted
## Hệ thống Đấu Giá Đấu Trí (Tactical Bidding + Soul Scan + Soul Intimidation) & Ký Gửi (Consignment):
## - Hỗ trợ 2 Đấu Trường Đấu Giá:
##   1. "nha_phi" (Phòng Đấu Giá Mễ Đặc Nhĩ — Ô Thản / Đế Đô)
##   2. "bat_phien_mon" (Đại Đấu Giá Trường Bát Phiến Môn — Hắc Ấn Thành Chương 05)
## - Mỗi phiên sinh 3 Lô Chí Bảo với 3 đối thủ NPC có ngân sách (max_budget) & độ kiên nhẫn (patience) riêng.
## - Cơ chế Thăm Dò Linh Hồn (Soul Scan) soi ngân sách đối thủ + Ép Giá Uy Áp Linh Hồn (SOUL >= 25) khiến đối thủ bỏ cuộc!
## - Hệ thống Ký Gửi vật phẩm (đan dược, thảo dược, ma hạch) hưởng hệ số cộng thêm 1.25x–1.85x theo SOUL & danh vọng!


static func get_venue_name(venue_id: String) -> String:
	if venue_id == "bat_phien_mon":
		return "Đại Đấu Giá Trường Bát Phiến Môn — Hắc Ấn Thành"
	return "Phòng Đấu Giá Mễ Đặc Nhĩ — Nhã Phi"


static func _make_rivals(venue_id: String, start_price: int) -> Array:
	var pool: Array = []
	if venue_id == "bat_phien_mon":
		pool = [
			"Phạm Lao (Huyết Tông)",
			"Hàn Phong (Dược Hoàng)",
			"Hắc Khô Lâu Mộ Chủ",
			"Tô Mị (La Sát Môn)",
			"Huyết Đao Lão Tổ",
			"Hắc Ấn Hắc Bào Khách"
		]
	else:
		pool = [
			"Gia Liệt Tất (Gia Liệt Gia)",
			"Mộc Chiến (Mộc Gia)",
			"Áo Ba Khách Thương",
			"Lạc Mã Trưởng Lão",
			"Nạp Lan Quản Gia",
			"Hắc Y Đan Khách"
		]
	pool.shuffle()

	var archetypes: Array = [
		{ "mult_min": 1.24, "mult_max": 1.52, "pat_min": 2, "pat_max": 3 },
		{ "mult_min": 1.48, "mult_max": 1.82, "pat_min": 3, "pat_max": 4 },
		{ "mult_min": 1.72, "mult_max": 2.22, "pat_min": 4, "pat_max": 5 }
	]
	archetypes.shuffle()

	var out: Array = []
	for i in range(3):
		var arch: Dictionary = archetypes[i]
		var mult: float = randf_range(float(arch["mult_min"]), float(arch["mult_max"]))
		var max_b: int = maxi(start_price + 30, int(round(float(start_price) * mult / 5.0)) * 5)
		out.append({
			"name": str(pool[i]),
			"max_budget": max_b,
			"patience": randi_range(int(arch["pat_min"]), int(arch["pat_max"])),
			"folded": false
		})
	return out


static func _build_lot_dict(
	venue_id: String,
	lot_id: String,
	lot_name: String,
	desc: String,
	icon: String,
	color_hex: String,
	kind: String,
	item_id: String,
	template_id: String,
	rarity: String,
	count: int,
	start_price: int,
	extras: Dictionary = {}
) -> Dictionary:
	var d: Dictionary = {
		"id": lot_id,
		"venue_id": venue_id,
		"name": lot_name,
		"desc": desc,
		"icon": icon,
		"color_hex": color_hex,
		"kind": kind,
		"item_id": item_id,
		"template_id": template_id,
		"rarity": rarity,
		"count": count,
		"start_price": start_price,
		"current_bid": start_price,
		"highest_bidder": "Chưa có ai",
		"round": 0,
		"max_rounds": 5,
		"scanned": false,
		"status": "ongoing",
		"closed": false,
		"awarded": false,
		"rivals": _make_rivals(venue_id, start_price)
	}
	for ek in extras.keys():
		d[ek] = extras[ek]
	return d


static func generate_auction_lots(venue_id: String) -> Array:
	var v_id: String = venue_id if venue_id == "bat_phien_mon" else "nha_phi"
	var realm_idx: int = clampi(PlayerData.realm_index, 1, 12)
	var lots: Array = []

	if v_id == "bat_phien_mon":
		var scale_m: float = 1.0 + maxf(0.0, float(realm_idx - 4) * 0.12)
		var p1: int = int(round(460.0 * scale_m / 10.0)) * 10
		var p2: int = int(round(720.0 * scale_m / 10.0)) * 10
		var p3: int = int(round(980.0 * scale_m / 10.0)) * 10

		# Lô 1: Lô Hắc Diễm · Ma Hạch Cấp 5 (Lôi + Huyết Ma Hạch khảm vũ khí)
		lots.append(_build_lot_dict(
			v_id,
			"lot_bpm_core5",
			"Lô Hắc Diễm · Ma Hạch Cấp 5 (Lôi & Huyết)",
			"Song Tinh Hạch Ma Thú Cấp 5 (Lôi Ma Hạch x1 + Huyết Ma Hạch x1) — khảm trực tiếp vào 3 Rãnh Vũ Khí (+58 ATK, +22% Phá Thế & +6% Hút Máu)!",
			"res://assets/sprites/pickups/monster_core.png",
			"#E0AAFF",
			"item",
			"core_loi_5",
			"",
			"thien",
			1,
			p1,
			{ "extra_items": { "core_huyet_5": 1 } }
		))

		# Lô 2: Âm Dương Huyền Long Đan (Thất Phẩm)
		lots.append(_build_lot_dict(
			v_id,
			"lot_bpm_am_duong",
			"Âm Dương Huyền Long Đan (Thất Phẩm)",
			"Thất Phẩm Kỳ Đan chấn động Hắc Giác Vực mang hiệu ứng Phá Hậu Nhi Lập: hồi đầy 100% HP/QI & bùng phát +25% ATK trong 30 giây!",
			"res://assets/sprites/icons/pill_exp_jade.png",
			"#FFD166",
			"item",
			"pill_am_duong_huyen_long",
			"",
			"thien",
			1,
			p2
		))

		# Lô 3: Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa #3 (Gói Chí Bảo Hắc Ấn)
		var bpm_gear_pool: Array = ["caul_hac_ma_dinh", "arm_phap_bao_truong_lao", "pend_kim_viem_ho_hon_ngoc", "caul_xich_duong_dinh"]
		var chosen_tpl: String = str(bpm_gear_pool[randi() % bpm_gear_pool.size()])
		if GameDatabase.get_equipment_template(chosen_tpl).is_empty():
			chosen_tpl = "caul_hac_ma_dinh"
		lots.append(_build_lot_dict(
			v_id,
			"lot_bpm_tan_do_3",
			"Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa #3 (Gói Chí Bảo Hắc Ấn)",
			"Gói Chí Bảo Bát Phiến Môn: [Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa #3 (3/4)] + 1 Trang bị Thiên Phẩm + 6 Đá Cường Hóa + +10 Linh Hồn Lực (SOUL)!",
			"res://assets/sprites/icons/icon_pendant.png",
			"#FF4D6D",
			"relic_pack",
			"",
			chosen_tpl,
			"thien",
			1,
			p3,
			{
				"relic_title": "Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa #3 (3/4)",
				"bonus_stones": 6,
				"bonus_soul": 10
			}
		))
		return lots

	# === PHÒNG ĐẤU GIÁ MỄ ĐẶC NHĨ (nha_phi) ===
	var high_tier: bool = (realm_idx >= 4 or PlayerData.has_flag("ch03_completed") or PlayerData.is_demo_mode)

	# Lô 1: Trang bị hiếm (Địa Phẩm hoặc Thiên Phẩm)
	var gear_candidates: Array = []
	var gear_rarity: String = "thien" if high_tier else "dia"
	if high_tier:
		gear_candidates = ["wpn_chien_phu_thanh_moc", "caul_xich_duong_dinh", "arm_phap_bao_truong_lao", "arm_giap_vay_xa_hoang", "neck_bang_hoang_tam", "pend_thanh_lien_dai"]
	else:
		gear_candidates = ["wpn_tinh_cuong_dao", "arm_hai_tam_giap", "caul_hac_ma_dinh", "ring_cot_viem_gioi", "boot_phong_hanh_hai", "glv_thiet_quyen_uyen"]
	gear_candidates.shuffle()
	var g_tpl: String = str(gear_candidates[0])
	var g_def: Dictionary = GameDatabase.get_equipment_template(g_tpl)
	if g_def.is_empty():
		g_tpl = "caul_hac_ma_dinh"
		g_def = GameDatabase.get_equipment_template(g_tpl)
	var g_rar_name: String = EquipmentSystem.get_rarity_name(gear_rarity)
	var g_col_hex: String = "#FF9F1C" if gear_rarity == "thien" else "#C77DFF"
	var g_price: int = (420 + realm_idx * 45) if high_tier else (180 + realm_idx * 35)
	g_price = int(round(float(g_price) / 10.0)) * 10
	lots.append(_build_lot_dict(
		v_id,
		"lot_np_gear_%s" % g_tpl,
		"[%s] %s" % [g_rar_name, str(g_def.get("name", "Bảo Khí Hiếm"))],
		"%s — Chế tác tinh xảo kèm nhiều dòng thuộc tính phụ ngẫu nhiên tại Phòng Đấu Giá Mễ Đặc Nhĩ!" % str(g_def.get("description", "Trang bị hiếm.")),
		str(g_def.get("icon", "res://assets/sprites/icons/icon_armor.png")),
		g_col_hex,
		"gear",
		"",
		g_tpl,
		gear_rarity,
		1,
		g_price
	))

	# Lô 2: Lô Ma Hạch hiếm (core_hoa_3 hoặc core_phong_4)
	var use_core4: bool = high_tier or (realm_idx >= 3 and randf() < 0.45)
	var core_id: String = "core_phong_4" if use_core4 else "core_hoa_3"
	var core_cnt: int = 2 if realm_idx >= 3 else 1
	var core_def: Dictionary = GameDatabase.get_item_def(core_id)
	var core_name: String = str(core_def.get("name", "Ma Hạch Hiếm"))
	var core_col: String = str(core_def.get("color_hex", "#70D6FF" if use_core4 else "#FF4D6D"))
	var core_price: int = (220 if use_core4 else 150) * core_cnt
	lots.append(_build_lot_dict(
		v_id,
		"lot_np_%s" % core_id,
		"Lô Tinh Hạch: %s x%d" % [core_name, core_cnt],
		"%s — Dùng khảm vào Rãnh Vũ Khí tăng mạnh chiến lực hoặc khai lò luyện đan cao phẩm!" % str(core_def.get("description", "Tinh hạch Ma Thú quý hiếm.")),
		"res://assets/sprites/pickups/monster_core.png",
		core_col,
		"item",
		core_id,
		"",
		"dia",
		core_cnt,
		core_price
	))

	# Lô 3: Bảo Đan Hiếm (Tam Văn Thanh Linh Đan hoặc Băng Tâm Đan)
	if high_tier:
		var pill_def: Dictionary = GameDatabase.get_item_def("pill_tam_van_thanh_linh")
		var p_price: int = 440 + realm_idx * 30
		p_price = int(round(float(p_price) / 10.0)) * 10
		lots.append(_build_lot_dict(
			v_id,
			"lot_np_tam_van",
			"Chí Bảo Luyện Đan: %s x1" % str(pill_def.get("name", "Tam Văn Thanh Linh Đan")),
			"%s — Lô đan hiếm có khó tìm tại Tổng Bộ Mễ Đặc Nhĩ Đế Đô!" % str(pill_def.get("description", "Bảo đan đột phá Đấu Linh.")),
			"res://assets/sprites/icons/pill_exp_jade.png",
			"#80ED99",
			"item",
			"pill_tam_van_thanh_linh",
			"",
			"thien",
			1,
			p_price
		))
	else:
		var bt_def: Dictionary = GameDatabase.get_item_def("pill_bang_tam_dan")
		var bt_cnt: int = 2
		var bt_price: int = 160 + realm_idx * 25
		bt_price = int(round(float(bt_price) / 10.0)) * 10
		lots.append(_build_lot_dict(
			v_id,
			"lot_np_bang_tam",
			"Hộp Ngọc Tứ Phẩm: %s x%d" % [str(bt_def.get("name", "Băng Tâm Đan (Tứ Phẩm)")), bt_cnt],
			"%s — Nhã Phi đặc biệt giữ lại cho quý khách Mễ Đặc Nhĩ!" % str(bt_def.get("description", "Hồi ngay +185 HP.")),
			"res://assets/sprites/icons/pill_hp_red.png",
			"#70D6FF",
			"item",
			"pill_bang_tam_dan",
			"",
			"dia",
			bt_cnt,
			bt_price
		))

	return lots


static func process_bid_turn(lot: Dictionary, action: String, player_soul: int, player_gold: int) -> Dictionary:
	if lot.is_empty():
		return { "ok": false, "status": "lost", "msg": "Lô đấu giá không hợp lệ!", "final_price": 0 }

	var cur_bid: int = int(lot.get("current_bid", lot.get("start_price", 100)))
	if bool(lot.get("closed", false)):
		var prev_st: String = str(lot.get("status", "lost"))
		return {
			"ok": false,
			"status": prev_st,
			"msg": "Phiên đấu giá vật phẩm này đã khép lại (%s)!" % ("Đã thắng thầu" if prev_st == "won" else "Đã kết thúc"),
			"final_price": cur_bid
		}

	var rivals: Array = lot.get("rivals", [])

	# 1) Thăm Dò Linh Hồn (Soul Scan) — miễn phí, không nhảy lượt, soi rõ max_budget & patience!
	if action == "scan":
		lot["scanned"] = true
		var parts: Array = []
		for r in rivals:
			if r is Dictionary:
				var rname: String = str(r.get("name", "Đối thủ"))
				if bool(r.get("folded", false)):
					parts.append("%s [Đã bỏ]" % rname)
				else:
					parts.append("%s (Tối đa %dV · Kiên nhẫn %d)" % [rname, int(r.get("max_budget", 0)), int(r.get("patience", 0))])
		var soul_note: String = "Đủ uy áp Linh Hồn (>=25 SOUL) để dùng [Ép Giá]!" if player_soul >= 25 else "Cần >= 25 SOUL để phát động Uy Áp khi [Ép Giá]!"
		return {
			"ok": true,
			"status": "ongoing",
			"msg": "THĂM DÒ LINH HỒN (%d SOUL): %s. %s" % [player_soul, " | ".join(parts), soul_note],
			"final_price": cur_bid
		}

	# Hỗ trợ rút lui chủ động nếu người chơi bấm bỏ qua
	if action == "fold" or action == "pass":
		lot["closed"] = true
		lot["status"] = "lost"
		return {
			"ok": true,
			"status": "lost",
			"msg": "Bạn đã chủ động rút khỏi lô đấu giá [%s]." % str(lot.get("name", "")),
			"final_price": cur_bid
		}

	# 2) Ra giá ("bid") hoặc Ép giá ("overbid")
	var is_overbid: bool = (action == "overbid")
	var raise_amt: int = maxi(40, int(round(float(cur_bid) * 0.30))) if is_overbid else maxi(20, int(round(float(cur_bid) * 0.15)))
	var new_bid: int = cur_bid + raise_amt

	if player_gold < new_bid:
		return {
			"ok": false,
			"status": "insufficient_gold",
			"msg": "Không đủ Kim Tệ! Cần %d Kim Tệ để ra giá (hiện có %d Kim Tệ)." % [new_bid, player_gold],
			"final_price": cur_bid
		}

	lot["current_bid"] = new_bid
	lot["highest_bidder"] = "Tiêu Viêm"
	var cur_round: int = int(lot.get("round", 0)) + 1
	var max_rounds: int = maxi(1, int(lot.get("max_rounds", 5)))
	lot["round"] = cur_round

	var log_parts: Array = []
	if is_overbid:
		log_parts.append("Bạn ÉP GIÁ mạnh lên %d Kim Tệ!" % new_bid)
	else:
		log_parts.append("Bạn nâng giá lên %d Kim Tệ." % new_bid)

	# 3) Kiểm tra Uy Áp Linh Hồn (SOUL Intimidation Check) khi dùng "overbid"
	var scared_names: Array = []
	if is_overbid:
		if player_soul >= 25:
			var pat_drop: int = 1 + (1 if player_soul >= 60 else 0) + (1 if player_soul >= 120 else 0)
			for r in rivals:
				if not (r is Dictionary) or bool(r.get("folded", false)):
					continue
				var new_pat: int = maxi(0, int(r.get("patience", 2)) - pat_drop)
				r["patience"] = new_pat
				var max_b: int = int(r.get("max_budget", 0))
				# Rung chuyển tâm thần: đối thủ kiên nhẫn thấp hoặc gần trần ngân sách bỏ cuộc ngay!
				if new_pat <= 1 or new_bid >= int(round(float(max_b) * 0.84)):
					r["folded"] = true
					scared_names.append(str(r.get("name", "Đối thủ")))
			if not scared_names.is_empty():
				log_parts.append("UY ÁP LINH HỒN (%d SOUL) chấn nhiếp khiến %s sợ hãi bỏ cuộc!" % [player_soul, ", ".join(scared_names)])
			else:
				log_parts.append("Uy áp Linh Hồn (%d SOUL) làm suy giảm mạnh kiên nhẫn các đối thủ!" % player_soul)
		else:
			log_parts.append("(Cần >= 25 SOUL để phát động Uy Áp Linh Hồn dọa đối thủ!)")

	# 4) Phản hồi thông minh của các đối thủ NPC
	var rival_min_step: int = maxi(15, int(round(float(new_bid) * 0.10)))
	var rival_min_next: int = new_bid + rival_min_step
	var newly_folded: Array = []
	var contenders: Array = []

	for r in rivals:
		if not (r is Dictionary) or bool(r.get("folded", false)):
			continue
		var r_budget: int = int(r.get("max_budget", 0))
		var r_pat: int = int(r.get("patience", 1))
		if r_budget < rival_min_next or r_pat <= 0:
			r["folded"] = true
			newly_folded.append(str(r.get("name", "Đối thủ")))
		else:
			contenders.append(r)

	if not newly_folded.is_empty():
		log_parts.append("%s vượt quá khả năng nên rút lui." % ", ".join(newly_folded))

	# Tất cả đối thủ đã bỏ cuộc -> Thắng thầu ngay!
	if contenders.is_empty():
		lot["closed"] = true
		lot["status"] = "won"
		log_parts.append("CHỐT BÚA! Toàn bộ đối thủ đã bỏ cuộc — Bạn thắng thầu với giá %d Kim Tệ!" % new_bid)
		return {
			"ok": true,
			"status": "won",
			"msg": " ".join(log_parts),
			"final_price": new_bid
		}

	# Hiệp cuối (round >= max_rounds): nếu người chơi dẫn giá & đối thủ không đủ áp đảo thì chốt thắng!
	if cur_round >= max_rounds:
		var whale: Dictionary = {}
		var best_score: int = -1
		for c in contenders:
			var cd: Dictionary = c
			var sc: int = int(cd.get("max_budget", 0)) + int(cd.get("patience", 0)) * 40
			if sc > best_score:
				best_score = sc
				whale = cd
		var whale_budget: int = int(whale.get("max_budget", 0))
		var whale_pat: int = int(whale.get("patience", 0))
		# Chỉ khi đối thủ còn cực kỳ kiên nhẫn + thừa ngân sách vượt trội và người chơi không ép giá mới cướp búa phút chót
		if not is_overbid and whale_pat >= 3 and whale_budget >= int(round(float(new_bid) * 1.22)):
			var snipe_bid: int = mini(whale_budget, new_bid + maxi(20, int(round(float(new_bid) * 0.14))))
			lot["current_bid"] = snipe_bid
			lot["highest_bidder"] = str(whale.get("name", "Đối thủ"))
			lot["closed"] = true
			lot["status"] = "lost"
			log_parts.append("GIÂY CUỐI! %s tung %d Kim Tệ cướp thầu ngay trước nhát búa cuối!" % [str(whale.get("name", "Đối thủ")), snipe_bid])
			return {
				"ok": true,
				"status": "lost",
				"msg": " ".join(log_parts),
				"final_price": snipe_bid
			}
		lot["closed"] = true
		lot["status"] = "won"
		log_parts.append("BÚA ĐẤU GIÁ GIÁNG XUỐNG (Hiệp %d/%d)! Bạn giữ vững giá cao nhất %d Kim Tệ — THẮNG THẦU!" % [cur_round, max_rounds, new_bid])
		return {
			"ok": true,
			"status": "won",
			"msg": " ".join(log_parts),
			"final_price": new_bid
		}

	# Còn hiệp -> Chọn đối thủ hung hăng nhất đáp trả
	var chosen_rival: Dictionary = contenders[0]
	var top_desire: float = -1.0
	for c in contenders:
		var cd: Dictionary = c
		var headroom: float = float(int(cd.get("max_budget", 0)) - new_bid)
		var desire: float = headroom + float(int(cd.get("patience", 1))) * 45.0 + randf_range(0.0, 35.0)
		if desire > top_desire:
			top_desire = desire
			chosen_rival = cd

	var r_step: int = maxi(15, int(round(float(new_bid) * randf_range(0.09, 0.16))))
	var rival_bid: int = mini(int(chosen_rival.get("max_budget", new_bid + r_step)), new_bid + r_step)
	chosen_rival["patience"] = maxi(0, int(chosen_rival.get("patience", 1)) - 1)
	lot["current_bid"] = rival_bid
	lot["highest_bidder"] = str(chosen_rival.get("name", "Đối thủ"))

	log_parts.append("%s lập tức nâng giá lên %d Kim Tệ! (Hiệp %d/%d)" % [
		str(chosen_rival.get("name", "Đối thủ")), rival_bid, cur_round, max_rounds
	])
	return {
		"ok": true,
		"status": "ongoing",
		"msg": " ".join(log_parts),
		"final_price": rival_bid
	}


static func award_won_lot(lot: Dictionary) -> String:
	if lot.is_empty():
		return "Lô đấu giá không hợp lệ!"
	if bool(lot.get("awarded", false)):
		return "Bạn đã nhận phần thưởng lô đấu giá này rồi!"

	var price: int = int(lot.get("current_bid", lot.get("start_price", 0)))
	PlayerData.gold = maxi(0, PlayerData.gold - price)
	PlayerData.auction_wins += 1
	lot["awarded"] = true
	lot["closed"] = true
	lot["status"] = "won"

	var kind: String = str(lot.get("kind", "item"))
	var granted_parts: Array = []

	if kind == "gear":
		var tpl_id: String = str(lot.get("template_id", ""))
		var rar: String = str(lot.get("rarity", "dia"))
		var inst: Dictionary = EquipmentSystem.roll_equipment_instance(tpl_id, rar)
		if not inst.is_empty():
			PlayerData.add_gear_to_bag(inst)
			granted_parts.append(EquipmentSystem.get_item_display_name(inst))
		else:
			granted_parts.append(str(lot.get("name", "Trang Bị Hiếm")))

	elif kind == "item":
		var iid: String = str(lot.get("item_id", ""))
		var cnt: int = maxi(1, int(lot.get("count", 1)))
		if iid != "":
			PlayerData.add_item(iid, cnt)
			var idef: Dictionary = GameDatabase.get_item_def(iid)
			var iname: String = str(idef.get("name", str(lot.get("name", iid))))
			granted_parts.append("%s x%d" % [iname, cnt])
		var extra_d: Dictionary = lot.get("extra_items", {}) if (lot.get("extra_items", {}) is Dictionary) else {}
		for ek in extra_d.keys():
			var ek_s: String = str(ek)
			var ecnt: int = maxi(1, int(extra_d[ek]))
			PlayerData.add_item(ek_s, ecnt)
			var edef: Dictionary = GameDatabase.get_item_def(ek_s)
			var ename: String = str(edef.get("name", PlayerData.get_core_socket_def(ek_s).get("name", ek_s)))
			granted_parts.append("%s x%d" % [ename, ecnt])

	elif kind == "relic_pack":
		var r_title: String = str(lot.get("relic_title", ""))
		if r_title != "":
			PlayerData.add_story_relic(r_title)
			granted_parts.append("[%s]" % r_title)
		var tpl_id2: String = str(lot.get("template_id", ""))
		if tpl_id2 != "":
			var rar2: String = str(lot.get("rarity", "thien"))
			var inst2: Dictionary = EquipmentSystem.roll_equipment_instance(tpl_id2, rar2)
			if not inst2.is_empty():
				PlayerData.add_gear_to_bag(inst2)
				granted_parts.append(EquipmentSystem.get_item_display_name(inst2))
		var iid2: String = str(lot.get("item_id", ""))
		if iid2 != "":
			var cnt2: int = maxi(1, int(lot.get("count", 1)))
			PlayerData.add_item(iid2, cnt2)
			var idef2: Dictionary = GameDatabase.get_item_def(iid2)
			granted_parts.append("%s x%d" % [str(idef2.get("name", iid2)), cnt2])
		var b_stones: int = int(lot.get("bonus_stones", 0))
		if b_stones > 0:
			PlayerData.enhance_stones += b_stones
			granted_parts.append("+%d Đá CH" % b_stones)
		var b_soul: int = int(lot.get("bonus_soul", 0))
		if b_soul > 0:
			PlayerData.bonus_soul += b_soul
			PlayerData.recalculate_and_clamp(false)
			granted_parts.append("+%d SOUL" % b_soul)

	# Đánh dấu cờ hoàn tất đấu giá Bát Phiến Môn (Chương 05 Hắc Ấn Thành!)
	var v_id: String = str(lot.get("venue_id", ""))
	if v_id == "bat_phien_mon" or str(lot.get("id", "")).begins_with("lot_bpm_"):
		PlayerData.set_story_flag("ch05_auction_done")

	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.stats_changed.emit()
	PlayerData.trigger_auto_save("thắng đấu giá")

	var summary: String = " · ".join(granted_parts) if not granted_parts.is_empty() else str(lot.get("name", "Chí Bảo"))
	return "TRÚNG THẦU THÀNH CÔNG (-%d Kim Tệ)! Nhận: %s (Tổng thắng đấu giá: %d)!" % [price, summary, PlayerData.auction_wins]


static func _get_consign_multiplier() -> float:
	var soul_val: int = PlayerData.get_soul()
	var soul_bonus: float = clampf(float(soul_val) / 220.0, 0.0, 0.38)
	var nha_phi_aff: int = PlayerData.get_affection("nha_phi")
	var rep_bonus: float = clampf(
		float(nha_phi_aff) / 100.0 * 0.22
		+ (0.06 if PlayerData.has_flag("met_nha_phi") else 0.0)
		+ minf(0.10, float(PlayerData.auction_wins) * 0.02),
		0.0,
		0.22
	)
	return clampf(1.25 + soul_bonus + rep_bonus, 1.25, 1.85)


static func _compute_item_base_value(item_id: String, idef: Dictionary) -> int:
	var tier: int = clampi(int(idef.get("tier", 1)), 1, 8)
	var itype: String = str(idef.get("type", "herb"))
	var tier_base: Dictionary = {
		1: 18,
		2: 40,
		3: 82,
		4: 140,
		5: 225,
		6: 340,
		7: 520,
		8: 760
	}
	var base_v: float = float(tier_base.get(tier, 20 * tier))
	if itype == "monster_core":
		base_v *= 1.25
	elif itype == "consumable_buff" or itype == "breakthrough":
		base_v *= 1.32
	elif itype == "consumable_hp" or itype == "consumable_qi" or itype == "consumable_exp":
		base_v *= 1.12
	elif item_id.begins_with("core_"):
		base_v *= 1.25
	return maxi(10, int(round(base_v)))


static func _resolve_item_icon(item_id: String, itype: String) -> String:
	if itype == "monster_core" or item_id.begins_with("core_"):
		return "res://assets/sprites/pickups/monster_core.png"
	if itype == "herb" or item_id.begins_with("herb_"):
		return "res://assets/sprites/pickups/herb_item.png"
	if itype == "consumable_hp":
		return "res://assets/sprites/icons/pill_hp_red.png"
	if itype == "consumable_qi":
		return "res://assets/sprites/icons/pill_qi_blue.png"
	return "res://assets/sprites/icons/pill_exp_jade.png"


static func get_consignable_items() -> Array:
	var out: Array = []
	var mult: float = _get_consign_multiplier()
	var sellable_types: Array = [
		"herb",
		"monster_core",
		"consumable_hp",
		"consumable_qi",
		"consumable_exp",
		"consumable_buff",
		"breakthrough"
	]

	for raw_id in PlayerData.inventory.keys():
		var iid: String = str(raw_id)
		var qty: int = PlayerData.get_item_count(iid)
		if qty <= 0:
			continue
		var idef: Dictionary = GameDatabase.get_item_def(iid)
		var itype: String = str(idef.get("type", ""))
		var iname: String = str(idef.get("name", ""))
		var tier: int = int(idef.get("tier", 1))
		var col_hex: String = str(idef.get("color_hex", "#FFE599"))

		# Hỗ trợ cả Ma Hạch cấp 5 khảm được ngay cả khi DB chưa kịp khai báo mô tả
		if idef.is_empty():
			var cdef: Dictionary = PlayerData.get_core_socket_def(iid)
			if not cdef.is_empty():
				itype = "monster_core"
				iname = str(cdef.get("name", iid))
				tier = 5 if iid.ends_with("_5") else 3
				col_hex = "#" + (cdef.get("color", Color("#E0AAFF")) as Color).to_html(false)
			else:
				continue
		elif not sellable_types.has(itype):
			continue

		var base_val: int = _compute_item_base_value(iid, idef if not idef.is_empty() else { "tier": tier, "type": itype })
		var unit_price: int = maxi(12, int(round(float(base_val) * mult)))
		out.append({
			"id": iid,
			"item_id": iid,
			"name": iname if iname != "" else iid,
			"type": itype,
			"tier": tier,
			"qty": qty,
			"count": qty,
			"base_price": base_val,
			"unit_price": unit_price,
			"mult": snappedf(mult, 0.01),
			"color_hex": col_hex,
			"icon": _resolve_item_icon(iid, itype)
		})

	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa: int = int(a.get("unit_price", 0))
		var pb: int = int(b.get("unit_price", 0))
		if pa != pb:
			return pa > pb
		return str(a.get("name", "")) < str(b.get("name", ""))
	)
	return out


static func consign_item(item_id: String, qty: int) -> Dictionary:
	var owned: int = PlayerData.get_item_count(item_id)
	if qty <= 0 or owned < qty:
		EventBus.audio_sfx_requested.emit("alchemy_fail")
		return {
			"ok": false,
			"gold_earned": 0,
			"msg": "Không đủ vật phẩm để ký gửi (hiện có x%d)!" % owned
		}

	var idef: Dictionary = GameDatabase.get_item_def(item_id)
	var iname: String = str(idef.get("name", ""))
	var calc_def: Dictionary = idef
	if calc_def.is_empty():
		var cdef: Dictionary = PlayerData.get_core_socket_def(item_id)
		if not cdef.is_empty():
			iname = str(cdef.get("name", item_id))
			calc_def = { "tier": 5 if item_id.ends_with("_5") else 3, "type": "monster_core" }
		else:
			iname = item_id
			calc_def = { "tier": 1, "type": "herb" }

	var mult: float = _get_consign_multiplier()
	var base_val: int = _compute_item_base_value(item_id, calc_def)
	var unit_price: int = maxi(12, int(round(float(base_val) * mult)))
	var gold_earned: int = unit_price * qty

	if not PlayerData.remove_item(item_id, qty):
		return { "ok": false, "gold_earned": 0, "msg": "Không thể trừ vật phẩm từ Nạp Giới!" }

	PlayerData.gold += gold_earned
	PlayerData.auction_consigned_total += qty
	EventBus.stats_changed.emit()
	EventBus.audio_sfx_requested.emit("loot_pickup")

	return {
		"ok": true,
		"gold_earned": gold_earned,
		"msg": "Ký gửi [%s] x%d (hệ số %.2fx) -> Thu về +%d Kim Tệ!" % [iname, qty, mult, gold_earned]
	}
