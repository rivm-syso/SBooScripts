#This script initialises a standard test (global) environment

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data") #by default Substance = "default substance"

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

World$filterStates <- list(SpeciesName = "Molecular")

# To proceed with testing we set
if (is.na(World$fetchData("kdis"))) {
  warning("kdis is missing, setting kdis = 1e-20")
  World$SetConst(kdis = 0)
}

# To proceed with testing we set pKa
if (is.na(World$fetchData("pKa"))) {
  warning("pKa is needed but missing, setting pKa=7")
  World$SetConst(pKa = 7)
}

# if substance is set; pKa and other substance properties will be set according the table, see
#sWorld$substance <- "(4-Chloro-2-methylphenoxy)acetic acid compd. with N-Methylmethanamine (1:1)"
World$fetchData("pKa")

if (World$fetchData("ChemClass")==("")) {
  warning("ChemClass is needed but missing, setting to neutral")
  World$SetConst(ChemClass = "neutral")
}
World$SetConst(DragMethod = "Original")
AllF <- ls() %>% sapply(FUN = get)
ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

World$SetConst(Test = "FALSE") 

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
