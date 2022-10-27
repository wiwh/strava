library(tidyverse)
if(!("data_load" %in% ls())) data_load <- read_csv("../data/all_activities_df.csv")

summarize_watts <- function(data, quantile = 0) {
  summary_watts <- data %>% group_by(activity_id) %>% summarize(across(watts, ~ mean(., na.rm=T)))
  summary_watts %>% filter(watts > quantile(watts, quantile, na.rm = T)) %>% arrange(desc(watts))
}

(watts_summary <- summarize_watts(data_load, quantile = 0.9))
