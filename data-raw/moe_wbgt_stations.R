####################################
# 環境省の暑さ指数 (WBGT) 予測値等電子情報提供サービス
# 観測地点... 
# - 予測値... 840地点
#     気象庁のやつと同じ
#     木曽平沢 (長野, 48541) --> 木祖薮原 (長野, 48536)
#     阿蘇山 --> 終了
# - 実測値... 11地点（昨年度までと同様）
# 札幌、仙台、新潟、東京、名古屋、大阪、広島、高知、福岡、鹿児島、那覇
####################################
library(zipangu)
library(jmastats)
library(sf)
library(dplyr)

if (!file.exists("data/wbgt_stations2022.csv")) {
  if (!file.exists("data-raw/R04_wbgt_data_service_manual.pdf")) {
    download.file("https://www.wbgt.env.go.jp/man15NH/R04_wbgt_data_service_manual.pdf",
                  destfile = "data-raw/R04_wbgt_data_service_manual.pdf")    
  }
  text <-
    pdftools::pdf_text("data-raw/R04_wbgt_data_service_manual.pdf")

  pdf_table_to_df <- function(text) {
    x <- 
      text %>% 
      stringr::str_split("\n", simplify = TRUE) %>% 
      c() %>% 
      stringr::str_subset("^$", negate = TRUE)
    x <- 
      x %>%
      stringr::str_subset("^(北海道|東北|関東|甲信|東海|北陸|近畿|中国|四国|九州|沖縄)") %>% 
      purrr::map(
        ~ stringr::str_split(.x, "[:space:]{1,}", n = 7, simplify = TRUE)
      ) %>% 
      purrr::reduce(rbind)
    
    as.data.frame(x) %>%   
      tibble::as_tibble() %>% 
      purrr::set_names(c("地方", "振興局", "地点番号",
                         "観測所名", "よみがな", 
                         "ローマ字表記",
                         "所在地"))    
  }
  
  d <- 
    seq.int(11, 23) %>% 
    purrr::map_dfr(
      ~ pdf_table_to_df(text[[.x]]))
  # 暑さ指数情報の提供を終了
  # 34361 江ノ島
  # 44356 南鳥島
  # 86156 阿蘇山
  d <- 
    d %>% 
    filter(!`地点番号` %in% c(34361, 44356, 86156)) %>% 
    assertr::verify(nrow(.) == 840L)
  
  df_wbgt_stations <- 
    jmastats::stations %>% 
    sf::st_drop_geometry() %>% 
    select(area, station_no, station_name, pref_code) %>% 
    distinct(station_no, station_name, .keep_all = TRUE) %>% 
    inner_join(d %>% 
                 select(`地点番号`, `観測所名`) %>% 
                 mutate(`地点番号` = as.integer(`地点番号`)),　
               by = c("station_no" = "地点番号",
                      "station_name" = "観測所名")) %>% 
    assertr::verify(nrow(.) == 840L)
  
  df_wbgt_stations %>%
    readr::write_csv("data/wbgt_stations2022.csv")
}
if (!file.exists("data/wbgt_observe2022.csv")) {
  if (!file.exists("data-raw/R04_wbgt_data_service_manual.pdf")) {
    download.file("https://www.wbgt.env.go.jp/man15NH/R04_wbgt_data_service_manual.pdf",
                  destfile = "data-raw/R04_wbgt_data_service_manual.pdf")    
  }
  text <-
    pdftools::pdf_text("data-raw/R04_wbgt_data_service_manual.pdf")
  
  d <-
    text[[length(text)]] %>% 
    stringr::str_split("\n", simplify = TRUE) %>% 
    c() %>% 
    stringr::str_subset("^$", negate = TRUE) %>% 
    stringr::str_squish() %>% 
    stringr::str_subset(
      paste0("(",
             paste0(harmonize_prefecture_name(jpnprefs$prefecture_kanji, to = "short"), 
                    collapse = "|"),
             ")")) %>% 
    purrr::map(
      ~ stringr::str_split(.x, "[:space:]{1,}", n = 4, simplify = TRUE)
    ) %>% 
    purrr::reduce(rbind) %>% 
    as.data.frame()
  
  d <-
    bind_rows(
    d[, 1:2] %>% 
      purrr::set_names(c("prefecture", "roman")),
    d[, 3:4] %>% 
      purrr::set_names(c("prefecture", "roman"))) %>% 
    tibble::as_tibble() %>% 
    filter(prefecture != "")
    
  df_wbgt_observe2022 <- 
    d %>% 
    mutate(pref_long = harmonize_prefecture_name(prefecture, to = "long")) %>% 
    left_join(jpnprefs %>% 
                select(jis_code, pref_long = prefecture_kanji),
              by = "pref_long") %>% 
    arrange(jis_code) %>% 
    select(!c(pref_long, jis_code)) %>% 
    assertr::verify(nrow(.) == 47L)
  
  df_wbgt_observe2022 %>% 
    readr::write_csv("data/wbgt_observe2022.csv")
}
