library(readr)
library(dplyr)
library(ggdag)
library(rlang)
library(foreach)
library(iterators)
library(tidyverse)
library(lhs)
library(openxlsx)


Run_count <- 20


inoutname <- paste0("/rivm/n/defaresj/Documents/SimpleBox_OO_variables_v1.0.xlsx")
datadir <- paste0("data")

LandscapeIn <- read.xlsx(inoutname,
                         sheet = 3,
                         colNames = TRUE,
                         cols = c(1:10))
SubstanceIn <- read.xlsx(inoutname,
                         sheet = 2,
                         colNames = TRUE,
                         cols = c(1:11))
EmissionIn <- read.xlsx(inoutname,
                        sheet = 4,
                        colNames = TRUE,
                        cols = c(1:10))
ScaleSheet <- read.csv(paste0(datadir, "/ScaleSheet.csv"))
SubCompartSheet <- read.csv(paste0(datadir, "/SubCompartSheet.csv"))
SpeciesSheet <- read.csv(paste0(datadir, "/SpeciesSheet.csv"))

source("baseScripts/initWorld_onlyMolec.R")


# 1. check if entry exists for Param
# 2. if so, use fetchData() to pull dataframe from World
# 3. for each Scale+Subcompart combination in input file, adjust Param dataframe
# 4. store adjusted parameters in World with setConst()
# 5. store required data in params dataframe for uncertainty calcs

UncertParams <- tibble(varName = character(),
                       Scale = character(),
                       SubCompart = character(),
                       Substance = character(),
                       Distribution = character(),
                       a = numeric(),
                       b = numeric(),
                       c = numeric(),
                       data = list())

Emiss <- tibble(Substance = character(),
                Abbr = character(),
                Distribution = character(),
                a = numeric(),
                b = numeric(),
                c = numeric(),
                Emis = list())

Concentrations <- tibble(Substance = character(),
                         SubCompart = character(),
                         Min = numeric(),
                         Quant25 = numeric(),
                         Median = numeric(),
                         Quant75 = numeric(),
                         Max = numeric()
                         )

Substances <- character()
SubstParams <- character()


# Read Emission Inputs
for (i in seq(nrow(EmissionIn))) {
  Substance <- EmissionIn$Substance[i]
  if (!any(Substances == Substance)) {
    Substances <- append(Substances, Substance)
  }
  
  SubCompart <- EmissionIn$SubCompart[i]
  Scale <- EmissionIn$Scale[i]
  Species <- EmissionIn$Species[i]
  
  Abbr <- paste0(SubCompartSheet$AbbrC[which(SubCompartSheet$SubCompartName == SubCompart)],
                 ScaleSheet$AbbrS[which(ScaleSheet$ScaleName == Scale)],
                 SpeciesSheet$AbbrP[which(SpeciesSheet$Species == Species)])
  
  
  Emiss <- add_row(Emiss, tibble_row(Substance = EmissionIn$Substance[i],
                                     Abbr = Abbr,
                                     Distribution = EmissionIn$Distribution[i],
                                     a = EmissionIn$a[i]*1000/(365*24*60*60),
                                     b = EmissionIn$b[i]*1000/(365*24*60*60),
                                     c = EmissionIn$c[i]*1000/(365*24*60*60)))
  
  
}


# Read Landscape Inputs and set them in the model
for (i in seq(nrow(LandscapeIn))) {
  Parameter <- World$fetchData(LandscapeIn$VarName[i])
  
  
  if("Scale" %in% colnames(Parameter) & "SubCompart" %in% colnames(Parameter)) {
    index <- which(Parameter$Scale == LandscapeIn$Scale[i] & Parameter$SubCompart == LandscapeIn$SubCompart[i])
    Parameter[index, 3] <- LandscapeIn$c[i]
  }
  
  else if ("Scale" %in% colnames(Parameter)) {
    if (is.na(LandscapeIn$Scale[i])) {
      index <- seq(1,nrow(Parameter))
    }
    else {
      index <- which(Parameter$Scale == LandscapeIn$Scale[i])
    }
    Parameter[index, 2] <- LandscapeIn$c[i]
  }
  
  else if ("SubCompart" %in% colnames(Parameter)) {
    if (is.na(LandscapeIn$SubCompart[i])) {
      index <- seq(1,nrow(Parameter))
    }
    else {
      index <- which(Parameter$SubCompart == LandscapeIn$SubCompart[i])
    }
    Parameter[index, 2] <- LandscapeIn$c[i]
  }
  
  else{
    Parameter <- LandscapeIn$c[i]
  }
  
  
  variablename <- LandscapeIn$VarName[i]
  World$SetConst(variablename = Parameter)
  
  if (LandscapeIn$Distribution[i] != "Fixed") {
    UncertParams <- add_row(UncertParams, tibble_row(varName = LandscapeIn$VarName[i],
                                                   Scale = LandscapeIn$Scale[i],
                                                   SubCompart = LandscapeIn$SubCompart[i],
                                                   Distribution = LandscapeIn$Distribution[i],
                                                   a = LandscapeIn$a[i],
                                                   b = LandscapeIn$b[i],
                                                   c = LandscapeIn$c[i]))
  }
  
}



# Read substance inputs. Do not set them yet.
for (i in seq(nrow(SubstanceIn))) {
  
  if (!any(SubstParams == SubstanceIn$VarName[i])) {
    SubstParams <- append(SubstParams, SubstanceIn$VarName[i])
  }
  
  
  if (SubstanceIn$Distribution[i] != "Fixed") {
    UncertParams <- add_row(UncertParams, tibble_row(varName = SubstanceIn$VarName[i],
                                                     Distribution = SubstanceIn$Distribution[i],
                                                     Substance = SubstanceIn$Substance[i],
                                                     a = SubstanceIn$a[i],
                                                     b = SubstanceIn$b[i],
                                                     c = SubstanceIn$c[i]))
  }
  
}



# Triangular distribution function
triangular_cdf_inv <- function(u, # LH scaling factor
                               a, # Minimum
                               b, # Maximum
                               c) { # Peak value
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

normal_pdf <- function(u, c, b){
  
  min <- max(c - b^2, 0)
  max <- c + b^2
  
  ifelse(u < (c-min)/(max-min),
         min + sqrt(u * (max-min) * (c-min)),
         max - sqrt((1-u) * (max-min) * (max-c)))
  
  
}

LogNormal_pdf <- function(u, a, b){
  
  min <- max(c-b, 0)
  max <- c + b^2
  
  ifelse(u < (c-min)/(max-min),
         min + sqrt(u * (max-min) * (c-min)),
         max - sqrt((1-u) * (max-min) * (max-c)))
  
}

      
n_vars <- nrow(UncertParams)   # The number of variables you want to create a distribution for
n_emisscomps <- nrow(Emiss)
n_lhs <- n_vars + n_emisscomps
n_samples <- Run_count     # The number of samples you want to pull from the distributions for each variable

lhs_samples <- optimumLHS(n_samples, n_lhs) # Generate numbers between 0 and 1 using lhs

lhs_samples_vars <- lhs_samples[, 1:n_vars] 
lhs_samples_emis <- lhs_samples[, (n_vars + 1):ncol(lhs_samples)]


for (i in 1:n_vars) {
  a <- UncertParams$a[i]
  b <- UncertParams$b[i]
  c <- UncertParams$c[i]
  
  
  if (UncertParams$Distribution[i] == "Triangular") {
    samples <- triangular_cdf_inv(lhs_samples_vars[, i], a, b, c)
  }
  if (UncertParams$Distribution[i] == "Normal") {
    samples <- normal_pdf(lhs_samples_vars[,i], c, b)
    
  }
  if (UncertParams$Distribution[i] == "Log normal") {
    samples <- LogNormal_pdf(lhs_samples_vars[, i], c, b)
  }
  
  # Create a new tibble for 'data' with samples replacing original values
  new_data <- tibble(value = samples)
  
  # Update the data column in the sample_df
  UncertParams$data[[i]] <- new_data
}

# Emission
for (i in 1:n_emisscomps) {
  a <- Emiss$a[i]
  b <- Emiss$b[i]
  c <- Emiss$c[i]
  
  
  if (Emiss$Distribution[i] == "Triangular") {
    samples <- triangular_cdf_inv(lhs_samples_emis[, i], a, b, c)
  }
  if (Emiss$Distribution[i] == "Normal") {
    samples <- normal_pdf(lhs_samples_emis[,i], c, b)
  }
  if (Emiss$Distribution[i] == "Log normal") {
    samples <- LogNormal_pdf(lhs_samples_emis[, i], c, b)
  }
  
  # Create a new tibble for 'data' with samples replacing original values
  new_data <- tibble(value = samples)
  
  # Update the data column in the sample_df
  Emiss$Emis[[i]] <- new_data
}

Quantiles <- tibble(SubCompart=character(), "25 quantile"= numeric(), "75 quantile"=numeric())


for (Substance in Substances) {
  
  for (SubstParam in SubstParams) {
    Parameter <- SubstanceIn$c[which(SubstanceIn$Substance == Substance &
                                       SubstanceIn$VarName == SubstParam)]
    World$SetConst(SubstParam = Parameter)
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
  
  
  
  solved <- World$Solve(Emiss, needdebug = F, UncertParams)
  
  
  Concentrations_full <- filter(World$GetConcentration(), Scale == "Regional")    
  Concentrations_full <- Concentrations_full[,-c(1,2)]

  
  Subcomparts <- unique(Concentrations_full$SubCompart)
  
  for (SubCompart in Subcomparts) {
    
    index <- which(Concentrations_full$SubCompart == SubCompart)
    Conc_min <- min(Concentrations_full$Concentration[index])
    Conc_quant25 <- quantile(Concentrations_full$Concentration[index], 0.25)
    Conc_median <- median(Concentrations_full$Concentration[index])
    Conc_quant75 <- quantile(Concentrations_full$Concentration[index], 0.25)
    Conc_max <- max(Concentrations_full$Concentration[index])
    
    Concentrations <- add_row(Concentrations, tibble_row(Substance = Substance,
                                                         SubCompart = SubCompart,
                                                         Min = Conc_min,
                                                         Quant25 = Conc_quant25,
                                                         Median = Conc_median,
                                                         Quant75 = Conc_quant75,
                                                         Max = Conc_max
                                                         ))
  }
  
  
  
  
}

write.xlsx(Concentrations, "/rivm/n/defaresj/Documents/SB_OO_Output.xlsx")

#print(Quantiles)








