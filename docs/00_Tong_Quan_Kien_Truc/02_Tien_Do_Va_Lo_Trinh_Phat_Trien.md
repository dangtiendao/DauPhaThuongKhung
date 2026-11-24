# TIẾN ĐỘ DỰ ÁN & LỘ TRÌNH PHÁT TRIỂN (PROJECT PROGRESS & ROADMAP)

> **Dự án**: Đấu Phá Thương Khung — Top-down 2D HD Pixel Action RPG (Godot Engine 4)
> **Cập nhật lần cuối**: 24/11/2026
> **Phiên bản hiện tại**: **v0.3.0 (Playable Quyển I: Chương 01 – Chương 03)**
> **Mục đích**: Theo dõi đối chiếu giữa **Hồ sơ thiết kế (GDD — 11 Chương)** và **Trạng thái thực thi trong mã nguồn**, quản lý backlog lỗi kỹ thuật và lộ trình phát triển các mốc tiếp theo.

---

## 1. Bức Tranh Tổng Quan Hiện Tại (Snapshot)

| Hạng mục | Đã hoàn thiện trong game | Mục tiêu GDD | Tỷ lệ / Ghi chú |
| :--- | :---: | :---: | :--- |
| **Tài liệu Thiết kế (GDD)** | 24 file + 2 concept art | 24 file | **100%** — Đã viết trọn 11 Chương & toàn bộ hệ thống |
| **Cốt truyện chơi được** | **3 Chương** (NV 1–21) | 11 Chương (4 Quyển) | **27%** — Xong Ch.01, Ch.02, Ch.03 (Sa Mạc Tháp Qua Nhĩ) |
| **Bản đồ liên thông** | **11 bản đồ** (14 rương, 21 cổng) | Toàn Đấu Khí Đại Lục | Ch.01 (3), Ch.02 (4), Ch.03 (4) |
| **Đấu Kỹ chủ động** | **10 chiêu** (`skills.json`) | 24 chiêu | **42%** — Đủ bộ Ch.01–03 + Phật Nộ Hỏa Liên `[F]` |
| **Dị Hỏa & Thú Hỏa** | **28/28** dữ liệu · **3/28** thu phục cốt truyện | 28 ngọn Hỏa | 25 ngọn còn lại hiện mới trải nghiệm được qua Chế độ DEMO |
| **Cảnh giới & Đột phá** | **12/12** dữ liệu · Đột phá cốt truyện tới **Đại Đấu Sư** | 12 Đại Cảnh Giới | Thiếu đan phương & cơ chế đặc thù từ bậc 4 → 12 |
| **Quái & Boss** | **20** (8 quái + 12 Boss · 6 Boss có `anim_sheet` 4 frame) | 25+ Đại Boss | Cả 12 Boss đang dùng chung 1 khuôn AI `boss_duelist` |
| **Luyện Đan** | **17** vật phẩm · **7** đan phương (Phẩm 1–4) | 36 đan phương · 13 Thiên Đỉnh | Có Mini-game Khống Hỏa + Chắn Đan Lôi |
| **Trang Bị 10 Ô** | **21** mẫu · **3** bộ Set · 6 phẩm chất · +0→+15 | Trang bị + Yêu Khôi + Khảm Hạch | Chưa có Yêu Khôi, khảm Ma Hạch, Cổ Đế Ngọc |
| **Đồng Hành AI `[G]`** | **3** (Dược Lão, Tiểu Y Tiên, Thải Lân) | 17 Đồng hành & Khách khanh | Hảo cảm 5 Hồng Nhan đã đếm điểm, chưa có mốc thưởng |
| **Thế Lực & Phó Bản Endgame** | **0 / 8** Phó bản · chưa có Tông Môn | 8 Phó bản + Bàn Môn → Thiên Phủ | Dự kiến triển khai từ Quyển II trở đi |
| **Mã nguồn & Kiến trúc** | **17 script** (9.333 dòng GDScript) · 9 scene · 8 JSON | — | 100% đường dẫn `res://` hợp lệ, chưa khởi tạo Git |

---

## 2. Tiến Độ Cốt Truyện Theo 11 Chương (4 Quyển)

| Quyển | Chương | Trạng thái | Hiện trạng thực tế & Phần còn thiếu |
| :--- | :--- | :---: | :--- |
| **Quyển I**<br>*Gia Mã Đế Quốc* | **Ch.01**: Ô Thản Thành | ✅ Hoàn tất | 3 map, NV 1–9, Từ Hôn, Dược Lão, Nhã Phi, Tiêu Ngọc, Tiêu Ninh, Nhược Lâm, Lăng Ảnh, Liễu Tịch, Gia Liệt Áo, Huyền Trọng Xích. *(GDD nâng cao chưa làm: đấu giá đấu trí, ngâm bồn gỗ mini-game, né thước 30 ngày, stealth ám sát).* |
| **Quyển I** | **Ch.02**: Ma Thú Sơn Mạch | ✅ Hoàn tất | 4 map, NV 10–15, Tiểu Y Tiên, 3 Thạch Thất (Tử Vân Dực, Tàn Đồ 1/4, Sư Tử Ngâm), Vân Chi, Tiểu Tử Tinh Sư Vương & Tử Hỏa, Mục Lực, Mục Xà, Chia ly Thung Lũng U Lan. |
| **Quyển I** | **Ch.03**: Sa Mạc Tháp Qua Nhĩ | ✅ Hoàn tất | 4 map, NV 16–21, Tiêu Đỉnh/Tiêu Lệ, Hải Ba Đông (Tàn Đồ 2/4), Thanh Lân, Địa Huyệt Dung Nham (Song Đầu Hỏa Linh Xà, Thanh Liên Đài), Mặc Ba Tư, Cổ Hà, Vân Vận, Mỹ Đỗ Toa độ kiếp, Thôn phệ `#19 Thanh Liên Địa Tâm Hỏa`, Thải Lân & Phật Nộ Hỏa Liên `[F]`. |
| **Quyển I** | **Ch.04**: Đế Đô & Ước Hẹn 3 Năm | ⏳ Chưa làm | Cổng chờ `ch04_unlocked_future` đã đặt ở cuối Ốc Đảo Diêm Lệ. Cần làm: Mặc Gia Bảo (Boss Mặc Thừa), cải trang Nham Kiêu, Đan Hội Gia Mã (`Tam Văn Thanh Linh Đan`), Vân Lam Sơn (Boss Nạp Lan Yên Nhiên, Vân Lăng & Hộ Tông Đại Trận). |
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
  * [x] 7 công thức Phẩm 1–4, Mini-game canh Hỏa Hầu `[Space]` + Chắn Đan Lôi `[E]` thưởng `+1` viên & `+50% SOUL`.
* [x] **Quái, Boss & Đồng Hành**:
  * [x] 20 kẻ địch (8 quái thường + 12 Boss có 2 Phase ở 55% HP, thanh máu Boss, telegraph, bắn 3 tia kiếm khí).
  * [x] 6 Boss đã có sprite sheet 4 frame (`tieu_ninh`, `gia_liet_ao`, `tieu_tu_tinh_su`, `muc_xa`, `hai_ba_dong`, `hoa_linh_xa`).
  * [x] 3 Đồng Hành AI `[G]`: Hồn Ảnh Dược Lão, Tiểu Y Tiên, Thần Thú Thải Lân.
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
  * [ ] Hiện thực hóa **28 hiệu ứng đặc biệt (`lotus_effect`)** trong `data/flames.json` khi dung hợp vào Phật Nộ Hỏa Liên (đóng băng, giật sét choáng, khiên đất, hút máu, xóa buff Boss, mưa thiên thạch, hắc động...) và vẽ đủ hiệu ứng cho cả 3–4 ngọn Hỏa ghép.
  * [ ] Độ Thông Thạo Đấu Kỹ (Mastery), thanh Poise/Phá Giáp, Lưu Hỏa dung hợp thường trực, Ma Độc Ban (Ch.07–08), Đế Tộc Văn (Ch.09+), Cải trang Hắc Bào — Nham Kiêu.
* [ ] **Quái Vật & Boss Đa Dạng Hóa**:
  * [ ] Mở rộng AI quái thường từ 3 mẫu lên 8 mẫu GDD (Độn Thổ, Pháo Kích, Kiếm Trận, Tàng Hình, Khiên Trước, Xiềng Xích Hút Hồn, Tự Bạo).
  * [ ] Tách kịch bản chiêu thức đặc thù cho từng Boss thay vì dùng chung 1 máy trạng thái `boss_duelist`.
  * [ ] Bổ sung 13+ Đại Boss Chương 04–11 (tổng 25 Boss GDD), chế độ tái chiến **Tâm Ma Luyện Cảnh** (3 độ khó + xếp hạng `C → SSS`) và **Đồ Giám Vạn Thú**.
* [ ] **Luyện Đan, Đấu Giá & Trang Bị Sinh Trưởng**:
  * [ ] Mở rộng từ 7 lên 36 đan phương (Phẩm 5–9 + Đế Phẩm), 13 danh đỉnh Thiên Đỉnh Bảng, Đan Lôi thực chiến trên bản đồ, Đan Thú hoang dã.
  * [ ] Nâng Phòng Đấu Giá Nhã Phi thành **Mini-game Đấu Giá tương tác** (trả giá đấu trí, ký gửi bán đan dược dưới thân phận Hắc Bào Tiên Sinh) và chế độ **Đại Hội Luyện Đan**.
  * [ ] Hệ thống **Chế Tạo & Nuôi Dưỡng Yêu Khôi** (Địa Yêu Khôi → Thiên Yêu Khôi → Bắc Vương + 4 lệnh AI), rãnh khảm Ma Hạch lên Huyền Trọng Xích, dung luyện Ma Hạch, 8 mảnh Đà Xá Cổ Đế Ngọc, Tọa Kỵ / Trùng Động.
* [ ] **Hồng Nhan, Đồng Hành & Thế Lực Tự Lập**:
  * [ ] Gắn gameplay thực tế cho điểm **Hảo Cảm** (10 cấp thưởng, tặng quà, nhiệm vụ riêng từng Hồng Nhan, Tuyệt Kỹ Hợp Kích đôi) và mở rộng dàn đồng hành (Huân Nhi, Vân Vận, Tử Nghiên, Thanh Lân, Hải Ba Đông...).
  * [ ] Hệ thống **Quản Lý Tông Môn Tự Lập** (`Bàn Môn → Viêm Minh → Thiên Phủ Liên Minh`): phái đệ tử thu dược liệu tự động, sảnh luyện đan thụ động, sự kiện phòng thủ Hồn Điện tập kích.
* [ ] **8 Phó Bản Cày Cuốc & Endgame**:
  * [ ] Thiên Phần Luyện Khí Tháp, Đấu Trường Cường Bảng, Thiên Sơn Huyết Đàm, Vạn Dặm Đan Giới (roguelite), Viễn Cổ Di Tích, Thiên Mộ, 17 Bí Cảnh Dị Hỏa Ẩn, Khe Nứt Đại Thiên Thế Giới & `New Game+`.
* [ ] **Đồ Họa, Âm Thanh & Đóng Gói**:
  * [ ] Vẽ bổ sung `anim_sheet` 4 frame cho 6 Boss còn lại (`tieu_ngoc`, `lieu_tich`, `thach_khoi`, `muc_luc`, `mac_ba_tu`, `co_ha`) và animation Idle 4 frame cho Tiêu Viêm; xóa file dư `assets/sprites/player/tieu_viem.png`.
  * [ ] Bổ sung BGM riêng cho Sa Mạc / Dung Nham / Thánh Thành / Cảnh chia ly.
  * [ ] Thiết lập cài đặt Đồ họa (Fullscreen/Độ phân giải), đổi phím (Key Rebinding), khởi tạo **Git**, cấu hình `export_presets.cfg` để build `.exe`/Web độc lập.

---

## 4. Danh Sách Lỗi & Nợ Kỹ Thuật Cần Sửa Sớm (Bug & Tech Debt Backlog)

| Mã | Mức độ | Vị trí mã nguồn | Mô tả vấn đề & Hướng khắc phục | Trạng thái |
| :--- | :---: | :--- | :--- | :---: |
| **BUG-01** | Cao | `scripts/autoload/audio_manager.gd` (`L65-73`) & `scripts/autoload/player_data.gd` (`L115-145`) | **Xung đột ghi đè `user://dptk_settings.json`**: Khi khởi động, `PlayerData.load_user_settings()` gọi `AudioManager.set_bgm_volume()` / `set_sfx_volume()` khiến `AudioManager._save_settings()` ghi đè file chỉ còn 3 trường âm thanh, làm mất `auto_save_enabled`, `auto_continue_on_start`, `last_played_slot`. Đồng thời `PlayerData.save_user_settings()` thiếu `is_muted`. **Khắc phục**: Gom đọc/ghi `dptk_settings.json` về một đầu mối duy nhất hoặc merge JSON trước khi ghi. | [ ] Mở |
| **BUG-02** | Cao | `scripts/entities/player_controller.gd` (`L480-488`) & `scripts/ui/hud_controller.gd` | **Đan dược Chương 03 không uống được**: `pill_bang_tam_dan` (+185 HP) và `pill_thanh_lien_tu` (+140 QI) đã định nghĩa là `consumable_hp`/`consumable_qi` nhưng phím `1/2/3` đang hardcode 3 viên Ch.01 và UI không có nút uống đan từ túi đồ. **Khắc phục**: Cho phép tự ưu tiên uống viên cao cấp hoặc thêm tab Nạp Giới Dược Phẩm bấm dùng trực tiếp / chọn gắn vào ô `1/2/3`. | [ ] Mở |
| **BUG-03** | Trung bình | `scripts/ui/hud_controller.gd` (`L1782-1795`) | **Tràn ngang Xưởng Hỏa Liên `[K]` ở Chế Độ DEMO**: 28 nút Hỏa đặt trong `HBoxContainer` khiến hàng nút tràn ra ngoài cửa sổ modal. **Khắc phục**: Đổi `HBoxContainer` thành `HFlowContainer` (hoặc `GridContainer` 4 cột). | [ ] Mở |
| **BUG-04** | Trung bình | `scripts/systems/alchemy_system.gd` (`L23-30`) & `scripts/ui/hud_controller.gd` (`L1860-2007`) | **Thưởng Dị Hỏa & Dược Đỉnh không tác động vào Mini-game Luyện Đan**: `get_success_chance()` chỉ dùng cho nút *Luyện Nhanh* (Phẩm 1), không mở rộng vùng xanh hoặc giảm tốc độ nguội khi chơi Mini-game (Phẩm 2–4). **Khắc phục**: Áp dụng `flame_bonus + gear_bonus + soul_diff` để mở rộng vùng Đan Tâm & giảm độ rung nhiệt trong mini-game. | [ ] Mở |
| **BUG-05** | Thấp | `scripts/systems/world_stage_manager.gd` (`L1016-1021`, `L1052-1114`) | Nhiệm vụ `q07_dot_pha_dau_gia` chưa có waypoint chỉ đường; `get_minimap_snapshot()` kiểm tra cổng mở bằng `has_flag()` thay vì dùng `_is_portal_unlocked()`. | [ ] Mở |
| **BUG-06** | Thấp | `scripts/entities/player_controller.gd` (`L856`) & `data/realms.json` (`L5`) | Hệ số sát thương gánh thêm khi bị áp chế cảnh giới bị hardcode `0.25` thay vì đọc `damage_taken_bonus_per_major_realm` (`0.30`) từ `GameDatabase.suppression_rules`. | [ ] Mở |
| **DOC-01** | Thấp | `docs/00_Tong_Quan_Kien_Truc/01_Art_Spec_Huong_Dan_Ve_Pixel.md` & comment đầu script | `01_Art_Spec` vẫn ghi `640×360` / `48×48` (game đã lên `1280×720` HD); vài comment đầu file `player_data.gd` và `world_stage_manager.gd` vẫn ghi "7 bản đồ / 15 mốc". | [ ] Mở |
| **OPS-01** | Trung bình | Thư mục gốc dự án | Chưa khởi tạo Git (`.git`) và chưa có `export_presets.cfg` để đóng gói bản phát hành. | [ ] Mở |

---

## 5. Lộ Trình Triển Khai Theo Mốc (Milestones)

### Mốc M1 — Ổn Định Nền & Dọn Bug (`v0.3.1`)
* [ ] Khởi tạo Git repository và commit mốc nền `v0.3.0`.
* [ ] Sửa trọn bộ `BUG-01` → `BUG-06`, dọn `DOC-01` và xóa file sprite thừa `tieu_viem.png`.
* [ ] Kiểm thử toàn tuyến Chương 01–03 từ phút 0 và kiểm thử Chế Độ DEMO / Auto-Save / Auto-Continue.

### Mốc M2 — Đào Sâu Cơ Chế Chiến Đấu & Hảo Cảm (`v0.3.5`)
* [ ] Lập trình nhóm hiệu ứng thực chiến `lotus_effect` cho Phật Nộ Hỏa Liên (tối thiểu toàn bộ nhóm lửa Ch.01–04 + top Dị Hỏa).
* [ ] Đa dạng hóa chiêu thức riêng cho 12 Boss hiện có (tách pattern Hải Ba Đông, Song Đầu Hỏa Linh Xà, Đan Vương Cổ Hà, Mục Xà...).
* [ ] Hoàn thiện `anim_sheet` 4 frame cho 6 Boss còn lại & Idle animation cho Tiêu Viêm.
* [ ] Kích hoạt thưởng Hảo Cảm theo mốc (buff/quà/đối thoại phụ) cho 5 Hồng Nhan hiện tại.
* [ ] Bổ sung nhạc nền Sa Mạc / Dung Nham và tùy chọn Fullscreen trong Menu cài đặt.

### Mốc M3 — Chương 04: Đế Đô & Ước Hẹn 3 Năm (`v0.4.0` — Trọn Quyển I)
* [ ] Thêm các bản đồ Chương 04: Diêm Thành / Mặc Gia Bảo, Đế Đô Gia Mã (Công Hội Luyện Dược Sư & Mễ Đặc Nhĩ), Quảng Trường Vân Lam Sơn.
* [ ] Thêm cơ chế Cải Trang Hắc Bào (**Nham Kiêu**), Mini-game Đấu Giá & **Đan Hội Gia Mã** (công thức `Tam Văn Thanh Linh Đan` đột phá lên **Đấu Linh**).
* [ ] Thêm Boss **Mặc Thừa**, **Nạp Lan Yên Nhiên** (Ước Hẹn 3 Năm), **Vân Lăng & Hộ Tông Đại Trận**, mở cổng sang Quyển II (Hắc Giác Vực).

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
