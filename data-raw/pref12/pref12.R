##############################
# 12. 千葉県
##############################
library(rvest)
# x <-
#   read_html("https://www.pref.chiba.lg.jp/shoubou/kaji/kyuukyuu/necchusho.html")
# 
# files <-
#   x |>
#   html_elements(css = '#tmp_contents > ul:nth-child(3) > li > a') |>
#   html_attr(name = "href") |>
#   xml2::url_absolute(base = "https://www.pref.chiba.lg.jp")
generate_pref12_pdf_links <- function(url, start_date, end_date, type) {
  rlang::arg_match(type,
                   c("concatenate", "dot-split"))
  days <- 
    seq.int(start_date,
            end_date,
            by = 1) |>
    as.character()
  if (type == "concatenate") {
    days <- 
      days |> 
      stringr::str_sub(6, 10) |> 
      stringr::str_remove("-")
  } else if (type == "dot-split") {
    days <-
      days |> 
      stringr::str_replace_all("-", ".")
  }
  paste0(url,
         days,
         ".pdf")
}

# 令和5年 --------------------------------------------------------------------
# イレギュラー
# necchusho2023.06.29..pdf, necchusho2023.07.5.pdf, necchusho2023.06.pdf
files <-
  generate_pref12_pdf_links("https://www.pref.chiba.lg.jp/shoubou/kaji/kyuukyuu/documents/necchusho",
                            lubridate::make_date(2023, 6, 1),
                            lubridate::make_date(2023, 7, 1)-1,
                            type = "dot-split")
files <-
  generate_pref12_pdf_links("https://www.pref.chiba.lg.jp/shoubou/kaji/kyuukyuu/documents/necchusho2023",
                            lubridate::make_date(2023, 7, 1),
                            lubridate::make_date(2023, 8, 1)-1,
                            type = "concatenate")

# x <- 
#   fs::dir_ls(here::here("data-raw/pref12/"), regexp = "2023\\..+pdf")
# fs::file_move(x,
#               stringr::str_remove_all(x, "\\."))

# x <-
#   fs::dir_ls(here::here("data-raw/pref12/"), regexp = "[0-9]pdf")
# fs::file_move(x,
#               stringr::str_replace(x, "pdf", ".pdf"))

# 令和4年OK --------------------------------------------------------------------
files <-
  generate_pref12_pdf_links("https://www.pref.chiba.lg.jp/shoubou/kaji/kyuukyuu/documents/necchusho04",
                            lubridate::make_date(2022, 5, 1),
                            lubridate::make_date(2022, 10, 1)-1) |> 
  ensurer::ensure(length(.) == 122L)

# x <- 
#   fs::dir_ls(here::here("data-raw/pref12/"), regexp = "necchusho04")
# fs::file_move(x,
#               stringr::str_replace(x, "necchusho04", "necchusho2022"))


# 令和3年 --------------------------------------------------------------------
# 部分的に404
# 9月3日から9月6日、9月9日, 9月14日から9月24日ほか
files <-
  generate_pref12_pdf_links("https://www.pref.chiba.lg.jp/shoubou/kaji/kyuukyuu/documents/necchusho03",
                          lubridate::make_date(2021, 6, 1),
                          lubridate::make_date(2021, 10, 1)-1) |>
  ensurer::ensure(length(.) == 122L)
length(files)


# x <- 
#   fs::dir_ls(here::here("data-raw/pref12/"), regexp = "necchusho03")
# fs::file_move(x,
#               stringr::str_replace(x, "necchusho03", "necchusho2021"))

# Download ----------------------------------------------------------------
# files |>
#   purrr::walk(
#     function(url) {
#       req <-
#         httr2::request(url) |> 
#         httr2::req_throttle(rate = 6 / 60) |> 
#         req_error(is_error = function(resp) FALSE) |> 
#         httr2::req_perform()
#       if (req$status_code == 200L) {
#         req |> 
#           httr2::resp_body_raw() |> 
#           readr::write_file(
#             glue::glue("{dir}/{file}",
#                        dir = here::here("data-raw/pref12/"),
#                        file = basename(url))
#           )
#       } else {
#         rlang::inform("404 not found")
#       }
#     }
#   )


# Parse -------------------------------------------------------------------
library(magrittr)
files <- 
  fs::dir_ls(here::here("data-raw/pref12"))

x <- 
  pdftools::pdf_text(files[1]) |> 
  stringr::str_split("（０時～１６時）|\u203b",
                     simplify = TRUE) |> 
  purrr::pluck(2) |> 
  stringr::str_split("\n", simplify = TRUE) %>%
  magrittr::extract(5:length(.)-1)

x[1]

x[2:length(x)] |> 
  stringr::str_squish() |> 
  stringr::str_split("[[:space:]]", simplify = TRUE) |> 
  tibble::as_tibble(.name_repair = "unique") |> 
  dplyr::select(!8) |> 
  purrr::set_names("消防本部名", "搬送者数", "死亡", "重症", "中等症", "軽症", "その他")

