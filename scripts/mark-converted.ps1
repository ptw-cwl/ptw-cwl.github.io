# mark-converted.ps1 - mark a post's platform entry as converted=true
# Create the entry if missing (default status=draft).
#
# Usage:
#   All syndicate=true posts, mark baijiahao converted:
#     powershell -ExecutionPolicy Bypass -File scripts\mark-converted.ps1
#   Specific file + platform:
#     powershell -ExecutionPolicy Bypass -File scripts\mark-converted.ps1 -Path content/posts/xxx.md -Platform wechat
param(
    [string]$Path = "",
    [string]$Platform = "baijiahao"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")

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

function Ensure-PlatformBlock {
    param([string[]]$lines, [int]$start, [int]$end, [string]$Platform)
    $platLine = -1
    for ($i = $start + 1; $i -lt $end; $i++) {
        if ($lines[$i] -match '^\s*platforms\s*:') { $platLine = $i; break }
    }
    $hasEntry = $false
    if ($platLine -ge 0) {
        for ($i = $platLine + 1; $i -lt $end; $i++) {
            if ($lines[$i] -match "^\s*-\s*name\s*:\s*$Platform\s*$") { $hasEntry = $true; break }
            if ($lines[$i] -match '^\s*\w+\s*:') { break }
        }
    }
    if ($hasEntry) { return $lines }
    $entry = @(
        "  - name: $Platform",
        "    publish: false",
        "    converted: true",
        '    pid: ""',
        "    status: draft",
        '    publishedAt: ""',
        '    url: ""'
    )
    if ($platLine -ge 0) {
        $lines = $lines[0..$platLine] + $entry + $lines[($platLine + 1)..($lines.Count - 1)]
    } else {
        $ins = -1
        for ($i = $start + 1; $i -lt $end; $i++) {
            if ($lines[$i] -match '^\s*syndicate\s*:') { $ins = $i; break }
        }
        if ($ins -eq -1) { $ins = $end - 1 }
        $block = @("platforms:", $entry[0], $entry[1], $entry[2], $entry[3], $entry[4], $entry[5], $entry[6])
        $lines = $lines[0..$ins] + $block + $lines[($ins + 1)..($lines.Count - 1)]
    }
    return $lines
}

function Set-ConvertedTrue {
    param([string[]]$lines, [string]$Platform)
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^\s*-\s*name\s*:\s*$Platform\s*$") {
            $found = $false
            for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                if ($lines[$j] -match '^\s*\w+\s*:') {
                    if ($lines[$j] -match '^\s*converted\s*:') { $lines[$j] = '    converted: true'; $found = $true; break }
                    if ($lines[$j] -notmatch '^\s{4,}-') { break }
                }
            }
            if (-not $found) {
                $lines = $lines[0..$i] + @('    converted: true') + $lines[($i + 1)..($lines.Count - 1)]
            }
            break
        }
    }
    return $lines
}

$files = @()
if ($Path -ne "") {
    $files += (Resolve-Path (Join-Path $root $Path)).Path
} else {
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
    foreach ($sec in $sections) {
        $dir = Join-Path $root "content\$sec"
        if (-not (Test-Path $dir)) { continue }
        foreach ($f in (Get-ChildItem -Path $dir -Filter *.md)) { $files += $f.FullName }
    }
}

$changed = 0
foreach ($fp in $files) {
    $r = Read-FrontMatterRange -FilePath $fp
    if ($r.start -eq -1 -or $r.end -eq -1) { continue }
    if (-not (Get-Syndicate -lines $r.lines -start $r.start -end $r.end)) {
        Write-Host ("SKIP (syndicate!=true): " + $fp) -ForegroundColor DarkGray
        continue
    }
    $r.lines = Ensure-PlatformBlock -lines $r.lines -start $r.start -end $r.end -Platform $Platform
    $r.lines = Set-ConvertedTrue -lines $r.lines -Platform $Platform
    Set-Content -Path $fp -Value $r.lines -Encoding UTF8
    Write-Host ("OK: marked " + $Platform + " converted=true -> " + $fp) -ForegroundColor Green
    $changed++
}
Write-Host ("DONE: marked " + $changed + " file(s)") -ForegroundColor Cyan
