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

*2026-11-20: I added some lines to the end of the pull_and_join script so that it saves the joined table as an object that can be called by the data cleaning script instead of calling and running the entire script every time to avoid always having to pull from the CDC, which requires an online connection and is slow. This means if the pull_and_join script is ever changed, it must be rerun to regenerate a new `dsbpt` table object before the cleaning script is used. This generated file lives in the `data/` directory, which is gitignored.

Hitch encountered at this point: the script generated a new data folder with the file inside it because my working directory was not set to my repo root, fixed by setting the repo root as the working directory and rerunning the script.

Then I created [02_clean.R](https://github.com/alissamaharaj/under-pressure/blob/main/src/02_clean.R), the data cleaning script. I pulled the `dsbpt` table object from the generated data file and ran some quick sanity checks to make sure it was loaded as expected; the dimensions and class matched as expected.

Then I filtered the table by age to get adult rows only; the adult row count is 8153, and the filter rule is ">= 18", with 80 as a top code; a hitch here was that I attempted to use the `filter()` function by passing the arguments incorrectly. I passed a logical vector instead of the dataframe as the first argument and the bare column as the second.

Using the filtered data, I created a table of the smoking questionnaire data counts, including NA rows, which returned this result:
```
Yes         No    Refused Don't know       <NA> 
3243       4878          7          7         18
```

I added a column to the adults data to show smoker status derived from `SMQ020` first, in terms of 'never/former/current'; this includes the 32 adults NA: (18 blank, 7 Refused, 7 Don’t know). Hitches here were that, when setting the `case_when` for the column, I used `|` where `&` was needed, and I tried to hardcode "NA" as a string instead of `NA_character_`. I also had trouble trying to include the factor conversion nested in the initial `mutate` call, but ultimately decided that adding a second call to overwrite the first with the factor conversion was cleaner. This was the resulting table from the resulting column:
```
  never  former current    <NA> 
   4878    2053    1190      32
```

I ran a few sanity checks on the blood pressure and cholesterol tables to make sure there were no special codes in the columns, only values; I checked the completeness of the blood pressure readings to check participant count by number of readings; the result of this check was:
```
0    1    2    3 
6100   17    6 2030
```
with '0' being no missing readings and '3' being no readings.

Then, pulling the `RIDSTATR` table and checking to evaluate the NA counts per reading for the exam data to confirm that every adult who was interviewed only was assigned 'NA' and to determine the "Examined but NA" counts. The results were:
```
Interviewed only Both interviewed and MEC examined 
1816                              6337
```

```
Variable	Adult NAs	Never examined	Examined, but NA
BMXBMI			1,918			1,816				102
BPXOSY1			2,030			1,816				214
LBXTC			2,436			1,816				620
```

This count includes adults absent from BPXO_L or TCHOL_L and adults present but blank. The BP NA count also confirms that all 23 partial-reading adults have reading 1 present, since the NA count matches exactly the 3 readings missing count from the previous check.

Next, for the blood pressure data, I decided that when calculating the means, the first reading will always be excluded and treated as a control value to account for deviations in initial readings due to the white-coat effect, etc., and use readings 2 and 3 to calculate the mean; in cases where only one other value is present, it serves as the mean on its own; in cases where reading 1 is the only value available, the mean is NA.

Then I added two columns to the adults data, `sbp_first`, which copies the first reading, and `sbp_later`, which gives the mean of the other readings based on the criteria I just outlined. `rowMeans` gives `NaN` when both later readings are missing, so a second `mutate` is used to convert these to real NAs. This gives 2036 'NA' rows, where 2030 have no readings, and 6 have reading 1 as the only reading.

Hitch: I tried to use `==` where `~` was required in a `case_when` assignment block when writing the `mutate` to give `NA_real_` objects to the empty mean rows.

*2026-11-21: I confirmed that the `RIAGENDR` data gives a factor with readable labels, so no refactor was needed like I had to do for the smoking data. It gives a row count of 8153 with no NAs, which covers all the adult data. "Male" is the first level of `RIAGENDR` so it is the regression reference, and the sex coefficient will be "Female" relative to "Male".

I built the object `adults_clean` consisting of the `SEQN`, `RIDAGEYR`, `RIAGENDR`, `BMXBMI`, `smokes`, `LBXTC`, `sbp_first`, and `sbp_later` columns and did sanity checks for the number of rows and the number of NAs for each, which gave the expected outputs. All adults in adults_clean, with no rows dropped, so the paired test and the model share one object. I also checked the number of complete cases for the model variables: `RIDAGEYR`, `RIAGENDR`, `BMXBMI`, `smokes`, `LBXTC`, and `sbp_later`, which gave a count of 5483 and will serve as the sample size for the regression. A derived 2670 participants are missing compared to the total row count because, alongside those interviewed only and those with incomplete SBP readings, there are a large number with NA cholesterol tests (2436). All 2,436 cholesterol-NA rows are within the 2,670, which leaves 234 dropped for other reasons (derived, not observed).

The clean data object is saved as a file, `adults_clean.rds`, in the `data/` folder so further scripts can pull it.

Hitch: I did not have the necessary library package `dplyr` loaded at the top of the script, but there were no errors raised since I only tested it by running the pull and join script first in the same session. I resolved this by adding a line at the top of the script to load the library and then ran the clean.R script only from a clean session to confirm that it works on its own.

*2026-11-23: Created [03_explore.R](https://github.com/alissamaharaj/under-pressure/blob/main/src/03_explore.R), loaded the `adults_clean` dataframe, and created summary tables for smoking status and sex.

Then, the histograms for 'Later Systolic BP in adults', 'Body Mass Index in adults', 'Total Cholesterol in adults', and 'Age in adults' were created.

After that were the boxplots for 'Later Systolic BP in adults by Smoking status' and 'Later Systolic BP in adults by Sex'.

Lastly, the scatterplots for 'Later Systolic BP in adults by Age', 'Later Systolic BP in adults by Body Mass Index', and 'Later Systolic BP in adults by Total Cholesterol' were created.

The NA smoking group (32 adults) was kept in the summary table and the boxplot; `n` in the summary tables means group size, not the count behind each mean; and the warnings for removed rows for each plot matched the number of NA rows every time.

Notable results from the plots were:
- sbp_later and BMI are right-skewed.
- The spread of sbp_later widens with age.
- The BMI smoother looks curved; curvature and widening spreads matter for future residual plots.
- 525 adults sit at the age 80 top code; this will go in `Limitations`.
- Cholesterol shows a weak association with sbp_later in the plot.

*2026-11-25: Created [04_tests.R](insert lou),  loaded the `adults_clean` dataframe, and filtered for rows with both `sbp_first` and `sbp_later`, giving 6117 rows. I used `mutate` to add a `sbp_diff` column to this filtered dataframe, which gives the difference in the SBP values, and then created a summary table and histogram of `sbp_diff`.

Hitch: I accidentally added a `group_by(sbp_diff)` which made one group per distinct value, so `sd` came back NA.

*2026-11-26: Tests done:
- t.test for the mean difference between sbp_first and sbp_later from paired
- two-sample test comparing sbp_later by sex
- variance test on smoking status and sbp_later with Tukey's Honestly Significant Difference test
- chi-squared test of blood pressure and smoking status, cutoff 120 chosen from a 2025 [study](https://pmc.ncbi.nlm.nih.gov/articles/PMC12032999/) that associates SBP values under 120 with reduced mortality, >= puts exactly 120 in the upper group, and the levels are named neutrally ("below 120", "120 or above") 
- correlation tests on age, BMI, and cholesterol

The smoking tests drop the NA-smoking adults automatically, and the correlations drop incomplete pairs.

When the script was complete, it was run from a clean session and passed as expected.
