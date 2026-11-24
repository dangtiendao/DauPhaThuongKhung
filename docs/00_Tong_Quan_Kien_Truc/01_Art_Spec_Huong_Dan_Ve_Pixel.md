# QUY CHUẨN KỸ THUẬT TỰ VẼ PIXEL ART (CHUẨN TIÊN HIỆP 48x48 CHO ASEPRITE / LIBRESPRITE)

Tài liệu này chốt bộ thông số kỹ thuật chuẩn đã cấu hình sẵn trong `project.godot` và toàn bộ các script Godot 4 để bạn tự thiết kế đồ họa Pixel đẹp ngang tầm game Indie (*Sea of Stars / Eastward / Octopath-lite*).

---

## 1. Năm Quy Chuẩn Vàng Đã Nâng Cấp

1. **Độ phân giải gốc khung hình (Base Viewport)**: `640 x 360 px` (`16:9` — phóng nét nguyên lần lên `1280x720` và Full HD `1920x1080`).
2. **Kích thước ô bản đồ (TileMap Grid)**: `16 x 16 px`.
3. **Khung vẽ Nhân vật & Quái thường**: **`48 x 48 px`** *(thân người cao `36–42 px`, tỷ lệ 2.5–3 đầu — đủ rộng để vẽ rõ tóc bay, nếp gấp Hắc Bào, đai đỏ, ánh mắt sắc lạnh mà vẫn vẽ nhanh animation 4–6 frames!)*.
4. **Bảng màu Cổ Phong 48 Màu (Hue-Shifted)**:
   * File bảng màu đã tạo sẵn tại `assets/palettes/dptk_xianxia_48.gpl`.
   * Trong **Aseprite / LibreSprite**: Chọn `Palette Options -> Load Palette -> dptk_xianxia_48.gpl`.
   * **Quy tắc viền**: Dùng màu Tím Than `#141020` làm viền thay vì đen tuyền `#000000` để nhân vật hòa quyện mượt mà với ánh sáng 2D!
5. **Ánh sáng Động & Hạt Lửa tự động từ Godot 4**:
   * Khi bạn vẽ Sprite đẹp rồi lưu đè vào `assets/sprites/`, Godot 4 tự động áp thêm ánh đèn `PointLight2D` đổi màu theo 23 Dị Hỏa, bóng đổ tiếp đất và hạt đốm lửa `CPUParticles2D` bay quanh nhân vật!

---

## 2. Quy Tắc SpriteSheet Hoạt Ảnh & Tách Lớp Vũ Khí

* **Luôn vẽ mặt hướng sang PHẢI (`+X`)**: Code tự lật gương (`flip_h`) khi nhìn sang trái.
* **Hỗ trợ SpriteSheet nằm ngang tự động**: Code trong `player_controller.gd` và `enemy_controller.gd` tự động chia số khung hình theo công thức `số_frame = chiều_rộng / chiều_cao`:
  * `assets/sprites/player/tieu_viem_idle.png`: **`192 x 48 px`** (4 frames đứng thở & tà áo bay).
  * `assets/sprites/player/tieu_viem_run.png`: **`288 x 48 px`** (6 frames nghiêng người chạy).
  * `assets/sprites/weapons/huyen_trong_xich.png`: **`48 x 48 px`** (Vẽ nằm ngang, chuôi bên trái `x = 3..12`, mũi thước hướng sang phải `x = 16..46`).
  * `assets/sprites/enemies/hoang_da_son_lang.png`, `thiet_boi_son_tru.png`, `tieu_ninh_boss.png`: **`96 x 48 px`** (2 frames — hoặc bạn có thể mở rộng thành `192 x 48` 4 frames, game tự nhận ngay không cần sửa code!).

---

## 3. Quy Tắc Vẽ Hiệu Ứng Lửa "Grayscale" Cho 23 Dị Hỏa

Các tệp hiệu ứng `assets/sprites/vfx/slash_arc.png` và `fire_lotus.png` (`64 x 64 px`) chỉ cần vẽ bằng **Thang Độ Xám (Trắng → Xám vừa → Xám tối)** — Shader `assets/shaders/di_hoa_palette.gdshader` sẽ tự động nhuộm màu chuẩn xác cho cả 23 loại Dị Hỏa trong `data/flames.json`!
