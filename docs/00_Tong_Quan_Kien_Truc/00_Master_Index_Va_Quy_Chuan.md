# HỒ SƠ THIẾT KẾ TỔNG THỂ (MASTER GDD): ĐẤU PHÁ THƯƠNG KHUNG — PIXEL ACTION RPG

> **Thể loại**: Top-down 2D Pixel Action RPG — Cày Cuốc, Đột Phá Cảnh Giới, Săn Dị Hỏa, Luyện Đan, Khám Phá Bí Cảnh
> **Nguyên tác**: Tiểu thuyết *Đấu Phá Thương Khung* (Thiên Tằm Thổ Đậu — Trọn bộ 1.648 chương)
> **Định hướng**: Fan-game phi thương mại / Học tập — Đồ họa Pixel Art tự thiết kế

---

## 1. Cấu Trúc Thư Mục Hồ Sơ Thiết Kế (`docs/`)

Toàn bộ nội dung game được chia nhỏ chi tiết theo đúng mạch truyện và từng hệ thống gameplay trong các thư mục con dưới đây:

```text
e:\Project\DauPhaThuongKhung\docs\
├── 00_Tong_Quan_Kien_Truc\
│   ├── 00_Master_Index_Va_Quy_Chuan.md          # Mục lục tổng, triết lý làm game hấp dẫn & quy chuẩn chung
│   ├── 01_Art_Spec_Huong_Dan_Ve_Pixel.md        # Quy chuẩn vẽ Pixel Art, SpriteSheet & Shader Dị Hỏa
│   └── 02_Tien_Do_Va_Lo_Trinh_Phat_Trien.md     # Bảng tiến độ Đã làm / Chưa làm, Bug Backlog & Roadmap M1–M6
│
├── 01_Cot_Truyen_Chi_Tiet\                      # Kịch bản chi tiết từng Hồi, Nhiệm vụ, Bí mật & Thoại theo truyện
│   ├── Quyen_01_Gia_Ma_De_Quoc\
│   │   ├── Chuong_01_O_Than_Thanh.md            # Từ Hôn, Bái Sư, Đấu Giá, Thành Niên Lễ, Hắc Bào diệt Gia Liệt
│   │   ├── Chuong_02_Ma_Thu_Son_Mach.md         # Thanh Sơn Trấn, Hang Tiểu Y Tiên, Vân Chi & Tử Hỏa, Mục Xà
│   │   ├── Chuong_03_Sa_Mac_Thap_Qua_Nhi.md     # Hải Ba Đông, Thanh Lân, Thánh Thành Xà Nhân & Thanh Liên Hỏa
│   │   └── Chuong_04_De_Do_Va_Uoc_Hen_3_Nam.md  # Mặc Gia, Nham Kiêu, Đan Hội Gia Mã, Đại chiến Vân Lam Sơn
│   │
│   ├── Quyen_02_Hac_Giac_Vuc_Va_Gia_Nam\
│   │   ├── Chuong_05_Hac_Giac_Vuc_Va_Ngoai_Vien.md # Hắc Ấn Thành, Tam Thiên Lôi Động, Khảo thí Già Nam, Săn Hỏa Năng
│   │   ├── Chuong_06_Noi_Vien_Va_Thien_Phan_Thap.md # Bàn Môn, Tử Nghiên, Cường Bảng, Vẫn Lạc Tâm Viêm & Hàn Phong
│   │   └── Chuong_07_Tam_Thuong_Van_Lam_Va_Doc_Tong.md # Diệt Vân Sơn, Dược Lão bị bắt, Viêm Minh, Xuất Vân Độc Tông
│   │
│   ├── Quyen_03_Trung_Chau_Phong_Van\
│   │   ├── Chuong_08_Bac_Vuc_Va_Dan_Hoi_Trung_Chau.md # Thiên Sơn Huyết Đàm, Phần Viêm Cốc, Đan Hội & Tam Thiên Hỏa
│   │   └── Chuong_09_Cuu_Su_Vong_Hon_Va_Thien_Mo.md   # Phá Vong Hồn Điện cứu Dược Lão, Hoa Tông, Di Tích, Thiên Mộ
│   │
│   └── Quyen_04_Thanh_De_Quyet_Chien\
│       ├── Chuong_10_Bo_De_Hoa_Thanh_Va_Tinh_Lien_Yeu_Hoa.md # Bồ Đề Cổ Thụ, Thiên Phủ Liên Minh, Yêu Hỏa Không Gian
│       └── Chuong_11_Co_De_Dong_Phu_Va_Song_De_Chi_Chien.md  # Cứu Tiêu Chiến, Cổ Đế Động Phủ, Chứng đạo Viêm Đế, Endgame
│
├── 02_He_Thong_Tu_Luyen_Va_Di_Hoa\
│   ├── Canh_Gioi_Va_Linh_Hon.md                 # 12 Đại Cảnh Giới x 9 Tinh, Cửu Chuyển, Tứ Cảnh Linh Hồn, Áp Chế
│   └── Bang_23_Di_Hoa_Va_Thu_Hoa.md             # Chi tiết trọn bộ 23 Dị Hỏa + Thú Hỏa, màu Shader, tiến hóa Phần Quyết
│
├── 03_Nhan_Vat_Va_The_Luc\
│   ├── Tieu_Viem_Va_Duoc_Lao.md                 # Chỉ số, Hình thái Pixel, Cơ chế Trọng Xích, Dược Lão & Khôi Lỗi
│   ├── Hong_Nhan_Dong_Hanh_Va_NPC.md            # Kỹ năng trợ chiến, Tuyến hảo cảm & Quest riêng của dàn nhân vật
│   └── The_Luc_Va_Phe_Phai.md                   # Quản lý thế lực tự lập (Bàn Môn -> Thiên Phủ) & Phe đối địch
│
├── 04_Dau_Ky_Cong_Phap_Va_Trang_Bi\
│   ├── Kho_Cong_Phap_Va_Dau_Ky.md               # Chi tiết toàn bộ Đấu Kỹ Hoàng -> Thiên Giai, combo & Hitbox 2D
│   ├── He_Thong_Luyen_Dan_Va_Duoc_Dinh.md       # Đan dược 1-9 Phẩm + Đế Phẩm, Mini-game Lò Đan, Đan Lôi, Thiên Đỉnh
│   └── Trang_Bi_Nap_Gioi_Va_Khoi_Loi.md         # Hệ thống rèn Xích, Nội Giáp, Phi Hành Đấu Dực, Nạp Giới, Yêu Khôi
│
└── 05_Quai_Vat_Boss_Va_Ban_Do\
    ├── He_Sinh_Thai_Ma_Thu_Va_Quai_Vat.md       # Quái thường & Tinh anh theo vùng (Cấp 1-9), AI Top-down & Bảng Loot
    ├── Thiet_Ke_Boss_Va_Co_Che_Phase.md         # Thiết kế kịch bản đánh Boss nhiều Phase từ Gia Liệt Áo tới Hồn Thiên Đế
    └── Pho_Ban_Cay_Cuoc_Va_Bi_Canh.md           # 8 Phó bản đặc biệt tạo chiều sâu cày cuốc lặp lại không chán
```

### Danh Mục Điều Hướng Nhanh (Quick Links)

* **00. Tổng Quan, Quy Chuẩn & Tiến Độ**: [Quy Chuẩn Vẽ Pixel Art](./01_Art_Spec_Huong_Dan_Ve_Pixel.md) | [Tiến Độ Dự Án, Bug Backlog & Lộ Trình Phát Triển](./02_Tien_Do_Va_Lo_Trinh_Phat_Trien.md)
* **01. Cốt Truyện Chi Tiết (11 Chương — 4 Quyển)**:
  * *Quyển 01 — Gia Mã Đế Quốc*: [Chương 01: Ô Thản Thành](../01_Cot_Truyen_Chi_Tiet/Quyen_01_Gia_Ma_De_Quoc/Chuong_01_O_Than_Thanh.md) | [Chương 02: Ma Thú Sơn Mạch](../01_Cot_Truyen_Chi_Tiet/Quyen_01_Gia_Ma_De_Quoc/Chuong_02_Ma_Thu_Son_Mach.md) | [Chương 03: Sa Mạc Tháp Qua Nhĩ](../01_Cot_Truyen_Chi_Tiet/Quyen_01_Gia_Ma_De_Quoc/Chuong_03_Sa_Mac_Thap_Qua_Nhi.md) | [Chương 04: Đế Đô & Ước Hẹn 3 Năm](../01_Cot_Truyen_Chi_Tiet/Quyen_01_Gia_Ma_De_Quoc/Chuong_04_De_Do_Va_Uoc_Hen_3_Nam.md)
  * *Quyển 02 — Hắc Giác Vực & Già Nam*: [Chương 05: Hắc Giác Vực & Ngoại Viện](../01_Cot_Truyen_Chi_Tiet/Quyen_02_Hac_Giac_Vuc_Va_Gia_Nam/Chuong_05_Hac_Giac_Vuc_Va_Ngoai_Vien.md) | [Chương 06: Nội Viện & Thiên Phần Tháp](../01_Cot_Truyen_Chi_Tiet/Quyen_02_Hac_Giac_Vuc_Va_Gia_Nam/Chuong_06_Noi_Vien_Va_Thien_Phan_Thap.md) | [Chương 07: Tam Thượng Vân Lam & Độc Tông](../01_Cot_Truyen_Chi_Tiet/Quyen_02_Hac_Giac_Vuc_Va_Gia_Nam/Chuong_07_Tam_Thuong_Van_Lam_Va_Doc_Tong.md)
  * *Quyển 03 — Trung Châu Phong Vân*: [Chương 08: Bắc Vực & Đan Hội Trung Châu](../01_Cot_Truyen_Chi_Tiet/Quyen_03_Trung_Chau_Phong_Van/Chuong_08_Bac_Vuc_Va_Dan_Hoi_Trung_Chau.md) | [Chương 09: Cứu Sư Vong Hồn & Thiên Mộ](../01_Cot_Truyen_Chi_Tiet/Quyen_03_Trung_Chau_Phong_Van/Chuong_09_Cuu_Su_Vong_Hon_Va_Thien_Mo.md)
  * *Quyển 04 — Thánh Đế Quyết Chiến*: [Chương 10: Bồ Đề Hóa Thánh & Tịnh Liên Yêu Hỏa](../01_Cot_Truyen_Chi_Tiet/Quyen_04_Thanh_De_Quyet_Chien/Chuong_10_Bo_De_Hoa_Thanh_Va_Tinh_Lien_Yeu_Hoa.md) | [Chương 11: Cổ Đế Động Phủ & Song Đế Chi Chiến](../01_Cot_Truyen_Chi_Tiet/Quyen_04_Thanh_De_Quyet_Chien/Chuong_11_Co_De_Dong_Phu_Va_Song_De_Chi_Chien.md)
* **02. Hệ Thống Tu Luyện & Dị Hỏa**: [12 Cảnh Giới & Tứ Cảnh Linh Hồn](../02_He_Thong_Tu_Luyen_Va_Di_Hoa/Canh_Gioi_Va_Linh_Hon.md) | [Bảng 23 Dị Hỏa & Thú Hỏa](../02_He_Thong_Tu_Luyen_Va_Di_Hoa/Bang_23_Di_Hoa_Va_Thu_Hoa.md)
* **03. Nhân Vật & Thế Lực**: [Tiêu Viêm & Dược Lão](../03_Nhan_Vat_Va_The_Luc/Tieu_Viem_Va_Duoc_Lao.md) | [Hồng Nhan, Đồng Hành & NPC](../03_Nhan_Vat_Va_The_Luc/Hong_Nhan_Dong_Hanh_Va_NPC.md) | [Thế Lực, Tông Môn Tự Lập & Phe Phái](../03_Nhan_Vat_Va_The_Luc/The_Luc_Va_Phe_Phai.md)
* **04. Đấu Kỹ, Luyện Đan & Trang Bị**: [Kho Công Pháp & 24 Đấu Kỹ](../04_Dau_Ky_Cong_Phap_Va_Trang_Bi/Kho_Cong_Phap_Va_Dau_Ky.md) | [Hệ Thống Luyện Đan, Đan Lôi & Thiên Đỉnh](../04_Dau_Ky_Cong_Phap_Va_Trang_Bi/He_Thong_Luyen_Dan_Va_Duoc_Dinh.md) | [Trang Bị, Nạp Giới & Yêu Khôi](../04_Dau_Ky_Cong_Phap_Va_Trang_Bi/Trang_Bi_Nap_Gioi_Va_Khoi_Loi.md)
* **05. Quái Vật, Boss & Phó Bản**: [Hệ Sinh Thái Ma Thú & Quái Vật](../05_Quai_Vat_Boss_Va_Ban_Do/He_Sinh_Thai_Ma_Thu_Va_Quai_Vat.md) | [Thiết Kế 25 Đại Boss Đa Phase](../05_Quai_Vat_Boss_Va_Ban_Do/Thiet_Ke_Boss_Va_Co_Che_Phase.md) | [8 Phó Bản Cày Cuốc & Bí Cảnh Endgame](../05_Quai_Vat_Boss_Va_Ban_Do/Pho_Ban_Cay_Cuoc_Va_Bi_Canh.md)

---

## 2. Năm Yếu Tố Làm Nên "Độ Cuốn & Tính Hấp Dẫn" Của Game

Một game chuyển thể từ truyện sẽ chết yểu nếu chỉ bắt người chơi "chạy từ A tới B chém 10 con sói rồi đọc chữ". Để game thực sự lôi cuốn người cày cuốc, mọi chương truyện trong bộ tài liệu này đều tuân theo **5 Trụ Cột Hấp Dẫn**:

1. **Khổ Tu Có Thưởng (Risk-Reward Grinding)**:
   * Đeo **Huyền Trọng Xích** ở chế độ *Trọng Áp* làm giảm tốc độ đánh/di chuyển nhưng cộng thêm **+30% EXP Đấu Khí & Rèn Thể Chất**. Khi gặp nguy hiểm, bấm tháo phong ấn xích để tốc độ bùng nổ tức thì — đúng cảm giác giấu nghề lật kèo của Tiêu Viêm!
2. **Đột Phá Cảnh Giới Thay Đổi Hẳn Lối Chơi (Qualitative Progression)**:
   * Không chỉ tăng số máu/công vô hồn. Lên *Đấu Giả* mở Nội thị & Phần Quyết; lên *Đấu Sư* có *Đấu Khí Sa Y*; lên *Đại Đấu Sư* hóa *Khải Giáp*; lên *Đấu Vương* mọc **Đấu Khí Hóa Dực** bay vọt qua địa hình; lên *Đấu Tông* đạp hư không khóa không gian (*Không Gian Phong Tỏa*); lên *Đấu Tôn* xé rách không gian dịch chuyển; lên *Đấu Thánh* mở Tịnh Liên Yêu Trận!
3. **Kỳ Ngộ Ẩn & Bí Mật Sát Nguyên Tác (Lore-Driven Exploration)**:
   * Người đọc truyện sẽ vỡ òa khi tự tay rơi xuống vách núi Thanh Sơn tìm thấy rương mật thất chứa *Tử Vân Dực*, nhận ra bóng đen **Lăng Ảnh** lướt qua mái nhà Ô Thản Thành bảo vệ Huân Nhi, hay lén mò xuống sông ngầm nhặt *Thanh Liên Đài* sau khi lấy Dị Hỏa!
4. **Săn Dị Hỏa & Tự Chế Phật Nộ Hỏa Liên (Custom Build Synergy)**:
   * Mỗi ngọn lửa thu được đổi hẳn màu sắc kỹ năng (nhờ Pixel Palette Shader) và cho phép người chơi **tự lắp ghép 2–4 loại Hỏa khác nhau** vào các khe của *Phật Nộ Hỏa Liên*, tạo ra hiệu ứng nổ độc nhất vô nhị (Đóng băng + Thiêu đốt + Nổ tâm hỏa + Hút máu!).
5. **Đấu Giá Ngầm, Luyện Đan Đón Đan Lôi & Xây Dựng Thế Lực**:
   * Đổi không khí giữa các đợt cày quái bằng việc khoác Hắc Bào đi **Đấu Giá Hội** tranh bảo vật phút chót, canh lửa **Luyện Đan** gọi sấm sét *Đan Lôi* giáng xuống (phải vừa giữ lò đan vừa đánh tan tia sét!), và bồi dưỡng đệ tử **Bàn Môn / Viêm Minh / Thiên Phủ Liên Minh** đi thu thập dược liệu tự động cho mình!

---

## 3. Quy Chuẩn Thuật Ngữ & Khung Điều Khiển Chung (Đồng Bộ Toàn Bộ Tài Liệu)

### 3.1. Bộ 6 Chỉ Số Nhân Vật (Core Stats)
* **HP (Sinh Lực)**: Máu nhân vật.
* **QI (Đấu Khí)**: Năng lượng thi triển Đấu Kỹ, duy trì Giáp/Cánh Đấu Khí.
* **ATK (Công Kích)**: Sát thương gốc của đòn đánh và Đấu Kỹ.
* **DEF (Phòng Ngự)**: Giảm sát thương vật lý/Đấu Khí nhận vào.
* **SPD (Thân Pháp)**: Tốc độ chạy, tốc độ xuất chiêu, tỷ lệ Chí mạng (Crit).
* **SOUL (Linh Hồn Lực)**: Chia 4 đại cảnh giới (*Phàm Cảnh → Linh Cảnh → Thiên Cảnh → Đế Cảnh*), quyết định phẩm cấp Luyện Đan, tầm quét cảm nhận báu vật/kẻ địch ẩn thân, và sát thương khống hỏa/tâm hỏa.

### 3.2. Khung Điều Khiển Top-down 2D Action RPG
* `WASD`: Di chuyển 8 hướng, mặt nhân vật hướng theo con trỏ chuột.
* `Chuột Trái (LMB)`: Đánh thường Combo (Tay không / Huyền Trọng Xích).
* `Chuột Phải (RMB)` hoặc `C`: Chuyển đổi trạng thái *Phong Ấn / Giải Phong Huyền Trọng Xích* (hoặc kích hoạt *Thiên Hỏa Tam Huyền Biến* ở nửa sau game).
* `Space`: Thân pháp Lướt né (`Dash` có I-frame — tiến hóa dần lên *Tử Vân Dực* → *Tam Thiên Lôi Động*).
* `Q`, `E`, `R`: 3 ô trang bị **Đấu Kỹ Chủ Động** tùy chọn từ kho kỹ năng đã học.
* `F`: Tuyệt kỹ **Phật Nộ Hỏa Liên** (Dung hợp đa Hỏa).
* `T`: Kỹ năng Trợ Chiến Đặc Biệt (*Dược Lão Phụ Thể* đầu game → *Triệu Hồi Thiên Yêu Khôi / Hồng Nhan Hợp Kích* cuối game).
* `1`, `2`, `3`: Uống nhanh Đan Dược gắn trên đai lưng.

### 3.3. Thang 12 Đại Cảnh Giới Chuẩn (Level Tier Mapping)
1. **Đấu Chi Khí** (1–9 Đoạn) — *Level 1–9*
2. **Đấu Giả** (1–9 Tinh) — *Level 10–19*
3. **Đấu Sư** (1–9 Tinh) — *Level 20–29*
4. **Đại Đấu Sư** (1–9 Tinh) — *Level 30–39*
5. **Đấu Linh** (1–9 Tinh) — *Level 40–49*
6. **Đấu Vương** (1–9 Tinh) — *Level 50–59*
7. **Đấu Hoàng** (1–9 Tinh) — *Level 60–69*
8. **Đấu Tông** (1–9 Tinh) — *Level 70–79*
9. **Đấu Tôn** (1–9 Tinh + *Cửu Chuyển Đấu Tôn 1–9 Chuyển*) — *Level 80–94*
10. **Bán Thánh** (Sơ - Trung - Cao Cấp) — *Level 95–99*
11. **Đấu Thánh** (1–9 Tinh: Sơ - Trung - Hậu - Đỉnh Phong) — *Level 100–119*
12. **Đấu Đế (Viêm Đế)** — *Level 120 (Cực Hạn Thần Thoại)*
