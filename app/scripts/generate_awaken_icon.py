#!/usr/bin/env python3
"""Generate 觉醒笔记 launcher source icon (1024×1024).

Readable at 48px: centered legal-pad page + dawn glow + small sun.
Colors align with lib/core/theme/app_colors.dart.
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

# AppColors — parchment / ink / accent (light theme)
BG_TOP = (0xFB, 0xF8, 0xF1)  # surfaceLight
BG_MID = (0xF5, 0xEF, 0xE0)  # bgLight
BG_BOTTOM = (0xF0, 0xE9, 0xD5)  # surfaceAltLight
ACCENT = (0x8B, 0x4A, 0x1E)  # accentLight (margin line)
GOLD = (0xBF, 0x93, 0x2A)  # goldLight
GOLD_SOFT = (0xE8, 0xD4, 0x98)
RULE = (0xDD, 0xD0, 0xB4)  # ruleLineLight
PAPER = (0xFF, 0xFD, 0xF8)  # slightly brighter than surface for the “sheet”


def _lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def _lerp_rgb(
    c1: tuple[int, int, int], c2: tuple[int, int, int], t: float
) -> tuple[int, int, int]:
    return (_lerp(c1[0], c2[0], t), _lerp(c1[1], c2[1], t), _lerp(c1[2], c2[2], t))


def vertical_gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    assert px is not None
    for y in range(size):
        t = y / max(size - 1, 1)
        if t < 0.45:
            u = t / 0.45
            c = _lerp_rgb(BG_TOP, BG_MID, u**0.85)
        else:
            u = (t - 0.45) / 0.55
            c = _lerp_rgb(BG_MID, BG_BOTTOM, u**0.9)
        for x in range(size):
            px[x, y] = c
    return img


def add_dawn_glow(base: Image.Image, cx: float, cy: float, rx: float, ry: float) -> None:
    """Soft amber ellipse — morning light behind the page."""
    px = base.load()
    w, h = base.size
    assert px is not None
    for y in range(h):
        for x in range(w):
            nx = (x - cx) / rx
            ny = (y - cy) / ry
            d = math.sqrt(nx * nx + ny * ny)
            if d < 1.0:
                t = (1.0 - d) ** 2.2 * 0.38
                cur = px[x, y]
                warm = _lerp_rgb(cur, GOLD_SOFT, t)
                px[x, y] = warm


def draw_soft_shadow(
    layer: Image.Image, bbox: tuple[int, int, int, int], radius: int
) -> None:
    """Very subtle shadow under the paper (RGBA layer)."""
    draw = ImageDraw.Draw(layer)
    draw.rounded_rectangle(bbox, radius=radius, fill=(0x2C, 0x1A, 0x10, 55))


def draw_sun_disc(layer: Image.Image, cx: int, cy: int, r: int) -> None:
    """Minimal sun — no rays (they muddy small icons)."""
    draw = ImageDraw.Draw(layer)
    for i in range(r, 0, -1):
        t = i / r
        col = _lerp_rgb(GOLD_SOFT, GOLD, t**0.5)
        a = int(30 + 225 * (1 - t))
        draw.ellipse((cx - i, cy - i, cx + i, cy + i), fill=(*col, a))
    draw.ellipse(
        (cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2),
        outline=(*_lerp_rgb(GOLD, ACCENT, 0.35), 120),
        width=max(2, r // 48),
    )


def render(size_out: int = 1024) -> Image.Image:
    ss = size_out * 2
    s = ss / 1024.0

    base = vertical_gradient(ss)
    cx = ss // 2
    # Dawn sits slightly above vertical center — safe for round masks
    add_dawn_glow(base, float(cx), ss * 0.36, ss * 0.62, ss * 0.38)

    # Paper block: centered, ~62% width — inside Android adaptive safe zone
    pad_x = int(190 * s)
    top = int(300 * s)
    bottom = int(860 * s)
    rad = int(36 * s)
    paper_bbox = (pad_x, top, ss - pad_x, bottom)

    shadow = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))
    sb = (
        paper_bbox[0] + int(8 * s),
        paper_bbox[1] + int(14 * s),
        paper_bbox[2] + int(8 * s),
        paper_bbox[3] + int(14 * s),
    )
    draw_soft_shadow(shadow, sb, rad)
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=10 * s))

    base_rgba = base.convert("RGBA")
    base_rgba = Image.alpha_composite(base_rgba, shadow)

    paper = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))
    pd = ImageDraw.Draw(paper)
    pd.rounded_rectangle(paper_bbox, radius=rad, fill=(*PAPER, 255))
    # Hairline edge
    pd.rounded_rectangle(
        paper_bbox,
        radius=rad,
        outline=(*RULE, 200),
        width=max(2, int(3 * s)),
    )
    base_rgba = Image.alpha_composite(base_rgba, paper)

    # Margin + rules (legal pad)
    draw_p = ImageDraw.Draw(base_rgba)
    mx = paper_bbox[0] + int(52 * s)
    draw_p.line(
        (mx, paper_bbox[1] + int(36 * s), mx, paper_bbox[3] - int(40 * s)),
        fill=ACCENT,
        width=max(3, int(6 * s)),
    )
    line_left = mx + int(44 * s)
    line_right = paper_bbox[2] - int(44 * s)
    y0 = paper_bbox[1] + int(110 * s)
    gap = int(72 * s)
    for k in range(5):
        y = y0 + k * gap
        if y < paper_bbox[3] - int(36 * s):
            draw_p.line((line_left, y, line_right, y), fill=RULE, width=max(2, int(4 * s)))

    # Sun overlaps top of paper slightly
    sun_layer = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))
    sun_r = int(118 * s)
    sun_cy = top + int(12 * s)
    draw_sun_disc(sun_layer, cx, sun_cy, sun_r)
    sun_layer = sun_layer.filter(ImageFilter.GaussianBlur(radius=0.9 * s))
    base_rgba = Image.alpha_composite(base_rgba, sun_layer)

    out = base_rgba.convert("RGB")
    out = out.resize((size_out, size_out), Image.Resampling.LANCZOS)
    return out


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    out_path = root / "assets" / "icon.png"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img = render(1024)
    img.save(out_path, "PNG", optimize=True)
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
