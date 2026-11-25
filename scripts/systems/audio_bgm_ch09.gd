class_name AudioBgmCh09
extends RefCounted
## Bộ Tổng Hợp 3 Bản Nhạc Nền Địa Vực Chương 09 (Procedural AudioStreamWAV — Ngũ Cung & Tiên Hiệp):
##   - bgm_tinh_van : Tinh Vẫn Các & Hoa Tông Thánh Địa (Cổ Tranh D Trưởng + Sáo Trúc bay bổng + Chuông Tinh Thần)
##   - bgm_vong_hon : Vong Hồn Sơn Mạch & Di Tích Tạo Hóa (D Thứ Ám Hồn + Tỏa Hồn Xiềng Xích + Trống U Minh)
##   - bgm_thien_mo : Cổ Giới Thành Nhân Lễ & Thiên Mộ Tam Tầng (Biên Chung Cổ Đế + Cổ Tranh C Thứ Hùng Tráng + Trống Thánh Uy)


static func build_tracks(sample_rate: int) -> Dictionary:
	return {
		"bgm_tinh_van": synth_tinh_van_loop(sample_rate),
		"bgm_vong_hon": synth_vong_hon_loop(sample_rate),
		"bgm_thien_mo": synth_thien_mo_loop(sample_rate)
	}


static func synth_tinh_van_loop(sample_rate: int) -> AudioStreamWAV:
	# Tinh Vẫn Các & Hoa Tông: Ngũ cung D Trưởng thanh thoát tiên cảnh (D, E, F#, A, B) + Sáo Trúc + Chuông Sao
	var guzheng_notes: Array[float] = [
		587.33, 659.25, 739.99, 880.00, 987.77, 880.00, 739.99, 659.25,
		587.33, 739.99, 880.00, 1174.66, 987.77, 880.00, 739.99, 587.33
	]
	var flute_notes: Array[float] = [
		1174.66, 0.0, 1318.51, 0.0, 1479.98, 0.0, 1318.51, 1174.66,
		987.77, 0.0, 1174.66, 0.0, 1479.98, 0.0, 1318.51, 1174.66
	]
	var step_samples: int = int(0.46 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = guzheng_notes.size() * step_samples
	var total_pairs: int = guzheng_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var gz_mul: float = exp(-3.2 * dt)
	var gz_h2_mul: float = exp(-5.0 * dt)
	var fl_mul: float = exp(-1.6 * dt)
	var chime_mul: float = exp(-2.4 * dt)
	var gz_atk_inc: float = dt / 0.011
	var fl_atk_inc: float = dt / 0.055

	var drone_cycles: float = maxf(2.0, roundf(146.83 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var d_vib: float = TAU * 5.2 * dt
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
			var guzheng: float = (gs1 * 0.60 + sin(g_ph * 2.0) * 0.25 * g_h2 + sin(g_ph * 3.0) * 0.09 * g_h2) * g_env * g_atk
			g_ph += g_dph
			g_env *= gz_mul
			g_h2 *= gz_h2_mul

			var flute: float = 0.0
			if fl_env > 0.002:
				if fl_atk < 1.0:
					fl_atk = minf(1.0, fl_atk + fl_atk_inc)
				vib_ph += d_vib
				flute = (sin(fl_ph) * 0.74 + sin(fl_ph * 2.0) * 0.16) * fl_env * fl_atk * 0.22
				fl_ph += fl_dph * (1.0 + 0.0044 * sin(vib_ph) * fl_atk)
				fl_env *= fl_mul

			var chime: float = 0.0
			if ch_env > 0.002:
				chime = (sin(ch_ph) * 0.60 + sin(ch_ph * 2.52) * 0.26) * ch_env * 0.14
				ch_ph += ch_dph
				ch_env *= chime_mul

			var drone: float = sin(drone_ph) * 0.13 + sin(drone5_ph) * 0.065
			drone_ph += d_drone
			drone5_ph += d_drone5

			var cur_f: float = clampf((guzheng * 0.35 + flute + chime + drone) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func synth_vong_hon_loop(sample_rate: int) -> AudioStreamWAV:
	# Vong Hồn Sơn Mạch & Di Tích Tạo Hóa: Thang âm D Thứ Phrygian u minh + Tiếng xích sắt kim loại + Trống U Hồn
	var lead_notes: Array[float] = [
		293.66, 311.13, 349.23, 440.00, 466.16, 440.00, 349.23, 311.13,
		293.66, 440.00, 523.25, 466.16, 440.00, 349.23, 311.13, 293.66
	]
	var chain_pat: Array[int] = [0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1]
	var drum_pat: Array[int] = [1, 0, 0, 2, 1, 0, 2, 0, 1, 0, 0, 2, 1, 2, 0, 2]
	var step_samples: int = int(0.40 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = lead_notes.size() * step_samples
	var total_pairs: int = lead_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var lead_mul: float = exp(-3.4 * dt)
	var chain_mul: float = exp(-12.0 * dt)
	var dum_mul: float = exp(-11.0 * dt)
	var rim_mul: float = exp(-26.0 * dt)
	var atk_inc: float = dt / 0.016
	var dum_min: float = TAU * 42.0 * dt
	var dum_dec: float = TAU * 52.0 * 9.5 * dt * dt

	var sub_cycles: float = maxf(2.0, roundf(73.42 * total_sec * 0.5) * 2.0)
	var d_sub: float = TAU * sub_cycles / float(total_pairs)
	var d_vib: float = TAU * 5.8 * dt
	var sub_ph: float = 0.0
	var vib_ph: float = 0.0
	var rng: int = 90919293
	var wind_lp: float = 0.0
	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(lead_notes.size()):
		var l_dph: float = TAU * lead_notes[idx] * dt
		var l_ph: float = 0.0
		var l_env: float = 1.0
		var l_atk: float = 0.0

		var do_chain: bool = chain_pat[idx] == 1
		var c_ph: float = 0.0
		var c_env: float = 1.0
		var c_dph: float = TAU * 1380.0 * dt

		var dp: int = drum_pat[idx]
		var d_ph: float = 0.0
		var d_env: float = 1.0
		var d_dph: float = TAU * (94.0 if dp == 1 else 260.0) * dt

		for _s in range(step_pairs):
			if l_atk < 1.0:
				l_atk = minf(1.0, l_atk + atk_inc)
			vib_ph += d_vib
			var lead: float = (sin(l_ph) * 0.62 + sin(l_ph * 2.0) * 0.24 + sin(l_ph * 3.0) * 0.10) * l_env * l_atk
			l_ph += l_dph * (1.0 + 0.007 * sin(vib_ph) * l_atk)
			l_env *= lead_mul

			rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF
			var nz: float = float(rng) * (2.0 / 2147483647.0) - 1.0
			wind_lp += 0.05 * (nz - wind_lp)

			var chain: float = 0.0
			if do_chain and c_env > 0.002:
				chain = (sin(c_ph) * 0.45 + sin(c_ph * 2.73) * 0.35 + nz * 0.20) * c_env * 0.14
				c_ph += c_dph
				c_env *= chain_mul

			var drum: float = 0.0
			if dp == 1:
				drum = sin(d_ph) * d_env * 0.36
				d_ph += d_dph
				if d_dph > dum_min:
					d_dph = maxf(dum_min, d_dph - dum_dec)
				d_env *= dum_mul
			elif dp == 2:
				drum = (sin(d_ph) * 0.55 + nz * 0.45) * d_env * 0.18
				d_ph += d_dph
				d_env *= rim_mul

			var drone: float = sin(sub_ph) * 0.19 + sin(sub_ph * 1.498) * 0.08 + wind_lp * 0.15
			sub_ph += d_sub

			var cur_f: float = clampf((lead * 0.35 + chain + drum + drone) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func synth_thien_mo_loop(sample_rate: int) -> AudioStreamWAV:
	# Cổ Giới & Thiên Mộ Tam Tầng: Thang âm C Thứ Hào Hùng (C, D, Eb, F, G, Ab, Bb) + Biên Chung Cổ Đế + Dàn Dây + Trống Chiến
	var lead_notes: Array[float] = [
		523.25, 587.33, 622.25, 783.99, 830.61, 783.99, 622.25, 587.33,
		523.25, 783.99, 932.33, 1046.50, 932.33, 783.99, 622.25, 523.25
	]
	var bass_roots: Array[float] = [
		130.81, 130.81, 130.81, 130.81, 103.83, 103.83, 116.54, 116.54,
		130.81, 130.81, 155.56, 155.56, 174.61, 174.61, 146.83, 130.81
	]
	var bell_hits: Array[float] = [
		1046.50, 0.0, 0.0, 0.0, 830.61, 0.0, 0.0, 0.0,
		1567.98, 0.0, 0.0, 0.0, 1174.66, 0.0, 1046.50, 0.0
	]
	var taiko_pat: Array[int] = [1, 0, 2, 1, 0, 2, 1, 2, 1, 0, 2, 1, 1, 2, 1, 0]
	var step_samples: int = int(0.42 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = lead_notes.size() * step_samples
	var total_pairs: int = lead_notes.size() * step_pairs
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var lead_mul: float = exp(-2.8 * dt)
	var h2_mul: float = exp(-4.8 * dt)
	var bell_mul: float = exp(-1.7 * dt)
	var tk1_mul: float = exp(-10.5 * dt)
	var tk2_mul: float = exp(-19.0 * dt)
	var atk_inc: float = dt / 0.011
	var tk_min: float = TAU * 44.0 * dt
	var tk_dec: float = TAU * 54.0 * 9.0 * dt * dt

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
		var t_dph: float = TAU * (92.0 if tp == 1 else 160.0) * dt
		var t_env: float = 1.0

		for _s in range(step_pairs):
			if l_atk < 1.0:
				l_atk = minf(1.0, l_atk + atk_inc)
			var ls1: float = sin(l_ph)
			var lead: float = (ls1 * 0.56 + sin(l_ph * 2.0) * 0.28 * l_h2 + sin(l_ph * 3.0) * 0.12 * l_h2) * l_env * l_atk
			l_ph += l_dph
			l_env *= lead_mul
			l_h2 *= h2_mul

			var swell: float = 0.62 + 0.38 * sin(swell_ph)
			swell_ph += d_swell
			var pad: float = (sin(pad_ph) * 0.50 + sin(pad_ph * 1.5) * 0.25 + sin(pad_ph * 2.0) * 0.18 + sin(pad_ph * 3.0) * 0.07) * 0.25 * swell
			pad_ph += p_dph

			var bell: float = 0.0
			if b_env > 0.002:
				bell = (sin(b_ph) * 0.58 + sin(b_ph * 2.0) * 0.24 + sin(b_ph * 3.02) * 0.18) * b_env * 0.18
				b_ph += b_dph
				b_env *= bell_mul

			var taiko: float = 0.0
			if tp == 1:
				taiko = sin(t_ph) * t_env * 0.34
				t_ph += t_dph
				if t_dph > tk_min:
					t_dph = maxf(tk_min, t_dph - tk_dec)
				t_env *= tk1_mul
			elif tp == 2:
				taiko = sin(t_ph) * t_env * 0.18
				t_ph += t_dph
				t_env *= tk2_mul

			var cur_f: float = clampf((lead * 0.34 + pad + bell + taiko) * 0.90, -0.95, 0.95)
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
