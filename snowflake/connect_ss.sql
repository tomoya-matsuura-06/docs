CREATE OR REPLACE PROCEDURE xxx(
    P_SS_ID STRING,
    P_SHEET_NAME STRING,
    P_TARGET_TABLE_FQN STRING,
    P_CREATE_TABLE_SQL STRING 
)
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    HANDLER = 'main'
    PACKAGES = ('snowflake-snowpark-python', 'pandas', 'gspread', 'google-auth')
    EXTERNAL_ACCESS_INTEGRATIONS = (xxx)
    SECRETS = ('google_creds' = xxx)
AS
$$
import pandas as pd
import gspread
import _snowflake
import json
from google.oauth2.credentials import Credentials


def main(session, p_ss_id, p_sheet_name, p_target_table_fqn, p_create_table_sql):
    """スプレッドシートとの接続からテーブル書き出しまで
    Args:
        session {str}: Actionsファイルで定義している SNOWFLAKE との接続情報
        p_ss_id {str}: スプレッドシートのID
        p_sheet_name {str}: シート名
        p_target_table_fqn {str}: インサート先のテーブル
        p_create_table_sql {str}: 作成するテーブル名
    Returns:
        なし。処理を実行
    """
    try:
        # 引数を元にテーブル作成
        session.sql(p_create_table_sql).collect()

        # Google 認証
        creds_json_string = _snowflake.get_generic_secret_string('google_creds')
        creds_info = json.loads(creds_json_string)
        creds = Credentials(
            None, 
            refresh_token=creds_info['refresh_token'],
            token_uri='https://oauth2.googleapis.com/token',
            client_id=creds_info['client_id'],
            client_secret=creds_info['client_secret']
        )
        client = gspread.authorize(creds)
        
        # スプレッドシートからデータを抽出
        spreadsheet = client.open_by_key(p_ss_id)
        worksheet = spreadsheet.worksheet(p_sheet_name)
        records = worksheet.get_all_records()

        # データをメモリに展開
        df = pd.DataFrame(records)
        
        #  データが空白であれば NUll、カラム名は大文字と _ に変換
        df = df.astype(str)
        df = df.replace('', None)
        df.columns = [str(col).upper().replace(' ', '_') for col in df.columns]
        
        snowpark_df = session.create_dataframe(df)
        
        # テーブルにデータをインサート
        snowpark_df.write.mode("overwrite").save_as_table(p_target_table_fqn)
        
        return "Success"

    except Exception as e:
        err_msg = str(e)
        try:
            session.call(
                'SLACK_NOTICE', 
                'SS_CONNECT',
                err_msg
            )
        except:
            pass 
        raise ValueError(err_msg)
$$;
