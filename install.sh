#!/usr/bin/env bash
# install.sh — Install humanize skill for various AI coding tools
#
# Currently supported tools:
#   - claude-code (default, fully supported)
#   - codex (fully supported)
#   - antigravity (not yet supported — see help)
#
# Architecture (v0.4.0+):
#   ${SKILLS_DIR}/humanize/         skill payload, overwritten on each install
#   ${SKILLS_DIR}/humanize-data/    user notes (NEVER touched by installer)
#
# Usage:
#   bash install.sh                     # interactive install for Claude Code
#   bash install.sh --tool=claude-code  # explicit tool selection
#   bash install.sh --tool=codex        # install for OpenAI Codex
#   bash install.sh --dev               # symlink mode (for skill development)
#   bash install.sh --no-auto           # skip auto-trigger
#   bash install.sh --silent            # no prompts, full install with defaults
#   bash install.sh --help              # show help

set -e

# ─── 共用設定 ───────────────────────────────────────
SKILL_NAME="humanize"
DATA_NAME="humanize-data"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL="claude-code"  # default

AUTO_TRIGGER_MARKER_START="<!-- humanize-skill-auto:start -->"
AUTO_TRIGGER_MARKER_END="<!-- humanize-skill-auto:end -->"

# ─── 版本 ───────────────────────────────────────────
if [[ -f "$REPO_DIR/VERSION" ]]; then
    REPO_VERSION="$(tr -d ' \t\n\r' < "$REPO_DIR/VERSION")"
else
    REPO_VERSION="unknown"
fi

# ─── Tool-specific config (will be set based on --tool=) ────
SKILL_DIR=""
DATA_DIR=""
INSTRUCTION_FILE=""
ROOT_DIR=""
SKILLS_DIR=""
INVOCATION_HINT="/humanize"

setup_tool_config() {
    case "$TOOL" in
        claude-code)
            SKILL_DIR="${HOME}/.claude/skills/${SKILL_NAME}"
            DATA_DIR="${HOME}/.claude/skills/${DATA_NAME}"
            INSTRUCTION_FILE="${HOME}/.claude/CLAUDE.md"
            ROOT_DIR="${HOME}/.claude"
            SKILLS_DIR="${HOME}/.claude/skills"
            INVOCATION_HINT="/humanize"
            ;;
        codex)
            ROOT_DIR="${CODEX_HOME:-${HOME}/.codex}"
            SKILL_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
            DATA_DIR="${ROOT_DIR}/skills/${DATA_NAME}"
            INSTRUCTION_FILE="${ROOT_DIR}/AGENTS.md"
            SKILLS_DIR="${ROOT_DIR}/skills"
            INVOCATION_HINT="\$humanize"
            ;;
        antigravity)
            cat <<EOF >&2

═══ Tool 'antigravity' 尚未支援 ═══

Google Antigravity IDE 的 skill / agent 設定機制尚未確認。
需要的資訊：
  1. Antigravity 把 agent instructions 放在哪個目錄？
     （IDE 的設定目錄 / 專案目錄 / 全域使用者目錄？）
  2. 有沒有 CLAUDE.md / AGENTS.md 等價的自動載入指令檔？
  3. 是否支援 markdown skill 格式，或需要特定格式？

如果你知道這些，請開 issue 或 PR 補充。
目前可安裝的 tool: claude-code（預設，完整支援）、codex（完整支援）
改用: bash install.sh --tool=claude-code 或 bash install.sh --tool=codex
EOF
            exit 2
            ;;
        *)
            echo "Unknown tool: $TOOL" >&2
            echo "Supported: claude-code, codex, antigravity (stub)" >&2
            exit 1
            ;;
    esac
}

build_auto_trigger_block() {
AUTO_TRIGGER_BLOCK="${AUTO_TRIGGER_MARKER_START}
## humanize skill 自動套用

### 最高原則（凌駕一切）
**不知道直接說 + 必要時向用戶提問。** 不要編造、不要用模糊語言掩護無知、不要把不確定的事實寫得像確定的事實。假裝知道比 AI 味更糟。詳見 \`${SKILL_DIR}/core/universal.md\` 第 0 條。

### 每次回應流程
1. 讀 \`${SKILL_DIR}/SKILL.md\` 入口檔
2. 依 \`${SKILL_DIR}/core/context_detection.md\` 偵測對方語境（9 大類）
3. **偵測輸出語言**（中文 / 英文 / 雙語）→ 載入對應的 \`core/lang_zh.md\` 或 \`core/lang_en.md\`（省 token：只載相關語言）
4. 讀對應 \`${SKILL_DIR}/contexts/{N}_{name}/README.md\` 規則
5. 讀對應 **\`${DATA_DIR}/contexts/{N}_{name}/notes.md\`** 用戶習慣（不存在則退讀 skill 內模板）
6. 套規則回應（最高原則優先：不知道就說、不確定就問）
7. **靜默**更新 \`${DATA_DIR}/contexts/{N}_{name}/notes.md\`（不要在回應內容裡提及此更新動作；不要寫進 skill 內模板，那會被升級覆寫）

### 規則來源
- 通用結構規則：\`${SKILL_DIR}/core/universal.md\`（英文，語言中立）
- 中文特定 patterns：\`${SKILL_DIR}/core/lang_zh.md\`（中文輸出時載入）
- 英文特定 patterns：\`${SKILL_DIR}/core/lang_en.md\`（英文輸出時載入）

### 更新 notes 規則
詳見 \`${SKILL_DIR}/core/notes_protocol.md\`：
- 真實 notes 永遠寫到 \`${DATA_DIR}/contexts/{N}/notes.md\`
- 最小紀錄（每條 < 1 行）
- 太遠的事件採濃縮（不刪除）
- 用戶明確要求別記的不要記
${AUTO_TRIGGER_MARKER_END}"
}

# ─── 旗標 ───────────────────────────────────────────
MODE="copy"
AUTO_TRIGGER="ask"
SILENT="no"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tool=*)   TOOL="${1#*=}"; shift ;;
        --tool)     TOOL="$2"; shift 2 ;;
        --dev)      MODE="symlink"; shift ;;
        --copy)     MODE="copy"; shift ;;
        --no-auto)  AUTO_TRIGGER="no"; shift ;;
        --auto)     AUTO_TRIGGER="yes"; shift ;;
        --silent)   SILENT="yes"; AUTO_TRIGGER="yes"; shift ;;
        --help|-h)
            cat <<EOF
humanize skill installer (v$REPO_VERSION)

Usage:
  bash install.sh                       interactive install (Claude Code, copy mode)
  bash install.sh --tool=claude-code    explicit tool selection (default)
  bash install.sh --tool=codex          install for OpenAI Codex
  bash install.sh --tool=antigravity    (stub — not yet supported)
  bash install.sh --dev                 symlink mode (for skill development)
  bash install.sh --no-auto             skip auto-trigger setup
  bash install.sh --silent              no prompts, full install with defaults
  bash install.sh --help                show this help

Supported tools:
  - claude-code: fully supported
  - codex: fully supported
  - antigravity: stub (needs path info — open an issue if you know the structure)

Layout after install:
  <tool root>/skills/humanize/        skill payload (overwritten on each install)
  <tool root>/skills/humanize-data/   user notes (NEVER touched by installer)

To uninstall later:
  bash ${REPO_DIR}/uninstall.sh [--tool=<name>]
EOF
            exit 0 ;;
        *)
            echo "Unknown flag: $1" >&2
            echo "Use --help for usage" >&2
            exit 1 ;;
    esac
done

# Resolve tool-specific config (may exit if unsupported tool)
setup_tool_config
build_auto_trigger_block

# ─── 環境檢查 ────────────────────────────────────────
echo "═══ humanize skill installer (tool=$TOOL, version=$REPO_VERSION) ═══"
echo

if [[ ! -d "$ROOT_DIR" ]]; then
    echo "⚠  $ROOT_DIR 不存在。可能還沒裝 $TOOL？"
    echo "  繼續安裝會自動建立目錄，但若沒裝 $TOOL 此 skill 無法運作。"
    if [[ "$SILENT" != "yes" ]]; then
        read -p "  繼續嗎？ (y/N) " continue_anyway
        [[ ! "$continue_anyway" =~ ^[Yy]$ ]] && exit 1
    fi
fi

mkdir -p "$SKILLS_DIR"

# ─── 版本比對 ────────────────────────────────────────
INSTALLED_VERSION=""
if [[ -f "$SKILL_DIR/VERSION" ]]; then
    INSTALLED_VERSION="$(tr -d ' \t\n\r' < "$SKILL_DIR/VERSION" 2>/dev/null || echo "")"
fi

if [[ -n "$INSTALLED_VERSION" ]]; then
    if [[ "$INSTALLED_VERSION" == "$REPO_VERSION" ]]; then
        echo "ℹ  已安裝版本 = $INSTALLED_VERSION（與 repo 同版，將執行重灌）"
    else
        echo "↑  升級偵測: $INSTALLED_VERSION  →  $REPO_VERSION"
    fi
else
    if [[ -d "$SKILL_DIR" ]]; then
        echo "ℹ  舊安裝沒有 VERSION 標記（升級到 $REPO_VERSION）"
    else
        echo "ℹ  全新安裝: $REPO_VERSION"
    fi
fi
echo

# ─── Step 1: 安裝 skill 檔案 ─────────────────────────
echo "[1/4] 安裝 skill 檔案 (mode: $MODE)..."

if [[ -e "$SKILL_DIR" || -L "$SKILL_DIR" ]]; then
    echo "  已存在的安裝，移除中..."
    rm -rf "$SKILL_DIR"
fi

if [[ "$MODE" == "symlink" ]]; then
    ln -s "$REPO_DIR" "$SKILL_DIR"
    echo "  ✓ symlinked: $SKILL_DIR -> $REPO_DIR"
else
    # 排除 .git、安裝腳本本身、Reference 樣本（內含真實資料）
    rsync -a \
        --exclude '.git' \
        --exclude '.DS_Store' \
        --exclude 'install.sh' \
        --exclude 'install.ps1' \
        --exclude 'uninstall.sh' \
        --exclude 'uninstall.ps1' \
        --exclude 'Reference' \
        --exclude 'sample_outputs' \
        "$REPO_DIR/" "$SKILL_DIR/"
    echo "  ✓ copied to: $SKILL_DIR"
fi

# 確認結構
required=(
    "$SKILL_DIR/SKILL.md"
    "$SKILL_DIR/VERSION"
    "$SKILL_DIR/core/universal.md"
    "$SKILL_DIR/core/context_detection.md"
    "$SKILL_DIR/core/notes_protocol.md"
    "$SKILL_DIR/core/lang_zh.md"
    "$SKILL_DIR/core/lang_en.md"
)
for f in "${required[@]}"; do
    if [[ ! -f "$f" ]]; then
        echo "  ✗ 缺少關鍵檔案: $f"
        exit 1
    fi
done
echo "  ✓ 核心檔案完整"

# ─── Step 2: 初始化 humanize-data/（首次） ───────────
echo "[2/4] 初始化 user data 目錄..."
echo "  位置: $DATA_DIR"
DATA_FRESH="no"
if [[ ! -d "$DATA_DIR" ]]; then
    mkdir -p "$DATA_DIR/contexts"
    DATA_FRESH="yes"
    echo "  ✓ 建立新的 user data 目錄"
else
    echo "  ✓ 已存在的 user data 目錄保留（內容不動）"
fi

# 對每個 context：若 humanize-data 內沒有 notes.md，複製 skill 內模板過去
init_count=0
keep_count=0
for ctx in 1_chat 2_emotional 3_help 4_discussion 5_formal 6_intimate 7_conflict 8_creative 9_teaching; do
    src="$SKILL_DIR/contexts/$ctx/notes.md"
    dst_dir="$DATA_DIR/contexts/$ctx"
    dst="$dst_dir/notes.md"
    if [[ ! -f "$src" ]]; then
        echo "  ⚠  skill 內模板缺失: $src（跳過此 context）"
        continue
    fi
    mkdir -p "$dst_dir"
    if [[ -f "$dst" ]]; then
        keep_count=$((keep_count + 1))
    else
        cp "$src" "$dst"
        init_count=$((init_count + 1))
    fi
done
echo "  ✓ user data: $init_count 新建 / $keep_count 保留"

# ─── Step 3: 確認 skill 內 notes 模板存在 ────────────
echo "[3/4] 確認 skill 內 notes.md 模板..."
template_missing=0
for ctx in 1_chat 2_emotional 3_help 4_discussion 5_formal 6_intimate 7_conflict 8_creative 9_teaching; do
    note_file="$SKILL_DIR/contexts/$ctx/notes.md"
    if [[ ! -f "$note_file" ]]; then
        echo "  ⚠  template 缺失: $ctx"
        template_missing=$((template_missing + 1))
    fi
done
if [[ $template_missing -eq 0 ]]; then
    echo "  ✓ 9 個 context 模板就緒"
fi

# ─── Step 4: 設定自動觸發 ────────────────────────────
echo "[4/4] 自動觸發設定..."

if [[ "$AUTO_TRIGGER" == "ask" ]]; then
    echo
    echo "  自動觸發 = 在 $INSTRUCTION_FILE 加一段指令，"
    echo "  讓 $TOOL 每次回應前自動讀 humanize skill 並套規則。"
    echo "  好處：不用手動 ${INVOCATION_HINT}"
    echo "  缺點：每輪會多消耗少量 context tokens"
    echo
    read -p "  啟用自動觸發？ (Y/n) " auto_yn
    if [[ ! "$auto_yn" =~ ^[Nn]$ ]]; then
        AUTO_TRIGGER="yes"
    else
        AUTO_TRIGGER="no"
    fi
fi

if [[ "$AUTO_TRIGGER" == "yes" ]]; then
    if [[ -f "$INSTRUCTION_FILE" ]] && grep -q "humanize-skill-auto:start" "$INSTRUCTION_FILE"; then
        # 重灌時把舊區塊整段換成新的（路徑可能變、版本可能變）
        tmpfile=$(mktemp)
        awk -v start="humanize-skill-auto:start" -v end="humanize-skill-auto:end" '
            $0 ~ start {skip=1; next}
            $0 ~ end {skip=0; next}
            !skip
        ' "$INSTRUCTION_FILE" > "$tmpfile"
        # 清掉因移除而產生的連續空白行
        awk 'BEGIN{blank=0} /^$/{blank++; if(blank<=1) print; next} {blank=0; print}' "$tmpfile" > "$INSTRUCTION_FILE"
        rm "$tmpfile"
        echo "" >> "$INSTRUCTION_FILE"
        echo "$AUTO_TRIGGER_BLOCK" >> "$INSTRUCTION_FILE"
        echo "  ✓ 已更新自動觸發區塊（含新版路徑 / 版本）"
    else
        # 加區塊（如果指令檔已存在則 append，不存在則建立）
        if [[ -f "$INSTRUCTION_FILE" ]]; then
            echo "" >> "$INSTRUCTION_FILE"
        else
            mkdir -p "$(dirname "$INSTRUCTION_FILE")"
            touch "$INSTRUCTION_FILE"
        fi
        echo "$AUTO_TRIGGER_BLOCK" >> "$INSTRUCTION_FILE"
        echo "  ✓ 已加自動觸發到 $INSTRUCTION_FILE"
    fi
else
    echo "  ⊘ 跳過自動觸發。要用時需手動 ${INVOCATION_HINT}"
fi

# ─── 完成 ───────────────────────────────────────────
echo
echo "═══ 安裝完成 ═══"
echo
echo "Tool:            $TOOL"
echo "Skill 位置:      $SKILL_DIR"
echo "User data:       $DATA_DIR"
if [[ -n "$INSTALLED_VERSION" && "$INSTALLED_VERSION" != "$REPO_VERSION" ]]; then
    echo "版本:            $INSTALLED_VERSION  →  $REPO_VERSION"
else
    echo "版本:            $REPO_VERSION"
fi
echo "Mode:            $MODE"
echo "Auto-trigger:    $AUTO_TRIGGER"
echo
echo "下一步："
echo "  • 開新的 $TOOL 對話"
if [[ "$AUTO_TRIGGER" == "yes" ]]; then
    echo "  • $TOOL 會自動套用 humanize skill（每輪偵測語境 + 紀錄）"
else
    echo "  • 在對話中輸入 ${INVOCATION_HINT} 來啟用"
fi
echo
echo "想移除：bash $REPO_DIR/uninstall.sh --tool=$TOOL"
echo "  （預設保留 $DATA_DIR；想連 notes 一起刪用 --purge-data）"
echo "想看文檔：cat $SKILL_DIR/README.md"
