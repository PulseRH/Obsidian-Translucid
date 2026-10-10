# Translucid

A translucent glass theme for Obsidian, consolidated from 13 personal snippets.

## Files
- `_source.css` — **the authored source. Edit this**, then rebuild. Contains the
  Style Settings panel and all feature sections (below the `==FEATURES-BELOW==`
  marker).
- `theme.css` — generated output that Obsidian loads. **Do not hand-edit** — it is
  overwritten by every build.
- `_build.ps1` — assembles `theme.css` from `_source.css` + the source snippets.
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
- **Base** ("combined fixed") and **Excalibrain** are pulled verbatim from
  `../snippets/` and inserted ahead of the features by the build.

## Feature toggles
Open **Settings → Style Settings → Translucid**. Each optional feature is a
`class-toggle` that adds a `body.tld-*` class the CSS keys off. Defaults reproduce
the previous snippet setup.

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
