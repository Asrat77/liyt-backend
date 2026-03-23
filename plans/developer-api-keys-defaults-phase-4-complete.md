## Phase 4 Complete: Business Pickup Defaults

Implemented business-managed pickup defaults with tenant-safe settings endpoints and delivery create fallback resolution. Delivery creation now supports missing/partial pickup payloads by using configured defaults, while preserving request-over-default precedence and returning a 422 contract when required pickup fields remain unresolved.

**Files created/changed:**

- apps/liyt_api/db/migrate/20260323130000_create_business_settings.rb
- apps/liyt_api/app/models/business_setting.rb
- apps/liyt_api/app/models/business.rb
- apps/liyt_api/app/controllers/business_settings_controller.rb
- apps/liyt_api/config/routes.rb
- apps/liyt_api/app/controllers/deliveries_controller.rb
- apps/liyt_api/test/controllers/business_settings_controller_test.rb
- apps/liyt_api/test/models/business_setting_test.rb
- apps/liyt_api/test/controllers/deliveries_controller_test.rb
- apps/liyt_api/db/schema.rb
- apps/liyt_api/db/seeds.rb
- postman/DSCF CREDIT API_collection.json

**Functions created/changed:**

- BusinessSetting model validations and associations
- Business has_one :business_setting association
- BusinessSettingsController#show
- BusinessSettingsController#update
- DeliveriesController#resolved_pickup_for_create
- DeliveriesController#default_pickup_attributes
- DeliveriesController#merged_pickup_attributes
- DeliveriesController#pickup_missing_fields

**Tests created/changed:**

- test/controllers/business_settings_controller_test.rb
- test/models/business_setting_test.rb
- test/controllers/deliveries_controller_test.rb

**Review Status:** APPROVED

**Git Commit Message:**
feat: add business pickup defaults for deliveries

- add business_settings persistence and tenant-safe settings endpoints
- apply pickup fallback precedence in deliveries create flow
- return pickup_invalid with missing_fields when defaults are insufficient
- add controller/model tests and update seeds/postman for phase 4
