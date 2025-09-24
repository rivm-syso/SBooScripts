#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

#make variables which are tested
SBvars <- c("AreaLand",
            "AreaSea",
            "SystemArea",
            "PreArea",
            "Area",
            "AreaFrac",
            "Volume"
            )

for (x in SBvars) {
  World$NewCalcVariable(x)
  World$CalcVar(x)
}

#calculation of kaas is by executing a process
testClass <- World$NewProcess("k_WetDeposition")
testClass$execute()

testClass$execute(debugAt = list()) #an empty list always triggers
testVar$execute(debugAt = list(Scale = "Regional", SubCompart = "air"))
#The actual execution of the proces:
testVar$execute()

#AirFlow was calculated, but not stored; this can also be arranged by
World$UpdateKaas() #which (tries to ) calculate all kaas
