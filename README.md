# Joe Orchard — Programmer Portfolio

A static rebuild of the original Squarespace portfolio, ready to host free on GitHub Pages.
No build step, no framework, no JavaScript — three HTML files, one stylesheet, and the images.

## Structure

```
index.html            Game Projects  (was /)
software.html         Software Projects  (was /home-1)
about.html            About me  (was /new-page)
assets/css/style.css  All styling
assets/img/           Project images (pulled from the Squarespace CDN)
assets/files/         Dissertation PDF goes here
fetch-assets.sh       Re-downloads the images from the CDN
```

## Outstanding — the dissertation PDF

`assets/files/Automatic-asset-placement-paper.pdf` **is not yet present.** It is linked
from the main nav and from the Procedural Asset Spawning project, so both links 404
until the file is added.

It could not be downloaded automatically: the Squarespace trial has expired, so
`/s/Automatic-asset-placement-paper.pdf` returns 404 to anyone not logged in, and unlike
the images it is not served from the public CDN.

To add it, while still logged in to Squarespace:

1. Open the site's file manager, or visit
   `https://joeorchardprogrammerportfolio.squarespace.com/s/Automatic-asset-placement-paper.pdf`
   in the logged-in browser.
2. Save the PDF as `assets/files/Automatic-asset-placement-paper.pdf`.

Do this before the Squarespace login stops working — once the account lapses entirely,
the file is gone.

## Publishing to GitHub Pages

```bash
git init
git add .
git commit -m "Static rebuild of portfolio"
git branch -M main
git remote add origin https://github.com/<user>/<repo>.git
git push -u origin main
```

Then in the repo: **Settings → Pages → Source: Deploy from a branch → `main` / `(root)`**.

The site appears at `https://<user>.github.io/<repo>/` within a minute or two.

For a bare `https://<user>.github.io/` instead, name the repo `<user>.github.io`.

A `.nojekyll` file is included so GitHub serves the files as-is rather than running
them through Jekyll.

### Custom domain

Add a `CNAME` file containing the domain, then point DNS at GitHub Pages. Pages issues
the HTTPS certificate automatically.

## Editing

Everything is plain HTML. To add a project, copy an existing `<article class="project">`
block and change the text, image and `id`. If you add it to a page, add a matching entry
to that page's `<ul class="anchor-nav">` so it appears in the jump links at the top.

Colours and type live as custom properties at the top of `assets/css/style.css`:

| Token | Value | Use |
|---|---|---|
| `--bg` | `#5c5751` | page background |
| `--bg-raise` | `#66605a` | skill chips |
| `--bg-light` | `#ece8e3` | footer band |
| `--accent` | `#bdb2c3` | **decorative only** — rules, borders, underlines |
| `--accent-text` | `#d9d0e0` | any accent-coloured **text**, including links |
| `--font-head` | Manrope | headings |
| `--font-body` | Poppins | body text |

The palette and type were sampled from the live Squarespace site.

The two accent tokens matter: the original `#bdb2c3` manages only **3.5:1** against the
background, below the 4.5:1 WCAG AA minimum for body text. It is kept for borders and
underlines, where contrast rules do not apply, while text uses the lighter `#d9d0e0`
at **4.8:1**. If you change one, check the other.

Reading width is capped by `--prose` (72ch) so paragraphs stay legible while images
run full-bleed.

### Full-bleed images

Hero images and the dissertation gallery break out of the centred column and span the
whole viewport, via `margin-inline: calc(50% - 50vw)` on `.full-bleed`, `.project-hero`
and `.gallery`.

Two things make that work, and both will bite if changed:

- **`overflow-x: clip` on `html` and `body`** — `100vw` counts the scrollbar, so a
  full-bleed child overhangs the layout viewport by the scrollbar's width and would
  otherwise cause a horizontal scrollbar. It must be `clip`, **not `hidden`**: `hidden`
  makes the element a scroll container, which breaks the sticky header.
- **`max-height: 72vh` + `object-fit: cover` on hero images** — at full width a 16:9
  screenshot is taller than most screens. The two banner-strip images are shorter than
  the cap and are unaffected.

`.gallery--compact` (the Check List App screenshots) opts out. Those sources are only
386px wide, so spreading them across a wide monitor would upscale them into mush. It
bleeds out and then pads back in so the grid never exceeds 1240px, which puts each
image at ~400px — essentially native. Note that a plain `max-width` would not work,
because the element is laid out inside the 992px column and never reaches the cap.

## Notes on the rebuild

- Images are `.webp` — the CDN serves that format, and every current browser supports it.
  `fetch-assets.sh` pulls them at `?format=original` (1920–2500px wide), which is what
  full-bleed display needs. Do not drop back to `?format=1500w`: it is both smaller on
  screen and, oddly, slightly larger on disk.
- Header, nav and footer are duplicated across the three pages. With only three pages
  that is simpler than adding a build step; if the site grows, consider a static site
  generator.
- The original used Squarespace's Fluid Engine, which positions blocks on a free grid.
  The rebuild uses normal document flow, so long pages read the same but the fine
  positioning of some image groups differs slightly.
