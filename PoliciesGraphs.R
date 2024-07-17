#install.packages("readxl")
library(readxl)
library(ggplot2)
rm(list = ls())
setwd("/Users/PallaviMaladkar/Dropbox/Honors Thesis-Pallavi/Canada data")

policies <- read_xlsx(path = "envpolicy_ready.xlsx")


# CARBON TAX RATES
carbon_filtered <- subset(policies, !(province %in% c("Nova Scotia")))
# NS is the only province without carbon taxes ever

ggplot(carbon_filtered, aes(x = year, y = carbon_rate, group = province, color = province)) +
  geom_line(position = position_dodge(width = 0.8)) +
  #geom_point(position = position_dodge(width = 0.8)) +
  ggtitle("Carbon Tax Rates by Province") +
  scale_x_continuous(breaks = seq(2004,2024,2)) +
  xlab("Year") + 
  ylab("Tax Rate, $/ton CO2e") +
  theme(text = element_text(family = "Times New Roman")) +
  guides(color = guide_legend(title = "Province"))



# CREDIT SYSTEM RATES
credit_filtered <- subset(policies, !(province %in% c("British Columbia", "Quebec", "Northwest Territories", "Nova Scotia")))
# BC, NWT, NS, Quebec dont have credit systems

ggplot(credit_filtered, aes(x = year, y = credit_rate, group = province, color = province)) +
  geom_line(position = position_dodge(width = 0.8)) +
  ggtitle("Credit System Excess Charges by Province") +
  scale_x_continuous(breaks = seq(2004,2024,2)) +
  xlab("Year") + 
  ylab("Excess Charge, $/ton CO2e") +
  theme(text = element_text(family = "Times New Roman")) +
  guides(color = guide_legend(title = "Province"))



# CAT SYSTEM RATES
cap_filtered <- subset(policies, province %in% c("Nova Scotia", "Quebec", "Ontario"))
# these are the only provinces that have CAT systems

ggplot(cap_filtered, aes(x = year, y = cap_rate, group = province, color = province)) +
  geom_line() +
  #geom_point() +
  ggtitle("Cap-and-trade System Auction Prices by Province") +
  scale_x_continuous(breaks = seq(2004,2024,2)) +
  xlab("Year") + 
  ylab("Auction Price, $/ton CO2e") +
  theme(text = element_text(family = "Times New Roman")) +
  guides(color = guide_legend(title = "Province"))

