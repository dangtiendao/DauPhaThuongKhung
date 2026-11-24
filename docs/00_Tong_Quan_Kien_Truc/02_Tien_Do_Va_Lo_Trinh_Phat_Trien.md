# TIẾN ĐỘ DỰ ÁN & LỘ TRÌNH PHÁT TRIỂN (PROJECT PROGRESS & ROADMAP)

> **Dự án**: Đấu Phá Thương Khung — Top-down 2D HD Pixel Action RPG (Godot Engine 4)
> **Cập nhật lần cuối**: 24/11/2026
> **Phiên bản hiện tại**: **v0.5.0 (Mở Màn Quyển II: Chương 05 Hắc Giác Vực & Ngoại Viện Già Nam — 25 Bản Đồ, 39 NV Chính, 15 Đấu Kỹ, 43 Quái/23 Boss, Khảm Ma Hạch 3 Rãnh, Thiên Phần Luyện Khí Tháp Roguelite, Đấu Giá Đấu Trí & Ký Gửi, Radar Linh Hồn `[Z]`, Đổi Phím Tùy Chỉnh)**
> **Mục đích**: Theo dõi đối chiếu giữa **Hồ sơ thiết kế (GDD — 11 Chương)** và **Trạng thái thực thi trong mã nguồn**, quản lý backlog lỗi kỹ thuật và lộ trình phát triển các mốc tiếp theo.

---

## 1. Bức Tranh Tổng Quan Hiện Tại (Snapshot)

| Hạng mục | Đã hoàn thiện trong game | Mục tiêu GDD | Tỷ lệ / Ghi chú |
| :--- | :---: | :---: | :--- |
| **Tài liệu Thiết kế (GDD)** | 25 file + 2 concept art | 25 file | **100%** — Đã viết trọn 11 Chương, hệ thống & roadmap tiến độ |
| **Cốt truyện chơi được** | **5 Chương — Quyển I + Mở Quyển II** (NV 1–39 + tuyến phụ + Hắc Giác Vực & Già Nam) | 11 Chương (4 Quyển) | **45%** — Xong Ch.01–Ch.04 & **Ch.05 (Hắc Giác Vực & Ngoại Viện Già Nam)** |
| **Bản đồ liên thông** | **25 bản đồ** (BFS tìm đường toàn cục) | Toàn Đấu Khí Đại Lục | Ch.01 (3), Ch.02 (4), Ch.03 (4), Ch.04 (8), **Ch.05 (6)** |
| **Đấu Kỹ chủ động** | **15 chiêu** (`skills.json`) | 24 chiêu | **63%** — Đã thêm `Tam Thiên Lôi Động`, `Sư Hổ Toái Kim Ngâm`, `Đế Ấn Quyết — Khai Sơn Ấn`, `Hỏa Liên Phân Thân` |
| **Dị Hỏa & Thú Hỏa** | **28/28** dữ liệu & **28/28 `lotus_effect`** · **3/28** thu phục cốt truyện · **3/4 Mảnh Tàn Đồ Yêu Hỏa** | 28 ngọn Hỏa | Cả 28 hiệu ứng đặc biệt Hỏa Liên hoạt động; thêm Mảnh Tàn Đồ #3 tại Hắc Ấn Thành |
| **Cảnh giới & Đột phá** | **12/12** dữ liệu · Đột phá cốt truyện tới **Đấu Linh 6 Tinh** | 12 Đại Cảnh Giới | Đã có Sa Y (Đấu Sư), Khải Giáp (Đại Đấu Sư), **Đấu Khí Ngưng Vật (Đấu Linh)** & **Radar Linh Hồn `[Z]`** |
| **Quái & Boss** | **43** (20 quái — **7 mẫu AI** + **23/23 Boss độc chiêu**) | 25+ Đại Boss | Đã mở rộng 4 AI mới (`burrower`, `artillery`, `shieldbearer`, `bomber`) & 4 Boss Ch.05 (Vân Phàn → La Hầu) |
| **Luyện Đan & Đấu Giá** | **26** vật phẩm · **12** đan phương (Phẩm 1–7) · **Đấu Giá Đấu Trí + Ký Gửi** | 36 đan phương · 13 Thiên Đỉnh | Đã thêm `Huyết Ngưng Đan`, `Đấu Linh Đan`, `Âm Dương Huyền Long Đan` & Mini-game Đấu Giá + Ký Gửi |
| **Trang Bị 10 Ô & Ma Hạch** | **31** mẫu · **5** bộ Set · **Khảm Ma Hạch 3 Rãnh** (+0→+15) | Trang bị + Yêu Khôi + Khảm Hạch | Đã thêm Bộ Già Nam Tân Sinh Vương, `Song Long Huyết Đỉnh` & **Khảm Ma Hạch Cấp 1–5** lên Vũ Khí |
| **Đồng Hành AI & Hồng Nhan** | **4** Đồng hành `[G]` (**+Tiêu Huân Nhi**) · **`[T]` Dược Lão → Mỹ Đỗ Toa Đấu Tông** · **5 Hồng Nhan** | 17 Đồng hành & Khách khanh | Đã mở khóa Đồng Hành #4 **Tiêu Huân Nhi** (Kim Đế Phần Thiên Viêm + hồi Đấu Khí) |
| **Thế Lực & Phó Bản Endgame** | **2 / 8** Chế độ Endgame (**Tâm Ma Luyện Cảnh 23 Boss** + **Thiên Phần Luyện Khí Tháp Roguelite**) | 8 Phó bản + Bàn Môn → Thiên Phủ | Leo tầng vô tận, Tâm Hỏa chước đốt, chọn 1/3 Chúc Phúc, đổi Tinh Hỏa Năng + Đồ Giám 43 loài |
| **Đồ Họa, VFX & Âm Thanh** | **60–144 FPS Physics Interpolation** · **22 script** · **16 JSON** · **7 BGM Ngũ Cung** · **Key Rebinding** · `export_presets.cfg` | — | Bộ sprite Tiêu Viêm mới, VFX additive 60 FPS toàn bộ 15 Đấu Kỹ & 23 Boss, Thời tiết vùng, Đổi phím tùy chỉnh & Build Windows `.exe` |

---

## 2. Tiến Độ Cốt Truyện Theo 11 Chương (4 Quyển)

| Quyển | Chương | Trạng thái | Hiện trạng thực tế & Phần còn thiếu |
| :--- | :--- | :---: | :--- |
| **Quyển I**<br>*Gia Mã Đế Quốc* | **Ch.01**: Ô Thản Thành | ✅ Hoàn tất | 3 map, NV 1–9, Từ Hôn, Dược Lão, Nhã Phi, Tiêu Ngọc, Tiêu Ninh, Nhược Lâm, Lăng Ảnh, Liễu Tịch, Gia Liệt Áo, Huyền Trọng Xích. *(GDD nâng cao chưa làm: đấu giá đấu trí, ngâm bồn gỗ mini-game, né thước 30 ngày, stealth ám sát).* |
| **Quyển I** | **Ch.02**: Ma Thú Sơn Mạch | ✅ Hoàn tất | 4 map, NV 10–15, Tiểu Y Tiên, 3 Thạch Thất (Tử Vân Dực, Tàn Đồ 1/4, Sư Tử Ngâm), Vân Chi, Tiểu Tử Tinh Sư Vương & Tử Hỏa, Mục Lực, Mục Xà, Chia ly Thung Lũng U Lan. |
| **Quyển I** | **Ch.03**: Sa Mạc Tháp Qua Nhĩ | ✅ Hoàn tất | 4 map, NV 16–21, Tiêu Đỉnh/Tiêu Lệ, Hải Ba Đông (Tàn Đồ 2/4), Thanh Lân, Địa Huyệt Dung Nham (Song Đầu Hỏa Linh Xà, Thanh Liên Đài), Mặc Ba Tư, Cổ Hà, Vân Vận, Mỹ Đỗ Toa độ kiếp, Thôn phệ `#19 Thanh Liên Địa Tâm Hỏa`, Thải Lân & Phật Nộ Hỏa Liên `[F]`. |
| **Quyển I** | **Ch.04**: Đế Đô & Ước Hẹn 3 Năm | ✅ Hoàn tất | 8 map (Diêm Thành Mặc Gia Trang, Gia Mã Thánh Thành, Nạp Lan Vương Phủ, Quảng Trường Đan Hội, Thiên Thang 999 Bậc, Đỉnh Vân Lam Sơn, Phế Tích Tiêu Gia, Rừng Phong Tỏa & Trấn Quỷ Quan), NV 22–31, 3 tuyến phụ + Easter Egg Mỹ Đỗ Toa, 7 Boss độc chiêu (Mặc Thừa → Nạp Lan Yên Nhiên → Vân Lăng → Đấu Tông Vân Sơn), Đấu Khí Khải Giáp & Ngoại Phóng, `Lạc Độc Ám Chưởng`, `[T]` Mỹ Đỗ Toa Đấu Tông, hồi sinh `Kim Viêm Hộ Hồn Ngọc`. *(Ghi chú: đồ họa map/Boss Ch.04 tạm tái sử dụng tileset/sprite sẵn có để hoàn thiện art & UI ở đợt polish sau).* |
| **Quyển II**<br>*Hắc Giác Vực & Già Nam* | **Ch.05**: Hắc Giác Vực & Ngoại Viện | ✅ Hoàn tất | 6 map (`ch05_hem_nui_hac_phong` → `ch05_rung_san_hoa_nang`), NV 32–39, 4 Boss (Vân Phàn, Phạm Lăng, Ngô Hạo, La Hầu), 4 Đấu Kỹ mới (`Tam Thiên Lôi Động`, `Sư Hổ Toái Kim Ngâm`, `Đế Ấn Quyết`, `Hỏa Liên Phân Thân`), Đồng hành #4 **Tiêu Huân Nhi**, Đấu Giá Bát Phiến Môn, Mảnh Tàn Đồ #3 & Săn Hỏa Năng 240 điểm. |
| **Quyển II** | **Ch.06**: Nội Viện & Thiên Phần Tháp | ⏳ Chưa làm | Bàn Môn, Tử Nghiên, Đấu Trường Cường Bảng (Boss Liễu Kình), Đáy Tháp Thiên Phần (Boss Vẫn Lạc Tâm Viêm `#14`, Hàn Phong). |
| **Quyển II** | **Ch.07**: Tam Thượng Vân Lam & Độc Tông | ⏳ Chưa làm | Boss Vân Sơn & Vụ Hộ Pháp (Dược Lão bị bắt), lập Viêm Minh, `#15 Hải Tâm Diễm`, Xuất Vân Độc Tông (Boss Hạt Tất Nham, Ma Độc Ban). |
| **Quyển III**<br>*Trung Châu Phong Vân* | **Ch.08**: Bắc Vực & Đan Hội Trung Châu | ⏳ Chưa làm | Thiên Sơn Huyết Đàm, Phần Viêm Cốc (`#12`), Tứ Phương Các (Phượng Thanh Nhi), Diệp Thành (Băng Hà Cốc), Đan Hội Trung Châu & `#9 Tam Thiên Diễm Viêm Hỏa`. |
| **Quyển III** | **Ch.09**: Cứu Sư Vong Hồn & Thiên Mộ | ⏳ Chưa làm | Đánh Vong Hồn Điện cứu Dược Lão (Trích Tinh Lão Quỷ), Hoa Tông, Viễn Cổ Di Tích, Thiên Mộ Tam Tầng, Đế Tộc Văn. |
| **Quyển IV**<br>*Thánh Đế Quyết Chiến* | **Ch.10**: Bồ Đề Hóa Thánh & Tịnh Liên | ⏳ Chưa làm | Bồ Đề Cổ Thụ, Thiên Phủ Liên Minh, `#4 Kim Đế Phần Thiên Viêm`, Yêu Hỏa Không Gian (4/4 Mảnh Tàn Đồ → `#3 Tịnh Liên Yêu Hỏa`). |
| **Quyển IV** | **Ch.11**: Cổ Đế Động Phủ & Song Đế Chiến | ⏳ Chưa làm | Cứu Tiêu Chiến, Dược Giới (`#5`, `#10`, `#22`), Cổ Đế Động Phủ (8 mảnh Cổ Đế Ngọc, Đế Phẩm Sồ Đan, `#1 Đế Viêm`), **Final Boss Hồn Thiên Đế (3 Phase)** & Endgame Đại Thiên Thế Giới. |

---

## 3. Ma Trận Tiến Độ Từng Hệ Thống (GDD vs. Đã Code)

### 3.1. Những Việc ĐÃ LÀM (Core Đã Chạy Ổn Định — `v0.5.0`)
* [x] **Kiến trúc dữ liệu & Autoload**: `EventBus`, `AudioManager`, `GameDatabase`, `PlayerData` nạp động **16 file JSON** trong `data/` (Data-Driven Story Engine hỗ trợ mở rộng `ch02..ch11`, hội thoại phân nhánh JSON, BFS tìm đường đa bản đồ qua **25 bản đồ** & **39 NV chính**).
* [x] **Hệ thống Điều Khiển & Chiến Đấu (60–144 FPS)** (`scripts/entities/player_controller.gd`):
  * [x] Di chuyển 8 hướng (2D Physics Interpolation, Foot-Anchored Pivot, Input Buffer `0.14s`, Hitstop toàn cục, Camera Look-Ahead), đánh thường combo 3 nhịp kèm 4 bộ attack sprite sheet liền thân (Tay Không / Kiếm / Đao / Huyền Trọng Xích).
  * [x] Lướt né `[Space]` có I-frame & tàn ảnh (tiến hóa tự động: Lướt thường → **Lướt Tử Vân Dực** → **Tam Thiên Lôi Động**).
  * [x] Phong ấn / Giải phong Huyền Trọng Xích `[RMB / C]` (`-15% SPD`, `+30% EXP`).
  * [x] Cơ chế đặc thù 3 bậc đầu: **Đấu Khí Sa Y** (Đấu Sư `+18% DEF`), **Đấu Khí Khải Giáp & Kiếm Khí Ngoại Phóng** (Đại Đấu Sư `+32% DEF`), **Đấu Khí Ngưng Vật** (Đấu Linh `+42% DEF`, `+15%` lực phá thế, `1.20×` tầm đánh).
  * [x] **15 Đấu Kỹ** hoạt động đầy đủ (`Q/E/R/F`) kèm **Độ Thông Thạo (`Sơ Khuy → Đỉnh Phong`)**, bộ VFX additive 60 FPS (`SkillVfxBurst`, `VfxAssets`) & **`[T]` Cốt Linh Phụ Thể → Đấu Tông Mỹ Đỗ Toa Hộ Pháp**.
  * [x] Đèn động `PointLight2D`, Thời tiết động theo vùng (bão cát, tàn lửa, mây mù, đom đóm), screen shake tùy chỉnh, chữ Crit nảy parabol.
* [x] **Cảnh Giới, Linh Hồn & Dị Hỏa**:
  * [x] Khai báo đủ 12 Đại Cảnh Giới, 4 Cảnh Linh Hồn và công thức Áp Chế / Xuyên Áp Chế (`data/realms.json`), kèm **Radar Linh Hồn `[Z]`** cảm ứng rương ẩn & lộ hình kẻ địch.
  * [x] Khai báo đủ **28/28 loại Hỏa** (`data/flames.json`) + Shader lửa động 3 tầng màu (`assets/shaders/di_hoa_palette.gdshader`) + trọn bộ **28/28 `lotus_effect`** khi dung hợp 2–4 Hỏa cho `[F] Phật Nộ Hỏa Liên`.
* [x] **Trang Bị 10 Ô, Ma Hạch & Loot** (`scripts/systems/equipment_system.gd`, `scripts/entities/loot_pickup.gd`):
  * [x] 10 ô mặc đồ, **31 mẫu trang bị**, 6 phẩm chất (Phàm → Đế), **5 bộ Set**, 8 dòng affix ngẫu nhiên, cường hóa `+0 → +15`, phân giải hàng loạt và **Khảm Ma Hạch 3 Rãnh (Cấp 1–5)** lên Vũ Khí trong `[I]`.
* [x] **Lò Luyện Đan `[L]` & Đấu Giá Đấu Trí + Ký Gửi** (`scripts/systems/alchemy_system.gd`, `scripts/systems/auction_system.gd`):
  * [x] **26 vật phẩm** & **12 đan phương (Phẩm 1–7)**, Mini-game canh Hỏa Hầu `[Space]` + Chắn Đan Lôi `[E]` có cộng thưởng trực tiếp từ Dị Hỏa, Dược Đỉnh, Linh Hồn & Hảo Cảm Tiểu Y Tiên; **áp dụng ràng buộc giới hạn phẩm luyện đan theo Cảnh Linh Hồn (`alchemy_max_tier`)**.
  * [x] **Mini-game Đấu Giá Đấu Trí & Ký Gửi** (`AuctionSystem`) tại 2 đấu trường (Mễ Đặc Nhĩ & Bát Phiến Môn) kèm Thăm Dò Linh Hồn & Uy Áp Linh Hồn.
* [x] **Kiến Trúc Mô-Đun & Kiểm Thử Tự Động (`P1`)**:
  * [x] Tách `SaveLoadManager` khỏi `player_data.gd`; tách `BossRushManager`, `ThienPhanTowerManager` & `StoryDialogueRunner` khỏi `world_stage_manager.gd`; tách 6 panel UI lớn (`panel_alchemy`, `panel_auction`, `panel_equipment`, `panel_world_map_bestiary`, `panel_tower_boss_rush`, `panel_pause_settings`) vào `scripts/ui/panels/`.
  * [x] Bộ kiểm thử tự động Godot headless `tests/` (`tests/test_runner.tscn`, `tests/test_suite.gd`, `tests/run_tests.bat`) — **512 assertions** kiểm tra JSON schema, asset `res://`, BFS liên thông 25 bản đồ, `alchemy_max_tier`, Save/Load, DEMO & live scene.
* [x] **Quái, Boss, Đồng Hành, Hồng Nhan & Endgame**:
  * [x] **43 kẻ địch** (20 quái thường với **7 mẫu AI**: `chaser`, `charger`, `artillery`, `burrower`, `bomber`, `shieldbearer`, `dummy` + **23/23 Boss** có bộ chiêu thức riêng, Phase 2, **Thanh Phá Thế Poise/Stagger**, `BossHazardZone` & `EnemyProjectile` VFX 60 FPS).
  * [x] **4 Đồng Hành AI `[G]`** (Dược Lão, Tiểu Y Tiên, Thải Lân, **Tiêu Huân Nhi**) + **5 Hồng Nhan Tri Kỷ** trong `[M]` (4 mốc Buff 25/50/75/100, Quà Tri Kỷ & Tặng Quà x2 sở thích).
  * [x] **2 Chế độ Endgame & Đồ Giám** trong `[M]`: **Tâm Ma Luyện Cảnh** (23 Boss × 3 độ khó, xếp hạng `C → SSS`), **Thiên Phần Luyện Khí Tháp Roguelite** (leo tầng vô tận, Tâm Hỏa, chọn 1/3 Chúc Phúc, Tinh Hỏa Năng) & **Đồ Giám Vạn Thú (43 loài)**.
* [x] **Giao Diện MOBA, Save/Load, DEMO, Âm Thanh & Đóng Gói**:
  * [x] HUD MOBA bấm chuột trực tiếp + quét hồi chiêu + Tooltip + Live Mini-Map + Bản Đồ Thế Giới `[M]` (25 map).
  * [x] Màn hình chính + Lưu/Tải 3 Ô Nạp Giới (nhớ tọa độ `(x, y)`) + Auto-Save + Auto-Continue + **Chế Độ DEMO** (Ô 3, mở khóa trọn 25 map Ch.01–05, Đấu Linh 9 Tinh, 15 Kỹ, 28 Hỏa, 4 Đồng Hành, 3 Ma Hạch).
  * [x] **Đổi Phím Tùy Chỉnh (Key Rebinding)** + **Cài đặt Hiển thị** (`Fullscreen`, `VSync`, `Hiện FPS`, `Shake Scale`) trong `[ESC]`, **7 BGM ngũ cung Procedural** + 21+ SFX, `tools/normalize_spritesheet.py` và cấu hình đóng gói Windows `export_presets.cfg` + `icon.ico`.

### 3.2. Những Hệ Thống GDD CHƯA LÀM Hoặc Mới Làm Một Phần
* [ ] **Cảnh Giới & Linh Hồn nâng cao**:
  * [ ] Bổ sung đan dược & công thức đột phá từ Đấu Vương → Đấu Đế (`Hoàng Cực Đan`, `Phá Tông Đan`, `Sinh Cốt Dung Huyết Đan`, `Bồ Đề Tử`, `Bồ Đề Tâm`, `Đế Phẩm Sồ Đan`).
  * [ ] Cơ chế riêng từ bậc 6 trở lên: **Đấu Vương** (Hóa Dực bay qua địa hình), **Đấu Tông** (Không Gian Phong Tỏa), **Đấu Tôn** (Xé Không Gian), **Đấu Thánh** (Giới Vực), **Viêm Đế** (Vạn Hỏa Triều Tông).
  * [ ] Hồn Kỹ thực chiến, Nội Thị Kinh Mạch, tỷ lệ Tẩu Hỏa Nhập Ma & Độ Kiếp Thiên Lôi.
* [ ] **Đấu Kỹ & Hiệu Ứng Dị Hỏa Chuyên Sâu**:
  * [ ] Bổ sung **9 Đấu Kỹ** còn lại (`15/24 → 24/24`, nhóm Địa/Thiên Giai & Đế Kỹ).
  * [ ] Lưu Hỏa dung hợp thường trực, Ma Độc Ban (Ch.07–08), Đế Tộc Văn (Ch.09+), Cải trang Hắc Bào — Nham Kiêu.
* [ ] **Quái Vật & Boss Đa Dạng Hóa**:
  * [ ] Bổ sung mẫu AI nâng cao cho Ch.06–11 (Tàng Hình, Kiếm Trận, Xiềng Xích Hút Hồn) và dàn Đại Boss Chương 06–11 (Liễu Kình, Vẫn Lạc Tâm Viêm, Hàn Phong, Vân Sơn & Vụ Hộ Pháp, Hạt Tất Nham, Trích Tinh Lão Quỷ → Hồn Thiên Đế 3 Phase).
* [ ] **Luyện Đan & Trang Bị Sinh Trưởng (Mid/Endgame)**:
  * [ ] Mở rộng từ **12 lên 36 đan phương** (Phẩm 6–9 + Đế Phẩm), 13 danh đỉnh Thiên Đỉnh Bảng, Đan Lôi thực chiến trên bản đồ, Đan Thú hoang dã và chế độ Đại Hội Luyện Đan mở rộng.
  * [ ] Hệ thống **Chế Tạo & Nuôi Dưỡng Yêu Khôi** (Địa Yêu Khôi → Thiên Yêu Khôi → Bắc Vương + 4 lệnh AI), dung luyện Ma Hạch nâng cấp, 8 mảnh Đà Xá Cổ Đế Ngọc, Tọa Kỵ / Trùng Động.
* [ ] **Hồng Nhan, Đồng Hành & Thế Lực Tự Lập**:
  * [ ] Nhiệm vụ riêng từng Hồng Nhan, Tuyệt Kỹ Hợp Kích đôi, và chiêu mộ dàn đồng hành giai đoạn sau (Vân Vận, Tử Nghiên, Thanh Lân, Hải Ba Đông...).
  * [ ] Hệ thống **Quản Lý Tông Môn Tự Lập** (`Bàn Môn → Viêm Minh → Thiên Phủ Liên Minh`): phái đệ tử thu dược liệu tự động, sảnh luyện đan thụ động, sự kiện phòng thủ Hồn Điện tập kích.
* [ ] **6/8 Phó Bản Cày Cuốc & Endgame Còn Lại**:
  * [ ] Đấu Trường Cường Bảng, Thiên Sơn Huyết Đàm, Vạn Dặm Đan Giới (roguelite), Viễn Cổ Di Tích, Thiên Mộ, 17 Bí Cảnh Dị Hỏa Ẩn, Khe Nứt Đại Thiên Thế Giới & `New Game+`.
* [ ] **Đồ Họa (Bù Nợ Art Ch.04–05)**:
  * [ ] Vẽ **5 icon riêng** cho 5 Đấu Kỹ mới, **tileset riêng** cho Đế Đô / Vân Lam Sơn / Hắc Giác Vực / Già Nam, **sprite 4-frame riêng** cho 11 Boss & NPC mới Ch.04–05 (hiện đang tái sử dụng sprite cũ), và nâng cấp combo Huyền Trọng Xích 12 frame.

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
| **OPS-01** | Trung bình | Thư mục gốc dự án | Đã khởi tạo Git (`.git`) và tạo sẵn cấu hình phát hành Windows `export_presets.cfg` (x64, `gl_compatibility`). | [x] Đã hoàn tất (`v0.4.5`) |

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
* [x] *(Bổ sung hoàn tất ở `v0.4.1–v0.4.5`)* Idle 4 frame Tiêu Viêm, nhạc nền Sa Mạc/Dung Nham/Đế Đô/Vân Lam Sơn & cài đặt Fullscreen/VSync/FPS.

### Mốc M3 — Data-Driven Story Engine & Chương 04: Đế Đô & Ước Hẹn 3 Năm (`v0.4.0` — Trọn Quyển I) — ✅ HOÀN TẤT (cốt truyện & gameplay)
* [x] Nâng cấp **Data-Driven Story Engine**: nạp động `maps/quests/dialogues/enemies_chXX.json`, trình chạy hội thoại/nhánh chọn JSON, BFS tìm đường tự động qua toàn bộ đồ thị cổng bản đồ, và lưu tiến độ theo `quest_id` tự động nâng cấp bản lưu cũ.
* [x] Thêm trọn bộ **8 bản đồ Chương 04** (`ch04_mac_gia_trang` → `ch04_rung_phong_toa`), **10 mốc nhiệm vụ chính (NV 22–31)**, **3 nhiệm vụ phụ / kỳ ngộ ẩn** (Mễ Đặc Nhĩ, Thề Máu Tiêu Tộc Nộ Huyết, Mật Thư Lăng Ảnh `Kim Viêm Hộ Hồn Ngọc`) và **Easter Egg Khách Điếm Đế Đô**.
* [x] Thêm cơ chế **Đấu Khí Khải Giáp & Ngoại Phóng** (Đại Đấu Sư), Đấu Kỹ **`Lạc Độc Ám Chưởng`**, đan phương **`Phá Ách Đan` & `Tam Văn Thanh Linh Đan`**, biến cố **Dược Lão ngủ say → `[T]` Đấu Tông Mỹ Đỗ Toa Hộ Pháp**, và **7 Boss độc chiêu** (Mặc Thừa, Mộc Chiến, Viêm Lợi, Nạp Lan Yên Nhiên, Vân Yên Đại Trận, Vân Lăng & Đấu Tông Vân Sơn), mở cổng chờ sang Quyển II (`ch05_unlocked_future`).
* [ ] *(Đợt polish Đồ họa & UI sau)* Vẽ tileset Đế Đô / Vân Lam Sơn và sprite 4-frame riêng cho 7 Boss & NPC mới Chương 04.

### Mốc M4 — Quyển II: Hắc Giác Vực, Già Nam & Tam Thượng Vân Lam (`v0.5.0 – v0.6.0`) — 🔄 ĐANG TRIỂN KHAI (1/3 Chương)
* [x] **Chương 05 (`v0.5.0`)**: 6 bản đồ Hắc Giác Vực & Ngoại Viện Già Nam, NV 32–39, 4 Boss (Vân Phàn, Phạm Lăng, Ngô Hạo, La Hầu), 4 Đấu Kỹ bậc Địa/Thiên Giai (`Tam Thiên Lôi Động`, `Sư Hổ Toái Kim Ngâm`, `Đế Ấn Quyết`, `Hỏa Liên Phân Thân`), Đồng hành #4 **Tiêu Huân Nhi**, cơ chế **Đấu Linh (Đấu Khí Ngưng Vật)**, Khảm Ma Hạch 3 Rãnh, Đấu Giá Đấu Trí & Ký Gửi, Radar Linh Hồn `[Z]`, Đổi Phím Tùy Chỉnh và Phó bản 01 (**Thiên Phần Luyện Khí Tháp Roguelite**).
* [ ] **Chương 06 (`v0.5.5`)**: Nội Viện Già Nam, Đồng hành **Tử Nghiên**, Phó bản 02 (**Đấu Trường Cường Bảng**), Hệ thống Thế Lực cấp 1 (**Bàn Môn**), Boss **Liễu Kình**, **Vẫn Lạc Tâm Viêm (`#14`)** & **Dược Hoàng Hàn Phong**.
* [ ] **Chương 07 (`v0.6.0`)**: Tam Thượng Vân Lam & Xuất Vân Độc Tông, cơ chế **Đấu Khí Hóa Dực** (Đấu Vương) & **Ma Độc Ban**, Thế Lực cấp 2 (**Viêm Minh**), Boss **Vân Sơn & Vụ Hộ Pháp**, **Hạt Tất Nham**, thu phục `#15 Hải Tâm Diễm`.

### Mốc M5 — Quyển III: Trung Châu Phong Vân (`v0.7.0 – v0.8.0`)
* [ ] Triển khai Chương 08–09, Hệ thống **Yêu Khôi**, Đấu Tông/Đấu Tôn & Không Gian Phong Tỏa, Đan Lôi thực chiến Phẩm 7–8.
* [ ] Mở Phó bản 03–06 (**Thiên Sơn Huyết Đàm**, **Vạn Dặm Đan Giới**, **Viễn Cổ Di Tích**, **Thiên Mộ**) và `#9 Tam Thiên Diễm Viêm Hỏa`, `#12 Cửu Long Lôi Cương Hỏa`.

### Mốc M6 — Quyển IV: Thánh Đế Quyết Chiến & Phát Hành (`v0.9.0 – v1.0.0`)
* [ ] Triển khai Chương 10–11, **Thiên Phủ Liên Minh**, `#4 Kim Đế Phần Thiên Viêm`, `#3 Tịnh Liên Yêu Hỏa`, `#1 Đế Viêm`, 8 mảnh Cổ Đế Ngọc, **Final Boss Hồn Thiên Đế (3 Phase)**.
* [ ] Hoàn thiện 17 Bí Cảnh Dị Hỏa Ẩn, mở rộng **Tâm Ma Luyện Cảnh** (trọn 25+ Boss), **Khe Nứt Đại Thiên Thế Giới**, `New Game+` và phát hành bản build chính thức (`v1.0.0`).

---

## 6. Nhật Ký Cập Nhật Tiến Độ (Progress Log)

| Ngày | Phiên bản | Nội dung đã hoàn tất |
| :--- | :---: | :--- |
| *Trước 24/11/2026* | `v0.1 – v0.2` | Hoàn thiện trọn bộ 24 tài liệu GDD; dựng nền Godot 4 HD `1280×720`, Chương 01–02 (7 map), trang bị 10 ô, luyện đan mini-game, âm thanh procedural. |
| *Trước 24/11/2026* | `v0.3.0` | Mở rộng trọn vẹn **Chương 03 — Sa Mạc Tháp Qua Nhĩ** (tổng 11 map, 21 mốc NV, 20 quái/Boss, 6 `anim_sheet` Boss, Thần Thú Thải Lân, Phật Nộ Hỏa Liên `[F]`), bổ sung **Chế Độ DEMO** và **Auto-Save / Auto-Continue**. |
| **24/11/2026** | `v0.3.0` | Rà soát toàn bộ mã nguồn (`9.333` dòng GDScript) đối chiếu GDD; khởi tạo tài liệu theo dõi tiến độ & danh sách lỗi (`BUG-01` → `OPS-01`) này. |
| **24/11/2026** | `v0.3.5` | Hoàn tất **Mốc M1 & M2**: Khởi tạo Git, sửa `BUG-01`→`BUG-06`, hiện thực hóa trọn bộ **28 hiệu ứng `lotus_effect`**, mở khóa **Buff & Tặng Quà Hồng Nhan**, xây dựng **12 bộ chiêu thức Boss riêng + `BossHazardZone`**, và hoàn thiện **6 `anim_sheet` 4 frame còn lại** (`12/12` Boss). Đã kiểm thử Godot headless `0` lỗi. |
| **24/11/2026** | `v0.4.0` | Hoàn tất **Data-Driven Story Engine & Mốc M3 (Chương 04 — Trọn Quyển I)**: Nạp động file JSON từng chương, hội thoại/nhánh chọn JSON, BFS tìm đường đa bản đồ, lưu nhiệm vụ theo `quest_id` tự động tương thích bản lưu cũ; xây dựng **8 bản đồ mới (tổng 19)**, **10 NV chính (NV 22–31)**, 3 tuyến phụ + Easter Egg, **7 Boss độc chiêu (tổng 19)**, Đấu Khí Khải Giáp & Ngoại Phóng, `Lạc Độc Ám Chưởng`, `[T]` Mỹ Đỗ Toa Đấu Tông và hồi sinh `Kim Viêm Hộ Hồn Ngọc`. Đã kiểm thử tự động toàn luồng Ch.01–04 trên Godot headless (`0` lỗi). |
| **24/11/2026** | `v0.4.1` | **Siêu Tối Ưu Chuyển Động & Đồ Họa 60–144 FPS + Bộ Sprite Tiêu Viêm Mới**: Bật 2D Physics Interpolation, cắt bão HUD 60Hz, Foot-Anchored Pivot, bỏ khe giật combo 40ms, Input Buffer `0.14s`, Hitstop toàn cục; bổ sung `SpriteAnimHelper` (hỗ trợ strip/grid `4/6/8/12/16` frame), `VfxAssets` (particle mềm `BLEND_MODE_ADD`), `SkillVfxBurst` (14 bộ hiệu ứng 60 FPS riêng cho toàn bộ Đấu Kỹ), shader lửa động `di_hoa_palette.gdshader`; xây dựng `tools/normalize_spritesheet.py` và nâng cấp đồng bộ sprite Tiêu Viêm (`idle 4f`, `run 8f 4×2`, `cast 4f`, `dash 4f`). |
| **24/11/2026** | `v0.4.5` | **Đột Phá Boss VFX, Combat Sâu & Nội Dung Endgame**: Nâng cấp VFX 60 FPS cho toàn bộ `EnemyProjectile` (4 style + vệt đuôi mượt) & `BossHazardZone` (3 mode + rune telegraph); thêm **Thời tiết động theo vùng** (bão cát, tàn lửa dung nham, mây mù Vân Lam Sơn, đom đóm rừng trúc); thêm **Camera Look-Ahead**, chữ Crit nảy parabol, tâm ngắm mặt đất & cảnh báo Boss Phase 2; triển khai **Thanh Phá Thế Boss (Poise/Stagger)** (`+35%` DMG khi vỡ thế), **Độ Thông Thạo Đấu Kỹ** (`Sơ Khuy → Đỉnh Phong`), **Tâm Ma Luyện Cảnh** (19 Boss × 3 độ khó, hạng `C → SSS`), **Đồ Giám Vạn Thú** (33 loài), **4 BGM ngũ cung vùng mới** (tổng 7 BGM + SFX `poise_break`), **Cài đặt Hiển thị** (`Fullscreen / VSync / FPS / Shake Scale`) & `export_presets.cfg` build Windows `.exe`. |
| **24/11/2026** | `v0.5.0` | **Mở Màn Quyển II (Chương 05 — Hắc Giác Vực & Ngoại Viện Già Nam) & 5 Đại Hệ Thống Mới**: Thêm trọn bộ **6 bản đồ Ch.05** (tổng 25), **8 NV chính (NV 32–39)**, **10 quái/4 Boss mới** (Vân Phàn, Phạm Lăng, Ngô Hạo, La Hầu — tổng 43 quái/23 Boss), **4 Đấu Kỹ mới** (`Tam Thiên Lôi Động` + nâng cấp Lướt `[Space]`, `Sư Hổ Toái Kim Ngâm`, `Đế Ấn Quyết — Khai Sơn Ấn`, `Hỏa Liên Phân Thân` — tổng 15 chiêu), Đồng hành #4 **Tiêu Huân Nhi**, cơ chế **Đấu Linh (Đấu Khí Ngưng Vật)**; thêm **Khảm Ma Hạch 3 Rãnh** lên Huyền Trọng Xích/Vũ khí trong `[I]`; mở Phó bản Roguelite **Thiên Phần Luyện Khí Tháp** (leo tầng vô tận, Tâm Hỏa chước đốt, chọn 1/3 Chúc Phúc, đổi Tinh Hỏa Năng); nâng cấp **4 AI Quái mới** (`burrower`, `artillery`, `shieldbearer`, `bomber`) & **Đổi Phím Tùy Chỉnh (Key Rebinding)** trong `[ESC]`; bổ sung **Mini-game Đấu Giá Đấu Trí & Ký Gửi** (`AuctionSystem`) + **Radar Linh Hồn `[Z]`** cảm ứng rương & lộ hình địch. Kiểm thử tích hợp Godot 4.7.2 `0` lỗi & build Windows `.exe` (`icon.ico`, v0.5.0.0). |
| **24/11/2026** | `v0.5.1` | **Gia Cố Kiến Trúc, Kiểm Thử Tự Động (`P1`) & Nâng Chuẩn Mặc Định 8 Frame**: Tách `SaveLoadManager` khỏi `player_data.gd`; tách `BossRushManager`, `ThienPhanTowerManager` & `StoryDialogueRunner` khỏi `world_stage_manager.gd`; tách 6 panel UI lớn khỏi `hud_controller.gd`; áp dụng ràng buộc `alchemy_max_tier`; bổ sung `upgrade-8f` trong `tools/normalize_spritesheet.py` và nâng toàn bộ **20/20 spritesheet hoạt ảnh** (8 sheet Tiêu Viêm + 12 Boss `*_boss_anim.png`) lên chuẩn mặc định **8 frame** (`4×2`/`8×1`), đồng bộ `SpriteAnimHelper`, `PlayerController`, `EnemyController`, `01_Art_Spec` và mở rộng bộ test tự động `tests/`. |
