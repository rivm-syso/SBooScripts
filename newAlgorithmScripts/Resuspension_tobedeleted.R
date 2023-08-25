# function Ok, data not ready yet

#'@title Resuspenion of particles
#'@name Resuspenion
#'@param to.SettlingVelocity SettlingVelocity, see function
#'@param VertDistance mixed depth water sediment compartment #[m]
#'@param RHOsolid Mineral density of sediment and soil #[kg/m3]
#'@param FRACs Volume fraction solids in sediment #[-]
#'@param to.mConcSusp Concentration of suspended matter in water #[kg/m3]
#'@return k_Resuspension Resuspension flow from sediment #[s-1]
#'@export

k_Resuspension <- function (to.SettlingVelocity, VertDistance, 
                            RHOsolid, FRACs, to.mConcSusp) {
  
  #Gross sedimentation rate from water [m/s]
  GROSSEDrate <- SettlingVelocity*mConcSusp/(FRACs*RHOsolid)    #[m.s-1]
  
  #Resuspension flow from sediment [m/s]; can't be < 0
  RESUSflow <- max(0, GROSSEDrate - NETsedrate)
  
  #Resuspension k to water [s-1]
  k_Resuspenion <- RESUSflow / VertDistance
}





#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

#make variables which are needed
SBvars <- c("SettlingVelocity"
)

for (x in SBvars) {
  World$NewCalcVariable(x)
  World$CalcVar(x)
}



TestProcess <- World$NewProcess("k_Resuspension")
World$allFromAndTo("k_Resuspension")
#calculation of kaas is by executing a process
testClass <- World$NewProcess("k_Resuspension")
testClass$execute()
debug(testClass$execute)
testClass$execute(debugAt = list()) #an empty list always triggers
#testVar$execute(debugAt = list(Scale = "Regional", SubCompart = "air"))
#The actual execution of the proces:
testVar$execute()



