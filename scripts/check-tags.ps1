# 标签注册校验脚本 check-tags
$ErrorActionPreference = "Stop"

function Parse-TagDisplay {
    param([string]$Path)
    $map = @{}
    if (-not (Test-Path $Path)) { Write-Host "WARN: 未找到 $Path" -ForegroundColor Yellow; return $map }
    foreach ($line in (Get-Content -Path $Path -Encoding UTF8)) {
        if ($line -match '^\s*#|^\s*$') { continue }
        if ($line -match '^\s*(?<k>[A-Za-z0-9_-]+)\s*:\s*"?(.+?)"?\s*$') { $map[$Matches['k']] = $true }
    }
    return $map
}

function Get-FrontMatterTags {
    param([string]$Path)
    $text = Get-Content -Path $Path -Encoding UTF8 -Raw
    if ($text -notmatch '(?s)---\s*\n(.*?)\n---') { return @() }
    $fm = $Matches[1]
    if ($fm -notmatch '(?s)tags\s*:\s*\[(.*?)\]') { return @() }
    $raw = $Matches[1]; $tags = @()
    $pattern = [regex]::new('\x22([^\x22]*)\x22')
    foreach ($m in $pattern.Matches($raw)) { if ($m.Groups[1].Value -ne '') { $tags += $m.Groups[1].Value } }
    return $tags
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$tagDisplayPath = Join-Path $root "data\tag_display.yaml"
$registered = Parse-TagDisplay -Path $tagDisplayPath
$badKeys = @()
foreach ($k in $registered.Keys) { if ($k -cne $k.ToLower()) { $badKeys += $k } }

# 从 hugo.toml 解析 loadSections（内容加载白名单），遍历其下所有目录，
# 与白名单保持一致，避免未来新增分类（如 notes）后漏校验
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
Write-Host "INFO: 校验目录（loadSections）: $($sections -join ', ')" -ForegroundColor Cyan

$unregistered = @(); $badFiles = @{}
foreach ($sec in $sections) {
    $dir = Join-Path $root "content\$sec"
    if (-not (Test-Path $dir)) { Write-Host "WARN: 未找到目录: $dir" -ForegroundColor Yellow; continue }
    foreach ($file in (Get-ChildItem -Path $dir -Filter *.md)) {
        $tags = Get-FrontMatterTags -Path $file.FullName; $missing = @()
        foreach ($t in $tags) { if (-not $registered.ContainsKey($t)) { $missing += $t; if (-not $unregistered.Contains($t)) { $unregistered += $t } } }
        if ($missing.Count -gt 0) { $badFiles[$file.Name] = $missing }
    }
}
if ($badKeys.Count -eq 0 -and $badFiles.Count -eq 0) { Write-Host "OK: 所有文章标签均已登记，且映射 key 均为小写" -ForegroundColor Green; exit 0 }
if ($badKeys.Count -gt 0) { Write-Host "FAIL: 存在非小写映射 key（必须全小写）：" -ForegroundColor Red; foreach ($k in $badKeys) { Write-Host "    - $k" -ForegroundColor Red }; Write-Host "" }
if ($badFiles.Count -gt 0) { Write-Host "FAIL: 发现未登记标签，请补充：" -ForegroundColor Red; Write-Host ""; foreach ($kv in $badFiles.GetEnumerator()) { Write-Host "  $($kv.Key)" -ForegroundColor Red; foreach ($t in $kv.Value) { Write-Host "    - 未登记: $t" -ForegroundColor Red } }; Write-Host ""; Write-Host "修复：在 data/tag_display.yaml 中补充中文显示名" -ForegroundColor Yellow; foreach ($t in $unregistered) { Write-Host "  $t" -ForegroundColor Yellow } }
exit 1
