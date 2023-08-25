#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

#make variables which are needed to test
testVar <- World$NewCalcVariable("SettlingVelocity")
#To test without debug
testVar$execute()
#To test R6 objects and data handling:
World$CalcVar("SettlingVelocity")

World$fetchData("SettlingVelocity")

#Comparing with excel, mind the capitals...
ClassicClass$Excelgrep("elocity")
