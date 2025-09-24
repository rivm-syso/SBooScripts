
#initialise a standard test (global) environment:
source("baseScripts/initTestWorld.R")

#states are the existing combinations of 
The3D #the first lines as example 
head(NewstateModule$states)

#obviously not all possible permutations exist, this is coded in ClassicNanoWorld
table(NewstateModule$states[,c("SubCompart","Scale")])

#we create an instance of the central "core" object from the data in NewstateModule :
World <- SBcore$new(NewstateModule)
World$fetchData("TotalArea")

#no need anymore for NewstateModule; all is in "World", including data, like for a variable:

#see an overview of variables by
World$fetchData("all")


#We can define a new variable as a function (read from an R-file, if library is not loaded)
#if not already executed eg. by fakeLib.R do source("../SBoo/R/v_AreaSea.R")
#the function (AND the variable by definition also) looks like:
AreaSea        #

#We create a variable-module, for our World, with the name of the function as only parameter:
testVar <- World$NewCalcVariable("AreaSea")
testVar$needVars

#all steps to calculate Area's etc:
lapply(c("AreaLand","PreArea", "Area", "SystemArea", "AreaFrac"), function(FuName){
  World$NewCalcVariable(FuName)
  World$CalcVar(FuName)
})

testVar$execute(debugAt = list(Scale = "Continental"))
# Calling the execute method of the module helps with debugging, but 
# DOES NOT puts the variable in the database, CalcVar does
World$CalcVar("AreaSea")

