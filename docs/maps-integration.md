# Maps Integration (GebetaMaps)

Use cases

- Geocoding: address -> lat/lng.
- Directions: route distance/duration for quote + ETA.
- ONM (one-to-many): driver location -> N pickup locations for feed ranking.

Caches

- `geocode_cache_entries` caches geocoding results.
- `route_cache_entries` caches directions results.

Quota safety

- Apply caching, batching, and backoff.
