# Exploratory Data Analysis for the Chicago Food Inspections dataset.
#
# This script is a standalone scratchpad. It does not modify or produce data
# used by the rest of the project. Run it on its own to inspect the raw CSV.

# Read in the dataset.
csf <- read.csv("data/Food_Inspections.csv")

head(csf)
tail(csf)

# Data types for each column.
sapply(csf, typeof)

# Shape.
nrow(csf)
ncol(csf)

# Unique values and frequencies for the categorical columns of interest.
unique(csf$Risk);            table(csf$Risk)
unique(csf$City);            table(csf$City)
unique(csf$State);           table(csf$State)
unique(csf$Zip);             table(csf$Zip)
unique(csf$Results);         table(csf$Results)
unique(csf$Inspection.Type); table(csf$Inspection.Type)

# Counts of unique values across every column.
sapply(csf, function(x) length(unique(x)))

# Basic numeric summaries.
mean(csf$Inspection.ID)
median(csf$Inspection.ID)
sd(csf$Inspection.ID)
var(csf$Inspection.ID)

median(csf$License..)

mean(csf$Zip,       na.rm = TRUE)
median(csf$Zip,     na.rm = TRUE)
mean(csf$Longitude, na.rm = TRUE)
median(csf$Longitude, na.rm = TRUE)
mean(csf$Latitude,  na.rm = TRUE)
median(csf$Latitude, na.rm = TRUE)
