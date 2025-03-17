# This is a script that will run SimpleBox OO based on the input provided by an excel file.
# It will correctly read and apply all relevant parameter inputs, and writes the results to an output file.
# The input file (and thus this script) is not limited to one substance at a time. It also supports
# calculations of uncertainty ranges based on the uncertainty of the input parameters. Currently,
# the input uncertainty supports Triangular, Normal, Lognormal and Weibull distribution.

# NOTE: the ODE will throw a fatal error if very small input values are used (observed so far with 1e-20)


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
library(sensitivity)
library(ggplot2)
library(ks)



# Set the number of runs for calculating uncertainty.
Run_count <- 100

# Set the path to the input file, as well as the path to the model's data files.
inoutname <- paste0("path to input file")
datadir <- paste0("data")

# Read in the inputs for Landscape, Substance, Emission and Monitored parameters.
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
MEC_In <- read.xlsx(inoutname,
                    sheet = 5,
                    colNames = TRUE,
                    cols = c(1:11))

# Read the required model data files.
ScaleSheet <- read.csv(paste0(datadir, "/ScaleSheet.csv"))
SubCompartSheet <- read.csv(paste0(datadir, "/SubCompartSheet.csv"))
SpeciesSheet <- read.csv(paste0(datadir, "/SpeciesSheet.csv"))

# Initialize the World object. 
source("baseScripts/initWorld_onlyMolec.R")


# Prepare tibble dataframes for later use.
FixedParams <- tibble(Substance = character(),
                      varName = character(),
                      Scale = character(),
                      SubCompart = character(),
                      Waarde = numeric())

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

MEC_Distributed <- tibble(Substance = character(),
                          SubCompart = character(),
                          RUN = numeric(),
                          Value = numeric())

Conc_calc <- tibble(Substance = character(),
                    SubCompart = character(),
                    RUN = numeric(),
                    Value = numeric())

PECMEC_statistics <- tibble(Substance = character(),
                            SubCompart = character(),
                            PEC_Min = numeric(),
                            PEC_Quant25 = numeric(),
                            PEC_Median = numeric(),
                            PEC_Quant75 = numeric(),
                            PEC_Max = numeric(),
                            MEC_Min = numeric(),
                            MEC_Quant25 = numeric(),
                            MEC_Median = numeric(),
                            MEC_Quant75 = numeric(),
                            MEC_Max = numeric(),
                            "PEC:MEC_Min" = numeric(),
                            "PEC:MEC_Quant25" = numeric(),
                            "PEC:MEC_Median" = numeric(),
                            "PEC:MEC_Quant75" = numeric(),
                            "PEC:MEC_Max" = numeric()
)

# Store the Substance names that will be modeled from the input file.
Substances <- unique(EmissionIn$Substance)

# Failsafe in case no Substance was named in the input. 
if (length(Substances) == 0) {
  Substances <- c("Unnamed Substance")
  SubstanceIn$Substance <- "Unnamed Substance"
  EmissionIn$Substance <- "Unnamed Substance"
  message("No Substance name detected. Substance will be referred to as 'Unnamed Substance'.")
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
  
  # For each emission with a fixed value, set the mean, min and max to the same value.
  if (EmissionIn$Distribution[i] == "Fixed") {
    Emiss <- add_row(Emiss, tibble_row(Substance = EmissionIn$Substance[i],
                                       Abbr = Abbr,
                                       Distribution = EmissionIn$Distribution[i],
                                       a = EmissionIn$c[i]*1000/(365*24*60*60),
                                       b = EmissionIn$c[i]*1000/(365*24*60*60),
                                       c = EmissionIn$c[i]*1000/(365*24*60*60)))
  }
  
  # For each emission that has a non-fixed value, store the mean, min, and max values of the emission.
  else {
    Emiss <- add_row(Emiss, tibble_row(Substance = EmissionIn$Substance[i],
                                       Abbr = Abbr,
                                       Distribution = EmissionIn$Distribution[i],
                                       a = ifelse(is.na(EmissionIn$a[i]), 1e-10, EmissionIn$a[i]*1000/(365*24*60*60)),
                                       b = EmissionIn$b[i]*1000/(365*24*60*60),
                                       c = EmissionIn$c[i]*1000/(365*24*60*60)))
  }
  
}


# Read Landscape Inputs and separate fixed from uncertain inputs.
for (i in seq(nrow(LandscapeIn))) {
  
  if (LandscapeIn$Distribution[i] == "Fixed") {
    FixedParams <- add_row(FixedParams, tibble_row(varName = LandscapeIn$VarName[i],
                                                   Scale = LandscapeIn$Scale[i],
                                                   SubCompart = LandscapeIn$SubCompart[i],
                                                   Waarde = LandscapeIn$c[i]))
  }
  
  # For each Landscape parameter that has a non-fixed value, store the mean, min, and max values of the Landscape parameter.
  else {
    UncertParams <- add_row(UncertParams, tibble_row(varName = LandscapeIn$VarName[i],
                                                     Scale = LandscapeIn$Scale[i],
                                                     SubCompart = LandscapeIn$SubCompart[i],
                                                     Distribution = LandscapeIn$Distribution[i],
                                                     a = ifelse(is.na(LandscapeIn$a[i]), 1e-10, LandscapeIn$a[i]),
                                                     b = LandscapeIn$b[i],
                                                     c = LandscapeIn$c[i]))
  }
  
}



# Read Substance Inputs and separate fixed from uncertain inputs.
for (i in seq(nrow(SubstanceIn))) {
  
  if (SubstanceIn$Distribution[i] == "Fixed") {
    FixedParams <- add_row(FixedParams, tibble_row(varName = SubstanceIn$VarName[i],
                                                   Substance = SubstanceIn$Substance[i],
                                                   Waarde = SubstanceIn$c[i]))
  }
  
  # For each Substance parameter that has a non-fixed value, store the mean, min, and max values of the Substance parameter.
  else {
    UncertParams <- add_row(UncertParams, tibble_row(varName = SubstanceIn$VarName[i],
                                                     Distribution = SubstanceIn$Distribution[i],
                                                     Substance = SubstanceIn$Substance[i],
                                                     a = ifelse(is.na(SubstanceIn$a[i]), 1e-10, SubstanceIn$a[i]),
                                                     b = SubstanceIn$b[i],
                                                     c = SubstanceIn$c[i]))
  }
  
}


Available_Distributions <- c("Triangular", "Normal", "Log normal", "Weibull", "Fixed")

# The function of the triangular distribution.
triangular_cdf_inv <- function(u, a, b, c) {
  
  ifelse(u < (c-a)/(b-a),
         a + sqrt(u * (b-a) * (c-a)),
         b - sqrt((1-u) * (b-a) * (b-c)))
}

# The function of the normal distribution.
normal_pdf <- function(u, b, c){

  qnorm(u, c, b)
  
}

# The function of the log normal distribution.
LogNormal_pdf <- function(u, b, c){

  log(qlnorm(u, c, b))
  
}

# The function of the Weibull distribution.
Weibull_pdf <- function(u, a, b, c){
  
  a + qweibull(u, b, c)
}


# Set the number of parameters and emissions to create a distribution for.
n_vars <- nrow(UncertParams)
n_emisscomps <- nrow(Emiss)
n_MEC <- nrow(MEC_In)
n_lhs <- n_vars + n_emisscomps + n_MEC

# The number of samples you want to pull from the distributions for each variable (i.e. the number of runs)
n_samples <- Run_count

# Generate numbers between 0 and 1 using lhs
lhs_samples <- optimumLHS(n_samples, n_lhs) 

lhs_samples_vars <- lhs_samples[, 1:n_vars]
lhs_samples_emis <- lhs_samples[, (n_vars + 1):(n_vars+n_emisscomps)]
lhs_samples_MEC <- lhs_samples[,(n_vars+n_emisscomps+1):ncol(lhs_samples)]



# Calculate the values used in the uncertainty solver for Parameters
if (n_vars > 0) {
  for (i in 1:n_vars) {
    a <- UncertParams$a[i]
    b <- UncertParams$b[i]
    c <- UncertParams$c[i]
    
    # Select the Distribution to use to generate the parameter values.
    # If applicable, make sure all samples are equal to or greater than zero.
    if (UncertParams$Distribution[i] == "Triangular") {
      samples <- triangular_cdf_inv(lhs_samples_vars[, i], a, b, c)
    }
    if (UncertParams$Distribution[i] == "Normal") {
      samples <- normal_pdf(lhs_samples_vars[,i], b, c)
      samples[samples <= 0] <- a
    }
    if (UncertParams$Distribution[i] == "Log normal") {
      samples <- LogNormal_pdf(lhs_samples_vars[, i], b, c)
      samples[samples <= 0] <- a
    }
    if (UncertParams$Distribution[i] == "Weibull") {
      samples <- Weibull_pdf(lhs_samples_vars[, i], a, b, c)
    }
    
    # Failsafe in case no valid distribution type is passed.
    if (!(UncertParams$Distribution[i] %in% Available_Distributions)) {
      d <- first(na.omit(c(c, a, b)))
      samples <- rep(d, Run_count)
      message(sprintf("No valid Distribution detected for %s. Resorting to using Fixed value %f",
                      UncertParams$varName[i], d))
    }
    
    # Store the generated list of new input parameters.
    new_data <- tibble(value = samples)
    UncertParams$data[[i]] <- new_data
  }
} 

# Failsafe in case all parameters are using a fixed distribution.
for (i in Substances[!(Substances %in% UncertParams$Substance)]) {
  index <- match(i, FixedParams$Substance)
  # Failsafe if there are no parameters specific to a particular substance
  if (is.na(index)) {
    match(NA, FixedParams$Substance)
  }
  samples <- rep(FixedParams$Waarde[index], Run_count)
  new_data <- tibble(value = samples)
  UncertParams <- add_row(UncertParams, tibble_row(varName = FixedParams$varName[index] ,
                                                   Substance = FixedParams$Substance[index],
                                                   Scale = FixedParams$Scale[index],
                                                   SubCompart = FixedParams$SubCompart[index],
                                                   data = list(new_data)
                                                   ))
  UncertParams <- UncertParams %>% distinct(.keep_all = TRUE)
}

# Calculate the values used in the uncertainty solver for Emissions
for (i in 1:n_emisscomps) {
  a <- Emiss$a[i]
  b <- Emiss$b[i]
  c <- Emiss$c[i]
  
  # Select the Distribution to use to generate the parameter values.
  # If applicable, make sure all samples are equal to or greater than zero.
  if (Emiss$Distribution[i] == "Triangular") {
    samples <- triangular_cdf_inv(lhs_samples_emis[, i], a, b, c)
  }
  if (Emiss$Distribution[i] == "Normal") {
    samples <- normal_pdf(lhs_samples_emis[,i], c, b)
    samples[samples <= 0] <- a
  }
  if (Emiss$Distribution[i] == "Log normal") {
    samples <- LogNormal_pdf(lhs_samples_emis[, i], c, b)
    samples[samples <= 0] <- a
  }
  if (Emiss$Distribution[i] == "Weibull") {
    samples <- Weibull_pdf(lhs_samples_emis[, i], a, b, c)
  }
  if (Emiss$Distribution[i] == "Fixed"){
    samples <- rep(c, Run_count)
  }
  
  # Failsafe in case no valid distribution type is passed.
  if (!(Emiss$Distribution[i] %in% Available_Distributions)) {
    d <- first(na.omit(c(c, a, b)))
    samples <- rep(d, Run_count)
    message(sprintf("No valid Distribution detected for %s emission. Resorting to using Fixed value %f",
                    Emiss$Substance[i], d))
  }
  
  # Store the generated list of new input Emissions.
  new_data <- tibble(value = samples)
  Emiss$Emis[[i]] <- new_data
}


# Generate samples for the Monitored concentration.
for (i in 1:n_MEC) {
  a <- ifelse(is.na(MEC_In$a[i]), 1e-15, MEC_In$a[i])  
  b <- MEC_In$b[i]
  c <- MEC_In$c[i]
  
  # Select the Distribution to use to generate the parameter values.
  # If applicable, make sure all samples are equal to or greater than zero.
  if (MEC_In$Distribution[i] == "Triangular") {
    samples <- triangular_cdf_inv(lhs_samples_MEC[, i], a, b, c)
  }
  if (MEC_In$Distribution[i] == "Normal") {
    samples <- normal_pdf(lhs_samples_MEC[,i], c, b)
    samples[samples <= 0] <- a
  }
  if (MEC_In$Distribution[i] == "Log normal") {
    samples <- LogNormal_pdf(lhs_samples_MEC[, i], c, b)
    samples[samples <= 0] <- a
  }
  if (MEC_In$Distribution[i] == "Weibull") {
    samples <- Weibull_pdf(lhs_samples_MEC[, i], a, b, c)
  }
  if (MEC_In$Distribution[i] == "Fixed"){
    samples <- rep(c, Run_count)
  }
  
  # Store the generated list of new input Emissions
  for (j in 1:Run_count) {
    MEC_Distributed <- add_row(MEC_Distributed,
                               Substance = MEC_In$Substance[i],
                               SubCompart = MEC_In$SubCompart[i],
                               RUN = j,
                               Value =samples[j])
  }
  
}

SubstanceCount <- length(UncertParams$varName)

# Record the subcompartments needed for the PEC:MEC calculations
MEC_compart <- unique(MEC_Distributed$SubCompart)

# For every Substance, complete the rest of the setup and run the model.
for (Substance in Substances) {
  
  start.time <- Sys.time()
  
  # For all parameters with a fixed value, set the relevant variables of the model.
  FixedParamsM <- FixedParams[FixedParams$Substance == Substance | is.na(FixedParams$Substance),]
  World$mutateVars(FixedParamsM)
  
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
  
  
  # Set the solver and prepare its input arguments
  World$NewSolver("UncertainSolver")
  UncertParamsM <- UncertParams[UncertParams$Substance == Substance | is.na(UncertParams$Substance),]
  EmissM <- Emiss[Emiss$Substance == Substance,]
  
  # Solve the matrix
  solved <- World$Solve(EmissM, needdebug = F, UncertParamsM)
  
  # Extract all regional Concentrations from the model.
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
  
  
  # Extract the Concentrations needed for the PEC:MEC ratio calculations.
  for (MEC_subcompart in MEC_compart) {
    for (i in which(Concentrations_full$SubCompart == MEC_subcompart)) {
      Conc_calc <- add_row(Conc_calc, tibble_row(Substance = Substance,
                                                 SubCompart = MEC_subcompart,
                                                 RUN = Concentrations_full$RUN[i],
                                                 Value = Concentrations_full$Concentration[i]))
    }
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


# Calculate the PEC:MEC ratios.
PECMEC <- tibble(Substance = Conc_calc$Substance,
                 SubCompart = Conc_calc$SubCompart,
                 RUN = Conc_calc$RUN,
                 PEC = Conc_calc$Value,
                 MEC = MEC_Distributed$Value,
                 PECMEC = Conc_calc$Value/MEC_Distributed$Value)

Subcomparts <- unique(PECMEC$SubCompart)


# Calculate PEC:MEC ratio statistics
for (Substance in Substances) {
  for (SubCompart in Subcomparts){
    index <- which(PECMEC$Substance == Substance & PECMEC$SubCompart == SubCompart)
    if (!is.na(index[1])) {
      PEC_min <- min(PECMEC$PEC[index])
      PEC_quant25 <- quantile(PECMEC$PEC[index], 0.25)
      PEC_median <- median(PECMEC$PEC[index])
      PEC_quant75 <- quantile(PECMEC$PEC[index], 0.75)
      PEC_max <- max(PECMEC$PEC[index])
      MEC_min <- min(PECMEC$MEC[index])
      MEC_quant25 <- quantile(PECMEC$MEC[index], 0.25)
      MEC_median <- median(PECMEC$MEC[index])
      MEC_quant75 <- quantile(PECMEC$MEC[index], 0.75)
      MEC_max <- max(PECMEC$MEC[index])
      PECMEC_min <- min(PECMEC$PECMEC[index])
      PECMEC_quant25 <- quantile(PECMEC$PECMEC[index], 0.25)
      PECMEC_median <- median(PECMEC$PECMEC[index])
      PECMEC_quant75 <- quantile(PECMEC$PECMEC[index], 0.75)
      PECMEC_max <- max(PECMEC$PECMEC[index])
      
      PECMEC_statistics <- add_row(PECMEC_statistics, tibble_row(Substance = Substance,
                                                                 SubCompart = SubCompart,
                                                                 PEC_Min = PEC_min,
                                                                 PEC_Quant25 = PEC_quant25,
                                                                 PEC_Median = PEC_median,
                                                                 PEC_Quant75 = PEC_quant75,
                                                                 PEC_Max = PEC_max,
                                                                 MEC_Min = MEC_min,
                                                                 MEC_Quant25 = MEC_quant25,
                                                                 MEC_Median = MEC_median,
                                                                 MEC_Quant75 = MEC_quant75,
                                                                 MEC_Max = MEC_max,
                                                                 "PEC:MEC_Min" = PECMEC_min,
                                                                 "PEC:MEC_Quant25" = PECMEC_quant25,
                                                                 "PEC:MEC_Median" = PECMEC_median,
                                                                 "PEC:MEC_Quant75" = PECMEC_quant75,
                                                                 "PEC:MEC_Max" = PECMEC_max))
      
    }
  }
}


# Export the PEC, MEC, PEC:MEC and their statistics into an Excel file. This file is created in
# the same directory as the input file.
f_name <- str_split_i(inoutname, "/", -1)
outname <- str_replace(inoutname, f_name, "SB_OO_Output.xlsx")
write.xlsx(list("PECMEC raw" = PECMEC, "PECMEC statistics" = PECMEC_statistics), outname)





PECMEC <- mutate(PECMEC, S_SC = paste(Substance, SubCompart, sep = " - "))
df <- PECMEC %>% pivot_longer(cols = c("PEC", "MEC"), names_to = 'PM', values_to = 'Conc')

# Violin plots comparing modelled and predicted concentrations
ggplot(df, aes(x= S_SC, y=Conc, fill =PM)) + geom_violin(scale="width") +
  geom_boxplot(width=0.2, outliers = FALSE, position = position_dodge(width = 0.9)) +
  scale_y_continuous(trans="log10") +
  theme(axis.text.x = element_text(angle=90, hjust=1,vjust=0.5),
        axis.title.x = element_blank(),
        legend.title = element_blank()) +
  ylab("Concentration") +
  scale_fill_manual(values=c("lightsalmon", "lightskyblue"), labels = c("Monitored","Modelled"))


# Violin plots showing the ratio between modelled and predicted concentrations
ggplot(df, aes(x= S_SC, y=PECMEC, colour = Substance)) + geom_violin(scale="width") +
  geom_boxplot(width=0.2, outliers = TRUE, outlier.size = 0.2, position = position_dodge(width = 0.9), colour = "gray30") +
  scale_y_continuous(trans="log10") +
  theme(axis.text.x = element_text(angle=90, hjust=1,vjust=0.5),
        axis.title.x = element_blank(),
        legend.title = element_blank()) +
  ylab("Concentration") +
  scale_fill_hue(labels = c("Monitored Concentrations","Modelled Concentrations")) +
  geom_hline(yintercept = 1, linetype="dashed", colour="black")




# Sensitivity analysis. Seems unstable with negative values.

UncertParamsM <- UncertParamsM %>% mutate(varName_full  = paste(varName,Scale,SubCompart, sep = "_"))
UncertParams <- UncertParams %>% mutate(varName_full  = paste(varName,Scale,SubCompart, sep = "_"))
Sens_idices <- tibble(UncertParam = c(unique(UncertParams$varName_full), "Emission" ))
for (Substance in Substances) {
  
  for (SubCompart in Subcomparts) {
    
    if (!is.na(which(Conc_calc$Substance==Substance & Conc_calc$SubCompart==SubCompart)[1])) {
      
      UncertParamsM <- UncertParams[UncertParams$Substance == Substance | is.na(UncertParams$Substance),]
      UncertParamsM <- UncertParamsM %>% mutate(varName_full  = paste(varName,Scale,SubCompart, sep = "_"))
      EmissM <- Emiss[Emiss$Substance == Substance,]
      
      
      GSA_table <- tibble(RUN = seq(Run_count))
      for (i in seq(nrow(UncertParamsM))) {
        GSA_table <- GSA_table %>% mutate("{UncertParamsM$varName_full[i]}" := as.numeric(UncertParamsM$data[[i]][[1]]))

      }
      
      for (i in seq(nrow(EmissM))){
        Emiss_name <- paste("Emission",Substance,EmissM$Abbr[i], sep="_")
        GSA_table <- GSA_table %>% add_column("{Emiss_name}" := as.numeric(EmissM$Emis[[i]][[1]]))
      }
      
      Conc_name <- paste("Concentration",Substance,SubCompart, sep="_")
      GSA_table <- add_column(GSA_table, "{Conc_name}" := Conc_calc$Value[which(Conc_calc$Substance == Substance & Conc_calc$SubCompart==SubCompart)])
      
      
      
      GSA_data <- GSA_table
      

      
      id_identical_columns <- function(df) {
        # Get all column combinations
        column_pairs <- combn(names(df), 2, simplify = FALSE)
        
        # Find identical columns
        identical_columns <- sapply(column_pairs, function(pair) {
          all(df[[pair[1]]] == df[[pair[2]]])
        })
        if(any(identical_columns)){
          warning("Columns:",unique(unlist(column_pairs[identical_columns])),
                  "are not unique. Only use distinct distributions.")}else print("All fine")
        # Get unique columns to keep
      }
      
      probX_Y <-
        GSA_data |> ungroup() |> 
        drop_na() |> 
        mutate(RUN = NULL) |> # remove collumns that are not numeric data for probX
        mutate_all(~if_else(. == 0, 1e-20, .)) |> # make 0's very small numbers 1e-20
        mutate_all(log) |> # log transform
        drop_na() |> # drop any rows with NA's
        select(-where(~ var(.) == 0))# remove columns with 0 variance (are constant)
      
      
      id_identical_columns(probX_Y)
      
      probX <- probX_Y |> 
        mutate("{paste('Concentration', Substance, SubCompart, sep='_')}" := NULL) |> 
        data.matrix()
      probY <- probX_Y |> 
        pull(paste('Concentration',Substance,SubCompart, sep="_") )
      
      #run global sensitivity analysis
      m <- sensiFdiv(model = NULL, X=probX, fdiv = "TV", nboot = 0, conf = 0.95,   scale = TRUE)
      tell(m, y=probY,S)
      
      # ggplot(m, ylim = c(0, 1))
      #prepare output for ggplot
      borg_d_temp <- tibble(TC = colnames(probX),
                            delta= m$S$original)
      
      
      
      reorder(borg_d_temp$TC, borg_d_temp$delta)
      
      Sensplot <- ggplot(borg_d_temp, aes(x = delta,reorder(TC,delta))) + geom_bar(stat="identity")+
        theme_light()+
        theme(axis.text.y = element_text(size = 10),
              axis.title.y = element_blank(),
              # plot.background = element_blank(),
              panel.grid.major = element_blank(),
              panel.grid.minor = element_blank(),
              panel.border = element_blank())
      
      #plot(probX_Y)
      
      Sens_idices <- add_column(Sens_idices, "{paste(Substance,SubCompart,sep='_')}" := borg_d_temp$delta)
    }
  }
}

test <- colnames(Sens_idices)[-1]
df <- Sens_idices %>% pivot_longer(cols = test, names_to = "Substance", values_to = "Indices")

# Generate Heatmap for sensitivity analysis
print(ggplot(df, aes(x=factor(Substance, level=unique(Substance)), y=factor(UncertParam, level = rev(unique(UncertParam))), fill=Indices))+ 
        geom_tile(colour="white")+
        scale_fill_gradient(low="white", high = "red")+
        labs(x="Sub-compartiment + phase", y="Uncertain Parameters")+
        theme(axis.text.x = element_text(angle=45, hjust=1)))

