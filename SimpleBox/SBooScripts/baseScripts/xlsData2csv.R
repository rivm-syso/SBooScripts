# script to convert an M-like xlsx-file with 
# all the "landscape" data, chemical and physical data and 
# process "flow" data into csv files, for git storage mainly
# to see changes the best, it's very convenient if all are sorted consistently

#just to import function 
#source("../SBoo/R/fGeneral.R")

# the sheets to import
Defs = c(
  "ScaleSubCompartData",
  "ScaleSpeciesData",
  "SubCompartSpeciesData",
  "ScaleSheet",
  "SubCompartSheet",
  "SpeciesSheet",
  "ScaleProcesses",
  "SubCompartProcesses",
  "SpeciesProcesses",
  "Compartments",
  "Substances",
  "SpeciesCompartments",
  "SubstanceCompartments",
  "SubstanceSubCompartSpeciesData",
  "CONSTANTS",
  "SomeFromTo"
)

#read them into a list of d.f
MlikeWorkBook <- lapply(Defs, function (TheSheet) {
  openxlsx::read.xlsx(xlsxFile = "data/ooMs.xlsx",
                      sheet = TheSheet,
                      startRow = 3) #two lines were for comments
})
names(MlikeWorkBook) <- Defs

#the ordering and writing to csv is in a separate script (multiple usage)
source("baseScripts/ordWrite2csv.R")
