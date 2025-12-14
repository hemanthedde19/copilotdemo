# PowerShell script for safe Docker login using environment variables
# Usage: $Env:DOCKERHUB_USERNAME='hemanthedde19'; $Env:DOCKERHUB_TOKEN='...'; ./scripts/docker-login.ps1

if (-not $Env:DOCKERHUB_USERNAME) {
  Write-Error "Please set DOCKERHUB_USERNAME environment variable (e.g., $Env:DOCKERHUB_USERNAME='hemanthedde19')"
  exit 1
}
if (-not $Env:DOCKERHUB_TOKEN) {
  Write-Error "Please set DOCKERHUB_TOKEN environment variable (e.g., $Env:DOCKERHUB_TOKEN='...')"
  exit 1
}

Write-Host "Logging into Docker Hub as $($Env:DOCKERHUB_USERNAME)"
$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Env:DOCKERHUB_TOKEN)
$StdIn = [System.IO.MemoryStream]::new($Bytes)

# Use docker login --password-stdin
$proc = Start-Process -FilePath docker -ArgumentList "login -u $($Env:DOCKERHUB_USERNAME) --password-stdin" -NoNewWindow -RedirectStandardInput "$true" -RedirectStandardOutput "$true" -RedirectStandardError "$true" -PassThru
$proc.StandardInput.BaseStream.Write($Bytes, 0, $Bytes.Length)
$proc.StandardInput.Close()
$proc.WaitForExit()

if ($proc.ExitCode -eq 0) {
  Write-Host "Logged into Docker Hub successfully."
} else {
  Write-Error "Docker login failed with exit code $($proc.ExitCode)"
}
