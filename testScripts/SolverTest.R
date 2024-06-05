library(dplyr)
source("baseScripts/initWorld_onlyParticulate.R")
# Define the file paths and corresponding compartment abbreviations
file_paths <- c("../Emissions/emissions/EU/Results_SinkDynamic_Air-GBM_EU_2024-01-30-11-43_12.csv", 
                "../Emissions/emissions/EU/Results_SinkDynamic_STsoil-GBM_EU_2024-01-30-11-43_12.csv",
                "../Emissions/emissions/EU/Results_SinkDynamic_SurfaceWater-GBM_EU_2024-01-30-11-43_12.csv")
compartment_abbrs <- c("aCS", "s1CS", "w1CS")

World$kaas
World$NewSolver("SBsteady")
emissions <- data.frame(Abbr = "aRU", Emis = 1)
World$Solve(emissions)
# Define the function for interpolation
avg_emisfun <- function(Y) {
  # Use approxfun to create a linear interpolation function
  approxfun(data.frame(year = Y$Year ,
                       emis_kg = Y$Emis), rule = 1:2)
}

# Initialize an empty list to store the results
results_list <- list()
interpolations <- list()
output_emissions_list <- list()
# Loop over each file path and its corresponding compartment abbreviation
for (i in seq_along(file_paths)) {
  file <- file_paths[i]
  abbr <- compartment_abbrs[i]
  
  # Read the data
  Emissions <- read.csv(file)
  
  # Calculate the mean of each column, ignoring NA values
  avg_values <- sapply(Emissions, mean, na.rm = TRUE)
  
  # Create a new dataframe with the averages
  avg_Emissions <- data.frame(Column = names(avg_values), Emis = avg_values)
  
  # Add the Abbr column
  avg_Emissions$Abbr <- abbr
  
  # Remove the first row
  avg_Emissions <- avg_Emissions[-1, ]
  
  # Extract the year from the Column names
  avg_Emissions$Year <- as.integer(sub("X", "", avg_Emissions$Column))
  
  # Add the result to the list
  results_list[[abbr]] <- avg_Emissions
  interpolation_function <- avg_emisfun(avg_Emissions)
  
  # Store the interpolation with the appropriate name
  interpolations[[abbr]] <- interpolation_function
  
  # Define the times sequence
  times <- seq(0, 24, by = 0.1)
  
  # Interpolate emissions for each time point
  interpolated_emissions <- interpolation_function(times)
  
  # Create a dataframe for plotting
  output_emissions <- data.frame(seconds = times, Emis = interpolated_emissions, Abbr = abbr)
  
  # Add to the output emissions list
  output_emissions_list[[abbr]] <- output_emissions
}
#interpolations <- do.call(rbind, interpolations)
emissions <- do.call(rbind, output_emissions_list)

func_aCS<- interpolations$aCS
func_s1CS <- interpolations$s1CS
func_w1CS <- interpolations$w1CS

SB.K =World$kaas
print(SB.K)


SimpleBoxODE = function(t, m, parms) {
  
  with(as.list(c(parms, m)), {
    e <- c(rep(0, length(SBNames)))
  
    e[grep("aCS", SBNames)] <- func_aCS(t)
    e[grep("s1CS",SBNames)] <- func_s1CS(t)
    e[grep("w1CS",SBNames)] <- func_w1CS(t)
    dm <- K%*% m + e
    res <- c(dm)
    list(res, signal = e)
  })
}


Engine <-World$exportEngineR()
SB.K <-Engine
SBNames <-columnnames(Engine)
print(SBNames)
print(SBNames)
SB.m0 <- rep(0, length(SBNames))
print(length(SB.m0))
SBsolve4 <- function( tmax = 1e10, nTIMES = 100) {
  
  SB.K <- Engine
  
  SBtime <- seq(0,tmax,length.out = nTIMES)
  
  
  deS <- deSolve::ode(
    y = as.numeric(SB.m0),
    times = SBtime,
    func = SimpleBoxODE,
    parms = list(K = SB.K, SBNames,func_aCS, func_s1CS, func_w1CS),
    rtol = 1e-30, atol = 1e-7)
  #if(as.character(class(deS)[1])!="data.frame") return (list(errorstate="error", deS))
  
}

Solution <- SBsolve4(tmax = 24, nTIMES = 24)
Solution.df <- as.data.frame(Solution)
Solution_compartments <- Solution[, 1:155]
colnames(Solution_compartments)[1:155] <- SBNames

