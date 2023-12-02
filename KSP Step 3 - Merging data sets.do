cd "~\Dropbox\Honors thesis-Pallavi\Canada data"

******************************************************************
*					Merging data sets
******************************************************************

// Intensity-Labor crosswalk
import excel using "Crosswalk-intensity.xlsx", clear first
keep match naics_intens2009 naics_labor
drop if naics_labor==""
duplicates drop
tempfile crosswalk1
save `crosswalk1'

// Innovation-Labor crosswalk
import excel using "Crosswalk-intensity.xlsx", clear first
keep match naics_innov naics_labor
drop if naics_labor==""
duplicates drop
tempfile crosswalk2
save `crosswalk2'

// Emission-Labor crosswalk
import excel using "Crosswalk-intensity.xlsx", clear first
keep match naics_emission naics_labor
drop if naics_labor==""
duplicates drop
tempfile crosswalk3
save `crosswalk3'

// Keep selected industries
use labor_combined.dta, clear
drop labourstatistics
merge m:1 naics_labor using `crosswalk1', nogen keep(1 3)
keep if match==1
drop match

// Add intensity data
merge m:1 naics_intens2009 year using intensity_ready.dta, keep(1 3) nogen

// Add emission data, 2009-2020
merge m:1 naics_labor using `crosswalk3', nogen keep(1 3)
merge m:1 province naics_emission year using emissions_ready.dta, keep(1 3) 
tab year _m
drop _m

// Add innovation data
merge m:1 naics_labor using `crosswalk2', nogen keep(1 3)
gen province2=province
replace province2="Atlantic Region" if province=="New Brunswick" | province=="Newfoundland and Labrador" | province=="Nova Scotia" | province=="Prince Edward Island" 
replace province2="Rest of Canada" if province=="Alberta" | province=="British Columbia" | province=="Manitoba" | province=="Northwest Territories" | province=="Nunavut" | province=="Saskatchewan" | province=="Yukon"
merge m:1 province2 naics_innov using innovations_ready.dta, keep(1 3)
tab naics_labor if _m==1		// missing innovations in the public sector
drop _m

// Add GDP
/*
* alternative industries for missing GDP -> may create inconsistent series ->ignore
gen indcode2=indcode
replace indcode="32590" if indcode=="325A0" & year<2007
replace indcode="325B0" if indcode=="32520" & year<2007
replace indcode="51A00" if indcode=="51520" & year<2007
replace indcode="51A00" if indcode=="51700" & year<2007
replace indcode="51A00" if indcode=="51900" & year<2007
replace indcode="53A00" if indcode=="53200" & year<2007
replace indcode="53A00" if indcode=="53300" & year<2007
*/
merge m:1 province indcode year using gdp_ready.dta, keep(1 3) nogen
tab naics_labor if gdp2012==.
note: GDP is missing in 7 industries -> ignore
drop province2 match naics_emission naics_intens2009 naics_innov naics_gdp indcode

// Add population
merge m:1 province year using population_ready.dta, keep(1 3) nogen
merge m:1 province year using workagepop_ready.dta, keep(1 3) nogen

label var intemissn "GHG emission intensity, 2004-2019"
label var intenergy "Energy intensity, 2004-2019"

save carbon_tax_workfile.dta, replace

* Data collection
	* Collect tax rates and other policy characteristics
	* Collect proxy measures of channels in the theoretical model

* Pre-estimation work with variables
	* Classify industries by type and include industry type instead of moderating variables
	* Create sectors for 2-digit industries https://www23.statcan.gc.ca/imdb/p3VD.pl?Function=getVD&TVD=1181553
	* Create categorical variables from intensity and innovations (determine thresholds)

* Estimation
	* use tax rate instead of post
	* separate estimates by each treated province
	* balancing
	* dynamic TEs
	* models with timelines

?

******************************************************************
* 					Policy dummy variable
******************************************************************
			
gen taxbeg = .
replace taxbeg = 2008 if province == "British Columbia"
replace taxbeg = 2017 if province == "Alberta"
replace taxbeg = 2019 if province == "Newfoundland and Labrador"
replace taxbeg = 2019 if province == "Northwest Territories"
replace taxbeg = 2019 if province == "Prince Edward Island"
replace taxbeg = 2020 if province == "New Brunswick"
label var taxbeg "Year of carbon tax implementation"

gen taxend = .
replace taxend = 2019 if province == "Alberta"
label var taxend "Year of carbon tax abolishment"

label define taxcat 1 "Never" 2 "Before" 3 "During" 4 "After"
gen taxcat=1 if taxbeg==.
replace taxcat = 2 if taxbeg<. & year<=taxbeg
replace taxcat = 3 if taxbeg<. & year>taxbeg & year<=taxend
replace taxcat = 4 if taxbeg<. & year>taxend
label values taxcat taxcat
label var taxcat "Stages of carbon tax policy"

gen post=1 if year>taxbeg & taxbeg~=.		// switchers after
replace post=0 if year<taxbeg &  taxbeg~=.	// switchers before
replace post=0 if taxbeg==.		// never treated

*recode taxcat 3=1  1 2 4=0, gen(post)
label var post "Carbon tax in place"

******************************************************************
*					Preliminary estimates
******************************************************************

gen timeline=year-taxbeg

foreach v in paid_jobs hours_worked earnings wage_rate {
	gen ln`v'=ln(`v')
}

gen _intemissn=intemissn if timeline==-2
egen intemissnM=mean(intemissn), by(indcode)

foreach v in paid_jobs hours_worked earnings wage_rate {
	reghdfe ln`v' i.post##c.intemissnM, absorb(indcode year) vce(robust)
}


