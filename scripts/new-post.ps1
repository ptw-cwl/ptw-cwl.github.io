# =============================================
# new-post.ps1 - create a new post file
# Generate file named {type}_{rand5}_{unix_ts} and write front matter with id (same as filename).
#
# Usage (run from repo root):
#   powershell -ExecutionPolicy Bypass -File scripts\new-post.ps1 -Title "Article Title"
#   powershell -ExecutionPolicy Bypass -File scripts\new-post.ps1 -Title "Article Title" -Published
#
# Params:
#   -Title      Article title (required, may be Chinese)
#   -Type       Fixed: post (default, -> content/posts/) or about (-> content/about/ single page)
#   -Published  If passed, draft=false; default draft=true

# Both AI and manual call can use this script directly.
# NOTE: per 02-encoding rule, this script is all-ASCII (no Chinese in code/comments/output)
#       to stay safe under PowerShell 5.1 (GBK) default decoding. Title text may still be Chinese.
# =============================================

param(
    [Parameter(Mandatory = $true)][string]$Title,
    [string]$Type = "post",
    [switch]$Published
)

# type -> content subdir map (register new content dirs here)
$sectionMap = @{
    "post"  = "posts"
    "about" = "about"
}

if (-not $sectionMap.ContainsKey($Type)) {
    Write-Host "ERROR: unknown type '$Type'; supported: $($sectionMap.Keys -join ' / ')" -ForegroundColor Red
    exit 1
}

# generate 5-char base36 random (lowercase letters + digits)
$chars = "0123456789abcdefghijklmnopqrstuvwxyz"
$rand5 = -join (1..5 | ForEach-Object { $chars[(Get-Random -Maximum 36)] })

# creation time as unix timestamp (seconds)
$ts = [DateTimeOffset]::Now.ToUnixTimeSeconds()

# id = type_rand5_ts, keep identical to filename
$id = "$Type`_$rand5`_$ts"

$section = $sectionMap[$Type]
$dir = Join-Path $PSScriptRoot "..\content\$section"
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

# about is a single page: fixed index.md; if exists, only hint to fill id, do not overwrite
if ($Type -eq "about" -and (Test-Path (Join-Path $dir "index.md"))) {
    Write-Host "HINT: about page exists (content\about\index.md); manually add id: $id to its front matter" -ForegroundColor Yellow
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
description: ""
draft: $draft
---

"@

# write as UTF-8 without BOM (avoids Hugo BOM parse issue; Chinese content in output is fine)
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)

Write-Host "CREATED: $filePath"
Write-Host "id: $id"
Write-Host "NEXT: fill description (50-100 chars), tags and body; then set draft to false to publish"
Write-Host "NOTE: tags use English short codes (e.g. notes / ai-tool / hugo); register Chinese display name in data/tag_display.yaml"
