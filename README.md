# Sample Deploy Repo for GitHub Actions

This repository shows a minimal Node.js app with GitHub Actions workflows for:

- CI (install, test)
- Publish Docker image to Docker Hub
- Publish Docker image to GitHub Container Registry (GHCR)
- Optional SSH deploy to a server (pull & run Docker image)

Secrets you can configure in GitHub Actions:

- `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`: Docker Hub credentials (set `DOCKERHUB_USERNAME` to `hemanthedde19` if that's your Docker Hub user)
- `DOCKERHUB_REPOSITORY`: optional, override the Docker Hub repo like `hemanthedde19/sample-deploy-action`
- `GHCR_TOKEN`: Personal access token (not required in same-repo CI; `GITHUB_TOKEN` is enough)
- `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY`: For SSH-based deploy
- `DOCKER_IMAGE`: image name (e.g., `yourdockerhubuser/sample-deploy-action` or `ghcr.io/OWNER/repo`)

Required for basic publish+deploy workflows:

- Docker Hub publishing: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, and optional `DOCKERHUB_REPOSITORY` or `DOCKER_IMAGE`.
- GHCR publishing: `GITHUB_TOKEN` (already available in Actions) or `GHCR_TOKEN` for cross-repo pushes.
- SSH deploy: `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY`, and `DOCKER_IMAGE`.


Local and CI-safe login examples (DO NOT commit tokens into git):

- PowerShell (Windows):

```powershell
$Env:DOCKERHUB_USERNAME = 'hemanthedde19'
$Env:DOCKERHUB_TOKEN = 'your_token_here'
./scripts/docker-login.ps1
```

- Bash (Linux/macOS):

```bash
export DOCKERHUB_USERNAME=hemanthedde19
export DOCKERHUB_TOKEN=your_token_here
./scripts/docker-login.sh
```

Add the token to GitHub repository secrets to use in workflows:

- Web UI: Settings → Secrets and variables → Actions → New repository secret (Name: `DOCKERHUB_TOKEN`, Value: your token)
- `gh` CLI (interactive; safer than putting on command line):

```bash
gh secret set DOCKERHUB_TOKEN --body-file - <<<'YOUR_DOCKER_TOKEN'
```

or faster (non-interactive; avoid exposing token in shell history):

```bash
echo -n 'YOUR_DOCKER_TOKEN' | gh secret set DOCKERHUB_TOKEN
```

Security notes:

- If you accidentally paste a token into public places (like chat or a repo), rotate or revoke it immediately via Docker Hub (Account Settings → Security → Access Tokens).
- Do not share your token in public repositories or chat logs. Use repository secrets and CI-managed variables instead.


Configuration examples:

- Docker Hub push: Set `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` and (optionally) `DOCKERHUB_REPOSITORY`.
- GHCR push: Uses `GITHUB_TOKEN` automatically for the same repo; if pushing to a different repo, provide a token with `packages:write`.
- SSH deploy: Set `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY`, `DOCKER_IMAGE`.

Notes:

- Workflows are basic samples. Remove the flows you don't need or expand them for your target environment.
- The SSH deploy job assumes Docker is already installed on the remote host. It pulls the latest image and runs it.

Creating the repo and configuring secrets with `gh` CLI:

1. To create the repository (public):

```bash
# Create public repo and push
./scripts/create-repo.sh --name owner/repo
# or for private
./scripts/create-repo.sh --private --name owner/repo
```

2. To add repository secrets via `gh` (example):

```bash
export DOCKERHUB_USERNAME=hemanthedde19
export DOCKERHUB_TOKEN=your_token
export DOCKERHUB_REPOSITORY=hemanthedde19/sample-deploy-action
# then run
./scripts/setup-secrets.sh
```

PowerShell (Windows) equivalents:

```powershell
$Env:DOCKERHUB_USERNAME='hemanthedde19'
$Env:DOCKERHUB_TOKEN='your_token'
.\scripts\setup-secrets.ps1 -Repository owner/repo
```

Make the scripts executable (non-Windows):

```bash
chmod +x scripts/*.sh
```

Quick connect and permissions (Bash):

```bash
# Authenticate gh CLI interactively (choose GitHub.com and preferred auth method)
gh auth login

# Optional: Ensure the token has at least 'repo' and 'workflow' scopes to create repos and manage secrets
# Create the repo and push (runs create-repo and sets remote)
./scripts/create-repo.sh --name owner/repo

# Connect, push and set secrets (if DOCKERHUB vars present)
GH_REPOSITORY=owner/repo DOCKERHUB_USERNAME=hemanthedde19 DOCKERHUB_TOKEN=your_token ./scripts/connect-github.sh owner/repo

```

PowerShell (Windows):

```powershell
# Authenticate gh CLI
gh auth login

# Create the repo and push
.\scripts\create-repo.ps1 -Private -Name "owner/repo"

# Connect and push
$Env:GH_REPOSITORY = 'owner/repo'
$Env:DOCKERHUB_USERNAME = 'hemanthedde19'
$Env:DOCKERHUB_TOKEN = 'yourtoken'
.\scripts\connect-github.ps1 -Repository 'owner/repo'

```

Try it locally:

1. Install dependencies

```bash
npm ci
```

2. Run tests

```bash
npm test
```

3. Run locally

```bash
npm start
```

4. Build image with Docker

```bash
docker build -t sample-deploy-action:latest .
```

5. Push to container registry (DockerHub example)

```bash
docker tag sample-deploy-action:latest yourdockerhubuser/sample-deploy-action:latest
docker push yourdockerhubuser/sample-deploy-action:latest
```

Demo page:

- A minimal demo site is in the `demo` folder. You can serve it with a local static server (or open `demo/index.html`). The page will try `http://localhost:3000/` and the current host origin and display the JSON response.

```bash
# Example: serve with Python's http.server from repo root and visit http://localhost:8000/demo/
python -m http.server 8000
```


