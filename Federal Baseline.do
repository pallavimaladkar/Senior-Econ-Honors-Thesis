cd "~/Dropbox/Honors thesis-Pallavi/Canada data"

use carbon_tax_workfile_v2.dta, clear

********************************************************************************
*								FEDERAL BASELINE
********************************************************************************

// create dummies for carbon tax and credit system
gen carbon_dummy = 0
replace carbon_dummy = 1 if carbon_rate != 0
label var carbon_dummy "Carbon tax policy"
gen credit_dummy = 0
replace credit_dummy = 1 if credit_rate != 0
label var credit_dummy "Credit system policy"

// create logged variables
foreach v in emissions emissionsZ gdp2012 paid_jobs hours_worked wage_rate earnings {
	gen ln`v'=ln(`v')
}

// creating pre-treatment industry characteristics
gen _t=intemissn if year==2004
egen intemissn2004=mean(_t), by(indcode)

gen _s = intenergy if year == 2004
egen intenergy2004 = mean(_s), by(indcode)

// setting controls and fixed effects
global Z "i.credit_cat cap_dummy provpop provpop15_64" // adding credit systems and CATS as controls
global FE "indcodeA province year"

// Sample constraints
gen s=1 if paid_jobs>1000 // remove small industries

// Baseline carbon tax variable, corresponds to federal rates
gen baseline=0
replace baseline=20 if year==2019
replace baseline=30 if year==2020
replace baseline=40 if year==2021
replace baseline=50 if year==2022
label var baseline "Federal carbon tax"
gen carbon_dif=carbon_rate-baseline
gen carbon_dif100 = carbon_dif/100

// View baseline
sort year
twoway (scatter baseline year, c(l) lwidth(medthick)), sub("Carbon tax rate") name(carbontax, replace) 

tab province if carbon_dif < 0 // shows NS and Quebec have negative values

// install regression stuff
// ssc install reghdfe
// ssc install psmatch2
// ssc install ttable2
// ssc install asdoc

********************************************************************************

// Policy = Carbon difference from federal baseline

// Regression with carbon_dif
// reg emissions
// outreg2 using federalbaseline.doc, replace
foreach v in emissions gdp2012 paid_jobs hours_worked earnings {
	reghdfe ln`v' carbon_dif $Z if s==1 & !inlist(province, "Nova Scotia", "Quebec"), absorb($FE) vce(robust)
	outreg2 using federalbaseline.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($Z $FE) label bdec(3) ctitle(`v')
}
***** emissions, paid_jobs, hours_worked, not SS
***** GDP, wage_rate, earnings slight negative
***** GDP, 2 stars, -0.194% change
***** wage_rate, 3 stars, -0.3% change
***** earnings, 3 stars, -0.311% change
***** overall, seemingly very small changes? not sure exactly how important these will end up being

foreach v in emissions gdp2012 paid_jobs hours_worked earnings {
	reghdfe ln`v' carbon_dif100 $Z if s==1 & !inlist(province, "Nova Scotia", "Quebec"), absorb($FE) vce(robust)
	outreg2 using federalbaseline100.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($Z $FE) label bdec(3) ctitle(`v')
}





// Regression with carbon_dif, interacted with PTIC
foreach w in intemissn2004 intenergy2004 innov_ghg1 {
	foreach v in emissions gdp2012 paid_jobs hours_worked earnings {
		reghdfe ln`v' c.carbon_dif##c.`w' $Z if s==1 & !inlist(province, "Nova Scotia", "Quebec"), absorb($FE) vce(robust)
		outreg2 using carbondiffX`w'.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($Z $FE) label bdec(3) ctitle(`v')
	}
}

* intemissn2004
***** carbon_dif, positive SS coeffs on paid_jobs, hours_worked, neg on wage_rate
***** interact1, STRONG SS COEFFS
***** - negatives on GDP, paid_jobs, hours_worked, and earnings
***** - positive on wage_rate

* intenergy2004
***** same relationships as above

* innov_ghg1
***** wage_rate, negative SS coeff, all others no effect
***** interactions, negative S coeffs on GDP, paid_jobs, hours_worked, earnings

foreach w in intemissn2004 intenergy2004 innov_ghg1 {
	foreach v in emissions gdp2012 paid_jobs hours_worked earnings {
		reghdfe ln`v' c.carbon_dif100##c.`w' $Z if s==1 & !inlist(province, "Nova Scotia", "Quebec"), absorb($FE) vce(robust)
		outreg2 using carbondiff100X`w'.doc, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($Z $FE) label bdec(3) ctitle(`v')
	}
}

// heterogeneous effects graph
egen fakeid=group(province indcodeA)
xtset fakeid year
gen l2intemissn=l2.intemissn
xtile categ=l2intemissn, nq(5)

foreach v in lnhours_worked {
	reghdfe `v' c.carbon_dif100##c.l2intemissn $Z if s==1, absorb($FE) vce(robust)
	margins, dydx(carbon_dif100) over(categ)
	marginsplot, title("Effect of Carbon Tax over Federal Baseline on Employment") xdimension(categ) legend(pos(6) row(1)) ytitle("Marginal effects") name(margeff1, replace) yline(0) xtitle(Quantiles of Emission Intensity)
}








