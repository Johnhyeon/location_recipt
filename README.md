# 🚀 Opus-Codex Project Template

Claude Opus로 기획하고, Codex로 구현하는 워크플로우를 위한 프로젝트 템플릿입니다.

## 사용법

### 1. 이 템플릿으로 새 프로젝트 생성
GitHub에서 **"Use this template"** → **"Create a new repository"** 클릭

### 2. 프로젝트 초기 설정
```bash
git clone https://github.com/your-username/new-project.git
cd new-project

# Claude Opus로 프로젝트에 맞게 설정 파일 자동 생성
claude --model opus
> "이 프로젝트를 분석해서 CLAUDE.md와 AGENTS.md의 TODO 항목을 채워줘"
```

### 3. 기획 → 구현 워크플로우

**방법 A: 수동**
```bash
claude --model opus          # 기획안 작성
codex "plans/PLAN-xxx.md 읽고 구현해줘"   # 구현
```

**방법 B: 스크립트**
```powershell
.\scripts\plan-to-codex.ps1 -Feature "auth" -Prompt "JWT 인증 시스템"
```

**방법 C: Codex Cloud (추천)**
```powershell
.\scripts\plan-to-codex.ps1 -Feature "auth" -Prompt "JWT 인증" -CloudCodex
# → chatgpt.com/codex 에서 PR 자동 생성
```

## 구조

```
├── .claude/settings.json    # Claude Code 설정
├── CLAUDE.md                # Claude Code 프로젝트 컨텍스트
├── AGENTS.md                # Codex 가이드라인 + 자동 리뷰 규칙
├── plans/                   # 기획안 저장소
│   └── PLAN-TEMPLATE.md     # 기획안 양식
├── scripts/
│   └── plan-to-codex.ps1    # 자동화 스크립트
└── src/                     # 소스 코드 (프로젝트별)
```

## 스크립트 옵션

```powershell
# 기본: 기획 → 확인 → Codex suggest 모드
.\scripts\plan-to-codex.ps1 -Feature "기능명" -Prompt "설명"

# 자동 실행 (승인 없이)
.\scripts\plan-to-codex.ps1 ... -CodexMode "full-auto"

# 기획만 (구현은 나중에)
.\scripts\plan-to-codex.ps1 ... -SkipCodex

# Codex Cloud용 (push 후 웹에서 실행)
.\scripts\plan-to-codex.ps1 ... -CloudCodex

# 현재 브랜치에서 작업
.\scripts\plan-to-codex.ps1 ... -NoBranch
```

## 필수 구독
- **Claude Max** ($100/월): Opus 기획 + Sonnet 구현
- **ChatGPT Pro** ($200/월): Codex 무제한 사용
