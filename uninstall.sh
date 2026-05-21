#!/usr/bin/env bash
# uninstall.sh — Remove humanize skill from supported AI coding tools
#
# Usage:
#   bash uninstall.sh                      interactive uninstall (Claude Code)
#   bash uninstall.sh --tool=claude-code   explicit tool selection
#   bash uninstall.sh --tool=codex         uninstall from OpenAI Codex
#   bash uninstall.sh --silent             no prompts
#   bash uninstall.sh --keep-notes         preserve user's notes.md

set -e

SKILL_NAME="humanize"
TOOL="claude-code"
SKILL_DIR=""
INSTRUCTION_FILE=""

setup_tool_config() {
    case "$TOOL" in
        claude-code)
            SKILL_DIR="${HOME}/.claude/skills/${SKILL_NAME}"
            INSTRUCTION_FILE="${HOME}/.claude/CLAUDE.md"
            ROOT_DIR="${HOME}/.claude"
            ;;
        codex)
            ROOT_DIR="${CODEX_HOME:-${HOME}/.codex}"
            SKILL_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
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
KEEP_NOTES="no"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tool=*)       TOOL="${1#*=}"; shift ;;
        --tool)         TOOL="$2"; shift 2 ;;
        --silent)       SILENT="yes"; shift ;;
        --keep-notes)   KEEP_NOTES="yes"; shift ;;
        --help|-h)
            cat <<EOF
humanize skill uninstaller

Usage:
  bash uninstall.sh                       interactive uninstall (Claude Code)
  bash uninstall.sh --tool=claude-code    explicit tool selection
  bash uninstall.sh --tool=codex          uninstall from OpenAI Codex
  bash uninstall.sh --silent              no prompts
  bash uninstall.sh --keep-notes          preserve user's notes.md (back up before removing)

Supported tools: claude-code, codex (antigravity is a stub in install.sh)

What gets removed:
  - Skill folder under the tool's skills directory
  - Auto-trigger block from the tool's instruction file
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

# ─── Step 1: 備份 notes.md（如指定）───────────────────
if [[ "$KEEP_NOTES" == "yes" && -d "$SKILL_DIR" ]]; then
    BACKUP_DIR="${ROOT_DIR}/humanize-notes-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    if [[ -d "$SKILL_DIR/contexts" ]]; then
        for ctx_dir in "$SKILL_DIR/contexts"/*/; do
            ctx_name=$(basename "$ctx_dir")
            if [[ -f "$ctx_dir/notes.md" ]]; then
                cp "$ctx_dir/notes.md" "$BACKUP_DIR/${ctx_name}.notes.md"
            fi
        done
        echo "  ✓ notes.md 備份至: $BACKUP_DIR"
    fi
fi

# ─── Step 2: 移除 skill 檔案 ─────────────────────────
echo "[1/2] 移除 skill 檔案..."
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

# ─── Step 3: 從 instruction file 移除自動觸發區塊 ────
echo "[2/2] 移除自動觸發區塊..."
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
if [[ "$KEEP_NOTES" == "yes" ]]; then
    echo "備份 notes 位置: $BACKUP_DIR"
fi
