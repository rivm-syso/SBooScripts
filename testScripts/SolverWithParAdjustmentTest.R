substance <- "GO-Chitosan"

source("baseScripts/initWorld_onlyParticulate.R")



# Define the file paths and corresponding compartment abbreviations
file_paths <- c("../Emissions/emissions/EU/Results_SinkDynamic_Air-GBM_EU_2024-01-30-11-43_12.csv", 
                "../Emissions/emissions/EU/Results_SinkDynamic_STsoil-GBM_EU_2024-01-30-11-43_12.csv",
                "../Emissions/emissions/EU/Results_SinkDynamic_SurfaceWater-GBM_EU_2024-01-30-11-43_12.csv")
compartment_abbrs <- c("aCS", "s1CS", "w1CS")

World$kaas
World$NewSolver("SBsteady")
emissions <- data.frame(Abbr = "aRC", Emis = 1)
World$Solve(emissions)
# Define the function for interpolation
avg_emisfun <- function(Y) {
  # Use approxfun to create a linear interpolation function
  approxfun(data.frame(year = Y$Year_in_seconds ,
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
  avg_Emissions <- data.frame(Column = names(avg_values), Emis = avg_values*1000)
  
  # Add the Abbr column
  avg_Emissions$Abbr <- abbr
  
  # Remove the first row
  avg_Emissions <- avg_Emissions[-1, ]
  
  # Extract the year from the Column names
  avg_Emissions$Year <- as.integer(sub("X", "", avg_Emissions$Column))
  avg_Emissions$Year_in_seconds <- avg_Emissions$Year * 365.25 *24 * 360
  
  # Add the result to the list
  results_list[[abbr]] <- avg_Emissions
  interpolation_function <- avg_emisfun(avg_Emissions)
  
  # Store the interpolation with the appropriate name
  interpolations[[abbr]] <- interpolation_function
  
  # Define the times sequence
  times <- seq(0, 24*365.25*24*360, by = 10000)
  
  # Interpolate emissions for each time point
  interpolated_emissions <- interpolation_function(times)
  
  # Create a dataframe for plotting
  output_emissions <- data.frame(Year_in_seconds = times, Emis = interpolated_emissions, Abbr = abbr)
  
  # Add to the output emissions list
  output_emissions_list[[abbr]] <- output_emissions
}


#interpolations <- do.call(rbind, interpolations)
emissions <- do.call(rbind, output_emissions_list)
emissionsum <-sum(emissions$Emis)
print(emissions)
func_aCS<- interpolations$aCS
func_s1CS <- interpolations$s1CS
func_w1CS <- interpolations$w1CS

# Plot the interpolation function
ggplot(emissions, aes(x = Year_in_seconds, y = Emis, color = Abbr)) +
  geom_line() +
  labs(x = "seconds", y = "Emissions (kg)", color = "Compartment") +
  ggtitle("Interpolation Functions for Air, Soil, and Water") +
  theme_minimal()


#dummy data 
particle_sizes <- seq(from = 10, to = 1000, length.out = 5)
print(particle_sizes)
#Generation of matrix 
result_engine <- list()
result_sedimentation <- list()
result_index <- 1

# Loop through particle sizes
for (i in seq_along(particle_sizes)) {
  print(i)
  size <- particle_sizes[i]
  World$SetConst(RadS = size)
  World$UpdateKaas(mergeExisting = F)
  sedimentation <- World$moduleList[["k_Sedimentation"]]$execute()
  sedimentation$particle_size <- size
  result_sedimentation[[result_index]] <- sedimentation
  World$NewSolver("SBsteady")
  World$Solve(emissions)
  Engine <-World$exportEngineR()
  result_engine[[result_index]] <- Engine
  result_index <- result_index + 1
  rm(Engine, sedimentation)
}

combined_sedimentation <- do.call(rbind, result_sedimentation)
test_sedimentation <- subset(combined_sedimentation, toSubCompart =="freshwatersediment" & fromSpecies == "Small")

ggplot(test_sedimentation, aes(x = particle_size, y = k)) +
  geom_point() +
  labs(title = "Sedimentation",
       x = "Particle Size",
       y = "Sedimentation") +
  theme_minimal()

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

# exporting Engine
Engine_1 <- result_engine[[1]]
SBNames <-colnames(Engine_1)
print(SBNames)
print(SBNames)
SB.m0 <- rep(0, length(SBNames))
print(length(SB.m0))

SBsolve4 <- function(tmax = 1e10, nTIMES = 100, Engine) {
  
  SB.K <- Engine
  
  SBtime <- seq(0, tmax, length.out = nTIMES)
  
  out <- deSolve::ode(
    y = as.numeric(SB.m0),
    times = SBtime,
    func = SimpleBoxODE,
    parms = list(K = SB.K, SBNames, func_aCS, func_s1CS, func_w1CS),
    rtol = 1e-10, atol = 1e-2
  )
  
  return(out)
}

# Initialize a list to store the solutions
Solutions <- list()

# Loop through each Engine and solve
for (i in seq_along(result_engine)) {
  print(i)
  Solution <- SBsolve4(tmax = 24 * (365.25 * 24 * 360), nTIMES = 130, Engine = result_engine[[i]])
  Solutions[[i]] <- Solution
  rm(Solution)
}

Solution_1 <- Solutions[[1]]
abs_diff <- abs(Solutions[[1]] - Solutions[[3]])
print(abs_diff)
