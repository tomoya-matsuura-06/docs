### 1. ネットワークルール作成
``` SQL
CREATE OR REPLACE NETWORK RULE <DB名>.<SCHEMA名>.<適切な名称>
    TYPE = 'HOST_PORT'
    VALUE_LIST = (
        'sheets.googleapis.com', 
        'oauth2.googleapis.com', 
        'www.googleapis.com',
        'accounts.google.com'
    )
    MODE = 'EGRESS';
```

### 2. シークレット作成
``` SQL
CREATE OR REPLACE SECRET <DB名>.<SCHEMA名>.<適切な名称>
    TYPE = GENERIC_STRING
    SECRET_STRING = '{
        "client_id":"<xxx>",
        "client_secret":"<xxx>",
        "refresh_token":"<xxx>'
    }';
```

### 3. 外部アクセスインテグレーション作成
``` SQL
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION <適切な名称>
    ALLOWED_NETWORK_RULES = (<上記で作成したネットワークルールを完全修飾名で>)
    ALLOWED_AUTHENTICATION_SECRETS = (<上記で作成したシークレットを完全修飾名で>)
    ENABLED = TRUE;
```
