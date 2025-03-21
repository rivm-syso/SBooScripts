################################################################################
# Script for running SimpleBox                                                 #
# Created for LEON-T Deliverable 3.5                                           #
# Authors: Anne Hids and Joris Quik                                            #
# RIVM                                                                         #
# 4-12-2024                                                                    #
################################################################################

### Initialize ###########################################################################################################
library(tidyverse)

# Specify the environment
#env <- "Local"
#env <- "OOD"
#env <- "HPC"
env <- "OOD_BioGrid_mellinky"

# Specify the source
source_of_interest <- NA

if(env == "OOD" | env == "local"){
  path_parameters_file = "vignettes/CaseStudies/LEON-T/Microplastic_variables_v1.1c.xlsx"
} else if(env == "HPC"){
  mainfolder <- "/data/BioGrid/hidsa/SimpleBox/SBooScripts/"
  path_parameters_file = paste0(mainfolder, "vignettes/CaseStudies/LEON-T/Microplastic_variables_v1.1c.xlsx")
} else if(env == "OOD_BioGrid_mellinky"){
  # mainfolder <- "/data/BioGrid/mellinky/SimpleBox/SBooScripts/"
  path_parameters_file = paste0("vignettes/CaseStudies/LEON-T/Microplastic_variables_v1.1c.xlsx")
}

# ################################
# Requirements:
#   The R object "DPMFA_sink_micro" with n samples
#   The R object "Parameters" with n samples

if(env == "Local"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
    load(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_20241127.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
    load(paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_Other_20241127.RData"))
  }
} else if(env == "OOD"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_20241127.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
    load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_Other_20241127.RData"))
  }
} else if(env == "HPC"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_TWP_20241127.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
    load(paste0(mainfolder, "vignettes/CaseStudies/CaseData/Parameters_LEON-T_D3.5_Other_20241127.RData"))
  }
} else if(env == "OOD_BioGrid_mellinky"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    load(paste0("/data/BioGrid/mellinky/LEONT_files/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
    load(paste0("/data/BioGrid/mellinky/LEONT_files/Parameters_LEON-T_D3.5_TWP_20250224.RData"))
  } else if(is.na(source_of_interest)){
    load(paste0("/data/BioGrid/mellinky/LEONT_files/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
    load(paste0("/data/BioGrid/mellinky/LEONT_files/Parameters_LEON-T_D3.5_Other_20250224.RData"))
  }
}

if(env == "OOD" | env == "local"){
  source("baseScripts/initWorld_onlyPlastics.R")
} else if(env == "HPC"){
  source(paste0(mainfolder, "baseScripts/initWorld_onlyPlastics.R"))
} else if(env == "OOD_BioGrid_mellinky"){
  source(paste0("baseScripts/initWorld_onlyPlastics.R"))
}

if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
  World$substance <- "TRWP"
} else {
  World$substance <- "microplastic"
}

### End initialize #######################################################################################################

#### Select subset of RUNs from emission and parameters ##################################################################

#  Set the runs that need to be run, should be consequetive from x to y.
RUNSamples = c(131:132)

print(paste("LOG: run started for", min(RUNSamples), "to", max(RUNSamples)))

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

##########################################################################################################################

#### Get SB World ########################################################################################################

# Read data to change Regional scale to fit NL scale DPMFA data
Regional_Parameters <- readxl::read_excel(path_parameters_file, sheet = "Netherlands_data") |>
  rename(varName = Variable) |>
  rename(Waarde  = Value) |>
  select(-Unit) 

# Recalculate the area's
World$mutateVars(Regional_Parameters)
World$UpdateDirty(unique(Regional_Parameters$varName))

# Empty tibble for storing output for all runs:
Output <- tibble(Polymer  = unique(Sel_DPMFA_micro$Polymer), 
                 SBoutput = NA)

start_time <- Sys.time() # to see how long it all takes...

World$NewSolver("UncertainDynamicSolver")

# tmax <- max(Sel_DPMFA_micro$Timed)

for(pol in unique(Sel_DPMFA_micro$Polymer)){
  emis_source <- Sel_DPMFA_micro |>
    filter(Polymer == pol) |>
    select(Abbr, Timed, Emis)
  
  sample_source <- Material_Parameters_n |>
    filter(Polymer == pol) |>
    select(VarName, Scale, SubCompart, Species, data) |> 
    rename(varName = VarName)
  
  solved <- World$Solve((emis_source), sample_source, needdebug = F,
                        rtol_ode=1e-30, atol_ode = 0.5e-2)
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

