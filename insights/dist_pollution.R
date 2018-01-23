## The PURPOSE of this file is twofold
# 1- Analyze the relation of two things: 
#     i) Distance from measuring stations (MS) to green/black spots (i.e.: parks vs. big roads)
#     ii) Error when predicting the NO2 levels at those measuring stations
# 
# 2- Checking why the prediction errors are different in jjgarau's and mpsanchis' codes
#
#
## The CONCLUSIONS of this study are:
# 1- There is no correlation between the variables
#
# 2- jjgarau used relative error and mpsanchis used absolute error
# The MS of Eixample detected a lot of NO2 levels, so even though the relative error was small, the absolute error was large

# FIRST PART OF THE FILE ------------------
# Remove files
rm(list = ls())
dist <- read.csv('dist.csv')
dist <- data.table(dist)
names(dist)[2]<-"Station"

dist[,mdgreen:=pmin(d_sea, d_monjuic, d_tibidabo)] # add column with min dist to green spot
dist[,mdblack:=pmin(d_diagonal,d_plcat,d_rondaD,d_rondaB,d_airport)] # add col with min dist to black spot

fd <- data.table(read.csv('clean_data.csv'))

aux_mdgreen <- vector(mode="logical",length(fd$Station))
aux_mdblack <- vector(mode="logical",length(fd$Station))
for(i in 1:length(fd$Station)) {
  if(i%%1000 == 0) {
    print(paste0('it ',i))
  }
  sttn <- fd$Station[i]
  aux_mdgreen[i] <- dist[dist$Station == sttn]$mdgreen
  aux_mdblack[i] <- dist[dist$Station == sttn]$mdblack
}
# Adding distance to green+black spots in "big" dataset
fd$mdgreen <- aux_mdgreen
fd$mdblack <- aux_mdblack
write.csv(fd, "with_dist.csv", row.names = FALSE) # first version saved

# Compare distance to green spot vs. MSE day before
sttns <- levels(fd$Station)

# Add columns with error value (err = pred_val - actual_val)
fd$ConcentrationModPrev <- fd$ConcentrationModPrev - fd$ConcentrationObs
setnames(fd, 'ConcentrationModPrev', 'ErrorPrev')
fd$ConcentrationModSame <- fd$ConcentrationModSame - fd$ConcentrationObs
setnames(fd, 'ConcentrationModSame', 'ErrorSame')

errors_sttns <- vector(mode = "logical", length = 7)
for(i in 1:7) {
  sttn <- sttns[i]
  print(sttn)
  errors_sttn <- fd[fd$Station == sttn,]$ErrorPrev
  errors_sttns[i] <- sum(errors_sttn^2, na.rm = T)/length(errors_sttn[!is.na(errors_sttn)]) 
}
dist_green <- dist$mdgreen
dist_black <- dist$mdblack
plot(dist_green, errors_sttns) # XY plot
plot(dist_black, errors_sttns)
# Binary: green (1) vs black (0)
gorb <- c(0,0,0,0,1,1,1)
plot(gorb, errors_sttns)

# 2nd PART OF CODE: CHECK WHY ERRORS DIFFER --------------
#
# This part of the code was created because we found out we had different "error plots"
#
# CONCLUSION: one part of the code used absolute error (Predicted - Observed) and other part
# used relative error ( (Predicted - Observed)/Observed ).
#
# We agreed that the 2nd measure was better, as it took into account the NO2 amount, which varies
# significantly from one neighborhood of Barcelona to another.

# error in "Eixample" (we choose this station as it differed significantly)
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
data$ConcentrationModPrev <- data$ConcentrationModPrev - data$ConcentrationObs
setnames(data, 'ConcentrationModPrev', 'ErrorPrev')
data$ConcentrationModSame <- data$ConcentrationModSame - data$ConcentrationObs
setnames(data, 'ConcentrationModSame', 'ErrorSame')
data <- data[substring(data$DateBegin,1,4)!="2015"]

sttns <- unique(data$Station)
errors_sttns <- vector(mode = "logical", length = 7) # mean abs error in each of the stations
for(i in 1:7) {
  sttn <- sttns[i]
  print(sttn)
  errors_sttn <- data[data$Station == sttn,]$ErrorPrev
  errors_sttns[i] <- mean(abs(errors_sttn), na.rm = T)
}
barplot(errors_sttns, names.arg = sttns) # Eix, Gra, Ciut: highest abs error in average

errors_sttns_N <- vector(mode = "logical", length = 7) # mean abs error (normalized) in each of the stations
for(i in 1:7) {
  sttn <- sttns[i]
  print(sttn)
  errors_sttn_N <- data[data$Station == sttn,]$ErrorPrev / data[data$Station == sttn,]$ConcentrationObs
  errors_sttns_N[i] <- mean(abs(errors_sttn_N), na.rm = T)
}
barplot(errors_sttns_N, names.arg = sttns) # Ciu, VH, PN, Sants are highest

poll_sttns <- vector(mode = "logical", length = 7) # mean pollution value in each of the stations
for(i in 1:7) {
  sttn <- sttns[i]
  print(sttn)
  polls_sttn <- data[data$Station == sttn,]$ConcentrationObs
  poll_sttns[i] <- mean(polls_sttn, na.rm = T)
}
barplot(poll_sttns, names.arg = sttns) # Eix, Gra, Pob: highest conc. in average