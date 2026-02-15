### 1. ネットワークルール作成
``` SQL
CREATE OR REPLACE NETWORK RULE <DB名>.<SCHEMA名>.<適切な名称>
    TYPE = 'HOST_PORT'
    MODE = 'EGRESS'
    VALUE_LIST = ('hooks.slack.com');
```

### 2. シークレット作成
``` SQL
CREATE OR REPLACE SECRET <DB名>.<SCHEMA名>.<適切な名称>
    TYPE = GENERIC_STRING
    SECRET_STRING = '<チャンネルのWebhookURL>';
```

### 3. 外部アクセスインテグレーション作成
``` SQL
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION <適切な名称>
    ALLOWED_NETWORK_RULES = (<上記で作成したネットワークルールを完全修飾で>)
    ALLOWED_AUTHENTICATION_SECRETS = (<上記で作成したシークレットを完全修飾で>)
    ENABLED = TRUE;
```
