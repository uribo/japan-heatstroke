################################
# 14. 神奈川県
# 令和5年度
################################

# PDFのダウンロード --------------------------------------------------------------
library(rvest)
x <- 
  read_html("https://www.pref.kanagawa.jp/docs/kd8/hanso1.html") |> 
  html_nodes(css = "#tmp_contents > p > a") |> 
  html_attr(name = "href") |> 
  stringr::str_subset(".pdf$") |> 
  xml2::url_absolute(base = "https://www.pref.kanagawa.jp/")

# x |>
#   purrr::walk(
#     function(x) {
#       Sys.sleep(7)
#       download.file(x,
#                     destfile = glue::glue("data-raw/pref14/{basename(x)}"))
#     }
#   )


# PDFからのデータ抽出 -------------------------------------------------------------
library(pdftools)
x <- 
  pdf_text("data-raw/pref14/0828.pdf")

x |> 
  stringr::str_split("\n", simplify = TRUE) |> 
  purrr::reduce(c) |> 
  purrr::pluck(7)

x_dairy <- 
  x |> 
  stringr::str_split("\n", simplify = TRUE) |> 
  purrr::reduce(c) |> 
  stringr::str_subset("^[0-9]{1,}") |> 
  stringr::str_squish() |> 
  purrr::keep(
    \(x) stringr::str_count(x, "[:space:]") == 9L
  ) |> 
  stringr::str_replace_all("[:space:]", ", ")

library(lubridate)
dat <- 
  readr::read_csv(I(x_dairy), col_names = c("id", "消防（局）本部名",
                                            as.character(seq(ymd("2023-08-28"),
                                                             ymd("2023-09-03"),
                                                             by = 1))),
                  col_types = "dcddddddd_") |> 
  tidyr::pivot_longer(cols = 3:9,
                      names_to = "date",
                      values_to = "value")

x_type <- 
  x |> 
  stringr::str_split("\n", simplify = TRUE) |> 
  purrr::reduce(c) |> 
  stringr::str_subset("^[0-9]{1,}") |> 
  stringr::str_squish() |> 
  purrr::keep(
    \(x) stringr::str_count(x, "[:space:]") == 9L
  ) |> 
  stringr::str_replace_all("[:space:]", ", ")

dat <- 
  readr::read_csv(I(x_type), col_names = c("id", "消防（局）本部名",
                                       paste0("年齢区分（人）",
                                              c("新生児", "乳幼児", "少年", "成人", "高齢者", "合計")),
                                       paste0("初診時における傷病程度（人）",
                                              c("死亡", "重症", "中等症", "軽症", "その他", "合計"))),
                  col_types = "dcdddddddd")

dat
