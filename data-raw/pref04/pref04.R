################################
# 04. 宮城県
# 消防本部別でない
################################
library(rvest)
library(purrr)
x <-
  read_html("https://www.pref.miyagi.jp/soshiki/syoubou/netyuusyou.html")

x2 <- 
  x |> 
  html_nodes(css = "#tmp_contents > ul > li > a")

df <- 
  tibble::tibble(
  title = x2 |> 
    html_text(),
  url = x2 |> 
    html_attr(name = "href")
) |> 
  dplyr::filter(stringr::str_detect(url, ".pdf$"))

urls <- 
  df |> 
  dplyr::pull(url) |> 
  xml2::url_absolute(base = "https://www.pref.miyagi.jp/")

download_pdf <- 
  slowly(function(x)
    curl::curl_download(x,
                        destfile = here::here("data-raw/pref04", basename(x))), 
    rate = rate_delay(pause = 8), 
    quiet = FALSE)
urls |> 
  purrr::walk(download_pdf)
