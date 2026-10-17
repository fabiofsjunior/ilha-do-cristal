#!/usr/bin/env python3
"""Build crisp Android launcher icons from the game's crystal pixel sprite."""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/environments/tropical_oblique_candidate/crystal.png"
OUTPUT = ROOT / "assets/ui"


def nearest(sprite: Image.Image, size: tuple[int, int]) -> Image.Image:
    return sprite.resize(size, Image.Resampling.NEAREST)


def main_icon(sprite: Image.Image) -> Image.Image:
    canvas = Image.new("RGBA", (512, 512), "#101a27")
    draw = ImageDraw.Draw(canvas)
    draw.polygon([(256, 30), (470, 256), (256, 482), (42, 256)], fill="#173849", outline="#3f737d", width=8)
    draw.line([(256, 54), (446, 256), (256, 458), (66, 256), (256, 54)], fill="#a8874c", width=4, joint="curve")
    draw.rectangle((18, 18, 493, 493), outline="#9b7c46", width=8)
    draw.rectangle((34, 34, 477, 477), outline="#244957", width=4)
    crystal = nearest(sprite, (336, 384))
    canvas.alpha_composite(crystal, ((512 - crystal.width) // 2, 56))
    return canvas


def adaptive_background() -> Image.Image:
    canvas = Image.new("RGBA", (432, 432), "#101a27")
    draw = ImageDraw.Draw(canvas)
    draw.polygon([(216, 24), (408, 216), (216, 408), (24, 216)], fill="#173849", outline="#315b68", width=8)
    draw.line([(216, 58), (374, 216), (216, 374), (58, 216), (216, 58)], fill="#263f4c", width=5, joint="curve")
    return canvas


def adaptive_foreground(sprite: Image.Image, monochrome: bool = False) -> Image.Image:
    canvas = Image.new("RGBA", (432, 432), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    draw.polygon(
        [(216, 78), (340, 216), (216, 354), (92, 216)],
        fill=(29, 125, 146, 62),
        outline=(103, 220, 224, 155),
        width=6,
    )
    crystal = nearest(sprite, (202, 230))
    if monochrome:
        mask = crystal.getchannel("A")
        crystal = Image.new("RGBA", crystal.size, (255, 255, 255, 0))
        crystal.putalpha(mask)
        # Keep the monochrome mark clear on both light and dark launcher themes.
        draw = ImageDraw.Draw(canvas)
        draw.polygon(
            [(216, 78), (340, 216), (216, 354), (92, 216)],
            fill=(0, 0, 0, 0),
            outline=(255, 255, 255, 220),
            width=6,
        )
    canvas.alpha_composite(crystal, ((432 - crystal.width) // 2, 79))
    return canvas


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    sprite = Image.open(SOURCE).convert("RGBA")
    assets = {
        "app_icon.png": main_icon(sprite),
        "app_icon_background.png": adaptive_background(),
        "app_icon_foreground.png": adaptive_foreground(sprite),
        "app_icon_monochrome.png": adaptive_foreground(sprite, monochrome=True),
    }
    for name, image in assets.items():
        image.save(OUTPUT / name, optimize=True)
        print(f"{name}: {image.width}x{image.height} RGBA")


if __name__ == "__main__":
    main()
