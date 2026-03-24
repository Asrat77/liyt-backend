## Phase 3 Complete: API-Key Auth for Delivery Creation

Implemented API-key authentication for delivery creation with scope enforcement, tenant isolation by key business context, and preserved JWT behavior on non-create delivery endpoints. Phase 3 fixes were reviewed and approved, and Postman examples were updated to reflect key-auth status outcomes.

**Files created/changed:**

- apps/liyt_api/app/controllers/application_controller.rb
- apps/liyt_api/app/controllers/deliveries_controller.rb
- apps/liyt_api/app/models/current.rb
- apps/liyt_api/test/controllers/deliveries_controller_test.rb
- postman/DSCF CREDIT API_collection.json

**Functions created/changed:**

- ApplicationController#authenticate_request
- ApplicationController#authenticate_with_api_key_for_delivery_create
- ApplicationController#delivery_create_request?
- ApplicationController#find_active_api_key
- DeliveriesController#ensure_can_administer
- DeliveriesController#delivery_event_actor
- Current attributes (added api_key)

**Tests created/changed:**

- test/controllers/deliveries_controller_test.rb

**Review Status:** APPROVED

**Git Commit Message:**
feat: add api key auth for delivery create

- add X-API-Key auth path for POST /deliveries with scope checks
- preserve JWT behavior for non-create delivery endpoints
- record safe event actor for api-key created deliveries
- update deliveries tests and postman examples for auth outcomes
