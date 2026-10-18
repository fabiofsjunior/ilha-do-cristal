#!/usr/bin/env python3
"""Build launcher icon variants from the approved game logo artwork."""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "tools/art/source/ilha-cristal-logo.jpg"
OUTPUT = ROOT / "assets/ui"
MAIN_SIZE = 512
ADAPTIVE_SIZE = 432


def load_logo(size: int) -> Image.Image:
    logo = Image.open(SOURCE).convert("RGBA")
    if logo.width != logo.height:
        raise ValueError(f"The game logo must be square, got {logo.size}")
    return logo.resize((size, size), Image.Resampling.NEAREST)


def main_icon() -> Image.Image:
    return load_logo(MAIN_SIZE)


def adaptive_background() -> Image.Image:
    canvas = Image.new("RGBA", (ADAPTIVE_SIZE, ADAPTIVE_SIZE), "#101b26")
    draw = ImageDraw.Draw(canvas)
    draw.ellipse((56, 56, 376, 376), fill="#15384a")
    draw.ellipse((108, 108, 324, 324), fill="#17455b")
    return canvas


def adaptive_foreground() -> Image.Image:
    canvas = Image.new("RGBA", (ADAPTIVE_SIZE, ADAPTIVE_SIZE), (0, 0, 0, 0))
    # Keep the wordmark inside Android's centered adaptive-icon safe area.
    logo = load_logo(224)
    mask = Image.new("L", logo.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, logo.width - 1, logo.height - 1), radius=18, fill=255
    )
    logo.putalpha(mask)
    canvas.alpha_composite(logo, ((ADAPTIVE_SIZE - logo.width) // 2,) * 2)
    return canvas


def adaptive_monochrome() -> Image.Image:
    # Themed Android launchers require a single-color mark. Use the logo's
    # central crystal as its compact monochrome symbol.
    mask = Image.new("L", (ADAPTIVE_SIZE, ADAPTIVE_SIZE), 0)
    draw = ImageDraw.Draw(mask)
    draw.polygon(
        [(216, 84), (286, 157), (275, 285), (216, 348), (157, 285), (146, 157)],
        fill=255,
    )
    return _with_alpha(mask)


def _with_alpha(mask: Image.Image) -> Image.Image:
    icon = Image.new("RGBA", mask.size, (255, 255, 255, 255))
    icon.putalpha(mask)
    return icon


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    assets = {
        "app_icon.png": main_icon(),
        "app_icon_background.png": adaptive_background(),
        "app_icon_foreground.png": adaptive_foreground(),
        "app_icon_monochrome.png": adaptive_monochrome(),
    }
    for name, image in assets.items():
        image.save(OUTPUT / name, optimize=True)
        print(f"{name}: {image.width}x{image.height} RGBA")


if __name__ == "__main__":
    main()
