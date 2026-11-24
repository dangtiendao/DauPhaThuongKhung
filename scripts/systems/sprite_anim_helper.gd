class_name SpriteAnimHelper
extends RefCounted
## Bộ chuẩn hóa Sprite Sheet Đa Khung Hình Linh Hoạt (4 / 6 / 8 / 12 / 16+ frame):
## - Hỗ trợ cả dải ngang (hframes × 1) lẫn dạng lưới 2 chiều (hframes × vframes, ví dụ 4×2, 4×3, 4×4, 6×2).
## - Tự đọc cấu hình tùy chọn qua file sidecar "<ten_anh>.anim.json" hoặc gợi ý trong tên file ("_6f", "_8f", "_4x2", "_4x4").
## - Tự động đo chính xác đường tiếp đất bàn chân (foot_offset_y) để neo Pivot tại bàn chân cho mọi kích thước ảnh mới!

static var _meta_cache: Dictionary = {}


## Phân tích layout của một Texture2D (có cache vĩnh viễn theo resource_path).
## Trả về Dictionary: { "hframes": int, "vframes": int, "total_frames": int, "cell_w": int, "cell_h": int, "foot_offset_y": float, "fps": float, "anims": Dictionary }
static func inspect_sheet(tex: Texture2D, kind: String = "square", fallback_h: int = 1, fallback_v: int = 1, explicit_meta: Dictionary = {}) -> Dictionary:
	if tex == null:
		return {
			"hframes": max(1, fallback_h),
			"vframes": max(1, fallback_v),
			"total_frames": max(1, fallback_h * fallback_v),
			"cell_w": 96,
			"cell_h": 96,
			"foot_offset_y": -44.0,
			"fps": 10.0,
			"anims": {}
		}

	var rpath: String = tex.resource_path
	var w: int = tex.get_width()
	var h: int = tex.get_height()
	var id_part: String = rpath if rpath != "" else ("mem_%d" % tex.get_instance_id())
	var cache_key: String = "%s|%dx%d|%s|%d|%d|%s" % [id_part, w, h, kind, fallback_h, fallback_v, str(explicit_meta)]
	if _meta_cache.has(cache_key):
		return _meta_cache[cache_key]
	var hf: int = max(1, fallback_h)
	var vf: int = max(1, fallback_v)
	var total_f: int = -1
	var fps_val: float = 10.5
	var anims_dict: Dictionary = {}

	# 1. Ưu tiên đọc sidecar JSON ("res://.../tieu_viem_run.anim.json") nếu người dùng tạo kèm
	var sidecar: Dictionary = _load_sidecar_json(rpath)
	if not sidecar.is_empty():
		hf = max(1, int(sidecar.get("hframes", hf)))
		vf = max(1, int(sidecar.get("vframes", vf)))
		if sidecar.has("total_frames"):
			total_f = max(1, int(sidecar.get("total_frames", hf * vf)))
		fps_val = float(sidecar.get("fps", fps_val))
		if sidecar.get("anims", {}) is Dictionary:
			anims_dict = sidecar.get("anims", {})

	# 2. Override trực tiếp từ JSON data (enemies.json / equipment.json) nếu có
	if not explicit_meta.is_empty():
		if explicit_meta.has("hframes"):
			hf = max(1, int(explicit_meta.get("hframes", hf)))
		if explicit_meta.has("vframes"):
			vf = max(1, int(explicit_meta.get("vframes", vf)))
		if explicit_meta.has("total_frames"):
			total_f = max(1, int(explicit_meta.get("total_frames", hf * vf)))
		if explicit_meta.has("fps"):
			fps_val = float(explicit_meta.get("fps", fps_val))
		if explicit_meta.get("anims", {}) is Dictionary:
			anims_dict = explicit_meta.get("anims", {})

	# 3. Nếu chưa có metadata tường minh -> kiểm tra gợi ý tên file (_4x4, _4x2, _6f, _8f, _12f, _16f) hoặc tự suy luận theo kích thước
	if sidecar.is_empty() and not explicit_meta.has("hframes"):
		var hint: Dictionary = _parse_filename_hint(rpath)
		if not hint.is_empty():
			hf = max(1, int(hint.get("hframes", hf)))
			vf = max(1, int(hint.get("vframes", vf)))
		else:
			var auto_hv: Vector2i = _infer_grid_from_dimensions(w, h, kind, fallback_h, fallback_v)
			hf = max(1, auto_hv.x)
			vf = max(1, auto_hv.y)

	if total_f <= 0:
		total_f = hf * vf
	total_f = clampi(total_f, 1, hf * vf)

	var cell_w: int = maxi(1, int(round(float(w) / float(hf))))
	var cell_h: int = maxi(1, int(round(float(h) / float(vf))))
	var foot_off: float = _detect_foot_offset_y(tex, cell_w, cell_h)

	var result: Dictionary = {
		"hframes": hf,
		"vframes": vf,
		"total_frames": total_f,
		"cell_w": cell_w,
		"cell_h": cell_h,
		"foot_offset_y": foot_off,
		"fps": fps_val,
		"anims": anims_dict
	}
	_meta_cache[cache_key] = result
	return result


## Áp dụng thông số sheet và neo tâm xoay (Pivot) chuẩn xác vào bàn chân cho Sprite2D.
static func apply_to_sprite(sprite: Sprite2D, tex: Texture2D, meta: Dictionary, foot_anchor_y: float = 11.0) -> void:
	if sprite == null or tex == null:
		return
	var hf: int = maxi(1, int(meta.get("hframes", 1)))
	var vf: int = maxi(1, int(meta.get("vframes", 1)))
	var foot_off_y: float = float(meta.get("foot_offset_y", -44.0))
	if sprite.texture != tex:
		sprite.texture = tex
	if sprite.hframes != hf:
		sprite.hframes = hf
	if sprite.vframes != vf:
		sprite.vframes = vf
	sprite.centered = true
	sprite.offset = Vector2(0.0, foot_off_y)
	sprite.position = Vector2(0.0, foot_anchor_y)


## Tính danh sách chỉ số frame cho từng nhịp Combo (1/2/3) hoặc Chiêu thức (skill) thích ứng 4 / 6 / 8 / 12 / 16 frame!
static func get_player_attack_frames(meta: Dictionary, combo_step: int, is_skill: bool = false) -> PackedInt32Array:
	var total: int = maxi(1, int(meta.get("total_frames", 4)))
	var hf: int = maxi(1, int(meta.get("hframes", 4)))
	var vf: int = maxi(1, int(meta.get("vframes", 1)))
	var anims: Dictionary = meta.get("anims", {})

	var key_name: String = "skill" if is_skill else ("combo_%d" % clampi(combo_step, 1, 3))
	if anims.has(key_name) and anims[key_name] is Array and not (anims[key_name] as Array).is_empty():
		var custom_arr := PackedInt32Array()
		for v in anims[key_name]:
			custom_arr.append(clampi(int(v), 0, total - 1))
		return custom_arr

	# Lưới 4 hàng (ví dụ 4×4 = 16 frame hoặc 6×4 = 24 frame): Hàng 0=Combo1, Hàng 1=Combo2, Hàng 2=Combo3, Hàng 3=Skill!
	if vf >= 4:
		var row_idx: int = 3 if is_skill else clampi(combo_step - 1, 0, 2)
		return _range_frames(row_idx * hf, mini((row_idx + 1) * hf - 1, total - 1))
	# Lưới 3 hàng (ví dụ 4×3 = 12 frame): Hàng 0=Combo1, Hàng 1=Combo2, Hàng 2=Combo3/Skill!
	if vf == 3:
		var row_idx3: int = 2 if is_skill else clampi(combo_step - 1, 0, 2)
		return _range_frames(row_idx3 * hf, mini((row_idx3 + 1) * hf - 1, total - 1))

	if total <= 1:
		return PackedInt32Array([0])
	if total == 2:
		return PackedInt32Array([0, 1])
	if total == 4:
		if is_skill:
			return PackedInt32Array([0, 1, 3])
		if combo_step == 1:
			return PackedInt32Array([0, 1])
		elif combo_step == 2:
			return PackedInt32Array([2, 3])
		else:
			# Combo 3 quét mượt qua cả 4 khung hình thay vì nhảy cóc 0 -> 3!
			return PackedInt32Array([0, 1, 2, 3])
	if total == 6:
		if is_skill:
			return PackedInt32Array([0, 2, 4, 5])
		if combo_step == 1:
			return PackedInt32Array([0, 1])
		elif combo_step == 2:
			return PackedInt32Array([2, 3])
		else:
			return PackedInt32Array([4, 5])
	if total == 8:
		if is_skill:
			return PackedInt32Array([0, 1, 2, 6, 7])
		if combo_step == 1:
			return PackedInt32Array([0, 1, 2, 3])
		elif combo_step == 2:
			return PackedInt32Array([4, 5, 6, 7])
		else:
			return PackedInt32Array([0, 1, 2, 4, 5, 6, 7])

	# Dải 9..16+ frame: tự chia đều thành 3 nhịp combo (hoặc 4 phần nếu >= 12 frame)
	if is_skill:
		var s_len: int = maxi(3, int(round(float(total) / 4.0)))
		return _range_frames(maxi(0, total - s_len), total - 1)
	var seg: int = maxi(2, int(floor(float(total) / 3.0)))
	var st: int = clampi((combo_step - 1) * seg, 0, total - 1)
	var en: int = (total - 1) if combo_step >= 3 else mini(st + seg - 1, total - 1)
	return _range_frames(st, en)


## Tính danh sách chỉ số frame cho Boss/Quái theo trạng thái ("idle", "move", "windup", "strike").
## Hỗ trợ mượt cả 4×1 cũ lẫn 6×1, 8×1, 4×2, 4×4 (16 frame), 6×4...
static func get_enemy_state_frames(meta: Dictionary, state_name: String) -> PackedInt32Array:
	var total: int = maxi(1, int(meta.get("total_frames", 1)))
	var hf: int = maxi(1, int(meta.get("hframes", 1)))
	var vf: int = maxi(1, int(meta.get("vframes", 1)))
	var anims: Dictionary = meta.get("anims", {})

	if anims.has(state_name) and anims[state_name] is Array and not (anims[state_name] as Array).is_empty():
		var out := PackedInt32Array()
		for v in anims[state_name]:
			out.append(clampi(int(v), 0, total - 1))
		return out

	if total <= 1:
		return PackedInt32Array([0])

	# Lưới 4 hàng (4×4 = 16 frame, 6×4 = 24 frame): mỗi hàng là 1 hoạt ảnh riêng!
	if vf >= 4:
		var r: int = 0
		if state_name == "move":
			r = 1
		elif state_name == "windup":
			r = 2
		elif state_name == "strike":
			r = 3
		return _range_frames(r * hf, mini((r + 1) * hf - 1, total - 1))

	# Lưới 2 hàng chuẩn mặc định 8 frame (4×2: Hàng 0 = [0,1] Idle + [2,3] Move, Hàng 1 = [4,5] Windup + [6,7] Strike)
	if vf == 2:
		var half: int = maxi(1, hf / 2)
		if state_name == "idle":
			return _range_frames(0, maxi(0, half - 1))
		elif state_name == "move":
			return _range_frames(mini(half, hf - 1), hf - 1)
		elif state_name == "windup":
			return _range_frames(hf, hf + maxi(0, half - 1))
		else:
			return _range_frames(mini(hf + half, total - 1), total - 1)

	# Dải 1 hàng 4 frame chuẩn cũ (0: Idle, 1: Stride/Dash, 2: Windup, 3: Strike)
	if total == 4:
		if state_name == "idle":
			return PackedInt32Array([0])
		elif state_name == "move":
			return PackedInt32Array([0, 1])
		elif state_name == "windup":
			return PackedInt32Array([2])
		else:
			return PackedInt32Array([3])

	# Dải 1 hàng 6 / 8 / 12 / 16 frame: chia đều 4 nhóm trạng thái
	var q: int = maxi(1, int(floor(float(total) / 4.0)))
	if state_name == "idle":
		return _range_frames(0, q - 1)
	elif state_name == "move":
		return _range_frames(q, mini(q * 2 - 1, total - 1))
	elif state_name == "windup":
		return _range_frames(mini(q * 2, total - 1), mini(q * 3 - 1, total - 1))
	else:
		return _range_frames(mini(q * 3, total - 1), total - 1)


static func _range_frames(start_idx: int, end_idx: int) -> PackedInt32Array:
	var arr := PackedInt32Array()
	var s: int = mini(start_idx, end_idx)
	var e: int = maxi(start_idx, end_idx)
	for i in range(s, e + 1):
		arr.append(i)
	return arr


static func _load_sidecar_json(tex_path: String) -> Dictionary:
	if tex_path == "":
		return {}
	var base: String = tex_path.get_basename()
	var json_path: String = base + ".anim.json"
	if not FileAccess.file_exists(json_path):
		return {}
	var f := FileAccess.open(json_path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	return parsed as Dictionary if parsed is Dictionary else {}


static func _parse_filename_hint(tex_path: String) -> Dictionary:
	if tex_path == "":
		return {}
	var fname: String = tex_path.get_file().get_basename().to_lower()
	# Khớp dạng _4x4, _4x2, _6x2, _8x2
	var re_grid := RegEx.new()
	re_grid.compile("_(\\d+)x(\\d+)$")
	var m_g: RegExMatch = re_grid.search(fname)
	if m_g != null:
		return {
			"hframes": clampi(int(m_g.get_string(1)), 1, 32),
			"vframes": clampi(int(m_g.get_string(2)), 1, 16)
		}
	# Khớp dạng _6f, _8f, _12f, _16f
	var re_strip := RegEx.new()
	re_strip.compile("_(\\d+)f$")
	var m_s: RegExMatch = re_strip.search(fname)
	if m_s != null:
		return {
			"hframes": clampi(int(m_s.get_string(1)), 1, 32),
			"vframes": 1
		}
	return {}


static func _infer_grid_from_dimensions(w: int, h: int, kind: String, fallback_h: int, fallback_v: int) -> Vector2i:
	if w <= 0 or h <= 0:
		return Vector2i(fallback_h, fallback_v)

	if kind == "player_attack":
		# Ô chuẩn của sheet đánh là 192×152 (hỗ trợ 4×1, 6×1, 8×1, 4×2, 4×3, 4×4, 6×2...)
		if w % 192 == 0 and h % 152 == 0:
			return Vector2i(clampi(w / 192, 1, 16), clampi(h / 152, 1, 8))
		var est_h: int = clampi(int(round(float(w) / maxf(1.0, float(h) * 1.26))), 1, 16)
		return Vector2i(est_h, 1)

	if kind == "enemy_anim":
		# Hỗ trợ lưới Boss nhiều hàng nếu chiều cao >= 240px (gấp 2–4 lần ô ~128px)
		var est_v: int = 1
		if h >= 440:
			est_v = 4
		elif h >= 330:
			est_v = 3
		elif h >= 220:
			est_v = 2
		var row_h: float = float(h) / float(est_v)
		var est_cols: int = clampi(int(round(float(w) / maxf(1.0, row_h * 1.15))), 1, 16)
		return Vector2i(est_cols, est_v)

	# Mặc định "square" (Idle / Run / Cast / Dash — ô chuẩn ~96×96 hoặc vuông 1:1)
	# 1. Ưu tiên nhận diện lưới 2 chiều chuẩn ô 96×96 (ví dụ 288×192=3×2, 384×192=4×2, 576×192=6×2, 384×384=4×4)
	if w % 96 == 0 and h % 96 == 0 and h >= 192:
		var cols96: int = w / 96
		var rows96: int = h / 96
		if cols96 >= 2 and cols96 <= 16 and rows96 >= 2 and rows96 <= 8:
			return Vector2i(cols96, rows96)

	if w == h:
		return Vector2i(1, 1)

	# 2. Dải ngang chuẩn tỷ lệ 1:1 (384×96=4f, 576×96=6f, 768×96=8f, 1152×96=12f, 1536×96=16f)
	if w > h and (w % h == 0):
		var strip_n: int = w / h
		if strip_n >= 2 and strip_n <= 24:
			return Vector2i(strip_n, 1)

	# Fallback tổng quát theo tỷ lệ cạnh
	if w > h * 1.6:
		return Vector2i(clampi(int(round(float(w) / float(h))), 1, 24), 1)
	return Vector2i(fallback_h, fallback_v)


static func _detect_foot_offset_y(tex: Texture2D, cell_w: int, cell_h: int) -> float:
	var fallback_off: float = -float(cell_h) * 0.46
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		return fallback_off
	var scan_w: int = mini(cell_w, img.get_width())
	var scan_h: int = mini(cell_h, img.get_height())
	var bottom_y: int = -1
	for y in range(scan_h - 1, -1, -1):
		for x in range(0, scan_w, 2):
			if img.get_pixel(x, y).a > 0.12:
				bottom_y = y
				break
		if bottom_y >= 0:
			break
	if bottom_y < 0:
		return fallback_off
	# Với centered = true, tâm ảnh nằm ở cell_h * 0.5 -> dịch offset sao cho pixel bàn chân (bottom_y) trùng đúng y = 0!
	return float(cell_h) * 0.5 - float(bottom_y)
