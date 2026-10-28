[CmdletBinding()]
param(
    [int]$MaxPages = 6,
    [string]$OutputFile = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

if (-not $OutputFile) {
    $OutputFile = Join-Path $PSScriptRoot "..\data\events.json"
}

$cityCoords = @{
    "台北市" = @{ lat = 25.0478; lng = 121.5170 }
    "新北市" = @{ lat = 25.0120; lng = 121.4657 }
    "基隆市" = @{ lat = 25.1276; lng = 121.7392 }
    "桃園市" = @{ lat = 24.9936; lng = 121.3009 }
    "新竹市" = @{ lat = 24.8018; lng = 120.9715 }
    "新竹縣" = @{ lat = 24.8383; lng = 121.0084 }
    "苗栗縣" = @{ lat = 24.5602; lng = 120.8214 }
    "台中市" = @{ lat = 24.1632; lng = 120.6401 }
    "彰化縣" = @{ lat = 24.0754; lng = 120.5447 }
    "南投縣" = @{ lat = 23.9037; lng = 120.6859 }
    "雲林縣" = @{ lat = 23.7092; lng = 120.4313 }
    "嘉義市" = @{ lat = 23.4800; lng = 120.4491 }
    "嘉義縣" = @{ lat = 23.4518; lng = 120.2555 }
    "台南市" = @{ lat = 22.9997; lng = 120.2270 }
    "高雄市" = @{ lat = 22.6273; lng = 120.3014 }
    "屏東縣" = @{ lat = 22.6826; lng = 120.4879 }
    "宜蘭縣" = @{ lat = 24.7570; lng = 121.7530 }
    "花蓮縣" = @{ lat = 23.9912; lng = 121.6016 }
    "台東縣" = @{ lat = 22.7583; lng = 121.1444 }
}

$districtOffsets = @{
    "信義區" = @{ dLat = 0.015; dLng = 0.045 }
    "大安區" = @{ dLat = -0.018; dLng = 0.025 }
    "中正區" = @{ dLat = -0.015; dLng = 0.002 }
    "中山區" = @{ dLat = 0.022; dLng = 0.019 }
    "萬華區" = @{ dLat = -0.012; dLng = -0.018 }
    "松山區" = @{ dLat = 0.012; dLng = 0.040 }
    "新莊區" = @{ dLat = 0.024; dLng = -0.015 }
    "板橋區" = @{ dLat = -0.002; dLng = -0.003 }
    "中和區" = @{ dLat = -0.014; dLng = 0.035 }
    "永和區" = @{ dLat = -0.004; dLng = 0.048 }
    "三重區" = @{ dLat = 0.059; dLng = 0.030 }
    "中壢區" = @{ dLat = -0.040; dLng = -0.075 }
    "桃園區" = @{ dLat = 0.000; dLng = 0.000 }
    "東區"   = @{ dLat = 0.010; dLng = 0.010 }
    "北區"   = @{ dLat = 0.015; dLng = 0.005 }
    "西區"   = @{ dLat = -0.015; dLng = 0.015 }
    "南屯區" = @{ dLat = -0.028; dLng = 0.000 }
    "左營區" = @{ dLat = 0.061; dLng = -0.007 }
    "三民區" = @{ dLat = 0.020; dLng = 0.014 }
    "苓雅區" = @{ dLat = -0.003; dLng = 0.011 }
    "中西區" = @{ dLat = -0.007; dLng = -0.026 }
}

Write-Host "🔍 開始抓取台灣寶可夢官方活動網站賽事 (共爬取 $MaxPages 頁)..." -ForegroundColor Cyan
$events = @()
$pattern = '(?s)<a class="eventLink" href="(/tw/event-search/([0-9]+)/)">.*?<time class="eventDate">([^<]+)</time>.*?<p class="eventTime">([^<]+)</p>.*?<p class="eventTag[^"]*">([^<]+)</p>.*?<p class="formatAndLeague">([^<]+)</p>.*?<p class="eventTitle">([^<]+)</p>.*?<p class="organizer"><object><a[^>]*>([^<]+)</a></object></p>.*?<p class="place">([^<]+)</p>'

$currentYear = (Get-Date).Year

for ($p = 1; $p -le $MaxPages; $p++) {
    $url = "https://asia.pokemon-card.com/tw/event-search/search/?pageNo=$p&keyword="
    try {
        $res = Invoke-WebRequest -Uri $url -Headers @{"User-Agent"="Mozilla/5.0"} -UseBasicParsing -TimeoutSec 15
        $matches = [regex]::Matches($res.Content, $pattern)
        Write-Host "  📄 頁面 $($p)：成功抓取 $($matches.Count) 場賽事" -ForegroundColor Gray
        foreach ($m in $matches) {
            $rawId = $m.Groups[2].Value.Trim()
            $rawDate = $m.Groups[3].Value.Trim() # e.g. 10-28
            $rawTime = $m.Groups[4].Value.Trim() # e.g. 17:30-19:00
            $rawTag = $m.Groups[5].Value.Trim()
            $rawFormat = $m.Groups[6].Value.Trim()
            $rawTitle = $m.Groups[7].Value.Trim()
            $rawStore = $m.Groups[8].Value.Trim()
            $rawAddress = $m.Groups[9].Value.Trim()

            # 解析縣市與行政區
            $city = "其他地區"
            foreach ($c in $cityCoords.Keys) {
                if ($rawAddress -match $c) {
                    $city = $c
                    break
                }
            }

            $district = ""
            if ($rawAddress -match '(?:台北市|新北市|基隆市|桃園市|新竹市|新竹縣|苗栗縣|台中市|彰化縣|南投縣|雲林縣|嘉義市|嘉義縣|台南市|高雄市|屏東縣|宜蘭縣|花蓮縣|台東縣)?([^\d\s]{1,4}(?:區|市|鎮|鄉))') {
                $district = $matches[1]
            }

            # 經緯度估算
            $baseCoord = $cityCoords[$city]
            if (-not $baseCoord) {
                $baseCoord = @{ lat = 25.0478; lng = 121.5170 }
            }
            $lat = $baseCoord.lat
            $lng = $baseCoord.lng

            if ($district -and $districtOffsets.ContainsKey($district)) {
                $lat += $districtOffsets[$district].dLat
                $lng += $districtOffsets[$district].dLng
            } else {
                # 加入基於 ID 的微幅雜訊偏移 (約數百公尺範圍內)
                $hashVal = [Math]::Abs($rawId.GetHashCode() % 100) / 3000.0
                $lat += ($hashVal - 0.015)
                $lng += ($hashVal - 0.012)
            }

            # 賽事類型分類
            $category = "道館賽 (Gym Battle)"
            if ($rawTitle -match "Card Day|卡牌日") {
                $category = "卡牌日 (Card Day)"
            } elseif ($rawTitle -match "City League|城市聯盟賽") {
                $category = "城市聯盟賽 (City League)"
            } elseif ($rawTitle -match "新手|教學|體驗") {
                $category = "新手體驗賽"
            } elseif ($rawTag -match "Earnest|認真") {
                $category = "認真對戰賽 (Earnest Battle)"
            } elseif ($rawTitle -match "Champions League|大師賽") {
                $category = "大型官方賽事 (Champions League)"
            }

            # 模擬報名名額與熱度
            $capacity = 32
            $registered = 18
            if ($category -eq "城市聯盟賽 (City League)") {
                $capacity = 64
                $registered = 58
            } elseif ($category -eq "大型官方賽事 (Champions League)") {
                $capacity = 1000
                $registered = 980
            } else {
                $capacity = 16 + ([Math]::Abs($rawId.GetHashCode()) % 2) * 16
                $registered = [Math]::Min($capacity, [Math]::Max(4, ([Math]::Abs($rawId.GetHashCode()) % ($capacity + 5))))
            }

            $events += [PSCustomObject]@{
                id = $rawId
                title = $rawTitle
                officialLink = "https://asia.pokemon-card.com/tw/event-search/$rawId/"
                date = "$currentYear-$rawDate"
                displayDate = $rawDate
                time = $rawTime
                tag = $rawTag
                category = $category
                format = $rawFormat
                store = $rawStore
                address = $rawAddress
                city = $city
                district = $district
                lat = [Math]::Round($lat, 5)
                lng = [Math]::Round($lng, 5)
                capacity = $capacity
                registered = $registered
                isFull = ($registered -ge $capacity)
                hotScore = [Math]::Round(($registered / [Math]::Max(1, $capacity)) * 100)
            }
        }
    } catch {
        Write-Warning "⚠️ 抓取頁面 $p 發生異常: $($_.Exception.Message)"
    }
}

# 確保目錄存在
$outDir = Split-Path -Parent $OutputFile
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

$payload = [ordered]@{
    updatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    totalCount = $events.Count
    events = $events
}

$payload | ConvertTo-Json -Depth 6 | Set-Content -Path $OutputFile -Encoding UTF8
Write-Host "✅ 成功抓取並更新 $($events.Count) 場即時賽事資料至：$OutputFile" -ForegroundColor Green
