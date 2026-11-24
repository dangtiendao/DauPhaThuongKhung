# Đấu Phá Thương Khung — Top-down 2D HD Pixel Action RPG (Godot 4)

Dự án Fan-game phi thương mại / học tập lấy cảm hứng trọn vẹn từ tiểu thuyết **Đấu Phá Thương Khung** (Thiên Tằm Thổ Đậu), phát triển trên **Godot Engine 4 (GDScript)** với đồ họa **32-bit HD Pixel Art (`1280×720`, Physics Interpolation 60–144 FPS)**, giao diện **nút bấm MOBA trực quan**, **Data-Driven Story Engine**, và **tiến trình chuẩn nguyên tác qua trọn Quyển I + Mở màn Quyển II (`v0.5.0`): 25 bản đồ — 39 mốc nhiệm vụ chính (Chương 01 -> Chương 05: Hắc Giác Vực & Ngoại Viện Già Nam)**.

---

## 1. Cách Chạy Game Nhanh Nhất

1. **Chơi ngay**: Nhấp đúp file **`CHAY_GAME.bat`** trong thư mục dự án (`e:\Project\DauPhaThuongKhung\CHAY_GAME.bat`).
2. **Mở trình soạn thảo Godot Editor**: Nhấp đúp file **`MO_GODOT_EDITOR.bat`** (hoặc mở Godot 4 -> Import `project.godot` -> nhấn `F5`).
3. **Chạy bộ kiểm thử tự động (722 assertions)**: Chạy **`tests\run_tests.bat`** (hoặc `Godot --headless --path . res://tests/test_runner.tscn`).
4. **Đóng gói Windows `.exe`**: Cấu hình sẵn preset **`Windows Desktop`** trong `export_presets.cfg` (tích hợp `icon.ico`, nhúng `.pck`, xuất ra `builds/DauPhaThuongKhung.exe`).

---

## 2. Lộ Trình Chuẩn Nguyên Tác (25 Bản Đồ — 39 Mốc Cốt Truyện — 43 Quái & 23 Boss Độc Chiêu)

Khởi đầu **Phút 0**, Tiêu Viêm đứng tại **Quảng Trường Tiêu Gia** với **Đấu Chi Khí 3 Đoạn**, **Tay Không** (chưa có vũ khí, chưa thức tỉnh Dược Lão, chưa mở Lò Luyện Đan `[L]` / Dị Hỏa `[H]`, chưa có Đấu Kỹ hay Phật Nộ Hỏa Liên):

### Chương 01 — Ô Thản Thành (3 Bản Đồ · NV 1–9)
1. **Quảng Trường & Đại Sảnh Tiêu Gia (`ch01_tieu_gia`)**:
   - Chạm **Trắc Nghiệm Ma Thạch Bi `[V]`** kiểm tra cảnh giới thời gian thực (đổi lời bình theo cấp từ Tam Đoạn Đê Cấp đến Đấu Sư Chấn Động Ô Thản Thành!).
   - Gặp phụ thân **Tiêu Chiến**, **Tiêu Huân Nhi** (tăng Hảo Cảm), và giải quyết **Đại Sảnh Từ Hôn — Nạp Lan Yên Nhiên** (nhận Kỳ Vật *Ấn Ký Tôn Nghiêm +5% ATK*).
   - **Kỳ Ngộ Ẩn**: Sau khi Dược Lão thức tỉnh, gặp **Bóng Đen Thần Bí (Lăng Ảnh — Đấu Hoàng Ám Vệ)** góc Tây Bắc với **2 lựa chọn đối thoại** để nhận *Hắc Ảnh Phù (+8% Tốc Chạy)* & Linh Hồn Lực.
   - Đánh bại Boss **Tiêu Ninh** tại Lễ Thành Niên học **`[E]` Bát Cực Băng**, rồi gặp **Nhược Lâm Đạo Sư (Học Viện Già Nam)** nhận *Già Nam Ngọc Bài* (2 năm nghỉ phép)!
2. **Rừng Trúc & Vách Đá Hậu Sơn (`ch01_hau_son`)**:
   - Lên Vách Đá bấm `[V]` thức tỉnh & bái sư **Dược Trần (Dược Lão)** -> mở khóa **Lò Luyện Đan `[L]`**, **Phàm Hỏa `[H]`**, **`[Q]` Toái Thạch Chưởng**.
   - Săn **Hoang Dã Sơn Lang**, **Thiết Bối Sơn Trư**, và so chiêu Mini-Boss **Biểu Tỷ Tiêu Ngọc** (xuất hiện sau khi mua Hấp Chưởng).
3. **Phố Chợ Ô Thản Thành & Biệt Viện Gia Liệt Gia (`ch01_o_than_thanh`)**:
   - Ghé **Phòng Đấu Giá Mễ Đặc Nhĩ** gặp **Nhã Phi `[V]`** mua *Hấp Chưởng*, *Bạo Bộ*, *Thanh Thiết Kiếm*, *Tinh Cương Chiến Đao* hoặc tham gia **Đấu Giá Đấu Trí & Ký Gửi**.
   - Luyện **Tụ Khí Tán** đột phá **Đấu Giả**, hạ **Nhất Phẩm Dược Sư Liễu Tịch** (Lăng Ảnh xóa dấu vết) & **[BOSS CHƯƠNG 1] Gia Liệt Áo** để nhận **Huyền Trọng Xích**, **`[T]` Cốt Linh Phụ Thể**, Đồng Hành **`[G]` Hồn Ảnh Dược Lão** và mở cổng sang Chương 02!

### Chương 02 — Ma Thú Sơn Mạch (4 Bản Đồ · NV 10–15)
4. **Thanh Sơn Trấn — Vạn Dược Trai & Rừng Ngoại Vi (`ch02_ma_thu_son_mach`)**:
   - Gặp **Tiểu Y Tiên `[V]`** (gia nhập Đồng Hành `[G]`, học **`[R]` Diễm Phân Phệ Lãng Xích**) & **Thiếu Đoàn Trưởng Mục Lực** (giai đoạn đầu thân thiện, sau khi có Tử Hỏa trở thành Boss phục kích!).
   - Săn **Hỏa Tinh Viên** & **Tinh Anh Lang Đầu Đoàn**, kết nối 3 phân khu bí cảnh của Chương 02.
5. **Huyền Nhai Sơn Động — 3 Thạch Thất Kỳ Ngộ (`ch02_huyen_nhai_dong`)**:
   - Đánh bại **[BÍ CẢNH] Hộ Động Thạch Khôi** để mở trọn bộ **3 Thạch Thất**:
     - *Thạch Thất Trái*: Bí tịch **Cuồng Sư Ngâm (Âm Ba Công)** làm choáng 1.8s.
     - *Thạch Thất Giữa*: **Thất Thải Độc Kinh** (`+30` Hảo Cảm Tiểu Y Tiên).
     - *Thạch Thất Phải*: **Hộp Ngọc Tử Vân Dực** (tự động trang bị, nâng cấp `[Space]` thành **Lướt Tử Vân Dực** tốc độ cao + I-frame dài!), Đấu Kỹ **Tử Vân Dực Kích**, và **Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (1/4)**.
6. **Bờ Suối Trăng Bạc & Hang Sư Vương (`ch02_noi_vi_su_vuong`)**:
   - Gặp **Vân Chi (Vân Vận)** bên Bờ Suối Trăng Bạc với **Đối Thoại 2 Lựa Chọn Nướng Cá** (*Nướng thảo mộc +30 Hảo Cảm* hoặc *Kỳ ngộ hài hước lọ bột hồng Dược Lão!*).
   - Tiến vào Hang Tím hạ **[BOSS] Tiểu Tử Tinh Dực Sư Vương** đoạt *Tử Tinh Nguyên*, quay lại gặp Vân Chi thôn phệ **Tử Tinh Thú Hỏa** & nhận **Hải Tâm Giáp (Địa Phẩm)**!
   - Đột phá lên **Đấu Sư** tự động kích hoạt vòng hộ thể **Đấu Khí Sa Y** (`+18% DEF`, `-18%` sát thương nhận vào!).
7. **Thác Nước Nghìn Trượng & Thung Lũng U Lan (`ch02_thac_nuoc_muc_xa`)**:
   - Quyết chiến 1v1 **[BOSS CHƯƠNG 2] Đoàn Trưởng Mục Xà (Nhị Tinh Đấu Sư)** -> lĩnh ngộ Bí Pháp **Thiên Hỏa Tam Huyền Biến**.
   - Bước vào **Thung Lũng U Lan** gặp **Tiểu Y Tiên (Ách Nan Độc Thể)** với **2 lựa chọn chia ly cảm động**, mở cổng Đông sang **Chương 03 — Sa Mạc Tháp Qua Nhĩ**!

### Chương 03 — Sa Mạc Tháp Qua Nhĩ (4 Bản Đồ · NV 16–21)
8. **Thạch Mạc Thành & Mạc Thiết Đoàn (`ch03_thach_mac_thanh`)**:
   - Đoàn tụ Đại ca **Tiêu Đỉnh**, Nhị ca **Tiêu Lệ** và an ủi thiếu nữ hai dòng máu **Thanh Lân** (**2 lựa chọn đối thoại** thức tỉnh *Bích Xà Tam Hoa Đồng* mở Hố Cát Bắc).
   - Xuống Tiệm Bản Đồ Cổ góc Tây Nam đấu **[BOSS] Băng Hoàng Hải Ba Đông (Phong Ấn)** rồi ký giao ước nhận **Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (2/4)** & *Hàn Băng Chi Tâm*.
   - Săn **Sa Độc Hạt Vương** & **Chiến Binh Xà Nhân** ở biển cát phía Đông hái **Sa Chi Mạn Đà La** luyện **Băng Tâm Đan** & **Phá Chướng Đan** `[L]`.
9. **Địa Huyệt Sông Dung Nham Ngầm (`ch03_dia_huyet_dung_nham`)**:
   - Đánh bại **[BOSS] Song Đầu Hỏa Linh Xà** (Ma Thú Cấp 4 Đỉnh Phong) trên nền nham thạch nóng chảy để tiến ra Đảo Sen Ngọc Bích đào **Thanh Liên Đài** (`+15% EXP & +40% Hồi QI` vĩnh viễn) & **11 Hạt Thanh Liên Tử**!
10. **Thánh Thành Xà Nhân & Thánh Trì (`ch03_thanh_thanh_xa_nhan`)**:
    - Đánh tan **[BOSS] Đại Thống Lĩnh Mặc Ba Tư** và **[BOSS] Đan Vương Cổ Hà** (Lục Phẩm).
    - Gặp lại cố nhân **Vân Vận (Tông Chủ Vân Lam Tông)** giữa bão cát với **2 lựa chọn xúc động** khi nàng nhận ra chiếc *Hải Tâm Giáp* và nghiêng mũi kiếm mở lối!
    - Tiến lên Đảo Thánh Trì chứng kiến **Nữ Vương Mỹ Đỗ Toa Độ Kiếp Thiên Lôi**, cướp gọn **Hỏa Chủng Thanh Liên Địa Tâm Hỏa** & con **Thất Thải Thôn Thiên Mãng**!
11. **Ốc Đảo Diêm Lệ — Thôn Phệ Dị Hỏa (`ch03_oc_dao_diem_le`)**:
    - Gặp **Dược Lão `[V]`** cử hành **Nghi Thức Thôn Phệ #19 Thanh Liên Địa Tâm Hỏa** (2 lựa chọn *Băng Tâm Đan* hoặc *Ý Chí Ước Hẹn 3 Năm*) -> lột xác thành lửa Xanh Ngọc Bích (*Phần Quyết Huyền Giai Trung Cấp*), mở khóa **Thần Thú Đồng Hành `[G]` Thải Lân** (bắn tia 7 màu & Hộ Chủ cứu nguy khi HP < 35%), và **KHAI SINH TUYỆT KỸ TỐI THƯỢNG `[F]` PHẬT NỘ HỎA LIÊN** (tự động dung hợp Song Hỏa *Tử Hỏa + Thanh Liên Hỏa*!).

### Chương 04 — Đế Đô Phong Vân & Ước Hẹn 3 Năm Vân Lam Sơn (8 Bản Đồ · NV 22–31 · Kết Quyển I)
12. **Diêm Thành — Mặc Gia Trang & Địa Lao Ngầm (`ch04_mac_gia_trang`)**: Đột phá **Đại Đấu Sư** mở **Đấu Khí Khải Giáp & Kiếm Khí Ngoại Phóng**, dùng *Phá Ách Đan* giải phong ấn Băng Hoàng Hải Ba Đông, cứu Thanh Lân, nổ xác **[BOSS] Quái Nhân Mặc Thừa** bằng Song Sắc Hỏa Liên & chứng kiến **Dược Lão chìm vào giấc ngủ say** (tạm khóa `[T]`).
13. **Gia Mã Thánh Thành — Tổng Bộ Mễ Đặc Nhĩ (`ch04_gia_ma_de_do`)**: Trùng phùng Nhã Phi nhận Mặt Nạ Dịch Dung **"Nham Kiêu"**, đánh gục **[MINI-BOSS] Mộc Chiến**, nhận Nhiệm Vụ Phụ chỉnh đốn nội tộc Mễ Đặc Nhĩ (thưởng *Xích Dương Dược Đỉnh*), và mở **Easter Egg Khách Điếm Mỹ Đỗ Toa / Thải Lân**.
14. **Nạp Lan Vương Phủ (`ch04_nap_lan_vuong_phu`)**: Dùng Thanh Liên Hỏa rút Lạc Độc cứu Nạp Lan Kiệt -> nhận *Thất Huyễn Thanh Linh Tiên* & lĩnh ngộ Đấu Kỹ **`Lạc Độc Ám Chưởng`** (`-30% DEF` 10s + Độc Nổ Lan).
15. **Quảng Trường Đại Hội Luyện Đan Sư (`ch04_quang_truong_dan_hoi`)**: Lật tẩy đánh bại **[BOSS] Viêm Lợi (Xuất Vân)** & luyện thành công **`Tam Văn Thanh Linh Đan`** trong `[L]` đăng quang **Quán Quân Đan Hội Gia Mã**!
16. **Thiên Thang 999 Bậc (`ch04_thien_thang_van_lam`)** & **Đỉnh Vân Lam Sơn (`ch04_dinh_van_lam_son`)**: Xé mặt nạ *Nham Kiêu* chấn động toàn Đế Quốc, 1v1 đánh bại **[BOSS] Nạp Lan Yên Nhiên** trả tờ Hưu Thư, phá **[BOSS] Vân Yên Phúc Nhật Đại Trận** triệu hồi **Đấu Tông Mỹ Đỗ Toa** giáng thế (nâng cấp **`[T]` Đấu Tông Mỹ Đỗ Toa Hộ Pháp**!), và **Đệ Nhị Thượng Vân Lam** nổ xác **[BOSS] Đại Trưởng Lão Vân Lăng** dưới áp lực Đấu Tông Vân Sơn!
17. **Phế Tích Tiêu Gia (`ch04_phe_tich_tieu_gia`)**: Điều tra **Tàn Dư Hắc Vụ Xiềng Xích (Manh Mối Hồn Điện)**, làm Nhiệm Vụ Phụ cùng Tiêu Lệ mở nội tại vĩnh viễn **`Tiêu Tộc Nộ Huyết` (+15% ATK vs Vân Lam & Hồn Điện)**.
18. **Rừng Phong Tỏa & Biên Ải Trấn Quỷ Quan (`ch04_rung_phong_toa`)**: Lăng Ảnh cản chân Đấu Tông Vân Sơn (Kỳ Ngộ Ẩn từ Chương 01 trao **`Kim Viêm Hộ Hồn Ngọc`** tự động hồi sinh 1 lần 50% HP!), phá vòng vây **[BOSS] Hư Ảnh Đấu Tông Vân Sơn**, đoạn tình **Vân Vận** ở Hẻm Núi Lá Đỏ & lập **Lời Thề Thệ Diệt Vân Lam** mở đường tiến vào Quyển II!

### Chương 05 — Hắc Giác Vực & Ngoại Viện Già Nam (6 Bản Đồ · NV 32–39 · Mở Màn Quyển II)
19. **Hẻm Núi Hắc Phong (`ch05_hem_nui_hac_phong`)**: Đột phá **Đấu Linh** mở cơ chế **Đấu Khí Ngưng Vật** (`+42% DEF`, `+15%` lực phá thế & `+20%` tầm đánh), đánh tan vòng vây truy binh Vân Lam Tông và hạ **[BOSS] Chấp Sự Vân Phàn**.
20. **Rừng Đêm Huyết Vụ (`ch05_rung_dem_huyet_vu`)**: Đụng độ Doanh Trại Huyết Tông cùng Thải Lân, trảm **[BOSS] Thiếu Tông Chủ Phạm Lăng**, đoạt thân pháp Địa Giai **`Tam Thiên Lôi Động`** (tự động nâng cấp Lướt né `[Space]` lóe sấm sét!) & kích hoạt bí pháp **`Hỏa Liên Phân Thân`**.
21. **Hắc Ấn Thành — Đấu Giá Bát Phiến Môn (`ch05_hac_an_thanh`)**: Dược Lão tái tỉnh, tham gia **Đại Đấu Giá Trường Bát Phiến Môn** (Mini-game Đấu Giá Đấu Trí + Thăm Dò & Uy Áp Linh Hồn), thu **Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa (3/4)** & vật phẩm *Huyết Ngưng Đan / Đấu Linh Đan / Âm Dương Huyền Long Đan*.
22. **Hòa Bình Trấn — Ranh Giới Già Nam (`ch05_hoa_binh_tran`)**: Chiêm ngưỡng Bia Cổ Viện Trưởng **Mang Thiên Xích**, giao thương với thương nhân Gia Mã và chuẩn bị tiến vào Học Viện Già Nam.
23. **Ngoại Viện Học Viện Già Nam (`ch05_ngoai_vien_gia_nam`)**: Trùng phùng **Tiêu Huân Nhi** (gia nhập **Đồng Hành AI #4 `[G]`** với *Kim Đế Phần Thiên Viêm* & hồi Đấu Khí!), giao đấu Tuyển Chọn Top 5 hạ **[BOSS] Tu La Huyết Kiếm Ngô Hạo**, tiến vào Tàng Thư Các gặp Phó Viện Trưởng **Hổ Càn** lĩnh ngộ **`Sư Hổ Toái Kim Ngâm`** và **`Đế Ấn Quyết — Khai Sơn Ấn`**!
24. **Rừng Săn Hỏa Năng (`ch05_rung_san_hoa_nang`)**: Phản sát đội lão sinh săn tân sinh do **[BOSS] La Hầu (Hắc Sát Đội)** dẫn đầu, tích lũy **240 Hỏa Năng**, diện kiến Đại Trưởng Lão **Tô Thiên** hoàn tất Chương 05 và mở cổng chờ sang **Chương 06: Nội Viện & Thiên Phần Tháp**!

---

## 3. Tính Năng Gameplay Nổi Bật (v0.5.0)

* **Chiến đấu 60–144 FPS & Chiều sâu Combat**: 2D Physics Interpolation, Input Buffer, Hitstop toàn cục, Camera Look-Ahead, **Thanh Phá Thế Boss (Poise/Stagger)** (`+35%` DMG khi vỡ thế), **Độ Thông Thạo 15 Đấu Kỹ** (`Sơ Khuy → Tiểu Thành → Đại Thành → Đỉnh Phong`), 7 mẫu AI quái thường (`chaser`, `charger`, `artillery`, `burrower`, `bomber`, `shieldbearer`, `dummy`) và 23 Boss độc chiêu có VFX 60 FPS + Thời tiết động theo vùng.
* **Khảm Ma Hạch 3 Rãnh & Trang Bị 10 Ô `[I]`**: 31 mẫu trang bị, 6 phẩm chất, 5 bộ Set (*Tiêu Gia → Ma Thú → Sa Mạc → Đế Đô → Tân Sinh Vương Già Nam*), cường hóa `+0 → +15` và **khảm trực tiếp Ma Hạch Cấp 1–5** lên 3 rãnh Vũ Khí (tăng ATK, Crit, Phá Thế, Hút Máu, Thiêu Đốt).
* **Lò Luyện Đan `[L]` & Đấu Giá Đấu Trí + Ký Gửi**: 12 đan phương Phẩm 1–7 có Mini-game canh Hỏa Hầu + Chắn Đan Lôi; 2 đấu trường **Mễ Đặc Nhĩ (Nhã Phi)** & **Bát Phiến Môn** cho phép soi ngân sách bằng **Thăm Dò Linh Hồn**, ép giá bằng **Uy Áp Linh Hồn** và **Ký Gửi** đan dược/ma hạch lấy lời `1.25× – 1.85×`.
* **Endgame & Khám Phá**:
  * **Thiên Phần Luyện Khí Tháp (Roguelite)** trong `[M]`: Leo tầng vô tận, chịu Tâm Hỏa chước đốt, chọn **1/3 Chúc Phúc** mỗi tầng, đổi **Tinh Hỏa Năng**.
  * **Tâm Ma Luyện Cảnh** trong `[M]`: Tái đấu toàn bộ **23 Boss** ở 3 độ khó (`Thường / Ác Mộng / Đấu Tông`), chấm hạng `C → SSS`, thưởng Đá Cường Hóa & Kim Tệ.
  * **Đồ Giám Vạn Thú (43 loài)**, **Hệ thống Hồng Nhan Tri Kỷ (5 Hồng Nhan · 4 mốc Buff)** & **Radar Linh Hồn `[Z]`** quét rương ẩn / lộ hình địch.

---

## 4. Giao Diện MOBA & Hệ Thống Điều Khiển

Toàn bộ chiêu thức, kỹ năng cơ động, đan dược và 8 bảng hệ thống đều được **đóng khung ô MOBA bấm trực tiếp bằng chuột** (có lớp quét hồi chiêu thời gian thực & Tooltip khi di chuột), hỗ trợ **Đổi Phím Tùy Chỉnh (Key Rebinding)** trong `[ESC]`:

| Phím Mặc Định / Ô Bấm | Chức năng trong Game |
| :--- | :--- |
| `W A S D` / Phím mũi tên | Di chuyển 8 hướng |
| `V` hoặc `Enter` *(Ô `[V]`)* | **Tương tác gần nhất** (NPC / Ma Thạch Bi / Đấu Giá / Bảo Rương / Cổng Chuyển Bản Đồ) |
| `Chuột Trái (LMB)` | Đánh thường Combo 3 nhịp (Tay Không Quyền Cước -> Vũ Khí liền thân + SFX riêng) |
| `Q` / `E` / `R` / `F` / `T` | **15 Đấu Kỹ** tự do lắp trong `[K]`, **Phật Nộ Hỏa Liên** `[F]` & **Dược Lão / Mỹ Đỗ Toa Hộ Pháp** `[T]` |
| `Space` *(Ô `[SPC]`)* | Thân pháp Lướt né có I-frame *(tiến hóa: Lướt thường -> **Tử Vân Dực** -> **Tam Thiên Lôi Động**!)* |
| `Chuột Phải (RMB)` / `C` | Bật/Tắt **Phong Ấn Trọng Xích** (`-15% SPD, +30% EXP` khi đeo Huyền Trọng Xích) |
| `G` | **Triệu Hồi / Chuyển 4 Đồng Hành AI** (*Dược Lão* / *Tiểu Y Tiên* / *Thải Lân* / *Tiêu Huân Nhi*) |
| `Z` | **Radar Linh Hồn** — Phóng sóng cảm ứng rương báu ẩn & lộ hình kẻ địch |
| `1` / `2` / `3` | Uống nhanh: *Đan HP* / *Đan Đấu Khí* / *Đan EXP* (tự chuyển đan cao cấp khi hết) |
| `I` / `K` / `B` / `L` / `H` | Trang Bị 10 Ô & Khảm Ma Hạch / Kho 15 Đấu Kỹ & Hỏa Liên / Đột Phá / Lò Luyện Đan / Dị Hỏa Bảng |
| `M` | **Thế Giới (25 Map · Ch.01–05)** · **5 Hồng Nhan** · **Tâm Ma (23 Boss)** · **Thiên Phần Tháp** · **Đồ Giám** |
| `ESC` / `F5` / `F9` | Menu Tạm Dừng (**Đổi Phím**, **Hiển Thị Fullscreen/VSync/FPS/Shake**, **Auto-Save**, **DEMO**, Save/Load 3 Ô) / Lưu / Tải nhanh |

---

## 5. Chế Độ DEMO (Mở Khóa Tất Cả) & Tự Động Lưu / Chơi Tiếp

### Option 1 — ★ Chế Độ DEMO (Mở Khóa Tất Cả)
* **Bật từ Màn Hình Chính**: Bấm **`★ CHẾ ĐỘ DEMO — MỞ KHÓA TẤT CẢ (25 MAP · FULL ĐỒ)`** (tự động chạy riêng trên **Ô Lưu 3** để bảo toàn tuyệt đối bản lưu chuẩn cốt truyện ở **Ô 1 & Ô 2**), hoặc bật ngay trong game qua **`[ESC] -> ★ Bật Chế Độ DEMO`** hay chọn nút **`Demo`** ở từng ô trong *Quản Lý 3 Ô Lưu*.
* **Toàn bộ nội dung mở sẵn**:
  * Toàn bộ **25 Bản Đồ (Chương 01–05)** mở cổng + nút bấm **`Dịch Chuyển ->`** 1 chạm ngay trong **`[M]`**, vẫn giữ nguyên các **Boss** để vào đánh thử thoải mái!
  * Cảnh giới **Đấu Linh — 9 Tinh (Đỉnh Phong)** kích hoạt sẵn **Đấu Khí Ngưng Vật** (sẵn sàng đột phá Đấu Vương), đủ **15 Đấu Kỹ**, **`[T]` Hộ Pháp**, trọn bộ **28 loại Hỏa `[H]`** (lắp sẵn 4 ngọn Hỏa dung hợp trong **`[F]` Phật Nộ Hỏa Liên**), trọn bộ **4 Đồng Hành AI `[G]`** (kèm **Tiêu Huân Nhi**), **10 ô trang bị Thiên Phẩm + 3 Ma Hạch khảm sẵn**, **3/4 Mảnh Tàn Đồ Yêu Hỏa**, **240 Hỏa Năng**, **x20** toàn bộ đan dược & thảo dược, **50.000 Kim Tệ**, **999 Đá Cường Hóa**, và **100/100 Hảo Cảm** 5 Hồng Nhan.

### Option 2 — Tự Động Lưu & Tự Động Chơi Tiếp (Auto-Save & Auto-Continue)
* **Lưu cài đặt vĩnh viễn** trong `user://dptk_settings.json` (gồm cả phím tùy chỉnh, hiển thị và âm lượng), có 2 công tắc bật/tắt ngay trên **Màn Hình Chính** và **Menu Tạm Dừng `[ESC]`**:
  1. **Tự Động Lưu Dữ Liệu (Auto-Save)** *(mặc định BẬT)*: Tự động lưu ngầm vào ô đang chơi mỗi **30 giây**, khi **chuyển bản đồ**, **đột phá**, **hoàn thành nhiệm vụ / mốc cốt truyện**, **mở bảo rương**, khi **về Màn Hình Chính**, và cả khi **đóng cửa sổ game (`X`)**, lưu chính xác **tọa độ đứng `(x, y)`**.
  2. **Tự Động Vào Chơi Tiếp Bản Lưu Gần Nhất Lần Sau**: Khi bật, lần mở game tiếp theo sẽ hiện thanh đếm ngược ngắn (`1.6s`, có nút **Hủy**) rồi tự động tải thẳng vào **Ô Lưu chơi gần nhất** đúng bản đồ và đúng vị trí bạn vừa dừng!

---

## 6. Cấu Trúc Thư Mục Dự Án

* `docs/` — **25 Tài liệu Thiết kế Game (GDD) & Tiến Độ** chia chi tiết 11 Chương (4 Quyển), 23 Dị Hỏa, 12 Cảnh giới, Đấu Kỹ, Luyện Đan, Quái & 25 Boss, kèm bảng theo dõi tiến độ & lộ trình phát triển tại [`docs/00_Tong_Quan_Kien_Truc/02_Tien_Do_Va_Lo_Trinh_Phat_Trien.md`](docs/00_Tong_Quan_Kien_Truc/02_Tien_Do_Va_Lo_Trinh_Phat_Trien.md).
* `data/` — **16 Cơ sở dữ liệu JSON** (`maps.json`, `maps_ch04.json`, `maps_ch05.json` — 25 map; `quests_ch01/04/05.json` — 39 NV chính; `dialogues_ch04/05.json`; `enemies.json`, `enemies_ch04/05.json` — 43 quái/23 Boss; `realms.json`, `flames.json`, `skills.json`, `alchemy_items.json`, `equipment.json`).
* `assets/` — **146 tài nguyên 32-bit HD Pixel Art & Shader** (chuẩn mặc định **8 frame**: trọn bộ **31/31 spritesheet hoạt ảnh** gồm 8 sheet Tiêu Viêm `idle/run/cast/dash/4×attack` và trọn bộ **23/23 Boss `*_boss_anim.png`** đều là **8 frame** `4×2`/`8×1`; **23 NPC**, **31 icon MOBA** (15/15 Đấu Kỹ có icon riêng), **12 tileset vùng** gồm Đế Đô / Vân Lam Sơn / Hắc Giác Vực / Già Nam, props/VFX và `assets/shaders/di_hoa_palette.gdshader`).
* `scripts/` & `scenes/` — **32 script GDScript** (đã tách mô-đun `SaveLoadManager`, `BossRushManager`, `ThienPhanTowerManager`, `StoryDialogueRunner`, 6 panel UI trong `scripts/ui/panels/`, `AuctionSystem`, `AlchemySystem`, `EquipmentSystem`, **7 BGM ngũ cung Procedural** & 20+ SFX) & **9 scene `.tscn`**.
* `tests/` — Bộ kiểm thử tự động Godot headless (`tests/test_runner.tscn`, `tests/test_suite.gd`, `tests/run_tests.bat`) kiểm tra JSON schema, tồn tại asset `res://`, liên thông BFS 25 bản đồ, `alchemy_max_tier`, Save/Load, DEMO & live UI/Endgame.
* `tools/` — Công cụ tự động chuẩn hóa spritesheet `tools/normalize_spritesheet.py`.
* `export_presets.cfg` & `icon.ico` — Cấu hình đóng gói Windows x64 (`GL Compatibility`) độc lập.
