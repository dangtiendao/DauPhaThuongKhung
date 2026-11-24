extends Node
## Hệ thống Âm Thanh & Nhạc Nền Cổ Phong Tiên Hiệp Tổng Hợp Trực Tiếp (Procedural AudioStreamWAV):
## - Không phụ thuộc file MP3 ngoài -> hoạt động tức thì, âm sắc trong trẻo chuẩn Ngũ Cung Cổ Trang (Cổ Tranh / Sáo Trúc / Trống Chiến).
## - 3 Bản nhạc nền tự động chuyển mượt theo bản đồ & trạng thái Boss: bgm_peaceful, bgm_wild, bgm_boss.
## - 17 Hiệu ứng SFX chiến đấu, nhặt đồ, mở rương, luyện đan, đột phá, giao diện có biến thiên cao độ (pitch jitter).

const SETTINGS_PATH: String = "user://dptk_settings.json"
const SAMPLE_RATE: int = 22050

var bgm_volume: float = 0.65
var sfx_volume: float = 0.80
var is_muted: bool = false

var bgm_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
var sfx_pool_idx: int = 0

var bgm_tracks: Dictionary = {}
var sfx_streams: Dictionary = {}
var current_bgm_name: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings()

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


func play_bgm(track_name: String) -> void:
	if track_name == "" or track_name == current_bgm_name:
		return
	if not bgm_tracks.has(track_name):
		return
	current_bgm_name = track_name
	bgm_player.stream = bgm_tracks[track_name]
	_apply_volumes()
	bgm_player.play()


func play_sfx(sfx_name: String, pitch_jitter: float = 0.07) -> void:
	if is_muted or sfx_volume <= 0.001:
		return
	if not sfx_streams.has(sfx_name):
		return
	var p: AudioStreamPlayer = sfx_pool[sfx_pool_idx]
	sfx_pool_idx = (sfx_pool_idx + 1) % sfx_pool.size()
	p.stream = sfx_streams[sfx_name]
	p.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter) if pitch_jitter > 0.0 else 1.0
	p.volume_db = linear_to_db(sfx_volume * 0.72)
	p.play()


# =========================================================
# TỔNG HỢP NHẠC NỀN NGŨ CUNG CỔ TRANG (GUZHENG / FLUTE / WAR DRUMS)
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


func _synth_pentatonic_loop(notes: Array, step_sec: float, drone_freq: float, with_drums: bool) -> AudioStreamWAV:
	var total_sec: float = float(notes.size()) * step_sec
	var total_samples: int = int(total_sec * float(SAMPLE_RATE))
	var step_samples: int = int(step_sec * float(SAMPLE_RATE))
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(SAMPLE_RATE)
		var idx: int = min(notes.size() - 1, i / max(1, step_samples))
		var local_t: float = float(i % max(1, step_samples)) / float(SAMPLE_RATE)
		var freq: float = float(notes[idx])

		# Âm đàn Cổ Tranh (Guzheng pluck): hòa âm 1x + 2x + 3x tắt dần tự nhiên
		var env: float = exp(-local_t * (6.2 if with_drums else 3.8))
		var attack: float = minf(1.0, local_t / 0.012)
		var guzheng: float = (
			sin(TAU * freq * t) * 0.58
			+ sin(TAU * freq * 2.0 * t) * 0.24 * exp(-local_t * 5.0)
			+ sin(TAU * freq * 3.0 * t) * 0.10 * exp(-local_t * 9.0)
		) * env * attack

		# Nền sáo/drone trầm êm dịu
		var drone: float = (sin(TAU * drone_freq * t) * 0.16 + sin(TAU * drone_freq * 1.5 * t) * 0.07)

		# Trống chiến Taiko cho nhạc Boss
		var drum: float = 0.0
		if with_drums and (idx % 2 == 0):
			var d_env: float = exp(-local_t * 16.0)
			var d_pitch: float = 95.0 - 45.0 * minf(1.0, local_t * 9.0)
			drum = sin(TAU * d_pitch * local_t) * d_env * 0.45

		var sample_f: float = clampf((guzheng * 0.46 + drone + drum) * 0.85, -0.95, 0.95)
		var s16: int = int(sample_f * 32767.0)
		pcm[i * 2] = s16 & 0xFF
		pcm[i * 2 + 1] = (s16 >> 8) & 0xFF

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
# TỔNG HỢP 17 HIỆU ỨNG SFX CHIẾN ĐẤU, ĐAN ĐẠO & GIAO DIỆN
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
	sfx_streams["skill_stun"] = _synth_chord([392.0, 523.25, 783.99], 0.26, 0.68, false)
	sfx_streams["level_up"] = _synth_arpeggio([440.0, 554.37, 659.25, 880.0], 0.08, 0.62)
	sfx_streams["breakthrough"] = _synth_arpeggio([293.66, 369.99, 440.0, 587.33, 739.99, 880.0], 0.09, 0.78)
	sfx_streams["loot_pickup"] = _synth_arpeggio([587.33, 880.0], 0.055, 0.42)
	sfx_streams["loot_rare"] = _synth_arpeggio([523.25, 659.25, 783.99, 1046.5], 0.07, 0.68)
	sfx_streams["chest_open"] = _synth_arpeggio([392.0, 493.88, 587.33, 783.99], 0.085, 0.72)
	sfx_streams["alchemy_tick"] = _synth_sweep(520.0, 640.0, 0.07, 0.38, 0.08)
	sfx_streams["alchemy_success"] = _synth_arpeggio([440.0, 587.33, 739.99, 880.0, 1174.66], 0.075, 0.70)
	sfx_streams["alchemy_fail"] = _synth_sweep(180.0, 45.0, 0.30, 0.75, 0.65)
	sfx_streams["ui_click"] = _synth_sweep(640.0, 480.0, 0.045, 0.32, 0.05)
	sfx_streams["portal_warp"] = _synth_arpeggio([329.63, 440.0, 659.25, 987.77], 0.065, 0.58)
	sfx_streams["boss_roar"] = _synth_sweep(150.0, 48.0, 0.45, 0.85, 0.48)


func _synth_sweep(f0: float, f1: float, dur: float, amp: float, noise_mix: float) -> AudioStreamWAV:
	var n: int = max(1, int(dur * float(SAMPLE_RATE)))
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	var phase: float = 0.0
	for i in range(n):
		var u: float = float(i) / float(n)
		var f: float = lerpf(f0, f1, u)
		phase += TAU * f / float(SAMPLE_RATE)
		var env: float = (1.0 - u) * minf(1.0, u * 18.0)
		var tone: float = sin(phase)
		var nz: float = randf_range(-1.0, 1.0)
		var v: float = clampf((tone * (1.0 - noise_mix) + nz * noise_mix) * env * amp, -0.95, 0.95)
		var s16: int = int(v * 32767.0)
		pcm[i * 2] = s16 & 0xFF
		pcm[i * 2 + 1] = (s16 >> 8) & 0xFF
	return _pack_wav(pcm)


func _synth_chord(freqs: Array, dur: float, amp: float, sharp: bool) -> AudioStreamWAV:
	var n: int = max(1, int(dur * float(SAMPLE_RATE)))
	var pcm := PackedByteArray()
	pcm.resize(n * 2)
	for i in range(n):
		var t: float = float(i) / float(SAMPLE_RATE)
		var u: float = float(i) / float(n)
		var env: float = exp(-u * (5.5 if sharp else 3.2)) * minf(1.0, u * 25.0)
		var acc: float = 0.0
		for f_val in freqs:
			acc += sin(TAU * float(f_val) * t)
		acc /= maxf(1.0, float(freqs.size()))
		var v: float = clampf(acc * env * amp, -0.95, 0.95)
		var s16: int = int(v * 32767.0)
		pcm[i * 2] = s16 & 0xFF
		pcm[i * 2 + 1] = (s16 >> 8) & 0xFF
	return _pack_wav(pcm)


func _synth_arpeggio(freqs: Array, note_dur: float, amp: float) -> AudioStreamWAV:
	var note_samples: int = max(1, int(note_dur * float(SAMPLE_RATE)))
	var total_samples: int = note_samples * freqs.size()
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)
	for i in range(total_samples):
		var idx: int = min(freqs.size() - 1, i / note_samples)
		var lt: float = float(i % note_samples) / float(SAMPLE_RATE)
		var lu: float = float(i % note_samples) / float(note_samples)
		var f: float = float(freqs[idx])
		var env: float = exp(-lu * 3.4) * minf(1.0, lu * 20.0)
		var val: float = (sin(TAU * f * lt) * 0.72 + sin(TAU * f * 2.0 * lt) * 0.28) * env * amp
		var s16: int = int(clampf(val, -0.95, 0.95) * 32767.0)
		pcm[i * 2] = s16 & 0xFF
		pcm[i * 2 + 1] = (s16 >> 8) & 0xFF
	return _pack_wav(pcm)


func _pack_wav(pcm: PackedByteArray) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = pcm
	return wav
