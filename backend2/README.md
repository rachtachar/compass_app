# Backend 2: Django OpenID Connect (OIDC) Server with django-oidc-provider

This project acts as an OpenID Provider (Authorization Server) implementing OAuth 2.0 and OpenID Connect with RS256 token signing and PKCE support.

## Endpoints
- **Discovery**: `GET /.well-known/openid-configuration`
- **JWKS (Public Keys)**: `GET /jwks/`
- **Authorization**: `GET /authorize/`
- **Token**: `POST /token/`
- **UserInfo**: `GET /userinfo/`
- **Admin**: `GET /admin/`

## Pre-configured Credentials
- **Admin**: `admin` / `admin123`
- **Test User**: `student01` / `test1234`
- **OIDC Client ID**: `flutter-web-client-12345` (Public Client for `http://localhost:50000`)

## How to Run

```bash
# 1. Navigate to backend2
cd backend2

# 2. Run initial setup (if not already done)
uv run python setup_oidc.py

# 3. Start development server
uv run manage.py runserver 8000
```
