#### ネットワークルールの作成
```sql
CREATE OR REPLACE NETWORK RULE  <DB名>.<SCHEMA名>.<適切な名称>
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('TableauServer の URL');
```

#### シークレットの作成
```sql
CREATE OR REPLACE SECRET <DB名>.<SCHEMA名>.<適切な名称>
  TYPE = GENERIC_STRING
  SECRET_STRING = '{
    "username": "<ユーザー名ペースト>",
    "password": "<パスワードペースト>"
  }';
```

#### 外部アクセス統合の作成
```sql
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION <適切な名称>
    ALLOWED_NETWORK_RULES = (<上記で作成したネットワークルールを完全修飾名で>)
    ALLOWED_AUTHENTICATION_SECRETS = (<上記で作成したシークレットを完全修飾名で>)
    ENABLED = TRUE;
```
