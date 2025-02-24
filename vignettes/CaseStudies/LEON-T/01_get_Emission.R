################################################################################
# Script for combining DPMFA output from two scales for Tyre Wear and other    #
# microplastic sources                                                         #
# Created for LEON-T Deliverable 3.5                                           #
# Authors: Anne Hids and Joris Quik                                            #
# RIVM                                                                         #
# 4-12-2024                                                                    #
################################################################################

# Initialize
source("vignettes/CaseStudies/LEON-T/f_Emission4SB.R")

### initialize ###

# Specify the environment
env <- "OOD"
# env <- "local"

if(env == "local"){
  abspath_EU = "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_EU.RData"
  abspath_NL = "R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_NL.RData"
} else if(env == "OOD"){
  abspath_EU = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_EU.RData"
  abspath_NL = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_NL.RData"
}

source_of_interest = "Tyre wear"

DPMFA_SBoutput <- Load_DPMFA4SB(abspath_EU = abspath_EU, 
                                abspath_NL = abspath_NL,
                                source_of_interest = source_of_interest,
                                path_parameters_file = "vignettes/CaseStudies/LEON-T/Microplastic_variables_v1.1c.xlsx",
                                TESTING = FALSE)

# DPMFA_sink_micro <- DPMFA_SBoutput$DPMFA_sink_micro

if(!is.na(source_of_interest) && source_of_interest == "Tyre wear"){
  NR_SBR_fractions <- DPMFA_SBoutput$NR_SBR_fractions
}

if(env == "local"){
  save(DPMFA_SBoutput, NR_SBR_fractions, file = paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_", 
                                                       format(Sys.Date(),"%Y%m%d"),".RData"))
} else if(env == "OOD"){
  save(DPMFA_SBoutput, NR_SBR_fractions, file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_TWP_", 
                                                       format(Sys.Date(),"%Y%m%d"),".RData"))
}

source_of_interest = NA
DPMFA_SBoutput <- Load_DPMFA4SB(abspath_EU = abspath_EU, 
                                abspath_NL = abspath_NL,
                                source_of_interest = source_of_interest,
                                path_parameters_file = "vignettes/CaseStudies/LEON-T/Microplastic_variables_v1.1c.xlsx",
                                TESTING = FALSE)

# DPMFA_sink_micro <- DPMFA_SBoutput$DPMFA_sink_micro

if(env == "local"){
  save(DPMFA_SBoutput, file = paste0("R:/Projecten/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_Other_", 
                                     format(Sys.Date(),"%Y%m%d"),".RData"))
} else if(env == "OOD"){
  save(DPMFA_SBoutput, file = paste0("/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFAoutput_LEON-T_D3.5_Other_", 
                                     format(Sys.Date(),"%Y%m%d"),".RData"))
}

