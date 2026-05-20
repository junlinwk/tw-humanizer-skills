<#
.SYNOPSIS
    Uninstall humanize skill from various AI coding tools on Windows.

.PARAMETER Tool
    Target tool: claude-code (default), codex, antigravity.

.PARAMETER KeepNotes
    Preserve user's notes.md (back up before removing).

.PARAMETER Silent
    No confirmation prompts.

.PARAMETER Help
    Show this help.

.EXAMPLE
    .\uninstall.ps1
    Interactive uninstall for Claude Code.

.EXAMPLE
    .\uninstall.ps1 -KeepNotes
    Back up notes before uninstall.

.EXAMPLE
    .\uninstall.ps1 -Silent
    No prompts.
#>

[CmdletBinding()]
param(
    [ValidateSet("claude-code", "codex", "antigravity")]
    [string]$Tool = "claude-code",
    [switch]$KeepNotes,
    [switch]$Silent,
    [switch]$Help
)

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

$SkillName = "humanize"

# ─── Tool config (mirrors install.ps1) ──────────────
function Get-ToolConfig {
    param([string]$ToolName)
    switch ($ToolName) {
        "claude-code" {
            return @{
                Supported = $true
                SkillDir = Join-Path $env:USERPROFILE ".claude\skills\$SkillName"
                InstructionFile = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
            }
        }
        "codex" {
            return @{ Supported = $false; Reason = "Codex 尚未支援，見 install.ps1" }
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
$InstructionFile = $config.InstructionFile

Write-Host "═══ humanize skill uninstaller (Windows, tool=$Tool) ═══" -ForegroundColor Cyan
Write-Host ""

# ─── Step 1: 備份 notes.md（如指定）───────────────────
if ($KeepNotes -and (Test-Path $SkillDir)) {
    $BackupDir = Join-Path $env:USERPROFILE ".claude\humanize-notes-backup-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    $contextsDir = Join-Path $SkillDir "contexts"
    if (Test-Path $contextsDir) {
        Get-ChildItem $contextsDir -Directory | ForEach-Object {
            $noteFile = Join-Path $_.FullName "notes.md"
            if (Test-Path $noteFile) {
                Copy-Item $noteFile (Join-Path $BackupDir "$($_.Name).notes.md")
            }
        }
        Write-Host "  ✓ notes.md 備份至: $BackupDir" -ForegroundColor Green
    }
}

# ─── Step 2: 移除 skill 檔案 ─────────────────────────
Write-Host "[1/2] 移除 skill 檔案..." -ForegroundColor Yellow

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

# ─── Step 3: 從 instruction file 移除自動觸發區塊 ────
Write-Host "[2/2] 移除自動觸發區塊..." -ForegroundColor Yellow

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
if ($KeepNotes) {
    Write-Host "備份 notes 位置: $BackupDir"
}
