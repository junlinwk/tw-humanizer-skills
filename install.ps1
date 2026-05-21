<#
.SYNOPSIS
    Install humanize skill for various AI coding tools on Windows.

.DESCRIPTION
    Installs the humanize skill files to the appropriate location
    and optionally adds auto-trigger to the tool's instruction file.

    Currently supported tools:
      - claude-code (default, fully supported)
      - codex (fully supported)
      - antigravity (not yet supported — see help)

    Architecture (v0.4.0+):
      <tool root>\skills\humanize\        skill payload, overwritten on each install
      <tool root>\skills\humanize-data\   user notes (NEVER touched by installer)

.PARAMETER Tool
    Target tool: claude-code (default), codex, antigravity.

.PARAMETER Dev
    Create symbolic link instead of copying (requires Developer Mode or Admin).

.PARAMETER Copy
    Force copy mode (default).

.PARAMETER NoAuto
    Skip adding auto-trigger to instruction file.

.PARAMETER Auto
    Force enable auto-trigger without prompting.

.PARAMETER Silent
    No prompts, full install with defaults.

.PARAMETER Help
    Show this help.

.EXAMPLE
    .\install.ps1
    Interactive install for Claude Code.

.EXAMPLE
    .\install.ps1 -Silent
    No-prompt install with auto-trigger enabled.

.EXAMPLE
    .\install.ps1 -Dev
    Use symbolic link (needs Developer Mode).

.EXAMPLE
    .\install.ps1 -Tool codex
    Install for OpenAI Codex.
#>

[CmdletBinding()]
param(
    [ValidateSet("claude-code", "codex", "antigravity")]
    [string]$Tool = "claude-code",
    [switch]$Dev,
    [switch]$Copy,
    [switch]$NoAuto,
    [switch]$Auto,
    [switch]$Silent,
    [switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# ─── 設定 ───────────────────────────────────────────
$SkillName = "humanize"
$DataName = "humanize-data"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$AutoTriggerMarkerStart = "<!-- humanize-skill-auto:start -->"
$AutoTriggerMarkerEnd = "<!-- humanize-skill-auto:end -->"

# ─── 版本 ───────────────────────────────────────────
$VersionFile = Join-Path $RepoDir "VERSION"
if (Test-Path $VersionFile) {
    $RepoVersion = (Get-Content $VersionFile -Raw -Encoding UTF8).Trim()
} else {
    $RepoVersion = "unknown"
}

# ─── Tool-specific configuration ─────────────────────
function Get-ToolConfig {
    param([string]$ToolName)

    switch ($ToolName) {
        "claude-code" {
            return @{
                Supported = $true
                SkillDir = Join-Path $env:USERPROFILE ".claude\skills\$SkillName"
                DataDir = Join-Path $env:USERPROFILE ".claude\skills\$DataName"
                InstructionFile = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
                RootDir = Join-Path $env:USERPROFILE ".claude"
                SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
                InvocationHint = "/humanize"
            }
        }
        "codex" {
            $codexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
            return @{
                Supported = $true
                SkillDir = Join-Path $codexRoot "skills\$SkillName"
                DataDir = Join-Path $codexRoot "skills\$DataName"
                InstructionFile = Join-Path $codexRoot "AGENTS.md"
                RootDir = $codexRoot
                SkillsDir = Join-Path $codexRoot "skills"
                InvocationHint = '$humanize'
            }
        }
        "antigravity" {
            return @{
                Supported = $false
                Reason = @"
Google Antigravity IDE 的 skill / agent 設定機制尚未確認。
需要的資訊：
  1. Antigravity 把 agent instructions 放在哪個目錄？
     （IDE 的設定目錄 / 專案目錄 / 全域使用者目錄？）
  2. 有沒有 CLAUDE.md / AGENTS.md 等價的自動載入指令檔？
  3. 是否支援 markdown skill 格式，或需要特定格式？

如果你知道這些，請開 issue 或 PR 補充。
"@
            }
        }
        default {
            throw "Unknown tool: $ToolName"
        }
    }
}

# ─── 取得 tool 設定 ──────────────────────────────────
$config = Get-ToolConfig -ToolName $Tool

if (-not $config.Supported) {
    Write-Host ""
    Write-Host "═══ Tool '$Tool' 尚未支援 ═══" -ForegroundColor Yellow
    Write-Host ""
    Write-Host $config.Reason
    Write-Host ""
    Write-Host "目前可安裝的 tool："
    Write-Host "  - claude-code（預設，完整支援）"
    Write-Host "  - codex（完整支援）"
    Write-Host ""
    Write-Host "改用：.\install.ps1 -Tool claude-code 或 .\install.ps1 -Tool codex"
    exit 2
}

$SkillDir = $config.SkillDir
$DataDir = $config.DataDir
$InstructionFile = $config.InstructionFile
$RootDir = $config.RootDir
$SkillsDir = $config.SkillsDir
$InvocationHint = $config.InvocationHint

# ─── 自動觸發區塊內容（依當前 tool 動態組裝路徑）──────
$AutoTriggerBlock = @"
$AutoTriggerMarkerStart
## humanize skill 自動套用

### 最高原則（凌駕一切）
**不知道直接說 + 必要時向用戶提問。** 不要編造、不要用模糊語言掩護無知、不要把不確定的事實寫得像確定的事實。假裝知道比 AI 味更糟。詳見 ``$SkillDir\core\universal.md`` 第 0 條。

### 每次回應流程
1. 讀 ``$SkillDir\SKILL.md`` 入口檔
2. 依 ``$SkillDir\core\context_detection.md`` 偵測對方語境（9 大類）
3. **偵測輸出語言**（中文 / 英文 / 雙語）→ 載入對應的 ``core\lang_zh.md`` 或 ``core\lang_en.md``（省 token：只載相關語言）
4. 讀對應 ``$SkillDir\contexts\{N}_{name}\README.md`` 規則
5. 讀對應 **``$DataDir\contexts\{N}_{name}\notes.md``** 用戶習慣（不存在則退讀 skill 內模板）
6. 套規則回應（最高原則優先：不知道就說、不確定就問）
7. **靜默**更新 ``$DataDir\contexts\{N}_{name}\notes.md``（不要在回應內容裡提及此更新動作；不要寫進 skill 內模板，那會被升級覆寫）

### 規則來源
- 通用結構規則：``$SkillDir\core\universal.md``（英文，語言中立）
- 中文特定 patterns：``$SkillDir\core\lang_zh.md``（中文輸出時載入）
- 英文特定 patterns：``$SkillDir\core\lang_en.md``（英文輸出時載入）

### 更新 notes 規則
詳見 ``$SkillDir\core\notes_protocol.md``：
- 真實 notes 永遠寫到 ``$DataDir\contexts\{N}\notes.md``
- 最小紀錄（每條 < 1 行）
- 太遠的事件採濃縮（不刪除）
- 用戶明確要求別記的不要記
$AutoTriggerMarkerEnd
"@

# ─── 旗標解析 ────────────────────────────────────────
$Mode = if ($Dev) { "symlink" } else { "copy" }
$AutoTrigger = "ask"
if ($Silent) { $AutoTrigger = "yes" }
elseif ($Auto) { $AutoTrigger = "yes" }
elseif ($NoAuto) { $AutoTrigger = "no" }

# ─── 環境檢查 ────────────────────────────────────────
Write-Host "═══ humanize skill installer (Windows, tool=$Tool, version=$RepoVersion) ═══" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $RootDir)) {
    Write-Warning "$RootDir 不存在，可能還沒裝 $Tool"
    if (-not $Silent) {
        $continue = Read-Host "  繼續嗎？(y/N)"
        if ($continue -notmatch '^[Yy]') { exit 1 }
    }
    New-Item -ItemType Directory -Path $RootDir -Force | Out-Null
}

New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null

# ─── 版本比對 ────────────────────────────────────────
$InstalledVersionFile = Join-Path $SkillDir "VERSION"
$InstalledVersion = ""
if (Test-Path $InstalledVersionFile) {
    try {
        $InstalledVersion = (Get-Content $InstalledVersionFile -Raw -Encoding UTF8).Trim()
    } catch { $InstalledVersion = "" }
}

if ($InstalledVersion) {
    if ($InstalledVersion -eq $RepoVersion) {
        Write-Host "ℹ  已安裝版本 = $InstalledVersion（與 repo 同版，將執行重灌）"
    } else {
        Write-Host ("↑  升級偵測: {0}  →  {1}" -f $InstalledVersion, $RepoVersion) -ForegroundColor Green
    }
} else {
    if (Test-Path $SkillDir) {
        Write-Host "ℹ  舊安裝沒有 VERSION 標記（升級到 $RepoVersion）"
    } else {
        Write-Host "ℹ  全新安裝: $RepoVersion"
    }
}
Write-Host ""

# ─── Step 1: 安裝 skill 檔案 ─────────────────────────
Write-Host "[1/4] 安裝 skill 檔案 (mode: $Mode)..." -ForegroundColor Yellow

if (Test-Path $SkillDir) {
    Write-Host "  已存在的安裝，移除中..."
    $item = Get-Item $SkillDir -Force
    if ($item.LinkType -eq "SymbolicLink") {
        Remove-Item $SkillDir -Force
    } else {
        Remove-Item $SkillDir -Recurse -Force
    }
}

if ($Mode -eq "symlink") {
    try {
        New-Item -ItemType SymbolicLink -Path $SkillDir -Target $RepoDir -ErrorAction Stop | Out-Null
        Write-Host "  ✓ symlinked: $SkillDir -> $RepoDir" -ForegroundColor Green
    } catch {
        Write-Warning "Symlink 失敗（需要 Developer Mode 或系統管理員權限）"
        Write-Host "  改用 copy 模式..." -ForegroundColor Yellow
        $Mode = "copy"
    }
}

if ($Mode -eq "copy") {
    # robocopy 排除 .git、安裝腳本、Reference、sample_outputs、本地測試
    $robocopyArgs = @(
        $RepoDir, $SkillDir, "/E",
        "/XD", ".git", "Reference", "sample_outputs",
        "/XF", ".DS_Store", "install.sh", "install.ps1", "uninstall.sh", "uninstall.ps1", "problem.txt",
        "/NFL", "/NDL", "/NJH", "/NJS"
    )
    & robocopy @robocopyArgs | Out-Null
    if ($LASTEXITCODE -ge 8) {
        Write-Error "Robocopy 失敗 (exit $LASTEXITCODE)"
        exit 1
    }
    Write-Host "  ✓ copied to: $SkillDir" -ForegroundColor Green
}

# 驗證核心檔案
$required = @(
    "VERSION",
    "SKILL.md",
    "core\universal.md",
    "core\context_detection.md",
    "core\notes_protocol.md",
    "core\lang_zh.md",
    "core\lang_en.md"
)
foreach ($f in $required) {
    $full = Join-Path $SkillDir $f
    if (-not (Test-Path $full)) {
        Write-Error "缺少關鍵檔案: $full"
        exit 1
    }
}
Write-Host "  ✓ 核心檔案完整" -ForegroundColor Green

# ─── Step 2: 初始化 humanize-data\（首次） ───────────
Write-Host "[2/4] 初始化 user data 目錄..." -ForegroundColor Yellow
Write-Host "  位置: $DataDir"
if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path (Join-Path $DataDir "contexts") -Force | Out-Null
    Write-Host "  ✓ 建立新的 user data 目錄" -ForegroundColor Green
} else {
    Write-Host "  ✓ 已存在的 user data 目錄保留（內容不動）" -ForegroundColor Green
}

$contexts = @("1_chat", "2_emotional", "3_help", "4_discussion", "5_formal", "6_intimate", "7_conflict", "8_creative", "9_teaching")
$initCount = 0
$keepCount = 0
foreach ($ctx in $contexts) {
    $src = Join-Path $SkillDir "contexts\$ctx\notes.md"
    $dstDir = Join-Path $DataDir "contexts\$ctx"
    $dst = Join-Path $dstDir "notes.md"
    if (-not (Test-Path $src)) {
        Write-Warning "  skill 內模板缺失: $src（跳過此 context）"
        continue
    }
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    if (Test-Path $dst) {
        $keepCount++
    } else {
        Copy-Item $src $dst
        $initCount++
    }
}
Write-Host "  ✓ user data: $initCount 新建 / $keepCount 保留" -ForegroundColor Green

# ─── Step 3: 確認 skill 內 notes.md 模板 ──────────────
Write-Host "[3/4] 確認 skill 內 notes.md 模板..." -ForegroundColor Yellow
$templateMissing = 0
foreach ($ctx in $contexts) {
    $noteFile = Join-Path $SkillDir "contexts\$ctx\notes.md"
    if (-not (Test-Path $noteFile)) {
        Write-Warning "  template 缺失: $ctx"
        $templateMissing++
    }
}
if ($templateMissing -eq 0) {
    Write-Host "  ✓ 9 個 context 模板就緒" -ForegroundColor Green
}

# ─── Step 4: 自動觸發設定 ────────────────────────────
Write-Host "[4/4] 自動觸發設定..." -ForegroundColor Yellow

if ($AutoTrigger -eq "ask") {
    Write-Host ""
    Write-Host "  自動觸發 = 在 $InstructionFile 加一段指令，"
    Write-Host "  讓 $Tool 每次回應前自動讀 humanize skill 並套規則。"
    Write-Host "  好處：不用手動 $InvocationHint"
    Write-Host "  缺點：每輪會多消耗少量 context tokens"
    Write-Host ""
    $autoYn = Read-Host "  啟用自動觸發？(Y/n)"
    $AutoTrigger = if ($autoYn -match '^[Nn]') { "no" } else { "yes" }
}

if ($AutoTrigger -eq "yes") {
    $existingContent = ""
    if (Test-Path $InstructionFile) {
        $existingContent = Get-Content $InstructionFile -Raw -Encoding UTF8
    }

    if ($existingContent -match "humanize-skill-auto:start") {
        # 重灌：把舊區塊整段換成新的（路徑可能變、版本可能變）
        $pattern = "(?ms)" + [regex]::Escape($AutoTriggerMarkerStart) + ".*?" + [regex]::Escape($AutoTriggerMarkerEnd)
        $newContent = [regex]::Replace($existingContent, $pattern, $AutoTriggerBlock)
        Set-Content -Path $InstructionFile -Value $newContent -Encoding UTF8
        Write-Host "  ✓ 已更新自動觸發區塊（含新版路徑 / 版本）" -ForegroundColor Green
    } else {
        $parentDir = Split-Path -Parent $InstructionFile
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
        if (Test-Path $InstructionFile) {
            Add-Content -Path $InstructionFile -Value "`n$AutoTriggerBlock" -Encoding UTF8
        } else {
            Set-Content -Path $InstructionFile -Value $AutoTriggerBlock -Encoding UTF8
        }
        Write-Host "  ✓ 已加自動觸發到 $InstructionFile" -ForegroundColor Green
    }
} else {
    Write-Host "  ⊘ 跳過自動觸發。要用時需手動 $InvocationHint" -ForegroundColor Gray
}

# ─── 完成 ───────────────────────────────────────────
Write-Host ""
Write-Host "═══ 安裝完成 ═══" -ForegroundColor Cyan
Write-Host ""
Write-Host "Tool:            $Tool"
Write-Host "Skill 位置:      $SkillDir"
Write-Host "User data:       $DataDir"
if ($InstalledVersion -and ($InstalledVersion -ne $RepoVersion)) {
    Write-Host ("版本:            {0}  →  {1}" -f $InstalledVersion, $RepoVersion)
} else {
    Write-Host "版本:            $RepoVersion"
}
Write-Host "Mode:            $Mode"
Write-Host "Auto-trigger:    $AutoTrigger"
Write-Host ""
Write-Host "下一步："
Write-Host "  • 開新的 $Tool 對話"
if ($AutoTrigger -eq "yes") {
    Write-Host "  • $Tool 會自動套用 humanize skill"
} else {
    Write-Host "  • 在對話中輸入 $InvocationHint 來啟用"
}
Write-Host ""
Write-Host "想移除: powershell -ExecutionPolicy Bypass -File $RepoDir\uninstall.ps1 -Tool $Tool"
Write-Host "  （預設保留 $DataDir；想連 notes 一起刪用 -PurgeData）"
