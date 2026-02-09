# Webhooks

Goal

- Notify businesses about delivery events (created, accepted, status changes, delivered, cancelled).

Model

- `webhook_endpoints`: configuration per business.
- `webhook_events`: durable event payloads.
- `webhook_deliveries`: delivery attempts with retry state.

Signing

- Store only `secret_digest`.
- Sign payload with HMAC on delivery.
