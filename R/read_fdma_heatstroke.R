read_fdma_heatstroke <- function(path, sheets = NULL, nest = TRUE) {
  if (is.null(sheets)) {
    sheets <- 
      readxl::excel_sheets(path)
  }
  sheets |> 
    purrr::map(
      function(.x) {
        ncols <-
          ncol(readxl::read_xlsx(path, sheet = .x, n_max = 1))
        if (ncols == 14L) {
          df <- 
            readxl::read_xlsx(path, sheet = .x) |> 
            dplyr::select(seq_len(14)) |> 
            purrr::set_names(
              c("日付",
                            "都道府県コード",
                            "搬送人員（計）", 
                            paste("年齢区分",
                                  c("新生児", "乳幼児", "少年",
                                    "成人", "高齢者", "不明"),
                                  sep = "："),
                            paste("傷病程度",
                                  c("死亡", "重症", "中等症", 
                                    "軽症", "その他"),
                                  sep = "："))
            )
          if (nest == TRUE) {
            df <- 
              df |> 
              tidyr::nest(age_class   = tidyselect::starts_with("年齢区分"),
                          status_type = tidyselect::starts_with("傷病程度"))
          }
        } else if (ncols == 21L) {
          df <-
            readxl::read_xlsx(path, 
                              sheet = 1,
                              skip  = 1,
                              col_names = c("日付",
                                            "都道府県コード",
                                            "搬送人員（計）", 
                                            paste("年齢区分",
                                                  c("新生児", "乳幼児", "少年",
                                                    "成人", "高齢者"),
                                                  sep = "："),
                                            paste("傷病程度",
                                                  c("死亡", "重症", "中等症", 
                                                    "軽症", "その他"),
                                                  sep = "："),
                                            paste("発生場所",
                                                  c("住居", "仕事場\u2460", "仕事場\u2461",
                                                    "教育機関", "公衆(屋内)", 
                                                    "公衆(屋外)", "道路", "その他"),
                                                  sep = "：")),
                              col_types = c("date",
                                            "text",
                                            rep("numeric", 19)))
        } else if (ncols == 22L) {
          df <-
            readxl::read_xlsx(path, 
                              sheet = .x,
                              skip  = 1,
                              col_names = c("日付",
                                            "都道府県コード",
                                            "搬送人員（計）", 
                                            paste("年齢区分",
                                                  c("新生児", "乳幼児", "少年",
                                                    "成人", "高齢者", "不明"),
                                                  sep = "："),
                                            paste("傷病程度",
                                                  c("死亡", "重症", "中等症", 
                                                    "軽症", "その他"),
                                                  sep = "："),
                                            paste("発生場所",
                                                  c("住居", "仕事場\u2460", "仕事場\u2461",
                                                    "教育機関", "公衆(屋内)", 
                                                    "公衆(屋外)", "道路", "その他"),
                                                  sep = "：")),
                              col_types = c("date",
                                            "text",
                                            rep("numeric", 20)))

          if (nest == TRUE) {
            df <- 
              df |> 
              tidyr::nest(age_class   = tidyselect::starts_with("年齢区分"),
                          status_type = tidyselect::starts_with("傷病程度"),
                          place_type  = tidyselect::starts_with("発生場所"))
          }
        }
        df |> 
          dplyr::mutate(
            `都道府県コード` = stringr::str_pad(都道府県コード, width = 2, pad = "0"),
            `日付` = lubridate::as_date(日付))
      }
    )
}


read_fdma_heatstroke_all <- function(path) {
  sheets <- 
    readxl::excel_sheets(path)
  purrr::map(
    sheets,
    ~ read_fdma_heatstroke(path,
                           sheets = .x)) |> 
    dplyr::bind_rows() |> 
    dplyr::rename(date = 日付,
                  jis_code = 都道府県コード,
                  value = `搬送人員（計）`)
}

fdma_df_longer <- function(data, column) {
  data |> 
    tidyr::unnest(cols = {{ column }}) |> 
    tidyr::pivot_longer(cols = tidyselect::contains("："),
                        names_to = "type",
                        values_to = "count",
                        names_prefix = ".+：")
}
