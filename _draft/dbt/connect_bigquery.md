##### BQ との接続の流れ
サービスアカウント利用の場合
1. IAM 管理からサービスアカウントを作成
2. 権限をいただく
  a. BigQuery ジョブユーザー
  b. BigQuery データ編集者
3. ~/.dbt 階層に profiles.yml を追加（ローカル実行の場合）
4. profiles.yml に json キーのパスとユーザー情報を追加

