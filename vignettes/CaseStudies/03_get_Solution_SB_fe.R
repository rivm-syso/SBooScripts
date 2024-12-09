############
# SimpleBox preparation
#
###########
path_parameters_file = "vignettes/CaseStudies/CaseData/Microplastic_variables_v1.xlsx"

###############################
# # Code to be able to use batch computation             
library(foreach)
library(parallel)

# ################################
library(tidyverse)
# Requirements:
#   DPMFA_sink_micro with n samples
#   Parameters with n samples

load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241110.RData"))
load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_20241110.RData"))
# load(paste0("vignettes/CaseStudies/CaseData/DPMFAoutput_LEON-T_D3.5_TWP_20241110.RData"))
# load(paste0("vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_TWP_20241110.RData"))


batch_n = 2
batch_max = 8
RUNs <- tibble(RUN2 = seq(batch_n,batch_max,batch_n))
RUNs <-
  RUNs |> mutate(RUN1 = RUN2-(batch_n-1))

registerDoParallel(3)  # use multicore, set to the number of our cores
start_time <- Sys.time() # to see how long it all takes...
SBout_fe <- foreach(n = 1:length(RUNs$RUN1) ) %dopar% {
  RUNSamples = RUNs$RUN1[n]:RUNs$RUN2[n]
  ### initialize ###
  source_of_interest =  "Tyre wear"
  source("baseScripts/initWorld_onlyPlastics.R")
  
  if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
    World$substance <- "TRWP"
  } else {
    World$substance <- "microplastic"
  }
  ### end initialize ###
  
  
  #### Select subset of RUNs from emission and parameters ####
  # RUNSamples = c(1:3) #  Set the runs that need to be run, should be consequetive from x to y.
  ##
  subsetRuns <- function(dfRUNs,nummers){ #Function to select RUNsamples from emision data
    dfRUNs |> filter(RUN == nummers)
  }
  subsetRuns2 <- function(dfRUNs,nummers){ #Function to select RUNsamples from parameter data
    dfRUNs[nummers,]
  }
  # Filter out emission subcompartments for which SimpleBox does not have a compartment (yet)
  Sel_DPMFA_micro <-
    DPMFA_SBoutput$DPMFA_sink_micro |> filter(Subcompartment %in% World$fetchData("AbbrC")$AbbrC) |> 
    mutate(Emis = map(Emis, subsetRuns2,nummers=RUNSamples))
  Material_Parameters_n <- Parameters$Material_Parameters_n |> 
    mutate(data = map(data, subsetRuns2, nummers = RUNSamples))
  
  #### Get SB World ####
  # Read in data to change Regional scale to fit NL scale DPMFA data
  Regional_Parameters <- readxl::read_excel(path_parameters_file, sheet = "Netherlands_data") |>
    rename(varName = Variable) |>
    rename(Waarde = Value) |>
    select(-Unit) 
  
  # Recalculate the area's
  World$mutateVars(Regional_Parameters)
  World$UpdateDirty(unique(Regional_Parameters$varName))
  
  # empty tibble for storing output for all runs:
  Output <- tibble(Polymer = unique(Sel_DPMFA_micro$Polymer), 
                   SBoutput = NA)
  

  
  World$NewSolver("UncertainDynamicSolver")
  tmax <- max(Sel_DPMFA_micro$Timed)
  for(pol in unique(Sel_DPMFA_micro$Polymer)){
    emis_source <- Sel_DPMFA_micro |>
      filter(Polymer == pol) |>
      select(Abbr, Timed, Emis)
    
    sample_source <- Material_Parameters_n |>
      filter(Polymer == pol) |>
      select(VarName, Scale, SubCompart, Species, data) |> 
      rename(varName = VarName)
    
    solved <- World$Solve((emis_source), sample_source, tmax = tmax, needdebug = F)
    solved$DynamicConc <- World$GetConcentration()
    
    Output$SBoutput[Output$Polymer == pol] <- list(solved)
    
    list(Output,RUNSamples,Sel_DPMFA_micro,Material_Parameters_n)
  }
  
  
  
}

elapsed_time <- Sys.time() - start_time
print(paste0("Elapsed time is ", elapsed_time))

save(SBout_fe, elapsed_time,
     file = paste0("vignettes/CaseStudies/CaseData/SBoutput_fe_TWP", 
                   min(RUNs$RUN1), "_", max(RUNs$RUN2) , "_RUNS_", format(Sys.Date(),"%Y_%m_%d"),".RData"),
     compress = "xz",
     compression_level = 9)  
