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



inoutname <- paste0("/rivm/n/defaresj/Documents/LEON-T input output.xlsx")

# SystemIn <- read.xlsx(inoutname,
#                       sheet=2,
#                       colNames=TRUE,
#                       rows=c(1:9),
#                       cols = c(1:3))
# LandscapeIn <- read.xlsx(inoutname,
#                          sheet = 1,
#                          colNames = TRUE,
#                          rows = c(1:27),
#                          cols = c(1:5))
# SubstanceIn <- read.xlsx(inoutname,
#                          sheet = 2,
#                          colNames = TRUE,
#                          rows = c(16:28),
#                          cols = c(1:20))
EmissionIn <- read.xlsx(inoutname,
                        sheet = 4,
                        colNames = TRUE,
                        rows = c(1:3),
                        cols = c(1:5))
Out <- c(t(read.xlsx(inoutname,
                     sheet = 4,
                     colNames = FALSE,
                     rows = 1)))


# Initialize the World object


# Choose the substance to model.
Substances <- c("TSP", "PM10", "PM2.5", "PM1")

for (Substance in Substances) {
  
  source("baseScripts/initWorld_onlyParticulate.R")
  
  World$substance <- Substance
  
  World$NewSolver("SBsteady")
  
  indexS <- which(colnames(EmissionIn) == Substance)
  emissions <- data.frame(Abbr = EmissionIn$Abrr, Emis = EmissionIn[,indexS])
  #emissions <- data.frame(Abbr = c("w1RS", "s3RS"), Emis = c(1000, 1000))
  
  # Convert emission to [g/s]
  
  emissions <- emissions |> mutate(Emis = Emis*1000000/(365*24*60*60))
  
  #World$SetConst("FRACrun" = 0.6)
  
  TotalAreas <- World$fetchData("TotalArea")
  TotalAreas$TotalArea[which(TotalAreas$Scale == "Regional")] <- 2.2957e+10
  World$SetConst("TotalArea" = TotalAreas)
  
  Areas <- World$fetchData("Area")
  Areas$Area[which(Areas$Scale == "Regional" & Areas$SubCompart == "othersoil")] <- 5.24e+8
  World$SetConst("Area" = Areas)
  
  #World$NewCalcVariable("Volume")
  #World$CalcVar("Volume")
  
  
  
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
  
  
  masses <- World$Solve(emissions)
  
  masses <- filter(World$Solve(emissions), Scale == "Regional") %>% arrange(SubCompart)
  masses <- as_tibble(masses)
  
  mass_sum <- summarise(group_by(masses, SubCompart), sum_mass = sum(y))
  Volume <- filter(World$fetchData("Volume"), Scale == "Regional")
  Concentrations <- data_frame(SubCompart = Volume$SubCompart, Concentration = c(mass_sum$sum_mass / Volume$Volume))
  
  
  
  Conc_Out <- data.frame(
    Concentration = rep("-", 4)
  )
  
  # Gas and Aerosol/Clouds in Air
  Cair <- Concentrations$Concentration[which(Concentrations$SubCompart == "air")]
  #FRgas <- World$fetchData("FRingas")$FRingas[which(World$fetchData("FRingas")$Scale == "Regional")]
  FRgas <- 0.9999
  #Concentrations <- rbind.data.frame(Concentrations, c("air - gas", Cair * FRgas, "g/m^3"))
  
  Conc_Out$Concentration[1] <- Cair * FRgas
  
  
  # Dissolved and Suspended in Freshwater
  Criver <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "river")])
  #FRw1 <- World$fetchData("FRinw")$FRinw[which(World$fetchData("FRinw")$Scale == "Regional" & World$fetchData("FRinw")$SubCompart == "river")]
  FRw1 <- 0.9999
  Concentrations$Concentration[which(Concentrations$SubCompart == "river")] <- Criver / 1000
  #Concentrations <- rbind(Concentrations, c("river - dissolved", Criver / 1000 * FRw1, "g/L"))
  
  Conc_Out$Concentration[2] <- Criver / 1000 * FRw1
  
  
  # Water and Solid in Freshwater Sediment
  Csediment <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "freshwatersediment")])
  FRwinsd <- World$fetchData("FRACw")$FRACw[which(World$fetchData("FRACw")$Scale == "Regional" & World$fetchData("FRACw")$SubCompart == "freshwatersediment")]
  #KPsuspsd1 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "freshwatersediment")]
  KPsuspsd1 <- 72/1000
  FRsinsd <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "freshwatersediment")]
  RhoS <- World$fetchData("RhoCP")$RhoCP[which(World$fetchData("RhoCP")$SubCompart == "freshwatersediment")]
  #Concentrations <- rbind(Concentrations, c("freshwatersediment - solid", Csediment*FRsinsd/(FRwinsd/(KPsuspsd1*RhoS/1000)+FRsinsd)*(1000)/(FRsinsd*RhoS), "g/kg d"))
  
  Conc_Out$Concentration[3] <-  Csediment*FRsinsd/(FRwinsd/(KPsuspsd1*RhoS/1000)+FRsinsd)/(FRsinsd*RhoS)
  
  
  # Water and Solid in Other Soil
  Cothersoil <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "othersoil")])
  FRsins3 <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "othersoil")]
  #Concentrations <- rbind(Concentrations, c("othersoil - solid", Cothersoil*0.999*(1000)/(FRsins3*RhoS), "g/kg d"))
  
  Conc_Out$Concentration[4] <- Cothersoil*0.999/(FRsins3*RhoS)
  
  
  Conc_Out$Concentration <- as.numeric(Conc_Out$Concentration)
  
  
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




