#!/usr/bin/env python3
"""Generates App Store / Play Store marketing assets for IncaCook.

Run: python3 docs/store_submission/generate_assets.py
Reads brand colors from lib/core/utils/theme/brand_colors.dart & palette.dart
(hardcoded here to keep this script standalone) and the 4 raw screenshots in
assets/screenshots/.
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCREENSHOTS_DIR = os.path.join(ROOT, "assets", "screenshots")
OUT_DIR = os.path.join(ROOT, "docs", "store_submission")
LOGO_PATH = os.path.join(ROOT, "assets", "logos", "app_logo.png")
FONT_DIR = os.path.join(ROOT, "assets", "fonts")

# ---- Brand palette (from lib/core/utils/theme/brand_colors.dart & palette.dart) ----
PRIMARY = (0x00, 0xC2, 0x63)        # BrandColors.primary
PRIMARY_DARK = (0x00, 0x8A, 0x46)   # darker shade of primary for gradient
SECONDARY = (0xC8, 0x55, 0x3D)      # BrandColors.secondary (terracotta)
CREAM = (0xFF, 0xF8, 0xF4)          # LightPalette.background
CREAM_LOW = (0xF8, 0xEF, 0xE8)
ON_SURFACE = (0x2B, 0x17, 0x13)     # LightPalette.onSurface (warm dark brown)

def font(name, size):
    return ImageFont.truetype(os.path.join(FONT_DIR, name), size)

def vertical_gradient(size, top, bottom):
    w, h = size
    base = Image.new("RGB", (1, h), color=0)
    for y in range(h):
        t = y / max(h - 1, 1)
        r = int(top[0] + (bottom[0] - top[0]) * t)
        g = int(top[1] + (bottom[1] - top[1]) * t)
        b = int(top[2] + (bottom[2] - top[2]) * t)
        base.putpixel((0, y), (r, g, b))
    return base.resize(size)

def rounded_rect_mask(size, radius):
    mask = Image.new("L", size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius=radius, fill=255)
    return mask

def wrap_text(draw, text, f, max_width):
    words = text.split()
    lines, cur = [], ""
    for w in words:
        trial = (cur + " " + w).strip()
        if draw.textlength(trial, font=f) <= max_width:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines

def redact_address(shot: Image.Image) -> Image.Image:
    """Screenshot 4 shows a real street address. Cover that row with a
    frosted pill before it goes anywhere public."""
    shot = shot.copy()
    d = ImageDraw.Draw(shot)
    w, h = shot.size
    box = [int(w * 0.06), int(h * 0.548), int(w * 0.97), int(h * 0.60)]
    d.rounded_rectangle(box, radius=14, fill=CREAM_LOW)
    f = font("Poppins-SemiBold.ttf", 15)
    d.text(((box[0] + box[2]) // 2, (box[1] + box[3]) // 2), "Adresse masquée",
           font=f, fill=ON_SURFACE, anchor="mm")
    return shot

def make_screenshot(src_path, headline, canvas_size, out_path, redact=False):
    W, H = canvas_size
    canvas = vertical_gradient((W, H), CREAM, CREAM_LOW)

    # Decorative blobs echoing the app's decorBlobTint aesthetic.
    blob_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    bd = ImageDraw.Draw(blob_layer)
    bd.ellipse([-W * 0.35, -H * 0.12, W * 0.55, H * 0.28], fill=PRIMARY + (255,))
    bd.ellipse([W * 0.55, H * 0.85, W * 1.35, H * 1.15], fill=SECONDARY + (120,))
    blob_layer = blob_layer.filter(ImageFilter.GaussianBlur(W * 0.02))
    canvas = canvas.convert("RGBA")
    canvas.alpha_composite(blob_layer)
    canvas = canvas.convert("RGB")

    draw = ImageDraw.Draw(canvas)

    # Headline
    headline_font = font("Poppins-Bold.ttf", int(W * 0.062))
    margin = int(W * 0.09)
    lines = wrap_text(draw, headline, headline_font, W - 2 * margin)
    line_h = int(W * 0.078)
    text_top = int(H * 0.065)
    for i, line in enumerate(lines):
        draw.text((W / 2, text_top + i * line_h), line, font=headline_font,
                   fill=ON_SURFACE, anchor="ma", align="center")

    # Phone mockup
    shot = Image.open(src_path).convert("RGB")
    if redact:
        shot = redact_address(shot)
    shot_ratio = shot.width / shot.height
    phone_w = int(W * 0.72)
    phone_h = int(phone_w / shot_ratio)
    max_phone_h = int(H * 0.62)
    if phone_h > max_phone_h:
        phone_h = max_phone_h
        phone_w = int(phone_h * shot_ratio)
    phone_x = (W - phone_w) // 2
    phone_y = text_top + len(lines) * line_h + int(H * 0.035)

    bezel_pad = int(W * 0.014)
    corner_r = int(W * 0.055)
    bezel_box = [phone_x - bezel_pad, phone_y - bezel_pad,
                 phone_x + phone_w + bezel_pad, phone_y + phone_h + bezel_pad]

    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle(
        [bezel_box[0], bezel_box[1] + int(H * 0.018), bezel_box[2], bezel_box[3] + int(H * 0.018)],
        radius=corner_r, fill=(0, 0, 0, 70))
    shadow = shadow.filter(ImageFilter.GaussianBlur(W * 0.02))
    canvas = canvas.convert("RGBA")
    canvas.alpha_composite(shadow)
    canvas = canvas.convert("RGB")
    draw = ImageDraw.Draw(canvas)

    draw.rounded_rectangle(bezel_box, radius=corner_r, fill=(20, 20, 20))

    shot_resized = shot.resize((phone_w, phone_h), Image.LANCZOS)
    inner_r = int(corner_r * 0.72)
    mask = rounded_rect_mask((phone_w, phone_h), inner_r)
    canvas.paste(shot_resized, (phone_x, phone_y), mask)

    # Footer wordmark
    logo = Image.open(LOGO_PATH).convert("RGBA")
    logo_size = int(W * 0.075)
    logo = logo.resize((logo_size, logo_size), Image.LANCZOS)
    footer_y = H - int(H * 0.055)
    canvas.paste(logo, (int(W / 2 - logo_size * 1.7), footer_y - logo_size // 2), logo)
    wm_font = font("Poppins-SemiBold.ttf", int(W * 0.045))
    draw = ImageDraw.Draw(canvas)
    draw.text((int(W / 2 - logo_size * 0.6), footer_y), "IncaCook",
               font=wm_font, fill=ON_SURFACE, anchor="lm")

    canvas.save(out_path, quality=95)
    print("wrote", out_path)

def make_icon_1024():
    src = Image.open(LOGO_PATH).convert("RGBA")
    bg = Image.new("RGB", (1024, 1024), CREAM)
    src_ratio_size = int(1024 * 0.86)
    src_resized = src.resize((src_ratio_size, src_ratio_size), Image.LANCZOS)
    off = (1024 - src_ratio_size) // 2
    bg.paste(src_resized, (off, off), src_resized)
    out = os.path.join(OUT_DIR, "ios", "icon_1024.png")
    bg.save(out)
    print("wrote", out)
    return bg

def make_icon_512(icon_1024):
    out = os.path.join(OUT_DIR, "android", "icon_512.png")
    icon_1024.resize((512, 512), Image.LANCZOS).save(out)
    print("wrote", out)

def make_feature_graphic():
    W, H = 1024, 500
    canvas = vertical_gradient((W, H), PRIMARY, PRIMARY_DARK).convert("RGBA")
    ring = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ring)
    rd.ellipse([W * 0.72, -H * 0.55, W * 1.35, H * 0.85], outline=CREAM + (60,), width=10)
    rd.ellipse([W * 0.80, -H * 0.35, W * 1.20, H * 0.55], outline=CREAM + (40,), width=6)
    canvas.alpha_composite(ring)
    canvas = canvas.convert("RGB")
    draw = ImageDraw.Draw(canvas)

    logo = Image.open(LOGO_PATH).convert("RGBA")
    logo_size = int(H * 0.62)
    logo_bg = Image.new("RGBA", (logo_size + 40, logo_size + 40), (0, 0, 0, 0))
    ld = ImageDraw.Draw(logo_bg)
    ld.ellipse([0, 0, logo_size + 40, logo_size + 40], fill=CREAM + (255,))
    logo_resized = logo.resize((logo_size, logo_size), Image.LANCZOS)
    logo_bg.paste(logo_resized, (20, 20), logo_resized)
    canvas.paste(logo_bg, (int(W * 0.06), (H - logo_bg.height) // 2), logo_bg)

    title_font = font("Poppins-Bold.ttf", 72)
    tagline_font = font("Poppins-Medium.ttf", 30)
    text_x = int(W * 0.06) + logo_bg.width + 30
    draw.text((text_x, H * 0.30), "IncaCook", font=title_font, fill=CREAM)
    draw.text((text_x, H * 0.30 + 82), "Le goût de chez toi,\nprès de chez toi",
               font=tagline_font, fill=CREAM, spacing=10)

    out = os.path.join(OUT_DIR, "android", "feature_graphic_1024x500.png")
    canvas.save(out, quality=95)
    print("wrote", out)

def main():
    shots = sorted(os.listdir(SCREENSHOTS_DIR))
    jpgs = [f for f in shots if f.lower().endswith((".jpeg", ".jpg", ".png"))]
    jpgs.sort()
    # Order determined by inspecting content: welcome/login, seller dashboard,
    # driver map, address form (needs redaction).
    ordered = {
        "login": [f for f in jpgs if f.endswith("23.42.20 (1).jpeg")][0] if any(f.endswith("23.42.20 (1).jpeg") for f in jpgs) else None,
    }

    def find(suffix):
        for f in jpgs:
            if f.endswith(suffix):
                return os.path.join(SCREENSHOTS_DIR, f)
        return None

    screens = [
        (find("23.42.20 (1).jpeg"), "Commandez de bons petits plats\nfaits maison, près de chez vous", False, "01_login"),
        (find("23.42.20.jpeg"), "Devenez vendeur et gérez\nvotre activité facilement", False, "02_seller_dashboard"),
        (find("23.42.20 (2).jpeg"), "Devenez livreur et gagnez\nde l'argent à votre rythme", False, "03_driver_map"),
        (find("23.42.20 (3).jpeg"), "Une livraison précise,\ndirectement à votre porte", True, "04_address"),
    ]

    # Apple accepts 1284 × 2778 for the 6.7-inch iPhone screenshot slot.
    # Keep this exact size: App Store Connect rejects the former 1320 × 2868
    # canvas for the current listing configuration.
    IOS_SIZE = (1284, 2778)
    ANDROID_SIZE = (1080, 1920)  # Play Store phone screenshot, 9:16

    # Tablet/iPad sizes. Neither platform has a distinct tablet UI to
    # screenshot (this is a phone-first app), so these are the same phone
    # mockup + marketing headline, rendered onto a larger canvas — the
    # standard approach for apps without a bespoke tablet layout.
    ANDROID_TABLET_7IN_SIZE = (1440, 2560)  # Play "7-inch tablet" slot, exact 9:16
    # 12.9"/13" iPad display class. VERIFY against App Store Connect at
    # upload time — Apple has changed the mandatory iPad size more than
    # once; if Connect asks for a different size, edit IOS_IPAD_SIZE and
    # rerun rather than hand-resizing the output.
    IOS_IPAD_SIZE = (2048, 2732)

    for src, headline, redact, name in screens:
        if not src:
            print("MISSING source for", name)
            continue
        make_screenshot(src, headline, IOS_SIZE,
                         os.path.join(OUT_DIR, "ios", "screenshots_6.9in", f"{name}.png"), redact)
        make_screenshot(src, headline, ANDROID_SIZE,
                         os.path.join(OUT_DIR, "android", "screenshots_phone", f"{name}.png"), redact)
        make_screenshot(src, headline, ANDROID_TABLET_7IN_SIZE,
                         os.path.join(OUT_DIR, "android", "screenshots_tablet_7in", f"{name}.png"), redact)
        make_screenshot(src, headline, IOS_IPAD_SIZE,
                         os.path.join(OUT_DIR, "ios", "screenshots_ipad_12.9in", f"{name}.png"), redact)

    icon = make_icon_1024()
    make_icon_512(icon)
    make_feature_graphic()

if __name__ == "__main__":
    main()
