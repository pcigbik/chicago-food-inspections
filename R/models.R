# Linear Regression and Chi-Square models for the Chicago Food Inspections project.
#
# This script depends on `csf_select` and `combine_data_risk_pass` from Graphs.R.
# Source the upstream scripts first if you are running this standalone:
#   source("R/dataCleaning.R")
#   source("R/Graphs.R")

library(stats)
library(ggplot2)
library(caTools)
library(readr)
library(dplyr)


# Linear Model: predicting Pass Rate from past risk classifications ----------

# Set a seed so the 80:20 split is reproducible run to run.
set.seed(123)

split       <- sample.split(combine_data_risk_pass$Pass_Rate, SplitRatio = 0.8)
train_data  <- subset(combine_data_risk_pass, split == TRUE)
test_data   <- subset(combine_data_risk_pass, split == FALSE)

# Train the linear model on the 80% training set.
lr_model <- lm(
  Pass_Rate ~ Risk_One_Rate + Risk_Two_Rate + Risk_Three_Rate + Year + Facility_Type,
  data = train_data
)

# Predict on the held-out test set.
test_data$pred <- predict(lr_model, newdata = test_data)

# Real vs predicted plot for the 80:20 split.
ggplot(test_data, aes(x = Pass_Rate, y = pred, color = Facility_Type)) +
  geom_point() +
  labs(title = "Real vs Predicted Values",
       x = "True Pass Rate",
       y = "Predicted Pass Rate")


# Evaluate the same model against the entire dataset --------------------------

pred_all_data         <- predict(lr_model, newdata = combine_data_risk_pass)
test_all_risk         <- combine_data_risk_pass
test_all_risk$pred    <- pred_all_data

ggplot(test_all_risk, aes(x = Pass_Rate, y = pred, color = Facility_Type)) +
  geom_point() +
  labs(title = "Real vs Predicted Values (Full Dataset)",
       x = "True Pass Rate",
       y = "Predicted Pass Rate")


# Metrics ---------------------------------------------------------------------

mae       <- mean(abs(test_data$Pass_Rate - test_data$pred), na.rm = TRUE)
mae_all   <- mean(abs(test_all_risk$Pass_Rate - test_all_risk$pred), na.rm = TRUE)
r_sqr     <- summary(lr_model)$r.squared

# R-squared from refitting on the full dataset (for comparison).
lr_model_full <- lm(
  Pass_Rate ~ Risk_One_Rate + Risk_Two_Rate + Risk_Three_Rate + Year + Facility_Type,
  data = combine_data_risk_pass
)
r_sqr_all <- summary(lr_model_full)$r.squared

cat("80:20 Model\n",
    "  R-squared: ", round(r_sqr, 4),     "\n",
    "  MAE:       ", round(mae, 4),       "\n\n",
    "Entire Dataset\n",
    "  R-squared: ", round(r_sqr_all, 4), "\n",
    "  MAE:       ", round(mae_all, 4),   "\n",
    sep = "")


# Chi-Square Test of Independence: Risk vs. Results --------------------------

# Does the risk classification of an inspection have any relationship to its
# result, or are the two independent? A significant p-value rejects independence.
chi_result <- chisq.test(csf_select$Risk, csf_select$Results, correct = FALSE)
chi_result
