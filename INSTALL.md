# 安裝指南 (Installation Guide)

`/humanize` skill 安裝後可讓 Claude Code 在每次回應時自動偵測語境並套用對應規則。

---

## 系統需求

- **Claude Code** 已安裝（`~/.claude/` 目錄存在）
- macOS / Linux（Windows 使用者請看下方 [Windows 章節](#windows)）
- Bash 4+ 或 zsh
- `rsync` 已安裝（macOS / Linux 通常已內建）

---

## 快速安裝（一行）

```bash
git clone <repo-url> humanize-skill
cd humanize-skill
bash install.sh
```

安裝過程會問你「是否啟用自動觸發」（建議：是）。

完成後，**開新的 Claude Code 對話**即生效。

---

## 安裝模式

### 標準模式（推薦給一般使用者）
```bash
bash install.sh
```
- skill 檔案會 **複製** 到 `~/.claude/skills/humanize/`
- 你可以後續移動或刪除原本下載的資料夾，skill 仍可運作
- 互動式問你要不要啟用自動觸發

### 開發模式（推薦給 skill 開發者）
```bash
bash install.sh --dev
```
- skill 檔案會 **symlink** 到 `~/.claude/skills/humanize/`
- 你在原本資料夾的修改會即時反映
- 適合迭代 skill 內容

### 靜默模式（適合 CI / 自動化）
```bash
bash install.sh --silent
```
- 不問任何問題
- 預設啟用自動觸發、使用複製模式

### 不要自動觸發
```bash
bash install.sh --no-auto
```
- 安裝 skill 但不修改 `~/.claude/CLAUDE.md`
- 要用時手動輸入 `/humanize`

---

## 安裝後驗證

### 1. 檔案就位
```bash
ls ~/.claude/skills/humanize/
# 應看到: SKILL.md  README.md  core/  contexts/  examples/  presets/  ...
```

### 2. 自動觸發已加入（如選了 auto）
```bash
grep -A 3 "humanize-skill-auto:start" ~/.claude/CLAUDE.md
# 應看到自動觸發區塊
```

### 3. 開新對話測試
- 打開新的 Claude Code 對話
- 隨便傳一句話，例如 「我今天有點累」
- Claude 應該以 **情緒語境** 回應（共感優先、不立刻給解法）
- 而不是傳統的「我可以協助你分析壓力來源並提供解決方案」

---

## 安裝後會發生什麼

### Skill 檔案
位置：`~/.claude/skills/humanize/`
內含：
- `SKILL.md` — 入口路由
- `core/` — 通用規則 + 語境判斷 + 紀錄協議
- `contexts/1-9/` — 9 個語境，各含 README + notes.md
- `examples/`、`presets/`、`self-check.md`

### Auto-trigger 區塊（如啟用）
位置：`~/.claude/CLAUDE.md`
內容：用 markers 包起來的指令區塊（不會干擾你自己的 CLAUDE.md 內容）

```markdown
<!-- humanize-skill-auto:start -->
## /humanize skill 自動套用
每次回應前依以下流程處理：
1. 讀入口檔
2. 偵測語境
3. ...
<!-- humanize-skill-auto:end -->
```

uninstall 時這個區塊會被乾淨移除（透過 markers 識別）。

### 用戶習慣紀錄
位置：`~/.claude/skills/humanize/contexts/{N}_{name}/notes.md`
- 一開始是空白模板
- Claude 互動後會慢慢累積（最小紀錄原則，每條 < 1 行）
- 9 個語境分別紀錄不同類型的習慣 / 偏好 / 踩坑 / 學習進度

---

## 隱私說明

- 所有 notes.md 都存在 **本地** `~/.claude/skills/humanize/`
- **不會上傳到任何雲端**（Claude Code 的對話內容會傳到 Anthropic，但這些檔案是 Claude 寫入你本機磁碟的）
- 你可以隨時讀取、編輯、刪除 notes.md
- 用戶若要求「別記這個」，Claude 會遵守並避免寫入相關內容

---

## 移除

### 完整移除
```bash
bash uninstall.sh
```
會移除：
- `~/.claude/skills/humanize/` 整個目錄
- `~/.claude/CLAUDE.md` 中的自動觸發區塊

### 保留 notes.md 備份
```bash
bash uninstall.sh --keep-notes
```
會在 `~/.claude/humanize-notes-backup-YYYYMMDD_HHMMSS/` 備份所有 notes，再執行完整移除。

---

## 更新 Skill

### 標準模式（複製版）
```bash
cd humanize-skill  # 原本 clone 的位置
git pull
bash install.sh    # 重跑會覆蓋舊版
```

### 開發模式（symlink 版）
```bash
cd humanize-skill
git pull
# 不用重新 install，symlink 已指向原始檔案
```

---

## 常見問題

### Q: 自動觸發會讓每次對話變慢嗎？
A: 多消耗少量 tokens（讀 SKILL.md 約幾百 token）。延遲可忽略，但 context window 會稍微壓縮。

### Q: 如何暫時停用自動觸發？
A: 編輯 `~/.claude/CLAUDE.md`，把自動觸發區塊註解掉或刪除。或執行 `uninstall.sh` 後再用 `install.sh --no-auto` 重裝。

### Q: 同時開多個 Claude Code 對話會衝突嗎？
A: 不會。notes.md 是 append 為主，但多開可能造成相同事件被記兩次。長期看影響不大。

### Q: notes.md 太大怎麼辦？
A: Claude 會依 `notes_protocol.md` 自動觸發濃縮（細節事件 → 模式描述）。手動清也行。

### Q: 我可以只啟用部分語境嗎？
A: 編輯 `~/.claude/skills/humanize/SKILL.md` 移除不想要的語境路由。但建議保留全部，Claude 會自己挑合適的。

---

## Windows（PowerShell 原生支援）

Windows 使用者可以直接用 PowerShell 版安裝：

```powershell
# 互動安裝
.\install.ps1

# 靜默安裝（適合 CI）
.\install.ps1 -Silent

# 開發模式（symlink，需 Developer Mode 或系統管理員）
.\install.ps1 -Dev

# 跳過自動觸發
.\install.ps1 -NoAuto

# 顯示完整說明
Get-Help .\install.ps1 -Detailed
```

如果 PowerShell 執行政策阻擋，先跑：
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

移除：`.\uninstall.ps1`，加 `-KeepNotes` 可備份 notes 後再移除。

**WSL2 替代方案**：在 WSL2 內跑 `bash install.sh` 也行。

---

## 多工具支援（Multi-tool）

目前完整支援的：
- ✅ **claude-code**（預設）

stub（架構就緒、需路徑資訊才能補完）：
- ⏳ **codex**（OpenAI Codex CLI）
- ⏳ **antigravity**（Google Antigravity IDE）

指定 tool：
```bash
bash install.sh --tool=claude-code   # 預設可省略
bash install.sh --tool=codex          # 目前顯示 stub 訊息
```

PowerShell 版：
```powershell
.\install.ps1 -Tool claude-code
```

如果你知道 codex / antigravity 的：
1. custom instructions / skills 目錄路徑
2. 是否有 CLAUDE.md 等價的自動載入指令檔
3. 自動觸發機制

請開 issue / PR 補完 `setup_tool_config()` 函式。架構已就緒，只需填路徑即可。

---

## 開發者註

- skill 檔案結構詳見 `README.md`
- 修改後可用 `bash install.sh --dev` 安裝 symlink，立即生效
- `install.sh` 預設排除 `Reference/` 與 `sample_outputs/problem.txt`（內含本地測試資料）
