# Translucid

A translucent glass theme for Obsidian, consolidated from 13 personal snippets.

## Files
- `_source.css` — **the authored source. Edit this**, then rebuild. Contains the
  Style Settings panel and all feature sections (below the `==FEATURES-BELOW==`
  marker).
- `theme.css` — generated output that Obsidian loads. **Do not hand-edit** — it is
  overwritten by every build.
- `_base.css` — theme-owned base glass styles, with existing fixes applied.
- `_excalibrain.css` — theme-owned, scoped Excalibrain styles.
- `_build.ps1` — assembles `theme.css` from these three local source files.
- `manifest.json` — theme metadata.

## Architecture
The theme is a normal **unlayered** stylesheet. Ordering is by SOURCE POSITION —
the build emits base first, then features, so features override the base:

```
settings (from _source) → base → excalibrain → features (from _source)
```

We deliberately do **not** use CSS `@layer`: a layered theme loses the cascade to
every unlayered snippet and to Obsidian's `app.css`, which caused backgrounds and
transparency to be overridden (image only showing on the ribbon/right sidebar).

- **Features** live in `_source.css` below the `==FEATURES-BELOW==` marker, each
  gated behind a `body.tld-*` class that Style Settings toggles.
- **Base** and **Excalibrain** live in `_base.css` and `_excalibrain.css` in this
  repository and are inserted ahead of the features by the build. No files from
  the `.obsidian/snippets` directory are needed or read.

## Feature toggles
Open **Settings → Style Settings → Translucid**. Each optional feature is a
`class-toggle` that adds a `body.tld-*` class the CSS keys off. Defaults reproduce
the previous snippet setup.

### Bases
Under **Style Settings → Translucid → Bases**, enable frosted backgrounds and
zebra rows for table, cards and list views. Adjust the blur strength and toggle
horizontal and vertical centering independently (centering is off by default).
Choose **Bases zebra direction** for horizontal rows, vertical columns, or both
as a checkerboard or stacked crosshatch bands. Crosshatch fills alternating
whole rows and columns; their intersections stack two tints for a stronger shade.
Horizontal and crosshatch row bands are anchored to the table body's logical
row positions, so scrolling and recycled row elements do not flip their tint.
Frost sits on a stationary layer behind the Bases scroller, reducing blur work
as virtualized rows appear. Bases still controls when new rows and images load.
The other modes use one tint per cell. Cards and lists keep alternating items.
Grouped table titles alternate by group. Sticky column headers follow the
selected zebra direction, including stacked crosshatch shading.
The native inter-group gap stays intact and shares the following group title's
shading, so the space above each heading blends into that header.
Enable **Hide Bases table lines** to remove the grid and outer table borders
while preserving zebra fills, resize handles and active-cell indicators.
Linked aliases center on their visible label while the edit pencil stays at
the cell edge. Use **Bases text size** and **Bases row height** to adjust scale.
The table keeps native scrolling, resizing, editing and selection indicators.

### Notebook Navigator indentation guides
Enable **Style Settings → Translucid → Plugins → Notebook Navigator gradient
zebra guides**, then adjust shading colour and strength. Notebook Navigator's
**Show indent guides** setting must also be enabled. Horizontal gradients fade
across each indentation column and alternate by nesting depth. Native guide
lines, row heights, selection and click targets are retained; RTL fades reverse.

### Extended Base
Support activates automatically when the Extended Base plugin renders its
Notion-style table, list, board or feed views. It uses the existing Bases frost,
zebra, text-size and alignment settings; table views also support row height,
grid-line hiding and all zebra directions. Pill and group colors stay intact.
Image-only table cells have no padding or inline-image baseline gap. Extended
Base covers scale with the column width at their natural aspect ratio, including
while dragging narrower. Native Bases covers fit proportionally inside its
fixed-height rows, allowing empty space instead of cropping. Text cells keep padding.
Enable **Style Settings → Translucid → Bases → Disable Extended Base support**
to keep the plugin's own view styling. No plugin files are modified.

### Layout widths
The **Layout widths** section has sliders for the **Settings modal width**
(Obsidian 1.13 sizes it with `--modal-width`/`--modal-max-width`, stock 90vw
capped at 1100px) and the **Settings sidebar width** — the left navigation
column inside the Settings window (stock: 25% clamped to 200–250px).

### K-Plex compatibility
The **K-Plex** plugin (`k-plex`, view types `k-plex-react-view` / `k-plex-sidepanel-view`)
ships an opaque `#0d1219` app root, `.98/.99` gradient chrome and a gradient vignette
over the plex canvas. With **K-Plex transparent background** on (default), the view
chain is made transparent so the theme background image shows through the graph,
and the topbar, content sidecar, search palette, relation modal, info bubbles and
history bar become frosted glass instead. Node cards keep their own fills.

## Root-cause fixes applied (not band-aids)
- **Checkboxes**: the base `input { background: … }` shorthand wiped the native
  tick. The build excludes `[type=checkbox]/[type=radio]` from those fill rules, so
  native rendering returns. The old `check box tick fix` snippet is gone.
- **Status bar**: no longer hardcodes `right: 460px`; anchored inside the root
  workspace split so it tracks the sidebar's real width. ⚠️ verify in-app.
- **Note embeds**: `note Embed overhaul 2` scoped to `.markdown-embed:not(.image-embed):not(.media-embed)`
  so image/PDF/plugin embeds are untouched.
- **Scrollbars**: frosted/translucent, with an optional active-pane-hover-only mode.

## Rebuild
```powershell
& ".obsidian/themes/Translucid/_build.ps1"
```

## Known v0.1 notes
- **Excalibrain** feature is always-on (scoped to Excalibrain panes). A dedicated
  toggle is deferred because the snippet defines `:root` / `body.theme-light` blocks
  that don't survive simple body-class nesting.
- Requires the **Style Settings** plugin for the gated features to appear.
