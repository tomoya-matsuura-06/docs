##### Snowflake 内で全て SQL ではなく Python ファイルと組み合わせて実行する方法
1. Python ファイルを作成
2. プロシージャを作成
3. Tasks にて実行

---

##### プロシージャの組み合わせ方
```sql
CREATE OR REPLACE PROCEDURE xxx()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = (
    'snowflake-snowpark-python',
    'pandas',
    'gspread',
    'google-auth',
    'google-api-python-client',
    'tableauserverclient',
    'requests',
    'emoji'
)
IMPORTS = (
    '@{{ SNOWFLAKE_DATABASE }}.GIT_SYNC."xxx"/branches/main/libraries/xxx.py',
    '@{{ SNOWFLAKE_DATABASE }}.GIT_SYNC."xxx"/branches/{{ GIT_BRANCH }}/src/xxx',
)
HANDLER = 'main.main'
EXTERNAL_ACCESS_INTEGRATIONS = (
    xxx
)
SECRETS = (
    'secrets' = xxx
);
```
