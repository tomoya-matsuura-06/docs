### 1. ネットワークルール作成
``` SQL
CREATE OR REPLACE NETWORK RULE <DB名>.<SCHEMA名>.<適切な名称>
    TYPE = 'HOST_PORT'
    VALUE_LIST = ('api.box.com', 'dl.boxcloud.com', 'upload.box.com')
    MODE = 'EGRESS';
```

### 2. シークレット作成
``` SQL
CREATE OR REPLACE SECRET <DB名>.<SCHEMA名>.<適切な名称>
  TYPE = GENERIC_STRING
  SECRET_STRING = '{
    "boxAppSettings": {
      "clientID": "<クライアントIDペースト>",
      "clientSecret": "<クライアントシークレットペースト>",
      "appAuth": {
        "publicKeyID": "<パブリックキーIDペースト>",
        "privateKey": "<秘密鍵ペースト>",
        "passphrase": "<パスフレーズペースト>"
      }
    },
    "enterpriseID": "<エンタープライズIDペースト>"
  }';
```

### 3. 外部アクセスインテグレーション作成
``` SQL
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION <適切な名称>
    ALLOWED_NETWORK_RULES = (<上記で作成したネットワークルールを完全修飾名で>)
    ALLOWED_AUTHENTICATION_SECRETS = (<上記で作成したシークレットを完全修飾名で>)
    ENABLED = TRUE;
```
