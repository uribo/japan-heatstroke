################################
# 21. 岐阜県
################################
# 1. [WIP]PDFのダウンロード -----------------------------------------------------------
library(dplyr)
library(rvest)
x <- 
  read_html("https://www.pref.gifu.lg.jp/page/6398.html")

x |> 
  html_elements(css = "#main_body > div.detail_free") |> 
  html_elements(css = "table > tbody > tr > td > a") |> 
  html_attr(name = "href")

x |> 
  html_elements(css = "#main_body > div.detail_free") |> 
  html_elements(css = "table > tbody > tr > td") |> 
  html_text() |> 
  stringr::str_subset("PDF")
