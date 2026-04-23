"""App Store 截屏：按比例缩放并填充至目标像素。"""

from __future__ import annotations

from PIL import Image


def strip_mean_rgb(im: Image.Image, top: bool) -> tuple[int, int, int]:
    """取图像上缘或下缘一条带的平均 RGB（用于填充色）。"""
    w, h = im.size
    band_h = max(1, min(24, h // 8))
    if top:
        box = (0, 0, w, band_h)
    else:
        box = (0, h - band_h, w, h)
    crop = im.crop(box).convert("RGB")
    px = crop.load()
    tw, th = crop.size
    r = g = b = 0
    n = tw * th
    for y in range(th):
        for x in range(tw):
            t = px[x, y]
            r += t[0]
            g += t[1]
            b += t[2]
    return (r // n, g // n, b // n)


def pad_color(im: Image.Image) -> tuple[int, int, int]:
    top = strip_mean_rgb(im, True)
    bottom = strip_mean_rgb(im, False)
    return (
        (top[0] + bottom[0]) // 2,
        (top[1] + bottom[1]) // 2,
        (top[2] + bottom[2]) // 2,
    )


def fit_and_pad(im: Image.Image, target_w: int, target_h: int) -> Image.Image:
    """按比例缩放以完全放入目标矩形，居中后用背景色填充至精确尺寸。"""
    w, h = im.size
    scale = min(target_w / w, target_h / h)
    new_w = max(1, round(w * scale))
    new_h = max(1, round(h * scale))
    resized = im.resize((new_w, new_h), Image.Resampling.LANCZOS)
    fill = pad_color(im)
    out = Image.new("RGB", (target_w, target_h), fill)
    x = (target_w - new_w) // 2
    y = (target_h - new_h) // 2
    if resized.mode in ("RGBA", "P"):
        resized = resized.convert("RGB")
    out.paste(resized, (x, y))
    return out
