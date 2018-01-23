# Adds a binary feature which indicates to the model if the error of prediction is "too bad"
# error = (prediction_day_before - observation)/observation
# too bad <==> error > 1.5
#
# NOTE: this feature did not seem to improve the accuracy of the model, despite the fact that about 11% of the (total) rows
# were positive in this analysis. This should be analyzed by the CALIPSO team.
#
# NOTE: the error prediction could be too bad because of two reasons: either because of the Levels Observed themselves (i.e: the
# NO2 detector stops working and the numbers given are unusual) or because of the Levels Predicted (i.e.: the CALIPSO predictions
# for some reasons give a "weird" number). T
 
# Add "weird_measurement" to rows --------------
data = data.table(read.csv('data/enriched_data.csv', stringsAsFactors = F))
data[,DateBegin := as.Date(DateBegin)]
data[,diff_cocmp:=abs((ConcentrationModPrev-ConcentrationObs)/ConcentrationObs)]
data[year(as.Date(DateBegin)) <= 2014, weird_meas:=as.integer(diff_cocmp > 1.5)]
data$diff_cocmp <- NULL
write.csv(data,file = "enriched_data_wm.csv",row.names = F)
