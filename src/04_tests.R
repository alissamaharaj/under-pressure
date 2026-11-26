library(dplyr)
library(ggplot2)

# Loads clean adults data
adults_clean <- readRDS("data/adults_clean.rds")

# Filters for rows with both sbp_first and sbp_later
paired <- adults_clean |>
  filter(!is.na(sbp_later) & !is.na(sbp_first))

# Adds sbp_diff column to paired assigning the difference in sbp_first and sbp_later 
paired <- mutate(paired, sbp_diff = sbp_first - sbp_later)

# Creates summary table for sbp_diff
diff_summary <- paired |>
  summarize(n=n(), mean_diff=mean(sbp_diff), sd_diff=sd(sbp_diff))

# Creates histogram of Systolic BP Difference in adults
ggplot(paired, aes(x = sbp_diff)) + geom_histogram(binwidth = 5) + labs(title = "Systolic BP Difference in adults", x="(mmHg)", y="Number of adults")

# Tests the mean difference between sbp_first and sbp_later from paired
sbp_ttest <- t.test(x=paired$sbp_first, y=paired$sbp_later, paired=TRUE)

# Compares sbp_later by sex using two sample test
sex_ttest <- t.test(sbp_later ~ RIAGENDR, data=adults_clean)

# Variance test on smoking status and sbp_later
smokes_aov <- aov(sbp_later~smokes, data=adults_clean)

# Tukey's Honestly Significant Difference test on smokes_aov
tuk_smokes <- TukeyHSD(smokes_aov)

# Creates adults_bp with a blood pressure category from sbp_later (cutoff 120)
adults_bp <- adults_clean |>
  mutate(bp_cat = case_when(
    is.na(sbp_later) ~ NA_character_,
    sbp_later < 120 ~ "below 120",
    TRUE ~ "120 or above"
  )) |>
  mutate(bp_cat = factor(bp_cat, levels = c("below 120", "120 or above")))

# Cross-tabulates smoking status against the blood pressure category
smokes_bp_table <- table(adults_bp$smokes, adults_bp$bp_cat)

# Shows the share in each blood pressure category within each smoking group
smokes_prop_table <- round(prop.table(smokes_bp_table, margin = 1), 3)

# Chi squared test of smokes_bp_table
chisq_smokes <- chisq.test(smokes_bp_table)

# Correlation of sbp_later with age (Pearson)
cor_age <- cor.test(x = adults_clean$RIDAGEYR, y = adults_clean$sbp_later)

# Correlation of sbp_later with BMI (Pearson)
cor_bmi <- cor.test(x = adults_clean$BMXBMI, y = adults_clean$sbp_later)

# Correlation of sbp_later with cholesterol (Pearson)
cor_chol <- cor.test(x = adults_clean$LBXTC, y = adults_clean$sbp_later)

# Rank-based check of sbp_later with BMI (Spearman), since the BMI relationship looked curved
cor_bmi_sp <- cor.test(x = adults_clean$BMXBMI, y = adults_clean$sbp_later,
                       method = "spearman", exact = FALSE)
