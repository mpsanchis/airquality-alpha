### Evolution of NO2 levels ###
rm(list = ls())
df <- read.csv('clean_data.csv')
df <- df[c('DateBegin','ConcentrationObs')] #keep only date and observed NO2  

removeday <- function(fecha){
  return( substr(fecha,3,7) )
}

df$DateBegin <- apply(data.frame(df$DateBegin),1,removeday) # remove day from time stamp

x_vals <- unique(df$DateBegin)
print(x_vals)
y_vals <- vector(mode = "numeric", length = length(x_vals))
for(i in 1:length(x_vals)) {
  month_chosen <- x_vals[i]
  y_vals[i] <- mean( df[df$DateBegin == month_chosen,]$ConcentrationObs )
}

dataplot <- data.frame(x_vals,y_vals)
pl <- ggplot(dataplot, aes(x_vals,y_vals))
pl+geom_bar(stat = "identity")
