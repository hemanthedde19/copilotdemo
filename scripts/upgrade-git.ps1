<#
Upgrade Git on Windows using common package managers (winget, choco, scoop).
Run as Administrator when required.

Usage:
  - Run elevated PowerShell: Start-Process powershell -Verb runAs
  - To upgrade: .\scripts\upgrade-git.ps1
  - To run non-interactively: powershell -ExecutionPolicy Bypass -File .\scripts\upgrade-git.ps1 -AcceptAll
#>

param(
  [switch]$AcceptAll
)

function Write-Info([string]$msg){ Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-ErrorLine([string]$msg){ Write-Host "[ERROR] $msg" -ForegroundColor Red }

set -e

Write-Info "Attempting to upgrade Git"

if (Get-Command winget -ErrorAction SilentlyContinue) {
  Write-Info "Found winget; upgrading with winget"
  if (-not $AcceptAll) { $choice = Read-Host "Run 'winget upgrade --id Git.Git -e'? (Y/n)"; if ($choice -eq 'n') { exit 0 } }
  winget upgrade --id Git.Git -e || winget install --id Git.Git -e --silent
  Write-Info "winget upgrade finished."
  exit 0
}

if (Get-Command choco -ErrorAction SilentlyContinue) {
  Write-Info "Found Chocolatey; upgrading with choco"
  if (-not $AcceptAll) { $choice = Read-Host "Run 'choco upgrade git -y'? (Y/n)"; if ($choice -eq 'n') { exit 0 } }
  choco upgrade git -y
  Write-Info "choco upgrade finished."
  exit 0
}

if (Get-Command scoop -ErrorAction SilentlyContinue) {
  Write-Info "Found Scoop; upgrading with scoop"
  if (-not $AcceptAll) { $choice = Read-Host "Run 'scoop update git'? (Y/n)"; if ($choice -eq 'n') { exit 0 } }
  scoop update git
  Write-Info "scoop update finished."
  exit 0
}

Write-ErrorLine "No supported package manager detected (winget, choco, scoop)."
Write-Info "You can download the latest Git for Windows installer from https://git-scm.com/download/win and run it manually."
exit 1
