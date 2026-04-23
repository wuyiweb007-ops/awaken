#!/usr/bin/env python3
"""将截屏调整为 App Store Connect 要求的精确像素尺寸。"""

from __future__ import annotations

import sys
from pathlib import Path

from appstore_image_utils import fit_and_pad


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    iphone_dir = root / "image" / "iphone"
    inputs = sorted(iphone_dir.glob("*.png"))
    out_dir = root / "appstore_screenshots"
    out_dir.mkdir(exist_ok=True)

    specs = (
        (1242, 2688, "6.5in_portrait"),
        (1284, 2778, "6.7in_portrait"),
    )

    for path in inputs:
        if not path.is_file():
            print(f"跳过（不存在）: {path}", file=sys.stderr)
            continue
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
