#!/usr/bin/env python3
"""将 iPad 截屏调整为 App Store Connect 要求的精确像素尺寸。"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image

from appstore_image_utils import fit_and_pad


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    ipad_dir = root / "image" / "ipad"
    out_dir = ipad_dir
    inputs = sorted(ipad_dir.glob("*.jpg")) + sorted(ipad_dir.glob("*.jpeg"))
    if not inputs:
        print(f"未找到 JPG: {ipad_dir}", file=sys.stderr)
        return 1

    # 竖屏与横屏（若素材为竖屏，横屏结果上下会有较宽填充，一般仅上传竖屏即可）
    specs = (
        (2064, 2752, "portrait_12.9"),
        (2048, 2732, "portrait_11"),
        (2752, 2064, "landscape_12.9"),
        (2732, 2048, "landscape_11"),
    )

    for path in inputs:
        im = Image.open(path).convert("RGB")
        stem = path.stem
        for tw, th, label in specs:
            out = fit_and_pad(im, tw, th)
            name = f"{stem}_{tw}x{th}_{label}.png"
            out_path = out_dir / name
            out.save(out_path, "PNG", optimize=True)
            print(f"已写入 {out_path} ({tw}×{th})")

    print(f"完成。输出目录: {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
