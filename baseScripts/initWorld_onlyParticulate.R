#This script initialises a standard 'World' environment for nano-particles

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#to run the script with another selection of substance / excel reference, #
#set the variables substance and excelReference before sourcing this script, like substance = "nAg_10nm"
#   no longer needed
#if (!exists("substance")) {
#  substance <- "nAg_10nm"
#}
#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data")

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

# To proceed with testing we set

World$substance <- "nAg_10nm"
if (is.na(World$fetchData("pKa"))) {
  warning("pKa is needed but missing, setting pKa=7")
  World$SetConst(pKa = 7)
}

if (World$fetchData("ChemClass")==("")) {
  warning("ChemClass is needed but missing, setting to particle")
  World$SetConst(ChemClass = "particle") #????
}

if (is.na(World$fetchData("Pvap25"))) {
  warning("Pvap is missing but not used, setting constant")
  World$SetConst(Pvap25 = 1e-7)
}
World$SetConst(DragMethod = "Original")

#call the particulate processes 
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
ParProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Particulate)]
sapply(paste("k", ParProcesses, sep = "_"), World$NewProcess)

#add all flows, they are all part of "Advection"
FluxDefFunctions <- ls(pattern = "x_")
sapply(FluxDefFunctions, World$NewFlow)
World$SetConst(Test = "TRUE")
#derive needed variables
World$VarsFromprocesses()

World$SetConst(Ksw = 47500) #default, not used for particle behavior

#World$PostponeVarProcess(VarFunctions = "OtherkAir", ProcesFunctions = "k_Deposition")

# Not now World$UpdateKaas()
