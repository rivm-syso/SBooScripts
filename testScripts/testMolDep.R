#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

#make variables which are tested
SBvars <- c("AreaLand",
            "AreaSea",
            "Area",
            "Volume",
            "FRorig",
            "FRorig_spw",
            "Kp",
            "Kacompw",
            "Kaers",
            "Kaerw",
            "FRinw",
            "FRingas",
            "kdeg.sediment"
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
World$fetchData("WINDspeed")
#OtherkAir
World$fetchData("SpeciesName")
World$fetchData("landFRAC")
World$fetchData("Kaers")
World$fetchData("Kaerw")
World$fetchData("FRACaerWorld")

# #THIS IS ALL MESSY, ANOTHER SOLUTION IS NEEDED
# KswModelled <- fKsw(Kow = World$fetchData("Kow"), 
#                     pKa = 7, 
#                     CorgStandard = World$fetchData("CorgStandard"), 
#                     a = with(World$fetchData("QSARtable"), 
#                              a[QSAR.ChemClass == World$fetchData("ChemClass")]), 
#                     b = with(World$fetchData("QSARtable"), 
#                              b[QSAR.ChemClass == World$fetchData("ChemClass")]), 
#                     ChemClass = World$fetchData("ChemClass"),
#                     RHOsolid = with(World$fetchData("rhoMatrix"),
#                                     rhoMatrix[SubCompart == "othersoil"]),
#                     alt_form = F)
# 
# Ksw.alt <- fKsw(Kow = World$fetchData("Kow"), 
#                 pKa = 7, 
#                 CorgStandard = World$fetchData("CorgStandard"), 
#                 a = with(World$fetchData("QSARtable"), 
#                          a[QSAR.ChemClass == World$fetchData("ChemClass")]), 
#                 b = with(World$fetchData("QSARtable"), 
#                          b[QSAR.ChemClass == World$fetchData("ChemClass")]), 
#                 ChemClass = World$fetchData("ChemClass"),
#                 RHOsolid = with(World$fetchData("rhoMatrix"),
#                                 rhoMatrix[SubCompart == "othersoil"]),
#                 alt_form = T, KswModelled)
# 
# FromData <- World$fetchData("Globals")
# FromData$Ksw <- KswModelled
# FromData$Ksw.alt <- Ksw.alt
# FromData$RHOsolid <- with(World$fetchData("rhoMatrix"),
#                           rhoMatrix[SubCompart == "othersoil"])
# World$UpdateData(FromData, keys = T, TableName = "Globals")
# 
# 
# #calculation of kaas is by executing a process
# testClass <- World$NewProcess("k_Deposition")
# testClass$execute()
# 
# #fill another relevant k for OtherkAir
# # NOT_deposition <- ((GASABS.a.w*(AREAFRAC.w0R+AREAFRAC.w1R+AREAFRAC.w2R)+
# #                       GASABS.a.s*(AREAFRAC.s1R+AREAFRAC.s2R+AREAFRAC.s3R))/HEIGHT.aR + 
# #                      KDEG.aR +
# #                      k.aR.aC) # problematic correction for other removal processes from air affection actual deposition.
# testDegradation <-  World$NewProcess("k_Degradation")
# testDegradation$execute()
  
testClass$execute(debugAt = list()) #an empty list always triggers
testVar$execute(debugAt = list(Scale = "Regional", SubCompart = "air"))
#The actual execution of the proces:
testVar$execute()

#AirFlow was calculated, but not stored; this can also be arranged by
World$UpdateKaas() #which (tries to ) calculate all kaas
