# Frontend 1: Flutter Client for JWT Authentication

This is a Flutter client for authenticating against `backend1` (Django REST Framework + SimpleJWT).

## Features
- **JWT Login**: `POST /api/token/` to obtain Access and Refresh tokens
- **Protected API Calls**: Calls `GET /api/bookings/` sending `Authorization: Bearer <access_token>`
- **Token Refresh**: Automatically or manually refreshes expired access tokens via `POST /api/token/refresh/`
- **Stateless Token Inspector**: Decodes and displays JWT payload claims directly in UI

## Prerequisites
Make sure `backend1` is running on `http://localhost:8000` (or configured port).

## How to Run

```bash
# 1. Navigate to frontend1
cd frontend1

# 2. Run on Chrome, Windows Desktop, or Mobile
flutter run -d chrome
# or
flutter run -d windows
```
