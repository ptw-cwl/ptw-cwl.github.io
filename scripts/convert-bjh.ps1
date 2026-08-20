# convert-bjh.ps1 - Convert posts to Baijiahao style (convert ONLY, no publish)
# Flow: scan syndicate=true posts -> per platform entry where converted=false -> convert -> write back converted=true, status=converted
#
# Split from publish-bjh.ps1: conversion and publishing are two independent steps.
#   - convert-bjh.ps1  : prepares the platform-ready draft (sets converted=true, status=converted). Never really publishes.
#   - publish-bjh.ps1  : only really publishes when the platform entry has publish=true AND converted=true.
#
# Credentials: none needed for conversion. (see rule 08: sensitive-info protection)
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\convert-bjh.ps1
#   powershell -ExecutionPolicy Bypass -File scripts\convert-bjh.ps1 -OnlyPending   # draft/converting only

param(
    [switch]$OnlyPending
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$platform = "baijiahao"

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

function Get-Body {
    param([string]$FilePath, [int]$fmEnd)
    $lines = Get-Content -Path $FilePath -Encoding UTF8
    return ($lines[($fmEnd + 1)..($lines.Count - 1)] -join "`n")
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
        $lines = $lines[0..$ins] + @('platforms:', $entry[0], $entry[1], $entry[2], $entry[3], $entry[4], $entry[5], $entry[6]) + $lines[($ins + 1)..($lines.Count - 1)]
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

# ---------- style conversion (anti-duplicate) ----------
function Convert-ToBjhStyle {
    param([string]$Title, [string]$Body)
    $intro = "[Digest] This article shares: " + $Title + ". Reorganized below in a more conversational tone for Baijiahao readers."
    $out = $intro + "`n`n" + $Body
    return $out
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
        $status = Get-PlatformField -lines $r.lines -Platform $platform -Field 'status'
        if ($status -eq 'published') {
            Write-Host ("SKIP (already published): " + $file.Name) -ForegroundColor DarkGray
            continue
        }
        # reset a stuck 'converting' state left by an interrupted previous run, so it can be retried
        if ($status -eq 'converting') {
            Write-Host ("reset stuck 'converting' -> draft: " + $file.Name) -ForegroundColor Yellow
            $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'status' -Value 'draft'
            $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'converted' -Value 'false'
            Set-Content -Path $file.FullName -Value $r.lines -Encoding UTF8
            $status = 'draft'
        }
        if ($OnlyPending -and $status -ne 'draft') { continue }

        $converted = Get-PlatformField -lines $r.lines -Platform $platform -Field 'converted'
        if ($converted -eq 'true') {
            Write-Host ("SKIP (already converted): " + $file.Name) -ForegroundColor DarkGray
            continue
        }

        $title = ""
        for ($i = $r.start + 1; $i -lt $r.end; $i++) { if ($r.lines[$i] -match '^\s*title\s*:\s*"(.*)"') { $title = $Matches[1]; break } }
        $body = Get-Body -FilePath $file.FullName -fmEnd $r.end

        Write-Host ("converting: " + $file.Name) -ForegroundColor Cyan
        $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'status' -Value 'converting'
        Set-Content -Path $file.FullName -Value $r.lines -Encoding UTF8

        $convertedBody = Convert-ToBjhStyle -Title $title -Body $body
        # store converted content into a local git-ignored dir for review (publish step reads it)
        $draftOutDir = Join-Path $root "scripts\.bjh_drafts"
        if (-not (Test-Path $draftOutDir)) { New-Item -ItemType Directory -Path $draftOutDir | Out-Null }
        $safeTitle = ($title -replace '[\\/:*?"<>|]', '_')
        $outPath = Join-Path $draftOutDir ($safeTitle + ".md")
        Set-Content -Path $outPath -Value $convertedBody -Encoding UTF8

        $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'converted' -Value 'true'
        $r.lines = Set-PlatformField -lines $r.lines -Platform $platform -Field 'status' -Value 'converted'
        Set-Content -Path $file.FullName -Value $r.lines -Encoding UTF8
        Write-Host ("  converted -> " + $outPath) -ForegroundColor Green
        $processed++
    }
}

Write-Host ("DONE: converted " + $processed + " post(s)") -ForegroundColor Cyan
Write-Host "NOTE: conversion only sets converted=true. Run publish-bjh.ps1 (with platform publish=true) to really publish." -ForegroundColor Yellow
