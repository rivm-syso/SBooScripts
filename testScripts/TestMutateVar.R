
#create World as SBcore
source("baseScripts/initWorld_onlyParticulate.R")

TotalArea <- data.frame(
  Scale = c("Arctic", "Continental", "Moderate", "Regional"),
  TotalArea = c(4.25E+13, 7.43E+12, 8.50E+13, 4.13e+11)
)

Temperature <- data.frame(
  Scale = "Regional", 
  Temp = 279
)

RAINrate <- data.frame(
  Scale = "Arctic",
  RAINrate = 4.37e-5
)
dfs <- list(TotalArea, Temperature, RAINrate)
for (i in seq_along(dfs)) {
  dfs[[i]] <- World$mutateVar(dfs[[i]])
}
#add emission and the solver for uncertainty
emissions <- data.frame(Abbr = "aRU", Emis = 1)
World$NewSolver("vUncertain")
World$fetchData("RadS")
World$fetchData("RAINrate")
#
vnamesDSD <- data.frame(
  vnames = "RadS",
  distNames = "uniform",  #see lhs package for possible distributions; q[dist] function should also exist and be implemented in vUncertain
  secondPar = 1e-7,
  Scale = c(NA)
)


SolRet <- World$Solve(needdebug = F, #set to T if you want to see the solver at work
                      emissions,     #all solvers need emissions
                      vnamesDistSD = vnamesDSD,  #specific for this solver, see example frame right above
                      n = 100, 
                      tol = 1e-30)         #number of samples

World$fetchData("RadS")
