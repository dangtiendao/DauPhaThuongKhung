# HỆ SINH THÁI MA THÚ, QUÂN ĐOÀN HỒN ĐIỆN, AI TOP-DOWN 2D & BẢNG LOOT

> **Mã tài liệu**: `05_Quai_Vat_Boss_Va_Ban_Do\He_Sinh_Thai_Ma_Thu_Va_Quai_Vat.md`
> **Phạm vi**: Phân cấp Ma Thú 1–9 & Tứ Đại Gia Tộc Viễn Cổ, Danh mục Quái thường & Tinh Anh theo 10 vùng bản đồ + Quân đoàn Hồn Điện, 8 Mẫu Hành vi AI Top-down 2D, Quy chuẩn tối ưu Pixel Art và Bảng tỷ lệ rớt đồ (Loot Table).
> **Đồng bộ**: Tương thích chặt chẽ với 12 Đại Cảnh Giới, chỉ số cảm nhận `SOUL`, nguyên liệu Luyện Đan / Đúc Yêu Khôi tại [00_Master_Index_Va_Quy_Chuan.md](../00_Tong_Quan_Kien_Truc/00_Master_Index_Va_Quy_Chuan.md).

---

## 1. Hệ Thống Phân Cấp Ma Thú (Cấp 1 -> Cấp 9) & Tứ Đại Gia Tộc Viễn Cổ

### 1.1. Bảng Đối Chiếu Cấp Bậc Ma Thú Tương Ứng 12 Đại Cảnh Giới Nhân Loại
Trong nguyên tác, Ma Thú có tuổi thọ dài đằng đẵng và nhục thân trời phú vượt trội hơn nhân loại cùng cảnh giới, nhưng lại thua thiệt về Linh Hồn Lực (`SOUL`) và sự tinh diệu của Đấu Kỹ ở giai đoạn đầu:

| Cấp Bậc Ma Thú | Tương Ứng Cảnh Giới Nhân Loại | Cấp Độ (`Level`) | Đặc Điểm Tiến Hóa Sinh Học & Gameplay 2D | Tỷ Lệ Rớt **Ma Hạch** Gốc |
| :--- | :--- | :---: | :--- | :---: |
| **Á Ma / Dã Thú** | Đấu Chi Khí (1–9 Đoạn) | `Lv.1 – 9` | Thú hoang hung dữ, chưa kết tụ Ma Hạch, chỉ rớt thịt/da/xương. | `0%` *(Chỉ rớt Vật liệu)* |
| **Ma Thú Cấp 1** | Đấu Giả (1–9 Tinh) | `Lv.10 – 19` | Biết truyền năng lượng nguyên tố sơ cấp vào răng vuốt. | `18%` Ma Hạch Cấp 1 |
| **Ma Thú Cấp 2** | Đấu Sư (1–9 Tinh) | `Lv.20 – 29` | Da dày như giáp nhẹ (`+15% DEF`), biết phóng đạn nguyên tố tầm ngắn. | `16%` Ma Hạch Cấp 2 |
| **Ma Thú Cấp 3** | Đại Đấu Sư (1–9 Tinh) | `Lv.30 – 39` | Kết tinh vỏ năng lượng cứng quanh người, bắt đầu đi săn theo bầy. | `15%` Ma Hạch Cấp 3 |
| **Ma Thú Cấp 4** | Đấu Linh (1–9 Tinh) | `Lv.40 – 49` | Thống lĩnh một vùng rừng nhỏ; có **Thanh Giáp Cứng** chống khựng đòn. | `14%` Ma Hạch Cấp 4 |
| **Ma Thú Cấp 5** | Đấu Vương (1–9 Tinh) | `Lv.50 – 59` | Mở linh trí sơ đẳng, biết bay lượn hoặc điều khiển địa hình khu vực. | `12%` Ma Hạch Cấp 5 |
| **Ma Thú Cấp 6** | Đấu Hoàng (1–9 Tinh) | `Lv.60 – 69` | Biết nói tiếng người (hoặc ăn *Hóa Hình Thảo* hóa người); nhục thân cực khỏe! | `10%` Ma Hạch Cấp 6 |
| **Ma Thú Cấp 7** | Đấu Tông (1–9 Tinh) | `Lv.70 – 79` | **Tự động hóa hình người**, thu nhỏ Hurtbox nhưng tốc độ & lực đấm kinh hoàng. | `9%` Ma Hạch Cấp 7 |
| **Ma Thú Cấp 8** | Đấu Tôn & Cửu Chuyển | `Lv.80 – 94` | *Bát Giai Chí Tôn Thú*: Vận dụng Không Gian Chi Lực, tiếng gầm rung màn hình! | `8%` Ma Hạch Cấp 8 |
| **Ma Thú Cấp 9** | Bán Thánh & Đấu Thánh | `Lv.95 – 119` | *Cửu Giai Thánh Thú*: Huyết mạch thượng cổ bất tử, chỉ xuất hiện ở Cổ Vực/Đảo Rồng. | `7%` Ma Hạch Cấp 9 |
| **Đế Thú / Thần Thú** | Đấu Đế (Cực Hạn) | `Lv.120` | Sinh vật thần thoại ở Khe Nứt Vị Diện / Cổ Đế Động Phủ. | **`100%`** Đế Nguyên Hạch |

> **Sự Khác Biệt Chiến Thuật ("Nhân Tu vs. Ma Thú")**:
> * **Đánh Ma Thú**: Máu dày (`+35% HP`), sát thương húc vồ to, nhưng dễ bị khắc chế bởi kỹ năng **Tâm Hỏa** (*Vẫn Lạc Tâm Viêm*) và **Âm Ba Linh Hồn** (*Sư Hổ Toái Kim Ngâm / Hoàng Tuyền Thiên Nộ*).
> * **Đánh Cường Giả Nhân Loại & Hồn Điện**: Máu giấy hơn nhưng **AI biết lướt né đòn chậm**, bật *Đấu Khí Khải Giáp*, uống trộm thuốc hồi máu hoặc kết *Kiếm Trận* bọc lót nhau!

---

### 1.2. Tứ Đại Gia Tộc Ma Thú Viễn Cổ (Đỉnh Phong Huyết Mạch Thượng Cổ)
Ở nửa sau game (Quyển 3 & Quyển 4), thế giới Ma Thú xoay quanh 4 chủng tộc thượng cổ có huyết mạch áp chế toàn bộ vạn thú thông thường:

| Gia Tộc Viễn Cổ | Màu Sắc & Hình Thái Pixel | Thiên Phú Huyết Mạch Trong Gameplay | Quan Hệ Cốt Truyện Với Tiêu Viêm |
| :--- | :--- | :--- | :--- |
| **1. Thái Hư Cổ Long** *(Đệ Nhất Thú Tộc)* | Tím Hoàng Kim lấp lánh vảy rồng không gian (`64×64 px` dạng rồng / `22×26 px` hóa người) | **Thôn Phệ Hư Không & Khóa Chặt Không Gian**: Vô hiệu hóa kỹ năng lướt `Space` của mục tiêu trong `2s`; vảy rồng giảm `40%` sát thương vật lý! | **Đồng minh ruột thịt** (nhờ Long Hoàng **Tử Nghiên**); Tiêu Viêm giúp dẹp loạn Tam Đại Long Vương đảo Bắc – Nam – Tây và đúc **Bắc Vương**! |
| **2. Thiên Yêu Hoàng** *(Thiên Địch Cổ Long)* | Mười màu ngọc bích rực rỡ, sau lưng mọc đôi cánh Cửu Phượng sắc như đao | **Cực Tốc Yêu Vũ & Hóa Thạch Yêu Nhãn**: Di chuyển tàn ảnh siêu thanh, tiếng hót làm nhiễu loạn thanh `QI` của người chơi. | **Thù địch dai dẳng!** Vì Tiêu Viêm dám xẻ xác tổ tiên chúng làm *Thiên Nhạn Cửu Hành Dực*, tộc nhân Thiên Yêu Hoàng (*Phượng Thanh Nhi, Hoàng Thiên, Cửu Phượng*) liên tục săn đuổi đòi cánh! |
| **3. Cửu U Địa Minh Mãng** *(Đông Đảo Nhất)* | Xanh Đen u ám quấn khói lạnh Hoàng Tuyền, mắt dọc đỏ ngầu | **Hàn Âm Cửu U & Phân Thân Mãng Ảnh**: Đòn đánh tích thanh *Đóng Băng Hàn Độc*; chết ở đầm lầy có thể lột xác hồi `30% HP`. | Ban đầu xung đột với Đại trưởng lão *Yêu Khiếu Thiên*, sau khi Tiêu Viêm cứu tộc trưởng **Yêu Minh** dưới đáy Hoàng Tuyền Đàm thì trở thành quân chủ lực Thiên Phủ! |
| **4. Viễn Cổ Long Hùng** *(Bá Chủ Sức Mạnh)* | Nâu Vàng Khổng Lồ (`56×56 px`), gấu cổ đại phủ kín vảy rồng trên vai | **Bá Thể Tuyệt Đối (`Unstoppable`)**: Không thể bị đẩy lùi hay hất tung bởi bất kỳ chiêu nào dưới Thiên Giai; vồ đất tạo sóng chấn động toàn màn hình! | Sinh sống hoang dã trong **Mãng Hoang Cổ Vực**, canh giữ khu vực Bồ Đề Cổ Thụ xuất thế. |

---

## 2. Danh Mục Chủng Loại Quái Thường & Tinh Anh Theo 10 Vùng Bản Đồ

Mỗi vùng bản đồ có hệ sinh thái riêng biệt, không lặp lại nhàm chán, gắn trực tiếp với một tổ hợp **Mẫu AI (Mục 3)** và nguyên liệu đặc thù:

### Vùng 1: Hậu Sơn Ô Thản Thành & Ma Thú Sơn Mạch *(Chương 1 – 2 | Lv.1 – 29)*
* **Quái Thường**:
  * *Thiết Mộc Lang* (Á Ma – Cấp 1, Hệ Mộc | AI: `Lao Húc`): Đi săn theo đàn 3–4 con, rớt *Da Sói, Răng Sói*.
  * *Xích Băng Xà* (Cấp 1, Hệ Băng | AI: `Độn Thổ` dưới cỏ cao): Phun nọc làm chậm `20%`, rớt *Xà Đản Quả, Túi Độc*.
  * *Hỏa Tinh Viên* (Cấp 2, Hệ Hỏa | AI: `Pháo Kích`): Vượn lông đỏ ném đá lửa từ mỏm núi cao, rớt *Ma Hạch Cấp 2 (Hỏa)*.
  * *Lính Đánh Thuê Lang Đầu Đoàn* (Đấu Giả – Đấu Sư | AI: `Khiên Phản Đòn` + Cung thủ): Kẻ địch nhân loại đầu tiên, rớt *Kim Tệ, Hồi Khí Tán*.
* **Quái Tinh Anh / Thú Vương Khu Vực**:
  * **Hắc Nham Cuồng Hùng** (Cấp 2 Đỉnh | AI: `Khiên Phản Đòn + Lao Húc`): Gấu đá giáp cứng canh hang *Tử Diệp Lan Thảo*, cần dùng *Toái Thạch Chưởng* đập vỡ giáp.
  * **Song Dực Hắc Vân Điêu** (Cấp 3 | AI: Bay bổ nhào): Săn trên vách núi Thanh Sơn, rớt *Tinh Huyết Điêu* nâng cấp *Tử Vân Dực*.

### Vùng 2: Sa Mạc Tháp Qua Nhĩ & Lãnh Địa Xà Nhân *(Chương 3 | Lv.28 – 42)*
* **Quái Thường**:
  * *Sa Độc Hạt* (Cấp 2–3, Hệ Độc | AI: `Độn Thổ` cát lún): Chui lên đâm đuôi bọ cạp gây Độc rút máu.
  * *Phệ Thạch Nghĩ (Kiến Ăn Đá)* (Cấp 2, Đàn đông 12 con | AI: `Nổ Khi Chết` axit): Máu ít nhưng vây kín chân, dùng *Xuy Hỏa Chưởng* thổi bay cả cụm cực đã!
  * *Xà Nhân Tuần Tra Binh & Mị Xà Nữ* (Đấu Sư – Đại Đấu Sư | AI: Lao giáo lướt cát + Hôn gió làm Chậm): Rớt *Xà Lân, Xích Đồng Sa Tinh*.
* **Quái Tinh Anh**:
  * **Song Đầu Hỏa Linh Xà** (Cấp 4 — Sông ngầm dung nham | AI: `Độn Thổ` nham thạch + Phun 2 tia lửa chữ V): Canh giữ đường vào *Thanh Liên Địa Tâm Hỏa*!
  * **Xà Nhân Bát Đại Thống Lĩnh (Tinh Anh Tuần Phòng)** (Đấu Linh | AI: `Kiếm Trận Liên Kết` 2 giáo xà nhân): Rớt *Ma Hạch Cấp 4, Quyển Trục Huyền Giai*.

### Vùng 3: Đế Đô Gia Mã, Vân Lam Sơn & Biên Giới Độc Tông *(Chương 4 & 7 | Lv.38 – 65)*
* **Quái Thường**:
  * *Mặc Gia Thiết Vệ (Ghép Chi Ma Thú)* (Đại Đấu Sư | AI: `Lao Húc` cuồng loạn): Nửa người nửa tay gấu/báo do Mặc Thừa cấy ghép.
  * *Vân Lam Chấp Pháp Đệ Tử* (Đại Đấu Sư – Đấu Linh | AI: **`Kiếm Trận Liên Kết` Vân Yên Phúc Nhật Trận**): 4 đệ tử áo trắng nối kiếm khí phong hệ!
  * *Vạn Độc Triết Chu & Độc Sư Xuất Vân* (Đấu Linh – Đấu Vương | AI: `Pháo Kích` đầm độc + `Nổ Khi Chết` khói tím).
* **Quái Tinh Anh**:
  * **Vân Lam Hộ Pháp Trưởng Lão** (Đấu Vương | AI: Phong Nhận Liên Hoàn + Bay lượn): Rớt *Vân Lam Tinh Kim, Phá Chướng Đan*.
  * **Huyết Độc Ngô Công (Rết Khổng Lồ Cấp 6)** (Đấu Hoàng | AI: `Độn Thổ` liên hoàn 3 điểm): Rớt *Ma Hạch Cấp 6 (Độc)*.

### Vùng 4: Hắc Giác Vực & Thâm Sơn Nội Viện Già Nam *(Chương 5 – 6 | Lv.45 – 64)*
* **Quái Thường**:
  * *Hắc Bảng Ám Sát Giả* (Đấu Linh – Đấu Vương | AI: **`Sát Thủ Tàng Hình`**): Ẩn mình trong hẻm tối Hắc Ấn Thành đâm lén đoạt của!
  * *Huyết Tông Huyết Đồ* (Đấu Linh | AI: Hút máu cận chiến): Chém trúng người chơi tự hồi máu.
  * *Hỏa Tinh Tích Dịch (Thằn Lằn Lửa Đáy Tháp)* (Cấp 5, Hệ Hỏa | AI: `Lao Húc` để lại vệt lửa + `Nổ Khi Chết`): Quái cày EXP & Hỏa Năng dưới đáy *Thiên Phần Luyện Khí Tháp*.
* **Quái Tinh Anh**:
  * **Tuyết Ma Thiên Viên** (Cấp 6 Đỉnh / Chuẩn Cấp 7 — Khỉ Tuyết Khổng Lồ Trắng Xóa | AI: `Khiên Phản Đòn` bằng băng + Đập ngực chấn địa): Thủ hộ *Địa Tâm Tôi Thể Nhũ*!
  * **Thiết Giáp Tê Ngưu Vương** (Cấp 6 | AI: `Lao Húc` húc sập cây cối rừng Già Nam): Rớt *Tinh Huyết Cấp 6, Long Lực Đan nguyên liệu*.

### Vùng 5: Bắc Vực, Thiên Sơn Huyết Đàm & Lôi Sơn *(Chương 8 | Lv.68 – 80)*
* **Quái Thường**:
  * *Phệ Kim Thử (Đàn Chuột Vàng Ăn Kim Loại)* (Cấp 3–5 nhưng đi thành **bầy 25 con** dưới chân Thiên Sơn | AI: Gặm tụt Giáp Đấu Khí — phải bật sóng âm *Sư Hổ Toái Kim Ngâm* mới dẹp nổi!).
  * *Phong Lôi Các Tinh Nhuệ* (Đấu Hoàng – Đấu Tông | AI: Lướt tia chớp ngắn áp sát).
  * *Hỏa Độc Giao Xà* (Cấp 6–7 | AI: Lặn dưới đầm máu phóng lao lửa độc).
* **Quái Tinh Anh**:
  * **Hoàng Kim Thử Vương** (Cấp 7, Hệ Âm Ba | AI: Rít sóng âm gọi viện binh chuột vàng) & **Lôi Phạt Trưởng Lão** (Đấu Tông | Rớt *Hư Không Lôi Đồng*).

### Vùng 6, 7, 8 & 9: Trung Châu Thâm Vực — Đan Giới, Di Tích, Thiên Mộ & Mãng Hoang *(Chương 8 – 10 | Lv.80 – 112)*
* **Vạn Dặm Đan Giới**: *Vạn Dược Thú* (Cấp 7–8), *Thiên Yêu Khôi Thạch Vệ*, *Huyết Tinh Cuồng Sư Cấp 8* (rớt thánh dược Bát Phẩm!).
* **Viễn Cổ Di Tích Đấu Thánh**: *Cốt Giáp Đường Lang* (AI: `Sát Thủ Tàng Hình` chém liềm xương), *Thú Hồn Khôi Lỗi* (AI: `Khiên Phản Đòn` kim loại — rớt *Thánh Cốt Tinh Kim* đúc 10 Thiên Yêu Khôi!).
* **Thiên Mộ Tam Tầng**: *Năng Lượng Thể Đấu Tôn (Tầng 1)* -> *Cửu Chuyển Huyết Linh Thể (Tầng 2)* -> *Viễn Cổ Bán Thánh Năng Lượng Thể (Tầng 3)*! Đặc điểm: Không có máu thịt, sau khi bị đánh gục sẽ rơi thẳng **Năng Lượng Hạch Tinh Thuần** giúp Tiêu Viêm cày cấp thần tốc!
* **Mãng Hoang Cổ Vực & Yêu Hỏa Không Gian**: *Mãng Hoang Độc Trùng Triều* (mưa axit ăn mòn Đấu Khí), *Viễn Cổ Long Hùng Cấp 9*, và quân đoàn **Hỏa Nô Đấu Tôn / Bán Thánh** mắt trắng dã do *Tịnh Liên Yêu Hỏa* khống chế!

---

### Vùng 10 (Đặc Biệt): Hệ Thống Quân Đoàn "HỒN ĐIỆN & HỒN TỘC" (Xuyên Suốt Chương 4 -> 11)
Hồn Điện là thế lực phản diện ám ảnh nhất toàn truyện — luôn xuất hiện trong màn sương đen rợn người kèm tiếng xích sắt loảng xoảng đi săn lùng Linh Hồn Luyện Đan Sư và Cổ Ngọc:

| Cấp Bậc Quân Hàm Hồn Điện | Cảnh Giới Thực Lực | Vũ Khí & Mẫu AI Đặc Trưng | Khắc Chế Chuẩn Nguyên Tác & Chiến Lợi Phẩm |
| :--- | :--- | :--- | :--- |
| **1. Hồn Sứ (Hắc Y Sứ Giả)** | Đấu Vương – Đấu Hoàng | Quăng xích đen trói chân (`AI: Hút Linh Hồn` tầm gần). | Dùng **Dị Hỏa** thiêu xích gây `×1.5 sát thương`! Rớt *Túi Hồn Sơ Cấp*. |
| **2. Nhân / Địa / Thiên Hộ Pháp** *(Vụ, Thiết, Ngô, Hiên Hộ Pháp)* | Đấu Tông (1–9 Tinh) | Nuốt oán hồn hóa khổng lồ mặc **Hắc Vụ Khải Giáp** (`AI: Hút Linh Hồn + Khiên Hắc Vụ`). | Gọi **Địa Yêu Khôi** (vô hồn) ra đấm thẳng mặt + ném *Hỏa Liên* phá vụ giáp! Rớt **Hung Hồn Đúc Khôi** + *Hồn Đan tăng SOUL*! |
| **3. Hồn Điện Tôn Lão** *(Thanh Hoa, Mộ Cốt, Trích Tinh)* | Đấu Tôn (1–9 Tinh) | Bóp nát không gian, phóng **Toái Hồn Chưởng** tấn công thẳng vào thanh `SOUL`. | Dùng *Hoàng Tuyền Chỉ* khóa hồi máu + *Thiên Yêu Khôi* kèm sát! Rớt *Túi Linh Hồn Bản Nguyên*. |
| **4. Cửu Đại Thiên Tôn** *(Cửu -> Tam -> Nhị -> Đại Thiên Tôn)* | Cửu Chuyển Đấu Tôn -> Bán Thánh Cao Cấp | Huyết Hà Hồn Trận (`AI: Kiếm Trận Liên Kết` bằng sương máu), triệu hồi Minh Hồn Long. | Bật *Tịnh Liên Yêu Trận* tịnh hóa cả mảng sương máu! Rớt *Ma Hạch Cấp 9 / Thánh Cốt*. |
| **5. Hồn Tộc Tứ Ma Thánh & Thôn Linh Tộc** | Thất Tinh -> Bất Tử Cửu Tinh Đấu Thánh | Xé rách hư không triệu hồi **Hủy Diệt Hồn Lôi**, cắn nuốt linh khí bản đồ. | Mở *Đế Cảnh Linh Hồn Pháp Tướng* + **Bắc Vương** nghênh chiến! Rớt *Mảnh Cổ Ngọc / Đế Tinh*. |

---

## 3. Thiết Kế Chi Tiết 8 Mẫu Hành Vi AI Top-down 2D (Chống Nhàm Chán Tuyệt Đối)

Mọi quái vật trong game không bao giờ chỉ "đi bộ thẳng vào người chơi rồi cắn". Chúng vận hành dựa trên **8 Mẫu Hành Vi AI Gốc (`Core Combat AI Modules`)** với tín hiệu cảnh báo mặt đất (`Pixel Ground Telegraph`) cực kỳ rõ ràng để thưởng xứng đáng cho kỹ năng phản xạ của người chơi:

### Mẫu 01: Lao Húc Thẳng (`Bull Charge`)
* **Dấu hiệu báo trước (`Telegraph 0.65s`)**: Quái cào chân xuống đất lóe mắt đỏ, vẽ một **dải băng mũi tên đỏ `224 × 36 px`** khóa hướng đứng hiện tại của người chơi.
* **Thực thi**: Phóng vọt với tốc độ `350% SPD` gây sát thương lớn và hất ngã.
* **Tương tác Khắc chế Sướng Tay**: Nếu người chơi lướt `Space` sang ngang khiến quái **húc sầm đầu vào vách đá, gốc cây to hoặc cột trụ đá**, quái sẽ bị **Dội Ngược Tự Choáng `2.5s`** và lộ điểm yếu nhận `×1.5 sát thương`!

### Mẫu 02: Độn Thổ Đánh Úp (`Subterranean Burrow`)
* **Dấu hiệu báo trước**: Quái chui tọt xuống cát/nham thạch (vô hiệu hóa khóa mục tiêu trên mặt đất), xuất hiện **vệt đất đùn bụi chạy ngầm** dưới chân người chơi rồi dừng lại rung mạnh `0.5s` trước khi vọt lên đớp!
* **Tương tác Khắc chế**: Nhấn giữ `Space` bay lơ lửng bằng *Tử Vân Dực* khiến nó vồ hụt giữa không khí, hoặc dùng các chiêu chấn địa (*Phúc Địa Ấn / Diễm Phân Phệ Lãng Xích*) bổ thẳng xuống mô đất đang đùn để **ép nó văng ngược lên mặt đất ngửa bụng Choáng `2.0s`**!

### Mẫu 03: Pháo Kích Cầu Vồng (`Area Mortar`)
* **Dấu hiệu báo trước**: Quái giữ khoảng cách xa `240 px`, bắn cầu lửa/nọc độc bay vòng cung lên cao; dưới mặt đất hiện **vòng tròn viền đỏ thu nhỏ dần (`80 px`)** trong `0.9s`, để lại vũng độc/lửa cháy `4s`.
* **Tương tác Khắc chế**: Dùng *Hấp Chưởng* kéo tuột tên pháo thủ bay ngược vào chính vũng độc hắn vừa bắn, hoặc bật *Lục Hợp Du Thân Xích* gạt nổ quả đạn ngay lúc chạm đất!

### Mẫu 04: Kiếm Trận Liên Kết (`Tethered Formation Pack`)
* **Dấu hiệu báo trước**: Nhóm `3 – 5 tên đệ tử tông môn` đứng thành hình tam giác/ngũ giác, nối với nhau bằng **sợi dây ánh sáng Đấu Khí**: Chia đều sát thương nhận vào và nhận **`+50% DEF`**.
* **Tương tác Khắc chế**: Dùng *Xuy Hỏa Chưởng* hoặc *Bát Cực Băng* đấm văng 1 tên bay xa quá `160 px` làm **đứt phụt dây trận pháp**, khiến cả nhóm bị phản phệ mất ngay `15% HP` và khựng `1.5s`!

### Mẫu 05: Sát Thủ Tàng Hình (`Stealth Backstab`)
* **Dấu hiệu báo trước**: Quái hòa vào bóng tối (độ mờ `Alpha 12%`, chỉ thấy gợn không khí lờ mờ), lặng lẽ vòng ra đúng hướng lưng con trỏ chuột của Tiêu Viêm để đâm lén chí mạng.
* **Tương tác Khắc chế bằng Chỉ số `SOUL`**: Linh Hồn Lực càng cao thì xung quanh Tiêu Viêm càng có **Vòng Cảm Ứng Vô Hình** — ngay khi tên sát thủ bước vào bán kính cảm ứng `SOUL`, cơ thể hắn lập tức bị **quét hiện viền tím rực rỡ** kèm tiếng chuông cảnh báo để người chơi xoay lưng vung Trọng Xích bổ thẳng mặt!

### Mẫu 06: Khiên Cứng Phản Đòn (`Directional Front Shield`)
* **Dấu hiệu báo trước**: Quái giơ mai rùa/khiên sắt sáng trắng che góc `120°` phía trước mặt, giảm `90%` sát thương trực diện. Khi khiên lóe vàng mà người chơi vẫn chém thường `LMB` vào sẽ bị bật ngược khựng tay!
* **Tương tác Khắc chế**: Dùng *Tam Thiên Lôi Động* lướt xuyên qua người nó chém vào tấm lưng không giáp (`×1.4 Backstab Damage`), hoặc tích đủ Ám Kình đấm **Bát Cực Băng** xuyên thẳng qua khiên!

### Mẫu 07: Xiềng Xích Hút Hồn (`Soul Tether Drain` — Đặc Sản Hồn Điện)
* **Dấu hiệu báo trước**: Hồn Sứ / Hộ Pháp quăng sợi xích đen găm vào ngực Tiêu Viêm (tầm tối đa `192 px`), mỗi giây rút `15 QI` của người chơi chuyển thành máu và khiên Hắc Vụ cho hắn!
* **Tương tác Khắc chế**: Phóng bất kỳ kỹ năng mang **Dị Hỏa** nào cắt ngang sợi xích đen — ngọn lửa chí dương sẽ **cháy ngược theo đường dây xích truyền thẳng vào người tên Hồn Điện gây Nổ Hồn Choáng `2.0s`**! Hoặc cho *Địa/Thiên Yêu Khôi* (vốn không có linh hồn tươi) đứng chắn hứng xích làm hắn hút hụt tự nghẹn!

### Mẫu 08: Phình Xác Tự Bạo (`Volatile Death Detonation`)
* **Dấu hiệu báo trước**: Khi thanh máu về `0`, quái không biến mất ngay mà đứng phồng bụng đỏ rực kèm tiếng rít cao dần trong `1.2s` rồi phát nổ bán kính `96 px` (**gây sát thương cho cả người chơi LẪN toàn bộ quái khác trong vùng!**).
* **Tương tác Khắc chế ("Biến Quái Thành Bom")**: Ngay khi thấy quái phồng đỏ sắp nổ, tung *Xuy Hỏa Chưởng* đá văng cái xác đang bốc khói lao thẳng vào giữa bầy quái Tinh Anh phía xa tạo chuỗi nổ Domino dọn sạch cả phòng!

---

## 4. Quy Tắc Tối Ưu Pixel Art Cho Người Tự Vẽ & Bảng Loot Table Tổng

### 4.1. Công Thức Nhân Bản 1 Sprite Quái Gốc Thành 4 Bậc Biến Thể
Để một người hoặc nhóm nhỏ tự vẽ vẫn tạo ra hơn **120+ loại quái đa dạng** khắp 11 chương mà không quá tải:
1. **Bậc Thường (`Normal` — Scale `1.0x`)**: Bảng màu gốc tự nhiên, gắn `1 Mẫu AI`.
2. **Bậc Biến Dị Nguyên Tố (`Mutated` — Scale `1.0x` + Palette Swap)**: Đổi bảng màu 4 sắc độ sang Đỏ Lửa / Xanh Băng / Tím Độc -> Đổi nguyên tố đạn bắn ra (ví dụ *Thiết Mộc Lang* -> *Hàn Băng Lang* ở Bắc Vực).
3. **Bậc Tinh Anh Đầu Đàn (`Elite` — Scale `1.25x` + Viền Pixel Sáng `1px Outline`)**: Máu `×3.5`, Công `×1.4`, có thêm **Thanh Giáp Đấu Khí** và kết hợp `2 Mẫu AI` (ví dụ vừa `Khiên Cứng` vừa `Lao Húc`).
4. **Bậc Thú Vương / Tiểu Đầu Mục (`Mini-Boss` — Scale `1.5x` + Hạt Aura Ma Khí dưới chân)**: Máu `×8.0`, miễn nhiễm đẩy lùi nhẹ, canh giữ Rương Đấu Kỹ hoặc Cây Thuốc Quý, chắc chắn rớt nguyên liệu hiếm!

### 4.2. Bảng Tỷ Lệ Rớt Vật Phẩm Tổng Hợp (`Global Loot Table & Pity System`)

| Phân Hạng Kẻ Địch | Vàng / Tiền Khu Vực | Dược Liệu & Khoáng | Ma Hạch Cùng Cấp | Tinh Huyết / Túi Hồn | Quyển Trục Đấu Kỹ / Đan Phương Hiếm |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Quái Thường (`Normal`)** | `100%` (`1×`) | `25%` (`1–2 món`) | `8% – 18%` *(theo cấp)* | `2%` | `0.2%` *(Mảnh ghép quyển trục)* |
| **Quái Biến Dị (`Mutated`)** | `100%` (`1.5×`) | `40%` *(Đúng hệ)* | `22%` *(Chuẩn thuộc tính)* | `6%` | `0.8%` |
| **Tinh Anh (`Elite`)** | `100%` (`4×`) | `85%` (`2–3 món`) | **`65%`** | **`30%`** | `5.0%` *(Mảnh / Công thức hoàn chỉnh)* |
| **Thú Vương / Hộ Pháp (`Mini-Boss`)** | `100%` (`10×`) | `100%` *(Có thuốc quý)* | **`100%`** (`1–2 viên`) | **`80%`** *(+Xác/Hung hồn)* | **`25.0%`** *(Chắc chắn rớt lần đầu hạ gục!)* |

> **Cơ Chế Bảo Hiểm Chống Xui Xẻo (`Smart Loot Pity`)**:
> * Nếu người chơi đang ghim theo dõi (`Track Recipe`) một công thức Đan Dược hoặc Bậc Rèn Xích cần **Ma Hạch / Tinh Huyết cụ thể**, mỗi con quái cùng loại bị hạ mà chưa rớt món đó sẽ cộng ngầm **`+8% tỷ lệ rớt`** cho con tiếp theo — đảm bảo không bao giờ đánh quá `12 con` mà phải về tay trắng!

---

## 5. Công Thức Scaling Chỉ Số Quái 120 Cấp & Quy Tắc "Áp Chế Cảnh Giới"

### 5.1. Bảng Chuẩn Hóa Chỉ Số Quái Thường (`Normal Mob Baseline`) Theo 12 Đại Cảnh Giới
Bảng dưới đây là mốc tham chiếu chuẩn để nạp thẳng vào `MonsterStatTable.json` (Tinh Anh nhân `×3.5 HP, ×1.4 ATK`; Thú Vương nhân `×8.0 HP, ×1.8 ATK`):

| Mốc Cảnh Giới Quái | Cấp Độ (`Lv`) | `HP` Gốc | `ATK` Gốc | `DEF` Gốc | Giáp Đấu Khí | `EXP` Rớt Cơ Bản |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **1. Á Ma / Đấu Chi Khí** | `Lv.1 – 9` | `80 – 260` | `12 – 28` | `4 – 12` | `0` | `15 – 45 EXP` |
| **2. Cấp 1 / Đấu Giả** | `Lv.10 – 19` | `380 – 950` | `38 – 75` | `18 – 38` | `0` | `70 – 160 EXP` |
| **3. Cấp 2 / Đấu Sư** | `Lv.20 – 29` | `1,300 – 2,800` | `95 – 175` | `48 – 90` | `30% HP` *(Sa Y)* | `220 – 480 EXP` |
| **4. Cấp 3 / Đại Đấu Sư** | `Lv.30 – 39` | `3,800 – 7,500` | `220 – 390` | `110 – 195` | `50% HP` *(Khải Giáp)* | `650 – 1,350 EXP` |
| **5. Cấp 4 / Đấu Linh** | `Lv.40 – 49` | `10,500 – 21,000` | `480 – 820` | `240 – 410` | `60% HP` | `1,800 – 3,600 EXP` |
| **6. Cấp 5 / Đấu Vương** | `Lv.50 – 59` | `28,000 – 55,000` | `1,050 – 1,750` | `500 – 850` | `75% HP` | `4,800 – 9,500 EXP` |
| **7. Cấp 6 / Đấu Hoàng** | `Lv.60 – 69` | `72,000 – 145,000` | `2,200 – 3,600` | `1,050 – 1,750` | `90% HP` | `13,000 – 26,000 EXP` |
| **8. Cấp 7 / Đấu Tông** | `Lv.70 – 79` | `190,000 – 380,000` | `4,500 – 7,400` | `2,100 – 3,500` | `110% HP` | `35,000 – 72,000 EXP` |
| **9. Cấp 8 / Đấu Tôn & Cửu Chuyển** | `Lv.80 – 94` | `520,000 – 1,450,000` | `9,200 – 21,000` | `4,200 – 9,500` | `130% HP` | `95,000 – 280,000 EXP` |
| **10. Chuẩn Cấp 9 / Bán Thánh** | `Lv.95 – 99` | `1,900,000 – 2,900,000` | `26,000 – 36,000` | `12,000 – 16,500` | `150% HP` | `380,000 – 600,000 EXP` |
| **11. Cấp 9 / Đấu Thánh (1–9 Tinh)** | `Lv.100 – 119` | `4,200,000 – 18,000,000` | `48,000 – 145,000` | `22,000 – 68,000` | `180% HP` *(Thánh Uy)* | `900,000 – 3,500,000 EXP` |
| **12. Đế Thú / Bán Đế Tinh Nhuệ** | `Lv.120` | `28,000,000+` | `190,000+` | `90,000+` | `200% HP` | *Điểm Đạo Hạnh Đế Cảnh* |

### 5.2. Cơ Chế "Áp Chế Đại Cảnh Giới" & Khoái Cảm Vượt Cấp Chiến Đấu
Trên Đấu Khí Đại Lục, chênh lệch 1 Đại Cảnh Giới là một trời một vực (như Đấu Hoàng đứng trước Đấu Tông hay Bán Thánh đứng trước Đấu Thánh):
* **Quy tắc Áp Chế Mặc Định**: Khi kẻ địch cao hơn người chơi **`1 Đại Cảnh Giới`**, người chơi gây giảm `-35% sát thương` và nhận thêm `+40% sát thương` (cao hơn `2 Đại Cảnh Giới` giảm `-75%` — gần như gãi ngứa!).
* **Đặc quyền "Việt Cấp Nhi Chiến" của Nhân vật chính Tiêu Viêm**:
  * Mỗi loại **Dị Hỏa thật sự** đang trang bị trong *Phần Quyết* giúp **triệt tiêu `15%` hiệu ứng Áp Chế Cảnh Giới**!
  * Kích hoạt **Thiên Hỏa Tam Huyền Biến** cộng trực tiếp **`+2 / +4 / +6 Tinh Cảnh Giới Thực Chiến`**, biến một Tiêu Viêm Cửu Tinh Đấu Hoàng đủ sức chém ngang ngửa Tứ Tinh Đấu Tông đúng y hệt nguyên tác!
  * Hạ gục thành công một Tinh Anh / Boss cao hơn bản thân từ `5 Level` trở lên thưởng nóng **`+50% EXP Vượt Cấp` và nhân đôi tỷ lệ rớt Ma Hạch**!

---

## 6. Sự Kiện Thế Giới Động Trên Bản Đồ Hoang Dã (`Dynamic World Events`)

Để thế giới 2D thực sự "sống" chứ không chỉ là các bãi quái đứng im chờ bị chém, hệ thống sinh ngẫu nhiên **3 Sự Kiện Động** khi người chơi đi săn dược liệu hoặc di chuyển giữa các vùng:

1. **Kỳ Ngộ "Lưỡng Hổ Tương Tranh — Ngư Ông Đắc Lợi"**:
   * *Tái hiện kinh điển*: Giống hệt cảnh Tiêu Viêm nấp sau tảng đá rình Vân Vận đại chiến Tử Tinh Dực Sư Vương ở Chương 2!
   * Thỉnh thoảng trên bản đồ xuất hiện biểu tượng hai thanh kiếm chéo nhau: Một **Thú Vương Cấp Cao** và một **Cường Giả NPC / Thú Vương Khác** đang lao vào đánh nhau chí tử.
   * Người chơi có thể mặc **Hắc Bào** nấp trong bụi cỏ (`Stealth Zone`) kiên nhẫn đợi cả hai đánh nhau tụt xuống dưới `20% HP` rồi bất ngờ vọt ra ném *Phật Nộ Hỏa Liên* hớt trọn cả 2 phần thưởng vượt cấp ngay từ sớm!
2. **Sự Kiện Đêm Khuya: "Hồn Điện Vây Bắt Luyện Đan Sư" (`Soul Hall Night Ambush`)**:
   * Vào ban đêm ở bản đồ Hắc Giác Vực và Trung Châu, màn sương đen bất ngờ bao phủ một góc rừng: `1 Hộ Pháp + 4 Hồn Sứ Hồn Điện` đang quăng xích trói một NPC Luyện Đan Sư già.
   * Nếu người chơi giải cứu kịp trước khi thanh Linh Hồn của NPC cạn sạch: NPC cảm kích tặng ngay **1 Đan Phương Hiếm hoặc 3 cây Dược Liệu Cao Cấp**, đồng thời thu được **Hung Hồn Hộ Pháp** mang về đúc Yêu Khôi!
3. **Thú Triều Bùng Nổ (`Regional Beast Tide`)**:
   * Chu kỳ mỗi `45 phút` chơi tại biên ải *Thanh Sơn Trấn*, *Pháo Đài Gia Mã* hoặc *Mãng Hoang Cổ Vực*: Tù và báo động vang rền, hàng trăm Ma Thú tràn về cổng trấn trong `3 phút`.
   * Tham gia giữ cổng cùng lính gác mang lại lượng **Ma Hạch & Danh Vọng Thế Lực gấp `×3 lần`** bình thường!

---

## 7. Tương Tác Địa Hình & Bẫy Môi Trường Chiến Đấu 2D (`Environmental Tactics`)

Mỗi vùng bản đồ đều đặt sẵn các vật thể tương tác hai chiều giúp người chơi thông minh dùng mưu thắng sức:

| Vật Thể Môi Trường 2D | Bản Đồ Xuất Hiện | Cách Kích Hoạt Thực Chiến | Hiệu Quả Lên Quái Vật & Boss |
| :--- | :--- | :--- | :--- |
| **Tổ Ong Độc Ma Thú / Đá Lăn** | Ma Thú Sơn Mạch | Bắn *Viêm Đạn* làm rụng tổ ong hoặc đấm vỡ chốt đá trên dốc. | Bầy ong cắn hỗn loạn làm mù quái `4s`; đá lăn đè bẹp hàng quái `250% ATK`. |
| **Hố Cát Lún Xoáy & Xương Rồng Nổ** | Sa Mạc Tháp Qua Nhĩ | Dùng *Hấp Chưởng / Xuy Hỏa Chưởng* đẩy quái sa chân vào tâm hố cát. | Quái không biết bay bị giữ chân cứng `3s` và hút tụt `-25% DEF`. |
| **Mạch Phun Nham Tương Ngầm** | Sông Ngầm / Đáy Tháp Thiên Phần | Mặt đất nứt đỏ sủi bọt `1.0s` rồi phụt cột lửa cao `96 px`. | Đẩy kẻ địch nhân loại/Hồn Điện vào cột lửa gây sát thương chuẩn `12% Max HP`! |
| **Cột Đá Cổ Chứa Phong Lôi Khí** | Lôi Sơn / Viễn Cổ Di Tích | Dẫn dụ quái `AI: Lao Húc` tông sập cột đá cổ. | Cột đổ phóng điện tê liệt diện rộng `144 px`, làm lộ mật thất ẩn bên dưới! |
| **Màn Sương Chướng Khí Mãng Hoang** | Mãng Hoang Cổ Vực | Phủ kín bản đồ rút máu liên tục nếu không có lửa hộ thể. | Tiêu Viêm bật **Dị Hỏa Hộ Thân** tự tạo vòng tròn an toàn `128 px` cho cả Đồng Hành đi cùng! |

---

## 8. Đồ Giám Vạn Thú, Sổ Truy Nã Hồn Điện & Quy Tắc Phối Đội Hình Bãi Quái

### 8.1. Hệ Thống "Đồ Giám Vạn Thú" (`Bestiary Mastery` — Phần Thưởng Cho Dân Cày)
Mỗi chủng loại Ma Thú và kẻ địch Hồn Điện khi bị đánh bại lần đầu sẽ tự động ghi danh vào cuốn **Vạn Thú Đồ Lục** do Dược Lão biên soạn, chia làm 3 mốc thưởng cày cuốc vĩnh viễn:

| Mốc Nghiên Cứu Đồ Giám | Số Lượng Tiêu Diệt | Thông Tin & Phần Thưởng Mở Khóa Vĩnh Viễn |
| :--- | :---: | :--- |
| **Mốc 1: Sơ Thức** | `10 cá thể` | Hiển thị rõ thanh Máu con số cụ thể & **Hệ Thuộc Tính Khắc Chế** ngay trên đầu quái. |
| **Mốc 2: Thấu Triệt** | `50 cá thể` | Mở khóa xem toàn bộ **Bảng Loot Chi Tiết** của loài đó + Tăng **`+10% Sát thương gây lên loài đó`**. |
| **Mốc 3: Chế Bá Chủng Tộc** | `150 cá thể` *(Tinh Anh: 25)* | Tặng điểm chỉ số vĩnh viễn cho Tiêu Viêm (`+5 HP / +1 ATK / +1 SOUL` tùy loài) + Tăng **`+20% tỷ lệ rớt Ma Hạch`** của loài đó! |

### 8.2. Bảng "Truy Sát Lệnh Hồn Điện" (`Soul Hall Bounty Hunter`)
Từ Chương 7 trở đi (sau mối huyết thù Dược Lão bị bắt và Tiêu Chiến mất tích), tại bảng tin của *Viêm Minh / Tinh Vẫn Các* mở tính năng **Săn Lùng Phân Điện Hồn Điện**:
* Mỗi chu kỳ làm mới **5 Mục Tiêu Truy Nã Đặc Biệt** (từ *Hắc Y Hộ Pháp* tới *Bát Thiên Tôn*) đang lẩn trốn ngẫu nhiên tại một khu rừng hoặc thành trì hoang phế trên bản đồ thế giới.
* Người chơi dùng cảm ứng của *Cốt Viêm Giới* lần theo vệt khói đen tìm ra sào huyệt ẩn, phá hủy **Tụ Hồn Phiên** của chúng để thu về số lượng lớn **Linh Hồn Bản Nguyên Thuần Khiết** (tài nguyên cốt lõi nâng cấp `SOUL` từ *Linh Cảnh -> Thiên Cảnh -> Đế Cảnh*) và **Thi Thể Đấu Tôn** chất lượng cao để đúc đủ đội hình *10 Thiên Yêu Khôi*!

### 8.3. Quy Tắc Thiết Kế Tổ Hợp Bãi Quái Trên Bản Đồ (`2D Encounter Composition`)
Để mỗi trận đụng độ nhỏ kéo dài `8 – 15 giây` trên đường đi đều đòi hỏi tư duy chọn mục tiêu thay vì đứng im bấm 1 nút, các bãi quái (`Encounter Pods`) trên bản đồ luôn tuân theo **Công Thức Phối Đội Hình Tam Giác**:

```text
          [Pháo Kích / Mị Xà / Hồn Sứ Hút Hồn]  (Hàng Sau - Cách 192 px)
                     ▲               ▲
                     │ (Dây Liên Kết / Yểm Trợ)
                     │               │
      [Khiên Cứng / Gấu Đá]     [Lao Húc / Độn Thổ]  (Hàng Trước - Áp sát 64 px)
                           \   /
                        (TIÊU VIÊM)
```

* **Cách giải bài toán của người chơi**:
  * Nếu chỉ mải chém con *Gấu Đá Khiên Cứng* phía trước, tên *Hồn Sứ* hàng sau sẽ rảnh tay quăng xích rút sạch `QI` hoặc *Pháo Kích* dội độc kín chân.
  * Người chơi giỏi sẽ bấm `Space (Tam Thiên Lôi Động)` lướt xuyên qua khe hở hai con hàng trước -> Tung `Q (Hấp Chưởng)` gom gọn bọn máu giấy hàng sau lại -> Bổ 1 nhát `E (Diễm Phân Phệ Lãng Xích)` dọn sạch tuyến sau trong 2 giây rồi mới quay lại dùng *Bát Cực Băng* đấm nát khiên con Tinh Anh còn trơ trọi!

### 8.4. Chiết Xuất "Thú Hỏa" Từ Ma Thú Hệ Hỏa (`Beast Flame Extraction`)
Trước khi săn đủ các ngọn Dị Hỏa cấp cao, các loài Ma Thú Hệ Hỏa Tinh Anh / Thú Vương từ Cấp 3 đến Cấp 7 trên bản đồ đóng vai trò cực kỳ quan trọng cho lối chơi **Khống Hỏa & Lộng Viêm Quyết**:
* **Cách chiết xuất**: Khi đánh hạ Ma Thú Hệ Hỏa Tinh Anh (như *Xích Diễm Hổ Cấp 3, Song Đầu Hỏa Linh Xà Cấp 4, Liệt Viêm Ưng Cấp 5, Hỏa Tinh Viên Vương Cấp 6, Hồng Liên Nghiệp Hỏa Hạt Cấp 7*), dùng *Khống Hỏa Thuật* rút lấy **Tinh Phách Thú Hỏa** từ Ma Hạch còn nóng hổi của chúng!
* **Công dụng thực tế**:
  1. Dung hợp `5 loại Thú Hỏa khác nhau` trong **Lộng Viêm Quyết** để ngưng tụ ra **Hóa Sinh Hỏa** mạnh tương đương Dị Hỏa hạng `#20 – #22`!
  2. Thả Linh Phách Ma Thú bắt sống về giữ cổng **Dược Viên Thế Lực** (*Bàn Môn / Tinh Vẫn Các*) giúp chống trộm thuốc và tăng `+15% sản lượng thu hoạch`!

---

## 9. Ma Trận Khắc Chế Nguyên Tố & Sơ Đồ Trạng Thái AI (`2D AI State Machine`)

### 9.1. Bảng Ma Trận Tương Khắc 8 Hệ Thuộc Tính Trên Đấu Khí Đại Lục
Sử dụng đúng loại Ma Hạch khảm trên xích hoặc đổi Dị Hỏa phù hợp sẽ giúp tối ưu sát thương lên từng chủng loài quái:

| Hệ Tấn Công \ Hệ Kẻ Địch | **Hỏa** | **Băng / Thủy** | **Mộc / Độc** | **Lôi** | **Thổ / Đá** | **Phong** | **Hắc Hồn (Hồn Điện)** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Đấu Khí Hỏa Thường** | `75%` | `120%` | `135%` | `100%` | `90%` | `110%` | `115%` |
| **Thiên Địa Dị Hỏa** *(Đặc quyền!)* | **`110%`** *(Áp chế!)* | **`140%`** | **`160%`** *(Tịnh độc!)* | `110%` | `115%` | `120%` | **`175%` *(Khắc tinh chí mạng!)*** |
| **Hệ Băng / Hàn Âm** | `125%` | `70%` | `110%` | `100%` | `100%` | `115%` | `90%` |
| **Hệ Lôi Đình** | `100%` | `135%` | `95%` | `70%` | `85%` | `125%` | **`145%`** *(Chí dương phá tà!)* |
| **Hệ Trọng Lực / Thổ Xích** | `105%` | `125%` *(Đập băng!)* | `100%` | `115%` | `130%` *(Toái thạch!)* | `90%` | `80%` *(Xuyên hư thể kém)* |
| **Linh Hồn Công Kích (`SOUL`)** | `100%` | `100%` | `100%` | `100%` | **`140%`** *(Xuyên giáp đá!)* | `100%` | *Đọ trực tiếp chỉ số `SOUL`* |

### 9.2. Cấu Trúc Máy Trạng Thái Hữu Hạn Cho Quái Top-down 2D (`Finite State Machine`)
Mọi thực thể quái và Tinh Anh vận hành thống nhất trên vòng đời 6 trạng thái để dễ lập trình và mở rộng:

```text
[1. PATROL / IDLE] ──(Player vào tầm Aggro / Quét SOUL)──▶ [2. CHASE / REPOSITION]
        ▲                                                            │
 (Mất dấu > 8s)                                          (Đủ tầm & CD sẵn sàng)
        │                                                            ▼
[6. STAGGER / HIT] ◀──(Vỡ Giáp Poise / Đâm cột đá)─── [3. TELEGRAPH WIND-UP]
        ▲                                               (Hiện vạch đỏ 0.5s - 0.9s)
        │                                                            │
        └───────── [5. RECOVERY VULNERABLE] ◀──── [4. EXECUTE ACTIVE HITBOX]
```

* **Nguyên tắc Công Bằng Tuyệt Đối (`Fairness Rule`)**:
  * Quái **không bao giờ ra đòn `0-frame` không báo trước** khi ở ngoài rìa màn hình (`Off-screen Attack Lock`: Quái ngoài khung hình `640 × 360 px` chỉ được phép di chuyển tiến vào màn hình trước khi bắt đầu pha `TELEGRAPH WIND-UP`).
  * Khi có trên `6 con quái cận chiến` cùng vây quanh Tiêu Viêm, hệ thống **Token Điều Phối Tấn Công (`Attack Token Pool = 3`)** đảm bảo chỉ tối đa 3 con cùng lao vào chém một lúc, số còn lại lượn vòng gầm gừ tạo áp lực điện ảnh mà không gây rối mắt bất công!
