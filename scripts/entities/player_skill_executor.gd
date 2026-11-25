class_name PlayerSkillExecutor
extends RefCounted
## Bộ Thi Triển 24 Đấu Kỹ, Phật Nộ Hỏa Liên [F], Nội Thiêu #14 & Hỗ Trợ [T] Của Tiêu Viêm (Tách mô-đun từ player_controller.gd):
##   - launch_pending_fire_lotus(): Phóng Phật Nộ Hỏa Liên (Song/Tam/Tứ Sắc) sau pha tụ ấn
##   - cast_skill_slot(): Thực thi trọn bộ 24/24 Đấu Kỹ (Ch.01–Ch.08+)
##   - try_trigger_inner_heart_ignition(): Nội tại #14 Vẫn Lạc Tâm Viêm (mỗi 5 đòn nổ sát thương chuẩn)
##   - pulse_flame_clone_burst() & detonate_flame_clone_finale(): 3 Hỏa Liên Phân Thân xoay quanh thân
##   - activate_duoc_lao_assist(): [T] Dược Lão -> Mỹ Đỗ Toa -> Địa Yêu Khôi -> Chuẩn Thiên Yêu Khôi

const SKILL_SCENE: PackedScene = preload("res://scenes/entities/skill_effect.tscn")


static func launch_pending_fire_lotus(pl) -> void:
	var p: Dictionary = pl.pending_lotus_payload
	pl.pending_lotus_payload = {}
	if pl.get_parent() == null:
		return
	var proj: Area2D = SKILL_SCENE.instantiate() as Area2D
	pl.get_parent().add_child(proj)
	var aim_t: Vector2 = p.get("aim_target", pl.global_position + Vector2.RIGHT * 220.0) as Vector2
	var a_dir: Vector2 = (aim_t - pl.global_position).normalized()
	if a_dir == Vector2.ZERO:
		a_dir = Vector2.RIGHT
	EventBus.audio_sfx_requested.emit("skill_fire")
	EventBus.screen_shake_requested.emit(4.5, 0.14)
	pl._spawn_hit_sparks(pl.global_position + a_dir * 32.0 + Vector2(0, -24), pl.active_core_col, a_dir, 18)
	if proj.has_method("configure_skill"):
		proj.configure_skill(
			"fire_lotus_ult",
			pl.global_position + a_dir * 36.0 + Vector2(0, -24),
			aim_t,
			float(p.get("dmg", 80.0)),
			float(p.get("kb", 520.0)),
			float(p.get("r_pen", 0.5)),
			float(p.get("rad_px", 215.0)),
			float(p.get("spd", 360.0)),
			p.get("flame_def", {}) as Dictionary,
			p.get("fusion_list", []) as Array
		)


static func cast_skill_slot(pl, slot_key: String, skill_id: String) -> void:
	if float(pl.skill_cooldowns.get(slot_key, 0.0)) > 0.0:
		return
	var sdef: Dictionary = GameDatabase.get_skill_def(skill_id)
	if sdef.is_empty():
		return

	var behavior: String = str(sdef.get("behavior", "melee_burst"))
	var qi_cost: float = float(sdef.get("qi_cost", 15.0))
	if behavior == "fire_lotus_ult":
		qi_cost *= PlayerData.get_lotus_qi_cost_multiplier()
	var used_toc_van_free: bool = false
	if behavior != "xiao_clan_crest" and "toc_van_free_casts" in pl and int(pl.toc_van_free_casts) > 0:
		qi_cost = 0.0
		used_toc_van_free = true
	if PlayerData.current_qi < qi_cost:
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -64), "Không đủ Đấu Khí!", Color("#4CC9F0"))
		return

	if used_toc_van_free:
		pl.toc_van_free_casts = maxi(0, int(pl.toc_van_free_casts) - 1)
	PlayerData.current_qi -= qi_cost
	EventBus.qi_updated.emit(PlayerData.current_qi, PlayerData.get_max_qi())

	# Độ Thông Thạo Đấu Kỹ (Sơ Khuy -> Tiểu Thành -> Đại Thành -> Đỉnh Phong)
	var mastery: Dictionary = PlayerData.record_skill_use(skill_id, pl.global_position)
	var m_dmg_mult: float = float(mastery.get("dmg_mult", 1.0))
	var m_cd_mult: float = float(mastery.get("cd_mult", 1.0))
	var m_rad_mult: float = float(mastery.get("radius_mult", 1.0))

	var ht_cd_mult: float = SaintRealmManager.get_hoang_tuyen_cd_mult(PlayerData) if (behavior in ["yellow_springs_palm", "yellow_springs_wrath"]) else 1.0
	var cd_total: float = float(sdef.get("cooldown", 5.0)) * PlayerData.get_cooldown_multiplier() * m_cd_mult * ht_cd_mult
	pl.skill_cooldowns[slot_key] = cd_total
	pl.skill_cooldown_totals[slot_key] = cd_total
	EventBus.skill_cooldown_updated.emit(slot_key, cd_total, cd_total)

	var dmg: float = (PlayerData.get_atk() * float(sdef.get("atk_ratio", 1.5)) + float(PlayerData.get_soul()) * float(sdef.get("soul_ratio", 0.2))) * PlayerData.get_flame_dmg_multiplier() * m_dmg_mult
	var rad_px: float = float(sdef.get("radius_px", 110.0)) * m_rad_mult
	var kb: float = float(sdef.get("knockback", 320.0))
	var r_pen: float = float(sdef.get("realm_pen", 0.15))
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var burn_val: float = (dmg * float(f_def.get("burn_dps_ratio", 0.10)) * PlayerData.get_flame_dmg_multiplier() if not f_def.is_empty() else 0.0) + PlayerData.get_core_burn_dps()
	var poise_mult: float = PlayerData.get_poise_dmg_multiplier()
	var aim_target: Vector2 = pl.get_global_mouse_position()
	var aim_dir: Vector2 = (aim_target - pl.global_position).normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.RIGHT

	if behavior == "pull_pulse":
		pl._start_skill_pose(aim_dir, 0.28, "cast")
		var pull_spot: Vector2 = pl.global_position + aim_dir * 68.0
		pl._spawn_skill_vfx("pull_pulse", pull_spot + Vector2(0, -18), aim_dir, rad_px, 0.46, Color("#E0FBFC"), Color("#70D6FF"), Color("#0077B6"))
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -72), "HẤP CHƯỞNG!", Color("#70D6FF"))
		var hit_pull: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var to_spot: Vector2 = (pull_spot - enemy_node.global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, to_spot * absf(kb), r_pen, burn_val, 0.0, 1.0, 24.0 * poise_mult)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#70D6FF"), to_spot, 10)
						hit_pull = true
		if hit_pull:
			EventBus.trigger_hitstop(0.024, 0.12)

	elif behavior == "melee_burst":
		var is_bat_cuc: bool = (skill_id == "bat_cuc_bang")
		pl._start_skill_pose(aim_dir, 0.26, "weapon")
		pl.lunge_vel = aim_dir * (420.0 if is_bat_cuc else 330.0)
		var hit_center: Vector2 = pl.global_position + aim_dir * (60.0 if is_bat_cuc else 52.0)
		pl._spawn_skill_vfx(
			"bat_cuc_bang" if is_bat_cuc else "toai_thach",
			hit_center + Vector2(0, -18),
			aim_dir,
			rad_px,
			0.40 if is_bat_cuc else 0.36,
			pl.active_core_col,
			Color("#FF9F1C") if is_bat_cuc else pl.active_mid_col,
			pl.active_outer_col
		)
		pl._spawn_hit_sparks(hit_center + Vector2(0, -20), pl.active_mid_col, aim_dir, 20 if is_bat_cuc else 16)
		VfxAssets.spawn_dust_puff(pl.get_parent(), hit_center + Vector2(0, 8), Color(0.82, 0.76, 0.68, 0.50), 9, 145.0, 1.4)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(7.8 if is_bat_cuc else 6.0, 0.20)
		var sk_title: String = str(sdef.get("name", "Đấu Kỹ")).to_upper() + "!"
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -72), sk_title, Color("#FF9F1C"))
		var burst_poise: float = (48.0 if is_bat_cuc else 34.0) * poise_mult
		var hit_any: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if hit_center.distance_to(enemy_node.global_position) <= rad_px:
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, aim_dir * kb, r_pen, burn_val, 0.0, 1.0, burst_poise)
						hit_any = true
		if hit_any:
			EventBus.trigger_hitstop(0.038 if is_bat_cuc else 0.028, 0.09)

	elif behavior == "flame_dash":
		var start_p: Vector2 = pl.global_position
		var burst_pt: Vector2 = start_p + aim_dir * 135.0
		pl.dash_dir = aim_dir
		pl.dash_duration_cur = 0.22
		pl.dash_timer = 0.22
		pl.dash_speed_override = 0.0
		pl.invuln_timer = 0.35
		pl._spawn_dash_afterimage()
		pl._spawn_skill_vfx("flame_dash", start_p + Vector2(0, -14), aim_dir, rad_px, 0.38, pl.active_core_col, Color("#FF9F1C"), Color("#E63946"), { "end_world_pos": burst_pt + Vector2(0, -14) })
		pl._spawn_hit_sparks(start_p + Vector2(0, -12), Color("#FF9F1C"), -aim_dir, 18)
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.screen_shake_requested.emit(5.0, 0.14)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -72), "BẠO BỘ!", Color("#FF9F1C"))
		var mid_pt: Vector2 = start_p + aim_dir * 75.0
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if enemy_node.global_position.distance_to(start_p) <= rad_px or enemy_node.global_position.distance_to(mid_pt) <= rad_px:
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, aim_dir * kb, r_pen, burn_val, 0.0, 1.0, 24.0 * poise_mult)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FF9F1C"), aim_dir, 10)

	elif behavior == "sonic_stun":
		pl._start_skill_pose(aim_dir, 0.30, "cast")
		pl._spawn_skill_vfx("sonic_stun", pl.global_position + Vector2(0, -26), aim_dir, rad_px, 0.56, Color("#FFF8D6"), Color("#FFD166"), Color("#FF9F1C"), { "follow_target": pl, "follow_offset": Vector2(0, -26) })
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -26), Color("#FFD166"), Vector2.RIGHT, 22)
		var stun_s: float = float(sdef.get("stun_sec", 1.8))
		var core_burn: float = PlayerData.get_core_burn_dps()
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.screen_shake_requested.emit(7.5, 0.24)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -78), "SƯ TỬ NGÂM!", Color("#FFD166"))
		var hit_s: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, core_burn, 0.0, 1.0, 38.0 * poise_mult)
						hit_s = true
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_s)
		if hit_s:
			EventBus.trigger_hitstop(0.032, 0.10)

	elif behavior == "flame_shield":
		pl._start_skill_pose(aim_dir, 0.28, "weapon")
		pl.invuln_timer = maxf(pl.invuln_timer, 1.25)
		pl._spawn_skill_vfx("flame_shield", pl.global_position + Vector2(0, -24), aim_dir, rad_px, 1.25, pl.active_core_col, pl.active_mid_col, pl.active_outer_col, { "follow_target": pl, "follow_offset": Vector2(0, -24) })
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), pl.active_mid_col, Vector2.RIGHT, 24)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(7.2, 0.22)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -78), "LỤC HỢP DU THÂN XÍCH! (MIỄN THƯƠNG)", Color("#FF9F1C"))
		var hit_sh: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 36.0 * poise_mult)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), pl.active_mid_col, push_d, 10)
						hit_sh = true
		if hit_sh:
			EventBus.trigger_hitstop(0.032, 0.10)

	elif behavior == "wing_cyclone":
		pl._start_skill_pose(aim_dir, 0.32, "weapon")
		pl.lunge_vel = aim_dir * 490.0
		pl.invuln_timer = maxf(pl.invuln_timer, 0.45)
		pl._spawn_skill_vfx("wing_cyclone", pl.global_position + Vector2(0, -24), aim_dir, rad_px, 0.44, Color("#F3D5FF"), Color("#C77DFF"), Color("#7B2CBF"), { "follow_target": pl, "follow_offset": Vector2(0, -24) })
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), Color("#C77DFF"), -aim_dir, 22)
		EventBus.audio_sfx_requested.emit("dash_whoosh")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(6.8, 0.20)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -78), "TỬ VÂN DỰC KÍCH!", Color("#C77DFF"))
		var cyc_center: Vector2 = pl.global_position + aim_dir * 68.0
		var hit_w: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if cyc_center.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 34.0 * poise_mult)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#C77DFF"), push_d, 12)
						hit_w = true
		if hit_w:
			EventBus.trigger_hitstop(0.030, 0.10)

	elif behavior == "flame_buff":
		pl._start_skill_pose(aim_dir, 0.34, "cast")
		PlayerData.is_flame_buff_active = true
		pl.flame_buff_timer = float(sdef.get("buff_duration", 10.0))
		pl._refresh_flame_shader()
		EventBus.stats_changed.emit()
		pl._spawn_skill_vfx("flame_buff", pl.global_position + Vector2(0, -16), Vector2.UP, rad_px, 0.62, Color("#FFF3B0"), Color("#FF4D6D"), Color("#9D0208"), { "follow_target": pl, "follow_offset": Vector2(0, -16) })
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -20), Color("#FF4D6D"), Vector2.UP, 26)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.screen_shake_requested.emit(8.5, 0.26)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -82), "THIÊN HỎA TAM HUYỀN BIẾN! (+45% ATK)", Color("#FF4D6D"))
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 32.0 * poise_mult)

	elif behavior == "poison_palm":
		pl._start_skill_pose(aim_dir, 0.28, "cast")
		var palm_center: Vector2 = pl.global_position + aim_dir * 72.0
		pl._spawn_skill_vfx("poison_palm", pl.global_position + Vector2(0, -22), aim_dir, rad_px, 0.46, Color("#B7E4C7"), Color("#52B788"), Color("#1B4332"))
		pl._spawn_hit_sparks(palm_center + Vector2(0, -20), Color("#52B788"), aim_dir, 20)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(6.5, 0.18)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -78), "LẠC ĐỘC ÁM CHƯỞNG! (-30% DEF)", Color("#52B788"))
		var hit_p: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if palm_center.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.30, 10.0)
					if enemy_node.has_method("apply_poison_detonate"):
						enemy_node.apply_poison_detonate(dmg * 0.65, 6.0)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 30.0 * poise_mult)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#2EC4B6"), push_d, 12)
						hit_p = true
		if hit_p:
			EventBus.trigger_hitstop(0.030, 0.10)

	elif behavior == "thunder_blink":
		# TAM THIÊN LÔI ĐỘNG: Chớp lôi tốc độ cao 175px + 0.45s bất tử + Sét giật dọc quỹ đạo & nổ Lôi Ảnh tại chỗ cũ!
		pl.is_attacking = false
		pl.attack_follow_hold_timer = 0.0
		pl.weapon_trail_active = false
		if absf(aim_dir.x) > 0.05:
			pl.body_sprite.flip_h = aim_dir.x < 0.0
		var start_p: Vector2 = pl.global_position
		var end_p: Vector2 = start_p + aim_dir * 175.0
		if pl.cam != null and pl.cam.limit_right > pl.cam.limit_left:
			end_p.x = clampf(end_p.x, float(pl.cam.limit_left) + 32.0, float(pl.cam.limit_right) - 32.0)
			end_p.y = clampf(end_p.y, float(pl.cam.limit_top) + 32.0, float(pl.cam.limit_bottom) - 32.0)
		pl.dash_dir = aim_dir
		pl.dash_duration_cur = 0.16
		pl.dash_timer = 0.16
		pl.dash_speed_override = 1100.0
		pl.invuln_timer = maxf(pl.invuln_timer, 0.45)
		pl._spawn_dash_afterimage()
		pl._spawn_skill_vfx(
			"thunder_blink",
			start_p + Vector2(0, -22),
			aim_dir,
			rad_px,
			0.44,
			Color("#F8F9FA"),
			Color("#B8C0FF"),
			Color("#7B2CBF"),
			{ "end_world_pos": end_p + Vector2(0, -22) }
		)
		VfxAssets.spawn_spark_burst(pl.get_parent(), start_p + Vector2(0, -20), Color("#E0FBFC"), Color("#9D4EDD"), 24, 110.0, 290.0, 0.38, -aim_dir, 180.0, 0.30, 0.65, true)
		VfxAssets.spawn_spark_burst(pl.get_parent(), end_p + Vector2(0, -20), Color("#FFFFFF"), Color("#72EFDD"), 16, 85.0, 230.0, 0.32, aim_dir, 150.0, 0.25, 0.55, true)
		EventBus.audio_sfx_requested.emit("thunder_blink")
		EventBus.screen_shake_requested.emit(6.5, 0.18)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -78), "TAM THIÊN LÔI ĐỘNG!", Color("#C77DFF"))
		var path_width: float = maxf(66.0, rad_px * 0.58)
		var hit_tb: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				var closest_pt: Vector2 = Geometry2D.get_closest_point_to_segment(enemy_node.global_position, start_p, end_p)
				var on_path: bool = enemy_node.global_position.distance_to(closest_pt) <= path_width
				var in_afterimage: bool = enemy_node.global_position.distance_to(start_p) <= rad_px
				if on_path or in_afterimage:
					var push_d: Vector2 = (enemy_node.global_position - start_p).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("apply_slow"):
						enemy_node.apply_slow(0.45, 2.2)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 34.0 * poise_mult)
						VfxAssets.spawn_spark_burst(pl.get_parent(), enemy_node.global_position + Vector2(0, -24), Color("#E0FBFC"), Color("#C77DFF"), 12, 90.0, 220.0, 0.30, push_d, 150.0, 0.26, 0.55, true)
						hit_tb = true
		if hit_tb:
			EventBus.trigger_hitstop(0.028, 0.10)

	elif behavior == "golden_roar":
		# SƯ HỔ TOÁI KIM NGÂM: Sóng âm Sư Hổ nón vàng kim ±48° phá giáp -35% + làm choáng + phá thế mạnh!
		pl._start_skill_pose(aim_dir, 0.32, "cast")
		pl._spawn_skill_vfx("golden_roar", pl.global_position + Vector2(0, -24), aim_dir, rad_px, 0.54, Color("#FFF8D6"), Color("#FFD166"), Color("#E07A00"), { "follow_target": pl, "follow_offset": Vector2(0, -24) })
		pl._spawn_hit_sparks(pl.global_position + aim_dir * 32.0 + Vector2(0, -24), Color("#FFD166"), aim_dir, 24)
		var stun_s: float = float(sdef.get("stun_sec", 2.0))
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.screen_shake_requested.emit(8.5, 0.26)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -80), "SƯ HỔ TOÁI KIM NGÂM!", Color("#FFD166"))
		var hit_gr: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				var to_en: Vector2 = enemy_node.global_position - pl.global_position
				var dist: float = to_en.length()
				if dist <= rad_px:
					var push_d: Vector2 = to_en.normalized() if dist > 4.0 else aim_dir
					if aim_dir.dot(push_d) >= 0.25 or dist <= 95.0:
						if enemy_node.has_method("apply_def_shred"):
							enemy_node.apply_def_shred(0.35, 8.0)
						if enemy_node.has_method("apply_stun"):
							enemy_node.apply_stun(stun_s)
						if enemy_node.has_method("receive_hit"):
							enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 48.0 * poise_mult)
							pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FFD166"), push_d, 12)
							hit_gr = true
		if hit_gr:
			EventBus.trigger_hitstop(0.036, 0.09)

	elif behavior == "mountain_seal":
		# ĐẾ ẤN QUYẾT — KHAI SƠN ẤN: Giáng Cổ Ấn vàng ngọc xuống điểm trỏ (trong 220px), làm choáng & phá thế cực mạnh!
		pl._start_skill_pose(aim_dir, 0.34, "cast")
		var m_vec: Vector2 = aim_target - pl.global_position
		var m_dist: float = m_vec.length()
		var seal_pos: Vector2 = (pl.global_position + aim_dir * 135.0) if m_dist < 24.0 else (pl.global_position + aim_dir * minf(m_dist, 220.0))
		pl._spawn_skill_vfx("mountain_seal", seal_pos, aim_dir, rad_px, 0.68, Color("#FFF8D6"), Color("#FFD166"), Color("#2EC4B6"), { "z_index": 6 })
		VfxAssets.spawn_spark_burst(pl.get_parent(), seal_pos + Vector2(0, -16), Color("#FFF8D6"), Color("#FFD166"), 28, 120.0, 310.0, 0.48, Vector2.UP, 180.0, 0.32, 0.72, true)
		VfxAssets.spawn_dust_puff(pl.get_parent(), seal_pos + Vector2(0, 8), Color(0.95, 0.85, 0.55, 0.52), 12, 165.0, 1.75)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.audio_sfx_requested.emit("poise_break")
		EventBus.screen_shake_requested.emit(10.5, 0.30)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -82), "ĐẾ ẤN QUYẾT — KHAI SƠN ẤN!", Color("#FFD166"))
		var stun_ms: float = float(sdef.get("stun_sec", 1.6))
		var hit_ms: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if seal_pos.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - seal_pos).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.25, 6.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_ms)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.0, 1.0, 58.0 * poise_mult)
						VfxAssets.spawn_spark_burst(pl.get_parent(), enemy_node.global_position + Vector2(0, -24), Color("#FFFFFF"), Color("#FFD166"), 14, 95.0, 235.0, 0.34, push_d, 150.0, 0.28, 0.58, true)
						hit_ms = true
		if hit_ms:
			EventBus.trigger_hitstop(0.045, 0.08)

	elif behavior == "flame_clone":
		# HỎA LIÊN PHÂN THÂN: Triệu hồi 3 quả cầu Dị Hỏa xoay quanh thân trong 6.5s, tự động đốt nổ địch mỗi 0.55s!
		pl._start_skill_pose(aim_dir, 0.30, "cast")
		var fc_dur: float = float(sdef.get("buff_duration", 6.5))
		pl.flame_clone_timer = fc_dur
		pl.flame_clone_tick = 0.10
		pl.flame_clone_dmg = dmg * 0.55
		pl.flame_clone_radius = maxf(110.0, rad_px)
		pl.flame_clone_r_pen = r_pen
		pl._spawn_skill_vfx(
			"flame_clone",
			pl.global_position + Vector2(0, -24),
			aim_dir,
			pl.flame_clone_radius,
			fc_dur,
			pl.active_core_col,
			pl.active_mid_col,
			pl.active_outer_col,
			{ "follow_target": pl, "follow_offset": Vector2(0, -24) }
		)
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), pl.active_mid_col, Vector2.UP, 24)
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.screen_shake_requested.emit(5.5, 0.18)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -80), "HỎA LIÊN PHÂN THÂN!", pl.active_mid_col)

	elif behavior == "tyrant_claw":
		# ĐẠI LIỆT PHÁCH QUAN TRẢO (Bá Thương Liễu Kình): Vọt mạnh tung 4 vết cào kim quang nghiền nát khiên & phá thế cực đại + Choáng 2s!
		pl._start_skill_pose(aim_dir, 0.34, "weapon")
		pl.lunge_vel = aim_dir * 465.0
		var claw_pos: Vector2 = pl.global_position + aim_dir * 78.0
		pl._spawn_skill_vfx("tyrant_claw", claw_pos + Vector2(0, -14), aim_dir, rad_px, 0.54, Color("#FFF8D6"), Color("#FFD166"), Color("#FF7B00"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), claw_pos + Vector2(0, -20), Color("#FFFFFF"), Color("#FFD166"), 28, 125.0, 320.0, 0.44, aim_dir, 140.0, 0.30, 0.72, true)
		VfxAssets.spawn_dust_puff(pl.get_parent(), claw_pos + Vector2(0, 10), Color(0.96, 0.84, 0.46, 0.54), 12, 175.0, 1.7)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.audio_sfx_requested.emit("poise_break")
		EventBus.screen_shake_requested.emit(10.8, 0.30)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -84), "ĐẠI LIỆT PHÁCH QUAN TRẢO!!", Color("#FFD166"))
		var stun_tc: float = float(sdef.get("stun_sec", 2.0))
		var hit_tc: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if claw_pos.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.30, 8.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_tc)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val, 0.20, 1.0, 68.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FFD166"), push_d, 16)
						hit_tc = true
		if hit_tc:
			EventBus.trigger_hitstop(0.046, 0.08)

	elif behavior == "glazed_lotus_vortex":
		# LƯU LY LIÊN TÂM ẤN (Song Dị Hỏa #19 + #14): Xoáy Lưu Ly xanh-tím hút tụ địch -> Nở Liên Hoa 8 Cánh Nội Thiêu + Choáng 1.6s!
		pl._start_skill_pose(aim_dir, 0.36, "cast")
		var v_vec: Vector2 = aim_target - pl.global_position
		var v_dist: float = v_vec.length()
		var vortex_pos: Vector2 = (pl.global_position + aim_dir * 135.0) if v_dist < 24.0 else (pl.global_position + aim_dir * minf(v_dist, 225.0))
		pl._spawn_skill_vfx("glazed_lotus_vortex", vortex_pos + Vector2(0, -18), aim_dir, rad_px, 0.64, Color("#FFFFFF"), Color("#00F5D4"), Color("#9D4EDD"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), vortex_pos + Vector2(0, -20), Color("#FFFFFF"), Color("#00F5D4"), 26, 110.0, 290.0, 0.48, Vector2.UP, 180.0, 0.30, 0.72, true)
		VfxAssets.spawn_spark_burst(pl.get_parent(), vortex_pos + Vector2(0, -20), Color("#FFFFFF"), Color("#E0AAFF"), 20, 95.0, 250.0, 0.46, Vector2.UP, 180.0, 0.28, 0.66, true)
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(11.5, 0.34)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -86), "LƯU LY LIÊN TÂM ẤN!!", Color("#00F5D4"))
		var stun_gl: float = float(sdef.get("stun_sec", 1.6))
		var inner_true_bonus: float = float(PlayerData.get_soul()) * 1.55
		var hit_gl: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if vortex_pos.distance_to(enemy_node.global_position) <= rad_px:
					var pull_d: Vector2 = (vortex_pos - enemy_node.global_position).normalized()
					if pull_d == Vector2.ZERO:
						pull_d = aim_dir
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_gl)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, pull_d * absf(kb), r_pen, burn_val * 1.45, 0.25, 1.0, 54.0 * poise_mult)
						enemy_node.receive_hit(inner_true_bonus, Vector2.ZERO, 1.0, 0.0, 1.0, 1.0, 16.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#E0AAFF"), pull_d, 14)
						hit_gl = true
		if hit_gl:
			EventBus.trigger_hitstop(0.048, 0.08)

	elif behavior == "ocean_seal":
		# ĐẾ ẤN QUYẾT — PHIÊN HẢI ẤN (Cổ Tộc Ch.07): Trận Ấn Kim-Thanh giáng sóng thần! CỘNG HƯỞNG 1.8x BẠO KÍCH lên địch đang Phá Giáp / Choáng (combo Khai Sơn Ấn)!
		pl._start_skill_pose(aim_dir, 0.36, "cast")
		var o_vec: Vector2 = aim_target - pl.global_position
		var o_dist: float = o_vec.length()
		var seal_pos: Vector2 = (pl.global_position + aim_dir * 145.0) if o_dist < 24.0 else (pl.global_position + aim_dir * minf(o_dist, 240.0))
		pl._spawn_skill_vfx("ocean_seal", seal_pos + Vector2(0, -14), aim_dir, rad_px, 0.66, Color("#FFFFFF"), Color("#38BDF8"), Color("#FFD166"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), seal_pos + Vector2(0, -18), Color("#FFFFFF"), Color("#38BDF8"), 28, 125.0, 320.0, 0.46, aim_dir, 150.0, 0.30, 0.72, true)
		VfxAssets.spawn_spark_burst(pl.get_parent(), seal_pos + Vector2(0, -18), Color("#FFF8D6"), Color("#FFD166"), 20, 100.0, 260.0, 0.44, Vector2.UP, 180.0, 0.28, 0.64, true)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.audio_sfx_requested.emit("poise_break")
		EventBus.screen_shake_requested.emit(12.2, 0.34)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -86), "ĐẾ ẤN QUYẾT — PHIÊN HẢI ẤN!!", Color("#38BDF8"))
		var stun_os: float = float(sdef.get("stun_sec", 2.0))
		var hit_os: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if seal_pos.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - seal_pos).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					var has_resonance: bool = (("def_shred_timer" in enemy_node and float(enemy_node.get("def_shred_timer")) > 0.0) or ("stun_timer" in enemy_node and float(enemy_node.get("stun_timer")) > 0.0))
					var final_os_dmg: float = dmg * (1.80 if has_resonance else 1.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_os)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(final_os_dmg, push_d * kb, r_pen, burn_val * 1.25, 0.28 if has_resonance else 0.10, 1.0, 68.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						if has_resonance:
							EventBus.floating_text_requested.emit(enemy_node.global_position + Vector2(0, -108), "✦ CỘNG HƯỞNG ĐẾ ẤN 1.8x!", Color("#FFD166"))
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FFD166") if has_resonance else Color("#38BDF8"), push_d, 16)
						hit_os = true
		if hit_os:
			EventBus.trigger_hitstop(0.048, 0.08)

	elif behavior == "flame_buff_tier2":
		# THIÊN HỎA TAM HUYỀN BIẾN — NHỊ BIẾN (Ch.07): 16s bùng phát Song Dị Hỏa (+65% ATK, +30% SPD, đòn đánh thường phóng 2 sóng Lưu Ly Hỏa)!
		pl._start_skill_pose(aim_dir, 0.34, "cast")
		PlayerData.is_flame_buff_active = true
		PlayerData.is_nhi_bien_active = true
		pl.flame_buff_timer = float(sdef.get("buff_duration", 16.0))
		pl._refresh_flame_shader()
		pl._spawn_skill_vfx("flame_buff_tier2", pl.global_position + Vector2(0, -22), Vector2.UP, rad_px, 0.68, Color("#FFFFFF"), Color("#00F5D4"), Color("#E0AAFF"), { "follow_target": pl, "follow_offset": Vector2(0, -22) })
		VfxAssets.spawn_spark_burst(pl.get_parent(), pl.global_position + Vector2(0, -24), Color("#FFFFFF"), Color("#00F5D4"), 26, 110.0, 290.0, 0.48, Vector2.UP, 180.0, 0.30, 0.72, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.screen_shake_requested.emit(10.0, 0.30)
		EventBus.stats_changed.emit()
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -86), "THIÊN HỎA TAM HUYỀN BIẾN — NHỊ BIẾN!! (+65% ATK)", Color("#00F5D4"))
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val * 1.35, 0.0, 1.0, 38.0 * poise_mult)

	elif behavior == "space_lock":
		# KHÔNG GIAN PHONG TỎA (Đặc Quyền Đấu Tông Ch.08): Đóng băng hư không thành lồng giam không gian — Phá khiên, Choáng 2.5s & -25% DEF!
		pl._start_skill_pose(aim_dir, 0.34, "cast")
		var sl_vec: Vector2 = aim_target - pl.global_position
		var sl_pos: Vector2 = (pl.global_position + aim_dir * 135.0) if sl_vec.length() < 24.0 else (pl.global_position + aim_dir * minf(sl_vec.length(), 255.0))
		pl._spawn_skill_vfx("space_lock", sl_pos + Vector2(0, -16), aim_dir, rad_px, 0.72, Color("#FFFFFF"), Color("#72EFDD"), Color("#48BFE3"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), sl_pos + Vector2(0, -20), Color("#FFFFFF"), Color("#72EFDD"), 28, 95.0, 270.0, 0.48, Vector2.UP, 180.0, 0.28, 0.68, true)
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.audio_sfx_requested.emit("poise_break")
		EventBus.screen_shake_requested.emit(11.0, 0.32)
		EventBus.shockwave_requested.emit(sl_pos, rad_px * 1.40, 0.056, Color("#72EFDD"), 0.42)
		EventBus.screen_flash_requested.emit(Color("#72EFDD"), 0.22, 0.18)
		VfxAssets.spawn_ground_crater(pl.get_parent(), sl_pos, rad_px * 0.72, Color("#48BFE3"), 2.8)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -88), "KHÔNG GIAN PHONG TỎA!! (ĐẤU TÔNG)", Color("#72EFDD"))
		var stun_sl: float = float(sdef.get("stun_sec", 2.5))
		var hit_sl: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if sl_pos.distance_to(enemy_node.global_position) <= rad_px:
					var pull_d: Vector2 = (sl_pos - enemy_node.global_position).normalized()
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.25, 7.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_sl)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, pull_d * kb, r_pen, burn_val, 0.15, 1.0, 74.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#72EFDD"), pull_d, 14)
						hit_sl = true
		if hit_sl:
			EventBus.trigger_hitstop(0.048, 0.08)

	elif behavior == "emperor_five_seals":
		# ĐẾ ẤN QUYẾT — NGŨ ẤN HỢP NHẤT: CỔ ĐẾ ẤN (Chuẩn Thiên Giai Ch.08): Hợp 5 Ấn Cổ Tộc (Khai Sơn·Phiên Hải·Phúc Địa·Nhân Hoàng·Cổ Đế) giáng thiên địa!
		pl._start_skill_pose(aim_dir, 0.40, "cast")
		var ef_vec: Vector2 = aim_target - pl.global_position
		var ef_pos: Vector2 = (pl.global_position + aim_dir * 155.0) if ef_vec.length() < 24.0 else (pl.global_position + aim_dir * minf(ef_vec.length(), 270.0))
		pl._spawn_skill_vfx("emperor_five_seals", ef_pos + Vector2(0, -18), aim_dir, rad_px, 0.78, Color("#FFFFFF"), Color("#FFD166"), Color("#FF595E"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), ef_pos + Vector2(0, -20), Color("#FFF8D6"), Color("#FFD166"), 36, 130.0, 360.0, 0.52, Vector2.UP, 180.0, 0.32, 0.78, true)
		VfxAssets.spawn_spark_burst(pl.get_parent(), ef_pos + Vector2(0, -20), Color("#FFFFFF"), Color("#FF595E"), 24, 110.0, 310.0, 0.48, aim_dir, 160.0, 0.28, 0.68, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(16.0, 0.45)
		EventBus.shockwave_requested.emit(ef_pos, rad_px * 1.55, 0.068, Color("#FFD166"), 0.48)
		EventBus.screen_flash_requested.emit(Color("#FFD166"), 0.34, 0.24)
		VfxAssets.spawn_ground_crater(pl.get_parent(), ef_pos, rad_px * 0.88, Color("#FF595E"), 3.4)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -92), "ĐẾ ẤN QUYẾT — NGŨ ẤN HỢP NHẤT: CỔ ĐẾ ẤN!!", Color("#FFD166"))
		var stun_ef: float = float(sdef.get("stun_sec", 2.4))
		var hit_ef: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if ef_pos.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - ef_pos).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					var has_res5: bool = (("def_shred_timer" in enemy_node and float(enemy_node.get("def_shred_timer")) > 0.0) or ("stun_timer" in enemy_node and float(enemy_node.get("stun_timer")) > 0.0))
					var final_ef_dmg: float = dmg * (1.65 if has_res5 else 1.0)
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.40, 10.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_ef)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(final_ef_dmg, push_d * kb, r_pen, burn_val * 1.5, 0.35 if has_res5 else 0.20, 1.0, 92.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						if has_res5:
							EventBus.floating_text_requested.emit(enemy_node.global_position + Vector2(0, -112), "✦ NGŨ ẤN CỘNG HƯỞNG 1.65x!!", Color("#FF595E"))
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FFD166"), push_d, 18)
						hit_ef = true
		if hit_ef:
			EventBus.trigger_hitstop(0.056, 0.08)

	elif behavior == "flame_buff_tier3":
		# THIÊN HỎA TAM HUYỀN BIẾN — TAM BIẾN (Phần Viêm Cốc Ch.08): 18s Hợp Nhất Tam Dị Hỏa (+85% ATK, +45% SPD, -30% CD, Đánh Thường Phóng 3 Sóng Hỏa)!
		pl._start_skill_pose(aim_dir, 0.36, "cast")
		PlayerData.is_flame_buff_active = true
		PlayerData.is_nhi_bien_active = true
		PlayerData.is_tam_bien_active = true
		pl.flame_buff_timer = float(sdef.get("buff_duration", 18.0))
		pl._refresh_flame_shader()
		pl._spawn_skill_vfx("flame_buff_tier3", pl.global_position + Vector2(0, -22), Vector2.UP, rad_px, 0.78, Color("#FFFFFF"), Color("#FFD166"), Color("#C77DFF"), { "follow_target": pl, "follow_offset": Vector2(0, -22) })
		VfxAssets.spawn_spark_burst(pl.get_parent(), pl.global_position + Vector2(0, -24), Color("#FFFFFF"), Color("#FFD166"), 32, 125.0, 340.0, 0.52, Vector2.UP, 180.0, 0.32, 0.76, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.screen_shake_requested.emit(13.0, 0.38)
		EventBus.shockwave_requested.emit(pl.global_position, rad_px * 1.35, 0.048, Color("#FFD166"), 0.42)
		EventBus.screen_flash_requested.emit(Color("#C77DFF"), 0.26, 0.20)
		EventBus.stats_changed.emit()
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -90), "THIÊN HỎA TAM HUYỀN BIẾN — TAM BIẾN!! (+85% ATK · -30% CD)", Color("#FFD166"))
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val * 1.65, 0.15, 1.0, 56.0 * poise_mult)

	elif behavior == "soul_shock_palm":
		# HỒN KỸ: KINH HỒN CHƯỞNG (Linh Cảnh Đỉnh Phong Ch.08): Chưởng ấn Linh Hồn xuyên 85% giáp + cộng thẳng 2.8x SOUL gây Choáng 2.0s!
		pl._start_skill_pose(aim_dir, 0.32, "cast")
		var sp_vec: Vector2 = aim_target - pl.global_position
		var sp_pos: Vector2 = (pl.global_position + aim_dir * 130.0) if sp_vec.length() < 24.0 else (pl.global_position + aim_dir * minf(sp_vec.length(), 250.0))
		pl._spawn_skill_vfx("soul_shock_palm", sp_pos + Vector2(0, -18), aim_dir, rad_px, 0.66, Color("#FFFFFF"), Color("#E0AAFF"), Color("#7B2CBF"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), sp_pos + Vector2(0, -22), Color("#FFFFFF"), Color("#E0AAFF"), 28, 110.0, 300.0, 0.46, aim_dir, 140.0, 0.28, 0.66, true)
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(12.5, 0.34)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -88), "HỒN KỸ: KINH HỒN CHƯỞNG!! (XUYÊN HỒN)", Color("#E0AAFF"))
		var soul_bonus: float = float(PlayerData.get_soul()) * 2.8
		var stun_sp: float = float(sdef.get("stun_sec", 2.0))
		var hit_sp: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if sp_pos.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - sp_pos).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_sp)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg + soul_bonus, push_d * kb, maxf(r_pen, 0.85), burn_val * 0.6, 0.25, 1.0, 78.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#E0AAFF"), push_d, 15)
						hit_sp = true
		if hit_sp:
			EventBus.trigger_hitstop(0.050, 0.08)

	elif behavior == "thunder_clone":
		# TAM THIÊN LÔI HUYỄN THÂN (Ch.08): Ngưng tụ Lôi Huyễn Phân Thân 9s tự giật sét quanh thân + né tránh 0.6s & nổ Ngũ Sắc Đan Lôi!
		pl._start_skill_pose(aim_dir, 0.32, "cast")
		pl.invuln_timer = maxf(pl.invuln_timer, 0.60)
		pl.flame_clone_timer = 9.0
		pl.flame_clone_tick = 0.25
		pl.flame_clone_dmg = dmg * 0.52
		pl.flame_clone_radius = rad_px
		pl.flame_clone_r_pen = maxf(r_pen, 0.72)
		pl._spawn_skill_vfx("thunder_clone", pl.global_position + Vector2(0, -22), aim_dir, rad_px, 0.72, Color("#FFFFFF"), Color("#C77DFF"), Color("#FFD166"), { "follow_target": pl, "follow_offset": Vector2(0, -22) })
		VfxAssets.spawn_spark_burst(pl.get_parent(), pl.global_position + Vector2(0, -24), Color("#FFFFFF"), Color("#C77DFF"), 30, 120.0, 320.0, 0.48, Vector2.UP, 180.0, 0.28, 0.72, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(12.0, 0.34)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -88), "TAM THIÊN LÔI HUYỄN THÂN!! (9s LÔI PHÂN THÂN)", Color("#C77DFF"))
		var hit_tl: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(1.2)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg * 0.85, push_d * kb, r_pen, burn_val, 0.22, 1.0, 58.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FFD166"), push_d, 14)
						hit_tl = true
		if hit_tl:
			EventBus.trigger_hitstop(0.044, 0.08)

	elif behavior == "spatial_giant_palm":
		# KHÔNG GIAN ĐẠI THỦ ẤN (Đặc Quyền Đấu Tôn Ch.09): Bàn tay không gian bạc khổng lồ gom địch về tâm, bỏ qua 75% giáp vật lý, phá khiên & Choáng 2.6s!
		pl._start_skill_pose(aim_dir, 0.36, "cast")
		var sgp_vec: Vector2 = aim_target - pl.global_position
		var sgp_pos: Vector2 = (pl.global_position + aim_dir * 145.0) if sgp_vec.length() < 24.0 else (pl.global_position + aim_dir * minf(sgp_vec.length(), 280.0))
		pl._spawn_skill_vfx("spatial_giant_palm", sgp_pos + Vector2(0, -18), aim_dir, rad_px, 0.76, Color("#FFFFFF"), Color("#72EFDD"), Color("#7B2CBF"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), sgp_pos + Vector2(0, -22), Color("#FFFFFF"), Color("#72EFDD"), 34, 115.0, 320.0, 0.50, Vector2.UP, 180.0, 0.30, 0.74, true)
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.audio_sfx_requested.emit("poise_break")
		EventBus.screen_shake_requested.emit(13.5, 0.36)
		EventBus.shockwave_requested.emit(sgp_pos, rad_px * 1.48, 0.064, Color("#72EFDD"), 0.46)
		EventBus.screen_flash_requested.emit(Color("#72EFDD"), 0.26, 0.20)
		VfxAssets.spawn_ground_crater(pl.get_parent(), sgp_pos, rad_px * 0.80, Color("#7B2CBF"), 3.2)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -90), "KHÔNG GIAN ĐẠI THỦ ẤN!! (XUYÊN GIÁP)", Color("#72EFDD"))
		var stun_sgp: float = float(sdef.get("stun_sec", 2.6))
		var hit_sgp: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if sgp_pos.distance_to(enemy_node.global_position) <= rad_px:
					var pull_d: Vector2 = (sgp_pos - enemy_node.global_position).normalized()
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.35, 8.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_sgp)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, pull_d * absf(kb), r_pen, burn_val * 1.2, 0.75, 1.0, 86.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#72EFDD"), pull_d, 16)
						hit_sgp = true
		if hit_sgp:
			EventBus.trigger_hitstop(0.052, 0.08)

	elif behavior == "creation_heaven_palm":
		# ĐẠI THIÊN TẠO HÓA CHƯỞNG (Thiên Giai Sơ Cấp Ch.09): Chưởng Ấn Tạo Hóa Thánh Giả giáng trời — Phá Khiên, -45% DEF 10s, Choáng 3.0s, 110 Phá Thế!
		pl._start_skill_pose(aim_dir, 0.42, "cast")
		var chp_vec: Vector2 = aim_target - pl.global_position
		var chp_pos: Vector2 = (pl.global_position + aim_dir * 165.0) if chp_vec.length() < 24.0 else (pl.global_position + aim_dir * minf(chp_vec.length(), 300.0))
		pl._spawn_skill_vfx("creation_heaven_palm", chp_pos + Vector2(0, -20), aim_dir, rad_px, 0.86, Color("#FFFFFF"), Color("#FFD166"), Color("#FF4D6D"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), chp_pos + Vector2(0, -24), Color("#FFF8D6"), Color("#FFD166"), 42, 145.0, 390.0, 0.56, Vector2.UP, 180.0, 0.34, 0.84, true)
		VfxAssets.spawn_spark_burst(pl.get_parent(), chp_pos + Vector2(0, -24), Color("#FFFFFF"), Color("#FF4D6D"), 28, 120.0, 340.0, 0.52, aim_dir, 160.0, 0.30, 0.72, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(18.5, 0.50)
		EventBus.shockwave_requested.emit(chp_pos, rad_px * 1.65, 0.074, Color("#FFD166"), 0.52)
		EventBus.screen_flash_requested.emit(Color("#FFD166"), 0.38, 0.28)
		VfxAssets.spawn_ground_crater(pl.get_parent(), chp_pos, rad_px * 0.94, Color("#FF4D6D"), 3.8)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -96), "THIÊN GIAI: ĐẠI THIÊN TẠO HÓA CHƯỞNG!!", Color("#FFD166"))
		var stun_chp: float = float(sdef.get("stun_sec", 3.0))
		var hit_chp: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if chp_pos.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - chp_pos).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.45, 10.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_chp)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val * 1.75, 0.45, 1.0, 110.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), Color("#FFD166"), push_d, 20)
						hit_chp = true
		if hit_chp:
			EventBus.trigger_hitstop(0.062, 0.07)

	elif behavior == "ten_golden_puppets":
		# THẬP TUYỆT KIM KHÔI TRẬN (10 Kim Sắc Thiên Yêu Khôi Ch.09): 14s Đại Trận giảm -50% sát thương nhận vào + liên tục giật Hắc Ma Lôi mỗi 1.2s!
		pl._start_skill_pose(aim_dir, 0.36, "cast")
		var dur_kk: float = float(sdef.get("buff_duration", 14.0))
		var king_mult: float = 1.25 if PlayerData.has_flag("FLAG_KIM_KHOI_THONG_LINH") else 1.0
		PlayerData.is_kim_khoi_tran_active = true
		pl.kim_khoi_tran_timer = dur_kk
		pl.kim_khoi_tran_tick = 1.20
		pl.kim_khoi_tran_dmg = dmg * 0.42 * king_mult
		pl.kim_khoi_tran_rad = rad_px
		pl._refresh_flame_shader()
		pl._spawn_skill_vfx("ten_golden_puppets", pl.global_position + Vector2(0, -20), Vector2.UP, rad_px, 0.85, Color("#FFFFFF"), Color("#FFD166"), Color("#9D4EDD"), { "follow_target": pl, "follow_offset": Vector2(0, -20) })
		VfxAssets.spawn_spark_burst(pl.get_parent(), pl.global_position + Vector2(0, -24), Color("#FFF8D6"), Color("#FFD166"), 36, 130.0, 350.0, 0.52, Vector2.UP, 180.0, 0.32, 0.78, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.audio_sfx_requested.emit("thunder_blink")
		EventBus.screen_shake_requested.emit(14.0, 0.38)
		EventBus.shockwave_requested.emit(pl.global_position, rad_px * 1.4, 0.056, Color("#FFD166"), 0.44)
		EventBus.stats_changed.emit()
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -92), "THẬP TUYỆT KIM KHÔI TRẬN!! (-50% DMG · 10 THIÊN LÔI)", Color("#FFD166"))
		var hit_kk: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(1.8)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg * 0.85 * king_mult, push_d * kb, r_pen, burn_val, 0.25, 1.0, 72.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						hit_kk = true
		if hit_kk:
			EventBus.trigger_hitstop(0.048, 0.08)

	elif behavior == "xiao_clan_crest":
		# TỘC VĂN ĐẤU ĐẾ TIÊU TỘC (Ch.09 Thiên Mộ — Tiêu Huyền Hoán Huyết): Cộng dồn trên Tam Huyền Biến -> +150% ATK, đầy 100% QI & miễn phí QI 2 đại chiêu!
		pl._start_skill_pose(aim_dir, 0.38, "cast")
		var base_tv_dur: float = float(sdef.get("buff_duration", 15.0))
		if PlayerData.has_flag("FLAG_TIEU_HUYEN_OATH"):
			base_tv_dur *= 1.10 # SQ_09_05 Bia Mộ Tiêu Huyền (+10% thời gian duy trì!)
		PlayerData.is_toc_van_active = true
		pl.toc_van_timer = base_tv_dur
		pl.toc_van_free_casts = 2
		PlayerData.current_qi = PlayerData.get_max_qi()
		pl._refresh_flame_shader()
		pl._spawn_skill_vfx("xiao_clan_crest", pl.global_position + Vector2(0, -24), Vector2.UP, rad_px, 0.90, Color("#FFFFFF"), Color("#FF4D6D"), Color("#FFD166"), { "follow_target": pl, "follow_offset": Vector2(0, -24) })
		VfxAssets.spawn_spark_burst(pl.get_parent(), pl.global_position + Vector2(0, -28), Color("#FFFFFF"), Color("#FF4D6D"), 40, 140.0, 380.0, 0.56, Vector2.UP, 180.0, 0.34, 0.84, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.screen_shake_requested.emit(16.0, 0.42)
		EventBus.shockwave_requested.emit(pl.global_position, rad_px * 1.55, 0.068, Color("#FF4D6D"), 0.48)
		EventBus.screen_flash_requested.emit(Color("#FF4D6D"), 0.32, 0.24)
		EventBus.stats_changed.emit()
		EventBus.qi_updated.emit(PlayerData.current_qi, PlayerData.get_max_qi())
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -96), "TỘC VĂN ĐẤU ĐẾ TIÊU TỘC!! (ĐẦY QI · 2 CHIÊU 0 QI)", Color("#FF4D6D"))
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(1.5)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val * 1.5, 0.30, 1.0, 68.0 * poise_mult)

	elif behavior == "yellow_springs_palm":
		# HOÀNG TUYỀN CHỈ & CHƯỞNG (Thiên Giai Trung Cấp Ch.10): Chỉ lực xuyên giáp + Chưởng ấn vàng sẫm hút 6% HP & làm chậm 3s!
		pl._start_skill_pose(aim_dir, 0.38, "cast")
		var ysp_vec: Vector2 = aim_target - pl.global_position
		var ysp_pos: Vector2 = (pl.global_position + aim_dir * 185.0) if ysp_vec.length() < 24.0 else (pl.global_position + aim_dir * minf(ysp_vec.length(), 340.0))
		pl._spawn_skill_vfx("yellow_springs_palm", ysp_pos + Vector2(0, -20), aim_dir, rad_px, 0.82, Color("#FEF08A"), Color("#CA8A04"), Color("#713F12"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), ysp_pos + Vector2(0, -24), Color("#FEF08A"), Color("#CA8A04"), 38, 135.0, 360.0, 0.52, aim_dir, 140.0, 0.32, 0.78, true)
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.audio_sfx_requested.emit("poise_break")
		EventBus.screen_shake_requested.emit(16.0, 0.42)
		EventBus.shockwave_requested.emit(ysp_pos, rad_px * 1.55, 0.068, Color("#CA8A04"), 0.46)
		VfxAssets.spawn_ground_crater(pl.get_parent(), ysp_pos, rad_px * 0.86, Color("#CA8A04"), 3.6)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -94), "THIÊN GIAI: HOÀNG TUYỀN CHỈ & CHƯỞNG!!", Color("#FDE047"))
		var hit_ysp: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if ysp_pos.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - ysp_pos).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_slow"):
						enemy_node.apply_slow(0.45, 3.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(float(sdef.get("stun_sec", 2.4)))
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, push_d * kb, r_pen, burn_val * 1.5, 0.55, 1.0, 118.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						hit_ysp = true
		if hit_ysp:
			var drain_hp: float = PlayerData.get_max_hp() * 0.06 * PlayerData.get_heal_effectiveness_mult()
			PlayerData.current_hp = minf(PlayerData.get_max_hp(), PlayerData.current_hp + drain_hp)
			EventBus.stats_changed.emit()
			EventBus.trigger_hitstop(0.056, 0.08)

	elif behavior == "yellow_springs_wrath":
		# HOÀNG TUYỀN THIÊN NỘ (Thiên Giai Cao Cấp Hồn Kỹ Ch.10): 2.200% SOUL toàn màn hình — Kết liễu quái thường < Bán Thánh & Choáng 4s cả Boss Đấu Thánh!
		pl._start_skill_pose(aim_dir, 0.44, "cast")
		var wrath_dmg: float = float(PlayerData.get_soul()) * 22.0 + dmg * 0.35
		pl._spawn_skill_vfx("yellow_springs_wrath", pl.global_position + Vector2(0, -24), Vector2.UP, rad_px, 0.96, Color("#FFFFFF"), Color("#F59E0B"), Color("#78350F"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), pl.global_position + Vector2(0, -24), Color("#FEF08A"), Color("#F59E0B"), 52, 160.0, 440.0, 0.62, Vector2.UP, 180.0, 0.36, 0.88, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.audio_sfx_requested.emit("skill_stun")
		EventBus.screen_shake_requested.emit(22.0, 0.58)
		EventBus.shockwave_requested.emit(pl.global_position, rad_px * 1.80, 0.080, Color("#F59E0B"), 0.56)
		EventBus.screen_flash_requested.emit(Color("#FDE047"), 0.40, 0.30)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -98), "CỬU U HOÀNG TUYỀN THIÊN NỘ!! (CHOÁNG HỒN 4s)", Color("#FDE047"))
		var stun_ysw: float = float(sdef.get("stun_sec", 4.0))
		var hit_ysw: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
					if push_d == Vector2.ZERO:
						push_d = aim_dir
					var is_boss_e: bool = bool(enemy_node.get("is_boss")) if ("is_boss" in enemy_node) else false
					var er_idx: int = int(enemy_node.get("realm_index")) if ("realm_index" in enemy_node) else 1
					var exec_dmg: float = wrath_dmg
					if not is_boss_e and er_idx < 10 and ("max_hp" in enemy_node):
						exec_dmg = maxf(exec_dmg, float(enemy_node.get("max_hp")) * 1.25) # Kết liễu linh hồn quái thường dưới Bán Thánh!
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.45, 9.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(stun_ysw)
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(exec_dmg, push_d * kb, 1.0, burn_val * 1.2, 1.0, 1.0, 135.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						hit_ysw = true
		if hit_ysw:
			EventBus.trigger_hitstop(0.066, 0.07)

	elif behavior == "reincarnation_fire_disc":
		# PHẬT NỘ LUÂN HỒI (Tự Sáng Tạo Thiên Giai Ch.10): Đĩa lửa Đen–Trắng 4 Dị Hỏa cắt đôi không gian, hút gom & nghiền nát!
		pl._start_skill_pose(aim_dir, 0.44, "cast")
		var pnl_vec: Vector2 = aim_target - pl.global_position
		var pnl_pos: Vector2 = (pl.global_position + aim_dir * 200.0) if pnl_vec.length() < 24.0 else (pl.global_position + aim_dir * minf(pnl_vec.length(), 360.0))
		pl._spawn_skill_vfx("reincarnation_fire_disc", pnl_pos + Vector2(0, -22), aim_dir, rad_px, 0.94, Color("#FFFFFF"), Color("#00F5D4"), Color("#1D1E2C"))
		VfxAssets.spawn_spark_burst(pl.get_parent(), pnl_pos + Vector2(0, -24), Color("#FFFFFF"), Color("#00F5D4"), 48, 150.0, 420.0, 0.60, Vector2.UP, 180.0, 0.36, 0.86, true)
		VfxAssets.spawn_spark_burst(pl.get_parent(), pnl_pos + Vector2(0, -24), Color("#FFAFCC"), Color("#9D4EDD"), 32, 120.0, 360.0, 0.56, aim_dir, 160.0, 0.32, 0.78, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(21.0, 0.54)
		EventBus.shockwave_requested.emit(pnl_pos, rad_px * 1.78, 0.082, Color("#00F5D4"), 0.56)
		EventBus.screen_flash_requested.emit(Color("#FFFFFF"), 0.42, 0.28)
		VfxAssets.spawn_ground_crater(pl.get_parent(), pnl_pos, rad_px * 0.96, Color("#9D4EDD"), 4.2)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -98), "TỨ DIỄM NGHỊCH CHUYỂN: PHẬT NỘ LUÂN HỒI!!", Color("#00F5D4"))
		var hit_pnl: bool = false
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pnl_pos.distance_to(enemy_node.global_position) <= rad_px:
					var pull_d: Vector2 = (pnl_pos - enemy_node.global_position).normalized()
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.50, 10.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(float(sdef.get("stun_sec", 3.0)))
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg, pull_d * absf(kb), 1.0, burn_val * 2.2, 0.75, 1.0, 145.0 * poise_mult)
						pl._try_trigger_inner_heart_ignition(enemy_node)
						hit_pnl = true
		if hit_pnl:
			EventBus.trigger_hitstop(0.068, 0.07)

	elif behavior == "purifying_lotus_array":
		# MỘNG YỂM THIÊN VỤ & TỊNH LIÊN YÊU TRẬN (Ch.10 Yêu Thánh): 12 Cánh Sen Trắng-Hồng khóa sân 12s, -50% DEF & đốt 5% Max HP/s!
		pl._start_skill_pose(aim_dir, 0.42, "cast")
		var dur_tl: float = float(sdef.get("buff_duration", 12.0))
		PlayerData.is_tinh_lien_tran_active = true
		PlayerData.player_slow_timer = 0.0
		PlayerData.player_slow_ratio = 0.0
		pl.tinh_lien_tran_timer = dur_tl
		pl.tinh_lien_tran_tick = 1.0
		pl.tinh_lien_tran_dmg = dmg * 0.48
		pl.tinh_lien_tran_rad = rad_px
		pl._refresh_flame_shader()
		pl._spawn_skill_vfx("purifying_lotus_array", pl.global_position + Vector2(0, -20), Vector2.UP, rad_px, 1.05, Color("#FFFFFF"), Color("#FFAFCC"), Color("#9D4EDD"), { "follow_target": pl, "follow_offset": Vector2(0, -20) })
		VfxAssets.spawn_spark_burst(pl.get_parent(), pl.global_position + Vector2(0, -24), Color("#FFFFFF"), Color("#FDA4AF"), 52, 145.0, 410.0, 0.62, Vector2.UP, 180.0, 0.36, 0.88, true)
		EventBus.audio_sfx_requested.emit("breakthrough")
		EventBus.audio_sfx_requested.emit("skill_burst")
		EventBus.screen_shake_requested.emit(18.0, 0.48)
		EventBus.shockwave_requested.emit(pl.global_position, rad_px * 1.65, 0.074, Color("#FDA4AF"), 0.54)
		EventBus.screen_flash_requested.emit(Color("#FFF1F2"), 0.36, 0.26)
		EventBus.stats_changed.emit()
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -98), "✿ TỊNH LIÊN YÊU TRẬN!! (12s · -50% GIÁP · ĐỐT 5% HP/s)", Color("#FDA4AF"))
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var enemy_node: Node2D = en as Node2D
				if pl.global_position.distance_to(enemy_node.global_position) <= rad_px:
					if enemy_node.has_method("break_boss_shield"):
						enemy_node.break_boss_shield()
					if enemy_node.has_method("apply_def_shred"):
						enemy_node.apply_def_shred(0.50, dur_tl)
					if enemy_node.has_method("apply_slow"):
						enemy_node.apply_slow(0.50, 4.0)
					if enemy_node.has_method("apply_stun"):
						enemy_node.apply_stun(float(sdef.get("stun_sec", 2.5)))
					if enemy_node.has_method("receive_hit"):
						enemy_node.receive_hit(dmg * 0.75, Vector2.ZERO, 1.0, burn_val * 2.0, 1.0, 1.0, 105.0 * poise_mult)

	elif behavior == "flame_wave":
		pl._start_skill_pose(aim_dir, 0.28, "weapon")
		EventBus.audio_sfx_requested.emit("skill_fire")
		EventBus.screen_shake_requested.emit(5.2, 0.15)
		pl._spawn_hit_sparks(pl.global_position + aim_dir * 32.0 + Vector2(0, -24), pl.active_mid_col, aim_dir, 16)
		if pl.get_parent() != null:
			var proj: Area2D = SKILL_SCENE.instantiate() as Area2D
			pl.get_parent().add_child(proj)
			var spd: float = float(sdef.get("projectile_speed", 460.0))
			var use_flame: Dictionary = f_def if not f_def.is_empty() else GameDatabase.get_flame_def("pham_hoa")
			if proj.has_method("configure_skill"):
				proj.configure_skill("flame_wave", pl.global_position + aim_dir * 36.0 + Vector2(0, -24), aim_target, dmg, kb, r_pen, rad_px, spd, use_flame, [])

	elif behavior == "fire_lotus_ult":
		# PHẬT NỘ HỎA LIÊN: Pha tụ ấn 0.22s gom năng lượng nhiều ngọn Dị Hỏa giữa tay trước khi phóng!
		pl._start_skill_pose(aim_dir, 0.34, "cast")
		var use_flame: Dictionary = f_def if not f_def.is_empty() else GameDatabase.get_flame_def("pham_hoa")
		var fusion_list: Array = PlayerData.lotus_fusion_flames.duplicate()
		if fusion_list.is_empty():
			fusion_list = [str(use_flame.get("id", "pham_hoa"))]
		var fusion_cols: Array = []
		for fid in fusion_list:
			var fd: Dictionary = GameDatabase.get_flame_def(str(fid))
			if not fd.is_empty():
				fusion_cols.append(Color(str(fd.get("mid_hex", "#2EC4B6"))))
		pl._spawn_skill_vfx(
			"lotus_cast",
			pl.global_position + aim_dir * 26.0 + Vector2(0, -26),
			aim_dir,
			90.0,
			0.24,
			pl.active_core_col,
			pl.active_mid_col,
			pl.active_outer_col,
			{ "follow_target": pl, "follow_offset": aim_dir * 26.0 + Vector2(0, -26), "extra_colors": fusion_cols }
		)
		EventBus.audio_sfx_requested.emit("skill_stun")
		var fusion_bonus: float = (1.0 + float(max(0, fusion_list.size() - 1)) * 0.28) * PlayerData.get_lotus_affection_dmg_mult()
		pl.pending_lotus_timer = 0.22
		pl.pending_lotus_payload = {
			"aim_target": aim_target,
			"dmg": dmg * fusion_bonus,
			"kb": kb,
			"r_pen": r_pen,
			"rad_px": rad_px,
			"spd": float(sdef.get("projectile_speed", 360.0)),
			"flame_def": use_flame,
			"fusion_list": fusion_list
		}


static func try_trigger_inner_heart_ignition(pl, enemy_node: Node2D) -> void:
	if not PlayerData.has_van_lac_passive() or not is_instance_valid(enemy_node):
		return
	pl.inner_flame_hit_counter += 1
	if pl.inner_flame_hit_counter < 5:
		return
	pl.inner_flame_hit_counter = 0
	var true_dmg: float = float(PlayerData.get_soul()) * 2.4 + PlayerData.get_atk() * 0.65
	if enemy_node.has_method("receive_hit"):
		enemy_node.receive_hit(true_dmg, Vector2.ZERO, 1.0, 0.0, 1.0, 1.0, 22.0 * PlayerData.get_poise_dmg_multiplier())
	VfxAssets.spawn_spark_burst(pl.get_parent(), enemy_node.global_position + Vector2(0, -28), Color("#FFFFFF"), Color("#E0AAFF"), 18, 90.0, 240.0, 0.36, Vector2.UP, 180.0, 0.28, 0.60, true)
	VfxAssets.spawn_spark_burst(pl.get_parent(), enemy_node.global_position + Vector2(0, -28), Color("#FFFFFF"), Color("#00F5D4"), 12, 70.0, 190.0, 0.32, Vector2.UP, 180.0, 0.24, 0.52, true)
	EventBus.audio_sfx_requested.emit("skill_fire")
	EventBus.floating_text_requested.emit(enemy_node.global_position + Vector2(0, -104), "✦ TÂM HỎA NỘI THIÊU! -%d" % int(round(true_dmg)), Color("#E0AAFF"))


static func pulse_flame_clone_burst(pl) -> void:
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var burn_val: float = (pl.flame_clone_dmg * float(f_def.get("burn_dps_ratio", 0.10)) * PlayerData.get_flame_dmg_multiplier() if not f_def.is_empty() else 0.0) + PlayerData.get_core_burn_dps()
	var poise_val: float = 14.0 * PlayerData.get_poise_dmg_multiplier()
	var struck: bool = false
	for en in pl.get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(en) or not (en is Node2D):
			continue
		var enemy_node: Node2D = en as Node2D
		if pl.global_position.distance_to(enemy_node.global_position) <= pl.flame_clone_radius:
			var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
			if push_d == Vector2.ZERO:
				push_d = Vector2.RIGHT
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(pl.flame_clone_dmg, push_d * 145.0, pl.flame_clone_r_pen, burn_val, 0.0, 1.0, poise_val)
				pl._spawn_hit_sparks(enemy_node.global_position + Vector2(0, -24), pl.active_mid_col, push_d, 8)
				struck = true
	if struck:
		EventBus.audio_sfx_requested.emit("skill_fire")


static func detonate_flame_clone_finale(pl) -> void:
	var f_def: Dictionary = PlayerData.get_active_flame_def()
	var finale_dmg: float = pl.flame_clone_dmg * 1.65
	var burn_val: float = (finale_dmg * float(f_def.get("burn_dps_ratio", 0.12)) * PlayerData.get_flame_dmg_multiplier() if not f_def.is_empty() else 0.0) + PlayerData.get_core_burn_dps()
	var poise_val: float = 28.0 * PlayerData.get_poise_dmg_multiplier()
	pl._spawn_skill_vfx(
		"lotus_detonate",
		pl.global_position + Vector2(0, -24),
		Vector2.RIGHT,
		pl.flame_clone_radius * 1.08,
		0.46,
		pl.active_core_col,
		pl.active_mid_col,
		pl.active_outer_col,
		{ "extra_colors": [pl.active_mid_col, pl.active_core_col] }
	)
	pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), pl.active_mid_col, Vector2.UP, 24)
	EventBus.audio_sfx_requested.emit("skill_burst")
	EventBus.screen_shake_requested.emit(6.5, 0.20)
	for en in pl.get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(en) or not (en is Node2D):
			continue
		var enemy_node: Node2D = en as Node2D
		if pl.global_position.distance_to(enemy_node.global_position) <= pl.flame_clone_radius * 1.12:
			var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
			if push_d == Vector2.ZERO:
				push_d = Vector2.RIGHT
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(finale_dmg, push_d * 290.0, pl.flame_clone_r_pen, burn_val, 0.0, 1.0, poise_val)


static func pulse_kim_khoi_tran(pl) -> void:
	var poise_val: float = 24.0 * PlayerData.get_poise_dmg_multiplier()
	var struck: bool = false
	for en in pl.get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(en) or not (en is Node2D):
			continue
		var enemy_node: Node2D = en as Node2D
		if pl.global_position.distance_to(enemy_node.global_position) <= pl.kim_khoi_tran_rad:
			var push_d: Vector2 = (enemy_node.global_position - pl.global_position).normalized()
			if push_d == Vector2.ZERO:
				push_d = Vector2.RIGHT
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(pl.kim_khoi_tran_dmg, push_d * 180.0, 0.85, PlayerData.get_core_burn_dps(), 0.25, 1.0, poise_val)
				VfxAssets.spawn_spark_burst(pl.get_parent(), enemy_node.global_position + Vector2(0, -26), Color("#FFF8D6"), Color("#FFD166"), 10, 85.0, 210.0, 0.28, Vector2.UP, 180.0, 0.24, 0.56, true)
				struck = true
	if struck:
		pl._spawn_skill_vfx("ten_golden_puppets", pl.global_position + Vector2(0, -20), Vector2.UP, pl.kim_khoi_tran_rad * 0.72, 0.32, Color("#FFFFFF"), Color("#FFD166"), Color("#9D4EDD"), { "follow_target": pl, "follow_offset": Vector2(0, -20) })
		EventBus.audio_sfx_requested.emit("thunder_blink")


static func pulse_tinh_lien_tran(pl) -> void:
	var poise_val: float = 28.0 * PlayerData.get_poise_dmg_multiplier()
	var struck: bool = false
	for en in pl.get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(en) or not (en is Node2D):
			continue
		var enemy_node: Node2D = en as Node2D
		if pl.global_position.distance_to(enemy_node.global_position) <= pl.tinh_lien_tran_rad:
			var emhp: float = float(enemy_node.get("max_hp")) if ("max_hp" in enemy_node) else 10000.0
			var is_boss_e: bool = bool(enemy_node.get("is_boss")) if ("is_boss" in enemy_node) else false
			var pct_burn: float = minf(emhp * 0.05, PlayerData.get_atk() * (4.5 if is_boss_e else 8.0))
			var tick_dmg: float = maxf(pl.tinh_lien_tran_dmg, pct_burn)
			if enemy_node.has_method("apply_def_shred"):
				enemy_node.apply_def_shred(0.50, 2.5)
			if enemy_node.has_method("receive_hit"):
				enemy_node.receive_hit(tick_dmg, Vector2.ZERO, 1.0, 0.0, 1.0, 1.0, poise_val)
				VfxAssets.spawn_spark_burst(pl.get_parent(), enemy_node.global_position + Vector2(0, -26), Color("#FFFFFF"), Color("#FDA4AF"), 10, 75.0, 190.0, 0.30, Vector2.UP, 180.0, 0.24, 0.56, true)
				struck = true
	if struck:
		pl._spawn_skill_vfx("purifying_lotus_array", pl.global_position + Vector2(0, -20), Vector2.UP, pl.tinh_lien_tran_rad * 0.85, 0.42, Color("#FFFFFF"), Color("#FFAFCC"), Color("#9D4EDD"), { "follow_target": pl, "follow_offset": Vector2(0, -20) })
		EventBus.audio_sfx_requested.emit("skill_fire")


static func activate_duoc_lao_assist(pl) -> void:
	var mode: String = PlayerData.get_assist_mode()
	if mode == "locked":
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -72), "Chưa mở Cốt Linh Phụ Thể [T]!", Color("#ADB5BD"))
		EventBus.banter_triggered.emit("Gợi ý cốt truyện: Hoàn thành trận diệt Gia Liệt Áo (cuối Chương 01) để mở khóa Cốt Linh Phụ Thể [T]!")
		return
	if mode == "sleeping":
		EventBus.audio_sfx_requested.emit("alchemy_fail")
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -74), "Dược Lão Đang Ngủ Say Trong Nhẫn Đen!", Color("#A8DADC"))
		EventBus.banter_triggered.emit("Cốt truyện Chương 04: Dược Lão đã tiêu hao tàn hồn sau vụ nổ Mặc Gia! Hãy tự lực chinh phục Đế Đô & Vân Lam Sơn!")
		return
	if float(pl.skill_cooldowns.get("T", 0.0)) > 0.0:
		return
	pl._start_skill_pose(Vector2.RIGHT if not pl.body_sprite.flip_h else Vector2.LEFT, 0.36, "cast")
	PlayerData.is_duoc_lao_active = true
	pl.duoc_lao_timer = 12.0
	pl.skill_cooldowns["T"] = 45.0
	pl.skill_cooldown_totals["T"] = 45.0
	EventBus.skill_cooldown_updated.emit("T", 45.0, 45.0)
	pl._refresh_flame_shader()
	EventBus.audio_sfx_requested.emit("breakthrough")
	EventBus.stats_changed.emit()
	EventBus.screen_shake_requested.emit(22.0 if (mode == "tinh_lien_hop_bich" or mode == "bac_vuong") else (16.5 if mode == "ban_thanh_duoc_tran" else (14.0 if mode == "thien_yeu_khoi" else (12.0 if mode == "dia_yeu_khoi" else (10.5 if mode == "medusa_dau_tong" else 8.5)))), 0.50 if (mode == "tinh_lien_hop_bich" or mode == "bac_vuong") else (0.40 if mode == "ban_thanh_duoc_tran" else 0.36))
	EventBus.trigger_hitstop(0.064 if (mode == "tinh_lien_hop_bich" or mode == "bac_vuong") else (0.056 if mode == "ban_thanh_duoc_tran" else (0.048 if mode == "thien_yeu_khoi" else 0.044)), 0.08)
	if mode == "tinh_lien_hop_bich":
		PlayerData.player_slow_timer = 0.0
		PlayerData.player_slow_ratio = 0.0
		PlayerData.lotus_shield_hp = maxf(PlayerData.lotus_shield_hp, PlayerData.get_max_hp() * 0.60)
		pl._spawn_skill_vfx("bac_vuong_tinh_lien_assist", pl.global_position + Vector2(0, -24), Vector2.UP, 460.0, 1.05, Color("#FFFFFF"), Color("#FFD700"), Color("#FFAFCC"), { "follow_target": pl, "follow_offset": Vector2(0, -24) })
		EventBus.shockwave_requested.emit(pl.global_position, 520.0, 0.082, Color("#FFAFCC"), 0.58)
		EventBus.screen_flash_requested.emit(Color("#FFF1F2"), 0.42, 0.30)
		VfxAssets.spawn_ground_crater(pl.get_parent(), pl.global_position, 260.0, Color("#FFD700"), 4.4)
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), Color("#FFD700"), Vector2.UP, 58)
		var hb_dmg: float = PlayerData.get_atk() * 6.40 + float(PlayerData.get_soul()) * 5.2
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var en_nd: Node2D = en as Node2D
				if pl.global_position.distance_to(en_nd.global_position) <= 460.0:
					var push_d: Vector2 = (en_nd.global_position - pl.global_position).normalized()
					if en_nd.has_method("break_boss_shield"):
						en_nd.break_boss_shield()
					if en_nd.has_method("apply_def_shred"):
						en_nd.apply_def_shred(0.50, 12.0)
					if en_nd.has_method("receive_hit"):
						en_nd.receive_hit(hb_dmg, push_d * 820.0, 1.0, PlayerData.get_core_burn_dps() * 1.5, 1.0, 1.0, 155.0 * PlayerData.get_poise_dmg_multiplier())
					if en_nd.has_method("apply_stun"):
						en_nd.apply_stun(4.5)
		# Tiểu Y & Bắc Vương tự động hút nhặt toàn bộ chiến lợi phẩm trên sân!
		for lp in pl.get_tree().get_nodes_in_group("loot_pickups"):
			if is_instance_valid(lp) and lp is Node2D:
				(lp as Node2D).global_position = pl.global_position
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -100), "✿ KIM ĐẾ TỊNH LIÊN HỢP BÍCH & BẮC VƯƠNG!! (+60% KHIÊN · TỰ NHẶT ĐỒ)", Color("#FFD700"))
		EventBus.banter_triggered.emit("Cổ Huân Nhi & Tiểu Y + Bắc Vương: 'Kim Đế dẫn lối, Tịnh Liên phần thiên — Y Y nha~ Tiêu Viêm ca ca, cùng xuất chiêu!!'")
	elif mode == "bac_vuong":
		PlayerData.player_slow_timer = 0.0
		PlayerData.player_slow_ratio = 0.0
		PlayerData.lotus_shield_hp = maxf(PlayerData.lotus_shield_hp, PlayerData.get_max_hp() * 0.50)
		pl._spawn_skill_vfx("bac_vuong_tinh_lien_assist", pl.global_position + Vector2(0, -24), Vector2.UP, 420.0, 0.96, Color("#FFFFFF"), Color("#FFD700"), Color("#CA8A04"), { "follow_target": pl, "follow_offset": Vector2(0, -24) })
		EventBus.shockwave_requested.emit(pl.global_position, 480.0, 0.076, Color("#FFD700"), 0.54)
		EventBus.screen_flash_requested.emit(Color("#FEF08A"), 0.38, 0.28)
		VfxAssets.spawn_ground_crater(pl.get_parent(), pl.global_position, 240.0, Color("#FFD700"), 4.0)
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), Color("#FFD700"), Vector2.UP, 50)
		var bv_mult: float = 1.35 if SaintRealmManager.has_bac_vuong_seven_star(PlayerData) else 1.0
		var bv_dmg: float = (PlayerData.get_atk() * 5.20 + float(PlayerData.get_soul()) * 3.8) * bv_mult
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var en_nd: Node2D = en as Node2D
				if pl.global_position.distance_to(en_nd.global_position) <= 420.0:
					var pull_d: Vector2 = (pl.global_position - en_nd.global_position).normalized()
					if en_nd.has_method("break_boss_shield"):
						en_nd.break_boss_shield()
					if en_nd.has_method("apply_def_shred"):
						en_nd.apply_def_shred(0.45, 10.0)
					if en_nd.has_method("receive_hit"):
						en_nd.receive_hit(bv_dmg, pull_d * 520.0, 1.0, PlayerData.get_core_burn_dps(), 0.65, 1.0, 135.0 * PlayerData.get_poise_dmg_multiplier())
					if en_nd.has_method("apply_stun"):
						en_nd.apply_stun(4.2)
		var star_lbl: String = "THẤT TINH KIM LÔI" if SaintRealmManager.has_bac_vuong_seven_star(PlayerData) else "LỤC TINH ĐẤU THÁNH"
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -98), "BẮC VƯƠNG (%s) — KIM CƯƠNG PHÁ THIÊN!! (+50%% KHIÊN)" % star_lbl, Color("#FFD700"))
		EventBus.banter_triggered.emit("Siêu Khôi Lỗi [Bắc Vương — %s] đấm nát không gian gom toàn bộ kẻ địch, dựng Khiên 50%% HP & tăng +280%% ATK!!" % star_lbl)
	elif mode == "ban_thanh_duoc_tran":
		PlayerData.player_slow_timer = 0.0
		PlayerData.player_slow_ratio = 0.0
		PlayerData.lotus_shield_hp = maxf(PlayerData.lotus_shield_hp, PlayerData.get_max_hp() * 0.40)
		pl._spawn_skill_vfx("ban_thanh_duoc_tran_assist", pl.global_position + Vector2(0, -24), Vector2.UP, 380.0, 0.92, Color("#FFFFFF"), Color("#E0FBFC"), Color("#4CC9F0"), { "follow_target": pl, "follow_offset": Vector2(0, -24) })
		EventBus.shockwave_requested.emit(pl.global_position, 440.0, 0.070, Color("#A8DADC"), 0.52)
		EventBus.screen_flash_requested.emit(Color("#E0FBFC"), 0.36, 0.28)
		VfxAssets.spawn_ground_crater(pl.get_parent(), pl.global_position, 220.0, Color("#4CC9F0"), 3.8)
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), Color("#E0FBFC"), Vector2.UP, 46)
		var bt_dmg: float = PlayerData.get_atk() * 4.20 + float(PlayerData.get_soul()) * 3.0
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var en_nd: Node2D = en as Node2D
				if pl.global_position.distance_to(en_nd.global_position) <= 380.0:
					var push_d: Vector2 = (en_nd.global_position - pl.global_position).normalized()
					if en_nd.has_method("break_boss_shield"):
						en_nd.break_boss_shield()
					if en_nd.has_method("apply_def_shred"):
						en_nd.apply_def_shred(0.35, 9.0)
					if en_nd.has_method("receive_hit"):
						en_nd.receive_hit(bt_dmg, push_d * 720.0, 1.0, PlayerData.get_core_burn_dps(), 0.45, 1.0, 110.0 * PlayerData.get_poise_dmg_multiplier())
					if en_nd.has_method("apply_stun"):
						en_nd.apply_stun(4.0)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -96), "BÁN THÁNH DƯỢC TRẦN — CỐT LINH VẠN LÝ BĂNG PHONG!! (ĐÓNG BĂNG 4s)", Color("#E0FBFC"))
		EventBus.banter_triggered.emit("Bán Thánh Dược Trần (phất nhẹ ống tay áo trắng): 'Đồ đệ của Dược Trần ta đã vất vả rồi — Cốt Linh Băng Phong toàn sân 4s · +40% Khiên · +235% ATK!'")
	elif mode == "thien_yeu_khoi":
		PlayerData.player_slow_timer = 0.0
		PlayerData.player_slow_ratio = 0.0
		PlayerData.lotus_shield_hp = maxf(PlayerData.lotus_shield_hp, PlayerData.get_max_hp() * 0.30)
		pl._spawn_skill_vfx("thien_yeu_khoi_assist", pl.global_position + Vector2(0, -22), Vector2.UP, 300.0, 0.78, Color("#FFFFFF"), Color("#FFD166"), Color("#C77DFF"), { "follow_target": pl, "follow_offset": Vector2(0, -22) })
		EventBus.shockwave_requested.emit(pl.global_position, 360.0, 0.060, Color("#FFD166"), 0.45)
		EventBus.screen_flash_requested.emit(Color("#FFD166"), 0.30, 0.22)
		VfxAssets.spawn_ground_crater(pl.get_parent(), pl.global_position, 185.0, Color("#C77DFF"), 3.2)
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), Color("#FFD166"), Vector2.UP, 40)
		var ty_dmg: float = PlayerData.get_atk() * 3.35
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var en_nd: Node2D = en as Node2D
				if pl.global_position.distance_to(en_nd.global_position) <= 300.0:
					var push_d: Vector2 = (en_nd.global_position - pl.global_position).normalized()
					if en_nd.has_method("break_boss_shield"):
						en_nd.break_boss_shield()
					if en_nd.has_method("receive_hit"):
						en_nd.receive_hit(ty_dmg, push_d * 680.0, 0.92, PlayerData.get_core_burn_dps(), 0.32, 1.0, 88.0 * PlayerData.get_poise_dmg_multiplier())
					if en_nd.has_method("apply_stun"):
						en_nd.apply_stun(2.2)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -90), "CHUẨN THIÊN YÊU KHÔI — NGŨ SẮC THIÊN LÔI!! (+30% KHIÊN)", Color("#FFD166"))
		EventBus.banter_triggered.emit("[Chuẩn Thiên Yêu Khôi] toàn thân ánh vàng Ngũ Sắc Đan Lôi giáng xuống — tạo Khiên 30% HP, miễn làm chậm & tăng +205% ATK trong 12 giây!!")
	elif mode == "dia_yeu_khoi":
		PlayerData.player_slow_timer = 0.0
		PlayerData.player_slow_ratio = 0.0
		pl._spawn_skill_vfx("dia_yeu_khoi_assist", pl.global_position + Vector2(0, -22), Vector2.UP, 265.0, 0.68, Color("#FFFFFF"), Color("#CAF0F8"), Color("#48CAE4"), { "follow_target": pl, "follow_offset": Vector2(0, -22) })
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), Color("#90E0EF"), Vector2.UP, 34)
		var dy_dmg: float = PlayerData.get_atk() * 2.85
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var en_nd: Node2D = en as Node2D
				if pl.global_position.distance_to(en_nd.global_position) <= 265.0:
					var push_d: Vector2 = (en_nd.global_position - pl.global_position).normalized()
					if en_nd.has_method("break_boss_shield"):
						en_nd.break_boss_shield()
					if en_nd.has_method("receive_hit"):
						en_nd.receive_hit(dy_dmg, push_d * 600.0, 0.85, PlayerData.get_core_burn_dps(), 0.25, 1.0, 72.0 * PlayerData.get_poise_dmg_multiplier())
					if en_nd.has_method("apply_stun"):
						en_nd.apply_stun(1.8)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -86), "ĐỊA YÊU KHÔI LÔI BỘC!! (BẤT HOẠI ĐẤU TÔNG)", Color("#CAF0F8"))
		EventBus.banter_triggered.emit("Vệ Sĩ Bất Tử [Địa Yêu Khôi] vung thiết quyền bạc nện nát hư không — miễn nhiễm làm chậm & tăng vọt +170% ATK trong 12 giây!!")
	elif mode == "medusa_dau_tong":
		pl._spawn_skill_vfx("medusa_assist", pl.global_position + Vector2(0, -20), Vector2.UP, 235.0, 0.65, Color("#FFFFFF"), Color("#E0AAFF"), Color("#7B2CBF"), { "follow_target": pl, "follow_offset": Vector2(0, -20) })
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), Color("#E0AAFF"), Vector2.RIGHT, 30)
		var m_dmg: float = PlayerData.get_atk() * 2.4
		for en in pl.get_tree().get_nodes_in_group("enemies"):
			if is_instance_valid(en) and en is Node2D:
				var en_nd: Node2D = en as Node2D
				if pl.global_position.distance_to(en_nd.global_position) <= 235.0:
					var push_d: Vector2 = (en_nd.global_position - pl.global_position).normalized()
					if en_nd.has_method("receive_hit"):
						en_nd.receive_hit(m_dmg, push_d * 540.0, 0.75, PlayerData.get_core_burn_dps(), 0.0, 1.0, 55.0 * PlayerData.get_poise_dmg_multiplier())
					if en_nd.has_method("apply_stun"):
						en_nd.apply_stun(1.4)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -82), "ĐẤU TÔNG MỸ ĐỖ TOA HỘ PHÁP!", Color("#E0AAFF"))
		EventBus.banter_triggered.emit("Mỹ Đỗ Toa Nữ Vương (Đạp Hư Không): 'Kẻ giữ đan phương của bổn vương, đám sâu kiến các ngươi cũng dám động vào sao?!'")
	else:
		pl._spawn_skill_vfx("duoc_lao_assist", pl.global_position + Vector2(0, -20), Vector2.UP, 175.0, 0.60, Color("#FFFFFF"), Color("#A8DADC"), Color("#457B9D"), { "follow_target": pl, "follow_offset": Vector2(0, -20) })
		pl._spawn_hit_sparks(pl.global_position + Vector2(0, -24), Color("#A8DADC"), Vector2.UP, 26)
		EventBus.floating_text_requested.emit(pl.global_position + Vector2(0, -78), "CỐT LINH PHỤ THỂ!", Color("#A8DADC"))
		EventBus.banter_triggered.emit("Dược Lão: 'Giao thân thể cho vi sư! Để chúng chiêm ngưỡng uy lực Cốt Linh Lãnh Hỏa!'")
