# TIẾN ĐỘ DỰ ÁN & LỘ TRÌNH PHÁT TRIỂN (PROJECT PROGRESS & ROADMAP)

> **Dự án**: Đấu Phá Thương Khung — Top-down 2D HD Pixel Action RPG (Godot Engine 4)
> **Cập nhật lần cuối**: 24/11/2026
> **Phiên bản hiện tại**: **v0.6.0 (HOÀN TẤT TRỌN VẸN QUYỂN I & II — Chương 07: Tam Thượng Vân Lam Sơn & Xuất Vân Độc Tông — 38 Bản Đồ, 56 NV Chính, 19 Đấu Kỹ, 65 Quái/34 Boss 8-Frame, Đế Quốc Viêm Minh 4 Đường, Ma Độc Ban, Tam Sắc Hỏa Liên, #15 Hải Tâm Diễm, Đồng Hành #6 Địa Yêu Khôi, Thiên Độc Nữ Tiến Hóa & Đấu Giá Hắc Hoàng Tông)**
> **Mục đích**: Theo dõi đối chiếu giữa **Hồ sơ thiết kế (GDD — 11 Chương)** và **Trạng thái thực thi trong mã nguồn**, quản lý backlog lỗi kỹ thuật và lộ trình phát triển các mốc tiếp theo.

---

## 1. Bức Tranh Tổng Quan Hiện Tại (Snapshot)

| Hạng mục | Đã hoàn thiện trong game | Mục tiêu GDD | Tỷ lệ / Ghi chú |
| :--- | :---: | :---: | :--- |
| **Tài liệu Thiết kế (GDD)** | 25 file + 2 concept art | 25 file | **100%** — Đã viết trọn 11 Chương, hệ thống & roadmap tiến độ |
| **Cốt truyện chơi được** | **7 Chương — TRỌN BỘ QUYỂN I & II** (NV 1–56 + tuyến phụ + Không Gian Trùng Động Trung Châu) | 11 Chương (4 Quyển) | **64%** — Hoàn tất 100% Quyển I (Ch.01–04) & **100% Quyển II (Ch.05–07)**! |
| **Bản đồ liên thông** | **38 bản đồ** (BFS tìm đường toàn cục) | Toàn Đấu Khí Đại Lục | Ch.01 (3), Ch.02 (4), Ch.03 (4), Ch.04 (8), Ch.05 (6), Ch.06 (6), **Ch.07 (7)** |
| **Đấu Kỹ chủ động** | **19 chiêu** (`skills.json`) | 24 chiêu | **79%** — Đã thêm `Phiên Hải Ấn` (Cộng hưởng 1.8× Khai Sơn Ấn) & `Thiên Hỏa Nhị Biến` (19/19 icon riêng) |
| **Dị Hỏa & Thú Hỏa** | **28/28** dữ liệu & **28/28 `lotus_effect`** · **6/28** thu phục cốt truyện (`+#11 Cốt Linh Ấn Ký`, `+#15 Hải Tâm Diễm`) | 28 ngọn Hỏa | **Tam Sắc Phật Nộ Hỏa Liên** (`#19+#14+#11`), Passive EXP/QI 24/7 & *Tâm Hỏa Nội Thiêu* |
| **Cảnh giới & Đột phá** | **12/12** dữ liệu · Đột phá cốt truyện tới **Đấu Hoàng 9 Tinh Đỉnh Phong** (+ `Phá Tông Đan` Thất Phẩm!) | 12 Đại Cảnh Giới | Đã có Sa Y, Khải Giáp, Ngưng Vật, Đấu Khí Hóa Dực, **Đấu Hoàng (Điều Động Thiên Địa Năng Lượng)** & Radar `[Z]` |
| **Quái & Boss** | **65** (31 quái — **7 mẫu AI** + **34/34 Boss 8-frame độc chiêu**) | 25+ Đại Boss | Đã thêm 5 quái & 6 Boss Đấu Tông Ch.07 (`Vân Sơn`, `Vụ Hộ Pháp`, `Nhạn Lạc Thiên`, `Hạt Tất Nham`, `Hàn Phong Đấu Tông`, `Địa Ma Lão Quỷ`) |
| **Luyện Đan & Đấu Giá** | **42** vật phẩm · **20** đan phương (Phẩm 1–7) · **3 Đấu Trường Đấu Giá + Ký Gửi** | 36 đan phương · 13 Thiên Đỉnh | Đã thêm `Thiên Hồn Dung Huyết Đan`, `Thanh Hồn Hóa Sinh Đan`, `Viêm Minh Linh Đan`, Thất Phẩm `Phá Tông Đan` & Đấu Giá **Hắc Hoàng Tông** |
| **Trang Bị 10 Ô & Ma Hạch** | **41** mẫu · **7** bộ Set · **Khảm Ma Hạch Cấp 1–6** (+0→+15) | Trang bị + Yêu Khôi + Khảm Hạch | Đã thêm Set #7 **Viêm Minh Chi Chủ**, *Bồ Đề Hóa Thể Tiên*, *Thiên Yêu Hoàng Cốt Dực* & `core_doc_6` |
| **Đồng Hành AI & Hồng Nhan** | **6** Đồng hành `[G]` (**+Địa Yêu Khôi** & **Thiên Độc Nữ**) · **`[T]` → Địa Yêu Khôi Lôi Bộc** · **5 Hồng Nhan** | 17 Đồng hành & Khách khanh | Rèn Vệ Sĩ Bất Tử **Địa Yêu Khôi** & tiến hóa **Tiểu Y Tiên → Thiên Độc Nữ Đấu Tông tóc bạc**! |
| **Thế Lực & Phó Bản Endgame** | **3 / 8** Chế độ Endgame (**Tâm Ma 34 Boss** + **Thiên Phần Tháp** + **Cường Bảng / Đấu Tông**) + **Đế Quốc Viêm Minh** | 8 Phó bản + Bàn Môn → Thiên Phủ | Tiến hóa **Bàn Môn → Đế Quốc Viêm Minh** (4 Đường Lv.0–3, `FLAG_YAN_ALLIANCE_MAX`) & Đồ Giám 65 loài |
| **Đồ Họa, VFX & Âm Thanh** | **60–144 FPS** · **33 script** · **24 JSON** · **185 art assets (42/42 sheet 8-frame)** · **1.096 test assertions** | — | Shader `char_motion_polish.gdshader`, 7 BGM Ngũ Cung, Key Rebinding & Build Windows `.exe` (`v0.6.0.0`) |

---

## 2. Tiến Độ Cốt Truyện Theo 11 Chương (4 Quyển)

| Quyển | Chương | Trạng thái | Hiện trạng thực tế & Phần còn thiếu |
| :--- | :--- | :---: | :--- |
| **Quyển I**<br>*Gia Mã Đế Quốc* | **Ch.01**: Ô Thản Thành | ✅ Hoàn tất | 3 map, NV 1–9, Từ Hôn, Dược Lão, Nhã Phi, Tiêu Ngọc, Tiêu Ninh, Nhược Lâm, Lăng Ảnh, Liễu Tịch, Gia Liệt Áo, Huyền Trọng Xích. *(GDD nâng cao chưa làm: đấu giá đấu trí, ngâm bồn gỗ mini-game, né thước 30 ngày, stealth ám sát).* |
| **Quyển I** | **Ch.02**: Ma Thú Sơn Mạch | ✅ Hoàn tất | 4 map, NV 10–15, Tiểu Y Tiên, 3 Thạch Thất (Tử Vân Dực, Tàn Đồ 1/4, Sư Tử Ngâm), Vân Chi, Tiểu Tử Tinh Sư Vương & Tử Hỏa, Mục Lực, Mục Xà, Chia ly Thung Lũng U Lan. |
| **Quyển I** | **Ch.03**: Sa Mạc Tháp Qua Nhĩ | ✅ Hoàn tất | 4 map, NV 16–21, Tiêu Đỉnh/Tiêu Lệ, Hải Ba Đông (Tàn Đồ 2/4), Thanh Lân, Địa Huyệt Dung Nham (Song Đầu Hỏa Linh Xà, Thanh Liên Đài), Mặc Ba Tư, Cổ Hà, Vân Vận, Mỹ Đỗ Toa độ kiếp, Thôn phệ `#19 Thanh Liên Địa Tâm Hỏa`, Thải Lân & Phật Nộ Hỏa Liên `[F]`. |
| **Quyển I** | **Ch.04**: Đế Đô & Ước Hẹn 3 Năm | ✅ Hoàn tất | 8 map (Diêm Thành Mặc Gia Trang, Gia Mã Thánh Thành, Nạp Lan Vương Phủ, Quảng Trường Đan Hội, Thiên Thang 999 Bậc, Đỉnh Vân Lam Sơn, Phế Tích Tiêu Gia, Rừng Phong Tỏa & Trấn Quỷ Quan), NV 22–31, 3 tuyến phụ + Easter Egg Mỹ Đỗ Toa, 7 Boss độc chiêu có trọn bộ **sprite 8-frame (`4×2`) riêng** (Mặc Thừa → Nạp Lan Yên Nhiên → Vân Lăng → Đấu Tông Vân Sơn), 4 NPC mới riêng (Nạp Lan Kiệt, Pháp Mã, Gia Hình Thiên, Vân Sơn), tileset riêng Đế Đô & Vân Lam Sơn, Đấu Khí Khải Giáp & Ngoại Phóng, `Lạc Độc Ám Chưởng` (icon riêng), `[T]` Mỹ Đỗ Toa Đấu Tông, hồi sinh `Kim Viêm Hộ Hồn Ngọc`. |
| **Quyển II**<br>*Hắc Giác Vực & Già Nam* | **Ch.05**: Hắc Giác Vực & Ngoại Viện | ✅ Hoàn tất | 6 map (`ch05_hem_nui_hac_phong` → `ch05_rung_san_hoa_nang`), NV 32–39, 4 Boss (Vân Phàn, Phạm Lăng, Ngô Hạo, La Hầu), 4 Đấu Kỹ mới (`Tam Thiên Lôi Động`, `Sư Hổ Toái Kim Ngâm`, `Đế Ấn Quyết`, `Hỏa Liên Phân Thân`), Đồng hành #4 **Tiêu Huân Nhi**, Đấu Giá Bát Phiến Môn, Mảnh Tàn Đồ #3 & Săn Hỏa Năng 240 điểm. |
| **Quyển II** | **Ch.06**: Nội Viện & Thiên Phần Tháp | ✅ Hoàn tất | 6 map (`ch06_noi_vien_ban_mon` → `ch06_bau_troi_noi_vien`), NV 40–47, 3 kỳ ngộ/nhiệm vụ phụ, Thế Lực **Bàn Môn** (3 Phân Đường + thu hoạch thụ động + Tử Nghiên tầm bảo), **Đấu Trường Cường Bảng Top 10**, Đồng hành #5 **Tử Nghiên**, 5 Boss 8-frame (`Bạch Thành`, `Tuyết Ma Thiên Viên`, `Liễu Kình`, `#14 Vẫn Lạc Tâm Viêm`, `Hàn Phong`), 2 Đấu Kỹ mới (`Đại Liệt Phách Quan Trảo`, `Lưu Ly Liên Tâm Ấn`), Passive **Vẫn Lạc Tâm Viêm 24/7** & **Đấu Khí Hóa Dực**. *(18 art Ch.06 hiện dùng bản palette-crafted 8f sắc nét do quota tạo ảnh tạm hết — sẵn sàng nâng cấp 1-đổi-1).* |
| **Quyển II** | **Ch.07**: Tam Thượng Vân Lam & Độc Tông | ✅ Hoàn tất | 7 map (`ch07_dinh_nui_chia_ly` → `ch07_thien_nhai_trung_dong`), NV 48–56, 4 kỳ ngộ/nhiệm vụ phụ (Cổ Hà quy thuận, Bia Tiêu Chiến, An thai Thải Lân, Chữa Phệ Sinh Đan cho Tiêu Lệ), 6 Boss Đấu Tông 8-frame (`Vân Sơn`, `Vụ Hộ Pháp`, `Nhạn Lạc Thiên`, `Hạt Tất Nham`, `Hàn Phong Đấu Tông`, `Địa Ma Lão Quỷ`), **Tam Sắc Hỏa Liên** (`+#11 Cốt Linh Ấn Ký`), **`#15 Hải Tâm Diễm`**, **Đế Quốc Viêm Minh** (4 Đường), **Ma Độc Ban**, **Đồng Hành #6 Địa Yêu Khôi**, tiến hóa **Thiên Độc Nữ**, **Đấu Giá Hắc Hoàng Tông** & 2 Đấu Kỹ (`Phiên Hải Ấn`, `Thiên Hỏa Nhị Biến`). *(20 art Ch.07 hiện dùng bản palette-crafted 8f sắc nét — sẵn sàng thay nóng 1-đổi-1 bằng ảnh AI vẽ mới).* |
| **Quyển III**<br>*Trung Châu Phong Vân* | **Ch.08**: Bắc Vực & Đan Hội Trung Châu | ⏳ Chưa làm | Thiên Sơn Huyết Đàm, Phần Viêm Cốc (`#12`), Tứ Phương Các (Phượng Thanh Nhi), Diệp Thành (Băng Hà Cốc), Đan Hội Trung Châu & `#9 Tam Thiên Diễm Viêm Hỏa`. |
| **Quyển III** | **Ch.09**: Cứu Sư Vong Hồn & Thiên Mộ | ⏳ Chưa làm | Đánh Vong Hồn Điện cứu Dược Lão (Trích Tinh Lão Quỷ), Hoa Tông, Viễn Cổ Di Tích, Thiên Mộ Tam Tầng, Đế Tộc Văn. |
| **Quyển IV**<br>*Thánh Đế Quyết Chiến* | **Ch.10**: Bồ Đề Hóa Thánh & Tịnh Liên | ⏳ Chưa làm | Bồ Đề Cổ Thụ, Thiên Phủ Liên Minh, `#4 Kim Đế Phần Thiên Viêm`, Yêu Hỏa Không Gian (4/4 Mảnh Tàn Đồ → `#3 Tịnh Liên Yêu Hỏa`). |
| **Quyển IV** | **Ch.11**: Cổ Đế Động Phủ & Song Đế Chiến | ⏳ Chưa làm | Cứu Tiêu Chiến, Dược Giới (`#5`, `#10`, `#22`), Cổ Đế Động Phủ (8 mảnh Cổ Đế Ngọc, Đế Phẩm Sồ Đan, `#1 Đế Viêm`), **Final Boss Hồn Thiên Đế (3 Phase)** & Endgame Đại Thiên Thế Giới. |

---

## 3. Ma Trận Tiến Độ Từng Hệ Thống (GDD vs. Đã Code)

### 3.1. Những Việc ĐÃ LÀM (Core Đã Chạy Ổn Định — `v0.5.5`)
* [x] **Kiến trúc dữ liệu & Autoload**: `EventBus`, `AudioManager`, `GameDatabase`, `PlayerData` nạp động **20 file JSON** trong `data/` (Data-Driven Story Engine hỗ trợ mở rộng `ch02..ch11`, hội thoại phân nhánh JSON, BFS tìm đường đa bản đồ qua **31 bản đồ** & **47 NV chính**).
* [x] **Hệ thống Điều Khiển & Chiến Đấu (60–144 FPS)** (`scripts/entities/player_controller.gd`):
  * [x] Di chuyển 8 hướng (2D Physics Interpolation, Foot-Anchored Pivot, Input Buffer `0.14s`, Hitstop toàn cục, Camera Look-Ahead), đánh thường combo 3 nhịp kèm 4 bộ attack sprite sheet liền thân (Tay Không / Kiếm / Đao / Huyền Trọng Xích).
  * [x] Lướt né `[Space]` có I-frame & tàn ảnh (tiến hóa tự động: Lướt thường → **Lướt Tử Vân Dực** → **Tam Thiên Lôi Động** → **Đấu Khí Hóa Dực**).
  * [x] Phong ấn / Giải phong Huyền Trọng Xích `[RMB / C]` (`-15% SPD`, `+30% EXP`).
  * [x] Cơ chế đặc thù 4 bậc đầu: **Đấu Khí Sa Y** (Đấu Sư `+18% DEF`), **Đấu Khí Khải Giáp & Kiếm Khí Ngoại Phóng** (Đại Đấu Sư `+32% DEF`), **Đấu Khí Ngưng Vật** (Đấu Linh `+42% DEF`, `+15%` lực phá thế, `1.20×` tầm đánh), **Đấu Khí Hóa Dực** (Đấu Vương `+52% DEF`, `+15% SPD`, `+25%` lực phá thế, `1.28×` tầm đánh & đôi cánh lưu ly động sau lưng!).
  * [x] **17 Đấu Kỹ** hoạt động đầy đủ (`Q/E/R/F`) kèm **Độ Thông Thạo (`Sơ Khuy → Đỉnh Phong`)**, bộ VFX additive 60 FPS (`SkillVfxBurst`, `VfxAssets`), nội tại **#14 Vẫn Lạc Tâm Viêm** (*Tu Luyện 24/7* + *Tâm Hỏa Nội Thiêu* sát thương chuẩn mỗi 5 đòn) & **`[T]` Cốt Linh Phụ Thể → Đấu Tông Mỹ Đỗ Toa Hộ Pháp**.
  * [x] Đèn động `PointLight2D`, Thời tiết động theo vùng (bão cát, tàn lửa, mây mù, đom đóm), screen shake tùy chỉnh, chữ Crit nảy parabol.
* [x] **Cảnh Giới, Linh Hồn & Dị Hỏa**:
  * [x] Khai báo đủ 12 Đại Cảnh Giới, 4 Cảnh Linh Hồn và công thức Áp Chế / Xuyên Áp Chế (`data/realms.json`), kèm **Radar Linh Hồn `[Z]`** cảm ứng rương ẩn & lộ hình kẻ địch (soi lộ hình *Đại Xà Vẫn Lạc Tâm Viêm*!).
  * [x] Khai báo đủ **28/28 loại Hỏa** (`data/flames.json`) + Shader lửa động 3 tầng màu (`assets/shaders/di_hoa_palette.gdshader`) + trọn bộ **28/28 `lotus_effect`** khi dung hợp 2–4 Hỏa cho `[F] Phật Nộ Hỏa Liên`.
* [x] **Trang Bị 10 Ô, Ma Hạch & Loot** (`scripts/systems/equipment_system.gd`, `scripts/entities/loot_pickup.gd`):
  * [x] 10 ô mặc đồ, **36 mẫu trang bị**, 6 phẩm chất (Phàm → Đế), **6 bộ Set**, 8 dòng affix ngẫu nhiên, cường hóa `+0 → +15`, phân giải hàng loạt và **Khảm Ma Hạch 3 Rãnh (Cấp 1–5, gồm cả `core_bang_5`)** lên Vũ Khí trong `[I]`.
* [x] **Lò Luyện Đan `[L]` & Đấu Giá Đấu Trí + Ký Gửi** (`scripts/systems/alchemy_system.gd`, `scripts/systems/auction_system.gd`):
  * [x] **33 vật phẩm** & **16 đan phương (Phẩm 1–7)**, Mini-game canh Hỏa Hầu `[Space]` + Chắn Đan Lôi `[E]` có cộng thưởng trực tiếp từ Dị Hỏa, Dược Đỉnh, Linh Hồn, Đan Đường Bàn Môn & Hảo Cảm Tiểu Y Tiên; **áp dụng ràng buộc giới hạn phẩm luyện đan theo Cảnh Linh Hồn (`alchemy_max_tier`)**.
  * [x] **Mini-game Đấu Giá Đấu Trí & Ký Gửi** (`AuctionSystem`) tại 2 đấu trường (Mễ Đặc Nhĩ & Bát Phiến Môn) kèm Thăm Dò Linh Hồn & Uy Áp Linh Hồn.
* [x] **Kiến Trúc Mô-Đun & Kiểm Thử Tự Động (`P1`)**:
  * [x] Tách `SaveLoadManager`, `PanGateManager` khỏi `player_data.gd`; tách `BossRushManager`, `ThienPhanTowerManager` & `StoryDialogueRunner` khỏi `world_stage_manager.gd`; tách 6 panel UI lớn (`panel_alchemy`, `panel_auction`, `panel_equipment`, `panel_world_map_bestiary`, `panel_tower_boss_rush`, `panel_pause_settings`) vào `scripts/ui/panels/`.
  * [x] Bộ kiểm thử tự động Godot headless `tests/` (`tests/test_runner.tscn`, `tests/test_suite.gd`, `tests/run_tests.bat`) — **10 Suites / 896 assertions** kiểm tra JSON schema, asset `res://`, BFS liên thông 31 bản đồ, `alchemy_max_tier`, Save/Load, DEMO, live scene, 36/36 sheet 8-frame, 17/17 icon Đấu Kỹ riêng & toàn bộ cơ chế Ch.06.
* [x] **Quái, Boss, Đồng Hành, Hồng Nhan, Bàn Môn & Endgame**:
  * [x] **54 kẻ địch** (26 quái thường với **7 mẫu AI**: `chaser`, `charger`, `artillery`, `burrower`, `bomber`, `shieldbearer`, `dummy` + **28/28 Boss 8-frame** có bộ chiêu thức riêng, Phase 2, **Thanh Phá Thế Poise/Stagger**, `BossHazardZone` & `EnemyProjectile` VFX 60 FPS).
  * [x] **5 Đồng Hành AI `[G]`** (Dược Lão, Tiểu Y Tiên, Thải Lân, Tiêu Huân Nhi, **Tử Nghiên**) + **5 Hồng Nhan Tri Kỷ** trong `[M]`.
  * [x] **Quản Trị Thế Lực Bàn Môn (`PanGateManager`) & 3 Chế độ Endgame** trong `[M]`: **🏯 Bàn Môn** (3 Phân Đường Lv.0–3, thu hoạch thụ động, Tử Nghiên tầm bảo & **Đấu Trường Cường Bảng Top 10**), **Tâm Ma Luyện Cảnh** (28 Boss × 3 độ khó, hạng `C → SSS`), **Thiên Phần Luyện Khí Tháp Roguelite** & **Đồ Giám Vạn Thú (54 loài)**.
* [x] **Giao Diện MOBA, Save/Load, DEMO, Âm Thanh & Đóng Gói**:
  * [x] HUD MOBA bấm chuột trực tiếp + quét hồi chiêu + Tooltip + Live Mini-Map + Bản Đồ Thế Giới `[M]` (31 map).
  * [x] Màn hình chính + Lưu/Tải 3 Ô Nạp Giới (nhớ tọa độ `(x, y)`) + Auto-Save + Auto-Continue + **Chế Độ DEMO** (Ô 3, mở khóa trọn 31 map Ch.01–06, Đấu Vương 9 Tinh Hóa Dực, 17 Kỹ, 28 Hỏa, 5 Đồng Hành, Bàn Môn Lv.2, 3 Ma Hạch).
  * [x] **Đổi Phím Tùy Chỉnh (Key Rebinding)** + **Cài đặt Hiển thị** (`Fullscreen`, `VSync`, `Hiện FPS`, `Shake Scale`) trong `[ESC]`, **7 BGM ngũ cung Procedural** + 21+ SFX, `tools/normalize_spritesheet.py` và cấu hình đóng gói Windows `export_presets.cfg` (`0.5.5.0`) + `icon.ico`.

### 3.2. Những Hệ Thống GDD CHƯA LÀM Hoặc Mới Làm Một Phần
* [ ] **Cảnh Giới & Linh Hồn nâng cao**:
  * [ ] Bổ sung đan dược & công thức đột phá từ Đấu Hoàng → Đấu Đế (`Phá Tông Đan`, `Sinh Cốt Dung Huyết Đan`, `Bồ Đề Tử`, `Bồ Đề Tâm`, `Đế Phẩm Sồ Đan`). *(Đã có `Hoàng Cực Đan` ở Ch.06!)*
  * [ ] Cơ chế riêng từ bậc 7 trở lên: **Đấu Tông** (Không Gian Phong Tỏa), **Đấu Tôn** (Xé Không Gian), **Đấu Thánh** (Giới Vực), **Viêm Đế** (Vạn Hỏa Triều Tông). *(Đã xong **Đấu Khí Hóa Dực** bậc 6 Đấu Vương ở Ch.06!)*
  * [ ] Hồn Kỹ thực chiến, Nội Thị Kinh Mạch, tỷ lệ Tẩu Hỏa Nhập Ma & Độ Kiếp Thiên Lôi.
* [ ] **Đấu Kỹ & Hiệu Ứng Dị Hỏa Chuyên Sâu**:
  * [ ] Bổ sung **7 Đấu Kỹ** còn lại (`17/24 → 24/24`, nhóm Địa/Thiên Giai & Đế Kỹ).
  * [ ] Ma Độc Ban (Ch.07–08), Đế Tộc Văn (Ch.09+), Cải trang Hắc Bào — Nham Kiêu.
* [ ] **Quái Vật & Boss Đa Dạng Hóa**:
  * [ ] Bổ sung mẫu AI nâng cao cho Ch.07–11 (Tàng Hình, Kiếm Trận, Xiềng Xích Hút Hồn) và dàn Đại Boss Chương 07–11 (Vân Sơn & Vụ Hộ Pháp, Hạt Tất Nham, Trích Tinh Lão Quỷ → Hồn Thiên Đế 3 Phase).
* [ ] **Luyện Đan & Trang Bị Sinh Trưởng (Mid/Endgame)**:
  * [ ] Mở rộng từ **16 lên 36 đan phương** (Phẩm 6–9 + Đế Phẩm), 13 danh đỉnh Thiên Đỉnh Bảng, Đan Lôi thực chiến trên bản đồ, Đan Thú hoang dã và chế độ Đại Hội Luyện Đan mở rộng.
  * [ ] Hệ thống **Chế Tạo & Nuôi Dưỡng Yêu Khôi** (Địa Yêu Khôi → Thiên Yêu Khôi → Bắc Vương + 4 lệnh AI), dung luyện Ma Hạch nâng cấp, 8 mảnh Đà Xá Cổ Đế Ngọc, Tọa Kỵ / Trùng Động.
* [ ] **Hồng Nhan, Đồng Hành & Thế Lực Tự Lập**:
  * [ ] Nhiệm vụ riêng từng Hồng Nhan, Tuyệt Kỹ Hợp Kích đôi, và chiêu mộ dàn đồng hành giai đoạn sau (Vân Vận, Thanh Lân, Hải Ba Đông...).
  * [ ] Nâng cấp Thế Lực tự lập lên cấp 2–3 (**Viêm Minh** Ch.07 → **Thiên Phủ Liên Minh** Ch.10) kèm sự kiện phòng thủ Hồn Điện tập kích. *(Cấp 1 **Bàn Môn** đã hoàn tất ở Ch.06!)*
* [ ] **5/8 Phó Bản Cày Cuốc & Endgame Còn Lại**:
  * [ ] Thiên Sơn Huyết Đàm, Vạn Dặm Đan Giới (roguelite), Viễn Cổ Di Tích, Thiên Mộ, 17 Bí Cảnh Dị Hỏa Ẩn, Khe Nứt Đại Thiên Thế Giới & `New Game+`. *(Đã xong 3/8: Tâm Ma Luyện Cảnh, Thiên Phần Luyện Khí Tháp & Đấu Trường Cường Bảng!)*
* [x] **Đồ Họa (Bù Nợ Art Ch.04–05 — ĐÃ HOÀN TẤT ở `v0.5.2`; Art Ch.06 hoàn tất tạm thời ở `v0.5.5`)**:
  * [x] Ch.04–05 (`v0.5.2`): **39 tài nguyên 32-bit HD Pixel Art mới** vẽ riêng (5 icon, 4 tileset, 8 NPC, 11 Boss 8-frame).
  * [x] Ch.06 (`v0.5.5`): **18 tài nguyên pixel-art riêng** (2 tileset, 2 icon Đấu Kỹ, 4 NPC, 5 Boss 8-frame + 5 portrait) hiện được tổng hợp palette-crafted chuẩn `4×2` do quota model tạo ảnh tạm hết — có thể thay nóng 1-đổi-1 bằng ảnh AI vẽ mới sau khi quota reset mà không cần sửa bất kỳ dòng code/JSON nào.

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
* [x] *(Đợt polish Đồ họa `v0.5.2`)* Đã hoàn thiện tileset Đế Đô (`de_do_palace.png`) & Vân Lam Sơn (`yunlan_marble.png`), 4 NPC mới và trọn bộ sprite 8-frame (`4×2`) riêng cho 7/7 Boss Chương 04.

### Mốc M4 — Quyển II: Hắc Giác Vực, Già Nam & Tam Thượng Vân Lam (`v0.5.0 – v0.6.0`) — ✅ HOÀN TẤT 100% (3/3 Chương!)
* [x] **Chương 05 (`v0.5.0`)**: 6 bản đồ Hắc Giác Vực & Ngoại Viện Già Nam, NV 32–39, 4 Boss (Vân Phàn, Phạm Lăng, Ngô Hạo, La Hầu), 4 Đấu Kỹ bậc Địa/Thiên Giai (`Tam Thiên Lôi Động`, `Sư Hổ Toái Kim Ngâm`, `Đế Ấn Quyết`, `Hỏa Liên Phân Thân`), Đồng hành #4 **Tiêu Huân Nhi**, cơ chế **Đấu Linh (Đấu Khí Ngưng Vật)**, Khảm Ma Hạch 3 Rãnh, Đấu Giá Đấu Trí & Ký Gửi, Radar Linh Hồn `[Z]`, Đổi Phím Tùy Chỉnh và Phó bản 01 (**Thiên Phần Luyện Khí Tháp Roguelite**).
* [x] **Chương 06 (`v0.5.5`)**: 6 bản đồ Nội Viện Già Nam & Đáy Tháp Thiên Phần (tổng 31 map), NV 40–47, 3 kỳ ngộ/nhiệm vụ phụ, Đồng hành #5 **Tử Nghiên** (Choáng + `+45%` Radar/Hút Đồ + Tầm Bảo), Phó bản 02 (**Đấu Trường Cường Bảng Top 10**), Hệ thống Thế Lực cấp 1 (**Bàn Môn** 3 Phân Đường), 5 Boss 8-frame (`Bạch Thành`, `Tuyết Ma Thiên Viên`, `Liễu Kình`, `#14 Vẫn Lạc Tâm Viêm`, `Hàn Phong`), 2 Đấu Kỹ (`Đại Liệt Phách Quan Trảo`, `Lưu Ly Liên Tâm Ấn`), Passive **Vẫn Lạc Tâm Viêm 24/7** & **Đấu Khí Hóa Dực**.
* [x] **Chương 07 (`v0.6.0`)**: 7 bản đồ từ Đỉnh Núi Chia Ly → Đỉnh Vân Lam Sơn → Xuất Vân Độc Chướng → Ma Viêm Cốc → Không Gian Trùng Động Thiên Nhai Thành (tổng **38 map**), NV 48–56 + 4 kỳ ngộ/tuyến phụ, 6 Boss Đấu Tông 8-frame (`Vân Sơn`, `Vụ Hộ Pháp`, `Nhạn Lạc Thiên`, `Hạt Tất Nham`, `Hàn Phong Đấu Tông`, `Địa Ma Lão Quỷ`), **Đấu Hoàng (`realm >= 7`)**, **Tam Sắc Hỏa Liên** (`+#11 Cốt Linh Ấn Ký`), **`#15 Hải Tâm Diễm`**, **Ma Độc Ban**, Thế Lực cấp 2 (**Đế Quốc Viêm Minh** 4 Đường + 3 Đấu Tông khiêu chiến), **Đồng Hành #6 Địa Yêu Khôi** + `[T]` Lôi Bộc, tiến hóa **Thiên Độc Nữ**, **Đấu Giá Hắc Hoàng Tông**, Thất Phẩm `Phá Tông Đan` & 2 Đấu Kỹ (`Phiên Hải Ấn`, `Thiên Hỏa Nhị Biến`).

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
| **24/11/2026** | `v0.5.2` | **Bù Trọn Nợ Art Chương 04–05 (`P2 Art`) — 39 Tài Nguyên 32-bit HD Pixel Art Mới**: Vẽ & chuẩn hóa **5 icon riêng (`56×56`)** cho 5 Đấu Kỹ Ch.04–05 (`15/15` icon độc nhất, cập nhật cả HUD `[Space]` Lôi Động & Thiên Phần Tháp), **4 tileset vùng seamless (`128×128`)** (`de_do_palace`, `yunlan_marble`, `hac_giac_obsidian`, `gia_nam_courtyard`), **8 sprite NPC mới** (`Nạp Lan Kiệt`, `Pháp Mã`, `Gia Hình Thiên`, `Đấu Tông Vân Sơn`, `Hổ Càn`, `Tô Thiên`, `Chưởng Quỹ Bát Phiến Môn`, `Thương Nhân Gia Mã`), và trọn bộ **11 Boss Ch.04–05 chuẩn 8-frame (`4×2`) riêng** (tổng **31/31 spritesheet 8-frame** = 8 Tiêu Viêm + 23/23 Boss). Kiểm thử Godot 4.7.2 headless: **722 PASSED / 0 FAILED**. |
| **24/11/2026** | `v0.5.5` | **Hoàn Tất Chương 06 (`P2`) — Nội Viện Già Nam & Đáy Tháp Thiên Phần**: Thêm trọn bộ **6 bản đồ mới** (tổng **31 bản đồ** BFS liên thông), **8 NV chính (NV 40–47)** + 3 tuyến phụ/kỳ ngộ, **11 kẻ địch mới gồm 5 Boss 8-frame độc chiêu** (`Bạch Thành`, `Tuyết Ma Thiên Viên`, `Bá Thương Liễu Kình`, `#14 Vẫn Lạc Tâm Viêm`, `Dược Hoàng Hàn Phong` — tổng 54 quái/28 Boss), **2 Đấu Kỹ mới** (`Đại Liệt Phách Quan Trảo`, `Lưu Ly Liên Tâm Ấn` — 17/17 icon riêng), Set #6 **Nội Viện Bá Chủ** + 5 trang bị mới + 4 đan phương mới (`Hoàng Cực Đan`, `Địa Linh Đan`, `Hỏa Liên Đan`, `Đan Hoàn Ngọt`) + Ma Hạch `core_bang_5`; ra mắt **Quản Trị Thế Lực Bàn Môn** (`PanGateManager` & tab `🏯 Bàn Môn` trong `[M]` với 3 Phân Đường Lv.0–3, thu hoạch thụ động, Tử Nghiên tầm bảo & **Đấu Trường Cường Bảng Top 10**), **Đồng Hành #5 Tử Nghiên**, nội tại **#14 Vẫn Lạc Tâm Viêm 24/7** (*Tu Luyện Gian Lận Khí* + *Tâm Hỏa Nội Thiêu* sát thương chuẩn mỗi 5 đòn) và **Đấu Vương — Đấu Khí Hóa Dực** (cánh lưu ly xanh-tím động sau lưng + bay lướt `[Space]`). Kiểm thử Godot 4.7.2 headless (10 Suites): **896 PASSED / 0 FAILED**. |
| **24/11/2026** | `v0.5.6` | **Nâng Cấp Gói Combat VFX & Procedural Polish 60–144 FPS**: Tạo shader nhân vật pixel-crisp `assets/shaders/char_motion_polish.gdshader` (khóa bàn chân `cell_y >= 0.78`, gió phất tóc/tà áo 60 FPS, viền Đấu Khí Rim-Glow 1px theo Dị Hỏa/Phase 2 & Hit-Flash trắng); nâng cấp `SkillVfxBurst` thêm lớp **Motion-Smear + 3 kim gió mũi lưỡi** cho `melee_slash` cùng 4 mode VFX chuyên biệt mới (`windup_charge` tụ lực 8 tia, `boss_strike_arc` 3 tầng cung trăng khuyết, `tyrant_claw` 4 vết cào kim quang Ch.06, `glazed_lotus_vortex` xoáy lưu ly xanh-tím 8 cánh sen Ch.06); tích hợp **Tàn Ảnh hành động (Action Afterimage)**, **Bụi bước chân Boss**, **Vòng tụ lực Cast/Windup** cho `PlayerController` & `EnemyController`. Kiểm thử Godot 4.7.2 headless: **903 PASSED / 0 FAILED**. |
| **24/11/2026** | `v0.6.0` | **HOÀN TẤT TRỌN VẸN QUYỂN II (Mốc M4 100%) — Chương 07: Tam Thượng Vân Lam Sơn & Xuất Vân Độc Tông**: Thêm trọn bộ **7 bản đồ mới** (`ch07_dinh_nui_chia_ly` → `ch07_thien_nhai_trung_dong`, tổng **38 bản đồ** BFS liên thông), **9 NV chính (NV 48–56)** + 4 kỳ ngộ/tuyến phụ, **11 kẻ địch mới gồm 6 Boss Đấu Tông 8-frame (`4×2`)** (`Vân Sơn`, `Vụ Hộ Pháp`, `Nhạn Lạc Thiên`, `Hạt Tất Nham`, `Hàn Phong Đấu Tông`, `Địa Ma Lão Quỷ` — tổng **65 quái / 34 Boss**), **2 Đấu Kỹ mới** (`Phiên Hải Ấn` cộng hưởng 1.8× *Khai Sơn Ấn*, `Thiên Hỏa Nhị Biến` phóng song sóng Lưu Ly — **19/19 icon riêng**), **20 tài nguyên art Ch.07**, Set #7 **Viêm Minh Chi Chủ** + 5 trang bị mới + 4 đan phương mới (**20 công thức**, gồm Thất Phẩm `Phá Tông Đan`) + `core_doc_6`; triển khai **Đế Quốc Viêm Minh** (nâng cấp Bàn Môn → 4 Đường + `FLAG_YAN_ALLIANCE_MAX` + 3 Đấu Tông khiêu chiến), **Phong ấn Ma Độc Ban** (-10% Max QI / `+1%` ATK mỗi Boss stack), **Tam Sắc Hỏa Liên** (`+#11 Cốt Linh Ấn Ký`), **`#15 Hải Tâm Diễm`**, **Đấu Hoàng (`realm >= 7`)**, **Đồng Hành #6 Địa Yêu Khôi** + `[T]` Lôi Bộc Bất Hoại, tiến hóa **Thiên Độc Nữ Tiểu Y Tiên**, **Đấu Giá Hắc Hoàng Tông (#3)**, và 3 mode VFX mới (`ocean_seal`, `flame_buff_tier2`, `dia_yeu_khoi_assist`). Kiểm thử Godot 4.7.2 headless (11 Suites): **1.096 PASSED / 0 FAILED** (`export_presets.cfg` v0.6.0.0). |
