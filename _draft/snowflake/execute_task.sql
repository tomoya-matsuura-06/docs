-- ルートタスク
CREATE OR REPLACE TASK xxx
    WAREHOUSE = xxx
    SCHEDULE = 'USING CRON 30 13 * * * Asia/Tokyo'
AS
     SELECT 'xxx';

-- 順次タスク
CREATE OR REPLACE TASK xxx
    WAREHOUSE = xxx
    USER_TASK_TIMEOUT_MS = 1500000 -- ~25分
    AFTER xxx
AS
    CALL {{ SNOWFLAKE_DATABASE }}.{{ SCHEMA_RAW_DATA }}.xxx();


-- タスクの有効化（子から先に）
ALTER TASK xxx RESUME;
ALTER TASK xxx RESUME;
