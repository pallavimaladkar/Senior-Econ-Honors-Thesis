cd "~/Dropbox/Honors thesis-Pallavi/Canada data"

******************************************************************
*					Intensity crosswalks
******************************************************************

import excel using "Crosswalk-intensity.xlsx", clear first
keep match naics_intens2009 naics_intens2008
drop if naics_intens2008==""
duplicates drop
duplicates list naics_intens2008
tempfile crosswalk2008
save `crosswalk2008'

import excel using "Crosswalk-intensity.xlsx", clear first
keep match naics_intens2009 
drop if naics_intens2009==""
duplicates drop 
duplicates list naics_intens2009
tempfile crosswalk2009
save `crosswalk2009'


******************************************************************
*			Energy and Emission Intensity, 1990-2008
******************************************************************

// Energy intensity
import delimited using "Intensity energy 1990-2008.csv", clear
drop dguid uom uom_id scalar_factor scalar_id vector coordinate symbol terminated decimals
drop if intensitymeasure=="Index, 1990=100"
drop intensitymeasure status geo
rename *ref_date year
label var year "Year"
drop if year<2004
rename industryllevelaggregation naics_intens2008
rename value intenergy
label var intenergy "Energy intensity"
tempfile energy
save `energy'

// Emission Intensity
import delimited using "Intensity emission 1990-2008.csv", clear
drop dguid uom uom_id scalar_factor scalar_id vector coordinate symbol terminated decimals
drop if intensitymeasure=="Index, 1990=100"
drop intensitymeasure status geo
rename ïref_date year
label var year "Year"
drop if year<2004
rename industryllevelaggregation naics_intens2008
rename value intemissn
merge 1:1 naics_intens2008 year using `energy', nogen
merge m:1 naics_intens2008 using `crosswalk2008', nogen
keep if match==1
drop match
collapse int*, by(naics_intens2009 year)		// average intensity for multiple naics2008 per naics2009
label var intemissn "GHG emission intensity"
label var intenergy "Energy intensity"
save intensity2008.dta, replace


******************************************************************
*			Energy and Emission Intensity, 2009-2020
******************************************************************

import delimited using "Intensity 2009-2019.csv", clear
drop geo dguid uom uom_id scalar_factor scalar_id vector coordinate symbol terminated decimals
rename ïref_date year
label var year "Year"
gen naics_intens2009=sector
label var naics_intens2009 "Industry name in 2009 intensity files"
drop sector

drop if naics_intens2009=="Crop and animal production [BS11A00]" & year>=2014 & year<=2020 
drop if naics_intens2009=="Retail trade [BS4A000]" & year>=2014 & year<=2020 
replace naics_intens2009="Crop and animal production [BS11A00]" if naics_intens2009=="Crop and animal production (except cannabis) [BS11B00]" & year>=2014 & year<=2020
replace naics_intens2009="Retail trade [BS4A000]" if naics_intens2009=="Retail trade (except cannabis) [BS4AA00]" & year>=2014 & year<=2020

preserve
rename value intenergy // renaming energy intensity
label var intenergy "Energy intensity, 2009-19"
keep if intensity=="Direct plus indirect energy intensity" // keep energy intensity
drop intensity 
rename status miss_energy
label var miss_energy "Reasons for missing energy intensity"
tempfile energy2009
save `energy2009'
restore

rename value intemissn
label var intemissn "GHG emission intensity, 2009-19"
keep if intensity=="Direct plus indirect greenhouse gas emissions intensity" // keep GHG emissions
drop intensity status
merge 1:1 naics_intens2009 year using `energy2009', nogen
merge m:1 naics_intens2009 using `crosswalk2009', nogen  // ???
keep if match==1
drop match
append using intensity2008.dta
order naics* year
save intensity_ready.dta, replace

erase intensity2008.dta
?

******************************************************************
*					Innovations, 2015-2019
******************************************************************

import delimited using "Innovations.csv", clear
keep if enterprisesize=="Total, all enterprise sizes"
gen select=1 if environmentalbenefitsfrominnovat=="Reduced greenhouse gas emissions"
replace select=2 if environmentalbenefitsfrominnovat=="Reduced greenhouse gas emissions for the end user or consumer"
replace select=3 if environmentalbenefitsfrominnovat=="Innovations with any environmental benefits"
drop enterprisesize environmentalbenefitsfrominnovat dguid uom uom_id scalar_factor scalar_id vector coordinate symbol terminated decimals

encode ïref_date, gen(survey)
drop ïref_date
label var survey "Innovation survey year"
rename geo province2
gen naics_innov=northamericanindustryclassificat
drop northamericanindustryclassificat
format naics_innov %50s

// Variables
foreach v of numlist 1/3 {
	preserve
		rename value value`v'
		rename status status`v'
		keep if select==`v'
		drop select 
		save temp`v'.dta, replace
	restore
}
// Quality of estimate
use temp1.dta, clear
foreach v of numlist 2/3 {
	merge 1:1 province2 survey naics_innov using temp`v'.dta, nogen
}	
rename value1 innov_ghg
rename value2 innov_end
rename value3 innov_any
rename status1 innov_ghgQ
rename status2 innov_endQ
rename status3 innov_anyQ

reshape wide innov*, i(province2 naics_inn) j(survey) 
label var innov_ghg1 "Reduced GHG emissions"
label var innov_end1 "Reduced GHG emissions for end user/consumer"
label var innov_any1 "Innovations with any environmental benefits"
foreach v in innov_ghg innov_end innov_any {
	local x: variable label `v'1
	label var `v'Q1 "Quality flag: `x' 2015-17"
	label var `v'Q2 "Quality flag: `x' 2017-19"
	label var `v'1 "`x' 2015-17"
	label var `v'2 "`x' 2017-19"
}
order province* naics*  
save innovations_ready.dta, replace

foreach v of numlist 1/3 {
	erase temp`v'.dta
}

******************************************************************
*				Population Control Variable, 2004-2022
******************************************************************

import delimited using "Population.csv", clear
drop dguid uom uom_id scalar_factor scalar_id vector coordinate status symbol terminated decimals
rename *ref_date year
label var year "Year"
drop if year < 2004
rename geo province
label var province "Province"
keep if sex == "Both sexes"
drop sex 
drop if province == "Canada"

preserve 
keep if agegroup == "All ages"
rename value provpop
label var provpop "Province total population"
drop agegroup
save population_ready.dta, replace
restore

keep if agegroup == "15 to 64 years"
rename value provpop15_64
label var provpop15_64 "Province working age population"
drop agegroup
save workagepop_ready.dta, replace





