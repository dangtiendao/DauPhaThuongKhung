class_name StoryDialogueRunner
extends RefCounted
## Trình chạy Hội Thoại & Kịch Bản NPC 100% Data-Driven JSON (Chương 01 -> Chương 11 — v1.1.0):
## - Toàn bộ 11 Chương đều đọc trực tiếp từ data/dialogues_ch01.json .. data/dialogues_ch11.json.


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

		var open_flag: String = str(bd.get("on_open_flag", ""))
		if open_flag != "":
			PlayerData.set_story_flag(open_flag)

		var sfx_s: String = str(bd.get("sfx", ""))
		if sfx_s != "":
			EventBus.audio_sfx_requested.emit(sfx_s)
		var sh_arr: Array = bd.get("shake", [])
		if sh_arr.size() >= 2:
			EventBus.screen_shake_requested.emit(float(sh_arr[0]), float(sh_arr[1]))

		var direct_act: String = str(bd.get("direct_action", ""))
		if direct_act == "open_shop":
			EventBus.shop_requested.emit()
			return true

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

	var dlg_def: Dictionary = GameDatabase.get_dialogue_def(role_str)
	if not dlg_def.is_empty():
		if run_data_driven_dialogue(dlg_def, npc_name, sprite_p):
			return

	EventBus.dialogue_requested.emit(npc_name, sprite_p, [
		"%s mỉm cười chắp tay chào bạn." % npc_name
	], "heal_full")
