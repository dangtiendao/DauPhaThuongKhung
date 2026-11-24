# QUY CHUẨN KỸ THUẬT TỰ VẼ PIXEL ART (CHUẨN TIÊN HIỆP 32-BIT HD 1280×720 · MẶC ĐỊNH 8 FRAME)

Tài liệu này chốt bộ thông số kỹ thuật chuẩn đã cấu hình sẵn trong `project.godot`, `SpriteAnimHelper`, `tools/normalize_spritesheet.py` và toàn bộ script Godot 4 theo **chuẩn mặc định 8 khung hình (`4×2` hoặc `8×1`)**.

---

## 1. Năm Quy Chuẩn Vàng (Chuẩn 8-Frame HD Pixel Art)

1. **Độ phân giải gốc khung hình (Base Viewport)**: `1280 × 720 px` (`16:9` HD Pixel Art, chế độ co giãn `canvas_items / expand`, bộ lọc ảnh `Nearest`, bật `2D Physics Interpolation` 60–144 FPS).
2. **Kích thước ô bản đồ (Tile Texture)**: `64 × 64 px` / `128 × 128 px` lát liền mạch (`STRETCH_TILE`).
3. **Khung vẽ Nhân vật & Boss (Mặc định 8 frame)**:
   * **Tiêu Viêm — Idle & Run**: Lưới `4×2` kích thước **`384 × 192 px`** (8 frame, mỗi ô `96 × 96 px`).
   * **Tiêu Viêm — Cast & Dash**: Dải ngang `8×1` kích thước **`896 × 112 px`** (8 frame, mỗi ô `112 × 112 px`).
   * **Tiêu Viêm — 4 bộ Attack liền thân vũ khí (`unarmed / sword / sabre / ruler`)**: Lưới `4×2` kích thước **`768 × 304 px`** (8 frame, mỗi ô `192 × 152 px` — Hàng 0: Combo 1 `[0..3]`, Hàng 1: Combo 2 `[4..7]`, Combo 3 quét liên hoàn 7 frame `[0,1,2,4,5,6,7]`).
   * **Boss 8 khung hình (`*_boss_anim.png`)**: Lưới `4×2` kích thước **`544 × 248 px` đến `640 × 272 px`** (`hframes = 4, vframes = 2`: Hàng 0 = `[0,1] Idle thở` + `[2,3] Move bước lao`, Hàng 1 = `[4,5] Windup tụ lực` + `[6,7] Strike ra đòn & dư lực`).
4. **Bảng màu Cổ Phong 48 Màu (Hue-Shifted)**:
   * File bảng màu đã tạo sẵn tại `assets/palettes/dptk_xianxia_48.gpl`.
   * Trong **Aseprite / LibreSprite**: Chọn `Palette Options -> Load Palette -> dptk_xianxia_48.gpl`.
   * **Quy tắc viền**: Dùng màu Tím Than `#141020` làm viền thay vì đen tuyền `#000000` để nhân vật hòa quyện mượt mà với ánh sáng 2D!
5. **Ánh sáng Động & Hạt Lửa tự động từ Godot 4**:
   * Khi bạn lưu Sprite mới vào `assets/sprites/`, Godot 4 tự động áp ánh đèn `PointLight2D` đổi màu theo 23 Dị Hỏa, bóng đổ tiếp đất neo chân (`Foot-Anchored Pivot`) và hạt đốm lửa `CPUParticles2D` bay quanh nhân vật!

---

## 2. Quy Tắc SpriteSheet Hoạt Ảnh & Công Cụ Tự Động (`SpriteAnimHelper`)

* **Luôn vẽ mặt hướng sang PHẢI (`+X`)**: Code tự lật gương (`flip_h`) khi nhìn sang trái.
* **Tự động nhận diện số khung hình & tương thích ngược**: `SpriteAnimHelper.inspect_sheet()` tự nhận diện lưới `4×2` / `8×1` (mặc định 8 frame), đồng thời vẫn hỗ trợ ngược `4×1`, `6×1`, `4×3` (12 frame), `4×4` (16 frame) hoặc cấu hình tường minh qua hậu tố tên file (`_8f`, `_4x2`, `_4x3`) / sidecar `<ten_anh>.anim.json`.
* **Nâng nhanh bất kỳ sheet 4 frame mới nào lên chuẩn 8 frame sắc nét**:
  ```bash
  python tools/normalize_spritesheet.py upgrade-8f <input_4f.png> -o <output_8f.png> --mode boss
  ```
  *(Hỗ trợ `--mode idle | cast | dash | attack | boss`, tự khóa bàn chân, chống cắt mép vũ khí và giữ nguyên 100% bảng màu pixel gốc).*
* **Vũ khí đeo lưng (`assets/sprites/weapons/*.png`)**: Chuôi hướng trái, mũi hướng phải để gắn chuẩn lên lưng nhân vật khi di chuyển.

---

## 3. Quy Tắc Vẽ Hiệu Ứng Lửa "Grayscale" Cho 23 Dị Hỏa

Các tệp hiệu ứng `assets/sprites/vfx/slash_arc.png` và `fire_lotus.png` (`64 × 64 px`) chỉ cần vẽ bằng **Thang Độ Xám (Trắng → Xám vừa → Xám tối)** — Shader `assets/shaders/di_hoa_palette.gdshader` sẽ tự động nhuộm màu chuẩn xác cho cả 23 loại Dị Hỏa trong `data/flames.json`!
