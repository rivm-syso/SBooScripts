
#create World as SBcore
source("baseScripts/initWorld_onlyParticulate.R")

# mutate Vars, 2 ways: a file or from a list of dataframes
World$mutateVars("testScripts/solvError.csv")

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

ToPaste <- lapply(list(TotalArea, Temperature, RAINrate), function(x) {
  varName <- names(x)[!names(x) %in% The3D]
  stopifnot(length(varName)==1)
  # one line with 2 disadvantages of tidyverse..:
  as.data.frame(pivot_longer(data = x, cols = all_of(varName), names_to = "varName", values_to = "Waarde"))
})
#and one advantage: bind_rows handles missing columns
dfs <- do.call(bind_rows, ToPaste)

World$mutateVars(dfs)

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
