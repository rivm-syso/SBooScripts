# SimpleBox 5.0 Test

# This script is an attempt at reproducing the work of Bakker et al (2003) in SimpleBox 5.0

# Load all required packages
library(readr)
library(dplyr)
library(ggdag)
library(rlang)
library(foreach)
library(iterators)

# Initialize the World object
source("baseScripts/initWorld_onlyMolec.R")

# Choose the substance to model. Of the 5 substances used in Bakker (2003) only Tetrachloroethylene
# is currently present in data/Substances.csv by default. The others need to be added manually.
Substance <- "tetrachloroethylene"

World$substance <- Substance


# There are some substance specific parameters not included in data/Substances.csv, so I create a dataframe for them.
Substance_extra <- data.frame(Substance = c("tetrachloroethylene", "lindane", "fluoranthene", "chrysene", "benzo[a]pyrene"),
                              H0sol = c(34170, 49100, 39830, 41250, 79300),
                              kdegair = c(2.4e-7, 5.39e-9, 5.39e-9, 5.39e-9, 5.39e-9),
                              kdegwater = c(5.3e-10, 4.46e-8, 4.46e-8, 4.46e-8, 4.46e-8),
                              kdegsoil = c(4.10e-8, 2.23e-8, 2.23e-8, 2.23e-8, 2.23e-8))

# Set the emission values [ton/year]
emissions <- data.frame(Abbr = c("aRU", "w1RU", "aCU", "w1CU"), Emis = c(2380, 15.1, 64200, 223.4))     # Tetrachloroethylene
#emissions <- data.frame(Abbr = c("aRU", "s2RU", "aCU", "s2CU"), Emis = c(2.1, 18.9, 104.4, 939.6))      # Lindane
#emissions <- data.frame(Abbr = c("aRU", "w1RU", "s2RU", "s3RU"), Emis = c(196.8, 19.2, 7.2, 16.8))      # Fluoranthene
#emissions <- data.frame(Abbr = c("aRU", "w1RU", "s2RU", "s3RU"), Emis = c(75.2, 3.2, 0.8, 0.8))         # Chrysene
#emissions <- data.frame(Abbr = c("aRU", "w1RU", "s2RU", "s3RU"), Emis = c(26.88, 4.16, 0.32, 0.64))     # Benzo[a]pyrene

# Convert emission to [mol/s]
MW <- World$fetchData("MW")
emissions <- emissions |> mutate(Emis = Emis*1000/(MW*365*24*60*60))

# Setting system area [m^2]
SystemArea <- World$fetchData("TotalArea")
index <- which(SystemArea$Scale == "Regional")
SystemArea$TotalArea[index] <- 8.4e+10
# index <- which(SystemArea$Scale == "Continental")
# SystemArea$TotalArea[index] <- 3.714e+12 
World$SetConst("TotalArea" = SystemArea)

# Setting sea fraction of total area [-]
FracSea <- World$fetchData("FRACsea")
index <- which (FracSea$Scale == "Regional")
FracSea$FRACsea[index] <- 0.50
World$SetConst("FRACsea" = FracSea)

# Setting fractions of total land area [-]
# Lake fraction does not exist in this scenario, but cannot be set to 0 in the model
LandFrac <- World$fetchData("landFRAC")
index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "river")
LandFrac$landFRAC[index] <- 0.1
index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "lake")
LandFrac$landFRAC[index] <- 1e-20
index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "naturalsoil")
LandFrac$landFRAC[index] <- 0.40
index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "agriculturalsoil")
LandFrac$landFRAC[index] <- 0.48
index <- which(LandFrac$Scale == "Regional" & LandFrac$SubCompart == "othersoil")
LandFrac$landFRAC[index] <- 0.02
World$SetConst("landFRAC" = LandFrac)


# Setting mass fractions of organic carbon in soil and sediment [-]
Corg <- World$fetchData("Corg")
index <- which(Corg$SubCompart == "freshwatersediment")
Corg$Corg[index] <- 0.05
index <- which(Corg$SubCompart == "naturalsoil")
Corg$Corg[index] <- 0.05
index <- which(Corg$SubCompart == "agriculturalsoil")
Corg$Corg[index] <- 0.05
index <- which(Corg$SubCompart == "othersoil")
Corg$Corg[index] <- 0.05
World$SetConst("Corg" = Corg)

World$SetConst("CorgStandard" = 0.05)

# Setting mass fraction of organic carbon suspended in water [-]
World$SetConst("CORG.susp" = 0.1)

# Setting mass concentration of suspended matter in water [mg/L]
# The data retrieved by World$fetchData() is in SI units, so it should be converted to [mg/L] first
SUSP <- World$fetchData("SUSP")
SUSP <- SUSP |> mutate(SUSP = SUSP*1000)
index <- which(SUSP$SubCompart == "river")
SUSP$SUSP[index] <- 24.4
index <- which(SUSP$SubCompart == "sea")
SUSP$SUSP[index] <- 5
World$SetConst("SUSP" = SUSP)

# Setting temperatures [K]
Temp <- World$fetchData("Temp")
index <- which(Temp$Scale == "Regional")
Temp$Temp[index] <- 273 + 10
index <- which(Temp$Scale == "Continental")
Temp$Temp[index] <- 273 + 10
World$SetConst("Temp" = Temp)

# Setting depth/height of the compartments [m]
DepthHeight <- World$fetchData("VertDistance")
index <- which(DepthHeight$Scale == "Regional" & DepthHeight$SubCompart == "river")
DepthHeight$VertDistance[index] <- 3
index <- which(DepthHeight$Scale == "Regional" & DepthHeight$SubCompart == "sea")
DepthHeight$VertDistance[index] <- 25
index <- which(DepthHeight$Scale == "Regional" & DepthHeight$SubCompart == "air")
DepthHeight$VertDistance[index] <- 400
index <- which(DepthHeight$Scale == "Regional" & DepthHeight$SubCompart == "freshwatersediment")
DepthHeight$VertDistance[index] <- 0.03
World$SetConst("VertDistance" = DepthHeight)

# Setting the fractions of water in sediment and soil [-]
FRwater <- World$fetchData("subFRACw")
index <- which(FRwater$Scale == "Regional" & FRwater$SubCompart == "freshwatersediment")
FRwater$subFRACw[index] <- 0.8
index <- which(FRwater$Scale == "Regional" & FRwater$SubCompart == "naturalsoil")
FRwater$subFRACw[index] <- 0.2
index <- which(FRwater$Scale == "Regional" & FRwater$SubCompart == "agriculturalsoil")
FRwater$subFRACw[index] <- 0.2
index <- which(FRwater$Scale == "Regional" & FRwater$SubCompart == "othersoil")
FRwater$subFRACw[index] <- 0.2
World$SetConst("subFRACw" = FRwater)

# Setting the fractions of solids in soil [-]
FRsolid <- World$fetchData("FRACs")
index <- which(FRsolid$Scale == "Regional" & FRsolid$SubCompart == "naturalsoil")
FRsolid$FRACs[index] <- 0.6
index <- which(FRsolid$Scale == "Regional" & FRsolid$SubCompart == "agriculturalsoil")
FRsolid$FRACs[index] <- 0.6
index <- which(FRsolid$Scale == "Regional" & FRsolid$SubCompart == "othersoil")
FRsolid$FRACs[index] <- 0.6
World$SetConst("FRACs" = FRsolid)

# Setting the fractions of water on soil that infiltrates/becomes runoff [-]
World$SetConst("FRACrun" = 0.25)
World$SetConst("FRACinf" = 0.25)

# This scenario has no lakewater compartment, but LakeFracRiver (fraction of freshwater part of lakes) cannot be 0.
World$SetConst("LakeFracRiver" = 1e-20)

# Setting wind speed [m/s]
wind <- World$fetchData("WINDspeed")
index <- which(wind$Scale == "Regional")
wind$WINDspeed[index] <- 5
World$SetConst("WINDspeed" = wind)

# Setting the rain rate [mm/year]
# The data retrieved by World$fetchData() is in SI units, so it should be converted to [mm/year] first
rain <- World$fetchData("RAINrate")
rain <- rain |> mutate(RAINrate = RAINrate*1000*3600*24*365)
index <- which(rain$Scale == "Regional")
rain$RAINrate[index] <- 740.95
World$SetConst("RAINrate" = rain)

# Setting the deposition rate of aerosols [m/s]
World$SetConst("AEROSOLdeprate" = 0.001)

# Setting the Collection efficiency of aerosols []
collecteff <- World$fetchData("COLLECTeff")
index <- which(collecteff$Scale == "Regional")
collecteff$COLLECTeff[index] <- 20000
World$SetConst("COLLECTeff" = collecteff)

# Setting the settling velocity in water [m/s]      # Setting this parameter doesn't seem to do anything, as the model will calculate settling velocity on its own using f_SetVelWater.
# settlev <- World$fetchData("SettlVelocitywater")
# index <- which(settlev$Scale == "Regional")
# settlev$SettlVelocitywater[index] <- 2.89e-6
# World$SetConst("SettlVelocitywater" = settlev)

#World$SetConst("EROSIONsoil" = 9.51294e-13)      # [mm/year] ?? World$fetchDataUnits() says m/s, but the default values clearly suggest mm/year
#World$SetConst("Erosion" = 0.03)                 # [m/s] ?? World$fetchDataUnits() says mm/year, but the default value clearly suggests m/s. Also this parameter seems redundant.

# Setting partial mass transfer coefficient of the water/sediment interface [m/s]
World$SetConst("kwsd.sed" = 2.78e-8)
World$SetConst("kwsd.water" = 2.78e-6)

# Setting the enthalpy of dissolution [J/mol]
indexS <- which(Substance_extra$Substance == Substance)
World$SetConst("H0sol" = Substance_extra$H0sol[indexS])

# Setting the net sedimentation rate [m/s]
sedrate <- World$fetchData("NETsedrate")
index <- which(sedrate$Scale == "Regional" & sedrate$SubCompart == "sea")
sedrate$NETsedrate[index] <- 2.74288e-11
index <- which(sedrate$Scale == "Continental" & sedrate$SubCompart == "sea")
sedrate$NETsedrate[index] <- 0 

# Setting the degradation rates for the subcompartments [/s]
# kdeg <- World$fetchData("kdeg")                                   # Attempting to set these parameters for anything other than Tetrachloroethylene will result in an error. 
# index <- which(kdeg$SubCompart == "air")
# kdeg$kdeg[index] <- Substance_extra$kdegair[indexS]
# index <- which(kdeg$SubCompart == "river" | kdeg$SubCompart == "sea")
# kdeg$kdeg[index] <- Substance_extra$kdegwater[indexS]
# index <- which(kdeg$SubCompart == "agriculturalsoil" | kdeg$SubCompart == "naturalsoil" | kdeg$SubCompart == "othersoil"  )
# kdeg$kdeg[index] <- Substance_extra$kdegsoil[indexS]
# World$SetConst("kdeg" = kdeg)


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


# The scenario from Bakker (2003) does not have a lake component. In order to disable that compartment in SB 5.0,
# I forcibly set all transfer rates going to and from the lake compartments to 0.
# lakeindex <- which(World$kaas$fromSubCompart == "lake" | World$kaas$fromSubCompart == "lakesediment" | World$kaas$toSubCompart == "lake" | World$kaas$toSubCompart == "lakesediment")
# for (i in lakeindex) {
#   World$kaas$k[i] <- 0
# }
# 
# # Bakker (2003) specifically lists a rate for Continental Rivers to Regional Rivers, so I'm manually setting
# # it here in SimpleBox 5.0
# Volumew1C <- filter(World$fetchData("Volume"), Scale =="Continental", SubCompart == "river")[3]
# Ratew1Ctow1R <- 2247/Volumew1C
# index <- which(World$kaas$process == "k_Advection" & World$kaas$fromScale == "Continental" & World$kaas$fromSubCompart == "river" & World$kaas$toSubCompart == "river")
# World$kaas$k[index] <- as.numeric(Ratew1Ctow1R)


# Set a solver and solve the matrix
World$NewSolver("SB1Solve")

masses <- filter(World$Solve(emissions), Scale == "Regional") %>% arrange(SubCompart)   # THIS OUTPUT IS IN MOL, NOT KG!
masses <- as_tibble(masses)

# Convert mass output to Kg
masses <- masses |> mutate(EqMass = EqMass*MW)

print(masses)                          

# Get the concentrations for the compartments
Concentrations <- filter(World$GetConcentration(), Scale == "Regional")    # SAME HERE. THIS IS MOL, NOT KG!
Concentrations <- Concentrations[,-c(1,2)]

# Convert concentrations to g/
Concentrations <- Concentrations |> mutate(Concentration = Concentration*MW)
index <- which(Concentrations$SubCompart == "river" | Concentrations$SubCompart == "sea")
for (i in index) {
  Concentrations$Concentration[i] <- Concentrations$Concentration[i] / 1000
}


# Calculate concentrations for the sub-phases in the relevant compartments
Cair <- filter(Concentrations, SubCompart == "air")[,2]
Criver <- filter(Concentrations, SubCompart == "river")[,2]
Csediment <- filter(Concentrations, SubCompart == "freshwatersediment")[,2]
Cnatsoil <- filter(Concentrations, SubCompart == "naturalsoil")[,2]
Cagrisoil <- filter(Concentrations, SubCompart == "agriculturalsoil")[,2]
Cothersoil <- filter(Concentrations, SubCompart == "othersoil")[,2]

# Gas and Aerosol/Clouds in Air
FRgas <- filter(World$fetchData("FRingas"), Scale == "Regional")[,3]
Concentrations <- rbind.data.frame(Concentrations, c("air - gas", Cair[[1]]*FRgas, "g/m^3"))
Concentrations <- rbind.data.frame(Concentrations, c("air - aerosol", Cair[[1]]*(1-FRgas), "g/m^3"))

# Dissolved and Suspended in Freshwater
FRw1 <- filter(World$fetchData("FRinw"), Scale == "Regional" & SubCompart == "river")[,3]
KPsuspw1 <- filter(World$fetchData("Kp"), SubCompart == "river")[,2]
Concentrations <- rbind(Concentrations, c("river - dissolved", Criver[[1]]*FRw1, "g/L"))
Concentrations <- rbind(Concentrations, c("river - suspended", Criver[[1]]*FRw1*KPsuspw1, "g/kg d"))

# Water and Solid in Freshwater Sediment
FRwinsd <- filter(World$fetchData("FRACw"), Scale == "Regional" & SubCompart == "freshwatersediment")[,3]
KPsuspsd1 <- filter(World$fetchData("Kp"), SubCompart == "freshwatersediment")[,2]
FRsinsd <- filter(World$fetchData("FRACs"), Scale == "Regional" & SubCompart == "freshwatersediment")[,3]
RhoS <- filter(World$fetchData("RhoCP"), SubCompart == "freshwatersediment")[,2]
Csedsolid <- Csediment*FRsinsd/(FRwinsd/(KPsuspsd1*RhoS/1000)/FRsinsd)
Concentrations <- rbind(Concentrations, c("freshwatersediment - water", Csedsolid[[1]]/KPsuspsd1, "g/L"))
Concentrations <- rbind(Concentrations, c("freshwatersediment - solid", Csedsolid[[1]], "g/kg d"))

# Water and Solid in Natural Soil
FRwins1 <- filter(World$fetchData("FRACw"), Scale == "Regional" & SubCompart == "naturalsoil")[,3]
KPsusps1 <- filter(World$fetchData("Kp"), SubCompart == "naturalsoil")[,2]
FRains1 <- filter(World$fetchData("FRACa"), Scale == "Regional" & SubCompart == "naturalsoil")[,3]
FRsins1 <- filter(World$fetchData("FRACs"), Scale == "Regional" & SubCompart == "naturalsoil")[,3]
Csoilsolid <- Cnatsoil*(FRwins1*1000+(1- FRwins1- FRains1)*RhoS)*0.99/(FRsins1*RhoS)
Concentrations <- rbind(Concentrations, c("naturalsoil - water", Csoilsolid[[1]]/KPsusps1, "g/L"))
Concentrations <- rbind(Concentrations, c("naturalsoil - solid", Csoilsolid[[1]], "g/kg d"))

# Water and Solid in Agricultural Soil
FRwins2 <- filter(World$fetchData("FRACw"), Scale == "Regional" & SubCompart == "agriculturalsoil")[,3]
KPsusps2 <- filter(World$fetchData("Kp"), SubCompart == "agriculturalsoil")[,2]
FRains2 <- filter(World$fetchData("FRACa"), Scale == "Regional" & SubCompart == "agriculturalsoil")[,3]
FRsins2 <- filter(World$fetchData("FRACs"), Scale == "Regional" & SubCompart == "agriculturalsoil")[,3]
Csoilsolid <- Cagrisoil*(FRwins2*1000+(1- FRwins2- FRains2)*RhoS)*0.99/(FRsins2*RhoS)
Concentrations <- rbind(Concentrations, c("agriculturalsoil - water", Csoilsolid[[1]]/KPsusps2, "g/L"))
Concentrations <- rbind(Concentrations, c("agriculturalsoil - solid", Csoilsolid[[1]], "g/kg d"))

# Water and Solid in Other Soil
FRwins3 <- filter(World$fetchData("FRACw"), Scale == "Regional" & SubCompart == "othersoil")[,3]
KPsusps3 <- filter(World$fetchData("Kp"), SubCompart == "othersoil")[,2]
FRains3 <- filter(World$fetchData("FRACa"), Scale == "Regional" & SubCompart == "othersoil")[,3]
FRsins3 <- filter(World$fetchData("FRACs"), Scale == "Regional" & SubCompart == "othersoil")[,3]
Csoilsolid <- Cothersoil*(FRwins3*1000+(1- FRwins3- FRains3)*RhoS)*0.99/(FRsins3*RhoS)
Concentrations <- rbind(Concentrations, c("othersoil - water", Csoilsolid[[1]]/KPsusps3, "g/L"))
Concentrations <- rbind(Concentrations, c("othersoil - solid", Csoilsolid[[1]], "g/kg d"))


# Print final results
Concentrations$Concentration <- as.numeric(Concentrations$Concentration)

print(arrange(Concentrations, SubCompart), n=22)
