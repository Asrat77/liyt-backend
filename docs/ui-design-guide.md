# UI Design Guide (MVP)

This guide is a UX/product brief for designers. It focuses on structure, data, and behavior (not visual style).

Scope: MVP (no automated dispatch; drivers self-select and accept jobs).

## Goals

- Help business staff create and monitor deliveries quickly.
- Help drivers find work and complete deliveries with minimal friction.
- Help developers integrate via API keys and clear docs.

## In scope (MVP)

- Business dashboard (create, list, and view deliveries)
- Driver app (availability, available jobs, current delivery)
- Developer dashboard (API docs + API keys)

## Out of scope (MVP)

- Automated dispatch/offers
- Recipient portal login/OTP (tracking by code only)
- Payments and in-app chat

## Glossary (shared language)

- Business: tenant root (`businesses`). All business data is scoped by `business_id`.
- Business staff user: `users` (auth via JWT; roles via `roles`/`user_roles`).
- Driver: global actor (`drivers`). Driver app is tenantless.
- Recipient: global actor (`recipients`). No login required for tracking.
- Delivery: workflow entity (`deliveries`).
- Stops: immutable pickup/dropoff snapshots (`delivery_stops`), exactly 2 in MVP.
- Timeline: append-only event stream (`delivery_events`).
- Delivery `public_id`: internal-friendly identifier for authenticated apps.
- Tracking code: public bearer-like code for tracking (stored as digest in `delivery_tracking_tokens`).

## UX constraints to honor

- Driver feed is cross-tenant and must be PII-gated until accept.
- Accept is atomic; only one driver can win a job.
- Delivery transitions must always write timeline events.
- Tracking code and API keys are shown in plaintext only once.

## Core UI view models (designer-facing)

Backend models are normalized; UIs should use view models with clear hierarchy.

### Delivery summary (list/card)

Primary (always visible):

- `public_id`
- `status`
- `created_at`
- `pickup_summary` and `dropoff_summary` (surface-specific; see PII rules)

Secondary (optional):

- `ready_at`, `scheduled_pickup_at`, `promised_delivery_at`
- `channel` (`business | p2p`)
- `fee` (`total_fee_cents`, `currency`)

### Delivery detail (record)

Primary:

- `status` and next action
- Stops (pickup + dropoff)
- Timeline (`delivery_events[]`)

Secondary:

- `delivery_items[]` (if present)
- Driver (if accepted)
- Cancellation fields

### Stop (pickup/dropoff)

- `kind`: `pickup | dropoff`
- `contact_name`, `contact_phone`
- `address1`, `address2`, `city`, `region`, `postal_code`, `country_code`
- `latitude`, `longitude`
- `instructions`

### Timeline event

- `event_type`
- `from_status`, `to_status` (optional)
- `actor_type`, `actor_id`
- `note` (optional)
- `occurred_at`

### Driver availability

- `status`: `offline | available`
- `available_since`, `last_heartbeat_at`
- Derived: `busy` if an active delivery exists

### API key

- `name`
- `prefix` (safe to display)
- `scopes[]`
- `created_at`, `last_used_at`, `expires_at`, `revoked_at`

## PII and visibility rules (must be reflected in UI)

Driver available-jobs feed (pre-accept):

- Do NOT show: `address1/address2`, `contact_name`, `contact_phone`, `instructions`, business-private notes.
- OK to show: city/region, approximate pin, distance estimate, item count or weight ranges.

Post-accept:

- Full stop details become visible for that delivery.

Tracking view (by tracking code):

- OK: delivery status, high-level pickup/dropoff locality, ETA if provided, timeline.
- Avoid: full addresses, phone numbers, internal business references, driver PII beyond first name/vehicle type.

Recommended UI patterns:

- Use a "locked" panel state for address/contact fields in pre-accept views.
- Replace full address with locality string (city/region) and "Reveal after accept" hint.

## Surfaces and page inventory

Related briefs (screen-by-screen info hierarchy):

- `docs/ui-brief-business.md`
- `docs/ui-brief-driver.md`
- `docs/ui-brief-developer.md`

### 1) Business Dashboard (Business staff)

Primary jobs:

- Monitor deliveries
- Create manual orders
- Diagnose exceptions via timeline

Navigation (MVP):

- Dashboard
- Deliveries
- Create Delivery
- Integrations (API Keys)
- Settings (optional)

Pages to design:

1. Sign in
- Touches: `users`, `refresh_tokens`
- States: invalid credentials, locked/inactive user

2. Dashboard (overview)
- Touches (read): delivery counts by `status`, recent `delivery_events`
- Must show: pending backlog, in-progress, delivered, cancelled

3. Deliveries list
- Touches (read): `deliveries` + stop summaries
- Filters: status, date range, channel, driver accepted
- Must show: `public_id`, status, created_at, pickup/dropoff (full allowed), promised_delivery_at

4. Create delivery (manual order)
- Touches (write): `deliveries`, `delivery_stops` (pickup + dropoff), optional `delivery_items[]`
- Inputs: pickup (location preset), dropoff (contact + address), items, schedule
- Success: show `public_id` and initial `status=pending`
- Error states: validation, missing address, schedule conflict

5. Delivery detail
- Touches (read): `deliveries`, `delivery_stops`, `delivery_items`, `delivery_events`, `driver` (if accepted)
- Must show: status, next action (if any), stop details, timeline
- Actions: cancel (allowed statuses only)

6. Delivery timeline (part of detail)
- Touches (read): `delivery_events`
- Purpose: explain "what happened" for support and ops

7. Integrations: API Keys
- Touches (read/write): `api_keys`
- Must include: create, revoke, copy once warning

### 2) Driver App (Driver)

Primary jobs:

- Go online/offline
- See available jobs (PII-gated)
- Accept a job (atomic)
- Complete delivery status changes

Navigation (MVP):

- Home (availability + current job)
- Available jobs
- Current delivery
- Settings

Pages to design:

1. Driver sign in
- Touches: `drivers`, `refresh_tokens` (OTP recommended)
- States: verification, resend, rate limit

2. Home (availability)
- Touches (read/write): `driver_availabilities`
- Must show: online toggle, last heartbeat
- If busy: show current delivery card with CTA

3. Available jobs list (global feed)
- Touches (read): `deliveries(status=pending)` + safe stop summaries
- Must follow PII gating
- Must show: pickup area, dropoff area, distance/ETA estimate, created/ready time

4. Available job detail (pre-accept)
- Touches (read): same as list, PII-gated
- Action: Accept
- States: success -> current delivery, failure -> "already accepted" message

5. Current delivery (post-accept)
- Touches (read): `deliveries`, `delivery_stops` (full), `delivery_items`, `delivery_events`
- Must show: full pickup/dropoff details, instructions, status, next action
- Actions: mark picked up, mark in transit, mark delivered

6. Proof of delivery (optional)
- Touches (write): `delivery_proofs` + attachments
- Inputs: photo, signature, notes

7. Settings
- Touches: `drivers` (profile), app preferences

### 3) Developer Dashboard (Business integrations)

Primary jobs:

- Read API docs
- Create/revoke API keys
- Understand scopes and usage

Navigation (MVP):

- API Docs
- API Keys

Pages to design:

1. API Docs
- Touches: static docs content
- Must include: auth schemes, base URL, idempotency guidance, example payloads

2. API Keys list
- Touches: `api_keys`
- Fields: name, prefix, scopes, created_at, last_used_at, expires/revoked status
- Actions: create, revoke

3. Create API Key flow
- Touches (write): `api_keys`
- Steps: name + scopes, confirmation, show plaintext key once
- Must include: copy action, warning, and dismiss acknowledgment

## Data flows (end-to-end)

### A) Business creates a delivery, driver accepts, delivery completes

1. Business staff creates delivery
- Writes: `deliveries(status=pending)` + 2 `delivery_stops` + `delivery_events(created)`
2. Driver goes online
- Writes: `driver_availabilities(status=available)`
3. Driver sees available jobs
- Reads: `deliveries(status=pending)` with PII-gated fields
4. Driver accepts a job
- Atomic update: `deliveries` where `status=pending` and `driver_id IS NULL`
- Writes: `driver_id`, `accepted_at`, `status=accepted`, `delivery_events(accepted)`
5. Driver performs status transitions
- Writes: `deliveries.*_at` + `status` updates + `delivery_events` for each transition
6. Business monitors
- Reads: delivery detail + timeline; optionally receives notifications/webhooks

### B) API key creation and usage

1. Business staff creates API key
- Writes: `api_keys(prefix, key_hash, scopes)`
- UI shows plaintext key once
2. External system calls LIYT API
- Backend verifies hash; logs to `api_requests`
3. Business views keys and usage
- Reads: `api_keys`, optionally `api_requests`

## Required UI states (per surface)

Lists:

- Loading (skeleton or placeholder rows)
- Empty (no deliveries / no jobs / no keys)
- Error (retry affordance)

Detail views:

- Not found (invalid `public_id`)
- Permission denied (business scope)
- Stale data (status changed elsewhere)

Driver accept:

- Success (navigate to current delivery)
- Failure (already accepted)
- Offline (queue retry or disable action)

## Accessibility and device constraints

- Driver app is mobile-first; use large touch targets and clear next action.
- Critical status changes must be obvious without color alone.
- Provide offline/poor network feedback (last sync time, retry).

## Appendix: allowlists (recommended)

### Driver available feed allowlist (pre-accept)

- Delivery: `public_id`, `status`, `channel`, `created_at`, `ready_at`, `scheduled_pickup_at`, `estimated_distance_meters`, `estimated_duration_seconds`
- Stop summaries: `city`, `region`, `country_code`, optional coarse `latitude/longitude`
- Package summary: `total_weight_grams` (optional), item count (optional)

### Driver post-accept allowlist (current delivery)

- Full stop addresses, contacts, instructions, items, timeline
