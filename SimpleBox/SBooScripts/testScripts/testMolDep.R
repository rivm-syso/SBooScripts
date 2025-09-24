#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

#we need the partitioning
source("testScripts/initPartitioningVariables.R")

#make variables which are tested
SBvars <- c("AreaLand",
            "AreaSea",
            "Area",
            "Volume"
            
            )

for (x in SBvars) {
  World$NewCalcVariable(x)
  World$CalcVar(x)
}
World$fetchData("FRinw")
World$fetchData("WINDspeed")
World$fetchData("VertDistance")
World$fetchData("twet")
World$fetchData("tdry")
World$fetchData("COLLECTeff")
World$fetchData("AEROSOLdeprate")
World$fetchData("Kacompw")
World$fetchData("FRorig")
#OtherkAir
World$fetchData("SpeciesName")
World$fetchData("landFRAC")
World$fetchData("Kaers")
World$fetchData("Kaerw")

World$fetchData("kdeg.sed")
World$fetchData("kdeg.air")
World$fetchData("kdeg.water")
World$fetchData("kdeg.soil")

#fill another relevant k for OtherkAir
testDegradation <-  World$NewProcess("k_Degradation")
World$UpdateKaas(mergeExisting = F)

#only now we can calculate OtherkAir, because:
World$fetchData("kaas") #this is not the regular use!! see method kaas of World !!
source("newAlgorithmScripts/v_OtherkAir.R")
testtm <- World$NewCalcVariable("OtherkAir")
#testtm$execute()
World$CalcVar("OtherkAir")

testClass <- World$NewProcess("k_Deposition")
testClass$execute(debugAt = list())

  
testClass$execute(debugAt = list()) #an empty list always triggers
testVar$execute(debugAt = list(Scale = "Regional", SubCompart = "air"))
#The actual execution of the proces:
testVar$execute()

#AirFlow was calculated, but not stored; this can also be arranged by
World$UpdateKaas() #which (tries to ) calculate all kaas
