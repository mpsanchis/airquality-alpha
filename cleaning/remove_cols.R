setwd("~/Documentos/airquality-alpha")
fd <- read.csv('full_data.csv')

fd$Countrycode <- NULL
fd$Namespace <- NULL
fd$AirQualityNetwork <- NULL
fd$AirQualityStation <- NULL
fd$SamplingPoint <- NULL
fd$SamplingProcess <- NULL
fd$Sample <- NULL
fd$AirPollutant <- NULL
fd$AirPollutantCode <- NULL
fd$AveragingTime <- NULL
fd$UnitOfMeasurement <- NULL
fd$Validity <- NULL
fd$Verification <- NULL
fd$DatetimeEnd <- NULL
fd$DateEnd <- NULL
fd$TimeEnd <- NULL

# Change name of stations col
names(fd)[1] <- "Station"