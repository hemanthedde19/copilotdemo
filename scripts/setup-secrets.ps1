param(
  [string]$Repository
)

# Usage: $Env:DOCKERHUB_USERNAME='hemanthedde19'; $Env:DOCKERHUB_TOKEN='...'; ./scripts/setup-secrets.ps1 -Repository 'owner/repo'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Error "gh CLI not found. Install it from https://cli.github.com/"
  exit 1
}

if (-not $Repository) {
  $Repository = gh repo view --json nameWithOwner -q .nameWithOwner
}

if (-not $Repository) { Write-Error "Repository not specified and could not be inferred." ; exit 1 }

function Set-SecretIfPresent {
  param([string]$SecretName)
  $val = (Get-Item Env:\$SecretName -ErrorAction SilentlyContinue).Value
  if ($val) {
    Write-Host "Setting secret $SecretName in $Repository"
    gh secret set $SecretName --repo $Repository --body "$val"
  }
}

Set-SecretIfPresent -SecretName 'DOCKERHUB_USERNAME'
Set-SecretIfPresent -SecretName 'DOCKERHUB_TOKEN'
Set-SecretIfPresent -SecretName 'DOCKERHUB_REPOSITORY'
Set-SecretIfPresent -SecretName 'GHCR_TOKEN'
Set-SecretIfPresent -SecretName 'SSH_HOST'
Set-SecretIfPresent -SecretName 'SSH_USER'
Set-SecretIfPresent -SecretName 'SSH_PRIVATE_KEY'
Set-SecretIfPresent -SecretName 'DOCKER_IMAGE'

Write-Host "Secrets setup complete for $Repository"
