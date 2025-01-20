library(readr)
library(dplyr)
library(ggdag)
library(rlang)
library(foreach)
library(iterators)
library(tidyverse)
library(lhs)


inoutname <- paste0("/rivm/n/defaresj/Documents/SimpleBox_OO_variables_v1.0.xlsx")

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

source("baseScripts/initWorld_onlyMolec.R")

Dictionary <- dict()

# 1. check if entry exists for Param
# 2. if so, use fetchData() to pull dataframe from World
# 3. for each Scale+Subcompart combination in input file, adjust Param dataframe
# 4. store adjusted parameters in World with setConst()
# 5. store required data in params dataframe for uncertainty calcs

UncertParams <- tibble(varName = character(),
                       Scale = character(),
                       SubCompart = character(),
                       Distribution = character(),
                       a = numeric(),
                       b = numeric(),
                       c = numeric(),
                       data = list())

Emiss <- tibble(Substance = character(),
                Abbr = character(),
                min = numeric(),
                max = numeric(),
                mean = numeric)


for (i in seq(nrow(EmissionIn))) {
  
}


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

LogNormal_cdf_inv <- function(u, a, b){
  1 / (u*exp(b)*sqrt(2*pi)) * exp(-(log(u)-exp(a))^2 / (2*exp(b)^2))
}

      
n_vars <- nrow(UncertParams)   # The number of variables you want to create a distribution for
n_samples <- 20     # The number of samples you want to pull from the distributions for each variable
lhs_samples <- optimumLHS(n_samples, n_vars) # Generate numbers between 0 and 1 using lhs


for (i in 1:n_vars) {
  a <- UncertParams$a[i]
  b <- UncertParams$b[i]
  c <- UncertParams$c[i]
  
  
  if (UncertParams$Distribution[i] == "Triangular") {
    samples <- triangular_cdf_inv(lhs_samples[, i], a, b, c)
  }
  if (UncertParams$Distribution[i] == "Normal") {
    samples <- normal_cdf_inv(lhs_samples[, i], c, b)
  }
  if (UncertParams$Distribution[i] == "Log normal") {
    samples <- LogNormal_cdf_inv(lhs_samples[, i], c, b)
  }
  
  # Create a new tibble for 'data' with samples replacing original values
  new_data <- tibble(value = samples)
  
  # Update the data column in the sample_df
  UncertParams$data[[i]] <- new_data
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
emissions <- data.frame(Abbr = c("aRU", "w1RU", "aCU", "w1CU"), Emis = c(2380, 15.1, 64200, 223.4))     # Tetrachloroethylene
solved <- World$Solve(emissions, needdebug = F, UncertParams)






