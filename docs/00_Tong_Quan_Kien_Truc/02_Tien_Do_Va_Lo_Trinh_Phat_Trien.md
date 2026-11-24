# TIẾN ĐỘ DỰ ÁN & LỘ TRÌNH PHÁT TRIỂN (PROJECT PROGRESS & ROADMAP)

> **Dự án**: Đấu Phá Thương Khung — Top-down 2D HD Pixel Action RPG (Godot Engine 4)
> **Cập nhật lần cuối**: 24/11/2026
> **Phiên bản hiện tại**: **v0.4.0 (Trọn Bộ Quyển I: Ch.01–04 · Data-Driven Story Engine + Đế Đô & Ước Hẹn 3 Năm Vân Lam Sơn — 19 Bản Đồ, 31 Nhiệm Vụ Chính, 19 Boss Độc Chiêu)**
> **Mục đích**: Theo dõi đối chiếu giữa **Hồ sơ thiết kế (GDD — 11 Chương)** và **Trạng thái thực thi trong mã nguồn**, quản lý backlog lỗi kỹ thuật và lộ trình phát triển các mốc tiếp theo.

---

## 1. Bức Tranh Tổng Quan Hiện Tại (Snapshot)

| Hạng mục | Đã hoàn thiện trong game | Mục tiêu GDD | Tỷ lệ / Ghi chú |
| :--- | :---: | :---: | :--- |
| **Tài liệu Thiết kế (GDD)** | 25 file + 2 concept art | 25 file | **100%** — Đã viết trọn 11 Chương, hệ thống & roadmap tiến độ |
| **Cốt truyện chơi được** | **4 Chương — Trọn Quyển I** (NV 1–31 + 3 tuyến phụ Ch.04 + Easter Egg) | 11 Chương (4 Quyển) | **36%** — Xong Ch.01, Ch.02, Ch.03 & **Ch.04 (Đế Đô & Vân Lam Sơn)** |
| **Bản đồ liên thông** | **19 bản đồ** (22 rương, BFS tìm đường tự động) | Toàn Đấu Khí Đại Lục | Ch.01 (3), Ch.02 (4), Ch.03 (4), **Ch.04 (8)** |
| **Đấu Kỹ chủ động** | **11 chiêu** (`skills.json`) | 24 chiêu | **46%** — Đủ bộ Quyển I + `Lạc Độc Ám Chưởng` + Phật Nộ Hỏa Liên `[F]` |
| **Dị Hỏa & Thú Hỏa** | **28/28** dữ liệu & **28/28 `lotus_effect`** · **3/28** thu phục cốt truyện | 28 ngọn Hỏa | Cả 28 hiệu ứng đặc biệt Hỏa Liên đã hoạt động; 25 ngọn còn lại thử qua DEMO |
| **Cảnh giới & Đột phá** | **12/12** dữ liệu · Đột phá cốt truyện tới **Đại Đấu Sư 9 Tinh Đỉnh Phong** | 12 Đại Cảnh Giới | Đã có **Đấu Khí Sa Y** (Đấu Sư) & **Đấu Khí Khải Giáp + Ngoại Phóng** (Đại Đấu Sư) |
| **Quái & Boss** | **33** (14 quái + **19/19 Boss có chiêu riêng & `anim_sheet` 4 frame**) | 25+ Đại Boss | 12 Boss Ch.01–03 + **7 Boss Ch.04** (Mặc Thừa → Đấu Tông Vân Sơn) |
| **Luyện Đan** | **20** vật phẩm · **9** đan phương (Phẩm 1–6) | 36 đan phương · 13 Thiên Đỉnh | Đã thêm `Phá Ách Đan`, `Tam Văn Thanh Linh Đan` & `Thất Huyễn Thanh Linh Tiên` |
| **Trang Bị 10 Ô** | **25** mẫu · **4** bộ Set · 6 phẩm chất · +0→+15 | Trang bị + Yêu Khôi + Khảm Hạch | Đã thêm Bộ Quán Quân Đế Đô, `Xích Dương Đỉnh`, `Pháp Bào Trưởng Lão`, `Kim Viêm Hộ Hồn Ngọc` |
| **Đồng Hành AI & Hồng Nhan** | **3** Đồng hành `[G]` · **`[T]` Dược Lão → Mỹ Đỗ Toa Đấu Tông** · **5 Hồng Nhan** Buff & Tặng Quà | 17 Đồng hành & Khách khanh | Đã nối biến cố Dược Lão ngủ say -> Mỹ Đỗ Toa Đấu Tông Hộ Pháp |
| **Thế Lực & Phó Bản Endgame** | **0 / 8** Phó bản · chưa có Tông Môn | 8 Phó bản + Bàn Môn → Thiên Phủ | Dự kiến triển khai từ Quyển II trở đi |
| **Mã nguồn & Hạ tầng** | **18 script** · 9 scene · **12 JSON (Data-Driven Story Engine)** · Git | — | Nạp động `maps/quests/dialogues/enemies_chXX.json`, lưu theo `quest_id`, kiểm thử headless `0` lỗi |

---

## 2. Tiến Độ Cốt Truyện Theo 11 Chương (4 Quyển)

| Quyển | Chương | Trạng thái | Hiện trạng thực tế & Phần còn thiếu |
| :--- | :--- | :---: | :--- |
| **Quyển I**<br>*Gia Mã Đế Quốc* | **Ch.01**: Ô Thản Thành | ✅ Hoàn tất | 3 map, NV 1–9, Từ Hôn, Dược Lão, Nhã Phi, Tiêu Ngọc, Tiêu Ninh, Nhược Lâm, Lăng Ảnh, Liễu Tịch, Gia Liệt Áo, Huyền Trọng Xích. *(GDD nâng cao chưa làm: đấu giá đấu trí, ngâm bồn gỗ mini-game, né thước 30 ngày, stealth ám sát).* |
| **Quyển I** | **Ch.02**: Ma Thú Sơn Mạch | ✅ Hoàn tất | 4 map, NV 10–15, Tiểu Y Tiên, 3 Thạch Thất (Tử Vân Dực, Tàn Đồ 1/4, Sư Tử Ngâm), Vân Chi, Tiểu Tử Tinh Sư Vương & Tử Hỏa, Mục Lực, Mục Xà, Chia ly Thung Lũng U Lan. |
| **Quyển I** | **Ch.03**: Sa Mạc Tháp Qua Nhĩ | ✅ Hoàn tất | 4 map, NV 16–21, Tiêu Đỉnh/Tiêu Lệ, Hải Ba Đông (Tàn Đồ 2/4), Thanh Lân, Địa Huyệt Dung Nham (Song Đầu Hỏa Linh Xà, Thanh Liên Đài), Mặc Ba Tư, Cổ Hà, Vân Vận, Mỹ Đỗ Toa độ kiếp, Thôn phệ `#19 Thanh Liên Địa Tâm Hỏa`, Thải Lân & Phật Nộ Hỏa Liên `[F]`. |
| **Quyển I** | **Ch.04**: Đế Đô & Ước Hẹn 3 Năm | ✅ Hoàn tất | 8 map (Diêm Thành Mặc Gia Trang, Gia Mã Thánh Thành, Nạp Lan Vương Phủ, Quảng Trường Đan Hội, Thiên Thang 999 Bậc, Đỉnh Vân Lam Sơn, Phế Tích Tiêu Gia, Rừng Phong Tỏa & Trấn Quỷ Quan), NV 22–31, 3 tuyến phụ + Easter Egg Mỹ Đỗ Toa, 7 Boss độc chiêu (Mặc Thừa → Nạp Lan Yên Nhiên → Vân Lăng → Đấu Tông Vân Sơn), Đấu Khí Khải Giáp & Ngoại Phóng, `Lạc Độc Ám Chưởng`, `[T]` Mỹ Đỗ Toa Đấu Tông, hồi sinh `Kim Viêm Hộ Hồn Ngọc`. *(Ghi chú: đồ họa map/Boss Ch.04 tạm tái sử dụng tileset/sprite sẵn có để hoàn thiện art & UI ở đợt polish sau).* |
| **Quyển II**<br>*Hắc Giác Vực & Già Nam* | **Ch.05**: Hắc Giác Vực & Ngoại Viện | ⏳ Chưa làm | Hắc Ấn Thành (đấu giá ngầm), Tam Thiên Lôi Động, khảo thí Già Nam, săn Hỏa Năng. |
| **Quyển II** | **Ch.06**: Nội Viện & Thiên Phần Tháp | ⏳ Chưa làm | Bàn Môn, Tử Nghiên, Đấu Trường Cường Bảng (Boss Liễu Kình), Đáy Tháp Thiên Phần (Boss Vẫn Lạc Tâm Viêm `#14`, Hàn Phong). |
| **Quyển II** | **Ch.07**: Tam Thượng Vân Lam & Độc Tông | ⏳ Chưa làm | Boss Vân Sơn & Vụ Hộ Pháp (Dược Lão bị bắt), lập Viêm Minh, `#15 Hải Tâm Diễm`, Xuất Vân Độc Tông (Boss Hạt Tất Nham, Ma Độc Ban). |
| **Quyển III**<br>*Trung Châu Phong Vân* | **Ch.08**: Bắc Vực & Đan Hội Trung Châu | ⏳ Chưa làm | Thiên Sơn Huyết Đàm, Phần Viêm Cốc (`#12`), Tứ Phương Các (Phượng Thanh Nhi), Diệp Thành (Băng Hà Cốc), Đan Hội Trung Châu & `#9 Tam Thiên Diễm Viêm Hỏa`. |
| **Quyển III** | **Ch.09**: Cứu Sư Vong Hồn & Thiên Mộ | ⏳ Chưa làm | Đánh Vong Hồn Điện cứu Dược Lão (Trích Tinh Lão Quỷ), Hoa Tông, Viễn Cổ Di Tích, Thiên Mộ Tam Tầng, Đế Tộc Văn. |
| **Quyển IV**<br>*Thánh Đế Quyết Chiến* | **Ch.10**: Bồ Đề Hóa Thánh & Tịnh Liên | ⏳ Chưa làm | Bồ Đề Cổ Thụ, Thiên Phủ Liên Minh, `#4 Kim Đế Phần Thiên Viêm`, Yêu Hỏa Không Gian (4/4 Mảnh Tàn Đồ → `#3 Tịnh Liên Yêu Hỏa`). |
| **Quyển IV** | **Ch.11**: Cổ Đế Động Phủ & Song Đế Chiến | ⏳ Chưa làm | Cứu Tiêu Chiến, Dược Giới (`#5`, `#10`, `#22`), Cổ Đế Động Phủ (8 mảnh Cổ Đế Ngọc, Đế Phẩm Sồ Đan, `#1 Đế Viêm`), **Final Boss Hồn Thiên Đế (3 Phase)** & Endgame Đại Thiên Thế Giới. |

---

## 3. Ma Trận Tiến Độ Từng Hệ Thống (GDD vs. Đã Code)

### 3.1. Những Việc ĐÃ LÀM (Core Đã Chạy Ổn Định)
* [x] **Kiến trúc dữ liệu & Autoload**: `EventBus`, `AudioManager`, `GameDatabase`, `PlayerData` đọc 8 file JSON trong `data/`.
* [x] **Hệ thống Điều Khiển & Chiến Đấu Cơ Bản** (`scripts/entities/player_controller.gd`):
  * [x] Di chuyển 8 hướng, đánh thường combo 3 nhịp kèm 4 bộ attack sprite sheet liền thân (Tay Không / Kiếm / Đao / Huyền Trọng Xích).
  * [x] Lướt né `[Space]` có I-frame & tàn ảnh (nâng cấp tự động thành Lướt Tử Vân Dực khi đeo cánh).
  * [x] Phong ấn / Giải phong Huyền Trọng Xích `[RMB / C]` (`-15% SPD`, `+30% EXP`).
  * [x] Đấu Khí Sa Y tự kích hoạt ở Đấu Sư (`+18% DEF`, giảm `18%` sát thương khi QI `> 25%`).
  * [x] 10 Đấu Kỹ hoạt động đầy đủ (`Q/E/R/F`) + Cốt Linh Phụ Thể (`T`).
  * [x] Đèn động `PointLight2D`, hạt lửa `CPUParticles2D`, hitstop, screen shake, floating damage text.
* [x] **Cảnh Giới & Dị Hỏa**:
  * [x] Khai báo đủ 12 Đại Cảnh Giới, 4 Cảnh Linh Hồn và công thức Áp Chế / Xuyên Áp Chế (`data/realms.json`).
  * [x] Khai báo đủ 28 loại Hỏa (`data/flames.json`) + Shader nhuộm 3 tầng màu lửa (`assets/shaders/di_hoa_palette.gdshader`).
  * [x] Xưởng lắp Đấu Kỹ & ghép 2–4 Hỏa cho Phật Nộ Hỏa Liên `[K]`.
* [x] **Trang Bị 10 Ô & Loot** (`scripts/systems/equipment_system.gd`, `scripts/entities/loot_pickup.gd`):
  * [x] 10 ô mặc đồ, 6 phẩm chất (Phàm → Đế), cột sáng loot trên mặt đất, 8 dòng affix ngẫu nhiên, 3 Set Bonus, cường hóa `+0 → +15`, phân giải đồ lẻ & phân giải hàng loạt.
* [x] **Lò Luyện Đan `[L]`** (`scripts/systems/alchemy_system.gd`, `scripts/ui/hud_controller.gd`):
  * [x] 7 công thức Phẩm 1–4, Mini-game canh Hỏa Hầu `[Space]` + Chắn Đan Lôi `[E]` có cộng thưởng trực tiếp từ Dị Hỏa, Dược Đỉnh, Linh Hồn & Hảo Cảm Tiểu Y Tiên; hỗ trợ uống & gắn nhanh **Băng Tâm Đan** và **Hạt Thanh Liên Tử**.
* [x] **Quái, Boss, Hỏa Liên & Hồng Nhan**:
  * [x] 20 kẻ địch (8 quái thường + **12/12 Boss** có bộ chiêu thức/pattern riêng, 2 Phase ở 55% HP, thanh máu Boss, `BossHazardZone` cột lửa/vũng độc/băng trụ/dung nham/bão cát & đạn chuyên biệt).
  * [x] **12/12 Boss** đều đã có sprite sheet 4 frame (`anim_sheet`) mượt 60 FPS.
  * [x] Hiện thực hóa đủ **28 hiệu ứng đặc biệt (`lotus_effect`)** cho 28 ngọn Hỏa trong Phật Nộ Hỏa Liên `[F]` kèm vòng lửa 2–4 màu đồng tâm.
  * [x] 3 Đồng Hành AI `[G]` (Dược Lão, Tiểu Y Tiên, Thải Lân) + **Hệ thống Hồng Nhan Tri Kỷ** trong `[M]` (4 mốc Buff 25/50/75/100, Quà Tri Kỷ & Tặng Quà x2 sở thích).
* [x] **Giao Diện MOBA, Save/Load, DEMO & Âm Thanh**:
  * [x] HUD MOBA bấm chuột trực tiếp + quét hồi chiêu + Tooltip + Live Mini-Map + Bản Đồ Thế Giới `[M]`.
  * [x] Màn hình chính + Lưu/Tải 3 Ô Nạp Giới (nhớ tọa độ `(x, y)`) + Auto-Save + Auto-Continue + **Chế Độ DEMO** (Ô 3, mở khóa toàn bộ & Dịch Chuyển Nhanh `[M]`).
  * [x] Âm thanh Procedural tổng hợp trực tiếp (`3` BGM ngũ cung + `21` SFX).

### 3.2. Những Hệ Thống GDD CHƯA LÀM Hoặc Mới Làm Một Phần
* [ ] **Cảnh Giới & Linh Hồn nâng cao**:
  * [ ] Bổ sung đan dược & công thức đột phá từ Đại Đấu Sư → Đấu Đế (`Tam Văn Thanh Linh Đan`, `Đấu Linh Đan`, `Hoàng Cực Đan`, `Phá Tông Đan`, `Sinh Cốt Dung Huyết Đan`, `Bồ Đề Tử`, `Bồ Đề Tâm`, `Đế Phẩm Sồ Đan`).
  * [ ] Cơ chế riêng của Đại Đấu Sư (Khải Giáp), Đấu Linh (Ngưng Vật), Đấu Vương (Hóa Dực bay qua địa hình), Đấu Tông (Không Gian Phong Tỏa), Đấu Tôn (Xé Không Gian), Đấu Thánh (Giới Vực), Viêm Đế (Vạn Hỏa Triều Tông).
  * [ ] Radar Linh Hồn cảm ứng bí bảo/quái ẩn (`radar_radius_px`), giới hạn phẩm luyện đan theo Cảnh Linh Hồn (`alchemy_max_tier`), Hồn Kỹ thực chiến, Nội Thị Kinh Mạch, tỷ lệ Tẩu Hỏa Nhập Ma & Độ Kiếp Thiên Lôi.
* [ ] **Đấu Kỹ & Hiệu Ứng Dị Hỏa Chuyên Sâu**:
  * [ ] Bổ sung 14 Đấu Kỹ còn lại (10/24 → 24/24).
  * [x] Hiện thực hóa **28 hiệu ứng đặc biệt (`lotus_effect`)** trong `data/flames.json` khi dung hợp vào Phật Nộ Hỏa Liên và vẽ vòng màu cho đủ 2–4 ngọn Hỏa ghép.
  * [ ] Độ Thông Thạo Đấu Kỹ (Mastery), thanh Poise/Phá Giáp, Lưu Hỏa dung hợp thường trực, Ma Độc Ban (Ch.07–08), Đế Tộc Văn (Ch.09+), Cải trang Hắc Bào — Nham Kiêu.
* [ ] **Quái Vật & Boss Đa Dạng Hóa**:
  * [ ] Mở rộng AI quái thường từ 3 mẫu lên 8 mẫu GDD (Độn Thổ, Pháo Kích, Kiếm Trận, Tàng Hình, Khiên Trước, Xiềng Xích Hút Hồn, Tự Bạo).
  * [x] Tách kịch bản chiêu thức đặc thù cho từng Boss (12 Boss Ch.01–03 đã có bộ chiêu & địa hình riêng).
  * [ ] Bổ sung 13+ Đại Boss Chương 04–11 (tổng 25 Boss GDD), chế độ tái chiến **Tâm Ma Luyện Cảnh** (3 độ khó + xếp hạng `C → SSS`) và **Đồ Giám Vạn Thú**.
* [ ] **Luyện Đan, Đấu Giá & Trang Bị Sinh Trưởng**:
  * [ ] Mở rộng từ 7 lên 36 đan phương (Phẩm 5–9 + Đế Phẩm), 13 danh đỉnh Thiên Đỉnh Bảng, Đan Lôi thực chiến trên bản đồ, Đan Thú hoang dã.
  * [ ] Nâng Phòng Đấu Giá Nhã Phi thành **Mini-game Đấu Giá tương tác** (trả giá đấu trí, ký gửi bán đan dược dưới thân phận Hắc Bào Tiên Sinh) và chế độ **Đại Hội Luyện Đan**.
  * [ ] Hệ thống **Chế Tạo & Nuôi Dưỡng Yêu Khôi** (Địa Yêu Khôi → Thiên Yêu Khôi → Bắc Vương + 4 lệnh AI), rãnh khảm Ma Hạch lên Huyền Trọng Xích, dung luyện Ma Hạch, 8 mảnh Đà Xá Cổ Đế Ngọc, Tọa Kỵ / Trùng Động.
* [ ] **Hồng Nhan, Đồng Hành & Thế Lực Tự Lập**:
  * [x] Gắn gameplay thực tế cho điểm **Hảo Cảm** 5 Hồng Nhan (4 mốc Buff 25/50/75/100, tặng quà x2 sở thích & nhận Quà Tri Kỷ trong `[M]`).
  * [ ] Nhiệm vụ riêng từng Hồng Nhan, Tuyệt Kỹ Hợp Kích đôi, và chiêu mộ dàn đồng hành sau (Huân Nhi, Vân Vận, Tử Nghiên, Thanh Lân, Hải Ba Đông...).
  * [ ] Hệ thống **Quản Lý Tông Môn Tự Lập** (`Bàn Môn → Viêm Minh → Thiên Phủ Liên Minh`): phái đệ tử thu dược liệu tự động, sảnh luyện đan thụ động, sự kiện phòng thủ Hồn Điện tập kích.
* [ ] **8 Phó Bản Cày Cuốc & Endgame**:
  * [ ] Thiên Phần Luyện Khí Tháp, Đấu Trường Cường Bảng, Thiên Sơn Huyết Đàm, Vạn Dặm Đan Giới (roguelite), Viễn Cổ Di Tích, Thiên Mộ, 17 Bí Cảnh Dị Hỏa Ẩn, Khe Nứt Đại Thiên Thế Giới & `New Game+`.
* [ ] **Đồ Họa, Âm Thanh & Đóng Gói**:
  * [x] Hoàn thiện `anim_sheet` 4 frame cho toàn bộ 12/12 Boss (`tieu_ngoc`, `lieu_tich`, `thach_khoi`, `muc_luc`, `mac_ba_tu`, `co_ha`) & xóa file dư `assets/sprites/player/tieu_viem.png`.
  * [ ] Vẽ animation Idle 4 frame cho Tiêu Viêm; bổ sung BGM riêng cho Sa Mạc / Dung Nham / Thánh Thành / Cảnh chia ly.
  * [ ] Thiết lập cài đặt Đồ họa (Fullscreen/Độ phân giải), đổi phím (Key Rebinding) và cấu hình `export_presets.cfg` để build `.exe`/Web độc lập.

---

## 4. Danh Sách Lỗi & Nợ Kỹ Thuật Cần Sửa Sớm (Bug & Tech Debt Backlog)

| Mã | Mức độ | Vị trí mã nguồn | Mô tả vấn đề & Hướng khắc phục | Trạng thái |
| :--- | :---: | :--- | :--- | :---: |
| **BUG-01** | Cao | `scripts/autoload/audio_manager.gd` & `scripts/autoload/player_data.gd` | **Xung đột ghi đè `user://dptk_settings.json`**: Đã đồng bộ merge JSON an toàn, truyền `save_to_disk=false` khi load và lưu đủ cả `is_muted` + các cờ Auto-Save/Auto-Continue. | [x] Đã sửa (`v0.3.5`) |
| **BUG-02** | Cao | `scripts/autoload/player_data.gd`, `player_controller.gd`, `hud_controller.gd` | **Đan dược Chương 03 không uống được**: Đã thêm fallback thông minh cho phím `[1]`/`[2]` + thanh Uống Đan trực tiếp & nút Gắn `[1]`/`[2]` trong `[L]` và `[I]` cho **Băng Tâm Đan** & **Hạt Thanh Liên Tử**. | [x] Đã sửa (`v0.3.5`) |
| **BUG-03** | Trung bình | `scripts/ui/hud_controller.gd` | **Tràn ngang Xưởng Hỏa Liên `[K]` ở Chế Độ DEMO**: Đã đổi `HBoxContainer` → `HFlowContainer` kèm danh sách `lotus_effect` đang kích hoạt. | [x] Đã sửa (`v0.3.5`) |
| **BUG-04** | Trung bình | `scripts/systems/alchemy_system.gd` & `scripts/ui/hud_controller.gd` | **Thưởng Dị Hỏa & Dược Đỉnh vào Mini-game Luyện Đan**: Đã thêm `AlchemySystem.get_minigame_modifiers()` nối Dị Hỏa + Dược Đỉnh + Hảo Cảm Tiểu Y Tiên + SOUL để mở rộng vùng Đan Tâm, làm dịu tốc độ nguội và tăng thời gian Chắn Đan Lôi. | [x] Đã sửa (`v0.3.5`) |
| **BUG-05** | Thấp | `scripts/systems/world_stage_manager.gd` | Đã bổ sung waypoint cho `q07_dot_pha_dau_gia` và sửa `get_minimap_snapshot()` gọi `_is_portal_unlocked()`. | [x] Đã sửa (`v0.3.5`) |
| **BUG-06** | Thấp | `scripts/entities/player_controller.gd` & `data/realms.json` | Đã đọc động `damage_taken_bonus_per_major_realm` (`0.30`) từ `GameDatabase.suppression_rules`. | [x] Đã sửa (`v0.3.5`) |
| **DOC-01** | Thấp | `01_Art_Spec_Huong_Dan_Ve_Pixel.md`, `player_data.gd`, `world_stage_manager.gd` | Đã cập nhật thông số `1280×720 HD` và comment đầu file chuẩn 11 bản đồ / 21 mốc. | [x] Đã sửa (`v0.3.5`) |
| **OPS-01** | Trung bình | Thư mục gốc dự án | Đã khởi tạo Git (`.git`) và commit mốc nền; còn thiếu `export_presets.cfg` để đóng gói bản phát hành. | [ ] Một phần |

---

## 5. Lộ Trình Triển Khai Theo Mốc (Milestones)

### Mốc M1 — Ổn Định Nền & Dọn Bug (`v0.3.1`) — ✅ HOÀN TẤT
* [x] Khởi tạo Git repository và commit mốc nền `v0.3.0`.
* [x] Sửa trọn bộ `BUG-01` → `BUG-06`, dọn `DOC-01` và xóa file sprite thừa `tieu_viem.png`.
* [x] Kiểm thử tự động bằng Godot headless (`0` lỗi).

### Mốc M2 — Đào Sâu Cơ Chế Chiến Đấu & Hảo Cảm (`v0.3.5`) — ✅ HOÀN TẤT (cốt lõi)
* [x] Lập trình trọn bộ **28 hiệu ứng thực chiến `lotus_effect`** cho Phật Nộ Hỏa Liên `[F]` & vẽ đủ 2–4 vòng màu Hỏa dung hợp.
* [x] Đa dạng hóa chiêu thức & pattern riêng cho **12/12 Boss** (kèm `BossHazardZone`: cột lửa, vũng độc, băng trụ làm chậm, hồ dung nham, bão cát & khiên Boss).
* [x] Hoàn thiện `anim_sheet` 4 frame cho 6 Boss còn lại (**12/12 Boss** đều có hoạt ảnh 4 khung hình).
* [x] Kích hoạt **Hảo Cảm Hồng Nhan** (4 mốc Buff 25/50/75/100, Quà Tri Kỷ & Tặng Quà x2 sở thích) ngay trong `[M]`.
* [ ] *(Tùy chọn bổ sung)* Idle 4 frame Tiêu Viêm, nhạc nền Sa Mạc/Dung Nham & nút Fullscreen trong cài đặt.

### Mốc M3 — Data-Driven Story Engine & Chương 04: Đế Đô & Ước Hẹn 3 Năm (`v0.4.0` — Trọn Quyển I) — ✅ HOÀN TẤT (cốt truyện & gameplay)
* [x] Nâng cấp **Data-Driven Story Engine**: nạp động `maps/quests/dialogues/enemies_chXX.json`, trình chạy hội thoại/nhánh chọn JSON, BFS tìm đường tự động qua toàn bộ đồ thị cổng bản đồ, và lưu tiến độ theo `quest_id` tự động nâng cấp bản lưu cũ.
* [x] Thêm trọn bộ **8 bản đồ Chương 04** (`ch04_mac_gia_trang` → `ch04_rung_phong_toa`), **10 mốc nhiệm vụ chính (NV 22–31)**, **3 nhiệm vụ phụ / kỳ ngộ ẩn** (Mễ Đặc Nhĩ, Thề Máu Tiêu Tộc Nộ Huyết, Mật Thư Lăng Ảnh `Kim Viêm Hộ Hồn Ngọc`) và **Easter Egg Khách Điếm Đế Đô**.
* [x] Thêm cơ chế **Đấu Khí Khải Giáp & Ngoại Phóng** (Đại Đấu Sư), Đấu Kỹ **`Lạc Độc Ám Chưởng`**, đan phương **`Phá Ách Đan` & `Tam Văn Thanh Linh Đan`**, biến cố **Dược Lão ngủ say → `[T]` Đấu Tông Mỹ Đỗ Toa Hộ Pháp**, và **7 Boss độc chiêu** (Mặc Thừa, Mộc Chiến, Viêm Lợi, Nạp Lan Yên Nhiên, Vân Yên Đại Trận, Vân Lăng & Đấu Tông Vân Sơn), mở cổng chờ sang Quyển II (`ch05_unlocked_future`).
* [ ] *(Đợt polish Đồ họa & UI sau)* Vẽ tileset Đế Đô / Vân Lam Sơn và sprite 4-frame riêng cho 7 Boss & NPC mới Chương 04.

### Mốc M4 — Quyển II: Hắc Giác Vực, Già Nam & Tam Thượng Vân Lam (`v0.5.0 – v0.6.0`)
* [ ] Triển khai Chương 05–07, Đấu Kỹ bậc Địa Giai (`Tam Thiên Lôi Động`, `Khai Sơn Ấn`...), cơ chế **Đấu Khí Hóa Dực** (Đấu Vương) & **Ma Độc Ban**.
* [ ] Mở Phó bản 01 (**Thiên Phần Luyện Khí Tháp**), Phó bản 02 (**Đấu Trường Cường Bảng**), Hệ thống Thế Lực cấp 1–2 (**Bàn Môn → Viêm Minh**).
* [ ] Boss Liễu Kình, Vẫn Lạc Tâm Viêm (`#14`), Dược Hoàng Hàn Phong (`#15`), Vân Sơn & Vụ Hộ Pháp, Hạt Tất Nham.

### Mốc M5 — Quyển III: Trung Châu Phong Vân (`v0.7.0 – v0.8.0`)
* [ ] Triển khai Chương 08–09, Hệ thống **Yêu Khôi**, Đấu Tông/Đấu Tôn & Không Gian Phong Tỏa, Đan Lôi thực chiến Phẩm 7–8.
* [ ] Mở Phó bản 03–06 (**Thiên Sơn Huyết Đàm**, **Vạn Dặm Đan Giới**, **Viễn Cổ Di Tích**, **Thiên Mộ**) và `#9 Tam Thiên Diễm Viêm Hỏa`, `#12 Cửu Long Lôi Cương Hỏa`.

### Mốc M6 — Quyển IV: Thánh Đế Quyết Chiến & Phát Hành (`v0.9.0 – v1.0.0`)
* [ ] Triển khai Chương 10–11, **Thiên Phủ Liên Minh**, `#4 Kim Đế Phần Thiên Viêm`, `#3 Tịnh Liên Yêu Hỏa`, `#1 Đế Viêm`, 8 mảnh Cổ Đế Ngọc, **Final Boss Hồn Thiên Đế (3 Phase)**.
* [ ] Hoàn thiện 17 Bí Cảnh Dị Hỏa Ẩn, **Tâm Ma Luyện Cảnh**, **Khe Nứt Đại Thiên Thế Giới**, `New Game+` và đóng gói bản phát hành (`export_presets.cfg`).

---

## 6. Nhật Ký Cập Nhật Tiến Độ (Progress Log)

| Ngày | Phiên bản | Nội dung đã hoàn tất |
| :--- | :---: | :--- |
| *Trước 24/11/2026* | `v0.1 – v0.2` | Hoàn thiện trọn bộ 24 tài liệu GDD; dựng nền Godot 4 HD `1280×720`, Chương 01–02 (7 map), trang bị 10 ô, luyện đan mini-game, âm thanh procedural. |
| *Trước 24/11/2026* | `v0.3.0` | Mở rộng trọn vẹn **Chương 03 — Sa Mạc Tháp Qua Nhĩ** (tổng 11 map, 21 mốc NV, 20 quái/Boss, 6 `anim_sheet` Boss, Thần Thú Thải Lân, Phật Nộ Hỏa Liên `[F]`), bổ sung **Chế Độ DEMO** và **Auto-Save / Auto-Continue**. |
| **24/11/2026** | `v0.3.0` | Rà soát toàn bộ mã nguồn (`9.333` dòng GDScript) đối chiếu GDD; khởi tạo tài liệu theo dõi tiến độ & danh sách lỗi (`BUG-01` → `OPS-01`) này. |
| **24/11/2026** | `v0.3.5` | Hoàn tất **Mốc M1 & M2**: Khởi tạo Git, sửa `BUG-01`→`BUG-06`, hiện thực hóa trọn bộ **28 hiệu ứng `lotus_effect`**, mở khóa **Buff & Tặng Quà Hồng Nhan**, xây dựng **12 bộ chiêu thức Boss riêng + `BossHazardZone`**, và hoàn thiện **6 `anim_sheet` 4 frame còn lại** (`12/12` Boss). Đã kiểm thử Godot headless `0` lỗi. |
| **24/11/2026** | `v0.4.0` | Hoàn tất **Data-Driven Story Engine & Mốc M3 (Chương 04 — Trọn Quyển I)**: Nạp động file JSON từng chương, hội thoại/nhánh chọn JSON, BFS tìm đường đa bản đồ, lưu nhiệm vụ theo `quest_id` tự động tương thích bản lưu cũ; xây dựng **8 bản đồ mới (tổng 19)**, **10 NV chính (NV 22–31)**, 3 tuyến phụ + Easter Egg, **7 Boss độc chiêu (tổng 19)**, Đấu Khí Khải Giáp & Ngoại Phóng, `Lạc Độc Ám Chưởng`, `[T]` Mỹ Đỗ Toa Đấu Tông và hồi sinh `Kim Viêm Hộ Hồn Ngọc`. Đã kiểm thử tự động toàn luồng Ch.01–04 trên Godot headless (`0` lỗi). |
