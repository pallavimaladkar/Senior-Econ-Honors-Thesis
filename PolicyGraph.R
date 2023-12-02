#install.packages("readxl")
library(readxl)
library(ggplot2)
rm(list = ls())
setwd("/Users/PallaviMaladkar/Dropbox/Honors Thesis-Pallavi/Canada data")

policy <- read_xlsx(path = "TaxRatesByProvince.xlsx")

# CARBON TAX RATES
ggplot(policy, aes(x = year, y = tax_rate, group = province, color = province)) +
  geom_line(position = position_dodge(width = 0.8)) +
  ggtitle("Carbon Tax Rates by Canadian Province") +
  scale_x_continuous(breaks = seq(2004,2024,2)) +
  xlab("Year") + 
  ylab("Carbon Tax Rate") +
  theme(text = element_text(family = "Times New Roman")) +
  guides(color = guide_legend(title = "Province"))
