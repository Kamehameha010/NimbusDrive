# Lambda Authorizer

> Custom API Gateway Lambda authorizer for Supabase JWT validation.

Supports both HS256 (symmetric) and RS256 (asymmetric via JWKS endpoint) token verification.

---

## Features

- **HS256 Verification** — Validates tokens signed with Supabase JWT secret
- **RS256 Verification** — Fetches public keys from Supabase JWKS endpoint, with automatic fallback from HS256
- **SSM Parameter Store** — Reads configuration from AWS SSM under `/nimbus/supabase/*`

---

## Endpoints (API Gateway Integration)

Applied as an authorizer on API Gateway routes. Expects the `Authorization: Bearer <token>` header.

---

## How It Works

1. Extract token from `authorizationToken` event field
2. Strip `Bearer ` prefix
3. Attempt HS256 verification using Supabase JWT secret
4. If HS256 fails with audience or signature error, fall back to RS256 via JWKS
5. Extract `sub` claim as user identifier
6. Return IAM policy: `Allow` with user ID in context, or `Deny` with error reason

---

## Configuration

| SSM Parameter Path | Description |
|--------------------|-------------|
| `/nimbus/supabase/supabase_url` | Supabase project URL |
| `/nimbus/supabase/supabase_anon_key` | Supabase anon/public key |
| `/nimbus/supabase/jwt_secret` | Supabase JWT secret (for HS256) |

---

## Deployment

Deployed via Terraform as a ZIP-based Lambda:

```bash
cd iac/prod
terraform apply
```
