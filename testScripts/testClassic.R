source("baseScripts/fakeLib.R")

#Delete (or change) the next line to use the molecular defaults in init...
substance <- "nAg_10nm"

#The script creates the "ClassicStateModule" object with the states of the classic 4. excel version. 
ClassicStateModule <- ClassicNanoWorld$new("data", substance)

#with this data we create an instance of the central "core" object,
World <- SBcore$new(ClassicStateModule)

#To compare results / search for algorithms/data; 
excelReference <- "data/20210331 SimpleBox4nano_rev006.xlsx"
if (excelReference != "") {
  if (!file.exists(excelReference)){
    stop(paste("file does not exist:", excelReference))
  }
  ClassicExcel <- ClassicNanoProcess$new(TheCore = World, filename = excelReference)
}

World$UpdateKaas()
ClassicSB.K <- ClassicExcel$ExcelSB.K()

#initialise a standard test (global) environment for nano:
AllF <- ls() %>% sapply(FUN = get)
ProcessDefFunctions <- names(AllF) %>% startsWith("k_")

#Which are Nano? Create those as module NB the k_ is missing in the processlist
Processes4SpeciesTp <- read.csv("data/Processes4SpeciesTp.csv")
NanoProcesses <- Processes4SpeciesTp$Process[grepl("[a-z,A-Z]", Processes4SpeciesTp$Particulate)]
sapply(paste("k", NanoProcesses, sep = "_"), World$NewProcess)

#add all flows, they are all part of "Advection"
FluxDefFunctions <- names(AllF) %>% startsWith("x_")
sapply(names(AllF)[FluxDefFunctions], World$NewFlow)

#derive needed variables
World$VarsFromprocesses()

# calculations
World$UpdateKaas()

#define solver to obtain SB engine Matrix and diff()
SModule <- World$NewSolver("SB1Solve", tol=1e-15)
debugonce(SModule$DiffSB.K)
dfDiff <- SModule$DiffSB.K(ClassicSB.K)

#dfDiff$fout <- T
#dframe2excel(inner_join(x = dfDiff, y = kaas, by = c("from" = "fromAbbr", "to" = "toAbbr")), outxlsx = "diff")
#SModule$PrepKaasM()
#SModule$PrepemisV()
#World$NewSolver("SBsteady", tmax=1e10)
#SolRet <- World$Solve(T)
emissions <- ClassicExcel$ExcelEmissions("current.settings")
SolRet <- World$Solve(emissions)

World$NewSolver("SBsolve")
SolRet <- World$Solve(F)

#calculate resulting mass (store as EqMass) to concentrations
World$fetchData("EqMass")
Concentrations <- function(EqMass, Volume) {
  EqMass / Volume
}
World$NewCalcVariable("Concentrations")
ConcPM <- World$CalcVar("Concentrations")
#ConcPM <- merge(ConcPM, World$fetchData("Matrix"))

EqFluxes <- 
ggplot(data = ConcPM, aes(x = Concentrations)) +
  Some


#apply and replace current kaas by setting mergeExisting to False (Default is True):
World$UpdateKaas(ClassicExcel)
OriSB.K <- ClassicExcel$ExcelSB.K()
