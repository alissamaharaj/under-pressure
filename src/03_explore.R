library(dplyr)
library(ggplot2)

# Loads clean adults data
adults_clean <- readRDS("data/adults_clean.rds")

# Creates summary table for smoking status
smokes_summary <- adults_clean |>
  group_by(smokes) |>
  summarize(n=n(), mean_sbp=mean(sbp_later, na.rm = TRUE), sd_sbp=sd(sbp_later, na.rm = TRUE))

# Creates summary table for sex
sex_summary <- adults_clean |>
  group_by(RIAGENDR) |>
  summarize(n=n(), mean_sbp=mean(sbp_later, na.rm = TRUE), sd_sbp=sd(sbp_later, na.rm = TRUE))

# Creates histogram of Later Systolic BP in adults
ggplot(adults_clean, aes(x = sbp_later)) + geom_histogram(binwidth = 5) + labs(title = "Later systolic BP in adults", x="(mmHg)", y="Number of adults")

# Creates histogram of Body Mass Index in adults
ggplot(adults_clean, aes(x = BMXBMI)) + geom_histogram(binwidth = 2) + labs(title = "Body Mass Index in adults", x="(kg/m²)", y="Number of adults")

# Creates histogram of Total Cholesterol in adults
ggplot(adults_clean, aes(x = LBXTC)) + geom_histogram(binwidth = 10) + labs(title = "Total Cholesterol in adults", x="(mg/dL)", y="Number of adults")

# Creates histogram of Age in adults
ggplot(adults_clean, aes(x = RIDAGEYR)) + geom_histogram(binwidth = 5) + labs(title = "Age in adults", x="(years)", y="Number of adults")

# Creates boxplot for Later Systolic BP in adults by Smoking status
ggplot(adults_clean, aes(x = smokes, y = sbp_later)) + geom_boxplot() + labs(title ="Later systolic BP in adults by Smoking status", x="Smoking status", y="(mmHg)")

# Creates boxplot for Later Systolic BP in adults by Sex
ggplot(adults_clean, aes(x = RIAGENDR, y = sbp_later)) + geom_boxplot() + labs(title ="Later systolic BP in adults by Sex", x="Sex", y="(mmHg)")

# Creates scatterplot for Later Systolic BP in adults by Age
ggplot(adults_clean, aes(x = RIDAGEYR, y = sbp_later)) + geom_point(alpha = 0.1) + geom_smooth(method = "lm") + labs(title ="Later systolic BP in adults by Age", x="(years)", y="(mmHg)")

# Creates scatterplot for Later Systolic BP in adults by Body Mass Index
ggplot(adults_clean, aes(x = BMXBMI, y = sbp_later)) + geom_point(alpha = 0.05) + geom_smooth() + labs(title ="Later systolic BP in adults by Body Mass Index", x="(kg/m²)", y="(mmHg)")

# Creates scatterplot for Later Systolic BP in adults by Total Cholesterol
ggplot(adults_clean, aes(x = LBXTC, y = sbp_later)) + geom_point(alpha = 0.05) + geom_smooth() + labs(title ="Later systolic BP in adults by Total Cholesterol", x="(mg/dL)", y="(mmHg)")
