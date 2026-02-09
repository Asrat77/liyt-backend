# Authentication

Business staff

- Primary: JWT access tokens.
- Long-lived refresh tokens stored in `refresh_tokens`.
- Authorization: role-based permissions per business.

Business integrations

- API keys stored as `api_keys.prefix` + `api_keys.key_hash`.
- Scope-limited via `api_keys.scopes`.

Drivers

- Recommended: phone OTP -> JWT + refresh tokens (same `refresh_tokens` polymorphic owner).
- Driver endpoints are tenantless.

Recipients

- Recommended: phone OTP -> JWT + refresh tokens.
- Tracking by code uses `delivery_tracking_tokens` (store digest, never plaintext).
