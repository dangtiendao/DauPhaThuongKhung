# SỔ THEO DÕI CHẤT LƯỢNG ĐỒ HỌA & VFX CẦN NÂNG CẤP (ART & VFX QUALITY DEBT)

> **Cập nhật lần cuối**: 25/11/2026 (tại mốc `v0.8.0` — **HOÀN TẤT 36/36 ASSET AI 32-BIT HD CHƯƠNG 09 [0 NỢ ART!]** · Đạt tròn **56/56 = 100% True 8-Frame AI** toàn dự án [8 Player + 48 Boss]!)
> **Mục đích**: Ghi nhận minh bạch toàn bộ **ảnh sprite, NPC, tileset, icon, quái thường, prop và hiệu ứng VFX/Shader** của dự án, đối chiếu trạng thái nâng cấp theo mức ưu tiên.
> **Nguyên tắc thay nóng**: Mọi file ảnh trong danh sách dưới đây đã được gắn đường dẫn chuẩn trong JSON/GDScript — khi ghi đè ảnh mới đúng kích thước cột **"Kích thước chuẩn"** rồi chạy `--import --quit`, toàn bộ game sẽ tự động nhận ảnh mới mà **không cần sửa code hay JSON**.

---

## Tổng Quan Nhanh Theo Mức Ưu Tiên

| Mức ưu tiên | Nhóm tài nguyên | Số lượng | Trạng thái |
| :---: | :--- | :---: | :--- |
| **Ch.09 (`v0.8.0`)** | Đồ họa **Chương 09** (7 Boss 8f + 7 chân dung + 8 NPC + 3 Mob mới + 7 Tileset + 4 Icon) | **✅ 36/36 Đã xong (`v0.8.0`)** | Vẽ mới 100% AI 32-bit HD Pixel Art (0 nợ Art!, `semi_alpha = 0`, 56/56 True 8-Frame AI) |
| **P0 — Cao nhất** | Đồ họa **Chương 08** (7 Boss 8f + 7 chân dung + 7 NPC + 5 Tileset + 5 Icon) | **✅ 31/31 Đã xong (`v0.7.3`)** | Đã thay mới 100% bằng tranh AI 32-bit HD Pixel Art (True 8-Frame `4×2`, `semi_alpha = 0`, `min_diff` `66.7%–93.5%`) |
| **P1 — Cao** | **10 file Ch.06–07** còn sót ở đợt `v0.6.3` (4 NPC + 3 Tileset + 3 Icon) | **✅ 10/10 Đã xong (`v0.7.3`)** | Đã thay mới 100% bằng tranh AI 32-bit HD Pixel Art đồng bộ chuẩn `v0.6.3` |
| **P2 — Trung bình** | **VFX 2.0, Shader & Hiệu Ứng Thị Giác** (`ScreenFxOverlay`, `space_shockwave`, `vfx_energy_dissolve`, Cánh Hóa Dực, Đồng Hành 2.0, Đan Lôi + 5 VFX Ch.09) | **✅ 6/6 + 5 Ch.09 (`v0.8.0`)** | Hoàn tất trọn gói VFX 2.0 + 5 đại chiêu Ch.09 100% tương thích `gl_compatibility` (60–144 FPS) |
| **P3 — Bổ sung Polish** | **Quái thường tái sử dụng sprite Ch.04–08, Prop & Vũ khí đeo lưng** *(đã xong 3/3 Pickup `32×32` ở `v0.7.1` & 3 Mob Ch.09 mới ở `v0.8.0`)* | **38 Mob cũ + Prop/Vũ khí** | Tùy chọn polish nâng cao (không chặn phát hành Ch.10–11) |

> **Ghi chú đối chứng (Phần ĐÃ ĐẠT CHUẨN AI 32-bit HD Pixel Art — 100% Ch.01–09!)**:
> * `8/8` spritesheet Tiêu Viêm (`v0.6.1`) — True 8-Frame AI sắc nét.
> * **`48/48` Boss Chương 01–09** (`v0.6.2`, `v0.6.3`, `v0.7.3`, **`v0.8.0`**) — **56/56 = 100% True 8-Frame (`4×2`) AI toàn dự án** + **48/48 chân dung Boss AI**.
> * **100% NPC (46/46), Tileset vùng (28/28), Icon Đấu Kỹ (28/28) & 3 Mob mới Ch.09** đạt chuẩn AI 32-bit HD Pixel Art (`0` file P0/P1/Ch.09 còn tồn đọng!).

---

## P0 — Đồ Họa Chương 08 — ✅ ĐÃ HOÀN TẤT 31/31 (`v0.7.3`)

> **Trạng thái**: Đã vẽ mới 100% bằng AI 32-bit HD Pixel Art, chuẩn hóa đúng kích thước gốc, nền trong suốt sạch (`semi_alpha = 0`), kiểm duyệt trực quan từng file và re-import sạch trên Godot 4.7.2 (`1.461/1.461` test PASSED).

### P0.1 — 7 Boss Chương 08 (`4×2` True 8-Frame + 7 Chân Dung — ✅ 14/14 File)
* [x] `assets/sprites/enemies/phi_thien_boss_anim.png` (`624×272`, cell `156×136`, `min_diff=85.5%`) & `phi_thien_boss.png` (`156×136`) — *Thiên Lôi Tử Phí Thiên (Bát Tinh Đấu Tông, đạo bào tím-chàm lôi điện, thương sét)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/enemies/vuong_tran_boss_anim.png` (`624×272`, cell `156×136`, `min_diff=66.7%`) & `vuong_tran_boss.png` (`156×136`) — *Huyết Sát Vương Trần (Hoàng Tuyền Các, giáp đỏ-đen, song huyết đao)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/enemies/phuong_thanh_nhi_boss_anim.png` (`672×320`, cell `168×160`, `min_diff=78.2%`) & `phuong_thanh_nhi_boss.png` (`168×160`) — *Phượng Thanh Nhi (Thiên Yêu Hoàng cánh phượng tím-vàng, thương lôi)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/enemies/bang_ha_thanh_hai_boss_anim.png` (`672×320`, cell `168×160`, `min_diff=86.5%`) & `bang_ha_thanh_hai_boss.png` (`168×160`) — *Cốc Chủ Băng Hà & Thanh Hải Tôn Giả (băng bào + bóng ma xiềng xích Hồn Điện)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/enemies/cuu_long_loi_cuong_boss_anim.png` (`640×264`, cell `160×132`, `min_diff=93.5%`) & `cuu_long_loi_cuong_boss.png` (`160×132`) — *#12 Cửu Long Lôi Cương Hỏa (Ngân Long lửa bạc-lam)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/enemies/mo_cot_lao_nhan_boss_anim.png` (`624×272`, cell `156×136`, `min_diff=76.8%`) & `mo_cot_lao_nhan_boss.png` (`156×136`) — *Mộ Cốt Lão Nhân (trượng đầu lâu, quỷ hỏa tím-đen Hồn Điện)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/enemies/tam_thien_diem_viem_boss_anim.png` (`672×320`, cell `168×160`, `min_diff=77.6%`) & `tam_thien_diem_viem_boss.png` (`168×160`) — *Final Boss #9 Thái Hư Tử Hắc Cự Long (rồng tinh hà tím-đen cánh sao)* — **Hoàn tất AI (`v0.7.3`)**.

### P0.2 — 7 NPC & Đồng Hành #7 Chương 08 (✅ 7/7 File)
* [x] `assets/sprites/npcs/npc_thien_hoa_ton_gia.png` (`104×104`) — **Đồng Hành #7 `[G]`** *Thiên Hỏa Tôn Giả với đủ 5 vòng Ngũ Luân Ly Hỏa* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_han_tuyet.png` (`96×96`) — *Nhị Tiểu Thư Hàn Tuyết (áo lụa xanh ngọc, tóc đen)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_phong_ton_gia.png` (`104×104`) — *Phong Tôn Giả — Phong Nhàn (bào xanh trắng Tinh Vẫn Các, râu bạc)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_duong_chan.png` (`104×104`) — *Cốc Chủ Đường Chấn (giáp bào đỏ-vàng Phần Viêm Cốc)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_huyen_khong_tu.png` (`104×104`) — *Cự Đầu Huyền Không Tử (bạch bào viền vàng kim Đan Tháp)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_tao_dinh.png` (`96×96`) — *Yêu Nữ Tào Dĩnh (váy tím-hồng Đan Vực, hồn hỏa)* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_hung_chien.png` (`104×104`) — *Viễn Cổ Long Hùng Hoàng Hùng Chiến (chiến sĩ lông vàng đồng khổng lồ)* — **Hoàn tất AI (`v0.7.3`)**.

### P0.3 — 5 Tileset Vùng Seamless Chương 08 (`128×128` — ✅ 5/5 File)
* [x] `assets/sprites/tiles/bac_vuc_storm_slate.png` (`128×128`) — Nền đá xám bão cát Bắc Vực — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/tiles/thien_son_blood_pool.png` (`128×128`) — Đá đen núi lửa nứt mạch huyết nham Thiên Sơn Huyết Đàm — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/tiles/lac_than_frost_poison.png` (`128×128`) — Băng thạch lam xen vết nứt độc tím Lạc Thần Giản — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/tiles/thanh_dan_white_marble.png` (`128×128`) — Cẩm thạch trắng khảm chỉ vàng Thánh Đan Thành — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/tiles/tinh_vuc_starfield.png` (`128×128`) — Sàn tinh hà tím thẫm Ngân Hà Tinh Vực — **Hoàn tất AI (`v0.7.3`)**.

### P0.4 — 5 Icon Đấu Kỹ Chương 08 (`56×56` — ✅ 5/5 File)
* [x] `assets/sprites/icons/skill_khong_gian_phong_toa.png` (`56×56`) — *Không Gian Phong Tỏa* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/icons/skill_co_de_an.png` (`56×56`) — *Đế Ấn Quyết — Cổ Đế Ấn* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/icons/skill_tam_huyen_tam_bien.png` (`56×56`) — *Thiên Hỏa Tam Huyền Biến — Tam Biến* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/icons/skill_kinh_hon_chuong.png` (`56×56`) — *Hồn Kỹ: Kinh Hồn Chưởng* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/icons/skill_tam_thien_loi_huyen_than.png` (`56×56`) — *Tam Thiên Lôi Huyễn Thân* — **Hoàn tất AI (`v0.7.3`)**.

---

## P1 — 10 File Ch.06–07 — ✅ ĐÃ HOÀN TẤT 10/10 (`v0.7.3`)

> **Trạng thái**: Đã thay thế 100% bản palette-crafted cũ bằng tranh vẽ AI 32-bit HD Pixel Art đồng bộ chuẩn `v0.6.3`.

### P1.1 — 4 NPC Ch.06–07 (✅ 4/4 File)
* [x] `assets/sprites/npcs/npc_tu_nghien.png` (`96×96`) — Đồng Hành #5 `[G]` Tử Nghiên — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_dia_yeu_khoi.png` (`104×104`) — Đồng Hành #6 `[G]` & `[T]` Địa Yêu Khôi / Chuẩn Thiên Yêu Khôi — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_lam_tu_nhai.png` (`104×104`) — Lâm Tu Nhai (Nội Viện Già Nam) — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/npcs/npc_mac_thien_hanh.png` (`96×96`) — Tông Chủ Mạc Thiên Hành (Hắc Hoàng Tông) — **Hoàn tất AI (`v0.7.3`)**.

### P1.2 — 3 Tileset Vùng Ch.06–07 (`128×128` — ✅ 3/3 File)
* [x] `assets/sprites/tiles/thien_phan_magma.png` (`128×128`) — Nền dung nham Đáy Tháp Thiên Phần — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/tiles/xuat_van_poison_marsh.png` (`128×128`) — Đầm lầy độc tím Xuất Vân Đế Quốc — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/tiles/thien_nhai_wormhole.png` (`128×128`) — Sàn Không Gian Trùng Động Thiên Nhai Thành — **Hoàn tất AI (`v0.7.3`)**.

### P1.3 — 3 Icon Đấu Kỹ Ch.06–07 (`56×56` — ✅ 3/3 File)
* [x] `assets/sprites/icons/skill_luu_ly_lien_tam.png` (`56×56`) — *Lưu Ly Liên Tâm Ấn* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/icons/skill_phien_hai_an.png` (`56×56`) — *Đế Ấn Quyết — Phiên Hải Ấn* — **Hoàn tất AI (`v0.7.3`)**.
* [x] `assets/sprites/icons/skill_tam_huyen_nhi_bien.png` (`56×56`) — *Thiên Hỏa Tam Huyền Biến — Nhị Biến* — **Hoàn tất AI (`v0.7.3`)**.

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

## Tiến Độ Hoàn Thiện Trả Nợ Đồ Họa (P0 + P1 + P2)

1. ~~**Đợt A (14 file — 7 Boss Ch.08 True 8-Frame + 7 Chân Dung)**~~: ✅ **ĐÃ HOÀN TẤT ở `v0.7.3`** — Chốt trọn **49/49 = 100% True 8-Frame AI** toàn dự án!
2. ~~**Đợt B (11 file — 11 NPC Ch.06–08 gồm Tử Nghiên, Địa Yêu Khôi, Thiên Hỏa Tôn Giả...)**~~: ✅ **ĐÃ HOÀN TẤT ở `v0.7.3`**.
3. ~~**Đợt C (16 file — 8 Tileset `128×128` & 8 Icon Đấu Kỹ `56×56` Ch.06–08)**~~: ✅ **ĐÃ HOÀN TẤT ở `v0.7.3`**. *(3 Pickup `pickups/` đã nâng cấp xong ở `v0.7.1`).*
4. ~~**Đợt D (VFX 2.0)**~~: ✅ **ĐÃ HOÀN TẤT ở `v0.7.1`** (`space_shockwave.gdshader`, `vfx_energy_dissolve.gdshader`, `ScreenFxOverlay`, Cánh Hóa Dực sprite-shader, `128×128` VFX textures, Đồng Hành 2.0 & Ngũ Sắc Đan Lôi giáng thực tế).
5. **Tùy chọn Polish P3 (không chặn Ch.09–11)**: Chỉ còn quái thường tái sử dụng sprite cũ & biến thể vũ khí/prop (P3.2 & P3.3).
