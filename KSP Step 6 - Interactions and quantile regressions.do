cd "~/Dropbox/Honors thesis-Pallavi/Canada data"

*************************************************************
*			Baseline regression with lagged covariates
*************************************************************

use carbon_tax_workfile_v2.dta, clear
xtset id year

// Log transformation and re-scaling
foreach v in emissionsZ paid_jobs earnings hours_worked {
	gen ln`v'=ln(1+`v')
}
gen l2emissrev=l2.emissrev
gen l2intemissn=l2.intemissn
xtile categ=l2intemissn, nq(5)

// Sample constraints
gen s=1 if paid_jobs>1000 // remove small industries

// Vectors
global Z "i.credit_cat cap_dummy provpop provpop15_64"
global FE "indcodeA province year"

collapse (sum) emissionsZ, by(sector year provid)
recode emissionsZ* 0=.
reshape wide emissionsZ, i(sector year) j(provid)

xtset sector year
scatter emissionsZ1 year  if sector==2, c(l) name(emissionsZ1, replace)
foreach v in 1 2 3 9 11 12 {
	scatter emissionsZ`v' year  if sector==3, c(l) name(emissionsZ`v', replace)
}

egen id=group(provid sector)
label var id "Province-sector ID"

foreach v of numlist 1/8 {
	tab sector if sector==`v'
	reghdfe lnpaid_jobs l.lnpaid_jobs i.carbon_cat $Z if s==1 & sector==`v', absorb($FE) vce(robust)
}
foreach v of numlist 1/8 {
	tab sector if sector==`v'
	reghdfe lnemissions l.lnemissions i.carbon_cat $Z if sector==`v', absorb(province year) vce(robust)
}

// Baseline
reg emissions
outreg2 using baseline.xls, replace
foreach v in emissions paid_jobs earnings  {
	reghdfe ln`v' carbon_rate $Z if s==1, absorb($FE) vce(robust)
	outreg2 using baseline.xls, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($FE) label ctitle(`v')
}
foreach v in emissions paid_jobs earnings  {
	reghdfe ln`v' l2emissrev $Z if s==1, absorb($FE) vce(robust)
	outreg2 using baseline.xls, append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($FE) label ctitle(`v')
}

*************************************************************
*			Heterogeneous effects
*************************************************************

* Interactions
* Quantile regression
* Correlated random coefficient model
* GSEM

// Interactions + marginal effects
reghdfe lnpaid_jobs c.carbon_rate##c.l2intemissn $Z if s==1, absorb($FE) vce(robust)
margins, dydx(carbon_rate) over(categ)
marginsplot, title("Effect of Carbon Tax on Employment") xdimension(categ) legend(pos(6) row(1)) ytitle("Marginal effects") name(margeff1, replace) yline(0) xtitle(Quantiles)

reghdfe lnpaid_jobs c.l2emissrev##c.l2intemissn $Z if s==1, absorb($FE) vce(robust)
margins, dydx(l2emissrev) over(categ)
marginsplot, title("Effect of Carbon Tax Revenue Share on Employment") xdimension(categ) legend(pos(6) row(1)) ytitle("Marginal effects") name(margeff2, replace) yline(0) xtitle(Quantiles)

reghdfe lnearnings c.carbon_rate##c.l2intemissn $Z if s==1, absorb($FE) vce(robust)
margins, dydx(carbon_rate) over(categ)
marginsplot, title("Effect of Carbon Tax on Earnings") xdimension(categ) legend(pos(6) row(1)) ytitle("Marginal effects") name(margeff3, replace) yline(0) xtitle(Quantiles)

reghdfe lnhours_worked c.carbon_rate##c.l2intemissn $Z if s==1, absorb($FE) vce(robust)
margins, dydx(carbon_rate) over(categ)
marginsplot, title("Effect of Carbon Tax on Hours") xdimension(categ) legend(pos(6) row(1)) ytitle("Marginal effects") name(margeff4, replace) yline(0) xtitle(Quantiles)

// Quantile regression
encode province, gen(provid)
foreach v in credit_cat year provid {
	tab `v', gen(`v'_)
	drop `v'_1

}
global Z "credit_cat_2 credit_cat_3 cap_dummy provpop provpop15_64 year_2 year_3 year_4 year_5 year_6 year_7 year_8 year_9 year_10 year_11 year_12 year_13 year_14 year_15 year_16 year_17 year_18 year_19 provid_2 provid_3 provid_4 provid_5 provid_6 provid_7 provid_8 provid_9 provid_10 provid_11 provid_12 provid_13"
qreg lnpaid_jobs carbon_rate $Z if s==1, q(50)
grqreg carbon_rate, seed(1) 

global Z "credit_cat_2 credit_cat_3 cap_dummy provpop provpop15_64 year_6 year_7 year_8 year_9 year_10 year_11 year_12 year_13 year_14 year_15 year_16 year_17  provid_2 provid_3 provid_4 provid_5 provid_6 provid_7 provid_8 provid_9 provid_10 provid_11 provid_12 provid_13"
qreg lnemissions carbon_rate $Z if s==1, q(50)
grqreg carbon_rate, seed(1) title("Quantile tretment effecs")

// Time-varying CRC
global Z "i.credit_cat cap_dummy provpop provpop15_64"
foreach y in lnemissions {
	qui reghdfe `y' $Z i.year if carbon_rate==0 & s==1, absorb(indcodeA province) residuals   // individual FEs
	predict xb, xb
	predict FEtemp if carbon_rate==0, d  // province FEs for untreated observations
	egen FE=mean(FEtemp), by(indcodeA province) 
	gen y_0 = xb+FE		// counter-factual potential outcome
	gen te_`y'=`y'-y_0
	label var te_`y' "CRC treatment effect-`y'"
	drop xb FE* y_* _* 
}
foreach y in lnemissions {
	reg te_`y' carbon_rate if s==1, vce(cluster province)
}
drop te_*

