substance <- "default substance"
source("baseScripts/initWorld_onlyMolec.R")
World$substance <- substance

# Voorbeeld met dataframe
emissions <- data.frame(Abbr = c("aRU", "s2RU", "w1RU"), Emis = c(10000, 10000, 10000)) # convert 1 t/y to si units: kg/s

emissions <- emissions |>
  mutate(Emis = Emis*1000/(365*24*60*60)) 

World$NewSolver("SB1Solve")

solved2 <- World$Solve(emissions, needdebug = F)

sol <- World$Solution()
World$GetConcentration()

#### Test for dynamic 
substance <- "microplastic"
source("baseScripts/initWorld_onlyPlastics.R")
World$substance <- substance

# Voorbeeld met dataframe
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS","aRS", "s2RS", "w1RS"), Emis = c(10, 10, 10,20, 20, 20), Timed = c(1, 2, 3, 4, 5, 6)) # convert 1 t/y to si units: kg/s

emissions <- emissions |>
  mutate(Timed = Timed*(365.25*24*60*60)) |> ungroup()

tmax <- 365.25*24*60*60*10
times <- seq(0, tmax, length.out = 10)

World$NewSolver("DynApproxSolve")
solved <- World$Solve(tmax = tmax, emissions, needdebug = F)

c2 <- World$GetConcentration()



