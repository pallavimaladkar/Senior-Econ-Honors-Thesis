cd "~/Dropbox/Honors thesis-Pallavi/Canada data"
global results "Results2/"

*************************************************************
*			Baseline regression with lagged covariates
*************************************************************

use carbon_tax_workfile_v2.dta, clear
xtset id year

gen carbon_dummy=(carbon_cat>1)
label var carbon_dummy "Carbon tax policy in place"

gen credit_dummy=(credit_cat>1)
label var credit_dummy "Credit system in place"

foreach v in carbon_dummy credit_dummy cap_dummy carbon_rate cap_rate {
	gen l`v'=l.`v'
	local lbl: variable label `v'
	label var l`v' "Lagged `lbl'"
}

// Log transformation and re-scaling
foreach v in emissionsZ paid_jobs earnings hours_worked gdp2012 provpop provpop15_64 {
	gen ln`v'=ln(1+`v')
	gen lln`v'=l.ln`v'
}
label var lnemissionsZ "Emissions"
label var lngdp2012 "GDP"
label var lnpaid_jobs "Employment"
label var lnearnings "Earnings"
label var lnhours_worked "Hours"

gen lnintemissn=lnemissionsZ-lngdp2012
label var lnintemissn "Emission Intensity"
gen l2intemissn=l2.intemissn
xtile categ=l2intemissn, nq(5)
gen l2intenergy=l2.intenergy
xtile categ2=l2intenergy, nq(5)
xtile categ3=innov_ghg1, nq(5)

gen carbon_rate100 = carbon_rate/100
label var carbon_rate100 "Carbon tax rate, $/100 tons CO2e"
gen cap_rate100 = cap_rate/100
label var cap_rate100 "Auction price, $/100 tons CO2e"
gen credit_rate100 = credit_rate/100
label var credit_rate100 "Excess charge, $/100 tons CO2e"



// Sample constraints
gen s=1 if paid_jobs>500 // remove small industries

// Vectors
global Z "lnprovpop lnprovpop15_64"
global FE "indcodeA province year"

grstyle init
grstyle set plain, horizontal grid

*************************************************************
*			Baseline model
*************************************************************

// contemporaneous effect
reg emissions
outreg2 using "$results/carbon_dummy.xls", replace
outreg2 using "$results/carbon_rate.xls", replace
foreach v in emissionsZ gdp2012 paid_jobs hours_worked earnings {
	reghdfe ln`v' carbon_dummy cap_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	outreg2 using "$results/carbon_dummy.doc", append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($FE) label ctitle(`v') dec(3)
}

carbon_rate100 carbon_dummy cap_rate100 cap_dummy credit_dummy

foreach v in emissionsZ gdp2012 paid_jobs hours_worked earnings {
	reghdfe ln`v' carbon_rate100 cap_rate100 credit_rate100 $Z if s==1, absorb($FE) vce(robust)
	outreg2 using "$results/carbon_rate.doc", append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($FE) label ctitle(`v') dec(3)
}

// lagged effect
reg emissions
outreg2 using "$results/lcarbon_dummy.xls", replace
outreg2 using "$results/lcarbon_rate.xls", replace
foreach v in emissionsZ gdp2012 paid_jobs hours_worked earnings intemissn {
	reghdfe ln`v' lcarbon_dummy lcap_dummy lcredit_dummy $Z if s==1, absorb($FE) vce(robust)
	outreg2 using "$results/lcarbon_dummy.xls", append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($FE) label ctitle(`v') dec(3)
}

foreach v in emissionsZ gdp2012 paid_jobs hours_worked earnings intemissn {
	reghdfe ln`v' lcarbon_rate lcarbon_dummy lcap_rate lcap_dummy lcredit_dummy $Z if s==1, absorb($FE) vce(robust)
	outreg2 using "$results/lcarbon_rate.xls", append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($FE) label ctitle(`v') dec(3)
}

// tax revenue share

*************************************************************
*			By sector regressions
*************************************************************

// Effect of carbon tax policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' carbon_dummy##i.sector cap_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins i.sector, noestimcheck dydx(carbon_dummy) 
	marginsplot, horizontal plotopts(c(none) color(midblue)) ciopts(color(midblue)) title(`lbl') plotregion(style(none)) xline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_carbon, replace) ytitle("") xtitle("")
}
graph combine lnemissionsZ_carbon lngdp2012_carbon lnpaid_jobs_carbon lnearnings_carbon, iscale(.6) name(carbon_combined, replace)

// table
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnhours_worked lnearnings {
	qui reghdfe `v' carbon_dummy##i.sector cap_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	outreg2 using "$results/carbon_sector.doc", append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($FE) label ctitle(`v') dec(3)
}



// Effect of cap and trade policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' cap_dummy##i.sector carbon_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins i.sector, noestimcheck dydx(cap_dummy) 
	marginsplot, horizontal plotopts(c(none) color(midgreen)) ciopts(color(midgreen)) title(`lbl') plotregion(style(none)) xline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_cap, replace) ytitle("") xtitle("")
}
graph combine lnemissionsZ_cap lngdp2012_cap lnpaid_jobs_cap lnearnings_cap, iscale(.6) name(cap_combined, replace)

// table
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnhours_worked lnearnings {
	qui reghdfe `v' cap_dummy##i.sector carbon_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	outreg2 using "$results/cap_sector.doc", append addtext(Industry FE, Yes, Province FE, Yes, Year FE, Yes) drop($FE) label ctitle(`v') dec(3)
}

* try lagged taxes
* try rates instead of dummies
* try emission revenue

// Effect of carbon tax rate
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' c.carbon_rate##i.sector cap_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins i.sector, noestimcheck dydx(carbon_rate) 
	marginsplot, horizontal plotopts(c(none) color(midblue)) ciopts(color(midblue)) title(`lbl') plotregion(style(none)) xline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_carbon, replace) ytitle("") xtitle("")
}
graph combine lnemissionsZ_carbon lngdp2012_carbon lnpaid_jobs_carbon lnearnings_carbon, iscale(.6) name(carbon_combined, replace)

// Effect of cap and trade policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' c.cap_rate##i.sector carbon_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins i.sector, noestimcheck dydx(cap_rate) 
	marginsplot, horizontal plotopts(c(none) color(midgreen)) ciopts(color(midgreen)) title(`lbl') plotregion(style(none)) xline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_cap, replace) ytitle("") xtitle("")
}
graph combine lnemissionsZ_cap lngdp2012_cap lnpaid_jobs_cap lnearnings_cap, iscale(.6) name(cap_combined, replace)




foreach v in lnhours_worked lnintemissn {
	local lbl: variable label `v'
	qui reghdfe `v' carbon_dummy##i.sector cap_dummy $Z if s==1, absorb($FE) vce(robust)
	margins i.sector, noestimcheck dydx(carbon_dummy) 
	marginsplot, horizontal plotopts(c(none)) title(`lbl') xline(0) level(90) name(`v'_carbon, replace) ytitle("") xtitle("")
}

*************************************************************
*			By 2-year lagged pre-treatment conditions
*************************************************************

// Effect of carbon tax policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' carbon_dummy##c.l2intemissn cap_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins, noestimcheck dydx(carbon_dummy) over(categ)
	marginsplot, plotopts(color(midblue)) ciopts(color(midblue)) title(`lbl') plotregion(style(none)) yline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_carbonI, replace) ytitle("") xtitle("Quantiles of Emission Intensity")
}
graph combine lnemissionsZ_carbonI lngdp2012_carbonI lnpaid_jobs_carbonI lnearnings_carbonI, iscale(.7) name(carbonI_combined, replace)

// Effect of cap and trade policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' carbon_dummy cap_dummy##c.l2intemissn credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins, noestimcheck dydx(cap_dummy) over(categ)
	marginsplot, plotopts(color(midgreen)) ciopts(color(midgreen)) title(`lbl') plotregion(style(none)) yline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_capI, replace) ytitle("") xtitle("Quantiles of Emission Intensity")
}
graph combine lnemissionsZ_capI lngdp2012_capI lnpaid_jobs_capI lnearnings_capI, iscale(.7) name(capI_combined, replace)


* appendix: energy intensity
// Effect of carbon tax policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' carbon_dummy##c.l2intenergy cap_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins, noestimcheck dydx(carbon_dummy) over(categ2)
	marginsplot, plotopts(color(midblue)) ciopts(color(midblue)) title(`lbl') plotregion(style(none)) yline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_carbonI, replace) ytitle("") xtitle("Quantiles of Energy Intensity")
}
graph combine lnemissionsZ_carbonI lngdp2012_carbonI lnpaid_jobs_carbonI lnearnings_carbonI, iscale(.7) name(carbonEN_combined, replace)

// Effect of cap and trade policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' carbon_dummy cap_dummy##c.l2intenergy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins, noestimcheck dydx(cap_dummy) over(categ2)
	marginsplot, plotopts(color(midgreen)) ciopts(color(midgreen)) title(`lbl') plotregion(style(none)) yline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_capI, replace) ytitle("") xtitle("Quantiles of Energy Intensity")
}
graph combine lnemissionsZ_capI lngdp2012_capI lnpaid_jobs_capI lnearnings_capI, iscale(.7) name(capEN_combined, replace)



* main text: innovation

// Effect of carbon tax policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' carbon_dummy##c.innov_ghg1 cap_dummy credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins, noestimcheck dydx(carbon_dummy) over(categ3)
	marginsplot, plotopts(color(midblue)) ciopts(color(midblue)) title(`lbl') plotregion(style(none)) yline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_carbonI, replace) ytitle("") xtitle("Quantiles of Percent Innovation Levels")
}
graph combine lnemissionsZ_carbonI lngdp2012_carbonI lnpaid_jobs_carbonI lnearnings_carbonI, iscale(.7) name(carbonIN_combined, replace)

// Effect of cap and trade policy
foreach v in lnemissionsZ lngdp2012 lnpaid_jobs lnearnings {
	local lbl: variable label `v'
	qui reghdfe `v' carbon_dummy cap_dummy##c.innov_ghg1 credit_dummy $Z if s==1, absorb($FE) vce(robust)
	margins, noestimcheck dydx(cap_dummy) over(categ3)
	marginsplot, plotopts(color(midgreen)) ciopts(color(midgreen)) title(`lbl') plotregion(style(none)) yline(0, lcolor(black) lpattern(vshortdash)) level(90) name(`v'_capI, replace) ytitle("") xtitle("Quantiles of Percent Innovation Levels")
}
graph combine lnemissionsZ_capI lngdp2012_capI lnpaid_jobs_capI lnearnings_capI, iscale(.7) name(capIN_combined, replace)


* try emission revenue

*************************************************************
*			Mediating model
*************************************************************

egen indnum=group(indcodeA)

* carbon dummy
foreach v in lngdp2012 lnpaid_jobs lnhours_worked lnearnings {
	qui reg `v' carbon_dummy##c.l2intemissn cap_dummy credit_dummy $Z i.indnum i.provid i.year if lnemissions<. & s==1
	est store `v'
	qui reg lnemissionsZ `v' carbon_dummy##c.l2intemissn cap_dummy credit_dummy $Z i.indnum i.provid i.year if s==1
	est store emis
	*outreg2 using mediating.xls, replace addtext(Province FE, Yes, Year FE, Yes) drop($Z i.provid i.year) label bdec(3) ctitle(`v')

suest `v' emis, vce(robust)

foreach i in 1 {
nlcom 	(direct: [emis_mean]1.carbon_dummy+`i'*[emis_mean]1.carbon_dummy#c.l2intemissn) ///
		(indirect: [emis_mean]`v'*([`v'_mean]1.carbon_dummy+`i'*[`v'_mean]1.carbon_dummy#c.l2intemissn)) ///
		(total: [emis_mean]1.carbon_dummy+`i'*[emis_mean]1.carbon_dummy#c.l2intemissn + [emis_mean]`v'*([`v'_mean]1.carbon_dummy+`i'*[`v'_mean]1.carbon_dummy#c.l2intemissn))
	}
}


* cap dummy
foreach v in lngdp2012 lnpaid_jobs lnhours_worked lnearnings {
	qui reg `v' cap_dummy##c.l2intemissn carbon_dummy credit_dummy $Z i.indnum i.provid i.year if lnemissions<. & s==1
	est store `v'
	qui reg lnemissionsZ `v' cap_dummy##c.l2intemissn carbon_dummy credit_dummy $Z i.indnum i.provid i.year if s==1
	est store emis
	*outreg2 using mediating.xls, replace addtext(Province FE, Yes, Year FE, Yes) drop($Z i.provid i.year) label bdec(3) ctitle(`v')

suest `v' emis, vce(robust)

foreach i in 1 {
nlcom 	(direct: [emis_mean]1.cap_dummy+`i'*[emis_mean]1.cap_dummy#c.l2intemissn) ///
		(indirect: [emis_mean]`v'*([`v'_mean]1.cap_dummy+`i'*[`v'_mean]1.cap_dummy#c.l2intemissn)) ///
		(total: [emis_mean]1.cap_dummy+`i'*[emis_mean]1.cap_dummy#c.l2intemissn + [emis_mean]`v'*([`v'_mean]1.cap_dummy+`i'*[`v'_mean]1.cap_dummy#c.l2intemissn))
	}
}



* appendix: energy intensity
* main text: innovation
* try emission revenue


