################################
# Google Trends
# 実行日: 2022-09-02
################################
library(dplyr)
library(ggplot2)
x <-
  gtrendsR::gtrends(keyword = "熱中症",
                    geo = "JP",
                    time = "all")
readr::write_rds(x, here::here("data/gtrends_20040101-20220801.rds"),
                 compress = "xz")
usethis::use_git_ignore("data/gtrends_20040101-20220801.rds")

# 2004-01-01 to 2022-08-01
x$interest_over_time$date %>% range()

x$interest_over_time %>% 
  tibble::as_tibble() %>% 
  filter(between(lubridate::year(date), 2017, 2019)) %>% 
  mutate(hits = if_else(hits == "<1", "0.5", hits) %>% 
           as.numeric()) %>% 
  ggplot() +
  aes(date, hits) +
  geom_line() +
  labs(title = "Google Trends上での「熱中症」への関心",
       subtitle = "2004-01-01から2022-08-01")
