# API Routes

This document lists all routes defined in `apps/liyt_api/config/routes.rb`, with request/response bodies, restrictions, and flows based on current controllers and tests.

## Shared behavior

- Auth header: `Authorization: Bearer <access_token>`
- API key header: `X-API-Key: <plaintext_api_key>`
- Access tokens: JWT, `typ` of `user` or `driver`
- Refresh tokens: long-lived and stored as a hash; provided only at issue/refresh time
- Default auth: all routes require auth unless explicitly noted below
- API key auth path is enabled only for `POST /deliveries`
- For `POST /deliveries`, when both `Authorization` and `X-API-Key` are present, API key auth is used
- Health check: `/up` is always unauthenticated

### Token response shape

```json
{
  "access_token": "<jwt>",
  "refresh_token": "<opaque>",
  "token_type": "Bearer",
  "expires_in": 900
}
```

## Health

### GET /up

- Purpose: health check
- Auth: not required
- Responses:
  - 200 OK when the app boots with no exceptions
  - 500 Internal Server Error otherwise

## Auth (business users)

### POST /auth/sessions

- Controller: `Auth::SessionsController#create`
- Auth: not required
- Body:
  - `email` (string, required)
  - `password` (string, required)
- Responses:
  - 201 Created: token response
  - 401 Unauthorized: invalid credentials or unknown email

### POST /auth/sessions/refresh

- Controller: `Auth::SessionsController#refresh`
- Auth: not required
- Body:
  - `refresh_token` (string, required)
- Restrictions:
  - Token must exist and not be expired or revoked
  - If expired or revoked, the entire token family is revoked
- Responses:
  - 200 OK: token response plus roles
  - 401 Unauthorized: missing token, unknown token, expired token, or revoked token
- Response body:
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<opaque>",
  "token_type": "Bearer",
  "expires_in": 900,
  "roles": ["admin"]
}
```

### POST /auth/sessions/revoke

- Controller: `Auth::SessionsController#revoke`
- Auth: not required
- Body:
  - `refresh_token` (string, required)
- Restrictions:
  - Revokes the entire token family
- Responses:
  - 204 No Content: token family revoked
  - 401 Unauthorized: missing token
  - 404 Not Found: token not found

### POST /auth/registrations

- Controller: `Auth::RegistrationsController#create`
- Auth: not required
- Body:
  - `business_name` (string, required)
  - `support_email` (string, optional)
  - `email` (string, required)
  - `password` (string, required)
- Flow:
  - Create business
  - Create user for the business
  - Ensure admin role exists for the business
  - Assign admin role to the user
  - Issue access and refresh tokens
- Responses:
  - 201 Created: token response plus user, business, roles
  - 422 Unprocessable Entity: invalid data or duplicate email
- Response body:
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<opaque>",
  "token_type": "Bearer",
  "expires_in": 900,
  "user": { "id": 1, "email": "admin@example.test", "business_id": 1 },
  "business": {
    "id": 1,
    "name": "Acme Dispatch",
    "slug": "acme-dispatch",
    "status": "active",
    "support_email": "support@acme.test"
  },
  "roles": ["admin"]
}
```

### GET /auth/me

- Controller: `Auth::MeController#show`
- Auth: required (user token)
- Responses:
  - 200 OK: current user info and roles
  - 401 Unauthorized: missing or invalid token
- Response body:
```json
{
  "id": 1,
  "email": "admin@example.test",
  "business_id": 1,
  "roles": ["admin"]
}
```

## Drivers

### POST /drivers/sessions

- Controller: `Drivers::SessionsController#create`
- Auth: not required
- Body:
  - `email` (string, required)
  - `password` (string, required)
- Responses:
  - 201 Created: token response
  - 401 Unauthorized: invalid credentials or unknown email

### POST /drivers/sessions/refresh

- Controller: `Drivers::SessionsController#refresh`
- Auth: not required
- Body:
  - `refresh_token` (string, required)
- Restrictions:
  - Token must exist and belong to a Driver
  - Token must not be expired or revoked
  - If expired or revoked, the entire token family is revoked
- Responses:
  - 200 OK: token response
  - 401 Unauthorized: missing token, unknown token, wrong owner type, expired token, or revoked token

### POST /drivers/sessions/revoke

- Controller: `Drivers::SessionsController#revoke`
- Auth: not required
- Body:
  - `refresh_token` (string, required)
- Restrictions:
  - Token must exist and belong to a Driver
  - Revokes the entire token family
- Responses:
  - 204 No Content: token family revoked
  - 401 Unauthorized: missing token
  - 404 Not Found: token not found or not a Driver token

### POST /drivers/registrations

- Controller: `Drivers::RegistrationsController#create`
- Auth: not required
- Body:
  - `email` (string, required)
  - `password` (string, required)
  - `full_name` (string, optional)
  - `phone` (string, required)
  - `vehicle_type` (string, optional)
  - `license_number` (string, optional)
- Flow:
  - Create driver
  - Issue access and refresh tokens
- Responses:
  - 201 Created: token response plus driver
  - 422 Unprocessable Entity: invalid data, duplicate email, or duplicate phone
- Response body:
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<opaque>",
  "token_type": "Bearer",
  "expires_in": 900,
  "driver": {
    "id": 1,
    "email": "driver@example.test",
    "full_name": "Sam Rider",
    "phone": "+251911111111",
    "status": "active",
    "vehicle_type": "motorbike",
    "license_number": "LIC-123",
    "verified_at": null,
    "rating": null,
    "last_latitude": null,
    "last_longitude": null,
    "last_location_at": null
  }
}
```

### GET /drivers/me

- Controller: `Drivers::MeController#show`
- Auth: required (driver token)
- Responses:
  - 200 OK: current driver info
  - 401 Unauthorized: missing or invalid token
- Response body:
```json
{
  "id": 1,
  "email": "driver@example.test",
  "full_name": "Sam Rider",
  "phone": "+251911111111",
  "status": "active",
  "vehicle_type": "motorbike",
  "license_number": "LIC-123",
  "verified_at": null,
  "rating": null,
  "last_latitude": null,
  "last_longitude": null,
  "last_location_at": null
}
```

## Customers

### POST /customers/sessions

- Controller: `Customers::SessionsController#create`
- Auth: not required
- Body:
  - `email` (string, required)
  - `password` (string, required)
- Restrictions:
  - Account must have `customer` role
- Responses:
  - 201 Created: token response
  - 401 Unauthorized: invalid credentials, unknown email, or missing customer role

### POST /customers/sessions/refresh

- Controller: `Customers::SessionsController#refresh`
- Auth: not required
- Body:
  - `refresh_token` (string, required)
- Restrictions:
  - Token must exist and belong to a User with `customer` role
  - Token must not be expired or revoked
  - If expired or revoked, the entire token family is revoked
- Responses:
  - 200 OK: token response plus roles
  - 401 Unauthorized: missing token, unknown token, wrong owner type, non-customer owner, expired token, or revoked token
- Response body:
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<opaque>",
  "token_type": "Bearer",
  "expires_in": 900,
  "roles": ["customer"]
}
```

### POST /customers/sessions/revoke

- Controller: `Customers::SessionsController#revoke`
- Auth: not required
- Body:
  - `refresh_token` (string, required)
- Restrictions:
  - Token must exist and belong to a User with `customer` role
  - Revokes the entire token family
- Responses:
  - 204 No Content: token family revoked
  - 401 Unauthorized: missing token
  - 404 Not Found: token not found or token does not belong to a customer user

### POST /customers/registrations

- Controller: `Customers::RegistrationsController#create`
- Auth: not required
- Body:
  - `email` (string, required)
  - `password` (string, required)
  - `full_name` (string, optional)
  - `phone` (string, optional)
- Flow:
  - Resolve a server-managed business context (customers are not required to choose a business during signup)
  - Create user for that business
  - Ensure customer role exists for that business
  - Assign customer role to the user
  - Issue access and refresh tokens
- Responses:
  - 201 Created: token response plus user and roles
  - 422 Unprocessable Entity: invalid data or duplicate email
- Response body:
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<opaque>",
  "token_type": "Bearer",
  "expires_in": 900,
  "user": { "id": 1, "email": "customer@example.test", "business_id": 1 },
  "roles": ["customer"]
}
```

### GET /customers/me

- Controller: `Customers::MeController#show`
- Auth: required (customer user token)
- Restrictions:
  - Current user must have `customer` role
- Responses:
  - 200 OK: current customer user info and roles
  - 401 Unauthorized: missing/invalid token or non-customer user token
- Response body:
```json
{
  "id": 1,
  "email": "customer@example.test",
  "business_id": 1,
  "roles": ["customer"]
}
```

## Business locations

### GET /business_locations

- Controller: `BusinessLocationsController#index`
- Auth: required (user token)
- Responses:
  - 200 OK: list of business locations for the current tenant

### GET /business_locations/:id

- Controller: `BusinessLocationsController#show`
- Auth: required (user token)
- Responses:
  - 200 OK: business location
  - 404 Not Found: location not in tenant

### POST /business_locations

- Controller: `BusinessLocationsController#create`
- Auth: required (admin only)
- Body:
  - `name` (string, required)
  - `country_code` (string, required)
  - `address1` (string, optional)
  - `address2` (string, optional)
  - `city` (string, optional)
  - `region` (string, optional)
  - `postal_code` (string, optional)
  - `latitude` (decimal, optional)
  - `longitude` (decimal, optional)
  - `instructions` (string, optional)
  - `active` (boolean, optional; default true)
- Responses:
  - 201 Created: business location
  - 403 Forbidden: non-admin user
  - 422 Unprocessable Entity: invalid data

### PATCH /business_locations/:id

- Controller: `BusinessLocationsController#update`
- Auth: required (admin only)
- Body: any field from create
- Responses:
  - 200 OK: business location
  - 403 Forbidden: non-admin user
  - 404 Not Found: location not in tenant
  - 422 Unprocessable Entity: invalid data

### DELETE /business_locations/:id

- Controller: `BusinessLocationsController#destroy`
- Auth: required (admin only)
- Responses:
  - 204 No Content: deleted
  - 403 Forbidden: non-admin user
  - 404 Not Found: location not in tenant

### Business location response

```json
{
  "id": 1,
  "business_id": 1,
  "name": "Warehouse One",
  "address1": "100 Main St",
  "address2": null,
  "city": "Portland",
  "region": "OR",
  "postal_code": "97204",
  "country_code": "US",
  "latitude": "45.5152",
  "longitude": "-122.6784",
  "instructions": "Dock 3",
  "active": true,
  "created_at": "2026-02-13T16:31:54Z",
  "updated_at": "2026-02-13T16:31:54Z"
}
```

## Business settings (pickup defaults)

### GET /business_settings

- Controller: `BusinessSettingsController#show`
- Auth: required (user token, staff or admin)
- Purpose: read tenant-level pickup defaults used by `POST /deliveries`
- Responses:
  - 200 OK: current tenant settings (returns empty/null values if not configured)
  - 403 Forbidden: user without `staff` or `admin` role
  - 401 Unauthorized: missing or invalid token

### PATCH /business_settings

- Controller: `BusinessSettingsController#update`
- Auth: required (user token, admin only)
- Body:
  - `pickup_address1` (string, optional)
  - `pickup_address2` (string, optional)
  - `pickup_city` (string, optional)
  - `pickup_region` (string, optional)
  - `pickup_postal_code` (string, optional)
  - `pickup_country_code` (string, optional)
  - `pickup_latitude` (decimal, optional)
  - `pickup_longitude` (decimal, optional)
  - `pickup_contact_name` (string, optional)
  - `pickup_contact_phone` (string, optional)
  - `pickup_instructions` (string, optional)
- Responses:
  - 200 OK: updated settings
  - 403 Forbidden: non-admin user
  - 422 Unprocessable Entity: invalid settings (`error: business_setting_invalid`)

### Business settings response

```json
{
  "id": 1,
  "business_id": 1,
  "pickup_address1": "Warehouse 9",
  "pickup_address2": null,
  "pickup_city": "Adama",
  "pickup_region": "Oromia",
  "pickup_postal_code": null,
  "pickup_country_code": "ET",
  "pickup_latitude": null,
  "pickup_longitude": null,
  "pickup_contact_name": "Dispatch",
  "pickup_contact_phone": "+251922222222",
  "pickup_instructions": "Use loading bay",
  "created_at": "2026-02-20T11:00:00Z",
  "updated_at": "2026-02-20T11:05:00Z"
}
```

## API keys

All API key endpoints are tenant-scoped and require a user JWT (not API-key auth).

RBAC for key management:

- `staff` or `admin` can list and view keys
- `admin` only can create, revoke, and rotate keys

### GET /api_keys

- Controller: `ApiKeysController#index`
- Auth: required (user token, staff or admin)
- Responses:
  - 200 OK: tenant keys ordered by newest first
  - 403 Forbidden: non-staff/non-admin

### GET /api_keys/:id

- Controller: `ApiKeysController#show`
- Auth: required (user token, staff or admin)
- Responses:
  - 200 OK: key metadata
  - 403 Forbidden: non-staff/non-admin
  - 404 Not Found: key outside current tenant

### POST /api_keys

- Controller: `ApiKeysController#create`
- Auth: required (user token, admin only)
- Body:
  - `name` (string, required)
  - `scopes` (array[string], optional; defaults to `["deliveries:write"]`)
  - `expires_at` (datetime, optional)
- Responses:
  - 201 Created: metadata plus one-time `plaintext_key`
  - 403 Forbidden: non-admin
  - 422 Unprocessable Entity: invalid input (`error: api_key_invalid`)

### PATCH /api_keys/:id/revoke

- Controller: `ApiKeysController#revoke`
- Auth: required (user token, admin only)
- Responses:
  - 200 OK: key metadata with `revoked_at` and `revoked_by_user_id`
  - 403 Forbidden: non-admin
  - 404 Not Found: key outside current tenant

### PATCH /api_keys/:id/rotate

- Controller: `ApiKeysController#rotate`
- Auth: required (user token, admin only)
- Body (all optional):
  - `name` (string)
  - `scopes` (array[string])
  - `expires_at` (datetime; can be set/cleared)
- Behavior:
  - Revokes the current key
  - Creates a replacement key in the same tenant
  - Returns one-time `plaintext_key` for the replacement
- Responses:
  - 201 Created: replacement key metadata plus one-time `plaintext_key`
  - 403 Forbidden: non-admin
  - 404 Not Found: key outside current tenant
  - 422 Unprocessable Entity: invalid input (`error: api_key_invalid`)

### API key response shape

`plaintext_key` is present only on create/rotate responses.

```json
{
  "id": 12,
  "business_id": 1,
  "name": "Orders Integration",
  "prefix": "a1b2c3d4e5f6",
  "scopes": ["deliveries:write"],
  "last_used_at": null,
  "expires_at": null,
  "revoked_at": null,
  "created_by_user_id": 4,
  "revoked_by_user_id": null,
  "created_at": "2026-02-20T11:00:00Z",
  "updated_at": "2026-02-20T11:00:00Z",
  "plaintext_key": "a1b2c3d4e5f6.secret-material"
}
```

## Deliveries (Business)

### GET /deliveries

- Controller: `DeliveriesController#index`
- Auth: required (user token)
- Query params:
  - `status` (string, optional): filter by status
- Responses:
  - 200 OK: list of deliveries for the current tenant
- Response body:
```json
[
  {
    "id": 1,
    "public_id": "ABC123XYZ",
    "status": "awaiting_recipient",
    "price": 150.00,
    "description": "Package delivery",
    "business_id": 1,
    "driver_id": null,
    "customer_id": null,
    "accepted_at": null,
    "picked_up_at": null,
    "delivered_at": null,
    "cancelled_at": null,
    "created_at": "2026-02-14T20:17:01Z"
  }
]
```

### GET /deliveries/:id

- Controller: `DeliveriesController#show`
- Auth: required (user token)
- Responses:
  - 200 OK: delivery details with stops and items
  - 404 Not Found: delivery not found or not in tenant
- Response body:
```json
{
  "id": 1,
  "public_id": "ABC123XYZ",
  "status": "awaiting_recipient",
  "price": 150.00,
  "description": "Package delivery",
  "business_id": 1,
  "driver_id": null,
  "customer_id": null,
  "accepted_at": null,
  "picked_up_at": null,
  "delivered_at": null,
  "cancelled_at": null,
  "created_at": "2026-02-14T20:17:01Z",
  "stops": [
    {
      "id": 1,
      "kind": "pickup",
      "sequence": 0,
      "address1": "123 Pickup St",
      "city": "Addis Ababa",
      "region": "Addis Ababa",
      "contact_name": "Sender Name",
      "contact_phone": "+251911111111"
    }
  ],
  "items": [
    {
      "id": 1,
      "name": "Package A",
      "quantity": 2
    }
  ]
}
```

### POST /deliveries

- Controller: `DeliveriesController#create`
- Auth:
  - User JWT (`Authorization`) with `admin` role, OR
  - API key (`X-API-Key`) with `deliveries:write` scope
- Auth precedence:
  - For this endpoint only, if both headers are present, API-key auth is used
- Body:
  - `description` (string, optional)
  - `price` (decimal, optional): default 0.00
  - `recipient_email` (string, optional): if present, sends confirmation email
  - `pickup` (object, optional; merged over business defaults):
    - `address1` (string)
    - `address2` (string, optional)
    - `city` (string)
    - `region` (string)
    - `postal_code` (string, optional)
    - `country_code` (string)
    - `latitude` (decimal, optional)
    - `longitude` (decimal, optional)
    - `contact_name` (string)
    - `contact_phone` (string)
    - `instructions` (string, optional)
  - `items` (array, optional):
    - `name` (string)
    - `quantity` (integer, default 1)
- Flow:
  - Resolve pickup as: `business_settings defaults` + `request pickup override`
  - Validate required pickup fields: `address1`, `city`, `region`, `country_code`, `contact_name`, `contact_phone`
  - Create delivery with status `awaiting_recipient`
  - Create pickup stop
  - Create items
  - Generate tracking token
  - Send confirmation email to recipient
- Responses:
  - 201 Created: delivery created
  - 401 Unauthorized: missing/invalid auth, invalid API key, revoked API key, or expired API key
  - 403 Forbidden: user is not admin or API key lacks `deliveries:write`
  - 422 Unprocessable Entity:
    - `pickup_invalid` when required pickup data cannot be resolved
    - `delivery_invalid` for model-level validation failures

### Delivery create 422 (`pickup_invalid`) response

```json
{
  "error": "pickup_invalid",
  "missing_fields": ["address1", "city", "region", "country_code", "contact_name", "contact_phone"]
}
```

### PATCH /deliveries/:id/cancel

- Controller: `DeliveriesController#cancel`
- Auth: required (admin only)
- Body:
  - `reason` (string, optional)
- Restrictions:
  - Can only cancel when status is `awaiting_recipient` or `pending`
- Responses:
  - 204 No Content: cancelled
  - 403 Forbidden: non-admin user
  - 404 Not Found: delivery not found
  - 422 Unprocessable Entity: cannot cancel at this stage

## Driver Deliveries

### GET /drivers/deliveries

- Controller: `Drivers::DeliveriesController#index`
- Auth: required (driver token)
- Responses:
  - 200 OK: list of available and assigned deliveries
- Response body:
```json
[
  {
    "id": 1,
    "public_id": "ABC123XYZ",
    "status": "pending",
    "price": 150.00,
    "description": "Package delivery",
    "pickup_address": {
      "city": "Addis Ababa",
      "region": "Addis Ababa"
    },
    "dropoff_address": {
      "city": "Addis Ababa",
      "region": "Addis Ababa"
    },
    "created_at": "2026-02-14T20:17:01Z"
  }
]
```

### GET /drivers/deliveries/:id

- Controller: `Drivers::DeliveriesController#show`
- Auth: required (driver token)
- Responses:
  - 200 OK: full delivery details
  - 404 Not Found: delivery not found or not available
- Response body:
```json
{
  "id": 1,
  "public_id": "ABC123XYZ",
  "status": "pending",
  "price": 150.00,
  "description": "Package delivery",
  "business": {
    "id": 1,
    "name": "Acme Logistics"
  },
  "customer": {
    "id": 1,
    "full_name": "John Doe",
    "phone": "+251911111111"
  },
  "pickup": {
    "address1": "123 Pickup St",
    "city": "Addis Ababa",
    "contact_name": "Sender Name",
    "contact_phone": "+251900000000"
  },
  "dropoff": {
    "address1": "456 Dropoff Ave",
    "city": "Addis Ababa",
    "contact_name": "John Doe",
    "contact_phone": "+251911111111"
  },
  "items": [
    { "name": "Package A", "quantity": 2 }
  ],
  "accepted_at": null,
  "picked_up_at": null,
  "delivered_at": null
}
```

### PATCH /drivers/deliveries/:id/accept

- Controller: `Drivers::DeliveriesController#accept`
- Auth: required (driver token)
- Restrictions:
  - Delivery must be in `pending` status
  - Delivery must not be assigned to another driver
- Flow:
  - Assign driver to delivery
  - Change status to `accepted`
  - Record `accepted_at` timestamp
  - Create delivery event
- Responses:
  - 200 OK: delivery accepted
  - 403 Forbidden: delivery assigned to another driver
  - 404 Not Found: delivery not found
  - 422 Unprocessable Entity: delivery not available

### PATCH /drivers/deliveries/:id/pickup

- Controller: `Drivers::DeliveriesController#pickup`
- Auth: required (driver token)
- Restrictions:
  - Delivery must be in `accepted` status
  - Delivery must be assigned to current driver
- Flow:
  - Change status to `picked_up`
  - Record `picked_up_at` timestamp
  - Create delivery event
- Responses:
  - 200 OK: pickup recorded
  - 403 Forbidden: delivery not assigned to you
  - 404 Not Found: delivery not found
  - 422 Unprocessable Entity: delivery not in accepted state

### PATCH /drivers/deliveries/:id/complete

- Controller: `Drivers::DeliveriesController#complete`
- Auth: required (driver token)
- Restrictions:
  - Delivery must be in `picked_up` or `in_transit` status
  - Delivery must be assigned to current driver
- Flow:
  - Change status to `delivered`
  - Record `delivered_at` timestamp
  - Create delivery event
- Responses:
  - 200 OK: delivery completed
  - 403 Forbidden: delivery not assigned to you
  - 404 Not Found: delivery not found
  - 422 Unprocessable Entity: delivery not ready for completion

## Customer Confirmations (Public)

### GET /customers/confirmation

- Controller: `Customers::ConfirmationsController#show`
- Auth: not required
- Query params:
  - `token` (string, required): tracking token from email
- Responses:
  - 200 OK: delivery preview
  - 404 Not Found: token not found
  - 410 Gone: token expired
- Response body:
```json
{
  "delivery": {
    "public_id": "ABC123XYZ",
    "status": "awaiting_recipient",
    "description": "Package delivery",
    "price": 150.00,
    "business": {
      "id": 1,
      "name": "Acme Logistics"
    },
    "pickup": {
      "address1": "123 Pickup St",
      "city": "Addis Ababa"
    },
    "items": [
      { "name": "Package A", "quantity": 2 }
    ]
  }
}
```

### POST /customers/confirmation/confirm

- Controller: `Customers::ConfirmationsController#confirm`
- Auth: not required
- Body:
  - `token` (string, required): tracking token from email
  - `full_name` (string, required when creating a new customer): customer name
  - `phone` (string, required when creating a new customer): customer phone
  - `email` (string, optional): customer email
  - `password` (string, optional): when provided together with `email`, a sign-in user can be provisioned
  - `dropoff` (object, optional) OR `location` (object, optional):
    - `address1` (string)
    - `address2` (string, optional)
    - `city` (string)
    - `region` (string)
    - `postal_code` (string, optional)
    - `country_code` (string)
    - `latitude` (decimal, optional)
    - `longitude` (decimal, optional)
    - `instructions` (string, optional)
    - `name` (string, optional): for saved location (e.g., "Home", "Office")
- Flow:
  - Resolve customer:
    - If `email` matches an existing customer, reuse it
    - Otherwise create a customer from `full_name`/`phone`/`email`
  - If both `email` and `password` are present:
    - Create or resolve a `User` for the delivery business
    - Ensure `customer` role exists for that business
    - Assign `customer` role to the user (idempotent)
  - If `password` is not provided, confirmation still succeeds (legacy confirmation remains valid)
  - Create customer location (if name provided)
  - Create dropoff stop (when `dropoff` or `location` is provided)
  - Update delivery status to `pending`
  - Create delivery event
- Sign-in after confirmation:
  - Customer users authenticate via existing `POST /auth/sessions` with `email` and `password`
  - No tokens are issued by confirmation itself
- Responses:
  - 200 OK: delivery confirmed
  - 404 Not Found: token not found
  - 410 Gone: token expired
  - 422 Unprocessable Entity: already confirmed or invalid data
- Response body:
```json
{
  "message": "Delivery confirmed successfully",
  "delivery": {
    "public_id": "ABC123XYZ",
    "status": "pending",
    "tracking_url": "https://liyt.com/track/xyz123"
  }
}
```

## Tracking (Public)

### GET /track/:token

- Controller: `TrackingController#show`
- Auth: not required
- URL params:
  - `token` (string, required): tracking token hash
- Restrictions:
  - Token must not be expired
  - Delivery must not be in `awaiting_recipient` status (must be confirmed first)
- Responses:
  - 200 OK: delivery status and tracking info
  - 404 Not Found: token not found or delivery not confirmed
  - 410 Gone: token expired
- Response body:
```json
{
  "delivery": {
    "public_id": "ABC123XYZ",
    "status": "picked_up",
    "price": 150.00,
    "description": "Package delivery",
    "accepted_at": "2026-02-14T21:00:00Z",
    "picked_up_at": "2026-02-14T22:00:00Z",
    "delivered_at": null,
    "business": {
      "name": "Acme Logistics"
    },
    "driver": {
      "full_name": "Sam Rider",
      "phone": "+251922222222",
      "vehicle_type": "motorbike",
      "last_latitude": "9.1450",
      "last_longitude": "40.4897",
      "last_location_at": "2026-02-14T22:05:00Z"
    },
    "pickup": {
      "address1": "123 Pickup St",
      "city": "Addis Ababa",
      "contact_name": "Sender Name"
    },
    "dropoff": {
      "address1": "456 Dropoff Ave",
      "city": "Addis Ababa",
      "contact_name": "John Doe"
    }
  }
}
```
