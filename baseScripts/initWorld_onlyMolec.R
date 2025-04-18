#This script initialises a standard test (global) environment

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new(MlikeFile = "data", Substance = substance) #by default Substance = "default substance"

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

World$filterStates <- list(SpeciesName = "Molecular")

# To proceed with testing we set
if (is.na(World$fetchData("kdis"))) {
  warning("kdis is missing, setting kdis = 0")
  World$SetConst(kdis = 0)
}

if (World$fetchData("ChemClass")==("")) {
  warning("ChemClass is needed but missing, setting to neutral")
  World$SetConst(ChemClass = "neutral")
}

World$SetConst(DragMethod = "Original")
AllF <- ls() %>% sapply(FUN = get)
ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

# to set verification test at initialisation for proper k update.
if(!exists("VerificationSBoo")){
  World$SetConst(Test = "FALSE")
} else ifelse(VerificationSBoo == TRUE, World$SetConst(Test = "TRUE") , World$SetConst(Test = "FALSE"))

#Which are Molecular? Create those as module NB the k_ is missing in the processlist
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
MolProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Molecular)]
sapply(paste("k", MolProcesses, sep = "_"), World$NewProcess)

#add all flows, they are all part of "Advection"
FluxDefFunctions <- names(AllF) %>% startsWith("x_")
sapply(names(AllF)[FluxDefFunctions], World$NewFlow)

#derive needed variables
World$VarsFromprocesses()

World$PostponeVarProcess(VarFunctions = "OtherkAir", ProcesFunctions = "k_Deposition")

World$UpdateKaas()

# for solving, as an example
# emissions <- data.frame(Abbr = "aRU", Emis = 1000)
# 
# World$NewSolver("SB1Solve")
# World$Solve(emissions)
# World$states$sortFactors(World$fetchData("EqMass"))
