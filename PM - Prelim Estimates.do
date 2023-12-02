cd "~/Dropbox/Honors thesis-Pallavi/Canada data"



// merging policy variables
import excel using "TaxRatesbyProvince.xlsx", clear first
tempfile TaxRatesbyProvince
save `TaxRatesbyProvince'

use carbon_tax_workfile.dta, clear

merge m:1 province year using `TaxRatesbyProvince', keep(1 3) nogen


// getting data ready
drop L M N O P Q

label var tax_dummy "Carbon tax dummy"
label var tax_cat "Carbon tax level of enforcement"
label var tax_rate "Carbon tax rate $/tonCO2e"
label var credit_dummy "Baseline and credit system dummy"
label var credit_cat "Baseline and credit system level of enforcement"
label var CAT_dummy "Cap-and-trade dummy"
label var CAT_rate "Cap-and-trade system cap (metric tons/million emission units)"

foreach v in tax_dummy tax_rate credit_dummy CAT_dummy CAT_rate {
	replace `v'=0 if `v'==.
}


********************************************************************************
*									REGRESSIONS
********************************************************************************

ssc install reghdfe
global Z "provpop provpop15_64"

foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
	gen ln`v'=ln(`v')
}

gen _t=intemissn if year==2004
egen intemissn2004=mean(_t), by(indcode_orig)

gen _s = intenergy if year == 2004
egen intenergy2004 = mean(_s), by(indcode_orig)





// CARBON TAX DUMMY

// foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
// 	reghdfe `v' tax_dummy##c.innov_any1 $Z, absorb(indcode_orig province year) vce(robust)
// }

foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
	reghdfe ln`v' tax_dummy##c.innov_any1 $Z, absorb(indcode_orig province year) vce(robust)
	outreg2 using prelim_tax.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop(provpop provpop15_64) label ctitle(`v')

}



// CREDIT SYSTEM DUMMY

// foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
// 	reghdfe `v' credit_dummy##c.innov_any1 $Z, absorb(indcode_orig province year) vce(robust)
// }

foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
	reghdfe ln`v' credit_dummy##c.innov_any1 $Z, absorb(indcode_orig province year) vce(robust)
	outreg2 using prelim_credit.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop(provpop provpop15_64) label ctitle(`v')
}



// CAT DUMMY

foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
	reghdfe ln`v' CAT_dummy##c.innov_any1 $Z, absorb(indcode_orig province year) vce(robust)
	outreg2 using prelim_CAT.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop(provpop provpop15_64) label ctitle(`v')
}







// ALL 3 POLICIES

// innovations
foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
	reghdfe ln`v' tax_dummy##c.innov_any1 credit_dummy##c.innov_any1 CAT_dummy##c.innov_any1 $Z, absorb(indcode_orig province year) vce(robust)
	outreg2 using prelim_inn.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop(provpop provpop15_64) label ctitle(`v')
}

// emissions intensity
foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
	reghdfe ln`v' tax_dummy##c.intemissn2004 credit_dummy##c.intemissn2004 CAT_dummy##c.intemissn2004 $Z, absorb(indcode_orig province year) vce(robust)
	outreg2 using prelim_emissn.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop(provpop provpop15_64) label ctitle(`v')
}

// energy intensity
foreach v in emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings {
	reghdfe ln`v' tax_dummy##c.intenergy2004 credit_dummy##c.intenergy2004 CAT_dummy##c.intenergy2004 $Z, absorb(indcode_orig province year) vce(robust)
	outreg2 using prelim_energy.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop(provpop provpop15_64) label ctitle(`v')
}












