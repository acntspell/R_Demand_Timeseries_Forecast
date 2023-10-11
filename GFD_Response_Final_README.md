# GFD Time Series Forecasting - README

## Introduction:

This script focuses on time series forecasting for the monthly call volume data related to the GFD response. Various forecasting methods like naive, seasonal, random walk with drift, mean, ETS, ARIMA, and a combined approach are applied and visualized to understand the potential call volume for the future. Furthermore, the data is adjusted to account for the impact of COVID-19.

## Libraries Used:

- **tidyverse**: Collection of R packages for data manipulation and visualization.
- **forecast**: Provides tools for displaying and analyzing univariate time series forecasts.
- **readxl**: To read Excel files.
- **ggplot2**: System for declaratively creating graphics.
- **seasonal**: Provides tools for seasonal adjustment.
- **lubridate**: Simplifies working with date-times.
- **plotly**: Create interactive web graphics from ggplot2 visualizations.

## Code Walkthrough:

1. **Loading Data**:
   - Data "GFD_Response_Info.xlsx" is loaded.
   - Basic information using `summary()` and `head()` is displayed.
   - Data is filtered to retain needed variables and to remove non-GFD FDZs. 
   - Monthly summaries are created for each station.

2. **Adjusting for COVID Impact**:
   - The data is extracted and adjusted externally for Covid impact.
   - Adjusted and unadjusted data are read back into R and plotted for visualization.

3. **Training/Test Split**:
   - Data for station 4 is chosen as an example.
   - A training/test split is created for forecasting.

4. **Benchmark Models**:
   - Four basic benchmark models (Naive, Seasonal, Random Walk, and Mean) are applied and their accuracy is tested.

5. **ETS Models**:
   - Exponential Smoothing State Space models with different combinations are fitted to the data.
   - Their accuracy is tested.

6. **ARIMA Models**:
   - Autoregressive Integrated Moving Average (ARIMA) models with various parameters are evaluated using AICc.
   - The best model's residuals are checked.
   - Forecasting is performed with the chosen ARIMA model.

7. **Time Series Decomposition**:
   - X11 and STL decompositions are performed.
   - Forecasting is done on the decomposed data.

8. **Combined Forecasts**:
   - Forecasts from STL, ARIMA, and ETS are combined to form an averaged forecast.
   - This averaged forecast is evaluated against the test set.

9. **Sum Predictions**:
   - Sum predictions for the upcoming 48 months are calculated using various models and compared to the actual test values.

10. **Dynamic Plot**:
   - An interactive visualization of Station 4's monthly call volume along with various forecasts is created using `plotly`.

## Data Files:

- `GFD_Response_Info.xlsx`: Initial dataset containing GFD response information.
- `GFD_Simple.csv`: Processed data after filtering and selecting necessary columns.
- `GFD_Sum.csv`: Data summarizing calls per month by station.
- `GFD_Unadjusted.xlsx`: Data extracted without adjustments.
- `GFD_Covid_Adjusted_V2.xlsx`: Data adjusted for Covid.

## Outputs:

1. **CSV Files**:
   - `GFD_Simple.csv`
   - `GFD_Sum.csv`

2. **Visualizations**:
   - Call volume plots (Unadjusted & COVID Adjusted).
   - Forecasts using Benchmark models, ETS, ARIMA, Time Series Decomposition.
   - Interactive visualization of forecasts.

3. **Summaries**:
   - Basic summaries of loaded datasets.
   - Accuracy assessments for various forecast models.

## How to Run:

1. Ensure all required packages are installed.
2. Ensure the necessary Excel files are in the working directory.
3. Execute the R script.

## Note:

Before running the script, ensure all data paths and file names are correct, especially if there have been changes to the file names or if files have been moved to different locations.
