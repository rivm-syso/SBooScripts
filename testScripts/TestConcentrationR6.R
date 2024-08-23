substance <- "default substance"
source("baseScripts/initWorld_onlyMolec.R")
World$substance <- substance

# Voorbeeld met dataframe
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s

MW <- World$fetchData("MW")

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 

World$NewSolver("SB1Solve")

solved2 <- World$Solve(emissions, needdebug = F)

sol <- World$Solution()
World$GetConcentration(sol)
