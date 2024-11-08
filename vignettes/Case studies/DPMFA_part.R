### DPMFA part 2


source("vignettes/Case studies/read_DPMFA4SB.R")
# source("vignettes/Case studies/ProbDistributionFun.R")

DPMFA_sink_micro <- Load_DPMFA4SB(abspath_EU = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_EU.RData", 
                                  abspath_NL = "/rivm/r/E121554 LEON-T/03 - uitvoering WP3/Deliverable 3.5/DPMFA_NL.RData",
                                  source_of_interest = "Tyre wear",
                                  path_parameters_file = "vignettes/Case studies/CaseData/Microplastic_variables_v1.xlsx",
                                  TESTING = FALSE)


