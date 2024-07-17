cd "~/Dropbox/Honors thesis-Pallavi/Canada data"

******************************************************************
*					Merging data sets
******************************************************************

	*** Crosswalks

// Intensity-Labor crosswalk
import excel using "Crosswalk-intensity.xlsx", clear first
keep match naics_intens2009 indcodeA
drop if indcodeA==""
tempfile crosswalk1
save `crosswalk1'

// Innovation-Labor crosswalk
import excel using "Crosswalk-intensity.xlsx", clear first
keep match naics_innov indcodeA
drop if indcodeA==""
tempfile crosswalk2
save `crosswalk2'

// Emission-Labor crosswalk
import excel using "Crosswalk-intensity.xlsx", clear first
keep match naics_emission indcodeA indcode
drop if indcodeA==""
tempfile crosswalk3
save `crosswalk3'

	*** Aggregate labor and GDP variables for split industries

use labor_combined.dta, clear
replace indcode="4AA00" if indcode=="44-45"
merge 1:1 province year indcode using gdp_ready.dta, keep(3) nogen 

clonevar indcodeA=indcode
clonevar naics_laborA=naics_labor

replace indcodeA="4A000" if indcode=="4AA00"

replace indcodeA="325C0" if indcode=="325A0" | indcode=="32520"
replace naics_laborA="Miscellaneous chemical product manufacturing [BS325C0]" if indcodeA=="325C0"

replace indcodeA="334B0" if indcode=="33420" | indcode=="33440" | indcode=="334A0"
replace naics_laborA="Electronic product manufacturing [BS334B0]" if indcodeA=="334B0"

replace indcodeA="335A0" if indcode=="33510" | indcode=="33530" | indcode=="33590"
replace naics_laborA="Electrical  equipment and component manufacturing [BS335A0]" if indcodeA=="335A0"

replace indcodeA="48B00" if indcode=="48800" | indcode=="48Z00"
replace naics_laborA="Transit, ground passenger and scenic and sightseeing transportation, taxi and limousine service and support activities for transportation [BS48B00]" if indcodeA=="48B00"

replace indcodeA="51B00" if indcode=="51520" | indcode=="51700" | indcode=="51800" | indcode=="51900" | indcode=="51100"
replace naics_laborA="Publishing, pay/specialty services, telecommunications and other information services [BS51B00]" if indcodeA=="51B00"

replace indcodeA="53B00" if indcode=="53200" | indcode=="53300"
replace naics_laborA="Rental and leasing services and lessors of non-financial intangible assets (except copyrighted works) [BS53B00]" if indcodeA=="53B00"

replace indcodeA="541C0" if indcode=="541A0" | indcode=="54130"
replace naics_laborA="Legal, accounting and architectural, engineering and related services [BS541C0]" if indcodeA=="541C0"

replace indcodeA="541D0" if indcode=="541B0" | indcode=="54150"
replace naics_laborA="Computer systems design and other professional, scientific and technical services [BS541D0]" if indcodeA=="541D0"

foreach v in gdp2012 paid_jobs hours_worked earnings wage_rate {
	local lbl_`v': variable label `v'
}
collapse (sum) gdp2012 paid_jobs hours_worked earnings, by(province year indcodeA naics_laborA)
gen wage_rate=earnings/hours_worked
replace wage_rate=0 if hours_worked==0
foreach v in gdp2012 paid_jobs hours_worked earnings wage_rate {
	label var `v' "`lbl_`v''"
}

// Add emissions data, 2009-2021
merge m:1 indcodeA using `crosswalk3', nogen keep(2 3)		// must be perfect
merge 1:1 province naics_emission year using emissions_ready.dta, keep(1 3) nogen

clonevar emissionsZ=emissions
replace emissionsZ=0 if emissionsZ==. & year>2008 & year<2022	// checked
label var emissionsZ "GHG emissions, zero-imputed"

// Add intensity data, 2004-2019
merge m:1 indcodeA using `crosswalk1', nogen keep(1 3)
merge m:1 naics_intens2009 year using intensity_ready.dta, keep(1 3) 
* missing intensity: Other aboriginal government services
tab year _m
drop _m

// Add innovation data (time-constant)
merge m:1 indcodeA using `crosswalk2', nogen keep(1 3)
gen province2=province
replace province2="Atlantic Region" if province=="New Brunswick" | province=="Newfoundland and Labrador" | province=="Nova Scotia" | province=="Prince Edward Island" 
replace province2="Rest of Canada" if province=="Alberta" | province=="British Columbia" | province=="Manitoba" | province=="Northwest Territories" | province=="Nunavut" | province=="Saskatchewan" | province=="Yukon"
merge m:1 province2 naics_innov using innovations_ready.dta, keep(1 3)
tab naics_labor if _m==1		// missing innovations in the public sector
drop _m province2

// Add population
merge m:1 province year using population_ready.dta, keep(1 3) nogen
merge m:1 province year using workagepop_ready.dta, keep(1 3) nogen

// Add environmental tax, 2010-2020 (use lagged)
merge m:1 province year using envtax_ready.dta, keep(1 3) nogen

// Add carbon tax policies
merge m:1 province year using envpolicy_ready.dta, keep(1 3) nogen

replace carbon_rate=carbon_rate/100
gen emissrev=(crbtax_all+permit_all)/prdtax_all
label var emissrev "Share of tax revenue from emission-related taxes"

// Sector
gen sector = substr(indcodeA, 1, 2)
destring sector, replace ignore("A")
recode sector 11=1 21/22=2 23=3 31/33=4 4 41=5 48=6 49/81=7 91=8
label define sector 1 "Farming and Forestry" 2 "Mining, oil, gas, electricity" 3 "Construction" 4 "Manufacturing" 5 "Trade" 6 "Transportation" 7 "Services" 8 "Government"
label values sector sector
label var sector "Sector"

// IDs
egen id=group(province indcodeA)
label var id "Province-Industry ID"

// province id
encode province, gen(provid)
label var provid	"Province ID"
order id province provid sector

drop indcode match naics_emission naics_innov
save carbon_tax_workfile_v2.dta, replace








