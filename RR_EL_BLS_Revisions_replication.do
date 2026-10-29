** Economic Letters Replication for BLS Payroll Revisions: Forecasting Recessions (2026)
** Authors: Roberto Pinhiero, Rory Quinlan


** Note: Berfore running control + H to replace "YOUR_Path\replication" in all locations and Haver_path to your haver path in all locations
	** Set up folder named replication containing folders named Data, Figures, Tables, Raw_Data
	** Ensure Raw_Data folder contains the prvided data for the script

clear
set more off
global topdir "YOUR_Path\replication"
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"

***** First, creating a file for the cfnai in which we keep only the first releases of the index ***********

import excel "`rawdir'\cfnai-realtime-1-xlsx.xlsx", sheet("cfnai_realtime") firstrow
rename A date

preserve
keep date CF112002

tempfile CF
save `CF'
restore

foreach v of varlist _all{
gen to_delete_`v'_1=1 if `v'==. & date==td(01mar1967)
egen to_delete_`v'=max( to_delete_`v'_1)	
drop to_delete_`v'_1
replace `v'=. if to_delete_`v'==1
}

dropmiss, force

merge 1:1 date using `CF'
drop _merge
drop to_delete_*

reshape long CF, i(date) j(vintage)

gen vintage_st  = string(vintage,"%06.0f")

gen month_vintage = substr(vintage_st,1,2)
gen year_vintage = substr(vintage_st,3,.)
destring month_vintage, replace
destring year_vintage, replace

gen vintage_date = ym(year_vintage,month_vintage)
format vintage_date %tm
drop month_vintage year_vintage vintage vintage_st

gen month=month(date)
gen year = year(date)
drop date
gen date=ym(year,month)
format date %tm
drop month year

**** keeping the 2001m1 vintage for dates<2001m1 ********
drop if date<=tm(2001m1) & vintage_date!=tm(2001m1)

gen CF_old=.
replace CF_old=CF if date<=tm(2001m1)
replace CF_old=CF if date==vintage_date
drop if CF==.

keep date CF_old
duplicates drop
drop if CF_old==.

save "`datadir'/CFNAI_part1.dta", replace

clear
import excel "`rawdir'\cfnai-realtime-2-xlsx.xlsx", sheet("cfnai_realtime") firstrow
drop FN
rename Date date

foreach v of varlist _all{
gen to_delete_`v'_1=1 if `v'==. & date==td(31mar1967)
egen to_delete_`v'=max( to_delete_`v'_1)	
drop to_delete_`v'_1
replace `v'=. if to_delete_`v'==1
}

dropmiss, force
drop to_delete_*


reshape long CF, i(date) j(vintage)


gen vintage_st  = string(vintage,"%06.0f")

gen month_vintage = substr(vintage_st,1,2)
gen year_vintage = substr(vintage_st,3,.)
destring month_vintage, replace
destring year_vintage, replace

gen vintage_date = ym(year_vintage,month_vintage)
format vintage_date %tm
drop month_vintage year_vintage vintage 

gen month=month(date)
gen year = year(date)
drop date
gen date=ym(year,month)
format date %tm
drop month year

drop if date<=tm(2011m12)
drop vintage_st

gen CF_old=.
replace CF_old=CF if date==vintage_date
drop if CF==.

keep date CF_old
duplicates drop
drop if CF_old==.

save "`datadir'/CFNAI_part2.dta", replace

clear
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"
import excel "`rawdir'\cfnai-realtime-3-xlsx.xlsx", sheet("cfnai_realtime") firstrow

rename Date date
split date, p("-")
replace date2="01" if date2=="Jan"
replace date2="02" if date2=="Feb"
replace date2="03" if date2=="Mar"
replace date2="04" if date2=="Apr"
replace date2="05" if date2=="May"
replace date2="06" if date2=="Jun"
replace date2="07" if date2=="Jul"
replace date2="08" if date2=="Aug"
replace date2="09" if date2=="Sep"
replace date2="10" if date2=="Oct"
replace date2="11" if date2=="Nov"
replace date2="12" if date2=="Dec"
destring date1, replace
destring date2, replace
destring date3, replace
drop date
gen date=ym(date3,date2)
format date %tm


foreach v of varlist _all{
gen to_delete_`v'_1=1 if `v'==. & date==tm(1967m3)
egen to_delete_`v'=max( to_delete_`v'_1)	
drop to_delete_`v'_1
replace `v'=. if to_delete_`v'==1
}

dropmiss, force
drop to_delete_*


reshape long CF, i(date) j(vintage)


gen vintage_st  = string(vintage,"%06.0f")

gen month_vintage = substr(vintage_st,1,2)
gen year_vintage = substr(vintage_st,3,.)
destring month_vintage, replace
destring year_vintage, replace

gen vintage_date = ym(year_vintage,month_vintage)
format vintage_date %tm
drop month_vintage year_vintage vintage 


drop if date<=tm(2018m12)
drop vintage_st

gen CF_old=.
replace CF_old=CF if date==vintage_date
drop if CF==.

keep date CF_old
duplicates drop
drop if CF_old==.

append using "`datadir'/CFNAI_part2.dta"
append using "`datadir'/CFNAI_part1.dta"
sort date

drop if date<tm(1979m1)
drop if date==tm(2025m8)

 save "`datadir'/CFNAI_First_Read.dta", replace
 
 *********** Doing the same for the ADS index **********
 clear
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"

 import excel "`rawdir'\ADS_All_Vintages-zip.xlsx", sheet("Sheet1") firstrow
split A, p(":")
rename A1 year
rename A2 month
rename A3 day
destring year, replace
destring month, replace
destring day, replace

drop A 

gen date = ym(year, month)
format date %tm

drop year month day

local ADS_group ADS_INDEX_*


collapse (mean) `ADS_group' , by(date)

reshape long ADS_INDEX_, i(date) j(vintage) string

gen month_vintage = substr(vintage,1,2)
gen day_vintage = substr(vintage,3,2)
gen year_vintage = substr(vintage,5,.)

destring month_vintage, replace
destring day_vintage, replace
destring year_vintage, replace
replace year_vintage= 2000+year_vintage

gen vintage_date = ym(year_vintage, month_vintage)
format vintage_date %tm

bysort vintage_date: egen last_day = max(day_vintage)
keep if day_vintage==last_day
keep date ADS_INDEX_ vintage_date
sort date vintage_date

 save "`datadir'/ADS_vintage_First_pass.dta", replace
 
 clear
 local datadir "${topdir}\Data"
use "`datadir'/ADS_vintage_First_pass.dta", replace

drop if vintage_date>tm(2008m12) & date<=tm(2008m12)

gen ADS_old=.
replace ADS_old=ADS_INDEX_ if date<=tm(2008m12)
replace ADS_old=ADS_INDEX_ if date==vintage_date
drop if ADS_old==.

keep date ADS_old
duplicates drop

drop if date<tm(1979m1)
drop if date>=tm(2025m8)
sort date

local datadir "${topdir}\Data"
save "`datadir'/ADS_First_Read.dta", replace

***** same for initial claims ****

 clear
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"
import excel "`rawdir'\ICNSA_Part1.xlsx", sheet("Vintages Starting 2009-05-28") firstrow
gen month=month(observation_date)
gen year=year(observation_date)
gen date=ym(year,month)
format date %tm

local ICNSA_group ICNSA_*

collapse (mean) `ICNSA_group' , by(date)


reshape long ICNSA_, i(date) j(vintage) string

gen year_vintage=substr(vintage,1,4)
gen month_vintage=substr(vintage,5,2)
gen day_vintage=substr(vintage,7,.)

destring year_vintage, replace
destring month_vintage, replace
destring day_vintage, replace

gen vintage_date = ym(year_vintage, month_vintage)
format vintage_date %tm

bysort vintage_date: egen last_day = max(day_vintage)
keep if day_vintage==last_day

keep date ICNSA_ vintage_date
sort date vintage_date
drop if date<=tm(2009m5) & vintage_date>tm(2009m5)

gen ICNSA_old=.
replace ICNSA_old=ICNSA_ if date<=tm(2009m5)
replace ICNSA_old=ICNSA_ if date==vintage_date

drop if ICNSA_old==.

keep date ICNSA_old
duplicates drop
replace ICNSA_old = ICNSA_old/1000


local datadir "${topdir}\Data"
save "`datadir'/ICNSA_Part1.dta", replace

clear
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"
import excel "`rawdir'\ICNSA_Part2.xlsx", sheet("Vintages Starting 2016-01-07") firstrow
gen month=month(observation_date)
gen year=year(observation_date)
gen date=ym(year,month)
format date %tm

local ICNSA_group ICNSA_*

collapse (mean) `ICNSA_group' , by(date)


reshape long ICNSA_, i(date) j(vintage) string

gen year_vintage=substr(vintage,1,4)
gen month_vintage=substr(vintage,5,2)
gen day_vintage=substr(vintage,7,.)

destring year_vintage, replace
destring month_vintage, replace
destring day_vintage, replace

gen vintage_date = ym(year_vintage, month_vintage)
format vintage_date %tm

bysort vintage_date: egen last_day = max(day_vintage)
keep if day_vintage==last_day
drop if date<tm(2016m1)

gen ICNSA_old=.
replace ICNSA_old=ICNSA_ if date==vintage_date

drop if ICNSA_old==.

keep date ICNSA_old
duplicates drop
replace ICNSA_old = ICNSA_old/1000

append using "`datadir'/ICNSA_Part1.dta"
duplicates drop

drop if date<tm(1979m1)
drop if date>=tm(2025m8)
sort date
replace ICNSA_old = round(ICNSA_old,.01)

local datadir "${topdir}\Data"
save "`datadir'/ICNSA_First_Read.dta", replace


*******************************************
clear
set more off
global topdir "YOUR_Path\replication"
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"
* ssc install estout, replace

import delimited "`rawdir'\Year-Month-est-and-revisions-79-25.csv"
drop month year
split date, p("/")
rename date1 month
rename date2 day
rename date3 year

destring year, replace
destring month, replace
destring day, replace

drop date 

gen date = ym(year,month)
format date %tm

gen daily_date=mdy(month,day,year)
format daily_date %td
gen quarter=quarter(daily_date)

drop date 

gen date = ym(year,month)
format date %tm
drop day
gen qdate=yq(year,quarter)
format qdate %tq

rename seasonallyadjustedoverthemonthch first_reading_SA
rename v5 second_reading_SA
rename v6 third_reading_SA
rename seasonallyadjustedrevisioninover ch_level_first_second_SA
rename v8 ch_level_second_third_SA
rename v9 ch_level_first_third_SA
rename notseasonallyadjustedoverthemont first_reading_NSA
rename notseasonallyoverthemonthchangea second_reading_NSA
rename v12 third_reading_NSA
rename notseasonallyadjustedrevisionino ch_level_first_second_NSA
rename v14 ch_level_second_third_NSA
rename v15 ch_level_first_third_NSA

foreach var in ch_level_first_second_SA ch_level_second_third_SA ch_level_first_third_SA ch_level_first_second_NSA ch_level_second_third_NSA ch_level_first_third_NSA {
	replace `var'="" if `var'=="NA***"
	replace `var'="" if `var'=="NA"
	destring `var', replace
}

gen CI_low_95_first_reading = first_reading_NSA - 1.96*82554
gen CI_high_95_first_reading = first_reading_NSA + 1.96*82554

drop if date >tm(2025m7)
order date year month
sort date

tempfile revisions
save `revisions'


clear
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"

set haverdir "Haver_path"

import haver RECESSM2@USECON LFN@USECON

tsset time

gen turn_recession=0
replace turn_recession=1 if recessm2_usecon==1 & L1.recessm2_usecon==0
gen turn_rec_range=0
replace turn_rec_range=1 if turn_recession==1 | F1.turn_recession==1 | F2.turn_recession==1 | F3.turn_recession==1 | L1.turn_recession==1 | L2.turn_recession==1 | L3.turn_recession==1

gen turn_expansion=0
replace turn_expansion=1 if L1.recessm2_usecon==1 & recessm2_usecon==0

gen turn_exp_range=0
replace turn_exp_range=1 if turn_expansion==1 | F1.turn_expansion==1 | F2.turn_expansion==1 | F3.turn_expansion==1 | L1.turn_expansion==1 | L2.turn_expansion==1 | L3.turn_expansion==1

gen turning_points = turn_recession + turn_expansion

gen turning_range = turn_rec_range + turn_exp_range

gen turning_range_ext = turning_range
replace turning_range_ext=1 if turning_range_ext==2 /* keeping the ones that are quite short lived recessions */

gen date = time

merge 1:1 date using `revisions'
keep if _merge==3
drop _merge

tabstat ch_level_first_third_NSA, by(turning_range_ext) stat(mean p50 p10 p25 p75 p90 sd)

gen abs_ch_1_3_NSA = abs(ch_level_first_third_NSA)

estpost tabstat abs_ch_1_3_NSA, by(turning_range_ext) stat(mean p50 p10 p25 p75 p90 sd N)

esttab using "`tablesdir'/tabstat_abs.tex", cells("mean p50 p10 p25 p75 p90 sd N") replace /* Table A-1 in Section A-2 in Appendix */

*ksmirnov abs_ch_1_3_NSA, by(turning_range_ext) /* we don't see differences, but sample sizes are small and the medians are very close to each other. There are lots of ties, so KS is not a good option */

ranksum abs_ch_1_3_NSA, by(turning_range_ext) 

kdensity abs_ch_1_3_NSA if turning_range_ext==0, lwidth(medthick) plot(kdensity abs_ch_1_3_NSA if turning_range_ext==1, lwidth(medthick)) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) legend(label(1 "Other Times") label(2 "Turning Points") rows(1) region(lcolor(white))) title("") xtitle("|{&Delta} NSA Payroll Gain from 1st. to 3rd. reading (in thousands)|") aspectratio(.5)
graph export "`graphdir'\Distributions_turning_points_abs.png", as(png) replace  /* Figure A-1 in Section A-2 in Appendix */

xtile dec1 =abs_ch_1_3_NSA, nq(100)

gen large_revision=0
replace large_revision=1 if dec1>=90
replace large_revision=. if ch_level_first_third_NSA==.

tab large_revision turning_range_ext, column all


estpost tab   large_revision turning_range_ext

esttab using "`tablesdir'/tab_abs.tex", cell(b(fmt(2)) colpct(fmt(2))) unstack noobs replace /* Table A-3 in Section A-2 in Appendix */

**** Let's now normalize by the size of the labor force ****

gen abs_ch_1_3_NSA_share = (abs_ch_1_3_NSA/lfn_usecon)*100

estpost tabstat abs_ch_1_3_NSA_share, by(turning_range_ext) stat(mean p50 p10 p25 p75 p90 sd N)

esttab using "`tablesdir'/tabstat_absLF.tex", cells("mean(fmt(%9.4f)) p50(fmt(%9.4f)) p10(fmt(%9.4f)) p25(fmt(%9.4f)) p75(fmt(%9.4f)) p90(fmt(%9.4f)) sd(fmt(%9.4f)) N(fmt(%9.0f))") replace

kdensity abs_ch_1_3_NSA_share if turning_range_ext==0, lwidth(medthick) plot(kdensity abs_ch_1_3_NSA_share if turning_range_ext==1, lwidth(medthick)) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) legend(label(1 "Other Times") label(2 "Turning Points") rows(1) region(lcolor(white))) title("") xtitle("|{&Delta} NSA Payroll Gain from 1st. to 3rd. reading (in % of labor force)|") aspectratio(.5)
graph export "`graphdir'/Distributions_turning_points_absLF.png", as(png) replace /* Figure A-2 in Section A-2 in Appendix */

ranksum abs_ch_1_3_NSA_share, by(turning_range_ext) 

xtile dec1LF =abs_ch_1_3_NSA_share, nq(100)


gen large_revision_share=0
replace large_revision_share=1 if dec1LF>=90

tab large_revision_share turning_range_ext, column all

estpost tab   large_revision_share turning_range_ext

esttab using "`tablesdir'/tab_absLF.tex", cell(b(fmt(2)) colpct(fmt(2))) unstack noobs replace /* Table A-2 in Section A-2 in Appendix */



******** Including the summary statistics table **********

// Create summary table delta13 by recession status
estpost tabstat ch_level_first_third_NSA, by(recessm2_usecon) ///
    statistics(N mean p50 sd p1 p10 p25 p75 p90 p99)
// Export to Latex format
esttab using "`tablesdir'/delta13_ds.tex", cells("mean(fmt(%9.2f)) p50(fmt(%9.2f)) sd(fmt(%9.2f)) p1(fmt(%9.2f)) p10(fmt(%9.2f)) p25(fmt(%9.2f)) p75(fmt(%9.2f)) p90(fmt(%9.2f)) p99(fmt(%9.2f))") ///
      noobs nonumber replace title("delta23 Descriptive Statistics")
// T-test with unequal variances assumption (Welch's t-test)
ttest ch_level_first_third_NSA, by(recessm2_usecon) unequal welch

kdensity ch_level_first_third_NSA if recessm2_usecon==0, lwidth(medthick) plot(kdensity ch_level_first_third_NSA if recessm2_usecon==1, lwidth(medthick)) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) legend(label(1 "Other Times") label(2 "Recessions") rows(1) region(lcolor(white))) title("") xtitle("{&Delta} NSA Payroll Gain from 1st. to 3rd. reading (in thousands)") aspectratio(.5)
graph export "`graphdir'/Distributions_recessions.png", as(png) replace /* Figure xxx in Section xx in Appendix */

// Create summary table delta13 by recession status
estpost tabstat ch_level_first_third_NSA, by(turning_range_ext) ///
    statistics(N mean p50 sd p1 p10 p25 p75 p90 p99)
// Export to RTF (Word) format
esttab using "`tablesdir'/delta13_ds_turn.tex", cells("mean(fmt(%9.2f)) p50(fmt(%9.2f)) sd(fmt(%9.2f)) p1(fmt(%9.2f)) p10(fmt(%9.2f)) p25(fmt(%9.2f)) p75(fmt(%9.2f)) p90(fmt(%9.2f)) p99(fmt(%9.2f))") ///
      noobs nonumber replace title("delta23 Descriptive Statistics - Turning Points")
// T-test with unequal variances assumption (Welch's t-test)
ttest ch_level_first_third_NSA, by(recessm2_usecon) unequal welch

kdensity ch_level_first_third_NSA if turning_range_ext==0, lwidth(medthick) plot(kdensity ch_level_first_third_NSA if turning_range_ext==1, lwidth(medthick)) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) legend(label(1 "Other Times") label(2 "Turning Points") rows(1) region(lcolor(white))) title("") xtitle("{&Delta} NSA Payroll Gain from 1st. to 3rd. reading (in thousands)") aspectratio(.5)
graph export "`graphdir'/Distributions_turning_points.png", as(png) replace /* Figure xxx in Section xx in Appendix */

gen ch_level_13_NSA_LF = (ch_level_first_third_NSA/lfn_usecon)*100

// Create summary table delta13 by recession status - LF
estpost tabstat ch_level_13_NSA_LF, by(recessm2_usecon) ///
    statistics(N mean p50 sd p1 p10 p25 p75 p90 p99)
// Export to Latex format
esttab using "`tablesdir'/delta13_ds_LF.tex", cells("mean(fmt(%9.2f)) p50(fmt(%9.2f)) sd(fmt(%9.2f)) p1(fmt(%9.2f)) p10(fmt(%9.2f)) p25(fmt(%9.2f)) p75(fmt(%9.2f)) p90(fmt(%9.2f)) p99(fmt(%9.2f))") ///
      noobs nonumber replace title("delta23 Descriptive Statistics")
// T-test with unequal variances assumption (Welch's t-test)
ttest ch_level_first_third_NSA, by(recessm2_usecon) unequal welch

kdensity ch_level_13_NSA_LF if recessm2_usecon==0, lwidth(medthick) plot(kdensity ch_level_13_NSA_LF if recessm2_usecon==1, lwidth(medthick)) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) legend(label(1 "Other Times") label(2 "Recessions") rows(1) region(lcolor(white))) title("") xtitle("{&Delta} NSA Payroll Gain from 1st. to 3rd. reading (% of Labor Force)") aspectratio(.5)
graph export "`graphdir'/Distributions_recessions_LF.png", as(png) replace /* Figure xxx in Section xx in Appendix */


// Create summary table delta13 by recession status
estpost tabstat ch_level_13_NSA_LF, by(turning_range_ext) ///
    statistics(N mean p50 sd p1 p10 p25 p75 p90 p99)
// Export to RTF (Word) format
esttab using "`tablesdir'/delta13_ds_turn_LF.tex", cells("mean(fmt(%9.2f)) p50(fmt(%9.2f)) sd(fmt(%9.2f)) p1(fmt(%9.2f)) p10(fmt(%9.2f)) p25(fmt(%9.2f)) p75(fmt(%9.2f)) p90(fmt(%9.2f)) p99(fmt(%9.2f))") ///
      noobs nonumber replace title("delta23 Descriptive Statistics - Turning Points")
// T-test with unequal variances assumption (Welch's t-test)
ttest ch_level_first_third_NSA, by(recessm2_usecon) unequal welch

kdensity ch_level_13_NSA_LF if turning_range_ext==0, lwidth(medthick) plot(kdensity ch_level_13_NSA_LF if turning_range_ext==1, lwidth(medthick)) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) legend(label(1 "Other Times") label(2 "Turning Points") rows(1) region(lcolor(white))) title("") xtitle("{&Delta} NSA Payroll Gain from 1st. to 3rd. reading (% of Labor Force)") aspectratio(.5)
graph export "`graphdir'/Distributions_turning_points_LF.png", as(png) replace /* Figure xxx in Section xx in Appendix */


**************************************************************************************************************************
***** Including the section that create tables and other results: from Analysis_revisions_prediction_monthly.do **********
**************************************************************************************************************************


clear
set more off

global topdir "YOUR_Path\replication"
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"

import delimited "`rawdir'\Year-Month-est-and-revisions-79-25.csv"
drop month year
split date, p("/")
rename date1 month
rename date2 day
rename date3 year

destring year, replace
destring month, replace
destring day, replace

drop date 

gen date = ym(year,month)
format date %tm
drop day

rename seasonallyadjustedoverthemonthch first_reading_SA
rename v5 second_reading_SA
rename v6 third_reading_SA
rename seasonallyadjustedrevisioninover ch_level_first_second_SA
rename v8 ch_level_second_third_SA
rename v9 ch_level_first_third_SA
rename notseasonallyadjustedoverthemont first_reading_NSA
rename notseasonallyoverthemonthchangea second_reading_NSA
rename v12 third_reading_NSA
rename notseasonallyadjustedrevisionino ch_level_first_second_NSA
rename v14 ch_level_second_third_NSA
rename v15 ch_level_first_third_NSA

foreach var in ch_level_first_second_SA ch_level_second_third_SA ch_level_first_third_SA ch_level_first_second_NSA ch_level_second_third_NSA ch_level_first_third_NSA {
	replace `var'="" if `var'=="NA***"
	replace `var'="" if `var'=="NA"
	destring `var', replace
}

reg ch_level_first_third_NSA first_reading_NSA, robust
predict se_revision, stdp

gen CI_low_95_first_reading = first_reading_NSA - 1.96*82.554
gen CI_high_95_first_reading = first_reading_NSA + 1.96*82.554

drop if date >tm(2025m8)
order date year month
sort date

tsset date

gen ch_perc_first_second_SA = (ch_level_first_second_SA/abs(first_reading_SA))*100
gen ch_perc_second_third_SA = (ch_level_second_third_SA/abs(second_reading_SA))*100
gen ch_perc_first_third_SA = (ch_level_first_third_SA/abs(first_reading_SA))*100

gen ch_perc_first_second_NSA = (ch_level_first_second_NSA/abs(first_reading_NSA))*100
gen ch_perc_second_third_NSA = (ch_level_second_third_NSA/abs(second_reading_NSA))*100
gen ch_perc_first_third_NSA = (ch_level_first_third_NSA/abs(first_reading_NSA))*100


****** Large 1+2 revisions in levels *****

xtile ptile_rev13_level_SA = ch_level_first_third_SA, nq(100)

gen large_down_13_level_SA = 0
replace large_down_13_level_SA = 1 if ptile_rev13_level_SA<10
replace large_down_13_level_SA=. if ch_level_first_third_SA==.

gen large_up_13_level_SA = 0
replace large_up_13_level_SA = 1 if ptile_rev13_level_SA>90
replace large_up_13_level_SA=. if ch_level_first_third_SA==.

gen large_rev_13_level_SA= large_down_13_level_SA + large_up_13_level_SA


gen abs_ch_1_3_NSA = abs(ch_level_first_third_NSA)

xtile dec1 =abs_ch_1_3_NSA, nq(100)

gen large_revision=0
replace large_revision=1 if dec1>=90
replace large_revision=. if ch_level_first_third_NSA==.

xtile ptile_rev13_level_NSA = ch_level_first_third_NSA, nq(100)

gen large_down_13_level_NSA = 0
replace large_down_13_level_NSA = 1 if ptile_rev13_level_NSA<10
replace large_down_13_level_NSA=. if ch_level_first_third_NSA==.

gen large_up_13_level_NSA = 0
replace large_up_13_level_NSA = 1 if ptile_rev13_level_NSA>90
replace large_up_13_level_NSA=. if ch_level_first_third_NSA==.

gen large_rev_13_level_NSA= large_down_13_level_NSA + large_up_13_level_NSA


label var large_down_13_level_SA "=1 if obs in bottom 10% of level change 1st to 3rd read - SA"
label var large_up_13_level_SA "=1 if obs in top 90% of level change 1st to 3rd read - SA"
label var large_rev_13_level_SA "=1 if obs in bottom 10 or top 90% of level change 1st to 3rd read - SA"

label var large_down_13_level_NSA "=1 if obs in bottom 10% of level change 1st to 3rd read - NSA"
label var large_up_13_level_NSA "=1 if obs in top 90% of level change 1st to 3rd read - NSA"
label var large_rev_13_level_NSA "=1 if obs in bottom 10 or top 90% of level change 1st to 3rd read - NSA"

drop if date>=tm(2025m8)

save "`datadir'\revisions_monthly.dta", replace



clear


clear
set more off

global topdir "YOUR_Path\replication"
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"
set haverdir "Haver_path"

import haver RECESSM2@USECON N111RG10@G10 N111RG3M@G10 CHEPLM@USECON SP500@USECON LFN@USECON
gen SPREAD = n111rg10_g10- n111rg3m_g10

drop if time<tm(1979m1)
drop if time>tm(2025m11)

rename time date

tsset date
forvalues i=1(1)12 {
gen recession_next`i' = F`i'.recessm2_usecon
}

merge 1:1 date using "`datadir'\revisions_monthly.dta"
drop _merge
drop if date>tm(2025m8)

*********** Graph *************

tsset date, monthly
summarize ch_level_first_third_NSA if year!=2003
generate recession = r(max) if recessm2_usecon == 1
replace recession  = r(min) if recessm2_usecon == 0

gen ch_level_13_NSA_LF = (ch_level_first_third_NSA/lfn_usecon)*100

gen ch_level_13_SA_LF = (ch_level_first_third_SA/lfn_usecon)*100


******************************************************************


xtile ptile_rev13_level_SA_LF = ch_level_13_SA_LF, nq(100)

gen large_down_13_level_SA_LF = 0
replace large_down_13_level_SA_LF = 1 if ptile_rev13_level_SA_LF<10
gen large_up_13_level_SA_LF = 0
replace large_up_13_level_SA_LF = 1 if ptile_rev13_level_SA_LF>90
gen large_rev_13_level_SA_LF= large_down_13_level_SA_LF + large_up_13_level_SA_LF


xtile ptile_rev13_level_NSA_LF = ch_level_13_NSA_LF, nq(100)

gen large_down_13_level_NSA_LF = 0
replace large_down_13_level_NSA_LF = 1 if ptile_rev13_level_NSA_LF<10
gen large_up_13_level_NSA_LF = 0
replace large_up_13_level_NSA_LF = 1 if ptile_rev13_level_NSA_LF>90
gen large_rev_13_level_NSA_LF= large_down_13_level_NSA_LF + large_up_13_level_NSA_LF

replace large_down_13_level_NSA_LF=. if large_down_13_level_NSA==.


label var large_down_13_level_SA_LF "=1 if obs in bottom 10% of level change 1st to 3rd read - SA"
label var large_up_13_level_SA_LF "=1 if obs in top 90% of level change 1st to 3rd read - SA"
label var large_rev_13_level_SA "=1 if obs in bottom 10 or top 90% of level change 1st to 3rd read - SA"

label var large_down_13_level_NSA_LF "=1 if obs in bottom 10% of level change 1st to 3rd read - NSA"
label var large_up_13_level_NSA_LF "=1 if obs in top 90% of level change 1st to 3rd read - NSA"
label var large_rev_13_level_NSA_LF "=1 if obs in bottom 10 or top 90% of level change 1st to 3rd read - NSA"

***********************************************************************

summarize ch_level_first_third_NSA
local min = r(min)

/*
twoway  (area recession date if year!=2003,   color(gs14) base(`min'))  (tsline ch_level_first_third_NSA if year!=2003, lcolor(blue)) (tsline  CI_low_95_first_reading if year!=2003, lcolor(blue) lwidth(thin) lpattern(dash)) , legend(off) xtitle("") ytitle("Revision: 3rd. - 1st. reading - NSA (in thousands)")  graphregion(color(white)) bgcolor(white) ylabel(,nogrid) aspectratio(.5)
graph export "`graphdir'/Levels_R13_Recession_Monthly.png", as(png) replace
*/
drop recession


tsset date, monthly
summarize ch_level_first_third_SA if year!=2003
generate recession = r(max) if recessm2_usecon == 1
replace recession  = r(min) if recessm2_usecon == 0


/*
summarize ch_level_first_third_SA
local min = r(min)


twoway  (area recession date if year!=2003,   color(gs14) base(`min'))  (tsline ch_level_first_third_SA if year!=2003, lcolor(dkgreen)) , legend(off) xtitle("") ytitle("Revision: 3rd. - 1st. reading - SA (in thousands)")  graphregion(color(white)) bgcolor(white) ylabel(,nogrid) aspectratio(.5)
graph export "`graphdir'/Levels_R13_Recession_SA_Monthly.png", as(png) replace

**** ROC curve ****

gen lnsp500 = log(sp500_usecon)
tsset date
gen momsp500 = 100*12*(lnsp500-L1.lnsp500)


roctab recessm2_usecon momsp500, graph msize(tiny) yti("TP Rate") xti("FP Rate")

*/


************ Regressions ********


tsset date
forvalues i=1(1)12 {
gen ch_level_first_third_NSA_L`i' = L`i'.ch_level_first_third_NSA
gen ch_level_13_NSA_LF_L`i' = L`i'.ch_level_13_NSA_LF
}

gen change_in_revisions = ch_perc_first_third_NSA- ch_level_first_third_NSA_L1
gen change_in_revisions_LF = ch_level_13_NSA_LF - ch_level_13_NSA_LF_L1

local tablesdir "${topdir}\Tables"

******* Table 1 - Section 1.1 ******
quietly nwest probit recession_next1 ch_level_first_third_NSA if date<=tm(2025m7), lag(1) t(date) force
quietly outreg  using "`tablesdir'/Table3_EM_R13_NSA_M.tex", replace keep( ch_level_first_third_NSA ) se tex fragment  bdec(4) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
forvalues i=2(1)11 {
quietly nwest probit recession_next`i' ch_level_first_third_NSA if date<=tm(2025m7), lag(`i') t(date) force
quietly outreg  using "`tablesdir'/Table3_EM_R13_NSA_M.tex", merge keep( ch_level_first_third_NSA ) se tex  fragment bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 ch_level_first_third_NSA if date<=tm(2025m7), lag(12) t(date) force
outreg  using "`tablesdir'/Table3_EM_R13_NSA_M.tex", merge keep( ch_level_first_third_NSA ) se tex  fragment bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)

******* Table A-5 - Appendix Section A.2.1 ******

quietly nwest probit recession_next1 ch_level_13_NSA_LF if date<=tm(2025m7), lag(1) t(date) force
quietly outreg  using "`tablesdir'/Table3_EM_R13_NSA_M_LF.tex", replace keep( ch_level_13_NSA_LF ) se tex fragment  bdec(4) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

forvalues i=2(1)11 {
quietly nwest probit recession_next`i' ch_level_13_NSA_LF if date<=tm(2025m7), lag(`i') t(date) force
quietly outreg  using "`tablesdir'/Table3_EM_R13_NSA_M_LF.tex", merge keep( ch_level_13_NSA_LF ) se tex  fragment bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 ch_level_13_NSA_LF if date<=tm(2025m7), lag(12) t(date) force
outreg  using "`tablesdir'/Table3_EM_R13_NSA_M_LF.tex", merge keep( ch_level_13_NSA_LF ) se tex  fragment bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4) 


******* Table 2 - Section 1.1 ******

local tablesdir "${topdir}\Tables"
quietly nwest probit recession_next1 large_down_13_level_NSA if date<=tm(2025m7), lag(1) t(date) force
quietly outreg  using "`tablesdir'/Table5_EM_R13_NSA_M.tex", replace keep( large_down_13_level_NSA ) se tex fragment  bdec(4) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

forvalues i=2(1)11 {
quietly nwest probit recession_next`i' large_down_13_level_NSA if date<=tm(2025m7), lag(`i') t(date) force
quietly outreg  using "`tablesdir'/Table5_EM_R13_NSA_M.tex", merge keep( large_down_13_level_NSA ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 large_down_13_level_NSA if date<=tm(2025m7), lag(12) t(date) force
outreg  using "`tablesdir'/Table5_EM_R13_NSA_M.tex", merge keep( large_down_13_level_NSA ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)


******* Table A-6 - Appendix Section A.2.1 ******


quietly nwest probit recession_next1 large_down_13_level_NSA_LF if date<=tm(2025m7), lag(1) t(date) force
quietly outreg  using "`tablesdir'/Table5_EM_R13_NSA_M_LF.tex", replace keep( large_down_13_level_NSA_LF ) se tex fragment  bdec(4) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

forvalues i=2(1)11 {
quietly nwest probit recession_next`i' large_down_13_level_NSA_LF if date<=tm(2025m7), lag(`i') t(date) force
quietly outreg  using "`tablesdir'/Table5_EM_R13_NSA_M_LF.tex", merge keep( large_down_13_level_NSA_LF ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 large_down_13_level_NSA_LF if date<=tm(2025m7), lag(12) t(date) force
outreg  using "`tablesdir'/Table5_EM_R13_NSA_M_LF.tex", merge keep( large_down_13_level_NSA_LF ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)

******* Table 2a - Section 1.1 ******

local tablesdir "${topdir}\Tables"
quietly nwest probit recession_next1 large_revision if date<=tm(2025m7), lag(1) t(date) force
quietly outreg  using "`tablesdir'/Table5b_EM_R13_NSA_M.tex", replace keep( large_revision ) se tex fragment  bdec(4) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

forvalues i=2(1)11 {
quietly nwest probit recession_next`i' large_revision if date<=tm(2025m7), lag(`i') t(date) force
quietly outreg  using "`tablesdir'/Table5b_EM_R13_NSA_M.tex", merge keep( large_revision ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 large_revision if date<=tm(2025m7), lag(12) t(date) force
outreg  using "`tablesdir'/Table5b_EM_R13_NSA_M.tex", merge keep( large_revision ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)


gen turn_recession=0
replace turn_recession=1 if recessm2_usecon==1 & L1.recessm2_usecon==0

gen turn_expansion=0
replace turn_expansion=1 if L1.recessm2_usecon==1 & recessm2_usecon==0

gen turn_point = turn_recession+turn_expansion

tsset date
forvalues i=1(1)12 {
gen turn_next`i' = F`i'.turn_point
gen turndown_next`i' = F`i'.turn_recession
gen turnup_next`i' = F`i'.turn_expansion
}

nwest probit turndown_next1 large_down_13_level_NSA if date<=tm(2025m7), lag(1) t(date) force

******* Table 3 - Section 1.1 ******

local tablesdir "${topdir}\Tables"
quietly nwest probit recession_next1 large_down_13_level_NSA if SPREAD!=. & date<=tm(2025m7), lag(1) t(date) force
quietly outreg  using "`tablesdir'/Table5a_EM_R13_NSA_M.tex", replace keep( large_down_13_level_NSA ) se tex fragment  bdec(4) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

forvalues i=2(1)11 {
quietly nwest probit recession_next`i' large_down_13_level_NSA  if SPREAD!=. & date<=tm(2025m7), lag(`i') t(date) force
quietly outreg  using "`tablesdir'/Table5a_EM_R13_NSA_M.tex", merge keep( large_down_13_level_NSA ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 large_down_13_level_NSA  if SPREAD!=. & date<=tm(2025m7), lag(12) t(date) force
outreg  using "`tablesdir'/Table5a_EM_R13_NSA_M.tex", merge keep( large_down_13_level_NSA ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)

******* Table A-7 - Appendix Section A.2.1 ******

quietly nwest probit recession_next1 large_down_13_level_NSA_LF if SPREAD!=. & date<=tm(2025m7), lag(1) t(date) force
quietly outreg  using "`tablesdir'/Table5a_EM_R13_NSA_M_LF.tex", replace keep( large_down_13_level_NSA_LF ) se tex fragment  bdec(4) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

forvalues i=2(1)11 {
quietly nwest probit recession_next`i' large_down_13_level_NSA_LF  if SPREAD!=. & date<=tm(2025m7), lag(`i') t(date) force
quietly outreg  using "`tablesdir'/Table5a_EM_R13_NSA_M_LF.tex", merge keep( large_down_13_level_NSA_LF ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 large_down_13_level_NSA_LF  if SPREAD!=. & date<=tm(2025m7), lag(12) t(date) force
outreg  using "`tablesdir'/Table5a_EM_R13_NSA_M_LF.tex", merge keep( large_down_13_level_NSA_LF ) se tex fragment   bdec(4) starlevels(10 5 1) starloc(1)  summstat(N) summtitle(N) summdec(0 2 4)


*********** Figure 2 - Section 1.1 *****************

gen neg_ch_level_first_third_NSA = -ch_level_first_third_NSA
roctab recessm2_usecon neg_ch_level_first_third_NSA  if date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid) aspectratio(.5)
graph export "`graphdir'/Fig2_ROC_level.png", as(png) replace

*********** Figure A-3 - Appendix Section A.2.1 *****************

gen neg_ch_level_13_NSA_LF = -ch_level_13_NSA_LF
roctab recessm2_usecon neg_ch_level_13_NSA  if date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid) aspectratio(.5)
graph export "`graphdir'/Fig2_ROC_level_LF.png", as(png) replace


*****************************************************************************************
****** Autocorrelation Results - 
*****************************************************************************************

clear
set haverdir "Haver_path"

import haver LFN@USECON RECESSM2@USECON


drop if time<tm(1979m1)
rename time date

tempfile LF_us
save `LF_us'

clear
set more off

global topdir "YOUR_Path\replication"
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"

use "`datadir'\revisions_monthly.dta", replace

merge 1:1 date using `LF_us'
keep if _merge==3
drop _merge

gen ch_level_13_NSA_LF = (ch_level_first_third_NSA/lfn_usecon)*100

gen ch_level_13_SA_LF = (ch_level_first_third_SA/lfn_usecon)*100

tsset date

arima ch_level_first_third_NSA  if date<=tm(2025m7), ar(1)
outreg  using "`tablesdir'/Table1_AR1_all.tex", replace se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

preserve

gen recess_rev = L1.ch_level_first_third_NSA*recessm2_usecon
gen pre_rev = L1.ch_level_first_third_NSA

*gen normal_rev = L1.ch_level_first_third_NSA*(1-recessm2_usecon)


quietly reg ch_level_first_third_NSA pre_rev  if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_all.tex", replace se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_first_third_NSA pre_rev recessm2_usecon  if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_all.tex", merge se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_first_third_NSA pre_rev recessm2_usecon recess_rev  if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_all.tex", merge se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_first_third_NSA pre_rev recessm2_usecon recess_rev i.year  if date<=tm(2025m7), robust
outreg  using "`tablesdir'/Table1_auto_corr_all.tex", merge se tex fragment keep( pre_rev recessm2_usecon recess_rev _cons) bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

 *nwest reg ch_level_first_third_NSA pre_rev recessm2_usecon recess_rev, lag(4) t(date) force

quietly arima ch_level_13_NSA_LF, ar(1)
quietly outreg  using "`tablesdir'/Table1_AR1_all_LF.tex", replace se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

gen recess_rev_LF = L1.ch_level_13_NSA_LF*recessm2_usecon
gen pre_rev_LF = L1.ch_level_13_NSA_LF


quietly reg ch_level_13_NSA_LF pre_rev_LF if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_all_LF.tex", replace se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_13_NSA_LF pre_rev_LF recessm2_usecon if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_all_LF.tex", merge se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_13_NSA_LF pre_rev_LF recessm2_usecon recess_rev_LF if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_all_LF.tex", merge se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_13_NSA_LF pre_rev_LF recessm2_usecon recess_rev_LF i.year if date<=tm(2025m7), robust
outreg  using "`tablesdir'/Table1_auto_corr_all_LF.tex", merge se tex fragment keep( pre_rev_LF recessm2_usecon recess_rev_LF _cons) bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

tsset date

gen turn_recession=0
replace turn_recession=1 if recessm2_usecon==1 & L1.recessm2_usecon==0
gen turn_rec_range=0
replace turn_rec_range=1 if turn_recession==1 | F1.turn_recession==1 | F2.turn_recession==1 | F3.turn_recession==1 | L1.turn_recession==1 | L2.turn_recession==1 | L3.turn_recession==1

gen turn_expansion=0
replace turn_expansion=1 if L1.recessm2_usecon==1 & recessm2_usecon==0

gen turn_exp_range=0
replace turn_exp_range=1 if turn_expansion==1 | F1.turn_expansion==1 | F2.turn_expansion==1 | F3.turn_expansion==1 | L1.turn_expansion==1 | L2.turn_expansion==1 | L3.turn_expansion==1

gen turning_points = turn_recession + turn_expansion

gen turning_range = turn_rec_range + turn_exp_range

gen turning_range_ext = turning_range
replace turning_range_ext=1 if turning_range_ext==2 /* keeping the ones that are quite short lived recessions */

gen turn_rev = L1.ch_level_first_third_NSA*turning_range_ext
gen turn_rev_LF = L1.ch_level_13_NSA_LF*turning_range_ext

gen normal_rev = L1.ch_level_first_third_NSA*(1-turning_range_ext)


quietly reg ch_level_first_third_NSA pre_rev turning_range_ext if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_turn.tex", replace se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_first_third_NSA pre_rev turning_range_ext turn_rev if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_turn.tex", merge se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_first_third_NSA pre_rev turning_range_ext turn_rev i.year if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_turn.tex", merge se keep(pre_rev turning_range_ext turn_rev _cons) tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_first_third_NSA pre_rev turning_range_ext turn_rev recess_rev recessm2_usecon if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_turn.tex", merge se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_first_third_NSA pre_rev turning_range_ext turn_rev recess_rev recessm2_usecon i.year if date<=tm(2025m7), robust
outreg  using "`tablesdir'/Table1_auto_corr_turn.tex", merge se keep(pre_rev turning_range_ext turn_rev recess_rev recessm2_usecon _cons) tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

quietly reg ch_level_13_NSA_LF pre_rev_LF turning_range_ext if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_turn_LF.tex", replace se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_13_NSA_LF pre_rev_LF turning_range_ext turn_rev_LF if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_turn_LF.tex", merge se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_13_NSA_LF pre_rev_LF turning_range_ext turn_rev_LF i.year if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_turn_LF.tex", merge se keep(pre_rev_LF turning_range_ext turn_rev_LF _cons) tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_13_NSA_LF pre_rev_LF turning_range_ext turn_rev_LF recess_rev_LF recessm2_usecon if date<=tm(2025m7), robust
quietly outreg  using "`tablesdir'/Table1_auto_corr_turn_LF.tex", merge se tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)
quietly reg ch_level_13_NSA_LF pre_rev_LF turning_range_ext turn_rev_LF recess_rev_LF recessm2_usecon i.year if date<=tm(2025m7), robust
outreg  using "`tablesdir'/Table1_auto_corr_turn_LF.tex", merge se keep(pre_rev_LF turning_range_ext turn_rev_LF recess_rev_LF recessm2_usecon _cons) tex fragment  bdec(3) starlevels(10 5 1) starloc(1)   summstat(N) summtitle(N) summdec(0 2 4)

*nwest reg ch_level_first_third_NSA pre_rev turning_range_ext turn_rev recess_rev recessm2_usecon , lag(4) t(date) force

restore

drop recessm2_usecon

save "`datadir'\revisions_monthly_LF.dta", replace

preserve

rolling _b _se, window(18) nodots: arima ch_level_first_third_NSA if date<=tm(2025m7), ar(1)

gen lower_CI1 = _stat_2 - invnormal(0.95)*_stat_5
gen higher_CI = _stat_2 + invnormal(0.95)*_stat_5

keep _stat_2 _stat_5 lower_CI1 higher_CI end

rename end date

tempfile arma_rol18
save `arma_rol18'

restore


rolling _b _se, window(18) nodots: arima ch_level_13_NSA_LF if date<=tm(2025m7), ar(1)

gen lower_CI1_LF = _stat_2 - invnormal(0.95)*_stat_5
gen higher_CI_LF = _stat_2 + invnormal(0.95)*_stat_5

keep _stat_2 _stat_5 lower_CI1_LF higher_CI_LF end

rename _stat_2 _stat_2_LF
rename _stat_5 _stat_5_LF

rename end date

tempfile arma_rol18_LF
save `arma_rol18_LF'


************* Including other indexes ************

clear
import excel "YOUR_Path\replication\Raw_Data\ADS_Index_Most_Current_Vintage_Dec2025.xlsx", sheet("Sheet1") firstrow
split A, p(":")
rename A1 year
rename A2 month
rename A3 day
destring year, replace
destring month, replace
destring day, replace
drop A RECBARS

gen date = ym(year, month)
format date %tm

collapse (mean) ADS_Index, by(date)

tempfile ADS_index
save `ADS_index'


clear
set haverdir "Haver_path"

import haver RECESSM2@USECON N111RG10@G10 N111RG3M@G10 CHEPLM@USECON SP500@USECON LIC@WEEKLY LICN@WEEKLY LICNM@WEEKLY FRBCNAI@USECON F10FED@USECON


gen SPREAD = n111rg10_g10- n111rg3m_g10

gen year=year(dofm(time))

drop if year<1979

rename time date

merge 1:1 date using `ADS_index'
keep if _merge==3
drop _merge
label var ADS_Index "Arouba-Diebold-Scotti Index"

merge 1:1 date using `arma_rol18'
keep if _merge==3
drop _merge

merge 1:1 date using `arma_rol18_LF'
keep if _merge==3
drop _merge

merge 1:1 date using "`datadir'/CFNAI_First_Read.dta"
keep if _merge==3
drop _merge

merge 1:1 date using "`datadir'/ADS_First_Read.dta"
keep if _merge==3
drop _merge

merge 1:1 date using "`datadir'/ICNSA_First_Read.dta"
keep if _merge==3
drop _merge


save "`datadir'\revisions_autocorrelation_analysis.dta", replace


*****************************************
***********  RESULTS SECTION  ***********
*****************************************

clear
set more off

global topdir "YOUR_Path\replication"
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"

use "`datadir'\revisions_autocorrelation_analysis.dta", replace

gen statistically_significant=0
replace statistically_significant=1 if lower_CI1<0 & higher_CI<0
replace statistically_significant=1 if lower_CI1>0 & higher_CI>0


tsset date, monthly
summarize _stat_2 if year!=2003
generate recession = r(max) if recessm2_usecon == 1
replace recession  = r(min) if recessm2_usecon == 0

summarize _stat_2
local min = r(min)

******* Figure 3 - Section 2.1 **********

twoway  (area recession date if year!=2003,   color(gs14) base(`min'))  (tsline _stat_2 if year!=2003, lcolor(blue)) , legend(off) xtitle("") ytitle("{&beta}{sub:AR}")  graphregion(color(white)) bgcolor(white) ylabel(,nogrid)
graph export "`graphdir'/AR_Recession_Monthly_18.png", as(png) replace

**** creating a version with confidence intervals *****

drop recession
tsset date, monthly
summarize higher_CI  if year!=2003
generate recession = r(max) if recessm2_usecon == 1
summarize lower_CI1  if year!=2003
replace recession  = r(min) if recessm2_usecon == 0

summarize lower_CI1
local min = r(min)

twoway  (area recession date if year!=2003,   color(gs14) base(`min'))  (tsline _stat_2 if year!=2003, lcolor(blue)) (tsline lower_CI1 if year!=2003, lpattern(dash) lcolor(gs5)) (tsline higher_CI if year!=2003, lpattern(dash) lcolor(gs5)), legend(off) xtitle("") ytitle("{&beta}{sub:AR}")  graphregion(color(white)) bgcolor(white) ylabel(,nogrid)
graph export "`graphdir'/AR_Recession_Monthly_18_CIs.png", as(png) replace




drop recession
tsset date, monthly
summarize _stat_2_LF if year!=2003
generate recession = r(max) if recessm2_usecon == 1
replace recession  = r(min) if recessm2_usecon == 0

summarize _stat_2_LF
local min = r(min)

twoway  (area recession date if year!=2003,   color(gs14) base(`min'))  (tsline _stat_2_LF if year!=2003, lcolor(blue)) , legend(off) xtitle("") ytitle("{&beta}{sub:AR,LF}")  graphregion(color(white)) bgcolor(white) ylabel(,nogrid)
graph export "`graphdir'/AR_Recession_Monthly_18_LF.png", as(png) replace




***** ROC Curve - Figure 4 - Section 2.1 *****
gen beta_AR = - _stat_2
gen beta_AR_LF = - _stat_2_LF

gen lnlic = log(licn_weekly)
gen lnbeta = log(1+beta_AR)

gen lnlic_1stread = log(ICNSA_old)

tsset date, m
gen mominic = 100*12*(lnlic-L1.lnlic)
gen mominic_1stread = 100*12*(lnlic_1stread-L1.lnlic_1stread)

gen mombeta = 100*12*(lnbeta-L1.lnbeta)

**** Subfigure 4(a) *****
roctab recessm2_usecon beta_AR if date>tm(1978m12) & date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid)
graph export "`graphdir'/ROC_Beta_AR.png", as(png) replace

**** Subfigure 4(b) *****
roctab recessm2_usecon licn_weekly if date>tm(1978m12) & date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") lcolor(maroon) mcolor(maroon) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid)
graph export "`graphdir'/ROC_Initial_Claims.png", as(png) replace

roctab recessm2_usecon ICNSA_old if date>tm(1978m12) & date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") lcolor(maroon) mcolor(maroon) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid)
graph export "`graphdir'/ROC_Initial_Claims_1stread.png", as(png) replace

*roctab recessm2_usecon mominic if date>tm(1978m12), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") lcolor(maroon) mcolor(maroon)

gen NAI_index= -frbcnai_usecon
gen ADS_index = -ADS_Index

gen NAI_index_First_Read = -CF_old

gen ADS_index_First_Read = -ADS_old

local graphdir "${topdir}\Figures"

**** Subfigure 4(c) *****
roctab recessm2_usecon NAI_index if date>tm(1978m12) & date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") lcolor(dkorange) mcolor(dkorange) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid)
graph export "`graphdir'/ROC_NAI.png", as(png) replace

roctab recessm2_usecon NAI_index_First_Read if date>tm(1978m12) & date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") lcolor(dkorange) mcolor(dkorange) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid)
graph export "`graphdir'/ROC_NAI_1stread.png", as(png) replace

**** Subfigure 4(d) *****
roctab recessm2_usecon ADS_index if date>tm(1978m12) & date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") lcolor(dkgreen) mcolor(dkgreen) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid)
graph export "`graphdir'/ROC_ADS.png", as(png) replace

roctab recessm2_usecon ADS_index_First_Read if date>tm(1978m12) & date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") lcolor(dkgreen) mcolor(dkgreen) graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid)
graph export "`graphdir'/ROC_ADS_1stread.png", as(png) replace


***** Appendix Figure XXX - Appendix Section A.2.1 *****
roctab recessm2_usecon beta_AR_LF if date>tm(1978m12) & date<=tm(2025m7), graph msize(tiny) yti("True Positive Rate") xti("False Positive Rate") graphregion(color(white)) bgcolor(white) ylabel(,nogrid) xlabel(,nogrid)
graph export "`graphdir'/ROC_Beta_AR_LF.png", as(png) replace

*** Now, let's consider leads and lags ***

postfile cyclegdp str12 var str4 leadlag horizon obs auroc stderr lwrbd uprbd using tab1.dta, replace

forvalues i= 0(1)24 {
	foreach j in  beta_AR beta_AR_LF licn_weekly ICNSA_old mominic mombeta NAI_index NAI_index_First_Read ADS_index ADS_index_First_Read {
		qui gen lag`i'`j' = l`i'.`j'
		qui gen lead`i'`j' = f`i'.`j'
		}
	}
	
*bootstrap r(area), reps(1000) nodots :	
*bootstrap r(area), reps(1000) nodots :
foreach i of numlist 0/1{
	foreach j in beta_AR beta_AR_LF licn_weekly ICNSA_old mominic mombeta NAI_index NAI_index_First_Read ADS_index ADS_index_First_Read {
	quietly roctab recessm2_usecon lead`i'`j', sum
		post cyclegdp ("`j'")  ("lead") (`i') (r(N)) (r(area)) (r(se)) (r(lb)) (r(ub))
		}
	}
	
drop lag0*

foreach i of numlist 1/24{
	foreach j in  beta_AR beta_AR_LF licn_weekly ICNSA_old mominic mombeta NAI_index NAI_index_First_Read ADS_index ADS_index_First_Read {
		quietly roctab recessm2_usecon lag`i'`j', sum
		post cyclegdp ("`j'")  ("lag") (`i') (r(N)) (r(area)) (r(se)) (r(lb)) (r(ub))
		}
	}

postclose cyclegdp

preserve
clear
use tab1.dta


gen hzn = 0
replace hzn = horizon if leadlag == "lead"
replace hzn = - horizon if leadlag == "lag"
move hzn obs
drop horizon leadlag
sort var hzn

gen maxauroc = 0
foreach i in  beta_AR beta_AR_LF licn_weekly ICNSA_old mominic mombeta NAI_index NAI_index_First_Read ADS_index ADS_index_First_Read {
	qui summ auroc if var == "`i'", d
	replace maxauroc = 1 if var == "`i'" & auroc == r(max)
	}

*keep if maxauroc == 1 | hzn ==0 | hzn==-12

****** Table 4 - Section 2.1 *******
keep if  hzn ==0 | hzn==-12 /* Used to construct Table 4 */

replace auroc=round(auroc,.001)
replace stderr =round( stderr ,.001)

restore

gen dummy_significant = 1
replace dummy_significant=0 if lower_CI1<0 & higher_CI>0

tsset date
forvalues i=1(1)12 {
gen recession_next`i' = F`i'.recessm2_usecon
}

****** Table 5 - Section 2.1 *******

quietly nwest probit recession_next1 _stat_2 if date>tm(1978m12) & date<=tm(2025m7), lag(1) t(date)
quietly outreg  using "`tablesdir'/Table_Beta_AR_EM_1_raw.tex", replace keep( _stat_2 ) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)
forvalues i=2(1)11 {
quietly nwest probit recession_next`i' _stat_2 if date>tm(1978m12) & date<=tm(2025m7), lag(`i') t(date)
quietly outreg  using "`tablesdir'/Table_Beta_AR_EM_1_raw.tex", merge keep( _stat_2 ) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 _stat_2 if date>tm(1978m12) & date<=tm(2025m7), lag(12) t(date)
outreg  using "`tablesdir'/Table_Beta_AR_EM_1_raw.tex", merge keep( _stat_2 ) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)

******** Table A-8 - Appendix Section A.2.1 ***** 

quietly nwest probit recession_next1 _stat_2_LF if date>tm(1978m12) & date<=tm(2025m7), lag(1) t(date)
quietly outreg  using "`tablesdir'/Table_Beta_AR_EM_1_r_LF.tex", replace keep( _stat_2_LF ) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)
forvalues i=2(1)11 {
quietly nwest probit recession_next`i' _stat_2_LF if date>tm(1978m12) & date<=tm(2025m7), lag(`i') t(date)
quietly outreg  using "`tablesdir'/Table_Beta_AR_EM_1_r_LF.tex", merge keep( _stat_2_LF ) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 _stat_2_LF if date>tm(1978m12) & date<=tm(2025m7), lag(12) t(date)
outreg  using "`tablesdir'/Table_Beta_AR_EM_1_r_LF.tex", merge keep( _stat_2_LF ) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)

****** Table 6 - Section 2.1 *******

quietly nwest probit recession_next1 _stat_2 SPREAD if date>tm(1978m12) & date<=tm(2025m7), lag(1) t(date)
quietly outreg  using "`tablesdir'/Table_Beta_AR_EM_2_raw.tex", replace keep( _stat_2 SPREAD ) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)

forvalues i=2(1)11 {
quietly nwest probit recession_next`i' _stat_2 SPREAD if date>tm(1978m12) & date<=tm(2025m7), lag(`i') t(date)
quietly outreg  using "`tablesdir'/Table_Beta_AR_EM_2_raw.tex", merge keep( _stat_2 SPREAD) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 _stat_2 SPREAD if date>tm(1978m12) & date<=tm(2025m7), lag(12) t(date)
outreg  using "`tablesdir'/Table_Beta_AR_EM_2_raw.tex", merge keep( _stat_2 SPREAD) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)

******** Table A-9 - Appendix Section A.2.1 ***** 

quietly nwest probit recession_next1 _stat_2_LF SPREAD if date>tm(1978m12) & date<=tm(2025m7), lag(1) t(date)
quietly outreg  using "`tablesdir'/Table_Beta_AR_EM_2_r_LF.tex", replace keep( _stat_2_LF SPREAD ) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)

forvalues i=2(1)11 {
quietly nwest probit recession_next`i' _stat_2_LF SPREAD if date>tm(1978m12) & date<=tm(2025m7), lag(`i') t(date)
quietly outreg  using "`tablesdir'/Table_Beta_AR_EM_2_r_LF.tex", merge keep( _stat_2_LF SPREAD) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)
}

quietly nwest probit recession_next12 _stat_2_LF SPREAD if date>tm(1978m12) & date<=tm(2025m7), lag(12) t(date)
outreg  using "`tablesdir'/Table_Beta_AR_EM_2_r_LF.tex", merge keep( _stat_2_LF SPREAD) tex fragment se  bdec(2) starlevels(10 5 1) starloc(1) summstat(N) summtitle(N) summdec(0 2 4)

preserve

postfile nberhats str3 growth horizon nobs auroc stderr uprbd lwrbd using ROC_Beta_out.dta, replace

sort date

local enddate = m(2023m7)

drop if date > `enddate'
local bsamp = date[1]
local esamp = `enddate'
local bout = m(1999m1)
local maxhzn 24

forvalues h = 0/24{
	gen nberhat`h' =.
local j = `bsamp'
	forvalues d = `bout'/`esamp'{
		quietly probit recessm2_usecon l`h'._stat_2 if date < `d' & date >= `j'

		qui predict temp
		qui replace nberhat`h' = temp if date == `d'
		drop temp
		local j = `j' + 1
		}
	}

keep date recessm2_usecon nberhat*

forvalues i=0/24 {
	gen prob_rec_`i'=.
	replace prob_rec_`i'=1 if nberhat`i'>=0.5
	replace prob_rec_`i'=0 if nberhat`i'<0.5
}

drop if date<tm(1999m1)
forvalues i=0/24 {
	gen num_`i'= (2/_N)*(( prob_rec_`i'-recessm2_usecon)^2)
}

forvalues i=0/24 {
	egen QPS_`i'=total(num_`i')
}



forvalues h = 0/24 {
	qui roctab recessm2_usecon nberhat`h'
	post nberhats ("mom") (`h') (r(N)) (r(area)) (r(se)) (r(lb)) (r(ub))
	}
clear

postclose nberhats

clear 
use ROC_Beta_out.dta

****** Figure 5 - Section 2.1 *******

twoway (line auroc horizon if growth == "mom", lcol(blue) lpattern(dash)) (line lwrbd horizon if growth == "mom", lpattern(dash) lcolor(gs12)) ///
	(line uprbd horizon if growth == "mom", lpattern(dash) lcolor(gs12) legend(off) xlab(0(6)24) xti("Horizon (months)") yti(AUROC) ylab(0(0.2)1)  graphregion(color(white)) bgcolor(white) ylabel(,nogrid) yline(0.5, lpattern(dash) lwidth(vthin)))  
graph export "`graphdir'/ROC_out_beta_AR.png", as(png) replace

restore

preserve

postfile nberhats str3 growth horizon nobs auroc stderr uprbd lwrbd using ROC_Beta_out_LF.dta, replace

sort date

local enddate = m(2023m7)

drop if date > `enddate'
local bsamp = date[1]
local esamp = `enddate'
local bout = m(1999m1)
local maxhzn 24

forvalues h = 0/24{
	gen nberhat`h' =.
local j = `bsamp'
	forvalues d = `bout'/`esamp'{
		quietly probit recessm2_usecon l`h'._stat_2_LF if date < `d' & date >= `j'

		qui predict temp
		qui replace nberhat`h' = temp if date == `d'
		drop temp
		local j = `j' + 1
		}
	}

keep date recessm2_usecon nberhat*

forvalues i=0/24 {
	gen prob_rec_`i'=.
	replace prob_rec_`i'=1 if nberhat`i'>=0.5
	replace prob_rec_`i'=0 if nberhat`i'<0.5
}

drop if date<tm(1999m1)
forvalues i=0/24 {
	gen num_`i'= (2/_N)*(( prob_rec_`i'-recessm2_usecon)^2)
}

forvalues i=0/24 {
	egen QPS_`i'=total(num_`i')
}



forvalues h = 0/24 {
	qui roctab recessm2_usecon nberhat`h'
	post nberhats ("mom") (`h') (r(N)) (r(area)) (r(se)) (r(lb)) (r(ub))
	}
clear

postclose nberhats

clear 
use ROC_Beta_out_LF.dta

****** Appendix Figure XX - LF section *******

twoway (line auroc horizon if growth == "mom", lcol(blue) lpattern(dash)) (line lwrbd horizon if growth == "mom", lpattern(dash) lcolor(gs12)) ///
	(line uprbd horizon if growth == "mom", lpattern(dash) lcolor(gs12) legend(off) xlab(0(6)24) xti("Horizon (months)") yti(AUROC) ylab(0(0.2)1)  graphregion(color(white)) bgcolor(white) ylabel(,nogrid) yline(0.5, lpattern(dash) lwidth(vthin)))  
graph export "`graphdir'/ROC_out_beta_AR_LF.png", as(png) replace

restore

****** Appendix Figure CFNAI - SA section *******
local graphdir "${topdir}\Figures"
postfile nberhats str3 growth horizon nobs auroc stderr uprbd lwrbd using ROC_CFNAI_out.dta, replace

sort date

local enddate = m(2023m7)

drop if date > `enddate'
local bsamp = date[1]
local esamp = `enddate'
local bout = m(1999m1)
local maxhzn 24

forvalues h = 0/24{
	gen nberhat`h' =.
local j = `bsamp'
	forvalues d = `bout'/`esamp'{
		quietly probit recessm2_usecon l`h'.CF_old if date < `d' & date >= `j'

		qui predict temp
		qui replace nberhat`h' = temp if date == `d'
		drop temp
		local j = `j' + 1
		}
	}

keep date recessm2_usecon nberhat*

forvalues i=0/24 {
	gen prob_rec_`i'=.
	replace prob_rec_`i'=1 if nberhat`i'>=0.5
	replace prob_rec_`i'=0 if nberhat`i'<0.5
}

drop if date<tm(1999m1)
forvalues i=0/24 {
	gen num_`i'= (2/_N)*(( prob_rec_`i'-recessm2_usecon)^2)
}

forvalues i=0/24 {
	egen QPS_`i'=total(num_`i')
}



forvalues h = 0/24 {
	qui roctab recessm2_usecon nberhat`h'
	post nberhats ("mom") (`h') (r(N)) (r(area)) (r(se)) (r(lb)) (r(ub))
	}
clear

postclose nberhats

clear 
use ROC_CFNAI_out.dta

****** Appendix Figure XX - LF section *******

twoway (line auroc horizon if growth == "mom", lcol(blue) lpattern(dash)) (line lwrbd horizon if growth == "mom", lpattern(dash) lcolor(gs12)) ///
	(line uprbd horizon if growth == "mom", lpattern(dash) lcolor(gs12) legend(off) xlab(0(6)24) xti("Horizon (months)") yti(AUROC) ylab(0(0.2)1)  graphregion(color(white)) bgcolor(white) ylabel(,nogrid) yline(0.5, lpattern(dash) lwidth(vthin)))  
graph export "`graphdir'/ROC_out_beta_cfnai.png", as(png) replace


****************** Quarterly Figures ************************
clear
set more off
global topdir "YOUR_Path\replication"
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"
import delimited "`rawdir'\Year-Month-est-and-revisions-79-25.csv"
drop month year
split date, p("/")
rename date1 month
rename date2 day
rename date3 year

destring year, replace
destring month, replace
destring day, replace

gen daily_date=mdy(month,day,year)
format daily_date %td
gen quarter=quarter(daily_date)

drop date 

gen date = ym(year,month)
format date %tm
drop day
gen qdate=yq(year,quarter)
format qdate %tq

rename seasonallyadjustedoverthemonthch first_reading_SA
rename v5 second_reading_SA
rename v6 third_reading_SA
rename seasonallyadjustedrevisioninover ch_level_first_second_SA
rename v8 ch_level_second_third_SA
rename v9 ch_level_first_third_SA
rename notseasonallyadjustedoverthemont first_reading_NSA
rename notseasonallyoverthemonthchangea second_reading_NSA
rename v12 third_reading_NSA
rename notseasonallyadjustedrevisionino ch_level_first_second_NSA
rename v14 ch_level_second_third_NSA
rename v15 ch_level_first_third_NSA

foreach var in ch_level_first_second_SA ch_level_second_third_SA ch_level_first_third_SA ch_level_first_second_NSA ch_level_second_third_NSA ch_level_first_third_NSA {
	replace `var'="" if `var'=="NA***"
	replace `var'="" if `var'=="NA"
	destring `var', replace
}

gen CI_low_95_first_reading = first_reading_NSA - 1.96*82554
gen CI_high_95_first_reading = first_reading_NSA + 1.96*82554

drop if date >tm(2025m7)
order date year month
sort date



collapse (mean) first_reading_SA second_reading_SA third_reading_SA ch_level_first_second_SA ch_level_second_third_SA ch_level_first_third_SA first_reading_NSA second_reading_NSA third_reading_NSA ch_level_first_second_NSA ch_level_second_third_NSA ch_level_first_third_NSA, by(qdate)

tsset qdate

gen ch_rate_1st_2nd_NSA_Q = (ch_level_first_second_NSA-L1.ch_level_first_second_NSA)/abs(L1.ch_level_first_second_NSA)
gen ch_rate_2nd_3rd_NSA_Q = (ch_level_second_third_NSA-L1.ch_level_second_third_NSA)/abs(L1.ch_level_second_third_NSA)
gen ch_rate_1st_3rd_NSA_Q = (ch_level_first_third_NSA-L1.ch_level_first_third_NSA)/abs(L1.ch_level_first_third_NSA)

save "`datadir'\revisions_quarterly.dta", replace



clear
set haverdir "Haver_path"

import haver RECESSQ2@USECON  N111RG10@G10 N111RG3M@G10  LFN@USECON
gen SPREAD = n111rg10_g10- n111rg3m_g10
drop if time<tq(1979q1)
rename time qdate
drop if qdate==tq(2025q4)

tsset qdate
forvalues i=1(1)8 {
gen recession_next`i' = F`i'.recessq2_usecon
}

merge 1:1 qdate using "`datadir'\revisions_quarterly.dta"
drop if _merge==2
drop _merge

gen ch_level_13_NSA_LF = (ch_level_first_third_NSA/lfn_usecon)*100


************* 

tsset qdate, quarterly

gen year= year(dofq(qdate))

summarize ch_level_first_third_NSA if year!=2003
generate recession = r(max) if recessq2_usecon == 1
replace recession  = r(min) if recessq2_usecon == 0

summarize ch_level_first_third_NSA
local min = r(min)

twoway  (area recession qdate if year!=2003,   color(gs14) base(`min'))  (tsline ch_level_first_third_NSA if year!=2003, lcolor(maroon)) , legend(off) xtitle("") ytitle("Revision: 3rd. - 1st. reading - NSA (in thousands)")  graphregion(color(white)) bgcolor(white) ylabel(,nogrid) aspectratio(.5)
graph export "`graphdir'/Levels_R13_Recession_Quarterly.png", as(png) replace


drop recession

summarize ch_level_13_NSA_LF if year!=2003
generate recession = r(max) if recessq2_usecon == 1
replace recession  = r(min) if recessq2_usecon == 0

summarize ch_level_13_NSA_LF
local min = r(min)

twoway  (area recession qdate if year!=2003,   color(gs14) base(`min'))  (tsline ch_level_13_NSA_LF if year!=2003, lcolor(maroon)) , legend(off) xtitle("") ytitle("Revision: 3rd. - 1st. reading - NSA (% Labor Force)")  graphregion(color(white)) bgcolor(white) ylabel(,nogrid) aspectratio(.5)
graph export "`graphdir'/Perc_LF_R13_Recession_Quarterly.png", as(png) replace

******* Monthly + 3MMA graphs *******
clear
set more off

global topdir "YOUR_Path\replication"
local datadir "${topdir}\Data"
local graphdir "${topdir}\Figures"
local tablesdir "${topdir}\Tables"
local rawdir "${topdir}\Raw_Data"

import delimited "`rawdir'\Year-Month-est-and-revisions-79-25.csv"
drop month year
split date, p("/")
rename date1 month
rename date2 day
rename date3 year


destring year, replace
destring month, replace
destring day, replace

drop date 

gen date = ym(year,month)
format date %tm
drop day

rename seasonallyadjustedoverthemonthch first_reading_SA
rename v5 second_reading_SA
rename v6 third_reading_SA
rename seasonallyadjustedrevisioninover ch_level_first_second_SA
rename v8 ch_level_second_third_SA
rename v9 ch_level_first_third_SA
rename notseasonallyadjustedoverthemont first_reading_NSA
rename notseasonallyoverthemonthchangea second_reading_NSA
rename v12 third_reading_NSA
rename notseasonallyadjustedrevisionino ch_level_first_second_NSA
rename v14 ch_level_second_third_NSA
rename v15 ch_level_first_third_NSA

foreach var in ch_level_first_second_SA ch_level_second_third_SA ch_level_first_third_SA ch_level_first_second_NSA ch_level_second_third_NSA ch_level_first_third_NSA {
	replace `var'="" if `var'=="NA***"
	replace `var'="" if `var'=="NA"
	destring `var', replace
}

reg ch_level_first_third_NSA first_reading_NSA, robust
predict se_revision, stdp

gen CI_low_95_first_reading = first_reading_NSA - 1.96*82.554
gen CI_high_95_first_reading = first_reading_NSA + 1.96*82.554

drop if date >tm(2025m7)
order date year month
sort date

tsset date

gen ch_perc_first_second_SA = (ch_level_first_second_SA/abs(first_reading_SA))*100
gen ch_perc_second_third_SA = (ch_level_second_third_SA/abs(second_reading_SA))*100
gen ch_perc_first_third_SA = (ch_level_first_third_SA/abs(first_reading_SA))*100

gen ch_perc_first_second_NSA = (ch_level_first_second_NSA/abs(first_reading_NSA))*100
gen ch_perc_second_third_NSA = (ch_level_second_third_NSA/abs(second_reading_NSA))*100
gen ch_perc_first_third_NSA = (ch_level_first_third_NSA/abs(first_reading_NSA))*100


****** Large 1+2 revisions in levels *****

xtile ptile_rev13_level_SA = ch_level_first_third_SA, nq(100)

gen large_down_13_level_SA = 0
replace large_down_13_level_SA = 1 if ptile_rev13_level_SA<10
gen large_up_13_level_SA = 0
replace large_up_13_level_SA = 1 if ptile_rev13_level_SA>90
gen large_rev_13_level_SA= large_down_13_level_SA + large_up_13_level_SA


xtile ptile_rev13_level_NSA = ch_level_first_third_NSA, nq(100)

gen large_down_13_level_NSA = 0
replace large_down_13_level_NSA = 1 if ptile_rev13_level_NSA<10
gen large_up_13_level_NSA = 0
replace large_up_13_level_NSA = 1 if ptile_rev13_level_NSA>90
gen large_rev_13_level_NSA= large_down_13_level_NSA + large_up_13_level_NSA


label var large_down_13_level_SA "=1 if obs in bottom 10% of level change 1st to 3rd read - SA"
label var large_up_13_level_SA "=1 if obs in top 90% of level change 1st to 3rd read - SA"
label var large_rev_13_level_SA "=1 if obs in bottom 10 or top 90% of level change 1st to 3rd read - SA"

label var large_down_13_level_NSA "=1 if obs in bottom 10% of level change 1st to 3rd read - NSA"
label var large_up_13_level_NSA "=1 if obs in top 90% of level change 1st to 3rd read - NSA"
label var large_rev_13_level_NSA "=1 if obs in bottom 10 or top 90% of level change 1st to 3rd read - NSA"

save "`datadir'\revisions_monthly.dta", replace



clear
set haverdir "Haver_path"

import haver RECESSM2@USECON  LFN@USECON

drop if time<tm(1979m1)

rename time date

merge 1:1 date using "`datadir'\revisions_monthly.dta"
drop _merge


gen ch_level_13_NSA_LF = (ch_level_first_third_NSA/lfn_usecon)*100



************************* Graphing ************************************

* Generate vars to structure shading in graph for recession
tsset date, monthly
summarize ch_level_first_third_NSA if year!=2003
generate recession = r(max) if recessm2_usecon == 1
replace recession  = r(min) if recessm2_usecon == 0


* Choose colors
global color2 = "40 117 168" // "#2875a8"   // blue
global color3 = "230 122 23" // "#e67a17"   // orange

* Generate 3-month moving average
tssmooth ma ch_level_first_third_NSA_ma3 = ch_level_first_third_NSA if year!=2003, window(2 1 0)

* Set ylims for shading recessions
summarize ch_level_first_third_NSA
local min = r(min)


************* Actual plot of 3-MA and monthly revisions

twoway (area recession date if year!=2003,   color(gs14) base(`min')) || ///
(tsline ch_level_first_third_NSA if year!=2003, lcolor("$color2")) || ///
(tsline ch_level_first_third_NSA_ma3 if year!=2003, lcolor("$color3") lpattern(solid) lwidth(normal)), ///
legend(order(2 "Monthly revisions" 3 "3-month moving average") position(10) ring(0) region(lcolor(white) fcolor(white%70)) cols(1)) ///
xtitle("") ytitle("Revision: 3rd - 1st reading - NSA (in thousands)") ///
graphregion(color(white)) bgcolor(white) ylabel(,nogrid) aspectratio(.5) ylabel(-750(250)750)
graph export "`graphdir'/Levels_R13_Recession_Monthly_and_MA3.png", as(png) replace


drop recession

tsset date, monthly
summarize ch_level_13_NSA_LF if year!=2003
generate recession = r(max) if recessm2_usecon == 1
replace recession  = r(min) if recessm2_usecon == 0


* Generate 3-month moving average
tssmooth ma ch_level_13_NSA_LF_ma3 = ch_level_13_NSA_LF if year!=2003, window(2 1 0)

* Set ylims for shading recessions
summarize ch_level_13_NSA_LF
local min = r(min)

twoway (area recession date if year!=2003,   color(gs14) base(`min')) || ///
(tsline ch_level_13_NSA_LF if year!=2003, lcolor("$color2")) || ///
(tsline ch_level_13_NSA_LF_ma3 if year!=2003, lcolor("$color3") lpattern(solid) lwidth(normal)), ///
legend(order(2 "Monthly revisions" 3 "3-month moving average") position(10) ring(0) region(lcolor(white) fcolor(white%70)) cols(1)) ///
xtitle("") ytitle("Revision: 3rd - 1st reading - NSA (in % Labor Force)") ///
graphregion(color(white)) bgcolor(white) ylabel(,nogrid) aspectratio(.5)
graph export "`graphdir'/PercLF_R13_Recession_Monthly_and_MA3.png", as(png) replace