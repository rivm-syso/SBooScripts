# SimpleBox 5.0 Test

# This script is an attempt at reproducing the work of Bakker et al (2003) in SimpleBox 5.0

# Load all required packages
library(readr)
library(dplyr)
library(ggdag)
library(rlang)
library(foreach)
library(iterators)
library(tidyverse)
library(lhs)

# Triangular distribution function
triangular_cdf_inv <- function(u, # LH scaling factor
                               a, # Minimum
                               b, # Maximum
                               c) { # Peak value
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

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





n_vars <- 16          # The number of variables you want to create a distribution for
n_samples <- 100     # The number of samples you want to pull from the distributions for each variable

lhs_samples <- optimumLHS(n_samples, n_vars) # Generate numbers between 0 and 1 using lhs


# Uncertain variable 1: Temperature
var1Name <- "Temp"

var1 <- World$fetchData(var1Name) |>
  filter(Scale == "Regional") |>
  mutate(SubCompart = NA)

var1$a <- 270              # Minimum value
var1$b <- 305              # Maximum value
var1$c <- var1$Temp        # peak value (peak)


# Uncertain variable 2: Corg susp
var2Name <- "CORG.susp"

var2 <- tibble(!!var2Name := World$fetchData(var2Name))
var2$SubCompart <- NA
var2$Scale <- NA

var2$a <- 0.06# Minimum value
var2$b <- 0.14               # Maximum value
var2$c <- var2$CORG.susp  # peak value (peak)


# Uncertain variable 3: Wind speed
var3Name <- "WINDspeed"

var3 <- World$fetchData(var3Name) |>
  filter(Scale == "Regional") |>
  mutate(SubCompart = NA)

var3$a <- 1.65               # Minimum value
var3$b <- 13.6               # Maximum value
var3$c <- var3$WINDspeed     # peak value (peak)


# Uncertain variable 4: Collecting Efficiency
var4Name <- "COLLECTeff"

var4 <- World$fetchData(var4Name) |>
  filter(Scale == "Regional") |>
  mutate(SubCompart = NA)

var4$a <- 5000               # Minimum value
var4$b <- 35000              # Maximum value
var4$c <- var4$COLLECTeff     # peak value (peak)


# Uncertain variable 5: Rain rate
var5Name <- "RAINrate"

var5 <- World$fetchData(var5Name) |>
  filter(Scale == "Regional") |>
  mutate(SubCompart = NA)

var5$a <- 2.3148e-10               # Minimum value
var5$b <- 7.6273e-8               # Maximum value
var5$c <- var5$RAINrate     # peak value (peak)


# Uncertain variable 6: Fraction that infiltrates soil
var6Name <- "FRACinf"

var6 <- World$fetchData(var6Name) |>
  filter(Scale == "Regional") |>
  mutate(SubCompart = NA)


var6$a <- 0              # Minimum value
var6$b <- 0.5               # Maximum value
var6$c <- var6$FRACinf     # peak value (peak)


# Uncertain variable 7: Suspension in river
var7Name <- "SUSP"

var7 <- World$fetchData(var7Name) |>
  filter(SubCompart == "river") |>
  mutate(Scale = NA)

var7$a <- 0.0009               # Minimum value
var7$b <- 0.0479              # Maximum value
var7$c <- var7$SUSP     # peak value (peak)


# Uncertain variable 8: Corg in sediment
var8Name <- "Corg"

var8 <- World$fetchData(var8Name) |>
  filter(SubCompart == "freshwatersediment") |>
  mutate(Scale = NA)

var8$a <- 0.01               # Minimum value
var8$b <- 0.09               # Maximum value
var8$c <- var8$Corg     # peak value (peak)


# Uncertain variable 9: Corg in soil
var9Name <- "Corg"

var9 <- World$fetchData(var9Name) |>
  filter(SubCompart == "agriculturalsoil") |>
  mutate(Scale = NA)

var9$a <- 0.01               # Minimum value
var9$b <- 0.09               # Maximum value
var9$c <- var9$Corg     # peak value (peak)


# Uncertain variable 10: Fraction that becomes runoff
var10Name <- "FRACrun"

var10 <- tibble(!!var10Name := World$fetchData(var10Name))
var10$SubCompart <- NA
var10$Scale <- NA

var10$a <- 0              # Minimum value
var10$b <- 0.5               # Maximum value
var10$c <- var10$FRACrun     # peak value (peak)


# Uncertain variable 11: Height of air column
var11Name <- "VertDistance"

var11 <- World$fetchData(var11Name) |>
  filter(SubCompart == "air" & Scale == "Regional")

var11$a <- 77
var11$b <- 1138
var11$c <- var11$VertDistance


# Uncertain variable 12: Rho solid
var12Name <- "RhoCP"

var12 <- World$fetchData(var12Name) |>
  filter(SubCompart == "naturalsoil") |>
  mutate(Scale = NA)

var12$a <- 2000
var12$b <- 3000
var12$c <- var12$RhoCP


# Uncertain variable 13: Rho solid
var13Name <- "RhoCP"

var13 <- World$fetchData(var13Name) |>
  filter(SubCompart == "agriculturalsoil") |>
  mutate(Scale = NA)

var13$a <- 2000
var13$b <- 3000
var13$c <- var13$RhoCP


# Uncertain variable 14: Rho solid
var14Name <- "RhoCP"

var14 <- World$fetchData(var14Name) |>
  filter(SubCompart == "othersoil") |>
  mutate(Scale = NA)

var14$a <- 2000
var14$b <- 3000
var14$c <- var14$RhoCP

# Uncertain variable 15: sediment depth
var15Name <- "VertDistance"

var15 <- World$fetchData(var15Name) |>
  filter(Scale == "Regional" & SubCompart == "freshwatersediment")

var15$a <- 0.01
var15$b <- 0.1
var15$c <- var15$VertDistance


# Uncertain variable 16: river depth
var16Name <- "VertDistance"

var16 <- World$fetchData(var16Name) |>
  filter(Scale == "Regional" & SubCompart == "river")

var16$a <- 2
var16$b <- 15
var16$c <- var16$VertDistance


params <- tibble(
  varName = c(var1Name, var2Name, var3Name, var4Name, var5Name,
              var6Name, var7Name, var8Name, var9Name, var10Name,
              var11Name, var12Name, var13Name, var14Name, var15Name,
              var16Name),
  Scale = c(var1$Scale, var2$Scale, var3$Scale, var4$Scale, var5$Scale,
            var6$Scale, var7$Scale, var8$Scale, var9$Scale, var10$Scale,
            var11$Scale, var12$Scale, var13$Scale, var14$Scale, var15$Scale,
            var16$Scale),
  SubCompart = c(var1$SubCompart, var2$SubCompart, var3$SubCompart, var4$SubCompart, var5$SubCompart,
                 var6$SubCompart, var7$SubCompart, var8$SubCompart, var9$SubCompart, var10$SubCompart,
                 var11$SubCompart, var12$SubCompart, var13$SubCompart, var14$SubCompart, var15$SubCompart,
                 var16$SubCompart),
  data = list(
    tibble(id = c("a", "b", "c"), value = c(var1$a, var1$b, var1$c)),
    tibble(id = c("a", "b", "c"), value = c(var2$a, var2$b, var2$c)),
    tibble(id = c("a", "b", "c"), value = c(var3$a, var3$b, var3$c)),
    tibble(id = c("a", "b", "c"), value = c(var4$a, var4$b, var4$c)),
    tibble(id = c("a", "b", "c"), value = c(var5$a, var5$b, var5$c)),
    tibble(id = c("a", "b", "c"), value = c(var6$a, var6$b, var6$c)),
    tibble(id = c("a", "b", "c"), value = c(var7$a, var7$b, var7$c)),
    tibble(id = c("a", "b", "c"), value = c(var8$a, var8$b, var8$c)),
    tibble(id = c("a", "b", "c"), value = c(var9$a, var9$b, var9$c)),
    tibble(id = c("a", "b", "c"), value = c(var10$a, var10$b, var10$c)),
    tibble(id = c("a", "b", "c"), value = c(var11$a, var11$b, var11$c)),
    tibble(id = c("a", "b", "c"), value = c(var12$a, var12$b, var12$c)),
    tibble(id = c("a", "b", "c"), value = c(var13$a, var13$b, var13$c)),
    tibble(id = c("a", "b", "c"), value = c(var14$a, var14$b, var14$c)),
    tibble(id = c("a", "b", "c"), value = c(var15$a, var15$b, var15$c)),
    tibble(id = c("a", "b", "c"), value = c(var16$a, var16$b, var16$c))
  )
)

sample_df <- params

# Transform each LHS sample column to the corresponding triangular distribution
for (i in 1:n_vars) {
  a <- filter(params$data[[i]], id == "a") %>% pull(value)
  b <- filter(params$data[[i]], id == "b") %>% pull(value)
  c <- filter(params$data[[i]], id == "c") %>% pull(value)
  
  samples <- triangular_cdf_inv(lhs_samples[, i], a, b, c)
  
  # Create a new tibble for 'data' with samples replacing original values
  new_data <- tibble(value = samples)
  
  # Update the data column in the sample_df
  sample_df$data[[i]] <- new_data
}



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


# Solve the matrix
World$NewSolver("UncertainSolver")

solved <- World$Solve(emissions, needdebug = F, sample_df)





# 
# Input_Variables <- 
#   solved$Input_Variables |> unnest(data) 
# Input_Emission <- 
#   solved$Input_Emission |> unnest(Emis) 
# 
# Plot_data <- 
#   Input_Variables |> 
#   # some units missing resulting in NA
#   pivot_wider(names_from = c(varName,Scale,SubCompart,Unit), values_from = value) |> 
#   full_join(solved$SteadyStateMass)
# 
# varnames <- colnames(Plot_data)[2:(1+n_vars)]
# 
# plot_theme <-  theme(
#   axis.title.x = element_text(size = 14),    
#   axis.title.y = element_text(size = 14),    
#   axis.text.x = element_text(size = 12,angle = 45, hjust = 1),     
#   axis.text.y = element_text(size = 12),
#   title = element_text(size=20)
# )
# 
# emiscomps <- unique(solved$Input_Emission$Abbr)
# 
# 
# p1 <- ggplot(Plot_data, mapping = aes(x=varnames[1], y = EqMass)) +
#   geom_point() + facet_wrap(vars(Abbr)) +
#   scale_y_continuous(trans = 'log10')
# p1
# 
# p2_data <-
#   Plot_data |> pivot_longer(varnames,
#                             values_to = "Variable value",
#                             names_to = "Variable") |>
#   filter(SubCompart == "river")
# 
# p2 <-  ggplot(p2_data, mapping = aes(x=`Variable value`, y = EqMass)) +
#   geom_point() + facet_wrap(vars(Scale,SubCompart,Variable)) +
#   scale_y_continuous(trans = 'log10')
# p2

# p3_data <-
#   Input_Emission |> pivot_wider(names_from = c(Abbr,Unit), names_glue = "{Abbr}_Emis_{Unit}",
#                                 values_from = Emis) |>
#   full_join(solved$SteadyStateMass, by = "Abbr") |>   filter(SubCompart == "river") |>
#   pivot_longer(c(`aRU_Emis_kg.s-1`,`s2RU_Emis_kg.s-1`), values_to = "Emission_kg.s-1",names_to = "EmisComp")
# 
# p3 <-  ggplot(p3_data, mapping = aes(x=`Emission_kg.s-1`, y = EqMass)) +
#   geom_point() + facet_wrap(vars(Scale,SubCompart,EmisComp)) 
# p3
# 
# plots_data <- Plot_data |>
#   filter(Abbr %in% emiscomps)
# 
# for(i in varnames) {
#   p2 <- ggplot(plots_data, mapping = aes(x = .data[[i]], y = EqMass)) +
#     geom_point() + 
#     facet_wrap(vars(Abbr)) + 
#     ggtitle("Mass in compartment at year ") + 
#     labs(subtitle = "One set of emissions",
#          x = i,  
#          y = "Mass (kg)") +
#     plot_theme                 
#   print(p2)
# }




# Get the concentrations for the compartments
Concentrations <- filter(World$GetConcentration(), Scale == "Regional")    # SAME HERE. THIS IS MOL, NOT KG!
Concentrations <- Concentrations[,-c(1,2)]

MW <- World$fetchData("MW")

Quantiles <- tibble(SubCompart=character(), "2.5 quantile"= numeric(), "97.5 quantile"=numeric())


Concair <- Concentrations$Concentration[which(Concentrations$SubCompart == "air")]
FRgas <- World$fetchData("FRingas")$FRingas[which(World$fetchData("FRingas")$Scale == "Regional")]
Concairgas <- numeric()
Concairaerosol <- numeric()
for (i in seq(length(Concair))){
  Concairgas <- append(Concairgas, (Concair[i] * MW * FRgas))
  Concairaerosol <- append(Concairaerosol, Concair[i] * MW * (1-FRgas))
}
Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(Concair)),`2.5 quantile`=quantile(Concairgas, 0.025),`97.5 quantile`=quantile(Concairgas, 0.975))
Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(Concairaerosol)),`2.5 quantile`=quantile(Concairaerosol, 0.025),`97.5 quantile`=quantile(Concairaerosol, 0.975))

Concriver <- Concentrations$Concentration[which(Concentrations$SubCompart == "river")]
FRw1 <- World$fetchData("FRinw")$FRinw[which(World$fetchData("FRinw")$Scale == "Regional" & World$fetchData("FRinw")$SubCompart == "river")]
KPsuspw1 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "river")]
Concriverdissolved <- numeric()
Concriversuspended <- numeric()
for (i in seq(length(Concriver))){
  Concriverdissolved <- append(Concriverdissolved, Concriver[i] * MW / 1000 * FRw1)
  Concriversuspended <- append(Concriversuspended, Concriver[i] * MW / 1000 * FRw1 * KPsuspw1)
}
Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(Concriverdissolved)),`2.5 quantile`=quantile(Concriverdissolved, 0.025),`97.5 quantile`=quantile(Concriverdissolved, 0.975))
Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(Concriversuspended)),`2.5 quantile`=quantile(Concriversuspended, 0.025),`97.5 quantile`=quantile(Concriversuspended, 0.975))

ConcFWsed <- Concentrations$Concentration[which(Concentrations$SubCompart == "freshwatersediment")]
FRwinsd <- World$fetchData("FRACw")$FRACw[which(World$fetchData("FRACw")$Scale == "Regional" & World$fetchData("FRACw")$SubCompart == "freshwatersediment")]
KPsuspsd1 <- World$fetchData("Kp")$Kp[which(World$fetchData("Kp")$SubCompart == "freshwatersediment")]
FRsinsd <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "freshwatersediment")]
#RhoS <- World$fetchData("RhoCP")$RhoCP[which(World$fetchData("RhoCP")$SubCompart == "freshwatersediment")]
RhoS <- 2500
ConcFWsedsolid <- numeric()
for (i in seq(length(ConcFWsed))){
  ConcFWsedsolid <- append(ConcFWsedsolid, ConcFWsed[i] * FRsinsd/(FRwinsd/(KPsuspsd1*RhoS/1000)+FRsinsd)*(MW*1000)/(FRsinsd*RhoS))
}
Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(ConcFWsedsolid)),`2.5 quantile`=quantile(ConcFWsedsolid, 0.025),`97.5 quantile`=quantile(ConcFWsedsolid, 0.975))

Concnatsoil <- Concentrations$Concentration[which(Concentrations$SubCompart == "naturalsoil")]
FRsins1 <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "naturalsoil")]
Concnatsoilsolid <- numeric()
for (i in seq(length(Concnatsoil))){
  Concnatsoilsolid <- append(Concnatsoilsolid, Concnatsoil[i]*0.999*(MW*1000)/(FRsins1*RhoS))
}
Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(Concnatsoilsolid)),`2.5 quantile`=quantile(Concnatsoilsolid, 0.025),`97.5 quantile`=quantile(Concnatsoilsolid, 0.975))

Concagrisoil <- Concentrations$Concentration[which(Concentrations$SubCompart == "agriculturalsoil")]
FRsins2 <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "agriculturalsoil")]
Concagrisoilsolid <- numeric()
for (i in seq(length(Concagrisoil))){
  Concagrisoilsolid <- append(Concagrisoilsolid, Concagrisoil[i]*0.999*(MW*1000)/(FRsins2*RhoS))
}
Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(Concagrisoilsolid)),`2.5 quantile`=quantile(Concagrisoilsolid, 0.025),`97.5 quantile`=quantile(Concagrisoilsolid, 0.975))

Concothersoil <- Concentrations$Concentration[which(Concentrations$SubCompart == "othersoil")]
FRsins3 <- World$fetchData("FRACs")$FRACs[which(World$fetchData("FRACs")$Scale == "Regional" & World$fetchData("FRACs")$SubCompart == "othersoil")]
Concothersoilsolid <- numeric()
for (i in seq(length(Concothersoil))){
  Concothersoilsolid <- append(Concothersoilsolid, Concothersoil[i]*0.999*(MW*1000)/(FRsins3*RhoS))
}
Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(Concothersoilsolid)),`2.5 quantile`=quantile(Concothersoilsolid, 0.025),`97.5 quantile`=quantile(Concothersoilsolid, 0.975))



print(Quantiles)


