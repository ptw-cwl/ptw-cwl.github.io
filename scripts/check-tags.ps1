# =============================================
# tags registration check (check-tags)
# Scans content/posts/*.md front matter tags, ensures each tag is
# registered in data/tag_display.yaml. Exits 1 if any tag is missing.
#
# Usage (run at repo root):
#   powershell -ExecutionPolicy Bypass -File scripts\check-tags.ps1
# =============================================

$ErrorActionPreference = "Stop"

function Parse-TagDisplay {
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path $Path)) {
        Write-Host "WARN: $Path not found, treating all tags as unregistered" -ForegroundColor Yellow
        return $map
    }
    foreach ($line in (Get-Content -Path $Path -Encoding UTF8)) {
        if ($line -match '^\s*#|^\s*$') { continue }
        if ($line -match '^\s*(?<k>[A-Za-z0-9_-]+)\s*:\s*"?(.+?)"?\s*$') {
            $map[$Matches['k']] = $true
        }
    }
    return $map
}

function Get-FrontMatterTags {
    param([string]$Path)
    $text = Get-Content -Path $Path -Encoding UTF8 -Raw
    if ($text -notmatch '(?s)---\s*\n(.*?)\n---') {
        return @()
    }
    $fm = $Matches[1]
    if ($fm -notmatch '(?s)tags\s*:\s*\[(.*?)\]') {
        return @()
    }
    $raw = $Matches[1]
    $tags = @()
    # match quoted tag values, avoiding literal double-quotes in source
    $pattern = [regex]::new('\x22([^\x22]*)\x22')
    foreach ($m in $pattern.Matches($raw)) {
        if ($m.Groups[1].Value -ne '') { $tags += $m.Groups[1].Value }
    }
    return $tags
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$tagDisplayPath = Join-Path $root "data\tag_display.yaml"
$postsDir = Join-Path $root "content\posts"

$registered = Parse-TagDisplay -Path $tagDisplayPath

if (-not (Test-Path $postsDir)) {
    Write-Host "WARN: posts dir not found: $postsDir" -ForegroundColor Yellow
    exit 0
}

$unregistered = @()
$badFiles = @{}

foreach ($file in (Get-ChildItem -Path $postsDir -Filter *.md)) {
    $tags = Get-FrontMatterTags -Path $file.FullName
    $missing = @()
    foreach ($t in $tags) {
        if (-not $registered.ContainsKey($t)) {
            $missing += $t
            if (-not $unregistered.Contains($t)) { $unregistered += $t }
        }
    }
    if ($missing.Count -gt 0) {
        $badFiles[$file.Name] = $missing
    }
}

if ($badFiles.Count -eq 0) {
    Write-Host "OK: all post tags are registered in data/tag_display.yaml" -ForegroundColor Green
    exit 0
}

Write-Host "FAIL: found unregistered tags, please add them to data/tag_display.yaml" -ForegroundColor Red
Write-Host ""
foreach ($kv in $badFiles.GetEnumerator()) {
    Write-Host "  $($kv.Key)" -ForegroundColor Red
    foreach ($t in $kv.Value) {
        Write-Host "    - unregistered: $t" -ForegroundColor Red
    }
}
Write-Host ""
Write-Host "Fix: add Chinese display names in data/tag_display.yaml, e.g."
foreach ($t in $unregistered) {
    Write-Host "  $t : `"fill-chinese-name`"" -ForegroundColor Yellow
}
exit 1
