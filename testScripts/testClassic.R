#Delete (or change) the next line to use the molecular defaults in init...
substance <- "nAg_10nm"

#To compare results / search for algorithms/data; 
excelReference <- "data/20210331 SimpleBox4nano_rev006.xlsx"
if (excelReference != "") {
  if (!file.exists(excelReference)){
    stop(paste("file does not exist:", excelReference))
  }
  ClassicExcel <- ClassicNanoProcess$new(TheCore = World, filename = excelReference)
}

#initialise a standard test (global) environment:
source("baseScripts/initWorld.R")

#FromKnames <- World$kaas
SModule <- World$NewSolver("SB1Solve", tol=1e-15)
#dfDiff <- SModule$DiffSB.K(OriSB.K)
#dfDiff$fout <- T
#kaas <- ClassicClass$myCore$kaas
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
