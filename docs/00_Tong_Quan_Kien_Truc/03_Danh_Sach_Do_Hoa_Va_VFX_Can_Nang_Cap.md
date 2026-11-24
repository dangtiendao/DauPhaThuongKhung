# SỔ THEO DÕI CHẤT LƯỢNG ĐỒ HỌA & VFX CẦN NÂNG CẤP (ART & VFX QUALITY DEBT)

> **Cập nhật lần cuối**: 24/11/2026 (tại mốc `v0.7.1` — Đã chốt trọn bộ **VFX 2.0 (P2)** & **3 Pickup HD `32×32` (P3.1)**)
> **Mục đích**: Ghi nhận minh bạch toàn bộ **ảnh sprite, NPC, tileset, icon, quái thường, prop và hiệu ứng VFX/Shader** hiện chưa đạt chất lượng phát hành cuối cùng (do lỗi quá tải model tạo ảnh `503 MODEL_CAPACITY_EXHAUSTED`, tái sử dụng sprite cũ, placeholder từ `v0.1`, hoặc giới hạn VFX vẽ bằng hình học cơ bản).
> **Nguyên tắc thay nóng**: Mọi file ảnh trong danh sách dưới đây đã được gắn đường dẫn chuẩn trong JSON/GDScript — khi tạo lại ảnh mới đúng kích thước cột **"Kích thước chuẩn"** và ghi đè file cũ rồi chạy `--import --quit`, toàn bộ game sẽ tự động nhận ảnh mới mà **không cần sửa code hay JSON**.

---

## Tổng Quan Nhanh Theo Mức Ưu Tiên

| Mức ưu tiên | Nhóm tài nguyên | Số lượng | Nguyên nhân gốc |
| :---: | :--- | :---: | :--- |
| **P0 — Cao nhất** | Đồ họa **Chương 08** (7 Boss 8f + 7 chân dung + 7 NPC + 5 Tileset + 5 Icon) | **31 file PNG** | Model `gemini-3.1-flash-image` quá tải `503` — tạm sinh bằng Python pixel-art hình khối cơ bản |
| **P1 — Cao** | **10 file Ch.06–07** còn sót chưa kịp thay AI ở đợt `v0.6.3` (4 NPC + 3 Tileset + 3 Icon) | **10 file PNG** | Model `gemini-3.1-flash-image` hết capacity `503` giữa đợt `v0.6.3` (tạm dùng bản palette-crafted) |
| **P2 — Trung bình** | **VFX 2.0, Shader & Hiệu Ứng Thị Giác** (`ScreenFxOverlay`, `space_shockwave`, `vfx_energy_dissolve`, Cánh Hóa Dực, Đồng Hành 2.0, Đan Lôi) | **✅ 6/6 Đã xong (`v0.7.1`)** | Hoàn tất trọn gói VFX 2.0 100% tương thích `gl_compatibility` (60–144 FPS) |
| **P3 — Bổ sung Polish** | **Quái thường tái sử dụng sprite, Prop & Vũ khí đeo lưng** *(đã xong 3/3 Pickup `32×32` ở `v0.7.1`)* | **38 Mob + Prop/Vũ khí** | Tái sử dụng sprite cũ Ch.01–03 & prop tương tác dùng chung |

> **Ghi chú đối chứng (Phần ĐÃ ĐẠT CHUẨN AI 32-bit HD Pixel Art)**:
> * `8/8` spritesheet Tiêu Viêm (`v0.6.1`) — True 8-Frame AI sắc nét.
> * `34/34` Boss Chương 01–07 (`v0.6.2` & `v0.6.3`) — True 8-Frame (`4×2`) AI sắc nét.
> * `6/16` art Ch.06–07 đã thay AI ở `v0.6.3`: `npc_han_nhan.png`, `npc_thien_doc_nu.png`, `npc_lieu_kinh.png`, `npc_vu_ho_phap.png`, `noi_vien_jade.png`, `skill_dai_liet_phach_quan.png`.

---

## P0 — Đồ Họa Chương 08 Tạm Sinh Thủ Công Do Model AI `503` (31 File)

> **Vấn đề chung**: Toàn bộ 31 file Chương 08 trong đợt `v0.7.0` được tạo bằng script Python thuần (vì `gemini-3.1-flash-image` trả lỗi `HTTP 503 MODEL_CAPACITY_EXHAUSTED`). Dù đạt đúng kích thước, viền `#141020` và 8/8 khung hình khác biệt, nhưng **chi tiết khuôn mặt, nếp y phục, hiệu ứng vảy rồng, ánh sáng và độ sâu pixel kém xa chuẩn 32-bit HD AI của Chương 01–07**.

### P0.1 — 7 Boss Chương 08 (`4×2` True 8-Frame + 7 Chân Dung — 14 File)
* [ ] `assets/sprites/enemies/phi_thien_boss_anim.png` (`624×272`, cell `156×136`) & `phi_thien_boss.png` (`156×136`) — *Thiên Lôi Tử Phí Thiên (Bát Tinh Đấu Tông, đạo bào tím-chàm lôi điện, thương sét)* — **Nguyên nhân**: Model `503` (procedural hình khối, ~8.8KB / 1.1KB).
* [ ] `assets/sprites/enemies/vuong_tran_boss_anim.png` (`624×272`, cell `156×136`) & `vuong_tran_boss.png` (`156×136`) — *Huyết Sát Vương Trần (Hoàng Tuyền Các, giáp đỏ-đen, song huyết đao)* — **Nguyên nhân**: Model `503` (procedural, ~9.3KB / 1.1KB).
* [ ] `assets/sprites/enemies/phuong_thanh_nhi_boss_anim.png` (`672×320`, cell `168×160`) & `phuong_thanh_nhi_boss.png` (`168×160`) — *Phượng Thanh Nhi (Thiên Yêu Hoàng cánh phượng tím-vàng, thương lôi)* — **Nguyên nhân**: Model `503` (procedural, cánh & mặt còn thô, ~11.5KB / 1.4KB).
* [ ] `assets/sprites/enemies/bang_ha_thanh_hai_boss_anim.png` (`672×320`, cell `168×160`) & `bang_ha_thanh_hai_boss.png` (`168×160`) — *Cốc Chủ Băng Hà & Thanh Hải Tôn Giả (băng bào + bóng ma xiềng xích Hồn Điện)* — **Nguyên nhân**: Model `503` (procedural, bóng Thanh Hải quá nhỏ/đơn giản, ~10.2KB / 1.2KB).
* [ ] `assets/sprites/enemies/cuu_long_loi_cuong_boss_anim.png` (`640×264`, cell `160×132`) & `cuu_long_loi_cuong_boss.png` (`160×132`) — *#12 Cửu Long Lôi Cương Hỏa (Ngân Long lửa bạc-lam)* — **Nguyên nhân**: Model `503` (procedural thân rồng dạng chuỗi hình tròn, thiếu vảy & sừng tinh xảo, ~9.5KB / 1.2KB).
* [ ] `assets/sprites/enemies/mo_cot_lao_nhan_boss_anim.png` (`624×272`, cell `156×136`) & `mo_cot_lao_nhan_boss.png` (`156×136`) — *Mộ Cốt Lão Nhân (trượng đầu lâu, quỷ hỏa tím-đen Hồn Điện)* — **Nguyên nhân**: Model `503` (procedural, ~9.9KB / 1.2KB).
* [ ] `assets/sprites/enemies/tam_thien_diem_viem_boss_anim.png` (`672×320`, cell `168×160`) & `tam_thien_diem_viem_boss.png` (`168×160`) — *Final Boss #9 Thái Hư Tử Hắc Cự Long (rồng tinh hà tím-đen cánh sao)* — **Nguyên nhân**: Model `503` (procedural thân chuỗi chấm tròn, chưa xứng tầm Final Boss Ch.08, ~13.0KB / 1.6KB).

### P0.2 — 7 NPC & Đồng Hành #7 Chương 08 (7 File — ~0.8–1.0KB/file)
* [ ] `assets/sprites/npcs/npc_thien_hoa_ton_gia.png` (`104×104`) — **Ưu tiên cao nhất trong nhóm NPC** vì là **Đồng Hành #7 `[G]`** xuất hiện liên tục cạnh Tiêu Viêm (*Thiên Hỏa Tôn Giả với Ngũ Luân Ly Hỏa*).
* [ ] `assets/sprites/npcs/npc_han_tuyet.png` (`96×96`) — *Nhị Tiểu Thư Hàn Tuyết (áo lụa xanh ngọc, tóc đen)*.
* [ ] `assets/sprites/npcs/npc_phong_ton_gia.png` (`104×104`) — *Phong Tôn Giả — Phong Nhàn (bào xanh trắng Tinh Vẫn Các, râu bạc)*.
* [ ] `assets/sprites/npcs/npc_duong_chan.png` (`104×104`) — *Cốc Chủ Đường Chấn (giáp bào đỏ-vàng Phần Viêm Cốc)*.
* [ ] `assets/sprites/npcs/npc_huyen_khong_tu.png` (`104×104`) — *Cự Đầu Huyền Không Tử (bạch bào viền vàng kim Đan Tháp)*.
* [ ] `assets/sprites/npcs/npc_tao_dinh.png` (`96×96`) — *Yêu Nữ Tào Dĩnh (váy tím-hồng Đan Vực)*.
* [ ] `assets/sprites/npcs/npc_hung_chien.png` (`104×104`) — *Viễn Cổ Long Hùng Hoàng Hùng Chiến (chiến sĩ lông vàng đồng khổng lồ)*.

### P0.3 — 5 Tileset Vùng Seamless Chương 08 (`128×128`, ~1.6–1.7KB/file)
* [ ] `assets/sprites/tiles/bac_vuc_storm_slate.png` (`128×128`) — Nền đá xám bão cát Bắc Vực (hiện là gạch đơn giản ít chiều sâu).
* [ ] `assets/sprites/tiles/thien_son_blood_pool.png` (`128×128`) — Đá đen núi lửa nứt mạch huyết nham Thiên Sơn Huyết Đàm.
* [ ] `assets/sprites/tiles/lac_than_frost_poison.png` (`128×128`) — Băng thạch lam xen vết nứt độc tím Lạc Thần Giản.
* [ ] `assets/sprites/tiles/thanh_dan_white_marble.png` (`128×128`) — Cẩm thạch trắng khảm chỉ vàng Thánh Đan Thành.
* [ ] `assets/sprites/tiles/tinh_vuc_starfield.png` (`128×128`) — Sàn tinh hà tím thẫm Ngân Hà Tinh Vực.

### P0.4 — 5 Icon Đấu Kỹ Chương 08 (`56×56`, ~269–338 bytes/file)
* [ ] `assets/sprites/icons/skill_khong_gian_phong_toa.png` (`56×56`) — *Không Gian Phong Tỏa* (hiện là hình bát giác 2D đơn giản).
* [ ] `assets/sprites/icons/skill_co_de_an.png` (`56×56`) — *Đế Ấn Quyết — Cổ Đế Ấn* (hiện là 5 ô vuông ghép đơn giản).
* [ ] `assets/sprites/icons/skill_tam_huyen_tam_bien.png` (`56×56`) — *Thiên Hỏa Tam Huyền Biến — Tam Biến* (hiện là 3 tam giác lửa phẳng).
* [ ] `assets/sprites/icons/skill_kinh_hon_chuong.png` (`56×56`) — *Hồn Kỹ: Kinh Hồn Chưởng* (hiện là bàn tay nét thẳng).
* [ ] `assets/sprites/icons/skill_tam_thien_loi_huyen_than.png` (`56×56`) — *Tam Thiên Lôi Huyễn Thân* (hiện là 2 bóng hình tam giác).

---

## P1 — 10 File Palette-Crafted Ch.06–07 Còn Sót Lại Do Model AI `503` (Đợt `v0.6.3`)

> **Vấn đề**: Chất lượng khá hơn bản Python Ch.08 nhưng vẫn là bản tổng hợp palette-crafted (không phải tranh vẽ AI 32-bit đồng bộ như `npc_thien_doc_nu.png` hay `noi_vien_jade.png`).

### P1.1 — 4 NPC Ch.06–07 (Đặc biệt ưu tiên 2 Đồng Hành `[G]`)
* [ ] `assets/sprites/npcs/npc_tu_nghien.png` (`96×96`) — **Ưu tiên cao**: Đồng Hành #5 `[G]` Tử Nghiên (xuất hiện thường xuyên).
* [ ] `assets/sprites/npcs/npc_dia_yeu_khoi.png` (`104×104`) — **Ưu tiên cao**: Đồng Hành #6 `[G]` & icon `[T]` Địa Yêu Khôi / Chuẩn Thiên Yêu Khôi.
* [ ] `assets/sprites/npcs/npc_lam_tu_nhai.png` (`104×104`) — Lâm Tu Nhai (Nội Viện Già Nam).
* [ ] `assets/sprites/npcs/npc_mac_thien_hanh.png` (`96×96`) — Tông Chủ Mạc Thiên Hành (Hắc Hoàng Tông).

### P1.2 — 3 Tileset Vùng Ch.06–07 (`128×128`)
* [ ] `assets/sprites/tiles/thien_phan_magma.png` (`128×128`) — Nền dung nham Đáy Tháp Thiên Phần.
* [ ] `assets/sprites/tiles/xuat_van_poison_marsh.png` (`128×128`) — Đầm lầy độc tím Xuất Vân Đế Quốc.
* [ ] `assets/sprites/tiles/thien_nhai_wormhole.png` (`128×128`) — Sàn Không Gian Trùng Động Thiên Nhai Thành.

### P1.3 — 3 Icon Đấu Kỹ Ch.06–07 (`56×56`)
* [ ] `assets/sprites/icons/skill_luu_ly_lien_tam.png` (`56×56`) — *Lưu Ly Liên Tâm Ấn*.
* [ ] `assets/sprites/icons/skill_phien_hai_an.png` (`56×56`) — *Đế Ấn Quyết — Phiên Hải Ấn*.
* [ ] `assets/sprites/icons/skill_tam_huyen_nhi_bien.png` (`56×56`) — *Thiên Hỏa Tam Huyền Biến — Nhị Biến*.

---

## P2 — Hạn Chế Về VFX, Shader & Hiệu Ứng Thị Giác — ✅ ĐÃ HOÀN TẤT 6/6 (`v0.7.1`)

> **Trạng thái**: Đã nâng cấp trọn bộ **VFX 2.0** trong bản `v0.7.1`, giữ 100% tương thích `gl_compatibility` (`OpenGL 3.3.0`) và 60–144 FPS.

* [x] **VFX-01 — Texture VFX lõi nâng cấp HD (`128×128` & `96×128`)** *(Hoàn tất `v0.7.1`)*:
  * Đã vẽ mới `assets/sprites/vfx/fire_lotus.png` (`128×128` hoa sen 16 cánh phát sáng đa tầng), `assets/sprites/vfx/slash_arc.png` (`128×128` trăng khuyết sắc bén) và tạo mới `assets/sprites/vfx/wing_plume.png` (`96×128` cánh lông vũ năng lượng); đồng bộ lại scale hiển thị trong `skill_projectile.gd` & `player_controller.gd`.
* [x] **VFX-02 — Nâng cấp toàn bộ Mode `SkillVfxBurst` Ch.07–08 + Shader Khúc Xạ / Dissolve + Vết Nứt Mặt Đất** *(Hoàn tất `v0.7.1`)*:
  * Tạo 2 shader mới: `assets/shaders/space_shockwave.gdshader` (khúc xạ bẻ cong không gian + tách sắc RGB) và `assets/shaders/vfx_energy_dissolve.gdshader` (fBM flow + noise dissolve + viền cháy nóng).
  * Nâng cấp `scripts/entities/skill_vfx_burst.gd` với **sét phân nhánh đa tầng** (`_draw_fractal_bolt`), **trận đồ cổ tự vòng đôi** (`_draw_ancient_rune_seal`), 2 mode mới `"ground_crater"` (hố nứt cháy sém lưu lại 3s) & `"dan_lei_pillar"`, và đại tu trực quan cho toàn bộ `space_lock`, `emperor_five_seals`, `flame_buff_tier3`, `soul_shock_palm`, `thunder_clone`, `dia_yeu_khoi_assist`, `thien_yeu_khoi_assist`.
* [x] **VFX-03 — Cánh Đấu Khí Hóa Dực dạng Sprite + Shader Năng Lượng** *(Hoàn tất `v0.7.1`)*:
  * Thay hoàn toàn cánh đa giác 5 đỉnh cũ trong `player_controller.gd` bằng đôi `wing_left_sprite` / `wing_right_sprite` sử dụng `wing_plume.png` + `vfx_energy_dissolve.gdshader`, tự động mở rộng kích thước, nhịp vỗ và đổi bảng màu động theo cảnh giới Đấu Vương / Đấu Hoàng / Đấu Tông / Tam Biến & khi Lướt `[Space]`.
* [x] **VFX-04 — Đồng Hành 2.0 (Vệt Đuôi Mượt + Ngũ Luân Ly Hỏa 3D-Tilt) & Cột Ánh Sáng Rơi Đồ** *(Hoàn tất `v0.7.1`)*:
  * Nâng cấp `companion_controller.gd`: mọi đạn năng lượng của cả 7 Đồng Hành có vệt đuôi thuôn phát sáng 8 điểm + nổ tia lửa khi trúng đích; riêng **Thiên Hỏa Tôn Giả** sở hữu 5 vòng **Ngũ Luân Ly Hỏa Pháp** xoay phối cảnh nghiêng 3D sống động.
  * Nâng cấp `loot_pickup.gd`: cột ánh sáng phẩm chất đa tầng thuôn nhọn + hạt sáng bay lên + vòng cổ tự mặt đất cho trang bị & Ma Hạch.
* [x] **VFX-05 — Lớp Hậu Kỳ Toàn Màn Hình `ScreenFxOverlay` (`gl_compatibility` Safe)** *(Hoàn tất `v0.7.1`)*:
  * Tạo `scripts/systems/screen_fx_overlay.gd` (`CanvasLayer` layer 6 nằm dưới `GameHUD` layer 10): Sóng khúc xạ biến dạng không gian thực (bật ở Hỏa Liên, Không Gian Phong Tỏa, Cổ Đế Ấn, Tam Biến, Đan Lôi, Boss Phase 2), chớp sáng Additive Flash, viền đỏ nhịp tim khi HP `< 25%`, và viền ánh sao Ngân Hà tại `ch08_tinh_vuc_phong_an` (tôn trọng cài đặt `shake_scale`).
* [x] **VFX-06 — Ngũ Sắc Đan Lôi Giáng Trực Tiếp Xuống Bản Đồ** *(Hoàn tất `v0.7.1`)*:
  * Nối `EventBus.dan_lei_strike_requested` vào hàng đợi `_dan_lei_queue` sạch bộ nhớ trong `world_stage_manager.gd`: đánh nối tiếp 3–5 cột thiên lôi đa sắc từ bầu trời xuống đất kèm hố nứt, sóng khúc xạ & chớp sáng khi đạt quán quân Đan Hội (`ch08_dan_hoi_champion`), luyện thành Đan Phẩm 7/8 (`alchemy_system.gd`), và đột phá Đấu Tông / hoàn tất Ch.08.

---

## P3 — Quái Thường Tái Sử Dụng Sprite, Pickup Sơ Khai & Prop

* [x] **P3.1 — 3 Vật Phẩm Nhặt Rơi (`pickups/`) nâng cấp lên `32×32` HD Pixel Art** *(Hoàn tất `v0.7.1`)*:
  * `assets/sprites/pickups/herb_item.png` (`32×32` linh dược lá ngọc có viền `#141020`)
  * `assets/sprites/pickups/monster_core.png` (`32×32` ma hạch đa diện lõi sáng tím-hồng)
  * `assets/sprites/pickups/qi_orb.png` (`32×32` tinh cầu đấu khí ngọc lam phát sáng)
* [ ] **P3.2 — Quái Thường Ch.04–08 Tái Sử Dụng Sprite Cũ & Chưa Có Anim Sheet Riêng**:
  * `lang_dau_tinh_anh.png` đang dùng chung cho **7 loại quái** (`Ch.02 → Ch.08`: *Hộ Vệ Mặc Gia, Huyết Y Đao Khách, Đấu Vương Hắc Giác, Ma Viêm Chấp Pháp, Phong Lôi Chấp Sự, Hoàng Tuyền Đao Khách*).
  * `xa_nhan_chien_binh.png` đang dùng chung cho **6 loại quái** (*Chấp Sự Vân Lam, Cường Bảng Tinh Nhuệ, Độc Thi Chiến Binh, Vạn Xà Độc Mãng*).
  * `sa_doc_hat_vuong.png` đang dùng chung cho **5 loại quái** (*Lạc Độc Huyết Ảnh, Huyết Ảnh Chấp Sự, Thanh Mộc Độc Mãng, Huyết Ngạt Độc Sư*).
  * Một số quái thường Ch.07–08 đang mượn ảnh tĩnh Boss cũ (`thach_khoi_boss.png` ×3, `la_hau_boss.png` ×2, `tieu_ninh_boss.png` ×2, `npc_muc_luc.png` ×2).
  * **Hướng nâng cấp**: Vẽ tối thiểu 6–8 mẫu quái vùng đặc trưng mới (*Đệ tử Vân Lam Tông, Độc Sư Xuất Vân, Hắc Y Sứ Hồn Điện, Băng Hà Hộ Pháp, Xích Hỏa Thạch Nhân, Phệ Kim Thử*) kèm 4-frame idle/walk.
* [ ] **P3.3 — Vũ Khí Đeo Lưng & Prop Tương Tác Ch.05–08 Tái Sử Dụng**:
  * `assets/sprites/weapons/huyen_trong_xich.png` (`96×36`) đang dùng chung cho cả 5 cấp Huyền Trọng Xích (từ Phàm Xích Ch.01 tới *Tam Thiên Tinh Viêm Xích* Ch.08) — nên tách biến thể phát sáng theo từng bộ Set.
  * `assets/sprites/props/testing_stele.png` đang dùng làm vật thể tương tác cho *Bia Trắc Hồn*, *Đáy Thiên Sơn Huyết Đàm*, *Bản Nguyên Long Châu #9*, *Lò Rèn Yêu Khôi* — nên bổ sung prop riêng (`blood_pool_altar.png`, `dragon_core_orb.png`, `forge_thunder_pool.png`).

---

## Quy Trình Trả Nợ Đồ Họa Khuyến Nghị Khi Model AI Hết `503`

1. **Đợt A (14 file — Tác động thị giác lớn nhất)**: Thay toàn bộ **7 Boss Ch.08 True 8-Frame (`4×2`) + 7 ảnh chân dung** (P0.1) để đạt tròn **49/49 = 100% True 8-Frame AI** toàn dự án.
2. **Đợt B (11 file — Nhân vật gặp xuyên suốt)**: Thay **2 NPC Đồng Hành P1** (`npc_tu_nghien`, `npc_dia_yeu_khoi`) + **7 NPC Ch.08** (đặc biệt `npc_thien_hoa_ton_gia`) + **2 NPC Ch.06–07** còn lại (`npc_lam_tu_nhai`, `npc_mac_thien_hanh`).
3. **Đợt C (16 file — Bối cảnh & UI sắc nét)**: Thay **8 Tileset (`128×128`)** Ch.06–08 + **8 Icon Đấu Kỹ (`56×56`)** Ch.06–08. *(3 Pickup `pickups/` đã nâng cấp xong ở `v0.7.1`).*
4. ~~**Đợt D (VFX 2.0)**~~: ✅ **ĐÃ HOÀN TẤT ở `v0.7.1`** (`space_shockwave.gdshader`, `vfx_energy_dissolve.gdshader`, `ScreenFxOverlay`, Cánh Hóa Dực sprite-shader, `128×128` VFX textures, Đồng Hành 2.0 & Ngũ Sắc Đan Lôi giáng thực tế).
