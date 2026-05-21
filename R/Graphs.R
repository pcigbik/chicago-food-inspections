# Graphs and aggregated data frames for the Chicago Food Inspections project.
#
# This script depends on `csf_new` from dataCleaning.R. Source dataCleaning.R
# first if you are running this standalone:
#   source("R/dataCleaning.R")
#
# It produces two key data frames that the rest of the project uses:
#   - csf_select:             cleaned data filtered to the four facility types
#   - combine_data_risk_pass: yearly pass rates and risk rates by facility type

library(dplyr)
library(janitor)
library(ggplot2)
library(tidyr)
library(stringr)
library(readr)

# Start from the cleaned data, drop rows with a blank Risk value, and keep only
# the four facility types this project focuses on. Using %in% here so all four
# values are kept (using `==` with a vector silently drops most rows).
csf_no_blank <- csf_new[csf_new$Risk != "", ]
csf_select <- csf_no_blank %>%
  filter(Facility_Type %in% c("Restaurant", "Bar", "School", "Daycare"))

# Color palette used for the risk-over-time stacked bar charts.
risk_colors <- c(
  "Risk 1 (High)"   = "#C70039",
  "Risk 2 (Medium)" = "#f8f968",
  "Risk 3 (Low)"    = "#a3f968"
)

# Risk levels in daycares that passed inspections, 2010 - 2024.
csf_select %>%
  filter(Facility_Type == "Daycare",
         Results %in% c("Pass", "Pass w/ Conditions")) %>%
  ggplot(aes(x = Year, fill = Risk)) +
  geom_bar() +
  labs(title = "Risk Levels in Daycares That Passed Inspections 2010 - 2024",
       x = "Year", y = "Count") +
  scale_fill_manual("Risk Levels", values = risk_colors)

# Risk levels in restaurants that passed inspections, 2010 - 2024.
csf_select %>%
  filter(Facility_Type == "Restaurant",
         Results %in% c("Pass", "Pass w/ Conditions")) %>%
  ggplot(aes(x = Year, fill = Risk)) +
  geom_bar() +
  labs(title = "Risk Levels in Restaurants That Passed Inspections 2010 - 2024",
       x = "Year", y = "Count") +
  scale_fill_manual("Risk Levels", values = risk_colors)

# Risk levels in bars that passed inspections, 2010 - 2024.
csf_select %>%
  filter(Facility_Type == "Bar",
         Results %in% c("Pass", "Pass w/ Conditions")) %>%
  ggplot(aes(x = Year, fill = Risk)) +
  geom_bar() +
  labs(title = "Risk Levels in Bars That Passed Inspections 2010 - 2024",
       x = "Year", y = "Count") +
  scale_fill_manual("Risk Levels", values = risk_colors)

# Risk levels in schools that passed inspections, 2010 - 2024.
csf_select %>%
  filter(Facility_Type == "School",
         Results %in% c("Pass", "Pass w/ Conditions")) %>%
  ggplot(aes(x = Year, fill = Risk)) +
  geom_bar() +
  labs(title = "Risk Levels in Schools That Passed Inspections 2010 - 2024",
       x = "Year", y = "Count") +
  scale_fill_manual("Risk Levels", values = risk_colors)


# Prevalence of each risk level across the four facility types ----------------

# Risk 1
csf_select %>%
  filter(Risk == "Risk 1 (High)") %>%
  ggplot(aes(Facility_Type, fill = Facility_Type)) +
  geom_bar() +
  labs(title = "Prevalenace of Risk 1 In Specfic Facilities",
       x = "Facility Type", y = "Count")

# Risk 2
csf_select %>%
  filter(Risk == "Risk 2 (Medium)") %>%
  ggplot(aes(Facility_Type, fill = Facility_Type)) +
  geom_bar() +
  labs(title = "Prevalenace of Risk 2 In Specfic Facilities",
       x = "Facility Type", y = "Count")

# Risk 3
csf_select %>%
  filter(Risk == "Risk 3 (Low)") %>%
  ggplot(aes(Facility_Type, fill = Facility_Type)) +
  geom_bar() +
  labs(title = "Prevalenace of Risk 3 In Specfic Facilities",
       x = "Facility Type", y = "Count")


# Average risk score over the years -------------------------------------------

# Convert Risk into a numeric Binary_Risk column where 1 = low and 3 = high.
csf_select$Binary_Risk <- dplyr::case_when(
  csf_select$Risk == "Risk 1 (High)"   ~ 3,
  csf_select$Risk == "Risk 2 (Medium)" ~ 2,
  csf_select$Risk == "Risk 3 (Low)"    ~ 1,
  csf_select$Risk == "All"             ~ 0,
  TRUE                                 ~ NA_real_
)

risk_coef <- csf_select %>%
  group_by(Facility_Type) %>%
  summarise(avg = mean(Binary_Risk, na.rm = TRUE))

risk_coef_yrly <- csf_select %>%
  group_by(Facility_Type, Year) %>%
  summarise(avg = mean(Binary_Risk, na.rm = TRUE), .groups = "drop")

# Average risk score per facility type per year.
csf_select %>%
  group_by(Facility_Type, Year) %>%
  summarise(Average_Risk = mean(Binary_Risk, na.rm = TRUE), .groups = "drop") %>%
  ggplot(aes(Year, Average_Risk, color = Facility_Type)) +
  geom_point() +
  geom_line() +
  ggtitle("Avgerage Risk Score Over the Years")


# Yearly pass rates and risk rates by facility type ---------------------------

# Pass rate: share of inspections that resulted in Pass or Pass w/ Conditions.
pass_data <- csf_select %>%
  group_by(Facility_Type, Year) %>%
  summarise(
    Passes   = sum(Results == "Pass") + sum(Results == "Pass w/ Conditions"),
    Failures = sum(Results == "Fail") + sum(Results == "No Entry") +
               sum(Results == "Out of Business") + sum(Results == "Not Ready") +
               sum(Results == "Business Not Located"),
    .groups  = "drop"
  ) %>%
  mutate(Pass_Rate = Passes / (Failures + Passes))

# Risk rates: share of inspections classified at each risk level.
risk_rate <- csf_select %>%
  group_by(Facility_Type, Year) %>%
  summarise(
    riskOne   = sum(Risk == "Risk 1 (High)"),
    riskTwo   = sum(Risk == "Risk 2 (Medium)"),
    riskThree = sum(Risk == "Risk 3 (Low)"),
    All       = sum(Risk == "All"),
    .groups   = "drop"
  ) %>%
  mutate(
    Risk_One_Rate   = riskOne   / (riskOne + riskTwo + riskThree + All),
    Risk_Two_Rate   = riskTwo   / (riskOne + riskTwo + riskThree + All),
    Risk_Three_Rate = riskThree / (riskOne + riskTwo + riskThree + All)
  )

# Combined frame used by models.R and by the .qmd report.
combine_data_risk_pass <- data.frame(
  Facility_Type   = pass_data$Facility_Type,
  Year            = pass_data$Year,
  Pass_Rate       = pass_data$Pass_Rate,
  Risk_One_Rate   = risk_rate$Risk_One_Rate,
  Risk_Two_Rate   = risk_rate$Risk_Two_Rate,
  Risk_Three_Rate = risk_rate$Risk_Three_Rate
)

# Persist the combined frame for reuse. The data/ folder must already exist.
if (dir.exists("data")) {
  write_csv(combine_data_risk_pass, file = "data/combined_data_risk_pass.csv")
}


# Risk Rate vs Pass Rate scatter plots ----------------------------------------

# Daycare
combine_data_risk_pass %>%
  filter(Facility_Type == "Daycare") %>%
  ggplot(aes(x = Pass_Rate, y = Risk_One_Rate, color = Year)) +
  geom_point() +
  ggtitle("Daycare Risk 1 Rate vs. Pass Rate from 2010 - 2024")

# Bar
combine_data_risk_pass %>%
  filter(Facility_Type == "Bar") %>%
  ggplot(aes(x = Risk_Three_Rate, y = Pass_Rate, color = Year)) +
  geom_point() +
  labs(title = "Risk 3 Rate vs Overall Pass Rate in Bars from 2010 - 2024",
       x = "Risk Three Rate", y = "Pass Rate")

# School
combine_data_risk_pass %>%
  filter(Facility_Type == "School") %>%
  ggplot(aes(x = Risk_One_Rate, y = Pass_Rate, color = Year)) +
  geom_point() +
  labs(title = "Risk 1 Rate vs Overall Pass Rate in Schools from 2010 - 2024",
       x = "Risk One Rate", y = "Pass Rate")

# Restaurant
combine_data_risk_pass %>%
  filter(Facility_Type == "Restaurant") %>%
  ggplot(aes(x = Pass_Rate, y = Risk_One_Rate, color = Year)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "orange") +
  ggtitle("Correaltion Between Risk 1 Rate and Overall Pass Rate in Restaurants from 2010 - 2024")
