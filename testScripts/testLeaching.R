#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

#make variables which are needed to test
SBvars <- c("SettlingVelocity")

for (x in SBvars) {
  World$NewCalcVariable(x)
  World$CalcVar(x)
}

#calculation of kaas is by executing a process
testClass <- World$NewProcess("Leaching")
#this is calculate for transitions:
# World$allFromAndTo("k_Advection_Air") # redundant from 4-12-2023.

#SBcore can find the variable missing for the calculation graph:
World$whichUnresolved() # AirFlow 

#calculation of variables can be #1 just that for a variable, or #2 also be stored in the internal database of "World"
#1 calculate (usually when debugging)
testVar <- World$NewCalcVariable("SettlingVelocity")

#testVar$execute(debugAt = list()) #an empty list always triggers
testVar$execute(debugAt = list(Scale = "Regional", SubCompart = "air"))
#The actual execution of th eproces:
testVar$execute()

#AirFlow was calculated, but not stored; this can also be arranged by
World$UpdateKaas() #which (tries to ) calculate all kaas

#which can be debugged, similar to variables:
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
# testClass <- World$NewProcess("k_Advection_Air") # redundant from 4-12-2023.
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
