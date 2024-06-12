
#create World as SBcore
source("baseScripts/initWorld_onlyParticulate.R")

#add emission and the solver for uncertainty
emissions <- data.frame(Abbr = "aRU", Emis = 1000)
World$NewSolver("vUncertain")

#
vnamesDSD <- data.frame(
  vnames = c("Pvap25", "RAINrate"),
  distNames = "normal",  #see lhs package for possible distributions; q[dist] function should also exist and be implemented in vUncertain
  secondPar = 0.3,
  Scale = c(NA, "Regional")
)

SolRet <- World$Solve(needdebug = F, #set to T if you want to see the solver at work
                      emissions,     #all solvers need emissions
                      vnamesDistSD = vnamesDSD,  #specific for this solver, see example frame right above
                      n = 10)                    #number of samples