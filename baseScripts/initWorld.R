#This script initialises a standard test (global) environment

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#to run the script with another selection of substance / excel reference,
#set the variables substance and excelReference before sourcing this script
if (!exists("substance")) {
  substance <- "default substance"
}

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data", substance)

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

#We can calculate variables and fluxes availeable (fakeLib provided the functions:)
Vfiles <- Rfiles[startsWith(Rfiles, prefix = "v_")]
#all steps to calculate Area's etc:
lapply(c("AreaSea", "AreaLand", "Area", "Volume"), function(FuName){
  World$NewCalcVariable(FuName)
  World$CalcVar(FuName)
})


#To compare results / search for algorithms/data
ClassicExcel <- ClassicNanoProcess$new(TheCore = World, filename = excelReference)
#apply and replace current kaas by setting mergeExisting to False (Default is True):
World$UpdateKaas(ClassicExcel)
