################### Libraries Used ################

library(tidyverse)
library(forecast)
library(readxl)
library(ggplot2)
library(seasonal)
library(lubridate)
library(plotly)

###################### Intro Data Tasks ################

## Read in xls response data

GFD <- read_xlsx("GFD_Response_Info.xlsx")

summary(GFD)
head(GFD)

## isolate needed variables and remove non-GFD FDZ's

GFD_Simple <- GFD%>%
  dplyr::select("inci_no",
                "Month",
                "Year",
                "station",
                "FDZ",
                "Incident Type")%>%
  filter(as.numeric(FDZ)>=0)%>%
  filter(as.numeric(station)>=0)

write.csv(GFD_Simple, "GFD_Simple.csv")

summary(GFD_Simple)

## Build Month/Year as Variable

GFD_Simple <- GFD_Simple%>%
  mutate(Month_Date = as.Date(paste(GFD_Simple$Month, 01, GFD_Simple$Year), "%m %d %Y"))

## Widen data to summarize calls per month by station

Sum_GFD <- GFD_Simple%>%
  group_by(Month_Date, station)%>%
  summarise(Count=n())%>%
  pivot_wider(names_from = station, values_from = Count)
         
str(Sum_GFD)
summary(Sum_GFD)
head(Sum_GFD)

write.csv(Sum_GFD, "GFD_Sum.csv")

########### Data Extracted % Adjusted for Covid ####################

## Data was output to excel and the following transforms were conducted:

## 1) Non-city stations were removed from the data set.

## 2) Pre-covid response values were transformed by reducing the monthly values using the % reduction in responses between
##    2019 and 2020 as a result of Covid response. 

## Data was then imported back into R for forecasting.

GFD_Unadjusted <- read_xlsx("GFD_Unadjusted.xlsx")

GFD_Adjusted <- read_xlsx("GFD_Covid_Adjusted_V2.xlsx")

GFD_ts_non <- ts(GFD_Unadjusted[,2:25], start=c(2006,7), end=c(2022,3),freq=12)

gfd_non<-autoplot(GFD_ts_non)+
  ggtitle("Monthly Call Volume - Unadjusted")+
  ylab("Calls per Month")+xlab("Year")

ggplotly(gfd_non)

GFD_ts <- ts(GFD_Adjusted[,2:25], start=c(2006,7), end=c(2022,3),freq=12)

gfd<-autoplot(GFD_ts)+
  ggtitle("Monthly Call Volume - COVID Adjusted")+
  ylab("Calls per Month")+xlab("Year")

ggplotly(gfd)

########## Station Train/Test Split ##############

## Create time series for particular station (station 4 as example)

## Create train/test split for station

GFD_ts_station <- ts(GFD_Adjusted$`4`, start=c(2006,7), end=c(2022,3),freq=12)

GFD_ts_train <- window(GFD_ts_station, end=c(2018,3))
GFD_ts_test <- window(GFD_ts_station, start=c(2018,4), end=c(2022,3))  

################## Benchmark Models ##########################

GFD_naive <- naive(GFD_ts_train, h=48)

GFD_seasonal <- snaive(GFD_ts_train, h=48)

GFD_drift <- rwf(GFD_ts_train, drift = TRUE, h=48)

GFD_avg <- meanf(GFD_ts_train, h=48)

autoplot(GFD_ts_station)+
  ggtitle("Station 4 Monthly Call Volume w/Benchmark Forecasts")+
  ylab("Calls per Month")+xlab("Year")+
  autolayer(GFD_naive$mean, series = "Naive")+
  autolayer(GFD_seasonal$mean, series = "Seasonal")+
  autolayer(GFD_drift$mean, series = "Random Walk")+
  autolayer(GFD_avg$mean, series = "Mean")

accuracy(GFD_naive,GFD_ts_test)
accuracy(GFD_seasonal,GFD_ts_test)
accuracy(GFD_drift,GFD_ts_test)
accuracy(GFD_avg,GFD_ts_test)


################## ETS models ###################

GFD_ETS <- ets(GFD_ts_train, model = "MAM", damped = FALSE)
GFD_ETS2 <- ets(GFD_ts_train, model = "MMM", damped = FALSE)
GFD_ETS3 <- ets(GFD_ts_train, model = "MAA", damped = FALSE)

summary(GFD_ETS)
summary(GFD_ETS2)
summary(GFD_ETS3)

GFD_ETS_forecast <- forecast(GFD_ETS, h=48)
GFD_ETS_forecast2 <- forecast(GFD_ETS2, h=48)
GFD_ETS_forecast3 <- forecast(GFD_ETS3, h=48)

accuracy(GFD_ETS_forecast,GFD_ts_test)
accuracy(GFD_ETS_forecast2,GFD_ts_test)
accuracy(GFD_ETS_forecast3,GFD_ts_test)

autoplot(GFD_ts_station)+
  ggtitle("Station 4 Monthly Call Volume w/ETS Forecast")+
  ylab("Calls per Month")+xlab("Year")+
  autolayer(GFD_ETS_forecast$mean, series = "MAM")+
  autolayer(GFD_ETS_forecast$mean, series = "MMM")+
  autolayer(GFD_ETS_forecast$mean, series = "MAA")
  

################ ARIMA models ##################


### Differencing: select d ###

autoplot(GFD_ts_station)

autoplot(diff(GFD_ts_station))

## d = 1

### 4. Examine ACF/PACF - select p & q ###
ggtsdisplay(diff(diff(GFD_ts_station,lag=12)))

## significant at lag 1 & 12 on ACF, multiple significant lags on PACF. q = 1 selected

## seasonal term selected as 1

### 5. Fit selected ARIMA(p,d,q) model; tweak & compare AICc ###
model1 <- Arima(GFD_ts_train,order=c(0,1,1),seasonal=c(0,1,0))
model2 <- Arima(GFD_ts_train,order=c(0,2,1),seasonal=c(0,1,0))
model3 <- Arima(GFD_ts_train,order=c(0,1,2),seasonal=c(0,1,0))
model4 <- Arima(GFD_ts_train,order=c(1,1,1),seasonal=c(0,1,0))
model5 <- Arima(GFD_ts_train,order=c(2,1,1),seasonal=c(0,1,0))

model1  ## lowest AICc
model2
model3  
model4
model5

### 6. Check residual diagnostics ###
checkresiduals(model1)

model6 <- Arima(GFD_ts_train,order=c(0,1,1),seasonal=c(1,1,0))
model7 <- Arima(GFD_ts_train,order=c(0,1,1),seasonal=c(2,1,0))
model8 <- Arima(GFD_ts_train,order=c(0,1,1),seasonal=c(0,1,1))
model9 <- Arima(GFD_ts_train,order=c(0,1,1),seasonal=c(0,1,2))
model10 <- Arima(GFD_ts_train,order=c(0,1,1),seasonal=c(1,1,1))

model6
model7
model8  ## lowest AICc
model9
model10

checkresiduals(model8)

summary(model8)

### Create ARIMA forecasts ###

GFD_ARIMA_forecast <- forecast(model8, h=48)

autoplot(GFD_ts_station)+
  ggtitle("Station 4 Monthly Call Volume w/ARIMA Forecast")+
  ylab("Calls per Month")+xlab("Year")+
  autolayer(GFD_ARIMA_forecast$mean, series = "Forecast")

accuracy(GFD_ARIMA_forecast,GFD_ts_test)

################# Time Series Decomposition ##################

GFD_X11 <- seas(GFD_ts_train, x11="")

autoplot(GFD_X11)

GFD_STL <- stl(GFD_ts_train, s.window = 9, t.window = 9)

autoplot(GFD_STL)+
  ggtitle("4 Station STL Time Series Decomposition")

GFD_STL_fcrw <- forecast(GFD_STL, method = "rwdrift", h=48)

autoplot(GFD_ts_station)+
  ggtitle("Station 4 Monthly Call Volume w/Decomp Forecasts")+
  ylab("Calls per Month")+xlab("Year")+
  autolayer(GFD_STL_fcrw$mean, series = "STL Drift")

accuracy(GFD_STL_fcrw,GFD_ts_test)

#################### Combined Forecasts ###################

## Combine forecasts into single time series

GFD_combined <- ts.intersect(GFD_STL_fcrw$mean, GFD_ARIMA_forecast$mean, GFD_ETS_forecast$mean)

## Convert combined ts into data frame

GFD_combined_df <- data.frame(GFD_combined)
                          
## Create average of forecasts as variable in data frame

GFD_mean <- GFD_combined_df %>%
  mutate(combined = (GFD_STL_fcrw$mean+GFD_ARIMA_forecast$mean+GFD_ETS_forecast$mean)/3)

GFD_mean

## Convert mean dataframe back to time series

GFD_mean_ts <- ts(GFD_mean$combined, start = c(2018,4), frequency = 12)

GFD_mean_ts

accuracy(GFD_mean_ts,GFD_ts_test)

################## Look at sum predictions for 48 month time series

sum(GFD_STL_fcrw$mean)
sum(GFD_ARIMA_forecast$mean)
sum(GFD_ETS_forecast$mean)
sum(GFD_ts_test)
sum(GFD_mean_ts)
sum(GFD_naive$mean)

#################### Dynamic Plot ####################

library(plotly)

st4_plot <- autoplot(GFD_ts_station)+
  ggtitle("Station 4 Monthly Call Volume w/Forecasts")+
  ylab("Calls per Month")+xlab("Year")+
  autolayer(GFD_STL_fcrw$mean, series = "STL")+
  autolayer(GFD_ARIMA_forecast$mean, series = "ARIMA")+
  autolayer(GFD_ETS_forecast$mean, series = "ETS")+
  autolayer(GFD_mean_ts, series = "Combined")

ggplotly(st4_plot)

################ *** Finish Loop *** ###################
