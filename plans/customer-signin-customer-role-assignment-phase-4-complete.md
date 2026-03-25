## Phase 4 Complete: Documentation And Contract Alignment

Updated API and README documentation to describe optional account bootstrap during customer confirmation, preserved legacy no-password confirmation behavior, and aligned route examples with the actual `POST /customers/confirmation/confirm` endpoint.

**Files created/changed:**

- apps/liyt_api/docs/api.md
- apps/liyt_api/README.md

**Functions created/changed:**

- N/A (documentation phase)

**Tests created/changed:**

- N/A (documentation phase)

**Review Status:** APPROVED

**Git Commit Message:**
docs: document customer confirm signin flow

- describe optional password-based user provisioning on confirm
- clarify legacy confirmation behavior without password
- align README confirmation route with current routes
