cd "~/Dropbox/Honors thesis-Pallavi/Canada data"

*************************************************************
*			Policy Visualization via Panel View
*************************************************************

use carbon_tax_workfile_v2.dta, clear
keep if indcodeA=="11300"

// Carbon Tax
gen baseline=0
replace baseline=20 if year==2019
replace baseline=30 if year==2020
replace baseline=40 if year==2021
replace baseline=50 if year==2022
label var baseline "Federal carbon tax"
gen carbon_dif=carbon_rate-baseline

sort year
twoway (scatter baseline year, c(l) lwidth(medthick)), sub("Carbon tax rate") name(carbontax, replace) 

gen policy1=. if carbon_cat==1 & cap_dummy==0
replace policy1=2 if carbon_cat==1 & cap_dummy==1
replace policy1=3 if (carbon_cat==2 | carbon_cat==3) & cap_dummy==0 & carbon_dif==0
replace policy1=4 if (carbon_cat==2 | carbon_cat==3) & cap_dummy==0 & carbon_dif~=0
label define policy1 1 "None" 2 "Cap-and-Trade" 3 "Baseline Tax" 4 "Different Tax" 
label values policy1 policy1

panelview policy1, i(province) t(year) type(treat) xtitle("Year",size(vsmall)) ytitle("State",size(vsmall)) title("Regulation of GHG Emissions",size(small)) bytiming legend(label(1 "Cap-and-trade") label(2 "Baseline Tax") label(3 "Different Tax") row(1) pos(6)) name(policy1, replace) mycolor(Blues) 

// Federal vs provincial tax
gen policy2=. if carbon_cat==1 & cap_dummy==0
replace policy2=2 if carbon_cat==1 & cap_dummy==1
replace policy2=3 if carbon_cat==2 & cap_dummy==0
replace policy2=4 if carbon_cat==3 & cap_dummy==0
label define policy2 1 "None" 2 "Cap-and-Trade" 3 "Provincial Tax" 4 "Federal Tax" 
label values policy2 policy2

panelview policy2, i(province) t(year) type(treat) xtitle("Year",size(vsmall)) ytitle("State",size(vsmall)) title("Regulation of GHG Emissions",size(small)) bytiming legend(label(1 "Cap-and-trade") label(2 "Provincial Tax") label(3 "Federal Tax") row(1) pos(6)) name(policy2, replace) mycolor(Blues) 

// Credit System
gen policy3=. if carbon_cat==1 & credit_cat==1 & cap_dummy==0
replace policy3=2 if carbon_cat==1 & credit_cat==1 & cap_dummy==1
replace policy3=3 if carbon_cat>1 & credit_cat==1 & cap_dummy==0
replace policy3=4 if carbon_cat==1 & credit_cat>1 & cap_dummy==0
replace policy3=5 if carbon_cat>1 & credit_cat>1 & cap_dummy==0
label define policy3 1 "None" 2 "Cap-and-Trade" 3 "Carbon Tax" 4 "Credit System" 5 "Mixed"
label values policy3 policy3

panelview policy3, i(province) t(year) type(treat) xtitle("Year",size(vsmall)) ytitle("State",size(vsmall)) title("Regulation of GHG Emissions",size(small)) bytiming legend(label(1 "cap-and-trade") label(2 "carbon tax") label(3 "credit system") label(4 "mixed") row(1) pos(6)) name(policy3, replace) mycolor(pastel) 

// Trends by province
sort year
twoway (scatter carbon_rate year if province=="British Columbia", c(l)) (scatter carbon_rate year if province=="Alberta", c(l)) (scatter baseline year, c(l) lwidth(medthick) lcolor(black) mcolor(black)), legend(label(1 "BC") label(2 "Alberta") label(4 "Baseline")) sub("Carbon tax rate") name(carbontax, replace) 




