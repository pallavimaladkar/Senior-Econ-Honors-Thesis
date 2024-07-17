cd "~\Dropbox\Honors thesis-Pallavi\Canada data"

******************************************************************
*				Environmental Policies
******************************************************************

import excel using "Carbon tax data.xlsx", clear first
drop *_ind *_all Notes GeneralDescription link1 link2 LargeEmitters
rename *, lower

// Carbon tax
gen carbon_cat=1 if carbontax=="None"
replace carbon_cat=2 if carbontax=="Federal"
replace carbon_cat=3 if carbontax=="Provincial"
label define carbon_cat 1 "None" 2 "Federal" 3 "Provincial"
label values carbon_cat carbon_cat
label var carbon_cat "Carbon tax policy type"
tab carbontax carbon_cat
drop carbontax

rename carbontaxrate carbon_rate
label var carbon_rate "Carbon tax rate $/tonCO2e"

// Cap-and-trade
gen cap_dummy=(creditsystem=="Cap-and-Trade")
label var cap_dummy "Cap-and-trade policy"

gen cap_rate=0
replace cap_rate=excesscharge if cap_dummy==1
label var cap_rate "Auction price, $/tonCO2e"

// Credit system
rename excesscharge credit_rate
replace credit_rate=0 if cap_dummy==1 
label var credit_rate "Excess charge $/tonCO2e"

gen credit_cat=1 if creditsystem=="None" | creditsystem=="Cap-and-Trade"
replace credit_cat=2 if creditsystem=="Federal"
replace credit_cat=3 if creditsystem=="Provincial" | creditsystem=="Mixed credit sytem"
label define credit_cat 1 "None" 2 "Federal" 3 "Provincial"
label values credit_cat credit_cat
label var credit_cat "Baseline and credit system type"
tab creditsystem credit_cat
drop creditsystem
order province year carbon_cat carbon_rate credit_cat credit_rate cap_dummy cap_rate
save envpolicy_ready.dta, replace


******************************************************************
*				Environmental Tax, 2010-2020
******************************************************************

import delimited using "Environmental tax 2010-2020.csv", clear
drop dguid uom uom_id scalar_factor scalar_id vector coordinate status symbol terminated decimals
rename *ref_date year
label var year "Year"
rename geo province
label var province "Province"
drop if province == "Canada"
encode environmentaltax, gen(temp)
label list temp
drop if temp==6 | temp==7  // Share of environmental taxes and Total, energy taxes
*keep if temp<3 | temp==8 | temp==9

encode economicsector, gen(temp2)
keep if temp2==3 | temp2==5		// Industry and Total
label list temp2
gen categ=temp+100*temp2
tab categ
drop temp temp2 environmentaltax economicsector
reshape wide value, i(province year) j(categ)

rename value301 crbtax_ind
rename value302 permit_ind
rename value303 enfuel_ind
rename value304 natres_ind
rename value305 pollut_ind
rename value308 envtax_ind
rename value309 prdtax_ind
rename value310 transp_ind
rename value501 crbtax_all
rename value502 permit_all
rename value503 enfuel_all
rename value504 natres_all
rename value505 pollut_all
rename value508 envtax_all
rename value509 prdtax_all
rename value510 transp_all

label var crbtax_ind "Carbon tax"
label var permit_ind "Emission trading permits" 
label var enfuel_ind "Energy and fuel for transport taxes"
label var natres_ind "Natural resources taxes"
label var pollut_ind "Pollution taxes"
label var envtax_ind "Environmental taxes" 
label var prdtax_ind "Taxes on products and production" 
label var transp_ind "Transportation taxes" 
foreach v in crbtax permit enfuel natres pollut envtax prdtax transp {
		local lbl : variable label `v'_ind
		label var `v'_ind "`lbl', industry"
		label var `v'_all "`lbl', all sectors"
}
format prdtax_ind %12.0g
format prdtax_all %12.0g
tempfile tax
save `tax'

use population_ready.dta, clear
drop provpop
merge 1:1 province year using `tax', nogen
sort province year
save envtax_ready.dta, replace
?

foreach v in permit_ind permit_all {
	replace `v'=0 if year<2010
	replace `v'=. if province=="Alberta" & year>=2007 & year<=2009
}
foreach v in crbtax_ind crbtax_all {
	replace `v'=0 if year<2010
	replace `v'=. if province=="British Columbia" & year>=2008 & year<=2009
	replace `v'=. if province=="Quebec" & year>=2007 & year<=2009
}


