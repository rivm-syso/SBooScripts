### DPMFA part 2


source("vignettes/Case studies/f_Emission4SB.R")
# source("vignettes/Case studies/ProbDistributionFun.R")

DPMFA_SBoutput <- Load_DPMFA4SB(abspath_EU = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_EU.RData", 
                                  abspath_NL = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_NL.RData",
                                  source_of_interest = "Tyre wear",
                                  path_parameters_file = "vignettes/Case studies/CaseData/Microplastic_variables_v1.xlsx",
                                  TESTING = FALSE)


DPMFA_sink_micro <- DPMFA_SBoutput$DPMFA_sink_micro
NR_SBR_fractions <- DPMFA_SBoutput$NR_SBR_fractions

save(DPMFA_SBoutput, file = paste0("vignettes/Case studies/CaseData/DPMFAoutput_LEON-T_D3.5_TWP_", 
            format(Sys.Date(),"%Y%m%d"),".RData"))
