#!/usr/bin/env python3
"""
Công cụ Tự Động Chuẩn Hóa, Xóa Rác Biên & Ghép SpriteSheet AI cho Godot 4 (Đấu Phá Thương Khung).
Chạy 100% bằng Python chuẩn (không cần cài Pillow/NumPy)!

Ví dụ sử dụng:
  1) Kiểm tra căn chân & lỗi dính rác biên của một SpriteSheet:
     python tools/normalize_spritesheet.py inspect assets/sprites/player/tieu_viem_attack_unarmed.png --cols 4 --rows 1

  2) Xóa sạch rác cắt biên (bleed) mà giữ nguyên 100% pixel nhân vật:
     python tools/normalize_spritesheet.py clean assets/sprites/player/tieu_viem_attack_unarmed.png -o assets/sprites/player/tieu_viem_attack_unarmed.png --cols 4 --rows 1

  3) Chuẩn hóa ảnh sinh từ AI (tự tách nền, cắt khung, khóa bàn chân, đồng bộ chiều cao, xuất 4/6/8/12/16 frame):
     python tools/normalize_spritesheet.py normalize raw_run.png -o assets/sprites/player/tieu_viem_run.png --cols 4 --rows 2 --cell-w 96 --cell-h 96 --target-h 87 --remove-bg --outline

  4) Ghép nhiều sheet nhỏ (ví dụ 3 ảnh 4 frame -> 1 ảnh lưới 4x3 = 12 frame):
     python tools/normalize_spritesheet.py pack combo1.png combo2.png combo3.png -o tieu_viem_attack_ruler.png --in-cols 4 --in-rows 1 --out-cols 4 --out-rows 3

  5) Trích xuất 1 frame mẫu phóng to làm ảnh Reference gửi cho AI:
     python tools/normalize_spritesheet.py extract-ref assets/sprites/player/tieu_viem_attack_unarmed.png -o ref_tieu_viem.png --cols 4 --frame 0 --scale 5
"""

import argparse
import collections
import math
import os
import struct
import subprocess
import sys
import tempfile
import zlib


# =====================================================================
# BỘ ĐỌC / GHI PNG THUẦN PYTHON (HỖ TRỢ ĐẦY ĐỦ RGBA, RGB, PALETTE, GRAY)
# =====================================================================
def _paeth(a: int, b: int, c: int) -> int:
    p = a + b - c
    pa = abs(p - a)
    pb = abs(p - b)
    pc = abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def load_rgba(path: str):
    """Đọc ảnh (PNG trực tiếp, hoặc JPG/WEBP qua PowerShell System.Drawing trên Windows) -> (w, h, bytearray RGBA)."""
    with open(path, "rb") as f:
        sig = f.read(8)
    if sig != b"\x89PNG\r\n\x1a\n":
        # Chuyển tạm sang PNG bằng System.Drawing (Windows)
        tmp_png = os.path.join(tempfile.gettempdir(), f"norm_conv_{os.getpid()}.png")
        ps = (
            "Add-Type -AssemblyName System.Drawing; "
            f"$b=[System.Drawing.Bitmap]::new('{path.replace(chr(39), chr(39)*2)}'); "
            f"$b.Save('{tmp_png}', [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()"
        )
        subprocess.run(["powershell", "-NoProfile", "-Command", ps], check=True)
        try:
            return load_rgba(tmp_png)
        finally:
            if os.path.exists(tmp_png):
                os.remove(tmp_png)

    with open(path, "rb") as f:
        data = f.read()

    pos = 8
    w = h = bit_depth = color_type = interlace = 0
    idat_parts = []
    palette = []
    trns = b""

    while pos < len(data):
        length = struct.unpack(">I", data[pos : pos + 4])[0]
        ctype = data[pos + 4 : pos + 8]
        chunk = data[pos + 8 : pos + 8 + length]
        pos += 12 + length
        if ctype == b"IHDR":
            w, h, bit_depth, color_type, _comp, _filt, interlace = struct.unpack(">IIBBBBB", chunk)
        elif ctype == b"PLTE":
            palette = [(chunk[i], chunk[i + 1], chunk[i + 2]) for i in range(0, len(chunk), 3)]
        elif ctype == b"tRNS":
            trns = chunk
        elif ctype == b"IDAT":
            idat_parts.append(chunk)
        elif ctype == b"IEND":
            break

    if interlace != 0 or bit_depth not in (8, 16):
        # Fallback sang System.Drawing cho PNG interlace hoặc bit depth đặc biệt
        tmp_png = os.path.join(tempfile.gettempdir(), f"norm_dec_{os.getpid()}.png")
        ps = (
            "Add-Type -AssemblyName System.Drawing; "
            f"$s=[System.Drawing.Bitmap]::new('{path.replace(chr(39), chr(39)*2)}'); "
            "$d=[System.Drawing.Bitmap]::new($s.Width,$s.Height,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb); "
            "$g=[System.Drawing.Graphics]::FromImage($d); $g.DrawImage($s,0,0,$s.Width,$s.Height); $g.Dispose(); $s.Dispose(); "
            f"$d.Save('{tmp_png}', [System.Drawing.Imaging.ImageFormat]::Png); $d.Dispose()"
        )
        subprocess.run(["powershell", "-NoProfile", "-Command", ps], check=True)
        try:
            return load_rgba(tmp_png)
        finally:
            if os.path.exists(tmp_png):
                os.remove(tmp_png)

    raw = zlib.decompress(b"".join(idat_parts))
    channels_map = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}
    ch = channels_map[color_type]
    bpc = bit_depth // 8
    bpp = ch * bpc
    stride = w * bpp

    recon = bytearray(h * stride)
    in_pos = 0
    for y in range(h):
        ftype = raw[in_pos]
        in_pos += 1
        row_start = y * stride
        prev_start = (y - 1) * stride
        if ftype == 0:
            recon[row_start : row_start + stride] = raw[in_pos : in_pos + stride]
        elif ftype == 1:
            for i in range(stride):
                a = recon[row_start + i - bpp] if i >= bpp else 0
                recon[row_start + i] = (raw[in_pos + i] + a) & 0xFF
        elif ftype == 2:
            for i in range(stride):
                b = recon[prev_start + i] if y > 0 else 0
                recon[row_start + i] = (raw[in_pos + i] + b) & 0xFF
        elif ftype == 3:
            for i in range(stride):
                a = recon[row_start + i - bpp] if i >= bpp else 0
                b = recon[prev_start + i] if y > 0 else 0
                recon[row_start + i] = (raw[in_pos + i] + ((a + b) >> 1)) & 0xFF
        elif ftype == 4:
            for i in range(stride):
                a = recon[row_start + i - bpp] if i >= bpp else 0
                b = recon[prev_start + i] if y > 0 else 0
                c = recon[prev_start + i - bpp] if (y > 0 and i >= bpp) else 0
                recon[row_start + i] = (raw[in_pos + i] + _paeth(a, b, c)) & 0xFF
        in_pos += stride

    if color_type == 6 and bit_depth == 8:
        return w, h, recon

    out = bytearray(w * h * 4)
    if color_type == 2 and bit_depth == 8:
        oi = 0
        for i in range(0, len(recon), 3):
            out[oi] = recon[i]
            out[oi + 1] = recon[i + 1]
            out[oi + 2] = recon[i + 2]
            out[oi + 3] = 255
            oi += 4
    elif color_type == 3 and bit_depth == 8:
        oi = 0
        for idx in recon:
            r, g, b = palette[idx] if idx < len(palette) else (0, 0, 0)
            a = trns[idx] if idx < len(trns) else 255
            out[oi] = r
            out[oi + 1] = g
            out[oi + 2] = b
            out[oi + 3] = a
            oi += 4
    elif color_type == 4 and bit_depth == 8:
        oi = 0
        for i in range(0, len(recon), 2):
            v = recon[i]
            out[oi] = v
            out[oi + 1] = v
            out[oi + 2] = v
            out[oi + 3] = recon[i + 1]
            oi += 4
    elif color_type == 0 and bit_depth == 8:
        oi = 0
        for v in recon:
            out[oi] = v
            out[oi + 1] = v
            out[oi + 2] = v
            out[oi + 3] = 255
            oi += 4
    elif bit_depth == 16:
        oi = 0
        step = ch * 2
        for i in range(0, len(recon), step):
            if color_type == 6:
                out[oi] = recon[i]
                out[oi + 1] = recon[i + 2]
                out[oi + 2] = recon[i + 4]
                out[oi + 3] = recon[i + 6]
            elif color_type == 2:
                out[oi] = recon[i]
                out[oi + 1] = recon[i + 2]
                out[oi + 2] = recon[i + 4]
                out[oi + 3] = 255
            else:
                v = recon[i]
                out[oi] = v
                out[oi + 1] = v
                out[oi + 2] = v
                out[oi + 3] = recon[i + 2] if color_type == 4 else 255
            oi += 4
    return w, h, out


def save_rgba(path: str, w: int, h: int, buf: bytearray) -> None:
    def _chunk(ctype: bytes, payload: bytes) -> bytes:
        crc = zlib.crc32(ctype + payload) & 0xFFFFFFFF
        return struct.pack(">I", len(payload)) + ctype + payload + struct.pack(">I", crc)

    raw = bytearray(h * (w * 4 + 1))
    stride = w * 4
    for y in range(h):
        raw[y * (stride + 1)] = 0
        raw[y * (stride + 1) + 1 : (y + 1) * (stride + 1)] = buf[y * stride : (y + 1) * stride]

    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + _chunk(b"IHDR", ihdr) + _chunk(b"IDAT", zlib.compress(bytes(raw), 6)) + _chunk(b"IEND", b"")
    parent = os.path.dirname(os.path.abspath(path))
    if parent:
        os.makedirs(parent, exist_ok=True)
    with open(path, "wb") as f:
        f.write(png)


def crop_rgba(buf: bytearray, w: int, x0: int, y0: int, cw: int, ch: int) -> bytearray:
    out = bytearray(cw * ch * 4)
    for y in range(ch):
        src = ((y0 + y) * w + x0) * 4
        dst = y * cw * 4
        out[dst : dst + cw * 4] = buf[src : src + cw * 4]
    return out


def blit_rgba(dst: bytearray, dw: int, dh: int, src: bytearray, sw: int, sh: int, ox: int, oy: int) -> None:
    for y in range(sh):
        dy = oy + y
        if dy < 0 or dy >= dh:
            continue
        for x in range(sw):
            dx = ox + x
            if dx < 0 or dx >= dw:
                continue
            si = (y * sw + x) * 4
            if src[si + 3] == 0:
                continue
            di = (dy * dw + dx) * 4
            dst[di] = src[si]
            dst[di + 1] = src[si + 1]
            dst[di + 2] = src[si + 2]
            dst[di + 3] = src[si + 3]


# =====================================================================
# XỬ LÝ TÁCH NỀN, XÓA RÁC BIÊN, ĐO CHÂN & RESAMPLE PIXEL ART
# =====================================================================
def _color_dist(r1: int, g1: int, b1: int, r2: int, g2: int, b2: int) -> float:
    return math.sqrt((r1 - r2) ** 2 + (g1 - g2) ** 2 + (b1 - b2) ** 2)


def remove_solid_bg(buf: bytearray, w: int, h: int, tol: float = 42.0, remove_interior_holes: bool = True) -> None:
    """Tách nền đồng nhất bằng Flood-Fill từ viền + khử lỗ nền kín giữa 2 chân/tay + khử viền sáng (defringe)."""
    corners = [
        (0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1),
        (w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2)
    ]
    samples = []
    for cx, cy in corners:
        idx = (cy * w + cx) * 4
        if buf[idx + 3] > 200:
            samples.append((buf[idx], buf[idx + 1], buf[idx + 2]))
    if not samples:
        return

    # Lấy màu nền phổ biến nhất quanh mép ảnh
    bg_r = sorted(s[0] for s in samples)[len(samples) // 2]
    bg_g = sorted(s[1] for s in samples)[len(samples) // 2]
    bg_b = sorted(s[2] for s in samples)[len(samples) // 2]

    visited = bytearray(w * h)
    q = collections.deque()

    def _matches_bg(x: int, y: int, t: float) -> bool:
        i = (y * w + x) * 4
        if buf[i + 3] <= 12:
            return True
        return _color_dist(buf[i], buf[i + 1], buf[i + 2], bg_r, bg_g, bg_b) <= t

    for x in range(w):
        for y in (0, h - 1):
            if _matches_bg(x, y, tol):
                visited[y * w + x] = 1
                q.append((x, y))
    for y in range(h):
        for x in (0, w - 1):
            if not visited[y * w + x] and _matches_bg(x, y, tol):
                visited[y * w + x] = 1
                q.append((x, y))

    while q:
        x, y = q.popleft()
        i = (y * w + x) * 4
        buf[i + 3] = 0
        for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if 0 <= nx < w and 0 <= ny < h:
                ni = ny * w + nx
                if not visited[ni] and _matches_bg(nx, ny, tol):
                    visited[ni] = 1
                    q.append((nx, ny))

    # Tách thêm các mảng nền kín bên trong (ví dụ khe sáng giữa 2 chân, khe dưới cánh tay) nếu khớp màu nền rất sát
    if remove_interior_holes:
        inner_tol = tol * 0.55
        for y in range(1, h - 1):
            for x in range(1, w - 1):
                i = (y * w + x) * 4
                if buf[i + 3] > 20 and _color_dist(buf[i], buf[i + 1], buf[i + 2], bg_r, bg_g, bg_b) <= inner_tol:
                    # Chỉ xóa nếu không phải tròng mắt nhỏ (kiểm tra vùng liên thông >= 16 pixel)
                    comp = []
                    cq = collections.deque([(x, y)])
                    seen_local = {(x, y)}
                    while cq and len(comp) < 2500:
                        px, py = cq.popleft()
                        comp.append((px, py))
                        for nx, ny in ((px - 1, py), (px + 1, py), (px, py - 1), (px, py + 1)):
                            if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in seen_local:
                                ni = (ny * w + nx) * 4
                                if buf[ni + 3] > 20 and _color_dist(buf[ni], buf[ni + 1], buf[ni + 2], bg_r, bg_g, bg_b) <= inner_tol:
                                    seen_local.add((nx, ny))
                                    cq.append((nx, ny))
                    if len(comp) >= 18:
                        for px, py in comp:
                            buf[(py * w + px) * 4 + 3] = 0

    # Defringe 1px: xóa viền mờ pha màu nền dính quanh biên nhân vật (giữ nguyên viền tối đậm)
    bg_lum = 0.299 * bg_r + 0.587 * bg_g + 0.114 * bg_b
    to_clear = []
    for y in range(1, h - 1):
        for x in range(1, w - 1):
            i = (y * w + x) * 4
            a = buf[i + 3]
            if a == 0:
                continue
            adj_trans = (
                buf[((y - 1) * w + x) * 4 + 3] == 0
                or buf[((y + 1) * w + x) * 4 + 3] == 0
                or buf[(y * w + x - 1) * 4 + 3] == 0
                or buf[(y * w + x + 1) * 4 + 3] == 0
            )
            if adj_trans:
                dist = _color_dist(buf[i], buf[i + 1], buf[i + 2], bg_r, bg_g, bg_b)
                pix_lum = 0.299 * buf[i] + 0.587 * buf[i + 1] + 0.114 * buf[i + 2]
                if dist <= tol * 1.65 and abs(pix_lum - bg_lum) < 95.0:
                    to_clear.append(i)
    for idx in to_clear:
        buf[idx + 3] = 0


def find_components(buf: bytearray, w: int, h: int, alpha_thr: int = 16):
    """Tìm các vùng pixel liên thông (8 hướng) -> list of dict(pixels, area, bbox)."""
    visited = bytearray(w * h)
    comps = []
    for y in range(h):
        for x in range(w):
            pos = y * w + x
            if visited[pos] or buf[pos * 4 + 3] <= alpha_thr:
                continue
            q = collections.deque([(x, y)])
            visited[pos] = 1
            pixels = []
            min_x = max_x = x
            min_y = max_y = y
            while q:
                cx, cy = q.popleft()
                pixels.append((cx, cy))
                if cx < min_x: min_x = cx
                if cx > max_x: max_x = cx
                if cy < min_y: min_y = cy
                if cy > max_y: max_y = cy
                for ny in range(max(0, cy - 1), min(h, cy + 2)):
                    for nx in range(max(0, cx - 1), min(w, cx + 2)):
                        npos = ny * w + nx
                        if not visited[npos] and buf[npos * 4 + 3] > alpha_thr:
                            visited[npos] = 1
                            q.append((nx, ny))
            comps.append({
                "pixels": pixels,
                "area": len(pixels),
                "bbox": (min_x, min_y, max_x, max_y),
            })
    comps.sort(key=lambda c: c["area"], reverse=True)
    return comps


def clean_cell_bleed(buf: bytearray, w: int, h: int, keep_ratio: float = 0.08, gap_px: int = 4) -> int:
    """Xóa các mảnh rác cắt bị dính từ frame bên cạnh (vùng nhỏ tách rời xa thân chính)."""
    comps = find_components(buf, w, h)
    if len(comps) <= 1:
        return 0
    main = comps[0]
    m_x0, m_y0, m_x1, m_y1 = main["bbox"]
    main_area = main["area"]
    removed = 0
    for c in comps[1:]:
        cx0, cy0, cx1, cy1 = c["bbox"]
        # Khoảng cách ngang/dọc tới bounding box thân chính
        dx = max(0, m_x0 - cx1, cx0 - m_x1)
        dy = max(0, m_y0 - cy1, cy0 - m_y1)
        near_edge = (cx0 <= 6 or cx1 >= w - 7)
        too_small = c["area"] < max(24, int(main_area * keep_ratio))
        if (dx >= gap_px or dy >= gap_px * 2) and (near_edge or too_small):
            for px, py in c["pixels"]:
                buf[(py * w + px) * 4 + 3] = 0
            removed += c["area"]
    return removed


def get_bbox_and_body_cx(buf: bytearray, w: int, h: int, alpha_thr: int = 16, anchor_mode: str = "torso"):
    min_x, min_y, max_x, max_y = w, h, -1, -1
    for y in range(h):
        row = y * w
        for x in range(w):
            if buf[(row + x) * 4 + 3] > alpha_thr:
                if x < min_x: min_x = x
                if x > max_x: max_x = x
                if y < min_y: min_y = y
                if y > max_y: max_y = y
    if max_x < 0:
        return None
    # 'torso': lấy tâm X ở vùng thân-chân (35%..96%); 'legs': lấy vùng chân-giày (68%..99%) để vũ khí lớn vươn ngang không kéo lệch chân!
    body_h = max(1, max_y - min_y + 1)
    if anchor_mode == "legs":
        y_lo = min_y + int(body_h * 0.68)
        y_hi = min_y + int(body_h * 0.99)
    else:
        y_lo = min_y + int(body_h * 0.35)
        y_hi = min_y + int(body_h * 0.96)
    xs = []
    for y in range(y_lo, min(h, y_hi + 1)):
        row = y * w
        for x in range(min_x, max_x + 1):
            if buf[(row + x) * 4 + 3] > alpha_thr:
                xs.append(x)
    cx = (sum(xs) / float(len(xs))) if xs else ((min_x + max_x) * 0.5)
    return (min_x, min_y, max_x, max_y, cx)


def resize_rgba_area(src: bytearray, sw: int, sh: int, dw: int, dh: int, mode: str = "area") -> bytearray:
    """Thu phóng mượt kiểu Pixel Art: 'nearest' cho sprite pixel sẵn, 'area' cho ảnh AI phân giải cao."""
    out = bytearray(dw * dh * 4)
    if dw <= 0 or dh <= 0:
        return out
    if mode == "nearest" or (dw >= sw and dh >= sh):
        for y in range(dh):
            sy = min(sh - 1, int(y * sh / dh))
            for x in range(dw):
                sx = min(sw - 1, int(x * sw / dw))
                si = (sy * sw + sx) * 4
                di = (y * dw + x) * 4
                out[di : di + 4] = src[si : si + 4]
        return out

    # Box / Area downsampling trên RGB nhân alpha -> alpha cutoff sắc cạnh chuẩn pixel art!
    scale_x = sw / float(dw)
    scale_y = sh / float(dh)
    for y in range(dh):
        y0 = int(math.floor(y * scale_y))
        y1 = min(sh, max(y0 + 1, int(math.ceil((y + 1) * scale_y))))
        for x in range(dw):
            x0 = int(math.floor(x * scale_x))
            x1 = min(sw, max(x0 + 1, int(math.ceil((x + 1) * scale_x))))
            sr = sg = sb = sa = 0.0
            cnt = 0
            for sy in range(y0, y1):
                row = sy * sw
                for sx in range(x0, x1):
                    si = (row + sx) * 4
                    a = src[si + 3] / 255.0
                    sr += src[si] * a
                    sg += src[si + 1] * a
                    sb += src[si + 2] * a
                    sa += a
                    cnt += 1
            if cnt > 0 and sa > 0.0:
                avg_a = sa / cnt
                if avg_a >= 0.42:
                    di = (y * dw + x) * 4
                    out[di] = min(255, int(round(sr / sa)))
                    out[di + 1] = min(255, int(round(sg / sa)))
                    out[di + 2] = min(255, int(round(sb / sa)))
                    out[di + 3] = 255
    return out


def add_pixel_outline(buf: bytearray, w: int, h: int, col=(20, 16, 32, 255)) -> None:
    """Thêm viền 1px tím than #141020 quanh silhouette (chỉ ở các pixel trong suốt sát thân)."""
    outline_pts = []
    for y in range(h):
        for x in range(w):
            if buf[(y * w + x) * 4 + 3] > 0:
                continue
            has_nbr = False
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < w and 0 <= ny < h and buf[(ny * w + nx) * 4 + 3] > 180:
                    has_nbr = True
                    break
            if has_nbr:
                outline_pts.append((x, y))
    for x, y in outline_pts:
        i = (y * w + x) * 4
        buf[i] = col[0]
        buf[i + 1] = col[1]
        buf[i + 2] = col[2]
        buf[i + 3] = col[3]


def load_gpl_palette(gpl_path: str):
    colors = []
    with open(gpl_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or line.startswith("GIMP") or line.startswith("Name") or line.startswith("Columns"):
                continue
            parts = line.split()
            if len(parts) >= 3 and parts[0].isdigit() and parts[1].isdigit() and parts[2].isdigit():
                colors.append((int(parts[0]), int(parts[1]), int(parts[2])))
    return colors


def snap_palette(buf: bytearray, palette) -> None:
    if not palette:
        return
    cache = {}
    for i in range(0, len(buf), 4):
        if buf[i + 3] < 20:
            continue
        key = (buf[i], buf[i + 1], buf[i + 2])
        best = cache.get(key)
        if best is None:
            r, g, b = key
            best = min(palette, key=lambda p: (r - p[0]) ** 2 + (g - p[1]) ** 2 + (b - p[2]) ** 2)
            cache[key] = best
        buf[i], buf[i + 1], buf[i + 2] = best


# =====================================================================
# CÁC LỆNH CLI CHÍNH
# =====================================================================
def cmd_inspect(args):
    w, h, buf = load_rgba(args.input)
    cw = w // args.cols
    ch = h // args.rows
    print(f"=== {os.path.basename(args.input)} ({w}x{h}, grid {args.cols}x{args.rows}, cell {cw}x{ch}) ===")
    idx = 0
    for r in range(args.rows):
        for c in range(args.cols):
            cell = crop_rgba(buf, w, c * cw, r * ch, cw, ch)
            info = get_bbox_and_body_cx(cell, cw, ch)
            comps = find_components(cell, cw, ch)
            if info is None:
                print(f"  f{idx:02d}: EMPTY")
            else:
                x0, y0, x1, y1, cx = info
                bh = y1 - y0 + 1
                fpad = ch - 1 - y1
                print(
                    f"  f{idx:02d}: bbox=({x0},{y0})..({x1},{y1}) bodyH={bh} footPad={fpad} "
                    f"bodyCxOff={cx - cw * 0.5:+.1f} components={len(comps)}"
                )
            idx += 1


def cmd_clean(args):
    w, h, buf = load_rgba(args.input)
    cw = w // args.cols
    ch = h // args.rows
    out = bytearray(w * h * 4)
    total_removed = 0
    for r in range(args.rows):
        for c in range(args.cols):
            cell = crop_rgba(buf, w, c * cw, r * ch, cw, ch)
            rem = clean_cell_bleed(cell, cw, ch, keep_ratio=args.keep_ratio, gap_px=args.gap)
            total_removed += rem
            blit_rgba(out, w, h, cell, cw, ch, c * cw, r * ch)
            if rem > 0:
                print(f"  Cleaned cell ({c},{r}): removed {rem} stray bleed pixels")
    save_rgba(args.output, w, h, out)
    print(f"Saved cleaned sheet -> {args.output} (total removed: {total_removed} px)")


def _find_bands_1d(counts, expected_n: int):
    """Tìm đúng expected_n dải ảnh tách biệt theo các khoảng trống (valleys) thay vì chia đều cứng."""
    length = len(counts)
    if expected_n <= 1:
        nz = [i for i, v in enumerate(counts) if v > 0]
        return [(nz[0], nz[-1] + 1)] if nz else [(0, length)]

    # Tìm tất cả các đoạn liên tiếp có pixel > 0
    raw_segs = []
    in_seg = False
    st = 0
    for i, v in enumerate(counts):
        if v > 0 and not in_seg:
            in_seg = True
            st = i
        elif v == 0 and in_seg:
            in_seg = False
            raw_segs.append([st, i])
    if in_seg:
        raw_segs.append([st, length])

    # Lọc bỏ chấm nhiễu quá mảnh (< 1% chiều dài & ít pixel)
    total_mass = sum(counts)
    min_mass = max(8, int(total_mass * 0.002))
    segs = [s for s in raw_segs if sum(counts[s[0]:s[1]]) >= min_mass]

    # Nếu có nhiều đoạn nhỏ hơn expected_n (do dải lụa/vũ khí rời thân), gộp 2 đoạn gần nhau nhất cho tới khi còn đúng expected_n
    while len(segs) > expected_n:
        best_i = 0
        best_gap = 10**9
        for i in range(len(segs) - 1):
            gap = segs[i + 1][0] - segs[i][1]
            if gap < best_gap:
                best_gap = gap
                best_i = i
        segs[best_i][1] = segs[best_i + 1][1]
        segs.pop(best_i + 1)

    if len(segs) == expected_n:
        # Mở rộng nhẹ biên ra nửa rãnh trống mỗi bên để giữ sạch viền
        bands = []
        for i, (a, b) in enumerate(segs):
            lo = 0 if i == 0 else (segs[i - 1][1] + a) // 2
            hi = length if i == len(segs) - 1 else (b + segs[i + 1][0]) // 2
            bands.append((max(0, lo), min(length, hi)))
        return bands

    # Fallback: tìm rãnh thấp nhất quanh các vị trí chia đều
    cuts = [0]
    step = length / float(expected_n)
    win = max(4, int(step * 0.22))
    for k in range(1, expected_n):
        center = int(round(k * step))
        lo = max(cuts[-1] + 1, center - win)
        hi = min(length - 1, center + win)
        best_x = min(range(lo, hi + 1), key=lambda x: counts[x])
        cuts.append(best_x)
    cuts.append(length)
    return [(cuts[i], cuts[i + 1]) for i in range(expected_n)]


def cmd_normalize(args):
    w, h, buf = load_rgba(args.input)
    if args.remove_bg:
        remove_solid_bg(buf, w, h, tol=args.bg_tol, remove_interior_holes=not args.keep_holes)

    if args.uniform_grid:
        row_bands = [(r * (h // args.rows), (r + 1) * (h // args.rows)) for r in range(args.rows)]
    else:
        y_counts = [0] * h
        for y in range(h):
            row = y * w
            cnt = 0
            for x in range(w):
                if buf[(row + x) * 4 + 3] > 20:
                    cnt += 1
            y_counts[y] = cnt
        row_bands = _find_bands_1d(y_counts, args.rows)

    frames = []
    for y0, y1 in row_bands:
        rh = y1 - y0
        if rh <= 0:
            continue
        if args.uniform_grid:
            col_bands = [(c * (w // args.cols), (c + 1) * (w // args.cols)) for c in range(args.cols)]
        else:
            x_counts = [0] * w
            for y in range(y0, y1):
                row = y * w
                for x in range(w):
                    if buf[(row + x) * 4 + 3] > 20:
                        x_counts[x] += 1
            col_bands = _find_bands_1d(x_counts, args.cols)

        for x0, x1 in col_bands:
            cw = x1 - x0
            if cw <= 0:
                continue
            cell = crop_rgba(buf, w, x0, y0, cw, rh)
            clean_cell_bleed(cell, cw, rh, keep_ratio=0.05, gap_px=max(4, cw // 28))
            info = get_bbox_and_body_cx(cell, cw, rh, anchor_mode=args.anchor_x_mode)
            if info is not None:
                frames.append((cell, cw, rh, info))

    if not frames:
        print("ERROR: Khong tim thay frame nao hop le!", file=sys.stderr)
        sys.exit(1)

    # Dùng chiều cao trung vị (median) hoặc fixed-scale cố định (cho combo vũ khí dài!)
    heights = sorted(f[3][3] - f[3][1] + 1 for f in frames)
    ref_h = heights[len(heights) // 2]
    uniform_scale = args.fixed_scale if args.fixed_scale > 0.0 else (float(args.target_h) / float(max(1, ref_h)))

    out_cols = args.out_cols if args.out_cols > 0 else args.cols
    out_rows = args.out_rows if args.out_rows > 0 else int(math.ceil(len(frames) / float(out_cols)))
    out_w = out_cols * args.cell_w
    out_h = out_rows * args.cell_h
    out_buf = bytearray(out_w * out_h * 4)
    palette = load_gpl_palette(args.palette) if args.palette else None

    for idx, (cell, cw, ch, info) in enumerate(frames):
        if idx >= out_cols * out_rows:
            break
        x0, y0, x1, y1, body_cx = info
        bw = x1 - x0 + 1
        bh = y1 - y0 + 1
        sub = crop_rgba(cell, cw, x0, y0, bw, bh)

        # Nếu chọn uniform scaling giữ nhịp cao-thấp tự nhiên khi chạy; vẫn clamp không vượt cell_w/cell_h
        sc = uniform_scale if not args.per_frame_height else (float(args.target_h) / float(max(1, bh)))
        max_sc_w = float(args.cell_w - 4) / float(max(1, bw))
        max_sc_h = float(args.cell_h - args.foot_pad - 2) / float(max(1, bh))
        sc = min(sc, max_sc_w, max_sc_h)

        nw = max(1, int(round(bw * sc)))
        nh = max(1, int(round(bh * sc)))
        resized = resize_rgba_area(sub, bw, bh, nw, nh, mode=args.resample)
        if args.outline:
            add_pixel_outline(resized, nw, nh)
        if palette:
            snap_palette(resized, palette)

        # Neo chính xác tâm thân theo X và bàn chân theo Y (foot_pad tính từ đáy ô)
        rel_cx = (body_cx - x0) * sc
        ox = int(round(args.cell_w * 0.5 - rel_cx))
        ox = max(1, min(args.cell_w - nw - 1, ox))
        oy = args.cell_h - args.foot_pad - nh

        oc = idx % out_cols
        orow = idx // out_cols
        blit_rgba(out_buf, out_w, out_h, resized, nw, nh, oc * args.cell_w + ox, orow * args.cell_h + oy)

    save_rgba(args.output, out_w, out_h, out_buf)
    print(f"Normalized {len(frames)} frames -> {args.output} ({out_w}x{out_h}, grid {out_cols}x{out_rows}, cell {args.cell_w}x{args.cell_h})")


def cmd_pack(args):
    all_cells = []
    cell_w = cell_h = 0
    for p in args.inputs:
        w, h, buf = load_rgba(p)
        cw = w // args.in_cols
        ch = h // args.in_rows
        if cell_w == 0:
            cell_w, cell_h = cw, ch
        for r in range(args.in_rows):
            for c in range(args.in_cols):
                all_cells.append(crop_rgba(buf, w, c * cw, r * ch, cw, ch))

    out_cols = args.out_cols
    out_rows = args.out_rows if args.out_rows > 0 else int(math.ceil(len(all_cells) / float(out_cols)))
    out_w = out_cols * cell_w
    out_h = out_rows * cell_h
    out_buf = bytearray(out_w * out_h * 4)
    for idx, cell in enumerate(all_cells):
        if idx >= out_cols * out_rows:
            break
        oc = idx % out_cols
        orow = idx // out_cols
        blit_rgba(out_buf, out_w, out_h, cell, cell_w, cell_h, oc * cell_w, orow * cell_h)
    save_rgba(args.output, out_w, out_h, out_buf)
    print(f"Packed {len(all_cells)} frames -> {args.output} ({out_w}x{out_h}, grid {out_cols}x{out_rows})")


def cmd_extract_ref(args):
    w, h, buf = load_rgba(args.input)
    cw = w // args.cols
    ch = h // args.rows
    c = args.frame % args.cols
    r = args.frame // args.cols
    cell = crop_rgba(buf, w, c * cw, r * ch, cw, ch)
    info = get_bbox_and_body_cx(cell, cw, ch)
    if info is None:
        print("ERROR: Frame trong!", file=sys.stderr)
        sys.exit(1)
    x0, y0, x1, y1, _ = info
    pad = 8
    sx0 = max(0, x0 - pad)
    sy0 = max(0, y0 - pad)
    sw = min(cw - sx0, (x1 - x0 + 1) + pad * 2)
    sh = min(ch - sy0, (y1 - y0 + 1) + pad * 2)
    sub = crop_rgba(cell, cw, sx0, sy0, sw, sh)
    nw = sw * args.scale
    nh = sh * args.scale
    up = resize_rgba_area(sub, sw, sh, nw, nh, mode="nearest")
    # Đặt lên nền trắng tinh để AI nhìn rõ chi tiết viền & màu sắc
    bg = bytearray(nw * nh * 4)
    for i in range(0, len(bg), 4):
        if up[i + 3] > 20:
            bg[i : i + 4] = up[i : i + 4]
        else:
            bg[i] = 255
            bg[i + 1] = 255
            bg[i + 2] = 255
            bg[i + 3] = 255
    save_rgba(args.output, nw, nh, bg)
    print(f"Extracted reference frame {args.frame} -> {args.output} ({nw}x{nh})")


def main():
    parser = argparse.ArgumentParser(description="Chuan hoa & ghep SpriteSheet AI cho Godot 4")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_ins = sub.add_parser("inspect")
    p_ins.add_argument("input")
    p_ins.add_argument("--cols", type=int, default=4)
    p_ins.add_argument("--rows", type=int, default=1)
    p_ins.set_defaults(func=cmd_inspect)

    p_cln = sub.add_parser("clean")
    p_cln.add_argument("input")
    p_cln.add_argument("-o", "--output", required=True)
    p_cln.add_argument("--cols", type=int, default=4)
    p_cln.add_argument("--rows", type=int, default=1)
    p_cln.add_argument("--keep-ratio", type=float, default=0.08)
    p_cln.add_argument("--gap", type=int, default=4)
    p_cln.set_defaults(func=cmd_clean)

    p_nrm = sub.add_parser("normalize")
    p_nrm.add_argument("input")
    p_nrm.add_argument("-o", "--output", required=True)
    p_nrm.add_argument("--cols", type=int, required=True)
    p_nrm.add_argument("--rows", type=int, default=1)
    p_nrm.add_argument("--out-cols", type=int, default=0)
    p_nrm.add_argument("--out-rows", type=int, default=0)
    p_nrm.add_argument("--cell-w", type=int, default=96)
    p_nrm.add_argument("--cell-h", type=int, default=96)
    p_nrm.add_argument("--target-h", type=int, default=87)
    p_nrm.add_argument("--foot-pad", type=int, default=3)
    p_nrm.add_argument("--remove-bg", action="store_true")
    p_nrm.add_argument("--bg-tol", type=float, default=45.0)
    p_nrm.add_argument("--keep-holes", action="store_true")
    p_nrm.add_argument("--resample", choices=["area", "nearest"], default="area")
    p_nrm.add_argument("--outline", action="store_true")
    p_nrm.add_argument("--palette", default="")
    p_nrm.add_argument("--per-frame-height", action="store_true")
    p_nrm.add_argument("--uniform-grid", action="store_true", help="Chia deu cung theo cols/rows thay vi do ranh trong")
    p_nrm.add_argument("--anchor-x-mode", choices=["torso", "legs"], default="torso", help="Can tam X theo than (torso) hoac chan (legs - tot cho vu khi dai)")
    p_nrm.add_argument("--fixed-scale", type=float, default=0.0, help="Khoa ty le thu phong co dinh (bo qua target-h)")
    p_nrm.set_defaults(func=cmd_normalize)

    p_pck = sub.add_parser("pack")
    p_pck.add_argument("inputs", nargs="+")
    p_pck.add_argument("-o", "--output", required=True)
    p_pck.add_argument("--in-cols", type=int, default=4)
    p_pck.add_argument("--in-rows", type=int, default=1)
    p_pck.add_argument("--out-cols", type=int, default=4)
    p_pck.add_argument("--out-rows", type=int, default=0)
    p_pck.set_defaults(func=cmd_pack)

    p_ref = sub.add_parser("extract-ref")
    p_ref.add_argument("input")
    p_ref.add_argument("-o", "--output", required=True)
    p_ref.add_argument("--cols", type=int, default=4)
    p_ref.add_argument("--rows", type=int, default=1)
    p_ref.add_argument("--frame", type=int, default=0)
    p_ref.add_argument("--scale", type=int, default=5)
    p_ref.set_defaults(func=cmd_extract_ref)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
