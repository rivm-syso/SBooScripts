# ReorderCSV.R
# Keep the csv files with data ordered consistently
# thereby good traceable with clear changes visible in git

# first, read the list of the tables and their keys
DefKeys <- read.csv("data/Defs.csv")
#obtain (unique) Defs in this!! order
DefDups <- duplicated(DefKeys$Defs)
Defs <- DefKeys$Defs[!DefDups]

#read all the data from existing csv's
MlikeWorkBook <- lapply(Defs, function(tableName) {
  assign(tableName, read.csv(
    paste("data/", tableName, ".csv", sep = "")))
})
names(MlikeWorkBook) <- Defs

#the ordering and writing to csv is in a separate script (multiple usage)
source("baseScripts/ordWrite2csv.R")

