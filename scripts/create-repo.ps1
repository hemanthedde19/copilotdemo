param(
  [switch]$Private,
  [string]$Name
)

# Usage: .\scripts\create-repo.ps1 -Private -Name "owner/repo"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Error "gh CLI not found. Install it from https://cli.github.com/"
  exit 1
}

if ($Name) {
  $fullRepo = $Name
} else {
  $fullRepo = Split-Path -Leaf (Get-Location)
}

$visibilityFlag = '--public'
if ($Private) { $visibilityFlag = '--private' }

Write-Host "Creating $fullRepo ($visibilityFlag)"
if (gh repo create $fullRepo $visibilityFlag --confirm) {
  Write-Host "Created repo $fullRepo"
} else {
  Write-Warning "Failed to create repo or repo may already exist."
}

if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
  git init
  git checkout -b main
}

git add .
try {
  git commit -m "Initial commit"
} catch {
  Write-Host "No changes to commit or commit failed."
}

# Set remote
if ($fullRepo -match '/') {
  git remote remove origin 2>$null | Out-Null
  git remote add origin "git@github.com:$fullRepo.git"
} else {
  $owner = (gh api user --jq .login)
  git remote remove origin 2>$null | Out-Null
  git remote add origin "git@github.com:$owner/$fullRepo.git"
}

git push -u origin main

if (Test-Path scripts\setup-secrets.ps1) {
  Write-Host "Run scripts\setup-secrets.ps1 to configure repository secrets via gh CLI"
}

Write-Host "Repo created and pushed: $fullRepo"
