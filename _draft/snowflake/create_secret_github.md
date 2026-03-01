### 1. シークレット作成
``` SQL
CREATE OR REPLACE SECRET <DB名>.<SCHEMA名>.<適切な名称>
    TYPE = password
    USERNAME = '<GitHubユーザー名>'
    PASSWORD = '<Generate Tokenで作成したPATペースト>';
```

### 2. APIインテグレーション作成
``` SQL
CREATE OR REPLACE API INTEGRATION <適切な名称>
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('<リポジトリのURL>')
    ALLOWED_AUTHENTICATION_SECRETS = (<上記で作成したシークレットを完全修飾名で>)
    ENABLED = TRUE;
```

### 3. リポジトリクローン作成
``` SQL
CREATE OR REPLACE GIT REPOSITORY <適切な名称>
    ORIGIN = '<リポジトリのURL>' 
    API_INTEGRATION = <上記で作成したインテグレーション> 
    GIT_CREDENTIALS = <上記で作成したシークレットを完全修飾名で>;
```
※ SNOWFLAKE側にローカルリポジトリを保持し、リモートリポジトリと同期を行うことでGIT管理を可能にします。
