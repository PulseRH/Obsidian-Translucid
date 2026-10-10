# Translucid theme build (UNLAYERED)
# Source of truth: _source.css  (meta + @settings + FEATURES-BELOW marker + features)
# Output: theme.css = settings + base + excalibrain + features, all UNLAYERED.
#
# Why unlayered: a theme wrapped in @layer loses the cascade to every unlayered
# snippet and to Obsidian's app.css, so backgrounds/transparency get overridden.
# Ordering is instead controlled by SOURCE POSITION: base first, feature sections
# after (so they override base) — same model the original snippets used.

$ErrorActionPreference = 'Stop'
$themeDir = $PSScriptRoot
$snips    = (Resolve-Path (Join-Path $themeDir '..\..\snippets')).Path
$themeCss = Join-Path $themeDir 'theme.css'
function ReadText($p) { [System.IO.File]::ReadAllText($p) }

# 1. Authored source -> split into settings (top) and features (after marker).
$src = ReadText (Join-Path $themeDir '_source.css')
$marker = '/* ==FEATURES-BELOW== */'
$mi = $src.IndexOf($marker)
if ($mi -lt 0) { throw "FEATURES-BELOW marker not found in _source.css" }
$settings = $src.Substring(0, $mi).TrimEnd()
$features = $src.Substring($mi + $marker.Length)

# 2. Strip @layer wrappers from the features region:
#    drop the `@layer NAME {` opener lines and the column-0 `}` closer lines
#    (in the authored region those are ONLY layer delimiters; rule closers are
#    indented). Leaves the inner rules unlayered.
$kept = New-Object System.Collections.Generic.List[string]
$dropOpen = 0; $dropClose = 0
foreach ($ln in ($features -split "`n")) {
  $t = $ln.TrimEnd([char]13)
  if ($t -match '^@layer\s+\w+\s*\{\s*$') { $dropOpen++; continue }
  if ($t -match '^\}\s*$')                { $dropClose++; continue }
  $kept.Add($t)
}
if ($dropOpen -ne $dropClose) { Write-Warning ("layer opener/closer mismatch: {0} vs {1}" -f $dropOpen,$dropClose) }
$featuresUnlayered = ($kept -join "`r`n")

# 3. Base theme: strip its @settings, exclude checkbox/radio from input-fill
#    (root-cause tick fix). NOT wrapped in a layer.
$base = ReadText (Join-Path $snips '[light transparnt theme] - combined fixed.css')
$base = [regex]::Replace($base, '/\*\s*@settings.*?\*/', '', 'Singleline')
$pairs = @(
  @("input,`ntextarea,`nselect,",                   "input:not([type=checkbox]):not([type=radio]),`ntextarea,`nselect,"),
  @("input:hover,`ntextarea:hover,`nselect:hover,", "input:not([type=checkbox]):not([type=radio]):hover,`ntextarea:hover,`nselect:hover,"),
  @("input:focus,`ntextarea:focus,`nselect:focus,", "input:not([type=checkbox]):not([type=radio]):focus,`ntextarea:focus,`nselect:focus,"),
  @("body input,`nbody textarea,`nbody select,",    "body input:not([type=checkbox]):not([type=radio]),`nbody textarea,`nbody select,"),
  @("body input:hover,`nbody textarea:hover,`nbody select:hover,", "body input:not([type=checkbox]):not([type=radio]):hover,`nbody textarea:hover,`nbody select:hover,"),
  @("body input:focus,`nbody textarea:focus,`nbody select:focus,", "body input:not([type=checkbox]):not([type=radio]):focus,`nbody textarea:focus,`nbody select:focus,")
)
foreach ($p in $pairs) {
  if ($base.Contains($p[0])) { $base = $base.Replace($p[0], $p[1]) }
  else { Write-Warning ("checkbox-exclude: pattern not found -> " + $p[0].Split([char]10)[0]) }
}

# 4. Excalibrain (scoped to its panes). NOT wrapped in a layer.
$exca = ReadText (Join-Path $snips '[light ttransparnt theme] edit (2) excalibrain embeds.css')

# 5. Emit: settings -> base -> excalibrain -> features (features override base).
$nl = "`r`n"
$out = $settings + $nl + $nl +
  '/* ===== BASE (light transparnt theme - combined fixed) ===== */' + $nl + $base + $nl + $nl +
  '/* ===== EXCALIBRAIN (scoped) ===== */' + $nl + $exca + $nl + $nl +
  '/* ===== FEATURES (override base by source order) ===== */' + $featuresUnlayered + $nl
[System.IO.File]::WriteAllText($themeCss, $out, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("Built theme.css ({0} KB), stripped {1} layer blocks" -f [math]::Round((Get-Item $themeCss).Length/1kb,1), $dropOpen)
