# Filter by Station
stations <- c('ES0691A', 'ES1396A', 'ES1438A', 'ES1480A', 'ES1679A', 'ES1856A', 'ES1992A')

for(stt in stations) {
  print(paste0('##### ', stt,' ####'))
  filtered_table <- obs[obs$AirQualityStationEoICode == stt,]
  ndata <- nrow(filtered_table) # number of rows
  
  spr <- filtered_table$SamplingProcess
  ############# SAMPLING PROCESS
  only_one_level <- FALSE
  level <- "aux"
  for(spr_level in levels(spr)) {
    if(sum(spr == spr_level) == ndata) {
      only_one_level <- TRUE
      level <- spr_level
    }
  }
  if(only_one_level) {
    print(paste0('sampling process:',level))
  }
  else {
    print('more than one sampling process')
  }
  spp <- filtered_table$SamplingPoint
  ############## SAMPLING POINT
  only_one_level <- FALSE
  level <- "aux"
  for(spp_level in levels(spp)) {
    if(sum(spp == spp_level) == ndata) {
      only_one_level <- TRUE
      level <- spp_level
    }
  }
  if(only_one_level) {
    print(paste0('sampling point:',level))
  }
  else {
    print('more than one sampling point')
  }
  spl <- filtered_table$Sample
  ############## SAMPLE
  only_one_level <- FALSE
  level <- "aux"
  for(spl_level in levels(spl)) {
    if(sum(spl == spl_level) == ndata) {
      only_one_level <- TRUE
      level <- spl_level
    }
  }
  if(only_one_level) {
    print(paste0('sample:',level))
  }
  else {
    print('more than one sample')
  }
}