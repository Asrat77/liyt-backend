# MVP Implementation Plan

0) Repo bootstrap

- Rails 8 API app, Postgres, Active Job with Solid Queue, Solid Cache, Solid Cable, Active Storage (disk in MVP).

1) Auth + RBAC (business staff)

- JWT access + `refresh_tokens`.
- `roles` + `user_roles` + permission checks.
- Tenant scoping via `Current.tenant`.

2) Business integrations

- `api_keys` issuance + verification.
- `api_requests` logging.
- `idempotency_keys` for create/accept endpoints.

3) Delivery core

- `deliveries`, `delivery_stops`, `delivery_events`, `delivery_items`.
- Status transitions + validations.

4) Driver MVP

- Availability + heartbeat.
- Available feed.
- Atomic accept.

5) Recipient MVP

- Send (P2P) and Track.
- Link stops to recipients by phone.

6) Notifications + Webhooks

- Notification outbox.
- Webhook outbox + worker.

7) Maps integration

- GebetaMaps adapter.
- Geocode + route caches.

Definition of done

- End-to-end: create -> accept -> delivered.
- Tracking works via code.
- Webhook and notifications retry safely.
