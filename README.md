# Đấu Phá Thương Khung — Top-down 2D HD Pixel Action RPG (Godot 4)

Dự án Fan-game phi thương mại / học tập lấy cảm hứng trọn vẹn từ tiểu thuyết **Đấu Phá Thương Khung** (Thiên Tằm Thổ Đậu), phát triển trên **Godot Engine 4 (GDScript)** với đồ họa **100% 32-bit HD AI Pixel Art (`1280×720`, 56/56 True 8-Frame AI, Physics Interpolation & VFX 2.0 Shader 60–144 FPS)**, giao diện **nút bấm MOBA trực quan**, **Data-Driven Story Engine**, **14 Bản Nhạc Nền Ngũ Cung Địa Vực**, và **tiến trình chuẩn nguyên tác TRỌN BỘ 100% QUYỂN I, QUYỂN II & QUYỂN III (`v0.8.0`): 53 bản đồ — 76 mốc nhiệm vụ chính (Chương 01 -> Chương 09: Huyết Chiến Vong Hồn Cứu Dược Lão, Niết Bàn Đấu Tôn Xé Rách Không Gian, Hoa Tông, Di Tích Tạo Hóa Thánh Cốt, Phục Sinh Bán Thánh Dược Trần, Hư Không Lôi Trì & Cổ Long Đảo, Cổ Giới & Bí Cảnh Thiên Mộ x5 EXP, Cửu Chuyển Đấu Tôn & Tộc Văn Tiêu Tộc `[X]`)**.

---

## 1. Cách Chạy Game Nhanh Nhất

1. **Chơi ngay**: Nhấp đúp file **`CHAY_GAME.bat`** trong thư mục dự án (`e:\Project\DauPhaThuongKhung\CHAY_GAME.bat`).
2. **Mở trình soạn thảo Godot Editor**: Nhấp đúp file **`MO_GODOT_EDITOR.bat`** (hoặc mở Godot 4 -> Import `project.godot` -> nhấn `F5`).
3. **Chạy bộ kiểm thử tự động (1.731 assertions · 14 Suites)**: Chạy **`tests\run_tests.bat`** (hoặc `Godot --headless --path . res://tests/test_runner.tscn`).
4. **Đóng gói Windows `.exe`**: Cấu hình sẵn preset **`Windows Desktop`** trong `export_presets.cfg` (`0.8.0.0`, tích hợp `icon.ico`, nhúng `.pck`, xuất ra `builds/DauPhaThuongKhung.exe`).

---

## 2. Lộ Trình Chuẩn Nguyên Tác (53 Bản Đồ — 76 Mốc Cốt Truyện — 93 Quái & 48 Boss Độc Chiêu)

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
24. **Rừng Săn Hỏa Năng (`ch05_rung_san_hoa_nang`)**: Phản sát đội lão sinh săn tân sinh do **[BOSS] La Hầu (Hắc Sát Đội)** dẫn đầu, tích lũy **240 Hỏa Năng**, diện kiến Đại Trưởng Lão **Tô Thiên** hoàn tất Chương 05 và tiến thẳng qua cổng Đông vào **Nội Viện Già Nam**!

### Chương 06 — Nội Viện Già Nam & Đáy Tháp Thiên Phần (6 Bản Đồ · NV 40–47 · Thế Lực Bàn Môn & Dị Hỏa #14)
25. **Trang Viên Bàn Môn & Phố Giao Dịch Nội Viện (`ch06_noi_vien_ban_mon`)**: Dẹp **[MINI-BOSS] Bạch Thành (Bạch Bang)**, đấu đan khuất phục **Hàn Nhàn (Dược Bang)** thành lập **Thế Lực Bàn Môn** (mở tab **`🏯 Bàn Môn`** trong `[M]` với 3 Phân Đường nâng cấp Cấp 0→3: *Đan Đường*, *Võ Đường*, *Ám Đường* + thu hoạch thụ động Tinh Hỏa Năng/Kim Tệ/Ma Hạch).
26. **Hậu Sơn Dược Tài & Thung Lũng Tuyết Ma (`ch06_hau_son_duoc_vien`)**: Dùng *Đan Hoàn Ngọt* thu phục **Tiểu Man Vương Tử Nghiên** gia nhập **Đồng Hành AI #5 `[G]`** (*Cổ Long Nhất Quyền* gây Choáng + tăng `+45%` Radar Linh Hồn & Tầm Hút Đồ + phái đi tầm bảo trong Ám Đường!), hạ **[BOSS] Tuyết Ma Thiên Viên** đoạt *Địa Tâm Tôi Thể Nhũ* (`+15% DEF`, `+1200 HP`) & luyện Lục Phẩm **`Địa Linh Đan`**.
27. **Đấu Trường Cường Bảng Nội Viện (`ch06_dau_truong_cuong_bang`)**: Kịch chiến kinh thiên động địa với **[BOSS] Bá Thương Liễu Kình (Cường Bảng #3)** -> kết nghĩa huynh đệ, kết giao **Lâm Tu Nhai (#2)**, nhận vé Top 10 & lĩnh ngộ Địa Giai Đấu Kỹ **`Đại Liệt Phách Quan Trảo`**!
28. **Thiên Phần Luyện Khí Tháp Tầng 7–9 (`ch06_thien_phan_noi_thap`)**: Gặp Đại Trưởng Lão **Tô Thiên** (kèm nhiệm vụ phụ chữa Hỏa Độc) & ký ức phản sư **Dược Lão** (`+25%` sát thương vs Hàn Phong & Hồn Điện), kích hoạt biến cố **Đại Bạo Động Thiên Phần Tháp** bị Đại Xà Vẫn Lạc Tâm Viêm kéo thẳng xuống đáy vực!
29. **Vực Thẳm Dung Nham Đáy Tháp (`ch06_vuc_tham_dung_nham`)**: Hiệp lực cùng Dược Lão đánh bại **[BOSS] Bản Thể Đại Xà Vẫn Lạc Tâm Viêm (#14)** (nhấp nháy bán vô hình, bị `[Z]` Radar soi lộ hình!), trải qua biến cố định mệnh cùng **Nữ Hoàng Mỹ Đỗ Toa (Đấu Tông)**, dung hợp Song Dị Hỏa **`Lưu Ly Liên Tâm Hỏa (#19 + #14)`**, mở nội tại **`Tu Luyện Gian Lận Khí 24/7`** (+EXP & +4% QI/giây, mỗi 5 đòn nổ *Tâm Hỏa Nội Thiêu* Sát Thương Chuẩn!), lĩnh ngộ **`Lưu Ly Liên Tâm Ấn`** và đột phá **Đấu Vương Đỉnh Phong — Đấu Khí Hóa Dực** (đôi cánh lưu ly xanh-tím động sau lưng + nâng cấp bay lướt `[Space]`)!
30. **Bầu Trời Nội Viện Chiến Hỏa (`ch06_bau_troi_noi_vien`)**: Không chiến thanh toán phản đồ sư môn **[FINAL BOSS CH.06] Dược Hoàng Hàn Phong (Hải Tâm Diễm #15)** giữa vòng bảo hộ Đấu Tông Mỹ Đỗ Toa & liên quân Già Nam -> nhận tin dữ Tiêu Gia mở đường sang **Chương 07: Tam Thượng Vân Lam Sơn**!

### Chương 07 — Tam Thượng Vân Lam Sơn & Xuất Vân Độc Tông (7 Bản Đồ · NV 48–56 · Khép Lại Trọn Quyển II)
31. **Đỉnh Núi Hậu Viện Già Nam (`ch07_dinh_nui_chia_ly`)**: Chia tay **Tiêu Huân Nhi** trước Hắc Yên Thông Đạo Cổ Tộc -> nhận tầng 2 Đế Ấn Quyết **`Phiên Hải Ấn`** (*Cộng Hưởng 1.8× Bạo Kích* khi nối chiêu sau *Khai Sơn Ấn*!) và tin tình báo từ **Lăng Ảnh**.
32. **Đại Viện Mễ Đặc Nhĩ & Quảng Trường Viêm Minh (`ch07_de_do_me_dac_nhi`)**: Giải vây **Hải Ba Đông & Đại ca Tiêu Đỉnh**, bế quan Sinh Tử Môn đột phá **ĐẤU HOÀNG** (*Điều Động Thiên Địa Năng Lượng* + Cánh Hoàng Kim Lưu Ly) & lĩnh ngộ **`Thiên Hỏa Tam Huyền Biến — Nhị Biến`**; lập **Đế Quốc VIÊM MINH** (nâng cấp Bàn Môn → **`👑 Viêm Minh`** 4 Đường Đế Quốc); luyện Lục Phẩm **`Thiên Hồn Dung Huyết Đan`** an thai **Nữ Hoàng Thải Lân (Tiểu Tiêu Tiêu)** và chạm Kỳ Ngộ **Bia Ký Ức Tiêu Chiến** (`+15%` DMG vs Hồn Điện)!
33. **Đỉnh Vân Lam Sơn — Tam Thượng Vân Lam (`ch07_tam_thuong_van_lam`)**: Phá hôn lễ & thuyết phục **Đan Vương Cổ Hà** quy thuận Viêm Minh, trảm **[BOSS ĐẤU TÔNG] Vân Sơn** bằng *Tam Sắc Hỏa Liên*, tử chiến **[BOSS HỒN ĐIỆN] Vụ Hộ Pháp** (biến cố Dược Lão bị bắt về Hồn Điện — để lại Ấn Ký **`#11 Cốt Linh Lãnh Hỏa`** mở khóa **Tam Sắc Phật Nộ Hỏa Liên**!) và biệt ly **Vân Vận** giải tán Vân Lam Tông!
34. **Biên Ải Trấn Quỷ Quan Chiến Hỏa (`ch07_tran_quy_quan_doc_hoa`)**: Phá vây Liên Quân Tam Tông, trảm **[BOSS ĐẤU TÔNG] Nhạn Lạc Thiên**, đoàn tụ cảm động cùng **Thiên Độc Nữ Tiểu Y Tiên** (tóc bạc Đấu Tông — tiến hóa Đồng Hành `[G]`!) và luyện **`Thanh Hồn Hóa Sinh Đan`** hóa giải Phệ Sinh Đan cho **Nhị ca Tiêu Lệ**!
35. **Thánh Địa Vạn Hạt Môn — Xuất Vân Đế Quốc (`ch07_van_hat_mon_xuat_van`)**: Trảm **[BOSS ĐẤU TÔNG] Hạt Tất Nham** (kích hoạt lời nguyền **`☠ Ma Độc Ban`**: khóa 10% Max QI nhưng mỗi lần hạ Boss tích lũy `+1%` ATK tới `+20%`!), khám phá Kỳ Ngộ Độc Trì & phá Mật Thất Hồn Điện đoạt **`Bình Ngọc Nạp Hồn`**!
36. **Hắc Hoàng Thành & Tổng Đàn Ma Viêm Cốc (`ch07_hac_hoang_ma_viem`)**: Tham dự **Đấu Giá Hội Hắc Hoàng Tông** (#3 Venue — *Bồ Đề Hóa Thể Tiên*, *Thiên Thiết Khoáng*, *Vạn Hạt Độc Hạch Cấp 6*, *Phá Tông Đan*), nhận viện binh **Đại Trưởng Lão Tô Thiên** (`+15%` ATK), nhốt tàn hồn **[BOSS] Hàn Phong Đấu Tông** đoạt **`#15 Hải Tâm Diễm`**, trảm **[FINAL BOSS QUYỂN II] Địa Ma Lão Quỷ (Đấu Tông 7 Tinh)** và đúc xác lão quỷ thành Vệ Sĩ Bất Tử **`ĐỊA YÊU KHÔI`** (Đồng Hành #6 `[G]` & Hỗ Trợ `[T]` Lôi Bộc Bất Hoại)!
37. **Thiên Nhai Thành — Không Gian Trùng Động (`ch07_thien_nhai_trung_dong`)**: Chia tay **Nữ Hoàng Thải Lân** ở lại Viêm Minh dưỡng thai Tiêu Tiêu, rồi cùng **Thiên Độc Nữ, Tử Nghiên & Địa Yêu Khôi** bước vào Không Gian Trùng Động tiến về **Đại Lục Trung Châu (Quyển III — Chương 08)**!

### Chương 08 — Bắc Vực Trung Châu & Đan Hội (8 Bản Đồ · NV 57–66 · Mở Màn Quyển III · Đủ 24/24 Đấu Kỹ GDD)
38. **Hoang Mạc Bắc Vực & Hẻm Núi Vạn Phong Giản (`ch08_hoang_mac_van_phong`)**: Lạc giữa bão không gian Trung Châu, giải cứu đoàn xe Nhị Tiểu Thư **Hàn Tuyết** (Hàn Gia — kèm kỳ ngộ phụ *Trích Thủy Chi Ân*).
39. **Thiên Bắc Thành — Sinh Tử Đài & Phủ Hàn Gia (`ch08_thien_bac_thanh`)**: Giao đấu trên Sinh Tử Đài & phá vòng vây truy sát của **[BOSS] Thiên Lôi Tử Phí Thiên** (Phong Lôi Các).
40. **Thiên Mục Sơn Mạch & Đáy Thiên Sơn Huyết Đàm (`ch08_thien_muc_huyet_dam`)**: Diệt **[BOSS] Huyết Sát Vương Trần** (Hoàng Tuyền Các), Kỳ Ngộ *Phệ Kim Thử Cổ*, tắm Huyết Đàm đột phá **ĐẤU TÔNG** (*Đạp Hư Không `860 px/s`*, `1.42×` tầm đánh) & lĩnh ngộ **`Không Gian Phong Tỏa`**!
41. **Đỉnh Lôi Sơn — Đại Hội Tứ Phương Các (`ch08_loi_son_tu_phuong`)**: Xé hắc bào chấn động Bắc Vực, tái ngộ **Phong Tôn Giả (Phong Nhàn)** & quyết chiến **[BOSS] Phượng Thanh Nhi** (Thiên Yêu Hoàng Tộc).
42. **Lạc Thần Giản & Bầu Trời Diệp Thành (`ch08_lac_than_diep_thanh`)**: Phá vây **[BOSS] Cốc Chủ Băng Hà & Thanh Hải Tôn Giả** (Hồn Điện), **hóa giải hoàn toàn `Ma Độc Ban`** (`+15% ATK`, Tiểu Y Tiên tiến hóa **Tam Tinh Đấu Tôn**), phục sinh **Đồng Hành #7 `[G]` Thiên Hỏa Tôn Giả** (*Ngũ Luân Ly Hỏa Pháp*), và chứng kiến **Cổ Huân Nhi** xé trời giáng lâm truyền thụ tầng cuối Đế Ấn Quyết **`Cổ Đế Ấn`**!
43. **Thánh Địa Phần Viêm Cốc — Hỏa Đàn Cửu Long (`ch08_phan_viem_coc`)**: Trợ giúp Cốc Chủ **Đường Chấn**, vượt khảo nghiệm **[BOSS] #12 Cửu Long Lôi Cương Hỏa** & lĩnh ngộ tầng tối hậu **`Thiên Hỏa Tam Huyền Biến — Tam Biến`** (`+85% ATK`, `-30%` hồi chiêu).
44. **Thánh Đan Thành & Nội Vực Đan Tháp (`ch08_thanh_dan_thanh`)**: Tham gia **Đấu Giá Thiên Bảo Phường (#4)**, diện kiến **Huyền Không Tử** & **Yêu Nữ Tào Dĩnh** (kèm *Hồi Ức Huyền Y* nhận *Huyền Tâm Hộ Hồn Bội -25% DMG Hồn Điện*), nổ tung **Bia Trắc Hồn** lĩnh ngộ Hồn Kỹ **`Kinh Hồn Chưởng`**, rồi luyện Bát Phẩm **`Sinh Cốt Dung Huyết Đan`** (yêu cầu Thiên Cảnh `900+ SOUL`) đón **Ngũ Sắc Đan Lôi giáng trực tiếp xuống bản đồ** đăng quang **Quán Quân Đan Hội**, mở **`Tam Thiên Lôi Huyễn Thân`** & tiến hóa **Chuẩn Thiên Yêu Khôi** (`[G]` & `[T]` Ngũ Sắc Thiên Lôi)!
45. **Vạn Dặm Đan Giới & Ngân Hà Tinh Vực (`ch08_tinh_vuc_phong_an`)**: Kết nghĩa **Long Hùng Hoàng Hùng Chiến**, đánh lui **[BOSS] Mộ Cốt Lão Nhân** (Hồn Điện), hàng phục **[FINAL BOSS CH.08] #9 Thái Hư Tử Hắc Cự Long** đoạt **`#9 Tam Thiên Diễm Viêm Hỏa`** (*Bất Tử Chi Thân* hồi `+3.5% HP/s` & hồi sinh `45% HP / 180s`) + **Tứ Sắc Hủy Diệt Hỏa Liên** (`#19 + #14 + #11 + #9`), mở cổng tiến sang **Chương 09 — Tinh Vẫn Các & Vong Hồn Điện**!

### Chương 09 — Huyết Chiến Vong Hồn & Kỳ Ngộ Thiên Mộ (7 Bản Đồ · NV 67–76 · Hoàn Tất 100% Quyển III!)
46. **Đại Bản Doanh Tinh Vẫn Các (`ch09_tinh_van_cac`)**: Hội quân 6 cường giả cùng **Phong Tôn Giả** & **Thiết Kiếm Tôn Giả**, trải qua 1 năm Niết Bàn phá quan lên **NHẤT TINH ĐẤU TÔN** (*Xé Rách Không Gian `[Space]` `980 px/s`* & **`Không Gian Đại Thủ Ấn`**), đánh tan **[BOSS] Hắc Bạch Thiên Tôn**, tiến hóa Thế Lực lên cấp 3 **`✦ TINH VẪN CÁC`** (5 công trình + 15 Boss Cường Bảng), rồi khai mở **Đại Trận Luyện Thân** phục sinh **BÁN THÁNH DƯỢC TRẦN** (trao trọn **`#11 Cốt Linh Lãnh Hỏa`**, mở **Ngũ Sắc Phật Nộ Hỏa Liên** đóng băng 3s, ghép đủ **4/4 Tàn Đồ Tịnh Liên Yêu Hỏa** & nâng cấp `[T]` **Cốt Linh Vạn Lý Băng Phong 4s**)!
47. **Vong Hồn Sơn Mạch (`ch09_vong_hon_son_mach`)**: Vượt *Phệ Hồn Mê Vụ*, tử chiến **[BOSS] Trích Tinh Lão Quỷ** (Ngũ Tinh Đấu Tôn Hồn Điện), chứng kiến **Thiết Kiếm Tôn Giả** tự bạo mở đường máu, phá Tỏa Hồn Tháp cứu bản thể **Sư Tôn Dược Trần** & hoàn thành Kỳ Ngộ *Mộ Bia Thiết Kiếm* (`Thiết Kiếm Trung Nghĩa Bội +15% ATK khi HP < 50%`).
48. **Hoa Tông Thánh Địa (`ch09_hoa_tong_thanh_dia`)**: Đập tan **[BOSS] Yêu Hoa Tà Quân & Hoa Cẩm** trên Lôi Đài Bạch Ngọc giữa mưa hoa anh đào, giúp **Vân Vận** đăng cơ Tông Chủ Hoa Tông (**Đồng Hành #9 `[G]`** + `-25%` hồi chiêu Lướt) & Kỳ Ngộ *Khúc Cầm Dưới Hoa Đào*.
49. **Đầm Lầy Khô Cốt & Viễn Cổ Di Tích (`ch09_vien_co_di_tich`)**: Tái ngộ **Thanh Lân** (**Đồng Hành #8 `[G]`** *Bích Xà Tam Hoa Khống Thú* + Kỳ Ngộ *Viễn Cổ Thiên Xà*), chiến **[BOSS] Tàn Hồn Tạo Hóa Thánh Giả**, bước 99 bậc Thạch Giai đoạt **3 Tạo Hóa Thánh Cốt** & lĩnh ngộ Đấu Kỹ Thiên Giai đầu tiên **`Đại Thiên Tạo Hóa Chưởng`**!
50. **Đông Long Đảo & Hư Không Lôi Trì (`ch09_co_long_loi_tri`)**: Cùng **Trưởng Lão Hắc Kình** luyện hóa Long Ma Tinh giúp **Tử Nghiên** lột xác thành **Thái Hư Cổ Long Hoàng**, tắm Hắc Ma Lôi rèn **`Thập Tuyệt Kim Khôi Trận`** (`-50%` DMG nhận vào + 10 Thiên Lôi + Kỳ Ngộ *Hắc Ma Lôi Châu*) & chém **[BOSS] Bắc Long Vương** nhất thống Cổ Long Đảo!
51. **Cổ Giới — Cổ Thánh Thành (`ch09_co_gioi_thanh_thanh`)**: Dự Thành Nhân Lễ Cổ Tộc, đối oanh Thiên Giai đánh bại **[BOSS] Tu La Đô Thống Cổ Yêu**, diện kiến Tộc Trưởng **Cổ Nguyên** nhận Lệnh Bài Thiên Mộ & mở Hệ thống **Cửu Chuyển Đấu Tôn `[B]`**!
52. **Bí Cảnh Thiên Mộ Tam Tầng (`ch09_thien_mo_tam_tang`)**: Dòng chảy **Thời Gian `×5` (`⏳ THIÊN MỘ · x5 EXP`)**, săn Năng Lượng Thể thu **Năng Lượng Hạch Cấp 8–9** ngưng tụ **1→9 Chuyển (`+72%` toàn chỉ số)**, trảm **[FINAL BOSS QUYỂN III] Huyết Đao Thánh Giả (Nhị Tinh Đấu Thánh)** và diện kiến Tổ Tiên **TIÊU HUYỀN** Hoán Huyết Tam Tộc thức tỉnh **`Tộc Văn Đấu Đế Tiêu Tộc [X]`** (cộng dồn trên *Tam Huyền Biến* đạt `+150% ATK` + đầy 100% QI + 2 chiêu 0 QI) + Kỳ Ngộ *Bia Mộ Tiêu Huyền*, khép lại trọn vẹn **100% QUYỂN III**!

---

## 3. Tính Năng Gameplay Nổi Bật (v0.8.0 — 100% Quyển I–III · 100% AI Art · VFX 2.0 · 14 BGM)

* **Chiến đấu 60–144 FPS & Gói VFX 2.0**: 2D Physics Interpolation, **4 Shader GLSL (`gl_compatibility` 100%)**, hậu kỳ `ScreenFxOverlay`, Input Buffer, Hitstop, Camera Look-Ahead, **Thanh Phá Thế Boss (Poise/Stagger)** (`+35%` DMG), **Độ Thông Thạo trọn bộ 28/28 Đấu Kỹ** (gồm Thiên Giai `Đại Thiên Tạo Hóa Chưởng`, `Không Gian Đại Thủ Ấn`, `Thập Tuyệt Kim Khôi Trận` & **`[X]` Tộc Văn Tiêu Tộc**), 7 mẫu AI quái thường, **48/48 Boss độc chiêu chuẩn True 8-Frame AI (`4×2`)**, **Xé Rách Không Gian (`980 px/s`, `0.60s` I-frame)**, **Cửu Chuyển Đấu Tôn (`0→9` = `+72%` chỉ số)**, **Thiên Mộ `×5` EXP**, **Ngũ Sắc Phật Nộ Hỏa Liên (đóng băng 3s)** & **`[T]` Bán Thánh Dược Trần (Băng Phong toàn sân 4s)**.
* **Quản Trị Thế Lực Bàn Môn → Viêm Minh → `✦ TINH VẪN CÁC` (`[M]`)**: Tiến hóa 3 cấp bậc tới **5 công trình** (thêm *Tinh Thần Hộ Các Đại Trận* `+5%/cấp ATK & DEF` + thu hoạch dược tài Bát Phẩm & Năng Lượng Hạch 8), cử **Long Hoàng Tử Nghiên** tầm bảo & khiêu chiến **15 Boss Cường Bảng / Đấu Tông / Đấu Tôn / Đấu Thánh**!
* **Khảm Ma Hạch 3 Rãnh & Trang Bị 10 Ô `[I]`**: **52 mẫu trang bị**, 6 phẩm chất, **9 bộ Set** (+Set #9 **Tinh Vẫn Thiên Mộ**), cường hóa `+0 → +15` và **khảm Ma Hạch Cấp 1–9** (+`core_nang_luong_8`, `core_nang_luong_9`).
* **Lò Luyện Đan `[L]` & 4 Đấu Trường Đấu Giá + Ký Gửi**: **62 vật phẩm & 28 đan phương** Phẩm 1–8 (thêm 4 đan phương Bát Phẩm Ch.09: *Phục Hồn Thánh Đan*, *Cửu Chuyển Tôn Nguyên Đan*, *Kim Cương Bất Hoại Đan*, *Bồ Đề Hóa Thể Đan*) & **4 đấu trường** (**Mễ Đặc Nhĩ**, **Bát Phiến Môn**, **Hắc Hoàng Tông**, **Thiên Bảo Phường**).
* **Endgame & Khám Phá**:
  * **Thiên Mộ Tam Tầng (`×5` EXP)**, **Thiên Phần Luyện Khí Tháp (Roguelite)** & **Đấu Trường Cường Bảng (15 Boss)** trong `[M]`.
  * **Tâm Ma Luyện Cảnh** trong `[M]`: Tái đấu toàn bộ **48 Boss** ở 3 độ khó (`Thường / Ác Mộng / Đấu Tông`), chấm hạng `C → SSS`.
  * **Đồ Giám Vạn Thú (93 loài)**, **9 Đồng Hành AI `[G]`** (thêm **Thanh Lân #8**, **Tông Chủ Vân Vận #9**, tiến hóa **Long Hoàng Tử Nghiên** & **Bán Thánh Dược Trần**), **5 Hồng Nhan Tri Kỷ** & **Radar Linh Hồn `[Z]`**.

---

## 4. Giao Diện MOBA & Hệ Thống Điều Khiển

Toàn bộ chiêu thức, kỹ năng cơ động, đan dược và 8 bảng hệ thống đều được **đóng khung ô MOBA bấm trực tiếp bằng chuột** (có lớp quét hồi chiêu thời gian thực & Tooltip khi di chuột), hỗ trợ **Đổi Phím Tùy Chỉnh (Key Rebinding)** trong `[ESC]`:

| Phím Mặc Định / Ô Bấm | Chức năng trong Game |
| :--- | :--- |
| `W A S D` / Phím mũi tên | Di chuyển 8 hướng |
| `V` hoặc `Enter` *(Ô `[V]`)* | **Tương tác gần nhất** (NPC / Ma Thạch Bi / Đấu Giá / Bảo Rương / Cổng Chuyển Bản Đồ) |
| `Chuột Trái (LMB)` | Đánh thường Combo 3 nhịp (Tay Không Quyền Cước -> Vũ Khí liền thân + SFX riêng) |
| `Q` / `E` / `R` / `F` / `T` | **24/24 Đấu Kỹ** tự do lắp trong `[K]`, **Tứ Sắc Hủy Diệt Hỏa Liên** `[F]` & **Dược Lão → Mỹ Đỗ Toa → Địa Yêu Khôi → Chuẩn Thiên Yêu Khôi** `[T]` |
| `Space` *(Ô `[SPC]`)* | Thân pháp Lướt né có I-frame *(tiến hóa: Lướt thường -> **Tử Vân Dực** -> **Tam Thiên Lôi Động** -> **Đấu Khí Hóa Dực** -> **Đấu Tông Đạp Hư Không**!)* |
| `Chuột Phải (RMB)` / `C` | Bật/Tắt **Phong Ấn Trọng Xích** (`-15% SPD, +30% EXP` khi đeo Huyền Trọng Xích) |
| `G` | **Triệu Hồi / Chuyển 7 Đồng Hành AI** (*Dược Lão* / *Thiên Độc Nữ Tam Tinh Đấu Tôn* / *Thải Lân* / *Tiêu Huân Nhi* / *Tử Nghiên* / *Chuẩn Thiên Yêu Khôi* / *Thiên Hỏa Tôn Giả*) |
| `Z` | **Radar Linh Hồn** — Phóng sóng cảm ứng rương báu ẩn & lộ hình kẻ địch *(+45% tầm khi gọi Tử Nghiên!)* |
| `1` / `2` / `3` | Uống nhanh: *Đan HP* / *Đan Đấu Khí* / *Đan EXP* (tự chuyển đan cao cấp khi hết) |
| `I` / `K` / `B` / `L` / `H` | Trang Bị 10 Ô & Khảm Ma Hạch / Kho 24 Đấu Kỹ & Hỏa Liên / Đột Phá / Lò Luyện Đan / Dị Hỏa Bảng |
| `M` | **Thế Giới (46 Map · Ch.01–08)** · **5 Hồng Nhan** · **👑 Viêm Minh & Cường Bảng (11 Boss)** · **Tâm Ma (41 Boss)** · **Thiên Phần Tháp** · **Đồ Giám (79 loài)** |
| `ESC` / `F5` / `F9` | Menu Tạm Dừng (**Đổi Phím**, **Hiển Thị Fullscreen/VSync/FPS/Shake**, **Auto-Save**, **DEMO**, Save/Load 3 Ô) / Lưu / Tải nhanh |

---

## 5. Chế Độ DEMO (Mở Khóa Tất Cả) & Tự Động Lưu / Chơi Tiếp

### Option 1 — ★ Chế Độ DEMO (Mở Khóa Tất Cả)
* **Bật từ Màn Hình Chính**: Bấm **`★ CHẾ ĐỘ DEMO — MỞ KHÓA TẤT CẢ (46 MAP · FULL ĐỒ)`** (tự động chạy riêng trên **Ô Lưu 3** để bảo toàn tuyệt đối bản lưu chuẩn cốt truyện ở **Ô 1 & Ô 2**), hoặc bật ngay trong game qua **`[ESC] -> ★ Bật Chế Độ DEMO`** hay chọn nút **`Demo`** ở từng ô trong *Quản Lý 3 Ô Lưu*.
* **Toàn bộ nội dung mở sẵn**:
  * Toàn bộ **46 Bản Đồ (Trọn Quyển I–II & Chương 08 Quyển III)** mở cổng + nút bấm **`Dịch Chuyển ->`** 1 chạm ngay trong **`[M]`**, vẫn giữ nguyên toàn bộ **41 Boss** để vào đánh thử thoải mái!
  * Cảnh giới **Đấu Tông — 9 Tinh (Đỉnh Phong)** + **Thiên Cảnh Linh Hồn (`980+ SOUL`)** kích hoạt sẵn **Đạp Hư Không**, **Cánh Đấu Khí Hóa Dực Shader**, nội tại **#14 Vẫn Lạc Tâm Viêm 24/7** & **#9 Bất Tử Chi Thân**, đủ **24/24 Đấu Kỹ**, **`[T]` Chuẩn Thiên Yêu Khôi Ngũ Lôi**, trọn bộ **28 loại Hỏa `[H]`** (lắp sẵn **Tứ Sắc Hủy Diệt Hỏa Liên `#19 + #14 + #11 + #9`**), trọn bộ **7 Đồng Hành AI `[G]`** (kèm **Thiên Hỏa Tôn Giả**, **Chuẩn Thiên Yêu Khôi** & **Tiểu Y Tiên Tam Tinh Đấu Tôn**), **Đế Quốc Viêm Minh Cấp 2** cả 4 Đường, **10 ô trang bị Bộ #8 Trung Châu Đan Vương Đế Phẩm + 3 Ma Hạch Cấp 6–7 (`core_tinh_7`, `core_loi_7`, `core_doc_6`) khảm sẵn**, **1.500 Hỏa Năng**, **x20** toàn bộ 52 đan dược/thảo dược/ma hạch, **380.000 Kim Tệ**, **999 Đá Cường Hóa**, và **100/100 Hảo Cảm** 5 Hồng Nhan.

### Option 2 — Tự Động Lưu & Tự Động Chơi Tiếp (Auto-Save & Auto-Continue)
* **Lưu cài đặt vĩnh viễn** trong `user://dptk_settings.json` (gồm cả phím tùy chỉnh, hiển thị và âm lượng), có 2 công tắc bật/tắt ngay trên **Màn Hình Chính** và **Menu Tạm Dừng `[ESC]`**:
  1. **Tự Động Lưu Dữ Liệu (Auto-Save)** *(mặc định BẬT)*: Tự động lưu ngầm vào ô đang chơi mỗi **30 giây**, khi **chuyển bản đồ**, **đột phá**, **hoàn thành nhiệm vụ / mốc cốt truyện**, **mở bảo rương**, khi **về Màn Hình Chính**, và cả khi **đóng cửa sổ game (`X`)**, lưu chính xác **tọa độ đứng `(x, y)`**.
  2. **Tự Động Vào Chơi Tiếp Bản Lưu Gần Nhất Lần Sau**: Khi bật, lần mở game tiếp theo sẽ hiện thanh đếm ngược ngắn (`1.6s`, có nút **Hủy**) rồi tự động tải thẳng vào **Ô Lưu chơi gần nhất** đúng bản đồ và đúng vị trí bạn vừa dừng!

---

## 6. Cấu Trúc Thư Mục Dự Án

* `docs/` — **25 Tài liệu Thiết kế Game (GDD), Tiến Độ & Sổ Nợ Đồ Họa** chia chi tiết 11 Chương (4 Quyển), 23 Dị Hỏa, 12 Cảnh giới, Đấu Kỹ, Luyện Đan, Quái & 25+ Boss, kèm bảng theo dõi tiến độ tại [`docs/00_Tong_Quan_Kien_Truc/02_Tien_Do_Va_Lo_Trinh_Phat_Trien.md`](docs/00_Tong_Quan_Kien_Truc/02_Tien_Do_Va_Lo_Trinh_Phat_Trien.md) và sổ theo dõi đồ họa tại [`docs/00_Tong_Quan_Kien_Truc/03_Danh_Sach_Do_Hoa_Va_VFX_Can_Nang_Cap.md`](docs/00_Tong_Quan_Kien_Truc/03_Danh_Sach_Do_Hoa_Va_VFX_Can_Nang_Cap.md).
* `data/` — **28 Cơ sở dữ liệu JSON** (`maps.json`, `maps_ch04..08.json` — 46 map; `quests_ch01`, `quests_ch04..08.json` — 66 NV chính; `dialogues_ch04..08.json`; `enemies.json`, `enemies_ch04..08.json` — 79 quái/41 Boss; `realms.json`, `flames.json`, `skills.json` — 24 Đấu Kỹ; `alchemy_items.json` — 52 vật phẩm/24 đan phương; `equipment.json` — 46 mẫu/8 Set).
* `assets/` — **215 tài nguyên sprite/texture 32-bit HD AI Pixel Art & 4 Shader GLSL** (chuẩn mặc định **8 frame**: trọn bộ **49/49 spritesheet hoạt ảnh = 100% True 8-Frame AI** gồm 8 sheet Tiêu Viêm `idle/run/cast/dash/4×attack` và trọn bộ **41/41 Boss `*_boss_anim.png`** đều là **8 frame** `4×2`/`8×1`; **38 NPC AI**, **40 icon** gồm 24/24 Đấu Kỹ có icon AI riêng, **21 tileset vùng seamless AI** từ Ô Thản Thành tới Thánh Đan Thành & Ngân Hà Tinh Vực, texture VFX `128×128` / `wing_plume` `96×128`, 3 pickup `32×32`, và 4 shader `di_hoa_palette`, `char_motion_polish`, `space_shockwave`, `vfx_energy_dissolve`).
* `scripts/` & `scenes/` — **44 script GDScript** (`24.5K` LOC · mọi file lõi `< 1.700` dòng sau đợt mô-đun hóa `v0.7.2`: `SaveLoadManager`, `PanGateManager`, `HeroineAffectionManager`, `StoryProgressionHelper`, `RegionalWeatherBuilder`, `WorldNavigationHelper`, `BossSkillExecutor`, `PlayerSkillExecutor`, `BossRushManager`, `ThienPhanTowerManager`, `StoryDialogueRunner`, `ScreenFxOverlay`, `AudioBgmCh0508`, **9 mô-đun UI** trong `scripts/ui/panels/`, `AuctionSystem`, `AlchemySystem`, `EquipmentSystem`, **11 BGM ngũ cung địa vực Procedural** & **24 SFX**) & **9 scene `.tscn`**.
* `tests/` — Bộ kiểm thử tự động Godot headless (`tests/test_runner.tscn`, `tests/test_suite.gd`, `tests/run_tests.bat`) — **13 Suites / 1.461 assertions (0 FAILED · 0 leaks)** kiểm tra JSON schema, tồn tại asset `res://`, liên thông BFS 46 bản đồ, `alchemy_max_tier`, Save/Load, DEMO, live UI/VFX 2.0/Endgame, 49/49 sheet 8-frame, Ch.06–08, 11 BGM / 46-map BGM & 10 mô-đun refactor `v0.7.2`.
* `tools/` — Công cụ tự động chuẩn hóa spritesheet `tools/normalize_spritesheet.py`.
* `export_presets.cfg` & `icon.ico` — Cấu hình đóng gói Windows x64 (`GL Compatibility`, `v0.7.3.0`) độc lập.
