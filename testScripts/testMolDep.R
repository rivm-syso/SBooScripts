#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

#make variables which are tested
SBvars <- c("AreaLand",
            "AreaSea",
            "SystemArea",
            "PreArea",
            "Area",
            "AreaFrac",
            "Volume",
            
            )

for (x in SBvars) {
  World$NewCalcVariable(x)
  World$CalcVar(x)
}

World$fetchData("WINDspeed")
World$fetchData("VertDistance")
World$fetchData("twet")
World$fetchData("tdry")
World$fetchData("COLLECTeff")
World$fetchData("AEROSOLdeprate")
World$fetchData("Kacompw")
World$fetchData("FRorig")
World$fetchData("WINDspeed")
#OtherkAir
World$fetchData("SpeciesName")
World$fetchData("landFRAC")
World$fetchData("Kaers")
World$fetchData("Kaerw")
World$fetchData("FRACaerWorld")

#calculation of kaas is by executing a process
testClass <- World$NewProcess("k_Deposition")
testClass$execute()

testClass$execute(debugAt = list()) #an empty list always triggers
testVar$execute(debugAt = list(Scale = "Regional", SubCompart = "air"))
#The actual execution of the proces:
testVar$execute()

#AirFlow was calculated, but not stored; this can also be arranged by
World$UpdateKaas() #which (tries to ) calculate all kaas
