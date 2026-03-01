CREATE OR REPLACE PROCEDURE xxx()
    RETURNS STRING
    LANGUAGE PYTHON
    RUNTIME_VERSION = "3.11"
    HANDLER = 'main'
    PACKAGES = ('snowflake-snowpark-python', 'requests', 'pyjwt', 'cryptography')
    EXTERNAL_ACCESS_INTEGRATIONS = (xxx)
    -- SECRETS = ('cred' = xxx)
AS
$$
import requests
import io


def main(session):
    """
    1. 共通処理にてBOXと接続
    2. BOXフォルダ内のアイテムをループで取得
    3. フォルダ内のファイルを取得
    4. ステージへのパスをファイル名ごとに作成
    5. Snowflake ステージにUP
    """
    try:
        # 1
        session.sql("CREATE STAGE IF NOT EXISTS xxx.xxx").collect()
        access_token = session.call('xxx')

        box_folder_id = 'xxx'
        base_stage_dir = '@xxx.xxx/xxx/'
        
        items_url = f"https://api.box.com/2.0/folders/{box_folder_id}/items"
        headers = {'Authorization': f'Bearer {access_token}'}
        items_response = requests.get(items_url, headers=headers, timeout=30)

        items_data = items_response.json()
        uploaded_file_count = 0

        # 2
        for item in items_data.get('entries', []):
            if item['type'] == 'file' and item['name'].endswith('.xlsx'):
                file_id = item['id']
                file_name = item['name']
                
                # 3
                file_content_url = f"https://api.box.com/2.0/files/{file_id}/content"
                file_response = requests.get(file_content_url, headers=headers, timeout=30)
                file_response.raise_for_status()

                # 4
                target_stage_path = f"{base_stage_dir}{file_name}"
                file_stream = io.BytesIO(file_response.content)
                
                # 5
                session.file.put_stream(
                    file_stream, 
                    target_stage_path, 
                    auto_compress=False, 
                    overwrite=True
                )
                uploaded_file_count += 1

        return "Success"  

    except Exception as e:
        err_msg = str(e)
        try:
            session.call('_COMMON.SLACK_NOTICE', 'EXTRACT_BOX_VOS_REPORT', err_msg)
        except:
            pass 
        raise ValueError(err_msg)
$$;
