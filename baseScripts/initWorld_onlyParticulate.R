#This script initialises a standard 'World' environment for nano-particles

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#to run the script with another selection of substance / excel reference, #
#set the variables substance and excelReference before sourcing this script, like substance = "nAg_10nm"
if (!exists("substance")) {
  substance <- "nAg_10nm"
}

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data", substance)

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

# We are interested in the particulate species only, so no need to filter like in the Molecular initWorld

# To proceed with testing we set

if (is.na(World$fetchData("pKa"))) {
  warning("pKa is needed but missing, setting pKa=7")
  World$SetConst(pKa = 7)
}

if (World$fetchData("ChemClass")==("")) {
  warning("ChemClass is needed but missing, setting to particle")
  World$SetConst(ChemClass = "particle") #????
}

AllF <- ls() %>% sapply(FUN = get)
ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

#call the particulate processes 
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
ParProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Particulate)]
sapply(paste("k", ParProcesses, sep = "_"), World$NewProcess)

#add all flows, they are all part of "Advection"
FluxDefFunctions <- names(AllF) %>% startsWith("x_")
sapply(names(AllF)[FluxDefFunctions], World$NewFlow)

#derive needed variables
World$VarsFromprocesses()

#World$PostponeVarProcess(VarFunctions = "OtherkAir", ProcesFunctions = "k_Deposition")

# World$UpdateKaas()
# World$UpdateKaas()(debugAt = list())

#for solving, as an example 
#emissions <- data.frame(Abbr = "aRU", Emis = 1000)
# World$NewSolver("SB1Solve")
# World$Solve(emissions)
# World$states$sortFactors(World$fetchData("EqMass"))
