## Phase 2 Complete: Implement Customer Account Bootstrap In Confirmation

Implemented optional customer sign-in account provisioning inside the existing confirmation transaction. When `email` and `password` are provided, the flow now creates or resolves a business-scoped `User`, ensures a `customer` role exists, and assigns it idempotently via `UserRole`, while preserving legacy behavior when password is omitted.

**Files created/changed:**

- apps/liyt_api/app/controllers/customers/confirmations_controller.rb
- postman/DSCF CREDIT API_collection.json

**Functions created/changed:**

- Customers::ConfirmationsController#confirm
- Customers::ConfirmationsController#assign_customer_signin_role
- Customers::ConfirmationsController#find_or_create_customer_user

**Tests created/changed:**

- Existing phase-1 confirmation/session tests were used as acceptance for this phase

**Review Status:** APPROVED with minor recommendations

**Git Commit Message:**
feat: provision customer user on confirm

- add optional user provisioning in customer confirmation flow
- assign business-scoped customer role idempotently
- update Postman collection for confirmation behavior changes
