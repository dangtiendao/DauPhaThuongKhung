# Đấu Phá Thương Khung — Top-down 2D HD Pixel Action RPG (Godot 4)

Dự án Fan-game phi thương mại / học tập lấy cảm hứng trọn vẹn từ tiểu thuyết **Đấu Phá Thương Khung** (Thiên Tằm Thổ Đậu), phát triển trên **Godot Engine 4 (GDScript)** với đồ họa **100% 32-bit HD AI Pixel Art (`1280×720`, 72/72 True 8-Frame AI, Physics Interpolation & VFX 2.0 Shader 60–144 FPS)**, giao diện **nút bấm MOBA trực quan**, **Data-Driven Story Engine**, **22 Bản Nhạc Nền Ngũ Cung Địa Vực**, và **tiến trình chuẩn nguyên tác HOÀN TẤT 100% 11/11 CHƯƠNG — TRỌN BỘ 4/4 QUYỂN (`v1.0.0` Official Release): 67 bản đồ — 96 mốc nhiệm vụ chính (Chương 01 -> Chương 11: Dược Giới Dược Điển, Đế Cảnh Linh Hồn & Cứu Phụ Thân Tiêu Chiến, Lão Long Hoàng Chúc Khôn #12, Đà Xá Cổ Đế Động Phủ Chứng Đạo VIÊM ĐẾ [23/23 Dị Hỏa · #1 Đế Viêm], Song Đế Chi Chiến 3-Phase Final Boss Hồn Thiên Đế, Đại Hôn Ô Thản Thành + 5 Hậu Truyện + True Ending Credits, Đại Thiên Thế Giới Tỷ Thí Superboss Võ Tổ Lâm Động & Mục Trần & Chế Độ Luân Hồi New Game+!)**.

---

## 1. Cách Chạy Game Nhanh Nhất

1. **Chơi ngay**: Nhấp đúp file **`CHAY_GAME.bat`** trong thư mục dự án (`e:\Project\DauPhaThuongKhung\CHAY_GAME.bat`).
2. **Mở trình soạn thảo Godot Editor**: Nhấp đúp file **`MO_GODOT_EDITOR.bat`** (hoặc mở Godot 4 -> Import `project.godot` -> nhấn `F5`).
3. **Chạy bộ kiểm thử tự động (2.349 assertions · 16 Suites)**: Chạy **`tests\run_tests.bat`** (hoặc `Godot --headless --path . res://tests/test_runner.tscn`).
4. **Đóng gói Windows `.exe`**: Cấu hình sẵn preset **`Windows Desktop`** trong `export_presets.cfg` (`1.0.0.0`, tích hợp `icon.ico`, nhúng `.pck`, xuất ra `builds/DauPhaThuongKhung.exe`).

---

## 2. Lộ Trình Chuẩn Nguyên Tác (67 Bản Đồ — 96 Mốc Cốt Truyện — 118 Quái & 64 Boss Độc Chiêu)

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

### Chương 10 — Bồ Đề Hóa Thánh & Tịnh Liên Yêu Hỏa Hàng Thế (7 Bản Đồ · NV 77–86 · Mở Màn Quyển IV!)
53. **Chiến Trường Tường Thành Viêm Minh (`ch10_viem_minh_chien_truong`)**: Xuyên Trùng Động Đông từ Thiên Mộ kịp cứu **Hải Ba Đông** & **Tiêu Đỉnh**, một ngón tay bóp nát **[BOSS] Sư Thiên & Cửu Thiên Tôn** (Thành tựu `ACH_10_01 +5% ATK`), đoàn tụ cảm động **Nữ Vương Thải Lân & Con Gái Tiêu Tiêu** (mở **Đồng Hành #11 `[G]` Thải Lân & Tiêu Tiêu** `+20%` tốc độ Xích & **Sơ Cấp Bán Thánh**).
54. **Cửa Ngõ Mãng Hoang Cổ Vực (`ch10_mang_hoang_co_vuc`)**: Hội quân cùng **Cổ Huân Nhi**, xuyên đàn *Viễn Cổ Thiên Ngô Độc Trùng* và đánh bại **[BOSS BÁN THÁNH] Thần Tử Hồn Ngọc** đạt *Trung Cấp Bán Thánh*.
55. **Bồn Địa Bồ Đề Cổ Thụ (`ch10_bo_de_co_thu`)**: Dùng Ngũ Sắc Hỏa Liên thanh lọc **[BOSS] Ác Niệm Đấu Đế Viễn Cổ**, tiếp nhận *Bồ Đề Tâm* + 10 *Bồ Đề Tử*, hóa kén bước vào **Ảo Cảnh Thủy Mặc Bách Thế Luân Hồi** (3 kiếp phàm nhân đen-trắng → **Thánh Giả Đạo Tâm** & `ACH_10_02 +250 SOUL`) chứng đạo **NHẤT TINH ĐẤU THÁNH — ĐẤU THÁNH KHÔNG GIAN** (Lướt `1.120 px/s`, 3 đạo kiếm khí LMB, `+25%` Thánh Uy), rồi nghiền nát **[BOSS] Thiên Minh Lão Yêu & Tam Đại Tà Phái**!
56. **Tổng Đàn Thiên Phủ Liên Minh (`ch10_thien_phu_lien_minh`)**: Dự Đại Lễ cùng **Đan Tháp Lão Tổ** & **Dược Trần** hợp nhất 4 thế lực thành siêu thế lực Cấp 4 **`👑 THIÊN PHỦ LIÊN MINH`** (6 công trình + **20 Boss Cường Bảng**), thực hiện Kỳ Ngộ *Đường Đậu Đan cho Bé Tiêu Tiêu* (`Phụ Nữ Đồng Tâm Kết +10% toàn chỉ số khi HP < 50%`) và *Ban Phát Bồ Đề Đại Hoàn Đan* (`+18%` chiến lực toàn bộ Đồng Hành!).
57. **Cửu U Địa Minh Mãng — Hoàng Tuyền Huyết Đàm (`ch10_cuu_u_hoang_tuyen`)**: Giải cứu kết minh Tộc Trưởng **Yêu Minh**, hạ **[BOSS] Tàn Ảnh Hoàng Tuyền Yêu Thánh** và cảm ngộ Thạch Bia lĩnh ngộ **Thiên Giai `Hoàng Tuyền Chưởng`** & **Hồn Kỹ `Hoàng Tuyền Thiên Nộ`** (`2.200% SOUL` · Choáng 4s)!
58. **Pháo Đài Nhân Điện — Hồn Điện (`ch10_nhan_dien_hon_dien`)**: Công phá tổng đàn Nhân Điện, trảm **[BOSS TAM TINH ĐẤU THÁNH] Phó Điện Chủ Nhân Điện**, sáng tạo đĩa lửa Đen–Trắng **`Phật Nộ Luân Hồi`** (`ACH_10_03 -20% CD Hoàng Tuyền`) & Kỳ Ngộ *Siêu Độ 10.000 Linh Hồn* (`+350 SOUL` Thiên Cảnh Đại Viên Mãn)!
59. **Yêu Hỏa Không Gian — Biển Lửa Tịnh Liên (`ch10_yeu_hoa_khong_gian`)**: Song Nguyệt Đồng Hiện mở cổng **4/4 Yêu Liên Cổ Ngọc**, rèn siêu khôi lỗi **Đồng Hành #10 `[G]` BẮC VƯƠNG** (Lục Tinh → **Thất Tinh Kim Lôi** qua *Cửu Huyền Kim Lôi Hạch*), nhận truyền thừa **Tàn Hồn Tịnh Liên Yêu Thánh** (`Tịnh Liên Yêu Trận`), đánh bại **[VUA LỬA #3] Bản Thể Tịnh Liên Yêu Hỏa**, **Song Luyện Đài Sen cùng Cổ Huân Nhi** thu trọn **`#4 Kim Đế Phần Thiên Viêm`** + **`#3 Tịnh Liên Yêu Hỏa` (Khí Linh Tiểu Y đồng hành vĩnh viễn vai phải: 30% Tịnh Hóa Đạn +8% QI & Tự Luyện Đan Phẩm 1–8 trong `[L]`)** + **Lục Sắc Thánh Liên (100% Xuyên Giáp · Phá Khiên Boss)** + **Tâm Ý Tương Thông Hồi Sinh 65% HP**, rồi trảm **[FINAL BOSS CH.10] Điện Chủ Hồn Điện Hồn Diệt Sinh** mở cổng sang **Chương 11 — Đà Xá Cổ Đế Động Phủ**!

### Chương 11 — Cổ Đế Động Phủ, Song Đế Chi Chiến & Đại Kết Cục Viêm Đế (7 Bản Đồ · NV 87–96 · Hoàn Tất 100% 4/4 Quyển!)
60. **Dược Giới — Vạn Dược Sơn (`ch11_duoc_gioi_van_duoc_son`)**: Dự Đại Hội Dược Điển cùng **Lão Tổ Dược Điển**, dùng Cửu Phẩm Huyền Đan nghiền nát **[BOSS] Hồn Hư Tử** (`ACH_11_01` + *Dược Đế Bạch Kim Đỉnh*), cầm chân **[BOSS] Bản Thể #2 Hư Vô Thôn Viêm** giữa bầu trời nứt đen & tiếp nhận ký thác **`#5 Sinh Linh Chi Diễm` + `#10 Cửu U Phong Viêm`** phá vây lên Thất Tinh Đấu Thánh!
61. **Táng Thiên Sơn Mạch (`ch11_tang_thien_son_mach`)**: Hội quân Liên Minh Tam Tộc cùng **Viêm Tẫn & Lôi Doanh**, phá tan gông cùm vạn năm đột phá **ĐẾ CẢNH LINH HỒN (`3.500+ SOUL` · Phẩm 10 Đế Phẩm · `Đế Hồn Pháp Tướng` +100% SOUL sát thương chuẩn)**, đập tan **[BOSS] Hồn Tộc Tứ Ma Thánh**, và thực hiện canh bạc tráo Đế Ngọc giải cứu **Phụ Thân TIÊU CHIẾN** đoàn viên sau 20 năm!
62. **Vực Sâu Dung Nham Đáy Tháp Già Nam (`ch11_day_thap_gia_nam`)**: Truy vết 8 mảnh Cổ Đế Ngọc quay về dưới đáy Thiên Phần Luyện Khí Tháp năm xưa — chứng kiến cha con Cổ Long **Tử Nghiên** đoàn tụ **Lão Long Hoàng CHÚC KHÔN** (mở khóa **Đồng Hành #12 `[G]` Chúc Khôn** Cửu Tinh Đỉnh Phong + Khiên 35% HP & Choáng 2.8s)!
63. **Đà Xá Cổ Đế Động Phủ (`ch11_co_de_dong_phu`)**: Hợp lực vây bắt **[BOSS BÁN ĐẾ] Đế Phẩm Sồ Đan**, rồi chạm **Thạch Tượng Đà Xá Cổ Đế** kích hoạt thiên tượng **VẠN HỎA TRIỀU TÔNG** — hiệu triệu 23 sắc Dị Hỏa dung nhập **`#1 Đế Viêm`**, chứng đạo **CẢNH GIỚI 12: VIÊM ĐẾ (ĐẤU ĐẾ)**, thức tỉnh thần binh **`Dị Hỏa Hằng Cổ Xích`**, **`Đế Bước Hư Không` (`1.280 px/s`, 5 Đạo Kiếm Khí 23 Sắc, `+45%` Đế Uy)**, **`[T]` Viêm Đế Pháp Tướng (ATK ×5.00 · +75% Khiên)** & **`Vạn Hỏa Phần Thương Khung`**!
64. **Cửu Tiêu Thương Khung (`ch11_cuu_tieu_thuong_khung`)**: Trận chiến cuối cùng **Song Đế Chi Chiến** chống **[FINAL BOSS 3 PHASE] Hồn Đế Hồn Thiên Đế** (*Phase 1 Huyết Hải → Phase 2 ≤65% Trảm Đế Quỷ Huyết Đao → Phase 3 ≤25% Tự Bạo Hắc Động Hồn Đế*), lĩnh ngộ **`Hằng Cổ Xích Trảm`** & **`Dị Hỏa Quảng Trường`** phong ấn vạn cổ Hồn Thiên Đế (`ACH_11_03`)!
65. **Ô Thản Thành Tân Trang — Phủ Tiêu Gia Đại Hôn (`ch11_o_than_thanh_dai_hon`)**: **TRUE ENDING** — cử hành **Song Hậu Đại Hôn** cùng **Cổ Huân Nhi & Thải Lân** trước phụ thân **Tiêu Chiến** & sư tôn **Dược Trần**, thưởng thức **`PanelEndingCredits` điện ảnh**, mở **`Hằng Cổ Dị Hỏa Liên` (7–23 Hỏa · Dừng Thời Gian 5s)** và hoàn tất **5 Nhiệm Vụ Hậu Truyện Cố Nhân (`EQ_11_01..05`)** (*Tiểu Y Tiên*, *Vân Vận*, *Nhã Phi–Hải Ba Đông*, *Tiệc Kẹo Cửu Phẩm +25% toàn đội Đồng Hành*, *Bái Tế Tiêu Huyền `ACH_11_02`*) để mở Thành Tựu Bạch Kim **`ACH_11_04: Song Hậu Đồng Quy (+10% toàn chỉ số)`**!
66. **Thương Khung Vị Diện Giao Giới — Đại Thiên Thế Giới (`ch11_dai_thien_giao_gioi`)**: **POST-GAME ENDGAME** — hạ **[BOSS] Hộ Vệ 23 Dị Hỏa** mở khóa trọn bộ **17 Bí Cảnh Dị Hỏa Ẩn (`23/23` Chân Hỏa Bản Nguyên)**, tỷ thí **2 Superboss Đa Vũ Trụ** (**Võ Tổ LÂM ĐỘNG** thưởng *Lôi Đế Tổ Phù Ấn +15% Đấu Kỹ* & **Đại Chúa Tể MỤC TRẦN** *Nhất Khí Hóa Tam Thanh*), đoạt Cúp Bạch Kim **`ACH_11_05: Chúa Tể Đại Thiên (+15% toàn chỉ số)`**, luyện Đan Phẩm 10 **`Đà Xá Đế Phẩm Hoàn Đan` (`+25%` toàn chỉ số vĩnh viễn)** và khởi động **Chế Độ Luân Hồi Chuyển Thế (`New Game+`)**!

---

## 3. Tính Năng Gameplay Nổi Bật (v1.0.0 Official Release — 11/11 Chương 100% · 72/72 True 8-Frame AI · 22 BGM)

* **Chiến đấu 60–144 FPS & Gói VFX 2.0**: 2D Physics Interpolation, **4 Shader GLSL (`gl_compatibility` 100%)**, hậu kỳ `ScreenFxOverlay` (+ **Màn Thủy Mặc Bách Thế**, **Huyết Thiên Song Đế**, **Hỷ Sự Ô Thản Thành**, **Tinh Không Đại Thiên & Viền Cầu Vồng Viêm Đế**), Input Buffer, Hitstop, Camera Look-Ahead, **Thanh Phá Thế Boss (Poise/Stagger)** (`+35%` DMG), **Độ Thông Thạo trọn bộ 37/37 Đấu Kỹ** (thêm 5 tuyệt kỹ Đế Cảnh Ch.11: `Đế Hồn Pháp Tướng`, `Vạn Hỏa Phần Thương Khung`, `Dị Hỏa Quảng Trường`, `Hằng Cổ Xích Trảm`, `Hằng Cổ Dị Hỏa Liên` + **`[X]` Tộc Văn Tiêu Tộc**), 7 mẫu AI quái thường, **64/64 Boss độc chiêu chuẩn True 8-Frame AI (`4×2`)** gồm **Final Boss 3-Phase Hồn Thiên Đế** & **2 Superboss Lâm Động / Mục Trần**, **Đế Bước Hư Không (`1.280 px/s`, `0.85s` I-frame, 5 Đạo Kiếm Khí 23 Sắc, `+45%` Đế Uy)**, **Khí Linh Tiểu Y thường trực** (`30%` tịnh hóa đạn `+8% QI` & Auto-Refine Phẩm 1–8), **Hằng Cổ Dị Hỏa Liên (`7–23` Hỏa · 100% Xuyên Giáp · Dừng Thời Gian 5s)** & **`[T]` Viêm Đế Pháp Tướng**.
* **Quản Trị Thế Lực Bàn Môn → Viêm Minh → Tinh Vẫn Các → `👑 THIÊN PHỦ LIÊN MINH` (`[M]`)**: Tiến hóa 4 cấp bậc tới **6 công trình** (`+18% SOUL`, `+15% DEF/Alchemy`, `+12% ATK`), cử **Long Hoàng Tử Nghiên** tầm bảo & khiêu chiến trọn bộ **25 Boss Cường Bảng** (thêm 5 Đế/Superboss Ch.11)!
* **Khảm Ma Hạch 3 Rãnh & Trang Bị 10 Ô `[I]`**: **64 mẫu trang bị**, 6 phẩm chất, **11 bộ Set** (+Set #11 **Vĩnh Hằng Viêm Đế**: *Dị Hỏa Hằng Cổ Xích*, *Vạn Hỏa Thái Sơ Dực*, *Lôi Đế Tổ Phù Ấn*, *Dược Đế Bạch Kim Đỉnh*...), cường hóa `+0 → +15` và **khảm Ma Hạch Cấp 1–10** (+**Đế Viêm Bản Nguyên Hạch Cấp 10 `core_de_viem_10`**).
* **Lò Luyện Đan `[L]` Đạt Đỉnh Phẩm 10 Đế Phẩm (36/36 = 100% GDD!) & 4 Đấu Trường Đấu Giá**: **83 vật phẩm & 36 đan phương** Phẩm 1–10 (thêm 4 đan phương Ch.11: *Trú Nhan Thánh Đan*, *Lôi Kiếp Huyền Đan +150 SOUL*, *Bồ Đề Cửu Phẩm Kim Đan*, và **Phẩm 10 `Đà Xá Đế Phẩm Hoàn Đan` `+25%` toàn chỉ số vĩnh viễn** yêu cầu Đế Cảnh `3.500+ SOUL`!) + nút **`✿ Tiểu Y (100%)`** tự luyện tức thì Phẩm 1–8 & **4 đấu trường** (**Mễ Đặc Nhĩ**, **Bát Phiến Môn**, **Hắc Hoàng Tông**, **Thiên Bảo Phường**).
* **Endgame Vô Tận, True Ending Credits & Luân Hồi Chuyển Thế (`New Game+`)**:
  * **17 Bí Cảnh Dị Hỏa Ẩn (`23/23` Chân Hỏa)**, **2 Superboss Đại Thiên (Võ Tổ Lâm Động & Mục Trần)**, **5 Hậu Truyện Ô Thản Thành (`EQ_11_01..05`)**, **5 Thành Tựu Bạch Kim (`ACH_11_01..05`)** & **`PanelEndingCredits`** trong Lễ Đường / `[ESC]`.
  * **Luân Hồi Chuyển Thế (`New Game+`)**: Khởi động từ Bia Đại Thiên hoặc `[ESC]`, mang trọn **23 Dị Hỏa, 37 Đấu Kỹ, Trang Bị & Khí Linh Tiểu Y** trở về Ô Thản Thành ở độ khó *Thương Khung Khốc Liệt* (`+200% HP`, `+50% ATK`, `+35% SPD`, rớt độc quyền *Hồng Trần Đế Tinh* + **Easter Egg Từ Hôn Đế Uy làm Cát Diệp & Nạp Lan rơi vỡ chén trà**!).
  * **Thiên Mộ Tam Tầng (`×5` EXP)**, **Thiên Phần Luyện Khí Tháp (Roguelite)**, **Đấu Trường Cường Bảng (25 Boss)**, **Tâm Ma Luyện Cảnh (64 Boss × 3 độ khó `C→SSS`)**, **Đồ Giám Vạn Thú (118 loài)** & **12 Đồng Hành AI `[G]`** (+ **Lão Long Hoàng Chúc Khôn #12** & **Khí Linh Tiểu Y** thường trực)!

---

## 4. Giao Diện MOBA & Hệ Thống Điều Khiển

Toàn bộ chiêu thức, kỹ năng cơ động, đan dược và 8 bảng hệ thống đều được **đóng khung ô MOBA bấm trực tiếp bằng chuột** (có lớp quét hồi chiêu thời gian thực & Tooltip khi di chuột), hỗ trợ **Đổi Phím Tùy Chỉnh (Key Rebinding)** trong `[ESC]`:

| Phím Mặc Định / Ô Bấm | Chức năng trong Game |
| :--- | :--- |
| `W A S D` / Phím mũi tên | Di chuyển 8 hướng |
| `V` hoặc `Enter` *(Ô `[V]`)* | **Tương tác gần nhất** (NPC / Ma Thạch Bi / Đấu Giá / Bảo Rương / Cổng Chuyển Bản Đồ) |
| `Chuột Trái (LMB)` | Đánh thường Combo 3 nhịp (phóng 3 Kiếm Khí khi đạt Đấu Thánh → **5 Đạo Kiếm Khí 23 Sắc khi Chứng Đạo Viêm Đế!**) |
| `Q` / `E` / `R` / `F` / `T` / `X` | **37/37 Đấu Kỹ** tự do lắp trong `[K]`, **Hằng Cổ Dị Hỏa Liên (`7–23` Hỏa)** `[F]`, **Trợ Chiến `[T]` → Viêm Đế Pháp Tướng**, & **Tộc Văn Tiêu Tộc `[X]`** |
| `Space` *(Ô `[SPC]`)* | Thân pháp Lướt né có I-frame *(tiến hóa: Lướt thường → Tử Vân Dực → Tam Thiên Lôi Động → Hóa Dực → Đạp Hư Không → Xé Không → Đấu Thánh → **Đế Bước Hư Không `1.280 px/s`**!)* |
| `Chuột Phải (RMB)` / `C` | Bật/Tắt **Phong Ấn Trọng Xích** (`-15% SPD, +30% EXP` khi đeo Huyền Trọng Xích / Hằng Cổ Xích) |
| `G` | **Triệu Hồi / Chuyển 12 Đồng Hành AI** *(+ **Lão Long Hoàng Chúc Khôn #12** & **Khí Linh Tiểu Y** bay thường trực!)* |
| `Z` | **Radar Linh Hồn** — Phóng sóng cảm ứng rương báu ẩn & lộ hình kẻ địch *(+45% tầm khi gọi Tử Nghiên!)* |
| `1` / `2` / `3` | Uống nhanh: *Đan HP* / *Đan Đấu Khí* / *Đan EXP* (tự chuyển đan cao cấp khi hết, gồm Trú Nhan Thánh Đan & Bồ Đề Cửu Phẩm!) |
| `I` / `K` / `B` / `L` / `H` | Trang Bị 10 Ô & Ma Hạch Cấp 1–10 / Kho 37 Đấu Kỹ & 23 Hỏa Liên / Đột Phá · Cửu Chuyển · Viêm Đế & NG+ / Lò Đan Phẩm 10 + Tiểu Y / 28 Dị Hỏa |
| `M` | **Thế Giới (67 Map · Ch.01–11)** · **5 Hồng Nhan** · **👑 Thiên Phủ & Cường Bảng (25 Boss)** · **Tâm Ma (64 Boss)** · **Thiên Phần Tháp** · **Đồ Giám (118 loài)** |
| `ESC` / `F5` / `F9` | Menu Tạm Dừng (**True Ending Credits**, **Luân Hồi NG+**, **Đổi Phím**, **Hiển Thị**, **Auto-Save**, **DEMO**, Save/Load 3 Ô) / Lưu / Tải nhanh |

---

## 5. Chế Độ DEMO (Mở Khóa Tất Cả) & Tự Động Lưu / Chơi Tiếp

### Option 1 — ★ Chế Độ DEMO (Mở Khóa Tất Cả)
* **Bật từ Màn Hình Chính**: Bấm **`★ CHẾ ĐỘ DEMO — MỞ KHÓA TẤT CẢ (67 MAP · FULL VIÊM ĐẾ)`** (tự động chạy riêng trên **Ô Lưu 3** để bảo toàn tuyệt đối bản lưu chuẩn cốt truyện ở **Ô 1 & Ô 2**), hoặc bật ngay trong game qua **`[ESC] -> ★ Bật Chế Độ DEMO`** hay chọn nút **`Demo`** ở từng ô trong *Quản Lý 3 Ô Lưu*.
* **Toàn bộ nội dung mở sẵn**:
  * Toàn bộ **67 Bản Đồ (Trọn 11/11 Chương Ch.01–Ch.11)** mở cổng + nút bấm **`Dịch Chuyển ->`** 1 chạm ngay trong **`[M]`**, vẫn giữ nguyên toàn bộ **64 Boss & Superboss** để vào thử sức thoải mái!
  * Cảnh giới **Cấp 12 VIÊM ĐẾ (ĐẤU ĐẾ) + Cửu Chuyển 9/9** + **Đế Cảnh Linh Hồn (`4.200+ SOUL`)** kích hoạt sẵn **Đế Bước Hư Không**, **Khí Linh Tiểu Y (#3)**, đủ **37/37 Đấu Kỹ**, **`[X]` Tộc Văn Tiêu Tộc**, **`[T]` Viêm Đế Pháp Tướng**, trọn bộ **28 loại Hỏa (`23/23` Dị Hỏa `[H]`, vận `#1 Đế Viêm`, lắp sẵn 8-Hỏa Hằng Cổ Dị Hỏa Liên)**, trọn bộ **12 Đồng Hành AI `[G]`** (kèm **Lão Long Hoàng Chúc Khôn #12**, **Bắc Vương 7★**, **Thải Lân–Tiêu Tiêu**), **Thiên Phủ Liên Minh Cấp 4**, **10 ô trang bị Bộ #11 Vĩnh Hằng Viêm Đế Đế Phẩm + 3 Ma Hạch Cấp 9–10 (`core_de_viem_10`, `core_de_viem_10`, `core_kim_loi_9`)**, **x20** toàn bộ 83 vật phẩm (gồm Phẩm 10 *Đà Xá Đế Phẩm Hoàn Đan*), **9.999.999 Kim Tệ**, **999 Đá Cường Hóa**, **5/5 Thành Tựu Bạch Kim**, mở sẵn **True Ending Credits** & **New Game+**!

### Option 2 — Tự Động Lưu & Tự Động Chơi Tiếp (Auto-Save & Auto-Continue)
* **Lưu cài đặt vĩnh viễn** trong `user://dptk_settings.json` (gồm cả phím tùy chỉnh, hiển thị và âm lượng), có 2 công tắc bật/tắt ngay trên **Màn Hình Chính** và **Menu Tạm Dừng `[ESC]`**:
  1. **Tự Động Lưu Dữ Liệu (Auto-Save)** *(mặc định BẬT)*: Tự động lưu ngầm vào ô đang chơi mỗi **30 giây**, khi **chuyển bản đồ**, **đột phá**, **hoàn thành nhiệm vụ / mốc cốt truyện**, **mở bảo rương**, khi **về Màn Hình Chính**, và cả khi **đóng cửa sổ game (`X`)**, lưu chính xác **tọa độ đứng `(x, y)`** & vòng **Luân Hồi `NG+`**.
  2. **Tự Động Vào Chơi Tiếp Bản Lưu Gần Nhất Lần Sau**: Khi bật, lần mở game tiếp theo sẽ hiện thanh đếm ngược ngắn (`1.6s`, có nút **Hủy**) rồi tự động tải thẳng vào **Ô Lưu chơi gần nhất** đúng bản đồ và đúng vị trí bạn vừa dừng!

---

## 6. Cấu Trúc Thư Mục Dự Án

* `docs/` — **25 Tài liệu Thiết kế Game (GDD), Tiến Độ & Sổ Nợ Đồ Họa** chia chi tiết 11 Chương (4 Quyển), 23 Dị Hỏa, 12 Cảnh giới, Đấu Kỹ, Luyện Đan, Quái & 25+ Boss, kèm bảng theo dõi tiến độ tại [`docs/00_Tong_Quan_Kien_Truc/02_Tien_Do_Va_Lo_Trinh_Phat_Trien.md`](docs/00_Tong_Quan_Kien_Truc/02_Tien_Do_Va_Lo_Trinh_Phat_Trien.md) và sổ theo dõi đồ họa tại [`docs/00_Tong_Quan_Kien_Truc/03_Danh_Sach_Do_Hoa_Va_VFX_Can_Nang_Cap.md`](docs/00_Tong_Quan_Kien_Truc/03_Danh_Sach_Do_Hoa_Va_VFX_Can_Nang_Cap.md).
* `data/` — **40 Cơ sở dữ liệu JSON** (`maps.json`, `maps_ch04..11.json` — 67 map; `quests_ch01`, `quests_ch04..11.json` — 96 NV chính; `dialogues_ch04..11.json`; `enemies.json`, `enemies_ch04..11.json` — 118 quái/64 Boss; `realms.json`, `flames.json`, `skills.json` — 37 Đấu Kỹ; `alchemy_items.json` — 83 vật phẩm/36 đan phương = 100% GDD; `equipment.json` — 64 mẫu/11 Set).
* `assets/` — **331 PNG 32-bit HD AI Pixel Art & 4 Shader GLSL** (chuẩn mặc định **8 frame**: trọn bộ **72/72 spritesheet hoạt ảnh = 100% True 8-Frame AI** gồm 8 sheet Tiêu Viêm và trọn bộ **64/64 Boss `*_boss_anim.png`** đều là **8 frame** `4×2`/`8×1`; **62 NPC AI**, **37/37 Icon Đấu Kỹ AI riêng**, **42 Tileset vùng seamless AI** từ Ô Thản Thành tới Đại Thiên Thế Giới, 12 Mob AI Ch.09–11, VFX `128×128` / `wing_plume` `96×128`, 3 pickup `32×32`, và 4 shader GLSL).
* `scripts/` & `scenes/` — **51 script GDScript** (mọi file lõi `< 1.800` dòng: `SaveLoadManager`, `PanGateManager`, `NineTurnManager`, `SaintRealmManager`, `EmperorRealmManager`, `HeroineAffectionManager`, `StoryProgressionHelper`, `RegionalWeatherBuilder`, `WorldNavigationHelper`, `BossSkillExecutor`, `PlayerSkillExecutor`, `BossRushManager`, `ThienPhanTowerManager`, `StoryDialogueRunner`, `ScreenFxOverlay`, `AudioBgmCh0508`, `AudioBgmCh09`, `AudioBgmCh10`, `AudioBgmCh11`, **10 mô-đun UI** trong `scripts/ui/panels/` gồm `PanelEndingCredits`, `AuctionSystem`, `AlchemySystem`, `EquipmentSystem`, **22 BGM ngũ cung địa vực Procedural** & **24 SFX**) & **9 scene `.tscn`**.
* `tests/` — Bộ kiểm thử tự động Godot headless (`tests/test_runner.tscn`, `tests/test_suite.gd`, `tests/run_tests.bat`) — **16 Suites / 2.349 assertions (0 FAILED · 0 leaks)** kiểm tra JSON schema, tồn tại asset `res://`, liên thông BFS 67 bản đồ, `alchemy_max_tier` (Phẩm 1–10), Save/Load (gồm `NG+`), DEMO, live UI (`PanelEndingCredits`)/VFX 2.0/Endgame, 72/72 sheet 8-frame, Ch.06–11, Final Boss 3-Phase, 22 BGM / 67-map BGM & `< 1.800 LOC` core guard.
* `tools/` — Công cụ tự động chuẩn hóa spritesheet `tools/normalize_spritesheet.py`.
* `export_presets.cfg` & `icon.ico` — Cấu hình đóng gói Windows x64 (`GL Compatibility`, **`v1.0.0.0`**) độc lập.
