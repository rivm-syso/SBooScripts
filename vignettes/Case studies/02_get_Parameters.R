# creating distributions for SB parameters

source_of_interest =  "Tyre wear"
source("baseScripts/initWorld_onlyPlastics.R")

if(!is.na(source_of_interest) && length(source_of_interest) == 1 && source_of_interest == "Tyre wear") {
  World$substance <- "TRWP"
} else {
  World$substance <- "microplastic"
}

## Get the parameters, Parameters object needed for further solving using SB
Parameters <- read_Prob4SB(path_parameters_file = "vignettes/Case studies/CaseData/Microplastic_variables_v1.xlsx",
                           source_of_interest=source_of_interest,
                           n_samples = nrow(DPMFA_sink_micro$Emis[[1]]), # Number of emission runs 
                           # materials <- unique(Material_Parameters$Polymer)
                           materials = unique(DPMFA_sink_micro$Polymer), # materials in selected sources
                           scales = union((World$FromDataAndTo()$fromScale),(World$FromDataAndTo()$toScale)),
                           subCompartments =  union((World$FromDataAndTo()$fromSubCompart),(World$FromDataAndTo()$toSubCompart)),
                           species = union((World$FromDataAndTo()$fromSpecies),(World$FromDataAndTo()$toSpecies))
)
