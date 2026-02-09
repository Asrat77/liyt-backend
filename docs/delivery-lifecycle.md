# Delivery Lifecycle

Statuses (MVP)

- `pending`: created, available for drivers.
- `accepted`: a driver accepted the job.
- `picked_up`: driver has the package.
- `in_transit`: driver is en route.
- `delivered`: completed.
- `cancelled`: terminated.

State transitions

- Accept uses an atomic update (optimistic lock + status guard).
- Every transition creates a `delivery_events` row.

Cancel

- Capture `cancel_reason` + `cancelled_by_*`.
