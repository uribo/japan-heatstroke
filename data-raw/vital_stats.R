###############################
# 【厚生労働省】人口動態統計
# 2015~2021年の熱中症（X30 自然の過度の高温への曝露）死亡数
###############################
if (!file.exists(here::here("data-raw/vital_stats_hs_mortality.csv"))) {
  library(estatapi)
  library(dplyr)
  estatapi::estat_getStatsList(appId = Sys.getenv("ESTAT_TOKEN"),
                               surveyYears = 2021,
                               lang = "J",
                               statsCode = "00450011",
                               searchWord = "交通事故以外の不慮の事故") |> 
    select(`@id`, TITLE, SURVEY_DATE)
  
  # 0003412009: 交通事故以外の不慮の事故（Ｗ00－Ｘ59）による死亡数，年齢（特定階級）・外因（三桁基本分類）・性・発生場所別 ---
  d_s4 <- 
    estatapi::estat_getStatsData(appId = Sys.getenv("ESTAT_TOKEN"),
                                 statsDataId = "0003412009",
                                 lang = "J")
  d_s4_tiny <- 
    d_s4 |>
    filter(tab_code == "10100", # 表章項目: 死亡数
           cat03_code == "20X3090X39X300000000", # 死因基本分類_4: X30_自然の過度の高温への曝露
           unit == "人") |>
    select(!c(tab_code, `表章項目`,
              cat03_code, `死因基本分類_4`, 
              time_code, unit)) |> 
    select(!c(cat01_code, cat02_code, cat04_code, annotation)) |> 
    mutate(`時間軸(年次)` = stringr::str_remove(`時間軸(年次)`, "年$") |> 
             as.integer()) |> 
    purrr::set_names(c("place", "gender", "age_class", "year", "value"))
  
  d_s4_tiny |> 
    readr::write_csv(here::here("data-raw/vital_stats_hs_mortality.csv"))
}

# # 0003411706: 交通事故以外の不慮の事故（Ｗ00－Ｘ59）による死亡数，年齢（特定階級）・外因（三桁基本分類）・発生場所別---
# d_s5 <- 
#   estatapi::estat_getStatsData(appId = Sys.getenv("ESTAT_TOKEN"),
#                                statsDataId = "0003411706")
# d_s5 |> 
#   filter(tab_code == "10100",
#          cat01_code == "00100",
#          cat02_code == "20X3090X39X300000000",
#          cat03_code == "00100",
#          unit == "人") |> 
#   select(!c(tab_code, cat01_code, cat02_code, cat03_code, 
#             `表章項目`, `発生場所`, `死因基本分類_4`, `年齢(特定階級)`,
#             time_code, unit))
