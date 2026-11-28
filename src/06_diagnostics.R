library(ggplot2)
library(dplyr)

# Loads clean adults data
adults_clean <- readRDS("data/adults_clean.rds")

# Builds multiple linear regression model on sbp_later using predictors age, sex, BMI, smoking status, and cholesterol
model <- lm(sbp_later~RIDAGEYR+RIAGENDR+BMXBMI+smokes+LBXTC, adults_clean)

# Builds model dataframe with columns for residuals and fitted
model_df <- model.frame(model) |>
  mutate(ftd=fitted(model),res=residuals(model))

# Creates residuals scatterplot against fitted
ggplot(model_df, aes(x=ftd, y=res)) + geom_point(alpha = 0.1) + geom_hline(yintercept = 0) + geom_smooth()

# Creates residuals scatterplot against BMI
ggplot(model_df, aes(x=BMXBMI, y=res)) + geom_point(alpha = 0.05) + geom_hline(yintercept = 0) + geom_smooth()

# Creates residuals scatterplot against age
ggplot(model_df, aes(x=RIDAGEYR, y=res)) + geom_point(alpha = 0.1) + geom_hline(yintercept = 0) + geom_smooth()

# Creates histogram of residuals
ggplot(model_df, aes(x=res)) + geom_histogram(binwidth = 5) 

# Creates qq plot of residuals 
ggplot(model_df, aes(sample=res)) + geom_qq() + geom_qq_line()

# Adds cooks distance column to model_df
model_df <- mutate(model_df, cooks=cooks.distance(model))