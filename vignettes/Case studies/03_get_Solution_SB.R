############
# SimpleBox preparation
#
###########
# path_parameters_file = "vignettes/Case studies/CaseData/Microplastic_variables_v1.xlsx",

###############################
# # Code to be able to use batch computation             
# library("batch")
# parseCommandArgs()
# set.seed(seed)
# ################################

# Requirements:
#   DPMFA_sink_micro with n samples
#   Parameters with n samples

load(paste0("vignettes/Case studies/Casedata/DPMFAoutput_LEON-T_D3.5_TWP20241110.RData"))
load(paste0("vignettes/Case studies/Casedata/Parameters_LEON-T_D3.5_TWP20241110.RData"))

#### Select subset of RUNs from emission and parameters ####
RUNSamples = c(1:3) #  Set the runs that need to be run, should be consequetive from x to y.
##
subsetRuns <- function(dfRUNs,nummers){ #Function to select RUNsamples from emision data
  dfRUNs |> filter(RUN == nummers)
}
# Filter out emission subcompartments for which SimpleBox does not have a compartment (yet)
Sel_DPMFA_micro <-
  DPMFA_sink_micro |> filter(Subcompartment %in% World$fetchData("AbbrC")$AbbrC) |> 
  mutate(Emis = map(Emis, subsetRuns,nummers=RUNSamples))

subsetRuns2 <- function(dfRUNs,nummers){ #Function to select RUNsamples from parameter data
  dfRUNs[nummers,]
}
Material_Parameters_n <- Parameters$Material_Parameters_n |> 
  mutate(data = map(data, subsetRuns2, nummers = RUNSamples))

#### Get SB World ####


### initialize ###
source_of_interest =  "Tyre wear"
source("baseScripts/initWorld_onlyPlastics.R")

if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
  World$substance <- "TRWP"
} else {
  World$substance <- "microplastic"
}
### end initialize ###

# Read in data to change Regional scale to fit NL scale DPMFA data
Regional_Parameters <- read_excel(path_parameters_file, sheet = "Netherlands_data") |>
  rename(varName = Variable) |>
  rename(Waarde = Value) |>
  select(-Unit) 

# Recalculate the area's
World$mutateVars(Regional_Parameters)
World$UpdateDirty(unique(Regional_Parameters$varName))

# empty tibble for storing output for all runs:
Output <- tibble(Polymer = unique(DPMFA_sink_micro$Polymer), 
                 SBoutput = NA)

start_time <- Sys.time() # to see how long it all takes...

World$NewSolver("UncertainDynamicSolver")
tmax <- max(DPMFA_sink_micro$Timed)
for(pol in unique(DPMFA_sink_micro$Polymer)){
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
print(paste0("Elapsed time is ", elapsed_time))


save(Output, NR_SBR_fractions, Parameters, elapsed_time,
     file = paste0("vignettes/Case studies/CaseData/SBoutput_LEON-T_D3.5_TWP", 
                   min(RUNSamples), "_", max(RUNSamples) , "_RUNS_", format(Sys.Date(),"%Y_%m_%d"),".RData"),
     compress = "xz",
     compression_level = 9)  
