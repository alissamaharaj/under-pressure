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

*2026-11-17: Created an R script [01_pull_and_join.R](https://github.com/alissamaharaj/under-pressure/blob/main/src/01_pull_and_join.R) to load and join the data tables.

First, the `DEMO_L` table was loaded, and the dataframe dimensions and variables were returned. 

`DEMO_L` was checked for unique `SEQN` values and confirmed to have 11933 rows and 27 columns, all with unique `SEQN` values. The smoking data has 9015 rows and 9 columns.

Then I checked the age data for participants under the age of 12 (since the smoking data was said to start at 12); this returned 2545 participants, but this leaves 9388 rows, which leaves 373 rows unaccounted for in the difference between the age 12+ participants and the smoking data.

I checked for 'NA' ages to ensure the discrepancy did not come from participants with unrecorded ages; this check found no participants with unrecorded ages.

The smoking data was checked and confirmed that all `SEQN` values were also unique and all present in the total cycle data. The age range was also confirmed to be 12-80. The ages of the 373 participants were checked, and the range was 12-17, meaning all missing participants were under 18, making all adults accounted for in the smoking data. This project will only use adult data, so the 373-row discrepancy does not affect the project scope.

Hitches encountered: when trying to determine the number of participants with age below 12, I attempted to use `nrow()` on the query, which returned `NULL` since the query returned a logical vector; this was resolved by using the `sum()` function to add the number of returned TRUE/FALSE values.

*2026-11-19: Before starting, I ran the script from a clean session to show that it works.

First, I pulled the `demo$RIDSTATR` table, which gave counts for `Interviewed only: 3073` and `Both interviewed and MEC examined: 8860`. According to the CDC website, from the [DEMO_L](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/DEMO_L.htm) page, the RIDSTATR data differentiates thusly:

"RIDSTATR: identifies whether a participant was both interviewed at home or by telephone and examined in the mobile examination center (MEC), or was only interviewed but never participated in the examination.", where `1` = Interviewed only, `2` = Both interviewed and MEC examined.

Then, I pulled the tables `BMX_L`, `BPXO_L` and `TCHOL_L` and checked that there were no duplicated `SEQN` values or any `SEQN` values missing from the `DEMO_L` table for each. Based on the dimensions of these tables, there were 8860, 7801, and 8068 participants, respectively, meaning that all examined participants were in the bmx data, while bpxo (blood pressure) and tchol (cholesterol) each contained a subset of the exam group.

From the CDC website, these were the stated eligibility criteria for the [bpxo](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/BPXO_L.htm) and [tchol](https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/2021/DataFiles/TCHOL_L.htm) samples, respectively:

"Participants aged 8 years and older were eligible. Participants with any of the following on both arms were excluded from the exam: rashes, gauze dressings, casts, edema, paralysis, tubes, open sores or wounds, withered arms, and A-V shunts. Also, women who have had an axillary nodal biopsy or resection, or a unilateral radical mastectomy, do not have their blood pressure measured in the affected arm."

"Examined participants aged 6 years and older were eligible...There are over 800 laboratory tests performed on NHANES participants. However, not all participants provided biospecimens or enough volume for all the tests to be performed."

These may account for the discrepancy in the number of examined participants and the number of participants in the blood pressure and cholesterol data.

Next, I checked the variables present in the blood pressure data to ensure that all 3 readings were present, then moved on to joining the five tables `demo`, `smq`, `bmx`, `bpxo`, and `tchol`, in that order, using individual `left_join`s since they preserve all rows from the left table so all the rows from the total demographic data are preserved and the columns from each other table are added and assigned NA where applicable. The row count was maintained at 11933 through every join, and the dimensions of the final table were 11933 rows x 70 columns.

I then checked the NA counts for `SMQ020`, `BMXBMI`, `BPXOSY1` and `LBXTC`, which are unique primary values for each secondary table; these were:
```
SMQ020  BMXBMI BPXOSY1   LBXTC 
  3798    3462    4416    5043
```

The four NA counts mix people absent from a table with people present but blank, and they cover all ages.

I also did some one-off checks which were not included in the final R script to ensure that the `SEQN` values from each secondary table matched value for value with the demographic table, and did not only match the row counts.

Then I cleaned up the script to remove the test and print lines, ran the trimmed script from a clean session, and did a one-off dimension check on the final result to ensure it was still working as expected, which it was.
