# WORKING DIRECTORY ----------------------------------
setwd("~/Documents/R/airquality-alpha")

# LOAD PACKAGES --------------------------------------
library(data.table)
library(lubridate)

# LOAD DATA ------------------------------------------
clean_data = data.table(read.csv('data/clean_data.csv', stringsAsFactors = F))
dist = data.table(read.csv('data/dist.csv', stringsAsFactors = F))
holidays = data.table(read.csv('data/holidays.csv', stringsAsFactors = F))

# CLEAN DATA -----------------------------------------
dist[,`:=`(Lat=NULL,Long=NULL)]

# ENRICHMENT -----------------------------------------
data = merge(clean_data, dist, by='Station', all.x=T)
data[Station == 'ES0691A', Station:='Poblenou']
data[Station == 'ES1396A', Station:='Sants']
data[Station == 'ES1438A', Station:='Eixample']
data[Station == 'ES1480A', Station:='Gracia']
data[Station == 'ES1679A', Station:='Ciutadella']
data[Station == 'ES1856A', Station:='Vall Hebron']
data[Station == 'ES1992A', Station:='Palau Reial']

data[,weekday := weekdays(as.Date(DateBegin))]
data[,is_weekend := ifelse(weekday %in% c('sábado','domingo'), 1, 0)]
data[,weekday:=NULL]
data[,is_holiday := ifelse(DateBegin %in% holidays$Day, 1, 0)]
data[Station %in% c('Poblenou','Sants','Palau Reial'),
     daily_low_pred:=ifelse(TimeBegin %in% c('07:00:00','08:00:00','09:00:00','10:00:00','11:00:00','12:00:00','13:00:00','14:00:00','15:00:00'),1,0)]
data[Station == 'Eixample',daily_low_pred:=ifelse(TimeBegin %in% c('09:00:00','10:00:00','11:00:00','12:00:00','13:00:00','14:00:00','15:00:00'),1,0)]
data[Station == 'Gracia',daily_low_pred:=ifelse(TimeBegin %in% c('07:00:00','08:00:00','09:00:00','10:00:00','11:00:00','12:00:00','13:00:00','14:00:00','15:00:00','16:00:00'),1,0)]
data[Station == 'Ciutadella',daily_low_pred:=ifelse(TimeBegin %in% c('05:00:00','06:00:00','07:00:00','08:00:00','09:00:00','10:00:00','11:00:00'),1,0)]
data[Station == 'Vall Hebron',daily_low_pred:=ifelse(TimeBegin %in% c('05:00:00','06:00:00','07:00:00','08:00:00','09:00:00','10:00:00','11:00:00','12:00:00','13:00:00','14:00:00'),1,0)]

data[,month:=month(as.Date(DateBegin))]
data[Station=='Poblenou',yearly_low_pred:=ifelse(month>=4&month<=8,1,0)]
data[Station=='Sants',yearly_low_pred:=ifelse(month>=4&month<=10,1,0)]
data[Station=='Eixample',yearly_low_pred:=ifelse(month>=5&month<=8,1,0)]
data[Station=='Gracia',yearly_low_pred:=ifelse(month>=5&month<=6,1,0)]
data[Station=='Ciutadella',yearly_low_pred:=ifelse(month>=3&month<=9,1,0)]
data[Station=='Vall Hebron',yearly_low_pred:=ifelse(month>=4&month<=9,1,0)]
data[Station=='Palau Reial',yearly_low_pred:=0]
data[,month:=NULL]


# SAVE CSV -------------------------------------------
write.csv(data, 'data/enriched_data.csv', row.names = F)
