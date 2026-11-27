# Loads clean adults data
adults_clean <- readRDS("data/adults_clean.rds")

# Builds multiple linear regression model on sbp_later using predictors age, gender, BMI, smoking status, and cholesterol
model <- lm(sbp_later~RIDAGEYR+RIAGENDR+BMXBMI+smokes+LBXTC, adults_clean)

# Summarizes model
model_summary <- summary(model)

# Confidence intervals for model
modelconf <- confint(model)