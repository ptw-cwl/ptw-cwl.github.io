# publish-bjh.ps1 - Baijiahao publish step (publish ONLY, no conversion)
# Flow: scan syndicate=true posts -> per platform entry where publish=true AND converted=true AND status!=published
#       -> read converted draft from scripts/.bjh_drafts/<safeTitle>.md -> publish -> write back pid/status/publishedAt
#
# Conversion and publishing are two independent steps (split design):
#   - convert-bjh.ps1 : prepares the platform-ready draft (converted=true, status=converted) into scripts/.bjh_drafts/. Run it first.
#   - publish-bjh.ps1 : this script. Only really publishes when platform entry publish=true AND converted=true,
#                       and reads the draft produced by convert-bjh.ps1 (no re-conversion here).
#
# Credentials: read from env vars ONLY. Never write secrets into this file or any committed file (see rule 08: sensitive-info protection).
#   $env:BJH_COOKIE  Baijiahao login Cookie
#   $env:BJH_TOKEN   Baijiahao API Token (if using official API)
#
# Publish mode (pick one, implement Invoke-BjhPublish):
#   (a) official open-platform API  (b) Cookie-based web API  (c) publish externally only (default, no real publish)
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\publish-bjh.ps1
#   powershell -ExecutionPolicy Bypass -File scripts\publish-bjh.ps1 -OnlyPending   # draft/failed only

param(
    [switch]$OnlyPending
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$platform = "baijiahao"
$draftOutDir = Join-Path $root "scripts\.bjh_drafts"   # converted drafts, git-ignored
if (-not (Test-Path $draftOutDir)) { New-Item -ItemType Directory -Path $draftOutDir | Out-Null }

# ---------- front matter read/write ----------
function Read-FrontMatterRange {
    param([string]$FilePath)
    $lines = Get-Content -Path $FilePath -Encoding UTF8
    $start = -1; $end = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') {
            if ($start -eq -1) { $start = $i } else { $end = $i; break }
        }
    }
    return @{ start = $start; end = $end; lines = $lines }
}

function Get-Syndicate {
    param([string[]]$lines, [int]$start, [int]$end)
    for ($i = $start + 1; $i -lt $end; $i++) {
        if ($lines[$i] -match '^\s*syndicate\s*:\s*(\w+)') { return ($Matches[1] -match 'true') }
    }
    return $false
}

function Get-PlatformEntryRange {
    param([string[]]$lines, [string]$Platform)
    $nameLine = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^\s*-\s*name\s*:\s*$Platform\s*$") { $nameLine = $i; break }
    }
    if ($nameLine -eq -1) { return $null }
    $endLine = $lines.Count
    for ($j = $nameLine + 1; $j -lt $lines.Count; $j++) {
        if ($lines[$j] -match '^\s*-\s*name\s*:') { $endLine = $j; break }
        if ($lines[$j] -match '^\s*[A-Za-z_]+:') { break }
    }
    return @{ nameLine = $nameLine; endLine = $endLine }
}

function Ensure-PlatformEntry {
    param([string[]]$lines, [int]$start, [int]$end, [string]$Platform)
    $r = Get-PlatformEntryRange -lines $lines -Platform $Platform
    if ($null -ne $r) { return $lines }
    $platLine = -1
    for ($i = $start + 1; $i -lt $end; $i++) { if ($lines[$i] -match '^\s*platforms\s*:') { $platLine = $i; break } }
    $entry = @('  - name: ' + $Platform, '    publish: false', '    converted: false', '    pid: ""', '    status: draft', '    publishedAt: ""', '    url: ""')
    if ($platLine -ge 0) {
        $lines = $lines[0..$platLine] + $entry + $lines[($platLine + 1)..($lines.Count - 1)]
    } else {
        $ins = -1
        for ($i = $start + 1; $i -lt $end; $i++) { if ($lines[$i] -match '^\s*syndicate\s*:') { $ins = $i; break } }
        if ($ins -eq -1) { $ins = $end - 1 }
        $lines = $lines[0..$ins] + @('platforms:', $entry[0], $entry[1], $entry[2], $entry[3], $entry[4], $entry[5]) + $lines[($ins + 1)..($lines.Count - 1)]
    }
    return $lines
}

function Set-PlatformField {
    param([string[]]$lines, [string]$Platform, [string]$Field, [string]$Value)
    $r = Get-PlatformEntryRange -lines $lines -Platform $Platform
    if ($null -eq $r) { return $lines }
    $set = $false
    for ($i = $r.nameLine; $i -lt $r.endLine; $i++) {
        if ($lines[$i] -match "^\s*$Field\s*:") {
            $lines[$i] = "    $Field`: $Value"
            $set = $true; break
        }
    }
    if (-not $set) {
        $lines = $lines[0..$r.nameLine] + @("    $Field`: $Value") + $lines[($r.nameLine + 1)..($lines.Count - 1)]
    }
    return $lines
}

function Get-PlatformField {
    param([string[]]$lines, [string]$Platform, [string]$Field)
    $r = Get-PlatformEntryRange -lines $lines -Platform $Platform
    if ($null -eq $r) { return "" }
    for ($i = $r.nameLine; $i -lt $r.endLine; $i++) {
        if ($lines[$i] -match "^\s*$Field\s*:\s*""?([^""\n]*)""?") { return $Matches[1].Trim() }
    }
    return ""
}

# ---------- publish interface (implement per mode) ----------
function Invoke-BjhPublish {
    param([string]$Title, [string]$Content)
    # (c) default: write converted draft to local dir, publish externally
    $safeTitle = ($Title -replace '[\\/:*?"<>|]', '_')
    $outPath = Join-Path $draftOutDir ($safeTitle + ".md")
    Set-Content -Path $outPath -Value $Content -Encoding UTF8
    Write-Host ("  draft generated (external publish): " + $outPath) -ForegroundColor Cyan
    # (a)/(b) skeleton:
    # if (-not $env:BJH_COOKIE -and -not $env:BJH_TOKEN) { throw "missing env BJH_COOKIE/BJH_TOKEN" }
    # $resp = ... call Baijiahao API ...
    # return @{ pid = $resp.id; url = $resp.url; ok = $true }
    return @{ pid = ""; url = ""; ok = $true }
}

# ---------- main ----------
$sections = @()
$hugoToml = Join-Path $root "hugo.toml"
if (Test-Path $hugoToml) {
    $toml = Get-Content -Path $hugoToml -Encoding UTF8 -Raw
    if ($toml -match 'loadSections\s*=\s*\[(.*?)\]') {
        foreach ($s in ($Matches[1] -split ',')) {
            $s = $s.Trim().Trim("'").Trim('"')
            if ($s -ne '') { $sections += $s }
        }
    }
}
if ($sections.Count -eq 0) { $sections = @('posts', 'about') }

$processed = 0
foreach ($sec in $sections) {
    $dir = Join-Path $root "content\$sec"
    if (-not (Test-Path $dir)) { continue }
    foreach ($file in (Get-ChildItem -Path $dir -Filter *.md)) {
        $r = Read-FrontMatterRange -FilePath $file.FullName
        if ($r.start -eq -1 -or $r.end -eq -1) { continue }
        if (-not (Get-Syndicate -lines $r.lines -start $r.start -end $r.end)) {
            Write-Host ("SKIP (syndicate!=true): " + $file.Name) -ForegroundColor DarkGray
            continue
        }
        $r.lines = Ensure-PlatformEntry -lines $r.lines -start $r.start -end $r.end -Platform $platform

        # platform-level publish switch: default false = never really publish
        $publish = Get-PlatformField -lines $r.lines -Platform $platform -Field 'publish'
        if ($publish -ne 'true') {
            Write-Host ("SKIP (publish!=true): " + $file.Name) -ForegroundColor DarkGray
            continue
        }

        $status = Get-PlatformField -lines $r.lines -Platform $platform -Field 'status'
        if ($status -eq 'published') {
            Write-Host ("SKIP (already published): " + $file.Name) -ForegroundColor DarkGray
            continue
        }
        if ($OnlyPending -and $status -ne 'draft' -and $status -ne 'failed') { continue }

        # conversion is a separate step; this script only publishes already-converted drafts
        $converted = Get-PlatformField -lines $r.lines -Platform $platform -Field 'converted'
        if ($converted -ne 'true') {
            Write-Host ("SKIP (not converted, run convert-bjh.ps1 first): " + $file.Name) -ForegroundColor Yellow
            continue
        }

        $title = ""
        for ($i = $r.start + 1; $i -lt $r.end; $i++) { if ($r.lines[$i] -match '^\s*title\s*:\s*"(.*)"') { $title = $Matches[1]; break } }

        # read the converted draft produced by convert-bjh.ps1 (conversion is a separate step)
        $safeTitle = ($title -replace '[\\/:*?"<>|]', '_')
        $draftPath = Join-Path $draftOutDir ($safeTitle + ".md")
        if (-not (Test-Path $draftPath)) {
            Write-Host ("SKIP (converted draft missing, run convert-bjh.ps1 first): " + $file.Name) -ForegroundColor Yellow
            continue
        }
        $body = Get-Content -Path $draftPath -Encoding UTF8 -Raw

        Write-Host ("publishing: " + $file.Name) -ForegroundColor Cyan
        try {
            $resp = Invoke-BjhPublish -Title $title -Content $body
            if ($resp.ok) {
                $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'status' -Value 'published'
                if ($resp.pid -ne '') { $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'pid' -Value $resp.pid }
                if ($resp.url -ne '') { $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'url' -Value $resp.url }
                $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'publishedAt' -Value (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
                Write-Host ("  published: " + $file.Name) -ForegroundColor Green
                $processed++
            } else {
                $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'status' -Value 'failed'
                Write-Host ("  FAILED: " + $file.Name) -ForegroundColor Red
            }
        } catch {
            $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'status' -Value 'failed'
            Write-Host ("  ERROR: " + $_) -ForegroundColor Red
        }
        Set-Content -Path $file.FullName -Value $r.lines -Encoding UTF8
    }
}

Write-Host ("DONE: processed " + $processed + " post(s)") -ForegroundColor Cyan
Write-Host "NOTE: after pid/status rollback, git commit to dev branch (do NOT auto-push main)." -ForegroundColor Yellow
