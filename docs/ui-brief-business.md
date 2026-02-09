# UI Brief: Business Dashboard (MVP)

Purpose

- Help business staff create, monitor, and resolve deliveries quickly.

Primary data types

- `deliveries`, `delivery_stops`, `delivery_events`, `delivery_items`
- `users` (auth)
- `api_keys` (integrations, if in nav)

Screen-by-screen info hierarchy

1) Sign in

- Primary: email/phone + password, sign in CTA
- Secondary: forgot password (if provided), support contact
- States: invalid credentials, inactive user, loading

2) Dashboard (overview)

- Primary: status counts (pending, in-progress, delivered, cancelled)
- Secondary: recent activity list (latest `delivery_events`)
- Tertiary: today volume, exception callouts
- Empty state: no deliveries yet -> CTA to "Create delivery"

3) Deliveries list

- Primary: list/table of deliveries
  - Required columns: `public_id`, status, created_at, pickup, dropoff
- Secondary: filters (status, date range, channel, driver accepted)
- Tertiary: quick metrics (counts by status)
- Empty state: no results -> clear filters or create new

4) Create delivery (manual order)

- Primary: pickup and dropoff sections with contact + address
- Secondary: items/package info, schedule fields
- Tertiary: pricing preview (if shown), notes
- Confirmation: show `public_id`, status `pending`
- Error states: missing address, invalid phone, schedule conflict

5) Delivery detail

- Primary: status + next step, full pickup and dropoff details
- Secondary: timeline (events), items list, driver card (if accepted)
- Tertiary: fees, metadata, cancellation info
- Actions: cancel (if allowed by status)

6) Delivery timeline (if separate view)

- Primary: chronological events list with timestamps
- Secondary: actor attribution and notes

7) Integrations: API Keys (if in scope)

- Primary: list of keys (name, prefix, scopes, status)
- Secondary: create/revoke actions
- One-time secret: show plaintext key once with warning

Critical UI states and edge cases

- Delivery status updates in real time (or refresh indicator)
- Stale data: status changes while viewing detail
- Cancelation flow: confirm and explain effects

Notes

- Business views can show full address/contact details.
- Keep "Create delivery" consistently accessible.
