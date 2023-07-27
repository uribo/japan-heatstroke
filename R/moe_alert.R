read_moe_alert <- memoise::memoise(
  function(year) {
    if (lubridate::year(lubridate::today()) == year) {
      tgt_url <- 
        "https://www.wbgt.env.go.jp/alert_record.php"
    } else {
      tgt_url <-
        glue::glue("https://www.wbgt.env.go.jp/alert_record_{year}.php")    
    }
    x <- 
      rvest::read_html(tgt_url)
    x |> 
      rvest::html_nodes(css = "#maincontent > div > table") |> 
      rvest::html_table() |> 
      purrr::pluck(1)
  })

alert_to_long <- function(df, year) {
  df |> 
    purrr::set_names(
      c(names(df)[1:2],
        paste0(
          year,
          "/",
          names(df)[3:ncol(df)],
          " ",
          paste0(c(5, 17), ":00:00")
        ))
    ) |> 
    dplyr::slice(-1) |>  
    tidyr::pivot_longer(cols = contains("/"),
                        names_to = "datetime",
                        values_to = "alert") |> 
    readr::type_convert("cdcc") |> 
    dplyr::mutate(datetime = lubridate::as_datetime(datetime),
                  alert = dplyr::if_else(alert == "\u25cf",
                                         TRUE,
                                         FALSE))
}
