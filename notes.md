**START**

*2026-11-16: This project is a regression model using NHANES public health blood pressure data to determine which factors are associated with systolic blood pressure in adults, considering age, sex, BMI, smoking, and cholesterol.

This GitHub repository was created with this notes file, and the main folders were committed with placeholder `.gitkeep` files. The `data/` folder was added to `.gitignore` so it remains uncommitted.

The `nhanesA` and `tidyverse` packages were installed in my R environment; both of those packages and the `rmarkdown` package were loaded.

The NHANES information on the CDC website was used to determine which cycle to use; 08/2021-08/2023 was selected as it is the most recent, completed NHANES dataset. The file suffix for this cycle is `_L`. The cycle's data page was used to determine the filenames, variables, and special missing codes for the relevant factors:
- Demographics - `DEMO_L`:
  - Linkage ID - `SEQN`
  - Age - `RIDAGEYR`, range `0` - `80` (80 is a top value which encompasses 80+)
  - Sex - `RIAGENDR`, `1` = Male, `2` = Female
- Body Measures - `BMX_L`:
	- BMI - `BMXBMI`, range `11.1` to `74.8`
- Blood Pressure - `BPXO_L`:
	- BP Readings (Age 8+) :
		- Systolic - `BPXOSY1`, `BPXOSY2`, `BPXOSY3`
		- Diastolic - `BPXODI1`, `BPXODI2`, `BPXODI3`
- Smoking - `SMQ_L`:
	- Adult Cigarette Items (18+):
		- `SMQ020` (Smoked at least 100 cigarettes in life: `1` = Yes, `2` = No). Special missing codes: `7` (Refused), `9` (Don't know)
		- `SMQ040` (Do you now smoke cigarettes: `1` = Every day, `2` = Some days, `3` = Not at all). Special missing codes: `7` (Refused), `9` (Don't know)
		- `SMD641` (Days smoked cigarettes during past 30 days, `0`–`30`). Special missing codes: `77` (Refused), `99` (Don't know)
		- `SMD650` (Average cigarettes/day during past 30 days, `1`–`95`+). Special missing codes: `777` (Refused), `999` (Don't know)
	- Youth Cigarette Items (12-17):
		- `SMQ621` (Cigarettes smoked in entire life: `1` = Never through `8` = 100 or more). Special missing codes: `77` (Refused), `99` (Don't know)
- Cholesterol - `TCHOL_L`:
	- Linkage ID - `SEQN`
	- Survey Weight - `WTPH2YR`, Phlebotomy 2-year sample weight, `4391.82` to `241728.86`; `0` = not blood-drawn
	- Total Cholesterol (Primary) - `LBXTC`, Total cholesterol in mg/dL, participants aged 6+ years; continuous range `62` to `438` mg/dL; LLOD = `4` mg/dL
	- Total Cholesterol (SI Units): `LBDTCSI`, Total cholesterol in mmol/L, calculated as LBXTC × `0.02586`; continuous range `1.60` to `11.33` mmol/L

For the adult smoking data, `current`, `former`, and `never` smokers are resolved as follows based on the skipping pattern of the questionnaire:
- `never`: `SMQ020` = `2`
- `former`: `SMQ020` = `1` and `SMQ040` = `3`
- `current`: `SMQ020` = `1` and `SMQ040` = `1` or `2`
- `missing`: `SMQ020` = `7`, `9` or blank (for adults), or `SMQ020` = `1` with a blank, `7` or `9` on `SMQ040`

A blank `SMQ040` is structural for never-smokers and truly missing otherwise, so the recode must start from `SMQ020`, never from `SMQ040` alone.

This will be used as a reference key.

*2026-11-17: Created an R script (placeholder...insert lou) to load the `DEMO_L` table and return the dataframe dimensions and variables. 

`DEMO_L` was checked for unique `SEQN` values and confirmed to have 11933 rows and 27 columns, all with unique `SEQN` values. The smoking data has 9015 rows and 9 columns.

Then I checked the age data for participants under the age of 12 (since the smoking data was said to start at 12); this returned 2545 participants, but this leaves 9388 rows, which leaves 373 rows unaccounted for in the difference between the age 12+ participants and the smoking data.

I checked for 'NA' ages to ensure the discrepancy did not come from participants with unrecorded ages; this check found no participants with unrecorded ages.

The smoking data was checked and confirmed that all `SEQN` values were also unique and all present in the total cycle data. The age range was also confirmed to be 12-80. The ages of the 373 participants were checked, and the range was 12-17, meaning all missing participants were under 18, making all adults accounted for in the smoking data. This project will only use adult data, so the 373-row discrepancy does not affect the project scope.

Hitches encountered: when trying to determine the number of participants with age below 12, I attempted to use `nrow()` on the query, which returned `NULL` since the query returned a logical vector; this was resolved by using the `sum()` function to add the number of returned TRUE/FALSE values.
