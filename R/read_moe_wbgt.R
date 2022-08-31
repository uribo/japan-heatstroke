read_moe_wbgt <- function(type, station = NULL, station_no = NULL, prefecture = NULL, year_month = NULL) {
  rlang::arg_match(type,
                   c("forecast", "observe"))
  if (!is.null(station)) {
    rlang::arg_match(station,
                     c("Sapporo", "Sendai", "Niigata",
                       "Tokyo", "Nagoya", "Osaka", 
                       "Hiroshima", "Kochi", "Fukuoka",
                       "Kagoshima", "Naha"))
  }
  domain_url <- "https://www.wbgt.env.go.jp"
  csv_url <- 
    moe_wbgt_request_url(type = type, 
                         station_no = station_no, 
                         station = station, 
                         prefecture = prefecture, 
                         year_month = year_month)
  if (type == "forecast") {
    df <- 
      parse_moe_wbgt_csv(csv_url, file_type = "1-A")
  }
  if (type == "observe") {
    if (!is.null(station_no) & !is.null(year_month)) {
      df <-
        parse_moe_wbgt_csv(csv_url, file_type = "2-A", .station_no = station_no)
    } else if (is.null(station) & !is.null(prefecture) & !is.null(year_month)) {
      df <- 
        parse_moe_wbgt_csv(csv_url, file_type = "2-B")
    } else if (is.null(station) & is.null(prefecture) & !is.null(year_month)) {
      df <- 
        parse_moe_wbgt_csv(csv_url, file_type = "2-C")
    } else if (!is.null(station) & !is.null(year_month)) {
      df <- 
        parse_moe_wbgt_csv(csv_url, file_type = "2-D", .station = station)
    } 
  }
  df
}

# moe_wbgt_request_url(type = "observe", station_no = st_no_tsukuba, year_month = "202004")
# # 小文字
# moe_wbgt_request_url(type = "observe", prefecture = "tokyo", year_month = "202004")
# moe_wbgt_request_url(type = "observe", year_month = "202004")
# # 大文字
# moe_wbgt_request_url(type = "observe", station = "Tokyo", year_month = "202004")
moe_wbgt_request_url <- function(type, station_no = NULL, prefecture = NULL, station = NULL, year_month = NULL) {
  rlang::arg_match(type,
                   c("forecast", "observe"))
  domain_url <- "https://www.wbgt.env.go.jp"
  if (type == "forecast") {
    if (!is.null(station_no)) {
      glue::glue("{domain_url}/prev15WG/dl/yohou_{station_no}.csv")
    } else if (!is.null(prefecture)) {
      glue::glue("https://www.wbgt.env.go.jp/prev15WG/dl/yohou_{prefecture}.csv")
    } else if (type == "forecast" & is.null(station_no) & is.null(prefecture)) {
      "https://www.wbgt.env.go.jp/prev15WG/dl/yohou_all.csv"
    }
  } else if (type == "observe") {
    if (!is.null(station_no) & !is.null(year_month)) {
      glue::glue("{domain_url}/est15WG/dl/wbgt_{station_no}_{year_month}.csv")
    } else if (!is.null(prefecture) & !is.null(year_month)) {
      glue::glue("{domain_url}/est15WG/dl/wbgt_{prefecture}_{year_month}.csv")
    } else if (!is.null(station) & !is.null(year_month)) {
      glue::glue("{domain_url}/mntr/dl/{station}_{year_month}.csv")
    } else if (is.null(station_no) & is.null(prefecture) & !is.null(year_month)) {
      glue::glue("{domain_url}/est15WG/dl/wbgt_all_{year_month}.csv")
    }  
  }
}

parse_moe_wbgt_csv <- function(path, file_type, .station_no = NULL, .station = NULL) {
  if (file_type %in% c("1-A", "1-B", "1-C")) {
    df <- 
      suppressWarnings(
        readr::read_csv(path,
                        col_types = readr::cols(
                          .default = readr::col_double(),
                          ...1 = readr::col_character(),
                          ...2 = readr::col_character())))
    
    df <- 
      df %>%
      dplyr::select(!2) %>% 
      tidyr::pivot_longer(cols = seq.int(2, ncol(df)-1),
                          names_to = "datetime",
                          values_to = "wbgt") %>%
      dplyr::mutate(type = "forecast",
                    datetime = lubridate::as_datetime(datetime,
                                                      format = "%Y%m%d %H",
                                                      tz = "Asia/Tokyo")) %>%
      dplyr::relocate(type, .before = 1) %>%
      dplyr::rename(station_no = ...1)
    
  } else if (file_type == "2-A") {
    if (is.null(.station_no)) {
      .station_no <- 
        stringr::str_remove_all(path,
                                ".+/") %>% 
        stringr::str_extract("(?<=\\_).*?(?=\\_)")
    }
    df <-
      readr::read_csv(path,
                      skip = 1L,
                      col_names = c("date", "time", "wbgt"),
                      col_types = readr::cols(
                        date = readr::col_date(format = "%Y/%m/%d"),
                        time = readr::col_character(),
                        wbgt = readr::col_double())
      ) %>% 
      dplyr::mutate(type = "observe",
                    station_no = .station_no,
                    time = hms::as_hms(paste0(time, ":00"))) %>% 
      dplyr::relocate(type, .before = 1) %>% 
      dplyr::relocate(station_no, .before = wbgt)
  } else if (file_type %in% c("2-B", "2-C", "2-D")) {
    df <- 
      readr::read_csv(path,
                      col_types = readr::cols(
                        .default = readr::col_double(),
                        Date = readr::col_date(format = "%Y/%m/%d"),
                        Time = readr::col_character())) 
    if (file_type %in% c("2-B", "2-C")) {
      df <-
        df %>% 
        tidyr::pivot_longer(cols = seq.int(3, ncol(df)),
                            names_to = "station_no",
                            values_to = "wbgt") %>% 
        dplyr::rename(date = Date,
                      time = Time) %>% 
        dplyr::mutate(type = "observe",
                      time = hms::as_hms(paste0(time, ":00"))) %>% 
        dplyr::relocate(type, .before = 1)
    } else if (file_type == "2-D") {
      if (is.null(.station)) {
        .station <- 
          stringr::str_remove_all(path,
                                  ".+/") %>% 
          stringr::str_remove_all("_.+")        
      }
      df <- 
        df %>% 
        purrr::set_names(c("date", "time", "wbgt", "tg")) %>% 
        dplyr::mutate(type = "observe",
                      station = .station,
                      time = hms::as_hms(paste0(time, ":00"))) %>% 
        dplyr::relocate(type, .before = 1) %>% 
        dplyr::relocate(station, .after = type)
    }
  }
  df
}
