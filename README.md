This is the code I used to complete my Senior Honors Thesis in Economics at UNC Chapel Hill.
I worked on this code with the help of my thesis advisor, Dr. Klara Peter. 

KSP Steps 1-4 were used to get the main dataset ready. 
The data was downloaded online from Statistics Canada and merged through these do files.
The final data file is named carbon_tax_workfile_v2.dta, which is included in this repository.

The excel file TaxRatesByProvince.xlsx is the file containing policy information on carbon policies by Canadian province and year.
PoliciesGraphs.R is a file in RStudio that creates visualizations for the carbon policy rates over the time period.
~KSP Step 5.1 - Policy visualizations.do is a file in STATA that creates different visualizations for the carbon policy types and rates.
Data Tables v2.do contains ways to visually analyze the data in carbon_tax_workfile_v2.dta (histograms, line graphs, etc). 
These visualizations are useful in telling a story about the data in the thesis, and understanding what kind of analyses are useful. 

Code for my main estimates and analyses are available in the following files:
- PM - Main Estimates.do
- Heterogeneous Effects.do
- Mediating Model.do
- Federal Baseline.do (not used in thesis, just an exploration)
- KSP Step 6 - Interactions and quantile regressions.do (some more exploration, though some is elements are used in thesis)

PallaviMaladkar_EconomicsHonorsThesis.pdf is my complete senior honors thesis, submitted to the Carolina Digital Repository at UNC Chapel Hill.

For questions about code or analysis that does not seem to be included in the repository, I am happy to connect and provide this information.
