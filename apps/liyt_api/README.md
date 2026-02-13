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
