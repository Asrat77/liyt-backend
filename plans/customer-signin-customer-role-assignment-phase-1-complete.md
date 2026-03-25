## Phase 1 Complete: Lock Current Behavior With Tests

Added integration tests that define customer sign-in bootstrap expectations and preserved legacy customer confirmation behavior without password. The phase was completed as tests-only work, and review approved the test design and assertions.

**Files created/changed:**

- apps/liyt_api/test/controllers/customers/confirmations_controller_test.rb
- apps/liyt_api/test/controllers/auth/sessions_controller_test.rb

**Functions created/changed:**

- Customers::ConfirmationsControllerTest#test_confirms_delivery_with_sign_in_params_and_provisions_customer_user_role
- Customers::ConfirmationsControllerTest#test_confirms_delivery_without_password_and_preserves_legacy_confirmation_behavior
- Auth::SessionsControllerTest#test_customer_provisioned_via_confirmation_can_sign_in_and_refresh_with_customer_role

**Tests created/changed:**

- confirms delivery with sign-in params and provisions customer user role
- confirms delivery without password and preserves legacy confirmation behavior
- customer provisioned via confirmation can sign in and refresh with customer role

**Review Status:** APPROVED

**Git Commit Message:**
test: add customer signup role flow specs

- add customer confirmation tests for provisioning user and customer role
- preserve legacy confirmation behavior when password is absent
- cover sign-in and refresh role response for provisioned customer
