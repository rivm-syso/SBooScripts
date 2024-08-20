##################### Example with data frame as input #########################

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






################## Example with list of functions as input #####################

substance <- "microplastic"
source("baseScripts/initWorld_onlyPlastics.R")
World$substance <- substance

# Voorbeeld met dataframe
emissions <- data.frame(Abbr = c("aRS", "s2RS", "w1RS","aRS", "s2RS", "w1RS"), Emis = c(10, 10, 10,20, 20, 20), Timed = c(1, 2, 3, 4, 5, 6)) # convert 1 t/y to si units: kg/s

emissions <- emissions |>
  mutate(Timed = Timed*(365.25*24*60*60)) |> ungroup()

SBEmissions3 <- 
  emissions |> 
  group_by(Abbr) |> 
  summarise(n=n(),
            EmisFun = list(
              approxfun(
                data.frame(Timed = c(0,Timed), 
                           Emis=c(0,Emis)),
                rule = 2) # Change to rule 1:1 for no extrapolation
            )
  )

funlist <- SBEmissions3$EmisFun
names(funlist) <- SBEmissions3$Abbr

tmax <- 365.25*24*60*60*10
times <- seq(0, tmax, length.out = 10)

World$NewSolver("DynApproxSolve")
solved <- World$Solve(tmax = tmax, funlist, needdebug = F)



# Plot approxfun
times <- seq(0, 25*365.25*24*3600, by=10000)
PlotEmis <- funlist[["s2RS"]]
values <- sapply(times, PlotEmis)

plot(times, values, type = "l", lwd=2)

