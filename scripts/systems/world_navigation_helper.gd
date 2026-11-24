class_name WorldNavigationHelper
extends RefCounted
## Trợ Lý Tiểu Bản Đồ, La Bàn Nhiệm Vụ & Tìm Đường BFS Toàn Cục (Tách mô-đun từ world_stage_manager.gd):
##   - Tạo snapshot dữ liệu cho Live Mini-Map
##   - Tính tọa độ la bàn mục tiêu (Data-Driven JSON waypoints Ch.04–11 & Ch.01–03)
##   - Thuật toán BFS tìm cổng chuyển tiếp ngắn nhất qua đồ thị 46+ bản đồ


static func get_minimap_snapshot(stage) -> Dictionary:
	var npcs_out: Array = []
	for n in stage.npc_entries:
		var mk: Label = n.get("marker_node", null) as Label
		npcs_out.append({
			"pos": n.get("pos", Vector2.ZERO),
			"has_quest": mk != null and is_instance_valid(mk) and mk.visible
		})

	var portals_out: Array = []
	for pt in stage.portal_entries:
		var rf: String = str(pt.get("require_flag", ""))
		portals_out.append({
			"pos": pt.get("pos", Vector2.ZERO),
			"unlocked": stage._is_portal_unlocked(rf)
		})

	var chests_out: Array = []
	for ch in stage.chest_entries:
		chests_out.append({
			"pos": ch.get("pos", Vector2.ZERO),
			"opened": bool(ch.get("opened", false))
		})

	var enemies_out: Array = []
	for en in stage.get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(en) and en is Node2D:
			var en_nd: Node2D = en as Node2D
			var is_b: bool = bool(en_nd.get("is_boss_unit")) if "is_boss_unit" in en_nd else false
			enemies_out.append({
				"pos": en_nd.global_position,
				"is_boss": is_b
			})

	return {
		"map_id": stage.current_map_id,
		"map_size": stage.map_size,
		"is_forest": stage.current_is_forest,
		"zones": stage.zone_draw_specs,
		"player_pos": stage.player_node.global_position if stage.player_node != null else Vector2.ZERO,
		"npcs": npcs_out,
		"portals": portals_out,
		"chests": chests_out,
		"enemies": enemies_out,
		"radar_active": stage.radar_ping_timer > 0.0,
		"radar_radius": PlayerData.get_soul_radar_radius(),
		"radar_chests": stage.radar_pinged_chests
	}


static func get_quest_waypoint_world_pos(stage) -> Vector2:
	var current_map_id: String = str(stage.current_map_id)
	if stage.is_boss_rush_active or current_map_id == "tam_ma_luyen_canh" or stage.is_tower_active or current_map_id == "thien_phan_thap":
		return Vector2.ZERO
	var q: Dictionary = PlayerData.get_current_quest()
	if q.is_empty():
		return Vector2.ZERO

	# Data-Driven Waypoints trong JSON (hỗ trợ đa điều kiện cho Chương 04 -> 11 & sửa cốt truyện không cần đụng code!)
	if q.has("waypoint") and q["waypoint"] is Array:
		for step in q["waypoint"]:
			if not (step is Dictionary):
				continue
			var sd: Dictionary = step
			var is_def: bool = bool(sd.get("default", false))
			var cond_d: Dictionary = sd.get("when", {}) if (sd.get("when", {}) is Dictionary) else {}
			if is_def or PlayerData.evaluate_story_condition(cond_d):
				var kind: String = str(sd.get("kind", "npc"))
				var t_map: String = str(sd.get("map", current_map_id))
				var target_s: String = str(sd.get("target", ""))
				if kind == "breakthrough_ready":
					var req_pill: String = str(sd.get("pill_id", ""))
					if PlayerData.is_at_bottleneck() and (req_pill == "" or PlayerData.get_item_count(req_pill) > 0):
						return Vector2.ZERO
					if t_map != current_map_id:
						return find_portal_towards(stage, t_map)
					var pa: Array = sd.get("pos", [0, 0])
					return Vector2(float(pa[0]), float(pa[1])) if pa.size() >= 2 else Vector2.ZERO
				elif kind == "npc":
					return find_npc_pos_or_portal(stage, target_s, t_map)
				elif kind == "boss":
					return find_boss_pos_or_portal(stage, target_s, t_map)
				elif kind == "pos":
					if current_map_id == t_map:
						var pa: Array = sd.get("pos", [0, 0])
						return Vector2(float(pa[0]), float(pa[1])) if pa.size() >= 2 else Vector2.ZERO
					return find_portal_towards(stage, t_map)
				elif kind == "none":
					return Vector2.ZERO
		return Vector2.ZERO

	var qid: String = str(q.get("id", ""))

	if qid == "q01_dai_sanh_tu_hon":
		return find_npc_pos_or_portal(stage, "story_tu_hon", "ch01_tieu_gia")
	elif qid == "q02_thuc_tinh_duoc_lao":
		return find_npc_pos_or_portal(stage, "story_duoc_lao", "ch01_hau_son")
	elif qid == "q03_luyen_truc_co_linh_dich":
		return Vector2(480, 620) if current_map_id == "ch01_hau_son" else find_portal_towards(stage, "ch01_hau_son")
	elif qid == "q04_dau_gia_me_dac_nhi":
		return find_npc_pos_or_portal(stage, "shop_nha_phi", "ch01_o_than_thanh")
	elif qid == "q05_ty_thi_tieu_ngoc":
		return find_boss_pos_or_portal(stage, "tieu_ngoc_boss", "ch01_hau_son")
	elif qid == "q06_le_thanh_nien_tieu_ninh":
		if not PlayerData.has_flag("unlocked_bat_cuc_bang"):
			return find_boss_pos_or_portal(stage, "tieu_ninh_boss", "ch01_tieu_gia")
		return find_npc_pos_or_portal(stage, "story_nhuoc_lam", "ch01_tieu_gia")
	elif qid == "q07_dot_pha_dau_gia":
		if PlayerData.is_at_bottleneck() and PlayerData.get_item_count("pill_tu_khi_tan") > 0:
			return Vector2.ZERO
		return Vector2(1420, 560) if current_map_id == "ch01_hau_son" else find_portal_towards(stage, "ch01_hau_son")
	elif qid == "q08_am_sat_lieu_tich":
		return find_boss_pos_or_portal(stage, "lieu_tich_boss", "ch01_o_than_thanh")
	elif qid == "q09_diet_gia_liet_ao":
		return find_boss_pos_or_portal(stage, "gia_liet_ao_boss", "ch01_o_than_thanh")
	elif qid == "q10_thanh_son_tieu_y_tien":
		return find_npc_pos_or_portal(stage, "story_tieu_y_tien", "ch02_ma_thu_son_mach")
	elif qid == "q11_huyen_nhai_tu_van_duc":
		if current_map_id == "ch02_huyen_nhai_dong":
			return Vector2(1296, 320)
		return find_portal_towards(stage, "ch02_huyen_nhai_dong")
	elif qid == "q12_bo_suoi_van_chi":
		return find_npc_pos_or_portal(stage, "story_van_chi", "ch02_noi_vi_su_vuong")
	elif qid == "q13_hang_su_vuong_tu_hoa":
		if not PlayerData.has_flag("killed_tieu_su_vuong"):
			return find_boss_pos_or_portal(stage, "tieu_tu_tinh_su_boss", "ch02_noi_vi_su_vuong")
		return find_npc_pos_or_portal(stage, "story_van_chi", "ch02_noi_vi_su_vuong")
	elif qid == "q14_giai_vay_muc_luc":
		return find_boss_pos_or_portal(stage, "muc_luc_boss", "ch02_ma_thu_son_mach")
	elif qid == "q15_quyet_tu_muc_xa_u_lan":
		if not PlayerData.has_flag("killed_muc_xa"):
			return find_boss_pos_or_portal(stage, "muc_xa_boss", "ch02_thac_nuoc_muc_xa")
		return find_npc_pos_or_portal(stage, "story_tieu_y_tien_farewell", "ch02_thac_nuoc_muc_xa")
	elif qid == "q16_thach_mac_mac_thiet":
		return find_npc_pos_or_portal(stage, "story_tieu_dinh", "ch03_thach_mac_thanh")
	elif qid == "q17_bang_hoang_tan_do":
		if not PlayerData.has_flag("beat_hai_ba_dong"):
			return find_boss_pos_or_portal(stage, "hai_ba_dong_boss", "ch03_thach_mac_thanh")
		return find_npc_pos_or_portal(stage, "story_hai_ba_dong", "ch03_thach_mac_thanh")
	elif qid == "q18_thanh_lan_dia_huyet":
		if not PlayerData.has_flag("met_thanh_lan"):
			return find_npc_pos_or_portal(stage, "story_thanh_lan", "ch03_thach_mac_thanh")
		if current_map_id == "ch03_dia_huyet_dung_nham":
			return Vector2(1490, 540)
		return find_portal_towards(stage, "ch03_dia_huyet_dung_nham")
	elif qid == "q19_thanh_thanh_xa_nhan":
		if not PlayerData.has_flag("killed_mac_ba_tu"):
			return find_boss_pos_or_portal(stage, "mac_ba_tu_boss", "ch03_thanh_thanh_xa_nhan")
		return find_boss_pos_or_portal(stage, "co_ha_boss", "ch03_thanh_thanh_xa_nhan")
	elif qid == "q20_my_do_toa_doat_hoa":
		return find_npc_pos_or_portal(stage, "story_my_do_toa", "ch03_thanh_thanh_xa_nhan")
	elif qid == "q21_thon_phe_di_hoa_lien":
		return find_npc_pos_or_portal(stage, "story_devour_thanh_lien", "ch03_oc_dao_diem_le")
	return Vector2.ZERO


static func find_npc_pos_or_portal(stage, target_role: String, target_map: String) -> Vector2:
	for n in stage.npc_entries:
		if str(n.get("role", "")) == target_role:
			return n.get("pos", Vector2.ZERO)
	return find_portal_towards(stage, target_map)


static func find_boss_pos_or_portal(stage, boss_id: String, target_map: String) -> Vector2:
	for sl in stage.spawn_slots:
		if str(sl.get("id", "")) == boss_id:
			var ref = sl.get("ref", null)
			if ref != null and is_instance_valid(ref) and ref is Node2D:
				return (ref as Node2D).global_position
			return sl.get("pos", Vector2.ZERO)
	return find_portal_towards(stage, target_map)


static func find_portal_towards(stage, target_map: String) -> Vector2:
	if target_map == "" or stage.current_map_id == target_map:
		return Vector2.ZERO
	for pt in stage.portal_entries:
		if str(pt.get("target_map", "")) == target_map:
			return pt.get("pos", Vector2.ZERO)

	var hop: String = bfs_next_hop_map(stage, stage.current_map_id, target_map, true)
	if hop == "":
		hop = bfs_next_hop_map(stage, stage.current_map_id, target_map, false)
	if hop != "":
		for pt in stage.portal_entries:
			if str(pt.get("target_map", "")) == hop:
				return pt.get("pos", Vector2.ZERO)
	return Vector2.ZERO


static func bfs_next_hop_map(stage, start_id: String, goal_id: String, unlocked_only: bool) -> String:
	if start_id == goal_id or not GameDatabase.maps_by_id.has(goal_id):
		return ""
	var queue: Array = [start_id]
	var visited: Dictionary = { start_id: true }
	var first_hop: Dictionary = {}
	var head: int = 0

	while head < queue.size():
		var cur: String = str(queue[head])
		head += 1
		var m_def: Dictionary = GameDatabase.get_map_def(cur)
		var portals_arr: Array = m_def.get("portals", [])
		for pt in portals_arr:
			if not (pt is Dictionary):
				continue
			var req_f: String = str(pt.get("require_flag", ""))
			if req_f.ends_with("_future"):
				continue
			if unlocked_only and not stage._is_portal_unlocked(req_f):
				continue
			var nxt: String = str(pt.get("target_map", ""))
			if nxt == "" or visited.has(nxt) or not GameDatabase.maps_by_id.has(nxt):
				continue
			visited[nxt] = true
			var fh: String = nxt if cur == start_id else str(first_hop.get(cur, nxt))
			first_hop[nxt] = fh
			if nxt == goal_id:
				return fh
			queue.append(nxt)
	return ""
