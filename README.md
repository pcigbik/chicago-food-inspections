# Would a Local Chicago Facility Pass a Food Inspection?

Predicting food inspection pass rates in Chicago using historical risk classifications, with a Linear Regression model and a Chi-Square Test of Independence.

**By Precious C. Igbiki**
Data Science Research Program (DSRP) 2024, The Coding School and Columbia University

📄 **[Read the full report](https://pcigbik.github.io/chicago-food-inspections/Final_Report.html)** · 🎞️ **[View the presentation](docs/DRSP_Final_Presantation.pdf)**

---

## Overview

The City of Chicago publishes the results of every food inspection it carries out, along with a risk classification for the facility being inspected. This project asks whether the historical pattern of those risk classifications can be used to predict how a facility will perform on future inspections, focusing on four facility types: Daycares, Restaurants, Bars, and Schools.

### Key findings

- A linear regression model trained on past risk rates, year, and facility type predicts overall pass rate with **R² ≈ 0.80** and a mean absolute error of about **3.7 percentage points** on the held-out test set.
- A Chi-Square Test of Independence returned **X² = 636.45, df = 18, p < 2.2e-16**, confirming that risk classification and inspection results are not independent.
- Different facility types are held to clearly different baselines. Schools and daycares maintain high pass rates regardless of their risk distribution, while bars sit at the lower end of the pass rate range even when their risk profile improves.

## Tools

R, Quarto, dplyr, ggplot2, tidyr, caTools, stats.

## Repository structure

```
chicago-food-inspections/
├── Final_Report.qmd          Quarto source for the full report
├── Final_Report.html         Rendered report (open this to read)
├── R/
│   ├── dataCleaning.R        Cleans the raw CSV, standardizes facility types
│   ├── dataExploration.R     Initial exploratory data analysis
│   ├── Graphs.R              Builds csf_select and combine_data_risk_pass, plus all graphs
│   └── models.R              Linear regression and Chi-Square test
├── data/
│   └── README.md             How to get the raw dataset (too large for GitHub)
└── docs/
    └── DRSP_Final_Presantation.pdf
```

## Reproducing the analysis

1. Clone the repo:
   ```bash
   git clone https://github.com/pcigbik/chicago-food-inspections.git
   cd chicago-food-inspections
   ```

2. Download the raw data from the [Chicago Food Inspection Data portal](https://data.cityofchicago.org/Health-Human-Services/Food-Inspections/4ijn-s7e5/about_data) and save it as `data/Food_Inspections.csv`. See `data/README.md` for details.

3. Install the R packages:
   ```r
   install.packages(c("dplyr", "janitor", "ggplot2", "tidyr", "readr",
                      "lubridate", "stringr", "caTools"))
   ```

4. Render the report:
   ```bash
   quarto render Final_Report.qmd
   ```
   Or run the scripts in order from the project root:
   ```r
   source("R/dataCleaning.R")
   source("R/Graphs.R")
   source("R/models.R")
   ```

## Data source

City of Chicago Food Inspections dataset, available at https://data.cityofchicago.org/Health-Human-Services/Food-Inspections/4ijn-s7e5/about_data. Updated monthly by the Chicago Department of Public Health.

## Acknowledgements

Thank you to Shaunette Ferguson for mentoring me throughout this project, Pavithra Dasarakoppalu for technical support as my TA, and The Coding School alongside Columbia University for the opportunity.
