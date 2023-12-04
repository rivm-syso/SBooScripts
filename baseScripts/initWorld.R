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
VarDefFunctions <- c("AreaSea", "AreaLand", "Area", "Volume",
                "D", "FRACa", "FRACs", "FRACw", "FRinaers",
                "FRinaerw","FRingas","FRins","FRinw",
                "FRorig", "FRorig_spw", "Kacompw", "Kaers", "Kaerw",
                "Kp", "KpCOL", "Kscompw", "Ksdcompw", "Ksw.alt", "MasConc_Otherparticle",
                "MTC_2a", "MTC_2s", "MTC_2sd", "MTC_2w", "OtherkAir",
                "rad_species", "RainOnFreshwater", "rho_species", "SettlingVelocity",
                "SettVellNat", "Tempfactor")

lapply(VarDefFunctions, function(FuName){
  World$NewCalcVariable(FuName)
  #World$CalcVar(FuName) #only needed if you want to debug or force an order; UpdateKaas finds the DAG
})
FluxDefFunctions <- c("x_Advection_Air", "x_ContRiver2Reg", "x_ContSea2Moder", "x_ContSea2Reg",
"x_LakeOutflow", "x_RegSea2Cont", "x_RiverDischarge", "x_RiverSeaScales"
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

verbose = T
kex = World$NewCalcVariable("rad_species")
kex$execute(debugAt = list(SubCompartName = "air"))
World$UpdateKaas()
