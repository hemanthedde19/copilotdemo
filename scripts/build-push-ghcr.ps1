param(
  [string]$ImageName,
  [string]$Repository
)

# Build and push Docker image to GitHub Container Registry (GHCR)
# Usage: $Env:GHCR_TOKEN='pat'; .\scripts\build-push-ghcr.ps1

if (-not $Env:GHCR_TOKEN -and -not $Env:GITHUB_TOKEN) {
  Write-Error 'Set GHCR_TOKEN or GITHUB_TOKEN'
  exit 1
}

$repo = $Repository
if (-not $repo) { $repo = $Env:GHCR_REPOSITORY }
if (-not $repo) {
  try {
    $url = git remote get-url origin 2>$null
    if ($url -match 'github.com[:/](.+/.+)') { $repo = $Matches[1] }
  } catch {}
}

if (-not $repo) {
  Write-Error 'Could not determine repo. Set GHCR_REPOSITORY or pass -Repository'
  exit 1
}

if (-not $ImageName) { $ImageName = "ghcr.io/$repo" }
if ($Env:DOCKER_IMAGE) { $ImageName = $Env:DOCKER_IMAGE }

Write-Host "Image: $ImageName"

$token = $Env:GHCR_TOKEN; if (-not $token) { $token = $Env:GITHUB_TOKEN }
$user = $Env:GHCR_USERNAME; if (-not $user) { $user = $repo.Split('/')[0] }

Write-Host "Login to GHCR as $user"
$bytes = [System.Text.Encoding]::UTF8.GetBytes($token)
$proc = Start-Process -FilePath docker -ArgumentList "login ghcr.io -u $user --password-stdin" -NoNewWindow -RedirectStandardInput "$true" -RedirectStandardOutput "$true" -RedirectStandardError "$true" -PassThru
$proc.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
$proc.StandardInput.Close()
$proc.WaitForExit()
if ($proc.ExitCode -ne 0) { Write-Error "docker login failed"; exit 1 }

Write-Host "Build $ImageName:latest"
docker build -t $ImageName:latest .

$sha = (git rev-parse --short HEAD 2>$null) -replace "\s+",""; if (-not $sha) { $sha = 'local' }
docker tag $ImageName:latest $ImageName:$sha

Write-Host "Push $ImageName:latest and $ImageName:$sha"
docker push $ImageName:latest
docker push $ImageName:$sha

Write-Host "Done: $ImageName"
