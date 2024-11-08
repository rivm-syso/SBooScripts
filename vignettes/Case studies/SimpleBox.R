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


RUNSamples = c(11:20)

subsetRuns <- function(dfRUNs,nummers){
  dfRUNs |> filter(RUN == nummers)
}
Sel_DPMFA_micro <-
  DPMFA_sink_micro |> 
  mutate(Emis = map(Emis, subsetRuns,nummers=RUNSamples))

source_of_interest =  "Tyre wear"
  source("baseScripts/initWorld_onlyPlastics.R")

if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
  World$substance <- "TRWP"
} else {
  World$substance <- "microplastic"
}

Parameters <- read_Prob4SB(path_parameters_file = "vignettes/Case studies/CaseData/Microplastic_variables_v1.xlsx",
                           source_of_interest=source_of_interest,
                           n_samples = nrow(DPMFA_sink_micro$Emis[[1]]), # Number of emission runs 
                           # materials <- unique(Material_Parameters$Polymer)
                           materials = unique(DPMFA_sink_micro$Polymer), # materials in selected sources
                           scales = union((World$FromDataAndTo()$fromScale),(World$FromDataAndTo()$toScale)),
                           subCompartments =  union((World$FromDataAndTo()$fromSubCompart),(World$FromDataAndTo()$toSubCompart)),
                           species = union((World$FromDataAndTo()$fromSpecies),(World$FromDataAndTo()$toSpecies))
)


Regional_Parameters <- read_excel(path_parameters_file, sheet = "Netherlands_data") |>
  rename(varName = Variable) |>
  rename(Waarde = Value) |>
  select(-Unit) 

# Recalculate the area's
World$mutateVars(Regional_Parameters)
World$UpdateDirty(unique(Regional_Parameters$varName))

# Filter out emission subcompartments for which SimpleBox does not have a compartment (yet)
DPMFA_sink_micro <-
  DPMFA_sink_micro |> filter(Subcompartment %in% World$fetchData("AbbrC")$AbbrC)
start_time <- Sys.time()

Output <- tibble(Polymer = polymers, 
                 SBoutput = NA)


World$NewSolver("UncertainDynamicSolver")
tmax <- max(DPMFA_sink_micro$Timed)

for(pol in polymers){
  emis_source <- DPMFA_sink_micro |>
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


end_time <- Sys.time()

elapsed_time <- end_time - start_time

print(paste0("Elapsed time is ", elapsed_time))