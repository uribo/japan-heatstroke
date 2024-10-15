library(dplyr)
library(ggplot2)
# 熱中症による死亡数の年次推移（平成7年~令和2年）
# https://www.mhlw.go.jp/toukei/saikin/hw/jinkou/tokusyu/necchusho20/dl/nenrei.pdf
df <-
  bind_rows(
    readr::read_csv(here::here("data-raw/vital_stats_hs_mortality.csv"),
                    col_types = "cccii") |> 
      filter(place == "総数",
             gender == "総数",
             age_class == "総数") |> 
      select(year, count = value),
    tibble::tibble(
      year = c(seq.int(2014, 2007),
               2005,
               2000,
               1995),
      count = c(529, 1077, 727, 948, 1731,
                236, 569, 904,
                328, 207, 318))
  )
  
# df |> 
#   ggplot() +
#   aes(year, count) +
#   geom_bar(stat = "identity")
