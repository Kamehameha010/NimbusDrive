import os
import json
import jwt
import requests


SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_ANON_KEY = os.environ.get("SUPABASE_ANON_KEY")
SUPABASE_JWT_SECRET = os.environ.get("SUPABASE_JWT_SECRET")

EXPECTED_AUD = "authenticated"

def handler(event, context):
    token = event.get("authorizationToken", "")
    if not token:
        return generate_policy(event=event, reason="Falta token de autorización")

    if token.startswith("Bearer "):
        token = token.replace("Bearer ", "")

    payload = None

    try:
        payload = jwt.decode(
            token,
            SUPABASE_JWT_SECRET,
            algorithms=["HS256"],
            audience=EXPECTED_AUD
        )
    except (jwt.InvalidAudienceError, jwt.InvalidSignatureError, Exception) as e:
        try:
            payload = _verify_rs256_token(token)
        except Exception as e:
            return generate_policy(event=event, reason= f"Token inválido: {e}")

    user_id = payload.get("sub")
    if not user_id:
        return generate_policy(event=event, reason="Token no contiene user_id (sub)")
    return generate_policy(event, user_id=user_id)



def _verify_rs256_token(token):
    """Valida un token RS256 usando las claves públicas JWKS de Supabase"""
    jwks_url = f"{SUPABASE_URL}/auth/v1/.well-known/jwks.json"
    headers = {"apikey": SUPABASE_ANON_KEY}

    res = requests.get(jwks_url, headers=headers)
    res.raise_for_status()
    jwks = res.json()

    unverified_header = jwt.get_unverified_header(token)
    kid = unverified_header.get("kid")

    key = next((k for k in jwks["keys"] if k["kid"] == kid), None)
    if not key:
        raise Exception(f"No se encontró clave pública con kid '{kid}'")

    public_key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(key))

    return jwt.decode(
        token,
        public_key,
        algorithms=["RS256"],
        audience=EXPECTED_AUD,
        options={"verify_exp": True}
    )

def generate_policy(event, reason=None, user_id=None):
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