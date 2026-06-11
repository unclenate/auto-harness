<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# `docs/_assets/` — book covers and shared image assets

This directory holds visual assets used by GitBook for PDF / print export
and any other shared images referenced from prose pages.

## Inventory

| Asset | Purpose | Dimensions |
|-------|---------|------------|
| [`cover-front.svg`](cover-front.svg) | Front cover for PDF / print export | 1600 × 2400 (2:3 ratio) |
| [`cover-back.svg`](cover-back.svg) | Back cover for PDF / print export | 1600 × 2400 (2:3 ratio) |

Both covers are vector (SVG) and scale cleanly to any output size:

- US Letter (8.5 × 11 in)
- A4 (210 × 297 mm)
- Trade paperback (6 × 9 in)
- Digital ebook (1600 × 2400 px native)

## Style

**Bold typography + geometric module-composition motif** (per the
design pass that selected this direction). The front cover's geometric
element is a stylized nested-rectangle stack representing the
`manifest → modules → contract → validators` layering from
[diagram 1](../architecture/diagrams.md#1-component-composition).

**Palette:**

- Background: `#f6f4ee` (warm off-white; prints with less ink than
  full-bleed dark covers)
- Primary type: `#0e1c2e` (near-black)
- Accent: `#1f3a5f` (deep slate; used for accent bars, rules, and
  filled emphasis elements)
- Secondary type: `#3a4a5e` (slightly lighter slate for hierarchy)

**Fonts (CSS / SVG generic families):**

- Display / title type: `Georgia, 'Times New Roman', serif`
- Body / metadata: `Helvetica, Arial, sans-serif`
- Code / monospace accents: `Menlo, Consolas, monospace`

Each cover is one self-contained SVG file with no external dependencies.

## How GitBook uses these

GitBook does not have a fixed "cover image" config field at the moment;
PDF export typically uses the first page of the book as the de-facto
cover when none is configured. To make the covers explicit:

- The book's first internal page can reference `cover-front.svg` as an
  embedded image if a hero is wanted on the web.
- For PDF export via GitBook's export tooling, point the cover-image
  config (if available in your GitBook tier) at
  `docs/_assets/cover-front.svg`.
- For print runs done outside GitBook (e.g., Lulu, Blurb,
  IngramSpark), upload `cover-front.svg` and `cover-back.svg`
  directly as the print-cover assets.

## Updating

- **Version bump:** edit the `v1.0` and `2026` text near the bottom of
  each SVG.
- **Catalog count refresh** (back cover): the counts (`52 modules`,
  `84 templates`, `17 validators`, etc.) need to be updated by hand when
  the catalog grows. Keep in sync with
  [`platform/reference/how-to-read.md`](../../platform/reference/how-to-read.md)
  and [`docs/architecture/diagrams.md`](../architecture/diagrams.md#1-component-composition).
- **Style change:** swap the four palette hex codes consistently across
  both covers. The SVGs are designed to be easy to recolor without
  re-flowing the layout.

## Why SVG (not PNG)

- **Versionable** — SVG is text; diffs are reviewable.
- **Scalable** — never pixellates at any size or DPI.
- **Toolchain-free** — no Photoshop / Figma / Sketch round-trip; edit
  in any text editor.
- **Print-ready** — modern print services accept SVG directly.

If a downstream tool requires raster (PNG) covers, render with
`rsvg-convert` or any similar SVG renderer:

```bash
rsvg-convert -w 1600 cover-front.svg -o cover-front.png
rsvg-convert -w 1600 cover-back.svg  -o cover-back.png
```
