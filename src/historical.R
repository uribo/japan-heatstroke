################################
# ref) 札幌 https://www.wbgt.env.go.jp/record_data.php?region=01&prefecture=14&point=14163
# https://www.wbgt.env.go.jp/record_data.php?region=02&prefecture=34&point=34296
# 1. 確定版 2023年10月まで取得済み。 (2024-08-02)
# wbgt_stations2023.csv
# 4~10月(7ヶ月)
# 2018~2023 (5年) ... 42件(6年*7ヶ月)
# station_noの変更（名称は変わらず） ... 42件ないもの
# 36127: 福島（福島）2021年4月からは「36127」(14files)、それより前は「36126」 (21files 該当station_noなし)... ダウンロード済み
# 48536: 木祖薮原（長野） 2020年4月からは「48536」(21files)、それより前は「48541」 (14files 該当station_noなし)... ダウンロード済み
# 84306: 西海（長崎） 2021年4月からは「84306」(14files)、それより前は「84356」 (21files 該当station_noなし)... ダウンロード済み
# 84597: 脇岬（長崎） 2021年4月からは「84597」(14files)、それより前は「84596」 (21files 該当station_noなし)... ダウンロード済み
# station_noの変更（名称も変わる）
# 34296: 女川（宮城） 2021年4月からは「34296」(14files) 、それより前は江ノ島「34361」 (21files 該当station_noなし)... ダウンロード済み
# 
# 2. 速報版 (2023-10-24)
# wbgt_stations2023.csv
# https://www.wbgt.env.go.jp/mntr/2023/wbgt_2023/wbgt_34296_202310.csv
# 2023年4~10月(7ヶ月)
# 取得が行えるのは2024-10-23までなので注意
# 17:00が最後の記録？
################################
source(here::here("R/read_moe_wbgt.R"))
fs::dir_create("~/Documents/resources/環境省/熱中症予防情報サイト/地点別_実況推定値/確定版/")
fs::dir_create("~/Documents/resources/環境省/熱中症予防情報サイト/地点別_実況推定値/速報版/")

list_station_csv <- function(station_no, category = "確定版") {
  if (category == "確定版") {
    file_name <-
      glue::glue("final_wbgt_{station_no}_.+.csv")
  } else if (category == "速報版") {
    file_name <-
      glue::glue("wbgt_{station_no}_.+.csv")
  }
  fs::dir_ls(
    glue::glue("~/Documents/resources/環境省/熱中症予防情報サイト/地点別_実況推定値/{category}/"),
    regexp = file_name)
}
# length(list_station_csv(14116))

collect_wbgt_data <- function(station_no, category = "確定版") {
  if (category == "確定版") {
    year <- 
      seq.int(2018, 2023)
    month <-
      stringr::str_pad(seq.int(4, 10), pad = "0", width = 2)
  } else if (category == "速報版") {
    year <-
      2024
    month <-
      stringr::str_pad(seq.int(4, 10), pad = "0", width = 2)
  }
  x <- 
    tidyr::expand_grid(year = year,
                       month = month) |> 
    purrr::pmap_chr(\(year, month) paste0(year, month, collapse = "")) |> 
    sort()
  current_files <-
    list_station_csv(station_no, category)
  
  if (length(current_files) == length(x)) {
    cat(cli::col_green(
      glue::glue("{length(current_files)}件のファイルを取得済みです\n")
    ))
  } else {
    # 取得済みのファイルは再取得しない
    if (length(current_files) > 0) {
      x <- 
        x[!x %in% stringr::str_extract(basename(current_files), "(2018|2019|2020|2021|2022|2023|2024)(0[4-9]|10)")]
    }
    if (length(x) > 0) {
      moe_wbgt_request_urls(type = "observe", 
                            station_no = station_no, 
                            year_month = x) |> 
        purrr::walk(
          function(url) {
            req <- 
              httr2::request(url) |> 
              httr2::req_throttle(rate = 6 / 60) |> 
              httr2::req_error(is_error = function(resp) FALSE) |> 
              httr2::req_perform()
            if (req$status_code == 200L) {
              req |> 
                httr2::resp_body_raw() |> 
                readr::write_file(
                  glue::glue("{dir}/{file}",
                             dir = glue::glue("~/Documents/resources/環境省/熱中症予防情報サイト/地点別_実況推定値/{category}/"),
                             file = basename(url))
                )
            }
          }
        )
      cat(cli::col_blue(
        glue::glue("{x}件のファイルを取得しました\n",
                   # x = length(list_station_csv(station_no, category = category))
                   x = length(x))
      ))
    }
  }
}

# 速報版 ---------------------------------------------------------------------
# 2024年は取得せず (2024-07-31)
df_station <- 
  readr::read_csv(here::here("data/wbgt_stations2023.csv"), col_types = "cdcc")

df_station$station_no[3:nrow(df_station)] |> 
  purrr::map(
    ~ collect_wbgt_data(.x, category = "速報版"))

df_station$station_no |> 
  purrr::map_lgl(
    \(x) length(list_station_csv(x, category = "速報版")) != 7L
  ) |> 
  which()

# 確定版 ---------------------------------------------------------------------
# 2023-10まで取得済み (2024-08-02)
tibble::tibble(
  station_no = fs::dir_ls("~/Documents/resources/環境省/熱中症予防情報サイト/地点別_実況推定値/確定版/") |> 
      basename() |> 
      stringr::str_remove("final_wbgt_") |> 
      stringr::str_remove("_[0-9]{1,}.csv")) |> 
  dplyr::mutate(station_no = dplyr::case_match(
    station_no,
    "36126" ~ "36127",
    "48541" ~ "48536",
    "84356" ~ "84306",
    "84596" ~ "84597",
    "34361" ~ "34296",
    .default = station_no
  )) |> 
  dplyr::count(station_no, sort = TRUE) |> 
  dplyr::filter(n < length(seq.int(4, 10)) * length(seq.int(2018, 2023)))

df_station <- 
  readr::read_csv(here::here("data/wbgt_stations2023.csv"), col_types = "cdcc")

# 取得は分けて行う
df_station$station_no[800:nrow(df_station)] |> 
  purrr::map(
    \(x) collect_wbgt_data(x, category = "確定版"))
# tictoc::tic(); collect_wbgt_data(df_station$station_no[670]) ; tictoc::toc()
# source("historical.R")
