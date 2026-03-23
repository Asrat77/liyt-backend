## Phase 1 Complete: API Key Data Model

Implemented secure API key persistence for business integrations with hash-only storage, scope support, revocation/expiration fields, and model-level behavior/tests. This phase is approved by review and kept strictly to schema/model/test scope.

**Files created/changed:**

- apps/liyt_api/db/migrate/20260323120000_create_api_keys.rb
- apps/liyt_api/app/models/api_key.rb
- apps/liyt_api/app/models/business.rb
- apps/liyt_api/app/models/user.rb
- apps/liyt_api/db/schema.rb
- apps/liyt_api/db/seeds.rb
- apps/liyt_api/test/fixtures/api_keys.yml
- apps/liyt_api/test/models/api_key_test.rb
- apps/liyt_api/test/models/business_test.rb
- apps/liyt_api/test/models/user_test.rb

**Functions created/changed:**

- ApiKey.active
- ApiKey#active?
- ApiKey#revoked?
- ApiKey#expired?
- ApiKey#allows_scope?
- ApiKey#normalize_scopes
- ApiKey#ensure_key_material
- ApiKey#scopes_must_be_non_blank_strings
- Business has_many :api_keys
- User has_many :created_api_keys
- User has_many :revoked_api_keys

**Tests created/changed:**

- test/models/api_key_test.rb (new)
- test/models/business_test.rb (updated)
- test/models/user_test.rb (updated)
- test/fixtures/api_keys.yml (new)

**Review Status:** APPROVED

**Git Commit Message:**
feat: add secure api key data model

- add api_keys migration with business, audit users, scope and lifecycle fields
- implement ApiKey model with hash-only key material and scope/state helpers
- add business/user associations plus model fixtures and tests
- sync schema and seeds with phase-1 api key baseline
