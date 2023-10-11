################### Libraries Used ################

library(tidyverse)
library(forecast)
library(readxl)
library(ggplot2)
library(seasonal)
library(lubridate)
library(plotly)
library(ggthemes)

###################### Intro Data Tasks ################

## Load adjusted monthly response values

GFD_Adjusted <- read_xlsx("GFD_Covid_Adjusted_V2.xlsx")

GFD_Unadjusted <- read_xlsx("GFD_Unadjusted.xlsx")

## Set variable for automation

i <- c(2:21)

## Iterate for each station

for(x in i){

GFD_ts <- ts(GFD_Adjusted[,x], start=c(2006,7), end=c(2022,3),freq=12)

GFD_unadj_ts <- ts(GFD_Unadjusted[,x], start=c(2006,7), end=c(2018,3),freq=12)

numb <- colnames(GFD_Adjusted[,x])

########## Station Train/Test Split ##############

## Create train/test split for station

GFD_ts_station <- ts(GFD_ts, start=c(2006,7), end=c(2022,3),freq=12)

GFD_ts_train <- window(GFD_ts_station, end=c(2018,3))
GFD_ts_test <- window(GFD_ts_station, start=c(2018,4), end=c(2022,3))  

################## Benchmark Models ##########################

GFD_naive <- naive(GFD_ts_train, h=48)

GFD_drift <- rwf(GFD_ts_train, drift = TRUE, h=48)

GFD_avg <- meanf(GFD_ts_train, h=48)

################## ETS models ###################

GFD_ETS <- ets(GFD_ts_train, model = "MAM", damped = FALSE)

GFD_ETS_forecast <- forecast(GFD_ETS, h=48)

accuracy(GFD_ETS_forecast, GFD_ts_test)

################ ARIMA models ##################

GFD_ARIMA <- Arima(GFD_ts_train,order=c(0,1,1),seasonal=c(0,1,1))

checkresiduals(GFD_ARIMA)

### Create ARIMA forecasts ###

GFD_ARIMA_forecast <- forecast(GFD_ARIMA, h=48)

################# Time Series Decomposition ##################

GFD_STL <- stl(GFD_ts, s.window = 11)

pstl <- autoplot(GFD_STL)+
        ggtitle(paste(numb, " Station TS Decomposition (STL)", sep = ""))

pstl

p_pstl <- ggplotly(pstl)

htmlwidgets::saveWidget(as_widget(p_pstl), paste(numb, " TS Decomp.html", sep = ""))

ggsave(paste(numb, " TS_Decomp.pdf", sep = ""), width = 11, height = 8.5, units = "in")

#################### Combined Forecasts ###################

## Combine forecasts into single time series

GFD_combined <- ts.intersect(GFD_ARIMA_forecast$mean, GFD_ETS_forecast$mean)

## Convert combined ts into data frame

GFD_combined_df <- data.frame(GFD_combined)
                          
## Create average of forecasts as variable in data frame

GFD_mean <- GFD_combined_df %>%
  mutate(combined = (GFD_ARIMA_forecast$mean+GFD_ETS_forecast$mean)/2)

## Convert mean dataframe back to time series

GFD_mean_ts <- ts(GFD_mean$combined, start = c(2018,4), frequency = 12)

################## Accuracy & Sum predictions for 48 month time series #########

nac <- data.frame(accuracy(GFD_naive,GFD_ts_test))
dac <- data.frame(accuracy(GFD_drift,GFD_ts_test))
eac <- data.frame(accuracy(GFD_ETS_forecast,GFD_ts_test))
rac <- data.frame(accuracy(GFD_ARIMA_forecast,GFD_ts_test))
cac <- data.frame(accuracy(GFD_mean_ts,GFD_ts_test))
tac <- data.frame(c(NA,NA))

acc <- data.frame(rbind(nac[,5],dac[,5],eac[,5],rac[,5],cac[,5],tac[,1]))%>%
  rename(Train=X1, Test=X2)

rownames(acc) <- c("Naive","Random Walk","ETS","ARIMA","Combined","Test")

acc["Combined","Train"] <- NA
  
sn <- sum(GFD_naive$mean)
sm <- sum(GFD_drift$mean)
sa <- sum(GFD_ARIMA_forecast$mean)
se <- sum(GFD_ETS_forecast$mean)
st <- sum(GFD_ts_test)
sc <- sum(GFD_mean_ts)

scc <-data.frame(rbind(sn,sm,sa,se,sc,st))%>%
  rename(Sum=rbind.sn..sm..sa..se..sc..st.)

rownames(scc) <- c("Naive","Random Walk","ARIMA","ETS","Combined","Test")

ccc <- cbind.data.frame(acc,scc)%>%
  mutate(Avg=(Sum/4))

print(ccc)

write.csv(GFD_mean_ts,file = paste(numb, "_Forecast.csv", sep = ""))

write.csv(ccc,file = paste(numb, "_Error & Sum.csv", sep = ""))

#################### Dynamic Plot ####################

plot <- autoplot(GFD_ts)+
  ggtitle(paste(numb, " Monthly Call Volume vs 4-Yr Forecasts", sep = ""))+
  ylab("Calls per Month")+xlab("Year")+
  autolayer(GFD_ARIMA_forecast$mean, series = "ARIMA")+
  autolayer(GFD_ETS_forecast$mean, series = "ETS")+
  autolayer(GFD_mean_ts, series = "Combined")

pplot <- ggplotly(plot)

htmlwidgets::saveWidget(as_widget(pplot), paste(numb, " Forecasts.html", sep = ""))

################ *** Finish Test/Train Loop *** ###################

################ *** Start Forecast Loop *** ###################

################## Benchmark Models ##########################

GFD_naive_fc <- naive(GFD_ts_station, h=48)

GFD_drift_fc <- rwf(GFD_ts_station, drift = TRUE, h=48)

GFD_avg_fc <- meanf(GFD_ts_station, h=48)

################## ETS models ###################

GFD_ETS_fc <- ets(GFD_ts_station, model = "MAM", damped = FALSE)

GFD_ETS_forecast_fc <- forecast(GFD_ETS_fc, h=48)

################ ARIMA models ##################

GFD_ARIMA_fc <- Arima(GFD_ts_station,order=c(0,1,1),seasonal=c(0,1,1))

checkresiduals(GFD_ARIMA_fc)

### Create ARIMA forecasts ###

GFD_ARIMA_forecast_fc <- forecast(GFD_ARIMA_fc, h=48)

################# Time Series Decomposition ##################

##GFD_STL_fc <- stl(GFD_ts_station, s.window = 9, t.window = 9)

##GFD_STL_fcrw_fc <- forecast(GFD_STL_fc, method = "rwdrift", h=48)

#################### Combined Forecasts ###################

## Combine forecasts into single time series

GFD_combined_fc <- ts.intersect(GFD_ARIMA_forecast_fc$mean, GFD_ETS_forecast_fc$mean)

## Convert combined ts into data frame

GFD_combined_df_fc <- data.frame(GFD_combined_fc)

## Create average of forecasts as variable in data frame

GFD_mean_fc <- GFD_combined_df %>%
  mutate(combined = (GFD_ARIMA_forecast_fc$mean+GFD_ETS_forecast_fc$mean)/2) 

##

## Convert mean dataframe back to time series

GFD_mean_ts_fc <- ts(GFD_mean_fc$combined, start = c(2022,4), frequency = 12)

GFD_mean_ts_fc

################## Accuracy & Sum predictions for 48 month time series #########

sn_fc <- sum(GFD_naive_fc$mean)
sm_fc <- sum(GFD_drift_fc$mean)
sa_fc <- sum(GFD_ARIMA_forecast_fc$mean)
se_fc <- sum(GFD_ETS_forecast_fc$mean)
sc_fc <- sum(GFD_mean_ts_fc)
st_fc <- c(NA)

scc_fc <-data.frame(rbind(sn_fc,sm_fc,sa_fc,se_fc,sc_fc,st_fc))%>%
  rename(FORECAST_TOTAL=rbind.sn_fc..sm_fc..sa_fc..se_fc..sc_fc..st_fc.)

rownames(scc_fc) <- c("Naive","Random Walk","ETS","ARIMA","Combined","Test")

ccc_fc <- cbind.data.frame(ccc,scc_fc)%>%
  mutate(AVG_FORECAST=(FORECAST_TOTAL/4))

print(ccc_fc)

write.csv(ccc_fc,file = paste(numb, "_Forecast.csv", sep = ""))

#################### Dynamic Plot ####################

pplot_fc <- autoplot(GFD_ts, size = .8)+
  ggtitle(label = paste(numb, " Monthly Call Volume vs 4-Yr Forecasts", sep = ""),subtitle = "Pre-Covid Transform Applied Prior to March 2020")+
  ylab("Calls per Month")+xlab("Year")+
  autolayer(GFD_ARIMA_forecast_fc$mean, series = "ARIMA", size = .8)+
  autolayer(GFD_ETS_forecast_fc$mean, series = "ETS", size = .8)+
  autolayer(GFD_mean_ts_fc, series = "Combined", size = .8)+
  autolayer(GFD_unadj_ts, series = "Unadjusted", size =.8, alpha = 3/10)+
  theme_few()+
  theme(legend.position=c(.2,.9), legend.title = element_blank(), legend.direction = "horizontal")

pplot_fc

p_plot_fc <- ggplotly(pplot_fc)

htmlwidgets::saveWidget(as_widget(p_plot_fc), paste(numb, " Forecasts.html", sep = ""))

ggsave(paste(numb, " Forecasts.pdf", sep = ""), width = 14, height = 8.5, units = "in")

################### *** Finish Forecast Loop *** ######################

}
