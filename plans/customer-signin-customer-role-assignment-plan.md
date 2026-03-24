## Plan: Customer Signin And Role Assignment

Add a minimal customer-account bootstrap inside the existing customer confirmation flow so recipients can sign in with simple params while preserving current business and driver auth behavior. The implementation stays token-gated through delivery confirmation, assigns only the customer role server-side, and keeps API changes small.

**Phases 4**

1. **Phase 1: Lock Current Behavior With Tests**
- **Objective:** Capture current confirmation and session behavior, then add failing tests for customer sign-in bootstrap expectations.
- **Files/Functions to Modify/Create:** test/controllers/customers/*, test/controllers/auth/sessions_controller_test.rb
- **Tests to Write:** confirmation creates customer account when token plus email plus password are provided; confirmation keeps legacy behavior when password is absent; customer-provisioned user can authenticate through user sessions and receives customer role.
- **Steps:**
  1. Add integration tests for confirmation with token-gated account bootstrap.
  2. Run only the new tests and confirm failures.
  3. Keep assertions focused on User, Role, UserRole, and delivery status transitions.

2. **Phase 2: Implement Customer Account Bootstrap In Confirmation**
- **Objective:** On valid confirmation, optionally create or resolve a User for the delivery business using simple sign-in params and assign customer role.
- **Files/Functions to Modify/Create:** app/controllers/customers/confirmations_controller.rb, app/models/role.rb, app/models/user_role.rb
- **Tests to Write:** no duplicate customer role assignment for repeat confirmation; role assignment constrained to delivery business.
- **Steps:**
  1. Add minimal helper logic in confirmation flow to create/find User by email within the existing transaction.
  2. Create/find customer role scoped to delivery business and assign via UserRole.
  3. Ensure server-side role assignment only; do not accept role params from client.
  4. Re-run phase tests and make them pass.

3. **Phase 3: Keep Signin Simple And Stable**
- **Objective:** Confirm session creation remains simple and predictable for customer accounts using existing params.
- **Files/Functions to Modify/Create:** app/controllers/auth/sessions_controller.rb, app/controllers/concerns/token_issuer.rb
- **Tests to Write:** customer user signs in with email/password; token payload and refresh responses include customer role.
- **Steps:**
  1. Validate no new required params are introduced for normal signin.
  2. Keep response shape stable while ensuring role claims include customer.
  3. Run auth session tests and fix regressions minimally.

4. **Phase 4: Documentation And Contract Alignment**
- **Objective:** Align API docs and route descriptions with implemented customer sign-in bootstrap behavior.
- **Files/Functions to Modify/Create:** docs/api.md, README.md
- **Tests to Write:** none.
- **Steps:**
  1. Document required and optional params for confirmation-based account bootstrap.
  2. Document role assignment guarantees and signin expectations.
  3. Correct route-path mismatch in docs.

**Open Questions 3**

1. Should password be required for creating a sign-in capable customer user, or optional with legacy confirmation preserved?
2. If email already exists as a User in another business, should confirmation fail or link only Customer without User account?
3. Should confirmation response issue auth tokens immediately, or keep current response and require explicit signin afterward?
