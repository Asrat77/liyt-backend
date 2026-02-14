# LIYT API

Rails 8 API app for LIYT. Lives inside `liyt-backend/apps/liyt_api`.

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

### 2. Recipient confirms delivery (via email link)

```bash
# Preview delivery details
curl -sS -X GET "https://YOUR_DOMAIN/customers/confirmation?token=<TOKEN_FROM_EMAIL>"

# Confirm with dropoff location
curl -sS -X POST "https://YOUR_DOMAIN/customers/confirmation" \
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
