cd "~/Dropbox/Honors thesis-Pallavi/Canada data"

use carbon_tax_workfile_v2.dta, clear
egen fakeid=group(province indcodeA)
xtset fakeid year



********************************************************************************
*							setting up variables
********************************************************************************

// province id
// encode province, gen(provid)
// label var provid	"Province ID"

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
 
global Z "i.credit_cat cap_dummy provpop provpop15_64"
global FE "indcodeA province year"

gen l2emissrev=l2.emissrev
gen l2intemissn=l2.intemissn
xtile categ=l2intemissn, nq(5)

// sample constraints
// keep if paid_jobs>1000 // remove small industries



********************************************************************************
*							MM: CARBON TAXES
********************************************************************************

replace carbon_rate=carbon_rate/100
// gen emissrev=(crbtax_all+permit_all)/prdtax_all
// label var emissrev "Share of tax revenue from emission-related taxes"

// checking regular regressions
reghdfe lnpaid_jobs c.carbon_rate##c.l2intemissn $Z, absorb(province year) vce(robust)
reghdfe lnemissions lnpaid_jobs c.carbon_rate##c.l2intemissn $Z, absorb(province year) vce(robust)

reghdfe lngdp2012 c.carbon_rate##c.l2intemissn $Z, absorb(province year) vce(robust)
reghdfe lnemissions lngdp2012 c.carbon_rate##c.l2intemissn $Z, absorb(province year) vce(robust)

// mediating models
foreach v in paid_jobs {
	reg ln`v' c.carbon_rate##c.l2intemissn $Z i.provid i.year if lnemissions<.
	est store `v'_2
	reg lnemissions ln`v' c.carbon_rate##c.l2intemissn $Z i.provid i.year
	est store emis
	suest `v'_2 emis, vce(robust)
	
	outreg2 using mediating.doc, replace addtext(Province FE, Yes, Year FE, Yes) drop($Z i.provid i.year) label bdec(3) ctitle(`v')
}
/*

paid_jobs
carbon tax negatively impacts jobs with more emissions-intensive firms
jobs positively related to emissions
carbon tax negatively impacts emissions, but more emission intensity helps cancel it out
effect of carbon tax on emissions is indirect through employment????
basically when emission intensity == 1, negative effect of carbon rate cancels out, and so only effect on emissions comes from jobs
since jobs negatively impacted by carbon tax, and jobs and emissions are positively correlated, then carbon tax will negatively impact emissions through jobs


earnings
^ same relationships as above


gdp2012
carbon tax negatively impacts GDP, but not SS
GDP positively related to emissions
carbon tax negatively impacts emissions, but more emission intensity helps cancel it out
basically when emission intensity == 1, negative effect of carbon rate cancels out, and so only effect on emissions comes from GDP
since GDP negatively impacted by carbon tax (thought not SS), and GDP and emissions are positively correlated, then carbon tax will negatively impact emissions through GDP

*/

reg lnpaid_jobs c.carbon_rate##c.l2intemissn $Z i.provid i.year if lnemissions<.
est store jobs
reg lnemissions lnpaid_jobs c.carbon_rate##c.l2intemissn $Z i.provid i.year
est store emissions
suest jobs emissions, vce(robust)

qui reg lngdp2012 c.carbon_rate##c.l2intemissn $Z i.provid i.year if lnemissions<.
est store gdp
qui reg lnemissions lngdp2012 c.carbon_rate##c.l2intemissn $Z i.provid i.year
est store emissions
suest gdp emissions, vce(robust)

reg lnpaid_jobs c.carbon_rate##c.l2intemissn $Z i.provid i.year if lnemissions<.
est store jobs
reg lnemissions lnpaid_jobs c.carbon_rate##c.l2intemissn $Z i.provid i.year
est store emissions
suest jobs emissions, vce(robust)




********************************************************************************
*							MM: CAT SYSTEMS
********************************************************************************

global Z "carbon_dummy i.credit_cat provpop provpop15_64"

// gen cap_rate100=cap_rate/100

foreach v in hours_worked {
	reg ln`v' c.cap_rate##c.l2intemissn $Z i.provid i.year if lnemissions<.
	est store `v'_2
	reg lnemissions ln`v' c.cap_rate##c.l2intemissn $Z i.provid i.year
	est store emis
	suest `v'_2 emis, vce(robust)
	
	outreg2 using mediating2hrs.doc, replace addtext(Province FE, Yes, Year FE, Yes) drop($Z i.provid i.year) label bdec(3) ctitle(`v')
}


