
********************************************************************************
*							Heterogeneous effects
********************************************************************************

* Interactions
* Quantile regression
* Correlated random coefficient model
* GSEM

use carbon_tax_workfile_v2.dta, clear

// creating fakeid, unique grouping of province and industry
egen fakeid=group(province indcodeA)
xtset fakeid year

// create dummies for carbon tax and credit system
gen carbon_dummy = 0
replace carbon_dummy = 1 if carbon_rate != 0
label var carbon_dummy "Carbon tax policy"
gen credit_dummy = 0
replace credit_dummy = 1 if credit_rate != 0
label var credit_dummy "Credit system policy"

// Log transformation and re-scaling
foreach v in emissions gdp2012 paid_jobs hours_worked wage_rate earnings {
	gen ln`v'=ln(1+`v') // 1+ so values at 0 dont come in undefined
}
replace carbon_rate=carbon_rate/100							// why divide by 100 ? maybe to make coeffs easier to interpret
gen l2emissrev=l2.emissrev	// lagging emissrev by 2 years
gen l2intemissn=l2.intemissn
xtile categ=l2intemissn, nq(5)	// new variable, categorizes exp by quantiles

// setting global variables
global FE "indcodeA province year"

// Sample constraints
gen s=1 if paid_jobs>1000 // remove small industries

// install regression stuff
// ssc install reghdfe
// ssc install psmatch2
// ssc install ttable2
// ssc install asdoc




********************************************************************************
*								Carbon taxes
********************************************************************************

global Z "credit_dummy cap_dummy provpop provpop15_64" // adding credit systems and CATS as controls

// carbon rates
foreach v in lnpaid_jobs {
	reghdfe `v' c.carbon_rate##c.l2intemissn $Z if s==1, absorb($FE) vce(robust)
	margins, dydx(carbon_rate) over(categ)
	marginsplot, title("Effect of Carbon Taxes on Employment") xdimension(categ) legend(pos(6) row(1)) ytitle("Marginal effects") name(margeff1, replace) yline(0) xtitle(Quantiles of Emission Intensity)
}

// emission revenue
foreach v in lnpaid_jobs {
	reghdfe `v' c.l2emissrev##c.l2intemissn $Z if s==1, absorb($FE) vce(robust)
	margins, dydx(l2emissrev) over(categ)
	marginsplot, title("Effect of Carbon Taxes on Employment") xdimension(categ) legend(pos(6) row(1)) ytitle("Marginal effects") name(margeff1, replace) yline(0) xtitle(Quantiles of Emission Intensity)
}

// EMISSIONS

// JOBS
// carbon_rate
***** VERY NICE VERY PRETTY
***** higher emissions intensive firms lose more jobs, vice versa for less EI firms

// emissrev
***** NICE same relationship
***** not as centered around 0, Q2 and beyond all below 0
***** jobs hella suffer from increased carbon tax revenue



// GDP
// carbon_rate
***** same relationship
***** YOINKS all negative tho, it just hurts less for lower emissions int firms

// emissrev
***** same relationship
***** again all negative, hurts less for lower emissions int firms



********************************************************************************
*							Cap-and-trade systems
********************************************************************************

global Z "carbon_dummy credit_dummy provpop provpop15_64" // adding credit systems and CATS as controls

foreach v in lnemissions {
	reghdfe `v' c.cap_rate##c.l2intemissn $Z if s==1, absorb($FE) vce(robust)
	margins, dydx(cap_rate) over(categ)
	marginsplot, title("Effect of Cap-and-trade System on Emissions") xdimension(categ) legend(pos(6) row(1)) ytitle("Marginal effects") name(margeff1, replace) yline(0) xtitle(Quantiles of Emission Intensity) plotopts(color(blue)) ciopts(color(blue))
}














