#This script initialises a standard test (global) environment

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#to run the script with another selection of substance / excel reference,
#set the variables substance and excelReference before sourcing this script
if (!exists("substance")) {
  substance <- "default substance"
}
if (!exists("excelReference")) {
  excelReference <- "data/SimpleBox4.01_20211028.xlsm"
}

#updated by reading data as csv files 
#to debug with R6 use first: ClassicNanoWorld$debug("new")
NewstateModule <- ClassicNanoWorld$new("data", substance)

#with this data we create an instance of the central "core" object,
#In case you need to debug, do it before the instantiation by new(), like so:
#SBcore$debug("kaas") #the actual debug is further below
World <- SBcore$new(NewstateModule)

#We can calculate variables and fluxes availeable (fakeLib provided the functions:)
Vfiles <- Rfiles[startsWith(Rfiles, prefix = "v_")]
#all steps to calculate Area's etc:
lapply(c("AreaSea", "AreaLand", "Area", "Volume"), function(FuName){
  World$NewCalcVariable(FuName)
  World$CalcVar(FuName)
})


#To compare results / search for algorithms/data
if (excelReference != "") {
  if (!file.exists(excelReference)){
    stop(paste("file does not exist:", excelReference))
  }
  ClassicExcel <- ClassicNanoProcess$new(TheCore = World, filename = excelReference)
  #apply and replace current kaas by setting mergeExisting to False (Default is True):
  World$UpdateKaas(ClassicExcel)
}
