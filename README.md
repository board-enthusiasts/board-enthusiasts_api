# board-enthusiasts_api

API-first contract artifacts for the maintained Board Enthusiasts Wave 2 surface.

## Scope

These tracked API artifacts now describe the maintained Cloudflare Workers + Supabase surface only.

Maintained areas:

- API metadata and health probes
- public catalog browse and public studio/title detail
- current-user bootstrap and profile
- developer self-enrollment
- developer managed-studio list
- moderation developer search

Removed from the maintained contract collection and environment templates:

- Keycloak browser-login and callback routes
- legacy auth/config variables and callback placeholders
- player library, wishlist, notifications, and title-report routes
- other legacy backend-only endpoints that are not part of the maintained Wave 2 surface

Historical planning notes may remain under [`planning/`](./planning/), but the maintained executable contract lives only under [`postman/`](./postman/).

## Source Of Truth

- OpenAPI spec: [`postman/specs/board-enthusiasts-api.v1.openapi.yaml`](./postman/specs/board-enthusiasts-api.v1.openapi.yaml)
- Contract collection: [`postman/collections/board-enthusiasts-api.contract-tests.postman_collection.json`](./postman/collections/board-enthusiasts-api.contract-tests.postman_collection.json)
- Mock admin collection: [`postman/collections/postman-admin.board-enthusiasts-mock-provisioning.postman_collection.json`](./postman/collections/postman-admin.board-enthusiasts-mock-provisioning.postman_collection.json)
- Local environment: [`postman/environments/board-enthusiasts_local.postman_environment.json`](./postman/environments/board-enthusiasts_local.postman_environment.json)
- Mock environment: [`postman/environments/board-enthusiasts_mock.postman_environment.json`](./postman/environments/board-enthusiasts_mock.postman_environment.json)
- Mock admin environment: [`postman/environments/board-enthusiasts_mock-admin.postman_environment.json`](./postman/environments/board-enthusiasts_mock-admin.postman_environment.json)

## Local Workflow

Use the root CLI from the solution repository. Do not treat `api/scripts/*` as the primary entrypoint for routine work.

Recommended local contract run:

```bash
python ./scripts/dev.py api-test --start-workers
```

That flow is intended to:

- start or reuse local Supabase services
- reseed deterministic local Supabase auth/data/storage fixtures
- start the local Workers API
- fetch seeded developer and moderator bearer tokens
- run the Postman contract collection against `http://127.0.0.1:8787`

If you need the raw API-only helper instead of the root CLI:

```powershell
./scripts/run-postman-contract-tests.ps1 -BaseUrl http://127.0.0.1:8787
```

## Environment Variables

The committed local and mock environments intentionally keep only the maintained variables:

- `baseUrl`
- `contractExecutionMode`
- `developerAccessToken`
- `moderatorAccessToken`
- `expectedServiceName`
- readiness expectation variables

Anything tied to the removed Keycloak or legacy backend contract surface has been stripped from the maintained environment templates.

## Mock Workflow

The Postman admin collection still provisions mocks from the tracked contract collection and syncs the runtime mock environment `baseUrl`.

The provisioning validation now checks for maintained Wave 2 routes and saved examples rather than the removed Keycloak routes.

Normal mock validation path:

1. Provision the mock with the admin collection or root automation.
2. Run the tracked contract collection against the mock environment.
3. Use the `Mock Validation` folder to force the saved `503` readiness example when needed.

## Working Rules

- Keep exactly one maintained Git-tracked contract collection.
- Keep the tracked OpenAPI spec aligned to the maintained Wave 2 Workers surface.
- Do not reintroduce legacy-only endpoints or variables into the maintained collection/environment templates.
- Keep Postman Cloud provisioning requests in the separate admin collection.
- Keep the supported developer entrypoint rooted at `python ./scripts/dev.py ...`.
