#This script initialises a standard test (global) environment

#script to faking the future library(SBoo)
source("baseScripts/fakeLib.R")

#to run the script with another selection of substance / excel reference,
#set the variables substance and excelReference before sourcing this script, like substance = "nAg_10nm"
if (!exists("substance")) {
  substance <- "default substance"
}

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data", substance)

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

# We are interested in the Molecular species only
World$filterStates(SpeciesName = "Molecular")

# To proceed with testing we set
# World$SetConst(pKa = 2500)
if (is.na(World$fetchData("pKa"))) {
  stop("pKa is needed but missing")
}

#TODO put Ksw in th substance data
# 
# World$SetConst(Ksw = 47500)
# if (is.na(World$fetchData("Ksw"))) {
#   warning("Ksw is needed but missing; set by f_Ksw()")
#   AllRho <- World$fetchData("rhoMatrix")
#   RHOsolid = AllRho$rhoMatrix[AllRho$SubCompart == "othersoil"]
#   Ksw = f_Ksw(Kow = World$fetchData("Kow"),
#               pKa = World$fetchData("pKa"),
#               CorgStandard = World$fetchData("CorgStandard"),
#               a = World$fetchData("a"),
#               b = World$fetchData("b"),
#               ChemClass = World$fetchData("ChemClass"),
#               RHOsolid = RHOsolid,
#               alt_form = F,
#               Ksw_orig = NA
#   )
#   World$SetConst(Ksw = Ksw)
#   
# }

AllF <- ls() %>% sapply(FUN = get)
ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

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

#verbose = T

#kex = World$NewCalcVariable("rad_species")
#kex$execute(debugAt = list(SubCompartName = "air"))
verbose = T
World$UpdateKaas()

# emissions <- data.frame(Abbr = "aRU", Emis = 1000)
# 
# World$NewSolver("SB1Solve")
# World$Solve(emissions)
# #World$states$sortFactors(emissions)
# 
# World$states$sortFactors(World$fetchData("EqMass"))
