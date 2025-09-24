#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

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
Airflow <- World$NewCalcVariable("AirFlow")
#Airflow$execute(debugAt = list())
World$CalcVar("AirFlow")

#calculation of a flux is by executing
testFlux <- World$NewFlow("x_Advection_Air")#, WithProcess = "k_Advection_Air")
World$CalcVar("x_Advection_Air")

World$fetchData("x_Advection_Air")

#calculation of kaas is by executing a process
#this is calculate for transitions:
World$allFromAndTo("k_Advection")
World$moduleList[["k_Advection"]]$execute()

World$kaas
World$UpdateKaas() #which (tries to ) calculate all kaas

testFlux <- World$NewFlux("x_Advection_Air")
World$allFromAndTo("k_Advection")

#SBcore can find the variable missing for the calculation graph:
World$whichUnresolved() # AirFlow 
World$nodelist

#calculation of variables can be #1 just that: for a variable, or #2 also be stored in the internal database of "World"
#1 calculate (usually when debugging)
testVar <- World$NewCalcVariable("AirFlow")

#testVar$execute(debugAt = list()) #an empty list always triggers
testVar$execute(debugAt = list(SubCompartName = "air"))
#The actual execution of th eproces:
testVar$execute()

#AirFlow was calculated, but not stored; this can also be arranged by
World$UpdateKaas() #which (tries to ) calculate all kaas
#now the variable is part of World
World$fetchData("Area") 

#which can be debugged, similar to variables:
debugonce(testClass$execute)
testClass$execute(debugAt = list(fromScale = "Continental"))

#and we can plot the DAG:
NodeAsText <- paste(World$nodelist$Params, "->" ,World$nodelist$Calc)
AllNodesAsText <- do.call(paste, c(as.list(NodeAsText), list(sep = ";")))
dag <- dagitty::dagitty(paste("dag{", AllNodesAsText, "}"))
plot(dagitty::graphLayout(dag))

#Replace the (saved) kaas of World
World$UpdateKaas(mergeExisting = F)
#                         HERE is the actual debug
#World$kaas
#we can stop the "debug mode" for kaas NOT like
#SBcore$undebug("kaas") #NOTE the debug-mode is for the class SBcore, not the object World
#but the instance (object World) is still in debug mode.. We redo:
# World <- SBcore$new(NewstateModule)
# testVar <- World$NewCalcVariable("PreArea")
# testVar <- World$NewCalcVariable("Area")
# testVar <- World$NewCalcVariable("Volume")
# testVar <- World$NewCalcVariable("AirFlow")
# testClass <- World$NewProcess("k_Advection_Air")
# World$UpdateKaas()
# World$kaas
# 
# #All intermediate variable are now also present, see examples:
# World$fetchData("FRACarea")
# #and in excel:
# dframe2excel(ClassicClass$Excelgrep("AREA")$NamedRanges)
# dframe2excel(World$fetchData("Volume"))

#compare with classic
# 1. Store the current kaas
#BTW, you can more directly debug public methods, like debugonce(World$SaveKaas)
#World$SaveKaas("with SBoo")

# 2. calculate and replace the current with the classic ones
# a special case of processmodule; to compare updates with classic kaas, read from the SB4N file
#World$kaas #read Classic kaas are not related to actual processes; all are from "LoadKaas"

# 3. make a "diff" debugonce(World$DiffKaas)
World$DiffKaas(withProcess = F)


#testing by variable
TAU <- function(AirFlow, Volume, ...){
  Volume / AirFlow
}

testVar <- World$NewCalcVariable("TAU")
testVar$execute()
World$fetchData("Area")

PreArea <- World$NewCalcVariable("PreArea")
PreArea$execute()
