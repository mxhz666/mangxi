# ============================================================
#  scripts/build.ps1 - called by publish.bat
#  Reads works.json + scans assets/ (recursively) for videos.
#  Category comes from the FIRST subfolder name under assets/,
#  mapped via categories.json (English or Chinese folder names both work).
#  Top-level videos default to 'brand'.
#  Keep this file ASCII-only so Windows PowerShell 5.1 reads it correctly.
# ============================================================

$ErrorActionPreference = 'Stop'
$root     = Split-Path -Parent $PSScriptRoot          # portfolio folder
$jsonPath = Join-Path $root 'works.json'
$assets   = Join-Path $root 'assets'
$outJs    = Join-Path $root 'js\works.js'
$catPath  = Join-Path $root 'categories.json'

# 1) read existing works.json
#    PS 5.1 quirk: ConvertFrom-Json '[]' may return $null. Guard it, then drop empty entries.
$works = @()
if (Test-Path $jsonPath) {
  $raw = Get-Content $jsonPath -Raw -Encoding UTF8
  if ($raw -and $raw.Trim()) {
    $tmp = ConvertFrom-Json $raw
    if ($null -ne $tmp) { $works = @($tmp) }
  }
}
$works = @($works | Where-Object {
  if (-not ($_ -and $_.src -and ([string]$_.src).Trim() -ne '')) { return $false }
  $src = [string]$_.src
  if ($src -match '^assets/') {
    $fp = Join-Path $root ($src -replace '/', '\')
    if (-not (Test-Path $fp)) { return $false }   # drop entries whose file was moved/deleted
  }
  return $true
})

# 2) category lookup: folder name -> category key
$catLookup = @{}
foreach ($c in @('apparel','brand','chinese','american','ecommerce')) { $catLookup[$c] = $c }
if (Test-Path $catPath) {
  $map = Get-Content $catPath -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($p in $map.PSObject.Properties) { $catLookup[[string]$p.Name] = [string]$p.Value }
}

# 2.5) find ffmpeg (for auto cover extraction)
$ffmpeg = $null
foreach ($cand in @('C:\Program Files\Red Giant\Trapcode Suite\Tools\ffmpeg.exe')) {
  if (-not $ffmpeg -and (Test-Path $cand)) { $ffmpeg = $cand }
}
if (-not $ffmpeg) {
  $cmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
  if ($cmd) { $ffmpeg = $cmd.Source }
}

# 3) scan assets/ recursively for videos, auto-add the ones not referenced yet
$exts = @('.mp4','.mov','.webm','.m4v','.mkv','.avi')
$year = (Get-Date).Year
$used = @{}
foreach ($w in $works) {
  if ($w.src -match '^assets/') { $used[$w.src.ToLower()] = $true }
}

if (Test-Path $assets) {
  Get-ChildItem $assets -File -Recurse |
    Where-Object { $exts -contains $_.Extension.ToLower() } |
    Sort-Object FullName |
    ForEach-Object {
      $relFromAssets = $_.FullName.Substring($assets.Length + 1)   # e.g. apparel\01.mp4
      $rel = 'assets/' + ($relFromAssets -replace '\\', '/')
      if (-not $used.ContainsKey($rel.ToLower())) {
        $parts = $relFromAssets -split '\\'
        $folder = ''
        if ($parts.Count -gt 1) { $folder = $parts[0] }
        $cat = 'brand'
        if ($folder -and $catLookup.ContainsKey($folder)) { $cat = $catLookup[$folder] }
        $works += [pscustomobject]@{
          title = $_.BaseName
          cat   = $cat
          src   = $rel
          meta  = ''
        }
        $used[$rel.ToLower()] = $true
      }
    }
}

# 3.5) auto-generate covers (first frame) for every entry whose video exists
$rebuilt = @()
foreach ($w in $works) {
  $cover = [string]$w.cover
  $ratio = [string]$w.ratio
  $fullPath = $null
  if ($w.src -match '^assets/') { $fullPath = Join-Path $root ($w.src -replace '/', '\') }
  if ($fullPath -and (Test-Path $fullPath)) {
    # prefer a user-provided same-named image as the cover
    if (-not $cover) {
      $dirFull = [System.IO.Path]::GetDirectoryName($fullPath)
      $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fullPath)
      foreach ($ce in @('.jpg','.jpeg','.png','.webp')) {
        if (Test-Path (Join-Path $dirFull ($baseName + $ce))) {
          $cover = ($w.src -replace '\.[^.]+$', $ce)
          break
        }
      }
    }
    # else auto-generate the first frame with ffmpeg
    if (-not $cover -and $ffmpeg) {
      try {
        $coverFile = [System.IO.Path]::ChangeExtension($fullPath, '.jpg')
        if (-not (Test-Path $coverFile)) {
          & $ffmpeg -y -ss 1 -i $fullPath -frames:v 1 -q:v 3 -loglevel quiet $coverFile 2>$null
        }
        if (Test-Path $coverFile) { $cover = ($w.src -replace '\.[^.]+$', '.jpg') }
      } catch { }
    }
    if (-not $ratio -and $ffmpeg) {
      try {
        $probe = (& $ffmpeg -hide_banner -i $fullPath 2>&1 | Out-String)
        $mm = [regex]::Match($probe, '(\d{2,5})x(\d{2,5})')
        if ($mm.Success) {
          $wd = [int]$mm.Groups[1].Value
          $ht = [int]$mm.Groups[2].Value
          if ($wd -gt 0 -and $ht -gt 0) { if ($wd -lt $ht) { $ratio = '3/4' } else { $ratio = '4/3' } }
        }
      } catch { }
    }
  }
  $rebuilt += [pscustomobject]@{
    title = [string]$w.title
    cat   = [string]$w.cat
    src   = [string]$w.src
    meta  = [string]$w.meta
    cover = $cover
    ratio = $ratio
  }
}
$works = $rebuilt

# warn about entries whose asset file is missing
foreach ($w in $works) {
  if ($w.src -match '^assets/') {
    $p = Join-Path $root ($w.src -replace '/', '\')
    if (-not (Test-Path $p)) {
      Write-Host ("WARN: file not found - " + $w.src + "  (title: " + $w.title + ")")
    }
  }
}

# 4) serialize to a JSON array string + a JS array string
function Esc([string]$s) {
  return $s.Replace('\', '\\').Replace('"', '\"')
}

$jsonItems = @()
$jsItems   = @()
foreach ($w in $works) {
  $t = Esc $w.title
  $c = Esc $w.cat
  $s = Esc $w.src
  $m = Esc $w.meta
  $cv = Esc $w.cover
  $rt = Esc $w.ratio
  $jsonItems += "  { `"title`": `"$t`", `"cat`": `"$c`", `"src`": `"$s`", `"meta`": `"$m`", `"cover`": `"$cv`", `"ratio`": `"$rt`" }"
  $jsItems   += "  { `"title`": `"$t`", `"cat`": `"$c`", `"src`": `"$s`", `"meta`": `"$m`", `"cover`": `"$cv`", `"ratio`": `"$rt`" }"
}

$jsonContent = "[" + "`r`n" + ($jsonItems -join ",`r`n") + "`r`n]" + "`r`n"
$jsContent   = "/* AUTO-GENERATED by build.ps1 - edit works.json, not this file. */" + "`r`n" +
               "const WORKS = [" + "`r`n" + ($jsItems -join ",`r`n") + "`r`n];" + "`r`n"

# 5) write files (UTF-8, no BOM)
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($jsonPath, $jsonContent, $utf8)
[System.IO.File]::WriteAllText($outJs, $jsContent, $utf8)

# 6) cache-bust works.js in index.html so browsers always fetch the latest data
$indexPath = Join-Path $root 'index.html'
if (Test-Path $indexPath) {
  $idx = Get-Content $indexPath -Raw -Encoding UTF8
  $ver = (Get-Date -Format 'yyyyMMddHHmmss')
  $new = $idx -replace 'js/works\.js(\?v=[0-9]+)?', ('js/works.js?v=' + $ver)
  if ($new -ne $idx) { [System.IO.File]::WriteAllText($indexPath, $new, $utf8) }
}

Write-Host ("OK: " + $works.Count + " works -> js/works.js")
