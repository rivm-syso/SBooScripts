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

# To proceed with testing we set
World$SetConst(pKa = 2500)
if (is.na(World$fetchData("pKa"))) {
  stop("pKa is needed but missing")
}

#TODO put Ksw in th substance data

World$SetConst(Ksw = 47500)
if (is.na(World$fetchData("Ksw"))) {
  warning("Ksw is needed but missing; set by f_Ksw()")
  AllRho <- World$fetchData("rhoMatrix")
  RHOsolid = AllRho$rhoMatrix[AllRho$SubCompart == "othersoil"]
  Ksw = f_Ksw(Kow = World$fetchData("Kow"),
              pKa = World$fetchData("pKa"),
              CorgStandard = World$fetchData("CorgStandard"),
              a = World$fetchData("a"),
              b = World$fetchData("b"),
              ChemClass = World$fetchData("ChemClass"),
              RHOsolid = RHOsolid,
              alt_form = F,
              Ksw_orig = NA
  )
  World$SetConst(Ksw = Ksw)
  
}

#We can calculate variables and fluxes available (fakeLib provided the functions:)
VarDefFunctions <- c("AirFlow", "AreaSea", "AreaLand", "Area", "Volume",
                "D", "FRACa", "FRACs", "FRACw", "FRinaers",
                "FRinaerw","FRingas","FRins","FRinw",
                "FRorig", "FRorig_spw", "Kacompw", "Kaers", "Kaerw", "KdegDorC",
                "Kp", "KpCOL", "Kscompw", "Ksdcompw", "Ksw.alt", "MasConc_Otherparticle",
                "MTC_2a", "MTC_2s", "MTC_2sd", "MTC_2w", "OtherkAir",
                "rad_species", "RainOnFreshwater", "Runoff", "rho_species", "SettlingVelocity",
                "Tempfactor")

lapply(VarDefFunctions, function(FuName){
  World$NewCalcVariable(FuName)
  #World$CalcVar(FuName) #only needed if you want to debug or force an order; UpdateKaas finds the DAG
})
FluxDefFunctions <- c("x_Advection_Air", "x_ContRiver2Reg", "x_ContSea2Reg",
                      "x_FromModerate2ArctWater", "x_FromModerate2ContWater", "x_FromModerate2TropWater",
                      "x_LakeOutflow", "x_OceanMixing2Deep", "x_OceanMixing2Sea",
                      "x_RegSea2Cont", "x_RiverDischarge", "x_ToModerateWater"
)

lapply(FluxDefFunctions, function(FuName){
  World$NewFlow(FuName)
  #World$CalcVar(FuName) #only needed if you want to debug or force an order; UpdateKaas finds the DAG
})

#and the processes, that calculate kaas
ProcessDefFunctions <- c("k_Adsorption", "k_Advection", "k_Burial",
                         "k_HeteroAgglomeration.a", "k_HeteroAgglomeration.wsd",
                         "k_CWscavenging", "k_Degradation", "k_Deposition", "k_Desorption",
                         "k_DryDeposition", "k_Erosion", "k_Escape", 
                         "k_Leaching", "k_Resuspension", "k_Runoff", "k_Sedimentation", 
                         "k_Volatilisation", "k_WetDeposition")

lapply(ProcessDefFunctions, function(FuName){
  World$NewProcess(FuName)
  #World$CalcVar(FuName) #only needed if you want to force an order; UpdateKaas finds the DAG
})

World$PostponeVarProcess(VarFunctions = "OtherkAir", ProcesFunctions = "k_Deposition")

#verbose = T
#kex = World$NewCalcVariable("rad_species")
#kex$execute(debugAt = list(SubCompartName = "air"))
World$UpdateKaas()

#obtain emissions
excelReference <- "data/SimpleBox4.01_20211028.xlsm"
if (excelReference != "") {
  if (!file.exists(excelReference)){
    stop(paste("file does not exist:", excelReference))
  }
  ClassicExcel <- ClassicNanoProcess$new(TheCore = World, filename = excelReference)
}

emissions <- ClassicExcel$ExcelEmissions("current.settings")
#knames <- c("k_Burial", "k_Degradation", "k_Runoff", "k_Sedimentation") #from names(World$moduleList)[startsWith(names(World$moduleList), "k_")]
#World$NewSolver("kSense")
World$NewSolver("vUncertain")

vnamesDSD <- data.frame(
  vnames = c("AirFlow", "Kp", "KpCOL", "Kscompw", "Ksdcompw", "Runoff"),
  distNames = "normal",  #see lhs package for possible distributions
  secondPar = 0.3
)

#debugonce(World$Solve)
SolRet <- World$Solve(needdebug = T, emissions, n = 10, vnamesDistSD = vnamesDSD)
