# Translucid theme build. All inputs live alongside this script.
# Output is unlayered: settings -> base -> Excalibrain -> feature overrides.
# CSS layers would lose the cascade to Obsidian and unlayered user snippets.
$ErrorActionPreference = 'Stop'
$themeDir = $PSScriptRoot
function ReadText($name) {
  [System.IO.File]::ReadAllText((Join-Path $themeDir $name))
}

$src = ReadText '_source.css'
$marker = '/* ==FEATURES-BELOW== */'
$mi = $src.IndexOf($marker)
if ($mi -lt 0) { throw 'FEATURES-BELOW marker not found in _source.css' }
$settings = $src.Substring(0, $mi).TrimEnd()
$features = $src.Substring($mi + $marker.Length)

# Source layer delimiters are column-0; rule closers are indented.
$kept = New-Object System.Collections.Generic.List[string]
$dropOpen = 0
$dropClose = 0
foreach ($ln in ($features -split "`n")) {
  $t = $ln.TrimEnd([char]13)
  if ($t -match '^@layer\s+\w+\s*\{\s*$') { $dropOpen++; continue }
  if ($t -match '^\}\s*$') { $dropClose++; continue }
  $kept.Add($t)
}
if ($dropOpen -ne $dropClose) {
  throw "Layer opener/closer mismatch: $dropOpen vs $dropClose"
}
$featuresUnlayered = $kept -join "`r`n"

# These theme-owned sources already include the checkbox, modal-width and
# Excalibrain selector fixes. No vault snippets or build-time rewrites needed.
$base = ReadText '_base.css'
$exca = ReadText '_excalibrain.css'
$nl = "`r`n"
$out = $settings + $nl + $nl +
  '/* ===== BASE (light transparnt theme - combined fixed) ===== */' + $nl + $base + $nl + $nl +
  '/* ===== EXCALIBRAIN (scoped) ===== */' + $nl + $exca + $nl + $nl +
  '/* ===== FEATURES (override base by source order) ===== */' + $featuresUnlayered + $nl
$themeCss = Join-Path $themeDir 'theme.css'
[System.IO.File]::WriteAllText($themeCss, $out, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("Built theme.css ({0} KB), stripped {1} layer blocks" -f [math]::Round((Get-Item $themeCss).Length/1kb,1), $dropOpen)
