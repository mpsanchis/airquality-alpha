### PLOTTING: Evolution of NO2 levels ###
# 
# (average NO2 level for each month, in the whole city of Barcelona)

# 0 - Load data and define an auxiliary function
rm(list = ls())
df <- read.csv('clean_data.csv')
df <- df[c('DateBegin','ConcentrationObs')] #keep only date and observed NO2  

removeday <- function(fecha){ 
  # from a string "date" (yyyy-mm-dd) keeps yy-mm, assuming that all yyyy = 20yy
  return( substr(fecha,3,7) ) 
}

# 1 - Remove day from time stamp
df$DateBegin <- apply(data.frame(df$DateBegin),1,removeday) 

# 2- X Axis: all different months yy-mm (13-01, 13-02,..., 15-11, 15-12)
x_vals <- unique(df$DateBegin)
print(x_vals)

# 3- Y Axis: average concentration for each month
y_vals <- vector(mode = "numeric", length = length(x_vals))
for(i in 1:length(x_vals)) {
  month_chosen <- x_vals[i]
  y_vals[i] <- mean( df[df$DateBegin == month_chosen,]$ConcentrationObs )
}

# 4- Plotting X vs. Y
dataplot <- data.frame(x_vals,y_vals)
pl <- ggplot(dataplot, aes(x_vals,y_vals))
pl+geom_bar(stat = "identity")
