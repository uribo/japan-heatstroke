###############################
# オリンピック・パラリンピック暑熱環境測定事業
###############################
library(rvest)
x <- read_html("https://www.wbgt.env.go.jp/survey_tokyo2020.php")

x2 <- 
  x |> 
  html_elements(css = "#maincontent > p > a:nth-child(2)")

df <- 
  tibble::tibble(
    year = c(
      rep(c("R03", "R02", "R01"), each = 17),
      rep(c("H30", "H29"), each = 14)
    ),
  location = x |> 
    html_elements(css = "#maincontent > p > span") |> 
    html_text() |> 
    stringi::stri_trans_nfkc(),
  url = x2 |> 
    html_attr(name = "href") |> 
    xml2::url_absolute(base = "https://www.wbgt.env.go.jp/"))

fs::dir_create(here::here("data-raw/survey_tokyo2020"))
df |> 
  purrr::pwalk(
    function(year, url, ...) {
      download.file(
        url,
        destfile = glue::glue("data-raw/survey_tokyo2020/{paste(year, basename(url), sep = '_')}")
      )
    }
  )
