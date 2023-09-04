################################
# 07. 福島県
################################
# 1. PDFのダウンロード -----------------------------------------------------------
library(dplyr)
library(rvest)
x <-
  read_html("https://www.pref.fukushima.lg.jp/sec/16025a/necchu-02.html")

df <- 
  tibble::tibble(
  name = x |> 
    html_nodes(css = "#main_body > div.detail_free > p > a") |> 
    html_text(),
  url = x |> 
    html_nodes(css = "#main_body > div.detail_free > p > a") |> 
    html_attr(name = "href") |> 
    xml2::url_absolute(base = "https://www.pref.fukushima.lg.jp/")) |> 
  ensurer::ensure(nrow(.) >= 34L) |>
  filter(stringr::str_detect(name, "(平成|令和).+年")) |> 
  ensurer::ensure(nrow(.) == 10L) |> 
  mutate(name = stringr::str_squish(name) |> 
           stringi::stri_trans_nfkc() |> 
           stringr::str_extract(".+年") |> 
           stringr::str_remove_all("[[:space:]]"))

df |> 
  dplyr::filter(stringr::str_detect(name, "月別", negate = TRUE)) |> 
  purrr::pwalk(
    function(url, name) {
      download.file(url = url,
                    destfile = here::here(glue::glue("data-raw/pref07/{name}.pdf")))
    }
  )
