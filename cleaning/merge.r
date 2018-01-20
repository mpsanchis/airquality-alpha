# WORKING DIRECTORY ----------------------------------
setwd("~/Documents/R/airquality-alpha")

# LOAD PACKAGES --------------------------------------
library(data.table)

# LOAD DATA ------------------------------------------
obs_data = data.table(read.csv('data/obs_data.csv', stringsAsFactors = F))
mod_data = data.table(read.csv('data/mod_data.csv', stringsAsFactors = F))
stations = data.table(read.csv('data/stations.csv', stringsAsFactors = F))

# MERGE DATA
mod_data = merge(mod_data, stations[,.(code, lat, lon, height)], by=c('lat','lon'), all.x=T)
obs_data[, DateBegin := sapply(DatetimeBegin, function(x){return(unlist(strsplit(x,' '))[1])})]
obs_data[, TimeBegin := sapply(DatetimeBegin, function(x){return(unlist(strsplit(x,' '))[2])})]
obs_data[, DateEnd := sapply(DatetimeEnd, function(x){return(unlist(strsplit(x,' '))[1])})]
obs_data[, TimeEnd := sapply(DatetimeEnd, function(x){return(unlist(strsplit(x,' '))[2])})]

setnames(obs_data, 'Concentration', 'ConcentrationObs')

mod_data[,AirPollutant := NULL]

data = merge(obs_data, mod_data, by.x=c('AirQualityStationEoICode','DateBegin','TimeBegin'), by.y=c('code','day','hour'), all.y=T)

data[,`:=`(lat=NULL,lon=NULL,height=NULL)]
data = merge(data, stations[,.(code,lat,lon,height)], by.x='AirQualityStationEoICode', by.y='code', all.x=T)

write.csv(data, 'data/full_data.csv', row.names = F)





