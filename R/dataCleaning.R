# Data Cleaning for the Chicago Food Inspections dataset.
#
# Run this script first. It reads the raw CSV from the data/ folder and produces
# a cleaned data frame called `csf_new` that the other scripts depend on.

library(dplyr)
library(janitor)
library(ggplot2)
library(tidyr)
library(readr)
library(lubridate)
library(stringr)

# Read the raw data. Path is relative to the project root, so make sure you
# render the .qmd or run the scripts from the root of the repository.
csf <- read.csv("data/Food_Inspections.csv")

# Quick look
head(csf)

# Standardize the City column.
# All Chicago-area facilities get folded into "Chicago" regardless of how the
# city name was originally typed, including casing variants, typos, and the
# surrounding villages that the inspectors lumped in.
chicago_variants <- c(
  "CHicago", "CHICAGO", "123chicago", "CHICAGO.", "Chicago",
  "LANSING", "CHICAGOCHICAGO", "CCHICAGO", "CHCHICAGO", "CHICAGOO",
  "CHICAGOI", "312CHICAGO", "CHICAGOC", "chicago", "CHCICAGO", "CH",
  "CHICAGO HEIGHTS", "Summit", "SUMMIT", "OAK LAWN", "MATTESON",
  "ELK GROVE VILLAGE", "SCHAUMBURG", "ELMHURST", "NILES NILES",
  "chicagoBEDFORD PARK", "HIGHLAND PARK", "BLOOMINGDALE", "NAPERVILLE",
  "alsip", "WESTMONT", "TINLEY PARK"
)
csf$City[csf$City %in% chicago_variants] <- "Chicago"
csf$City[csf$City == "MAYWOOD"] <- "Maywood"

# Drop rows for states outside Illinois. The dataset is supposed to be
# Chicago-only but a handful of records slip in from neighboring states.
csf <- csf %>% filter(!State %in% c("CA", "CO", "WI", "NY", "IN", ""))

# Replace blank strings with NA in the columns where blanks are not meaningful.
csf$City[csf$City == ""]         <- NA
csf$AKA.Name[csf$AKA.Name == ""] <- NA
csf$DBA.Name[csf$DBA.Name == ""] <- NA
csf$Violations[csf$Violations == ""] <- NA

# Rename columns to be easier to work with downstream.
csf_new <- csf %>%
  rename(
    License         = License..,
    Inspection_ID   = Inspection.ID,
    Inspection_Date = Inspection.Date,
    Inspection_Type = Inspection.Type,
    DBA_Name        = DBA.Name,
    AKA_Name        = AKA.Name,
    Facility_Type   = Facility.Type
  )

# Collapse the dozens of Facility_Type variants down to a clean set of categories.
# The raw column has 518 unique values, most of which are casing or wording
# variants of the same handful of actual facility types.
csf_new <- csf_new %>%
  mutate(Facility_Type = case_when(
    Facility_Type == "SHELTER" ~ "Shelter",

    Facility_Type %in% c(
      "Daycare Above and Under 2 Years", "Daycare (2 - 6 Years)",
      "Daycare (2 Years)", "Daycare (Under 2 Years)", "DAYCARE",
      "Daycare Combo 1586", "DAYCARE 2 YRS TO 12 YRS", "DAYCARE 2-6, UNDER 6",
      "DAY CARE 102", "DAYCARE 1586", "DAYCARE 1023", "DAYCARE COMBO",
      "DAYCARE 6 WKS-5YRS", "Daycare Night", "Day Care Combo (1586)",
      "Day Care Facility", "CHURCH/DAY CARE", "DAY CARE", "DAY CARE 1023",
      "1584-DAY CARE ABOVE 2 YEARS", "DAY CARE 2 - 14"
    ) ~ "Daycare",

    Facility_Type %in% c(
      "Coffe Shop", "coffe shop", "cafe", "Kids Cafe", "CAFE",
      "COFFEE/TEA", "TEA STORE"
    ) ~ "Cafe",

    Facility_Type %in% c(
      "TAVERN", "TAVERN/LIQUOR", "Tavern", "HOOKA BAR", "Tavern/Bar",
      "LIQUOR", "LIQUOR/GROCERY STORE/BAR", "bar", "TAVERN-LIQUOR", "Liquor",
      "liquor store", "LIQUORE STORE/BAR", "BAR", "BAR/GRILL",
      "RETAIL WINE/WINE BAR", "WINE TASTING BAR", "tavern",
      "TAVERN/PACKAGED GOODS", "TAP room/tavern/liquor store", "TAVERN/1006"
    ) ~ "Bar",

    Facility_Type %in% c("hair salon", "HAIR SALON") ~ "Hair Salon",

    Facility_Type %in% c(
      "NON-PROFIT", "NON -PROFIT", "NOT FOR PROFIT",
      "NON-FOR PROFIT BASEMENT", "NON-FOR PROFIT CLUB"
    ) ~ "Non-Profit",

    Facility_Type %in% c("GYM STORE", "GYM") ~ "Gym",

    Facility_Type == "(convenience store)" ~ "Convenience Store",

    Facility_Type %in% c(
      "GROCERY & RESTAURANT", "RESTAURANT/BAKERY", "RESTAURANT.BANQUET HALLS",
      "GROCERY STORE/ RESTAURANT", "bakery/restaurant", "TENT RESTAURANT"
    ) ~ "Restaurant",

    Facility_Type %in% c(
      "AFTER SCHOOL CARE", "CHURCH/AFTER SCHOOL PROGRAM", "CHARTER SCHOOL",
      "PRIVATE SCHOOL", "school cafeteria", "School Cafeteria",
      "BEFORE AND AFTER SCHOOL PROGRAM", "after school program",
      "AFTER SCHOOL PROGRAM"
    ) ~ "School",

    TRUE ~ Facility_Type
  ))

# Drop the coordinate columns. They are not used in the analysis and adding
# them in could be a direction for a future version of this project.
csf_new <- csf_new %>% select(-any_of(c("Latitude", "Longitude", "Location")))

# Parse the inspection date and pull out the year as its own column.
csf_new$Inspection_Date <- as.Date(csf_new$Inspection_Date, format = "%m/%d/%Y")
csf_new$Year            <- as.numeric(format(csf_new$Inspection_Date, "%Y"))

# Sanity checks
unique(csf_new$Facility_Type)
head(csf_new$Year)
