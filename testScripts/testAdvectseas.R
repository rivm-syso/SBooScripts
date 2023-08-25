library(ggdag)
#init default core (World) with classic states, and classic kaas
source("baseScripts/initTestWorld.R")

source("newAlgorithmScripts/v_Kaw.R")
v_Kaw <- World$NewCalcVariable("Kaw")# ,WithProcess = "k_Runoff", Dimension = "SubCompart"
#v_Kaw$execute(list())
World$CalcVar("Kaw")

v_FRorig <- World$NewCalcVariable("FRorig")
#v_FRorig$execute()
World$CalcVar("FRorig")


source("newAlgorithmScripts/v_Ksw.R")
v_Ksw <- World$NewCalcVariable("Ksw")# ,WithProcess = "k_Runoff", Dimension = "SubCompart"
#v_Ksw$execute(list())
#World$CalcVar("Ksw")

lapply(c("AreaSea", "AreaLand", "Area"), function(FuName){
  World$NewCalcVariable(FuName)
  World$CalcVar(FuName)
})

#World$CleanupCalcGraphAbove("Area") #TODO
  
testVar <- World$NewCalcVariable("Volume")
World$CalcVar("Volume")

testVar <- World$NewCalcVariable("RainOnFreshwater")
World$CalcVar("RainOnFreshwater")

# 
# excelVolume <- ClassicClass$Excelgrep(grepstr = "Volume")
# excelVolume$Species <- NULL
# 
# testVol <- merge(World$fetchData("Volume"), excelVolume)
# testVol$difvol <- testVol$Volume / testVol$Numeric
# sd(testVol$difvol)

#tm <- merge(tAreaFrac, tAREAFRACx$CellStrings, all = T)
#World$allFromAndTo("k_Runoff")

source("newAlgorithmScripts/v_Runoff.R")
v_RunOff <- World$NewCalcVariable("Runoff")# ,WithProcess = "k_Runoff", Dimension = "SubCompart"
#v_RunOff$execute(list())
World$CalcVar("Runoff")

x_ContRiverDischarge <- World$NewFlow("x_ContRiver2Reg") # WATERFLOW.w1C.w1R 
#x_ContRiverDischarge$execute(debugAt = list())
World$CalcVar("x_ContRiver2Reg")

v_RiverDischarge <- World$NewFlow("x_RiverDischarge") # WATERflow.w1C.w2C and WATERflow.w1R.w2R 
#v_RiverDischarge$execute(list())
World$CalcVar("x_RiverDischarge")

v_LakeOutflow <- World$NewFlow("x_LakeOutflow") # WATERflow.w0C.w1C () and WATERflow.w0R.w1R 
#v_LakeOutflow$execute(list())
World$CalcVar("x_LakeOutflow")

v_ContSea2Reg <- World$NewFlow("x_ContSea2Reg")
#v_ContSea2Reg$execute(debugAt = list(Scale="Regional"))
World$CalcVar("x_ContSea2Reg")

v_RegSea2Cont <- World$NewFlow("x_RegSea2Cont")
#v_RegSea2Cont$execute(debugAt = list())
World$CalcVar("x_RegSea2Cont")

v_ContSea2Moder <- World$NewFlow("x_ContSea2Moder")
#v_ContSea2Moder$execute(list())
World$CalcVar("x_ContSea2Moder")

#World$fetchData("inpWATERflow")
#check; 2DO replace flows with fluxes withproces k_Advection & Compart == water
flows = World$moduleList[["k_Advection"]]$WithFlow

flux2Test <- World$fetchData("Flows")
flux2Test <- flux2Test[flux2Test$FlowName %in% flows & flux2Test$fromSubCompart %in% c("river","sea","lake"),]
flux2Test$fromScale <- factor(flux2Test$fromScale, levels = c("Regional", "Continental", "Moderate")) #force order
flux2Test$toScale <- factor(flux2Test$toScale, levels = c("Regional", "Continental", "Moderate")) #force order
flux2Test$fromSubCompart <- factor(flux2Test$fromSubCompart, levels = c("lake", "river", "sea")) #force order
flux2Test$toSubCompart <- factor(flux2Test$toSubCompart, levels = c("lake", "river", "sea")) #force order
f2Torder <- order(flux2Test$fromScale, flux2Test$fromSubCompart, flux2Test$toScale, flux2Test$toSubCompart)

flux2Test$fcolumns <- do.call(paste, c(flux2Test[c("fromScale", "fromSubCompart")], sep="."))
flux2Test$frows <- do.call(paste, c(flux2Test[c("toScale", "toSubCompart")], sep = "."))
#flux2Test$flux = 10e9 * flux2Test$flux # tune unit 

pivot_wider(flux2Test[f2Torder,c("frows","fcolumns","flow")],
            id_cols = frows, names_from = fcolumns, values_from = flow)


stop
World$fetchData("inpWATERflow")



k_AdvectionH2O <- World$NewProcess("k_AdvectionWaters")
World$allFromAndTo("k_AdvectionWaters")
k_AdvectionH2O$execute() #debugAt = list()

k_AdvectionH2O <- World$NewProcess("k_AdvectionSeaOcean")
World$allFromAndTo("k_AdvectionSeaOcean")
#debugonce(k_AdvectionH2O$execute)
k_AdvectionH2O$execute() #debugAt = list()

k_AdvectionH2O <- World$NewProcess("k_AdvectionRiverSeaScales")
World$allFromAndTo("k_AdvectionRiverSeaScales")
#debugonce(k_AdvectionH2O$execute)
k_AdvectionH2O$execute()#debugAt = list(from.ScaleName = "Continental", to.ScaleName = "Moderate", from.SubCompartName = "sea")) 
dframe2excel(k_AdvectionH2O$execute())

World$UpdateKaas(mergeExisting = F)
dframe2excel(World$DiffKaas(withProcess = T))


#related to the runoff flux:
source("newAlgorithmScripts/k_Runoff.R")
k_Runoff <- World$NewProcess("k_Runoff")

#for Molecular we need Kaw, which depend on Kaw25, temp, H0vap = -3.82*LN(IF(Tm>298,Pvap25*EXP(-6.79*(1-Tm/298)),Pvap25))+70

