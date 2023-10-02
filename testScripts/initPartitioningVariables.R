#Script for calculating the variables associated with partitioning
#See vignette for partitioning ("vignettes/partitioning.Rmd")

#Scripts assumes these two actions have already been performed:
          #1. substance has been defined 
          #2. the "World" has been initialised

Kow <- World$fetchData("Kow")
if(is.na(World$fetchData("Kow"))) {
  World$SetConst(Kow = 2750)
  warning("Kow is missing in input data. This is not always provided by default, e.g. for metals. 
Kow is set to 2750, corresponding to the default in the SB4nano excel version. This value is based on the median of all provided Kow of all substances in the excel version")
}

pKa <- World$fetchData("pKa")
if(is.na(pKa)) {
  World$SetConst(pKa = 7) 
  warning("pKa not given in input data. Substance assumed to be neutral (pKa = 7).")
}

CorgStandard <- World$fetchData("CorgStandard")
ChemClass <- World$fetchData("ChemClass")
QSARtable <- World$fetchData("QSARtable")
QSARrecord <- QSARtable[QSARtable$QSAR.ChemClass == ChemClass,]
RhoTable <- World$fetchData("rhoMatrix")
RHOsolid <- RhoTable$rhoMatrix[RhoTable$SubCompart == "naturalsoil"]


#Calculate Ksw if it is missing in input data
if(is.na(World$fetchData("Ksw"))){
  KswModelled <- f_Ksw(Kow, FromData$pKa, CorgStandard, 
                     a = QSARrecord$a, b = QSARrecord$b, ChemClass,
                     RHOsolid,
                     alt_form = F)
  World$SetConst(Ksw = KswModelled)

#  } else { ?
#    FromData$Ksw.alt <- World$fetchData("Ksw") #Ksw.alt still needs to be defined when Ksw is already in the data
  }

#Calculations of variables
# source("newAlgorithmScripts/v_Ksw.alt.R")
# testIt <- World$NewCalcVariable("Ksw.alt")
#testIt$execute()
test = World$NewCalcVariable("Ksw.alt")
World$CalcVar("Ksw.alt")
World$fetchData("Ksw.alt")

World$NewCalcVariable("FRorig")
World$CalcVar("FRorig")

World$NewCalcVariable("FRorig_spw")
World$CalcVar("FRorig_spw")

World$NewCalcVariable("Kp")
World$CalcVar("Kp")

World$NewCalcVariable("D")
World$CalcVar("D")

World$NewCalcVariable("KpCOL")
World$CalcVar("KpCOL")

World$NewCalcVariable("Kacompw")
World$CalcVar("Kacompw")

World$NewCalcVariable("Kaerw") 
World$CalcVar("Kaerw")

World$NewCalcVariable("Kaers")
World$CalcVar("Kaers")

#N.B. changed 2 Oct 2023 variables are all calculated from subFRACx
World$NewCalcVariable("FRACs")
World$CalcVar("FRACs")
World$NewCalcVariable("FRACw")
World$CalcVar("FRACw")
World$NewCalcVariable("FRACa")
World$CalcVar("FRACa")

testt <- World$NewCalcVariable("Ksdcompw")
#testt$execute(debugAt = list())
World$CalcVar("Ksdcompw")

World$NewCalcVariable("Kscompw") 
World$CalcVar("Kscompw")

World$NewCalcVariable("FRingas")
World$CalcVar("FRingas")

World$NewCalcVariable("FRinaers")
World$CalcVar("FRinaers")

World$NewCalcVariable("FRinaerw")
World$CalcVar("FRinaerw")

World$NewCalcVariable("FRinw")
World$CalcVar("FRinw")

World$NewCalcVariable("FRins")
World$CalcVar("FRins")

