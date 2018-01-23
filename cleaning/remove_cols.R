# FUNCTION: this code deletes the useless columns in "full_data.csv"
fd <- read.csv('data/full_data.csv')

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

fd = data.table(fd)
setnames(fd, 'AirQualityStationEoICode', 'Station') # Rename the column containing the station name
write.csv(fd, 'data/clean_data.csv', row.names = F)
