日本国内における熱中症関係のデータセット
=================

日本国内における熱中症情報を提供するウェブサイトから、Rで利用可能な形式にデータを読み込む処理を提供しています。

## 対象データ

[環境省 熱中症予防情報サイト](https://www.wbgt.env.go.jp/)より、熱中症警戒アラート、暑さ指数 (WBGT)の予測値および実況値のデータ取得のための処理を関数化しています。以下のコードを実行することで必要な関数が読み込まれます。

```r
library(magrittr)
source("https://raw.githubusercontent.com/uribo/japan-heatstroke/main/R/read_moe_wbgt.R")
```

`read_moe_wbgt()`関数を使い、予測値と実況値の取得を行います。取得対象のデータに応じて、以下のように引数の指定方法が変わります。各データの詳細は暑さ指数(WBGT)予測値等 電子情報提供サービスのページより確認ください。

ダウンロードされたデータを読み込むには`parse_moe_wbgt_csv()`で対象ファイルのパスとファイルの種類を指定します。

## 1. 予測値

予測値を取得する場合、`type`引数の値を`forecast`に固定します。以下に示すように他の引数との組み合わせにより、取得されるデータが変わります。

### 1-A. 地点別

```r
read_moe_wbgt(type = "forecast", station_no = "43056")
```

地点の指定を引数`station_no`で与えます。これは5桁の半角数字です。指定可能な840地点については、リポジトリに含めたデータセットより探せます。例えば茨城県つくば市「つくば」の`station_no`は次のコードを実行することで確認できます。

```r
df_wbgt_stations <- 
  readr::read_csv("data/wbgt_stations2022.csv",
                  col_types = "cccc")
subset(df_wbgt_stations, station_name == "つくば")
```

```r
# ダウンロード済みのファイルを読み込む
parse_moe_wbgt_csv("yohou_43056.csv",
                   file_type = "1-A")
```

### 1-B. 都道府県別

`prefecture`引数に対象の都道府県名（ローマ字表記、すべて小文字）を与えます。次の例では「岐阜県」内の全地点の予測値を取得します。

```r
read_moe_wbgt(type = "forecast", prefecture = "gifu")
```

```r
# ダウンロード済みのファイルを読み込む
parse_moe_wbgt_csv("yohou_ibaraki.csv",
                   file_type = "1-B")
```

### 1-C. 全地点

全地点での発表されている予測値を一度に取得するには`type`以外の引数を指定せずに実行します。

```r
read_moe_wbgt(type = "forecast")
```

```r
# ダウンロード済みのファイルを読み込む
parse_moe_wbgt_csv("yohou_all.csv",
                   file_type = "1-C")
```

## 実況値

実況値は過去のデータになります。予測値と同様に地点、都道府県、全地点の単位で取得しますが、期間を選ぶオプションがあります。これは2022年4月からの各月を、YYYYMMの形式で指定します。例えば2022年4月であれば「202204」となります。また実況値は、特定の地点に関してはその実測値を求めることが可能です。

実況値の取得は、データの種類を問わず`read_moe_wbgt(type = "observe")`としてください。また、予測値と同じく`parse_moe_wbgt_csv()`を使うことでダウンロードされたファイルの読み込みにも対応します。

### 2-A. 地点別

```r
read_moe_wbgt(type = "observe", station_no = "43056", year_month = "202204")
```

```r
# ダウンロード済みのファイルを読み込む
parse_moe_wbgt_csv("wbgt_43056_202204.csv",
                   file_type = "2-A")
```


### 2-B. 都道府県別

```r
read_moe_wbgt(type = "observe", prefecture = "gifu", year_month = "202207")
```

```r
# ダウンロード済みのファイルを読み込む
parse_moe_wbgt_csv("wbgt_gifu_202207.csv",
                   file_type = "2-B")
```

### 2-C. 全地点

```r
read_moe_wbgt(type = "observe", year_month = "202204")
```

```r
# ダウンロード済みのファイルを読み込む
parse_moe_wbgt_csv("wbgt_all_202204.csv",
                   file_type = "2-C")
```

### 2-D. 実測地点別

特定の11地点については実測値のデータ取得が可能です。`read_moe_wbgt()`では`station`引数にローマ字（頭文字のみ大文字）で対象の地点名を与えて実行します。

```r
read_moe_wbgt(type = "observe", station = "Osaka", year_month = "202205")
```

```r
# ダウンロード済みのファイルを読み込む
parse_moe_wbgt_csv("Tokyo_202204.csv",
                   file_type = "2-D")
```

## 熱中症警戒アラート

```r
source("https://raw.githubusercontent.com/uribo/japan-heatstroke/main/R/moe_alert.R")
```

```r
read_moe_alert(2022)
```

## 注意

- 熱中症予防情報サイトからのデータ提供は2022年10月26日までとなります。
- データの詳細、利用に関しては、熱中症予防情報サイトに掲載された情報を参考にしてください。

## ライセンス

コードのライセンスは[MIT](https://choosealicense.com/licenses/mit/)です。
