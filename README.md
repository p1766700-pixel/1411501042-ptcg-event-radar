# 🏆 PTCG 賽事雷達 (PTCG Event Radar)
> **專為台灣寶可夢卡牌玩家設計的賽事聚合與定位搜尋平台**

解決現有官方網站篩選繁瑣、無法快速掌握「離我最近、即將開始、熱門程度最高」賽事的痛點，讓玩家在數秒內找到最適合參加的比賽。

---

## ⚡ 核心功能特色

### 1. 智慧多條件選單與篩選器 (Advanced Filtering Menu)
- **即時模糊搜尋**：可搜尋店家名稱（如：卡之洞、法雅客、宏鼎文具等）或賽事名稱。
- **日期區間篩選**：今天開打、本週末、全部日期快速切換。
- **賽事類型（階級）**：道館賽 (Gym Battle)、卡牌日 (Card Day)、認真對戰賽 (Earnest Battle)、城市聯盟賽 (City League) 等。
- **縣市行政區篩選**：支援台北市、新北市、桃園市、台中市、台南市、高雄市、新竹等。
- **排序模式**：依「距離由近到遠」、「開賽時間」、「報名熱度」即時排序。

### 2. GPS 即時定位與「身邊熱門賽事」雷達 (Geolocation & "Hot Events" Radar)
- **精準距離計算**：利用前端 Geolocation API 與大圓距離（Haversine Formula）演算法，動態計算玩家目前位置至各賽事場館之直線距離。
- **身邊熱門賽事雷達專區 (Top 3)**：演算法綜合開賽時間近度、地理距離與額滿熱度，自動推播最優賽事卡片，並標註醒目標籤（如 `🔥 距離僅 1.2km`、`⚡ 報名熱門`、`🏆 精選賽事`）。
- **快速切換中心點**：提供台北車站、新北板橋、桃園、新竹、台中、台南、高雄等快速切換測試地點。

### 3. 賽事資訊卡片與官方導流 (Event Cards & Official Integration)
- **完整摘要**：賽事名稱、開賽日期/時間、店家名稱、完整地址、賽制規範（標準/擴充、全年齡/少年組）與報名名額進度條。
- **一鍵導航**：點擊地址或「一鍵導航」按鈕直接開啟 Google Maps 路線搜尋。
- **官方來源直連**：每場比賽卡片皆附有「官方詳情」連結，直達 [台灣寶可夢官方活動網站](https://asia.pokemon-card.com/tw/event/) 查閱權威報名規則與詳細規定。
- **賽事收藏**：點擊愛心可將喜愛賽事加入「我的收藏」（本地 LocalStorage 儲存），隨時檢視已收藏賽事。

---

## 📂 專案目錄結構

```text
ptcg-event-radar/
├── index.html              # 前端單頁應用程式（高質感競技風格、零依賴即開即用）
├── README.md               # 專案說明與開發指引
├── data/
│   └── events.json         # 即時官方賽事資料庫（包含經緯度與熱度評分）
└── scripts/
    ├── fetch_events.ps1    # 官方賽事爬蟲與資料清洗腳本（免 Python/Node 原生執行）
    ├── build_html.ps1      # 自動將資料庫嵌入 index.html 之建置腳本
    └── template.html       # 前端介面範本
```

---

## 🚀 快速開始使用

### 方式 A：直接在瀏覽器開啟（最簡單）
直接在檔案總管中雙擊 [`index.html`](file:///C:/Users/rushk/.gemini/antigravity/scratch/ptcg-event-radar/index.html) 或以 Chrome / Edge 開啟，即可立即使用全部搜尋、過濾、雷達與定位功能！

### 方式 B：更新最新官方賽事資料
若想抓取官網最新賽事，開啟 PowerShell 執行：
```powershell
powershell -ExecutionPolicy Bypass -File scripts/fetch_events.ps1 -MaxPages 5
powershell -ExecutionPolicy Bypass -File scripts/build_html.ps1
```
系統會自動向 `asia.pokemon-card.com` 抓取最新 100 場賽事並更新資料庫。

---

## 🗺️ 專案開發里程碑 (Milestones)

- [x] **Phase 1 (MVP)**：官方資料爬取、資料清洗與結構化、多條件搜尋選單、賽事卡片與 Google Maps / 官方連結導流。
- [x] **Phase 2 (雷達與定位)**：前端 GPS 定位接入、Haversine 距離即時計算、「當下最熱門」推薦雷達專區。
- [ ] **Phase 3 (社群與進階延伸)**：
  - 開賽前 Line Bot 通知提醒
  - 玩家現場揪團與賽後戰績討論區
  - 串接各店家 FB 粉絲專頁或官方報名表單
