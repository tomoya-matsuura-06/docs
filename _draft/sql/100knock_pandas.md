### 75. ランダム1%データ抽出

```jsx
df_customoer.sample(frac=0.01).head(10)
```

- random()で、行または列をサンプル抽出
- fracは、抽出する割合を指定

---

### 76. 層化抽出

- 層化は、母集団をいくつかにグループ分けすること
- 層化抽出には、train_test_split()を使用する
- train_test_split()は機械学習で訓練データ、テストデータの二分割に使用される

```jsx
_,df_tmp = train_test_split(df_customer, test_size=0.1, stratify=df_customer["gender_cd"])

df_tmp.groupby("gender_cd").agg({"customer_id": "count"})
```

- 引数startifyは、均等に分割させたいデータを指定する（そのデータの比率が元のデータと一致するように）
- 先頭を_とすることで返り値を求めない

