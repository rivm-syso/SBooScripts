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
Substance <- "fluoranthene"

World$substance <- Substance


# There are some substance specific parameters not included in data/Substances.csv, so I create a dataframe for them.
Substance_extra <- data.frame(Substance = c("tetrachloroethylene", "lindane", "fluoranthene", "chrysene", "benzo[a]pyrene"),
                              H0sol = c(34170, 49100, 39830, 41250, 79300),
                              kdegair = c(2.4e-7, 5.39e-9, 5.39e-9, 5.39e-9, 5.39e-9),
                              kdegwater = c(5.3e-10, 4.46e-8, 4.46e-8, 4.46e-8, 4.46e-8),
                              kdegsoil = c(4.10e-8, 2.23e-8, 2.23e-8, 2.23e-8, 2.23e-8))

# Set the emission values [ton/year]
#emissions <- data.frame(Abbr = c("aRU", "w1RU", "aCU", "w1CU"), Emis = c(2380, 15.1, 64200, 223.4))     # Tetrachloroethylene
#emissions <- data.frame(Abbr = c("aRU", "s2RU", "aCU", "s2CU"), Emis = c(2.1, 18.9, 104.4, 939.6))      # Lindane
emissions <- data.frame(Abbr = c("aRU", "w1RU", "s2RU", "s3RU"), Emis = c(196.8, 19.2, 7.2, 16.8))      # Fluoranthene
#emissions <- data.frame(Abbr = c("aRU", "w1RU", "s2RU", "s3RU"), Emis = c(75.2, 3.2, 0.8, 0.8))         # Chrysene
#emissions <- data.frame(Abbr = c("aRU", "w1RU", "s2RU", "s3RU"), Emis = c(26.88, 4.16, 0.32, 0.64))     # Benzo[a]pyrene

# Convert emission to [mol/s]
MW <- World$fetchData("MW")
emissions <- emissions |> mutate(Emis = Emis*1000/(MW*365*24*60*60))

# Setting system area [m^2]
SystemArea <- World$fetchData("TotalArea")
index <- which(SystemArea$Scale == "Regional")
SystemArea$TotalArea[index] <- 8.4e+10
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

# Setting the degradation rates for the subcompartments [/s]    # kdeg seems to have been replaced by KdegDorC
# kdeg <- World$fetchData("kdeg")                                   
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


# Convert and calculate concentrations for the sub-phases in the relevant compartments

# Gas and Aerosol/Clouds in Air
Cair <- Concentrations$Concentration[which(Concentrations$SubCompart == "air")]
FRgas <- World$fetchData("FRingas")$FRingas[which(World$fetchData("FRingas")$Scale == "Regional")]

Concentrations$Concentration[which(Concentrations$SubCompart == "air")] <- Cair * MW
Concentrations <- rbind.data.frame(Concentrations, c("air - gas", Cair * MW * FRgas, "g/m^3"))
Concentrations <- rbind.data.frame(Concentrations, c("air - aerosol", Cair * MW *(1-FRgas), "g/m^3"))

# Dissolved and Suspended in Freshwater
Criver <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "river")])
FRw1 <- World$fetchData("FRinw")$FRinw[which(World$fetchData("FRinw")$Scale == "Regional" & World$fetchData("FRinw")$SubCompart == "river")]
KPsuspw1 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "river")]

Concentrations$Concentration[which(Concentrations$SubCompart == "river")] <- Criver * MW / 1000
Concentrations <- rbind(Concentrations, c("river - dissolved", Criver * MW / 1000 * FRw1, "g/L"))
Concentrations <- rbind(Concentrations, c("river - suspended", Criver * MW / 1000 * FRw1 * KPsuspw1, "g/kg d"))

# Water and Solid in Freshwater Sediment
Csediment <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "freshwatersediment")])
FRwinsd <- World$fetchData("FRACw")$FRACw[which(World$fetchData("FRACw")$Scale == "Regional" & World$fetchData("FRACw")$SubCompart == "freshwatersediment")]
KPsuspsd1 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "freshwatersediment")]
FRsinsd <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "freshwatersediment")]
RhoS <- World$fetchData("RhoCP")$RhoCP[which(World$fetchData("RhoCP")$SubCompart == "freshwatersediment")]

Concentrations$Concentration[which(Concentrations$SubCompart == "freshwatersediment")] <- Csediment * (MW * 1000)/(FRwinsd*1000+FRsinsd*RhoS)
Concentrations <- rbind(Concentrations, c("freshwatersediment - water", (Csediment*FRsinsd/(FRwinsd/(KPsuspsd1*RhoS/1000)+FRsinsd)*(MW*1000)/(FRsinsd*RhoS))/KPsuspsd1, "g/L"))
Concentrations <- rbind(Concentrations, c("freshwatersediment - solid", Csediment*FRsinsd/(FRwinsd/(KPsuspsd1*RhoS/1000)+FRsinsd)*(MW*1000)/(FRsinsd*RhoS), "g/kg d"))

# Water and Solid in Natural Soil
Cnatsoil <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "naturalsoil")])
FRwins1 <- World$fetchData("FRACw")$FRACw[which(World$fetchData("FRACw")$Scale == "Regional" & World$fetchData("FRACw")$SubCompart == "naturalsoil")]
KPsusps1 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "naturalsoil")]
FRains1 <- World$fetchData("FRACa")$FRACa[which(World$fetchData("FRACa")$Scale == "Regional" & World$fetchData("FRACa")$SubCompart == "naturalsoil")]
FRsins1 <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "naturalsoil")]

Concentrations$Concentration[which(Concentrations$SubCompart == "naturalsoil")] <- Cnatsoil*(MW*1000)/(FRwins1*1000+(1-FRains1-FRwins1)*RhoS)
Concentrations <- rbind(Concentrations, c("naturalsoil - water", (Cnatsoil*0.999*(MW*1000)/(FRsins1*RhoS))/KPsusps1, "g/L"))
Concentrations <- rbind(Concentrations, c("naturalsoil - solid", Cnatsoil*0.999*(MW*1000)/(FRsins1*RhoS), "g/kg d"))

# Water and Solid in Agricultural Soil
Cagrisoil <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "agriculturalsoil")])
FRwins2 <- World$fetchData("FRACw")$FRACw[which(World$fetchData("FRACw")$Scale == "Regional" & World$fetchData("FRACw")$SubCompart == "agriculturalsoil")]
KPsusps2 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "agriculturalsoil")]
FRains2 <- World$fetchData("FRACa")$FRACa[which(World$fetchData("FRACa")$Scale == "Regional" & World$fetchData("FRACa")$SubCompart == "agriculturalsoil")]
FRsins2 <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "agriculturalsoil")]

Concentrations$Concentration[which(Concentrations$SubCompart == "agriculturalsoil")] <- Cagrisoil*(MW*1000)/(FRwins2*1000+(1-FRains2-FRwins2)*RhoS)
Concentrations <- rbind(Concentrations, c("agriculturalsoil - water", (Cagrisoil*0.999*(MW*1000)/(FRsins2*RhoS))/KPsusps2, "g/L"))
Concentrations <- rbind(Concentrations, c("agriculturalsoil - solid", Cagrisoil*0.999*(MW*1000)/(FRsins2*RhoS), "g/kg d"))

# Water and Solid in Other Soil
Cothersoil <- as.numeric(Concentrations$Concentration[which(Concentrations$SubCompart == "othersoil")])
FRwins3 <- World$fetchData("FRACw")$FRACw[which(World$fetchData("FRACw")$Scale == "Regional" & World$fetchData("FRACw")$SubCompart == "othersoil")]
KPsusps3 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "agriculturalsoil")]
FRains3 <- World$fetchData("FRACa")$FRACa[which(World$fetchData("FRACa")$Scale == "Regional" & World$fetchData("FRACa")$SubCompart == "othersoil")]
FRsins3 <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "othersoil")]

Concentrations$Concentration[which(Concentrations$SubCompart == "othersoil")] <- Cothersoil*(MW*1000)/(FRwins3*1000+(1-FRains3-FRwins3)*RhoS)
Concentrations <- rbind(Concentrations, c("othersoil - water", (Cothersoil*0.999*(MW*1000)/(FRsins3*RhoS))/KPsusps3, "g/L"))
Concentrations <- rbind(Concentrations, c("othersoil - solid", Cothersoil*0.999*(MW*1000)/(FRsins3*RhoS), "g/kg d"))


# Print final results
Concentrations$Concentration <- as.numeric(Concentrations$Concentration)

print(arrange(Concentrations, SubCompart), n=22)
