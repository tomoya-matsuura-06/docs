CREATE OR REPLACE PROCEDURE xxx(
    TARGET_PROC_NAME STRING,
    ERR_MSG STRING
)
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    HANDLER = 'main'
    PACKAGES = ('snowflake-snowpark-python', 'requests')
    EXTERNAL_ACCESS_INTEGRATIONS = (xxx)
    SECRETS = ('webhook_url' = xxx)
AS
$$
import json
import requests
import _snowflake


def main(session, target_proc_name, err_msg):
    """各プロシージャから呼び出し SLACK への通知を送る
    Args:
        session: Actions ファイルで定義している SNOWFLAKE との接続情報
        target_proc_name {str}: 対象となるプロシージャ
        err_msg {str}: エラー内容
    Retuens:
        なし。処理を実行
    """
    # SNOWFLAKE 内に格納してある Webhook_url を呼び出す
    slack_webhook_url = _snowflake.get_generic_secret_string('webhook_url')
    payload = {
        "text": (
            "Snowflake workflow error\n"
            f"担当: <xxx> \n"
            f"プロシージャ: `{target_proc_name}` \n"
            f"エラー内容: ```{err_msg}```"
        )
    }

    req = requests.post(
        slack_webhook_url,
        data=json.dumps(payload),
        headers={'Content-Type': 'application/json'},
        timeout=10
    )
    req.raise_for_status()

    return "Success"
$$;
