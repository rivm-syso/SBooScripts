#This script initialises a standard test (global) environment

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data")

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

# We are interested in the Molecular species only; No longer supported 
# World$filterStates(SpeciesName = "Molecular")
# use PROPERTY World$filterStates, like below

World$SetConst(DragMethod = "Original")

#temporarily, i hope?
World$SetConst(Test = FALSE)

World$filterStates = list(SpeciesName = "Molecular")
#test World$filterStatesFrame(World$states$asDataFrame)

#Which are Molecular? Create those as module NB the k_ is missing in the processlist
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
MolProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Molecular)]
sapply(paste("k", MolProcesses, sep = "_"), World$NewProcess)

#add all flows, they are all part of "Advection"
FluxDefFunctions <- ls(pattern = "x_")
sapply(FluxDefFunctions, World$NewFlow)

#derive needed variables
World$VarsFromprocesses()

World$PostponeVarProcess(VarFunctions = "OtherkAir", ProcesFunctions = "k_Deposition")

# No longer part of init...
# World$UpdateKaas()

#for solving, as an example 
# emissions <- data.frame(Abbr = "aRU", Emis = 1000)
# 
# World$NewSolver("SB1Solve")
# World$Solve(emissions)
# World$states$sortFactors(World$fetchData("EqMass"))
