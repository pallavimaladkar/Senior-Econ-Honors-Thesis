cd "~/Dropbox/Honors thesis-Pallavi/Canada data"

******************************************************************
*					Summary Statistics
******************************************************************

use carbon_tax_workfile.dta, clear

sum emissions gdp2012 gdpcurrent perchange paid_jobs hours_worked wage_rate earnings intemissn intenergy innov_ghg1 innov_ghg2 provpop provpop15_64
asdoc sum /*
*/ emissions gdp2012 gdpcurrent perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy innov_ghg1 innov_ghg2 /*
*/ provpop provpop15_64, label


tab year if emissions != .			// 2009-2021
tab year if gdp2012 != .			// 2004-2022 (all GDP measures)
tab year if paid_jobs != .			// 2004-2022 (all measures of labor characteristics)
tab year if intemissn != .			// 2004-2019 but we don't care bc we're choosing one year
tab year if intenergy != .			// ^
tab year if innov_any1 != .			// ^
tab year if provpop != .			// 2004-2022 (all controls)



// creating larger sectors
gen sectornum = substr(indcode_orig, 1, 1)
destring sectornum, replace
gen sector = "Farming, Food, and Forestry" if sectornum == 1
replace sector = "Mining and Construction" if sectornum == 2
replace sector = "Manufacturing" if sectornum == 3
replace sector = "Trade and Transportation" if sectornum == 4
replace sector = "Services" if sectornum >= 5 & sectornum <= 8
replace sector = "Government" if sectornum == 9


******************************************************************
*							Graphs
******************************************************************



// EMISSIONS BY PROVINCE
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


line emissions_BC emissions_Alberta emissions_NL emissions_NWT emissions_PEI emissions_NB emissions_Ontario emissions_Quebec emissions_NS emissions_Manitoba emissions_SK emissions_Yukon emissions_Nunavut year if year > 2008 & year <= 2020, ytitle("GHG Emissions (kilotons)") xtitle("Year") xlabel(2008(2)2021) ylabel(, angle(0)) title("GHG Emissions by Province, All Industries") legend(size(vsmall) position(3) cols(1))


// EMISSIONS BY SECTOR
bysort year: egen emissions_1 = sum(emissions) if sectornum == 1
label var emissions_1 "Farming, Food, and Forestry"
bysort year: egen emissions_2 = sum(emissions) if sector == "Mining and Construction"
label var emissions_2 "Mining and Construction"
bysort year: egen emissions_3 = sum(emissions) if sector == "Manufacturing"
label var emissions_3 "Manufacturing"
bysort year: egen emissions_4 = sum(emissions) if sector == "Trade and Transportation"
label var emissions_4 "Trade and Transportation"
bysort year: egen emissions_5 = sum(emissions) if sector == "Services"
label var emissions_5 "Services"
bysort year: egen emissions_6 = sum(emissions) if sector == "Government"
label var emissions_6 "Government"


line emissions_1 emissions_2 emissions_3 emissions_4 emissions_5 emissions_6 year if year > 2008 & year <= 2020, ytitle("GHG Emissions (kilotons)") xtitle("Year") xlabel(2008(2)2021) ylabel(, angle(0)) title("GHG Emissions by Sector, All Provinces") legend(size(vsmall) position(3) cols(1))


// EMPLOYMENT BY PROVINCE
bysort year: egen emp_BC = sum(paid_jobs) if province == "British Columbia"
label var emp_BC "British Columbia"
bysort year: egen emp_Alberta = sum(paid_jobs) if province == "Alberta"
label var emp_Alberta "Alberta"
bysort year: egen emp_NL = sum(paid_jobs) if province == "Newfoundland and Labrador"
label var emp_NL "Newfoundland and Labrador"
bysort year: egen emp_NWT = sum(paid_jobs) if province == "Northwest Territories"
label var emp_NWT "Northwest Territories"
bysort year: egen emp_PEI = sum(paid_jobs) if province == "Prince Edward Island"
label var emp_PEI "Prince Edward Island"
bysort year: egen emp_NB = sum(paid_jobs) if province == "New Brunswick"
label var emp_NB "New Brunswick"
bysort year: egen emp_Ontario = sum(paid_jobs) if province == "Ontario"
label var emp_Ontario "Ontario"
bysort year: egen emp_Quebec = sum(paid_jobs) if province == "Quebec"
label var emp_Quebec "Quebec"
bysort year: egen emp_NS = sum(paid_jobs) if province == "Nova Scotia"
label var emp_NS "Nova Scotia"
bysort year: egen emp_Manitoba = sum(paid_jobs) if province == "Manitoba"
label var emp_Manitoba "Manitoba"
bysort year: egen emp_SK = sum(paid_jobs) if province == "Saskatchewan"
label var emp_SK "Saskatchewan"
bysort year: egen emp_Yukon = sum(paid_jobs) if province == "Yukon"
label var emp_Yukon "Yukon"
bysort year: egen emp_Nunavut = sum(paid_jobs) if province == "Nunavut"
label var emp_Nunavut "Nunavut"


line emp_BC emp_Alberta emp_NL emp_NWT emp_PEI emp_NB emp_Ontario emp_Quebec emp_NS emp_Manitoba emp_SK emp_Yukon emp_Nunavut year if year >= 2004 & year <= 2022, ytitle("Paid worker jobs") xtitle("Year") xlabel(2004(4)2022) ylabel(, angle(0)) title("Employment by Province, All Industries") legend(size(vsmall) position(3) cols(1))



// EMPLOYMENT BY SECTOR
bysort year: egen emp_1 = sum(paid_jobs) if sectornum == 1
label var emp_1 "Farming, Food, and Forestry"
bysort year: egen emp_2 = sum(paid_jobs) if sector == "Mining and Construction"
label var emp_2 "Mining and Construction"
bysort year: egen emp_3 = sum(paid_jobs) if sector == "Manufacturing"
label var emp_3 "Manufacturing"
bysort year: egen emp_4 = sum(paid_jobs) if sector == "Trade and Transportation"
label var emp_4 "Trade and Transportation"
bysort year: egen emp_5 = sum(paid_jobs) if sector == "Services"
label var emp_5 "Services"
bysort year: egen emp_6 = sum(paid_jobs) if sector == "Government"
label var emp_6 "Government"


line emp_1 emp_2 emp_3 emp_4 emp_5 emp_6 year if year >= 2004 & year <= 2022, ytitle("Paid Worker Jobs") xtitle("Year") xlabel(2004(4)2022) ylabel(, angle(0)) title("Employment by Sector, All Provinces") legend(size(vsmall) position(3) cols(1))




// GDP BY PROVINCE
bysort year: egen gdp_BC = sum(gdp2012) if province == "British Columbia"
label var gdp_BC "British Columbia"
bysort year: egen gdp_Alberta = sum(gdp2012) if province == "Alberta"
label var gdp_Alberta "Alberta"
bysort year: egen gdp_NL = sum(gdp2012) if province == "Newfoundland and Labrador"
label var gdp_NL "Newfoundland and Labrador"
bysort year: egen gdp_NWT = sum(gdp2012) if province == "Northwest Territories"
label var gdp_NWT "Northwest Territories"
bysort year: egen gdp_PEI = sum(gdp2012) if province == "Prince Edward Island"
label var gdp_PEI "Prince Edward Island"
bysort year: egen gdp_NB = sum(gdp2012) if province == "New Brunswick"
label var gdp_NB "New Brunswick"
bysort year: egen gdp_Ontario = sum(gdp2012) if province == "Ontario"
label var gdp_Ontario "Ontario"
bysort year: egen gdp_Quebec = sum(gdp2012) if province == "Quebec"
label var gdp_Quebec "Quebec"
bysort year: egen gdp_NS = sum(gdp2012) if province == "Nova Scotia"
label var gdp_NS "Nova Scotia"
bysort year: egen gdp_Manitoba = sum(gdp2012) if province == "Manitoba"
label var gdp_Manitoba "Manitoba"
bysort year: egen gdp_SK = sum(gdp2012) if province == "Saskatchewan"
label var gdp_SK "Saskatchewan"
bysort year: egen gdp_Yukon = sum(gdp2012) if province == "Yukon"
label var gdp_Yukon "Yukon"
bysort year: egen gdp_Nunavut = sum(gdp2012) if province == "Nunavut"
label var gdp_Nunavut "Nunavut"


line gdp_BC gdp_Alberta gdp_NL gdp_NWT gdp_PEI gdp_NB gdp_Ontario gdp_Quebec gdp_NS gdp_Manitoba gdp_SK gdp_Yukon gdp_Nunavut year if year >= 2004 & year <= 2022, ytitle("GDP in 2012 Dollars (millions)") xtitle("Year") xlabel(2004(4)2022) ylabel(, angle(0)) title("GDP by Province, All Industries") legend(size(vsmall) position(3) cols(1))



// GDP BY SECTOR

bysort year: egen gdp_1 = sum(gdp2012) if sectornum == 1
label var gdp_1 "Farming, Food, and Forestry"
bysort year: egen gdp_2 = sum(gdp2012) if sector == "Mining and Construction"
label var gdp_2 "Mining and Construction"
bysort year: egen gdp_3 = sum(gdp2012) if sector == "Manufacturing"
label var gdp_3 "Manufacturing"
bysort year: egen gdp_4 = sum(gdp2012) if sector == "Trade and Transportation"
label var gdp_4 "Trade and Transportation"
bysort year: egen gdp_5 = sum(gdp2012) if sector == "Services"
label var gdp_5 "Services"
bysort year: egen gdp_6 = sum(gdp2012) if sector == "Government"
label var gdp_6 "Government"


line gdp_1 gdp_2 gdp_3 gdp_4 gdp_5 gdp_6 year if year >= 2004 & year <= 2022, ytitle("GDP in 2012 Dollars (millions)") xtitle("Year") xlabel(2008(4)2022) ylabel(, angle(0)) title("GDP by Sector, All Provinces") legend(size(vsmall) position(3) cols(1))



******************************************************************
*			Pre-treatment Indsutry characteristics Graphs
******************************************************************



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


// bysort year: egen intemissn_BC = mean(intemissn) if province == "British Columbia"
// label var intemissn_BC "British Columbia"
// bysort year: egen intemissn_Alberta = mean(intemissn) if province == "Alberta"
// label var intemissn_Alberta "Alberta"
// bysort year: egen intemissn_NL = mean(intemissn) if province == "Newfoundland and Labrador"
// label var intemissn_NL "Newfoundland and Labrador"
// bysort year: egen intemissn_NWT = mean(intemissn) if province == "Northwest Territories"
// label var intemissn_NWT "Northwest Territories"
// bysort year: egen intemissn_PEI = mean(intemissn) if province == "Prince Edward Island"
// label var intemissn_PEI "Prince Edward Island"
// bysort year: egen intemissn_NB = mean(intemissn) if province == "New Brunswick"
// label var intemissn_NB "New Brunswick"
// bysort year: egen intemissn_Ontario = mean(intemissn) if province == "Ontario"
// label var intemissn_Ontario "Ontario"
// bysort year: egen intemissn_Quebec = mean(intemissn) if province == "Quebec"
// label var intemissn_Quebec "Quebec"
// bysort year: egen intemissn_NS = mean(intemissn) if province == "Nova Scotia"
// label var intemissn_NS "Nova Scotia"
// bysort year: egen intemissn_Manitoba = mean(intemissn) if province == "Manitoba"
// label var intemissn_Manitoba "Manitoba"
// bysort year: egen intemissn_SK = mean(intemissn) if province == "Saskatchewan"
// label var intemissn_SK "Saskatchewan"
// bysort year: egen intemissn_Yukon = mean(intemissn) if province == "Yukon"
// label var intemissn_Yukon "Yukon"
// bysort year: egen intemissn_Nunavut = mean(intemissn) if province == "Nunavut"
// label var intemissn_Nunavut "Nunavut"
//
//
// line intemissn_BC intemissn_Alberta intemissn_NL intemissn_NWT intemissn_PEI intemissn_NB intemissn_Ontario intemissn_Quebec intemissn_NS intemissn_Manitoba intemissn_SK intemissn_Yukon intemissn_Nunavut year if year >= 2004 & year <= 2019, ytitle("Average GHG Emissions Intensity (tons of CO2e/$1000 production)") xtitle("Year") xlabel(2004(2)2019) ylabel(, angle(0)) title("Average GHG Emissions Intensity by Province") legend(size(vsmall) position(3) cols(1))


// INNOVATIONS

// 2015-17
graph bar innov_any1 innov_ghg1 innov_end1, over(sector) ytitle("Percent") title("Mean Percent Innovations by Purpose and Sector, 2015-17") legend(size(vsmall) position(6) cols(1))

graph bar innov_any1 innov_ghg1 innov_end1, over(province) title("Mean Percent Innovations by Purpose and Province, 2015-17") legend(size(vsmall) position(6) cols(1))



// 2017-19
graph bar innov_any2 innov_ghg2 innov_end2, over(sector) ytitle("Percent") title("Mean Percent Innovations by Purpose and Sector, 2017-19") legend(size(vsmall) position(6) cols(1))

graph bar innov_any2 innov_ghg2 innov_end2, over(province) title("Mean Percent Innovations by Purpose and Province, 2017-19") legend(size(vsmall) position(6) cols(1))

// CHANGE LABELS
// innovations with any environmental benefits
// innovations that reduce GHG emissions
// innovations with reduced GHG emissions for end user






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
sum emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings intemissn intenergy innov_ghg1 innov_ghg2 provpop provpop15_64 if year < 2019

sum emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings intemissn intenergy innov_ghg1 innov_ghg2 provpop provpop15_64 if year >= 2019

asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy /*
*/ provpop provpop15_64 if year < 2019, label

asdoc sum /*
*/ emissions gdp2012 perchange paid_jobs hours_worked wage_rate earnings /*
*/ intemissn intenergy /*
*/ provpop provpop15_64 if year >= 2019, label











