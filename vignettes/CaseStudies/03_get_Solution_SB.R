############
# SimpleBox preparation
#
###########

### initialize ###
library(tidyverse)

# Specify the environment
env <- "OOD"
#env <- "local"
#env <- "HPC"

# Specify the source
source_of_interest <- "Tyre wear"

if(env == "local"){
  setwd("N:/Documents/GitHub/SimpleBox/SBooScripts")
} else if(env == "OOD"){
  # setwd("/rivm/n/hidsa/Documents/GitHub/SimpleBox/SBooScripts") # please work in R studion projects with git! This resolves the need for these type of setwd.
} else if(env == "HPC"){
  mainfolder <- "/data/BioGrid/hidsa/SimpleBox/SBooScripts/"
}

if(env == "local"){
  path_parameters_file = "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Microplastic_variables_v1.xlsx"
} else if(env == "OOD"){
  path_parameters_file = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Microplastic_variables_v1.xlsx"
} else if(env == "HPC"){
  path_parameters_file = paste0(mainfolder, "vignettes/CaseStudies/CaseData/Microplastic_variables_v1.xlsx")
}

# ################################
# Requirements:
#   DPMFA_sink_micro with n samples
#   Parameters with n samples

if(env == "Local"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
    load(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_20241126.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
    load(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_Other_20241126.RData"))
  }
} else if(env == "OOD"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_20241126.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_Other_20241126.RData"))
  }
} else if(env == "HPC"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_TWP_20241126.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_Other_20241126.RData"))
  }
}

if(env == "OOD" | env == "local"){
  source("baseScripts/initWorld_onlyPlastics.R")
} else if(env == "HPC"){
  source(paste0(mainfolder, "baseScripts/initWorld_onlyPlastics.R"))
}

if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
  World$substance <- "TRWP"
} else {
  World$substance <- "microplastic"
}
### end initialize ###

#### Select subset of RUNs from emission and parameters ####
#  Set the runs that need to be run, should be consequetive from x to y.
RUNSamples = c(711:761)
print(paste("LOG: run started for", min(RUNSamples), "to", max(RUNSamples)))
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

start_time <- Sys.time() # to see how long it all takes...

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
}

elapsed_time <- Sys.time() - start_time
print(elapsed_time)
# print(paste0("Elapsed time is ", elapsed_time))

# Save the outcome 
if(env == "local"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    save(Output, Sel_DPMFA_micro, Material_Parameters_n, elapsed_time,
         file = paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/SBout_TWP", 
                       "_RUNS_",min(RUNSamples), "_", max(RUNSamples),"_" , "v1.RData"),
         compress = "xz",
         compression_level = 9)
  } else if(is.na(source_of_interest)){
    save(Output, Sel_DPMFA_micro, Material_Parameters_n, elapsed_time,
         file = paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/SBout_Other", 
                       "_RUNS_",min(RUNSamples), "_", max(RUNSamples),"_" , "v1.RData"),
         compress = "xz",
         compression_level = 9)
  }
} else if(env == "OOD"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    save(Output, Sel_DPMFA_micro, Material_Parameters_n, elapsed_time,
         file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/SBout_LEONT_TWP", 
                       "_RUNS_",min(RUNSamples), "_", max(RUNSamples),"_" , "v1.RData"),
         compress = "xz",
         compression_level = 9) 
  } else if(is.na(source_of_interest)){
    save(Output, Sel_DPMFA_micro, Material_Parameters_n, elapsed_time,
         file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/SBout_Other", 
                       "_RUNS_",min(RUNSamples), "_", max(RUNSamples),"_" , "v1.RData"),
         compress = "xz",
         compression_level = 9) 
  }
} else if(env == "HPC"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    save(Output, Sel_DPMFA_micro, Material_Parameters_n, elapsed_time,
         file = paste0(mainfolder, "vignettes/CaseStudies/LEON-T_output/SBout_LEONT_TWP",
                       "_RUNS_",min(RUNSamples), "_", max(RUNSamples),"_v1_HPC.RData"),
         compress = "xz",
         compression_level = 9)  
  } else {
    save(Output, Sel_DPMFA_micro, Material_Parameters_n, elapsed_time,
         file = paste0(mainfolder, "vignettes/CaseStudies/LEON-T_output/SBout_LEONT_Other",
                       "_RUNS_",min(RUNSamples), "_", max(RUNSamples),"_v1_HPC.RData"),
         compress = "xz",
         compression_level = 9)  
  }
}