# LIYT Backend

Backend for LIYT, a delivery platform. Businesses send deliveries to their customers, people send parcels to each other, and a shared pool of drivers picks the jobs up.

The Rails 8 API lives in `apps/liyt_api`. Delivery rules live in plain Ruby under `domains/`, outside Rails.

## What it does

- **Delivery lifecycle:** `pending → accepted → picked_up → in_transit → delivered`, plus `cancelled`, with every transition recorded as a delivery event.
- **Driver flow:** an availability toggle, a feed of open deliveries, and accept with atomic locking, so two drivers can never take the same job.
- **Multi-tenant business accounts:** role-based access, with tenant isolation enforced on every query.
- **Recipient portal:** send a parcel and track it.
- **Integrations:** business API keys (stored hashed), outbound webhooks, and a notification outbox with retries.
- **Maps:** GebetaMaps for geocoding and routing, with caching.
- **Observability:** API request logs and audit events.

## Stack

Ruby 3.4, Rails 8.1 (API only), PostgreSQL, Solid Queue and JWT. CI runs RuboCop, Brakeman, bundler-audit, the test suite, a Bullet N+1 check and a coverage gate (80% of lines, 50% of branches).

## Layout

| Path | What it is |
|---|---|
| `apps/liyt_api` | The Rails API app |
| `domains` | Delivery domain modules in plain Ruby |
| `infra` | Shared infrastructure helpers |
| `docs` | Product and architecture docs, starting with [docs/README.md](docs/README.md) |
| `postman` | API collection for trying the endpoints |

## Run it locally

```bash
cd apps/liyt_api
bin/setup          # installs gems and prepares the database
bin/rails test
bin/rails server
```

Endpoint examples and the local CI checks are in [apps/liyt_api/README.md](apps/liyt_api/README.md).
