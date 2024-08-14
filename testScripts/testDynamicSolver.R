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

solved <- World$Solve(emissions)


SB.K <- solved

names_solved <- colnames(SB.K)

names_emis <- paste(names_solved, "_emis", "")

names <- c("Timed", names_solved, names_emis)

colnames(solved) <- names




emislist <- list(approxfun(emissions$Timed, emissions$Emis))


emis_fun <- emislist[["w1CS"]]
names(emislist) <- "w1CS"


tmax <- 25 * (365.25 * 24 * 3600)  # Total number of seconds in 25 years
#generating approxfun for constant emissions
# Calculate emissions (constant rate)
emissions <- (average_emission * 1000) / ( 365.25 * 24 * 3600)  # Emissions rate in kg/second
times <- seq(0, tmax, length.out = 1000)
# Generate time points (assuming you want to interpolate over some interval)
emis_values <- rep(emissions, length(times))
# Create approxfun
emislist <- list(approxfun(times, emis_values))





SimpleBoxODE = function(t, m, parms) {
  
  with(as.list(c(parms, m)), {
    e <- c(rep(0, length(SBNames)))
    for (name in names(emislist)) {
      e[grep(name, SBNames)] <- emislist[[name]](t) 
    }
    dm <- K%*% m + e
    res <- c(dm)
    list(res, signal = e)
  })
}

SBsolve4 <- function( tmax = 1e10, nTIMES = 100, Engine, emislist) {
  
  SB.K = Engine
  SBNames = colnames(Engine)
  SB.m0 <- rep(0, length(SBNames))
  SBtime <- seq(0,tmax,length.out = nTIMES)
  
  
  out <- deSolve::ode(
    y = as.numeric(SB.m0),
    times = SBtime ,
    func = SimpleBoxODE,
    parms = list(K = SB.K, SBNames=SBNames, emislist= emislist),
    rtol = 1e-10, atol = 1e-2)
  #if(as.character(class(deS)[1])!="data.frame") return (list(errorstate="error", deS))
  colnames(out)[1:length(SBNames)+1] <- SBNames
  colnames(out)[grep("signal",colnames(out))] <- paste("emis",SBNames,sep = "2")
  as.data.frame(out) }

SolutionConstantApproxFun <- SBsolve4(tmax = 24*(365.25*24*3600),
                                      nTIMES = 25,
                                      Engine = World$exportEngineR(), 
                                      emislist = emislist)