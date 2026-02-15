CREATE OR REPLACE PROCEDURE xxx()
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    HANDLER = 'main'
    PACKAGES = ('snowflake-snowpark-python')
AS
$$


def main(session):
    try:
        # スプレッドシート情報
        ss_id = 'xxx'
        sheet_name = 'xxx'
        table_name = 'xxx'
        current_db = session.sql("SELECT CURRENT_DATABASE()").collect()[0][0]
        target_fqn = f"{current_db}.xxx.{table_name}"
        ss_connect_path = f"{current_db}.xxx"
        
        # テーブル作成クエリ
        create_table_sql = f"""
        CREATE OR REPLACE TABLE {target_fqn} (
            PLATFORM VARCHAR(16777216),
            FLAG VARCHAR(16777216),
            TYPE VARCHAR(16777216),
            URL VARCHAR(16777216)
        );
        """
        
        # 共通処理の実行
        session.call(
            ss_connect_path,
            ss_id,
            sheet_name,
            target_fqn,
            create_table_sql
        )
        
        return 'Success'

    except Exception as e:
        err_msg = str(e)
        try:
            slack_path = f"{current_db}.xxx"
            session.call(slack_path, 'xxx', err_msg)
        except:
            pass 
        raise ValueError(err_msg)
$$;
