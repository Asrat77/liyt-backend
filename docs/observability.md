# Observability

API request logging

- `api_requests` captures method/path/status/duration and actor metadata.

Audit events

- `audit_events` records sensitive business/admin actions.

Correlation

- Use a `request_id` propagated through logs and outbound webhooks.
