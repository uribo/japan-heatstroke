read_fdma_heatstroke <- function(path, sheets = NULL, nest = TRUE) {
  if (is.null(sheets)) {
    sheets <- 
      readxl::excel_sheets(path)
  }
  sheets %>% 
    purrr::map_dfr(
      function(.x) {
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
                                          rep("numeric", 20))) %>% 
          dplyr::mutate(
            `都道府県コード` = stringr::str_pad(都道府県コード, width = 2, pad = "0"),
            `日付` = lubridate::as_date(日付))
        if (nest == TRUE) {
          df <- 
            df %>% 
            tidyr::nest(age_class   = tidyselect::starts_with("年齢区分"),
                        status_type = tidyselect::starts_with("傷病程度"),
                        place_type  = tidyselect::starts_with("発生場所"))
        }
        df
      }
    )
}
