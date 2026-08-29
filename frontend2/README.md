# Frontend 2: Flutter Web OpenID Connect Client

This is a Flutter Web client that authenticates against `backend2` (`django-oidc-provider`) using the standard **OAuth 2.0 / OpenID Connect Authorization Code Flow with PKCE**.

## Features
- **OIDC Discovery**: Discovers endpoints dynamically from `http://localhost:8000/.well-known/openid-configuration`
- **Authorization Code + PKCE**: Uses `openid_client` browser flow for secure public client authentication
- **UserInfo & ID Token**: Fetches and inspects claims (`sub`, `name`, `email`, `preferred_username`, `iss`, `aud`, `exp`)
- **RS256 Signature Verification**: ID Token verified against backend public JWKS

## Prerequisites
Make sure `backend2` is running on `http://localhost:8000`.

## How to Run

```bash
# 1. Navigate to frontend2
cd frontend2

# 2. Run on Google Chrome at fixed port 50000
flutter run -d chrome --web-port 50000
```

> **Note**: The web port must be fixed at `50000` to match the registered redirect URI in `backend2` (`http://localhost:50000`).
