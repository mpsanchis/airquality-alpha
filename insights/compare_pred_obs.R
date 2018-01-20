# THIS SCRIPT PLOTS TWO THINGS:
# 1- MSE HISTOGRAM: day before and current day predictions
# 2- MSE EVOLUTION HOUR BY HOUR: day b4 and current day too

# GLOBAL ANALYSIS: ALL ERRORS -------------------------

# Remove files
rm(list = ls())

df <- read.csv('clean_data.csv')
df = data.table(df)

# Remove useless columns for this analysis
df$DatetimeBegin <- NULL
df$lat <- NULL
df$lon <- NULL

# Add columns with error value (err = pred_val - actual_val)
df$ConcentrationModPrev <- df$ConcentrationModPrev - df$ConcentrationObs
setnames(df, 'ConcentrationModPrev', 'ErrorPrev')
df$ConcentrationModSame <- df$ConcentrationModSame - df$ConcentrationObs
setnames(df, 'ConcentrationModSame', 'ErrorSame')

ErrPrev <- df$ErrorPrev
ErrSame <- df$ErrorSame

# Overlapping histograms:
hist(ErrPrev, breaks = 30, col=rgb(1,0,0,0.5),xlim=c(-150,150), ylim=c(0,50000), main="Overlapping Histogram", xlab="Error")
hist(ErrSame, breaks=30, col=rgb(0,0,1,0.5), add=T)
box()
# insight: prev. day under-predicts a little more than same day (based on graph)
sum(ErrSame^2,na.rm=T)/length(ErrSame[!is.na(ErrSame)]) # 894.9095
sum(ErrPrev^2,na.rm=T)/length(ErrPrev[!is.na(ErrPrev)]) # 883.3263
# insight: MSE the same day is worse than MSE the day before

# CALCULATE MSE AS A FUNCT. OF TIME OF THE DAY --------------------------------
x_val <- 0:23 # represents the hours of the day
mse_prev <- vector(mode = "numeric", length = 24) # mse at that time of the day
mse_same <- vector(mode = "numeric", length = 24)

for(i in x_val){
  errors_prev <- df[as.numeric(substring(df$TimeBegin,1,2)) == i]$ErrorPrev
  errors_same <- df[as.numeric(substring(df$TimeBegin,1,2)) == i]$ErrorSame
  errors_prev[is.nan(errors_prev)] = NA
  errors_same[is.nan(errors_same)] = NA
  mse_prev[i+1] <- sum(errors_prev^2, na.rm = T)/length(errors_prev[!is.na(errors_prev)]) # vectors begin at 1
  mse_same[i+1] <- sum(errors_same^2, na.rm = T)/length(errors_same[!is.na(errors_same)])
}

err_both <- rbind(mse_prev, mse_same)
mp <- barplot(err_both, beside = TRUE, names.arg = 0:23)


