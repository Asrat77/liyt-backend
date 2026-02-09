# Authorization

Principles

- Business endpoints: enforce `Current.tenant` and scope all queries by `business_id`.
- Driver endpoints: tenantless, but restrict data exposure (PII gating).
- Recipient endpoints: tenantless, scoped by recipient identity + tracking tokens.

Controller concerns

- Use a shared concern for consistent authorization checks.
- Keep checks small, readable, and composable.

See `docs/snippets/authorization_concern.rb`.
