# Domain Model

Tenant boundary

- `Business` is the tenant root.
- Business-only data is always scoped by `business_id`.

Global actors

- `Recipient` is global (not tenanted).
- `Driver` is global (not tenanted).

Deliveries

- `Delivery` is the workflow entity.
- `delivery_stops` holds immutable address/contact snapshots.
- Each delivery has 2 stops in MVP:
  - `kind='pickup'`
  - `kind='dropoff'`
- `delivery_stops.recipient_id` optionally links a stop to a `Recipient` account.

Events and proofs

- `delivery_events` is the audit/timeline stream.
- `delivery_proofs` stores proof-of-delivery metadata; files attach via ActiveStorage.

Pricing

- `pricing_profiles` and `pricing_rules` are business-scoped pricing configs.
- `delivery_quotes` captures quote calculations.

Integrations

- `webhook_*` tables implement outbound webhooks.
- `api_keys` enable machine-to-machine access for businesses.

Observability

- `api_requests` logs requests.
- `audit_events` logs sensitive domain actions.
