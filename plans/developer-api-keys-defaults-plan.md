## Plan: External Developer API Access + Business Defaults

Implement business-owned API key management, API-key-based delivery creation, and dashboard-configurable pickup defaults with test-first incremental phases.

**Phases 5**

1. **Phase 1: API Key Data Model**
- **Objective:** Add secure persistence for business API keys (hash-only, scoped, revocable, expirable).
- **Files/Functions to Modify/Create:** `apps/liyt_api/db/migrate/*create_api_keys*`, `apps/liyt_api/app/models/business.rb`, `apps/liyt_api/app/models/user.rb`, `apps/liyt_api/app/models/api_key.rb`, `apps/liyt_api/test/models/api_key_test.rb`, `apps/liyt_api/test/fixtures/api_keys.yml`.
- **Tests to Write:** model tests for generation, hash-only storage, uniqueness, scope validation, and active/expired/revoked predicates.
- **Steps:**
  1. Write failing model tests and fixtures.
  2. Add migration with indexes and constraints.
  3. Implement model behavior and associations.
  4. Run targeted tests and make them pass.

2. **Phase 2: Developer API Key Management Endpoints**
- **Objective:** Expose dashboard key lifecycle (list, create, revoke, rotate) with RBAC and tenancy.
- **Files/Functions to Modify/Create:** `apps/liyt_api/config/routes.rb`, `apps/liyt_api/app/controllers/api_keys_controller.rb`, `apps/liyt_api/app/controllers/concerns/authorization.rb`, `apps/liyt_api/test/controllers/api_keys_controller_test.rb`.
- **Tests to Write:** admin allowed create/revoke/rotate, staff forbidden where required, tenant isolation, plaintext key returned once.
- **Steps:**
  1. Write failing integration tests.
  2. Implement routes/controller actions.
  3. Enforce role and tenant checks.
  4. Run tests and make them pass.

3. **Phase 3: API Key Authentication for Delivery Create**
- **Objective:** Allow integrations to create deliveries via API key scopes.
- **Files/Functions to Modify/Create:** `apps/liyt_api/app/controllers/application_controller.rb`, `apps/liyt_api/app/models/current.rb`, `apps/liyt_api/app/controllers/concerns/authorization.rb`, `apps/liyt_api/config/routes.rb`, `apps/liyt_api/app/controllers/deliveries_controller.rb` (or dedicated integration controller), tests under `apps/liyt_api/test/controllers`.
- **Tests to Write:** valid key+scope success, invalid/revoked/expired unauthorized, missing scope forbidden, tenant isolation.
- **Steps:**
  1. Write failing integration tests.
  2. Implement API-key principal auth and scope checks.
  3. Wire delivery create endpoint for API keys.
  4. Run tests and make them pass.

4. **Phase 4: Business Defaults for Pickup**
- **Objective:** Add dashboard-managed defaults (default pickup location/contact/instructions) consumed by delivery create.
- **Files/Functions to Modify/Create:** settings migration/model/controller/routes, `apps/liyt_api/app/models/business.rb`, `apps/liyt_api/app/controllers/deliveries_controller.rb`, tests for settings and merge behavior.
- **Tests to Write:** create with defaults only, partial merge, request override precedence, 422 when unresolved pickup, tenant-safe defaults.
- **Steps:**
  1. Write failing tests for settings and delivery fallback behavior.
  2. Implement persistence and validations.
  3. Implement pickup fallback resolution in create flow.
  4. Run tests and make them pass.

5. **Phase 5: API Docs + Hardening**
- **Objective:** Update integration docs and align examples/contracts.
- **Files/Functions to Modify/Create:** `apps/liyt_api/docs/api.md`, `apps/liyt_api/README.md`, `docs/auth.md`, `docs/ui-brief-developer.md`.
- **Tests to Write:** run impacted suites and ensure no regressions.
- **Steps:**
  1. Update docs for auth, endpoints, and defaults behavior.
  2. Validate examples against implementation.
  3. Run impacted tests.

**Open Questions 4**

1. Should staff users also create/revoke keys, or admin-only?
2. Should partner endpoint be `/api/v1/deliveries` or `/api/v1/orders`?
3. Should `recipient_email` remain required for API clients?
4. Include idempotency in this implementation or next increment?
