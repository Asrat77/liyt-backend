# Authentication

Business staff

- Primary: JWT access tokens.
- Long-lived refresh tokens stored in `refresh_tokens`.
- Authorization: role-based permissions per business.

Business integrations

- API keys stored as `api_keys.prefix` + `api_keys.key_hash`.
- Scope-limited via `api_keys.scopes`.
- API key lifecycle (dashboard):
	- `GET /api_keys` and `GET /api_keys/:id` for `admin` and `staff`
	- `POST /api_keys`, `PATCH /api_keys/:id/revoke`, `PATCH /api_keys/:id/rotate` for `admin` only
- API key plaintext is returned once (create/rotate) and never persisted.
- API key request auth path is currently enabled for `POST /deliveries` via `X-API-Key`.
- Delivery creation with API key requires `deliveries:write` scope.
- For `POST /deliveries`, if both `Authorization` and `X-API-Key` are present, API key auth is used.
- API key delivery create failures:
	- `401` for missing/invalid/revoked/expired key in key-auth path
	- `403` for missing required scope
	- `422 pickup_invalid` when required pickup fields are unresolved after defaults merge

Business pickup defaults

- Stored in `business_settings` and managed by `GET /business_settings` and `PATCH /business_settings`.
- Delivery pickup resolution order:
	- request `pickup` fields
	- tenant `business_settings` pickup defaults
	- `422 pickup_invalid` with `missing_fields` when still incomplete

Drivers

- Recommended: phone OTP -> JWT + refresh tokens (same `refresh_tokens` polymorphic owner).
- Driver endpoints are tenantless.

Recipients

- Recommended: phone OTP -> JWT + refresh tokens.
- Tracking by code uses `delivery_tracking_tokens` (store digest, never plaintext).
