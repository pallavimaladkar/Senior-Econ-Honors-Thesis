cd "~/Dropbox/Honors thesis-Pallavi/Canada data"

******************************************************************
*					Summary Statistics
******************************************************************

use carbon_tax_workfile_v2.dta, clear


// creating larger sectors
// gen sectornum = substr(indcode, 1, 1)
// destring sectornum, replace
// gen sector = "Farming, Food, and Forestry" if sectornum == 1
// replace sector = "Mining and Construction" if sectornum == 2
// replace sector = "Manufacturing" if sectornum == 3
// replace sector = "Trade and Transportation" if sectornum == 4
// replace sector = "Services" if sectornum >= 5 & sectornum <= 8
// replace sector = "Government" if sectornum == 9
//
// gen emissrev = crbtax_ind+permit_ind
// gen emissrevprop = emissrev/prdtax_ind


// sum emissions gdp2012 paid_jobs hours_worked wage_rate earnings intemissn intenergy innov_ghg1 innov_ghg2 provpop provpop15_64 crbtax_all permit_all prdtax_all
// asdoc sum /*
// */ emissions gdp2012 gdpcurrent perchange paid_jobs hours_worked wage_rate earnings /*
// */ intemissn intenergy innov_ghg1 innov_ghg2 /*
// */ provpop provpop15_64, label


// tab year if emissions != .			// 2009-2021
// tab year if gdp2012 != .			// 2004-2022 (all GDP measures)
// tab year if paid_jobs != .			// 2004-2022 (all measures of labor characteristics)
// tab year if intemissn != .			// 2004-2019 but we don't care bc we're choosing one year
// tab year if intenergy != .			// ^
// tab year if innov_any1 != .			// ^
// tab year if provpop != .			// 2004-2022 (all controls)




******************************************************************
*							Graphs
******************************************************************


// GENERIC SUM OF VARIABLE BY PROVINCE

use carbon_tax_workfile_v2.dta, clear

foreach v in paid_jobs {
	
	
	bysort year: egen `v'_BC = sum(`v') if province == "British Columbia"
	label var `v'_BC "British Columbia"
	bysort year: egen `v'_Alberta = sum(`v') if province == "Alberta"
	label var `v'_Alberta "Alberta"
	bysort year: egen `v'_NL = sum(`v') if province == "Newfoundland and Labrador"
	label var `v'_NL "Newfoundland and Labrador"
	bysort year: egen `v'_NWT = sum(`v') if province == "Northwest Territories"
	label var `v'_NWT "Northwest Territories"
	bysort year: egen `v'_PEI = sum(`v') if province == "Prince Edward Island"
	label var `v'_PEI "Prince Edward Island"
	bysort year: egen `v'_NB = sum(`v') if province == "New Brunswick"
	label var `v'_NB "New Brunswick"
	bysort year: egen `v'_Ontario = sum(`v') if province == "Ontario"
	label var `v'_Ontario "Ontario"
	bysort year: egen `v'_Quebec = sum(`v') if province == "Quebec"
	label var `v'_Quebec "Quebec"
	bysort year: egen `v'_NS = sum(`v') if province == "Nova Scotia"
	label var `v'_NS "Nova Scotia"
	bysort year: egen `v'_Manitoba = sum(`v') if province == "Manitoba"
	label var `v'_Manitoba "Manitoba"
	bysort year: egen `v'_SK = sum(`v') if province == "Saskatchewan"
	label var `v'_SK "Saskatchewan"
	bysort year: egen `v'_Yukon = sum(`v') if province == "Yukon"
	label var `v'_Yukon "Yukon"
	bysort year: egen `v'_Nunavut = sum(`v') if province == "Nunavut"
	label var `v'_Nunavut "Nunavut"

	
	line `v'_BC `v'_Alberta `v'_NL `v'_NWT `v'_PEI `v'_NB `v'_Ontario `v'_Quebec `v'_NS `v'_Manitoba `v'_SK `v'_Yukon `v'_Nunavut year if year >= 2004 & year <= 2022, ytitle("Paid Worker Jobs") xtitle("Year") xlabel(2004(4)2022) ylabel(, angle(0)) title("Employment by Province") legend(size(vsmall) position(3) cols(1))
	
	
}


// GHG Emissions (kilotons)
// GHG Emissions by Province
//
// GDP in 2012 Dollars (millions)
// GDP by Province
//
// Paid Worker Jobs
// Employment by Province
//
// Emission Revenue, $
// Emission Revenue by Province



// GENERIC SUM OF VARIABLE BY SECTOR

foreach v in paid_jobs {


	bysort year: egen `v'_1 = sum(`v') if sector == 1
	label var `v'_1 "Farming and Forestry"
	bysort year: egen `v'_2 = sum(`v') if sector == 2
	label var `v'_2 "Mining, Oil, Gas, Electricity"
	bysort year: egen `v'_3 = sum(`v') if sector == 3
	label var `v'_3 "Construction"
	bysort year: egen `v'_4 = sum(`v') if sector == 4
	label var `v'_4 "Manufacturing"
	bysort year: egen `v'_5 = sum(`v') if sector == 5
	label var `v'_5 "Trade"
	bysort year: egen `v'_6 = sum(`v') if sector == 6
	label var `v'_6 "Transportation"
	bysort year: egen `v'_7 = sum(`v') if sector == 7
	label var `v'_7 "Services"
	bysort year: egen `v'_8 = sum(`v') if sector == 8
	label var `v'_8 "Government"


	line `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8 year if year >= 2004 & year <= 2022, ytitle("Paid Worker Jobs") xtitle("Year") xlabel(2004(4)2022) ylabel(, angle(0)) title("Employment by Sector") legend(size(vsmall) position(3) cols(1))
	
	drop `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8


}

// GHG Emissions (kilotons)
// GHG Emissions by Sector
//
// GDP in 2012 Dollars (millions)
// GDP by Sector
//
// Paid Worker Jobs
// Employment by Sector
// 2004-2022
//
// Emission Revenue, $
// Emission Revenue by Sector




/* ********************** AVERAGE OF VARIABLE BY SECTOR ***********************

// GENERIC *** AVERAGE *** OF VARIABLE BY SECTOR

foreach v in wage_rate {


	bysort year: egen `v'_1 = mean(`v') if sectornum == 1
	label var `v'_1 "Farming, Food, and Forestry"
	bysort year: egen `v'_2 = mean(`v') if sector == "Mining and Construction"
	label var `v'_2 "Mining and Construction"
	bysort year: egen `v'_3 = mean(`v') if sector == "Manufacturing"
	label var `v'_3 "Manufacturing"
	bysort year: egen `v'_4 = mean(`v') if sector == "Trade and Transportation"
	label var `v'_4 "Trade and Transportation"
	bysort year: egen `v'_5 = mean(`v') if sector == "Services"
	label var `v'_5 "Services"
	bysort year: egen `v'_6 = mean(`v') if sector == "Government"
	label var `v'_6 "Government"


	line `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 year if year > 2008 & year <= 2020, ytitle("Actual Wage Rate (Dollars)") xtitle("Year") xlabel(2008(2)2021) ylabel(, angle(0)) title("Wage Rate by Sector") legend(size(vsmall) position(3) cols(1))


}


// GENERIC *** AVERAGE *** OF VARIABLE BY SECTOR

foreach v in emissrevprop {


	bysort year: egen `v'_BC = mean(`v') if province == "British Columbia"
	label var `v'_BC "British Columbia"
	bysort year: egen `v'_Alberta = mean(`v') if province == "Alberta"
	label var `v'_Alberta "Alberta"
	bysort year: egen `v'_NL = mean(`v') if province == "Newfoundland and Labrador"
	label var `v'_NL "Newfoundland and Labrador"
	bysort year: egen `v'_NWT = mean(`v') if province == "Northwest Territories"
	label var `v'_NWT "Northwest Territories"
	bysort year: egen `v'_PEI = mean(`v') if province == "Prince Edward Island"
	label var `v'_PEI "Prince Edward Island"
	bysort year: egen `v'_NB = mean(`v') if province == "New Brunswick"
	label var `v'_NB "New Brunswick"
	bysort year: egen `v'_Ontario = mean(`v') if province == "Ontario"
	label var `v'_Ontario "Ontario"
	bysort year: egen `v'_Quebec = mean(`v') if province == "Quebec"
	label var `v'_Quebec "Quebec"
	bysort year: egen `v'_NS = mean(`v') if province == "Nova Scotia"
	label var `v'_NS "Nova Scotia"
	bysort year: egen `v'_Manitoba = mean(`v') if province == "Manitoba"
	label var `v'_Manitoba "Manitoba"
	bysort year: egen `v'_SK = mean(`v') if province == "Saskatchewan"
	label var `v'_SK "Saskatchewan"
	bysort year: egen `v'_Yukon = mean(`v') if province == "Yukon"
	label var `v'_Yukon "Yukon"
	bysort year: egen `v'_Nunavut = mean(`v') if province == "Nunavut"
	label var `v'_Nunavut "Nunavut"

	
	line `v'_BC `v'_Alberta `v'_NL `v'_NWT `v'_PEI `v'_NB `v'_Ontario `v'_Quebec `v'_NS `v'_Manitoba `v'_SK `v'_Yukon `v'_Nunavut year if year > 2008 & year <= 2020, ytitle("Proportion of Carbon Policy Revenue to Total Tax Revenue") xtitle("Year") xlabel(2008(2)2021) ylabel(, angle(0)) title("Emission Revenue by Province") legend(size(vsmall) position(3) cols(1))
	

}

*/






******************************************************************
*			Pre-treatment Indsutry characteristics Graphs
******************************************************************

mean(intemissn)
mean(intenergy)
mean(innov_ghg1)

hist intemissn if paid_jobs > 500, fcolor(orange) lcolor(black) lwidth(.1) name(histintemissn, replace)
hist intenergy if paid_jobs > 500, fcolor(orange) lcolor(black) lwidth(.1) name(histintenergy, replace)
graph combine histintemissn histintenergy, iscale(1.5) ysize(2) name(histlaggedindchar, replace)

//  if paid_jobs > 500 // you can add condition
hist intemissn, fcolor(orange) lcolor(black) lwidth(.1) name(histintemissn, replace)
hist intenergy, fcolor(orange) lcolor(black) lwidth(.1) name(histintenergy, replace)
hist innov_ghg1, fcolor(orange) lcolor(black) lwidth(.1) name(histinnov_ghg1, replace)
graph combine histintemissn histintenergy histinnov_ghg1, row(1) iscale(1.4) ysize(1.7) name(histlaggedindchar, replace)


foreach v in intenergy {
	bysort year: egen avg_`v' = mean(`v')
	line avg_`v' year if year >= 2004 & year <= 2019, ytitle("Average GHG Emissions Intensity (tons of CO2e/$1000 prod)") xtitle("Year") xlabel(2004(2)2019) ylabel(, angle(0)) title("Average GHG Emissions Intensity")
	
	bysort year: egen `v'_1 = sum(`v') if sector == 1
	label var `v'_1 "Farming and Forestry"
	bysort year: egen `v'_2 = sum(`v') if sector == 2
	label var `v'_2 "Mining, Oil, Gas, Electricity"
	bysort year: egen `v'_3 = sum(`v') if sector == 3
	label var `v'_3 "Construction"
	bysort year: egen `v'_4 = sum(`v') if sector == 4
	label var `v'_4 "Manufacturing"
	bysort year: egen `v'_5 = sum(`v') if sector == 5
	label var `v'_5 "Trade"
	bysort year: egen `v'_6 = sum(`v') if sector == 6
	label var `v'_6 "Transportation"
	bysort year: egen `v'_7 = sum(`v') if sector == 7
	label var `v'_7 "Services"
	bysort year: egen `v'_8 = sum(`v') if sector == 8
	label var `v'_8 "Government"


	line `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8 year if year >= 2004 & year <= 2019, ytitle("Energy Intensity (GJ/$1000 prod)") xtitle("Year") xlabel(2004(4)2020) ylabel(, angle(0)) title("Energy Intensity by Sector") legend(size(vsmall) position(3) cols(1))
	

	drop `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8 avg_`v'
}








cd "~/Dropbox/Honors thesis-Pallavi/Canada data"
use carbon_tax_workfile_v2.dta, clear

gen _t=intemissn if year==2004
egen intemissnme=mean(_t), by(indcodeA)

gen _s = intenergy if year == 2004
egen intenergyme = mean(_s), by(indcodeA)

foreach v in intemissn {
	
	bysort year: gen `v'_1 = sum(`v')/sum(`v'me) if sector == 1
	label var `v'_1 "Farming and Forestry"
	bysort year: gen `v'_2 = sum(`v')/sum(`v'me) if sector == 2
	label var `v'_2 "Mining, Oil, Gas, Electricity"
	bysort year: gen `v'_3 = sum(`v')/sum(`v'me) if sector == 3
	label var `v'_3 "Construction"
	bysort year: gen `v'_4 = sum(`v')/sum(`v'me) if sector == 4
	label var `v'_4 "Manufacturing"
	bysort year: gen `v'_5 = sum(`v')/sum(`v'me) if sector == 5
	label var `v'_5 "Trade"
	bysort year: gen `v'_6 = sum(`v')/sum(`v'me) if sector == 6
	label var `v'_6 "Transportation"
	bysort year: gen `v'_7 = sum(`v')/sum(`v'me) if sector == 7
	label var `v'_7 "Services"
	bysort year: gen `v'_8 = sum(`v')/sum(`v'me) if sector == 8
	label var `v'_8 "Government"
	
	collapse (mean) `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8, by(sector year)
	label var `v'_1 "Farming and Forestry"
    label var `v'_2 "Mining, Oil, Gas, Electricity"
    label var `v'_3 "Construction"
    label var `v'_4 "Manufacturing"
    label var `v'_5 "Trade"
    label var `v'_6 "Transportation"
    label var `v'_7 "Services"
    label var `v'_8 "Government"

	line `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8 year if year >= 2004 & year <= 2019, ytitle("Normalized GHG Emissions Intensity") xtitle("Year") xlabel(2004(4)2020) ylabel(, angle(0)) title("GHG Emissions Intensity by Sector") legend(size(vsmall) position(3) cols(1))
	

// 	drop `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8
}


// EMISSION INTENSITY GRAPH
// line `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8 year if year >= 2004 & year <= 2019, ytitle("GHG Emissions Intensity (tons of CO2e/$1000 prod)") xtitle("Year") xlabel(2004(4)2020) ylabel(, angle(0)) title("GHG Emissions Intensity by Sector") legend(size(vsmall) position(3) cols(1))
// 
// ENERGY INTENSITY
// line `v'_1 `v'_2 `v'_3 `v'_4 `v'_5 `v'_6 `v'_7 `v'_8 year if year >= 2004 & year <= 2019, ytitle("Energy Intensity (GJ/$1000 prod)") xtitle("Year") xlabel(2004(4)2020) ylabel(, angle(0)) title("Energy Intensity by Sector") legend(size(vsmall) position(3) cols(1))



/*
// EMISSION INTENSITY

bysort year: egen avg_intemissn = mean(intemissn)
line avg_intemissn year if year >= 2004 & year <= 2019, ytitle("Average GHG Emissions Intensity (tons of CO2e/$1000 prod)") xtitle("Year") xlabel(2004(2)2019) ylabel(, angle(0)) title("Average GHG Emissions Intensity")

// *ignore variable names, im just lazy and the code will work
bysort year: egen gdp_1 = sum(intemissn) if sectornum == 1
label var gdp_1 "Farming, Food, and Forestry"
bysort year: egen gdp_2 = sum(intemissn) if sector == "Mining and Construction"
label var gdp_2 "Mining and Construction"
bysort year: egen gdp_3 = sum(intemissn) if sector == "Manufacturing"
label var gdp_3 "Manufacturing"
bysort year: egen gdp_4 = sum(intemissn) if sector == "Trade and Transportation"
label var gdp_4 "Trade and Transportation"
bysort year: egen gdp_5 = sum(intemissn) if sector == "Services"
label var gdp_5 "Services"
bysort year: egen gdp_6 = sum(intemissn) if sector == "Government"
label var gdp_6 "Government"


line gdp_1 gdp_2 gdp_3 gdp_4 gdp_5 gdp_6 year if year >= 2004 & year <= 2019, ytitle("GHG Emissions Intensity (tons of CO2e/$1000 prod)") xtitle("Year") xlabel(2004(2)2020) ylabel(, angle(0)) title("GHG Emissions Intensity by Sector") legend(size(vsmall) position(3) cols(1))

drop gdp_1 gdp_2 gdp_3 gdp_4 gdp_5 gdp_6


// ENERGY INTENSITY

bysort year: egen avg_intenergy = mean(intenergy)
line avg_intenergy year if year >= 2004 & year <= 2019, ytitle("Average Energy Intensity (GJ/$1000 prod)") xtitle("Year") xlabel(2004(2)2019) ylabel(, angle(0)) title("Average Energy Intensity")

// *ignore variable names, im just lazy and the code will work
bysort year: egen gdp_1 = sum(intenergy) if sectornum == 1
label var gdp_1 "Farming, Food, and Forestry"
bysort year: egen gdp_2 = sum(intenergy) if sector == "Mining and Construction"
label var gdp_2 "Mining and Construction"
bysort year: egen gdp_3 = sum(intenergy) if sector == "Manufacturing"
label var gdp_3 "Manufacturing"
bysort year: egen gdp_4 = sum(intenergy) if sector == "Trade and Transportation"
label var gdp_4 "Trade and Transportation"
bysort year: egen gdp_5 = sum(intenergy) if sector == "Services"
label var gdp_5 "Services"
bysort year: egen gdp_6 = sum(intenergy) if sector == "Government"
label var gdp_6 "Government"


line gdp_1 gdp_2 gdp_3 gdp_4 gdp_5 gdp_6 year if year >= 2004 & year <= 2019, ytitle("Energy Intensity (GJ/$1000 prod)") xtitle("Year") xlabel(2004(4)2020) ylabel(, angle(0)) title("Energy Intensity by Sector") legend(size(vsmall) position(3) cols(1))

drop gdp_1 gdp_2 gdp_3 gdp_4 gdp_5 gdp_6
*/





// INNOVATIONS

// 2015-17
graph bar innov_ghg1, over(sector) ytitle("Percent") ylabel(0(10)50) title("Average % of Firms That Increase Innovations by Sector, 2015-17", size(medium))


// 2017-19
graph bar innov_ghg2, over(sector) ytitle("Percent") ylabel(0(10)50) title("Average % of Firms That Increase Innovations by Sector, 2017-19", size(medium))







******************************************************************
*						Controls Graphs
******************************************************************

bysort year: egen emissions_BC = sum(emissions) if province == "British Columbia"
label var emissions_BC "British Columbia"
bysort year: egen emissions_Alberta = sum(emissions) if province == "Alberta"
label var emissions_Alberta "Alberta"
bysort year: egen emissions_NL = sum(emissions) if province == "Newfoundland and Labrador"
label var emissions_NL "Newfoundland and Labrador"
bysort year: egen emissions_NWT = sum(emissions) if province == "Northwest Territories"
label var emissions_NWT "Northwest Territories"
bysort year: egen emissions_PEI = sum(emissions) if province == "Prince Edward Island"
label var emissions_PEI "Prince Edward Island"
bysort year: egen emissions_NB = sum(emissions) if province == "New Brunswick"
label var emissions_NB "New Brunswick"
bysort year: egen emissions_Ontario = sum(emissions) if province == "Ontario"
label var emissions_Ontario "Ontario"
bysort year: egen emissions_Quebec = sum(emissions) if province == "Quebec"
label var emissions_Quebec "Quebec"
bysort year: egen emissions_NS = sum(emissions) if province == "Nova Scotia"
label var emissions_NS "Nova Scotia"
bysort year: egen emissions_Manitoba = sum(emissions) if province == "Manitoba"
label var emissions_Manitoba "Manitoba"
bysort year: egen emissions_SK = sum(emissions) if province == "Saskatchewan"
label var emissions_SK "Saskatchewan"
bysort year: egen emissions_Yukon = sum(emissions) if province == "Yukon"
label var emissions_Yukon "Yukon"
bysort year: egen emissions_Nunavut = sum(emissions) if province == "Nunavut"
label var emissions_Nunavut "Nunavut"


drop pop workpop

bysort year: egen pop = sum(provpop)
label var pop "Total Population"
bysort year: egen workpop = sum(provpop15_64)
label var workpop "Working Age Population"

line pop workpop year if year >= 2004 & year <= 2022, ytitle("Population") xtitle("Year") xlabel(2004(2)2022) ylabel(, angle(0)) title("Population in Canada over Time") legend(size(vsmall) position(6))







// RANDOM HISTOGRAMS

hist emissions if emissions < 1000, frequency
hist gdp2012, frequency
hist perchange, frequency
hist paid_jobs, frequency
hist hours_worked, frequency
hist wage_rate, frequency
hist earnings, frequency
hist intemissn, frequency
hist intemissn if year == 2004, frequency
hist intenergy, frequency
hist innov_any1, frequency
hist provpop, frequency
hist provpop15_64, frequency

hist paid_jobs if paid_jobs < 60000, frequency
hist earnings if earnings < 1000000, frequency


******************************************************************
*					Summary Stats Klara Asked For
******************************************************************


// SUMMARY STATS BY LEVEL OF EMISSION INTENSITY

// determining high/medium/low emission levels
hist intemissn if year == 2004
// 0-1 is low emission intensity
// 1-2 is medium emission intensity
// >2 is high emission intensity

asdoc sum emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings intenergy innov_ghg1 innov_ghg2 if intemissn < 1, label

asdoc sum emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings intenergy innov_ghg1 innov_ghg2 if intemissn >= 1 & intemissn < 2, label

asdoc sum emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings intenergy innov_ghg1 innov_ghg2 if intemissn >= 2, label



asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy innov_ghg1 innov_ghg2 /*
*/ provpop provpop15_64 if intemissn < 1, label




// SUMMARY STATS BY INDUSTRY


asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy innov_ghg1 innov_ghg2 /*
*/ if sectornum == 1, label
asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy innov_ghg1 innov_ghg2 /*
*/ if sector == "Mining and Construction", label
asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy innov_ghg1 innov_ghg2 /*
*/ if sector == "Manufacturing", label
asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy innov_ghg1 innov_ghg2 /*
*/ if sector == "Trade and Transportation", label
asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy innov_ghg1 innov_ghg2 /*
*/ if sector == "Services", label
asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy innov_ghg1 innov_ghg2 /*
*/ if sector == "Government", label



// SUMMARY STATS BEFORE AND AFTER FEDERAL CARBON TAX

// basically before 2019 and then during and after 2019
sum emissions gdp2012 paid_jobs hours_worked wage_rate earnings intemissn intenergy innov_ghg1 innov_ghg2 provpop provpop15_64 if year < 2019

sum emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings intemissn intenergy innov_ghg1 innov_ghg2 provpop provpop15_64 if year >= 2019

asdoc sum /*
*/ emissions gdp2012 paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy /*
*/ provpop provpop15_64 if year < 2019, label

asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy /*
*/ provpop provpop15_64 if year >= 2019, label

asdoc tab indcodeA, label






