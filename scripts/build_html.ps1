[CmdletBinding()]
param()

$root = Split-Path -Parent $PSScriptRoot
$dataFile = Join-Path $root "data\events.json"
$outPath = Join-Path $root "index.html"

if (-not (Test-Path $dataFile)) {
    Write-Error "找不到賽事資料：$dataFile"
    exit 1
}

$jsonContent = Get-Content -Raw -Encoding UTF8 $dataFile

$templateFile = Join-Path $root "scripts\template.html"
if (-not (Test-Path $templateFile)) {
    Write-Error "找不到範本：$templateFile"
    exit 1
}

$template = Get-Content -Raw -Encoding UTF8 $templateFile
$finalHtml = $template.Replace("__JSON_PLACEHOLDER__", $jsonContent)

[System.IO.File]::WriteAllText($outPath, $finalHtml, [System.Text.Encoding]::UTF8)

Write-Host "✅ 成功生成 PTCG 賽事雷達前端應用程式：$outPath (檔案大小: $([Math]::Round((Get-Item $outPath).Length / 1KB, 1)) KB)" -ForegroundColor Green
