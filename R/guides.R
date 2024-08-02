# wbgt_guideline(31)
# wbgt_guideline(30)
# wbgt_guideline(25)
# wbgt_guideline(18)
wbgt_guideline <- function(x, lang = "ja") {
  lang <-
    rlang::arg_match(lang, c("ja", "en"))
  l <-
    list(
      ja = c(
        "危険",
        "厳重警戒",
        "警戒",
        "注意"
      ),
      en = c(
        "Danger",
        "Severe Warning",
        "Warning",
        "Caution"
      )
    )
  l <- 
    switch (lang,
            "ja" = l$ja,
            "en" = l$en)
  
  dplyr::case_when(
    x >= 31 ~ l[[1]],
    dplyr::between(x, 28, 30) ~ l[[2]],
    dplyr::between(x, 25, 27) ~ l[[3]],
    x < 25 ~ l[[4]]
  )  
}
