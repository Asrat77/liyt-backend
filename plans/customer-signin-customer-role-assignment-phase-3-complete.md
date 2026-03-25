## Phase 3 Complete: Keep Signin Simple And Stable

Kept signin contract unchanged (`email` + `password`) and strengthened regression protection around customer role claims in JWTs. No production code changes were required for this phase.

**Files created/changed:**

- apps/liyt_api/test/controllers/auth/sessions_controller_test.rb

**Functions created/changed:**

- Auth::SessionsControllerTest#test_customer_provisioned_via_confirmation_can_sign_in_and_refresh_with_customer_role

**Tests created/changed:**

- Added assertions for customer role in signin access-token payload
- Added assertions for customer role in refresh access-token payload

**Review Status:** APPROVED

**Git Commit Message:**
test: assert customer role in jwt claims

- verify customer role claim in signin access token
- verify customer role claim in refresh access token
- keep signin params simple and unchanged
