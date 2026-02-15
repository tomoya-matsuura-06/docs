CREATE OR REPLACE PROCEDURE xxx()
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    HANDLER = 'main'
    PACKAGES = ('snowflake-snowpark-python','requests', 'pyjwt', 'cryptography')
    EXTERNAL_ACCESS_INTEGRATIONS = (xxx)
    SECRETS = ('cred' = xxx)
AS
$$
import _snowflake
import requests
import json
import time
import jwt
import uuid
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.serialization import load_pem_private_key


def main(session):
    """BoxAPI でJWT 認証を行い、アクセストークンを返す。
    Args:
        session: Actions ファイルで定義している SNOWFLAKE との接続情報
    Returns:
        access_token: BOX との接続情報を返す
    """
    # シークレット取得（事前に Snowflake にシークレット作成）
    secret_data = _snowflake.get_generic_secret_string('cred')
    secret_json = json.loads(secret_data)

    # JSON 構成を読み取る
    box_settings = secret_json['boxAppSettings']
    client_id = box_settings['clientID']
    client_secret = box_settings['clientSecret']
    enterprise_id = secret_json['enterpriseID']
    app_auth = box_settings['appAuth']
    public_key_id = app_auth['publicKeyID']
    private_key = app_auth['privateKey']
    passphrase = app_auth['passphrase']

    # 秘密キーを複合化する
    private_key_obj = load_pem_private_key(
        data=privateKey.encode('utf8'),
        password=passphrase.encode('utf8')
        backend=default_backend()
    )

    # JWT アサーションを作成する
    authentication_url = 'https://api.box.com/oauth2/token'
    now = int(time.time())
    claims = {
        'iss': client_id,
        'sub': enterprise_id,
        'box_sub_type': 'enterprise',
        'aud': authentication_url,
        'jti': str(uuid.uuid4()),
        'iat': now - 30,
        'exp': now + 60
    }
    assertion = jwt.encode(
        claims,
        private_key_obj,
        algorithm='RS256',
        headers={
            'kid': public_key_id
        }
    )

    # アクセストークンをリクエスト
    params = {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': assertion,
        'client_id': client_id,
        'client_secret': client_secret
    }
    token_response = requests.post(authentication_url, params, timeout=30)

    if token_response.status_code == 200:
        return token_response.json().get('access_token')
    else:
        raise Exception(f"error: {token_response.status_code}: {token_response.text[:150]}")
$$
