# 安裝指南 (Installation Guide)

`/humanize` skill 安裝後可讓 Claude Code 或 OpenAI Codex 在每次回應時自動偵測語境並套用對應規則。

---

## 系統需求

- **Claude Code** 已安裝（`~/.claude/` 目錄存在）或 **OpenAI Codex** 已安裝（`~/.codex/` 目錄存在，或設定 `CODEX_HOME`）
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

安裝到 Codex：
```bash
bash install.sh --tool=codex
```

安裝過程會問你「是否啟用自動觸發」（建議：是）。

完成後，**開新的 Claude Code / Codex 對話**即生效。

---

## 安裝模式

### 標準模式（推薦給一般使用者）
```bash
bash install.sh
```
- skill 檔案會 **複製** 到 `~/.claude/skills/humanize/`
- 如果指定 `--tool=codex`，會複製到 `${CODEX_HOME:-~/.codex}/skills/humanize/`
- 你可以後續移動或刪除原本下載的資料夾，skill 仍可運作
- 互動式問你要不要啟用自動觸發

### 開發模式（推薦給 skill 開發者）
```bash
bash install.sh --dev
```
- skill 檔案會 **symlink** 到 `~/.claude/skills/humanize/`
- 如果指定 `--tool=codex`，symlink 會放在 `${CODEX_HOME:-~/.codex}/skills/humanize/`
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
- 安裝 skill 但不修改目標工具的指令檔（Claude Code: `~/.claude/CLAUDE.md`；Codex: `${CODEX_HOME:-~/.codex}/AGENTS.md`）
- 要用時 Claude Code 手動輸入 `/humanize`，Codex 手動輸入 `$humanize`

---

## 安裝後驗證

### 1. 檔案就位
```bash
ls ~/.claude/skills/humanize/
# 應看到: SKILL.md  README.md  core/  contexts/  examples/  presets/  ...

ls ~/.codex/skills/humanize/
# Codex 使用者應看到同樣結構
```

### 2. 自動觸發已加入（如選了 auto）
```bash
grep -A 3 "humanize-skill-auto:start" ~/.claude/CLAUDE.md
# 應看到自動觸發區塊

grep -A 3 "humanize-skill-auto:start" ~/.codex/AGENTS.md
# Codex 使用者應看到自動觸發區塊
```

### 3. 開新對話測試
- 打開新的 Claude Code / Codex 對話
- 隨便傳一句話，例如 「我今天有點累」
- agent 應該以 **情緒語境** 回應（共感優先、不立刻給解法）
- 而不是傳統的「我可以協助你分析壓力來源並提供解決方案」

---

## 版本管控（v0.4.0+）

- 單一真實來源：repo root 的 `VERSION` 檔（目前 **0.4.0**），同步寫入 `SKILL.md` frontmatter 的 `version`
- installer 把 `VERSION` 一併安裝到 `${SKILL_DIR}/VERSION` 作為「已安裝版本」標記
- 升級時 installer 自動比對 `repo VERSION` vs `${SKILL_DIR}/VERSION` 並印升級 banner（`0.3.x → 0.4.0`）
- frontmatter `version` 與根 `VERSION` 檔**必須同步**；改一個就要改另一個

---

## 安裝後會發生什麼

### Skill 檔案（會被升級覆寫）
位置：
- Claude Code: `~/.claude/skills/humanize/`
- Codex: `${CODEX_HOME:-~/.codex}/skills/humanize/`

內含：
- `VERSION` — 已安裝版本標記
- `SKILL.md` — 入口路由
- `core/` — 通用規則 + 語境判斷 + 紀錄協議
- `contexts/1-9/` — 9 個語境，各含 README + notes.md **模板**
- `examples/`、`presets/`、`self-check.md`

### User data 目錄（installer 永不碰）★ v0.4.0 新增
位置：
- Claude Code: `~/.claude/skills/humanize-data/`
- Codex: `${CODEX_HOME:-~/.codex}/skills/humanize-data/`

內含：
- `contexts/{1..9}_{name}/notes.md` — 真實累積的用戶習慣記憶

**重要**：
- agent **永遠**寫入這個目錄，不寫進 skill 內模板
- 升級 / 重灌 / uninstall 預設都**不會**動這個目錄
- 想徹底清除請 `bash uninstall.sh --purge-data`（或手動 `rm -rf`）

### Auto-trigger 區塊（如啟用）
位置：
- Claude Code: `~/.claude/CLAUDE.md`
- Codex: `${CODEX_HOME:-~/.codex}/AGENTS.md`

內容：用 markers 包起來的指令區塊，**內含當前 SKILL_DIR / DATA_DIR 絕對路徑**（升級時 installer 會自動替換成新版區塊）。

```markdown
<!-- humanize-skill-auto:start -->
## humanize skill 自動套用
... 含 SKILL_DIR / DATA_DIR 路徑 ...
<!-- humanize-skill-auto:end -->
```

uninstall 時這個區塊會被乾淨移除（透過 markers 識別）。

---

## 隱私說明

- 所有 notes 都存在**本地** `humanize-data/` 目錄
- **不會上傳到任何雲端**（AI 工具的對話內容可能送到各自服務端，但這些檔案是 agent 寫入你本機磁碟的）
- 你可以隨時讀取、編輯、刪除 `humanize-data/contexts/*/notes.md`
- 用戶若要求「別記這個」，agent 會遵守並避免寫入相關內容

---

## 移除

### 預設移除（保留 notes）
```bash
bash uninstall.sh
```
會：
- ✓ 移除 `~/.claude/skills/humanize/` 整個 skill 目錄
- ✓ 移除 `~/.claude/CLAUDE.md` 中的自動觸發區塊
- **保留** `~/.claude/skills/humanize-data/`（user notes）— 下次重裝可直接接上

Codex：
```bash
bash uninstall.sh --tool=codex
```

### 連 notes 一起刪
```bash
bash uninstall.sh --purge-data
```
**注意**：會徹底刪除 `humanize-data/`，所有累積的用戶記憶都會消失，不可復原。

舊 flag `--keep-notes` 已 deprecated（notes 預設就保留）。

---

## 更新 Skill（升級流程）

### 標準模式（複製版）
```bash
cd humanize-skill   # 原本 clone 的位置
git pull
bash install.sh     # installer 會自動：
                    #   1. 比對版本，印 "0.3.x → 0.4.0" banner
                    #   2. 覆寫 ~/.claude/skills/humanize/（含新 VERSION 檔）
                    #   3. 不動 ~/.claude/skills/humanize-data/（保留 notes）
                    #   4. 把 instruction file 的 auto-trigger 區塊換成新版
```

### 開發模式（symlink 版）
```bash
cd humanize-skill
git pull
# symlink 指向 repo，內容即時生效
# 但若 SKILL.md 變動了路徑 / 邏輯，需要重跑 install.sh --dev 來更新
# instruction file 的 auto-trigger 區塊（含絕對路徑）
```

### 驗證已升級
```bash
cat ~/.claude/skills/humanize/VERSION       # 應顯示 0.4.0
head -5 ~/.claude/skills/humanize/SKILL.md  # frontmatter 內 version 應一致
ls ~/.claude/skills/humanize-data/contexts/ # 確認 notes 還在
```

---

## 常見問題

### Q: 自動觸發會讓每次對話變慢嗎？
A: 多消耗少量 tokens（讀 SKILL.md 約幾百 token）。延遲可忽略，但 context window 會稍微壓縮。

### Q: 如何暫時停用自動觸發？
A: Claude Code 編輯 `~/.claude/CLAUDE.md`；Codex 編輯 `${CODEX_HOME:-~/.codex}/AGENTS.md`。把自動觸發區塊註解掉或刪除，或執行 `uninstall.sh` 後再用 `install.sh --no-auto` 重裝。

### Q: 同時開多個 AI 工具對話會衝突嗎？
A: 不會。notes.md 是 append 為主，但多開可能造成相同事件被記兩次。長期看影響不大。

### Q: notes.md 太大怎麼辦？
A: agent 會依 `notes_protocol.md` 自動觸發濃縮（細節事件 → 模式描述）。手動清也行。

### Q: 我可以只啟用部分語境嗎？
A: 編輯安裝目錄中的 `skills/humanize/SKILL.md` 移除不想要的語境路由。但建議保留全部，agent 會自己挑合適的。

---

## Windows（PowerShell 原生支援）

Windows 使用者可以直接用 PowerShell 版安裝：

```powershell
# 互動安裝
.\install.ps1

# 安裝到 Codex
.\install.ps1 -Tool codex

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

移除：`.\uninstall.ps1`（預設保留 notes），加 `-PurgeData` 連 notes 一起刪。`-KeepNotes` 已 deprecated（預設就保留）。

**WSL2 替代方案**：在 WSL2 內跑 `bash install.sh` 也行。

---

## 多工具支援（Multi-tool）

目前完整支援的：
- ✅ **claude-code**（預設）
- ✅ **codex**（OpenAI Codex CLI；使用 `${CODEX_HOME:-~/.codex}` / `%CODEX_HOME%`）

stub（架構就緒、需路徑資訊才能補完）：
- ⏳ **antigravity**（Google Antigravity IDE）

指定 tool：
```bash
bash install.sh --tool=claude-code   # 預設可省略
bash install.sh --tool=codex          # 安裝到 OpenAI Codex
```

PowerShell 版：
```powershell
.\install.ps1 -Tool claude-code
.\install.ps1 -Tool codex
```

如果你知道 antigravity 的：
1. custom instructions / skills 目錄路徑
2. 是否有 CLAUDE.md 等價的自動載入指令檔
3. 自動觸發機制

請開 issue / PR 補完 `setup_tool_config()` 函式。架構已就緒，只需填路徑即可。

---

## 開發者註

- skill 檔案結構詳見 `README.md`
- 修改後可用 `bash install.sh --dev` 安裝 symlink，立即生效
- `install.sh` 預設排除 `Reference/` 與 `sample_outputs/problem.txt`（內含本地測試資料）
