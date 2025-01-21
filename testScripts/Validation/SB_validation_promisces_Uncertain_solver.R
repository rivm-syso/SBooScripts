# SimpleBox OO validation using the PROMISCES datasets

# Load all required packages
library(readr)
library(dplyr)
library(ggdag)
library(rlang)
library(foreach)
library(iterators)
library(openxlsx)
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

normal_cdf_inv <- function(u, a, b){
  1 / sqrt(2*pi*b^2) * exp(-(u-a)^2/(2*b^2))
}


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


Quantiles <- tibble(SubCompart=character(), "25 quantile"= numeric(), "75 quantile"=numeric())


# Choose the substance to model.
Substances <- c("ADONA","PFPeA","PFOA","PFBA","PFHxA","GenX","PFHpA","PFOS","PFBS","PFHxS")

for (Substance in Substances) {
  
  
  source("baseScripts/initWorld_onlyMolec.R")
  
  World$substance <- Substance
  
  World$NewSolver("UncertainSolver")
  
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
  
  
  n_vars <- 4          # The number of variables you want to create a distribution for
  n_emiscomps <- 1
  n_samples <- 100     # The number of samples you want to pull from the distributions for each variable
  
  n_lhs <- n_vars + n_emiscomps # Total number of vectors to create with latin hypercube sampling (lhs)
  
  lhs_samples <- optimumLHS(n_samples, n_lhs) # Generate numbers between 0 and 1 using lhs
  
  lhs_samples_vars <- lhs_samples[, 1:n_vars] 
  lhs_samples_emis <- lhs_samples[, (n_vars + 1):ncol(lhs_samples)]
  
  
  # Uncertain variable 1: Temperature
  var1Name <- "Temp"
  
  var1 <- World$fetchData(var1Name) |>
    filter(Scale == "Regional") |>
    mutate(SubCompart = NA)
  
  var1$a <- 267.7              # Minimum value
  var1$b <- 282.5              # Maximum value
  var1$c <- var1$Temp        # peak value (peak)
  
  
  # Uncertain variable 2: Rain Rate
  var2Name <- "RAINrate"
  
  var2 <- World$fetchData(var2Name) |>
    filter(Scale == "Regional") |>
    mutate(SubCompart = NA)
  
  var2$a <- 1.50463e-8*1000*3600*24*365              # Minimum value
  var2$b <- 6.25e-8*1000*3600*24*365              # Maximum value
  var2$c <- var2$RAINrate*1000*3600*24*365        # peak value (peak)
  
  
  # Uncertain variable 3: Suspension in river
  var3Name <- "SUSP"
  
  var3 <- World$fetchData(var3Name) |>
    filter(SubCompart == "river") |>
    mutate(Scale = NA)
  
  var3$a <- 0.022*1000               # Minimum value
  var3$b <- 0.07*1000              # Maximum value
  var3$c <- var3$SUSP*1000     # peak value (peak)
  
  
  # Uncertain variable 4: Corg in soil
  var4Name <- "Corg"
  
  var4 <- World$fetchData(var4Name) |>
    filter(SubCompart == "agriculturalsoil") |>
    mutate(Scale = NA, Dist = "Triangle")
  
  var4$a <- 0.02               # Minimum value
  var4$b <- 0.06               # Maximum value
  var4$c <- var4$Corg     # peak value (peak)
  
  
  params <- tibble(
    varName = c(var1Name, var2Name, var3Name, var4Name),
    Scale = c(var1$Scale, var2$Scale, var3$Scale, var4$Scale),
    SubCompart = c(var1$SubCompart, var2$SubCompart, var3$SubCompart, var4$SubCompart),
    Distribution = c(var1$Dist, var2$Dist, var3$Dist, var4$Dist),
    data = list(
      tibble(id = c("a", "b", "c"), value = c(var1$a, var1$b, var1$c)),
      tibble(id = c("a", "b", "c"), value = c(var2$a, var2$b, var2$c)),
      tibble(id = c("a", "b", "c"), value = c(var3$a, var3$b, var3$c)),
      tibble(id = c("a", "b", "c"), value = c(var4$a, var4$b, var4$c))
    )
  )
  
  sample_df <- params
  
  # Transform each LHS sample column to the corresponding triangular distribution
  for (i in 1:n_vars) {
    
    
      
    a <- filter(params$data[[i]], id == "a") %>% pull(value)
    b <- filter(params$data[[i]], id == "b") %>% pull(value)
    c <- filter(params$data[[i]], id == "c") %>% pull(value)
    
    if (params$Distribution[i] = "Triangle") {
      samples <- triangular_cdf_inv(lhs_samples_vars[, i], a, b, c)
    }
    if (params$Distribution[i] = "Normal"){
      samples <- normal_cdf_inv(lhs_samples_vars[, i],a,b)
    }
    
    # Create a new tibble for 'data' with samples replacing original values
    new_data <- tibble(value = samples)
    
    # Update the data column in the sample_df
    sample_df$data[[i]] <- new_data
  }
  
  
  # Define the names of the uncertain variables
  comp1Name <- "w1RU"
  
  comp1 <-  emissions |>
    filter(Abbr == comp1Name)
  
  # Set the parameters for the triangular distribution
  comp1$a <- comp1$Emis*0.5    # Minimum value
  comp1$b <- comp1$Emis*1.5    # Maximum value
  comp1$c <- comp1$Emis        # peak value (peak)
  
  comp1 <- comp1 |>
    select(-Emis)
  
  
  params <- tibble(
    Abbr = c(comp1Name),
    Emis = list(
      tibble(id = c("a", "b", "c"), value = c(comp1$a, comp1$b, comp1$c))
    )
  )
  
  emis_df <- params
  
  
  # Transform each LHS sample column to the corresponding triangular distribution
  for (i in 1:n_emiscomps) {
    a <- filter(params$Emis[[i]], id == "a") %>% pull(value)
    b <- filter(params$Emis[[i]], id == "b") %>% pull(value)
    c <- filter(params$Emis[[i]], id == "c") %>% pull(value)
    
    samples <- triangular_cdf_inv(lhs_samples_emis[], a, b, c)
    
    # Create a new tibble for 'data' with samples replacing original values
    new_data <- tibble(value = samples)
    
    # Update the data column in the sample_df
    emis_df$Emis[[i]] <- new_data
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
  
  
  
  solved <- World$Solve(emis_df, needdebug = F, sample_df)
  
  # masses <- filter(World$Solve(emissions), Scale == "Regional") %>% arrange(SubCompart)   
  # masses <- as_tibble(masses)
  
  # Convert mass output to Kg
  #masses <- masses |> mutate(EqMass = EqMass*MW)
  
  #print(masses)                          
  
  # Get the concentrations for the compartments
  Concentrations <- filter(World$GetConcentration(), Scale == "Regional")    
  Concentrations <- Concentrations[,-c(1,2)]
  
  
  
  Concriver <- Concentrations$Concentration[which(Concentrations$SubCompart == "river")]
  Quantiles <- Quantiles |> add_row(SubCompart=deparse(substitute(Concriver)),`25 quantile`=quantile(Concriver, 0.25)/1000,`75 quantile`=quantile(Concriver, 0.75)/1000)
  
  # Conc_Out <- data.frame(
  #   Concentration = rep("-", 8)
  # )
  # 
  # 
  # Conc_Out$Concentration <- as.numeric(Conc_Out$Concentration)
  index <- which(Concentrations$SubCompart == "river")
  Conc_Out <- as.numeric(Concentrations$Concentration[index]) /1000
  
  # wb <- loadWorkbook(inoutname)
  # startCol <- (which(Out == Substance)-1)*2 + 1
  # writeData(wb,
  #           sheet = "Output",
  #           x = Conc_Out,
  #           startCol = startCol,
  #           startRow = 3,
  #           colNames = FALSE)
  # 
  # #inoutnameT <- "/rivm/n/defaresj/Documents/Bakker (2003) in SimpleBox 4/Bakker (2003) input output T.xlsx"
  # 
  # saveWorkbook(wb,inoutname,overwrite = T)
  # 
  # print(Conc_Out)
}

print(Quantiles)

