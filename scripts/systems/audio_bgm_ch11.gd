class_name AudioBgmCh11
extends RefCounted
## Bộ Tổng Hợp 4 Bản Nhạc Nền Địa Vực Chương 11 — Đại Kết Cục Viêm Đế (Procedural AudioStreamWAV — v1.0.0):
##   - bgm_co_de_dong_phu    : Đà Xá Cổ Đế Động Phủ & Quảng Trường 22 Cột Lửa (Cổ Tranh + Chuông Đế Vương D Trưởng Trang Nghiêm)
##   - bgm_song_de_chi_chien : Song Đế Phá Thương Khung — Final Boss Hồn Thiên Đế & Superboss (E Thứ 152 BPM Dồn Dập + Đế Trống + Hợp Xướng)
##   - bgm_o_than_dai_hon    : Ô Thản Thiếu Niên Mộng — Đại Hôn Ô Thản Thành & Ending Credits (Ngũ Cung G Trưởng Ấm Áp Hoài Niệm)
##   - bgm_dai_thien_the_gioi: Thương Khung Vị Diện Đại Thiên Thế Giới (Tinh Không F# Ngũ Cung Mênh Mông + Chuông Sao + Sáo Trời)


static func build_tracks(sample_rate: int) -> Dictionary:
	return {
		"bgm_co_de_dong_phu": synth_co_de_loop(sample_rate),
		"bgm_song_de_chi_chien": synth_song_de_loop(sample_rate),
		"bgm_o_than_dai_hon": synth_dai_hon_loop(sample_rate),
		"bgm_dai_thien_the_gioi": synth_dai_thien_loop(sample_rate)
	}


static func synth_co_de_loop(sample_rate: int) -> AudioStreamWAV:
	# Đà Xá Cổ Đế Động Phủ: Ngũ cung D Trưởng cổ kính uy nghiêm (D, E, F#, A, B) + Chuông Đồng Cổ + Drone trầm
	var lead: Array[float] = [
		293.66, 329.63, 369.99, 440.00, 493.88, 587.33, 493.88, 440.00,
		587.33, 659.25, 739.99, 587.33, 493.88, 440.00, 369.99, 293.66
	]
	var bell: Array[float] = [
		587.33, 0.0, 0.0, 0.0, 440.00, 0.0, 0.0, 0.0,
		739.99, 0.0, 0.0, 0.0, 587.33, 0.0, 0.0, 0.0
	]
	return _render_imperial_track(sample_rate, lead, bell, 0.44, 73.42, 0.0, false)


static func synth_song_de_loop(sample_rate: int) -> AudioStreamWAV:
	# Song Đế Phá Thương Khung (Final Boss 3-Phase & Superboss): E Thứ Sử Thi tốc độ cao + Đế Trống + Kèn Chiến!
	var lead: Array[float] = [
		659.25, 739.99, 783.99, 987.77, 880.00, 783.99, 739.99, 659.25,
		987.77, 1174.66, 1318.51, 1174.66, 987.77, 880.00, 783.99, 659.25
	]
	var brass: Array[float] = [
		329.63, 0.0, 392.00, 0.0, 493.88, 0.0, 440.00, 0.0,
		493.88, 0.0, 587.33, 0.0, 659.25, 0.0, 493.88, 329.63
	]
	return _render_imperial_track(sample_rate, lead, brass, 0.24, 82.41, 1.0, true)


static func synth_dai_hon_loop(sample_rate: int) -> AudioStreamWAV:
	# Ô Thản Thiếu Niên Mộng (Đại Hôn & True Ending Credits): G Trưởng Ngũ Cung ấm áp da diết (G, A, B, D, E)
	var lead: Array[float] = [
		392.00, 440.00, 493.88, 587.33, 659.25, 783.99, 659.25, 587.33,
		493.88, 587.33, 659.25, 493.88, 440.00, 493.88, 392.00, 392.00
	]
	var flute: Array[float] = [
		783.99, 0.0, 880.00, 0.0, 987.77, 0.0, 880.00, 783.99,
		659.25, 0.0, 783.99, 0.0, 659.25, 0.0, 587.33, 783.99
	]
	return _render_imperial_track(sample_rate, lead, flute, 0.50, 98.00, 0.0, false)


static func synth_dai_thien_loop(sample_rate: int) -> AudioStreamWAV:
	# Thương Khung Đại Thiên Thế Giới: Tinh Không A Trưởng Ngũ Cung thanh thoát mênh mông
	var lead: Array[float] = [
		440.00, 493.88, 554.37, 659.25, 739.99, 880.00, 739.99, 659.25,
		880.00, 987.77, 1108.73, 880.00, 739.99, 659.25, 554.37, 440.00
	]
	var chime: Array[float] = [
		880.00, 0.0, 1108.73, 0.0, 1318.51, 0.0, 1108.73, 0.0,
		880.00, 0.0, 1318.51, 0.0, 987.77, 0.0, 880.00, 0.0
	]
	return _render_imperial_track(sample_rate, lead, chime, 0.42, 110.00, 0.35, false)


static func _render_imperial_track(
	sample_rate: int,
	lead_notes: Array[float],
	acc_notes: Array[float],
	step_sec: float,
	drone_hz: float,
	drum_strength: float,
	heroic_choir: bool
) -> AudioStreamWAV:
	var step_samples: int = int(step_sec * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = lead_notes.size() * step_samples
	var total_pairs: int = lead_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var lead_mul: float = exp((-3.8 if heroic_choir else -2.6) * dt)
	var acc_mul: float = exp((-2.0 if heroic_choir else -1.6) * dt)
	var drum_mul: float = exp(-12.0 * dt)
	var atk_inc: float = dt / 0.012
	var acc_atk_inc: float = dt / 0.045

	var drone_cycles: float = maxf(2.0, roundf(drone_hz * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var d_vib: float = TAU * 5.2 * dt
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0
	var vib_ph: float = 0.0

	var acc_ph: float = 0.0
	var acc_dph: float = 0.0
	var acc_env: float = 0.0
	var acc_atk: float = 0.0
	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(lead_notes.size()):
		var l_dph: float = TAU * lead_notes[idx] * dt
		var l_ph: float = 0.0
		var l_env: float = 1.0
		var l_atk: float = 0.0

		if idx < acc_notes.size() and acc_notes[idx] > 0.0:
			acc_dph = TAU * acc_notes[idx] * dt
			acc_ph = 0.0
			acc_env = 1.0
			acc_atk = 0.0

		var d_env: float = drum_strength if ((idx % 2) == 0 or heroic_choir) else 0.0
		var d_ph: float = 0.0
		var d_freq: float = 128.0 if (idx % 4) == 0 else 92.0

		for _s in range(step_pairs):
			if l_atk < 1.0:
				l_atk = minf(1.0, l_atk + atk_inc)
			var lead_s: float = (sin(l_ph) * 0.62 + sin(l_ph * 2.0) * 0.24 + sin(l_ph * 3.0) * (0.14 if heroic_choir else 0.06)) * l_env * l_atk
			l_ph += l_dph
			l_env *= lead_mul

			var acc_s: float = 0.0
			if acc_env > 0.002:
				if acc_atk < 1.0:
					acc_atk = minf(1.0, acc_atk + acc_atk_inc)
				vib_ph += d_vib
				var mod_f: float = 1.0 + 0.004 * sin(vib_ph) * acc_atk
				if heroic_choir:
					acc_s = (sin(acc_ph) * 0.55 + sin(acc_ph * 2.0) * 0.28 + sin(acc_ph * 1.5) * 0.16) * acc_env * acc_atk * 0.28
				else:
					acc_s = (sin(acc_ph) * 0.72 + sin(acc_ph * 2.0) * 0.16 + sin(acc_ph * 2.76) * 0.08) * acc_env * acc_atk * 0.22
				acc_ph += acc_dph * mod_f
				acc_env *= acc_mul

			var drum_s: float = 0.0
			if d_env > 0.003:
				drum_s = sin(d_ph) * d_env * 0.30
				d_ph += TAU * (d_freq * (0.45 + 0.55 * d_env)) * dt
				d_env *= drum_mul

			var drone_s: float = sin(drone_ph) * 0.15 + sin(drone5_ph) * 0.08
			drone_ph += d_drone
			drone5_ph += d_drone5

			var cur_f: float = clampf((lead_s * 0.34 + acc_s + drum_s + drone_s) * 0.90, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = pcm
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	return wav
