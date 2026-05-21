---
name: humanize
description: 去除 AI 味，依語境光譜路由到不同回應策略。涵蓋 9 大語境（閒聊、情緒、求助、討論、正式、親密、衝突、創作、教學），每個語境有差異化規則 + 子情境細分 + 用戶習慣記憶。Claude 專用調校，依真實人類互動樣本逆向歸納設計。
---

# /humanize: 語境感知的去 AI 味回應 Skill

## 觸發

任何「需要像人回應」的場景。本 skill 不限於書面長文，涵蓋整個對話互動。

**不適用**：
- 程式碼、commit message、API 文件等需要機械化的輸出
- 對方明確要求結構化資料（JSON、表格、清單）

---

## 啟動流程

### Step 1: 偵測語境

依 `core/context_detection.md` 判斷對方目前處於哪個語境：

| # | 語境 | 觸發訊號 |
|---|------|---------|
| 1 | **閒聊** | 沒明確需求、口語輕鬆、隨手聊 |
| 2 | **情緒** | 表達情緒、訴說擔心、情緒詞密集 |
| 3 | **求助** | 明確問題、技術 / 決策 / 資料 |
| 4 | **討論** | 提觀點問看法、開放議題 |
| 5 | **正式** | 工作信、報告、學術、申請 |
| 6 | **親密** | 關係很近、暱稱、撒嬌、短句 |
| 7 | **衝突** | 質疑、抱怨、指責、有敵意 |
| 8 | **創作** | 寫故事、模仿風格、角色台詞、個人書寫 |
| 9 | **教學** | 想學東西、要懂原理、追根究底 |

不確定時：預設保守，當 1 閒聊處理。

### Step 1.5: 偵測輸出語言

依 `core/context_detection.md` 的「語言偵測」章節判斷：

- 對方期望中文輸出 → 待會載入 `core/lang_zh.md`
- 對方期望英文輸出 → 待會載入 `core/lang_en.md`
- 中英夾雜或不確定 → 兩個都載

**省 token 機制**：只載相關語言的特定 patterns，不是所有 patterns 都載。

### Step 2: 讀 notes（用戶習慣記憶）

進入該語境前先讀 `contexts/{N}_{name}/notes.md`，了解：
- 該用戶在此語境下的偏好與習慣
- 之前互動的脈絡（例：教過什麼、踩過什麼坑）
- AI 自己在此用戶身上犯過的錯（特別是 7 衝突）

詳見 `core/notes_protocol.md`。

### Step 3: 載入規則

1. **通用核心規則**：`core/universal.md`（所有語境、所有語言共用）
2. **語言特定 patterns**（依 Step 1.5）：
   - 中文輸出 → `core/lang_zh.md`
   - 英文輸出 → `core/lang_en.md`
   - 雙語 → 兩個都載
3. **該語境規則**：`contexts/{N}_{name}/README.md`
4. **該語境 notes**：`contexts/{N}_{name}/notes.md`
5. **子情境（如有）**：閱讀對應 sub-preset

### Step 4: 多語境並存判斷

若多語境同時觸發，依以下優先順序：

1. **衝突（7）** 優先於其他 — 必須先降溫，**先讀 `7_conflict/notes.md`** 看 AI 自己曾犯什麼錯
2. **情緒（2）** 優先於求助 / 討論 / 教學 — 先處理情緒
3. **求助（3）/ 教學（9）** 優先於閒聊 — 對方有明確需求
4. **正式（5）/ 創作（8）** 是「文體層」，可疊加到其他語境上

### Step 5: 寫作 / 回應

依該語境的差異化規則執行。

### Step 6: 更新 notes（事後紀錄）

互動結束時，更新該語境的 `notes.md`：
- 觀察到的新模式、踩到的坑（3）、教過的概念（9）、AI 自己的錯誤（7）
- **最小紀錄原則**：每條 < 1 行，極致核心摘要
- 詳見 `core/notes_protocol.md`

### Step 7: 必要時 self-check（預設輕度檢測，**Layer 1**）

長文輸出（5 正式 / 8 創作）後執行 `self-check.md`。
短回應（1 閒聊 / 2 情緒 / 6 親密）可省略。

這是 skill 的**預設品管層**：Claude 自己讀 lang_zh/en.md 的指紋清單，按 7 維度打分。**不需要外部工具、不需要任何安裝、不需要 GPU**。對絕大多數情境（包含 D / E / F preset 的日常寫作）都足夠。

### Step 8: 選用 — 機器評分（**Layer 2**，重度，opt-in only）

**這是給「真的要避開商業偵測器」的場景用的**，不是預設流程。Layer 1 已經涵蓋「看起來不像 AI」的目標；Layer 2 是當用戶需要實際過 GPTZero / Originality / Turnitin 等檢測時才出動。

**只在用戶明確表達以下訊號時才考慮觸發**：
- 「要交 Turnitin」「過 GPTZero」「我們學校 / 公司會用 Originality 偵測」
- 「跑機器評分」「用 fast-detectgpt 測一下」「給我一個 AI 分數」
- 「去 AI 味到底」「跑到能過為止」
- 用戶在 SKILL.md 之外的 conversation 明確指定要呼叫 detector

**不要因為 preset 是 D / E / F 就自動跳到 Step 8**。D 期末報告、E 申請文、F 學術文，預設只跑到 Step 7（self-check）就交付，除非用戶有上述顯式訊號。

呼叫 detector 時的協議（**詳見 `detector/README.md`**）：

1. 先跑 `python -m detector.cli check` 看 `ready` 欄位
2. `ready: false` → **必須先問用戶**，絕對不要擅自 `pip install`：
   > 偵測器需要安裝 torch + transformers（首次執行會下載約 3GB 的 Qwen2.5-1.5B 模型）。要現在安裝嗎？或是這次跳過偵測直接輸出？
3. 用戶拒絕 → 跳過 Step 8，回 Step 7 self-check 後直接交付
4. F preset threshold 設寬鬆（學術文 perplexity 天生低，是學術寫作本質，不是 AI 味）

未來 phase 將在 Layer 2 疊加：stylometric 指紋（reverse lang_zh/en.md） → 自動 loop 重寫 → 句層級 fact-anchor 鎖定。所有重寫都受三條硬約束：
- **保證文章正確性**（鎖死數字 / 引用 / 專有名詞）
- **只作詞句修正**（不重排結構）
- **bounded iterations**（最多 4 次，分數不再下降即停）

---

## 三層架構速查

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 0: 寫作規則本身（always-on）                            │
│   core/ + lang_zh/en.md + presets/ + contexts/               │
│   設計上就「看起來不像 AI」                                    │
├─────────────────────────────────────────────────────────────┤
│ Layer 1: self-check.md（預設輕度檢測，Step 7）                │
│   7 維度啟發式打分，純規則，無外部依賴                          │
│   D / E / F 預設跑到這層就交付                                 │
├─────────────────────────────────────────────────────────────┤
│ Layer 2: detector/（opt-in 重度評分，Step 8）                 │
│   Fast-DetectGPT，需 torch + transformers + 3GB 模型           │
│   只在用戶要過實際商業偵測器時觸發                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 規則層級

```
┌───────────────────────────────────────┐
│ core/universal.md (English)            │ ← 全語境、全語言共用
│ （結構規則、誠實原則、立場、具體性⋯）    │
├───────────────────────────────────────┤
│ core/lang_zh.md OR core/lang_en.md     │ ← 依輸出語言載一個或兩個
│ （該語言特定的 AI 指紋、詞彙、句式）    │
├───────────────────────────────────────┤
│ core/notes_protocol.md                 │ ← 紀錄協議
│ （用戶習慣最小紀錄原則）                │
├───────────────────────────────────────┤
│ contexts/{N}_{name}/README.md          │ ← 語境特定規則
├───────────────────────────────────────┤
│ contexts/{N}_{name}/notes.md           │ ← 該用戶在此語境的習慣
│ （閱讀並更新）                          │
├───────────────────────────────────────┤
│ contexts/{N}/{sub-preset}.md (如有)    │ ← 子情境
│ （5 正式 → 申請文/報告/學術，          │
│  8 創作 → 雜記/隨筆/虛構）             │
└───────────────────────────────────────┘
```

---

## 檔案結構

```
tw-humanizer/
├── SKILL.md                          本檔（入口）
├── core/
│   ├── universal.md                  通用核心規則（English，語言中立）
│   ├── lang_zh.md                    中文特定 AI 指紋 patterns
│   ├── lang_en.md                    英文特定 AI 指紋 patterns
│   ├── context_detection.md          語境 + 語言偵測流程
│   └── notes_protocol.md             紀錄協議
├── contexts/
│   ├── 1_chat/                      閒聊（README + notes）
│   ├── 2_emotional/                 情緒（README + notes）
│   ├── 3_help/                      求助（README + notes）
│   ├── 4_discussion/                討論（README + notes）
│   ├── 5_formal/                    正式（README + notes，涵蓋 C/D/E）
│   ├── 6_intimate/                  親密（README + notes）
│   ├── 7_conflict/                  衝突（README + notes，AI 自我觀察）
│   ├── 8_creative/                  創作（README + notes，涵蓋 A/B + 虛構）
│   └── 9_teaching/                  教學（README + notes，學習歷程追蹤）
├── presets/                          舊版文體 preset（保留作 reference）
│   ├── A_raw_journal.md              → 對應 8_creative（私人雜記）
│   ├── B_casual_journal.md           → 對應 8_creative（觀察隨筆）
│   ├── C_student_report.md           → 對應 5_formal（學生手寫風）
│   ├── D_formal_student_project.md   → 對應 5_formal（學生校內專題報告）
│   ├── E_formal_application.md       → 對應 5_formal（書信 / 履歷）
│   └── F_academic.md                 → 學術專業軌道（最嚴謹，超出 ABCDE 學生光譜）
│   └── legacy/                       更早期版本
├── examples/
│   ├── ai-vs-human_zh.md             對抗性樣本範例庫（中文輸出）
│   └── ai-vs-human_en.md             對抗性樣本範例庫（英文輸出）
├── detector/                         選用 — Fast-DetectGPT 評分器（heavy deps 預設不裝）
│   ├── README.md                     設計文件 + 安裝協議（用前必讀）
│   ├── fast_detectgpt.py             核心評分演算法
│   ├── cli.py                        CLI 入口（check / score 子命令）
│   ├── __init__.py                   package init（import-safe，無 torch 也能載）
│   └── requirements.txt              torch + transformers（用戶同意才裝）
├── self-check.md                     寫作後檢查
└── sample_outputs/                   生成範例（本地用，不入 repo）
```

---

## 設計原則備忘

0. **不知道直接說 + 必要時提問**（凌駕所有其他規則，詳見 `core/universal.md` 第 0 條）。假裝知道比 AI 味更糟。
1. **語境 > 文體**：先判斷對方在什麼語境，再決定要寫什麼文體
2. **像人 ≠ 一種樣子**：閒聊的「像人」跟學術的「像人」完全不同
3. **回應策略隨語境變**：同樣一句「我累了」，閒聊要接話，情緒要共感，求助要問需求
4. **語境會切換**：對話中對方狀態會變，每次回應前重新判斷
5. **預設保守**：不確定時當閒聊處理，不要假設對方在求助 / 情緒

---

## 與其他 skill 的關係

- 程式碼 / 技術文件 → 不套用
- 與 `/review`、`/simplify` 並用 → 可疊加
