library(dplyr)

# Loads joined table
dsbpt <- readRDS("data/dsbpt.rds")

# Filters by age for adults
adults <- filter(dsbpt, RIDAGEYR >= 18)

# Adds column to adults assigning smoker status
adults <- mutate(adults, smokes = case_when(
  SMQ020 == "No" ~ "never",
  SMQ020 == "Yes" & SMQ040 == "Not at all" ~ "former",
  SMQ020 == "Yes" & SMQ040 %in% c("Every day", "Some days") ~ "current",
  SMQ020 %in% c("Refused", "Don't know") | is.na(SMQ020) | SMQ020 == "Yes" & is.na(SMQ040) ~ NA_character_
))

# Converts smokes to a factor
adults <- mutate(adults, smokes = factor(smokes, levels = c("never", "former", "current")))

# Adds column to adults duplicating BPXOSY1 as sbp_first
adults <- mutate(adults, sbp_first = BPXOSY1)

# Adds column to adults giving mean of BPXOSY2 and BPXOSY3 as sbp_later
adults <- mutate(adults, sbp_later = rowMeans(adults[, c("BPXOSY2", "BPXOSY3")], na.rm = TRUE))

# Overwrites sbp_later to replace NaN (both later readings missing) with a real NA
adults <- mutate(adults, sbp_later = case_when(
  is.nan(sbp_later) ~ NA_real_,
  TRUE ~ sbp_later
))

# Pulls necessary columns of cleaned data as adults_clean
adults_clean <- select(adults, SEQN, RIDAGEYR, RIAGENDR, BMXBMI, smokes, LBXTC, sbp_first, sbp_later)

# Saves the clean data as a pullable object for further scripts to use
saveRDS(adults_clean, file = "data/adults_clean.rds")