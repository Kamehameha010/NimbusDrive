import json
import jwt
import requests
from typing import Any
from settings import settings


SUPABASE_URL = settings.SUPABASE_URL
SUPABASE_ANON_KEY = settings.SUPABASE_ANON_KEY
SUPABASE_JWT_SECRET = settings.SUPABASE_JWT_SECRET


def handler(event: dict[str, Any], context):
    token = event.get("authorizationToken")
    if not token:
        return generate_policy(event=event, reason="Token is missing")

    if token.startswith("Bearer "):
        token = token.replace("Bearer ", "")

    payload = None

    try:
        payload = verify_token(token, algorithms= ["HS256"]) 

    except (jwt.InvalidAudienceError, jwt.InvalidSignatureError) as e:
        try:
            payload = _verify_rs256_token(token)
        except Exception as e:
            return generate_policy(event=event, reason= f"Invalid token: {e}")

    user_id = payload.get("sub")
    if not user_id:
        return generate_policy(event=event, reason="Token does not contain user_id (sub)")
    return generate_policy(event, user_id=user_id)


def verify_token(token: str,algorithms: list[str],audience: str = "authenticated",options: dict[str, Any] = None,public_key: Any = None) -> dict[str, Any]:

    key = public_key if public_key is not None else SUPABASE_JWT_SECRET

    if key is None:
        raise ValueError("Missing key for JWT verification")

    return jwt.decode(
        token,
        key,
        algorithms=algorithms,
        audience=audience,
        options=options,
    )


def _verify_rs256_token(token: str) -> dict[str, any]:
    """Validates an RS256 token using Supabase’s public JWKS keys"""
    jwks_url = f"{SUPABASE_URL}/auth/v1/.well-known/jwks.json"
    headers = {"apikey": SUPABASE_ANON_KEY}

    res = requests.get(jwks_url, headers=headers)
    res.raise_for_status()
    jwks = res.json()

    unverified_header = jwt.get_unverified_header(token)
    kid = unverified_header.get("kid")

    key = next((k for k in jwks["keys"] if k["kid"] == kid), None)
    if not key:
        raise Exception(f"No public key found with kid '{kid}'")

    public_key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(key))

    return verify_token(token, public_key=public_key, algorithms=["RS256"], options={"verify_exp": True})

def generate_policy(event: dict[str, Any], reason:str|None=None, user_id:str|None=None) -> dict[str, Any]:
    if user_id:
        context = {"user": user_id}
        principalId = user_id
        effect = "Allow"
        resource= event["methodArn"]
    else:
        context = {"error": reason}
        principalId = "unauthorized"
        effect = "Deny"
        resource= event.get("methodArn", "*")

    return {
        "principalId": principalId,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": resource
                }
            ],
        },
        "context": context,
    }