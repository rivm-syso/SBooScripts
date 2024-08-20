substance <- "microplastic"
source("baseScripts/initWorld_onlyPlastics.R")
World$substance <- substance

# Voorbeeld met dataframe
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS"), Emis = c(10000, 10000, 10000), Timed = c(1, 2, 3) ) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000) |>           # Don't divide the emissions by seconds when using this solver!!
  mutate(Timed = (Timed*(365*24*60*60)))

World$NewSolver("EventSolver")

solved <- World$Solve(emissions, needdebug = F)