# Overview

LIYT is a delivery platform with:

- Business deliveries (multi-tenant): businesses create deliveries for recipients.
- Peer-to-peer (P2P): recipients can create deliveries from the recipient portal.
- A shared driver pool: drivers browse available deliveries and accept them (no auto-dispatch in MVP).

MVP scope:

- Delivery lifecycle: `pending -> accepted -> picked_up -> in_transit -> delivered` (+ `cancelled`).
- Driver flow: availability toggle, available feed, accept with atomic locking, status updates.
- Recipient portal: Send + Track.
- Business ops: create/manage deliveries, pricing profiles, API keys, webhooks.

Non-goals (MVP):

- Automated dispatch / forced assignment.
- Multi-stop route optimization (can come later).
- Payments (unless you explicitly add it).
