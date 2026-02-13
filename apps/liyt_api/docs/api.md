# API Routes

This document lists all routes defined in `apps/liyt_api/config/routes.rb`, with request/response bodies, restrictions, and flows based on current controllers and tests.

## Shared behavior

- Auth header: `Authorization: Bearer <access_token>`
- Access tokens: JWT, `typ` of `user` or `driver`
- Refresh tokens: long-lived and stored as a hash; provided only at issue/refresh time
- Default auth: all routes require auth unless explicitly noted below
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
