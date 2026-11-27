# Loads clean adults data
adults_clean <- readRDS("data/adults_clean.rds")

model <- lm(sbp_later~RIDAGEYR+RIAGENDR+BMXBMI+smokes+LBXTC, adults_clean)

model_summary <- summary(model)

modelconf <- confint(model)