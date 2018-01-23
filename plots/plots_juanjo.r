## MULTIPLE PLOTS TO GET A GENERAL IDEA OF HOW NO2 CONCENTRATION LEVELS VARY IN BARCELONA
#
# Variables: prediction error, error variation, NO2 concentration
# Evolution: hourly, weekly and monthly

# WORKING DIRECTORY ----------------------------------
setwd("~/Documentos/airquality-alpha")

# LOAD PACKAGES --------------------------------------
library(ggplot2)
library(ggvis)
library(lubridate)
library(dplyr)
library(data.table)

# LOAD DATA ------------------------------------------
data = data.table(read.csv('data/enriched_data.csv', stringsAsFactors = F))
data[,DateBegin := as.Date(DateBegin)]
data[,diff_cocms:=(ConcentrationModSame-ConcentrationObs)/ConcentrationObs]
data[,diff_cocmp:=(ConcentrationModPrev-ConcentrationObs)/ConcentrationObs]
data[,diff_cmpcms:=(ConcentrationModSame-ConcentrationModPrev)/ConcentrationModPrev]
data[diff_cmpcms==Inf, diff_cmpcms:=NA]
data[Station == 'ES0691A', Station:='Poblenou']
data[Station == 'ES1396A', Station:='Sants']
data[Station == 'ES1438A', Station:='Eixample']
data[Station == 'ES1480A', Station:='Gracia']
data[Station == 'ES1679A', Station:='Ciutadella']
data[Station == 'ES1856A', Station:='Vall Hebron']
data[Station == 'ES1992A', Station:='Palau Reial']

# PLOTS ----------------------------------------------

# Random day plot
aux = data[DatetimeBegin < as.Date('2013-03-02 00:00:00') & DatetimeBegin >= as.Date('2013-03-01 00:00:00')]
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~ConcentrationObs, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~ConcentrationModPrev, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~ConcentrationModSame, stroke=~Station) %>% layer_lines()

# By hours
aux = data[,.(co=mean(ConcentrationObs,na.rm=T),cmp=mean(ConcentrationModPrev,na.rm=T),
               cms=mean(ConcentrationModSame,na.rm=T),diff_cocms=mean(diff_cocms,na.rm=T),
              diff_cocmp=mean(diff_cocmp,na.rm=T),diff_cmpcms=mean(diff_cmpcms,na.rm=T)),by=.(Station, TimeBegin)]
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~co, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~cmp, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~cms, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~diff_cocmp, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~diff_cocms, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~TimeBegin, ~diff_cmpcms, stroke=~Station) %>% layer_lines()

# By weekdays
data[,weekday:=weekdays(DateBegin)]
aux = data[,.(co=mean(ConcentrationObs,na.rm=T),cmp=mean(ConcentrationModPrev,na.rm=T),
              cms=mean(ConcentrationModSame,na.rm=T),diff_cocms=mean(diff_cocms,na.rm=T),
              diff_cocmp=mean(diff_cocmp,na.rm=T),diff_cmpcms=mean(diff_cmpcms,na.rm=T)),by=.(Station, weekday)]
week_days = c('lunes','martes','miércoles','jueves','viernes','sábado','domingo')
aux = aux[!is.na(weekday)]
aux[,weekday:=sapply(weekday, function(x){return(which(week_days == x))})]
aux %>% group_by(Station) %>% ggvis(~weekday, ~co, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~weekday, ~cmp, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~weekday, ~cms, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~weekday, ~diff_cocmp, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~weekday, ~diff_cocms, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~weekday, ~diff_cmpcms, stroke=~Station) %>% layer_lines()

# By months
data[,month := month(DateBegin)]
aux = data[,.(co=mean(ConcentrationObs,na.rm=T),cmp=mean(ConcentrationModPrev,na.rm=T),
              cms=mean(ConcentrationModSame,na.rm=T),diff_cocms=mean(diff_cocms,na.rm=T),
              diff_cocmp=mean(diff_cocmp,na.rm=T),diff_cmpcms=mean(diff_cmpcms,na.rm=T)),by=.(Station, month)]
aux = aux[!is.na(month)]
aux %>% group_by(Station) %>% ggvis(~month, ~co, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~month, ~cmp, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~month, ~cms, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~month, ~diff_cocmp, stroke=~Station) %>% layer_lines()

aux %>% group_by(Station) %>% ggvis(~month, ~diff_cocms, stroke=~Station) %>% layer_lines()
aux %>% group_by(Station) %>% ggvis(~month, ~diff_cmpcms, stroke=~Station) %>% layer_lines()



