# GFD Monthly Call Volume Forecasting - README

## Introduction:

This script aims to perform time series forecasting on the monthly call volume data for different stations. The data has been adjusted to reflect the impact of COVID-19. Multiple forecasting techniques, such as naive forecasting, drift forecasting, ETS, ARIMA, and their combinations, are used. After constructing models on a train-test split, the script forecasts the next 48 months using the complete time series data.

## Libraries Used:

- **tidyverse**: Data manipulation and visualization package collection.
- **forecast**: Time series forecasting tools.
- **readxl**: Reading Excel files.
- **ggplot2**: Data visualization.
- **seasonal**: Tools for seasonal adjustment.
- **lubridate**: Date-time manipulation.
- **plotly**: Interactive graphing.
- **ggthemes**: Additional themes, geoms, etc. for `ggplot2`.

## Code Walkthrough:

1. **Loading Data**:
   - COVID-adjusted (`GFD_Covid_Adjusted_V2.xlsx`) and unadjusted (`GFD_Unadjusted.xlsx`) monthly response values are loaded.

2. **Iterative Forecasting for Each Station**:
   - A loop runs for each station.
   - The train/test split is created, followed by forecasts using benchmark models, ETS, and ARIMA models.
   - Time series decomposition using STL is visualized and saved as HTML and PDF files.
   - The combined forecasts of ARIMA and ETS models are produced and their accuracy is assessed.
   - Visualizations and results are saved as CSV, HTML, and PDF files.

3. **Full Forecasting Post Train-Test**:
   - After evaluating models on the train-test split, forecasting for the next 48 months is performed using the entire time series.
   - Various models, including ARIMA, ETS, and their combinations, are used.
   - Results and visualizations are saved in CSV, HTML, and PDF formats.

## Data Files:

- `GFD_Covid_Adjusted_V2.xlsx`: Dataset containing monthly call volume data, adjusted for the impact of COVID-19.
- `GFD_Unadjusted.xlsx`: Dataset containing unadjusted monthly call volume data.

## Outputs:

1. **CSV Files**:
   - Forecast data for each station: `"_Forecast.csv"`.
   - Error assessment and sum data for each station: `"_Error & Sum.csv"`.

2. **HTML Files**:
   - Time series decomposition visualizations: `"_ TS Decomp.html"`.
   - Forecast visualizations: `"_Forecasts.html"`.

3. **PDF Files**:
   - Time series decomposition visualizations: `"_ TS_Decomp.pdf"`.
   - Forecast visualizations: `"_Forecasts.pdf"`.

## How to Run:

1. Ensure all required packages are installed.
2. Ensure the necessary Excel files are in the working directory.
3. Execute the R script.

## Note:

Before running the script, ensure all data paths and file names are correct. If file names or paths change, adjust the script accordingly. Given the loop's nature for multiple stations, ensure the column indices in variable `i` match the number of stations in your dataset.
