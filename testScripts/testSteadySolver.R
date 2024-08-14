substance <- "microplastic"
source("baseScripts/initWorld_onlyPlastics.R")
World$substance <- substance

# Voorbeeld met dataframe
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 

World$NewSolver("SB1Solve")

solved <- World$Solve(emissions)
