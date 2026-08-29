# Backend 1: Django REST Framework with SimpleJWT Authentication

This backend provides JWT-based stateless authentication and protected REST APIs.

## Features
- **Obtain Token (Login)**: `POST /api/token/`
- **Refresh Token**: `POST /api/token/refresh/`
- **Protected Bookings API**: `GET /api/bookings/`, `POST /api/bookings/`
- **Protected User Profile**: `GET /api/profile/`
- **Health Check**: `GET /api/`
- **Django Admin**: `GET /admin/`

## Pre-seeded Credentials
- **Test User**: `student01` / `test1234`
- **Superuser Admin**: `admin` / `admin123`

## How to Run

```bash
# 1. Navigate to backend1
cd backend1

# 2. Run the development server (default port 8000)
uv run manage.py runserver 8000

# Or with custom port (e.g. 8001)
uv run manage.py runserver 8001
```

## Testing with curl / HTTPie
```bash
# Obtain JWT tokens
curl -X POST http://localhost:8000/api/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "student01", "password": "test1234"}'

# Access protected endpoint
curl http://localhost:8000/api/bookings/ \
  -H "Authorization: Bearer <access_token>"
```
