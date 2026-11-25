extends Node
## Hệ thống Âm Thanh, Nhạc Nền Cổ Phong Tiên Hiệp (Procedural AudioStreamWAV) & Cài Đặt Hiển Thị:
## - Không phụ thuộc file MP3 ngoài -> tổng hợp trực tiếp chuẩn Ngũ Cung & Địa Vực (Cổ Tranh / Sáo Trúc / Tỳ Bà / Biên Chung / Trống Chiến).
## - 22 Bản nhạc nền tự động chuyển mượt theo bản đồ & Boss:
##   bgm_peaceful, bgm_wild, bgm_boss, bgm_desert, bgm_lava, bgm_capital, bgm_yunlan,
##   bgm_hac_giac, bgm_gia_nam, bgm_poison, bgm_zhongzhou,
##   bgm_tinh_van, bgm_vong_hon, bgm_thien_mo,
##   bgm_bo_de, bgm_thien_phu, bgm_nhan_dien, bgm_yeu_hoa,
##   bgm_co_de_dong_phu, bgm_song_de_chi_chien, bgm_o_than_dai_hon, bgm_dai_thien_the_gioi.
## - 24 Hiệu ứng SFX chiến đấu (gồm Phá Thế poise_break, Đột Phá breakthrough & Choáng skill_stun hòa âm giàu sắc thái).
## - Lưu & gộp sạch cài đặt Âm Thanh + Hiển Thị (Fullscreen / VSync / FPS / Screen Shake) trong user://dptk_settings.json.

const BgmCh0508 = preload("res://scripts/systems/audio_bgm_ch05_08.gd")
const BgmCh09 = preload("res://scripts/systems/audio_bgm_ch09.gd")
const BgmCh10 = preload("res://scripts/systems/audio_bgm_ch10.gd")
const BgmCh11 = preload("res://scripts/systems/audio_bgm_ch11.gd")
const SETTINGS_PATH: String = "user://dptk_settings.json"
const SAMPLE_RATE: int = 22050

var bgm_volume: float = 0.65
var sfx_volume: float = 0.80
var is_muted: bool = false

@export var is_fullscreen: bool = false
@export var vsync_enabled: bool = true
@export var show_fps: bool = false
@export var shake_scale: float = 1.0

# Đổi Phím Tùy Chỉnh (Key Rebinding) lưu vào user://dptk_settings.json
const DEFAULT_KEYBINDS: Dictionary = {
	"move_up": KEY_W,
	"move_down": KEY_S,
	"move_left": KEY_A,
	"move_right": KEY_D,
	"dash": KEY_SPACE,
	"interact": KEY_V,
	"skill_q": KEY_Q,
	"skill_e": KEY_E,
	"skill_r": KEY_R,
	"skill_ult": KEY_F,
	"skill_assist": KEY_T,
	"toc_van_crest": KEY_X,
	"toggle_weight": KEY_C,
	"toggle_companion": KEY_G,
	"soul_radar": KEY_Z
}
var custom_keybinds: Dictionary = {}

var bgm_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_pool_idx: int = 0

var bgm_tracks: Dictionary = {}
var sfx_streams: Dictionary = {}
var current_bgm_name: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings()
	apply_display_settings()
	call_deferred("apply_custom_keybinds")

	bgm_player = AudioStreamPlayer.new()
	bgm_player.bus = "Master"
	add_child(bgm_player)

	for _i in range(10):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_pool.append(p)

	_build_all_sfx()
	_build_all_bgm()
	_apply_volumes()

	EventBus.audio_sfx_requested.connect(play_sfx)
	EventBus.bgm_requested.connect(play_bgm)


func _exit_tree() -> void:
	stop_all_audio()
	bgm_tracks.clear()
	sfx_streams.clear()


func stop_all_audio() -> void:
	if bgm_player != null:
		bgm_player.stop()
		bgm_player.stream = null
	for p in sfx_pool:
		if p != null:
			p.stop()
			p.stream = null
	current_bgm_name = ""


func set_bgm_volume(val: float, save_to_disk: bool = true) -> void:
	bgm_volume = clampf(val, 0.0, 1.0)
	_apply_volumes()
	if save_to_disk:
		_save_settings()


func set_sfx_volume(val: float, save_to_disk: bool = true) -> void:
	sfx_volume = clampf(val, 0.0, 1.0)
	_apply_volumes()
	if save_to_disk:
		_save_settings()


func set_muted(muted: bool, save_to_disk: bool = true) -> void:
	is_muted = muted
	_apply_volumes()
	if save_to_disk:
		_save_settings()


func set_fullscreen(val: bool, save: bool = true) -> void:
	is_fullscreen = val
	apply_display_settings()
	if save:
		_save_settings()


func set_vsync(val: bool, save: bool = true) -> void:
	vsync_enabled = val
	apply_display_settings()
	if save:
		_save_settings()


func set_show_fps(val: bool, save: bool = true) -> void:
	show_fps = val
	if EventBus.has_signal("display_settings_changed"):
		EventBus.display_settings_changed.emit()
	if save:
		_save_settings()


func set_shake_scale(val: float, save: bool = true) -> void:
	shake_scale = clampf(val, 0.0, 1.0)
	if EventBus.has_signal("display_settings_changed"):
		EventBus.display_settings_changed.emit()
	if save:
		_save_settings()


func apply_display_settings() -> void:
	if DisplayServer.get_name() != "headless":
		var target_mode: DisplayServer.WindowMode = (
			DisplayServer.WINDOW_MODE_FULLSCREEN if is_fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
		)
		if DisplayServer.window_get_mode() != target_mode:
			DisplayServer.window_set_mode(target_mode)
		var target_vsync: DisplayServer.VSyncMode = (
			DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
		)
		if DisplayServer.window_get_vsync_mode() != target_vsync:
			DisplayServer.window_set_vsync_mode(target_vsync)
	if EventBus.has_signal("display_settings_changed"):
		EventBus.display_settings_changed.emit()


func _apply_volumes() -> void:
	if bgm_player != null:
		if is_muted or bgm_volume <= 0.001:
			bgm_player.volume_db = -80.0
		else:
			bgm_player.volume_db = linear_to_db(bgm_volume * 0.42)


func _save_settings() -> void:
	# Đọc và gộp (merge) các khóa hiện có để không bao giờ ghi đè cài đặt Auto-Save của PlayerData!
	var merged: Dictionary = {}
	if FileAccess.file_exists(SETTINGS_PATH):
		var rf := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if rf != null:
			var parsed: Variant = JSON.parse_string(rf.get_as_text())
			if parsed is Dictionary:
				merged = parsed
	merged["bgm_volume"] = bgm_volume
	merged["sfx_volume"] = sfx_volume
	merged["is_muted"] = is_muted
	merged["is_fullscreen"] = is_fullscreen
	merged["vsync_enabled"] = vsync_enabled
	merged["show_fps"] = show_fps
	merged["shake_scale"] = shake_scale
	merged["custom_keybinds"] = custom_keybinds
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(merged, "\t"))


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		var d: Dictionary = parsed
		bgm_volume = clampf(float(d.get("bgm_volume", 0.65)), 0.0, 1.0)
		sfx_volume = clampf(float(d.get("sfx_volume", 0.80)), 0.0, 1.0)
		is_muted = bool(d.get("is_muted", false))
		is_fullscreen = bool(d.get("is_fullscreen", false))
		vsync_enabled = bool(d.get("vsync_enabled", true))
		show_fps = bool(d.get("show_fps", false))
		shake_scale = clampf(float(d.get("shake_scale", 1.0)), 0.0, 1.0)
		var kb = d.get("custom_keybinds", {})
		if kb is Dictionary:
			custom_keybinds = {}
			for ak in kb.keys():
				var ak_s: String = str(ak)
				if DEFAULT_KEYBINDS.has(ak_s):
					custom_keybinds[ak_s] = int(kb[ak])


func get_action_keycode(action_name: String) -> int:
	if custom_keybinds.has(action_name):
		return int(custom_keybinds[action_name])
	return int(DEFAULT_KEYBINDS.get(action_name, KEY_NONE))


func get_action_key_label(action_name: String) -> String:
	var kc: int = get_action_keycode(action_name)
	if kc == KEY_SPACE:
		return "SPC"
	if kc == KEY_NONE:
		return "?"
	return OS.get_keycode_string(kc as Key).to_upper()


func rebind_action_key(action_name: String, new_keycode: int, save: bool = true) -> void:
	if not DEFAULT_KEYBINDS.has(action_name) or new_keycode == KEY_NONE or new_keycode == KEY_ESCAPE:
		return
	custom_keybinds[action_name] = new_keycode
	_apply_single_keybind(action_name, new_keycode)
	if save:
		_save_settings()
	if EventBus.has_signal("keybinds_changed"):
		EventBus.keybinds_changed.emit()


func reset_default_keybinds(save: bool = true) -> void:
	custom_keybinds.clear()
	apply_custom_keybinds()
	if save:
		_save_settings()
	if EventBus.has_signal("keybinds_changed"):
		EventBus.keybinds_changed.emit()


func apply_custom_keybinds() -> void:
	for act_name in DEFAULT_KEYBINDS.keys():
		var kc: int = get_action_keycode(str(act_name))
		_apply_single_keybind(str(act_name), kc)


func _apply_single_keybind(action_name: String, keycode: int) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	# Giữ lại các phím phụ chuột (ví dụ RMB của toggle_weight) và phím mũi tên di chuyển / Enter
	var preserved: Array[InputEvent] = []
	for ev in InputMap.action_get_events(action_name):
		if ev is InputEventMouseButton:
			preserved.append(ev)
		elif ev is InputEventKey:
			var k_ev: InputEventKey = ev as InputEventKey
			if k_ev.physical_keycode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_ENTER]:
				preserved.append(ev)
	InputMap.action_erase_events(action_name)
	var new_ev := InputEventKey.new()
	new_ev.physical_keycode = keycode as Key
	InputMap.action_add_event(action_name, new_ev)
	for p_ev in preserved:
		InputMap.action_add_event(action_name, p_ev)


func play_bgm(track_name: String) -> void:
	if track_name == "" or track_name == current_bgm_name:
		return
	if not bgm_tracks.has(track_name):
		return
	current_bgm_name = track_name
	if bgm_player.playing:
		bgm_player.stop()
	bgm_player.stream = bgm_tracks[track_name]
	_apply_volumes()
	if AudioServer.get_driver_name() == "Dummy":
		return
	bgm_player.play()


func play_sfx(sfx_name: String, pitch_jitter: float = 0.07) -> void:
	if is_muted or sfx_volume <= 0.001:
		return
	if not sfx_streams.has(sfx_name):
		return
	if AudioServer.get_driver_name() == "Dummy":
		return
	var p: AudioStreamPlayer = sfx_pool[sfx_pool_idx]
	sfx_pool_idx = (sfx_pool_idx + 1) % sfx_pool.size()
	if p.playing:
		p.stop()
	p.stream = sfx_streams[sfx_name]
	p.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter) if pitch_jitter > 0.0 else 1.0
	p.volume_db = linear_to_db(sfx_volume * 0.72)
	p.play()


# =========================================================
# TỔNG HỢP 7 BẢN NHẠC NỀN NGŨ CUNG & ĐỊA VỰC ĐẤU KHÍ ĐẠI LỤC
# =========================================================
func _build_all_bgm() -> void:
	# 1. Nhạc Tiêu Gia & Ô Thản Thành (Ngũ cung D trưởng nhẹ nhàng cổ phong)
	var notes_peace: Array = [
		293.66, 329.63, 369.99, 440.00, 493.88, 440.00, 369.99, 329.63,
		293.66, 440.00, 493.88, 587.33, 493.88, 440.00, 369.99, 293.66
	]
	bgm_tracks["bgm_peaceful"] = _synth_pentatonic_loop(notes_peace, 0.48, 146.83, false)

	# 2. Nhạc Rừng Trúc Hậu Sơn & Ma Thú Sơn Mạch (Ngũ cung Thứ sâu lắng bí ẩn)
	var notes_wild: Array = [
		220.00, 261.63, 293.66, 329.63, 392.00, 329.63, 293.66, 261.63,
		220.00, 293.66, 329.63, 440.00, 392.00, 329.63, 261.63, 220.00
	]
	bgm_tracks["bgm_wild"] = _synth_pentatonic_loop(notes_wild, 0.52, 110.00, false)

	# 3. Nhạc Đánh Boss & Lôi Đài (Tiết tấu nhanh + Trống chiến hào hùng)
	var notes_boss: Array = [
		220.00, 220.00, 261.63, 329.63, 293.66, 261.63, 329.63, 392.00,
		440.00, 392.00, 329.63, 293.66, 329.63, 261.63, 220.00, 196.00
	]
	bgm_tracks["bgm_boss"] = _synth_pentatonic_loop(notes_boss, 0.25, 110.00, true)

	# 4. Sa Mạc Tháp Qua Nhĩ (Thang âm D Phrygian/Hijaz Tây Vực + Tỳ Bà + Gió cát + Trống khung)
	bgm_tracks["bgm_desert"] = _synth_desert_loop()

	# 5. Địa Huyệt Dung Nham (Âm trầm địa mạch + Chuông đồng căng thẳng + Nhịp tim trống chiến)
	bgm_tracks["bgm_lava"] = _synth_lava_loop()

	# 6. Hoàng Thành Gia Mã Đế Đô (Ngũ cung Cung Điệu uy nghi + Biên Chung/Kèn Đồng + Cổ Tranh rải âm)
	bgm_tracks["bgm_capital"] = _synth_capital_loop()

	# 7. Đỉnh Vân Lam Sơn & Ước Hẹn 3 Năm (Sáo trúc vân đỉnh + Kiếm phong hòa âm + Đàn dây & Trống sử thi)
	bgm_tracks["bgm_yunlan"] = _synth_yunlan_loop()

	# 8–11. Bộ 4 nhạc nền địa vực Chương 05–08 (Hắc Giác Vực, Học Viện Già Nam, Xuất Vân Độc Chướng, Trung Châu Tinh Vực)
	var extra_tracks: Dictionary = BgmCh0508.build_tracks(SAMPLE_RATE)
	for tk in extra_tracks.keys():
		bgm_tracks[str(tk)] = extra_tracks[tk]

	# 12–14. Bộ 3 nhạc nền địa vực Chương 09 (Tinh Vẫn Các/Hoa Tông, Vong Hồn Sơn Mạch/Di Tích, Cổ Giới/Thiên Mộ)
	var ch09_tracks: Dictionary = BgmCh09.build_tracks(SAMPLE_RATE)
	for tk9 in ch09_tracks.keys():
		bgm_tracks[str(tk9)] = ch09_tracks[tk9]

	# 15–18. Bộ 4 nhạc nền địa vực Chương 10 (Bồ Đề Cổ Thụ, Thiên Phủ Liên Minh, Pháo Đài Nhân Điện, Yêu Hỏa Không Gian)
	var ch10_tracks: Dictionary = BgmCh10.build_tracks(SAMPLE_RATE)
	for tk10 in ch10_tracks.keys():
		bgm_tracks[str(tk10)] = ch10_tracks[tk10]

	# 19–22. Bộ 4 nhạc nền Đại Kết Cục Chương 11 (Cổ Đế Động Phủ, Song Đế Chi Chiến, Ô Thản Đại Hôn, Đại Thiên Thế Giới)
	var ch11_tracks: Dictionary = BgmCh11.build_tracks(SAMPLE_RATE)
	for tk11 in ch11_tracks.keys():
		bgm_tracks[str(tk11)] = ch11_tracks[tk11]


func _synth_pentatonic_loop(notes: Array, step_sec: float, drone_freq: float, with_drums: bool) -> AudioStreamWAV:
	var note_count: int = notes.size()
	var step_samples: int = maxi(2, int(step_sec * float(SAMPLE_RATE)) & ~1)
	var step_pairs: int = step_samples >> 1
	var total_samples: int = note_count * step_samples
	var total_pairs: int = note_count * step_pairs
	var total_sec: float = float(total_samples) / float(SAMPLE_RATE)
	var dt: float = 2.0 / float(SAMPLE_RATE)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var env_mul: float = exp(-(6.2 if with_drums else 3.8) * dt)
	var h2_mul: float = exp(-5.0 * dt)
	var h3_mul: float = exp(-9.0 * dt)
	var drum_mul: float = exp(-16.0 * dt)
	var atk_inc: float = dt / 0.012
	var d_dph_start: float = TAU * 95.0 * dt
	var d_dph_min: float = TAU * 50.0 * dt
	var d_dph_dec: float = TAU * 45.0 * 9.0 * dt * dt

	var drone_cycles: float = maxf(2.0, roundf(drone_freq * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0

	var prev_f: float = 0.0
	var out_idx: int = 0
	for idx in range(note_count):
		var dph: float = TAU * float(notes[idx]) * dt
		var ph: float = 0.0
		var env: float = 1.0
		var h2_env: float = 1.0
		var h3_env: float = 1.0
		var atk: float = 0.0
		var do_drum: bool = with_drums and ((idx & 1) == 0)
		var d_env: float = 1.0
		var d_ph: float = 0.0
		var d_dph: float = d_dph_start

		for _s in range(step_pairs):
			if atk < 1.0:
				atk = minf(1.0, atk + atk_inc)
			var s1: float = sin(ph)
			var guzheng: float = (
				s1 * 0.58
				+ sin(ph + ph) * 0.24 * h2_env
				+ (s1 * (3.0 - 4.0 * s1 * s1)) * 0.10 * h3_env
			) * env * atk
			ph += dph
			env *= env_mul
			h2_env *= h2_mul
			h3_env *= h3_mul

			var drone: float = sin(drone_ph) * 0.16 + sin(drone5_ph) * 0.07
			drone_ph += d_drone
			drone5_ph += d_drone5

			var drum: float = 0.0
			if do_drum:
				drum = sin(d_ph) * d_env * 0.45
				d_ph += d_dph
				if d_dph > d_dph_min:
					d_dph = maxf(d_dph_min, d_dph - d_dph_dec)
				d_env *= drum_mul

			var cur_f: float = clampf((guzheng * 0.46 + drone + drum) * 0.85, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples)


func _synth_desert_loop() -> AudioStreamWAV:
	# Sa Mạc Tháp Qua Nhĩ: Thang âm D Hijaz / Phrygian Dominant (D, Eb, F#, G, A, Bb, C)
	var notes: Array[float] = [
		293.66, 311.13, 369.99, 440.00, 369.99, 311.13, 293.66, 261.63,
		293.66, 369.99, 440.00, 466.16, 440.00, 369.99, 311.13, 293.66
	]
	# Nhịp trống khung Tây Vực (Daf/Tar): 1=Dum trầm, 2=Tak giòn, 3=Dum nhẹ
	var drum_pat: Array[int] = [1, 0, 2, 0, 1, 0, 2, 2, 1, 0, 3, 0, 1, 0, 2, 2]
	var step_samples: int = int(0.42 * float(SAMPLE_RATE)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = notes.size() * step_samples
	var total_pairs: int = notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(SAMPLE_RATE)
	var dt: float = 2.0 / float(SAMPLE_RATE)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var env_mul: float = exp(-4.1 * dt)
	var h2_mul: float = exp(-5.8 * dt)
	var h3_mul: float = exp(-9.5 * dt)
	var twang_mul: float = exp(-32.0 * dt)
	var dum_mul: float = exp(-12.5 * dt)
	var tak_mul: float = exp(-28.0 * dt)
	var atk_inc: float = dt / 0.009
	var dum_dph_min: float = TAU * 60.0 * dt
	var dum_dph_dec: float = TAU * 58.0 * 10.0 * dt * dt

	var drone_cycles: float = maxf(2.0, roundf(73.42 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var d_lfo: float = TAU * 2.0 / float(total_pairs)
	var d_vib: float = TAU * 5.2 * dt
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0
	var lfo_ph: float = 0.0
	var vib_ph: float = 0.0

	var rng: int = 135792468
	var wind_lp: float = 0.0
	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(notes.size()):
		var base_dph: float = TAU * notes[idx] * dt
		var use_vib: bool = (idx == 1 or idx == 2 or idx == 11 or idx == 14)
		var ph: float = 0.0
		var env: float = 1.0
		var h2_env: float = 1.0
		var h3_env: float = 1.0
		var twang: float = 1.0
		var atk: float = 0.0

		var dp: int = drum_pat[idx]
		var d_env: float = 1.0
		var d_ph: float = 0.0
		var d_dph: float = TAU * (118.0 if dp == 1 else (104.0 if dp == 3 else 270.0)) * dt
		var d_gain: float = 0.34 if dp == 1 else (0.21 if dp == 3 else 0.22)

		for _s in range(step_pairs):
			if atk < 1.0:
				atk = minf(1.0, atk + atk_inc)
			var bend: float = 1.0 + 0.022 * twang
			if use_vib:
				bend += 0.0045 * sin(vib_ph)
				vib_ph += d_vib
			var s1: float = sin(ph)
			var pipa: float = (
				s1 * 0.56
				+ sin(ph + ph) * 0.25 * h2_env
				+ (s1 * (3.0 - 4.0 * s1 * s1)) * 0.12 * h3_env
			) * env * atk
			ph += base_dph * bend
			env *= env_mul
			h2_env *= h2_mul
			h3_env *= h3_mul
			twang *= twang_mul

			# Gió sa mạc lọc trầm + drone D2/A2
			rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF
			var nz: float = float(rng) * (2.0 / 2147483647.0) - 1.0
			wind_lp += 0.082 * (nz - wind_lp)
			var wind_mod: float = 0.71 + 0.29 * sin(lfo_ph)
			var drone: float = sin(drone_ph) * 0.17 + sin(drone5_ph) * 0.08 + wind_lp * 0.17 * wind_mod
			drone_ph += d_drone
			drone5_ph += d_drone5
			lfo_ph += d_lfo

			var drum: float = 0.0
			if dp == 1 or dp == 3:
				drum = sin(d_ph) * d_env * d_gain
				d_ph += d_dph
				if d_dph > dum_dph_min:
					d_dph = maxf(dum_dph_min, d_dph - dum_dph_dec)
				d_env *= dum_mul
			elif dp == 2:
				drum = (sin(d_ph) * 0.65 + nz * 0.35) * d_env * d_gain
				d_ph += d_dph
				d_env *= tak_mul

			var cur_f: float = clampf((pipa * 0.44 + drone + drum) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples)


func _synth_lava_loop() -> AudioStreamWAV:
	# Địa Huyệt Dung Nham: Bass địa mạch trầm gầm + Chuông kim loại u ám + Trống nhịp tim
	var bass_notes: Array[float] = [
		73.42, 73.42, 77.78, 73.42, 87.31, 77.78, 65.41, 73.42,
		73.42, 73.42, 103.83, 87.31, 77.78, 73.42, 65.41, 69.30
	]
	# Điểm nhấn chuông đồng/kim loại cao vút (0.0 = để chuông cũ ngân tiếp qua bước sau)
	var bell_notes: Array[float] = [
		587.33, 0.0, 622.25, 0.0, 0.0, 830.61, 0.0, 587.33,
		698.46, 0.0, 0.0, 622.25, 880.00, 0.0, 622.25, 0.0
	]
	# Nhịp tim trống chiến: 1=nhịp mạnh (lub), 2=nhịp bồi (dub)
	var drum_pat: Array[int] = [1, 2, 0, 0, 1, 2, 0, 0, 1, 2, 0, 0, 1, 2, 2, 2]
	var step_samples: int = int(0.40 * float(SAMPLE_RATE)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = bass_notes.size() * step_samples
	var total_pairs: int = bass_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(SAMPLE_RATE)
	var dt: float = 2.0 / float(SAMPLE_RATE)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var bass_mul: float = exp(-3.4 * dt)
	var bell_mul: float = exp(-3.2 * dt)
	var bell_hi_mul: float = exp(-7.5 * dt)
	var lub_mul: float = exp(-11.5 * dt)
	var dub_mul: float = exp(-15.5 * dt)
	var atk_inc: float = dt / 0.014
	var lub_dph_min: float = TAU * 36.0 * dt
	var lub_dph_dec: float = TAU * 50.0 * 9.5 * dt * dt
	var dub_dph_min: float = TAU * 42.0 * dt
	var dub_dph_dec: float = TAU * 32.0 * 11.0 * dt * dt

	var sub_cycles: float = maxf(2.0, roundf(73.42 * total_sec * 0.5) * 2.0)
	var d_sub: float = TAU * sub_cycles / float(total_pairs)
	var d_lfo: float = TAU * 2.0 / float(total_pairs)
	var sub_ph: float = 0.0
	var lfo_ph: float = 0.0

	var b_ph: float = 0.0
	var b_dph: float = 0.0
	var b_env: float = 0.0
	var b_hi: float = 0.0

	var rng: int = 246813579
	var rumble_lp: float = 0.0
	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(bass_notes.size()):
		var bass_dph: float = TAU * bass_notes[idx] * dt
		var bass_ph: float = 0.0
		var bass_env: float = 1.0
		var bass_atk: float = 0.0

		var bf: float = bell_notes[idx]
		if bf > 0.0:
			b_dph = TAU * bf * dt
			b_ph = 0.0
			b_env = 1.0
			b_hi = 1.0

		var dp: int = drum_pat[idx]
		var d_env: float = 1.0
		var d_ph: float = 0.0
		var d_dph: float = TAU * (86.0 if dp == 1 else 74.0) * dt

		for _s in range(step_pairs):
			if bass_atk < 1.0:
				bass_atk = minf(1.0, bass_atk + atk_inc)
			var bs1: float = sin(bass_ph)
			var raw_bass: float = (
				bs1 * 0.62
				+ sin(bass_ph + bass_ph) * 0.28
				+ (bs1 * (3.0 - 4.0 * bs1 * bs1)) * 0.10
			) * bass_env * bass_atk
			var bass_sat: float = raw_bass / (1.0 + 0.35 * absf(raw_bass))
			bass_ph += bass_dph
			bass_env *= bass_mul

			# Tiếng ầm ĩ địa mạch dung nham (sub-drone + tiếng sôi trầm)
			rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF
			var nz: float = float(rng) * (2.0 / 2147483647.0) - 1.0
			rumble_lp += 0.036 * (nz - rumble_lp)
			var magma_mod: float = 0.65 + 0.35 * sin(lfo_ph)
			var magma: float = sin(sub_ph) * 0.15 + rumble_lp * 0.28 * magma_mod
			sub_ph += d_sub
			lfo_ph += d_lfo

			# Chuông kim loại căng thẳng (hòa âm phi điều hòa 2.756x)
			var bell: float = 0.0
			if b_env > 0.002:
				bell = (
					sin(b_ph) * 0.56
					+ sin(b_ph + b_ph) * 0.22
					+ sin(b_ph * 2.756) * 0.22 * b_hi
				) * b_env * 0.28
				b_ph += b_dph
				b_env *= bell_mul
				b_hi *= bell_hi_mul

			var drum: float = 0.0
			if dp == 1:
				drum = sin(d_ph) * d_env * 0.44
				d_ph += d_dph
				if d_dph > lub_dph_min:
					d_dph = maxf(lub_dph_min, d_dph - lub_dph_dec)
				d_env *= lub_mul
			elif dp == 2:
				drum = sin(d_ph) * d_env * 0.28
				d_ph += d_dph
				if d_dph > dub_dph_min:
					d_dph = maxf(dub_dph_min, d_dph - dub_dph_dec)
				d_env *= dub_mul

			var cur_f: float = clampf((bass_sat * 0.38 + magma + bell + drum) * 0.86, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples)


func _synth_capital_loop() -> AudioStreamWAV:
	# Hoàng Thành Gia Mã Đế Đô: Ngũ cung Cung Điệu uy nghi (C-D-E-G-A)
	var lead_notes: Array[float] = [
		392.00, 440.00, 523.25, 587.33, 659.25, 587.33, 523.25, 440.00,
		523.25, 659.25, 783.99, 659.25, 587.33, 523.25, 440.00, 392.00
	]
	var arp_lo: Array[float] = [
		261.63, 329.63, 261.63, 293.66, 220.00, 261.63, 220.00, 261.63,
		293.66, 329.63, 392.00, 329.63, 293.66, 261.63, 196.00, 261.63
	]
	var arp_hi: Array[float] = [
		392.00, 523.25, 392.00, 440.00, 329.63, 440.00, 329.63, 392.00,
		440.00, 523.25, 587.33, 523.25, 440.00, 392.00, 293.66, 392.00
	]
	var step_samples: int = int(0.45 * float(SAMPLE_RATE)) & ~1
	var step_pairs: int = step_samples >> 1
	var half_pairs: int = step_pairs >> 1
	var total_samples: int = lead_notes.size() * step_samples
	var total_pairs: int = lead_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(SAMPLE_RATE)
	var dt: float = 2.0 / float(SAMPLE_RATE)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var lead_mul: float = exp(-2.1 * dt)
	var arp_mul: float = exp(-6.8 * dt)
	var chime_mul: float = exp(-1.9 * dt)
	var chime_hi_mul: float = exp(-5.0 * dt)
	var drum_mul: float = exp(-10.5 * dt)
	var wood_mul: float = exp(-30.0 * dt)
	var lead_atk_inc: float = dt / 0.032
	var arp_atk_inc: float = dt / 0.008
	var drum_dph_min: float = TAU * 54.0 * dt
	var drum_dph_dec: float = TAU * 42.0 * 9.0 * dt * dt

	var drone_cycles: float = maxf(2.0, roundf(130.81 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0

	var c_ph: float = 0.0
	var c_dph: float = 0.0
	var c_env: float = 0.0
	var c_hi: float = 0.0
	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(lead_notes.size()):
		var l_dph: float = TAU * lead_notes[idx] * dt
		var l_ph: float = 0.0
		var l_env: float = 1.0
		var l_atk: float = 0.0

		# Chuông Biên Chung hoàng gia vang lên đầu mỗi khuông nhịp (0, 4, 8, 12)
		if (idx % 4) == 0:
			c_dph = TAU * (lead_notes[idx] * 2.0) * dt
			c_ph = 0.0
			c_env = 1.0
			c_hi = 1.0

		var a_dph1: float = TAU * arp_lo[idx] * dt
		var a_dph2: float = TAU * arp_hi[idx] * dt
		var a_ph: float = 0.0
		var a_env: float = 1.0
		var a_atk: float = 0.0

		var perc_kind: int = 1 if (idx % 8 == 0) else (2 if (idx % 4 == 0) else (3 if (idx % 2 == 0) else 0))
		var p_env: float = 1.0
		var p_ph: float = 0.0
		var p_dph: float = TAU * (96.0 if perc_kind == 1 else (112.0 if perc_kind == 2 else 720.0)) * dt

		for s in range(step_pairs):
			if s == half_pairs:
				a_ph = 0.0
				a_env = 1.0
				a_atk = 0.0
			if l_atk < 1.0:
				l_atk = minf(1.0, l_atk + lead_atk_inc)
			if a_atk < 1.0:
				a_atk = minf(1.0, a_atk + arp_atk_inc)

			# Kèn đồng / hòa âm uy nghi cung đình (tối ưu bằng đồng nhất thức lượng giác)
			var ls1: float = sin(l_ph)
			var lc1: float = cos(l_ph)
			var ls2: float = 2.0 * ls1 * lc1
			var ls3: float = ls1 * (3.0 - 4.0 * ls1 * ls1)
			var ls4: float = 2.0 * ls2 * (1.0 - 2.0 * ls1 * ls1)
			var brass: float = (ls1 * 0.48 + ls2 * 0.26 + ls3 * 0.15 + ls4 * 0.08) * l_env * l_atk
			l_ph += l_dph
			l_env *= lead_mul

			# Cổ Tranh rải âm hai nốt mỗi nhịp
			var a_dph: float = a_dph1 if s < half_pairs else a_dph2
			var guzheng: float = (sin(a_ph) * 0.68 + sin(a_ph + a_ph) * 0.24) * a_env * a_atk
			a_ph += a_dph
			a_env *= arp_mul

			# Biên Chung hoàng kim
			var chime: float = 0.0
			if c_env > 0.002:
				chime = (sin(c_ph) * 0.64 + sin(c_ph * 2.41) * 0.26 * c_hi) * c_env * 0.20
				c_ph += c_dph
				c_env *= chime_mul
				c_hi *= chime_hi_mul

			# Nền Đế Đô C3/G3
			var drone: float = sin(drone_ph) * 0.16 + sin(drone5_ph) * 0.08
			drone_ph += d_drone
			drone5_ph += d_drone5

			# Bộ gõ cung đình (Trống đại lễ & Phách gỗ)
			var perc: float = 0.0
			if perc_kind == 1 or perc_kind == 2:
				var pg: float = 0.36 if perc_kind == 1 else 0.22
				perc = sin(p_ph) * p_env * pg
				p_ph += p_dph
				if p_dph > drum_dph_min:
					p_dph = maxf(drum_dph_min, p_dph - drum_dph_dec)
				p_env *= drum_mul
			elif perc_kind == 3:
				perc = (sin(p_ph) * 0.72 + sin(p_ph * 2.15) * 0.28) * p_env * 0.14
				p_ph += p_dph
				p_env *= wood_mul

			var cur_f: float = clampf((brass * 0.30 + guzheng * 0.22 + chime + drone + perc) * 0.90, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples)


func _synth_yunlan_loop() -> AudioStreamWAV:
	# Đỉnh Vân Lam Sơn & Ước Hẹn 3 Năm: Sáo trúc thanh thoát + Kiếm phong + Đàn dây & Trống sử thi
	var flute_notes: Array[float] = [
		659.25, 783.99, 880.00, 987.77, 880.00, 783.99, 659.25, 587.33,
		659.25, 880.00, 987.77, 1174.66, 987.77, 880.00, 783.99, 659.25
	]
	# Vòng hòa âm sử thi tăng tiến: Em -> C -> D -> Em -> G -> A -> B
	var str_bass: Array[float] = [
		82.41, 82.41, 82.41, 82.41, 65.41, 65.41, 73.42, 73.42,
		73.42, 73.42, 82.41, 82.41, 98.00, 110.00, 123.47, 123.47
	]
	# Trống chiến Vân Lam tăng dần kịch tính ở nửa sau
	var drum_pat: Array[int] = [1, 0, 0, 2, 1, 0, 2, 0, 1, 0, 2, 0, 1, 2, 1, 2]
	var step_samples: int = int(0.42 * float(SAMPLE_RATE)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = flute_notes.size() * step_samples
	var total_pairs: int = flute_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(SAMPLE_RATE)
	var dt: float = 2.0 / float(SAMPLE_RATE)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var flute_mul: float = exp(-1.65 * dt)
	var drum1_mul: float = exp(-13.5 * dt)
	var drum2_mul: float = exp(-22.0 * dt)
	var flute_atk_inc: float = dt / 0.042
	var str_atk_inc: float = dt / 0.035
	var drum_dph_min: float = TAU * 50.0 * dt
	var drum_dph_dec: float = TAU * 52.0 * 10.0 * dt * dt

	var d_vib: float = TAU * 5.6 * dt
	var d_swell: float = TAU / float(total_pairs)
	var sword_cycles: float = maxf(2.0, roundf(1318.51 * total_sec * 0.5) * 2.0)
	var d_sword: float = TAU * sword_cycles / float(total_pairs)
	var vib_ph: float = 0.0
	var swell_ph: float = -PI * 0.5
	var sword_ph: float = 0.0
	var str_ph: float = 0.0

	var rng: int = 987654321
	var lp_fast: float = 0.0
	var lp_slow: float = 0.0
	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(flute_notes.size()):
		var f_base_dph: float = TAU * flute_notes[idx] * dt
		var f_ph: float = 0.0
		var f_env: float = 1.0
		var f_atk: float = 0.0

		var s_dph: float = TAU * str_bass[idx] * dt
		var s_atk: float = 0.65 if (idx > 0 and is_equal_approx(str_bass[idx], str_bass[idx - 1])) else 0.25

		var dp: int = drum_pat[idx]
		var d_env: float = 1.0
		var d_ph: float = 0.0
		var d_dph: float = TAU * (102.0 if dp == 1 else 168.0) * dt

		for _s in range(step_pairs):
			if f_atk < 1.0:
				f_atk = minf(1.0, f_atk + flute_atk_inc)
			if s_atk < 1.0:
				s_atk = minf(1.0, s_atk + str_atk_inc)

			# Sáo trúc Vân Đỉnh luyến láy (vibrato mượt)
			var vib_mod: float = 1.0 + 0.0058 * sin(vib_ph) * f_atk
			vib_ph += d_vib
			var fs1: float = sin(f_ph)
			var flute: float = (
				fs1 * 0.68
				+ sin(f_ph + f_ph) * 0.22
				+ (fs1 * (3.0 - 4.0 * fs1 * fs1)) * 0.08
			) * f_env * f_atk
			f_ph += f_base_dph * vib_mod
			f_env *= flute_mul

			# Kiếm phong & gió mây đỉnh núi (lọc thông dải + hòa âm E6 thanh cao)
			rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF
			var nz: float = float(rng) * (2.0 / 2147483647.0) - 1.0
			lp_fast += 0.39 * (nz - lp_fast)
			lp_slow += 0.078 * (nz - lp_slow)
			var wind_band: float = lp_fast - lp_slow
			var swell: float = 0.5 + 0.5 * sin(swell_ph)
			swell_ph += d_swell
			var sword_wind: float = (wind_band * 0.14 + sin(sword_ph) * 0.045) * (0.45 + 0.55 * swell)
			sword_ph += d_sword

			# Dàn đàn dây sử thi dâng trào theo cao trào Ước Hẹn 3 Năm
			var dyn: float = 0.72 + 0.36 * swell
			var strings: float = (
				sin(str_ph) * 0.54
				+ sin(str_ph * 1.5) * 0.20
				+ sin(str_ph + str_ph) * 0.26
			) * s_atk * dyn * 0.26
			str_ph += s_dph

			# Trống chiến sử thi
			var drum: float = 0.0
			if dp == 1:
				drum = sin(d_ph) * d_env * (0.34 + 0.10 * swell)
				d_ph += d_dph
				if d_dph > drum_dph_min:
					d_dph = maxf(drum_dph_min, d_dph - drum_dph_dec)
				d_env *= drum1_mul
			elif dp == 2:
				drum = (sin(d_ph) * 0.70 + nz * 0.30) * d_env * (0.20 + 0.08 * swell)
				d_ph += d_dph
				d_env *= drum2_mul

			var cur_f: float = clampf((flute * 0.33 + strings + sword_wind + drum) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples)


func _pack_loop_wav(pcm: PackedByteArray, total_samples: int) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	wav.data = pcm
	return wav


# =========================================================
# TỔNG HỢP 22 HIỆU ỨNG SFX CHIẾN ĐẤU, PHÁ THẾ, ĐAN ĐẠO & GIAO DIỆN
# =========================================================
func _build_all_sfx() -> void:
	sfx_streams["swing_unarmed"] = _synth_sweep(260.0, 110.0, 0.11, 0.55, 0.25)
	sfx_streams["swing_blade"] = _synth_sweep(680.0, 210.0, 0.13, 0.50, 0.35)
	sfx_streams["swing_heavy"] = _synth_sweep(210.0, 68.0, 0.22, 0.72, 0.40)
	sfx_streams["hit_impact"] = _synth_sweep(190.0, 52.0, 0.10, 0.78, 0.45)
	sfx_streams["hit_crit"] = _synth_chord([440.0, 659.25, 880.0], 0.16, 0.70, true)
	sfx_streams["player_hurt"] = _synth_sweep(165.0, 62.0, 0.16, 0.75, 0.35)
	sfx_streams["dash_whoosh"] = _synth_sweep(420.0, 860.0, 0.14, 0.40, 0.55)
	sfx_streams["skill_fire"] = _synth_sweep(340.0, 140.0, 0.28, 0.65, 0.58)
	sfx_streams["skill_burst"] = _synth_sweep(290.0, 58.0, 0.32, 0.80, 0.52)
	sfx_streams["skill_stun"] = _synth_chord([392.0, 523.25, 783.99], 0.28, 0.70, false, true)
	sfx_streams["thunder_blink"] = _synth_sweep(1480.0, 260.0, 0.22, 0.72, 0.70)
	sfx_streams["radar_ping"] = _synth_chord([659.25, 987.77, 1318.5], 0.34, 0.52, false, true)
	sfx_streams["poise_break"] = _synth_poise_break()
	sfx_streams["level_up"] = _synth_arpeggio([440.0, 554.37, 659.25, 880.0], 0.08, 0.62)
	sfx_streams["breakthrough"] = _synth_breakthrough()
	sfx_streams["loot_pickup"] = _synth_arpeggio([587.33, 880.0], 0.055, 0.42)
	sfx_streams["loot_rare"] = _synth_arpeggio([523.25, 659.25, 783.99, 1046.5], 0.07, 0.68)
	sfx_streams["chest_open"] = _synth_arpeggio([392.0, 493.88, 587.33, 783.99], 0.085, 0.72)
	sfx_streams["alchemy_tick"] = _synth_sweep(520.0, 640.0, 0.07, 0.38, 0.08)
	sfx_streams["alchemy_success"] = _synth_arpeggio([440.0, 587.33, 739.99, 880.0, 1174.66], 0.075, 0.70)
	sfx_streams["alchemy_fail"] = _synth_sweep(180.0, 45.0, 0.30, 0.75, 0.65)
	sfx_streams["ui_click"] = _synth_sweep(640.0, 480.0, 0.045, 0.32, 0.05)
	sfx_streams["portal_warp"] = _synth_arpeggio([329.63, 440.0, 659.25, 987.77], 0.065, 0.58)
	sfx_streams["boss_roar"] = _synth_sweep(150.0, 48.0, 0.45, 0.85, 0.48)


func _synth_poise_break() -> AudioStreamWAV:
	# Phá Thế (Boss Poise Break): Vỡ giáp pha lê/ngọc bích sắc bén + Cồng đồng cổ vang dội trầm hùng!
	var dur: float = 0.58
	var n: int = maxi(1, int(dur * float(SAMPLE_RATE)))
	var inv_sr: float = 1.0 / float(SAMPLE_RATE)
	var inv_n: float = 1.0 / float(n)
	var pcm := PackedByteArray()
	pcm.resize(n * 2)

	var gong_ph: float = 0.0
	var sub_ph: float = 0.0
	var shim_ph: float = 0.0
	var sub_dph: float = TAU * 55.0 * inv_sr
	var shim_dph: float = TAU * 6.5 * inv_sr
	var gong_env: float = 1.0
	var sub_env: float = 1.0
	var crack_env: float = 1.0
	var bend_env: float = 1.0
	var gong_mul: float = exp(-4.2 * inv_sr)
	var sub_mul: float = exp(-9.5 * inv_sr)
	var crack_mul: float = exp(-19.0 * inv_sr)
	var bend_mul: float = exp(-14.0 * inv_sr)

	var rng: int = 55119933
	var prev_nz: float = 0.0
	var shard_freqs: Array[float] = [1760.0, 2349.32, 2793.83, 3520.0, 4186.01]
	var shard_delays: Array[int] = [0, 580, 1280, 2050, 2900]
	var shard_envs: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
	var shard_phs: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
	var shard_dphs: Array[float] = []
	for sf in shard_freqs:
		shard_dphs.append(TAU * sf * inv_sr)
	var shard_mul: float = exp(-17.5 * inv_sr)

	for i in range(n):
		var u: float = float(i) * inv_n
		var atk: float = minf(1.0, float(i) / 90.0)

		# 1. Các mảnh pha lê/giáp vỡ bật liên tiếp
		var shards: float = 0.0
		for k in range(5):
			if i == shard_delays[k]:
				shard_envs[k] = 1.0 - float(k) * 0.12
			var se: float = shard_envs[k]
			if se > 0.002:
				var sp: float = shard_phs[k]
				shards += (sin(sp) * 0.72 + sin(sp * 1.498) * 0.28) * se
				shard_phs[k] = sp + shard_dphs[k]
				shard_envs[k] = se * shard_mul

		# Tiếng vỡ lọc thông cao (high-pass crackle)
		rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF
		var nz: float = float(rng) * (2.0 / 2147483647.0) - 1.0
		var hp_nz: float = (nz - prev_nz) * 0.5
		prev_nz = nz
		var shatter: float = shards * 0.24 + hp_nz * crack_env * 0.42
		crack_env *= crack_mul

		# 2. Cồng đồng vang dội trầm hùng (giảm cao độ nhẹ khi va chạm + hòa âm đồng thau)
		var gong_freq: float = 104.0 + 24.0 * bend_env
		bend_env *= bend_mul
		gong_ph += TAU * gong_freq * inv_sr
		sub_ph += sub_dph
		var shimmer: float = 0.86 + 0.14 * sin(shim_ph)
		shim_ph += shim_dph
		var gong: float = (
			sin(gong_ph) * 0.46
			+ sin(gong_ph * 1.50) * 0.24
			+ sin(gong_ph * 2.13) * 0.18
			+ sin(gong_ph * 2.86) * 0.12
		) * gong_env * shimmer * 0.56 + sin(sub_ph) * sub_env * 0.36
		gong_env *= gong_mul
		sub_env *= sub_mul

		var tail_fade: float = 1.0 if u < 0.88 else maxf(0.0, (1.0 - u) / 0.12)
		var v: float = clampf((shatter + gong) * atk * tail_fade * 0.92, -0.95, 0.95)
		pcm.encode_s16(i * 2, int(v * 32767.0))

	return _pack_wav(pcm)


func _synth_breakthrough() -> AudioStreamWAV:
	# Đột Phá Cảnh Giới: Rải âm Ngũ Cung D Trưởng thăng hoa + hòa âm kim quang & nền D3 ấm áp
	var freqs: Array[float] = [293.66, 369.99, 440.0, 587.33, 739.99, 880.0, 1174.66]
	var note_samples: int = maxi(1, int(0.085 * float(SAMPLE_RATE)))
	var finale_extra: int = int(0.11 * float(SAMPLE_RATE))
	var total_samples: int = note_samples * freqs.size() + finale_extra
	var inv_sr: float = 1.0 / float(SAMPLE_RATE)
	var inv_total: float = 1.0 / float(total_samples)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var base_ph: float = 0.0
	var base_dph: float = TAU * 146.83 * inv_sr
	var ring_ph: float = 0.0
	var ring_dph: float = TAU * 587.33 * inv_sr
	var out_idx: int = 0
	var sample_i: int = 0

	for idx in range(freqs.size()):
		var seg_len: int = note_samples if idx < freqs.size() - 1 else (note_samples + finale_extra)
		var dph: float = TAU * freqs[idx] * inv_sr
		var ph: float = 0.0
		var env: float = 1.0
		var h3_env: float = 1.0
		var decay_k: float = 2.6 if idx == freqs.size() - 1 else 3.2
		var env_mul: float = exp(-decay_k / float(seg_len))
		var h3_mul: float = exp(-4.5 / float(seg_len))
		var atk_inc: float = 22.0 / float(seg_len)
		var atk: float = 0.0

		for _s in range(seg_len):
			if atk < 1.0:
				atk = minf(1.0, atk + atk_inc)
			var s1: float = sin(ph)
			var lead: float = (
				s1 * 0.56
				+ sin(ph * 1.5) * 0.14
				+ sin(ph + ph) * 0.22
				+ (s1 * (3.0 - 4.0 * s1 * s1)) * 0.08 * h3_env
			) * env * atk
			ph += dph
			env *= env_mul
			h3_env *= h3_mul

			var pad_env: float = sin(PI * float(sample_i) * inv_total) * 0.24
			var pad: float = (sin(base_ph) * 0.70 + sin(ring_ph) * 0.30) * pad_env
			base_ph += base_dph
			ring_ph += ring_dph
			sample_i += 1

			var val: float = clampf((lead * 0.78 + pad) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int(val * 32767.0))
			out_idx += 2

	return _pack_wav(pcm)


func _synth_sweep(f0: float, f1: float, dur: float, amp: float, noise_mix: float) -> AudioStreamWAV:
	var n: int = maxi(1, int(dur * float(SAMPLE_RATE)))
	var inv_n: float = 1.0 / float(n)
	var inv_sr: float = 1.0 / float(SAMPLE_RATE)
	var tone_mix: float = 1.0 - noise_mix
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	var phase: float = 0.0
	var rng: int = int(f0 * 100.0) ^ int(f1 * 37.0) ^ 0x51A37B
	for i in range(n):
		var u: float = float(i) * inv_n
		var f: float = f0 + (f1 - f0) * u
		phase += TAU * f * inv_sr
		var env: float = (1.0 - u) * minf(1.0, u * 18.0)
		rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF
		var nz: float = float(rng) * (2.0 / 2147483647.0) - 1.0
		var v: float = clampf((sin(phase) * tone_mix + nz * noise_mix) * env * amp, -0.95, 0.95)
		pcm.encode_s16(i * 2, int(v * 32767.0))
	return _pack_wav(pcm)


func _synth_chord(freqs: Array, dur: float, amp: float, sharp: bool, rich_harmonics: bool = false) -> AudioStreamWAV:
	var n: int = maxi(1, int(dur * float(SAMPLE_RATE)))
	var inv_n: float = 1.0 / float(n)
	var inv_sr: float = 1.0 / float(SAMPLE_RATE)
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	var inv_count: float = 1.0 / maxf(1.0, float(freqs.size()))
	var env_mul: float = exp(-(5.5 if sharp else 3.2) * inv_n)
	var hi_mul: float = exp(-6.0 * inv_n)
	var env: float = 1.0
	var hi_env: float = 1.0
	var shim_ph: float = 0.0
	var shim_dph: float = TAU * 14.0 * inv_sr
	var dphs: Array[float] = []
	var phs: Array[float] = []
	for f_val in freqs:
		dphs.append(TAU * float(f_val) * inv_sr)
		phs.append(0.0)
	var fc: int = freqs.size()

	for i in range(n):
		var atk: float = minf(1.0, float(i) * inv_n * 25.0)
		var acc: float = 0.0
		if rich_harmonics:
			for k in range(fc):
				var p: float = phs[k]
				var s1: float = sin(p)
				acc += s1 * 0.64 + sin(p + p) * 0.24 * hi_env + (s1 * (3.0 - 4.0 * s1 * s1)) * 0.12 * hi_env
				phs[k] = p + dphs[k]
			acc *= (0.90 + 0.10 * sin(shim_ph))
			shim_ph += shim_dph
			hi_env *= hi_mul
		else:
			for k in range(fc):
				var p: float = phs[k]
				acc += sin(p)
				phs[k] = p + dphs[k]
		var v: float = clampf(acc * inv_count * env * atk * amp, -0.95, 0.95)
		env *= env_mul
		pcm.encode_s16(i * 2, int(v * 32767.0))
	return _pack_wav(pcm)


func _synth_arpeggio(freqs: Array, note_dur: float, amp: float) -> AudioStreamWAV:
	var note_samples: int = maxi(1, int(note_dur * float(SAMPLE_RATE)))
	var total_samples: int = note_samples * freqs.size()
	var inv_sr: float = 1.0 / float(SAMPLE_RATE)
	var env_mul: float = exp(-3.4 / float(note_samples))
	var atk_inc: float = 20.0 / float(note_samples)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)
	var out_idx: int = 0
	for f_val in freqs:
		var dph: float = TAU * float(f_val) * inv_sr
		var ph: float = 0.0
		var env: float = 1.0
		var atk: float = 0.0
		for _s in range(note_samples):
			if atk < 1.0:
				atk = minf(1.0, atk + atk_inc)
			var val: float = (sin(ph) * 0.72 + sin(ph + ph) * 0.28) * env * atk * amp
			ph += dph
			env *= env_mul
			pcm.encode_s16(out_idx, int(clampf(val, -0.95, 0.95) * 32767.0))
			out_idx += 2
	return _pack_wav(pcm)


func _pack_wav(pcm: PackedByteArray) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = pcm
	return wav
