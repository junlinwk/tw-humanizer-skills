#!/usr/bin/env bash
# uninstall.sh — Remove humanize skill from supported AI coding tools
#
# Default behavior (v0.4.0+):
#   - Removes ${SKILLS_DIR}/humanize/ (skill payload)
#   - Removes auto-trigger block from instruction file
#   - **Preserves ${SKILLS_DIR}/humanize-data/ by default**（user notes 不動）
#
# Usage:
#   bash uninstall.sh                       interactive uninstall (Claude Code)
#   bash uninstall.sh --tool=claude-code    explicit tool selection
#   bash uninstall.sh --tool=codex          uninstall from OpenAI Codex
#   bash uninstall.sh --silent              no prompts
#   bash uninstall.sh --purge-data          also wipe humanize-data/ (notes 一起刪)
#   bash uninstall.sh --keep-notes          (deprecated; notes 預設就保留)

set -e

SKILL_NAME="humanize"
DATA_NAME="humanize-data"
TOOL="claude-code"
SKILL_DIR=""
DATA_DIR=""
INSTRUCTION_FILE=""

setup_tool_config() {
    case "$TOOL" in
        claude-code)
            SKILL_DIR="${HOME}/.claude/skills/${SKILL_NAME}"
            DATA_DIR="${HOME}/.claude/skills/${DATA_NAME}"
            INSTRUCTION_FILE="${HOME}/.claude/CLAUDE.md"
            ROOT_DIR="${HOME}/.claude"
            ;;
        codex)
            ROOT_DIR="${CODEX_HOME:-${HOME}/.codex}"
            SKILL_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
            DATA_DIR="${ROOT_DIR}/skills/${DATA_NAME}"
            INSTRUCTION_FILE="${ROOT_DIR}/AGENTS.md"
            ;;
        antigravity)
            echo "Tool '$TOOL' 尚未支援。見 install.sh --help" >&2
            exit 2
            ;;
        *)
            echo "Unknown tool: $TOOL" >&2
            exit 1
            ;;
    esac
}

SILENT="no"
PURGE_DATA="no"
KEEP_NOTES_DEPRECATED="no"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tool=*)       TOOL="${1#*=}"; shift ;;
        --tool)         TOOL="$2"; shift 2 ;;
        --silent)       SILENT="yes"; shift ;;
        --purge-data)   PURGE_DATA="yes"; shift ;;
        --keep-notes)   KEEP_NOTES_DEPRECATED="yes"; shift ;;  # backwards compat (no-op; default保留)
        --help|-h)
            cat <<EOF
humanize skill uninstaller

Usage:
  bash uninstall.sh                       interactive uninstall (Claude Code)
  bash uninstall.sh --tool=claude-code    explicit tool selection
  bash uninstall.sh --tool=codex          uninstall from OpenAI Codex
  bash uninstall.sh --silent              no prompts
  bash uninstall.sh --purge-data          ALSO delete user notes (humanize-data/)
  bash uninstall.sh --keep-notes          (deprecated; notes 預設就保留)

Default behavior:
  ✓ Removes skill folder (humanize/)
  ✓ Removes auto-trigger block from instruction file
  ✓ Preserves user notes in humanize-data/ (use --purge-data to wipe them too)

Supported tools: claude-code, codex (antigravity is a stub in install.sh)
EOF
            exit 0 ;;
        *)
            echo "Unknown flag: $1" >&2
            exit 1 ;;
    esac
done

setup_tool_config

echo "═══ humanize skill uninstaller (tool=$TOOL) ═══"
echo

if [[ "$KEEP_NOTES_DEPRECATED" == "yes" ]]; then
    echo "ℹ  --keep-notes 已 deprecated（notes 預設就保留在 $DATA_DIR）"
    echo
fi

# ─── Step 1: 移除 skill 檔案 ─────────────────────────
echo "[1/3] 移除 skill 檔案..."
if [[ -L "$SKILL_DIR" ]]; then
    rm "$SKILL_DIR"
    echo "  ✓ 移除 symlink: $SKILL_DIR"
elif [[ -d "$SKILL_DIR" ]]; then
    if [[ "$SILENT" != "yes" ]]; then
        read -p "  確定刪除 $SKILL_DIR ？ (y/N) " confirm
        [[ ! "$confirm" =~ ^[Yy]$ ]] && { echo "  取消"; exit 0; }
    fi
    rm -rf "$SKILL_DIR"
    echo "  ✓ 移除目錄: $SKILL_DIR"
else
    echo "  ⊘ 找不到 $SKILL_DIR （可能已移除）"
fi

# ─── Step 2: 處理 humanize-data/ ────────────────────
echo "[2/3] 處理 user data 目錄..."
if [[ "$PURGE_DATA" == "yes" ]]; then
    if [[ -d "$DATA_DIR" ]]; then
        if [[ "$SILENT" != "yes" ]]; then
            read -p "  ⚠  確定刪除 $DATA_DIR ？(這會清除所有 notes) (y/N) " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo "  保留 $DATA_DIR"
            else
                rm -rf "$DATA_DIR"
                echo "  ✓ 移除 user data: $DATA_DIR"
            fi
        else
            rm -rf "$DATA_DIR"
            echo "  ✓ 移除 user data: $DATA_DIR"
        fi
    else
        echo "  ⊘ $DATA_DIR 不存在"
    fi
else
    if [[ -d "$DATA_DIR" ]]; then
        echo "  ✓ 保留 $DATA_DIR （未來重裝可繼續用；要刪請加 --purge-data）"
    else
        echo "  ⊘ $DATA_DIR 不存在"
    fi
fi

# ─── Step 3: 從 instruction file 移除自動觸發區塊 ────
echo "[3/3] 移除自動觸發區塊..."
if [[ -f "$INSTRUCTION_FILE" ]] && grep -q "humanize-skill-auto:start" "$INSTRUCTION_FILE"; then
    tmpfile=$(mktemp)
    awk -v start="humanize-skill-auto:start" -v end="humanize-skill-auto:end" '
        $0 ~ start {skip=1; next}
        $0 ~ end {skip=0; next}
        !skip
    ' "$INSTRUCTION_FILE" > "$tmpfile"

    # 清掉因移除而產生的連續空白行
    awk 'BEGIN{blank=0} /^$/{blank++; if(blank<=1) print; next} {blank=0; print}' "$tmpfile" > "$INSTRUCTION_FILE"
    rm "$tmpfile"
    echo "  ✓ 已從 $INSTRUCTION_FILE 移除自動觸發區塊"
else
    echo "  ⊘ $INSTRUCTION_FILE 沒有自動觸發區塊"
fi

echo
echo "═══ 移除完成 ═══"
if [[ "$PURGE_DATA" != "yes" && -d "$DATA_DIR" ]]; then
    echo "User notes 保留於: $DATA_DIR"
    echo "  （想徹底清除：rm -rf $DATA_DIR）"
fi
