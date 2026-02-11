# LIYT API

Rails 8 API app for LIYT. Lives inside `liyt-backend/apps/liyt_api`.

## Auth endpoints

### Staff registration

```bash
curl -sS -X POST "https://YOUR_DOMAIN/auth/registrations" \
  -H "Content-Type: application/json" \
  -d '{"business_name":"Acme Logistics","email":"admin@acme.test","password":"password"}'
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
  -d '{"email":"driver@ride.test","password":"password"}'
```

### Driver login

```bash
curl -sS -X POST "https://YOUR_DOMAIN/drivers/sessions" \
  -H "Content-Type: application/json" \
  -d '{"email":"driver@ride.test","password":"password"}'
```
