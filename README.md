# board-third-party-lib_api

Design and tests for the API for the Board third party library.

## Table of Contents

- [Postman Workflow](#postman-workflow)
- [Mock-First Flow](#mock-first-flow)
- [Repository Files](#repository-files)
- [Working Rules](#working-rules)

## Postman Workflow

This repository is connected to a Postman project workspace using Postman Native Git.

Local development updates the files in this repo (`postman/`, `.postman/`), and Postman Cloud provides the API Builder, mock servers, monitors, and linked generated collections.

This project intentionally avoids Postman CLI automation in-repo for now to reduce duplicate collection creation and sync ambiguity. Sync to Postman Cloud using the Postman UI (Files/Source Control in the connected workspace).

### Recommended Model (Avoid Duplicates)

- Keep the **API Builder generated collection** in Postman Cloud only.
- Keep exactly one **Git-tracked test collection** in this repo:
  - `postman/collections/board-third-party-library-api.contract-tests.postman_collection.json`
- Keep one separate **Git-tracked Postman admin collection** for Postman Cloud provisioning tasks (mock server setup, inspection):
  - `postman/collections/postman-admin.board-third-party-library-mock-provisioning.postman_collection.json`
- Keep the OpenAPI spec as the contract source of truth:
  - `postman/specs/board-third-party-library-api.v1.openapi.yaml`
- Do not export the API Builder generated collection into this repo.
- Do not give the generated collection and the Git-tracked collection the same display name.

### Manual Sync (Postman UI)

Use Postman's connected repository UI to pull/push file changes.

Typical workflow:

1. Update the OpenAPI spec and/or Git-tracked contract test collection in this repo.
2. Commit changes in the `api` repo.
3. In Postman, refresh/pull the connected repository.
4. Regenerate/update the API Builder generated collection if the spec changed.
5. Run contract tests from `Board Third Party Library API (Contract Tests)`.
6. Save/export updates to the same Git-tracked collection file when test scripts change.

## Mock-First Flow

The contract test collection now includes:

- saved examples for the health endpoints (including `/health/ready` `200` and `503`)
- a `Mock Validation` folder with a mock-only request that forces the saved `503` readiness example using Postman mock headers

### Files used for mock-first work

- `postman/environments/board-third-party-library_mock.postman_environment.json`
- `postman/collections/postman-admin.board-third-party-library-mock-provisioning.postman_collection.json`
- `postman/collections/board-third-party-library-api.contract-tests.postman_collection.json`

### Provision the mock server (code-driven in Postman)

1. In Postman, import/sync the `Board Third Party Library - Mock` environment and select it.
2. Set a local-only current value for `postmanApiKey` in that environment (do not commit secrets).
3. Run `Postman Admin - Board Third Party Library Mock Provisioning`:
   - `Collections / List collections and resolve Contract Tests UID`
   - `Mocks / Create mock server (Contract Tests collection)`
4. The collection test scripts will populate:
   - `contractTestsCollectionUid`
   - `mockId`
   - `mockUrl`
   - `baseUrl` (set to the created mock URL)
5. Run `Board Third Party Library API (Contract Tests)` against the same `Board Third Party Library - Mock` environment.

### Mock response selection notes

- `Health / Readiness health check` validates the default saved example (expected healthy path).
- `Mock Validation / Readiness health check (Mock 503 example)` forces the unhealthy saved example using:
  - `x-mock-response-code: 503`
  - `x-mock-response-name: API is running but not ready due to dependency failure.`

## Repository Files

- `postman/specs/`: OpenAPI definitions (contract source of truth)
- `postman/collections/`: Git-tracked executable contract/smoke test collections and Postman admin/provisioning collections
- `postman/environments/`: Non-secret environment templates
- `postman/globals/`: Workspace globals when needed
- `.postman/config.json`: Postman Native Git workspace metadata and tracked artifact paths

## Working Rules

- API Builder generated collections are for spec sync and reference, not for long-lived hand-authored tests.
- Git-tracked collections are for executable tests and workflow assertions.
- Keep Postman Cloud admin/provisioning requests in a separate collection from API contract tests.
- Keep filenames stable once Postman Native Git is tracking them to avoid duplicate workspace artifacts.
