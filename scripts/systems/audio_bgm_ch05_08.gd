class_name AudioBgmCh0508
extends RefCounted
## Bộ Tổng Hợp 4 Bản Nhạc Nền Địa Vực Chương 05–08 (Procedural AudioStreamWAV — Ngũ Cung & Tiên Hiệp):
##   - bgm_hac_giac  : Hắc Giác Vực / Hắc Ấn Thành / Ma Viêm Cốc (Đàn Tam Thập Lục trầm + Trống giang hồ)
##   - bgm_gia_nam   : Học Viện Già Nam / Nội Viện Bàn Môn (Cổ Tranh G Trưởng + Sáo Ngọc + Chuông Thanh)
##   - bgm_poison    : Xuất Vân Độc Chướng / Lạc Thần Giản (Sáo Phrygian ma mị + Giọt độc kim loại + Sương mù)
##   - bgm_zhongzhou : Trung Châu Phong Vân / Thánh Đan Thành / Ngân Hà Tinh Vực (Chuông Tinh Hà + Đàn Tranh + Trống Đại Điện)


static func build_tracks(sample_rate: int) -> Dictionary:
	return {
		"bgm_hac_giac": synth_hac_giac_loop(sample_rate),
		"bgm_gia_nam": synth_gia_nam_loop(sample_rate),
		"bgm_poison": synth_poison_loop(sample_rate),
		"bgm_zhongzhou": synth_zhongzhou_loop(sample_rate)
	}


static func synth_hac_giac_loop(sample_rate: int) -> AudioStreamWAV:
	# Hắc Giác Vực: Thang âm C Thứ Ngũ Cung pha nốt trầm u tối (C, Eb, F, Gb, G, Bb)
	var notes: Array[float] = [
		261.63, 311.13, 349.23, 369.99, 392.00, 349.23, 311.13, 233.08,
		261.63, 392.00, 466.16, 392.00, 369.99, 349.23, 311.13, 261.63
	]
	var drum_pat: Array[int] = [1, 0, 2, 1, 0, 2, 1, 2, 1, 0, 2, 0, 1, 2, 2, 1]
	var step_samples: int = int(0.36 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = notes.size() * step_samples
	var total_pairs: int = notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var env_mul: float = exp(-5.2 * dt)
	var h2_mul: float = exp(-7.2 * dt)
	var h3_mul: float = exp(-11.0 * dt)
	var twang_mul: float = exp(-36.0 * dt)
	var dum_mul: float = exp(-14.0 * dt)
	var rim_mul: float = exp(-34.0 * dt)
	var atk_inc: float = dt / 0.007
	var dum_min: float = TAU * 48.0 * dt
	var dum_dec: float = TAU * 56.0 * 11.0 * dt * dt

	var drone_cycles: float = maxf(2.0, roundf(65.41 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0

	var rng: int = 515253545
	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(notes.size()):
		var base_dph: float = TAU * notes[idx] * dt
		var ph: float = 0.0
		var env: float = 1.0
		var h2: float = 1.0
		var h3: float = 1.0
		var twang: float = 1.0
		var atk: float = 0.0

		var dp: int = drum_pat[idx]
		var d_env: float = 1.0
		var d_ph: float = 0.0
		var d_dph: float = TAU * (108.0 if dp == 1 else 310.0) * dt

		for _s in range(step_pairs):
			if atk < 1.0:
				atk = minf(1.0, atk + atk_inc)
			var s1: float = sin(ph)
			var pluck: float = (
				s1 * 0.52
				+ sin(ph + ph) * 0.28 * h2
				+ (s1 * (3.0 - 4.0 * s1 * s1)) * 0.16 * h3
			) * env * atk
			var grit: float = pluck / (1.0 + 0.45 * absf(pluck))
			ph += base_dph * (1.0 + 0.018 * twang)
			env *= env_mul
			h2 *= h2_mul
			h3 *= h3_mul
			twang *= twang_mul

			var drone: float = sin(drone_ph) * 0.18 + sin(drone5_ph) * 0.09
			drone_ph += d_drone
			drone5_ph += d_drone5

			rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF
			var nz: float = float(rng) * (2.0 / 2147483647.0) - 1.0

			var drum: float = 0.0
			if dp == 1:
				drum = sin(d_ph) * d_env * 0.36
				d_ph += d_dph
				if d_dph > dum_min:
					d_dph = maxf(dum_min, d_dph - dum_dec)
				d_env *= dum_mul
			elif dp == 2:
				drum = (sin(d_ph) * 0.48 + nz * 0.52) * d_env * 0.20
				d_ph += d_dph
				d_env *= rim_mul

			var cur_f: float = clampf((grit * 0.44 + drone + drum) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func synth_gia_nam_loop(sample_rate: int) -> AudioStreamWAV:
	# Học Viện Già Nam: Ngũ cung G Trưởng thanh cao, sáng sủa (G, A, B, D, E) + Cổ Tranh + Sáo Ngọc + Chuông Đá
	var guzheng_notes: Array[float] = [
		392.00, 440.00, 493.88, 587.33, 659.25, 587.33, 493.88, 440.00,
		392.00, 587.33, 659.25, 783.99, 659.25, 587.33, 493.88, 392.00
	]
	var flute_notes: Array[float] = [
		783.99, 0.0, 987.77, 0.0, 1174.66, 0.0, 987.77, 880.00,
		783.99, 0.0, 1174.66, 0.0, 1318.51, 0.0, 1174.66, 987.77
	]
	var step_samples: int = int(0.44 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = guzheng_notes.size() * step_samples
	var total_pairs: int = guzheng_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var gz_mul: float = exp(-3.5 * dt)
	var gz_h2_mul: float = exp(-5.2 * dt)
	var fl_mul: float = exp(-1.8 * dt)
	var chime_mul: float = exp(-2.9 * dt)
	var gz_atk_inc: float = dt / 0.010
	var fl_atk_inc: float = dt / 0.048

	var drone_cycles: float = maxf(2.0, roundf(98.00 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var d_vib: float = TAU * 5.0 * dt
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0
	var vib_ph: float = 0.0

	var fl_ph: float = 0.0
	var fl_dph: float = 0.0
	var fl_env: float = 0.0
	var fl_atk: float = 0.0
	var ch_ph: float = 0.0
	var ch_dph: float = 0.0
	var ch_env: float = 0.0

	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(guzheng_notes.size()):
		var g_dph: float = TAU * guzheng_notes[idx] * dt
		var g_ph: float = 0.0
		var g_env: float = 1.0
		var g_h2: float = 1.0
		var g_atk: float = 0.0

		if flute_notes[idx] > 0.0:
			fl_dph = TAU * flute_notes[idx] * dt
			fl_ph = 0.0
			fl_env = 1.0
			fl_atk = 0.0

		if (idx % 4) == 0:
			ch_dph = TAU * (guzheng_notes[idx] * 2.0) * dt
			ch_ph = 0.0
			ch_env = 1.0

		for _s in range(step_pairs):
			if g_atk < 1.0:
				g_atk = minf(1.0, g_atk + gz_atk_inc)
			var gs1: float = sin(g_ph)
			var guzheng: float = (gs1 * 0.62 + sin(g_ph + g_ph) * 0.24 * g_h2 + sin(g_ph * 3.0) * 0.08 * g_h2) * g_env * g_atk
			g_ph += g_dph
			g_env *= gz_mul
			g_h2 *= gz_h2_mul

			var flute: float = 0.0
			if fl_env > 0.002:
				if fl_atk < 1.0:
					fl_atk = minf(1.0, fl_atk + fl_atk_inc)
				vib_ph += d_vib
				flute = (sin(fl_ph) * 0.72 + sin(fl_ph + fl_ph) * 0.18) * fl_env * fl_atk * 0.24
				fl_ph += fl_dph * (1.0 + 0.0048 * sin(vib_ph) * fl_atk)
				fl_env *= fl_mul

			var chime: float = 0.0
			if ch_env > 0.002:
				chime = (sin(ch_ph) * 0.65 + sin(ch_ph * 2.41) * 0.25) * ch_env * 0.13
				ch_ph += ch_dph
				ch_env *= chime_mul

			var drone: float = sin(drone_ph) * 0.13 + sin(drone5_ph) * 0.06
			drone_ph += d_drone
			drone5_ph += d_drone5

			var cur_f: float = clampf((guzheng * 0.36 + flute + chime + drone) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func synth_poison_loop(sample_rate: int) -> AudioStreamWAV:
	# Xuất Vân Độc Chướng & Lạc Thần Giản: Thang âm E Phrygian ma mị (E, F, G, A, B, C, D) + Giọt Độc + Sương Mù
	var eerie_notes: Array[float] = [
		329.63, 349.23, 415.30, 349.23, 329.63, 293.66, 329.63, 246.94,
		329.63, 493.88, 523.25, 493.88, 415.30, 349.23, 329.63, 311.13
	]
	var drop_notes: Array[float] = [
		987.77, 0.0, 0.0, 1046.50, 0.0, 830.61, 0.0, 0.0,
		1318.51, 0.0, 1046.50, 0.0, 0.0, 987.77, 0.0, 698.46
	]
	var pulse_pat: Array[int] = [1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0]
	var step_samples: int = int(0.45 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = eerie_notes.size() * step_samples
	var total_pairs: int = eerie_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var lead_mul: float = exp(-2.2 * dt)
	var drop_mul: float = exp(-6.8 * dt)
	var pulse_mul: float = exp(-10.0 * dt)
	var atk_inc: float = dt / 0.040

	var sub_cycles: float = maxf(2.0, roundf(82.41 * total_sec * 0.5) * 2.0)
	var d_sub: float = TAU * sub_cycles / float(total_pairs)
	var d_lfo: float = TAU * 2.0 / float(total_pairs)
	var d_vib: float = TAU * 6.4 * dt
	var sub_ph: float = 0.0
	var lfo_ph: float = 0.0
	var vib_ph: float = 0.0

	var dr_ph: float = 0.0
	var dr_dph: float = 0.0
	var dr_env: float = 0.0

	var rng: int = 77119933
	var mist_lp: float = 0.0
	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(eerie_notes.size()):
		var l_dph: float = TAU * eerie_notes[idx] * dt
		var l_ph: float = 0.0
		var l_env: float = 1.0
		var l_atk: float = 0.0

		if drop_notes[idx] > 0.0:
			dr_dph = TAU * drop_notes[idx] * dt
			dr_ph = 0.0
			dr_env = 1.0

		var do_pulse: bool = pulse_pat[idx] == 1
		var p_ph: float = 0.0
		var p_dph: float = TAU * 82.41 * dt
		var p_env: float = 1.0

		for _s in range(step_pairs):
			if l_atk < 1.0:
				l_atk = minf(1.0, l_atk + atk_inc)
			vib_ph += d_vib
			var lead: float = (sin(l_ph) * 0.64 + sin(l_ph * 2.0) * 0.22 + sin(l_ph * 3.0) * 0.10) * l_env * l_atk
			l_ph += l_dph * (1.0 + 0.0085 * sin(vib_ph) * l_atk)
			l_env *= lead_mul

			var drop: float = 0.0
			if dr_env > 0.002:
				drop = (sin(dr_ph) * 0.58 + sin(dr_ph * 2.71) * 0.34) * dr_env * 0.20
				dr_ph += dr_dph * (1.0 + 0.06 * dr_env)
				dr_env *= drop_mul

			rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF
			var nz: float = float(rng) * (2.0 / 2147483647.0) - 1.0
			mist_lp += 0.065 * (nz - mist_lp)
			var lfo: float = 0.60 + 0.40 * sin(lfo_ph)
			lfo_ph += d_lfo
			var mist: float = sin(sub_ph) * 0.16 + sin(sub_ph * 1.414) * 0.045 * lfo + mist_lp * 0.19 * lfo
			sub_ph += d_sub

			var pulse: float = 0.0
			if do_pulse:
				pulse = sin(p_ph) * p_env * 0.26
				p_ph += p_dph
				p_env *= pulse_mul

			var cur_f: float = clampf((lead * 0.34 + drop + mist + pulse) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func synth_zhongzhou_loop(sample_rate: int) -> AudioStreamWAV:
	# Trung Châu Phong Vân & Ngân Hà Tinh Vực: Thang âm A Dorian hùng vĩ (A, B, C, D, E, F#, G) + Chuông Tinh Hà + Cổ Tranh + Trống Đại Điện
	var lead_notes: Array[float] = [
		440.00, 523.25, 587.33, 659.25, 739.99, 659.25, 587.33, 523.25,
		440.00, 659.25, 739.99, 880.00, 783.99, 659.25, 587.33, 493.88
	]
	var bass_roots: Array[float] = [
		110.00, 110.00, 110.00, 110.00, 87.31, 87.31, 98.00, 98.00,
		110.00, 110.00, 130.81, 130.81, 146.83, 146.83, 123.47, 110.00
	]
	var bell_hits: Array[float] = [
		880.00, 0.0, 0.0, 0.0, 1174.66, 0.0, 0.0, 0.0,
		1318.51, 0.0, 0.0, 0.0, 1479.98, 0.0, 987.77, 0.0
	]
	var taiko_pat: Array[int] = [1, 0, 2, 0, 1, 0, 2, 2, 1, 0, 2, 0, 1, 2, 1, 0]
	var step_samples: int = int(0.43 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = lead_notes.size() * step_samples
	var total_pairs: int = lead_notes.size() * step_pairs
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var lead_mul: float = exp(-3.1 * dt)
	var h2_mul: float = exp(-5.0 * dt)
	var bell_mul: float = exp(-1.9 * dt)
	var tk1_mul: float = exp(-11.5 * dt)
	var tk2_mul: float = exp(-20.0 * dt)
	var atk_inc: float = dt / 0.012
	var tk_min: float = TAU * 46.0 * dt
	var tk_dec: float = TAU * 50.0 * 9.0 * dt * dt

	var d_swell: float = TAU / float(total_pairs)
	var swell_ph: float = -PI * 0.5
	var pad_ph: float = 0.0

	var b_ph: float = 0.0
	var b_dph: float = 0.0
	var b_env: float = 0.0

	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(lead_notes.size()):
		var l_dph: float = TAU * lead_notes[idx] * dt
		var l_ph: float = 0.0
		var l_env: float = 1.0
		var l_h2: float = 1.0
		var l_atk: float = 0.0

		var p_dph: float = TAU * bass_roots[idx] * dt

		if bell_hits[idx] > 0.0:
			b_dph = TAU * bell_hits[idx] * dt
			b_ph = 0.0
			b_env = 1.0

		var tp: int = taiko_pat[idx]
		var t_ph: float = 0.0
		var t_dph: float = TAU * (96.0 if tp == 1 else 154.0) * dt
		var t_env: float = 1.0

		for _s in range(step_pairs):
			if l_atk < 1.0:
				l_atk = minf(1.0, l_atk + atk_inc)
			var ls1: float = sin(l_ph)
			var guzheng: float = (
				ls1 * 0.58
				+ sin(l_ph + l_ph) * 0.26 * l_h2
				+ sin(l_ph * 3.0) * 0.10 * l_h2
			) * l_env * l_atk
			l_ph += l_dph
			l_env *= lead_mul
			l_h2 *= h2_mul

			var swell: float = 0.65 + 0.35 * sin(swell_ph)
			swell_ph += d_swell
			var astral_pad: float = (
				sin(pad_ph) * 0.52
				+ sin(pad_ph * 1.5) * 0.24
				+ sin(pad_ph * 2.0) * 0.18
				+ sin(pad_ph * 4.0) * 0.06
			) * 0.24 * swell
			pad_ph += p_dph

			var bell: float = 0.0
			if b_env > 0.002:
				bell = (sin(b_ph) * 0.62 + sin(b_ph * 2.0) * 0.22 + sin(b_ph * 3.01) * 0.16) * b_env * 0.17
				b_ph += b_dph
				b_env *= bell_mul

			var taiko: float = 0.0
			if tp == 1:
				taiko = sin(t_ph) * t_env * 0.32
				t_ph += t_dph
				if t_dph > tk_min:
					t_dph = maxf(tk_min, t_dph - tk_dec)
				t_env *= tk1_mul
			elif tp == 2:
				taiko = sin(t_ph) * t_env * 0.18
				t_ph += t_dph
				t_env *= tk2_mul

			var cur_f: float = clampf((guzheng * 0.34 + astral_pad + bell + taiko) * 0.90, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func _pack_loop_wav(pcm: PackedByteArray, total_samples: int, sample_rate: int) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = total_samples
	wav.data = pcm
	return wav
