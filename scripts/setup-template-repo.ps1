# setup-template-repo.ps1
# Usage: .\scripts\setup-template-repo.ps1 -GitHubUser "Johnhyeon"

param(
    [Parameter(Mandatory=$true)][string]$GitHubUser,
    [string]$RepoName = "opus-codex-template"
)

Write-Host ""
Write-Host "  Opus-Codex Template Repository Setup" -ForegroundColor Cyan
Write-Host ""

# Git init
if (-not (Test-Path ".git")) {
    git init
    Write-Host "  [OK] Git initialized" -ForegroundColor Green
}

# Initial commit
git add -A
git commit -m "chore: init opus-codex project template"
Write-Host "  [OK] Initial commit done" -ForegroundColor Green

# Check gh CLI
$ghCheck = Get-Command gh -ErrorAction SilentlyContinue

if ($ghCheck) {
    Write-Host ""
    Write-Host "  GitHub CLI detected. Creating repo..." -ForegroundColor Yellow
    gh repo create "$GitHubUser/$RepoName" --public --source=. --remote=origin --push
    Write-Host ""
    Write-Host "  [OK] Repo created and pushed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Last step (manual):" -ForegroundColor Yellow
    Write-Host "  1. Go to https://github.com/$GitHubUser/$RepoName/settings" -ForegroundColor White
    Write-Host "  2. Check 'Template repository' checkbox" -ForegroundColor White
}
else {
    Write-Host ""
    Write-Host "  GitHub CLI(gh) not found. Manual steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. Create repo '$RepoName' at https://github.com/new" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Run these commands:" -ForegroundColor White
    Write-Host "     git remote add origin https://github.com/$GitHubUser/$RepoName.git" -ForegroundColor Gray
    Write-Host "     git branch -M main" -ForegroundColor Gray
    Write-Host "     git push -u origin main" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. Settings > 'Template repository' checkbox ON" -ForegroundColor White
    Write-Host ""
    Write-Host "  (Optional) Install GitHub CLI: winget install GitHub.cli" -ForegroundColor DarkGray
}

Write-Host ""