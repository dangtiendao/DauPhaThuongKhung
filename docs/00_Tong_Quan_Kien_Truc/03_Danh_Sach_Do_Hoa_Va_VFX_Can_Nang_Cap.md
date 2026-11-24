# SỔ THEO DÕI CHẤT LƯỢNG ĐỒ HỌA & VFX CẦN NÂNG CẤP (ART & VFX QUALITY DEBT)

> **Cập nhật lần cuối**: 24/11/2026 (tại mốc `v0.7.0` — Chương 01 đến Chương 08)
> **Mục đích**: Ghi nhận minh bạch toàn bộ **ảnh sprite, NPC, tileset, icon, quái thường, prop và hiệu ứng VFX/Shader** hiện chưa đạt chất lượng phát hành cuối cùng (do lỗi quá tải model tạo ảnh `503 MODEL_CAPACITY_EXHAUSTED`, tái sử dụng sprite cũ, placeholder từ `v0.1`, hoặc giới hạn VFX vẽ bằng hình học cơ bản).
> **Nguyên tắc thay nóng**: Mọi file ảnh trong danh sách dưới đây đã được gắn đường dẫn chuẩn trong JSON/GDScript — khi tạo lại ảnh mới đúng kích thước cột **"Kích thước chuẩn"** và ghi đè file cũ rồi chạy `--import --quit`, toàn bộ game sẽ tự động nhận ảnh mới mà **không cần sửa code hay JSON**.

---

## Tổng Quan Nhanh Theo Mức Ưu Tiên

| Mức ưu tiên | Nhóm tài nguyên | Số lượng | Nguyên nhân gốc |
| :---: | :--- | :---: | :--- |
| **P0 — Cao nhất** | Đồ họa **Chương 08** (7 Boss 8f + 7 chân dung + 7 NPC + 5 Tileset + 5 Icon) | **31 file PNG** | Model `gemini-3.1-flash-image` quá tải `503` — tạm sinh bằng Python pixel-art hình khối cơ bản |
| **P1 — Cao** | **10 file Ch.06–07** còn sót chưa kịp thay AI ở đợt `v0.6.3` (4 NPC + 3 Tileset + 3 Icon) | **10 file PNG** | Model `gemini-3.1-flash-image` hết capacity `503` giữa đợt `v0.6.3` (tạm dùng bản palette-crafted) |
| **P2 — Trung bình** | **VFX, Shader & Hiệu Ứng Thị Giác** (`SkillVfxBurst`, Cánh Đấu Khí, Texture VFX `64×64`, Bloom) | **6 hạng mục VFX** | Hiện dùng vẽ vector Canvas2D (`draw_arc`/`draw_polygon`) và texture `64×64` sơ khai, chưa có shader dissolve/distortion/bloom |
| **P3 — Bổ sung Polish** | **Quái thường tái sử dụng sprite, Pickup sơ khai (`< 210B`), Prop & Vũ khí đeo lưng** | **3 Pickup + 38 Mob + Prop/Vũ khí** | Tái sử dụng sprite cũ Ch.01–03 & ảnh placeholder từ giai đoạn prototype `v0.1` |

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

## P2 — Hạn Chế Về VFX, Shader & Hiệu Ứng Thị Giác

> **Nguyên nhân**: Toàn bộ VFX hiện ưu tiên độ mượt `60–144 FPS` bằng `Canvas2D` (`draw_arc`, `draw_line`, `draw_colored_polygon`) kết hợp `CPUParticles2D` trên `gl_compatibility`, nên khi lên các đại chiêu bậc Đấu Hoàng / Đấu Tông (Ch.07–08) vẫn mang cảm giác **đường nét vector phẳng**, thiếu chiều sâu texture/shader.

* [ ] **VFX-01 — Texture VFX lõi sơ khai (`64×64`)**:
  * Vị trí: `assets/sprites/vfx/slash_arc.png` (`64×64`, `2.080 bytes`) & `assets/sprites/vfx/fire_lotus.png` (`64×64`, `2.663 bytes`).
  * Vấn đề: Độ phân giải thấp từ `v0.1`, ít chi tiết cánh sen/lưỡi lửa khi phóng to ở tuyệt kỹ `[F] Tứ Sắc Hủy Diệt Hỏa Liên`.
  * Hướng nâng cấp: Vẽ lại `128×128` (hoặc flipbook 4–8 frame) kết hợp `di_hoa_palette.gdshader` có biến đổi đa sắc theo số lượng Dị Hỏa dung hợp (2/3/4 màu).
* [ ] **VFX-02 — 6 Mode `SkillVfxBurst` Ch.08 & 3 Mode Ch.07 thuần hình học phẳng**:
  * Vị trí: `scripts/entities/skill_vfx_burst.gd` (`space_lock`, `emperor_five_seals`, `flame_buff_tier3`, `soul_shock_palm`, `thunder_clone`, `thien_yeu_khoi_assist`, `ocean_seal`, `dia_yeu_khoi_assist`).
  * Vấn đề: Dùng `draw_polyline`/`draw_arc`/`draw_circle` thuần (ví dụ `emperor_five_seals` vẽ 5 hình vuông đơn giản xoay tròn; `soul_shock_palm` vẽ 5 đoạn thẳng làm ngón tay).
  * Hướng nâng cấp: Bổ sung **Shader biến dạng không gian (screen-space ripple/refraction)** cho `space_lock` & `fire_lotus_ult`, **Noise-Dissolve Shader** cho cột lửa/sét, và **sprite rune/ấn chữ cổ** cho `emperor_five_seals` & `ocean_seal`.
* [ ] **VFX-03 — Cánh Đấu Khí Hóa Dực & Sóng Đạp Hư Không vẽ bằng tam giác đa giác**:
  * Vị trí: `scripts/entities/player_controller.gd` (`_draw()`).
  * Vấn đề: Đôi cánh Đấu Vương/Đấu Hoàng/Đấu Tông hiện là đa giác 5 đỉnh phẳng (`draw_colored_polygon`), chưa có kết cấu lông vũ năng lượng hay đuôi lửa mờ dần.
  * Hướng nâng cấp: Tạo spritesheet cánh 4–6 frame (`wing_flame_anim.png`) + additive shader nhuộm theo màu Dị Hỏa đang vận chuyển.
* [ ] **VFX-04 — Ngũ Luân Ly Hỏa Pháp & Hào Quang Đồng Hành còn đơn điệu**:
  * Vị trí: `scripts/entities/companion_controller.gd` (`_draw()`).
  * Vấn đề: 5 vòng lửa của Thiên Hỏa Tôn Giả hiện vẽ bằng 5 `draw_arc` nhỏ; các đạn năng lượng đồng hành (`active_bolts`) chỉ là 3 hình tròn đồng tâm.
  * Hướng nâng cấp: Thêm vệt đuôi (`Line2D` additive trail) cho đạn đồng hành và sprite/shader lửa xoay sống động cho 5 vòng lửa.
* [ ] **VFX-05 — Thiếu Bloom / Glow Nhẹ Toàn Cảnh (`WorldEnvironment`)**:
  * Vị trí: `scenes/main_prototype.tscn`.
  * Vấn đề: Chưa có lớp Glow nhẹ phân tầng (chỉ glow ngưỡng sáng cao của Dị Hỏa, Lôi Điện, Đan Lôi) nên cảnh chiến đấu Đấu Tông/Tinh Vực chưa đạt hiệu ứng phát sáng điện ảnh.
* [ ] **VFX-06 — Chưa có Ngũ Sắc Đan Lôi đánh trực tiếp xuống bản đồ**:
  * Vị trí: `scripts/systems/world_stage_manager.gd` & `scripts/ui/panels/panel_alchemy.gd`.
  * Vấn đề: Độ Ngũ Sắc Đan Lôi ở Chung Kết Đan Hội (Ch.08) hiện chủ yếu qua hội thoại & chữ nổi, chưa có cắt cảnh thiên lôi 5 màu giáng xuống thực tế trên bản đồ Thánh Đan Thành.

---

## P3 — Quái Thường Tái Sử Dụng Sprite, Pickup Sơ Khai & Prop

* [ ] **P3.1 — 3 Vật Phẩm Nhặt Rơi (`pickups/`) quá nhỏ/sơ khai (`< 210 bytes` từ `v0.1`)**:
  * `assets/sprites/pickups/herb_item.png` (`115 bytes`)
  * `assets/sprites/pickups/monster_core.png` (`118 bytes` — đang dùng làm cả icon đấu giá & Ma Hạch Cấp 1–7!)
  * `assets/sprites/pickups/qi_orb.png` (`204 bytes`)
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
3. **Đợt C (16 file — Bối cảnh & UI sắc nét)**: Thay **8 Tileset (`128×128`)** Ch.06–08 + **8 Icon Đấu Kỹ (`56×56`)** Ch.06–08 + **3 Pickup (`pickups/`)**.
4. **Đợt D (VFX 2.0)**: Nâng cấp **VFX-01 → VFX-06** (flipbook `fire_lotus`/`slash_arc`, shader distortion `space_lock`, cánh Đấu Khí dạng sprite-shader, `WorldEnvironment` Glow nhẹ).
