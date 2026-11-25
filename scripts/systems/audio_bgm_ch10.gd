class_name AudioBgmCh10
extends RefCounted
## Bộ Tổng Hợp 4 Bản Nhạc Nền Địa Vực Chương 10 (Procedural AudioStreamWAV — Quyển IV Thánh Đế Quyết Chiến):
##   - bgm_bo_de     : Mãng Hoang Cổ Vực & Bồn Địa Bồ Đề Cổ Thụ (Cổ Tranh G Trưởng Thiền Vị + Chuông Ngọc Bồ Đề + Sáo Sâu Lắng)
##   - bgm_thien_phu : Chiến Trường Viêm Minh & Tổng Đàn Thiên Phủ Liên Minh (Hùng Tráng Ngũ Cung C Trưởng + Kèn Đồng + Trống Chiến Trận)
##   - bgm_nhan_dien : Pháo Đài Nhân Điện — Công Thành Hồn Điện (D Thứ Phrygian Dồn Dập + Trống Công Thành + Tiếng Xích Kim Loại)
##   - bgm_yeu_hoa   : Yêu Hỏa Không Gian & Đài Sen Tịnh Liên (Song Tấu Sáo Trúc & Tỳ Bà A Thứ Lãng Mạn Yêu Dị + Hỏa Liên Ngân Vang)


static func build_tracks(sample_rate: int) -> Dictionary:
	return {
		"bgm_bo_de": synth_bo_de_loop(sample_rate),
		"bgm_thien_phu": synth_thien_phu_loop(sample_rate),
		"bgm_nhan_dien": synth_nhan_dien_loop(sample_rate),
		"bgm_yeu_hoa": synth_yeu_hoa_loop(sample_rate)
	}


static func synth_bo_de_loop(sample_rate: int) -> AudioStreamWAV:
	# Bồ Đề Cổ Thụ & Bách Thế Tỉnh Mộng: Ngũ cung G Trưởng thanh tịnh (G, A, B, D, E) + Chuông Thiền + Sáo Sâu
	var guzheng_notes: Array[float] = [
		392.00, 440.00, 493.88, 587.33, 659.25, 587.33, 493.88, 440.00,
		392.00, 493.88, 587.33, 783.99, 659.25, 587.33, 493.88, 392.00
	]
	var flute_notes: Array[float] = [
		783.99, 0.0, 880.00, 0.0, 987.77, 0.0, 880.00, 783.99,
		659.25, 0.0, 783.99, 0.0, 987.77, 0.0, 880.00, 783.99
	]
	var step_samples: int = int(0.50 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = guzheng_notes.size() * step_samples
	var total_pairs: int = guzheng_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var gz_mul: float = exp(-2.9 * dt)
	var gz_h2_mul: float = exp(-4.8 * dt)
	var fl_mul: float = exp(-1.5 * dt)
	var bell_mul: float = exp(-1.8 * dt)
	var gz_atk_inc: float = dt / 0.012
	var fl_atk_inc: float = dt / 0.065

	var drone_cycles: float = maxf(2.0, roundf(98.00 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var d_vib: float = TAU * 4.8 * dt
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0
	var vib_ph: float = 0.0

	var fl_ph: float = 0.0
	var fl_dph: float = 0.0
	var fl_env: float = 0.0
	var fl_atk: float = 0.0
	var b_ph: float = 0.0
	var b_dph: float = 0.0
	var b_env: float = 0.0

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
			b_dph = TAU * (guzheng_notes[idx] * 0.5) * dt
			b_ph = 0.0
			b_env = 1.0

		for _s in range(step_pairs):
			if g_atk < 1.0:
				g_atk = minf(1.0, g_atk + gz_atk_inc)
			var guzheng: float = (sin(g_ph) * 0.62 + sin(g_ph * 2.0) * 0.24 * g_h2 + sin(g_ph * 3.0) * 0.08 * g_h2) * g_env * g_atk
			g_ph += g_dph
			g_env *= gz_mul
			g_h2 *= gz_h2_mul

			var flute: float = 0.0
			if fl_env > 0.002:
				if fl_atk < 1.0:
					fl_atk = minf(1.0, fl_atk + fl_atk_inc)
				vib_ph += d_vib
				flute = (sin(fl_ph) * 0.78 + sin(fl_ph * 2.0) * 0.14) * fl_env * fl_atk * 0.22
				fl_ph += fl_dph * (1.0 + 0.0042 * sin(vib_ph) * fl_atk)
				fl_env *= fl_mul

			var bell: float = 0.0
			if b_env > 0.002:
				bell = (sin(b_ph) * 0.55 + sin(b_ph * 2.756) * 0.26 + sin(b_ph * 4.07) * 0.10) * b_env * 0.16
				b_ph += b_dph
				b_env *= bell_mul

			var drone: float = sin(drone_ph) * 0.14 + sin(drone5_ph) * 0.07
			drone_ph += d_drone
			drone5_ph += d_drone5

			var cur_f: float = clampf((guzheng * 0.34 + flute + bell + drone) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func synth_thien_phu_loop(sample_rate: int) -> AudioStreamWAV:
	# Thiên Phủ Liên Minh & Chiến Trường Viêm Minh: Ngũ cung C Trưởng hào hùng (C, D, E, G, A) + Kèn Đồng + Trống Tông Môn
	var lead_notes: Array[float] = [
		523.25, 587.33, 659.25, 783.99, 880.00, 783.99, 659.25, 783.99,
		1046.50, 880.00, 783.99, 659.25, 587.33, 659.25, 783.99, 523.25
	]
	var brass_notes: Array[float] = [
		261.63, 0.0, 329.63, 0.0, 392.00, 0.0, 329.63, 0.0,
		440.00, 0.0, 392.00, 0.0, 293.66, 0.0, 392.00, 261.63
	]
	var step_samples: int = int(0.38 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = lead_notes.size() * step_samples
	var total_pairs: int = lead_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var lead_mul: float = exp(-3.5 * dt)
	var brass_mul: float = exp(-2.2 * dt)
	var drum_mul: float = exp(-9.5 * dt)
	var lead_atk_inc: float = dt / 0.010
	var brass_atk_inc: float = dt / 0.032

	var drone_cycles: float = maxf(2.0, roundf(130.81 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0

	var br_ph: float = 0.0
	var br_dph: float = 0.0
	var br_env: float = 0.0
	var br_atk: float = 0.0

	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(lead_notes.size()):
		var l_dph: float = TAU * lead_notes[idx] * dt
		var l_ph: float = 0.0
		var l_env: float = 1.0
		var l_atk: float = 0.0

		if brass_notes[idx] > 0.0:
			br_dph = TAU * brass_notes[idx] * dt
			br_ph = 0.0
			br_env = 1.0
			br_atk = 0.0

		var drum_hit: bool = (idx % 2) == 0
		var drum_env: float = 1.0 if drum_hit else 0.0
		var drum_ph: float = 0.0
		var drum_freq: float = 104.0 if (idx % 4) == 0 else 78.0

		for _s in range(step_pairs):
			if l_atk < 1.0:
				l_atk = minf(1.0, l_atk + lead_atk_inc)
			var lead: float = (sin(l_ph) * 0.58 + sin(l_ph * 2.0) * 0.28 + sin(l_ph * 3.0) * 0.12) * l_env * l_atk
			l_ph += l_dph
			l_env *= lead_mul

			var brass: float = 0.0
			if br_env > 0.002:
				if br_atk < 1.0:
					br_atk = minf(1.0, br_atk + brass_atk_inc)
				brass = (sin(br_ph) * 0.55 + sin(br_ph * 2.0) * 0.30 + sin(br_ph * 3.0) * 0.16) * br_env * br_atk * 0.22
				br_ph += br_dph
				br_env *= brass_mul

			var drum: float = 0.0
			if drum_env > 0.004:
				drum = sin(drum_ph) * drum_env * 0.24
				drum_ph += TAU * (drum_freq * (0.55 + 0.45 * drum_env)) * dt
				drum_env *= drum_mul

			var drone: float = sin(drone_ph) * 0.13 + sin(drone5_ph) * 0.08
			drone_ph += d_drone
			drone5_ph += d_drone5

			var cur_f: float = clampf((lead * 0.34 + brass + drum + drone) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func synth_nhan_dien_loop(sample_rate: int) -> AudioStreamWAV:
	# Pháo Đài Nhân Điện — Công Thành Hồn Điện: D Thứ Phrygian khẩn trương (D, Eb, F, G, A, Bb) + Trống Chiến + Xích Hồn
	var lead_notes: Array[float] = [
		293.66, 311.13, 349.23, 440.00, 466.16, 440.00, 349.23, 311.13,
		293.66, 440.00, 466.16, 587.33, 523.25, 466.16, 440.00, 311.13
	]
	var step_samples: int = int(0.32 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = lead_notes.size() * step_samples
	var total_pairs: int = lead_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var lead_mul: float = exp(-4.4 * dt)
	var drum_mul: float = exp(-11.5 * dt)
	var chain_mul: float = exp(-7.5 * dt)
	var lead_atk_inc: float = dt / 0.008

	var drone_cycles: float = maxf(2.0, roundf(73.42 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_tritone: float = d_drone * 1.4142
	var drone_ph: float = 0.0
	var tri_ph: float = 0.0

	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(lead_notes.size()):
		var l_dph: float = TAU * lead_notes[idx] * dt
		var l_ph: float = 0.0
		var l_env: float = 1.0
		var l_atk: float = 0.0

		var drum_env: float = 1.0 if (idx % 2) == 0 else 0.55
		var drum_ph: float = 0.0
		var drum_freq: float = 96.0 if (idx % 4) == 0 else 68.0

		var chain_env: float = 1.0 if (idx % 4) == 2 else 0.0
		var chain_ph: float = 0.0

		for _s in range(step_pairs):
			if l_atk < 1.0:
				l_atk = minf(1.0, l_atk + lead_atk_inc)
			var lead: float = (sin(l_ph) * 0.54 + sin(l_ph * 2.0) * 0.30 + sin(l_ph * 3.0) * 0.16) * l_env * l_atk
			l_ph += l_dph
			l_env *= lead_mul

			var drum: float = 0.0
			if drum_env > 0.004:
				drum = sin(drum_ph) * drum_env * 0.28
				drum_ph += TAU * (drum_freq * (0.48 + 0.52 * drum_env)) * dt
				drum_env *= drum_mul

			var chain: float = 0.0
			if chain_env > 0.004:
				chain = (sin(chain_ph) * 0.50 + sin(chain_ph * 2.91) * 0.32 + sin(chain_ph * 4.37) * 0.18) * chain_env * 0.15
				chain_ph += TAU * 740.0 * dt
				chain_env *= chain_mul

			var drone: float = sin(drone_ph) * 0.16 + sin(tri_ph) * 0.06
			drone_ph += d_drone
			tri_ph += d_tritone

			var cur_f: float = clampf((lead * 0.34 + drum + chain + drone) * 0.88, -0.95, 0.95)
			pcm.encode_s16(out_idx, int((prev_f + cur_f) * 16383.5))
			pcm.encode_s16(out_idx + 2, int(cur_f * 32767.0))
			prev_f = cur_f
			out_idx += 4

	return _pack_loop_wav(pcm, total_samples, sample_rate)


static func synth_yeu_hoa_loop(sample_rate: int) -> AudioStreamWAV:
	# Yêu Hỏa Không Gian & Yêu Liên Đồng Tâm: Song tấu Tỳ Bà & Sáo Trúc A Thứ Ngũ Cung (A, C, D, E, G) yêu dị mà da diết
	var pipa_notes: Array[float] = [
		440.00, 523.25, 587.33, 659.25, 783.99, 659.25, 587.33, 523.25,
		440.00, 659.25, 783.99, 880.00, 783.99, 659.25, 587.33, 440.00
	]
	var flute_notes: Array[float] = [
		880.00, 0.0, 1046.50, 0.0, 1174.66, 0.0, 1046.50, 880.00,
		783.99, 0.0, 880.00, 0.0, 1318.51, 0.0, 1174.66, 880.00
	]
	var step_samples: int = int(0.44 * float(sample_rate)) & ~1
	var step_pairs: int = step_samples >> 1
	var total_samples: int = pipa_notes.size() * step_samples
	var total_pairs: int = pipa_notes.size() * step_pairs
	var total_sec: float = float(total_samples) / float(sample_rate)
	var dt: float = 2.0 / float(sample_rate)
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)

	var pp_mul: float = exp(-4.1 * dt)
	var pp_h2_mul: float = exp(-6.2 * dt)
	var fl_mul: float = exp(-1.55 * dt)
	var shimmer_mul: float = exp(-2.3 * dt)
	var pp_atk_inc: float = dt / 0.008
	var fl_atk_inc: float = dt / 0.060

	var drone_cycles: float = maxf(2.0, roundf(110.00 * total_sec * 0.5) * 2.0)
	var d_drone: float = TAU * drone_cycles / float(total_pairs)
	var d_drone5: float = d_drone * 1.5
	var d_vib: float = TAU * 5.6 * dt
	var drone_ph: float = 0.0
	var drone5_ph: float = 0.0
	var vib_ph: float = 0.0

	var fl_ph: float = 0.0
	var fl_dph: float = 0.0
	var fl_env: float = 0.0
	var fl_atk: float = 0.0
	var sh_ph: float = 0.0
	var sh_dph: float = 0.0
	var sh_env: float = 0.0

	var prev_f: float = 0.0
	var out_idx: int = 0

	for idx in range(pipa_notes.size()):
		var p_dph: float = TAU * pipa_notes[idx] * dt
		var p_ph: float = 0.0
		var p_env: float = 1.0
		var p_h2: float = 1.0
		var p_atk: float = 0.0

		if flute_notes[idx] > 0.0:
			fl_dph = TAU * flute_notes[idx] * dt
			fl_ph = 0.0
			fl_env = 1.0
			fl_atk = 0.0

		if (idx % 4) == 0:
			sh_dph = TAU * (pipa_notes[idx] * 2.0) * dt
			sh_ph = 0.0
			sh_env = 1.0

		for _s in range(step_pairs):
			if p_atk < 1.0:
				p_atk = minf(1.0, p_atk + pp_atk_inc)
			var pipa: float = (sin(p_ph) * 0.55 + sin(p_ph * 2.0) * 0.28 * p_h2 + sin(p_ph * 3.0) * 0.14 * p_h2) * p_env * p_atk
			p_ph += p_dph
			p_env *= pp_mul
			p_h2 *= pp_h2_mul

			var flute: float = 0.0
			if fl_env > 0.002:
				if fl_atk < 1.0:
					fl_atk = minf(1.0, fl_atk + fl_atk_inc)
				vib_ph += d_vib
				flute = (sin(fl_ph) * 0.76 + sin(fl_ph * 2.0) * 0.18) * fl_env * fl_atk * 0.24
				fl_ph += fl_dph * (1.0 + 0.0050 * sin(vib_ph) * fl_atk)
				fl_env *= fl_mul

			var shimmer: float = 0.0
			if sh_env > 0.002:
				shimmer = (sin(sh_ph) * 0.62 + sin(sh_ph * 2.41) * 0.24) * sh_env * 0.14
				sh_ph += sh_dph
				sh_env *= shimmer_mul

			var drone: float = sin(drone_ph) * 0.13 + sin(drone5_ph) * 0.07
			drone_ph += d_drone
			drone5_ph += d_drone5

			var cur_f: float = clampf((pipa * 0.34 + flute + shimmer + drone) * 0.88, -0.95, 0.95)
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
