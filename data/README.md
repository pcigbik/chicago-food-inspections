# Data

The raw Chicago Food Inspections dataset is too large to commit to GitHub directly (over 100 MB), and the file is updated monthly by the City of Chicago. To run the analysis locally, download the CSV manually.

## Steps

1. Go to the [Chicago Food Inspection Data portal](https://data.cityofchicago.org/Health-Human-Services/Food-Inspections/4ijn-s7e5/about_data).
2. Click **Export → CSV**.
3. Save the file in this folder and rename it to `Food_Inspections.csv`.

The expected path is:

```
data/Food_Inspections.csv
```

## Notes

- The dataset is updated monthly. Numbers in the report were generated against the snapshot pulled in August 2024.
- The `combined_data_risk_pass.csv` file in this folder is generated automatically by `R/Graphs.R` when the analysis is run.
