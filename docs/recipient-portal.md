# Recipient Portal

UI

- Two primary actions (large buttons): Send and Track.

Send

- Recipient creates a delivery with two stops.
- Pickup stop is the sender (the logged-in recipient).
- Dropoff stop is entered (or selected from saved addresses if implemented).

Track

- Recipient enters a tracking code.
- Server matches against `delivery_tracking_tokens.token_digest` and returns a limited tracking view.

Recipient deliveries list (optional)

- When logged in, recipients can see deliveries where a stop is linked via `delivery_stops.recipient_id`.
