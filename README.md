# board-third-party-lib_api

Design and tests for the API for the Board third party library.

## Postman Native Git Sync

This repository is connected to a Postman project workspace using Postman Native Git.

Local development updates the files in this repo (`postman/`, `.postman/`). To publish those local file changes to the Postman Cloud workspace, use the Postman CLI.

### Local PowerShell wrapper (recommended)

From this repo root (`api/`):

```powershell
$env:POSTMAN_API_KEY = "<your-postman-api-key>"
pwsh ./scripts/postman-sync.ps1
```

Useful variants:

```powershell
pwsh ./scripts/postman-sync.ps1 verify
pwsh ./scripts/postman-sync.ps1 login
pwsh ./scripts/postman-sync.ps1 push
pwsh ./scripts/postman-sync.ps1 all -SkipLogin
```

If your Postman account is in the EU region:

```powershell
pwsh ./scripts/postman-sync.ps1 all -Region eu
```

### CI/CD sync

GitHub Actions workflow:

- [`api/.github/workflows/postman-publish.yml`](.github/workflows/postman-publish.yml)

It publishes local Postman Native Git files to the Postman Cloud workspace on pushes to `main` and supports manual trigger (`workflow_dispatch`).

Required secret:

- `POSTMAN_API_KEY`
