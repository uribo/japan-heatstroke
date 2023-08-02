################################
# Google Trends
# 実行日: 2023-08-02
################################
library(dplyr)
library(ggplot2)
x <-
  gtrendsR::gtrends(keyword = "熱中症",
                    geo = "JP",
                    time = "all")
rds_path <- 
  glue::glue("data/gtrends_{day_min}-{day_max}.rds",
             day_min = stringr::str_remove_all(as.character(min(x$interest_over_time$date)), "-"), 
             day_max = stringr::str_remove_all(as.character(max(x$interest_over_time$date)), "-"))
readr::write_rds(x, 
                 here::here(rds_path),
                 compress = "xz")
usethis::use_git_ignore(rds_path)

rds_path

# 2004-01-01 to 2023-07-01
x$interest_over_time$date %>% range()

x$interest_over_time %>% 
  tibble::as_tibble() %>% 
#  filter(between(lubridate::year(date), 2017, 2019)) %>% 
  mutate(hits = if_else(hits == "<1", "0.5", hits) %>% 
           as.numeric()) %>% 
  ggplot() +
  aes(date, hits) +
  geom_line() +
  labs(title = "Google Trends上での「熱中症」への関心",
       subtitle = "2004-01-01から2022-08-01")
