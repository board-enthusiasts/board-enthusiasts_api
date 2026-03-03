# Player Library And Developer Enrollment Contract Draft

## Table of Contents

- [Purpose](#purpose)
- [Status](#status)
- [Draft Routes](#draft-routes)
- [Draft Response Shapes](#draft-response-shapes)
- [Open Questions](#open-questions)

## Purpose

This draft captures the next player-facing authenticated API surface without adding future-only endpoints to the maintained `v1` contract before backend implementation begins.

Use this document to guide the later contract-first implementation of:

- the authenticated player library
- the authenticated wishlist
- the separate post-sign-in developer enrollment step

## Status

Status on March 3, 2026:

- frontend routes now exist as visual stubs at `/player/library`, `/player/wishlist`, and `/account/developer-access`
- backend implementation does not exist yet
- the maintained contract remains [`api/postman/specs/board-third-party-library-api.v1.openapi.yaml`](../postman/specs/board-third-party-library-api.v1.openapi.yaml)

## Draft Routes

### `GET /player/library`

Authenticated read model for the signed-in player's owned and organized titles.

Intended behavior:

- return only the caller's private player-library data
- include owned titles first
- expose collection/favorite metadata when those features exist

### `GET /player/wishlist`

Authenticated read model for titles the signed-in player has saved for later.

Intended behavior:

- return only the caller's private wishlist entries
- reuse public catalog summary fields so wishlist cards can render without extra catalog fetches
- support future sort modes such as `recentlyAdded`

### `POST /identity/me/developer-enrollment`

Authenticated developer-enrollment action that stays separate from account registration.

Intended behavior:

- allow a signed-in player to request or activate developer access
- keep the exact approval model configurable for later policy decisions
- return a player-facing status instead of raw identity-provider role details

## Draft Response Shapes

```yaml
paths:
  /player/library:
    get:
      tags: [Player]
      security:
        - BearerAuth: []
      responses:
        '200':
          description: Authenticated player library returned successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PlayerLibraryResponse'
  /player/wishlist:
    get:
      tags: [Player]
      security:
        - BearerAuth: []
      responses:
        '200':
          description: Authenticated wishlist returned successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/PlayerWishlistResponse'
  /identity/me/developer-enrollment:
    post:
      tags: [Identity]
      security:
        - BearerAuth: []
      responses:
        '200':
          description: Developer enrollment state returned successfully.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/DeveloperEnrollmentResponse'

components:
  schemas:
    PlayerLibraryResponse:
      type: object
      required: [playerLibrary]
      properties:
        playerLibrary:
          $ref: '#/components/schemas/PlayerLibrary'
    PlayerLibrary:
      type: object
      required: [ownedTitles, collections, favorites]
      properties:
        ownedTitles:
          type: array
          items:
            $ref: '#/components/schemas/CatalogTitleSummary'
        collections:
          type: array
          items:
            $ref: '#/components/schemas/PlayerCollection'
        favorites:
          type: array
          items:
            type: string
            format: uuid
    PlayerCollection:
      type: object
      required: [id, displayName, titleIds]
      properties:
        id:
          type: string
          format: uuid
        displayName:
          type: string
        titleIds:
          type: array
          items:
            type: string
            format: uuid
    PlayerWishlistResponse:
      type: object
      required: [wishlist]
      properties:
        wishlist:
          $ref: '#/components/schemas/PlayerWishlist'
    PlayerWishlist:
      type: object
      required: [titles]
      properties:
        titles:
          type: array
          items:
            $ref: '#/components/schemas/CatalogTitleSummary'
    DeveloperEnrollmentResponse:
      type: object
      required: [developerEnrollment]
      properties:
        developerEnrollment:
          type: object
          required: [status, developerAccessEnabled]
          properties:
            status:
              type: string
              enum: [notRequested, pendingReview, enabled]
            developerAccessEnabled:
              type: boolean
```

## Open Questions

- whether developer enrollment is auto-approved or review-based
- whether wishlist writes should live under `/player/wishlist` or under catalog title actions
- whether player collections and favorites ship in the same backend wave as owned-title entitlements or immediately after
