param(
  [string]$Repository
)

# Connect repository and push using gh CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Error "gh CLI not found. Install it from https://cli.github.com/ and run gh auth login to authenticate."
  exit 1
}

if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
  Write-Host "Not a git repo. Initializing..."
  git init
  git checkout -b main 2>$null
}

if (-not $Repository) { $Repository = $Env:GH_REPOSITORY }
if (-not $Repository) {
  try {
    $url = git remote get-url origin 2>$null
    if ($url -match 'github.com[:/](.+/.+)') { $Repository = $Matches[1] }
  } catch { }
}

if (-not $Repository) { Write-Error "No repository specified. Run scripts/create-repo.ps1 or script with -Name owner/repo" ; exit 1 }

Write-Host "Ensuring repo exists: $Repository"
if (-not (gh repo view $Repository -q . 2>$null)) {
  Write-Host "Repo not found, creating..."
  gh repo create $Repository --public --source . --remote origin --push --confirm 2>$null | Out-Null
}

git add .
try { git commit -m 'Initial commit' } catch { Write-Host 'Nothing to commit' }
git push -u origin main

Write-Host "Repo connected and pushed: $Repository"

if ($Env:DOCKERHUB_TOKEN -or $Env:DOCKERHUB_USERNAME) {
  Write-Host "Setting DockerHub secrets (if provided)"
  .\scripts\setup-secrets.ps1 -Repository $Repository
}

Write-Host "Done. Use scripts/setup-secrets.ps1 to add any extra secrets."
