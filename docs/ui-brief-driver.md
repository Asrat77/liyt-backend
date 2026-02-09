# UI Brief: Driver App (MVP)

Purpose

- Help drivers go online, find available jobs, accept one, and complete delivery steps.

Primary data types

- `drivers`, `driver_availabilities`, `driver_positions`
- `deliveries`, `delivery_stops`, `delivery_events`, `delivery_items`

Screen-by-screen info hierarchy

1) Driver sign in (OTP)

- Primary: phone input, OTP input, continue CTA
- Secondary: resend OTP, support link
- States: rate limit, invalid code, loading

2) Home (availability)

- Primary: availability toggle (online/offline)
- Secondary: last heartbeat, current delivery card (if busy)
- Tertiary: shift summary (optional)

3) Available jobs list (pre-accept)

- Primary: job cards with pickup and dropoff locality
- Secondary: distance/ETA estimate, created/ready time
- Tertiary: package summary (item count, weight range)
- Empty state: no jobs -> refresh or keep online
- PII gating: no address/contact/instructions

4) Available job detail (pre-accept)

- Primary: pickup/dropoff locality + job summary
- Secondary: distance/ETA, package summary
- Tertiary: notes that are safe for pre-accept
- Actions: Accept
- Failure state: already accepted

5) Current delivery (post-accept)

- Primary: full pickup address/contact + next action CTA
- Secondary: full dropoff address/contact, instructions
- Tertiary: items, timeline, map CTA (if provided)
- Actions: mark picked up, mark in transit, mark delivered

6) Proof of delivery (optional)

- Primary: capture photo or signature
- Secondary: notes, confirm delivery

7) Settings

- Primary: profile info, vehicle type (if editable)
- Secondary: notifications, language

Critical UI states and edge cases

- Accept race: show "Already accepted" and return to feed
- Offline mode: show last sync time and disable status updates
- Stale feed: job disappears after refresh
- Cancellation while en route: show clear next steps

Notes

- Pre-accept views must hide PII; show "Locked until accept" pattern.
- Post-accept views show full stop details.
