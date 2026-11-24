# HỆ THỐNG TRANG BỊ SINH TRƯỞNG, NẠP GIỚI & CHẾ TẠO YÊU KHÔI

> **Mã tài liệu**: `04_Dau_Ky_Cong_Phap_Va_Trang_Bi\Trang_Bi_Nap_Gioi_Va_Khoi_Loi.md`
> **Phạm vi**: Kiến trúc 6 Ô Trang Bị Không Rác, Huyền Trọng Xích 10 bậc tôi luyện & 4 rãnh Ma Hạch, Phi Hành Đấu Dực, Nội Giáp, Nạp Giới Tiện Ích, Đà Xá Cổ Đế Ngọc và Hệ thống Chế tạo – Tiến hóa Yêu Khôi (Địa Yêu Khôi -> Thiên Yêu Khôi -> Bắc Vương).
> **Đồng bộ**: Kết nối trực tiếp với cơ chế Khổ Tu Trọng Áp (`RMB`), Độ Đan Lôi sạc Khôi Lỗi và 12 Đại Cảnh Giới tại [00_Master_Index_Va_Quy_Chuan.md](../00_Tong_Quan_Kien_Truc/00_Master_Index_Va_Quy_Chuan.md).

---

## 1. Triết Lý Thiết Kế: "6 Ô Trang Bị Không Rác" (Zero-Trash Meaningful Gear)

Một sai lầm phổ biến của game nhập vai cày cuốc là nhồi nhét hàng trăm thanh kiếm sắt, quần vải trắng/xanh vô hồn khiến người chơi mệt mỏi dọn túi đồ và phá hỏng chất riêng của nguyên tác. Trong *Đấu Phá Thương Khung*, Tiêu Viêm không thay vũ khí xoành xoạch — cậu gắn bó sinh tử cùng **Huyền Trọng Xích**, **Hải Tâm Giáp**, **Tử Vân Dực -> Thiên Nhạn Cửu Hành Dực** và **Cốt Viêm Giới**.

Vì vậy, hệ thống trang bị của game được thiết kế theo mô hình **6 Ô Trang Bị Sinh Trưởng Có Chiều Sâu**: Nguyên liệu đánh quái/khai khoáng dùng để **Tôi Luyện Thăng Bậc**, **Khảm Ma Hạch Đổi Chiêu** và **Đúc Yêu Khôi** chứ không vứt rác!

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                    BẢNG TRANG BỊ NHÂN VẬT: TIÊU VIÊM                    │
├──────────────────────┬───────────────────────────┬──────────────────────┤
│ [Ô 1: TRỌNG BINH]    │     (Sprite Nhân Vật)     │ [Ô 4: NẠP GIỚI]      │
│  Huyền Trọng Xích    │       20x24 px Pixel      │  Cốt Viêm Giới       │
│  (10 Bậc + 4 Ma Hạch)│     + Giáp Đấu Khí Ẩn     │  (Túi + Nam Châm)    │
├──────────────────────┼───────────────────────────┼──────────────────────┤
│ [Ô 2: ĐẤU DỰC]       │     [Ô 3: NỘI GIÁP]       │ [Ô 5: Y BÀO]         │
│  Thiên Nhạn Cửu Hành │      Hải Tâm Nội Giáp     │  Hắc Bào Ẩn Danh     │
│  (Bay + Tốc Độ SPD)  │      (DEF + Chống Sốc)    │  (Che Khí Tức/Crit)  │
├──────────────────────┴───────────────────────────┴──────────────────────┤
│ [Ô 6: KỲ VẬT BỘI SỨC]: Đà Xá Cổ Đế Ngọc / Thanh Liên Đài / Bồ Đề Tử    │
│ [PHỤ TRỢ PHÍM T]: Khôi Lỗi Hộ Pháp (Địa Yêu Khôi -> Thiên Yêu -> Bắc Vương)│
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Ô 1: Huyền Trọng Xích — Vũ Khí Sinh Trưởng 10 Bậc & 4 Rãnh Ma Hạch

Đúc từ **Diễm Vẫn Huyền Thiết** dưới lòng núi lửa rực cháy, Huyền Trọng Xích không có lưỡi sắc bén mà dùng sức nặng ngàn cân và hỏa kình nghiền nát đối thủ ("Trọng xích vô phong, đại xảo bất công").

### 2.1. Cơ Chế Kép Thương Hiệu: Phong Ấn Trọng Áp vs. Giải Phong Bùng Nổ (`RMB`)
Người chơi có thể chuyển đổi tức thời giữa 2 trạng thái ngay giữa trận đấu (Hồi chiêu chuyển trạng thái `3.0s`):

* **Trạng Thái 1 — Phong Ấn Trọng Áp (Mặc định khi cày cuốc)**:
  * Khóa dòng chảy Đấu Khí theo hiệu ứng áp chế của Diễm Vẫn Thiết: Giảm `-20% SPD` (chạy & vung xích đầm nặng).
  * **Phần thưởng Khổ Tu**: Nhận **`+30% EXP Tu Luyện Đấu Khí`**, **`×1.5 Điểm Thông Thạo Đấu Kỹ`**, tăng **`+25% Sát thương Phá Giáp (`Poise`)`** và kháng đẩy lùi `+40%`!
* **Trạng Thái 2 — Giải Phong Bùng Nổ (Tháo Chốt Áp Chế / Phóng Hỏa Văn)**:
  * Thân thể nhẹ bẫng như cởi bỏ xiềng xích vạn cân: Tốc độ vọt lên **`+25% SPD`**, **`+15% Tỷ lệ Chí mạng (`Crit Rate`)`**.
  * **Hiệu ứng "Thoát Xích Đột Kích"**: Trong **`8.0 giây` đầu tiên** ngay sau khi bấm tháo Phong Ấn trong giao tranh, Tiêu Viêm nhận buff *Bộc Phát Tiềm Năng* tăng **`+35% ATK`** và để lại bóng mờ đỏ rực mỗi bước di chuyển — tái hiện hoàn hảo khoảnh khắc kẻ thù sững sờ khi thấy tốc độ thật của Tiêu Viêm!

### 2.2. Bảng Lộ Trình 10 Bậc Tôi Luyện Huyền Trọng Xích (Dị Hỏa Rèn Xích)
Tại Lò Rèn hoặc dùng trực tiếp Dị Hỏa của bản thân nung chảy khoáng thạch quý để nâng cấp Huyền Trọng Xích:

| Bậc | Tên Hình Thái Trọng Xích | Cấp Mở | Nguyên Liệu Tôi Luyện Chính | Chỉ Số `ATK` Gốc | Số Rãnh Ma Hạch | Đột Phá Hiệu Ứng Vũ Khí |
| :-: | :--- | :---: | :--- | :---: | :---: | :--- |
| **01** | **Huyền Trọng Xích (Nguyên Bản)** | Lv.10 (C.1) | Dược Lão trao tặng khi bái sư | `+45 ATK` | `0` | Mở cơ chế *Phong Ấn Trọng Áp (`+30% EXP`)*. |
| **02** | **Xích Viêm Trọng Xích** | Lv.20 (C.2) | `10 Huyền Thiết Tinh + Tử Hỏa nung` | `+95 ATK` | **`1 Rãnh`** | Đòn đánh thứ 4 của `LMB` tạo vòng chấn địa nhỏ `64 px`. |
| **03** | **Thanh Liên Dung Hỏa Xích** | Lv.32 (C.3) | `Địa Tâm Hỏa Chi Tinh + Thanh Liên Hỏa` | `+175 ATK` | `1 Rãnh` | Thân xích nổi vân xanh ngọc; đòn chém thường có `20%` gây Bỏng. |
| **04** | **Phá Vân Trọng Xích** | Lv.42 (C.4) | `Vân Lam Tinh Kim + Ma Hạch Cấp 5` | `+280 ATK` | **`2 Rãnh`** | Tăng `+20%` sát thương lên Khiên Đấu Khí của cường giả nhân loại. |
| **05** | **Vẫn Lạc Vô Hình Xích** | Lv.55 (C.6) | `Đá Đáy Tháp Thiên Phần + Vẫn Lạc Hỏa` | `+440 ATK` | `2 Rãnh` | Vung xích kèm sóng nhiệt vô hình kéo dài tầm đánh thêm `+12 px`. |
| **06** | **Hàn Diễm Lưỡng Cực Xích** | Lv.68 (C.7) | `Hàn Tủy Tinh Thiết + Cốt Linh Lãnh Hỏa` | `+680 ATK` | **`3 Rãnh`** | Chém xen kẽ Hàn – Nhiệt làm mục tiêu bị *Giòn Giáp (`-15% DEF`)*. |
| **07** | **Tinh Không Lôi Văn Xích** | Lv.80 (C.8) | `Hư Không Lôi Đồng + Tam Thiên Diễm Hỏa` | `+1,050 ATK` | `3 Rãnh` | Hút năng lượng Tinh Không hồi `2% HP` mỗi khi kết liễu Tinh Anh. |
| **08** | **Hoàng Tuyền Minh Thiết Xích** | Lv.92 (C.9) | `Thánh Cốt Tinh Kim + Cốt Viêm Cửu U` | `+1,620 ATK` | **`4 Rãnh`** | Nặng gấp mười lần xưa: Đập nát hiệu ứng *Phong Tỏa Không Gian*! |
| **09** | **Tịnh Liên Yêu Thánh Xích** | Lv.105 (C.10) | `Thái Hư Thần Thiết + Tịnh Liên Yêu Hỏa` | `+2,600 ATK` | `4 Rãnh` | Mỗi nhát vung phóng kèm cánh sen hồng tịnh hóa Hắc Vụ Hồn Tộc. |
| **10** | **Hằng Cổ Viêm Đế Cự Xích** | Lv.120 (C.11) | `Bản Nguyên Đế Thạch + 23 Dị Hỏa Hợp Nhất` | **`+4,500 ATK`** | **`4 Rãnh (×1.5)`** | Mở khóa tuyệt học tối thượng **Dị Hỏa Hằng Cổ Xích**; nhân `×1.5` hiệu lực mọi Ma Hạch khảm trên xích! |

### 2.3. Hệ Thống 4 Rãnh Khảm "Ma Hạch Thuộc Tính" (Custom Weapon Modding)
Trên rãnh rỗng giữa thân Huyền Trọng Xích có thể khảm tối đa **4 viên Ma Hạch (Cấp 1 -> Cấp 9)** khác hệ để biến hóa đòn đánh thường `LMB`:

| Hệ Ma Hạch Khảm | Màu Viền Xích | Hiệu Ứng Cộng Thêm Vào Đòn Đánh Thường (`LMB`) Theo Cấp Ma Hạch (Cấp 1 -> Cấp 9) |
| :--- | :---: | :--- |
| **Ma Hạch Hỏa** | Đỏ Rực | Cộng `+10% -> +45% Hỏa Thương`; đòn thứ 4 nổ cầu lửa bán kính `72 px`. |
| **Ma Hạch Băng** | Lam Tuyết | Đòn chém làm **Chậm `15% -> 40%`**; tích đủ 5 nhát đóng băng quái thường `1.2s`. |
| **Ma Hạch Lôi** | Tím Điện | Phóng **Tia Chớp Chuỗi (`Chain Lightning`)** giật lan sang `2 -> 6 kẻ địch` đứng gần (`30% -> 85% ATK`). |
| **Ma Hạch Phong** | Xanh Lục | Tăng **`+8% -> +28% Tốc độ vung xích`** và giảm một nửa độ trễ thu đòn (`Recovery`). |
| **Ma Hạch Thổ** | Vàng Nâu | Tăng **`+20% -> +70% Sát thương Phá Giáp (`Poise`)** và tạo Khiên Đá chắn `5% -> 15% Max HP` khi đập đất. |
| **Ma Hạch Mộc** | Lục Ngọc | Hút sinh lực thảo mộc: Hồi **`1% -> 4% sát thương gây ra thành HP`** cho Tiêu Viêm. |
| **Ma Hạch Độc** | Tím Đen | Gây *Án Độc Ăn Mòn* rút máu theo thời gian và giảm `-30%` khả năng hồi phục của kẻ địch. |
| **Ma Hạch Không Gian** *(Cấp 7+)* | Bạc Hư Không | Bẻ cong không gian kéo dài lưỡi xích thêm **`+24 px` (`0.75 Tile`)** và tăng `+15% Xuyên DEF`! |

---

## 3. Ô 2: Phi Hành Đấu Dực — Lộ Trình Tiến Hóa Từ Tử Vân Dực Tới Cánh Yêu Hoàng

Từ cảnh giới **Đấu Vương (`Lv.50`)**, nhân vật tự ngưng tụ được *Đấu Khí Hóa Dực*. Tuy nhiên, trang bị **Phi Hành Đấu Dực (Cốt Dực)** ở Ô 2 sẽ **cộng hưởng chồng lên Đấu Khí Hóa Dực**, giúp Tiêu Viêm bay nhanh hơn hẳn cường giả cao hơn mình 1 đại cảnh giới (chuẩn nguyên tác!).

| Bậc Cánh | Tên Phi Hành Đấu Dực | Chương Mở & Nguyên Liệu Chế Tạo / Tiến Hóa | Cộng `SPD` | Thời Gian Bay Giữ `Space` | Hiệu Ứng Đặc Biệt Khi Bay & Lướt Né |
| :-: | :--- | :--- | :---: | :---: | :--- |
| **1** | **Tử Vân Dực** | Chương 2: Mở rương đá mật thất vách núi Thanh Sơn Trấn (Cánh Hắc Vân Điêu). | `+15% SPD` | `6.0 giây` | Cho phép bay qua vực thẳm, sông dung nham ngay từ cảnh giới Đấu Sư! |
| **2** | **Hắc Diễm Tử Vân Dực** | Chương 3–4: Luyện hóa thêm tinh huyết Điêu Cấp 5 + Thanh Liên Hỏa. | `+22% SPD` | `8.5 giây` | Lướt né vẩy `6 lông vũ lửa đen` phản kích kẻ bám đuôi. |
| **3** | **Thanh Hồng Lưu Quang Dực** | Chương 6: Kết hợp Đấu Khí Hóa Dực Đấu Vương + Phong Hạch Cấp 6. | `+30% SPD` | `12.0 giây` | Giảm `-30% QI` tiêu hao khi duy trì bay trên không trung. |
| **4** | **Thiên Nhạn Cửu Hành Dực (Sơ Chế)** | Chương 7–8: Mua **Cánh Khô Thiên Yêu Hoàng** tại Đấu Giá Hắc Hoàng Thành + Ngọc Cốt + Hỏa Tinh luyện suốt 1 tháng! | `+45% SPD` | `18.0 giây` | Tốc độ bứt phá kinh hoàng! Kéo dài khoảng cách *Tam Thiên Lôi Động* thêm `+32 px`, miễn nhiễm hiệu ứng *Làm Chậm*. |
| **5** | **Thiên Nhạn Cửu Hành Dực (Thức Tỉnh Yêu Thánh)** | Chương 9–10: Tẩy rửa tàn hồn oán niệm Thiên Yêu Hoàng bằng Tịnh Liên Hỏa + Tinh Huyết Cửu Phẩm. | **`+65% SPD`** | `30.0 giây` | Đôi cánh ngọc bích mười màu sải rộng `88 px`: Mỗi nhịp vỗ cánh tạo **Phong Nhận Không Gian** chém nát đạn đuổi theo, tăng `+0.12s I-frame`! |
| **6** | **Đế Diễm Thần Hoàng Dực** | Chương 11: Hóa sinh từ bản nguyên 23 Dị Hỏa khi chứng đạo Viêm Đế. | **`+90% SPD`** | **Vô Hạn (`∞`)** | Tự do phi hành vĩnh viễn trên không trung không tốn `QI`, để lại vệt cầu vồng lửa thiêu rụi quái chạm vào! |

---

## 4. Ô 3 & Ô 5: Nội Giáp Hộ Thân, Y Bào Ẩn Danh & Pháp Thân Đấu Khí

### 4.1. Bảng Lộ Trình Nội Giáp Phòng Hộ (Ô 3)
Nội giáp mặc sát da bên trong áo, chuyên hóa giải các đòn đánh lén chí mạng khi lớp Giáp Đấu Khí bên ngoài bị vỡ:

| Tên Nội Giáp | Chương | Nguồn Gốc Thu Thập | Chỉ Số `DEF` & `HP` | Cơ Chế Bảo Mệnh Độc Quyền |
| :--- | :---: | :--- | :--- | :--- |
| **Nội Giáp Da Thiết Mộc Lang** | Chương 1–2 | Chế từ da Sói Cấp 2 tại Thanh Sơn Trấn | `+25 DEF, +100 HP` | Giảm `15%` sát thương cắn xé vật lý của Ma Thú rừng. |
| **Huyền Thiết Lân Giáp** | Chương 3 | Kho báu lính đánh thuê Sa Mạc | `+65 DEF, +280 HP` | Tăng `+25%` kháng hiệu ứng *Xuất Huyết* và *Độc Xà*. |
| **Hải Tâm Nội Giáp** *(Chí bảo đầu – giữa game!)* | Chương 4–6 | Gia Hình Thiên / Hải Ba Đông tặng hoặc mảnh vỡ Thất Phẩm | `+180 DEF, +800 HP` | **Khiên Thủy Tinh Bảo Mệnh**: Khi nhận 1 đòn đơn lẻ lấy đi `>35% Max HP`, Nội Giáp tự lóe sáng xanh gánh thay **`70% sát thương đòn đó`** (CD `45s`)! |
| **Trọng Lân Hỏa Giáp** | Chương 7–8 | Rèn từ vảy Hỏa Mãng Cấp 7 tại Phần Viêm Cốc | `+420 DEF, +2,200 HP` | Hấp thu `25%` sát thương Hỏa nhận vào chuyển thành `QI` cho bản thân. |
| **Thái Hư Long Hoàng Khải Giáp** *(Chí bảo cuối game!)* | Chương 10 | **Long Hoàng Tử Nghiên** rút vảy rồng Thái Hư Cổ Long kết thành tặng Tiêu Viêm! | **`+1,200 DEF, +8,500 HP`** | **Long Uy Vạn Cổ**: Giảm thẳng `30% mọi sát thương nhận vào`, **phản chấn `40%` sát thương cận chiến** kèm hiệu ứng Choáng nhẹ cho kẻ dám chém Tiêu Viêm! |

### 4.2. Bảng Y Bào Danh Hiệu (Ô 5) & Giáp Ẩn Cảnh Giới
* **Hắc Bào Bí Ẩn (Áo Choàng Đen Trùm Đầu — Chương 1)**: Trang bị nhập vai biểu tượng! Khi bật mũ trùm Hắc Bào:
  1. Che giấu hoàn toàn tên tuổi & cảnh giới tại Phòng Đấu Giá / Hắc Giác Vực (tránh bị gia tộc thù địch nhận mặt).
  2. Giảm **`-35% bán kính phát hiện (`Aggro Range`)`** của quái trên bản đồ hoang dã, đòn đánh đầu tiên phá ẩn thân đạt **`100% Chí mạng`**!
* **Luyện Đan Sư Tinh Bào (Cấp 1 -> Cấp 9)**: Tăng `+10% -> +35% SOUL` khi luyện đan và tăng thiện cảm khi nói chuyện với NPC các thành trì.
* **Lớp Giáp Ẩn Tự Động Theo Cảnh Giới**: *Đấu Khí Sa Y* (Đấu Sư: `-8% Damage`) -> *Đấu Khí Khải Giáp* (Đại Đấu Sư: `-15% Damage`) -> *Kim Cương Lưu Ly Thân* (Chương 9–10, cửu trượng kim thân thu liễm vào da thịt: Biến cơ thể Tiêu Viêm cứng ngang Thánh Khí, miễn nhiễm đẩy lùi hoàn toàn!).

---

## 5. Ô 4 & Ô 6: Nạp Giới Tiện Ích Cày Cuốc & Thiên Địa Kỳ Vật

### 5.1. Lộ Trình Nâng Cấp Nạp Giới (Ô 4 — Giải Phóng Thao Tác Nhặt Đồ)
| Tên Nạp Giới | Chương | Sức Chứa | Tầm Nam Châm Tự Hút Đồ (`Auto-Loot`) | Tiện Ích Tự Động Hóa Cày Cuốc (`QoL Features`) |
| :--- | :---: | :---: | :---: | :--- |
| **Cổ Hắc Giới (Cốt Viêm Giới)** | Chương 1 | `60 Ô` | `48 px` (`1.5 Tiles`) | Nhẫn đen của Dược Lão: `+15% SOUL`, giữ dược liệu không bao giờ héo. |
| **Huyết Ngọc Nạp Giới** | Chương 3 | `120 Ô` | `96 px` (`3.0 Tiles`) | Tự động gom cộng dồn (`Stack 999`) mọi loại Dược Liệu và Ma Hạch cùng cấp. |
| **Hải Lam Cao Cấp Nạp Giới** | Chương 6 | `240 Ô` | `160 px` (`5.0 Tiles`) | Mở **Bộ Lọc Tự Phân Giải**: Tự nghiền vũ khí sắt vụn của cướp rơi ra thành *Tinh Thiết Bột* ngay khi hút vào! |
| **Trùng Không Gian Giới** | Chương 9 | `480 Ô` | `256 px` (`8.0 Tiles`) | Cho phép cất giữ **Đội hình 10 Thiên Yêu Khôi** và mở Lò Đan mọi lúc mọi nơi. |
| **Đế Giới Tự Thành Không Gian** | Chương 11 | **Vô Hạn** | **Toàn Màn Hình** | Hút sạch toàn bộ chiến lợi phẩm bản đồ trong `0.2s` không sót một hạt bụi! |

### 5.2. Bội Sức & Kỳ Vật Đặc Biệt (Ô 6)
* **Đà Xá Cổ Đế Ngọc (Thu thập 8 Mảnh Cổ Ngọc)**: Bắt đầu với `1/8 Mảnh Tiêu Gia`, thu thập dần qua Huân Nhi, Cổ Mộ, Hồn Điện... Mỗi mảnh ghép vào cộng **`+4% Toàn Chỉ Số (Tối đa +32%)`** và hiển thị kim chỉ nam dẫn đường tới Bí Cảnh Dị Hỏa gần nhất!
* **Thanh Liên Đài (Đài Sen Đá Xanh đáy dung nham Chương 3)**: Khi bấm phím Ngồi Thiền hồi sức ngoài giao tranh, Tiêu Viêm ngồi xếp bằng trên Đài Sen xanh ngọc: **Tốc độ hồi `HP & QI` tăng gấp `×5 lần`**, cộng thêm `+20% EXP bế quan` và dựng vòm sáng ngăn quái đánh lén phát đầu tiên!
* **Bồ Đề Tử (Hạt Bồ Đề Cổ Thụ Chương 10)**: Kháng `50%` sát thương Linh Hồn/Độc, nhân đôi xác suất rơi vào trạng thái **Đốn Ngộ** khi cày Độ Thông Thạo Đấu Kỹ lên bậc *Hóa Cảnh*!

---

## 6. Hệ Thống Chuyên Sâu: Chế Tạo & Nuôi Dưỡng YÊU KHÔI (Puppet System — Phím `T`)

Từ Chương 7 (sau khi thu được quyển trục **Khôi Lỗi Chi Kỹ — Thiên Yêu Khôi** và thi thể *Địa Ma Lão Quỷ* Đấu Tông đỉnh phong), phím `T` mở khóa hệ thống **Đúc & Điều Khiển Yêu Khôi** — một trụ cột cày cuốc cực kỳ gây nghiện bám sát 100% nguyên tác!

### 6.1. Công Thức Đúc Yêu Khôi Chuẩn Nguyên Tác (4 Nguyên Liệu Bắt Buộc)
Tại giao diện **Luyện Khôi Huyết Trì**, người chơi đặt đủ 4 thành phần rồi dùng Dị Hỏa nung chảy máu thịt và kim loại hòa làm một:

$$\text{YÊU KHÔI} = \underbrace{\text{Thi Thể Cường Giả}}_{\text{Quyết định khung xương gốc}} + \underbrace{\text{Hung Hồn Bị Bắt}}_{\text{Linh hồn Hồn Điện xóa ký ức}} + \underbrace{\text{Ma Hạch Cao Cấp}}_{\text{Trái tim năng lượng}} + \underbrace{\text{Kim Loại & Dị Hỏa}}_{\text{Nung đúc bất hoại}}$$

> **Nguồn kiếm Thi Thể & Hung Hồn**: Khi đánh bại các Boss nhân loại tà phái hoặc Hộ Pháp / Tôn Lão Hồn Điện (như *Địa Ma Lão Quỷ, Hàn Phong, Vụ Hộ Pháp, Cửu Thiên Tôn...*), người chơi có lựa chọn **[Thu Hồi Thi Thể / Phong Ấn Hung Hồn Vào Bình Ngọc]** thay vì thiêu hủy để mang về làm nguyên liệu đúc Khôi Lỗi!

### 6.2. Lộ Trình Tiến Hóa 5 Bậc Yêu Khôi (Từ Bạc -> Vàng Kim -> Thập Khôi Trận -> Bắc Vương)

| Cấp Độ Khôi Lỗi | Màu Sắc Pixel Sprite | Chương Mở & Nguyên Liệu Đúc / Đột Phá | Thực Lực Tương Đương | Kỹ Năng Thực Chiến & Đặc Tính Độc Quyền |
| :--- | :--- | :--- | :--- | :--- |
| **1. Nhân Yêu Khôi** | Đồng Xám (`22×26 px`) | Chương 7 Đầu: Thi thể Đấu Hoàng + Hồn Sứ + Ma Hạch Cấp 6 | Đấu Hoàng Đỉnh – Sơ Đấu Tông | Hộ vệ thử nghiệm: Đỡ đạn phía trước, đấm cận chiến gây khựng nhẹ. |
| **2. Địa Yêu Khôi** | **Bạc Sáng Lạnh** (`24×28 px`) | Chương 7: Thi thể **Địa Ma Lão Quỷ** + Hồn **Thiết Hộ Pháp** + Ma Hạch Cấp 7 + Tam Hỏa nung! | Ngũ Tinh – Cửu Tinh Đấu Tông *(Chém được Nhất Tinh Đấu Tôn!)* | **Mình Đồng Da Sắt**: Không biết đau, miễn nhiễm `100%` Độc, Ảo giác, Sợ hãi và Sát thương Linh Hồn! Tự động lao lên hút Aggro Boss cho Tiêu Viêm. |
| **3. Thiên Yêu Khôi** | **Vàng Kim Rực Rỡ + Lôi Văn** (`26×30 px`) | Chương 8: Cho Địa Yêu Khôi **nuốt trọn Bát Sắc / Cửu Sắc Đan Lôi** tại Đan Hội Trung Châu! | Tam Tinh -> **Cửu Tinh Đấu Tôn Đỉnh Phong** *(Ăn Đan Lôi tăng sao!)* | Ngực khắc **Lôi Văn Kim Quang**: Tốc độ dịch chuyển tức thời ngang *Tam Thiên Lôi Động*, đấm ra **Kim Lôi Quyền** xuyên `40% DEF`! Mỗi kỳ luyện đan Thất/Bát Phẩm cho ăn sét lại mạnh thêm! |
| **4. Thập Đại Thiên Yêu Khôi Đại Trận** | **10 Chiến Binh Vàng – Bạc** bay vòng tròn | Chương 9–10: Đúc đủ **10 Yêu Khôi** từ xác cường giả Vong Hồn Sơn Mạch & Di Tích! | Hợp kích ngang **Nhị – Tam Tinh Đấu Thánh**! | Bình thường gọi 1 con đi theo; khi bấm giữ `Phím T` (`CD 60s`), **cả 10 Thiên Yêu Khôi đồng loạt nhảy ra khỏi Nạp Giới** kết dây xích ánh sáng **Thiên Yêu Tỏa Thánh Trận** khóa cứng Boss 5s rồi đấm mưa thiên thạch vàng kim! |
| **5. Siêu Khôi Lỗi: BẮC VƯƠNG** | **Hắc Kim Long Lân Ám Giáp** (`32×36 px` uy vũ!) | Chương 10–11: Xác **Bắc Long Vương** (đã thôn phệ Nam & Tây Long Vương Thái Hư Cổ Long) + **Hắc Ma Lôi Kiếp Cửu Phẩm**! | **Lục Tinh -> Cửu Tinh Đấu Thánh** *(Nhục thân ngang Bán Đế!)* | Đỉnh cao Khôi Lỗi thuật toàn truyện! Sở hữu **Thái Hư Không Gian Chi Lực + Hắc Lôi Long Thể**: Một quyền đấm nát không gian (`3,200% ATK`), gánh trực diện đại chiêu của Tứ Ma Thánh Hồn Tộc mà không sứt một mảnh vảy! |

### 6.3. Cơ Chế Bảo Toàn & Điều Khiển AI Yêu Khôi (`4 Lệnh Chiến Thuật`)
* **Không bao giờ mất vĩnh viễn**: Nếu Yêu Khôi chịu sát thương quá tải cạn `100% Độ Bền`, nó tự động hóa thành tượng kim loại thu về Nạp Giới; người chơi chỉ tốn vài viên *Tinh Thiết + Ma Hạch phụ* để sửa đầy độ bền sau `30s`.
* **Đổi lệnh nhanh bằng `Alt + T`**:
  1. **Hộ Chủ (`Guard`)**: Luôn đứng chặn trên đường thẳng nối giữa Boss và Tiêu Viêm, tự động giơ tay gạt đạn.
  2. **Truy Sát (`Aggro`)**: Lao thẳng vào cắn xé mục tiêu Tiêu Viêm vừa chỉ định, ép Boss quay lưng về phía người chơi.
  3. **Thu Lôi (`Lightning Rod`)**: Tự động kích hoạt khi Độ Đan Lôi — nhảy lên đấm và nuốt sạch sấm sét bảo vệ Dược Đỉnh!
  4. **Chuyển Hóa Năng Lượng (`Core Overdrive`)**: Tạm đốt Ma Hạch trong ngực Yêu Khôi tăng gấp đôi tốc độ đấm trong `10s`.

---

## 7. Hồ Sơ Chi Tiết 8 Mảnh "Đà Xá Cổ Đế Ngọc" & Pháp Bảo Phụ Trợ Nguyên Tác

### 7.1. Bảng Thu Thập & Quyền Năng 8 Mảnh Đà Xá Cổ Đế Ngọc
Chìa khóa mở ra **Cổ Đế Động Phủ** của vị Đấu Đế cuối cùng trên đại lục được chia làm 8 mảnh nắm giữ bởi Bát Tộc Viễn Cổ. Mỗi mảnh Tiêu Viêm thu thập hoặc mượn được sẽ khảm vào **Bàn Cổ Ngọc (Ô 6)**, mở khóa sức mạnh tiệm cận Đế Cảnh:

| Mảnh Số | Tên Mảnh Cổ Ngọc | Chương Thu Thập & Bối Cảnh Cốt Truyện | Chỉ Số Cộng Thêm Vĩnh Viễn | Hiệu Ứng Quyền Năng Cổ Đế Mở Khóa |
| :-: | :--- | :--- | :--- | :--- |
| **1/8** | **Tiêu Tộc Cổ Ngọc** | Chương 1 -> Chương 9 *(Bị Hồn Điện đoạt ở C.7, đoạt lại khi cứu cha Tiêu Chiến)* | `+4% Toàn Chỉ Số, +50 QI` | Cảm ứng tầm gần (`128 px`) phát hiện mật thất ẩn và tàn đồ Dị Hỏa. |
| **2/8** | **Cổ Tộc Cổ Ngọc** | Chương 10 *(Cổ Nguyên & Huân Nhi giao phó sau lễ trưởng thành Cổ Giới)* | `+4% Toàn Chỉ Số, +15% Crit Damage` | Cộng hưởng *Đế Ấn Quyết*: Tăng `+20%` sát thương toàn bộ 5 thức Đế Ấn! |
| **3/8** | **Viêm Tộc Cổ Ngọc** | Chương 10 *(Viêm Tẫn tộc trưởng Viêm Tộc liên minh Thiên Phủ trao mượn)* | `+4% Toàn Chỉ Số, +20% Hỏa Thương` | Mọi Dị Hỏa trang bị được tăng thêm `+1 Bậc Uy Áp` đối với vạn hỏa kẻ thù. |
| **4/8** | **Lôi Tộc Cổ Ngọc** | Chương 10 *(Lôi Doanh tộc trưởng Lôi Tộc đồng minh chống Hồn Tộc)* | `+4% Toàn Chỉ Số, +15% SPD` | Cường hóa *Tam Thiên Lôi Động* & *Bắc Vương*: Tăng `+25%` sát thương Lôi hệ. |
| **5/8** | **Dược Tộc Cổ Ngọc** | Chương 10–11 *(Cứu tàn dân Dược Tộc thoát khỏi Vạn Giới Hồn Tộc thôn phệ)* | `+4% Toàn Chỉ Số, +500 SOUL` | Tăng `+15%` hiệu lực hồi phục của toàn bộ Đan Dược uống trong chiến đấu. |
| **6/8** | **Thạch Tộc Di Ngọc** | Chương 11 *(Đoạt lại từ tay Hồn Hư Tử / Tứ Ma Thánh trong đại chiến Trung Châu)* | `+4% Toàn Chỉ Số, +20% DEF` | Củng cố *Kim Cương Lưu Ly Thân*: Miễn nhiễm sát thương chí mạng vượt ngưỡng `50% HP`. |
| **7/8** | **Linh Tộc Di Ngọc** | Chương 11 *(Giải phóng tàn hồn Linh Tộc trong đại trận Hồn Giới)* | `+4% Toàn Chỉ Số, +15% Hồi QI/s` | Đòn đánh thường `LMB` tự động hồi gấp đôi lượng `QI` trên mỗi nhịp vung xích. |
| **8/8** | **Hồn Tộc Cổ Ngọc (Hợp Nhất)** | Chương 11 *(Đoạt mảnh cuối tại Hồn Giới — Khai mở **Đà Xá Cổ Đế Động Phủ**!)* | **Đủ Bộ: `+35% Toàn Chỉ Số`** | Hóa thành **Đà Xá Cổ Đế Ngọc Hoàn Chỉnh**: Miễn nhiễm áp chế Đấu Đế, mở cổng truyền thừa **Viêm Đế Lv.120**! |

### 7.2. Bốn Pháp Bảo Tiện Ích Phụ Trợ Độc Đáo Trong Túi Đồ
Ngoài 6 ô trang bị chính, người chơi có thể chế tạo và mang theo **4 Pháp Bảo Đặc Dụng** đặt trong thanh phím tắt phụ:
1. **Hỏa Liên Ngọc Bình (Bình Ngọc Phong Hỏa)**: Cho phép Tiêu Viêm lúc rảnh rỗi ngoài thành tự nén sẵn tối đa **`2 quả Phật Nộ Hỏa Liên Thu Nhỏ`** cất vào bình ngọc. Khi gặp Boss nguy cấp, bóp vỡ bình ngọc tung Hỏa Liên nổ ngay lập tức **không tốn thời gian tụ chiêu và không tốn `QI` hiện tại**!
2. **Không Gian Ngọc Giản (Truyền Tống Phù Trung Châu)**: Bóp nát ngọc giản mở khe nứt không gian dịch chuyển tức thời về Tổng Đàn (*Nội Viện Già Nam / Tinh Vẫn Các*) hoặc gọi cứu viện từ Đồng Hành Hồng Nhan.
3. **Nạp Linh Thủy Tinh (Của Dược Lão)**: Viên đá trong suốt đeo cổ giúp tự động tích trữ `QI` dư thừa khi đứng yên thành một **Bình Dự Trữ `500 QI`**, tự bơm thẳng vào kinh mạch khi thanh `QI` chính tụt xuống dưới `15%`.
4. **Thiên Tinh La Bàn (La Bàn Dò Tàn Đồ)**: Kết hợp cùng cảm nhận `SOUL`, rung lên và phát tiếng chuông ngân mỗi khi trong bản đồ hiện tại có **Mảnh Tàn Đồ Tịnh Liên Yêu Hỏa** hoặc **Hang Kho Báu Ẩn** chưa khám phá!

---

## 8. Kinh Tế Đa Tiền Tệ Chống Lạm Phát & Dung Luyện Ma Hạch

Một vấn đề kinh điển của game cày cuốc dài 120 cấp là Vàng ở cấp 100 bị lạm phát thành hàng tỷ đơn vị vô nghĩa. Bám sát bối cảnh từng vùng đất trong *Đấu Phá Thương Khung*, nền kinh tế được phân tách thành **4 Đồng Tiền Khu Vực Chuyên Biệt**:

| Loại Tiền Tệ | Khu Vực Lưu Hành | Cách Kiếm Chủ Đạo | Mục Đích Chi Tiêu Cốt Lõi |
| :--- | :--- | :--- | :--- |
| **1. Kim Tệ (Vàng Đế Quốc)** | Quyển 1: Gia Mã Đế Quốc & Hắc Giác Vực | Bán đan dược Phẩm 1–5, diệt cướp, nhiệm vụ lính đánh thuê Thanh Sơn. | Mua dược liệu sơ/trung cấp, đấu giá tại Mễ Đặc Nhĩ, mở rộng Dược Viên đầu tiên. |
| **2. Hỏa Năng (`Fire Energy` — Thẻ Tinh Thể)** | Quyển 2: Nội Viện Già Nam Học Viện | Thắng **Đấu Trường Cường Bảng**, bán * Thanh Chi Hỏa Liên Đan* của Bàn Môn! | **Nhiên liệu tu luyện tốc độ x3 trong Thiên Phần Luyện Khí Tháp** & đổi Đấu Kỹ Địa Giai tại Tàng Thư Các! |
| **3. Trung Châu Huyền Tinh Tệ** | Quyển 3: Tứ Phương Các & Đan Tháp Trung Châu | Ký gửi đan Thất – Bát Phẩm, vé đi Trùng Động Không Gian, diệt phân điện Hồn Điện. | Đấu giá nguyên liệu đúc **Thiên Yêu Khôi**, mua Danh Đỉnh, Đan Phương Bát Phẩm. |
| **4. Năng Lượng Hạch (`Energy Core`)** | Quyển 4: Thiên Mộ, Cổ Giới & Liên Minh | Săn **Năng Lượng Thể** trong 3 tầng Thiên Mộ và Boss Khe Nứt Đại Thiên Thế Giới! | Tẩy luyện dòng cực phẩm cho *Long Hoàng Khải Giáp*, đổi Thánh Dược Cửu Phẩm & đột phá Đấu Thánh! |

### Cơ Chế "Dị Hỏa Dung Luyện Ma Hạch" (Không Bao Giờ Thừa Đồ Cấp Thấp!)
Mọi viên Ma Hạch Cấp 1–5 rớt ra từ quái cũ đều có giá trị lâu dài:
* Tại giao diện **Dung Hỏa Lô**, người chơi ném **`3 Viên Ma Hạch Cùng Cấp + Cùng Thuộc Tính`** vào ngọn Dị Hỏa đang giữ để nung chảy hợp nhất thành **`1 Viên Ma Hạch Cao Hơn 1 Cấp`** (`100% thành công` nếu cấp Dị Hỏa đủ cao!).
* Tương tự, các mảnh khoáng thạch cấp thấp có thể tinh luyện thành **Tinh Thiết Bột** để sửa chữa độ bền cho Đội hình 10 Thiên Yêu Khôi sau các trận đại chiến.

---

## 9. Quy Chuẩn Ghép Lớp Pixel Art Ngoại Hình (`Modular Paper-Doll Sprite`)

Để người tự phát triển vẽ ít tốn thời gian nhất nhưng nhân vật vẫn thể hiện rõ từng món trang bị mới mặc lên người trên khung Sprite chuẩn **`32 × 32 px`** (khung mở rộng `48 × 48 px` khi bung cánh và vung Trọng Xích):

```text
[Layer 5 - Trên Cùng] : Hiệu ứng Hào Quang Dị Hỏa / Hỏa Văn Trán (Additive Blend)
[Layer 4 - Vũ Khí]    : Huyền Trọng Xích (Đổi màu vân theo 10 bậc + Viền sáng Ma Hạch)
[Layer 3 - Giáp Ẩn]   : Vỏ lụa bán trong suốt Đấu Khí Sa Y / Khải Giáp / Lưu Ly Kim Thân
[Layer 2 - Thân Chính]: Sprite Tiêu Viêm (Áo Tiêu Gia -> Hắc Bào -> Bào Luyện Đan -> Viêm Đế Bào)
[Layer 1 - Dưới Cùng] : Phi Hành Đấu Dực (Tử Vân Dực tím đen -> Thiên Nhạn 10 màu -> Đế Diễm Dực)
```

* **Tối ưu Khối lượng Vẽ (`Art Scope Optimization`)**:
  * Chỉ cần vẽ **1 bộ Animation gốc cho Thân Chính** (`Đứng thở 4f`, `Chạy 8 hướng × 6f`, `Lướt 2f`, `Vung Xích 4 nhịp × 4f`, `Kết Ấn 4f` = tổng cộng vỏn vẹn `~36 khung hình nhỏ`)!
  * *Huyền Trọng Xích* là một Sprite tách rời gắn theo điểm neo bàn tay (`Hand Pivot Point`), tự động đổi màu vân bằng **Palette Swap** qua 10 bậc rèn!
  * *Địa Yêu Khôi / Thiên Yêu Khôi / Bắc Vương* dùng chung khung xương hoạt ảnh Đấm Quyền (`Punch Rig`) chỉ khác kích thước (`24 px -> 26 px -> 32 px`) và bảng màu Bạc -> Vàng Lôi Văn -> Đen Vảy Rồng!

---

## 10. Hệ Thống "Linh Hồn Lạc Ấn", Khoáng Thạch Bản Đồ & Cộng Hưởng Bộ Danh Tiếng

### 10.1. Khắc "Linh Hồn Lạc Ấn" Bằng Tinh Huyết Ma Thú (`Beast Blood Soul-Imprint`)
Để tạo chiều sâu tùy biến lối chơi (`Custom Build`) ngay trên 6 món trang bị cố định, người chơi có thể dùng **Tinh Huyết Ma Thú Tinh Anh / Boss** kết hợp chỉ số `SOUL` để khắc **1 Lạc Ấn Chủ Đạo** lên mỗi món trang bị (có thể tẩy khắc lại bất cứ lúc nào):

| Tên Linh Hồn Lạc Ấn | Nguyên Liệu Tinh Huyết | Ô Khắc Phù Hợp | Hiệu Ứng Biến Đổi Lối Chơi (`Build-Defining Perk`) |
| :--- | :--- | :---: | :--- |
| **Lạc Ấn Tử Tinh Sư Vương** | Tinh Huyết Tử Tinh Dực Sư Cấp 6 | Trọng Xích / Đấu Dực | Mỗi khi kích hoạt *Giải Phong Trọng Xích*, phóng vòng lửa tím đốt cháy kẻ địch xung quanh `96 px` (`120% ATK/s` trong `4s`). |
| **Lạc Ấn Thôn Thiên Mãng** | Tinh Huyết Thất Thải Thôn Thiên Mãng | Nội Giáp / Bội Sức | Khi `HP < 30%`, triệu hồi bóng rắn bảy màu quấn quanh người hấp thụ `50%` sát thương nhận vào trong `6s` (CD `40s`). |
| **Lạc Ấn Bích Nhãn Tam Hoa** | Tinh Huyết Xà Nhân / Mặc Gia | Nạp Giới / Y Bào | Tự động thu phục Ma Thú cấp thấp yếu máu (`<15% HP`) làm thú trợ chiến tạm thời trong `60s` trên bản đồ hiện tại! |
| **Lạc Ấn Tuyết Ma Thiên Viên** | Tinh Huyết Tuyết Ma Thiên Viên Cấp 7 | Trọng Xích | Tăng **`+45% Sát thương Trọng Áp`** của đòn bổ thứ 4 `LMB` nhưng tăng thêm `-5% SPD` khi đang Phong Ấn xích. |
| **Lạc Ấn Thiên Độc Hạt Vương** | Tinh Huyết Ma Độc Hạt Cấp 7 | Trọng Xích / Y Bào | Mọi sát thương Bỏng từ Dị Hỏa gây thêm hiệu ứng **Độc Hỏa Kép**, nổ lan sang quái bên cạnh khi mục tiêu chết. |
| **Lạc Ấn Cửu U Minh Mãng** | Tinh Huyết Cửu U Địa Minh Mãng Cấp 8 | Nội Giáp | Miễn nhiễm hoàn toàn trạng thái *Đóng Băng / Hàn Độc*; kẻ đánh cận chiến bị nhiễm *Hàn Âm* giảm `-25% tốc độ đánh`. |
| **Lạc Ấn Thiên Yêu Hoàng Tộc** | Tinh Huyết Thiên Yêu Hoàng Cấp 9 | Đấu Dực | Sau mỗi lần dùng *Tam Thiên Lôi Động*, đòn Đấu Kỹ tiếp theo trong `2.5s` được **giảm `-50% QI tiêu hao`** và tăng `+25% Crit Damage`! |
| **Lạc Ấn Thái Hư Cổ Long** | Tinh Huyết Long Hoàng Cấp 9 | Trọng Xích / Nội Giáp | Đòn đánh có `15%` xác suất **Đóng Đinh Không Gian (`Spatial Lock`)** giam cứng kẻ địch (kể cả Boss!) đứng im `1.2s`! |

### 10.2. Danh Mục 10 Khoáng Thạch & Vật Liệu Rèn Phân Bổ Theo Bản Đồ
| Bậc Khoáng | Tên Khoáng Thạch / Vật Liệu | Vùng Bản Đồ Khai Thác / Rớt Đồ | Công Dụng Chế Tác Chính |
| :-: | :--- | :--- | :--- |
| **1** | **Ô Cương Thiết** | Mỏ đá sau núi Ô Thản Thành (Chương 1) | Sửa chữa cơ bản, chế đạn sắt vụn thử nghiệm. |
| **2** | **Huyền Thiết Tinh** | Hang đá Ma Thú Sơn Mạch (Chương 2) | Nâng cấp Huyền Trọng Xích Bậc 2 & Nội Giáp sơ cấp. |
| **3** | **Xích Đồng Sa Tinh** | Lòng đất Sa Mạc Tháp Qua Nhĩ (Chương 3) | Gia cố Huyền Trọng Xích Bậc 3 & Hộp Ngọc hái thuốc. |
| **4** | **Vân Lam Tinh Kim** | Chiến lợi phẩm Vân Lam Sơn / Đế Đô (Chương 4) | Nâng cấp Xích Bậc 4 & đúc Nhân Yêu Khôi thử nghiệm. |
| **5** | **Hắc Giác Ám Thiết** | Chợ đen Hắc Ấn Thành / Đáy Tháp Thiên Phần (Chương 5–6) | Nâng cấp Xích Bậc 5 & sửa chữa giáp Bàn Môn. |
| **6** | **Hàn Tủy Tinh Thiết** | Vùng núi băng Xuất Vân / Biên giới Bắc Vực (Chương 7) | Nâng cấp Xích Bậc 6 & nung khung xương **Địa Yêu Khôi**. |
| **7** | **Hư Không Lôi Đồng** | Lôi Sơn Phong Lôi Các / Trung Châu (Chương 8) | Nâng cấp Xích Bậc 7 & dẫn sét cho **Thiên Yêu Khôi**. |
| **8** | **Thánh Cốt Tinh Kim** | Viễn Cổ Di Tích Đấu Thánh (Chương 9) | Nâng cấp Xích Bậc 8 & đúc **Đội hình 10 Thiên Yêu Khôi**. |
| **9** | **Thái Hư Thần Thiết** | Hư Không Cổ Long Đảo / Mãng Hoang Cổ Vực (Chương 10) | Nâng cấp Xích Bậc 9, khảm *Long Hoàng Khải Giáp* & đúc **Bắc Vương**. |
| **10** | **Hằng Cổ Đế Thạch** | Đà Xá Cổ Đế Động Phủ (Chương 11) | Thăng hoa vũ khí tối thượng **Hằng Cổ Viêm Đế Cự Xích Bậc 10**! |

### 10.3. Hệ Thống Cộng Hưởng Danh Hiệu Trang Bị (`Iconic Set Bonuses`)
Khi người chơi sưu tầm và mặc đúng tổ hợp trang bị mang tính biểu tượng từng thời kỳ của Tiêu Viêm, nhân vật mở khóa thêm **Hiệu Ứng Cộng Hưởng Danh Hiệu** hiển thị dưới chân:
* **Bộ 1 — *"Hắc Bào Thiếu Niên Hiệp Khách"* (Chương 1–4)**:
  * *Yêu cầu*: `Huyền Trọng Xích (Bậc 2+) + Tử Vân Dực + Hải Tâm Nội Giáp + Hắc Bào Bí Ẩn`.
  * *Hiệu ứng*: Tăng `+15% Vàng & Dược Liệu nhặt được`; khi máu tụt dưới `40%`, giọng nói Dược Lão vang lên truyền tạm lớp khiên Đấu Khí Cốt Linh Lãnh Hỏa chắn `30% Max HP`!
* **Bộ 2 — *"Nham Kiêu Tông Sư Trung Châu"* (Chương 7–9)**:
  * *Yêu cầu*: `Huyền Trọng Xích (Bậc 7+) + Thiên Nhạn Cửu Hành Dực + Cốt Viêm Giới + Thiên Yêu Khôi`.
  * *Hiệu ứng*: Giảm `-20% Hồi chiêu` cho *Thiên Hỏa Tam Huyền Biến* và *Tam Thiên Lôi Huyễn Thân*; Thiên Yêu Khôi tăng thêm `+25% Tốc độ đấm` khi đứng trong tầm `160 px` quanh Tiêu Viêm!
* **Bộ 3 — *"Viêm Đế Thống Ngự Vạn Hỏa"* (Chương 11 — Endgame Tuyệt Đỉnh)**:
  * *Yêu cầu*: `Hằng Cổ Viêm Đế Xích (Bậc 10) + Đế Diễm Thần Hoàng Dực + Thái Hư Long Hoàng Giáp + Đà Xá Cổ Đế Ngọc (8/8) + Bắc Vương`.
  * *Hiệu ứng*: Mở khóa **Vòng Đế Viêm 23 Sắc** dưới chân; mọi Đấu Kỹ Hoàng/Huyền/Địa Giai cũ đều được nâng thẳng hệ số sát thương lên ngang chuẩn **Thiên Giai Cao Cấp** (cho phép người chơi dùng lại cả *Bát Cực Băng* hay *Diễm Phân Phệ Lãng Xích* đi cày Endgame cực sướng)!

### 10.4. Hệ Thống Tọa Kỵ Ma Thú & Phương Tiện Di Chuyển Vùng Rộng (`Mounts & Spatial Ships`)
Khi di chuyển trên Bản Đồ Thế Giới Rộng (`Overworld Map`) nối liền Gia Mã Đế Quốc -> Hắc Giác Vực -> Trung Châu, ngoài việc tự bay bằng Đấu Dực, người chơi có thể sưu tầm **5 Tọa Kỵ / Phi Thuyền nguyên tác** để tăng tốc hành trình và tránh quái vật cấp thấp cản đường:

| Tên Tọa Kỵ / Phương Tiện | Chương Mở | Tốc Độ Hành Trình | Đặc Tính Khám Phá Bản Đồ Thế Giới |
| :--- | :---: | :---: | :--- |
| **1. Đà Mã / Thanh Lân Ưng** | Chương 1–2 | `150% SPD` | Chim ưng phổ thông của đội bay Gia Mã, đưa nhanh giữa Ô Thản Thành – Thanh Sơn Trấn – Đế Đô. |
| **2. Phi Hành Thuyền Vân Lam / Lục Phẩm Điêu** | Chương 4–5 | `180% SPD` | Bỏ qua va chạm địa hình rừng núi, miễn gặp phục kích quái Cấp 1–4. |
| **3. Tử Tinh Dực Sư (Thú Cưỡi Huyết Mạch)** | Chương 6–7 | `220% SPD` | Tiếng gầm Sư Vương khiến toàn bộ Ma Thú dưới Cấp 6 tự động hoảng sợ dạt sang hai bên đường! |
| **4. Không Gian Ngọc Thuyền (Trùng Động)** | Chương 8 | `300% SPD` | Cần có để vượt qua **Bão Không Gian Trong Trùng Động Trung Châu** (nếu thuyền nứt sẽ rơi xuống Bắc Vực gặp Hàn Gia như trong truyện!). |
| **5. Hư Không Long Xa (Thái Hư Cổ Long)** | Chương 10–11 | **Tức Thời** | Mở khe nứt hư không bước một bước tới bất kỳ Thành Trì, Bí Cảnh hoặc Phân Điện nào trên toàn cõi Đấu Khí Đại Lục! |

---

## 11. Bảng Thang Điểm Nuôi Dưỡng Yêu Khôi & Mẫu Cấu Trúc Dữ Liệu (`JSON Schema`)

### 11.1. Bảng Thang Điểm "Tinh Luyện Lôi Văn" Của Yêu Khôi (Từ Lv.70 -> Lv.120)
Mỗi lần người chơi luyện đan Độ Đan Lôi hoặc dẫn sét ở Lôi Sơn cho Yêu Khôi hấp thụ, thanh **Lôi Văn (`Thunder-Rune EXP`)** tích lũy để mở khóa các mốc sức mạnh mới:

| Mốc Tiến Hóa Khôi Lỗi | Điểm Lôi Văn Tích Lũy | Cảnh Giới Tương Đương | Kỹ Năng & Nội Tại Thức Tỉnh Thêm |
| :--- | :---: | :--- | :--- |
| **Địa Yêu Khôi – Sơ Khởi** | `0 Điểm` | Ngũ Tinh Đấu Tông (`Lv.75`) | Mình đồng bạc sáng, đấm cận chiến đẩy lùi, miễn nhiễm Độc/Hồn. |
| **Địa Yêu Khôi – Chuẩn Thiên** | `300 Điểm` | Nhất Tinh Đấu Tôn (`Lv.80`) | Cơ thể bắt đầu ánh vàng nhạt; mở kỹ năng *Lao Đấm Phá Không*. |
| **Thiên Yêu Khôi – Sơ Kỳ** | `800 Điểm` *(Đan Hội C.8)* | Tam Tinh Đấu Tôn (`Lv.83`) | **Hóa Vàng Kim Toàn Tập!** Ngực hiện `1 Đạo Lôi Văn`, tốc độ ngang *Tam Thiên Lôi Động*. |
| **Thiên Yêu Khôi – Trung Kỳ** | `1,800 Điểm` | Lục Tinh Đấu Tôn (`Lv.86`) | Hiện `2 Đạo Lôi Văn`; cú đấm kèm hiệu ứng Tê Liệt `1.0s` và xuyên `40% DEF`. |
| **Thiên Yêu Khôi – Đỉnh Phong** | `3,500 Điểm` | Cửu Chuyển Đấu Tôn (`Lv.94`) | Hiện `3 Đạo Lôi Văn` chói lòa; tự tạo khiên Kim Lôi hấp thụ sát thương cho chủ nhân. |
| **Yêu Thánh Khôi** | `6,000 Điểm` + *Thánh Cốt* | Nhất – Nhị Tinh Đấu Thánh (`Lv.102`) | Mở khóa dẫn đầu **Thập Đại Thiên Yêu Khôi Đại Trận** khóa cứng không gian! |
| **Siêu Khôi Lỗi: BẮC VƯƠNG** | `10,000 Điểm` + *Xác Bắc Long Vương* | **Lục -> Cửu Tinh Đấu Thánh (`Lv.118`)** | **Hắc Kim Long Lôi Thể**: Đấm vỡ kết giới Đấu Thánh, hồi phục tự động trong sấm sét! |

### 11.2. Mẫu Cấu Trúc Dữ Liệu Trang Bị Sinh Trưởng (`EquipmentSaveData.json`)
```json
{
  "heavy_ruler": {
    "tier": 7,
    "item_id": "tinh_khong_loi_van_xich",
    "is_sealed_heavy_mode": true,
    "soul_imprint_id": "imprint_thai_hu_co_long",
    "socketed_cores": [
      { "slot": 1, "element": "lightning", "rank": 7 },
      { "slot": 2, "element": "ice", "rank": 7 },
      { "slot": 3, "element": "space", "rank": 8 }
    ]
  },
  "puppet_roster": {
    "active_puppet_id": "bac_vuong_supreme",
    "ai_stance": "LIGHTNING_ROD_GUARD",
    "thunder_rune_exp": 10450,
    "ten_puppet_formation_unlocked": true
  }
}
```
