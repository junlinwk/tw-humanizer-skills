# tw-humanizer

**讓 AI 回應像人寫的**

Context-aware response skill for Claude Code and OpenAI Codex — detects 9 conversational contexts × 2 output languages, applies the right register, remembers user preferences. Top principle: admit uncertainty, ask when unclear.

---

## 它解決什麼問題

AI 寫的東西常有明顯的「AI 味」：

- 在閒聊時還在結構化回答
- 在情緒裡立刻給解法
- 在求助時鋪陳一堆背景才給答案
- 在學術寫作裡堆「綜上所述」「值得進一步研究」
- 在不確定時編造或用模糊語言掩護

`humanize` skill 在 Claude Code / Codex 每次回應前：

1. 偵測對方語境（閒聊 / 情緒 / 求助 / 討論 / 正式 / 親密 / 衝突 / 創作 / 教學）
2. 偵測輸出語言（中文 / 英文 / 雙語）
3. 套用該語境的規則去 AI 味
4. 持久記憶用戶在各語境的偏好（最小紀錄原則）

---

## 安裝

### macOS / Linux / Windows（WSL2）

```bash
git clone https://github.com/junlinwk/tw-humanizer-skills.git
cd tw-humanizer-skills
bash install.sh
# 或安裝到 Codex:
bash install.sh --tool=codex
```

### Windows（PowerShell 原生）

```powershell
git clone https://github.com/junlinwk/tw-humanizer-skills.git
cd tw-humanizer-skills
.\install.ps1
# 或安裝到 Codex:
.\install.ps1 -Tool codex
```

如果執行政策阻擋：
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```


### 安裝後

- 互動模式會問你是否啟用「自動觸發」（建議：**是**，這樣目標工具每次回應前都會自動套用）
- 完成後 **開新對話** 即生效
- Claude Code 安裝位置：`~/.claude/skills/humanize/`（macOS / Linux / WSL2）或 `%USERPROFILE%\.claude\skills\humanize\`（Windows）
- Codex 安裝位置：`${CODEX_HOME:-~/.codex}/skills/humanize/` 或 `%CODEX_HOME%\skills\humanize\`（未設定時為 `%USERPROFILE%\.codex\skills\humanize\`）

### 移除

```bash
bash uninstall.sh        # macOS / Linux / WSL2
bash uninstall.sh --tool=codex
.\uninstall.ps1          # Windows PowerShell
.\uninstall.ps1 -Tool codex
```

加 `--keep-notes`（bash）或 `-KeepNotes`（PowerShell）可保留 notes 備份。

### 其他選項

```bash
bash install.sh --dev        # symlink 模式（開發者用）
bash install.sh --tool=codex # 安裝到 OpenAI Codex
bash install.sh --silent     # 靜默安裝（CI / 腳本用）
bash install.sh --no-auto    # 不啟用自動觸發
bash install.sh --help       # 完整旗標說明
```

完整文件見 [`INSTALL.md`](./INSTALL.md)（含開發者模式、多工具支援、隱私說明、進階設定）。

---

### 範例對照（同樣的訊息類型，不同語境的差異化回應）

#### 情境 1：情緒語境（2 emotional）

**用戶**：「我又被當了 真的不知道在念什麼」

❌ AI 預設回應（立刻給解法）
> 被當了確實令人沮喪。建議你分析原因：是讀書方法問題還是時間管理？我可以幫你制定改善計畫。

✅ humanize 啟用（偵測為情緒語境，先共感）
> 靠 真的衰 你還好嗎 是哪一科

**差別**：對方在訴情緒，不是來找你制定計畫。先承認情緒、再問細節，不是立刻結構化分析。

---

#### 情境 2：求助語境（3 help）

**用戶**：「Python 怎麼讀 CSV 然後轉 DataFrame」

❌ AI 預設回應（鋪陳一堆才給答案）
> 在資料分析領域中，Python 提供了多種讀取 CSV 的方法。其中最常用的是 pandas 套件，它提供了豐富的功能來處理表格資料。透過 pandas 的 `read_csv` 函式，您可以輕鬆地將 CSV 檔案轉換為 DataFrame...

✅ humanize 啟用（偵測為求助語境，直接給答案）
> ```python
> import pandas as pd
> df = pd.read_csv('file.csv')
> ```
> 中文 CSV 常遇到編碼問題，加 `encoding='utf-8'` 或 `encoding='big5'`。第一行不是 header 的話加 `header=None`。

**差別**：對方要答案，不是要鋪陳。第一句直接給 code，再補常見坑。

---

#### 情境 3：不確定時（§0 最高原則）

**用戶**：「Claude 4.7 的訓練資料截止到哪個日期？」

❌ AI 預設回應（編造看似合理的日期）
> Claude 4.7 的訓練資料截止日期為 2024 年 4 月。

✅ humanize 啟用（套用 §0：不知道直接說 + 引導查官方來源）
> 確切日期我自己也不完全確定。建議直接查 Anthropic 的 model card 或官方公告，那邊才會有準確資訊。要不要我幫你找？

**差別**：不確定時不編造，承認限制，引導對方查可靠來源。**這條原則凌駕一切**，因為假裝知道比 AI 味更糟，會直接誤導用戶。

---

## 最高原則（凌駕一切）

**不知道直接說 + 必要時向用戶提問。**

不要編造、不要用模糊語言掩護無知、不要把不確定的事實寫得像確定的事實。
**假裝知道比 AI 味更糟，會直接誤導用戶。**

詳見 [`core/universal.md`](./core/universal.md) §0。

---

## 9 大語境

| # | 語境 | 觸發訊號 | 核心原則 | notes 紀錄 |
|---|------|---------|---------|----------|
| 1 | **閒聊** | 沒明確需求、口語輕鬆 | 自然、接得上、不一定完整 | 聊過的話題 |
| 2 | **情緒** | 難過 / 焦慮 / 憤怒 / 興奮 | 先承認情緒，不立刻給解法 | 情感模式、緩和方式 |
| 3 | **求助** | 明確問題、技術 / 決策 | 清楚、具體、可執行 | 踩過的坑、工具偏好 |
| 4 | **討論** | 交換觀點、開放問題 | 表態 + 反問 + 補角度，不教訓 | 主題標題（極簡） |
| 5 | **正式** | 工作信 / 報告 / 學術 / 申請 | 結構嚴謹、少口語 | 身份、需求、文體偏好 |
| 6 | **親密** | 家人 / 伴侶 / 摯友 | 短、直接、有默契 | 喜好、反饋觀察 |
| 7 | **衝突** | 質疑 / 抱怨 / 指責 | 先降溫、抓真問題、不防禦 | **AI 自己的錯誤模式** |
| 8 | **創作** | 模仿聲音 / 虛構 / 角色 | 考慮角色情緒節奏 | 風格偏好 |
| 9 | **教學** | 想懂原理、追根究底 | 老師角色，不假設已理解 | 用戶水平、教過什麼、卡點 |

**多語境並存優先序**：衝突 > 情緒 > 求助 / 教學 > 閒聊 > 正式 / 創作。

---

## 四層架構

```
┌────────────────────────────────────┐
│ 第一層：語境判斷                      │
│ 對方現在處於 9 大語境的哪一個？         │
├────────────────────────────────────┤
│ 第二層：語言偵測（i18n 智慧載入）       │
│ 輸出中文 → 載 lang_zh.md             │
│ 輸出英文 → 載 lang_en.md             │
│ 中英夾雜 → 兩個都載                   │
│ → 省 25-40% token（純單一語言輸出時）  │
├────────────────────────────────────┤
│ 第三層：子情境細分                    │
│ 例： 5 正式 → 申請文 / 學生報告 / 學術 │
│     8 創作 → 雜記 / 隨筆 / 虛構       │
│     2 情緒 → 難過 / 焦慮 / 興奮       │
│     9 教學 → 程式 / 概念 / 解題       │
├────────────────────────────────────┤
│ 第四層：用戶習慣紀錄（notes.md）       │
│ 該用戶在此語境的偏好、踩過的坑、        │
│ 教過的概念、AI 自己的錯誤模式          │
│ → 最小紀錄原則，每條 < 1 行           │
│ → 太遠的事件採濃縮（不刪除）           │
└────────────────────────────────────┘
```

---

## 紀錄機制 (Notes System)

每個語境有 `notes.md`，AI 互動後靜默更新、互動前閱讀。

**設計原則**：
1. 最小紀錄（每條 < 1 行）
2. 分門別類（依該語境的欄位）
3. 過期濃縮（不刪除）：細節事件 → 模式描述
4. 用戶明確要求別記的不要記
5. 上限 ≤ 50 行（太多反而失去用處）

**特別重要的兩個 notes**：

- `humanize-data/contexts/7_conflict/notes.md`：紀錄 **AI 自己的錯誤模式** + 用戶不耐煩訊號 + 緩和方式。用戶疑似不爽時優先讀此檔。
- `humanize-data/contexts/9_teaching/notes.md`：紀錄用戶學習歷程，私人家教式。「上次說過 X」式呼應依此檔追蹤。

> 注意（v0.4.0+）：真實 notes 都在 sibling 目錄 `humanize-data/` 內，不在 skill 目錄裡。skill 內的 `contexts/{N}/notes.md` **只是模板**，升級時會被覆寫。

詳見 [`core/notes_protocol.md`](./core/notes_protocol.md)。

---

## i18n 設計

```
core/
├── universal.md         語言中立的核心規則（英文撰寫）
├── lang_zh.md           中文特定 AI 指紋 patterns
└── lang_en.md           英文特定 AI 指紋 patterns
```

依輸出語言只載入相關 patterns：
- 純中文輸出 → universal + lang_zh（省 lang_en 約 80 行）
- 純英文輸出 → universal + lang_en（省 lang_zh 約 100 行）
- 中英夾雜 → 三檔都載（跟舊版相同）

加新語言（例：日文）只需新增 `lang_ja.md`，universal 不動。

---

## 檔案結構

```
humanize/
├── SKILL.md                          入口 + 語境路由表
├── README.md                         本檔
├── INSTALL.md                        安裝指南
├── install.sh                        安裝腳本
├── uninstall.sh                      移除腳本
├── .gitignore
├── agents/
│   └── openai.yaml                   Codex UI metadata
├── core/
│   ├── universal.md                  通用核心規則（English，語言中立）
│   ├── lang_zh.md                    中文特定 AI 指紋 patterns
│   ├── lang_en.md                    英文特定 AI 指紋 patterns
│   ├── context_detection.md          語境 + 語言偵測流程
│   └── notes_protocol.md             紀錄協議
├── contexts/                         9 大語境（每個含 README + notes）
│   ├── 1_chat/
│   ├── 2_emotional/
│   ├── 3_help/
│   ├── 4_discussion/
│   ├── 5_formal/                     涵蓋 C/D/E 子情境
│   ├── 6_intimate/
│   ├── 7_conflict/                   AI 自我觀察的特殊 notes
│   ├── 8_creative/                   涵蓋 A/B + 虛構子情境
│   └── 9_teaching/                   學習歷程追蹤
├── presets/                          子情境的詳細規則
│   ├── A_raw_journal.md              → 8 創作 子情境（私人雜記）
│   ├── B_casual_journal.md           → 8 創作 子情境（觀察隨筆）
│   ├── C_student_report.md           → 5 正式 子情境（學生手寫風）
│   ├── D_formal_student_project.md   → 5 正式 子情境（學生校內專題報告）
│   ├── E_formal_application.md       → 5 正式 子情境（書信 / 履歷 / 申請文）
│   └── F_academic.md                 → 學術專業（最嚴謹，超出學生 ABCDE 光譜）
│   └── legacy/                       更早版本（封存）
├── examples/
│   ├── ai-vs-human_zh.md             對抗性樣本範例庫（中文輸出）
│   └── ai-vs-human_en.md             對抗性樣本範例庫（英文輸出）
├── self-check.md                     寫作後檢查
└── sample_outputs/                   生成範例（本地用，不入 repo）
    ├── journal_ai.txt                B 風格旅遊雜記
    ├── selfintro.txt                 C 風格學測備審
    └── quantum_prereq.txt            D 風格修課前報告
```

---

## 核心設計原則

0. **不知道直接說 + 必要時提問**（最高原則）— 假裝知道比 AI 味更糟
1. **語境 > 文體**：先判斷對方在什麼語境，再決定文體
2. **像人 ≠ 一種樣子**：閒聊的「像人」跟學術的「像人」完全不同
3. **多語境並存有優先序**：衝突 > 情緒 > 求助 / 教學 > 閒聊
4. **語境會切換**：對話中對方狀態會變，每次回應前重新判斷
5. **制式 ≠ AI 味**：申請文有「敬祝教安」是文化規範，不是 AI 痕跡
6. **立場 ≠ 反共識**：寫立場是「我真的這樣覺得」，不是「我要跟主流不一樣」

---

## 隱私說明

- 所有 `notes.md` 都存在**本地** user data 目錄（sibling 於 skill 目錄）：
  - Claude Code: `~/.claude/skills/humanize-data/contexts/{N}/notes.md`
  - Codex: `${CODEX_HOME:-~/.codex}/skills/humanize-data/contexts/{N}/notes.md`
- **不上傳任何雲端**（AI 工具的對話內容可能送到各自服務端，但這些 notes 檔是 agent 寫入你本機磁碟的）
- 你可以隨時讀取、編輯、刪除 notes
- 用戶若要求「別記這個」，agent 會遵守
- uninstall.sh 預設**保留** `humanize-data/`（升級 / 重灌也不會動）；想徹底清除請加 `--purge-data` 旗標

---

## 自訂

### 暫時停用自動觸發
Claude Code 編輯 `~/.claude/CLAUDE.md`；Codex 編輯 `${CODEX_HOME:-~/.codex}/AGENTS.md`。把 `humanize-skill-auto:start` 到 `:end` 之間的區塊註解掉或刪除。

### 只啟用部分語境
編輯安裝目錄中的 `skills/humanize/SKILL.md`，移除不想要的語境路由。但建議保留全部，agent 會自己挑合適的。

### 修改規則
所有規則都是純 Markdown，直接編輯即可：
- 通用規則 → `core/universal.md`
- 中英文特定 patterns → `core/lang_zh.md` / `core/lang_en.md`
- 語境特定規則 → `contexts/{N}_{name}/README.md`
- 子情境細節 → `presets/X_*.md`

### 加新語言
新增 `core/lang_{lang}.md`，在 `core/context_detection.md` 加偵測規則，universal 不用動。

---

## 設計依據

本 skill 不是憑空設計，是從真實人寫樣本逆向歸納的，樣本涵蓋多份：

- 私人雜記與旅遊日記
- 學校申請書
- 履歷簡歷
- 學生報告(百分百手寫)
- 人為評論

關鍵發現：

1. **「制式 ≠ AI 味」**：高中生申請文有套話是文化規範
2. **「立場 ≠ 反共識」**：刻意唱反調是另一種 AI 味
3. **「結構化 ≠ AI 味」**：學術 / 報告 / 申請文有合法結構化需求
4. **「文白夾雜 ≠ AI 味」**：台灣學術圈傳統用法
5. **真實人寫常有政治不正確、偏見直陳**：AI 預設會 hedge 掉這些
6. **自問自答偶用 ≠ AI 味**：開場設問或內心戲是人類訊號

---

## Roadmap

### Phase 1（已完成）
- 9 大語境 + notes 機制
- i18n（lang_zh / lang_en 智慧載入）
- 最高原則：不知道就說
- install / uninstall 腳本

### Phase 2（後續）
- 為各 context 補 `examples_en.md`（純英文範例庫）
- 加入 `examples_zh.md` 對應到中文範例

### Phase 3（如需要）
- contexts/{N}/README.md 加英文版（目前是中文）
- 補新語言 patterns（日文 / 韓文 / etc.）
- PowerShell `install.ps1` 給 Windows 原生環境

---

## 相關文件

- [`SKILL.md`](./SKILL.md) — 入口與啟動流程
- [`INSTALL.md`](./INSTALL.md) — 完整安裝指南
- [`core/universal.md`](./core/universal.md) — 通用核心規則（最高原則在此）
- [`core/context_detection.md`](./core/context_detection.md) — 語境 / 語言偵測
- [`core/notes_protocol.md`](./core/notes_protocol.md) — 紀錄系統
- [`examples/ai-vs-human_zh.md`](./examples/ai-vs-human_zh.md) / [`ai-vs-human_en.md`](./examples/ai-vs-human_en.md) — 對抗性樣本範例庫（中／英）
- [`self-check.md`](./self-check.md) — 寫作後 self-check 模板

---

## 致謝

本 skill 設計依據真實人寫樣本逆向歸納。
原始樣本不收錄於本 repo（見 `.gitignore` 中的 `Reference/` 排除），但其貢獻對 skill 的設計非常關鍵。
