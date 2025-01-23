# This is a script that will run SimpleBox OO based on the input provided by an excel file.
# It will correctly read and apply all relevant parameter inputs, and writes the results to an output file.
# The input file (and thus this script) is not limited to one substance at a time. It also supports
# calculations of uncertainty ranges based on the uncertainty of the input parameters. Currently,
# the input uncertainty only supports Triangular distribution.
# For now, the script only works with Molecular substances.


# Load in the required packages.
library(readr)
library(dplyr)
library(ggdag)
library(rlang)
library(foreach)
library(iterators)
library(tidyverse)
library(lhs)
library(openxlsx)

# Set the number of runs for calculating uncertainty.
Run_count <- 5

# Set the path to the input file, as well as the path to the model's data files.
inoutname <- paste0("/rivm/n/defaresj/Documents/SimpleBox_OO_variables_v1.0.xlsx")
datadir <- paste0("data")

# Read in the inputs for Landscape, Substance, and Emission parameters.
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

# Read the required model data files.
ScaleSheet <- read.csv(paste0(datadir, "/ScaleSheet.csv"))
SubCompartSheet <- read.csv(paste0(datadir, "/SubCompartSheet.csv"))
SpeciesSheet <- read.csv(paste0(datadir, "/SpeciesSheet.csv"))

# Initialize the World script. 
source("baseScripts/initWorld_onlyMolec.R")


# 1. check if entry exists for Param
# 2. if so, use fetchData() to pull dataframe from World
# 3. for each Scale+Subcompart combination in input file, adjust Param dataframe
# 4. store adjusted parameters in World with setConst()
# 5. store required data in params dataframe for uncertainty calcs


# Prepare tibble dataframes for later use.
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


# Store the substances and parameters in the input file.
Substances <- unique(EmissionIn$Substance)
SubstParams <- unique(SubstanceIn$VarName)

if (length(Substances) == 0) {
  Substances <- c("Unnamed Substance")
}


# Read and process Emission Inputs.
for (i in seq(nrow(EmissionIn))) {
  
  Substance <- EmissionIn$Substance[i]
  SubCompart <- EmissionIn$SubCompart[i]
  Scale <- EmissionIn$Scale[i]
  Species <- EmissionIn$Species[i]
  
  # Create the correct abbreviation for the emission input based on the listed Subcompartment, Scale and Species.
  Abbr <- paste0(SubCompartSheet$AbbrC[which(SubCompartSheet$SubCompartName == SubCompart)],
                 ScaleSheet$AbbrS[which(ScaleSheet$ScaleName == Scale)],
                 SpeciesSheet$AbbrP[which(SpeciesSheet$Species == Species)])
  
  # For each emission that has a non-fixed value, store the mean, min, and max values of the emission.
  Emiss <- add_row(Emiss, tibble_row(Substance = EmissionIn$Substance[i],
                                     Abbr = Abbr,
                                     Distribution = EmissionIn$Distribution[i],
                                     a = EmissionIn$a[i]*1000/(365*24*60*60),
                                     b = EmissionIn$b[i]*1000/(365*24*60*60),
                                     c = EmissionIn$c[i]*1000/(365*24*60*60)))
  
  
}


# Read and process Landscape Inputs.
for (i in seq(nrow(LandscapeIn))) {
  
  # Extract the parameter data from the World object into a dataframe.
  Parameter <- World$fetchData(LandscapeIn$VarName[i])
  
  # Edit the appropriate dataframe entry. Some parameter dataframes will have both 
  # SubCompart and Scale columns, one of them, or neither. The if-else branches will process
  # any possible combination.
  if("Scale" %in% colnames(Parameter) & "SubCompart" %in% colnames(Parameter)) {
    index <- which(Parameter$Scale == LandscapeIn$Scale[i] & Parameter$SubCompart == LandscapeIn$SubCompart[i])
    Parameter[index, 3] <- LandscapeIn$c[i]
  }
  
  else if ("Scale" %in% colnames(Parameter)) {
    
    # If the input file did not specify a Scale, apply the new input to all Scales.
    if (is.na(LandscapeIn$Scale[i])) {
      index <- seq(1,nrow(Parameter))
    }
    else {
      index <- which(Parameter$Scale == LandscapeIn$Scale[i])
    }
    Parameter[index, 2] <- LandscapeIn$c[i]
  }
  
  else if ("SubCompart" %in% colnames(Parameter)) {
    
    # If the input file did not specify a Subcompartment, apply the new input to all Subcompartments.
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
  
  # Write the changed dataframe back to the World object.
  variablename <- LandscapeIn$VarName[i]
  World$SetConst(variablename = Parameter)
  
  # For each Landscape parameter that has a non-fixed value, store the mean, min, and max values of the Landscape parameter.
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



# Read and process Substance Inputs. Do not set them yet.
for (i in seq(nrow(SubstanceIn))) {
  
  # For each Substance parameter that has a non-fixed value, store the mean, min, and max values of the Substance parameter.
  if (SubstanceIn$Distribution[i] != "Fixed") {
    UncertParams <- add_row(UncertParams, tibble_row(varName = SubstanceIn$VarName[i],
                                                     Distribution = SubstanceIn$Distribution[i],
                                                     Substance = SubstanceIn$Substance[i],
                                                     a = SubstanceIn$a[i],
                                                     b = SubstanceIn$b[i],
                                                     c = SubstanceIn$c[i]))
  }
  
}



# The function of the triangular distribution.
triangular_cdf_inv <- function(u, # LH scaling factor
                               a, # Minimum
                               b, # Maximum
                               c) { # Peak value
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

# The function of the normal distribution.
# TODO: Currently this is a triangular distribution. a proper function for the normal distribution
# needs to be implemented later.
normal_pdf <- function(u, c, b){
  
  min <- max(c - b^2, 1e-10)
  max <- c + b^2
  
  ifelse(u < (c-min)/(max-min),
         min + sqrt(u * (max-min) * (c-min)),
         max - sqrt((1-u) * (max-min) * (max-c)))
  
  
}

# The function of the log normal distribution.
# TODO: Currently this is a triangular distribution. a proper function for the log normal distribution
# needs to be implemented later.
LogNormal_pdf <- function(u, a, b){
  
  min <- max(c-b, 1e-10)
  max <- c + b^2
  
  ifelse(u < (c-min)/(max-min),
         min + sqrt(u * (max-min) * (c-min)),
         max - sqrt((1-u) * (max-min) * (max-c)))
  
}

# Set the number of parameters and emissions to create a distribution for.
n_vars <- nrow(UncertParams)
n_emisscomps <- nrow(Emiss)
n_lhs <- n_vars + n_emisscomps

# The number of samples you want to pull from the distributions for each variable (i.e. the number of runs)
n_samples <- Run_count

# Generate numbers between 0 and 1 using lhs
lhs_samples <- optimumLHS(n_samples, n_lhs) 

lhs_samples_vars <- lhs_samples[, 1:n_vars] 
lhs_samples_emis <- lhs_samples[, (n_vars + 1):ncol(lhs_samples)]


# Calculate the values used in the uncertainty solver for Parameters
for (i in 1:n_vars) {
  a <- UncertParams$a[i]
  b <- UncertParams$b[i]
  c <- UncertParams$c[i]
  
  # Select the Distribution to use to generate the parameter values.
  if (UncertParams$Distribution[i] == "Triangular") {
    samples <- triangular_cdf_inv(lhs_samples_vars[, i], a, b, c)
  }
  if (UncertParams$Distribution[i] == "Normal") {
    samples <- normal_pdf(lhs_samples_vars[,i], c, b)
  }
  if (UncertParams$Distribution[i] == "Log normal") {
    samples <- LogNormal_pdf(lhs_samples_vars[, i], c, b)
  }
  
  # Store the generated list of new input parameters.
  new_data <- tibble(value = samples)
  UncertParams$data[[i]] <- new_data
}


# Calculate the values used in the uncertainty solver for Emissions
for (i in 1:n_emisscomps) {
  a <- Emiss$a[i]
  b <- Emiss$b[i]
  c <- Emiss$c[i]
  
  # Select the Distribution to use to generate the parameter values.
  if (Emiss$Distribution[i] == "Triangular") {
    samples <- triangular_cdf_inv(lhs_samples_emis[, i], a, b, c)
  }
  if (Emiss$Distribution[i] == "Normal") {
    samples <- normal_pdf(lhs_samples_emis[,i], c, b)
  }
  if (Emiss$Distribution[i] == "Log normal") {
    samples <- LogNormal_pdf(lhs_samples_emis[, i], c, b)
  }
  
  # Store the generated list of new input Emissions.
  new_data <- tibble(value = samples)
  Emiss$Emis[[i]] <- new_data
}

SubstanceCount <- length(Substances)

# For every Substance, complete the rest of the setup and run the model.
for (Substance in Substances) {
  
  start.time <- Sys.time()
  #X <- Substance
  
  
  # Write the substance input parameters to the World object. Because Substance parameters don't
  # have Scale or SubCompart aspects, they can always be directly written to the World object.
  for (SubstParam in SubstParams) {
    
    Parameter <- SubstanceIn$c[which(SubstanceIn$Substance == Substance &
                                       SubstanceIn$VarName == SubstParam)]
    print(Parameter)
    print(SubstParam)
    World$SetConst(SubstParam = Parameter)
    print(World$fetchData(SubstParam))
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
  
  
  # Set the solver
  World$NewSolver("UncertainSolver")
  
  
  # Solve the matrix

  
  UncertParamsM <- UncertParams[UncertParams$Substance == Substance | is.na(UncertParams$Substance),]
  EmissM <- Emiss[Emiss$Substance == Substance,]
  
  
  solved <- World$Solve(EmissM, needdebug = F, UncertParamsM)
  
  # Extract the Concentrations from the model. This dataframe will contain all concentrations from all scales and subcomparts.
  Concentrations_full <- filter(World$GetConcentration(), Scale == "Regional")    
  Concentrations_full <- Concentrations_full[,-c(1,2)]

  
  Subcomparts <- unique(Concentrations_full$SubCompart)
  
  # Find the min, median, max and quantiles of the concentrations, and store them in a data frame.
  for (SubCompart in Subcomparts) {
    index <- which(Concentrations_full$SubCompart == SubCompart)
    Conc_min <- min(Concentrations_full$Concentration[index])
    Conc_quant25 <- quantile(Concentrations_full$Concentration[index], 0.25)
    Conc_median <- median(Concentrations_full$Concentration[index])
    Conc_quant75 <- quantile(Concentrations_full$Concentration[index], 0.75)
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
  
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  
  
  SubstanceCount <- SubstanceCount - 1
  if (SubstanceCount > 0) {
    
    cat(SubstanceCount, "more substances left to go. Estimated time left:", time.taken*SubstanceCount, "\n")
  }
  else {
    cat("Done\n")
  }
  
}

# Export the output. This contains the min, median, max and quantiles of the concentrations for all
# substances and subcompartments.
write.xlsx(Concentrations, "/rivm/n/defaresj/Documents/SB_OO_Output.xlsx")







