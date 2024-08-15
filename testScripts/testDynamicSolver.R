substance <- "microplastic"
source("baseScripts/initWorld_onlyPlastics.R")
World$substance <- substance

# Voorbeeld met dataframe
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), Emis = c(10000, 10000, 10000), Timed = c(1, 2, 3) ) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) |>
  mutate(Timed = (Timed*(365*24*60*60)- (365*24*60*60)))

World$NewSolver("SBsolve")

solved <- World$Solve(emissions, needdebug = F)
