# SimpleBox OO validation using the PROMISCES datasets

# Load all required packages
library(readr)
library(dplyr)
library(ggdag)
library(rlang)
library(foreach)
library(iterators)
library(openxlsx)

# Initialize the World object
source("baseScripts/initWorld_onlyMolec.R")


inoutname <- paste0("/rivm/n/defaresj/Documents/Promisces CS2 input output.xlsx")

# SystemIn <- read.xlsx(inoutname,
#                       sheet=2,
#                       colNames=TRUE,
#                       rows=c(1:9),
#                       cols = c(1:3))
LandscapeIn <- read.xlsx(inoutname,
                         sheet = 1,
                         colNames = TRUE,
                         rows = c(1:27),
                         cols = c(1:5))
SubstanceIn <- read.xlsx(inoutname,
                         sheet = 2,
                         colNames = TRUE,
                         rows = c(16:28),
                         cols = c(1:20))
EmissionIn <- read.xlsx(inoutname,
                        sheet = 3,
                        colNames = TRUE,
                        rows = c(1:2),
                        cols = c(1:11))
Out <- c(t(read.xlsx(inoutname,
                     sheet = 3,
                     colNames = FALSE,
                     rows = 1)))


# Initialize the World object


# Choose the substance to model.
Substances <- c("ADONA","PFPeA","PFOA","PFBA","PFHxA","GenX","PFHpA","PFOS","PFBS","PFHxS")

for (Substance in Substances) {
  
  
  source("baseScripts/initWorld_onlyMolec.R")
  
  World$substance <- Substance
  
  World$NewSolver("SB1Solve")
  
  indexS <- which(colnames(EmissionIn) == Substance)
  emissions <- data.frame(Abbr = EmissionIn$Abrr, Emis = EmissionIn[,indexS])
  
  # Convert emission to [kg/s]
  MW <- World$fetchData("MW")
  emissions <- emissions |> mutate(Emis = Emis*1000/(365*24*60*60))
  
  
  
  # Setting system area [m^2]
  SystemArea <- World$fetchData("TotalArea")
  index <- which(SystemArea$Scale == "Regional")
  SystemArea$TotalArea[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "System Area")]* 1e+6
  World$SetConst("TotalArea" = SystemArea)
  
  # Setting sea fraction of total area [-]
  FRsea <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Sea Water Area")] / LandscapeIn$Value_S[which(LandscapeIn$Properties == "System Area")]
  FracSea <- World$fetchData("FRACsea")
  index <- which (FracSea$Scale == "Regional")
  FracSea$FRACsea[index] <- FRsea
  World$SetConst("FRACsea" = FracSea)
  
  # Setting fractions of total land area [-]
  LandArea <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "System Area")] * (1 - FRsea)
  LandFrac <- World$fetchData("landFRAC")
  index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "river")
  LandFrac$landFRAC[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Fresh Water Area")] / LandArea
  index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "lake")
  LandFrac$landFRAC[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Lake Water Area")] / LandArea
  index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "naturalsoil")
  LandFrac$landFRAC[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Natural Soil Area")] / LandArea
  index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "agriculturalsoil")
  LandFrac$landFRAC[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Agricultural Soil Area")] / LandArea
  index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "othersoil")
  LandFrac$landFRAC[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Other Soil Area")] / LandArea
  World$SetConst("landFRAC" = LandFrac)
  
  # Setting mass fractions of organic carbon in soil and sediment [%]
  Corg <- World$fetchData("Corg")
  index <- which(Corg$SubCompart == "naturalsoil")
  Corg$Corg[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "CORGsoil i")] / 100
  index <- which(Corg$SubCompart == "agriculturalsoil")
  Corg$Corg[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "CORGsoil i")] / 100
  index <- which(Corg$SubCompart == "othersoil")
  Corg$Corg[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "CORGsoil i")] / 100
  World$SetConst("Corg" = Corg)
  
  World$SetConst("CorgStandard" = LandscapeIn$Value_S[which(LandscapeIn$Properties == "CORGsoil i")] / 100)
  
  # Setting temperatures [K]
  Temp <- World$fetchData("Temp")
  index <- which(Temp$Scale == "Regional")
  Temp$Temp[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Temp")] + 273
  World$SetConst("Temp" = Temp)
  
  # Setting depth/height of the compartments [m]
  DepthHeight <- World$fetchData("VertDistance")
  index <- which(DepthHeight$Scale == "Regional" & DepthHeight$SubCompart == "river")
  DepthHeight$VertDistance[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Depth Fresh Water")]
  index <- which(DepthHeight$Scale == "Regional" & DepthHeight$SubCompart == "lake")
  DepthHeight$VertDistance[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Depth Lake Water")]
  index <- which(DepthHeight$Scale == "Regional" & DepthHeight$SubCompart == "sea")
  DepthHeight$VertDistance[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Depth Sea Water")]
  World$SetConst("VertDistance" = DepthHeight)
  
  # Setting the fractions of water on soil that infiltrates/becomes runoff [-]
  World$SetConst("FRACrun" = LandscapeIn$Value_S[which(LandscapeIn$Properties == "FracRun")])
  
  # This scenario has no lakewater compartment, but LakeFracRiver (fraction of freshwater part of lakes) cannot be 0.
  #World$SetConst("LakeFracRiver" = 1e-20)
  
  # Setting wind speed [m/s]
  wind <- World$fetchData("WINDspeed")
  index <- which(wind$Scale == "Regional")
  wind$WINDspeed[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "WINDspeed")]
  World$SetConst("WINDspeed" = wind)
  
  
  # Setting mass concentration of suspended matter in water [mg/L]
  # The data retrieved by World$fetchData() is in SI units, so it should be converted to [mg/L] first
  SUSP <- World$fetchData("SUSP")
  SUSP <- SUSP |> mutate(SUSP = SUSP*1000)
  index <- which(SUSP$SubCompart == "river")
  SUSP$SUSP[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "SUSP river")]
  # index <- which(SUSP$SubCompart == "sea")
  # SUSP$SUSP[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "SUSPwater 2 [R]")]
  World$SetConst("SUSP" = SUSP)
  
  # Setting the rain rate [mm/year]
  # The data retrieved by World$fetchData() is in SI units, so it should be converted to [mm/year] first
  rain <- World$fetchData("RAINrate")
  rain <- rain |> mutate(RAINrate = RAINrate*1000*3600*24*365)
  index <- which(rain$Scale == "Regional")
  rain$RAINrate[index] <- LandscapeIn$Value_S[which(LandscapeIn$Properties == "Rain Rate")] * 365
  World$SetConst("RAINrate" = rain)
  
  
  
  # Calculating the parameters that are dependent on input parameters
  SBvars <- c("FRACs",
              "FRACw",
              "FRACa",
              "AreaLand",
              "AreaSea",
              "Area",
              "Volume",
              "AirFlow",
              "Runoff",
              "RainOnFreshwater",
              "FRorig",
              "FRorig_spw",
              "MTC_2a",
              "MTC_2w",
              "MTC_2s",
              "MTC_2sd",
              "Kscompw",
              "Tempfactor",
              "KdegDorC",
              "Kacompw",
              "Ksdcompw"
  )
  
  for (x in SBvars) {
    World$NewCalcVariable(x)
    World$CalcVar(x)
  }
  
  
  # Update the transfer rates based on the newly set and calculated parameters
  World$UpdateKaas()
  
  
  
  masses <- filter(World$Solve(emissions), Scale == "Regional") %>% arrange(SubCompart)   
  masses <- as_tibble(masses)
  
  # Convert mass output to Kg
  #masses <- masses |> mutate(EqMass = EqMass*MW)
  
  print(masses)                          
  
  # Get the concentrations for the compartments
  Concentrations <- filter(World$GetConcentration(), Scale == "Regional")    
  Concentrations <- Concentrations[,-c(1,2)]
  
  
  # Conc_Out <- data.frame(
  #   Concentration = rep("-", 8)
  # )
  # 
  # 
  # Conc_Out$Concentration <- as.numeric(Conc_Out$Concentration)
  index <- which(Concentrations$SubCompart == "river")
  Conc_Out <- as.numeric(Concentrations$Concentration[index]) /1000
  
  wb <- loadWorkbook(inoutname)
  startCol <- (which(Out == Substance)-1)*2 + 1
  writeData(wb,
            sheet = "Output",
            x = Conc_Out,
            startCol = startCol,
            startRow = 3,
            colNames = FALSE)
  
  #inoutnameT <- "/rivm/n/defaresj/Documents/Bakker (2003) in SimpleBox 4/Bakker (2003) input output T.xlsx"
  
  saveWorkbook(wb,inoutname,overwrite = T)
  
  print(Conc_Out)
}



