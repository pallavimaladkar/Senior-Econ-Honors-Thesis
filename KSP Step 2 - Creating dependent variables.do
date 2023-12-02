cd "~/Dropbox/Honors thesis-Pallavi/Canada data"
global origin "~r\Dropbox\CPS-shared\Emission"

******************************************************************
*					Labor Variables, 2004-2022
******************************************************************

import delimited using "$origin/Labor.csv", clear

gen select=1 if labourstatistics=="Number of paid workers jobs"
replace select=2 if labourstatistics=="Hours worked of paid workers"
replace select=3 if labourstatistics=="Wages and salaries for paid workers"
replace select=4 if labourstatistics=="Paid workers' actual wage rate"
drop if select==.
drop dguid uom uom_id scalar_factor scalar_id vector coordinate symbol terminated decimals
rename ïref_date year
label var year "Year"
drop if year<2004
drop if geo=="Northwest Territories including Nunavut" | geo=="Canada"
rename geo province

// Industry
rename northamericanindustryclassificat naics_labor
format naics_labor %50s
moss naics_labor, match("\[(.*)\]") regex
tab _count
rename _match indcode_orig
drop _*
gen indcode=indcode_orig if strlen(indcode_orig)>4
replace indcode=indcode_orig+"0" if strlen(indcode_orig)==4
replace indcode=indcode_orig+"00" if strlen(indcode_orig)==3
replace indcode=indcode_orig+"000" if strlen(indcode_orig)==2
replace indcode=indcode_orig+"0000" if strlen(indcode_orig)==1
label var naics_labor "NAICS name in Labor data"
label var indcode_orig "Industry original code"
label var indcode "Industry code"

// Variables
foreach v of numlist 1/4 {
	preserve
		rename value value`v'
		keep if select==`v'
		drop select status
		save temp`v'.dta, replace
	restore
}

// Merging
use temp1.dta, clear
foreach v of numlist 2/4 {
	merge 1:1 province year indcode using temp`v'.dta, nogen
}	
rename value1 paid_jobs
rename value2 hours_worked
rename value3 earnings
rename value4 wage_rate
label var paid_jobs "Number of paid workers jobs"
label var hours_worked "Hours worked of paid workers"
label var earnings "Wages and salaries for paid workers"
label var wage_rate "Paid workers' actual wage rate"
order province year naics* indcode*
save labor_combined.dta, replace

foreach v of numlist 1/4 {
	erase temp`v'.dta
}

******************************************************************
*					GDP, 2004-2022
******************************************************************

import delimited using "GDP-by-province-industry-year.csv", clear

gen select=1 if value=="Current dollars"
replace select=2 if value=="Chained (2012) dollars"
replace select=3 if value=="Contributions to percent change"
drop if select==.
drop dguid uom uom_id scalar_factor scalar_id vector coordinate symbol terminated decimals status
rename ïref_date year
label var year "Year"
drop if year < 2004
rename geo province
label var province "Province"
rename northamericanindustryclassificat naics_gdp

// Industry
ssc install moss
format naics_gdp %50s
moss naics_gdp, match("\[(.*)\]") regex
tab _count
rename _match indcode_orig
drop _*
gen indcode=indcode_orig if strlen(indcode_orig)>4
replace indcode=indcode_orig+"0" if strlen(indcode_orig)==4
replace indcode=indcode_orig+"00" if strlen(indcode_orig)==3
replace indcode=indcode_orig+"000" if strlen(indcode_orig)==2
replace indcode=indcode_orig+"0000" if strlen(indcode_orig)==1
label var naics_gdp "NAICS name in GDP data"
label var indcode_orig "Industry original code"
label var indcode "Industry code"

// Variables
foreach v of numlist 1/3 {
	preserve
		rename v12 value`v'
		keep if select==`v'
		drop select
		save temp`v'.dta, replace
	restore
}

// Merging
use temp1.dta, clear
foreach v of numlist 2/3 {
	merge 1:1 province year indcode using temp`v'.dta, nogen
}	
rename value1 gdpcurrent
rename value2 gdp2012
rename value3 perchange
label var gdpcurrent "GDP in current dollars (millions)"
label var gdp2012 "GDP in chained (2012) dollars (millions)"
label var perchange "Contributions to percent change"
drop value
order province year naics* indcode*
save gdp_ready.dta, replace

foreach v of numlist 1/3 {
	erase temp`v'.dta
}

******************************************************************
*				Emissions, 2009-2020
******************************************************************

import delimited using "Emissions-by-province-industry-year.csv", clear
drop dguid uom uom_id scalar_factor scalar_id vector coordinate status symbol terminated decimals
rename *ref_date year
label var year "Year"
rename geo province
label var province "Province"
gen naics_emission=sector
drop sector
format naics_emission %50s
label var naics_emission "NAICS code and sector"
rename value emissions
label var emissions "GHG emissions (kilotons)"
drop if province == "Canada"
save emissions_ready.dta, replace