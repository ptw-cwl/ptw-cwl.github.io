# =============================================
# 文章生成脚本（new-post）
# 按命名规范 {type}_{rand5}_{unix_ts} 生成文章文件，并在 front matter 写入 id（与文件名一致）
#
# 用法（仓库根目录执行）：
#   powershell -ExecutionPolicy Bypass -File scripts\new-post.ps1 -Title "文章标题"
#   powershell -ExecutionPolicy Bypass -File scripts\new-post.ps1 -Title "文章标题" -Published
#
# 参数：
#   -Title      文章标题（必填，中文）
#   -Type       固定值：post（默认，对应 content/posts/）/ about（对应 content/about/ 单页）
#   -Published  传入则 draft=false 直接发布；默认 draft=true 为草稿
#
# AI 创建与手动创建均可直接调用本脚本。
# =============================================

param(
    [Parameter(Mandatory = $true)][string]$Title,
    [string]$Type = "post",
    [switch]$Published
)

# 固定值 -> content 子目录映射（新增 content 目录时在此登记）
$sectionMap = @{
    "post"  = "posts"
    "about" = "about"
}

if (-not $sectionMap.ContainsKey($Type)) {
    Write-Host "错误：未知类型 '$Type'，仅支持：$($sectionMap.Keys -join ' / ')" -ForegroundColor Red
    exit 1
}

# 生成 5 位 base36 随机串（小写字母 + 数字）
$chars = "0123456789abcdefghijklmnopqrstuvwxyz"
$rand5 = -join (1..5 | ForEach-Object { $chars[(Get-Random -Maximum 36)] })

# 创建时间 Unix 时间戳（秒）
$ts = [DateTimeOffset]::Now.ToUnixTimeSeconds()

# id = 固定值_随机串_时间戳，与文件名保持一致
$id = "$Type`_$rand5`_$ts"

$section = $sectionMap[$Type]
$dir = Join-Path $PSScriptRoot "..\content\$section"
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# about 为单页：文件名固定 index.md，已存在时只提示补 id，不覆盖
if ($Type -eq "about" -and (Test-Path (Join-Path $dir "index.md"))) {
    Write-Host "提示：about 单页已存在（content\about\index.md），请在 front matter 中手动补充 id: $id" -ForegroundColor Yellow
    exit 0
}

$fileName = if ($Type -eq "about") { "index.md" } else { "$id.md" }
$filePath = Join-Path $dir $fileName

$localTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$escapedTitle = $Title.Replace('"', '\"')
$draft = if ($Published) { "false" } else { "true" }

$content = @"
---
title: "$escapedTitle"
id: $id
createTime: $localTime
updateTime: $localTime
tags: []
draft: $draft
---

"@

# 以无 BOM 的 UTF-8 写入（避免 Hugo 解析 BOM 异常，兼容中文内容）
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)

Write-Host "已创建：$filePath"
Write-Host "id：$id"
Write-Host "下一步：补充 tags 与正文，完成后把 draft 改为 false 即可发布"
