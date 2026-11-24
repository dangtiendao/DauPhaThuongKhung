# KHO CÔNG PHÁP, ĐẤU KỸ & BÍ PHÁP THỰC CHIẾN (2D TOP-DOWN COMBAT SKILLS)

> **Mã tài liệu**: `04_Dau_Ky_Cong_Phap_Va_Trang_Bi\Kho_Cong_Phap_Va_Dau_Ky.md`
> **Phạm vi**: Hệ thống Phẩm cấp Đấu Kỹ, Độ Thông Thạo thực chiến, Frame Data 60 FPS, Hitbox Pixel 2D, Cơ chế Dung hợp Hỏa Liên và Hồ sơ chi tiết 24 Đấu Kỹ & Bí Pháp chuẩn nguyên tác của Tiêu Viêm.
> **Đồng bộ**: Tuân thủ hệ chỉ số (`HP`, `QI`, `ATK`, `DEF`, `SPD`, `SOUL`), khung phím (`LMB`, `RMB/C`, `Space`, `Q/E/R`, `F`, `T`) và 12 Đại Cảnh Giới tại [00_Master_Index_Va_Quy_Chuan.md](../00_Tong_Quan_Kien_Truc/00_Master_Index_Va_Quy_Chuan.md).

---

## 1. Quy Chuẩn Không Gian, Frame Data & Khung Chiến Đấu Top-down 2D Pixel

Để lập trình viên gameplay và họa sĩ Pixel Art triển khai chính xác cảm giác đánh "nặng tay, dứt khoát, bùng nổ":

* **Đơn vị lưới chuẩn (`Tile`)**: `1 Tile = 32 × 32 px`. Khung nhìn camera chuẩn: `640 × 360 px` (`20 × 11.25 Tiles`, phóng nguyên `×3` lên `1920 × 1080`).
* **Tốc độ khung hình chuẩn (`Tick Rate`)**: `60 FPS` (`1 Frame ≈ 16.67ms`). Mọi kỹ năng đều chia rõ 3 pha:
  1. **Tụ lực (`Wind-up`)**: Khung hình chuẩn bị vung tay/xích (có thể hủy bằng `Space` lướt né).
  2. **Phát kình (`Active Hitbox`)**: Khung hình sinh vùng va chạm gây sát thương & hiệu ứng `Hit-stop` (`2–6 frames` khựng hình tạo lực đấm).
  3. **Thu thế (`Recovery`)**: Khung hình hồi tay (có thể rút ngắn bằng chỉ số `SPD` và Độ Thông Thạo).
* **Hurtbox nhân vật Tiêu Viêm**: Hình chữ nhật đứng `20 × 24 px` (tâm đặt tại gót chân).
* **Cơ chế Định hướng (`360° Cursor Aiming`)**: Mọi Đấu Kỹ tầm xa/hình quạt đều lấy góc vector từ tâm nhân vật tới con trỏ chuột.
* **Phân bổ Khe Kỹ Năng Thực Chiến**:
  * **Công Pháp Chủ Tu (Nội tại nền)**: *Phần Quyết* — tự động vận hành, quyết định tốc độ hồi `QI/s`, số khe Dị Hỏa và cấp độ chuyển hóa Đấu Khí.
  * **3 Ô Đấu Kỹ Chủ Động (`Q`, `E`, `R`)**: Tự do lắp ghép từ kho Đấu Kỹ đã học (không khóa cứng theo hệ, cho phép tạo build Cận chiến Ám kình, Pháo đài Trọng Xích, hay Pháp sư Khống Hỏa).
  * **Ô Thân Pháp (`Space`)**: Lướt cơ bản -> *Phi Hành Tử Vân Dực* -> *Tam Thiên Lôi Động* -> *Tam Thiên Lôi Huyễn Thân*.
  * **Ô Bí Pháp Bộc Phát (`RMB` / `C`)**: Đảo trạng thái *Phong Ấn / Giải Phong Huyền Trọng Xích* hoặc kích hoạt nhanh *Thiên Hỏa Tam Huyền Biến* / *Linh Hồn Pháp Tướng*.
  * **Ô Tuyệt Kỹ Chí Tôn (`F`)**: Nhánh kỹ năng thương hiệu **Phật Nộ Hỏa Liên -> Phật Nộ Luân Hồi -> Dị Hỏa Hằng Cổ Xích**.

---

## 2. Hệ Thống Phẩm Cấp Đấu Kỹ & Quy Tắc Phản Phệ Vượt Cấp

Đấu Kỹ chia thành **4 Đại Giai (Hoàng – Huyền – Địa – Thiên) × 3 Tiểu Cấp (Đê – Trung – Cao) = 12 Bậc**, cộng thêm tầng tối thượng **Đế Kỹ** ở Chương 11.

| Phẩm Cấp | Tiểu Cấp | Hệ Số Sát Thương Chuẩn | Tiêu Hao `QI` Gốc | Cảnh Giới Yêu Cầu Tối Thiểu | Đặc Trưng Thiết Kế Hitbox & Quy Tắc 2D |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **Hoàng Giai** | Đê / Trung / Cao | `120% / 160% / 210% ATK` | `8 – 15 QI` | Đấu Chi Khí – Đấu Giả (Lv.1–19) | Tầm ngắn `48–80 px`, `Wind-up` cực nhanh (`6–10f`), dùng kẹp giữa chuỗi đánh thường `LMB`. |
| **Huyền Giai** | Đê / Trung / Cao | `240% / 320% / 420% ATK` | `18 – 48 QI` | Đấu Giả – Đấu Linh (Lv.10–49) | Mở khóa kéo/đẩy vị trí (`Displacement`), Ám kình xuyên `DEF`, sóng âm `360°`, bay lơ lửng vượt vực. |
| **Địa Giai** | Đê / Trung / Cao | `500% / 720% / 980% ATK` | `55 – 160 QI` | Đấu Vương – Đấu Tôn (Lv.50–84) | Huy động năng lượng thiên địa: Biến đổi mặt đất thành vùng dung nham DoT, phản đạn, phân thân Lôi Đình. |
| **Thiên Giai** | Đê / Trung / Cao | `1,250% / 2,100% / 3,400%` | `150 – 420 QI` | Đấu Tôn – Đấu Thánh (Lv.80–119) | Can thiệp Không Gian & Linh Hồn: Lỗ đen hút quái toàn màn, sóng âm hủy thần trí, luân hồi nuốt đạn Boss. |
| **Đế Kỹ** | Chí Tôn | `8,800% (ATK + SOUL)` | `1,000 QI` | Đấu Đế / Viêm Đế (Lv.120) | Bao phủ toàn màn hình `640 × 360 px`, chém rách thiên khung, bỏ qua `100% DEF` và mọi khiên bất tử. |

### Cơ Chế "Cưỡng Ép Thi Triển Vượt Cấp" (Over-Tier Backlash)
Trong nguyên tác, Tiêu Viêm nhiều lần ở cảnh giới thấp vẫn cố tung Đấu Kỹ Địa Giai / Hỏa Liên dẫn đến kiệt quệ kinh mạch. Trong game:
* Người chơi **được phép học và lắp Đấu Kỹ cao hơn Cảnh giới hiện tại tối đa `1 Đại Cảnh`**.
* **Cái giá phải trả**: Mỗi chênh lệch `1 Tiểu Cấp` vượt quá khả năng làm tăng **`+35% QI tiêu hao`** và rút trực tiếp **`4% HP tối đa`** ngay khi xuất chiêu (không làm chết nhân vật, dừng ở `1 HP`).
* **Cách hóa giải chuẩn truyện**: Bật *Dược Lão Phụ Thể* (`Phím T` nửa đầu game) hoặc mở *Thiên Hỏa Tam Huyền Biến* (`Phím C` nửa sau game) sẽ nâng Cảnh giới thực chiến tạm thời lên đủ chuẩn, **xóa bỏ hoàn toàn phạt phản phệ!**

---

## 3. Hệ Thống Độ Thông Thạo Đấu Kỹ (Cày Thực Chiến 4 Cảnh Giới)

Mỗi Đấu Kỹ sở hữu thanh **Độ Thông Thạo (`Skill Mastery`)** độc lập, chỉ tăng khi tung chiêu thực chiến trúng mục tiêu:

```text
[Sơ Khuy Môn Kính] ──(250 MP)──▶ [Tiểu Thành] ──(900 MP)──▶ [Đại Thành] ──(2,800 MP + Ngộ Đạo)──▶ [Hóa Cảnh]
```

### 3.1. Công Thức Tích Lũy Điểm Thông Thạo (`Mastery Point - MP`)
$$\text{MP Nhận Được} = \text{MP Cơ Bản} \times \text{Hệ Số Mục Tiêu} \times \text{Hệ Số Khổ Tu}$$
* **MP Cơ Bản**: `1 MP` mỗi lần tung chiêu trúng ít nhất 1 kẻ địch (không cộng dồn theo số lượng quái cỏ để chống farm gian lận 1 chiêu đầy thanh).
* **Hệ Số Mục Tiêu**: Quái thường `×1.0` | Quái Tinh Anh `×2.0` | Đại Boss `×5.0`.
* **Hệ Số Khổ Tu**:
  * Đeo **Huyền Trọng Xích chế độ Phong Ấn (Trọng Áp)**: `×1.5 MP`.
  * Luyện chiêu trong *Thiên Phần Luyện Khí Tháp* hoặc *Thiên Mộ*: `×1.5 MP`.
  * Ngồi thiền trên *Thanh Liên Đài* sau trận chiến: Tặng thêm `+10% MP` tổng kết.

### 3.2. Đặc Quyền Từng Bậc Thông Thạo
| Bậc Thông Thạo | Yêu Cầu `MP` | Giảm `QI` | Giảm `CD` | Hệ Số Uy Lực | Đột Phá Cơ Chế & Biến Đổi Hình Thái Pixel |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **1. Sơ Khuy Môn Kính** | `0 MP` | `0%` | `0%` | `×1.00` | Hiệu ứng gốc; thời gian tụ lực (`Wind-up`) và thu thế (`Recovery`) mặc định. |
| **2. Tiểu Thành** | `250 MP` *(Hoàng/Huyền: 150)* | `-12%` | `-10%` | `×1.15` | Tăng `+15%` kích thước Hitbox; giảm `20% Recovery frames` để nối đòn mượt hơn. |
| **3. Đại Thành** | `900 MP` *(Hoàng/Huyền: 600)* | `-22%` | `-20%` | `×1.32` | **Mở khóa Đột Phá Đại Thành độc quyền** (thêm luồng đạn, xuyên giáp ngầm, hồi sinh phân thân...). |
| **4. Hóa Cảnh** | `2,800 MP` + **Ngộ Đạo** | `-35%` | `-30%` | `×1.55` | **Giảm `70% Wind-up` (gần như tức thời)**; kỹ năng tự động nhuộm màu Pixel Shader của **Dị Hỏa Chủ Đạo**! |

---

## 4. Bảng Tổng Hợp 24 Đấu Kỹ & Bí Pháp Chuẩn Nguyên Tác Của Tiêu Viêm

| # | Tên Đấu Kỹ / Bí Pháp | Phẩm Cấp | Chương Mở | `QI` | `CD` | Hitbox Pixel 2D & Góc Quét | Hệ Số Sát Thương |
| :-: | :--- | :--- | :---: | :---: | :---: | :--- | :--- |
| **01** | **Toái Thạch Chưởng** | Hoàng – Cao | Chương 1 | `12` | `2.5s` | Chữ nhật cận chiến `56 × 40 px` | `165% ATK` |
| **02** | **Hấp Chưởng** | Huyền – Đê | Chương 1 | `18` | `5.0s` | Hình nón ngược `90°`, bán kính `160 px` | `95% ATK` *(Kéo gom)* |
| **03** | **Xuy Hỏa Chưởng** | Huyền – Đê | Chương 1 | `22` | `5.5s` | Hình quạt `100°`, bán kính `128 px` | `190% ATK` *(Đẩy văng)* |
| **04** | **Bát Cực Băng** | Huyền – Cao | Chương 1 | `35` | `7.0s` | Lao tới `64 px` + Điểm nổ `48 × 48 px` | `380% ATK` *(+8 Ám Kình)* |
| **05** | **Phi Hành Tử Vân Dực** | Huyền – Cao | Chương 2 | `15` | `3.5s` | Sải cánh `56 px`, lướt bay dài `144 px` | `120% ATK` *(Bay vượt địa hình)* |
| **06** | **Khống Hỏa: Viêm Đạn / Hỏa Linh Xà** | Bí Kỹ Hỏa | Chương 2 | `20` | `3.0s` | Cầu lửa `20 × 20 px` / Xà Hỏa đuổi `288 px` | `140% ATK + 180% SOUL` |
| **07** | **Sư Hổ Toái Kim Ngâm** | Huyền – Cao | Chương 5 | `45` | `11.0s` | Vòng sóng âm tròn `360°`, bán kính `144 px` | `280% ATK + 120% SOUL` |
| **08** | **Lục Hợp Du Thân Xích** | Địa – Đê | Chương 5 | `40` | `10.0s` | Vòng xích xoay tròn `360°`, bán kính `72 px` | `65% ATK × 8 nhịp` *(Phản đạn)* |
| **09** | **Diễm Phân Phệ Lãng Xích** | Địa – Đê | Chương 4 | `60` | `9.0s` | Vệt sóng lửa rách đất `288 × 48 px` | `560% ATK` + DoT dung nham |
| **10** | **Tam Thiên Lôi Động** | Địa – Đê | Chương 5 | `25/nhịp` | `6.0s` | Lướt chớp 3 nhịp × `176 px`, I-frame `0.28s` | `160% ATK` *(Tàn ảnh sét)* |
| **11** | **Tam Thiên Lôi Huyễn Thân** | Địa – Cao | Chương 8 | `140` | `28.0s` | Phân thân `20 × 24 px`, bán kính chiến đấu `320 px` | Kế thừa `75% -> 100% ATK` |
| **12** | **Lộng Viêm Quyết** | Bí Pháp Hỏa | Chương 7 | `80` | `18.0s` | Hóa Sinh Hỏa bay quanh bán kính `112 px` | `110% SOUL / đòn phun` |
| **13** | **Thiên Hỏa Tam Huyền Biến** | Đệ Nhất Bí Pháp | Chương 6–8 | `15% QI` | `45.0s` | Sóng nổ `160 px` khi mở; cường hóa toàn thân | Buff `+35% / +65% / +110% Stats` |
| **14** | **Đế Ấn Quyết (Ngũ Ấn)** | Địa – Cao -> Thiên – Đê | Chương 6–10 | `55–220` | `14.0s` | Chưởng ấn kim quang `96 × 96` -> `280 × 280 px` | Chuỗi 5 Ấn tổng `2,150% ATK` |
| **15** | **Đại Thiên Tạo Hóa Chưởng** | Thiên – Đê | Chương 9 | `180` | `16.0s` | Chưởng ấn lỗ đen không gian `192 × 192 px` | `1,380% ATK` *(Xé không gian)* |
| **16** | **Hoàng Tuyền Chỉ** | Thiên – Đê | Chương 9 | `150` | `11.0s` | Tia chỉ xuyên thấu `384 × 32 px` | `1,250% ATK` *(Khóa hồi máu)* |
| **17** | **Hoàng Tuyền Chưởng** | Thiên – Trung | Chương 9 | `240` | `18.0s` | Cự chưởng vàng sẫm đè xuống `256 × 176 px` | `2,100% ATK` *(Phá 50% Giáp)* |
| **18** | **Hoàng Tuyền Thiên Nộ** | Thiên – Cao | Chương 9 | `300` | `32.0s` | Sóng âm Linh Hồn toàn màn `640 × 360 px` | `900% ATK + 2,400% SOUL` |
| **19** | **Kim Đế Phần Thiên Trảm / Đại Tịch Diệt Chỉ** | Thiên – Trung | Chương 10 | `210` | `15.0s` | Lưỡi trảm cung `224 px` / Điểm nổ `128 × 128 px` | `1,850% ATK + 600% SOUL` |
| **20** | **Phật Nộ Hỏa Liên** | Biến Thiên | Chương 3–10 | `50–85% QI` | `25–45s` | Vòm cầu nổ từ `160 px` -> `320 px` -> `480 px` | `1,100% -> 4,800% (ATK+SOUL)` |
| **21** | **Phật Nộ Luân Hồi** | Thiên – Cao+ | Chương 10 | `420` | `40.0s` | Đĩa xoay Luân Hồi hút đạn đường kính `240 px` | `4,200% (ATK + SOUL)` |
| **22** | **Tịnh Liên Yêu Trận** | Cổ Trận Thánh | Chương 10 | `350` | `38.0s` | Trận đồ hoa sen mặt đất đường kính `320 px` | `320% SOUL/s × 8s` *(Hút QI)* |
| **23** | **Linh Hồn Pháp Tướng** | Đế Cảnh Hồn | Chương 11 | `300` | `50.0s` | Kim Thân cao `128 px` sau lưng nhân vật | Cộng `+250% SOUL` chuẩn/đòn |
| **24** | **Dị Hỏa Hằng Cổ Xích** | **Đế Kỹ** | Chương 11 | `1,000` | `60.0s` | Cự Xích 23 màu `640 × 240 px` chẻ đôi bầu trời | `8,800% (ATK + SOUL)` |

---

## 5. Hồ Sơ Cơ Chế Thực Chiến Chi Tiết Từng Đấu Kỹ (01 – 24)

### Nhóm I: Khởi Đầu Ô Thản Thành & Ma Thú Sơn Mạch (Số 01 – 06)

#### 01. Toái Thạch Chưởng *(Hoàng Giai Cao Cấp)*
* **Nguồn gốc**: Tàng Thư Các Tiêu Gia (Chương 1 — Đấu Kỹ đầu đời Tiêu Viêm dùng đánh bại Tiêu Ninh).
* **Frame Data**: `Wind-up 8f` | `Active 4f` | `Recovery 10f`.
* **Cơ chế thực chiến**: Đấm thẳng cự ly ngắn đẩy lùi quái `16 px`, gây `×1.5 sát thương Phá Giáp (Poise Damage)` lên quái mang khiên đá hoặc vỏ cứng.
* **Đột phá Đại Thành**: Áp trạng thái *Toái Giáp* làm giảm `-15% DEF` của mục tiêu trong `4s`, cực tốt để mở đầu combo đầu game.

#### 02 & 03. Hấp Chưởng & Xuy Hỏa Chưởng *(Bộ Đôi Huyền Giai Đê Cấp — Combo Hút Đẩy)*
* **Nguồn gốc**: *Hấp Chưởng* mua tại Phòng Đấu Giá Mễ Đặc Nhĩ; *Xuy Hỏa Chưởng* do Dược Lão truyền dạy để phối hợp đối kháng.
* **Frame Data**: `Wind-up 10f` | `Active 8f` | `Recovery 12f`.
* **Cơ chế Cộng hưởng Hút – Đẩy (Signature Early Synergy)**:
  * **Bước 1 (`Hấp Chưởng`)**: Tạo luồng xoáy gió ngược hình nón `90°` kéo tuột bầy quái tầm xa (Cung thủ, Xà nhân) tụ thành một cụm ngay trước mặt Tiêu Viêm, đồng thời hút luôn túi đồ/vàng rơi trên đất.
  * **Bước 2 (`Xuy Hỏa Chưởng` trong vòng `1.5s` sau Hấp Chưởng)**: Luồng lực hút bị đảo chiều đột ngột tạo **Bạo Phá Chân Không**, tăng thêm `+120% ATK` và hất văng cả cụm quái bay ngược `96 px`! Nếu quái đập trúng vách đá hoặc cột trụ 2D: nhận thêm `+80% ATK` sát thương va chạm và Choáng `0.8s`.
* **Đột phá Đại Thành**: *Hấp Chưởng* ngắt được kỹ năng tụ lực đỏ của Tinh Anh; *Xuy Hỏa Chưởng* để lại thảm than hồng gây Bỏng `3s`.

#### 04. Bát Cực Băng *(Huyền Giai Cao Cấp — Uy Lực Sánh Ngang Địa Giai Đê Cấp)*
* **Nguồn gốc**: Dược Lão truyền dạy trong quá trình khổ tu tại Ma Thú Sơn Mạch.
* **Frame Data**: `Wind-up 12f` (bước dậm nứt đất) | `Active 5f` (Hit-stop nặng `6f` rung màn hình!) | `Recovery 14f`.
* **Cơ chế 8 Tầng Ám Kình (`Hidden Force Stacking`)**:
  * Khi đã lắp *Bát Cực Băng* lên thanh kỹ năng, mỗi đòn đánh thường `LMB` (tay không hoặc Trọng Xích) trúng địch tích **+1 Tầng Ám Kình** (tối đa `8 tầng`, hiển thị 8 chấm sáng quanh thanh máu nhân vật).
  * Khi kích hoạt chiêu, Tiêu Viêm lao vọt `64 px` thúc chỏ/đấm thẳng: Mỗi tầng Ám Kình cộng thêm **`+25% ATK` và `+8% Xuyên Giáp (`Armor Penetration`)**.
* **Đột phá Đại Thành**: Khi tích đủ `8 tầng`, cú đấm phóng luồng **Ám Kình Xuyên Thấu** nổ bung từ sau lưng mục tiêu hình nón `80 px`, tổng cộng **bỏ qua `65% DEF`** — khắc tinh số 1 của Boss giáp dày như Mặc Thừa, Vân Lăng!

#### 05. Phi Hành Tử Vân Dực *(Huyền Giai Cao Cấp Phi Hành Đấu Kỹ)*
* **Nguồn gốc**: Mật thất vách núi hẻm Thanh Sơn Trấn (Chương 2 — cùng rương với Tịnh Liên Yêu Hỏa tàn đồ).
* **Cơ chế Di chuyển Không gian 2D (`Z-Axis Elevation`)**:
  * Nhấn nhanh `Space`: Vỗ cánh Hắc-Tử lướt nhanh `144 px` có `0.22s I-frame`.
  * **Nhấn giữ `Space`**: Tiêu Viêm bay lơ lửng cách mặt đất trong tối đa `6s` (`+35% SPD`), **vô hiệu hóa toàn bộ bẫy mặt đất, đầm độc, khe vực dung nham và chấn địa sóng của Boss**!
* **Đột phá Đại Thành**: Tiến hóa *Hắc Diễm Tử Vân Dực*, mỗi lần lướt vẩy ra `6 lông vũ lửa đen` tự tìm mục tiêu gần nhất (`35% ATK/lông`).

#### 06. Khống Hỏa Thuật: Viêm Đạn / Hỏa Linh Xà *(Bí Kỹ Đan Hỏa)*
* **Nguồn gốc**: Vận dụng kỹ pháp khống hỏa của Luyện Đan Sư vào chiến đấu (Chương 2).
* **Cơ chế Tương tác `SOUL`**: Bấm nhanh bắn *Viêm Đạn* nổ nhỏ; giữ phím `0.6s` hóa *Hỏa Linh Xà* uốn lượn tự bẻ góc bám theo mục tiêu dựa trên chỉ số `SOUL` của Tiêu Viêm (không bao giờ trượt!).
* **Đột phá Đại Thành**: Phóng cùng lúc **Song Hỏa Xà** quấn chặt chân kẻ địch gây Trói Chân (`Root`) `1.5s`.

---

### Nhóm II: Trưởng Thành Già Nam Học Viện & Trung Châu Phong Vân (Số 07 – 14)

#### 07. Sư Hổ Toái Kim Ngâm *(Huyền Giai Cao Cấp Âm Ba Đấu Kỹ)*
* **Nguồn gốc**: Phần thưởng Khảo thí/Tàng Thư Các Già Nam Học Viện (Chương 5).
* **Cơ chế Giải vây `360°`**: Hít sâu (`Wind-up 9f`) rồi gầm vang tiếng Sư Tử – Mãnh Hổ hợp kích tạo vòng sóng âm vàng kim bán kính `144 px`: **Xóa sổ toàn bộ đường đạn tầm trung đang bay tới** và gây **Choáng cứng `1.8s`** mọi kẻ địch xung quanh!
* **Đột phá Đại Thành**: Gây hiệu ứng *Chấn Màng Nhĩ*, mục tiêu nhận thêm `+20% sát thương từ mọi nguồn` trong `5s`.

#### 08. Lục Hợp Du Thân Xích *(Địa Giai Đê Cấp Phòng Ngự Tuyệt Học)*
* **Nguồn gốc**: Tàng Thư Các Nội Viện Già Nam (Chương 5 — khẩu quyết *"Lục hợp du thân, xích ảnh bất lộ"*).
* **Cơ chế Phản Đạn Thực Chiến (`Active Parry & Deflect`)**: Tiêu Viêm múa Huyền Trọng Xích thành bức tường lửa tròn `72 px` quanh thân trong `2.5s` (vẫn di chuyển được với `70% SPD`). Giảm `80% sát thương cận chiến` và **mọi tia chưởng/mũi tên bắn chạm vòng xích đều bị bật ngược `180°` trả lại kẻ bắn với `150% sát thương`**!
* **Đột phá Đại Thành**: Nhịp thứ 8 kết thúc bằng cú đập xích nổ vòng lửa đẩy văng toàn bộ quái áp sát (`220% ATK`).

#### 09. Diễm Phân Phệ Lãng Xích *(Địa Giai Đê Cấp Trọng Xích Công Kích)*
* **Nguồn gốc**: Dược Lão trao tặng trước thềm Ước Hẹn 3 Năm Vân Lam Tông (Chương 4).
* **Frame Data**: `Wind-up 18f` (nhảy vọt vung xích qua đầu, có *Super Armor* chống ngắt chiêu!) | `Active 8f` | `Recovery 16f`.
* **Cơ chế Rách Đất**: Bổ dọc Huyền Trọng Xích chẻ toạc nền gạch tạo vết nứt sóng lửa dài `288 px` (`9 Tiles`), rộng `48 px`. Mặt đất bị nung chảy thành rãnh dung nham tồn tại `4s` gây `75% ATK/s` và làm chậm `30%`. Nếu bổ khi **đã tháo Phong Ấn Trọng Xích**: tăng thêm `+25% Tỷ lệ Chí mạng`!
* **Đột phá Đại Thành**: Một nhát bổ tách thành **3 cột sóng lửa rẻ quạt (`-20°, 0°, +20°`)**, diện tích càn quét tăng gấp ba!

#### 10 & 11. Tam Thiên Lôi Động & Tam Thiên Lôi Huyễn Thân *(Bộ Đôi Thân Pháp Phong Lôi Các)*
* **Nguồn gốc**: *Tam Thiên Lôi Động* đấu giá tại Hắc Ấn Thành (Chương 5); *Tam Thiên Lôi Huyễn Thân* đoạt được từ Trầm Vân / Hồng Thiên Khiếu của Phong Lôi Các (Chương 8).
* **Cơ chế Lướt Chớp (`Tam Thiên Lôi Động`)**: Cho phép lướt ziczac **3 lần liên tiếp** (`176 px/nhịp`, `0.28s I-frame/nhịp`), để lại tàn ảnh sét làm tê liệt quái đuổi theo `1s`. **Đại Thành**: *Perfect Dodge* (lướt sát đòn Boss trong `9 frames` cuối) hồi ngay `30 QI` và tặng thêm 1 nhịp lướt miễn phí!
* **Cơ chế Phân Thân Bất Diệt (`Tam Thiên Lôi Huyễn Thân`)**:
  * Ngưng tụ một **Lôi Huyễn Thân** có thanh máu độc lập (`60% HP` Tiêu Viêm) và kế thừa `75% ATK`, tự động dùng AI thông minh phối hợp đánh gọng kìm cùng người chơi.
  * **Quy tắc Bất Tử chuẩn 100% nguyên tác**: Khi phân thân bị Boss đập vỡ tan thành tia điện, **chỉ cần bản thể Tiêu Viêm chưa chết và còn trên `20% QI`, phân thân sẽ tự động tụ sét hồi sinh ngay cạnh Tiêu Viêm sau `6.0s`** (trong suốt `25s` hiệu lực chiêu)!
  * **Đột phá Đại Thành (*Tu La Cảnh*)**: Phân thân kế thừa **`100% ATK`**; bấm lại phím chiêu lần nữa sẽ **Hoán Đổi Vị Trí Tức Thời** giữa Tiêu Viêm và phân thân để thoát khỏi vòng vây chí tử của Boss!

#### 12 & 13. Lộng Viêm Quyết & Thiên Hỏa Tam Huyền Biến *(Song Tuyệt Bí Pháp Phần Viêm Cốc)*
* **Lộng Viêm Quyết**: Triệu hồi **Hóa Sinh Hỏa** (kết tinh từ 4–5 Thú Hỏa săn ở bản đồ hoặc *Vạn Thú Linh Hỏa*) bay quanh tự phun lửa yểm trợ (`110% SOUL/đòn`), cộng `+15% Hỏa Thương` và đặc biệt **được tính như 1 loại Dị Hỏa phụ** để kích hoạt Biến 3 của *Tam Huyền Biến* hoặc nhét vào *Phật Nộ Hỏa Liên* khi người chơi chưa săn đủ Dị Hỏa thật!
* **Thiên Hỏa Tam Huyền Biến (`Phím C`)**:
  * **Đệ Nhất Biến** (cần 1 Hỏa): Toàn thân bốc hỏa khí, tăng **`+35% ATK, DEF, SPD`** (tương đương nhảy vọt `+2 Tinh`).
  * **Đệ Nhị Biến** (cần 2 Hỏa): Mắt rực lửa đôi, tăng **`+65% Toàn Chỉ Số`** (tương đương nhảy vọt `+4 Tinh`).
  * **Đệ Tam Biến** (cần 3 Hỏa): Hoa văn Hỏa Viêm hiện rõ giữa trán, tăng **`+110% Toàn Chỉ Số`** (tương đương nhảy vọt **`+6 Tinh Cảnh Giới`**, xóa sạch áp chế cảnh giới khi đánh Boss vượt cấp!).
  * **Đại Thành**: Tu luyện viên mãn giúp xóa hoàn toàn trạng thái *Suy Yếu 4s* sau khi kết thúc `18s` biến hình, đồng thời giảm `-30% thời gian nén Phật Nộ Hỏa Liên`.

#### 14. Đế Ấn Quyết *(Cổ Tộc Bí Truyền — Hợp Nhất Ngũ Ấn Thông Thiên Giai!)*
* **Nguồn gốc**: Huân Nhi trao tặng 2 ấn đầu tại Già Nam Học Viện (Chương 6), lĩnh ngộ trọn bộ 5 ấn khi thực lực đạt Đấu Tông – Đấu Tôn.
* **Cơ chế Bấm Liên Hoàn 5 Nhịp (`Combo Chain Window 3.0s`)**:
  1. *Khai Sơn Ấn*: Chưởng kim quang thẳng phá giáp (`260% ATK`).
  2. *Phiên Hải Ấn*: Sóng kình cuộn xoáy gom quái (`320% ATK`).
  3. *Phúc Địa Ấn*: Lật úp mặt đất hất tung diện rộng (`410% ATK`).
  4. *Yểm Nhật Ấn*: Kim quang che khuất mặt trời, làm Mù (`Blind`) quái thường và giảm `35% chính xác` của Boss (`520% ATK`).
  5. *Cổ Đế Kính*: Phóng đại cổ ấn nổ kim sắc hủy diệt (`640% ATK`).
* **Đột phá Đại Thành (`Ngũ Ấn Hợp Nhất — Tiến Hóa Thiên Giai Đê Cấp`)**: Sau khi mở khóa cả 5 ấn, nhấn giữ phím `1.0s` để dung hợp trực tiếp 5 đạo ấn quyết trên bầu trời thành **Thiên Giai Cự Đế Ấn (`280 × 280 px`)** giáng thẳng xuống mục tiêu gây `2,150% ATK` trong một đòn duy nhất!

---

### Nhóm III: Tuyệt Học Thiên Giai, Hỏa Liên Dung Hợp & Đế Kỹ Viêm Đế (Số 15 – 24)

#### 15. Đại Thiên Tạo Hóa Chưởng *(Thiên Giai Đê Cấp — Tạo Hóa Thánh Giả)*
* **Nguồn gốc**: Rút ra từ Tạo Hóa Thánh Cốt tại Viễn Cổ Di Tích (Chương 9 — đổi bằng việc ghép ngọc xương sườn của Thiên Yêu Khôi/Thánh Cốt).
* **Cơ chế Xé Không Gian**: Đặt một **Chưởng Ấn Lỗ Đen (`192 × 192 px`)** tại vị trí con trỏ chuột. Lỗ đen bóp méo Pixel nền xung quanh (Shader Distortion), hút xoáy toàn bộ quái trong bán kính `224 px` vào tâm và phát nổ `1,380% ATK` (trong đó `30%` là sát thương chuẩn xuyên mọi kháng tính), trực tiếp phá nát *Không Gian Phong Tỏa* của Boss Đấu Tôn!

#### 16, 17 & 18. Hoàng Tuyền Tam Tuyệt *(Thiên Giai Đê -> Trung -> Cao Cấp)*
* **Nguồn gốc**: Bia đá truyền thừa của Hoàng Tuyền Thiên Tôn dưới đáy hồ Hoàng Tuyền Đàm (Chương 9).
* **16. Hoàng Tuyền Chỉ (Thiên – Đê)**: Bắn tia tử khí vàng đục `384 × 32 px` xuyên toàn bộ hàng kẻ địch, áp bùa chú **Hoàng Tuyền Minh Hủ** cắt đứt `100%` khả năng hồi máu/hút máu của Boss (khắc chế cứng các Boss Hồn Điện tự hồi phục!).
* **17. Hoàng Tuyền Chưởng (Thiên – Trung)**: Triệu hồi bàn tay Cửu U khổng lồ `256 × 176 px` đè bẹp từ trên cao, **đập nát ngay lập tức `50% Thanh Giáp Đấu Khí`** của Boss và ghim trọng lực cấm bay/lướt `4s`.
* **18. Hoàng Tuyền Thiên Nộ (Thiên – Cao — Âm Ba Linh Hồn Tuyệt Sát)**: Tiếng gầm phẫn nộ rung chuyển toàn màn hình `640 × 360 px` tính sát thương chủ đạo theo `2,400% SOUL`:
  * Mọi quái thường/tinh anh có cảnh giới Linh Hồn thấp hơn Tiêu Viêm **nổ tung thần hồn chết ngay tại chỗ**!
  * Đại Boss bị **Choáng Thần Trí cứng `3.0s`**, ngắt lập tức mọi chiêu đại tuyệt đang tụ lực!

#### 19. Kim Đế Phần Thiên Trảm / Đại Tịch Diệt Chỉ *(Thiên Giai Trung Cấp — Bí Tịch Sưu Tầm)*
* **Nguồn gốc**: Lĩnh ngộ qua giao lưu huyết mạch hỏa diễm cùng Huân Nhi (*Kim Đế Phần Thiên Viêm*) và bia cổ Thiên Mộ (Chương 10).
* **Cơ chế Đặc dụng**: Cho phép chuyển đổi linh hoạt ngoài giao tranh — *Kim Đế Phần Thiên Trảm* đốt cháy trực tiếp `15% thanh QI` của Boss thành sát thương chuẩn; *Đại Tịch Diệt Chỉ* điểm tan mọi lớp khiên Hắc Vụ bất tử của Hồn Điện Thiên Tôn.

#### 20. Phật Nộ Hỏa Liên *(Phím `F` — Cơ Chế Tự Chế 2 -> 3 -> 4 Khe Hỏa Độc Quyền)*
* **Nguồn gốc**: Tuyệt kỹ do chính Tiêu Viêm sáng tạo từ lần đầu dung hợp *Thanh Liên Địa Tâm Hỏa + Cốt Linh Lãnh Hỏa* tại Mặc Gia / Vân Lam Sơn (Chương 3–4) cho tới *Hủy Diệt Hỏa Liên* (Chương 9–10).
* **Bảng Cấp Độ Dung Hợp Hỏa Liên**:

| Hình Thái Hỏa Liên | Số Khe Hỏa | Phạm Vi Nổ 2D | Hệ Số Sát Thương | Hiệu Ứng Bổ Trợ Đặc Trưng |
| :--- | :---: | :---: | :---: | :--- |
| **Song Sắc Hỏa Liên** | `2 Hỏa` | Đường kính `160 px` | `1,100% (ATK+SOUL)` | Đẩy văng cực mạnh, phá vỡ Hộ Tông Đại Trận cấp thấp. |
| **Tam Sắc Hỏa Liên** | `3 Hỏa` | Đường kính `280 px` | `2,200% (ATK+SOUL)` | Nứt toạc mặt đất, tạo bão lửa cuộn xoáy `3s` kéo địch vào tâm. |
| **Hủy Diệt Hỏa Liên** | `4 Hỏa` | Đường kính `420 px` | `3,800% (ATK+SOUL)` | Sinh nấm mây lửa Hắc-Kim làm trắng xóa màn hình `0.4s`, xuyên `50% DEF`. |
| **Tịnh Liên Yêu Liên (Tiểu Y)** | `4 Hỏa + Yêu Hỏa` | Đường kính `480 px` | `4,800% (ATK+SOUL)` | **Yêu Hỏa Tiểu Y** hiện thân đẩy đài sen hồng trắng, tịnh hóa sạch sẽ ma khí Hồn Tộc! |

* **Hiệu ứng Cộng hưởng Khe Hỏa lắp vào**:
  * *Thanh Liên Địa Tâm Hỏa*: Cộng hiệu ứng Nham Thạch Hất Tung + Hồ dung nham `5s`.
  * *Cốt Linh Lãnh Hỏa*: Cộng hiệu ứng **Hàn Băng Đóng Cứng `2.0s`** trước nhịp nổ chính.
  * *Vẫn Lạc Tâm Viêm*: Bùng phát Tâm Hỏa từ nội tạng, rút thêm **`2.5% HP tối đa của Boss` (`8%` với quái)**.
  * *Tam Thiên Diễm Viêm Hỏa*: Hồi phục **`4% HP tối đa` mỗi kẻ địch trúng nổ** + bất tử `1.5s`.
  * *Sinh Linh Chi Diễm*: Phủ thảm thảo mộc xanh ngọc dưới chân hồi máu liên tục cho Tiêu Viêm và Đồng hành trong `6s`.

#### 21. Phật Nộ Luân Hồi *(Thiên Giai Cao Cấp Đỉnh Phong)*
* **Nguồn gốc**: Sáng tạo ở cảnh giới Tứ Tinh – Ngũ Tinh Đấu Thánh (Chương 10–11) khi nén 4 Dị Hỏa cực hạn không cho nổ mà ép thành vòng quay Luân Hồi.
* **Cơ chế Nuốt Đạn & Xóa Sổ**: Phóng **Đĩa Xoay Bốn Màu (`240 px`)** bay chậm về phía trước trong `4s`: Hút toàn bộ kẻ địch và **nuốt gọn mọi đường đạn/chiêu thức Thiên Giai của Boss bắn vào nó**. Càng nuốt nhiều đạn, đĩa càng phình to (tối đa `+60% sát thương`), kết thúc bằng nhát cắt không gian đen kịt `4,200% (ATK + SOUL)`!

#### 22. Tịnh Liên Yêu Trận *(Cổ Trận Đấu Thánh — Tịnh Liên Yêu Thánh Truyền Thừa)*
* **Nguồn gốc**: Ký ức truyền thừa của Tịnh Liên Yêu Thánh khi thu phục Dị Hỏa `#03` (Chương 10).
* **Cơ chế Luyện Hóa Giữa Chiến Trường**: Trải đại trận hoa sen đường kính `320 px` (`10 Tiles`) khóa cứng Boss bên trong (không thể lướt/dịch chuyển ra ngoài trong `8s`). Mọi kẻ địch đứng trong trận bị Hồng Liên Nghiệp Hỏa rút máu & Đấu Khí (`320% SOUL/s`), chuyển hóa thành **`+6% QI & +3% HP mỗi giây`** bơm ngược lại cho Tiêu Viêm!

#### 23. Linh Hồn Pháp Tướng *(Đế Cảnh Linh Hồn Tuyệt Kỹ)*
* **Nguồn gốc**: Đột phá Linh Hồn từ Thiên Cảnh Đại Viên Mãn lên **Đế Cảnh** sau khi hấp thu Bản Nguyên Đế Cảnh của Thôn Linh Tộc / Hoàng Tuyền (Chương 11).
* **Cơ chế Kim Thân Hộ Thể**: Kim Thân Pháp Tướng cao `128 px` hiện lên sau lưng trong `20s`: Miễn nhiễm `100%` mọi đòn tấn công Linh Hồn, tăng gấp đôi tầm quét Trọng Xích bằng cánh tay ánh sáng vàng ròng, mỗi đòn đánh đính kèm **`+250% SOUL` sát thương chuẩn**! **Đại Thành**: Tự động hóa giải 1 đòn kết liễu chí tử cho Tiêu Viêm.

#### 24. Dị Hỏa Hằng Cổ Xích *(Đế Kỹ Tối Thượng Của Viêm Đế Tiêu Viêm)*
* **Nguồn gốc**: Tiếp nhận truyền thừa **Đà Xá Cổ Đế** tại Cổ Đế Động Phủ, hiệu triệu Vạn Hỏa thiên hạ ngưng tụ 23 Dị Hỏa quyết tử cùng Hồn Thiên Đế (Chương 11).
* **Cơ chế Kết Liễu Thần Thoại**:
  * Khi nhấn giữ `F` ở cảnh giới Đấu Đế (`Lv.120`), bầu trời bản đồ tối sầm, **23 cột sáng Dị Hỏa đủ sắc màu** từ khắp chân trời bay tụ về tay Tiêu Viêm đúc thành thanh **Hằng Cổ Dị Hỏa Cự Xích (`640 × 240 px`)**!
  * Một nhát bổ dọc chẻ đôi khung hình gây **`8,800% (ATK + SOUL)` sát thương tuyệt đối** (xuyên thủng mọi lớp giáp Đế Cấp, xóa bỏ trạng thái bất tử giai đoạn chuyển Phase của Boss phụ, để lại vết nứt hư không cháy rực 23 màu suốt `6s`).

---

## 6. Hệ Thống Đánh Thường (`LMB`), Cơ Chế Phá Giáp (`Poise`) & Pixel Shader Dị Hỏa

### 6.1. Chuỗi Đánh Thường 4 Nhịp (`LMB` Basic Combo — Có Phong Ấn vs. Giải Phong Xích)
Trọng tâm cảm giác chém giết giây-phút-giây của game nằm ở sự tương phản rõ rệt giữa 2 trạng thái cầm **Huyền Trọng Xích** (`RMB`):

| Nhịp Đánh (`LMB`) | Hình Dạng Quét Hitbox | Chế Độ **Phong Ấn (Trọng Áp)** *(`+30% EXP`, `-20% SPD`)* | Chế Độ **Giải Phong (Bùng Nổ)** *(`+25% SPD`, `+15% Crit`)* | Điểm Hồi `QI` / Nhịp |
| :--- | :--- | :--- | :--- | :---: |
| **Nhịp 1: Hoành Tảo** | Quạt ngang phải -> trái `110°`, `48 px` | `90% ATK` (`Wind-up 11f`, đòn nặng đẩy lùi `12 px`) | `85% ATK` (`Wind-up 6f`, vung cực lẹ lướt tiến `8 px`) | `+4 QI` |
| **Nhịp 2: Nghịch Phạt** | Quạt ngang trái -> phải `110°`, `48 px` | `100% ATK` (`Wind-up 11f`, gây `×1.4` sát thương Giáp) | `95% ATK` (`Wind-up 6f`, phóng kèm lưỡi lửa ngắn `24 px`) | `+4 QI` |
| **Nhịp 3: Đột Kích Xích** | Đâm chuôi/mũi xích thẳng `64 × 28 px` | `125% ATK` (`Wind-up 13f`, làm khựng quái trung bình) | `115% ATK` (`Wind-up 7f`, xuyên thấu qua 3 mục tiêu) | `+6 QI` |
| **Nhịp 4: Trọng Áp Bổ Sơn** | Nhảy đập xích tròn `72 × 72 px` | **`190% ATK`** (`Super Armor`, chấn địa làm Chậm `35%`) | **`170% ATK`** (Xoay 2 vòng lửa hất tung nhẹ `0.5s`) | `+10 QI` |

> **Kỹ thuật Hủy Đòn (`Animation Cancel`)**: Ngay khi frame `Active` của Nhịp 4 vừa nổ sát thương, bấm tức thì `Q/E/R` hoặc `Space` để hủy toàn bộ frame `Recovery`, nối liền vào *Bát Cực Băng* hoặc *Diễm Phân Phệ Lãng Xích* tạo sát thương dồn (Burst DPS) cực đại!

### 6.2. Cơ Chế Thanh Bền Bỉ / Giáp Đấu Khí (`Poise & Dou Qi Shield`)
* Mọi Tinh Anh và Boss từ cảnh giới **Đại Đấu Sư** trở lên đều có **Thanh Giáp Đấu Khí (Màu Trắng/Vàng)** nằm dưới thanh Máu:
  * Khi còn Giáp Đấu Khí: Boss có *Super Armor* (không bị hất văng/khựng đòn thường) và giảm `35% sát thương nhận vào`.
  * Khi dùng các Đấu Kỹ Phá Giáp mạnh (*Toái Thạch Chưởng, Bát Cực Băng, Sư Hổ Toái Kim Ngâm, Hoàng Tuyền Chưởng*) đập cạn thanh Giáp về `0`: Boss rơi vào trạng thái **Phá Giáp (`Staggered / Guard Break`) trong `4.0s`** — quỳ gối khựng hoàn toàn, **nhận `×1.50` toàn bộ sát thương** (thời điểm vàng để ném *Phật Nộ Hỏa Liên*!).

### 6.3. Quy Tắc Đổi Màu Hiệu Ứng Đấu Kỹ Tự Động (`Dynamic Pixel Palette Shader`)
Để tiết kiệm công sức vẽ lại Sprite cho người tự làm game nhưng vẫn tạo hiệu ứng thị giác mãn nhãn mỗi khi thu phục Dị Hỏa mới:
* Toàn bộ Sprite vệt chém, sóng lửa, chưởng ấn của 24 Đấu Kỹ được vẽ ở dạng **Grayscale 4 sắc độ gốc** (`#FFFFFF` lõi sáng -> `#CCCCCC` thân -> `#777777` viền trong -> `#333333` khói ngoài).
* Engine áp một **1D Lookup Palette Texture (`4 × 1 px`)** dựa theo **Dị Hỏa Chủ Đạo** đang kích hoạt trong *Phần Quyết*:
  * *Tử Hỏa*: Tím Đậm `#4B0082` -> Tím Hồng `#BA55D3` -> Trắng Tím `#F8F0FF`.
  * *Thanh Liên Địa Tâm Hỏa*: Xanh Ngọc Lục `#006B54` -> Thanh Lam `#00FA9A` -> Trắng Ngọc `#E0FFFF`.
  * *Vẫn Lạc Tâm Viêm*: Cam Trong Suốt `#FF4500` (Alpha `75%` kèm distortion sóng nhiệt) -> Vàng Trắng `#FFFACD`.
  * *Cốt Linh Lãnh Hỏa*: Xám Tro Lạnh `#708090` -> Trắng Băng Sữa `#F0F8FF` -> Lõi Tuyết Tinh `#FFFFFF`.
  * *Tam Thiên Diễm Viêm Hỏa*: Đen Tinh Không `#19002E` -> Tím Ánh Sao `#8A2BE2` -> Hạt Bụi Sao Lấp Lánh.
  * *Tịnh Liên Yêu Hỏa*: Đỏ Hồng Liên `#FF69B4` -> Hồng Phấn Yêu Dị `#FFB6C1` -> Trắng Tinh Khiết `#FFF5EE`.

---

## 7. Ba Chuỗi Combo Thực Chiến Chuẩn Mực (Combat Flow Examples)

1. **Combo Nhập Môn Gia Mã (Chương 1–4 — "Hút Gom Bát Cực Nổ Vách Đá")**:
   * `Q (Hấp Chưởng)` gom 8 tên lính/quái vào sát người -> Đánh thường `LMB × 3` tích Ám Kình -> `E (Bát Cực Băng)` đấm xuyên 65% giáp con Tinh Anh đầu đàn -> `R (Xuy Hỏa Chưởng)` thổi văng cả cụm đập vào tường đá nhận sát thương va chạm kép!
2. **Combo Trung Kỳ Già Nam & Trung Châu (Chương 5–8 — "Song Thân Lôi Hỏa Giao Xích")**:
   * Mở `C (Thiên Hỏa Tam Huyền Biến)` + tháo Phong Ấn Trọng Xích -> Gọi `Q (Tam Thiên Lôi Huyễn Thân)` -> `Space (Tam Thiên Lôi Động)` lướt ra sau lưng Boss -> Bản thể và Phân thân cùng bổ `E (Diễm Phân Phệ Lãng Xích)` kẹp chữ X -> Gầm `R (Sư Hổ Toái Kim Ngâm)` choáng `1.8s` -> Thả `F (Tam Sắc Phật Nộ Hỏa Liên)` ngay giữa đầu Boss!
3. **Combo Đỉnh Phong Quyết Chiến Hồn Tộc (Chương 10–11 — "Yêu Trận Luân Hồi Trảm Đế")**:
   * Bật `C (Đế Cảnh Linh Hồn Pháp Tướng)` -> Trải `Q (Tịnh Liên Yêu Trận)` giam cứng Boss -> Gầm `E (Hoàng Tuyền Thiên Nộ)` vỡ thần hồn choáng `3.0s` + khóa hồi máu bằng *Hoàng Tuyền Chỉ* -> Giáng `R (Đại Thiên Tạo Hóa Chưởng / Ngũ Ấn Tụ Thiên)` hút vào tâm -> Tung `F (Phật Nộ Luân Hồi / Dị Hỏa Hằng Cổ Xích)` kết liễu mãn nhãn!
