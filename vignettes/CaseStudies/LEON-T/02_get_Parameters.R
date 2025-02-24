################################################################################
# Script for creating distributions for SimpleBox parameters                   #
# Created for LEON-T Deliverable 3.5                                           #
# Authors: Anne Hids and Joris Quik                                            #
# RIVM                                                                         #
# 4-12-2024                                                                    #
################################################################################
env <- "OOD"

source_of_interest =  NA

path_parameters_file = "vignettes/CaseStudies/LEON-T/Microplastic_variables_v1.1c.xlsx"

if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
  load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_20241126.RData"))
} else {
  load(paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_Other_20241126.RData"))
}

DPMFA_sink_micro <- DPMFA_SBoutput$DPMFA_sink_micro

source("baseScripts/initWorld_onlyPlastics.R")

if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
  World$substance <- "TRWP"
} else {
  World$substance <- "microplastic"
}

source("vignettes/CaseStudies/LEON-T/f_Parameters4SB.R")

## Get the parameters, Parameters object needed for further solving using SB
Parameters <- read_Prob4SB(path_parameters_file = path_parameters_file,
                           source_of_interest=source_of_interest,
                           n_samples = nrow(DPMFA_sink_micro$Emis[[1]]), # Number of emission runs 
                           materials = unique(DPMFA_sink_micro$Polymer), # materials in selected sources
                           scales = union((World$FromDataAndTo()$fromScale),(World$FromDataAndTo()$toScale)),
                           subCompartments =  union((World$FromDataAndTo()$fromSubCompart),(World$FromDataAndTo()$toSubCompart)),
                           species = union((World$FromDataAndTo()$fromSpecies),(World$FromDataAndTo()$toSpecies))
)

# Save the outcome 
if(env == "local"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    save(Parameters, 
         file = paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_", 
                       format(Sys.Date(),"%Y%m%d"),".RData"))
  } else if(is.na(source_of_interest)){
    save(Parameters, 
         file = paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_Other_", 
                       format(Sys.Date(),"%Y%m%d"),".RData"))
  }
} else if(env == "OOD"){
  if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
    save(Parameters, 
         file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_TWP_", 
                       format(Sys.Date(),"%Y%m%d"),".RData"))
  } else if(is.na(source_of_interest)){
    save(Parameters, 
         file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/Parameters_LEON-T_D3.5_Other_", 
                       format(Sys.Date(),"%Y%m%d"),".RData"))
  }
}
