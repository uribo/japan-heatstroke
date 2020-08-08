####################################
# 環境省の暑さ指数 (WBGT) 予測値等電子情報提供サービス
# 観測地点... 
# - 予測値... 840地点
#     気象庁のやつと同じ
#     木曽平沢 (長野, 48541) --> 木祖薮原 (長野, 48536)
#     阿蘇山 --> 終了
# - 実測値... 11地点（昨年度までと同様）
####################################
library(tabulizer)
library(jmastats)
library(sf)
library(dplyr)

if (!file.exists("data/wbgt_stations2020.csv")) {
  download.file("https://www.wbgt.env.go.jp/man15NH/R02_wbgt_data_service_manual.pdf",
                destfile = "data-raw/R02_wbgt_data_service_manual.pdf")
  d <- 
    extract_tables("data-raw/R02_wbgt_data_service_manual.pdf",
                   pages = seq.int(10, 22),
                   output = "data.frame") %>% 
    purrr::map(tibble::as_tibble)
  d2 <- 
    d %>% 
    purrr::map_at(
      1,
      ~ .x %>% 
        select(where(~sum(!is.na(.)) > 0)) %>% 
        tidyr::separate(`地点番号.観測所名`, into = c("地点番号", "観測所名")) 
    ) %>% 
    purrr::map_dfr(
      ~ .x %>% 
        readr::type_convert(col_types = "ccicccc") %>% 
        purrr::set_names(c("地方", "振興局", "地点番号",
                           "観測所名", "よみがな", 
                           "ローマ字表記",
                           "所在地"))) %>% 
    select(-7)
  d2 %>% 
    filter(`観測所名` == "声問")
  d2 %>% 
    filter(`観測所名` == "木曽平沢")
  df_wbgt_stations <- 
    jmastats::stations %>% 
    sf::st_drop_geometry() %>% 
    select(area, station_no, station_name, pref_code) %>% 
    distinct(station_no, station_name, .keep_all = TRUE) %>% 
    inner_join(d2 %>% 
                 filter(!is.na(`ローマ字表記`)) %>% 
                 select(`地点番号`, `観測所名`),
               by = c("station_no" = "地点番号",
                      "station_name" = "観測所名")) %>% 
    assertr::verify(nrow(.) == 840L)
  
  df_wbgt_stations %>% 
    readr::write_csv("data/wbgt_stations2020.csv")
}
if (!file.exists("data/wbgt_stations2020.csv")) {
  d <- 
    extract_tables("data-raw/R02_wbgt_data_service_manual.pdf",
                   pages = 23,
                   output = "data.frame") %>% 
    purrr::pluck(1) %>% 
    tibble::as_tibble()
  df_wbgt_observe2020 <- 
    bind_rows(
      d[, seq.int(2)] %>% 
        purrr::set_names(c("prefecture", "roman")),
      d[, seq.int(3, 4)] %>% 
        purrr::set_names(c("prefecture", "roman")))
  df_wbgt_observe2020 %>% 
    readr::write_csv("data/wbgt_observe2020.csv")  
}
