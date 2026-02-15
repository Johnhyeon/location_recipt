<#
.SYNOPSIS
    Claude Opus → Codex 자동 파이프라인
.DESCRIPTION
    Opus로 기획안을 생성하고, Codex CLI로 구현을 실행합니다.
.EXAMPLE
    .\plan-to-codex.ps1 -Feature "user-auth" -Prompt "JWT 기반 인증 시스템"
    .\plan-to-codex.ps1 -Feature "user-auth" -Prompt "JWT 기반 인증" -CodexMode "full-auto"
    .\plan-to-codex.ps1 -Feature "dashboard" -Prompt "관리자 대시보드" -SkipCodex
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Feature,

    [Parameter(Mandatory = $true)]
    [string]$Prompt,

    [ValidateSet("suggest", "auto-edit", "full-auto")]
    [string]$CodexMode = "suggest",

    [switch]$SkipCodex,        # 기획만 하고 Codex는 나중에
    [switch]$CloudCodex,       # Codex Cloud용 push만
    [switch]$NoBranch          # 브랜치 안 만들고 현재 브랜치에서 작업
)

$ErrorActionPreference = "Stop"
$Date = Get-Date -Format "yyyyMMdd"
$PlanFile = "plans/PLAN-$Date-$Feature.md"
$BranchName = "feat/$Feature"

# ─── Phase 1: Claude Opus 기획 ───
Write-Host ""
Write-Host "  Phase 1: Claude Opus 기획" -ForegroundColor Cyan
Write-Host "  =========================" -ForegroundColor Cyan
Write-Host "  Feature : $Feature" -ForegroundColor Gray
Write-Host "  Plan    : $PlanFile" -ForegroundColor Gray
Write-Host ""

$PlanPrompt = @"
다음 요구사항에 대해 구현 기획안을 작성해줘.

요구사항: $Prompt

기획안을 $PlanFile 에 저장해줘. 형식:

# PLAN: $Feature

## 개요
전체 설명 및 목표

## Task 1: [태스크명]
- **파일**: 수정/생성할 파일 경로 목록
- **설명**: 구체적 구현 내용 (코드 수준으로 상세히)
- **의존성**: 없음 또는 Task N
- **검증**: 테스트 명령어

## Task 2: [태스크명]
...

규칙:
- 각 태스크는 Codex가 독립적으로 실행할 수 있도록 충분히 상세하게
- 의존성 순서를 명확히
- 검증 가능한 테스트 명령어 필수
- 전체 태스크 수는 합리적으로 (보통 3~8개)
"@

claude --model opus -p $PlanPrompt

# 기획안 생성 확인
if (-not (Test-Path $PlanFile)) {
    Write-Host "  [ERROR] 기획안 생성 실패: $PlanFile" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "  기획안 생성 완료!" -ForegroundColor Green
Write-Host ""

# 기획안 출력
Write-Host "  ─── 기획안 미리보기 ───" -ForegroundColor Yellow
Get-Content $PlanFile | Select-Object -First 50 | ForEach-Object { Write-Host "  $_" }
$totalLines = (Get-Content $PlanFile).Count
if ($totalLines -gt 50) {
    Write-Host "  ... ($($totalLines - 50) lines more)" -ForegroundColor DarkGray
}
Write-Host "  ─────────────────────" -ForegroundColor Yellow
Write-Host ""

# 기획만 하는 경우
if ($SkipCodex) {
    Write-Host "  -SkipCodex 지정됨. 기획안만 생성 완료." -ForegroundColor Yellow
    Write-Host "  나중에 실행: codex `"$PlanFile 읽고 전체 구현해줘`"" -ForegroundColor Gray
    exit 0
}

# 사용자 확인
$Confirm = Read-Host "  Codex로 구현 진행할까요? (y/n)"
if ($Confirm -ne "y") {
    Write-Host "  중단됨. 기획안 수정 후 다시 실행하세요." -ForegroundColor Yellow
    exit 0
}

# ─── Phase 2: 구현 ───
Write-Host ""
Write-Host "  Phase 2: 구현 시작" -ForegroundColor Cyan
Write-Host "  ==================" -ForegroundColor Cyan
Write-Host ""

# Git 브랜치
if (-not $NoBranch) {
    git checkout -b $BranchName 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [WARN] 브랜치 '$BranchName' 이미 존재. 전환합니다." -ForegroundColor Yellow
        git checkout $BranchName
    }
    Write-Host "  Branch: $BranchName" -ForegroundColor Gray
}

# Codex Cloud 모드: push만 하고 종료
if ($CloudCodex) {
    git add $PlanFile
    git commit -m "chore: add plan for $Feature"
    git push origin HEAD
    Write-Host ""
    Write-Host "  기획안 push 완료!" -ForegroundColor Green
    Write-Host "  Codex Cloud(chatgpt.com/codex)에서 아래 프롬프트로 실행하세요:" -ForegroundColor White
    Write-Host ""
    Write-Host "  `"$PlanFile 읽고 모든 태스크를 순서대로 구현해줘.`"" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

# Codex CLI 실행
$CodexPrompt = @"
$PlanFile 파일을 읽고 모든 태스크를 의존성 순서대로 구현해줘.
각 태스크 완료 후 해당 검증 명령을 실행해서 통과하는지 확인해줘.
모든 태스크 완료 후 변경사항을 커밋해줘.
커밋 메시지 형식: feat($Feature): 태스크 내용 요약
"@

Write-Host "  Codex 실행 모드: $CodexMode" -ForegroundColor Gray
Write-Host ""

codex -a $CodexMode $CodexPrompt

# ─── 완료 ───
Write-Host ""
Write-Host "  완료!" -ForegroundColor Green
Write-Host "  ======" -ForegroundColor Green
Write-Host ""
Write-Host "  다음 단계:" -ForegroundColor White
Write-Host "    git log --oneline -10        # 커밋 확인" -ForegroundColor Gray
Write-Host "    git diff main                # 변경사항 확인" -ForegroundColor Gray
Write-Host "    git push origin $BranchName  # 푸시 & PR 생성" -ForegroundColor Gray
Write-Host ""
