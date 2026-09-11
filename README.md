# demo-hub

Static AMD ROCm Demo Hub landing page (nginx, non-root, port 8080). This
folder is a **complete, standalone application repository** — everything
needed to build, publish, and onboard it to `slai-app-platform` via the
`Deploy prod` GitHub Actions workflow, with no local Docker/Harbor CLI/`gh`
required.

## What's here

| Path | Purpose |
|---|---|
| `Dockerfile`, `nginx.conf`, `index.html` | The app itself |
| `.github/workflows/deploy-prod.yml` | Builds, pushes to Harbor, authorizes the image, and opens the `slai-app-platform` PR — all on GitHub-hosted runners |
| `deploy/slai-app-prod/demo-hub/` | Manifests copied into `slai-app-platform` by the workflow (already validated with the platform's own `main.py` — passes) |

## One-time setup

**1. Turn this into a real GitHub repo.**
```bash
cd demo-hub-app
git init
git add .
git commit -m "Initial commit: demo-hub app + platform handoff"
gh repo create <your-org-or-user>/demo-hub --private --source=. --push
# or create the repo in the browser first, then:
#   git remote add origin https://github.com/<you>/demo-hub.git
#   git push -u origin main
```

**2. Create the fine-grained PAT** (human step — `gh` can't mint these):
GitHub.com → your profile → Settings → Developer settings → Personal access
tokens → Fine-grained tokens → Generate new token.
- Resource owner: **AMD-SLAI** (the org that owns `slai-app-platform`)
- Repository access: **Only select repositories** → `slai-app-platform` only
- Permissions: **Contents: Read and write**, **Pull requests: Read and write**
- If the org uses SAML SSO, click **Configure SSO / Authorize** for `AMD-SLAI` on the new token — otherwise pushes return 403.

**3. Get a durable Harbor push credential.** This needs a project robot
account (not your personal short-lived CLI login, which expires). Either:
- run `scripts/harbor-create-project-robot.py` from the `slai-app-platform`
  checkout if you have Project Admin/Maintainer on `hw-slaiapp-dev`, or
- ask whoever administers that Harbor project to create one with push
  permission to `hw-slaiapp-dev/demo-hub`.

**4. On this repo (`demo-hub`) → Settings → Secrets and variables → Actions:**

Secrets:
| Name | Value |
|---|---|
| `SLAI_APP_DEV_PR_TOKEN` | the fine-grained PAT from step 2 |
| `HARBOR_USERNAME` | robot name from step 3 |
| `HARBOR_PASSWORD` | robot secret from step 3 |

Variables:
| Name | Value |
|---|---|
| `APP_ID` | `demo-hub` |
| `IMAGE_NAME` | `demo-hub` |
| `BUILD_CONTEXT` | `.` |

## Run it

**Actions → Deploy prod → Run workflow** (choose `main` as the base branch
for the prod URL). The workflow:

1. Builds the image (`linux/amd64`), smoke-tests `/healthz` in a local
   container, then pushes it to `mkmhub.amd.com/hw-slaiapp-dev/demo-hub`.
2. Authorizes the exact digest through the platform's signed release process.
3. Clones `slai-app-platform`, copies `deploy/slai-app-prod/demo-hub/` in,
   stamps the real image, and opens a PR labeled `deploy/slai-app-prod`.

You'll see the PR appear on `AMD-SLAI/slai-app-platform` — review and merge
it (once `deploy-paths-only` is green). Merging is what triggers the
platform team's rollout automation; you don't run anything else. It'll be
live at `https://demo-hub.slai-app.amd.com/` shortly after.

**Redeploys:** any time you change `index.html` or the manifests, just push
to `main` and run the workflow again — it re-publishes and re-syncs
automatically.
