library(nhanesA)
library(tidyverse)

# Pulls DEMO_L (Demographics) table as demo
demo <- nhanes("DEMO_L")

# Pulls SMQ_L (Smoking) table as smq
smq <- nhanes("SMQ_L")

# Pulls BMX_L (Body Measures) table as bmx
bmx <- nhanes("BMX_L")

# Pulls BPXO_L (Blood Pressure) table as bpxo
bpxo <- nhanes("BPXO_L")

# Pulls TCHOL_L (Cholesterol) table as tchol
tchol <- nhanes("TCHOL_L")

# Using left_joins on SEQN for each table so all 11933 demo rows are kept

# Joins smq to demo as ds
ds <- left_join(demo, smq, by = "SEQN")

# Joins bmx to ds as dsb
dsb <- left_join(ds, bmx, by = "SEQN")

# Joins bpxo to dsb as dsbp
dsbp <- left_join(dsb, bpxo, by = "SEQN")

# Joins tchol to dsbp as dsbpt
dsbpt <- left_join(dsbp, tchol, by = "SEQN")

# Saves the joined table so 02_clean.R can load it without re-pulling from CDC
dir.create("data", showWarnings = FALSE)
saveRDS(dsbpt, file = "data/dsbpt.rds")