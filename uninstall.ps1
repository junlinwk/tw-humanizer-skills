<#
.SYNOPSIS
    Uninstall humanize skill from various AI coding tools on Windows.

.DESCRIPTION
    Default behavior (v0.4.0+):
      - Removes <tool root>\skills\humanize\ (skill payload)
      - Removes auto-trigger block from instruction file
      - PRESERVES <tool root>\skills\humanize-data\ (user notes)
      Use -PurgeData to also delete user notes.

.PARAMETER Tool
    Target tool: claude-code (default), codex, antigravity.

.PARAMETER PurgeData
    Also delete humanize-data/ (user notes).

.PARAMETER KeepNotes
    Deprecated. Notes are preserved by default; this flag is now a no-op.

.PARAMETER Silent
    No confirmation prompts.

.PARAMETER Help
    Show this help.

.EXAMPLE
    .\uninstall.ps1
    Interactive uninstall for Claude Code (notes preserved).

.EXAMPLE
    .\uninstall.ps1 -PurgeData
    Uninstall and delete user notes too.

.EXAMPLE
    .\uninstall.ps1 -Tool codex
    Uninstall from OpenAI Codex.
#>

[CmdletBinding()]
param(
    [ValidateSet("claude-code", "codex", "antigravity")]
    [string]$Tool = "claude-code",
    [switch]$PurgeData,
    [switch]$KeepNotes,
    [switch]$Silent,
    [switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

$SkillName = "humanize"
$DataName = "humanize-data"

# ─── Tool config (mirrors install.ps1) ──────────────
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
            }
        }
        "antigravity" {
            return @{ Supported = $false; Reason = "Antigravity 尚未支援，見 install.ps1" }
        }
    }
}

$config = Get-ToolConfig -ToolName $Tool

if (-not $config.Supported) {
    Write-Host "Tool '$Tool' 尚未支援：$($config.Reason)" -ForegroundColor Yellow
    exit 2
}

$SkillDir = $config.SkillDir
$DataDir = $config.DataDir
$InstructionFile = $config.InstructionFile
$RootDir = $config.RootDir

Write-Host "═══ humanize skill uninstaller (Windows, tool=$Tool) ═══" -ForegroundColor Cyan
Write-Host ""

if ($KeepNotes) {
    Write-Host "ℹ  -KeepNotes 已 deprecated（notes 預設就保留在 $DataDir）" -ForegroundColor Gray
    Write-Host ""
}

# ─── Step 1: 移除 skill 檔案 ─────────────────────────
Write-Host "[1/3] 移除 skill 檔案..." -ForegroundColor Yellow

if (Test-Path $SkillDir) {
    $item = Get-Item $SkillDir -Force
    if ($item.LinkType -eq "SymbolicLink") {
        Remove-Item $SkillDir -Force
        Write-Host "  ✓ 移除 symlink: $SkillDir" -ForegroundColor Green
    } else {
        if (-not $Silent) {
            $confirm = Read-Host "  確定刪除 $SkillDir ？(y/N)"
            if ($confirm -notmatch '^[Yy]') {
                Write-Host "  取消"
                exit 0
            }
        }
        Remove-Item $SkillDir -Recurse -Force
        Write-Host "  ✓ 移除目錄: $SkillDir" -ForegroundColor Green
    }
} else {
    Write-Host "  ⊘ 找不到 $SkillDir （可能已移除）" -ForegroundColor Gray
}

# ─── Step 2: 處理 humanize-data\ ────────────────────
Write-Host "[2/3] 處理 user data 目錄..." -ForegroundColor Yellow

if ($PurgeData) {
    if (Test-Path $DataDir) {
        if (-not $Silent) {
            $confirm = Read-Host "  ⚠  確定刪除 $DataDir ？(這會清除所有 notes) (y/N)"
            if ($confirm -notmatch '^[Yy]') {
                Write-Host "  保留 $DataDir"
            } else {
                Remove-Item $DataDir -Recurse -Force
                Write-Host "  ✓ 移除 user data: $DataDir" -ForegroundColor Green
            }
        } else {
            Remove-Item $DataDir -Recurse -Force
            Write-Host "  ✓ 移除 user data: $DataDir" -ForegroundColor Green
        }
    } else {
        Write-Host "  ⊘ $DataDir 不存在" -ForegroundColor Gray
    }
} else {
    if (Test-Path $DataDir) {
        Write-Host "  ✓ 保留 $DataDir （未來重裝可繼續用；要刪請加 -PurgeData）" -ForegroundColor Green
    } else {
        Write-Host "  ⊘ $DataDir 不存在" -ForegroundColor Gray
    }
}

# ─── Step 3: 從 instruction file 移除自動觸發區塊 ────
Write-Host "[3/3] 移除自動觸發區塊..." -ForegroundColor Yellow

if ((Test-Path $InstructionFile) -and ((Get-Content $InstructionFile -Raw -Encoding UTF8) -match "humanize-skill-auto:start")) {
    $content = Get-Content $InstructionFile -Raw -Encoding UTF8
    # 移除 markers 之間（含 markers）的整個區塊
    $pattern = '(?s)\r?\n?<!-- humanize-skill-auto:start -->.*?<!-- humanize-skill-auto:end -->\r?\n?'
    $cleaned = $content -replace $pattern, ''
    # 清掉因移除而產生的連續多空行
    $cleaned = $cleaned -replace "(\r?\n){3,}", "`r`n`r`n"
    Set-Content -Path $InstructionFile -Value $cleaned.TrimEnd() -Encoding UTF8 -NoNewline
    Add-Content -Path $InstructionFile -Value "" -Encoding UTF8
    Write-Host "  ✓ 已從 $InstructionFile 移除自動觸發區塊" -ForegroundColor Green
} else {
    Write-Host "  ⊘ $InstructionFile 沒有自動觸發區塊" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══ 移除完成 ═══" -ForegroundColor Cyan
if (-not $PurgeData -and (Test-Path $DataDir)) {
    Write-Host "User notes 保留於: $DataDir"
    Write-Host "  （想徹底清除：Remove-Item -Recurse -Force $DataDir）"
}
