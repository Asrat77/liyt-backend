# UI Brief: Developer Dashboard (MVP)

Purpose

- Help business developers get API credentials and understand core integration flows.

Primary data types

- `api_keys`
- `api_requests` (if request logs are shown)

Screen-by-screen info hierarchy

1) API Docs

- Primary: auth schemes (JWT vs API key), base URL
- Secondary: idempotency guidance, core endpoints
- Tertiary: example requests/responses

2) API Keys list

- Primary: keys table with name, prefix, scopes, status
- Secondary: created_at, last_used_at, expiry
- Actions: create, revoke
- Empty state: no keys -> "Create API key"

3) Create API Key flow

- Primary: name and scopes
- Secondary: confirmation step
- One-time secret: show plaintext key once with copy CTA and warning

4) API Key detail (optional)

- Primary: key metadata and status
- Secondary: recent usage (if `api_requests` shown)
- Actions: rotate (create new + revoke old), set expiry

Critical UI states and edge cases

- One-time secret display: "This is the only time you will see this key"
- Revoked keys: clear badge and disabled state
- Expired keys: show reason and regenerate CTA

Notes

- Scopes should be human-readable and grouped by functional area.
