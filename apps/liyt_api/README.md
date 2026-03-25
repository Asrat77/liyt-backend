# LIYT API

Rails 8 API app for LIYT. Lives inside `liyt-backend/apps/liyt_api`.

## Local CI quality gates

Run these from `liyt-backend/apps/liyt_api` to mirror CI checks:

```bash
bundle exec rubocop
bundle exec brakeman -q -w2
bundle exec bundle-audit check --update --database tmp/ruby-advisory-db
bin/rails db:prepare
bin/rails test
ENABLE_BULLET=1 BULLET_SERIAL_TESTS=1 bin/rails test test/integration/bullet_query_efficiency_test.rb
COVERAGE=1 bin/rails test
```

Coverage reports are written to `apps/liyt_api/coverage/` when `COVERAGE=1` is set.

## Auth endpoints

### Staff registration

```bash
curl -sS -X POST "https://YOUR_DOMAIN/auth/registrations" \
  -H "Content-Type: application/json" \
  -d '{"business_name":"Acme Logistics","support_email":"support@acme.test","email":"admin@acme.test","password":"password"}'
```

### Staff login

```bash
curl -sS -X POST "https://YOUR_DOMAIN/auth/sessions" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@acme.test","password":"password"}'
```

### Driver registration

```bash
curl -sS -X POST "https://YOUR_DOMAIN/drivers/registrations" \
  -H "Content-Type: application/json" \
  -d '{"email":"driver@ride.test","password":"password","full_name":"Sam Rider","phone":"+251911111111","vehicle_type":"motorbike","license_number":"LIC-123"}'
```

### Driver login

```bash
curl -sS -X POST "https://YOUR_DOMAIN/drivers/sessions" \
  -H "Content-Type: application/json" \
  -d '{"email":"driver@ride.test","password":"password"}'
```

### Customer registration

```bash
curl -sS -X POST "https://YOUR_DOMAIN/customers/registrations" \
  -H "Content-Type: application/json" \
  -d '{"email":"customer@acme.test","password":"password","full_name":"John Doe","phone":"+251911111111"}'
```

### Customer login

```bash
curl -sS -X POST "https://YOUR_DOMAIN/customers/sessions" \
  -H "Content-Type: application/json" \
  -d '{"email":"customer@acme.test","password":"password"}'
```

### Customer token refresh

```bash
curl -sS -X POST "https://YOUR_DOMAIN/customers/sessions/refresh" \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"<CUSTOMER_REFRESH_TOKEN>"}'
```

### Customer profile

```bash
curl -sS -X GET "https://YOUR_DOMAIN/customers/me" \
  -H "Authorization: Bearer <CUSTOMER_TOKEN>"
```

## Delivery Flow

### 1. Business creates delivery

```bash
curl -sS -X POST "https://YOUR_DOMAIN/deliveries" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <BUSINESS_TOKEN>" \
  -d '{
    "description": "Package delivery to John",
    "price": 150.50,
    "recipient_email": "john@example.com",
    "pickup": {
      "address1": "123 Business St",
      "city": "Addis Ababa",
      "region": "Addis Ababa",
      "country_code": "ET",
      "contact_name": "Acme Logistics",
      "contact_phone": "+251911000000"
    },
    "items": [
      {"name": "Documents", "quantity": 1},
      {"name": "Package", "quantity": 2}
    ]
  }'
```

### 1b. Integration creates delivery with API key

`POST /deliveries` also supports API-key auth for partner integrations.

- Header: `X-API-Key: <PLAINTEXT_KEY>`
- Required scope on key: `deliveries:write`
- Pickup resolution: request `pickup` values override `business_settings` defaults
- If required pickup fields are unresolved after merge, API returns `422` with `pickup_invalid`

```bash
curl -sS -X POST "https://YOUR_DOMAIN/deliveries" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <PLAINTEXT_KEY>" \
  -d '{
    "description": "API-key delivery",
    "recipient_email": "john@example.com",
    "items": [
      {"name": "Documents", "quantity": 1}
    ]
  }'
```

Example `422` when pickup data is incomplete and no defaults exist:

```json
{
  "error": "pickup_invalid",
  "missing_fields": ["address1", "city", "region", "country_code", "contact_name", "contact_phone"]
}
```

### 2. Recipient confirms delivery (via email link)

```bash
# Preview delivery details
curl -sS -X GET "https://YOUR_DOMAIN/customers/confirmation?token=<TOKEN_FROM_EMAIL>"

# Confirm with dropoff location
curl -sS -X POST "https://YOUR_DOMAIN/customers/confirmation/confirm" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "<TOKEN_FROM_EMAIL>",
    "full_name": "John Doe",
    "phone": "+251911111111",
    "email": "john@example.com",
    "dropoff": {
      "address1": "456 Home St",
      "city": "Addis Ababa",
      "region": "Addis Ababa",
      "country_code": "ET",
      "instructions": "Call when arrived"
    }
  }'
```

Optional account bootstrap during confirmation:

- Include both `email` and `password` in the confirm request to provision (or resolve) a user account and assign the `customer` role for that delivery business.
- If `password` is omitted, confirmation still works (legacy behavior).
- Customer signin can use `POST /customers/sessions` with `email` and `password`.

### 3. Driver views available deliveries

```bash
curl -sS -X GET "https://YOUR_DOMAIN/drivers/deliveries" \
  -H "Authorization: Bearer <DRIVER_TOKEN>"
```

### 4. Driver accepts delivery

```bash
curl -sS -X PATCH "https://YOUR_DOMAIN/drivers/deliveries/<DELIVERY_ID>/accept" \
  -H "Authorization: Bearer <DRIVER_TOKEN>"
```

### 5. Driver marks as picked up

```bash
curl -sS -X PATCH "https://YOUR_DOMAIN/drivers/deliveries/<DELIVERY_ID>/pickup" \
  -H "Authorization: Bearer <DRIVER_TOKEN>"
```

### 6. Driver completes delivery

```bash
curl -sS -X PATCH "https://YOUR_DOMAIN/drivers/deliveries/<DELIVERY_ID>/complete" \
  -H "Authorization: Bearer <DRIVER_TOKEN>"
```

### 7. Customer tracks delivery (public)

```bash
curl -sS -X GET "https://YOUR_DOMAIN/track/<TRACKING_TOKEN>"
```

## Business Locations

### Create business location

```bash
curl -sS -X POST "https://YOUR_DOMAIN/business_locations" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <BUSINESS_TOKEN>" \
  -d '{
    "name": "Main Warehouse",
    "address1": "123 Main St",
    "city": "Addis Ababa",
    "region": "Addis Ababa",
    "country_code": "ET",
    "latitude": 9.1450,
    "longitude": 40.4897
  }'
```

### List business locations

```bash
curl -sS -X GET "https://YOUR_DOMAIN/business_locations" \
  -H "Authorization: Bearer <BUSINESS_TOKEN>"
```

## Business pickup defaults

Business admins can manage default pickup fields used by `POST /deliveries`.

### Update defaults

```bash
curl -sS -X PATCH "https://YOUR_DOMAIN/business_settings" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <BUSINESS_TOKEN>" \
  -d '{
    "pickup_address1": "Warehouse 9",
    "pickup_city": "Adama",
    "pickup_region": "Oromia",
    "pickup_country_code": "ET",
    "pickup_contact_name": "Dispatch",
    "pickup_contact_phone": "+251922222222",
    "pickup_instructions": "Use loading bay"
  }'
```

## API key lifecycle

All API key management routes use user JWT auth (not API-key auth):

- `GET /api_keys` (staff/admin)
- `GET /api_keys/:id` (staff/admin)
- `POST /api_keys` (admin)
- `PATCH /api_keys/:id/revoke` (admin)
- `PATCH /api_keys/:id/rotate` (admin)

### Create API key (admin)

```bash
curl -sS -X POST "https://YOUR_DOMAIN/api_keys" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <BUSINESS_TOKEN>" \
  -d '{
    "name": "Orders Integration",
    "scopes": ["deliveries:write"]
  }'
```

The response includes `plaintext_key` once. Store it immediately.

### Rotate API key (admin)

```bash
curl -sS -X PATCH "https://YOUR_DOMAIN/api_keys/<KEY_ID>/rotate" \
  -H "Authorization: Bearer <BUSINESS_TOKEN>"
```

Rotate revokes the old key and returns a new one-time `plaintext_key`.
