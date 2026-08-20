# check-platforms.ps1 - validate syndicate vs platforms fields consistency
# Ensures pid is not missing and status values are valid.
# Usage: powershell -ExecutionPolicy Bypass -File scripts\check-platforms.ps1
$ErrorActionPreference = "Stop"

function Get-FrontMatter {
    param([string]$Path)
    $text = Get-Content -Path $Path -Encoding UTF8 -Raw
    if ($text -notmatch '(?s)---\s*\n(.*?)\n---') { return $null }
    return $Matches[1]
}

function Parse-Bool {
    param([string]$v)
    return ($v -match '^\s*true\s*$')
}

function Get-Syndicate {
    param([string]$fm)
    if ($fm -match '(?m)^\s*syndicate\s*:\s*(\w+)') { return Parse-Bool $Matches[1] }
    return $false
}

function Get-PlatformsBlock {
    param([string]$fm)
    if ($fm -notmatch '(?s)(?m)^\s*platforms\s*:\s*\n((?:\s*- name:.*(?:\n(?!^\s*\w).*)*)?)') { return @() }
    $block = $Matches[1]
    $items = @()
    $parts = [regex]::Split($block, '(?m)^\s*-\s*name\s*:')
    for ($i = 1; $i -lt $parts.Count; $i++) {
        $seg = $parts[$i]
        if ($seg -match '^\s*([A-Za-z0-9_-]+)') {
            $name = $Matches[1]
            $item = @{ name = $name; publish = $false; converted = $false; pid = ""; status = "draft"; publishedAt = ""; url = "" }
            if ($seg -match '(?m)publish\s*:\s*(\w+)') { $item.publish = Parse-Bool $Matches[1] }
            if ($seg -match '(?m)converted\s*:\s*(\w+)') { $item.converted = Parse-Bool $Matches[1] }
            if ($seg -match '(?m)pid\s*:\s*"?([^"\n]*)"?') { $item.pid = $Matches[1].Trim() }
            if ($seg -match '(?m)status\s*:\s*"?([^"\n]*)"?') { $item.status = $Matches[1].Trim() }
            if ($seg -match '(?m)publishedAt\s*:\s*"?([^"\n]*)"?') { $item.publishedAt = $Matches[1].Trim() }
            if ($seg -match '(?m)url\s*:\s*"?([^"\n]*)"?') { $item.url = $Matches[1].Trim() }
            $items += $item
        }
    }
    return $items
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
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

$errors = @()
$warnings = @()
$validStatus = @('draft', 'converting', 'converted', 'published', 'failed')

foreach ($sec in $sections) {
    $dir = Join-Path $root "content\$sec"
    if (-not (Test-Path $dir)) { continue }
    foreach ($file in (Get-ChildItem -Path $dir -Filter *.md)) {
        $fm = Get-FrontMatter -Path $file.FullName
        if ($null -eq $fm) { continue }
        $syndicate = Get-Syndicate -fm $fm
        $platforms = Get-PlatformsBlock -fm $fm
        if (-not $syndicate) {
            if ($platforms.Count -gt 0) {
                $warnings += ($file.Name + ': syndicate=false but platforms present (ignored, inconsistent)')
            }
            continue
        }
        if ($platforms.Count -eq 0) { continue }
        foreach ($p in $platforms) {
            if ($validStatus -notcontains $p.status) {
                $errors += ($file.Name + ': platform ' + $p.name + ' status=' + $p.status + ' invalid (expect ' + ($validStatus -join '/') + ')')
            }
            if ($p.status -eq 'published' -and [string]::IsNullOrWhiteSpace($p.pid)) {
                $errors += ($file.Name + ': platform ' + $p.name + ' status=published but pid empty')
            }
            if ($p.status -eq 'published' -and -not $p.publish) {
                $errors += ($file.Name + ': platform ' + $p.name + ' status=published but publish!=true (inconsistent)')
            }
            if ($p.status -eq 'published' -and [string]::IsNullOrWhiteSpace($p.publishedAt)) {
                $warnings += ($file.Name + ': platform ' + $p.name + ' status=published but publishedAt empty')
            }
            if ($p.publish -and $p.status -eq 'converted') {
                $warnings += ($file.Name + ': platform ' + $p.name + ' publish=true but status=converted (will be published by publish-bjh.ps1)')
            }
            if ($p.converted -and $p.status -ne 'converted' -and $p.status -ne 'published' -and $p.status -ne 'failed') {
                $warnings += ($file.Name + ': platform ' + $p.name + ' converted=true but status=' + $p.status + ' (inconsistent; expect converted/published/failed)')
            }
        }
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "WARN:" -ForegroundColor Yellow
    foreach ($w in $warnings) { Write-Host ('  - ' + $w) -ForegroundColor Yellow }
}
if ($errors.Count -eq 0) {
    Write-Host "OK: platform fields check passed" -ForegroundColor Green
    exit 0
}
Write-Host "FAIL: platform fields check failed:" -ForegroundColor Red
foreach ($e in $errors) { Write-Host ('  - ' + $e) -ForegroundColor Red }
exit 1
