### Q9 出力を変えずにORをANDへ

ORよりANDとNOTを使用でインデックスが効率的に利用され処理が早くなる。（パフォーマンスチューニング）

問題に対して「逆の条件を考え」、「逆の条件を否定」することで出力を変えずにORをANDへ変換

- `=` の否定は `!=` (または `<>`)
- `>` の否定は **`<=`**
- `<` の否定は **`>=`**
- `>=` の否定は **`<`**
- `<=` の否定は **`>`**

### Q10 末尾が1のものだけを抽出

pandasであればstr.endwith(’1’)を使用、SQLでは使用できない。

LIKEとワイルドカードでパターンマッチさせる。

```sql
WHERE
	cusotmer_id LIKE '%1'
```

### Q13 先頭がA~Fで始まるものだけ抽出

- %が曖昧検索を実行できる
- 先につけると最後尾一致、後につけると先頭一致

```sql
WHERE
    status_cd ~ '^[A:F]'
```

- ~は、正規表現に一致するという意味。左辺が右辺と一致するか
- ^は、~で始まるを意味する。文字列の先頭に一致。
- $は、文字列の末尾に一致。

### Q16 フォーマット一致

- 全一致は先頭をキャレット、後方をダラーで囲う
- []にパターンを、{}に文字数を

```sql
SELECT
    *
FROM
    store
WHERE
    tel_no ~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$'
LIMIT
    10
```

### Q19 同一順位のランク付け

- ランク関数は単独で使用できない
- OVER句と一緒に使用する
- OVER句はウィンドウ関数

```sql
SELECT
    customer_id,
    amount, 
    RANK() OVER (ORDER BY amount DESC) AS amount_rank
FROM
    receipt
LIMIT
    10
```

- 同一順位をなくしてユニークな順位にしたい際は
- row_number()で可。連番を振るための関数

### Q28 中央値

- median関数が使用できない
- PERCENTILE_CONT(値)：指定したパーセントタイルの値を引数にとり、データを返す。
- OVER句ではなく、WITHIN GROPU(ORDER BY カラム)でソート順を指定する必要がある。

```sql
SELECT
    store_cd,
    PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY amount) AS median_amount
FROM
    receipt
GROUP BY
    store_cd
ORDER BY
    median_amount DESC
LIMIT
    5;
```

### Q29 最頻値

- mode使用
- `WITHIN GROUP`は順序付けられたグループの中で、どの値が最頻値かを判断する
- SQLの標準で「Ordered-Set Aggregate Functions（順序指定集計関数）」。
- 文法として決まっている

```sql
SELECT
    store_cd,
    MODE() WITHIN GROUP(ORDER BY product_cd) AS mode_product_cd
FROM
    receipt
GROUP BY
    store_cd
LIMIT
    10;
```

### Q30 分散

- var_popを使用

### Q31 標準偏差

- STDDEV_SAMP

### Q32 25%刻み

- PERCENTILE_CONTを使用
- WITHIN GROPU(ORDER BY カラム)でソート順を指定

```sql
SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY amount) AS amount_25per,
    PERCENTILE_CONT(0.50) WITHIN GROUP(ORDER BY amount) AS amount_50per,
    PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY amount) AS amount_75per,
    PERCENTILE_CONT(1.0) WITHIN GROUP(ORDER BY amount) AS amount_100per
FROM receipt
```

### Q35 スカラーサブクエリ

- ウィンドウ関数を使用することが最もパフォーマンスに優れている可能性が高い
    - DBの内部的な動きとして、中間データへのアクセスが1回で済む
    - データ再読み込みでなく、メモリ上で計算を実行
    - **データスキャン**が少なくなるため効率的
- サブクエリが敬遠されるのは相関サブクエリの場合
    - 一行ごとにサブクエリが実行されるケース（定説）
- スカラーサブクエリであればパフォーマンスに優れている
    - DBにのオプティマイザ（処理に最適化）
    - 最初に1回実行するのみ
    - 行ごとに実行されるわけではない

```sql
%%sql
WITH customer_amount AS (
    SELECT
        customer_id,
        SUM(amount) AS sum_amount
    FROM
        receipt
    WHERE
        customer_id NOT LIKE 'Z%'
    GROUP BY
        customer_id
)

SELECT
    customer_id,
    sum_amount
FROM
    customer_amount
WHERE
    sum_amount >= (
        SELECT
            AVG(sum_amount)
        FROM
            customer_amount
    )
LIMIT
    10
;
```

### Q39 完全外部結合

- `FULL OUTER JOIN`を使用する
- どちらのテーブルにも存在する、片方にしか存在しない含め全て表示したいとき

### Q40 直積

- `CROSS JOIN`を使用する
- 片方のデーブル全ての行と、もう片方のテーブル全ての行とを総当たりで組み合わせる

### Q41 一日前と売上比較

- WITH句で先に合計を計算した型を作成
- LAG関数は、現在の行から指定された前の行数を取得
- ウィンドウ関数のOVERで、適用範囲や順序を決める
- 明示的に前日の日付もカラムとして表示

```sql
WITH sales_amount_by_date AS (
    SELECT
        sales_ymd,
        sum(amount) AS sum_amount
    FROM
        receipt
    GROUP BY
        sales_ymd
    ORDER BY
        sales_ymd
)   

SELECT
    sales_ymd,
    LAG(sales_ymd, 1) OVER(ORDER BY sales_ymd) AS lag_ymd,
    sum_amount,
    sum_amount - LAG(sum_amount, 1) OVER(ORDER BY sales_ymd) AS diff_amount
FROM
    sales_amount_by_date
LIMIT
    10
;
```

### Q43 クロス集計

- **CREATE TABLE**の使用
- TABLE作成の中でWITH句を2個定義すると、結合操作なく合体される
- TRUNC関数の使用。少数部分の切り捨て。
- 何かビニングする際はSQLでもPandasでも基本的には**小数点切り捨て操作**を行う
- 性別をCASE文で分岐
- 流れ
    - テーブル作成 → WITH句で2つのテーブル要素を作成 → 最後にテーブルごと全呼び出し

```sql
CREATE TABLE sales_summary AS
    WITH gender_era_amount AS (
        SELECT
            TRUNC(age / 10) * 10 AS era,
            c.gender_cd,
            sum(r.amount) AS sum_amount
        FROM
            receipt AS r
        INNER JOIN customer AS c
            ON r.customer_id = c.customer_id
        GROUP BY
            era,
            c.gender_cd
    )
    SELECT
        era,
        SUM(CASE WHEN gender_cd = '0' THEN sum_amount END) AS male,
        SUM(CASE WHEN gender_cd = '1' THEN sum_amount END) AS female,
        SUM(CASE WHEN gender_cd = '9' THEN sum_amount END) AS unknown
    FROM
        gender_era_amount
    GROUP BY
        era
    ORDER BY
        era
;
SELECT
    *
FROM
    sales_summary
;
```

### Q44 UNION

- データを縦持ちに変換
- ３つのデータを縦結合するのでカラム名は統一しないといけない

```sql
SELECT
    era,
    '00' AS gender_cd,
    male AS amount
FROM
    sales_summary

UNION ALL

SELECT
    era,
    '01' AS gender_cd,
    female AS amount
FROM
    sales_summary

UNION ALL

SELECT
    era,
    '99' AS gender_cd,
    unknown AS amount
FROM
    sales_summary
```

### Q45 日時変換（日付型 → 文字列）

- `TO_CHAR`を使用
- 引数にカラムと変換したい形式を指定

```sql
SELECT
    customer_id,
    TO_CHAR(birth_day, 'YYYYMMDD')
FROM
    customer
LIMIT
    10
```

### Q46 日時変換（文字列 → 日付型）

- `TO_DATE`を使用

```sql
SELECT
    customer_id,
    TO_DATE(application_date, 'YYYYMMDD')
FROM
    customer
LIMIT
    10;
```

### Q47 日時変換（数値 → 日付型）

- `TO_DATE`と`CAST`を使用
- 一旦文字列に変換してから、日時変換

```sql
SELECT
    TO_DATE(CAST(sales_ymd AS VARCHAR), 'YYYYMMDD'),
    receipt_no,
    receipt_sub_no
FROM
    receipt
LIMIT
    10;
```

### Q48 日時変換（UNIX → 日付型）

- `TO_TIMESTAMP`を使用

```sql
SELECT
    TO_TIMESTAMP(sales_epoch),
    receipt_no,
    receipt_sub_no
FROM
    receipt
LIMIT
    10;
```

### Q49 日時変換（UNIX → 日付型 → 年）

- `TO_CHAR`と`EXTRACT`と`TIMESTAMP`を使用
- EXTRACTは抽出の意味。
- EXTRACTの引数は、（抽出したい日付粒度 `FROM` ソース）とフォーマット指定可
- 月、日でも同じ書き方。FM00で0埋め可。

```sql
SELECT
    TO_CHAR(EXTRACT(YEAR FROM TO_TIMESTAMP(sales_epoch)), 'FM9999') AS sales_year,
    receipt_sub_no
FROM
    receipt
LIMIT
    10;
```

### Q53 文字データの変換と二値化

- SUBSTRは、第一引数にカラム、第二第三に開始と終了位置を与える
- CASTで囲うことで型変換
- 二値化はCASE文を使用
- 範囲が100~209と指定がある場合、BETWEENを使用

```sql
WITH cust AS (
    SELECT
        customer_id,
        postal_cd,
        CASE
            WHEN CAST(SUBSTR(postal_cd, 1, 3) AS INTEGER)
                BETWEEN 100 AND 209 THEN 1
            ELSE 0
        END AS postal_flg
    FROM
        customer
),

rect AS (
    SELECT
        customer_id,
        SUM(amount) AS amount
    FROM
        receipt
    GROUP BY
        customer_id
)

SELECT
    c.postal_flg,
    COUNT(1)
FROM
    rect AS r
JOIN cust AS c
    ON r.customer_id = c.customer_id
GROUP BY
    c.postal_flg
```

### Q56 カテゴリ化

- LEASTは、値の最小値を返す。Pythonのmin()と同じ。スカラーなのか集計なのかの違い。
- TRUNCは、不要な値の切り捨て。
- 年代系はCASEではなく、カラム（age）に対して割り算適用で求める！

```sql
SELECT
    customer_id,
    birth_day,
    LEAST(CAST(TRUNC(age / 10) * 10 AS INTEGER), 60) AS era
FROM
    customer
GROUP BY
    customer_id,
    birth_day
    HAVING LEAST(CAST(TRUNC(age / 10) * 10 AS INTEGER), 60) >= 60
LIMIT
    10;
```

### Q58 ダミー変数化

- SQLでダミー変数はあまり適していない
- 機械学習の項目
- One-Hot-Encoding。1つのカラムを複数の独立したカラムに展開

```sql
SELECT
    customer_id,
    CASE WHEN gender_cd = '0' THEN '1' ELSE '0' END AS gender_male,
    CASE WHEN gender_cd = '1' THEN '1' ELSE '0' END AS gender_female,
    CASE WHEN gender_cd = '9' THEN '1' ELSE '0' END AS gender_unknown
FROM
    customer
LIMIT
    10;
```

### 62 常用対数化

- 常用対数は桁数がどれくらいちがうかの指標
- LOG10を使用する
- 底である10を何回掛け合わせたかで求める

```sql
SELECT
    customer_id,
    SUM(amount) AS sum_amount,
    LOG10(SUM(amount)) AS log10_amount
FROM
    receipt
WHERE
    customer_id NOT LIKE 'Z%'
GROUP BY
    customer_id
LIMIT
    10;
```

### 64 自然対数化

- LOG（⚪︎ +1）を使用する
- もしくは、専用関数のLN（Logarithmus Naturails）を使用

```sql
SELECT
    customer_id,
    SUM(amount) AS sum_amount,
    LN(SUM(amount)) AS log10_amount
FROM
    receipt
WHERE
    customer_id NOT LIKE 'Z%'
GROUP BY
    customer_id
LIMIT
    10;
```

