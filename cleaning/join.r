# FUNCTION: this code joined all the data from multiple files to just two files ('obs_data.csv' and 'mod_data.csv')
#
# ORIGINAL FILES: one file per day. Two types of data: observed (obs) and predicted (mod)

# SET WORKING DIRECTORY ------------------------------
setwd("~/Documents/R/airquality-alpha")

# LOAD PACKAGES --------------------------------------
library(data.table)

# LOAD DATA ------------------------------------------
header_obs = data.table(read.csv("data/headers_obs.csv", sep="", stringsAsFactors=FALSE))
header_mod = data.table(read.delim("data/headers_mod.csv", stringsAsFactors=FALSE))

mod_files = list.files('data/mod', recursive=T)
obs_files = list.files('data/obs', recursive=T)

obs_data = copy(header_obs)
mod_data = copy(header_mod)

# MERGE OBS DATA --------------------------------------
for (i in 1:length(obs_files)){
  data = data.table(read.delim(paste0('data/obs/',obs_files[i]), header = F, stringsAsFactors = F))
  names(data) = names(header_obs)
  obs_data = rbind(obs_data, data)
}

# MERGE MOD DATA --------------------------------------
for (i in 1:length(mod_files)){
  data = data.table(read.table(paste0('data/mod/',mod_files[i]), quote="\"", comment.char="", stringsAsFactors=FALSE))
  names(data) = names(header_mod)
  if (i == 1){
    mod_data = rbind(mod_data, data)
    first_date = mod_data$day[1]
    mod_data[,DayType := ifelse(day==first_date,'ConcentrationModSame','ConcentrationModPrev')] # two predictions: same day & previous day
  } else {
    first_date = data$day[1]
    data[,DayType := ifelse(day==first_date,'ConcentrationModSame','ConcentrationModPrev')]
    mod_data = rbind(mod_data, data)
  }
}

mod_data = dcast(mod_data, lon + lat + day + hour + AirPollutant ~ DayType, value.var = 'Concentration')
mod_data = mod_data[,.(AirPollutant=AirPollutant[1],ConcentrationModPrev=sum(ConcentrationModPrev,na.rm=T),
                       ConcentrationModSame=sum(ConcentrationModSame,na.rm=T)),by=.(day,hour,lat,lon)]

# PRINT DATA ------------------------------------------
write.csv(obs_data, 'data/obs_data.csv', row.names=F)
write.csv(mod_data, 'data/mod_data.csv', row.names=F)
