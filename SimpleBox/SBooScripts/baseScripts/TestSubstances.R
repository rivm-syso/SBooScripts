#This script runs SB for multiple substances
#This helps testing and comparing versions of SB

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

# The list with substances; The must all be present in the data - see data/Substances.csv
Substances2Run <- c(
  "1-chloro-2-nitrobenzene",
  "1-NONANOL",
  "vinyltoluene",
  "Zn(II)",
  "nAg_10nm"
)

#loop over these substances and store results; to test substance = "1-NONANOL"
for (substance in Substances2Run) {

  NewstateModule <- ClassicNanoWorld$new("data", substance)
  World <- SBcore$new(NewstateModule)
  #load all variables and processes in SBoo
  baseScripts/DefaultVarDefinitions.R
  
}


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
ClassicExcel <- ClassicNanoProcess$new(TheCore = World, filename = excelReference)
#apply and replace current kaas by setting mergeExisting to False (Default is True):
World$UpdateKaas(ClassicExcel)
