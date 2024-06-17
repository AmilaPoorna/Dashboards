#install.packages("dplyr")
library(dplyr)
#install.packages("lubridate")
library(lubridate)

data <- read.csv("Metro_Interstate_Traffic_Volume.csv")

View(data)
attach(data)

str(data)

summary(data)

missing_values <- colSums(is.na(data))
print(missing_values)

cleaned_data <- data %>%
  mutate(weather_description = case_when(
    weather_description == "Sky is Clear" ~ "sky is clear",
    TRUE ~ weather_description
  ))

duplicate_rows <- data[duplicated(cleaned_data), ]
print(duplicate_rows)

#Since date_time was a unique variable, duplicate rows were dropped.
cleaned_data <- distinct(cleaned_data)

cleaned_data$date_time <- ymd_hms(cleaned_data$date_time)

#cleaned_data$date <- as.Date(cleaned_data$date_time)
#cleaned_data$time <- format(cleaned_data$date_time, "%H:%M:%S")

#cleaned_data <- subset(cleaned_data, select = -date_time)

remove_outliers <- function(df, vars, threshold = 3) {
  outliers <- numeric()
  for (var in vars) {
    z_scores <- abs(scale(df[[var]]))
    outliers <- c(outliers, which(z_scores > threshold))
  }
  df[-outliers, ]
}

variables <- c("temp", "rain_1h")

cleaned_data <- remove_outliers(cleaned_data, variables)

View(cleaned_data)

saveRDS(cleaned_data, file = "data/data.rds")