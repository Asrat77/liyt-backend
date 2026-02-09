# Driver Flow

Availability

- `driver_availabilities` stores the current availability snapshot.
- `driver_availability_events` stores the history.

Available feed

- Show all `deliveries.status='pending'`.
- Rank by proximity to pickup stop using GebetaMaps ONM when driver location is available.

PII gating

- Feed returns minimal info (no full recipient address/contact) until accept.

Accept (atomic)

- Update `deliveries` only if `status='pending'` and `driver_id IS NULL`.
- Set `driver_id`, `accepted_at`, `status='accepted'`.
- Write `delivery_events`.

See `docs/snippets/atomic_accept.md`.
